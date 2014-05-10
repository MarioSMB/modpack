void dom_EventLog(string mode, float cpteam, entity actor) // use an alias for easy changing and quick editing later
{
	if(autocvar_sv_eventlog)
		GameLogEcho(sprintf(":dom:%s:%d%s", mode, cpteam, ((actor != world) ? strcat(":", ftos(actor.playerid)) : "")));
}

void dompoint_captured ()
{
	entity head;
	float old_delay;
	string msg = "dom-neut";

	self.team = self.cnt;
	self.cnt = -1;

	dom_EventLog("taken", self.team, self.dmg_inflictor);
	self.dmg_inflictor = world;

	self.skin = dom_skin[self.team];
	self.model = dom_model[self.team];
	self.modelindex = dom_modelindex[self.team];

	float points, wait_time;
	if (autocvar_g_domination_point_amt)
		points = autocvar_g_domination_point_amt;
	else
		points = self.frags;
	if (autocvar_g_domination_point_rate)
		wait_time = autocvar_g_domination_point_rate;
	else
		wait_time = self.wait;

	if(domination_roundbased)
	{
		PlayerScore_Add(self.enemy, SP_SCORE, +points);
		bprint(strcat(dom_message[self.team], "\n"));
	}
	else
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_DOMINATION_CAPTURE_TIME, dom_message[self.team], points, wait_time);

	if(self.enemy.playerid == self.enemy_playerid)
		PlayerScore_Add(self.enemy, SP_DOM_TAKES, 1);
	else
		self.enemy = world;
		
	if(dom_noise[self.team] != "")
	if(self.enemy)
		sound(self.enemy, CH_TRIGGER, dom_noise[self.team], VOL_BASE, ATTEN_NORM);
	else
		sound(self, CH_TRIGGER, dom_noise[self.team], VOL_BASE, ATTEN_NORM);

	if(dom_noise1[self.team] != "")
		play2all(dom_noise1[self.team]);

	//self.delay = time + wait_time;

	// do trigger work
	old_delay = self.delay;
	self.delay = 0;
	activator = self;
	SUB_UseTargets ();
	self.delay = old_delay;

	switch(self.team)
	{
		case NUM_TEAM_1: msg = "dom-red"; break;
		case NUM_TEAM_2: msg = "dom-blue"; break;
		case NUM_TEAM_3: msg = "dom-yellow"; break;
		case NUM_TEAM_4: msg = "dom-pink"; break;
	}

	WaypointSprite_UpdateSprites(self.sprite, msg, "", "");

	total_pps = 0, pps_red = 0, pps_blue = 0, pps_yellow = 0, pps_pink = 0;
	for(head = world; (head = find(head, classname, "dom_controlpoint")) != world; )
	{
		if (autocvar_g_domination_point_amt)
			points = autocvar_g_domination_point_amt;
		else
			points = head.frags;
		if (autocvar_g_domination_point_rate)
			wait_time = autocvar_g_domination_point_rate;
		else
			wait_time = head.wait;
		switch(head.team)
		{
			case NUM_TEAM_1:
				pps_red += points/wait_time;
				break;
			case NUM_TEAM_2:
				pps_blue += points/wait_time;
				break;
			case NUM_TEAM_3:
				pps_yellow += points/wait_time;
				break;
			case NUM_TEAM_4:
				pps_pink += points/wait_time;
				break;
		}
		total_pps += points/wait_time;
	}

	WaypointSprite_UpdateTeamRadar(self.sprite, RADARICON_DOMPOINT, colormapPaletteColor(self.team - 1, 0));
	WaypointSprite_Ping(self.sprite);

	self.captime = time;
}

void AnimateDomPoint()
{
	if(self.pain_finished > time)
		return;
	self.pain_finished = time + self.t_width;
	if(self.nextthink > self.pain_finished)
		self.nextthink = self.pain_finished;

	self.frame = self.frame + 1;
	if(self.frame > self.t_length)
		self.frame = 0;
}

float dom_Cooldown(entity e)
{
	float base, pw, f, c;

	c = 1;

	if(e.cnt == -1 && !e.team)
	{
		base = autocvar_g_domination_controlpoint_idletime_neutral;
		pw	 = autocvar_g_domination_controlpoint_idletime_neutral_power;
		f	 = autocvar_g_domination_controlpoint_idletime_neutral_factor;
	}
	else
	{
		base = autocvar_g_domination_controlpoint_idletime;
		pw	 = autocvar_g_domination_controlpoint_idletime_power;
		f	 = autocvar_g_domination_controlpoint_idletime_factor;
	}

	return base + pow(c, pw) * f * base;
}

float dom_InitialCooldown(entity e) { return ((e.cnt == -1 && !e.team) ? autocvar_g_domination_controlpoint_idletime_neutral_initial : autocvar_g_domination_controlpoint_idletime_initial); }

void dom_Activate(entity e)
{
	e.model = dom_model[e.team];
	e.modelindex = dom_modelindex[e.team];
	e.skin = dom_skin[e.team];

	e.dom_active = TRUE;
	e.dom_cooldown = 0;
	//e.dom_cooldown_max = 0;
	setsize(e, CP_MIN, CP_MAX);
	WaypointSprite_UpdateMaxHealth(e.sprite, 0);
	WaypointSprite_UpdateHealth(e.sprite, 0);
}

void dom_Deactivate(entity e, float cooldown)
{
	e.dom_cooldown_max = max(e.dom_cooldown_max, cooldown);
	e.dom_cooldown	  = max(e.dom_cooldown,	   cooldown);

	if(e.dom_active && e.dom_cooldown > 0)
	{
		e.model = dom_model[e.team];
		e.modelindex = dom_modelindex[e.team];
		setsize(e, CP_MIN, CP_MAX);
		e.dom_active = FALSE;
	}
}

void Dom_ControlPoint_UpdateCooldownProgress(entity e)
{
	WaypointSprite_UpdateMaxHealth(e.sprite, e.dom_cooldown_max);
	WaypointSprite_UpdateHealth(e.sprite, e.dom_cooldown_max - e.dom_cooldown);
}

void dom_ControlPointThink()
{
	float fragamt;

	self.nextthink = time;

	//self.frame = self.frame + 1;
	//if(self.frame > 119)
	//	self.frame = 0;
	AnimateDomPoint();

	// give points

	if (gameover || self.delay > time || time < game_starttime)	// game has ended, don't keep giving points
		return;

	if(self.dom_cooldown)
		self.delay = time;
	else if(autocvar_g_domination_point_rate)
		self.delay = time + autocvar_g_domination_point_rate;
	else
		self.delay = time + self.wait;

	// give credit to the team
	// NOTE: this defaults to 0
	if (!domination_roundbased)
	if (self.team)
	{
		if(autocvar_g_domination_point_amt)
			fragamt = autocvar_g_domination_point_amt;
		else
			fragamt = self.frags;
		TeamScore_AddToTeam(self.team, ST_SCORE, fragamt);
		TeamScore_AddToTeam(self.team, ST_DOM_TICKS, fragamt);

		// give credit to the individual player, if he is still there
		if (self.enemy.playerid == self.enemy_playerid)
		{
			PlayerScore_Add(self.enemy, SP_SCORE, fragamt);
			PlayerScore_Add(self.enemy, SP_DOM_TICKS, fragamt);
		}
		else
			self.enemy = world;
	}

	if(self.dom_cooldown) { Dom_ControlPoint_UpdateCooldownProgress(self); }
	else if(!self.dom_active) { dom_Activate(self); }

	if(time - self.pointupdatetime >= 0.1)
	{
		self.dom_unlock_progress = 0;
		self.dom_capturingplayer = world;
	}

	self.dom_cooldown = max(0, self.dom_cooldown - frametime);
}

void dom_ControlPointTouch()
{
	if(gameover) { return; }
	if(round_handler_IsActive() && !round_handler_IsRoundStarted()) { return; }
	
	entity toucher = other;

	if(gameover) { return; }
	if(!IS_PLAYER(toucher)) { return; }
	if(toucher.health < 1 || toucher.frozen) { return; }
	if(round_handler_IsActive() && !round_handler_IsRoundStarted()) { return; }

	toucher.pointupdatetime = time;

	if(SAME_TEAM(toucher, self))
	{
		if(time >= self.dom_lastmessage)
		{
			Send_Notification(NOTIF_ONE, toucher, MSG_CENTER, CENTER_JAILBREAK_WRONGTEAM);
			self.dom_lastmessage = time + 1.5;
		}
		return;
	}
	
	if(!self.dom_active)
	{
		if(time >= self.dom_lastmessage)
		{
			Send_Notification(NOTIF_ONE, toucher, MSG_CENTER, CENTER_JAILBREAK_NOTREADY);
			self.dom_lastmessage = time + 1.5;
		}
		return;
	}
	
	if(self.dom_capturingplayer && self.dom_capturingplayer != toucher)
	{
		if(time >= self.dom_lastmessage)
		{
			Send_Notification(NOTIF_ONE, toucher, MSG_CENTER, CENTER_JAILBREAK_TOOLATE);
			self.dom_lastmessage = time + 1.5;
		}
		return;
	}
	
	//if(self.cnt == -1 && !self.team)
		self.dom_unlock_progress = bound(0, self.dom_unlock_progress + frametime * autocvar_g_domination_controlpoint_unlock_speed, 1);
		
	self.pointupdatetime = time;
	self.dom_capturingplayer = toucher;
	toucher.dom_unlock_progress = self.dom_unlock_progress;
	
	if(self.dom_unlock_progress >= 1)
	{
		nades_GiveBonus(toucher, autocvar_g_nades_bonus_score_medium);

		self.team = 0; // neutral for now
		self.cnt = toucher.team;

		self.dmg_inflictor = toucher;

		WaypointSprite_UpdateSprites(self.sprite, "dom-neut", "", "");
		WaypointSprite_UpdateTeamRadar(self.sprite, RADARICON_DOMPOINT, '0 1 1');
		WaypointSprite_Ping(self.sprite);

		self.skin = dom_skin[self.team];
		self.model = dom_model[self.team];
		self.modelindex = dom_modelindex[self.team];
		
		self.dom_lastmessage = time + 2; // no spam

		self.enemy = toucher; // individual player scoring
		self.enemy_playerid = toucher.playerid;
		dompoint_captured();
		
		dom_Deactivate(self, dom_Cooldown(self));
		entity e;
		for(e = world; (e = find(e, classname, "dom_controlpoint")) != world; )
		if(e != self)
		if(e.team)
			dom_Deactivate(e, autocvar_g_domination_controlpoint_idletime);
		else
			dom_Deactivate(e, autocvar_g_domination_controlpoint_idletime_neutral);
	}
}

void dom_DelayedControlPointSetup(void) // called after a control point is placed on the map by dom_ControlPointSetup()
{
	// model setup
	self.model = dom_model[self.team];
	self.modelindex = dom_modelindex[self.team];
	self.noise = dom_noise[self.team]; // capture sound
	self.noise1 = dom_noise1[self.team]; // global capture sound
	self.skin = dom_skin[self.team];
	
	// appearence
	//setmodel(self, self.model);
	self.effects = self.effects | EF_LOWPRECISION;
	if(autocvar_g_domination_point_fullbright)
		self.effects |= EF_FULLBRIGHT;

	dom_Deactivate(self, dom_InitialCooldown(self));

	waypoint_spawnforitem(self);
	WaypointSprite_SpawnFixed("dom-neut", self.origin + '0 0 32', self, sprite, RADARICON_DOMPOINT, '0 1 1');
}

void dom_Reset()
{
	// reset team
	self.team = 0;
	self.cnt = -1;
	
	// model setup
	self.model = dom_model[self.team];
	self.noise = dom_noise[self.team]; // capture sound
	self.noise1 = dom_noise1[self.team]; // global capture sound
	self.skin = dom_skin[self.team];
	
	// main setup
	self.think = dom_ControlPointThink;
	self.nextthink = time;
	
	// waypoint setup
	WaypointSprite_UpdateSprites(self.sprite, "dom-neut", "", "");
	WaypointSprite_UpdateTeamRadar(self.sprite, RADARICON_DOMPOINT, '0 1 1');

	dom_Deactivate(self, dom_InitialCooldown(self));
}

void dom_ControlPointSetup(entity cp)
{
	// declarations
	self = cp; // for later usage with droptofloor()

	if(!cp.t_width)			{ cp.t_width = CP_TICRATE; }
	if(!cp.t_length)		{ cp.t_length = CP_MAXFRAMES; }
	if(!cp.scale)			{ cp.scale = CP_SCALE; }
	if(cp.message == "")	{ cp.message = " has captured a control point"; }
	if(cp.frags <= 0)		{ cp.frags = 1; }
	if(cp.wait <= 0)		{ cp.wait = 5; }

	total_pps += ((autocvar_g_domination_point_amt) ? autocvar_g_domination_point_amt : cp.frags) / ((autocvar_g_domination_point_rate) ? autocvar_g_domination_point_rate : cp.wait);

	// main setup
	cp.think = dom_ControlPointThink;
	cp.nextthink = time;
	cp.touch = dom_ControlPointTouch;
	cp.solid = SOLID_TRIGGER;
	cp.dom_capturingplayer = world;
	cp.reset = dom_Reset;
	cp.flags = FL_ITEM;
	cp.dom_active = TRUE;
	cp.cnt = -1;
	cp.team = 0;
	setsize(cp, CP_MIN, CP_MAX);
	setorigin(cp, cp.origin + '0 0 20'); // move up so droptofloor doesn't put it in solid

	// control point placement
	if((cp.spawnflags & 1) || cp.noalign) // don't drop to floor, just stay at fixed location
	{
		cp.noalign = TRUE;
		cp.movetype = MOVETYPE_NONE;
	}
	else // drop to floor, automatically find a platform and set that as spawn origin
	{
		cp.noalign = FALSE;
		self = cp;
		droptofloor();
		cp.movetype = MOVETYPE_NONE;
	}

	InitializeEntity(cp, dom_DelayedControlPointSetup, INITPRIO_SETLOCATION);
}

float total_controlpoints, redowned, blueowned, yellowowned, pinkowned;
void Domination_count_controlpoints()
{
	entity e;
	total_controlpoints = redowned = blueowned = yellowowned = pinkowned = 0;
	for(e = world; (e = find(e, classname, "dom_controlpoint")) != world; )
	{
		++total_controlpoints;
		redowned += (e.team == NUM_TEAM_1);
		blueowned += (e.team == NUM_TEAM_2);
		yellowowned += (e.team == NUM_TEAM_3);
		pinkowned += (e.team == NUM_TEAM_4);
	}
}

float Domination_GetWinnerTeam()
{
	float winner_team = 0;
	if(redowned == total_controlpoints)
		winner_team = NUM_TEAM_1;
	if(blueowned == total_controlpoints)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_2;
	}
	if(yellowowned == total_controlpoints)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_3;
	}
	if(pinkowned == total_controlpoints)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_4;
	}
	if(winner_team)
		return winner_team;
	return -1; // no control points left?
}

#define DOM_OWNED_CONTROLPOINTS() ((redowned > 0) + (blueowned > 0) + (yellowowned > 0) + (pinkowned > 0))
#define DOM_OWNED_CONTROLPOINTS_OK() (DOM_OWNED_CONTROLPOINTS() < total_controlpoints)
float Domination_CheckWinner()
{
	entity e;

	if(round_handler_GetEndTime() > 0 && round_handler_GetEndTime() - time <= 0)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_OVER);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_OVER);
		round_handler_Init(5, autocvar_g_domination_warmup, autocvar_g_domination_round_timelimit);
		FOR_EACH_CLIENT(e)
			nades_Clear(e);
		return 1;
	}

	Domination_count_controlpoints();

	float winner_team = Domination_GetWinnerTeam();
	
	if(winner_team == -1)
		return 0;
	
	if(winner_team > 0)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, APP_TEAM_NUM_4(winner_team, CENTER_ROUND_TEAM_WIN_));
		Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_NUM_4(winner_team, INFO_ROUND_TEAM_WIN_));
		TeamScore_AddToTeam(winner_team, ST_DOM_CAPS, +1);
	}
	else if(winner_team == -1)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_TIED);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_TIED);
	}
	
	round_handler_Init(5, autocvar_g_domination_warmup, autocvar_g_domination_round_timelimit);
	
	FOR_EACH_PLAYER(e)
		nades_Clear(e);
	
	return 1;
}

float Domination_CheckPlayers()
{
	return 1;
}

void Domination_RoundStart()
{
	entity oldself;
	oldself = self;
	FOR_EACH_PLAYER(self)
	{
		if(self.vehicle)
			vehicles_exit(VHEF_RELEASE);
		PutClientInServer();
	}
	
	self = oldself;
}

//go to best items, or control points you don't own
void havocbot_role_dom()
{
	if(self.deadflag != DEAD_NO)
		return;

	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;
		navigation_goalrating_start();
		havocbot_goalrating_controlpoints(10000, self.origin, 15000);
		havocbot_goalrating_items(8000, self.origin, 8000);
		//havocbot_goalrating_enemyplayers(3000, self.origin, 2000);
		//havocbot_goalrating_waypoints(1, self.origin, 1000);
		navigation_goalrating_end();
	}
}

MUTATOR_HOOKFUNCTION(dom_GetTeamCount)
{
	//ret_float = domination_teams;
	ret_string = "dom_team";
	return TRUE;
}

MUTATOR_HOOKFUNCTION(dom_ResetMap)
{
	total_pps = 0, pps_red = 0, pps_blue = 0, pps_yellow = 0, pps_pink = 0;
	return TRUE;
}

MUTATOR_HOOKFUNCTION(dom_PlayerThink)
{
	if(round_handler_IsActive() && !round_handler_IsRoundStarted())
	{
		self.dom_unlock_progress = 0;
		return FALSE;
	}

	if(time - self.pointupdatetime >= 0.01)
		self.dom_unlock_progress = 0;

	self.dom_total_pps = total_pps;
	self.dom_pps_red = pps_red;
	self.dom_pps_blue = pps_blue;
	self.dom_pps_yellow = pps_yellow;
	self.dom_pps_pink = pps_pink;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(dom_PlayerSpawn)
{
	return FALSE;
}

MUTATOR_HOOKFUNCTION(dom_PlayerDamage)
{
	entity e;
	if(self.dom_unlock_progress)
	{
		for(e = world; (e = find(e, classname, "dom_controlpoint")) != world; )
		if(e.dom_capturingplayer == self)
			e.dom_unlock_progress = bound(0, e.dom_unlock_progress - autocvar_g_domination_controlpoint_unlock_damage_pushback, 1);
	}
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(dom_BotRoles)
{
	self.havocbot_role = havocbot_role_dom;
	return TRUE;
}

/*QUAKED spawnfunc_dom_controlpoint (0 .5 .8) (-16 -16 -24) (16 16 32)
Control point for Domination gameplay.
*/
void spawnfunc_dom_controlpoint()
{
	if(!g_domination) { remove(self); return; }

	dom_ControlPointSetup(self);
}

/*QUAKED spawnfunc_dom_team (0 .5 .8) (-32 -32 -24) (32 32 32)
Team declaration for Domination gameplay, this allows you to decide what team
names and control point models are used in your map.

Note: If you use spawnfunc_dom_team entities you must define at least 3 and only two
can have netname set!  The nameless team owns all control points at start.

Keys:
"netname"
 Name of the team (for example Red Team, Blue Team, Green Team, Yellow Team, Life, Death, etc)
"cnt"
 Scoreboard color of the team (for example 4 is red and 13 is blue)
"model"
 Model to use for control points owned by this team (for example
 "progs/b_g_key.mdl" is a gold keycard, and "progs/b_s_key.mdl" is a silver
 keycard)
"skin"
 Skin of the model to use (for team skins on a single model)
"noise"
 Sound to play when this team captures a point.
 (this is a localized sound, like a small alarm or other effect)
"noise1"
 Narrator speech to play when this team captures a point.
 (this is a global sound, like "Red team has captured a control point")
*/

void spawnfunc_dom_team()
{
	if(!g_domination || autocvar_g_domination_teams_override >= 2) { remove(self); return; }

	precache_model(self.model);
	
	self.classname = "dom_team";
	// this would have to be changed if used in quakeworld
	if(self.cnt)
		self.team = self.cnt + 1; // WHY are these different anyway?

	setmodel(self, self.model);
	dom_model[self.team] = self.model;
	dom_modelindex[self.team] = self.modelindex;
	
	self.model = "";
	self.modelindex = 0;

	dom_noise[self.team] = self.noise;
	dom_noise1[self.team] = self.noise1;
	dom_message[self.team] = self.message;
	dom_skin[self.team] = self.skin;
	dom_teamname[self.team] = self.netname;
}

// scoreboard setup
void ScoreRules_dom(float teams)
{
	if(domination_roundbased)
	{
		ScoreRules_basics(teams, SFL_SORT_PRIO_PRIMARY, 0, TRUE);
		ScoreInfo_SetLabel_TeamScore  (ST_DOM_CAPS, "caps", SFL_SORT_PRIO_PRIMARY);
		ScoreInfo_SetLabel_PlayerScore(SP_DOM_TAKES, "takes", 0);
		ScoreRules_basics_end();
	}
	else
	{
		float sp_domticks, sp_score;
		sp_score = sp_domticks = 0;
		if(autocvar_g_domination_disable_frags)
			sp_domticks = SFL_SORT_PRIO_PRIMARY;
		else
			sp_score = SFL_SORT_PRIO_PRIMARY;
		ScoreRules_basics(teams, sp_score, sp_score, TRUE);
		ScoreInfo_SetLabel_TeamScore  (ST_DOM_TICKS,    "ticks",     sp_domticks);
		ScoreInfo_SetLabel_PlayerScore(SP_DOM_TICKS,    "ticks",     sp_domticks);
		ScoreInfo_SetLabel_PlayerScore(SP_DOM_TAKES,    "takes",     0);
		ScoreRules_basics_end();
	}
}

// code from here on is just to support maps that don't have control point and team entities
void dom_spawnteam (string teamname, float teamcolor, string pointmodel, float pointskin, string capsound, string capnarration, string capmessage)
{
	entity oldself;
	oldself = self;
	self = spawn();
	self.classname = "dom_team";
	// this would have to be changed if used in quakeworld
	self.team = teamcolor + 1;
	
	setmodel(self, self.model);
	dom_model[self.team] = self.model;
	dom_modelindex[self.team] = self.modelindex;
	
	self.model = "";
	self.modelindex = 0;

	dom_noise[self.team] = capsound;
	dom_noise1[self.team] = capnarration;
	dom_message[self.team] = capmessage;
	dom_skin[self.team] = pointskin;
	dom_teamname[self.team] = teamname;

	self = oldself;
}

void dom_spawnpoint(vector org)
{
	entity oldself;
	oldself = self;
	self = spawn();
	self.classname = "dom_controlpoint";
	self.think = spawnfunc_dom_controlpoint;
	self.nextthink = time;
	setorigin(self, org);
	spawnfunc_dom_controlpoint();
	self = oldself;
}

// spawn some default teams if the map is not set up for domination
void dom_spawnteams(float teams)
{
	dom_spawnteam("Red", NUM_TEAM_1-1, "models/domination/dom_red.md3", 0, "domination/claim.wav", "", "Red team has captured a control point");
	dom_spawnteam("Blue", NUM_TEAM_2-1, "models/domination/dom_blue.md3", 0, "domination/claim.wav", "", "Blue team has captured a control point");
	if(teams >= 3)
		dom_spawnteam("Yellow", NUM_TEAM_3-1, "models/domination/dom_yellow.md3", 0, "domination/claim.wav", "", "Yellow team has captured a control point");
	if(teams >= 4)
		dom_spawnteam("Pink", NUM_TEAM_4-1, "models/domination/dom_pink.md3", 0, "domination/claim.wav", "", "Pink team has captured a control point");
	dom_spawnteam("", 0, "models/domination/dom_unclaimed.md3", 0, "", "", "");
}

void dom_DelayedInit() // Do this check with a delay so we can wait for teams to be set up.
{
	// if no teams are found, spawn defaults
	if(find(world, classname, "dom_team") == world || autocvar_g_domination_teams_override >= 2)
	{
		print("No ""dom_team"" entities found on this map, creating them anyway.\n");
		domination_teams = ((autocvar_g_domination_teams_override < 2) ? autocvar_g_domination_default_teams : autocvar_g_domination_teams_override);
		dom_spawnteams(domination_teams);
	}
	
	CheckAllowedTeams(world);
	domination_teams = ((c4>=0) ? 4 : (c3>=0) ? 3 : 2);

	addstat(STAT_CAPTURE_PROGRESS, AS_FLOAT, dom_unlock_progress);
	addstat(STAT_DOM_TOTAL_PPS, AS_FLOAT, dom_total_pps);
	addstat(STAT_DOM_PPS_RED, AS_FLOAT, dom_pps_red);
	addstat(STAT_DOM_PPS_BLUE, AS_FLOAT, dom_pps_blue);
	if(domination_teams >= 3) addstat(STAT_DOM_PPS_YELLOW, AS_FLOAT, dom_pps_yellow);
	if(domination_teams >= 4) addstat(STAT_DOM_PPS_PINK, AS_FLOAT, dom_pps_pink);

	domination_roundbased = autocvar_g_domination_roundbased;

	ScoreRules_dom(domination_teams);

	if(domination_roundbased)
	{
		round_handler_Spawn(Domination_CheckPlayers, Domination_CheckWinner, Domination_RoundStart);
		round_handler_Init(5, autocvar_g_domination_warmup, autocvar_g_domination_round_timelimit);
	}
}

void dom_Initialize()
{
	precache_model("models/domination/dom_red.md3");
	precache_model("models/domination/dom_blue.md3");
	precache_model("models/domination/dom_yellow.md3");
	precache_model("models/domination/dom_pink.md3");
	precache_model("models/domination/dom_unclaimed.md3");
	precache_sound("domination/claim.wav");

	InitializeEntity(world, dom_DelayedInit, INITPRIO_GAMETYPE);
}


MUTATOR_DEFINITION(gamemode_domination)
{
	MUTATOR_HOOK(GetTeamCount, dom_GetTeamCount, CBC_ORDER_ANY);
	MUTATOR_HOOK(reset_map_players, dom_ResetMap, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, dom_PlayerThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, dom_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDamage_Calculate, dom_PlayerDamage, CBC_ORDER_ANY);
	MUTATOR_HOOK(HavocBot_ChooseRole, dom_BotRoles, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		if(time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");
		dom_Initialize();
	}

	MUTATOR_ONREMOVE
	{
		error("This is a game type and it cannot be removed at runtime.");
	}

	return FALSE;
}
