// round handling
float total_players;
float redalive, bluealive;
.float redalive_stat, bluealive_stat;
float ca_teams;
float allowed_to_spawn;

void JB_count_alive_players()
{
	entity e;
	total_players = redalive = bluealive = 0;
	FOR_EACH_PLAYER(e) {
		if(e.team == NUM_TEAM_1)
		{
			++total_players;
			if (!e.jb_isprisoned) ++redalive;
		}
		else if(e.team == NUM_TEAM_2)
		{
			++total_players;
			if (!e.jb_isprisoned) ++bluealive;
		}
	}
	FOR_EACH_REALCLIENT(e) {
		e.redalive_stat = redalive;
		e.bluealive_stat = bluealive;
	}
}

float JB_GetWinnerTeam()
{
	float winner_team = 0;
	if(redalive >= 1)
		winner_team = NUM_TEAM_1;
	if(bluealive >= 1)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_2;
	}
	if(winner_team)
		return winner_team;
	return -1; // no player left
}

#define JB_ALIVE_TEAMS() ((redalive > 0) + (bluealive > 0))
#define JB_ALIVE_TEAMS_OK() (JB_ALIVE_TEAMS() == 2)
float JB_CheckWinner()
{
	entity e, oldself;
	if(round_handler_GetEndTime() > 0 && round_handler_GetEndTime() - time <= 0)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_OVER);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_OVER);
		allowed_to_spawn = FALSE;
		round_handler_Init(5, autocvar_g_jailbreak_warmup, autocvar_g_jailbreak_round_timelimit);
		FOR_EACH_PLAYER(e)
		{
			if(!e.jb_isprisoned)
			{
				oldself = self;
				self = e;
				if(!e.jb_isprisoned)
					e.player_blocked = 1;
				PutClientInServer();
				self = oldself;
			}
			nades_Clear(e);
		}
		jb_roundover = TRUE;
		return 1;
	}

	JB_count_alive_players();
	if(JB_ALIVE_TEAMS_OK())
		return 0;

	float winner_team = JB_GetWinnerTeam();
	
	if(JB_JailIsOpen(winner_team))
		return 0; // ???
	
	if(winner_team > 0)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, APP_TEAM_NUM_4(winner_team, CENTER_ROUND_TEAM_WIN_));
		Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_NUM_4(winner_team, INFO_ROUND_TEAM_WIN_));
		TeamScore_AddToTeam(winner_team, ST_JB_ROUNDS, +1);
		
		JB_ActivateCamera(winner_team, JB_TORTURE_DURATION);
		JB_TorturePrisonersLater(winner_team, 3);
	}
	else if(winner_team == -1)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_TIED);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_TIED);
	}
	
	jb_roundover = TRUE;

	allowed_to_spawn = FALSE;
	round_handler_Init(JB_TORTURE_DURATION, autocvar_g_jailbreak_warmup, autocvar_g_jailbreak_round_timelimit);

	FOR_EACH_PLAYER(e)
	{
		if(!e.jb_isprisoned)
		{
			oldself = self;
			self = e;
			if(!e.jb_isprisoned)
				e.player_blocked = 1;
			PutClientInServer();
			self = oldself;
		}
		nades_Clear(e);
	}

	return 1;
}

void JB_RoundStart()
{
	if(warmup_stage)
		allowed_to_spawn = TRUE;
	else
		allowed_to_spawn = FALSE;
}

float prev_total_players;
float JB_CheckTeams()
{
	allowed_to_spawn = TRUE;
	JB_count_alive_players();
	if(JB_ALIVE_TEAMS_OK())
	{
		if(prev_total_players > 0)
			Kill_Notification(NOTIF_ALL, world, MSG_CENTER_CPID, CPID_MISSING_TEAMS);
		prev_total_players = -1;
		return 1;
	}
	if(prev_total_players != total_players)
	{
		float p1 = 0, p2 = 0, p3 = 0, p4 = 0;
		if(!redalive) p1 = NUM_TEAM_1;
		if(!bluealive) p2 = NUM_TEAM_2;
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_MISSING_TEAMS, p1, p2, p3, p4);
		prev_total_players = total_players;
	}
	return 0;
}

// logging
void JB_Log(float backlog, string s)
{
	if(autocvar_g_jailbreak_log)
	if(backlog)
		bprint(sprintf("Jailbreak: %s\n", s));
	else
		print(sprintf("Jailbreak: %s\n", s));
}

// camera
void SetCamera(entity player, entity cam, float timeout)
{
	if(IS_REAL_CLIENT(player))
	{
		msg_entity = player;
		WriteByte(MSG_ONE, SVC_TEMPENTITY);
		WriteByte(MSG_ONE, TE_CSQC_CAMERA);
		WriteByte(MSG_ONE, TRUE);
		WriteShort(MSG_ONE, cam.origin_x);
		WriteShort(MSG_ONE, cam.origin_y);
		WriteShort(MSG_ONE, cam.origin_z);
		WriteShort(MSG_ONE, timeout);
	}
}

void ClearCamera(entity player)
{
	if(IS_REAL_CLIENT(player))
	{
		msg_entity = player;
		WriteByte(MSG_ONE, SVC_TEMPENTITY);
		WriteByte(MSG_ONE, TE_CSQC_CAMERA);
		WriteByte(MSG_ONE, FALSE);
	}
}

void SetCameraWithAngles(entity player, entity cam, float timeout)
{
	if(IS_REAL_CLIENT(player))
	{
		SetCamera(player, cam, timeout);
		player.angles = cam.angles;
		player.angles_z = 0;
		player.fixangle = TRUE;
	}
}

// to cleanup
void JB_ClearCameraForAll() { entity p; FOR_EACH_REALCLIENT(p) JB_ClearCamera(p); }

void JB_AddDoor(entity door, float theteam, vector vdata, string sdata, entity cpoint) {
	if(door.classname != "door" && door.classname != "door_rotating") {
		JB_Log(TRUE, strcat("Warning: ^3", JB_ControlPoint_Name(cpoint), "^7 at ", vtos(cpoint.origin), " is linked with an entity of unhandled class (^3", door.classname, "^7)!"));
		return;
	}

	if(!JB_FIRSTDOOR(theteam))
		JB_SETFIRSTDOOR(theteam, door);

	if(JB_LASTDOOR(theteam))
		JB_NEXTDOOR(JB_LASTDOOR(theteam)) = door;

	JB_SETLASTDOOR(theteam, door);
}

float jb_doors_opened[2];
void JB_MaybeOpenDoor(entity door, float openjails, vector vdata, string sdata, entity cpoint)
{
	if(openjails == OPENJAILS_LOCKED && door.jaildoormode != JAILDOORMODE_OPEN)
		return;

	if(openjails == OPENJAILS_OPEN && door.jaildoormode == JAILDOORMODE_CLOSED)
		return;

	// OPENJAILS_LOCKED_FORCE is handled in JB_NonJBInit
	// For OPENJAILS_OPEN_FORCE, the below is always executed

	entity oldself = self;
	self = door;
	float opened = TRUE;

	switch(door.classname) {
		case "door":
			door_init_startopen();
			break;

		case "door_rotating":
			door_rotating_init_startopen();
			InitMovingBrushTrigger();
			break;

		default:
			JB_Log(TRUE, strcat("Warning: ^3", JB_ControlPoint_Name(cpoint), "^7 at ", vtos(cpoint.origin), " is linked with an entity of unhandled class (^3", door.classname, "^7)!"));
			opened = FALSE;
			break;
	}

	self = oldself;

	if(opened) {
		float idx = Team_TeamToNumber(cpoint.team);
		jb_doors_opened[idx] = jb_doors_opened[idx] + 1;
	}
}

// This is called for non-jailbreak modes only, to alter jb-specific entities on the map
void JB_NonJBInit()
{
	entity e;
	float openjails = autocvar_g_jailbreak_nonjb_openjails;

	SUB_ForEachTarget_Init();
	FOR_EACH_JB_CONTROLPOINT(e) if(e.team != JB_TEAM_NEUTRAL) {
		if(openjails != OPENJAILS_LOCKED_FORCE)
			SUB_ForEachTarget(e, JB_MaybeOpenDoor, TRUE, openjails, '0 0 0', string_null, e);
		e.think = SUB_Remove;
		e.nextthink = time;
	}

	// If all jail doors are locked, it means that the jail is not intended to be accessible.
	// We have to keep the jail sectors then to ensure it's not possible to get in with translocator (or something more evil to be added in the future).
	// Otherwise, they have to be removed. TODO: do something about maps with multiple jails (if we ever get any).

	for(e = findchain(classname, "jailbreak_jail"); e; e = e.chain) {
		float idx = Team_TeamToNumber(e.team);
		if(!autocvar_g_nades || jb_doors_opened[idx]) {
			e.think = SUB_Remove;
			e.nextthink = time;
		}
	}
}

//
//	Gametype logic
//

float JB_JailIsOpen(float theteam)
{
	entity e;
	FOR_EACH_JB_DOOR(e, theteam) if(e.state != STATE_BOTTOM)
		return TRUE;
	return FALSE;
}

void JB_TeleportToJail(entity p)
{
	if(p.jb_specteam)
		return;

	vector a;
	float et = JB_GetEnemyTeamOf(p.team);
	entity spot = JB_ChooseJailSpawnpoint(et);

	float tries;
	tries = 3;

	while(!spot && tries) {
		spot = JB_ChooseJailSpawnpoint(et);
		tries--;
	}

	if(!spot) {
		JB_Log(TRUE, strcat("Failed to pick a jail spawnpoint for ", self.netname, "^7, cannot imprison!"));
		return;
	}

	a = spot.angles;
	a_z = 0;
	TeleportPlayer(spot, self, spot.origin, self.mangle, a, '0 0 0', '0 0 0', TELEPORT_FLAGS_TELEPORTER);
}

void JB_Imprison(entity attacker)
{
	if(self.jb_isprisoned)
	{
		JB_Log(FALSE, strcat("Tried to imprison a prisoned player (", self.netname, ")"));
		return;
	}

	self.health = autocvar_g_jailbreak_prisoner_health;
	self.armorvalue = autocvar_g_jailbreak_prisoner_armor;

	self.jb_had_unlimited_ammo = (self.items & IT_UNLIMITED_WEAPON_AMMO);

	if(!self.jb_had_unlimited_ammo)
		self.items |= IT_UNLIMITED_WEAPON_AMMO;

	self.jb_fragrow = 0;
	
	self.weapon_blocked = TRUE;
	
	nades_Clear(self);

	JB_Log(FALSE, strcat("Imprisoning ", self.netname, "^7, attacker: ", etos(attacker), " with netname: ", attacker.netname));
	JB_TeleportToJail(self);

	self.jb_isprisoned = TRUE;
	self.jb_prisontime = time;
	self.jb_jaildm_aggressive = FALSE;

	if(!self.jb_specteam)
		Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_JAILBREAK_IMPRISON);
}

void JB_TorturePrisonersLater_Think()
{
	JB_TorturePrisoners(self.team);
	remove(self);
}

void JB_TorturePrisonersLater(float theteam, float thedelay)
{
	entity e = spawn();
	e.team = theteam;
	e.think = JB_TorturePrisonersLater_Think;
	e.nextthink = time + thedelay;
}

void JB_Release(entity saviour)
{
	if(!self.jb_isprisoned)
	{
		JB_Log(FALSE, strcat("Tried to release a free player (", self.netname, ")"));
		return;
	}

	self.jb_isprisoned = FALSE;
	self.jb_imprisoner = world;
	self.weapon_blocked = FALSE;
	self.player_blocked = FALSE; // just incase

	if(!self.jb_had_unlimited_ammo)
		self.items &= ~IT_UNLIMITED_WEAPON_AMMO;

	if(g_jailbreak_jail_deathmatch)
	{
		self.health = max(self.health, autocvar_g_jailbreak_prisoner_health);
		self.armorvalue = max(self.armorvalue, autocvar_g_jailbreak_prisoner_armor);
	}
}

//
//	Torture logic
//

#define JITTER(v,j) (v) + (j) * 2 * (random() - 0.5)

void JB_TorturePrisoners(float theteam)
{
	entity spot = world;
	
	for(;(spot = find(spot, classname, "info_jailbreak_torturespawn"));)
		if(spot.team == theteam)
			JB_Torture_Start(spot);
}

void JB_Torture_Think()
{
	if(gameover)
	{
		remove(self);
		return;
	}

	makevectors(self.angles);
	//self.nextthink = time + JITTER(self.jb_torture_delay, self.jb_torture_delay_jitter);

	float j = self.jb_torture_delay - JITTER(self.jb_torture_delay, self.jb_torture_delay_jitter);

	if(j > 0)
		j = 0.5 * j;

	self.nextthink = time + max(0.1, self.jb_torture_delay + j);
	self.jb_torture_suggestedforce = JITTER(self.jb_torture_force, self.jb_torture_force_jitter);

	pointparticles(particleeffectnum("poisonfield"), self.origin, '0 0 0', 2);
	
	entity head;
	FOR_EACH_PLAYER(head) if(DIFF_TEAM(head, self)) if(head.jb_isprisoned) { Damage(head, self, self, 2, DEATH_POISONFIELD, head.origin, '0 0 0'); }
}

void JB_Torture_Start(entity spot)
{
	entity e = spawn();
	e.classname = "jailbreak_torture";
	e.reset = SUB_Remove;
	e.reset2 = e.reset;
	e.think = JB_Torture_Think;
	e.angles = spot.angles;
	e.jb_torture_delay = spot.jb_torture_delay;
	e.jb_torture_delay_jitter = spot.jb_torture_delay_jitter;
	e.jb_torture_force = spot.jb_torture_force;
	e.jb_torture_force_jitter = spot.jb_torture_force_jitter;
	e.owner = spot;
	e.team = e.owner.team;
	setorigin(e, spot.origin);
	e.nextthink = time + JITTER(0, e.jb_torture_delay_jitter);
}

#undef JITTER

.float pointupdatetime;

//
//	Utility functions
//

entity JB_ChooseJailSpawnpoint(float theteam)
{
	entity spot = world;

	RandomSelection_Init();
	for(;(spot = find(spot, classname, "info_jailbreak_jailspawn"));) if(spot.team == theteam)
	{
		RandomSelection_Add(spot, 0, string_null, 1, 1);
	}

	spot = RandomSelection_chosen_ent;
	if(!spot)
		JB_Log(FALSE, strcat("JB_ChooseJailSpawnpoint(", ftos(theteam), ") failed!"));

	return spot;
}

float JB_GetEnemyTeamOf(float t) { return ((t == NUM_TEAM_1)? NUM_TEAM_2 : NUM_TEAM_1); }

float JB_TotalPlayersOnTeam(float theteam)
{
	entity e;
	float plcount = 0;
	FOR_EACH_PLAYER(e) if(e.team == theteam) ++plcount;
	
	return plcount;
}

float JB_AlivePlayersOnTeam(float theteam)
{
	entity e;
	float plcount = 0;
	FOR_EACH_PLAYER(e) if(e.team == theteam) if(!e.jb_isprisoned) ++plcount;
	
	return plcount;
}

entity JB_FindCamera(float theteam)
{
	RandomSelection_Init();

	entity e = world;
	for(;(e = find(e, classname, "info_jailbreak_jailcamera"));) if(e.team == theteam)
		RandomSelection_Add(e, 0, string_null, 1, 1);

	return RandomSelection_chosen_ent;
}

//float SVC_SETVIEWPORT = 5;
//float SVC_SETVIEWANGLES = 10;

float jb_ce_pvs, jb_ce_trace;

void JB_RestoreCullEntities()
{
	cvar_set("sv_cullentities_pvs", ftos(jb_ce_pvs));
	cvar_set("sv_cullentities_trace", ftos(jb_ce_trace));
	remove(self);
}

void JB_ActivateCamera(float theteam, float timeout)
{
	entity cam = JB_FindCamera(theteam);

	if(!cam)
	{
		JB_Log(FALSE, strcat("JB_ActivateCamera: the ", Team_ColoredFullName(theteam), "^7 has no camera entities, mapper sucks!"));
		return;
	}

	jb_ce_pvs = cvar("sv_cullentities_pvs");
	jb_ce_trace = cvar("sv_cullentities_trace");

	// without this we won't be able to watch them burn!
	cvar_settemp("sv_cullentities_pvs", "0");
	cvar_settemp("sv_cullentities_trace", "0");

	entity e = spawn();
	e.think = JB_RestoreCullEntities;
	e.nextthink = time + timeout;

	entity p;
	FOR_EACH_PLAYER(p)
	{
		if(IS_REAL_CLIENT(p))
		{
			if(p.team == theteam)
			{
				p.angles = cam.angles;
				p.angles_z = 0;
				p.fixangle = TRUE;
				p.jb_roundlost = FALSE;
			}
			else
				p.jb_roundlost = TRUE;
		}

		entity s;
		FOR_EACH_REALCLIENT(s) if(s == p || (IS_SPEC(s) && s.enemy == p))
			JB_SetCamera(s, cam, timeout);
	}

	jb_activecamera = cam;
}

//
//	Setup functions
//

void JB_SetupJailSpawnpoint()
{
	if(!g_jailbreak) { remove(self); return; }

	self.classname = "info_jailbreak_jailspawn";
}

void JB_Jail_Touch()
{
	//JB_Log(FALSE, strcat(other.netname, "^7 is in the ", ColoredTeamName(self.team), " ^7jail"));

	if(autocvar_g_nades)
	if(other.classname == "nade")
	{
		entity own = other.realowner;
		remove(other);
		nades_Clear(own);
		return;
	}
	
	if(other.classname == "grapplinghook")
	{
		RemoveGrapplingHook(other.realowner);
		return;
	}

	if(!g_jailbreak)
		return;

	if(!IS_PLAYER(other))
		return;

	if(!other.jb_isprisoned)
	{
		vector mymid = (self.absmin + self.absmax) * 0.5;
		vector othermid = (other.absmin + other.absmax) * 0.5;

		Damage(other, self, self, 0, DEATH_HURTTRIGGER, mymid, normalize(othermid - mymid) * min(500, vlen(other.velocity)));
		Send_Notification(NOTIF_ONE, other, MSG_CENTER, CENTER_JAILBREAK_NOENTRY);
		return;
	}

	other.jb_isprisoned = 2;

	if(SAME_TEAM(other, self))
		return;

	other.jb_jail_resettime = time + frametime * 5;
}

void JB_SetupJail()
{
	self.classname = "jailbreak_jail";
	self.touch = JB_Jail_Touch;
	EXACTTRIGGER_INIT;
}

void JB_SetupJailCamera()
{
	if(!g_jailbreak) { remove(self); return; }

	self.classname = "info_jailbreak_jailcamera";
}

void JB_SetupTortureSpawnpoint()
{
	if(!g_jailbreak) { remove(self); return; }

	self.classname = "info_jailbreak_torturespawn";

	if(!self.jb_torture_force)
		self.jb_torture_force = 400;

	if(!self.jb_torture_force_jitter)
		self.jb_torture_force_jitter = self.jb_torture_force * 0.1;

	if(!self.jb_torture_delay)
		self.jb_torture_delay = 2;

	if(!self.jb_torture_delay_jitter)
		self.jb_torture_delay_jitter = self.jb_torture_delay * 0.5;
}

.entity sprite;
void AnimateDomPoint();

string JB_ControlPoint_ModelForTeam(float t)
{
	switch(t)
	{
		case NUM_TEAM_1:		return "models/domination/dom_red.md3";
		case NUM_TEAM_2:		return "models/domination/dom_blue.md3";
		default:				return "models/domination/dom_yellow.md3";
	}
}

string JB_ControlPoint_WaypointForTeam(float t)
{
	switch(t)
	{
		case NUM_TEAM_1:		return "dom-red";
		case NUM_TEAM_2:		return "dom-blue";
		default:				return "dom-yellow";
	}
}

float JB_ControlPoint_Cooldown(entity e)
{
	float base, pw, f, c;

	c = e.jb_capturecount;

	if(e.team == JB_TEAM_NEUTRAL) {
		base = autocvar_g_jailbreak_controlpoint_idletime_neutral;
		pw	 = autocvar_g_jailbreak_controlpoint_idletime_neutral_power;
		f	 = autocvar_g_jailbreak_controlpoint_idletime_neutral_factor;
	} else {
		base = autocvar_g_jailbreak_controlpoint_idletime;
		pw	 = autocvar_g_jailbreak_controlpoint_idletime_power;
		f	 = autocvar_g_jailbreak_controlpoint_idletime_factor;
	}

	return base + pow(c, pw) * f * base;
}

float JB_ControlPoint_InitialCooldown(entity e) { return ((e.team == JB_TEAM_NEUTRAL) ? autocvar_g_jailbreak_controlpoint_idletime_neutral_initial : autocvar_g_jailbreak_controlpoint_idletime_initial); }

void JB_ControlPoint_Activate(entity e)
{
	e.jb_active = TRUE;
	e.jb_cooldown = 0;
	//e.jb_cooldown_max = 0;
	setmodel(e, JB_ControlPoint_ModelForTeam(e.team));
	WaypointSprite_UpdateMaxHealth(e.jb_waypoint, 0);
	WaypointSprite_UpdateHealth(e.jb_waypoint, 0);
}

void JB_ControlPoint_Deactivate(entity e, float cooldown)
{
	e.jb_cooldown_max = max(e.jb_cooldown_max, cooldown);
	e.jb_cooldown	  = max(e.jb_cooldown,	   cooldown);

	JB_Log(FALSE, strcat(etos(e), ": ", ftos(e.jb_cooldown), "s cooldown. Team: ", ftos(e.team), ", Caps: ", ftos(e.jb_capturecount)));

	if(e.jb_active && e.jb_cooldown > 0) {
		setmodel(e, "models/domination/dom_unclaimed.md3");
		e.jb_active = FALSE;
	}
}

void JB_ControlPoint_UpdateCooldownProgress(entity e)
{
	WaypointSprite_UpdateMaxHealth(e.jb_waypoint, e.jb_cooldown_max);
	WaypointSprite_UpdateHealth(e.jb_waypoint, e.jb_cooldown_max - e.jb_cooldown);
}

void JB_ControlPoint_DefendWaypoint()
{
	entity plr;
	float detected = FALSE;
	float rng;

	if(time < self.jb_defendthink_next)
		return;

	rng = autocvar_g_jailbreak_controlpoint_detect_enemies;

	FOR_EACH_PLAYER(plr) if(DIFF_TEAM(plr, self)) if(!plr.jb_isprisoned) {
		if(vlen(self.origin - plr.origin) < rng)
		if(checkpvs(self.origin, plr)) {
			detected = TRUE;
			break;
		}
	}

	//if(detected)
		//WaypointSprite_UpdateSprites(self.jb_waypoint, self.jb_waypoint.model1, "DEFEND!", self.jb_waypoint.model3);
	//else
		//WaypointSprite_UpdateSprites(self.jb_waypoint, self.jb_waypoint.model1, "", self.jb_waypoint.model3);

	self.jb_defendthink_next = time + 0.1;
}

void JB_ControlPoint_Think()
{
	self.nextthink = time;
	AnimateDomPoint();
	JB_ControlPoint_DefendWaypoint();

	if(time < game_starttime || jb_roundover)
		return;

	if(self.jb_cooldown) {
		JB_ControlPoint_UpdateCooldownProgress(self);
	} else if(!self.jb_active) {
		JB_ControlPoint_Activate(self);
	}

	if(time - self.pointupdatetime >= 0.1) {
		self.jb_unlock_progress = 0;
		self.jb_capturingplayer = world;
	}

	self.jb_cooldown = max(0, self.jb_cooldown - frametime);
}

void JB_ControlPoint_SwitchTeam(entity e, float t)
{
	e.team = t;
	//WaypointSprite_UpdateSprites(e.jb_waypoint, e.jb_waypoint.model1, "", e.jb_waypoint.model3);
	WaypointSprite_UpdateTeamRadar(e.jb_waypoint, RADARICON_FLAG, colormapPaletteColor(e.team - 1, FALSE));
	//WaypointSprite_UpdateTextColors(e.jb_waypoint, TeamColor(e.team), e.jb_waypoint.clr2, e.jb_waypoint.clr3);
	switch(e.team)
	{
		case NUM_TEAM_1: e.jb_waypoint.team = NUM_TEAM_2; break;
		case NUM_TEAM_2: e.jb_waypoint.team = NUM_TEAM_1; break;
		default: e.jb_waypoint.team = 0; break;
	}
	e.jb_waypoint.SendFlags |= 1;
}

void JB_TriggerTeamControlPoints(float t)
{
	entity o;
	o = self;

	FOR_EACH_JB_CONTROLPOINT(self)
		if(self.jb_team_initial == t)
			SUB_UseTargets_PreventReuse();

	self = o;
}

string JB_ControlPoint_Name(entity p)
{
	string clr, tm, end;

	switch(p.team)
	{
		case NUM_TEAM_1:	clr = "^1"; tm = "Red"; break;
		case NUM_TEAM_2:	clr = "^4"; tm = "Blue"; break;
		default:			clr = "^3"; tm = "Neutral"; break;
	}

	end = strcat(" (Point ", chr2str(str2chr("A", 0) + p.cnt), ")");

	if(!p.netname)
		return strcat(clr, tm, " Control Point", end);
	return strcat(clr, strdecolorize(p.netname), end);
}

void JB_ControlPoint_Capture(entity player)
{
	entity e;
	float pc = FALSE;

	activator = self;

	if(self.team == JB_TEAM_NEUTRAL || g_jailbreak_claim)
		JB_TriggerTeamControlPoints(JB_GetEnemyTeamOf(player.team));
	else SUB_UseTargets();
	
	FOR_EACH_PLAYER(e)
	{
		if(DIFF_TEAM(e, player))
			Send_Notification(NOTIF_ONE, e, MSG_CENTER, CENTER_JAILBREAK_ESCAPE, player.team);
		else if(e == player)
			Send_Notification(NOTIF_ONE, e, MSG_CENTER, CENTER_JAILBREAK_FREED);

		if(e.jb_isprisoned && SAME_TEAM(e, player))
		{
			Send_Notification(NOTIF_ONE, e, MSG_CENTER, CENTER_JAILBREAK_FREE);
			pc++;
		}

	}

	Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_JAILBREAK_CAPTURE, player.netname, JB_ControlPoint_Name(self));
	
	FOR_EACH_JB_CONTROLPOINT(e) { e.jb_lastmessage = time + 3; }

	entity o = self;
	FOR_EACH_CLIENT(self) if(!self.iscreature) if(self.jb_specteam == player.team)
		LeaveSpectatorMode();
	self = o;

	PlayerScore_Add(player, SP_SCORE, ((self.team == JB_TEAM_NEUTRAL)? autocvar_g_jailbreak_score_jbreak_neutralmultiplier : 1)
									* (autocvar_g_jailbreak_score_jbreak + autocvar_g_jailbreak_score_jbreak_perplayer * pc));
	PlayerScore_Add(player, SP_JB_JBREAKS, 1);
	PlayerScore_Add(player, SP_JB_FREED, pc);
	nades_GiveBonus(player, autocvar_g_nades_bonus_score_medium);
	play2all("kh/alarm.wav");

	if(autocvar_g_jailbreak_controlpoint_claim_noneutral)
	if(self.team == JB_TEAM_NEUTRAL)
		return;

	JB_ControlPoint_SwitchTeam(self, player.team);
}

void JB_ControlPoint_Touch()
{
	if(jb_roundover)
		return;

	if(other.health < 1 || other.frozen)
		return;
		
	if(gameover)
		return;

	if(!IS_PLAYER(other))
		return;

	other.pointupdatetime = time;

	if(SAME_TEAM(other, self))
	{
		if(time >= self.jb_lastmessage)
		{
			Send_Notification(NOTIF_ONE, other, MSG_CENTER, CENTER_JAILBREAK_WRONGTEAM);
			self.jb_lastmessage = time + 1.5;
		}
		return;
	}

	if(!self.jb_active)
	{
		if(time >= self.jb_lastmessage)
		{
			Send_Notification(NOTIF_ONE, other, MSG_CENTER, CENTER_JAILBREAK_NOTREADY);
			self.jb_lastmessage = time + 1.5;
		}
		return;
	}

	if(self.jb_capturingplayer && self.jb_capturingplayer != other)
	{
		if(time >= self.jb_lastmessage)
		{
			Send_Notification(NOTIF_ONE, other, MSG_CENTER, CENTER_JAILBREAK_TOOLATE);
			self.jb_lastmessage = time + 1.5;
		}
		return;
	}

	if(JB_TotalPlayersOnTeam(other.team) == JB_AlivePlayersOnTeam(other.team))
	{
		if(time >= self.jb_lastmessage)
		{
			Send_Notification(NOTIF_ONE, other, MSG_CENTER, CENTER_JAILBREAK_TEAMALIVE);
			self.jb_lastmessage = time + 1.5;
		}
		return;
	}

	entity cp;
	float capping_neutral = FALSE;
	if(self.team != JB_TEAM_NEUTRAL) FOR_EACH_JB_CONTROLPOINT(cp)
	if(cp.team == JB_TEAM_NEUTRAL) if(cp.jb_unlock_progress) if(cp.jb_capturingplayer.team == other.team)
	{
		capping_neutral = TRUE;
		break;
	}

	if(!capping_neutral || self.team == JB_TEAM_NEUTRAL)
		self.jb_unlock_progress = bound(0, self.jb_unlock_progress + frametime * autocvar_g_jailbreak_controlpoint_unlock_speed, 1);

	self.pointupdatetime = time;
	self.jb_capturingplayer = other;
	other.jb_unlock_progress = self.jb_unlock_progress;

	if(self.jb_unlock_progress >= 1)
	{
		JB_ControlPoint_Capture(other);

		JB_ControlPoint_Deactivate(self, JB_ControlPoint_Cooldown(self));
		entity e; FOR_EACH_JB_CONTROLPOINT(e) if(e != self)
			if(e.team == other.team)
				JB_ControlPoint_Deactivate(e, autocvar_g_jailbreak_controlpoint_idletime_global_own);
			else if(e.team == JB_TEAM_NEUTRAL || e.team == JB_GetEnemyTeamOf(other.team))
				JB_ControlPoint_Deactivate(e, autocvar_g_jailbreak_controlpoint_idletime_global);

		self.jb_capturecount += 1;
	}
}

void JB_ControlPoint_Reset()
{
	self.jb_capturecount = 0;
	self.jb_active = TRUE;
	self.jb_cooldown = 0;
	self.jb_cooldown_max = 0;
	JB_ControlPoint_Deactivate(self, JB_ControlPoint_InitialCooldown(self));
	WaypointSprite_UpdateMaxHealth(self.jb_waypoint, 0);
	WaypointSprite_UpdateHealth(self.jb_waypoint, 0);
	JB_ControlPoint_SwitchTeam(self, autocvar_g_jailbreak_controlpoint_claim_allneutral ? JB_TEAM_NEUTRAL : self.jb_team_initial);
}

void JB_SetupControlPoint()
{
	if(!jb_cp_first) {
		jb_cp_first = self;
	}

	if(jb_cp_last)
		jb_cp_last.jb_cp_next = self;

	jb_cp_last = self;

	if(!g_jailbreak) { return; } // removal is done in JB_NonJBInit

	self.classname = "jailbreak_controlpoint";
	self.jb_team_initial = self.team;

	if(autocvar_g_jailbreak_controlpoint_claim_allneutral)
		self.team = JB_TEAM_NEUTRAL;

	setmodel(self, JB_ControlPoint_ModelForTeam(self.team));
	self.skin = 0;

	if(!self.t_width)
		self.t_width = 0.02; // frame animation rate
	if(!self.t_length)
		self.t_length = 239; // maximum frame

	self.think = JB_ControlPoint_Think;
	self.nextthink = time;
	self.touch = JB_ControlPoint_Touch;
	self.solid = SOLID_TRIGGER;
	self.flags = FL_ITEM;
	self.reset = JB_ControlPoint_Reset;
	self.jb_capturecount = 0;
	self.jb_active = TRUE;
	self.cnt = jb_cp_num;
	JB_ControlPoint_Deactivate(self, JB_ControlPoint_InitialCooldown(self));
	setsize(self, '-32 -32 -32', '32 32 32');
	setorigin(self, self.origin + '0 0 20');
	droptofloor();

	waypoint_spawnforitem_force(self, self.origin);
	self.nearestwaypointtimeout = 0; // activate waypointing again
	WaypointSprite_SpawnFixed(strzone(strcat("Point ", chr2str(str2chr("A", 0) + jb_cp_num))), self.origin + '0 0 37', self, jb_waypoint, RADARICON_DOMPOINT, '0 1 1');
	switch(self.team)
	{
		case NUM_TEAM_1: self.jb_waypoint.team = NUM_TEAM_2; break;
		case NUM_TEAM_2: self.jb_waypoint.team = NUM_TEAM_1; break;
		default: self.jb_waypoint.team = 0; break;
	}
	self.jb_waypoint.SendFlags |= 1;
	WaypointSprite_UpdateTeamRadar(self.jb_waypoint, RADARICON_FLAG, colormapPaletteColor(self.team - 1, FALSE));
	//WaypointSprite_UpdateTextColors(self.jb_waypoint, TeamColor(self.team), '1 0.5 0', '0 0 0');
	//WaypointSprite_UpdateSprites(self.jb_waypoint, self.jb_waypoint.model1, self.jb_waypoint.model2, "");

	++jb_cp_num;
}

//
//	Jail-spectating
//

void JB_JailSpectate()
{
	self.jb_specteam = self.team;
}

void JB_JailSpec_Proxy_CopyFields(entity to, entity from)
{
	entity o = self;
	self = to;
	SpectateCopy(from);
	self = o;

	to.jb_isprisoned = from.jb_isprisoned;
	to.velocity = '0 0 0';

	if(!to.iscreature)
		setmodel(to, from.model);
}

void JB_JailSpec_Proxy_Think()
{
	player_regen();
	self.nextthink = time;
}

entity JB_JailSpec_CreateProxy()
{
	entity p = spawn();
	JB_JailSpec_Proxy_CopyFields(p, self);
	p.think = JB_JailSpec_Proxy_Think;
	p.nextthink = time;
	p.owner = self;
	self.jb_jailspec_proxy = p;
	return p;
}

// mutator hooks
MUTATOR_HOOKFUNCTION(jb_OnEntityPreSpawn)
{
	switch(self.classname)
	{
		case "item_flag_team1":
		case "item_flag_team2":
		case "item_flag_team3":
		case "item_flag_team4":
			return TRUE;
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(jb_ResetMap)
{
	jb_activecamera = world;
	jb_roundover = FALSE;
	
	JB_ClearCameraForAll();

	FOR_EACH_CLIENT(self)
	{
		if(IS_PLAYER(self))
		{
			JB_Release(world);
			PutClientInServer();
		}
		self.player_blocked = 0;
		self.weapon_blocked = FALSE;
	}

	return TRUE;
}

MUTATOR_HOOKFUNCTION(jb_PlayerDies)
{
	if(jb_roundover && frag_deathtype == DEATH_POISONFIELD)
		PlayerScore_Add(frag_target, SP_KILLS, +1); // dying negates 1, so we bring it back up

	if(!round_handler_IsRoundStarted() || jb_roundover)
		return FALSE;

	if(!self.jb_isprisoned)
	{
		if(frag_attacker == self || !frag_attacker)
			PlayerScore_Add(self, SP_SCORE, -autocvar_g_jailbreak_penalty_death);
		else if(IS_PLAYER(frag_attacker))
		{
			if(frag_attacker.team != self.team) {
				PlayerScore_Add(self, SP_SCORE, -autocvar_g_jailbreak_penalty_death);
				PlayerScore_Add(frag_attacker, SP_SCORE, autocvar_g_jailbreak_score_imprison);

				float rng = autocvar_g_jailbreak_defense_range;
				entity cp;
				if(rng) FOR_EACH_JB_CONTROLPOINT(cp)
				{
					if(SAME_TEAM(cp, frag_attacker) || (cp.team == JB_TEAM_NEUTRAL && cp.jb_active))
					{
						// Rewards control point defense if fragging nearby your team's or neutral cp.
						// In case of neutral cp, it has to be active (no defense farming in the beginning of the round)
						if(vlen(cp.origin - self.origin) < rng)
						{
							Send_Notification(NOTIF_ONE, frag_attacker, MSG_CENTER, CENTER_JAILBREAK_DEFENSE);
							PlayerScore_Add(frag_attacker, SP_SCORE, autocvar_g_jailbreak_score_defense);
							PlayerScore_Add(frag_attacker, SP_JB_DEFENSE, 1);
							nades_GiveBonus(frag_attacker, autocvar_g_nades_bonus_score_minor);
							break;
						}
					}
				}
			}
			else PlayerScore_Add(frag_attacker, SP_SCORE, -autocvar_g_jailbreak_penalty_teamkill);
		}

		frag_target.jb_imprisoner = frag_attacker;
		frag_target.respawn_flags |= RESPAWN_FORCE;
	}
	else
	{
		JB_Log(FALSE, strcat("Prisoned player ", self.netname, " ^7just died. Should this really happen?"));
		PutClientInServer();
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(jb_PlayerSpawn)
{
	self.jb_isprisoned = FALSE;

	self.jb_fragrow = 0;

	if(jb_activecamera && jb_roundover)
		JB_SetCameraWithAngles(self, jb_activecamera, JB_TORTURE_DURATION);

	if(!round_handler_IsRoundStarted())
	{
		if(self.jb_specteam)
			JB_Imprison(world);
		return FALSE;
	}
	
	if(self.jb_imprisoner != world)
	{
		JB_Imprison(self.jb_imprisoner);
		self.jb_imprisoner = world;
	}

	if(JB_TotalPlayersOnTeam(self.team) - 1 > 0 || self.jb_specteam) {	// allow to spawn non-prisoned if there are no players on that team
		JB_Imprison(world);
	}
	
	ClearCamera(self);

	self.jb_roundlost = FALSE;
	
	self.jb_specteam = 0;
	
	if(self.jb_jailspec_proxy)
	{
		JB_JailSpec_Proxy_CopyFields(self, self.jb_jailspec_proxy);
		remove(self.jb_jailspec_proxy);
		self.jb_jailspec_proxy = world;
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(jb_RemovePlayer)
{
	if(self.jb_isprisoned && !self.jb_specteam)
		JB_Release(world);

	self.jb_roundlost = FALSE;
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(jb_PlayerPreThink)
{
	if(gameover)
		return FALSE;

	if(self.jb_specteam && IS_PLAYER(self))
	{
		JB_JailSpec_CreateProxy();
		self.classname = "observer";
		PutObserverInServer();
		return FALSE;
	}

	if(!round_handler_IsRoundStarted())
	{
		self.jb_isprisoned_prev = 0;
		self.jb_unlock_progress = 0;
		return FALSE;
	}

	float ps = min(1, self.jb_isprisoned);
	if(ps != self.jb_isprisoned_prev)
	{
		if(!ps)
			Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_JAILBREAK_FREE, self.netname);
		self.jb_isprisoned_prev = ps;
	}

	if(time - self.pointupdatetime >= 0.01)
		self.jb_unlock_progress = 0;

	if(time - self.jb_prisontime < 0.5)
		return FALSE;

	if(self.jb_isprisoned == 1)
	{
		JB_Log(FALSE, strcat("^1BUG: ^7", self.netname, " ^7somehow got out of jail without touching the jail sector! Trying to put him back in.\n"));
		JB_TeleportToJail(self);
	}
	else if(self.jb_isprisoned)
	if(time > self.jb_jail_resettime)
		JB_Release(self.jb_saviour);

	return FALSE;
}

MUTATOR_HOOKFUNCTION(jb_PlayerDamage)
{
	if(self.jb_isprisoned && frag_deathtype != DEATH_POISONFIELD)
		frag_damage = 0;

	entity e;
	if(self.jb_unlock_progress)
	{
		FOR_EACH_JB_CONTROLPOINT(e)
		if(e.jb_capturingplayer == self)
			e.jb_unlock_progress = bound(0, e.jb_unlock_progress - autocvar_g_jailbreak_controlpoint_unlock_damage_pushback, 1);
	}
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(jb_ForbidThrowing)
{
	if(self.jb_isprisoned)
		return TRUE;
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(jb_GiveFrags)
{
	if(jb_roundover)
	{
		frag_score = 0;
		return TRUE;
	}
	return FALSE;
}

MUTATOR_HOOKFUNCTION(jb_GetTeamCount)
{
	ret_float = 2;
	return TRUE;
}

// spawn functions
#define JB_SPAWNFUNC(e,s,t) void spawnfunc_##e() { self.team = t; s(); }

JB_SPAWNFUNC(info_jailbreak_jailspawn_red, JB_SetupJailSpawnpoint, NUM_TEAM_1)
JB_SPAWNFUNC(info_jailbreak_jailspawn_blue, JB_SetupJailSpawnpoint, NUM_TEAM_2)

JB_SPAWNFUNC(func_jailbreak_jail_red, JB_SetupJail, NUM_TEAM_1)
JB_SPAWNFUNC(func_jailbreak_jail_blue, JB_SetupJail, NUM_TEAM_2)

JB_SPAWNFUNC(info_jailbreak_jailcamera_red, JB_SetupJailCamera, NUM_TEAM_1)
JB_SPAWNFUNC(info_jailbreak_jailcamera_blue, JB_SetupJailCamera, NUM_TEAM_2)

JB_SPAWNFUNC(info_jailbreak_torturespawn_red, JB_SetupTortureSpawnpoint, NUM_TEAM_1)
JB_SPAWNFUNC(info_jailbreak_torturespawn_blue, JB_SetupTortureSpawnpoint, NUM_TEAM_2)

JB_SPAWNFUNC(jailbreak_controlpoint_red, JB_SetupControlPoint, NUM_TEAM_1)
JB_SPAWNFUNC(jailbreak_controlpoint_blue, JB_SetupControlPoint, NUM_TEAM_2)
JB_SPAWNFUNC(jailbreak_controlpoint_neutral, JB_SetupControlPoint, JB_TEAM_NEUTRAL)

// scores
void ScoreRules_JB()
{
	CheckAllowedTeams(world);
	ScoreRules_basics(2, SFL_SORT_PRIO_PRIMARY, 0, TRUE); // SFL_SORT_PRIO_PRIMARY
	ScoreInfo_SetLabel_TeamScore(ST_JB_ROUNDS,			"rounds",		SFL_SORT_PRIO_PRIMARY);
	ScoreInfo_SetLabel_PlayerScore(SP_JB_JBREAKS,		"jbs",		0);
    ScoreInfo_SetLabel_PlayerScore(SP_JB_FREED,		    "freed",		SFL_SORT_PRIO_SECONDARY);
    ScoreInfo_SetLabel_PlayerScore(SP_JB_DEFENSE,		"def",		0);
	ScoreRules_basics_end();
}

// initialization
void jb_DelayedInit()
{
	entity e;

	SUB_ForEachTarget_Init();
	FOR_EACH_JB_CONTROLPOINT(e)
		SUB_ForEachTarget(e, JB_AddDoor, TRUE, e.jb_team_initial, '0 0 0', string_null, e);
}

void jb_Initialize()
{
	precache_sound("kh/alarm.wav");

	ScoreRules_JB();

	round_handler_Spawn(JB_CheckTeams, JB_CheckWinner, JB_RoundStart);
	round_handler_Init(5, autocvar_g_jailbreak_warmup, autocvar_g_jailbreak_round_timelimit);

	g_jailbreak_claim = autocvar_g_jailbreak_controlpoint_claim;

	addstat(STAT_REDALIVE, AS_INT, redalive_stat);
	addstat(STAT_BLUEALIVE, AS_INT, bluealive_stat);
	addstat(STAT_CAPTURE_PROGRESS, AS_FLOAT, jb_unlock_progress);
	addstat(STAT_PRISONED, AS_INT, jb_isprisoned);
	addstat(STAT_ROUNDLOST, AS_INT, jb_roundlost);

	g_jailbreak_jail_deathmatch = autocvar_g_jailbreak_jail_deathmatch;
	InitializeEntity(world, jb_DelayedInit, INITPRIO_GAMETYPE);
}

MUTATOR_DEFINITION(gamemode_jailbreak)
{
	MUTATOR_HOOK(OnEntityPreSpawn, jb_OnEntityPreSpawn, CBC_ORDER_FIRST);
	MUTATOR_HOOK(reset_map_players, jb_ResetMap, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, jb_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, jb_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientDisconnect, jb_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(MakePlayerObserver, jb_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, jb_PlayerPreThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDamage_Calculate, jb_PlayerDamage, CBC_ORDER_ANY);
	MUTATOR_HOOK(GiveFragsForKill, jb_GiveFrags, CBC_ORDER_ANY);
	MUTATOR_HOOK(ForbidThrowCurrentWeapon, jb_ForbidThrowing, CBC_ORDER_ANY);
	MUTATOR_HOOK(GetTeamCount, jb_GetTeamCount, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		if(time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");
		jb_Initialize();
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		// we actually cannot roll back jb_Initialize here
		// BUT: we don't need to! If this gets called, adding always
		// succeeds.
	}

	MUTATOR_ONREMOVE
	{
		print("This is a game type and it cannot be removed at runtime.");
		return -1;
	}

	return 0;
}
