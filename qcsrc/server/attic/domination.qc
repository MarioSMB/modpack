
/*
Domination as a plugin for netquake mods
by LordHavoc (lordhavoc@ghdigital.com)

How to add domination points to a mod:
1. Add this line to progs.src above world.qc:
domination.qc
2. Comment out all lines in ClientObituary in client.qc that begin with targ.frags  or attacker.frags.
3. Add this above spawnfunc_worldspawn in world.qc:
void() dom_init;
4. Add this line to the end of spawnfunc_worldspawn in world.qc:
dom_init();

Note: The only teams who can use dom control points are identified by spawnfunc_dom_team entities (if none exist these default to red and blue and use only quake models/sounds).
*/

#define DOMPOINTFRAGS frags

.float enemy_playerid;
.entity sprite;
.float captime;

// pps: points per second
.float dom_total_pps;
.float dom_pps_red;
.float dom_pps_blue;
.float dom_pps_yellow;
.float dom_pps_pink;
float total_pps;
float pps_red;
float pps_blue;
float pps_yellow;
float pps_pink;
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

void() dom_controlpoint_setup;

void LogDom(string mode, float team_before, entity actor)
{
	string s;
	if(!autocvar_sv_eventlog)
		return;
	s = strcat(":dom:", mode);
	s = strcat(s, ":", ftos(team_before));
	s = strcat(s, ":", ftos(actor.playerid));
	GameLogEcho(s);
}

void() dom_spawnteams;

void dompoint_captured ()
{
	entity head;
	float old_delay, old_team, real_team;

	// now that the delay has expired, switch to the latest team to lay claim to this point
	head = self.owner;

	real_team = self.cnt;
	self.cnt = -1;

	LogDom("taken", self.team, self.dmg_inflictor);
	self.dmg_inflictor = world;

	self.goalentity = head;
	self.model = head.mdl;
	self.modelindex = head.dmg;
	self.skin = head.skin;

	//bprint(head.message);
	//bprint("\n");

	//bprint(^3head.netname);
	//bprint(head.netname);
	//bprint(self.message);
	//bprint("\n");

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

	//self.nextthink = time + autocvar_g_domination_point_rate;
	//self.think = dompointthink;

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

	switch(self.goalentity.team)
	{
		case NUM_TEAM_1:
			WaypointSprite_UpdateSprites(self.sprite, "dom-red", "", "");
			break;
		case NUM_TEAM_2:
			WaypointSprite_UpdateSprites(self.sprite, "dom-blue", "", "");
			break;
		case NUM_TEAM_3:
			WaypointSprite_UpdateSprites(self.sprite, "dom-yellow", "", "");
			break;
		case NUM_TEAM_4:
			WaypointSprite_UpdateSprites(self.sprite, "dom-pink", "", "");
	}

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
			fragamt = self.DOMPOINTFRAGS;
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
	if (other.classname != "player")
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

	if(self.DOMPOINTFRAGS <= 0)
		self.DOMPOINTFRAGS = 1;
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

	//if(!self.glow_size)
	//	self.glow_size = cvar("g_domination_point_glow");
	self.effects = self.effects | EF_LOWPRECISION;
	if (autocvar_g_domination_point_fullbright)
		self.effects |= EF_FULLBRIGHT;
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
	float numteams;
	if(autocvar_g_domination_teams_override < 2)
		numteams = autocvar_g_domination_default_teams;
	else
		numteams = autocvar_g_domination_teams_override;
	// LordHavoc: edit this if you want to change defaults
	dom_spawnteam("Red", NUM_TEAM_1-1, "models/domination/dom_red.md3", 0, "domination/claim.wav", "", "Red team has captured a control point");
	dom_spawnteam("Blue", NUM_TEAM_2-1, "models/domination/dom_blue.md3", 0, "domination/claim.wav", "", "Blue team has captured a control point");
	if(numteams > 2)
		dom_spawnteam("Yellow", NUM_TEAM_3-1, "models/domination/dom_yellow.md3", 0, "domination/claim.wav", "", "Yellow team has captured a control point");
	if(numteams > 3)
		dom_spawnteam("Pink", NUM_TEAM_4-1, "models/domination/dom_pink.md3", 0, "domination/claim.wav", "", "Pink team has captured a control point");
	dom_spawnteam("", 0, "models/domination/dom_unclaimed.md3", 0, "", "", "");
}

void dom_delayedinit()
{
	entity head;

	// if no teams are found, spawn defaults, if custom teams are set, use them
	if (find(world, classname, "dom_team") == world || autocvar_g_domination_teams_override >= 2)
		dom_spawnteams();
	// if no control points are found, spawn defaults
	if (find(world, classname, "dom_controlpoint") == world)
	{
		// TODO in a few months (maybe 2011/08): change this into error() and remove this very poor dom point selection
		backtrace("This map contains no dom_controlpoint entities. A very poor dom point placement will be chosen. Please fix the map.");

		// if no supported map was found, make every deathmatch spawn a point
		head = find(world, classname, "info_player_deathmatch");
		while (head)
		{
			dom_spawnpoint(head.origin);
			head = find(head, classname, "info_player_deathmatch");
		}
	}

	ScoreRules_dom();
}

void dom_init()
{
	// we have to precache default models/sounds even if they might not be
	// used because spawnfunc_worldspawn is executed before any other entities are read,
	// so we don't even know yet if this map is set up for domination...
	precache_model("models/domination/dom_red.md3");
	precache_model("models/domination/dom_blue.md3");
	precache_model("models/domination/dom_yellow.md3");
	precache_model("models/domination/dom_pink.md3");
	precache_model("models/domination/dom_unclaimed.md3");
	precache_sound("domination/claim.wav");
	InitializeEntity(world, dom_delayedinit, INITPRIO_GAMETYPE);

	addstat(STAT_DOM_TOTAL_PPS, AS_FLOAT, dom_total_pps);
	addstat(STAT_DOM_PPS_RED, AS_FLOAT, dom_pps_red);
	addstat(STAT_DOM_PPS_BLUE, AS_FLOAT, dom_pps_blue);
	if(c3 >= 0) addstat(STAT_DOM_PPS_YELLOW, AS_FLOAT, dom_pps_yellow);
	if(c4 >= 0) addstat(STAT_DOM_PPS_PINK, AS_FLOAT, dom_pps_pink);
}

