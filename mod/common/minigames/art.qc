REGISTER_MINIGAME(art, "Pixel Art");

REGISTER_NET_LINKED(ENT_CLIENT_ART_CONTROLLER)

// 240 tiles...
const int ART_LET_CNT = 16;
const int ART_NUM_CNT = 16;

const int ART_TILE_SIZE = 16;

const int ART_TEAMS = 6;
const int ART_SPECTATOR_TEAM = 255; // must be above max teams and equal to or below 255

// send flags
const int ART_SF_COLOR = MINIG_SF_CUSTOM;
const int ART_SF_UPDATE_SINGLE = MINIG_SF_CUSTOM<<1;
const int ART_SF_UPDATE_ALL = MINIG_SF_CUSTOM<<2;

.vector art_color;

.int art_tilelet;

.vector art_tilecolor[ART_LET_CNT];

#ifdef SVQC
.int art_forceupdate;
#endif

// find same game piece given its tile name
entity art_find_controller(entity minig, int letter)
{
	entity e = NULL;
	while ( ( e = findentity(e,owner,minig) ) )
		if ( e.classname == "art_controller" && e.art_tilelet == letter )
			return e;
	return NULL;
}

// check if the tile name is valid (16x16 grid)
bool art_valid_tile(string tile)
{
	if ( !tile )
		return false;
	int number = minigame_tile_number(tile);
	int letter = minigame_tile_letter(tile);
	return 0 <= number && number < ART_NUM_CNT && 0 <= letter && letter < ART_LET_CNT;
}

void art_controller_setnumber(entity controller, int number)
{
#ifdef SVQC
	controller.art_forceupdate = number;
#endif
	minigame_server_sendflags(controller,ART_SF_UPDATE_SINGLE);
}

// editor
void art_editor_place(entity minigame, entity player, string pos, vector thecolor)
{
	if ( pos && thecolor.x >= 0 && thecolor.y >= 0 && thecolor.z >= 0 )
	{
		if ( art_valid_tile(pos) )
		{
			int number = minigame_tile_number(pos);
			int letter = minigame_tile_letter(pos);
			entity controller = art_find_controller(minigame, letter);

			controller.art_tilecolor[number] = thecolor;

			art_controller_setnumber(controller, number);
		}
	}
}

void art_do_move(entity minigame, entity player, string pos)
{
	art_editor_place(minigame, player, pos, player.art_color);
}

void art_set_color(entity minigame, entity player, string thecolor)
{
	vector col = '0 0 0';
	if(thecolor)
		col = stov(thecolor);

	player.art_color = col;
	minigame_server_sendflags(player,ART_SF_COLOR);
}

#ifdef SVQC
bool art_controller_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_ART_CONTROLLER);
	if(sf & ART_SF_UPDATE_ALL)
		sf &= ~ART_SF_UPDATE_SINGLE;

	WriteByte(MSG_ENTITY, sf);
	WriteByte(MSG_ENTITY, this.art_tilelet);
	WriteString(MSG_ENTITY,this.owner.netname);

	if(sf & ART_SF_UPDATE_SINGLE)
	{
		int number = this.art_forceupdate;
		//this.art_forceupdate = 0;
		vector col = this.art_tilecolor[number];
		WriteByte(MSG_ENTITY, number);
		WriteByte(MSG_ENTITY, col.x * 255);
		WriteByte(MSG_ENTITY, col.y * 255);
		WriteByte(MSG_ENTITY, col.z * 255);
	}

	if(sf & ART_SF_UPDATE_ALL)
	{
		for(int j = 0; j < ART_LET_CNT; ++j)
		{
			vector col = this.art_tilecolor[j];
			//WriteByte(MSG_ENTITY, j);
			WriteByte(MSG_ENTITY, col.x * 255);
			WriteByte(MSG_ENTITY, col.y * 255);
			WriteByte(MSG_ENTITY, col.z * 255);
		}
	}

	return true;
}
#elif defined(CSQC)
void minigame_read_owner(entity this);

NET_HANDLE(ENT_CLIENT_ART_CONTROLLER, bool isNew)
{
	this.classname = "art_controller";
	return = true;

	int sf = ReadByte();
	this.art_tilelet = ReadByte();
	minigame_read_owner(this);

	if(sf & ART_SF_UPDATE_SINGLE)
	{
		int number = ReadByte();
		this.art_tilecolor[number] = vec3(ReadByte() / 255, ReadByte() / 255, ReadByte() / 255);
	}

	if(sf & ART_SF_UPDATE_ALL)
	{
		for(int j = 0; j < ART_LET_CNT; ++j)
		{
			this.art_tilecolor[j] = vec3(ReadByte() / 255, ReadByte() / 255, ReadByte() / 255);
		}
	}
}
#endif

void art_setup_pieces(entity minigame)
{
	entity e = NULL;
	while( (e = findentity(e, owner, minigame)) )
		if(e.classname == "art_controller")
		{
			delete(e);
		}

	for(int letter = 0; letter < ART_LET_CNT; ++letter)
	{
		entity controller = new_pure(art_controller);
		controller.owner = minigame;
		controller.art_tilelet = letter;
	#ifdef SVQC
		Net_LinkEntity(controller, false, 0, art_controller_send);
	#endif
	}

	minigame_server_sendflags(minigame,MINIG_SF_UPDATE);
}

#ifdef SVQC

// required function, handle server side events
int art_server_event(entity minigame, string event, ...)
{
	switch(event)
	{
		case "start":
		{
			art_setup_pieces(minigame);

			return true;
		}
		case "end":
		{
			entity e = NULL;
			while( (e = findentity(e, owner, minigame)) )
			if(e.classname == "art_controller")
			{
				delete(e);
			}
			return false;
		}
		case "join":
		{
			int pl_num = minigame_count_players(minigame);

			if(pl_num >= ART_TEAMS) { return ART_SPECTATOR_TEAM; }

			// Get the right team
			if(minigame.minigame_players)
				return minigame_next_team(minigame.minigame_players.team, ART_TEAMS);

			// Team 1 by default
			return 1;
		}
		case "cmd":
		{
			entity player = ...(0,entity);
			bool event_blocked = (player.team == ART_SPECTATOR_TEAM);
			switch(argv(0))
			{
				case "move":
					if(event_blocked)
						return true;
					art_do_move(minigame, ...(0,entity), ((...(1,int)) >= 2 ? argv(1) : string_null));
					return true;
				case "color":
					if(event_blocked)
						return true;
					art_set_color(minigame, ...(0,entity), ((...(1,int)) >= 2 ? argv(1) : string_null));
					return true;
				case "restart":
					if(event_blocked)
						return true;
					art_setup_pieces(minigame);
					return true;
			}

			return false;
		}
		case "network_send":
		{
			entity sent = ...(0,entity);
			int sf = ...(1,int);
			if(sent.classname == "minigame_player" && (sf & ART_SF_COLOR))
			{
				WriteByte(MSG_ENTITY,sent.art_color.x * 255);
				WriteByte(MSG_ENTITY,sent.art_color.y * 255);
				WriteByte(MSG_ENTITY,sent.art_color.z * 255);
			}
			return false;
		}
	}

	return false;
}


#elif defined(CSQC)

vector art_curr_color;
string art_curr_pos;

vector art_boardpos; // HUD board position
vector art_boardsize;// HUD board size

vector art_get_tile_color(vector col)
{
	if(!col.y && !col.z)
		return colormapPaletteColor(rint(col.x * 10), false);
	return col;
}

// Required function, draw the game board
void art_hud_board(vector pos, vector mySize)
{
	minigame_hud_fitsqare(pos, mySize);
	art_boardpos = pos;
	art_boardsize = mySize;

	minigame_hud_simpleboard(pos,mySize,minigame_texture("art/board"));

	vector tile_size = minigame_hud_denormalize_size('1 1 0' / ART_TILE_SIZE,pos,mySize);
	vector tile_pos;

	entity e = NULL;
	FOREACH_MINIGAME_ENTITY(e)
	{
		if ( e.classname == "art_controller" )
		{
			for(int j = 0; j < ART_LET_CNT; ++j)
			{
				if(!e.art_tilecolor[j]) continue;

				int letter = e.art_tilelet;
				string mypos = minigame_tile_buildname(letter, j);

				tile_pos = minigame_tile_pos(mypos,ART_NUM_CNT,ART_LET_CNT);
				tile_pos = minigame_hud_denormalize(tile_pos,pos,mySize);

				minigame_drawpic_centered( tile_pos,
						minigame_texture("art/piece"),
						tile_size, art_get_tile_color(e.art_tilecolor[j]), panel_fg_alpha, DRAWFLAG_NORMAL );
			}	
		}
	}

	if(art_valid_tile(art_curr_pos))
	{
		tile_pos = minigame_tile_pos(art_curr_pos,ART_LET_CNT,ART_NUM_CNT);
		tile_pos = minigame_hud_denormalize(tile_pos,pos,mySize);

		minigame_drawpic_centered( tile_pos,
				minigame_texture("art/piece"),
				tile_size * 0.7, art_get_tile_color(art_curr_color), panel_fg_alpha/2, DRAWFLAG_NORMAL );
	}
}


// Required function, draw the game status panel
void art_hud_status(vector pos, vector mySize)
{
	HUD_Panel_DrawBg();
	vector ts = minigame_drawstring_wrapped(mySize.x, pos, active_minigame.descriptor.message,
		hud_fontsize * 2, '0.25 0.47 0.72', panel_fg_alpha, DRAWFLAG_NORMAL,0.5);
	ts.y += hud_fontsize.y;
	pos.y += ts.y;
	mySize.y -= ts.y;

	vector player_fontsize = hud_fontsize * 1.75;
	ts.y = player_fontsize.y + (mySize.y - ART_TEAMS * player_fontsize.y) / ART_TEAMS;
	ts.x = mySize_x;
	vector mypos;

	entity e;
	FOREACH_MINIGAME_ENTITY(e)
	{
		if ( e.classname == "minigame_player" && e.team != ART_SPECTATOR_TEAM )
		{
			mypos = pos + eY * (e.team - 1) * ts.y;

			if (e == minigame_self)
			{
				vector hl_size = '1 1 0';
				drawfill(mypos + hl_size, ts - 2 * hl_size, art_get_tile_color(art_curr_color), 0.25 * panel_fg_alpha, DRAWFLAG_ADDITIVE);
				drawborderlines(hl_size.x, mypos + hl_size, ts - 2 * hl_size, art_get_tile_color(art_curr_color), panel_fg_alpha, DRAWFLAG_NORMAL);
			}
			else
				drawfill(mypos, ts, art_get_tile_color(e.art_color), 0.25 * panel_fg_alpha, DRAWFLAG_ADDITIVE);

			minigame_drawcolorcodedstring_trunc(mySize.x - hud_fontsize.x * 0.5, mypos + eX * hud_fontsize.x * 0.25,
				entcs_GetName(e.minigame_playerslot - 1),
				player_fontsize, panel_fg_alpha, DRAWFLAG_NORMAL);

			mypos.y += player_fontsize.y;
			//drawstring_aspect(mypos, ftos(e.snake_score), ts - eY * player_fontsize.y - eX * ts.x * (3 / 4),
								//'0.7 0.84 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		}
	}
}

// Turn a set of flags into a help message
string art_turn_to_string(int turnflags)
{
	if(minigame_self.team == ART_SPECTATOR_TEAM)
		return _("You are spectating");
	return _("Press the space bar or right click to change your currently selected color");
}

// Make the correct move
void art_editor_make_move(entity minigame)
{
	minigame_cmd("move ", art_curr_pos);
}

void art_editor_set_color()
{
	minigame_cmd(sprintf("color %v", art_curr_color));
}

bool art_set_curr_pos(string s)
{
	return = false;

	if ( art_curr_pos )
	{
		if(s != art_curr_pos)
			return = true;
		strunzone(art_curr_pos);
	}
	if ( s )
		s = strzone(s);
	art_curr_pos = s;
}

bool art_normal_move(entity minigame, int themove)
{
	bool event_blocked = (minigame_self.team == ART_SPECTATOR_TEAM);
	switch ( themove )
	{
		case K_RIGHTARROW:
		case K_KP_RIGHTARROW:
			if (event_blocked)
				return true;
			art_editor_make_move(minigame);
			return true;
		case K_LEFTARROW:
		case K_KP_LEFTARROW:
			if (event_blocked)
				return true;
			art_editor_make_move(minigame);
			return true;
		case K_UPARROW:
		case K_KP_UPARROW:
			if (event_blocked)
				return true;
			art_editor_make_move(minigame);
			return true;
		case K_DOWNARROW:
		case K_KP_DOWNARROW:
			if (event_blocked)
				return true;
			art_editor_make_move(minigame);
			return true;
	}

	return false;
}

void art_increment_color()
{
	art_curr_color.x += 0.1;
	if(art_curr_color.x >= 1)
		art_curr_color.x = 0;

	art_editor_set_color();
}

bool art_editor_move(entity minigame, int themove)
{
	bool event_blocked = (minigame_self.team == ART_SPECTATOR_TEAM);
	switch ( themove )
	{
		case K_RIGHTARROW:
		case K_KP_RIGHTARROW:
			if (event_blocked)
				return true;
			if ( ! art_curr_pos )
				art_set_curr_pos("a3");
			else
				art_set_curr_pos(minigame_relative_tile(art_curr_pos,1,0,ART_NUM_CNT,ART_LET_CNT));
			return true;
		case K_LEFTARROW:
		case K_KP_LEFTARROW:
			if (event_blocked)
				return true;
			if ( ! art_curr_pos )
				art_set_curr_pos("c3");
			else
				art_set_curr_pos(minigame_relative_tile(art_curr_pos,-1,0,ART_NUM_CNT,ART_LET_CNT));
			return true;
		case K_UPARROW:
		case K_KP_UPARROW:
			if (event_blocked)
				return true;
			if ( ! art_curr_pos )
				art_set_curr_pos("a1");
			else
				art_set_curr_pos(minigame_relative_tile(art_curr_pos,0,1,ART_NUM_CNT,ART_LET_CNT));
			return true;
		case K_DOWNARROW:
		case K_KP_DOWNARROW:
			if (event_blocked)
				return true;
			if ( ! art_curr_pos )
				art_set_curr_pos("a3");
			else
				art_set_curr_pos(minigame_relative_tile(art_curr_pos,0,-1,ART_NUM_CNT,ART_LET_CNT));
			return true;
		case K_ENTER:
		case K_KP_ENTER:
			if (event_blocked)
				return true;
			art_editor_make_move(minigame);
			return true;
		case K_SPACE:
			if (event_blocked)
				return true;
			art_increment_color();
			return true;
	}

	return false;
}

bool mouse1_pressed;

// Required function, handle client events
int art_client_event(entity minigame, string event, ...)
{
	switch(event)
	{
		case "activate":
		{
			minigame.message = art_turn_to_string(minigame.minigame_flags);
			art_set_curr_pos("");
			art_curr_color = '0 0 0';
			mouse1_pressed = false;
			//art_editor_set_color();
			return false;
		}
		case "key_pressed":
		{
			if(art_editor_move(minigame, ...(0,int)))
				return true;

			return false;
		}
		case "mouse_pressed":
		{
			bool event_blocked = (minigame_self.team == ART_SPECTATOR_TEAM);
			if(...(0,int) == K_MOUSE1)
			{
				if (event_blocked)
					return true;
				mouse1_pressed = true;
				art_editor_make_move(minigame);
				return true;
			}

			if(...(0,int) == K_MOUSE2)
			{
				if (event_blocked)
					return true;
				art_increment_color();
				return true;
			}

			return false;
		}
		case "mouse_released":
		{
			if(...(0,int) == K_MOUSE1)
			{
				mouse1_pressed = false;
			}
		}
		case "mouse_moved":
		{
			if(minigame_self.team == ART_SPECTATOR_TEAM)
				return true;
			vector mouse_pos = minigame_hud_normalize(mousepos,art_boardpos,art_boardsize);
			bool changed = art_set_curr_pos(minigame_tile_name(mouse_pos,ART_LET_CNT,ART_NUM_CNT));
			if ( ! art_valid_tile(art_curr_pos) )
				art_set_curr_pos("");
			else if(mouse1_pressed && changed)
				art_editor_make_move(minigame);
			return true;
		}
		case "network_receive":
		{
			entity sent = ...(0,entity);
			int sf = ...(1,int);
			if ( sent.classname == "minigame" )
			{
				if ( sf & MINIG_SF_UPDATE )
				{
					sent.message = art_turn_to_string(sent.minigame_flags);
					//if ( sent.minigame_flags & minigame_self.team )
						minigame_prompt();
				}
			}
			else if(sent.classname == "minigame_player" && (sf & ART_SF_COLOR))
			{
				sent.art_color_x = ReadByte() / 255;
				sent.art_color_y = ReadByte() / 255;
				sent.art_color_z = ReadByte() / 255;

				if(sent == minigame_self)
					art_curr_color = sent.art_color; // keep up to date
			}

			return false;
		}
		case "menu_show":
		{
			HUD_MinigameMenu_CustomEntry(...(0,entity),_("Restart"),"restart");
			return false;
		}
		case "menu_click":
		{
			if(...(0,string) == "restart")
				minigame_cmd("restart");
			return false;
		}
	}

	return false;
}

#endif
