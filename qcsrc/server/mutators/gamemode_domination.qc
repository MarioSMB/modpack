void dom_EventLog(string mode, float team_before, entity actor) // use an alias for easy changing and quick editing later
{
	if(autocvar_sv_eventlog)
		GameLogEcho(strcat(":dom:", mode, ":", ftos(team_before), ((actor != world) ? (strcat(":", ftos(actor.playerid))) : "")));
}

void set_dom_state(entity e)
{
	e.dom_total_pps = total_pps;
	e.dom_pps_red = pps_red;
	e.dom_pps_blue = pps_blue;
	if(c3 >= 0)
		e.dom_pps_yellow = pps_yellow;
	if(c4 >= 0)
		e.dom_pps_pink = pps_pink;
}

void dompoint_captured ()
{
	entity head;
	float old_delay, old_team, real_team;
	string msg = "dom-neut";

	// now that the delay has expired, switch to the latest team to lay claim to this point
	head = self.owner;

	real_team = self.cnt;
	self.cnt = -1;

	dom_EventLog("taken", self.team, self.dmg_inflictor);
	self.dmg_inflictor = world;

	self.goalentity = head;
	self.model = head.mdl;
	self.modelindex = head.dmg;
	self.skin = head.skin;
	
	float points, wait_time;
	if (autocvar_g_domination_point_amt)
		points = autocvar_g_domination_point_amt;
	else
		points = self.frags;
	if (autocvar_g_domination_point_rate)
		wait_time = autocvar_g_domination_point_rate;
	else
		wait_time = self.wait;

	bprint("^3", head.netname, "^3", self.message);
	if (points != 1)
		bprint(" ^7(", ftos(points), " points every ", ftos(wait_time), " seconds)\n");
	else
		bprint(" ^7(", ftos(points), " point every ", ftos(wait_time), " seconds)\n");

	if(self.enemy.playerid == self.enemy_playerid)
		PlayerScore_Add(self.enemy, SP_DOM_TAKES, 1);
	else
		self.enemy = world;

	if (head.noise != "")
		if(self.enemy)
			sound(self.enemy, CH_TRIGGER, head.noise, VOL_BASE, ATTN_NORM);
		else
			sound(self, CH_TRIGGER, head.noise, VOL_BASE, ATTN_NORM);
	if (head.noise1 != "")
		play2all(head.noise1);

	self.delay = time + wait_time;

	// do trigger work
	old_delay = self.delay;
	old_team = self.team;
	self.team = real_team;
	self.delay = 0;
	activator = self;
	SUB_UseTargets ();
	self.delay = old_delay;
	self.team = old_team;
	
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
		switch(head.goalentity.team)
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
		}
		total_pps += points/wait_time;
	}

	WaypointSprite_UpdateTeamRadar(self.sprite, RADARICON_DOMPOINT, colormapPaletteColor(self.goalentity.team - 1, 0));
	WaypointSprite_Ping(self.sprite);

	self.captime = time;

	FOR_EACH_REALCLIENT(head)
		set_dom_state(head);
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

void dompointthink()
{
	float fragamt;

	self.nextthink = time + 0.1;

	//self.frame = self.frame + 1;
	//if(self.frame > 119)
	//	self.frame = 0;
	AnimateDomPoint();

	// give points

	if (gameover || self.delay > time || time < game_starttime)	// game has ended, don't keep giving points
		return;

	if(autocvar_g_domination_point_rate)
		self.delay = time + autocvar_g_domination_point_rate;
	else
		self.delay = time + self.wait;

	// give credit to the team
	// NOTE: this defaults to 0
	if (self.goalentity.netname != "")
	{
		if(autocvar_g_domination_point_amt)
			fragamt = autocvar_g_domination_point_amt;
		else
			fragamt = self.frags;
		TeamScore_AddToTeam(self.goalentity.team, ST_SCORE, fragamt);
		TeamScore_AddToTeam(self.goalentity.team, ST_DOM_TICKS, fragamt);

		// give credit to the individual player, if he is still there
		if (self.enemy.playerid == self.enemy_playerid)
		{
			PlayerScore_Add(self.enemy, SP_SCORE, fragamt);
			PlayerScore_Add(self.enemy, SP_DOM_TICKS, fragamt);
		}
		else
			self.enemy = world;
	}
}

void dompointtouch()
{
	entity head;
	if not(IS_PLAYER(other))
		return;
	if (other.health < 1)
		return;

	if(time < self.captime + 0.3)
		return;

	// only valid teams can claim it
	head = find(world, classname, "dom_team");
	while (head && head.team != other.team)
		head = find(head, classname, "dom_team");
	if (!head || head.netname == "" || head == self.goalentity)
		return;

	// delay capture

	self.team = self.goalentity.team; // this stores the PREVIOUS team!

	self.cnt = other.team;
	self.owner = head; // team to switch to after the delay
	self.dmg_inflictor = other;

	// self.state = 1;
	// self.delay = time + cvar("g_domination_point_capturetime");
	//self.nextthink = time + cvar("g_domination_point_capturetime");
	//self.think = dompoint_captured;

	// go to neutral team in the mean time
	head = find(world, classname, "dom_team");
	while (head && head.netname != "")
		head = find(head, classname, "dom_team");
	if(head == world)
		return;

	WaypointSprite_UpdateSprites(self.sprite, "dom-neut", "", "");
	WaypointSprite_UpdateTeamRadar(self.sprite, RADARICON_DOMPOINT, '0 1 1');
	WaypointSprite_Ping(self.sprite);

	self.goalentity = head;
	self.model = head.mdl;
	self.modelindex = head.dmg;
	self.skin = head.skin;

	self.enemy = other; // individual player scoring
	self.enemy_playerid = other.playerid;
	dompoint_captured();
}

void dom_controlpoint_setup()
{
	entity head;
	// find the spawnfunc_dom_team representing unclaimed points
	head = find(world, classname, "dom_team");
	while(head && head.netname != "")
		head = find(head, classname, "dom_team");
	if (!head)
		objerror("no spawnfunc_dom_team with netname \"\" found\n");

	// copy important properties from spawnfunc_dom_team entity
	self.goalentity = head;
	setmodel(self, head.mdl); // precision already set
	self.skin = head.skin;

	self.cnt = -1;

	if(self.message == "")
		self.message = " has captured a control point";

	if(self.frags <= 0)
		self.frags = 1;
	if(self.wait <= 0)
		self.wait = 5;

	float points, waittime;
	if (autocvar_g_domination_point_amt)
		points = autocvar_g_domination_point_amt;
	else
		points = self.frags;
	if (autocvar_g_domination_point_rate)
		waittime = autocvar_g_domination_point_rate;
	else
		waittime = self.wait;

	total_pps += points/waittime;

	if(!self.t_width)
		self.t_width = 0.02; // frame animation rate
	if(!self.t_length)
		self.t_length = 239; // maximum frame

	self.think = dompointthink;
	self.nextthink = time;
	self.touch = dompointtouch;
	self.solid = SOLID_TRIGGER;
	self.flags = FL_ITEM;
	setsize(self, '-32 -32 -32', '32 32 32');
	setorigin(self, self.origin + '0 0 20');
	droptofloor();

	waypoint_spawnforitem(self);
	WaypointSprite_SpawnFixed("dom-neut", self.origin + '0 0 32', self, sprite, RADARICON_DOMPOINT, '0 1 1');
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

MUTATOR_HOOKFUNCTION(dom_ClientConnect)
{
	set_dom_state(self);
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
	if(!g_domination)
	{
		remove(self);
		return;
	}
	self.think = dom_controlpoint_setup;
	self.nextthink = time + 0.1;
	self.reset = dom_controlpoint_setup;

	if(!self.scale)
		self.scale = 0.6;

	self.effects = self.effects | EF_LOWPRECISION;
	if (autocvar_g_domination_point_fullbright)
		self.effects |= EF_FULLBRIGHT;
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
	if(!g_domination || autocvar_g_domination_teams_override >= 2)
	{
		remove(self);
		return;
	}
	precache_model(self.model);
	if (self.noise != "")
		precache_sound(self.noise);
	if (self.noise1 != "")
		precache_sound(self.noise1);
	self.classname = "dom_team";
	setmodel(self, self.model); // precision not needed
	self.mdl = self.model;
	self.dmg = self.modelindex;
	self.model = "";
	self.modelindex = 0;
	// this would have to be changed if used in quakeworld
	if(self.cnt)
		self.team = self.cnt + 1; // WHY are these different anyway?
}

// scoreboard setup
void ScoreRules_dom()
{
	float sp_domticks, sp_score;
	sp_score = sp_domticks = 0;
	if(autocvar_g_domination_disable_frags)
		sp_domticks = SFL_SORT_PRIO_PRIMARY;
	else
		sp_score = SFL_SORT_PRIO_PRIMARY;
	CheckAllowedTeams(world);
	ScoreRules_basics(((c4>=0) ? 4 : (c3>=0) ? 3 : 2), sp_score, sp_score, TRUE);
	ScoreInfo_SetLabel_TeamScore  (ST_DOM_TICKS,    "ticks",     sp_domticks);
	ScoreInfo_SetLabel_PlayerScore(SP_DOM_TICKS,    "ticks",     sp_domticks);
	ScoreInfo_SetLabel_PlayerScore(SP_DOM_TAKES,    "takes",     0);
	ScoreRules_basics_end();
}

// code from here on is just to support maps that don't have control point and team entities
void dom_spawnteam (string teamname, float teamcolor, string pointmodel, float pointskin, string capsound, string capnarration, string capmessage)
{
	entity oldself;
	oldself = self;
	self = spawn();
	self.classname = "dom_team";
	self.netname = teamname;
	self.cnt = teamcolor;
	self.model = pointmodel;
	self.skin = pointskin;
	self.noise = capsound;
	self.noise1 = capnarration;
	self.message = capmessage;

	// this code is identical to spawnfunc_dom_team
	setmodel(self, self.model); // precision not needed
	self.mdl = self.model;
	self.dmg = self.modelindex;
	self.model = "";
	self.modelindex = 0;
	// this would have to be changed if used in quakeworld
	self.team = self.cnt + 1;

	//eprint(self);
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
void dom_spawnteams()
{
	float numteams = ((autocvar_g_domination_teams_override < 2) ? autocvar_g_domination_default_teams : autocvar_g_domination_teams_override);

	dom_spawnteam("Red", NUM_TEAM_1-1, "models/domination/dom_red.md3", 0, "domination/claim.wav", "", "Red team has captured a control point");
	dom_spawnteam("Blue", NUM_TEAM_2-1, "models/domination/dom_blue.md3", 0, "domination/claim.wav", "", "Blue team has captured a control point");
	if(numteams > 2)
		dom_spawnteam("Yellow", NUM_TEAM_3-1, "models/domination/dom_yellow.md3", 0, "domination/claim.wav", "", "Yellow team has captured a control point");
	if(numteams > 3)
		dom_spawnteam("Pink", NUM_TEAM_4-1, "models/domination/dom_pink.md3", 0, "domination/claim.wav", "", "Pink team has captured a control point");
	dom_spawnteam("", 0, "models/domination/dom_unclaimed.md3", 0, "", "", "");
}

void dom_DelayedInit() // Do this check with a delay so we can wait for teams to be set up.
{
	// if no teams are found, spawn defaults
	if(find(world, classname, "dom_team") == world || autocvar_g_domination_teams_override >= 2)
	{
		print("No ""dom_team"" entities found on this map, creating them anyway.\n");
		dom_spawnteams();
	}
	
	ScoreRules_dom();
}

void dom_Initialize()
{
	precache_model("models/domination/dom_red.md3");
	precache_model("models/domination/dom_blue.md3");
	precache_model("models/domination/dom_yellow.md3");
	precache_model("models/domination/dom_pink.md3");
	precache_model("models/domination/dom_unclaimed.md3");
	precache_sound("domination/claim.wav");
	
	addstat(STAT_DOM_TOTAL_PPS, AS_FLOAT, dom_total_pps);
	addstat(STAT_DOM_PPS_RED, AS_FLOAT, dom_pps_red);
	addstat(STAT_DOM_PPS_BLUE, AS_FLOAT, dom_pps_blue);
	if(c3 >= 0) addstat(STAT_DOM_PPS_YELLOW, AS_FLOAT, dom_pps_yellow);
	if(c4 >= 0) addstat(STAT_DOM_PPS_PINK, AS_FLOAT, dom_pps_pink);
	
	InitializeEntity(world, dom_DelayedInit, INITPRIO_GAMETYPE);
}


MUTATOR_DEFINITION(gamemode_domination)
{
	MUTATOR_HOOK(ClientConnect, dom_ClientConnect, CBC_ORDER_ANY);
	MUTATOR_HOOK(HavocBot_ChooseRule, dom_BotRoles, CBC_ORDER_ANY);
	
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

	return 0;
}
