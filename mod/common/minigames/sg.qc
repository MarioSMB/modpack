#include "sg.qh"
REGISTER_MINIGAME(sg, _("Space Guns"));

// minigame flags
const int SG_STATUS_PLAY = 0x0020; // playing
const int SG_STATUS_WIN = 0x0040; // player has won
const int SG_STATUS_NEXT = 0x0080; // player has won

const float SG_TURN_TEAM1 = 0x0001;
const float SG_TURN_TEAM2 = 0x0002;
const float SG_TURN_TEAM  = 0x000f; // turn team mask

// send flags
// (minigame_player) sent when reporting scores
const int SG_SF_PLAYERSCORE = MINIG_SF_CUSTOM;

// keys
const int SG_KEY_INCREASE = 0x01; // Move down/right
const int SG_KEY_DECREASE = 0x02; // Move up/left
const int SG_KEY_BOTH     = 0x03; // Player jamming keys at ramdom
const int SG_KEY_SHOOT    = 0x04; // Shooting

// fields
const int SG_MAX_PLAYERS = 2;
const int SG_SPECTATOR_TEAM = 255; // must be above max teams and equal to or below 255
.int    pong_score;                    // (minigame_player) number of goals
.int    sg_keys;                     // (client) pressed keys
.entity sg_shooters[SG_MAX_PLAYERS];// (minigame) shooters
.float  pong_length;                   // (sg_shooter/sg_bullet) size (0,1)
.entity sg_ai_shooter;                // (sg_ai) controlled shooter entity
.bool sg_invincible;                 // (sg_shooter) invincibility frame when spawning
.float sg_delay;                     // (sg_shooter) delay between attacks

#ifdef SVQC

int autocvar_sv_minigames_sg_maxscore = 5;

float autocvar_sv_minigames_sg_shooter_size = 0.1;
float autocvar_sv_minigames_sg_shooter_speed = 1;
//float autocvar_sv_minigames_sg_shooter_wait = 1; // TODO: what was this for?

float autocvar_sv_minigames_sg_bullet_speed = 1.5;
float autocvar_sv_minigames_sg_bullet_radius = 0.015;
float autocvar_sv_minigames_sg_bullet_refire = 0.25;
float autocvar_sv_minigames_sg_bullet_offset = 0.05;

float autocvar_sv_minigames_sg_ai_thinkspeed = 0.1;
float autocvar_sv_minigames_sg_ai_tolerance = 0.23;

// Add the score to the given team in the minigame
void sg_add_score(entity minigame, int team_killer)
{
	if ( !minigame )
		return;

	entity shooter = minigame.sg_shooters[team_killer-1];
	if ( shooter.realowner.minigame_players )
	{
		shooter.realowner.minigame_players.pong_score += 1;
		shooter.realowner.minigame_players.SendFlags |= SG_SF_PLAYERSCORE;
	}
}

// get point in the box nearest to the given one (2D)
vector sg_box_nearest(vector box_min, vector box_max, vector p)
{
	return vec2( p.x > box_max.x  ? box_max.x  : ( p.x < box_min.x ? box_min.x : p.x ),
		p.y > box_max.y  ? box_max.y  : ( p.y < box_min.y ? box_min.y : p.y ) );
}

// checks if the bullet hit the shooter for the given team
bool sg_shooter_hit(entity bullet, int pteam)
{
	entity shooter = bullet.owner.sg_shooters[pteam-1];
	if (!shooter || shooter.sg_invincible)
		return false;

#if 1
	vector near_point = sg_box_nearest(shooter.m_mins+shooter.origin,
									shooter.m_maxs+shooter.origin, bullet.origin);
	return vdist(near_point - bullet.origin, <=, bullet.pong_length);
#else
	return boxesoverlap(shooter.m_mins + shooter.origin, shooter.m_maxs + shooter.origin, bullet.m_mins + bullet.origin, bullet.m_maxs + bullet.origin);
#endif
}

bool sg_winner_team(entity bullet, int pteam)
{
	entity shooter = bullet.owner.sg_shooters[pteam-1];
	if(!shooter)
		return false;
	return ( shooter.realowner.minigame_players && shooter.realowner.minigame_players.pong_score >= autocvar_sv_minigames_sg_maxscore );
}

vector sg_team_to_shooterpos(int nteam);
void sg_shooter_reset(entity shooter)
{
	shooter.origin = sg_team_to_shooterpos(shooter.team);
	shooter.sg_invincible = true;
	shooter.realowner.minigame_players.sg_keys = 0;
	shooter.SendFlags |= MINIG_SF_UPDATE;
}

// Checks for a goal, when that happes adds scores and resets the shooter
void sg_shooter_die(entity bullet, int pteam)
{
	entity shooter = bullet.owner.sg_shooters[pteam-1];
	if (!shooter)
		return; // TODO?

	sg_add_score(bullet.owner, bullet.team);
	if(sg_winner_team(bullet, bullet.team))
	{
		entity minigame = shooter.owner;
		minigame.minigame_flags = SG_STATUS_WIN | bullet.team;
		minigame_server_sendflags(minigame,MINIG_SF_UPDATE);
		return;
	}

	sg_shooter_reset(shooter);
}

void sg_bullet_destroy(entity this)
{
	delete(this);
}

// Moves the bullet around
void sg_bullet_think(entity this)
{
	float think_speed = autocvar_sys_ticrate;
	this.nextthink = time + think_speed;

	if(!(this.owner.minigame_flags & SG_STATUS_PLAY))
	{
		sg_bullet_destroy(this);
		return;
	}

	//this.origin_x += this.velocity_x * think_speed;
	this.origin_y += this.velocity_y * think_speed;
	this.SendFlags |= MINIG_SF_UPDATE;

	int i;
	for ( i = 1; i <= SG_MAX_PLAYERS; i++ )
		if ( i != this.team && sg_shooter_hit(this, i) )
		{
			sg_shooter_die(this,i);
			sg_bullet_destroy(this);
			return;
		}

	// destroy the ball if it reaches the edge of the screen
	if ( this.origin_y <= this.pong_length || this.origin_y >= 1-this.pong_length )
		sg_bullet_destroy(this);
}

// Spawn a bullet above the player
void sg_bullet_spawn(entity shooter)
{
	entity bullet = msle_spawn(shooter.owner,new(pong_ball));
	bullet.pong_length = autocvar_sv_minigames_sg_bullet_radius;
	bullet.m_mins = vec2(-bullet.pong_length, -bullet.pong_length);
	bullet.m_maxs = vec2(bullet.pong_length, bullet.pong_length);
	setthink(bullet, sg_bullet_think);
	bullet.nextthink = time;
	bullet.team = shooter.team;
	bullet.SendFlags |= MINIG_SF_UPDATE;
	float bullet_dir = (shooter.team == 1) ? -1 : 1;
	bullet.origin = shooter.origin + '0 1 0' * (bullet_dir * autocvar_sv_minigames_sg_bullet_offset);

	bullet.velocity = vec2(0, bullet_dir * autocvar_sv_minigames_sg_bullet_speed);
}

// AI action
void sg_ai_think(entity this)
{
	float think_speed = autocvar_sv_minigames_sg_ai_thinkspeed;
	this.nextthink = time + think_speed;

	this.sg_keys = 0;
	if(!(this.owner.minigame_flags & SG_STATUS_PLAY))
		return;

	entity targ = NULL;
	int i;
	for ( i = 1; i <= SG_MAX_PLAYERS; i++ )
		if ( i != this.team )
		{
			targ = this.owner.sg_shooters[i-1];
			break;
		}

	if(targ && !targ.sg_invincible)
	{
		if(targ.origin.x > this.sg_ai_shooter.origin.x)
		{
			this.sg_keys = SG_KEY_INCREASE;
			this.sg_invincible = false;
		}
		else if(targ.origin.x < this.sg_ai_shooter.origin.x)
		{
			this.sg_keys = SG_KEY_DECREASE;
			this.sg_invincible = false;
		}

		if((targ.origin.x - this.sg_ai_shooter.origin.x) <= autocvar_sv_minigames_sg_ai_tolerance)
		{
			this.sg_keys |= SG_KEY_SHOOT;
			this.sg_invincible = false;
		}
		else
		{
			this.sg_keys &= ~SG_KEY_SHOOT;
		}
	}
}

entity sg_ai_spawn(entity shooter)
{
	entity ai = msle_spawn(shooter.owner,new(pong_ai));
	ai.minigame_players = ai;
	ai.team = shooter.team;
	setthink(ai, sg_ai_think);
	ai.nextthink = time;
	ai.sg_ai_shooter = shooter;

	shooter.realowner = ai;

	return ai;
}

// Moves the shooter
void sg_shooter_think(entity this)
{
	float think_speed = autocvar_sys_ticrate;
	this.nextthink = time + think_speed;

	if(!(this.owner.minigame_flags & SG_STATUS_PLAY))
		return;

	if ( this.realowner.minigame_players.sg_keys & SG_KEY_INCREASE ||
		 this.realowner.minigame_players.sg_keys & SG_KEY_DECREASE )
	{
		float pmovement = autocvar_sv_minigames_sg_shooter_speed * think_speed;
		float halflen = this.pong_length/2;

		if ( this.realowner.minigame_players.sg_keys & SG_KEY_DECREASE )
			pmovement *= -1;

		this.origin_x = bound(halflen, this.origin_x+pmovement, 1-halflen);

		this.SendFlags |= MINIG_SF_UPDATE;
		this.sg_invincible = false;
	}

	if((this.realowner.minigame_players.sg_keys & SG_KEY_SHOOT) && (time >= this.sg_delay))
	{
		this.sg_invincible = false;
		sg_bullet_spawn(this);
		this.sg_delay = time + autocvar_sv_minigames_sg_bullet_refire;
	}
}

vector sg_team_to_box_halfsize(int nteam, float length, float width)
{
	return vec2(length/2, width/2);
}

vector sg_team_to_shooterpos(int nteam)
{
	switch(nteam)
	{
		case 1: return '0.5 0.99 0';
		case 2: return '0.5 0.01 0';
		default:return '0 0 0';
	}
}

// Spawns a sg shooter
// if real_player is NULL, the shooter is controlled by AI
entity sg_shooter_spawn(entity minigame, int pl_team, entity real_player)
{
	entity shooter = msle_spawn(minigame,new(pong_paddle));
	shooter.pong_length = autocvar_sv_minigames_sg_shooter_size;
	shooter.origin = sg_team_to_shooterpos(pl_team);
	setthink(shooter, sg_shooter_think);
	shooter.nextthink = time;
	shooter.team = pl_team;
	shooter.sg_invincible = true;
	shooter.m_mins = sg_team_to_box_halfsize(pl_team,-shooter.pong_length,-1/16);
	shooter.m_maxs = sg_team_to_box_halfsize(pl_team,shooter.pong_length,1/16);

	if ( real_player == NULL )
		sg_ai_spawn(shooter);
	else
		shooter.realowner = real_player;

	minigame.sg_shooters[pl_team-1] = shooter;

	return shooter;
}

bool sg_alone(entity minigame)
{
	int realplayers = 0;
	int i;
	for ( i = 1; i <= SG_MAX_PLAYERS; i++ )
	{
		entity shooter = minigame.sg_shooters[i-1];
		if ( shooter.realowner.classname == "pong_ai" )
			continue;
		realplayers += 1;
	}
	return (realplayers <= 1);
}

// request a new match
void sg_next_match(entity minigame, entity player)
{
#ifdef SVQC
	if(sg_alone(minigame))
		minigame.minigame_flags = SG_STATUS_NEXT; // force next match if alone
	// on multiplayer matches, wait for both players to agree
	if ( minigame.minigame_flags & (SG_STATUS_WIN) )
	{
		minigame.minigame_flags = SG_STATUS_NEXT | player.team;
		minigame.SendFlags |= MINIG_SF_UPDATE;
	}
	else if ( (minigame.minigame_flags & SG_STATUS_NEXT) &&
			!( minigame.minigame_flags & player.team ) )
#endif
	{
		minigame.minigame_flags = SG_STATUS_PLAY;
		minigame_server_sendflags(minigame,MINIG_SF_UPDATE);
		int i;
		for ( i = 1; i <= SG_MAX_PLAYERS; i++ )
		{
			entity shooter = minigame.sg_shooters[i-1];
			sg_shooter_reset(shooter);
			if ( shooter.realowner.minigame_players )
			{
				shooter.realowner.minigame_players.pong_score = 0;
				shooter.realowner.minigame_players.SendFlags |= SG_SF_PLAYERSCORE;
			}
		}
	}
}

// required function, handle server side events
int sg_server_event(entity minigame, string event, ...)
{
	switch (event)
	{
		case "start":
		{
			minigame.minigame_flags |= SG_STATUS_PLAY;
			// keep declaration here, moving it into for() reverses weapon order
			// potentially compiler bug
			int j;
			for ( j = 0; j < SG_MAX_PLAYERS; j++ )
			//for ( int j = 0; j < SG_MAX_PLAYERS; j++ )
			{
				if ( minigame.sg_shooters[j] == NULL )
				{
					sg_shooter_spawn(minigame,j+1,NULL);
				}
			}
			return true;
		}
		case "join":
		{
			// Don't allow joining a match that is already running
			//if ( minigame.minigame_flags & SG_STATUS_PLAY )
				//return SG_SPECTATOR_TEAM;

			entity player = ...(0,entity);
			int i;
			for ( i = 0; i < SG_MAX_PLAYERS; i++ )
			{
				entity shooter = minigame.sg_shooters[i];
				if ( shooter == NULL || shooter.realowner.classname == "pong_ai" )
				{
					// clear the ai if it exists to make room for the player
					if(shooter.realowner.classname == "pong_ai")
					{
						minigame.sg_shooters[i] = NULL;
						delete(shooter.realowner);
						delete(shooter);
					}
					sg_shooter_spawn(minigame,i+1,player);
					return i+1;
				}
			}

			return SG_SPECTATOR_TEAM;
		}
		case "part":
		{
			entity player = ...(0,entity);
			entity shooter;
			entity ai;
			int i;
			for ( i = 0; i < SG_MAX_PLAYERS; i++ )
			{
				shooter = minigame.sg_shooters[i];
				if ( shooter != NULL && shooter.realowner == player )
				{
					ai = sg_ai_spawn(shooter);
					ai.pong_score = player.minigame_players.pong_score;
					break;
				}

			}
			return false;
		}
		case "cmd":
		{
			entity player = ...(0,entity);
			bool event_blocked = (player.team == SG_SPECTATOR_TEAM);
			switch(argv(0))
			{
				case "next":
					if(event_blocked)
						return true;
					sg_next_match(minigame,...(0,entity));
					return true;
				case "+movei":
					if(event_blocked)
						return true;
					player.sg_keys |= SG_KEY_INCREASE;
					return true;
				case "+moved":
					if(event_blocked)
						return true;
					player.sg_keys |= SG_KEY_DECREASE;
					return true;
				case "-movei":
					if(event_blocked)
						return true;
					player.sg_keys &= ~SG_KEY_INCREASE;
					return true;
				case "-moved":
					if(event_blocked)
						return true;
					player.sg_keys &= ~SG_KEY_DECREASE;
					return true;
				case "move":
					if(event_blocked)
						return true;
					if(argv(1))
						player.sg_keys = stoi(argv(1));
					return true;
				case "+shoot":
					if(event_blocked)
						return true;
					player.sg_keys |= SG_KEY_SHOOT;
					return true;
				case "-shoot":
					if(event_blocked)
						return true;
					player.sg_keys &= ~SG_KEY_SHOOT;
					return true;
			}
			return false;
		}
		case "network_send":
		{
			entity sent = ...(0,entity);
			int sf = ...(1,int);
			if ( sent.classname == "minigame_player" && (sf & SG_SF_PLAYERSCORE ) )
			{
				WriteLong(MSG_ENTITY,sent.pong_score);
			}
			return false;
		}
	}
	return false;
}


#elif defined(CSQC)

void drawrotpic(vector org, float rot, string pic, vector sz, vector hotspot, vector rgb, float a, float f);

float sg_team_to_angle(int nteam)
{
	switch(nteam)
	{
		default:
		case 1: return M_PI/2;
		case 2: return M_PI*3/2;
	}
}

vector sg_team_to_color(int nteam)
{
	switch(nteam)
	{
		case 1: return '1 0 0';
		case 2: return '0 0 1';
		default:return '1 1 1';
	}
}

int sg_keys_pressed;
int sg_keys_pressed_old;

// Required function, draw the game board
void sg_hud_board(vector pos, vector mySize)
{
	if(sg_keys_pressed != sg_keys_pressed_old)
		minigame_cmd(strcat("move ", itos(sg_keys_pressed)));
	sg_keys_pressed_old = sg_keys_pressed;

	minigame_hud_fitsqare(pos, mySize);
	minigame_hud_simpleboard(pos,mySize,minigame_texture("sg/board"));

	entity e;
	vector obj_pos;
	vector obj_size;
	FOREACH_MINIGAME_ENTITY(e)
	{
		if ( e.classname == "pong_ball" )
		{
			// Note: 4*radius = 2*diameter because the image is large enough to fit the glow around the bullet
			obj_size =  minigame_hud_denormalize_size('4 4 0'*e.pong_length,pos,mySize);
			obj_pos = minigame_hud_denormalize(e.origin,pos,mySize);

			minigame_drawpic_centered( obj_pos, minigame_texture("sg/bullet"),
					obj_size, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL );

			minigame_drawpic_centered( obj_pos, minigame_texture("sg/bullet-glow"),
					obj_size, sg_team_to_color(e.team),
					panel_fg_alpha, DRAWFLAG_ADDITIVE );
		}
		else if ( e.classname == "pong_paddle" )
		{
			obj_pos = minigame_hud_denormalize(e.origin,pos,mySize);
			obj_size = minigame_hud_denormalize_size(eX / 16 + eY*e.pong_length,pos,mySize);

			drawrotpic(obj_pos, sg_team_to_angle(e.team), minigame_texture("sg/shooter"),
				obj_size, obj_size/2, '1 1 1',
				panel_fg_alpha, DRAWFLAG_NORMAL );

		}
	}

	if ( active_minigame.minigame_flags & SG_STATUS_WIN )
	{
		vector winfs = hud_fontsize*2;
		string player_name = "AI"; // assume AI if player has no name
		FOREACH_ENTITY_ENT_ORDERED(owner, active_minigame,
		{
			if ( it.classname == "minigame_player" && 
					it.team == (active_minigame.minigame_flags & SG_TURN_TEAM) )
				player_name = entcs_GetName(it.minigame_playerslot-1);
		});
		
		vector win_pos = pos+eY*(mySize_y-winfs_y)/2;
		vector win_sz;
		win_sz = minigame_drawcolorcodedstring_wrapped(mySize_x,win_pos,
			sprintf("%s^7 won the game!",player_name), 
			winfs, 0, DRAWFLAG_NORMAL, 0.5);
		
		drawfill(win_pos-eY*hud_fontsize_y,win_sz+2*eY*hud_fontsize_y,'1 1 1',0.5,DRAWFLAG_ADDITIVE);
		
		minigame_drawcolorcodedstring_wrapped(mySize_x,win_pos,
			sprintf("%s^7 won the game!",player_name), 
			winfs, panel_fg_alpha, DRAWFLAG_NORMAL, 0.5);
	}
}

// Required function, draw the game status panel
void sg_hud_status(vector pos, vector mySize)
{
	HUD_Panel_DrawBg();
	vector ts;
	ts = minigame_drawstring_wrapped(mySize_x,pos,active_minigame.descriptor.message,
		hud_fontsize * 2, '0.25 0.47 0.72', panel_fg_alpha, DRAWFLAG_NORMAL,0.5);
	ts_y += hud_fontsize_y;
	pos_y += ts_y;
	mySize_y -= ts_y;

	vector player_fontsize = hud_fontsize * 1.75;
	ts_y = ( mySize_y - SG_MAX_PLAYERS*player_fontsize_y ) / SG_MAX_PLAYERS;
	ts_x = mySize_x;
	vector mypos;

	entity e;
	FOREACH_MINIGAME_ENTITY(e)
	{
		if ( (e.classname == "minigame_player" || e.classname == "pong_ai") && e.team != SG_SPECTATOR_TEAM )
		{
			mypos = pos;
			mypos_y  += (e.team-1) * (player_fontsize_y + ts_y);

			drawfill(mypos, ts, sg_team_to_color(e.team), 0.25, DRAWFLAG_ADDITIVE);

			minigame_drawcolorcodedstring_trunc(mySize_x,mypos,
				(e.minigame_playerslot ? entcs_GetName(e.minigame_playerslot-1) : _("AI")),
				player_fontsize, panel_fg_alpha, DRAWFLAG_NORMAL);

			drawstring(mypos+eY*player_fontsize_y,ftos(e.pong_score),'48 48 0',
					   '0.7 0.84 1', panel_fg_alpha, DRAWFLAG_NORMAL);

			if ( e == minigame_self )
				drawborderlines(1, mypos, ts, sg_team_to_color(e.team), 1, DRAWFLAG_NORMAL);
		}
	}
}

// convert minigame flags to a message
string sg_message(int mgflags)
{
	string rmessage = "";
	if(minigame_self.team == SG_SPECTATOR_TEAM)
		rmessage = _("You are spectating");
	else if ( mgflags & SG_STATUS_WIN )
	{
		// translator-friendly messages composed of 2 existing messages
		// TODO: proper "you win" banner instead of hijacking the help message
		if ( (mgflags & SG_TURN_TEAM) != minigame_self.team )
			rmessage = strcat(_("You lost the game!"), "\n", _("Select \"^1Next Match^7\" on the menu for a rematch!"));
		rmessage = strcat(_("You win!"), "\n", _("Select \"^1Next Match^7\" on the menu to start a new match!"));
	}
	else if ( mgflags & SG_STATUS_NEXT )
	{
		if ( (mgflags & SG_TURN_TEAM) != minigame_self.team )
			rmessage = _("Select \"^1Next Match^7\" on the menu to start a new match!");
		rmessage = _("Wait for your opponent to confirm the rematch");
	}
	else if (mgflags & SG_STATUS_PLAY)
		rmessage = _("Use the arrow keys to move and hold the space bar to shoot");
	return rmessage;
}

// Required function, handle client events
int sg_client_event(entity minigame, string event, ...)
{
	switch(event)
	{
		case "activate":
		{
			sg_keys_pressed = sg_keys_pressed_old = 0;
			return false;
		}
		case "deactivate":
		{
			strfree(minigame.message);
			return false;
		}
		case "key_pressed":
		case "key_released":
			if ((minigame.minigame_flags & SG_STATUS_PLAY) && minigame_self.team != SG_SPECTATOR_TEAM)
				switch ( ...(0,int) )
				{
					case K_UPARROW:
					case K_KP_UPARROW:
					case K_LEFTARROW:
					case K_KP_LEFTARROW:
						if (event == "key_pressed")
						{
							//minigame_cmd("+moved");
							sg_keys_pressed |= SG_KEY_DECREASE;
						}
						else
						{
							//minigame_cmd("-moved");
							sg_keys_pressed &= ~SG_KEY_DECREASE;
						}
						return true;
					case K_DOWNARROW:
					case K_KP_DOWNARROW:
					case K_RIGHTARROW:
					case K_KP_RIGHTARROW:
						if (event == "key_pressed")
						{
							//minigame_cmd("+movei");
							sg_keys_pressed |= SG_KEY_INCREASE;
						}
						else
						{
							//minigame_cmd("-movei");
							sg_keys_pressed &= ~SG_KEY_INCREASE;
						}
						return true;
					case K_SPACE:
						if (event == "key_pressed")
						{
							//minigame_cmd("+movei");
							sg_keys_pressed |= SG_KEY_SHOOT;
						}
						else
						{
							//minigame_cmd("-movei");
							sg_keys_pressed &= ~SG_KEY_SHOOT;
						}
						return true;
				}
			return false;
		case "network_receive":
		{
			entity sent = ...(0,entity);
			int sf = ...(1,int);
			if ( sent.classname == "minigame_player" && (sf & SG_SF_PLAYERSCORE ) )
			{
				sent.pong_score = ReadLong();
			}
			else if ( sent.classname == "minigame" )
			{
				if ( sf & MINIG_SF_UPDATE )
				{
					strcpy(sent.message, sg_message(sent.minigame_flags));
					if(minigame.minigame_flags & SG_STATUS_WIN)
						sg_keys_pressed = sg_keys_pressed_old = 0;
				}
			}
			return false;
		}
		case "menu_show":
		{
			HUD_MinigameMenu_CustomEntry(...(0,entity),_("Next Match"),"next");
			return false;
		}
		case "menu_click":
		{
			string cmd = ...(0,string);
			if(cmd == "next")
			{
				minigame_cmd("next");
			}
			return false;
		}
	}

	return false;
}
#endif
