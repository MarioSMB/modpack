#include "dodgeball.qh"

//#include "bot.qh"
#include "sentry.qh"

#ifdef SVQC
void player_catch6(entity this) { set_animofs(this, anim_player_pain1, 6, player_run); }
void player_catch5(entity this) { set_animofs(this, anim_player_pain1, 6, player_catch6); }
void player_catch4(entity this) { set_animofs(this, anim_player_pain1, 6, player_catch5); }
void player_catch3(entity this) { set_animofs(this, anim_player_pain1, 6, player_catch4); }
void player_catch2(entity this) { set_animofs(this, anim_player_pain1, 6, player_catch3); }
void player_catch1(entity this) { set_animofs(this, anim_player_pain1, 1, player_run); this.nextthink = time + 0.2; }

void player_deflect3(entity this) { set_animofs(this, anim_player_axattd1, 3, player_run); }
void player_deflect2(entity this) { set_animofs(this, anim_player_axattd1, 3, player_deflect3); }
void player_deflect1(entity this) { set_animofs(this, anim_player_axattd1, 2, player_deflect2); }

entity SelectBallSpot()
{
	RandomSelection_Init();
	FOREACH_ENTITY_CLASS("info_ball_spot", true,
	{
		RandomSelection_AddEnt(it, 1, 1);
	});

	return RandomSelection_chosen_ent;
}

void put_ball(entity this)
{
	entity spot = SelectBallSpot();
	
	set_movetype(this, MOVETYPE_BOUNCE);
	this.solid = SOLID_BBOX;
	this.classname = "dodgeball";
	
	this.velocity_x = -100 + random()*200;
	this.velocity_y = -100 + random()*200;
	this.velocity_z = 300;
	
	this.avelocity = '300 300 300';
	
	this.angles = vectoangles(this.velocity);
	
	settouch(this, ball_touch);
	
	this.nextthink = time + 20;
	setthink(this, teleport_back);
	
	_setmodel(this, "progs/ball_db.mdl");
	setsize(this, '-5 -5 -5', '5 5 5');
	setorigin(this, spot.origin + '0 0 1');
	
	spawn_tfog(this.origin);
}

void put_sball(entity this)
{
	//entity plr = find(NULL, classname, "player");
	//if(plr)
	//{
		// must have at least one player
		entity spot;
		if(random() < 0.5)
			spot = SelectTeamSpawn(this, 1);
		else
			spot = SelectTeamSpawn(this, 2);
		
		setorigin(this, spot.origin + '0 0 1');
		spawn_tfog(this.origin);
		this.oldspecial = STAT(SPECIAL, this);
		DropSpecialBall(this);
	//}
	
	if(this.oldspecial)
		STAT(SPECIAL, this) = this.oldspecial;
	this.nextthink = time + 30 + random()*30;
	setthink(this, put_sball);
}

void put_copter(entity this)
{
	//entity plr = find(NULL, classname, "player");
	//if(plr)
	//{
		// must have at least one player
		entity spot;
		if(random() < 0.5)
			spot = SelectTeamSpawn(this, 1);
		else
			spot = SelectTeamSpawn(this, 2);
		
		setorigin(this, spot.origin + '0 0 1');
		spawn_tfog(this.origin);
		this.oldspecial = STAT(SPECIAL, this);
		DropSpecialBall(this);
	//}
	
	if(this.oldspecial)
		STAT(SPECIAL, this) = this.oldspecial;
	this.nextthink = time + 60 + random()*60;
	setthink(this, put_copter);
}

void put_sentryball(entity this)
{
	//entity plr = find(NULL, classname, "player");
	//if(plr)
	//{
		// must have at least one player
		entity spot;
		if(random() < 0.5)
			spot = SelectTeamSpawn(this, 1);
		else
			spot = SelectTeamSpawn(this, 2);
		
		setorigin(this, spot.origin + '0 0 1');
		spawn_tfog(this.origin);
		this.oldspecial = STAT(SPECIAL, this);
		DropSpecialBall(this);
	//}
	
	if(this.oldspecial)
		STAT(SPECIAL, this) = this.oldspecial;
	this.nextthink = time + 60 + random()*60;
	setthink(this, put_sentryball);
}

STATIC_INIT_LATE(Dodgeball)
{
	if(world.worldtype != WORLDTYPE_DODGEBALL)
		return;

	cvar_settemp("timelimit", ftos(autocvar_sv_quake_dodgeball_timelimit));

	ceasefire = true;
	last_team = (random() > 0.5) ? 1 : 2;

	db_init_delay = time + 7; // give players a chance to load in

	precache_sound("music/db_gold_wins.wav");
	precache_sound("music/db_green_wins.wav");

	int ballcount = max(1, autocvar_sv_quake_dodgeball_balls);

	while(ballcount > 0)
	{
		entity ball = spawn();
		ball.nextthink = time + 1 + random();
		setthink(ball, put_ball);
		ballcount -= 1;
	}

	//if(autocvar_sv_quake_dodgeball_classic)
	//{
		entity copter = new(copter);
		STAT(SPECIAL, copter) = 5;
		copter.nextthink = time + 60;
		setthink(copter, put_copter);
		
		entity sentryball = new(sentryball);
		STAT(SPECIAL, sentryball) = 6;
		sentryball.nextthink = time + 60;
		setthink(sentryball, put_sentryball);
	//}
	//if(autocvar_sv_quake_dodgeball_classic <= 1)
	//{
		int sballcount = 4;
		while(sballcount > 0)
		{
			entity sball = new(sball);
			STAT(SPECIAL, sball) = sballcount;
			sball.nextthink = time + 20 + random()*10;
			setthink(sball, put_sball);
			sballcount -= 1;
		}
	//}
}

PRECACHE(Dodgeball_Precache)
{
	precache_model("progs/v_nododgeball.mdl"); // always precached for the weapon
	precache_model("progs/v_dodgeball.mdl");

	if(world.worldtype != WORLDTYPE_DODGEBALL)
		return;

	// dodgeball sounds/models
	precache_sound("dodgeball/bounce_db.wav");
	precache_sound("dodgeball/catch_db.wav");
	precache_sound("dodgeball/deflect_woosh_db.wav");
	precache_sound("dodgeball/icehit_db.wav");
	precache_sound("dodgeball/hit1_db.wav");
	precache_sound("dodgeball/hit2_db.wav");
	precache_sound("dodgeball/powerthrow_db.wav");
	precache_sound("dodgeball/prison_door_db.wav");
	//precache_sound("dodgeball/sprinting_db.wav");
	precache_sound("speech/headshot_db.wav");
	precache_sound("speech/fight_db.wav");
	precache_sound("speech/roflcopter_db.wav");
	precache_sound("speech/takesome_db.wav");
	precache_sound("speech/coptergoes_db.wav");
	precache_sound("zombie/z_shot1.wav");
	precache_sound("hknight/attack1.wav");
	
	precache_model("progs/ball_db.mdl");
	precache_model("progs/ball2_db.mdl");
	precache_model("progs/ball3_db.mdl");
	precache_model("progs/player_db.mdl");
	precache_model("progs/player_db2.mdl");
	precache_model("progs/headless_db.mdl");
	precache_model("progs/v_catch.mdl");
	precache_model("progs/v_deflect.mdl");
	precache_model("progs/v_dodgeball2.mdl");
	precache_model("progs/v_dodgeball3.mdl");
	precache_model("progs/v_dodgeball4.mdl");
	precache_model("progs/v_hdodgeball.mdl");
	precache_model("progs/v_roflcopterball.mdl");
	precache_model("progs/v_spanner_ball.mdl");
	precache_model("progs/quake_flame2.mdl");
	precache_model("progs/ice_db.mdl");
	precache_model("progs/bigball_db.mdl");
	precache_model("progs/prop_db.mdl");
	precache_model("progs/sentry_stand_db.mdl");
	precache_model("progs/sentry_top_db.mdl");
	precache_model("progs/ball_roflcopter_db.mdl");
	precache_model("progs/ball_spanner_db.mdl");
}

void PutClientInServer(entity this);
void th_respawn(entity this)
{
	PutClientInServer(this.owner);
	delete(this);
}

void CheckRounds()
{
	int team1_players = 0, team1_dead = 0;
	int team2_players = 0, team2_dead = 0;

	FOREACH_CLIENT(IS_PLAYER(it),
	{
		if(it.team_no == 1)
		{
			team1_players += 1;
			if(it.health <= 0 || it.died)
				team1_dead += 1;
		}
		else if(it.team_no == 2)
		{
			team2_players += 1;
			if(it.health <= 0 || it.died)
				team2_dead += 1;
		}
	});

	if(team1_players == 0 || team2_players == 0)
		return;
	if(team1_dead < team1_players && team2_dead < team2_players)
		return;

	if(team1_dead == team1_players)
	{
		team2_score += 1;
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_WON, "Green", team1_score, team2_score);
		play2all("music/db_green_wins.wav");
	}
	if(team2_dead == team2_players)
	{
		team1_score += 1;
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_WON, "Gold", team1_score, team2_score);
		play2all("music/db_gold_wins.wav");
	}

	ceasefire = countdown = true;
	countdown_time = time + 10;
	
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		if(it.died)
		{
			it.died = false;
			entity temp = new_pure(delayed_respawn);
			temp.owner = it;
			temp.nextthink = time + 0.4 + 0.4*random();
			setthink(temp, th_respawn);
		}
		else
			it.health = 100;
	});

	if(team1_score >= autocvar_sv_quake_dodgeball_pointlimit || team2_score >= autocvar_sv_quake_dodgeball_pointlimit)
	{
		mapname = "dodgestart";
		NextLevel();
	}
}

void dodgeball_StartFrame()
{
	if(world.worldtype != WORLDTYPE_DODGEBALL)
	{
		//FOREACH_CLIENT(IS_BOT_CLIENT(it), { dropclient(it); });
		return;
	}

	if(db_init_delay && time > db_init_delay)
	{
		BeginGame();
		db_init_delay = 0; // ensure no repeats!
	}

	if(gameover)
		return;

	if(countdown)
	{
		int r = rint(countdown_time - time);
		if(r <= 0)
		{
			Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_COUNTDOWN_BEGIN);
			play2all("speech/fight_db.wav");
			ceasefire = countdown = false;
			game_started = true;
		}
		else
		{
			if(r < 6)
			{
				if(r != last_time)
				{
					last_time = r;
					Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_COUNTDOWN_GAMESTART, r);
				}
			}
		}
		return;
	}

	CheckRounds();

	//BotFrame();
}

void player_catch1(entity this);
void Catch(entity this)
{
	if(this.health <= 0 || this.died)
		return;
	if(STAT(HAS_BALL, this))
		return;

	if(IS_PLAYER(this))
		player_catch1(this);
	STAT(CATCHING, this) = time + 0.2;
}

void BeginGame()
{
	if(game_started)
		return;
	if(countdown)
		return;
	
	Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_START_SOON);

	countdown = true;
	countdown_time = time + 5.5;
}

void player_deflect1(entity this);
void Deflect(entity this)
{
	if(ceasefire)
		return;
	if(!STAT(HAS_BALL, this))
		return;
	if(STAT(SPECIAL, this))
		return;	// can only deflect if holding a normal ball
	if(time < STAT(DEFLECTING, this))
		return;

	_sound(this, CH_WEAPON_B, "dodgeball/deflect_woosh_db.wav", 1, ATTN_NORM);
	if(IS_PLAYER(this))
		player_deflect1(this);
	STAT(DEFLECTING, this) = time + 0.3;
}

void dodgeball_PutPlayerInServer(entity this)
{
	if(world.worldtype != WORLDTYPE_DODGEBALL)
		return;

	this.health = 100;
	STAT(STAMINA, this) = 30;
	STAT(DEFLECTING, this) = 0;
	STAT(WEAPONS, this) = WEPSET(BALL);
	STAT(DUAL_WEAPONS, this) = '0 0 0';

	// add a slight delay after spawning to be able to throw balls
	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		ATTACK_FINISHED(this, weaponentity) = time + 0.3;
	}
}

void dodgeball_respawn2(entity this)
{
	if(world.worldtype != WORLDTYPE_DODGEBALL)
		return;

	if(!this.died)
	{
		// dead but respawning, just let them back up!
		//if(ceasefire || countdown || this.watertype <= CONTENT_WATER)
			respawn(this);
		return;
	}

	if(IS_REAL_CLIENT(this))
		play2(this, "dodgeball/prison_door_db.wav");
	respawn(this);
}

void dodgeball_GibPlayer(entity this, entity inflictor, entity attacker)
{
	if(world.worldtype != WORLDTYPE_DODGEBALL)
		return;

	if(STAT(FROZEN, this) > time)
	{
		for(int j = 0; j < 8; ++j)
		{
			ThrowGib(this, inflictor, "progs/ice_db.mdl", this.health * 1.5);
		}
		STAT(FROZEN, this) = 0;
	}
	setthink(this, dodgeball_respawn2);
	this.nextthink = time + 2;
}

void dodgeball_PlayerDies(entity this)
{
	if(world.worldtype != WORLDTYPE_DODGEBALL)
		return;

	if(!ceasefire && !countdown)
		this.died = true;
}

void dodgeball_RemovePlayer(entity this)
{
	if(world.worldtype != WORLDTYPE_DODGEBALL)
		return;

	// flip last played team to ensure next join is on their team
	last_team = (this.team_no == 1) ? 2 : 1;

	DropBall(this);

	this.team_no = 0;
}

void dodgeball_ClientConnect(entity this)
{
	if(world.worldtype != WORLDTYPE_DODGEBALL)
		return;

	this.team_no = (last_team == 1) ? 2 : 1;
	last_team = this.team_no;
}

void dodgeball_Rejoin(entity this)
{
	if(world.worldtype != WORLDTYPE_DODGEBALL)
		return;

	this.team_no = (last_team == 1) ? 2 : 1;
	last_team = this.team_no;

	//if(!countdown && !ceasefire)
		//this.died = true;
	//else
		//this.died = false;
}

void dodgeball_PlayerPreThink(entity this)
{
	if(world.worldtype != WORLDTYPE_DODGEBALL)
		return;

	if(!PHYS_INPUT_BUTTON_CROUCH(this) && this.health > 0)
	{
		if(time > this.stamina_time)
		{
			STAT(STAMINA, this) = min(STAT(STAMINA, this) + 1, 30);
			this.stamina_time = time + 0.25;
		}	
	}
}

void dodgeball_PlayerPowerups(entity this)
{
	if(world.worldtype != WORLDTYPE_DODGEBALL)
		return;

	if(STAT(HAS_BALL, this))
	{
		if(STAT(FROZEN, this) > time)
		{
			if(this.team_no == 1)
				this.skin = 9;
			else if(this.team_no == 2)
				this.skin = 10;
		}
		else
		{
			if(this.team_no == 1)
			{
				switch(STAT(SPECIAL, this))
				{
					case 1: this.skin = 3; break;
					case 2: this.skin = 11; break;
					case 3: this.skin = 5; break;
					case 4: this.skin = 7; break;
					case 5: this.skin = 15; break;
					case 6: this.skin = 13; break;
					default: this.skin = 1; break;
				}
			}
			else if(this.team_no == 2)
			{
				switch(STAT(SPECIAL, this))
				{
					case 1: this.skin = 4; break;
					case 2: this.skin = 12; break;
					case 3: this.skin = 6; break;
					case 4: this.skin = 8; break;
					case 5: this.skin = 16; break;
					case 6: this.skin = 14; break;
					default: this.skin = 2; break;
				}
			}
		}
	}
	else
	{
		if(STAT(FROZEN, this) > time)
		{
			if(this.team_no == 1)
				this.skin = 3;
			else if(this.team_no == 2)
				this.skin = 4;
		}
		else
		{
			if(this.team_no == 1)
				this.skin = 1;
			else if(this.team_no == 2)
				this.skin = 2;
		}
	}
}

entity SelectTeamSpawn(entity this, int tno)
{
	entity spot = NULL, spots = NULL, thing = NULL;
	float numspots = 0, totalspots = 0, pcount = 0;
	
	if(this.died)
	{
		if (tno == 1)
		{
			spot = find(NULL, classname, "info_player_prison1");
			while(spot)
			{
				totalspots = totalspots + 1;
				thing = findradius(spot.origin, 32);
				while (thing)
				{
					if (thing.classname == "player")
					{
						traceline (spot.origin, thing.origin, false, spot);
						if (trace_ent == thing)
							pcount = pcount + 1;
					}
					thing = thing.chain;
				}
				if (pcount == 0)
				{
					spot.goalentity = spots;
					spots = spot;
					numspots = numspots + 1;
				}
				
				spot = find(spot, classname, "info_player_prison1");
			}
			
			totalspots = totalspots - 1;
			if (!numspots)
			{
				totalspots = rint(random()*totalspots);
				spot = find(NULL, classname, "info_player_prison1");
				while (totalspots > 0)
				{
					totalspots = totalspots - 1;
					spot = find(spot, classname, "info_player_prison1");
				}
				return spot;
			}
			
			numspots = numspots - 1;
			numspots = rint(random()*numspots);
			
			spot = spots;
			while (numspots > 0)
			{
				spot = spot.goalentity;
				numspots = numspots - 1;
			}
			
			return spot;
		}
		if (tno == 2)
		{
			spot = find(NULL, classname, "info_player_prison2");
			while (spot)
			{
				totalspots = totalspots + 1;
				thing = findradius(spot.origin, 32);
				while (thing)
				{
					if (thing.classname == "player")
					{
						traceline (spot.origin, thing.origin, false, spot);
						if (trace_ent == thing)
							pcount = pcount + 1;
					}
					thing = thing.chain;
				}
				if (pcount == 0)
				{
					spot.goalentity = spots;
					spots = spot;
					numspots = numspots + 1;
				}
				
				spot = find(spot, classname, "info_player_prison2");
			}
			
			totalspots = totalspots - 1;
			if (!numspots)
			{
				totalspots = rint(random()*totalspots);
				spot = find(NULL, classname, "info_player_prison2");
				while (totalspots > 0)
				{
					totalspots = totalspots - 1;
					spot = find(spot, classname, "info_player_prison2");
				}
				return spot;
			}
			
			numspots = numspots - 1;
			numspots = rint(random()*numspots);
			
			spot = spots;
			while (numspots > 0)
			{
				spot = spot.goalentity;
				numspots = numspots - 1;
			}
			
			return spot;
		}
	}
	
	if(tno == 1)
	{
		spot = find(NULL, classname, "info_player_team1");
		while (spot)
		{
			totalspots = totalspots + 1;
			thing = findradius(spot.origin, 32);
			while (thing)
			{
				if (thing.classname == "player")
				{
					traceline (spot.origin, thing.origin, false, spot);
					if (trace_ent == thing)
						pcount = pcount + 1;
				}
				thing = thing.chain;
			}
			if (pcount == 0)
			{
				spot.goalentity = spots;
				spots = spot;
				numspots = numspots + 1;
			}
			
			spot = find(spot, classname, "info_player_team1");
		}
		
		totalspots = totalspots - 1;
		if (!numspots)
		{
			totalspots = rint(random()*totalspots);
			spot = find(NULL, classname, "info_player_team1");
			while (totalspots > 0)
			{
				totalspots = totalspots - 1;
				spot = find(spot, classname, "info_player_team1");
			}
			return spot;
		}
		
		numspots = numspots - 1;
		numspots = rint(random()*numspots);
		
		spot = spots;
		while (numspots > 0)
		{
			spot = spot.goalentity;
			numspots = numspots - 1;
		}
		
		return spot;
	}
	if (tno == 2)
	{
		spot = find(NULL, classname, "info_player_team2");
		while (spot)
		{
			totalspots = totalspots + 1;
			thing = findradius(spot.origin, 32);
			while (thing)
			{
				if (thing.classname == "player")
				{
					traceline (spot.origin, thing.origin, false, spot);
					if (trace_ent == thing)
						pcount = pcount + 1;
				}
				thing = thing.chain;
			}
			if (pcount == 0)
			{
				spot.goalentity = spots;
				spots = spot;
				numspots = numspots + 1;
			}
			
			spot = find(spot, classname, "info_player_team2");
		}
		
		totalspots = totalspots - 1;
		if (!numspots)
		{
			totalspots = rint(random()*totalspots);
			spot = find(NULL, classname, "info_player_team2");
			while (totalspots > 0)
			{
				totalspots = totalspots - 1;
				spot = find(spot, classname, "info_player_team2");
			}
			return spot;
		}
		
		numspots -= 1;
		numspots = rint(random()*numspots);
		
		spot = spots;
		while (numspots > 0)
		{
			spot = spot.goalentity;
			numspots = numspots - 1;
		}
		
		return spot;
	}

	return NULL;
}

// TODO: utilize clipgroups to allow teammates through?
void teamwall_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(toucher.health <= 0)
		return;

	vector _movedir = this.movedir;
	vector oldorg, neworg;

	toucher.velocity = toucher.velocity - (toucher.velocity * _movedir) * _movedir;
	oldorg.x = toucher.oldorigin_x * _movedir.x;
	oldorg.y = toucher.oldorigin_y * _movedir.y;
	oldorg.z = toucher.oldorigin_z * _movedir.z;
	
	_movedir.x = 0 - _movedir.x;
	_movedir.y = 0 - _movedir.y;
	_movedir.z = 0 - _movedir.z;
	
	neworg.x = toucher.origin_x * _movedir.x;
	neworg.y = toucher.origin_y * _movedir.y;
	neworg.z = toucher.origin_z * _movedir.z;
	
	setorigin(toucher, neworg + oldorg);
}

spawnfunc(func_teamwall)
{
	if(world.worldtype != WORLDTYPE_DODGEBALL)
	{
		delete(this);
		return;
	}
	InitTrigger(this);
	settouch(this, teamwall_touch);
}


void teleportball_touch(entity this, entity toucher)
{
	if(toucher.classname != "dodgeball")
		return;
	if(STAT(SPECIAL, toucher))
		return;

	teleport_back(toucher);
}

spawnfunc(trigger_teleportball)
{
	if(world.worldtype != WORLDTYPE_DODGEBALL)
	{
		delete(this);
		return;
	}
	InitTrigger(this);
	settouch(this, teleportball_touch);
}

spawnfunc(info_ball_spot)
{
	if(world.worldtype != WORLDTYPE_DODGEBALL)
	{
		delete(this);
		return;
	}
}

spawnfunc(info_player_prison1)
{
	if(world.worldtype != WORLDTYPE_DODGEBALL)
	{
		delete(this);
		return;
	}
}

spawnfunc(info_player_prison2)
{
	if(world.worldtype != WORLDTYPE_DODGEBALL)
	{
		delete(this);
		return;
	}
}
#endif

bool dodgeball_Sprinting(entity this)
{
	if(STAT(WORLDTYPE) != WORLDTYPE_DODGEBALL || STAT(SKATING) || STAT(SLIDE_ON) || (STAT(ITEMS) & IT_TANK) || STAT(CLOCKWORK))
		return false;
	return (PHYS_INPUT_BUTTON_CROUCH(this) && STAT(STAMINA, this) > 0 && IS_ONGROUND(this) && this.velocity != '0 0 0');
}

float dodgeball_GetMoveSpeed(entity this)
{
	if(STAT(WORLDTYPE) != WORLDTYPE_DODGEBALL)
		return 1;

	if(dodgeball_Sprinting(this))
		return 1.5;
	return 1;
}

bool dodgeball_PlayerPhysics(entity this)
{
	if(STAT(WORLDTYPE) != WORLDTYPE_DODGEBALL)
		return false;

	if(STAT(FROZEN, this) > time)
		return true;
#ifdef SVQC
	if(dodgeball_Sprinting(this))
		STAT(STAMINA, this) = max(STAT(STAMINA, this) - (30 * PHYS_INPUT_FRAMETIME), 0);
#endif
	return false;
}

#ifdef CSQC
string dodgeball_viewmodel(entity this)
{
	if(STAT(DIED))
		return "";
	if(!STAT(HAS_BALL))
		return "nododgeball";

	if(time < STAT(DEFLECTING))
		return "deflect";
	if(time < STAT(CATCHING))
		return "catch";

	int myspecial = STAT(SPECIAL);

	switch(myspecial)
	{
		case 1: return "dodgeball2";
		case 2: return "hdodgeball";
		case 3: return "dodgeball3";
		case 4: return "dodgeball4";
		case 5: return "roflcopterball";
		case 6: return "spanner_ball";
	}

	return "dodgeball";
}
#endif