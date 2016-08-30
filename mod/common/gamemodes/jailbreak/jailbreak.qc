#ifndef IMPLEMENTATION
#ifndef MENUQC
REGISTER_NET_LINKED(ENT_CLIENT_JAILCAMERA)
#endif
#ifdef SVQC
AUTOCVAR(g_jailbreak, bool, false, "Jailbreak: kill enemies to send them to jail, capture control points to free jailed teammates");
#endif
#include "jailbreak.qh"
#endif

#ifdef IMPLEMENTATION

#ifdef CSQC

REGISTER_MUTATOR(cl_jb, true);

MUTATOR_HOOKFUNCTION(cl_jb, WP_Format)
{
    entity this = M_ARGV(0, entity);
    string s = M_ARGV(1, string);
    if (s == WP_JB_ControlPoint.netname)
    {
    	M_ARGV(2, vector) = this.teamradar_color;
        M_ARGV(3, string) = strzone(sprintf(_("Point %s"), chr2str(str2chr("A", 0) + this.wp_extra)));
        return true;
    }
}

MUTATOR_HOOKFUNCTION(cl_jb, DrawCrosshair)
{
	return (gametype == MAPINFO_TYPE_JAILBREAK && spectatee_status >= 0 && STAT(ROUNDLOST) && !STAT(JB_ISPRISONED));
}

NET_HANDLE(ENT_CLIENT_JAILCAMERA, bool isnew)
{
	this.origin_x = ReadCoord();
	this.origin_y = ReadCoord();
	this.origin_z = ReadCoord();
	setorigin(this, this.origin);
		
	this.angles_x = ReadAngle();
	this.angles_y = ReadAngle();
	this.angles_z = ReadAngle();

	this.drawmask  = MASK_NORMAL;
	setmodel(this, MDL_Null); // give it a size for clientcamera
	setsize(this, '-1 -1 -1', '1 1 1');

	return true;
}

#endif

#ifdef SVQC

REGISTER_MUTATOR(nonjb, true);

MUTATOR_HOOKFUNCTION(nonjb, SetModname)
{
	if(!g_jailbreak)
		InitializeEntity(NULL, JB_NonJBInit, INITPRIO_LAST);
}

AUTOCVAR(g_jailbreak_point_limit, int, 5, "Jailbreak point limit overriding the mapinfo specified one (use 0 to play without limit, and -1 to use mapinfo's limit)");
AUTOCVAR(g_jailbreak_point_leadlimit, int, -1, "Jailbreak point lead limit overriding the mapinfo specified one (use 0 to play without limit, and -1 to use mapinfo's limit)");

void jb_Initialize();
REGISTER_MUTATOR(jb, false)
{
	MUTATOR_ONADD
	{
		if (time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");
		jb_Initialize();

		ActivateTeamplay();
		SetLimits(autocvar_g_jailbreak_point_limit, autocvar_g_jailbreak_point_leadlimit, autocvar_timelimit_override, -1);
		have_team_spawns = -1; // request team spawns
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		// we actually cannot roll back jb_Initialize here
		// BUT: we don't need to! If this gets called, adding always
		// succeeds.
	}

	MUTATOR_ONREMOVE
	{
		LOG_INFO("This is a game type and it cannot be removed at runtime.");
		return -1;
	}

	return false;
}

AUTOCVAR(g_jailbreak_teams, int, 2, "");
AUTOCVAR(g_jailbreak_teams_override, int, 0, "");
AUTOCVAR(g_jb_respawn_delay_small, float, 0, "");
AUTOCVAR(g_jb_respawn_delay_small_count, float, 0, "");
AUTOCVAR(g_jb_respawn_delay_large, float, 0, "");
AUTOCVAR(g_jb_respawn_delay_large_count, float, 0, "");
AUTOCVAR(g_jb_respawn_delay_max, float, 0, "");
AUTOCVAR(g_jb_respawn_waves, float, 0, "");
AUTOCVAR(g_jb_weapon_stay, float, 0, "");
AUTOCVAR(g_jailbreak_warmup, float, 5, "");
AUTOCVAR(g_jailbreak_round_timelimit, float, 360, "");
AUTOCVAR(g_jailbreak_score_imprison, int, 50, "Score for putting an enemy into jail");
AUTOCVAR(g_jailbreak_score_jbreak, int, 0, "Score for releasing your team");
AUTOCVAR(g_jailbreak_score_jbreak_perplayer, int, 35, "Added to g_jailbreak_score_jbreak per released player");
AUTOCVAR(g_jailbreak_score_jbreak_neutralmultiplier, float, 1.2, "Score multiplier for jailbreaking through a neutral control point");
AUTOCVAR(g_jailbreak_score_defense, int, 31, "Additional scoring bonus for defensive frags");
AUTOCVAR(g_jailbreak_defense_range, float, 1000, "Maximum distance to a control point for scoring a Defense");
AUTOCVAR(g_jailbreak_penalty_death, int, 5, "Penalty for dying");
AUTOCVAR(g_jailbreak_penalty_teamkill, int, 20, "Penalty for killing a teammate");
AUTOCVAR(g_jailbreak_controlpoint_unlock_speed, float, 0.25, "Controlpoint capture speed");
AUTOCVAR(g_jailbreak_controlpoint_unlock_damage_pushback, float, 1.0, "Push the capture progress back by this value each time the player takes any damage");
AUTOCVAR(g_jailbreak_controlpoint_idletime, float, 45, "For how long a controlpoint becomes inactive after it's been captured. The formula is: idletime + times_captured^power * idletime * factor");
AUTOCVAR(g_jailbreak_controlpoint_idletime_power, float, 1.2, "See g_jailbreak_controlpoint_idletime");
AUTOCVAR(g_jailbreak_controlpoint_idletime_factor, float, 1, "See g_jailbreak_controlpoint_idletime");
AUTOCVAR(g_jailbreak_controlpoint_idletime_initial, float, 30, "For how long a controlpoint stays inactive at the beginning of the round");
AUTOCVAR(g_jailbreak_controlpoint_idletime_global, float, 20, "For how long all team's controlpoints become inactive after the opposite team successfully jailbreaks");
AUTOCVAR(g_jailbreak_controlpoint_idletime_global_own, float, 5, "Same as idletime_global, but for the capturer's team");
AUTOCVAR(g_jailbreak_controlpoint_idletime_neutral, float, 45, "Idletime for the neutral controlpoint. See g_jailbreak_controlpoint_idletime");
AUTOCVAR(g_jailbreak_controlpoint_idletime_neutral_initial, float, 25, "Initial idletime for the neutral control point");
AUTOCVAR(g_jailbreak_controlpoint_idletime_neutral_power, float, 1, "See g_jailbreak_controlpoint_idletime_neutral");
AUTOCVAR(g_jailbreak_controlpoint_idletime_neutral_factor, float, 1, "See g_jailbreak_controlpoint_idletime_neutral");
AUTOCVAR(g_jailbreak_controlpoint_claim, bool, true, "If enabled, controlpoints will change their team whenever they are triggered");
AUTOCVAR(g_jailbreak_controlpoint_claim_allneutral, bool, false, "If enabled, all controlpoints will start as neutral in claim mode");
AUTOCVAR(g_jailbreak_controlpoint_claim_noneutral, bool, true, "If enabled, neutral controlpoints will not be claimed");
AUTOCVAR(g_jailbreak_torture_damagefactor, float, 0.3, "Damage multiplier for torture scenes");
AUTOCVAR(g_jailbreak_nonjb_openjails, bool, true, "Defines how jail doors behave when playing Jailbreak maps on non-Jailbreak gametypes. 0 = locked unless overriden by the map, 1 = open unless overriden by the map, 2 = always locked, 3 = always open");
AUTOCVAR(g_jailbreak_jail_deathmatch, int, 1, "Enables free-for-all deathmatch between imprisoned players of the same team (only when the jail doors are closed)");
AUTOCVAR(g_jailbreak_prisoner_health, int, 100, "Amount of health imprisoned players get");
AUTOCVAR(g_jailbreak_prisoner_armor, int, 0, "Amount of armor imprisoned players get");

float foreachtarget_callid;
.float targethandled;
void SUB_ForEachTarget(entity s, void(entity, float, vector, string, entity) cback, float recursive, float fdata, vector vdata, string sdata, entity edata)
{
    float i;
    string targname = "";
    entity targ;

    for(i = 0; i < 4; ++i)
    {
        switch(i)
        {
            case 0: targname = s.target ; break;
            case 1: targname = s.target2; break;
            case 2: targname = s.target3; break;
            case 3: targname = s.target4; break;
        }

        if(targname != "")
        {
            for(targ = NULL; (targ = find(targ, targetname, targname));)
            if(targ && targ.use && targ.targethandled != foreachtarget_callid)
            {
                cback(targ, fdata, vdata, sdata, edata);
                targ.targethandled = foreachtarget_callid;

                if(recursive)
                    SUB_ForEachTarget(targ, cback, recursive, fdata, vdata, sdata, edata);
            }
        }
    }
}

void SUB_ForEachTarget_Init() { ++foreachtarget_callid; }

// round handling
void JB_count_alive_players()
{
	total_players = redalive = bluealive = yellowalive = pinkalive = 0;
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		switch(it.team)
		{
			case NUM_TEAM_1: ++total_players; if(!STAT(JB_ISPRISONED, it)) ++redalive; break;
			case NUM_TEAM_2: ++total_players; if(!STAT(JB_ISPRISONED, it)) ++bluealive; break;
			case NUM_TEAM_3: ++total_players; if(!STAT(JB_ISPRISONED, it)) ++yellowalive; break;
			case NUM_TEAM_4: ++total_players; if(!STAT(JB_ISPRISONED, it)) ++pinkalive; break;
		}
	});
	FOREACH_CLIENT(IS_REAL_CLIENT(it),
	{
		it.redalive_stat = redalive;
		it.bluealive_stat = bluealive;
		it.yellowalive_stat = yellowalive;
		it.pinkalive_stat = pinkalive;
	});
}

int JB_GetWinnerTeam()
{
	int winner_team = 0;
	if(redalive >= 1)
		winner_team = NUM_TEAM_1;
	if(bluealive >= 1)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_2;
	}
	if(yellowalive >= 1)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_3;
	}
	if(pinkalive >= 1)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_4;
	}
	if(winner_team)
		return winner_team;
	return -1; // no player left
}

bool JB_JailIsOpen(int theteam);
void JB_ActivateCamera(int theteam);
void JB_TorturePrisonersLater(int theteam, float thedelay);

#define JB_ALIVE_TEAMS() ((redalive > 0) + (bluealive > 0) + (yellowalive > 0) + (pinkalive > 0))
#define JB_ALIVE_TEAMS_OK() (JB_ALIVE_TEAMS() == NumTeams(jb_teams))
bool JB_CheckWinner()
{
	if(round_handler_GetEndTime() > 0 && round_handler_GetEndTime() - time <= 0)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_OVER);
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_ROUND_OVER);
		allowed_to_spawn = false;
		round_handler_Init(5, autocvar_g_jailbreak_warmup, autocvar_g_jailbreak_round_timelimit);

		FOREACH_CLIENT(IS_PLAYER(it),
		{
			if(!STAT(JB_ISPRISONED, it))
			{
				it.player_blocked = 1;
				PutClientInServer(it);
			}

			nades_Clear(it);
		});
		jb_roundover = true;
		return 1;
	}

	JB_count_alive_players();
	if(JB_ALIVE_TEAMS() > 1)
		return 0;

	int winner_team = JB_GetWinnerTeam();

	if(JB_JailIsOpen(winner_team))
		return 0; // ???

	if(winner_team > 0)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, APP_TEAM_NUM(winner_team, CENTER_ROUND_TEAM_WIN));
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, APP_TEAM_NUM(winner_team, INFO_ROUND_TEAM_WIN));
		TeamScore_AddToTeam(winner_team, ST_JB_ROUNDS, +1);

		JB_ActivateCamera(winner_team);
		JB_TorturePrisonersLater(winner_team, 3);
	}
	else if(winner_team == -1)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_TIED);
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_ROUND_TIED);
	}

	jb_roundover = true;

	allowed_to_spawn = false;
	round_handler_Init(JB_TORTURE_DURATION, autocvar_g_jailbreak_warmup, autocvar_g_jailbreak_round_timelimit);

	FOREACH_CLIENT(IS_PLAYER(it),
	{
		if(!STAT(JB_ISPRISONED, it))
		{
			it.player_blocked = 1;
			PutClientInServer(it);
		}

		nades_Clear(it);
	});

	return 1;
}

void JB_RoundStart()
{
	if(warmup_stage)
		allowed_to_spawn = true;
	else
		allowed_to_spawn = false;
}

bool JB_CheckTeams()
{
	static int prev_missing_teams_mask;
	allowed_to_spawn = true;
	JB_count_alive_players();
	if(JB_ALIVE_TEAMS_OK())
	{
		if(prev_missing_teams_mask > 0)
			Kill_Notification(NOTIF_ALL, NULL, MSG_CENTER, CPID_MISSING_TEAMS);
		prev_missing_teams_mask = -1;
		return true;
	}
	if(total_players == 0)
	{
		if(prev_missing_teams_mask > 0)
			Kill_Notification(NOTIF_ALL, NULL, MSG_CENTER, CPID_MISSING_TEAMS);
		prev_missing_teams_mask = -1;
		return false;
	}
	int missing_teams_mask = 0;
	if(jb_teams & BIT(0))
		missing_teams_mask += (!redalive) * 1;
	if(jb_teams & BIT(1))
		missing_teams_mask += (!bluealive) * 2;
	if(jb_teams & BIT(2))
		missing_teams_mask += (!yellowalive) * 4;
	if(jb_teams & BIT(3))
		missing_teams_mask += (!pinkalive) * 8;
	if(prev_missing_teams_mask != missing_teams_mask)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_MISSING_TEAMS, missing_teams_mask);
		prev_missing_teams_mask = missing_teams_mask;
	}
	return false;
}

string JB_ControlPoint_Name(entity p);
void JB_AddDoor(entity door, int theteam, vector vdata, string sdata, entity cpoint)
{
	if(door.classname != "door" && door.classname != "door_rotating")
	{
		LOG_DEBUGF("Warning: %s^7 at %v is linked with an entity of unhandled class (%s^7)\n", JB_ControlPoint_Name(cpoint), cpoint.origin, door.classname);
		return;
	}

	door.jb_worlddoornext = jb_worlddoorlist; // link door into jb_worlddoorlist
	jb_worlddoorlist = door;
}

int jb_doors_opened[2];
void door_init_startopen(entity this); // TODO
void door_rotating_init_startopen(entity this); // TODO
void JB_MaybeOpenDoor(entity door, int openjails, vector vdata, string sdata, entity cpoint)
{
	if(openjails == OPENJAILS_LOCKED && door.jaildoormode != JAILDOORMODE_OPEN)
		return;

	if(openjails == OPENJAILS_OPEN && door.jaildoormode == JAILDOORMODE_CLOSED)
		return;

	// OPENJAILS_LOCKED_FORCE is handled in JB_NonJBInit
	// For OPENJAILS_OPEN_FORCE, the below is always executed

	bool opened = true;

	switch(door.classname)
	{
		case "door":
			door_init_startopen(door);
			break;

		case "door_rotating":
			door_rotating_init_startopen(door);
			InitMovingBrushTrigger(door);
			break;

		default:
			LOG_DEBUGF("Warning: %s^7 at %v is linked with an entity of unhandled class (%s^7)\n", JB_ControlPoint_Name(cpoint), cpoint.origin, door.classname);
			opened = false;
			break;
	}

	if(opened)
	{
		int idx = Team_TeamToNumber(cpoint.team);
		jb_doors_opened[idx] = jb_doors_opened[idx] + 1;
	}
}

// This is called for non-jailbreak modes only, to alter jb-specific entities on the map
void JB_NonJBInit(entity this)
{
	entity tmp_entity;
	int openjails = autocvar_g_jailbreak_nonjb_openjails;

	SUB_ForEachTarget_Init();
	for(tmp_entity = jb_worldcplist; tmp_entity; tmp_entity = tmp_entity.jb_worldcpnext)
	{
		if(tmp_entity.team)
		{
			if(openjails != OPENJAILS_LOCKED_FORCE)
				SUB_ForEachTarget(tmp_entity, JB_MaybeOpenDoor, true, openjails, '0 0 0', string_null, tmp_entity);
			setthink(tmp_entity, SUB_Remove);
			tmp_entity.nextthink = time;
		}
	}

	// If all jail doors are locked, it means that the jail is not intended to be accessible.
	// We have to keep the jail sectors then to ensure it's not possible to get in with translocator (or something more evil to be added in the future).
	// Otherwise, they have to be removed. TODO: do something about maps with multiple jails (if we ever get any).
	entity e; // TODO
	for(e = findchain(classname, "jailbreak_jail"); e; e = e.chain)
	{
		int idx = Team_TeamToNumber(e.team);
		if(!autocvar_g_nades || jb_doors_opened[idx])
		{
			setthink(e, SUB_Remove);
			e.nextthink = time;
		}
	}
}

//
//	Gametype logic
//

bool JB_JailIsOpen(int theteam)
{
	entity tmp_entity;
	for(tmp_entity = jb_worlddoorlist; tmp_entity; tmp_entity = tmp_entity.jb_worlddoornext)
	{
		if(tmp_entity.team == theteam)
		if(tmp_entity.state != STATE_BOTTOM)
			return true;
	}
	return false;
}

entity jb_ChooseJailSpawn(entity player, entity attacker);
void JB_TeleportToJail(entity p, entity attacker)
{
	vector a;
	entity spot = jb_ChooseJailSpawn(p, attacker);

	int tries = 3;

	while(!spot && tries > 0)
	{
		spot = jb_ChooseJailSpawn(p, attacker);
		tries--;
	}

	if(!spot)
	{
		LOG_DEBUG("Failed to pick a jail spawnpoint for ", p.netname, "^7, cannot imprison!\n");
		return;
	}

	a = spot.angles;
	a_z = 0;
	TeleportPlayer(spot, p, spot.origin, p.mangle, a, '0 0 0', '0 0 0', TELEPORT_FLAGS_TELEPORTER);
}

void JB_Imprison(entity targ, entity attacker)
{
	if(STAT(JB_ISPRISONED, targ))
	{
		LOG_DEBUG("Imprisoning prisoned player (", targ.netname, "^7)\n");
		//return;
	}

	targ.health = autocvar_g_jailbreak_prisoner_health;
	targ.armorvalue = autocvar_g_jailbreak_prisoner_armor;

	targ.jb_had_unlimited_ammo = (targ.items & IT_UNLIMITED_WEAPON_AMMO);

	if(!targ.jb_had_unlimited_ammo)
		targ.items |= IT_UNLIMITED_WEAPON_AMMO;

	targ.weapon_blocked = true;

	nades_Clear(targ);

	LOG_DEBUGF("Imprisoning %s^7, attacker: %e with netname: %s\n", targ.netname, attacker, attacker.netname);
	JB_TeleportToJail(targ, attacker);

	STAT(JB_ISPRISONED, targ) = true;
	targ.jb_prisontime = time;

	Send_Notification(NOTIF_ONE, targ, MSG_CENTER, CENTER_JAILBREAK_IMPRISON);
}

void JB_TorturePrisoners(int theteam);
void JB_TorturePrisonersLater_Think(entity this)
{
	JB_TorturePrisoners(this.team);
	delete(this);
}

void JB_TorturePrisonersLater(int theteam, float thedelay)
{
	entity e = spawn();
	e.team = theteam;
	setthink(e, JB_TorturePrisonersLater_Think);
	e.nextthink = time + thedelay;
}

void JB_Release(entity player, entity saviour)
{
	if(!STAT(JB_ISPRISONED, player))
	{
		LOG_DEBUG("Tried to release a free player (", player.netname, "^7)\n");
		return;
	}

	STAT(JB_ISPRISONED, player) = false;
	player.jb_imprisoner = NULL;
	player.weapon_blocked = false;
	player.player_blocked = false; // just incase

	if(!player.jb_had_unlimited_ammo)
		player.items &= ~IT_UNLIMITED_WEAPON_AMMO;

	if(g_jailbreak_jail_deathmatch)
	{
		player.health = max(player.health, autocvar_g_jailbreak_prisoner_health);
		player.armorvalue = max(player.armorvalue, autocvar_g_jailbreak_prisoner_armor);
	}
}

//
//	Torture logic
//

#define JITTER(v,j) (v) + (j) * 2 * (random() - 0.5)

void JB_Torture_Start(entity spot);
void JB_TorturePrisoners(int theteam)
{
	entity spot = NULL;

	for(;(spot = find(spot, classname, "info_jailbreak_torturespawn"));)
		if(spot.team == theteam)
			JB_Torture_Start(spot);
}

void JB_Torture_Think(entity this)
{
	if(gameover)
	{
		delete(this);
		return;
	}

	makevectors(this.angles);
	//this.nextthink = time + JITTER(this.jb_torture_delay, this.jb_torture_delay_jitter);

	float j = this.jb_torture_delay - JITTER(this.jb_torture_delay, this.jb_torture_delay_jitter);

	if(j > 0)
		j = 0.5 * j;

	this.nextthink = time + max(0.1, this.jb_torture_delay + j);
	this.jb_torture_suggestedforce = JITTER(this.jb_torture_force, this.jb_torture_force_jitter);

	Send_Effect(EFFECT_FIREFIELD, this.origin, '0 0 0', 2);

	FOREACH_CLIENT(IS_PLAYER(it) && DIFF_TEAM(it, this) && STAT(JB_ISPRISONED, it),
	{
		if(!Fire_IsBurning(it))
			Fire_AddDamage(it, NULL, 100, 6, DEATH_FIRE.m_id);
	});
}

void JB_Torture_Start(entity spot)
{
	entity e = new(jailbreak_torture);
	e.reset = SUB_Remove;
	e.reset2 = e.reset;
	setthink(e, JB_Torture_Think);
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

entity jb_ChooseJailSpawn(entity player, entity attacker)
{
	RandomSelection_Init();

	FOREACH_ENTITY_CLASS("info_jailbreak_jailspawn", true,
	{
		if(attacker && DIFF_TEAM(player, attacker)) // don't throw teammates in own jail?
		{
			if(SAME_TEAM(it, attacker))
				RandomSelection_Add(it, 0, string_null, 1, 1);
		}
		else
		{
			if(DIFF_TEAM(it, player))
				RandomSelection_Add(it, 0, string_null, 1, 1);
		}
	});

	if(!RandomSelection_chosen_ent)
		LOG_DEBUG("Unable to find an enemy jail spawnpoint, player team: ", ftos(player.team), "\n");

	return RandomSelection_chosen_ent;
}

int JB_TotalPlayersOnTeam(int theteam)
{
	int plcount = 0;

	FOREACH_CLIENT(IS_PLAYER(it) && it.team == theteam,
	{
		++plcount;
	});

	return plcount;
}

int JB_AlivePlayersOnTeam(int theteam)
{
	int plcount = 0;

	FOREACH_CLIENT(IS_PLAYER(it) && it.team == theteam,
	{
		if(!STAT(JB_ISPRISONED, it))
			++plcount;
	});

	return plcount;
}

entity JB_FindCamera(int theteam)
{
	RandomSelection_Init();

	FOREACH_ENTITY_CLASS("info_jailbreak_jailcamera", it.team == theteam,
	{
		RandomSelection_Add(it, 0, string_null, 1, 1);
	});

	return RandomSelection_chosen_ent;
}

void JB_ActivateCamera(int theteam)
{
	entity cam = JB_FindCamera(theteam);

	if(!cam)
	{
		LOG_DEBUG("Team ", itos(theteam), " has no camera entities, fail!\n");
		return;
	}

	FOREACH_CLIENT(IS_REAL_CLIENT(it),
	{
		STAT(ROUNDLOST, it) = true;

		if(IS_PLAYER(it) && !STAT(JB_ISPRISONED, it))
		{
			it.clientcamera = cam;
			msg_entity = it;
			WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
			WriteAngle(MSG_ONE, cam.angles_x);
			WriteAngle(MSG_ONE, cam.angles_y);
			WriteAngle(MSG_ONE, cam.angles_z);
		}
	});

	cam.active = true;

	FOREACH_ENTITY_CLASS("info_jailbreak_jailcamera", it != cam,
	{
		it.active = false;
	});
}

//
//	Setup functions
//

void JB_SetupJailSpawnpoint(entity this)
{
	if(!g_jailbreak) { delete(this); return; }

	this.classname = "info_jailbreak_jailspawn";
}

void JB_Jail_Touch(entity this, entity toucher)
{
	if(autocvar_g_nades)
	if(toucher.classname == "nade")
	{
		entity own = toucher.realowner;
		delete(toucher);
		nades_Clear(own);
		return;
	}

	if(toucher.classname == "grapplinghook")
	{
		RemoveGrapplingHook(toucher.realowner);
		return;
	}

	if(!g_jailbreak)
		return;

	if(!IS_PLAYER(toucher))
		return;

	if(!STAT(JB_ISPRISONED, toucher))
	{
		vector mymid = (this.absmin + this.absmax) * 0.5;
		vector theirmid = (toucher.absmin + toucher.absmax) * 0.5;

		Damage(toucher, this, this, 0, DEATH_HURTTRIGGER.m_id, mymid, normalize(theirmid - mymid) * min(500, vlen(toucher.velocity)));
		Send_Notification(NOTIF_ONE, toucher, MSG_CENTER, CENTER_JAILBREAK_NOENTRY);
		return;
	}

	STAT(JB_ISPRISONED, toucher) = 2;

	if(SAME_TEAM(toucher, this))
		return;

	toucher.jb_jail_resettime = time + frametime * 5;
}

void JB_SetupJail(entity this)
{
	this.classname = "jailbreak_jail";
	settouch(this, JB_Jail_Touch);
	EXACTTRIGGER_INIT;
}

bool jailcamera_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_JAILCAMERA);

	WriteCoord(MSG_ENTITY, this.origin_x);
	WriteCoord(MSG_ENTITY, this.origin_y);
	WriteCoord(MSG_ENTITY, this.origin_z);

	WriteAngle(MSG_ENTITY, this.angles_x);
	WriteAngle(MSG_ENTITY, this.angles_y);
	WriteAngle(MSG_ENTITY, this.angles_z);

	return true;
}

void JB_SetupJailCamera(entity this)
{
	if(!g_jailbreak) { delete(this); return; }

	this.classname = "info_jailbreak_jailcamera";

	Net_LinkEntity(this, false, 0, jailcamera_send);
}

void JB_SetupTortureSpawnpoint(entity this)
{
	if(!g_jailbreak) { delete(this); return; }

	this.classname = "info_jailbreak_torturespawn";

	if(!this.jb_torture_force)
		this.jb_torture_force = 400;

	if(!this.jb_torture_force_jitter)
		this.jb_torture_force_jitter = this.jb_torture_force * 0.1;

	if(!this.jb_torture_delay)
		this.jb_torture_delay = 2;

	if(!this.jb_torture_delay_jitter)
		this.jb_torture_delay_jitter = this.jb_torture_delay * 0.5;
}

entity JB_ControlPoint_ModelForTeam(int t)
{
	switch(t)
	{
		case NUM_TEAM_1:		return MDL_DOM_RED;
		case NUM_TEAM_2:		return MDL_DOM_BLUE;
		case NUM_TEAM_3:		return MDL_DOM_YELLOW;
		case NUM_TEAM_4:		return MDL_DOM_PINK;
		default:				return MDL_DOM_NEUTRAL;
	}
}

float JB_ControlPoint_Cooldown(entity e)
{
	float base, pw, f, c;

	c = e.jb_capturecount;

	if(e.team == 0)
	{
		base = autocvar_g_jailbreak_controlpoint_idletime_neutral;
		pw	 = autocvar_g_jailbreak_controlpoint_idletime_neutral_power;
		f	 = autocvar_g_jailbreak_controlpoint_idletime_neutral_factor;
	}
	else
	{
		base = autocvar_g_jailbreak_controlpoint_idletime;
		pw	 = autocvar_g_jailbreak_controlpoint_idletime_power;
		f	 = autocvar_g_jailbreak_controlpoint_idletime_factor;
	}

	return base + pow(c, pw) * f * base;
}

float JB_ControlPoint_InitialCooldown(entity e)
{
	return ((e.team == 0)
		?
		autocvar_g_jailbreak_controlpoint_idletime_neutral_initial
		: 
		autocvar_g_jailbreak_controlpoint_idletime_initial);
}

void JB_ControlPoint_Activate(entity e)
{
	e.jb_active = true;
	e.jb_cooldown = 0;
	//e.jb_cooldown_max = 0;
	setmodel(e, JB_ControlPoint_ModelForTeam(e.team));
	setsize(e, JB_CP_MIN, JB_CP_MAX);
	WaypointSprite_UpdateMaxHealth(e.jb_waypoint, 0);
	WaypointSprite_UpdateHealth(e.jb_waypoint, 0);
}

void JB_ControlPoint_Deactivate(entity e, float cooldown)
{
	e.jb_cooldown_max = max(e.jb_cooldown_max, cooldown);
	e.jb_cooldown	  = max(e.jb_cooldown,	   cooldown);

	LOG_DEBUGF("%e: %ds cooldown, team: %d, caps: %d\n", e, e.jb_cooldown, e.team, e.jb_capturecount);

	if(e.jb_active && e.jb_cooldown > 0)
	{
		setmodel(e, MDL_DOM_NEUTRAL);
		setsize(e, JB_CP_MIN, JB_CP_MAX);
		e.jb_active = false;
	}
}

void JB_ControlPoint_UpdateCooldownProgress(entity e)
{
	WaypointSprite_UpdateMaxHealth(e.jb_waypoint, e.jb_cooldown_max);
	WaypointSprite_UpdateHealth(e.jb_waypoint, e.jb_cooldown_max - e.jb_cooldown);
}

void JB_ControlPoint_Think(entity this)
{
	this.nextthink = time;
	AnimateDomPoint(this);

	if(time < game_starttime || jb_roundover)
		return;

	if(this.jb_cooldown) { JB_ControlPoint_UpdateCooldownProgress(this); }
	else if(!this.jb_active) { JB_ControlPoint_Activate(this); }

	if(time - this.pointupdatetime >= 0.1)
	{
		STAT(CAPTURE_PROGRESS, this) = 0;
		this.jb_capturingplayer = NULL;
	}

	this.jb_cooldown = max(0, this.jb_cooldown - frametime);
}

void JB_ControlPoint_SwitchTeam(entity e, int t)
{
	e.team = t;
	//WaypointSprite_UpdateSprites(e.jb_waypoint, e.jb_waypoint.model1, "", e.jb_waypoint.model3);
	WaypointSprite_UpdateTeamRadar(e.jb_waypoint, RADARICON_FLAG, (e.team) ? colormapPaletteColor(e.team - 1, false) : '0 1 1');
	//WaypointSprite_UpdateTextColors(e.jb_waypoint, TeamColor(e.team), e.jb_waypoint.clr2, e.jb_waypoint.clr3);
}

void JB_TriggerTeamControlPoints(entity cp, entity player)
{
	for(entity ent = jb_worldcplist; ent; ent = ent.jb_worldcpnext)
	{
		if(cp.team)
		{
			if(SAME_TEAM(ent, cp))
				SUB_UseTargets_PreventReuse(ent, cp, player);
		}
		else
		{
			if(ent.jb_team_initial != player.team)
				SUB_UseTargets_PreventReuse(ent, cp, player);
		}
	}
}

string JB_ControlPoint_Name(entity p)
{
	string clr, tm, end;

	clr = Team_ColorCode(p.team);
	tm = Team_ColorName(p.team);

	end = strcat(" (Point ", chr2str(str2chr("A", 0) + p.cnt), ")");

	if(!p.netname)
		return strcat(clr, tm, " Control Point", end);
	return strcat(clr, strdecolorize(p.netname), end);
}

void JB_ControlPoint_Capture(entity this, entity player)
{
	int pc = 0;

	if(!this.team || g_jailbreak_claim)
		JB_TriggerTeamControlPoints(this, player);
	else SUB_UseTargets(this, this, player);

	FOREACH_CLIENT(IS_PLAYER(it),
	{
		if(DIFF_TEAM(it, player))
			Send_Notification(NOTIF_ONE, it, MSG_CENTER, APP_TEAM_ENT(player, CENTER_JAILBREAK_ESCAPE));
		else if(it == player)
			Send_Notification(NOTIF_ONE, it, MSG_CENTER, CENTER_JAILBREAK_FREED);

		if(STAT(JB_ISPRISONED, it) && SAME_TEAM(it, player))
		{
			Send_Notification(NOTIF_ONE, it, MSG_CENTER, CENTER_JAILBREAK_FREE);
			pc++;
		}
	});

	Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_JAILBREAK_CAPTURE, player.netname, JB_ControlPoint_Name(this));

	for(entity e = jb_worldcplist; e; e = e.jb_worldcpnext)
	{
		e.jb_lastmessage = time + 3;
	}

	PlayerScore_Add(player, SP_SCORE, ((this.team == 0)? autocvar_g_jailbreak_score_jbreak_neutralmultiplier : 1)
									* (autocvar_g_jailbreak_score_jbreak + autocvar_g_jailbreak_score_jbreak_perplayer * pc));
	PlayerScore_Add(player, SP_JB_JBREAKS, 1);
	PlayerScore_Add(player, SP_JB_FREED, pc);
	nades_GiveBonus(player, autocvar_g_nades_bonus_score_medium);
	play2all(SND(KH_ALARM));

	if(autocvar_g_jailbreak_controlpoint_claim_noneutral)
	if(this.team == 0)
		return;

	JB_ControlPoint_SwitchTeam(this, player.team);
}

void JB_ControlPoint_Touch(entity this, entity toucher)
{
	if(jb_roundover)
		return;

	if(toucher.health < 1 || STAT(FROZEN, toucher))
		return;

	if(gameover)
		return;

	if(!IS_PLAYER(toucher))
		return;

	toucher.pointupdatetime = time;

	if(SAME_TEAM(toucher, this))
	{
		if(time >= this.jb_lastmessage)
		{
			Send_Notification(NOTIF_ONE, toucher, MSG_CENTER, CENTER_JAILBREAK_WRONGTEAM);
			this.jb_lastmessage = time + 1.5;
		}
		return;
	}

	if(!this.jb_active)
	{
		if(time >= this.jb_lastmessage)
		{
			Send_Notification(NOTIF_ONE, toucher, MSG_CENTER, CENTER_JAILBREAK_NOTREADY);
			this.jb_lastmessage = time + 1.5;
		}
		return;
	}

	if(this.jb_capturingplayer && this.jb_capturingplayer != toucher)
	{
		if(time >= this.jb_lastmessage)
		{
			Send_Notification(NOTIF_ONE, toucher, MSG_CENTER, CENTER_JAILBREAK_TOOLATE);
			this.jb_lastmessage = time + 1.5;
		}
		return;
	}

	if(JB_TotalPlayersOnTeam(toucher.team) == JB_AlivePlayersOnTeam(toucher.team))
	{
		if(time >= this.jb_lastmessage)
		{
			Send_Notification(NOTIF_ONE, toucher, MSG_CENTER, CENTER_JAILBREAK_TEAMALIVE);
			this.jb_lastmessage = time + 1.5;
		}
		return;
	}

	entity tmp_entity;
	bool capping_neutral = false;
	if(this.team)
	for(tmp_entity = jb_worldcplist; tmp_entity; tmp_entity = tmp_entity.jb_worldcpnext)
	{
		if(!tmp_entity.team)
		if(STAT(CAPTURE_PROGRESS, tmp_entity))
		if(SAME_TEAM(tmp_entity.jb_capturingplayer, toucher))
		{
			capping_neutral = true;
			break;
		}
	}

	if(!capping_neutral || !this.team)
		STAT(CAPTURE_PROGRESS, this) = bound(0, STAT(CAPTURE_PROGRESS, this) + frametime * autocvar_g_jailbreak_controlpoint_unlock_speed, 1);

	this.pointupdatetime = time;
	this.jb_capturingplayer = toucher;
	STAT(CAPTURE_PROGRESS, toucher) = STAT(CAPTURE_PROGRESS, this);

	if(STAT(CAPTURE_PROGRESS, this) >= 1)
	{
		JB_ControlPoint_Capture(this, toucher);

		JB_ControlPoint_Deactivate(this, JB_ControlPoint_Cooldown(this));

		for(tmp_entity = jb_worldcplist; tmp_entity; tmp_entity = tmp_entity.jb_worldcpnext)
		{
			if(tmp_entity != this)
			if(SAME_TEAM(tmp_entity, toucher))
				JB_ControlPoint_Deactivate(tmp_entity, autocvar_g_jailbreak_controlpoint_idletime_global_own);
			else if(!tmp_entity.team || DIFF_TEAM(tmp_entity, toucher))
				JB_ControlPoint_Deactivate(tmp_entity, autocvar_g_jailbreak_controlpoint_idletime_global);
		}

		this.jb_capturecount += 1;
	}
}

void JB_ControlPoint_Reset(entity this)
{
	this.jb_capturecount = 0;
	this.jb_active = true;
	this.jb_cooldown = 0;
	this.jb_cooldown_max = 0;
	JB_ControlPoint_Deactivate(this, JB_ControlPoint_InitialCooldown(this));
	WaypointSprite_UpdateMaxHealth(this.jb_waypoint, 0);
	WaypointSprite_UpdateHealth(this.jb_waypoint, 0);
	JB_ControlPoint_SwitchTeam(this, autocvar_g_jailbreak_controlpoint_claim_allneutral ? 0 : this.jb_team_initial);
}

bool jb_ControlPoint_Waypoint_Customize(entity this, entity client)
{
	if(!this.owner.team) { return true; }

	entity e = WaypointSprite_getviewentity(client);

	// hide from owner's team
	if(SAME_TEAM(this.owner, e)) { return false; }

	return true;
}

void JB_SetupControlPoint(entity this)
{
	this.jb_worldcpnext = jb_worldcplist; // link control point into jb_worldcplist
	jb_worldcplist = this;

	if(!g_jailbreak) { return; } // removal is done in JB_NonJBInit

	this.classname = "jailbreak_controlpoint";
	this.jb_team_initial = this.team;

	if(autocvar_g_jailbreak_controlpoint_claim_allneutral)
		this.team = 0;

	setmodel(this, JB_ControlPoint_ModelForTeam(this.team));
	this.skin = 0;

	if(!this.t_width)
		this.t_width = 0.02; // frame animation rate
	if(!this.t_length)
		this.t_length = 239; // maximum frame

	setthink(this, JB_ControlPoint_Think);
	this.nextthink = time;
	settouch(this, JB_ControlPoint_Touch);
	this.solid = SOLID_TRIGGER;
	this.flags = FL_ITEM;
	IL_PUSH(g_items, this);
	this.reset = JB_ControlPoint_Reset;
	this.jb_capturecount = 0;
	this.jb_active = true;
	this.cnt = jb_cp_num;
	this.scale = JB_CP_SCALE;
	JB_ControlPoint_Deactivate(this, JB_ControlPoint_InitialCooldown(this));
	setsize(this, JB_CP_MIN, JB_CP_MAX);
	setorigin(this, this.origin + '0 0 20');
	droptofloor(this);

	waypoint_spawnforitem_force(this, this.origin);
	this.nearestwaypointtimeout = 0; // activate waypointing again
	WaypointSprite_SpawnFixed(WP_JB_ControlPoint, this.origin + JB_CP_WPOFFSET, this, jb_waypoint, RADARICON_DOMPOINT);
	this.jb_waypoint.wp_extra = jb_cp_num;
	setcefc(this.jb_waypoint, jb_ControlPoint_Waypoint_Customize);
	WaypointSprite_UpdateTeamRadar(this.jb_waypoint, RADARICON_FLAG, (this.team) ? colormapPaletteColor(this.team - 1, false) : '0 1 1');
	//WaypointSprite_UpdateTextColors(this.jb_waypoint, TeamColor(this.team), '1 0.5 0', '0 0 0');
	//WaypointSprite_UpdateSprites(this.jb_waypoint, this.jb_waypoint.model1, this.jb_waypoint.model2, "");

	++jb_cp_num;
}

// mutator hooks
MUTATOR_HOOKFUNCTION(jb, OnEntityPreSpawn)
{
	entity ent = M_ARGV(0, entity);

	switch(ent.classname)
	{
		case "item_flag_team1":
		case "item_flag_team2":
		case "item_flag_team3":
		case "item_flag_team4":
			return true;
	}
}

MUTATOR_HOOKFUNCTION(jb, reset_map_players)
{
	jb_roundover = false;

	FOREACH_ENTITY_CLASS("info_jailbreak_jailcamera", true,
	{
		it.active = false;
	});

	FOREACH_CLIENT(true,
	{
		if(IS_PLAYER(it))
		{
			JB_Release(it, NULL);
			PutClientInServer(it);
		}

		it.player_blocked = 0;
		it.weapon_blocked = false;
		STAT(ROUNDLOST, it) = false;
		it.clientcamera = it;
	});

	return true;
}

MUTATOR_HOOKFUNCTION(jb, PlayerDies)
{
	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);
	float frag_deathtype = M_ARGV(3, float);

	if(jb_roundover && frag_deathtype == DEATH_FIRE.m_id)
		PlayerScore_Add(frag_target, SP_KILLS, +1); // dying negates 1, so we bring it back up

	if(!round_handler_IsRoundStarted() || jb_roundover)
		return;

	if(!STAT(JB_ISPRISONED, frag_target))
	{
		if(frag_attacker == frag_target || !frag_attacker)
			PlayerScore_Add(frag_target, SP_SCORE, -autocvar_g_jailbreak_penalty_death);
		else if(IS_PLAYER(frag_attacker))
		{
			if(DIFF_TEAM(frag_attacker, frag_target))
			{
				PlayerScore_Add(frag_target, SP_SCORE, -autocvar_g_jailbreak_penalty_death);
				PlayerScore_Add(frag_attacker, SP_SCORE, autocvar_g_jailbreak_score_imprison);

				float rng = autocvar_g_jailbreak_defense_range;
				entity cp;
				if(rng)
				for(cp = jb_worldcplist; cp; cp = cp.jb_worldcpnext)
				{
					if(SAME_TEAM(cp, frag_attacker) || (cp.team == 0 && cp.jb_active))
					{
						// Rewards control point defense if fragging nearby your team's or neutral cp.
						// In case of neutral cp, it has to be active (no defense farming in the beginning of the round)
						if(vdist(cp.origin - frag_target.origin, <, rng))
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
		LOG_DEBUG("Prisoned player ", frag_target.netname, "^7 just died, should this really happen?\n");
		PutClientInServer(frag_target);
	}
}

MUTATOR_HOOKFUNCTION(jb, PlayerSpawn, CBC_ORDER_LAST)
{
	entity player = M_ARGV(0, entity);

	if(!round_handler_IsRoundStarted()) { STAT(JB_ISPRISONED, player) = false; return; }

	if(player.jb_imprisoner != NULL)
	{
		JB_Imprison(player, player.jb_imprisoner);
		player.jb_imprisoner = NULL;
	}

	if(JB_TotalPlayersOnTeam(player.team) - 1 > 0) // allow to spawn non-prisoned if there are no players on that team
		JB_Imprison(player, NULL);
}

MUTATOR_HOOKFUNCTION(jb, SpectateCopy)
{
	entity spectatee = M_ARGV(0, entity);
	entity client = M_ARGV(1, entity);

	STAT(JB_ISPRISONED, client) = STAT(JB_ISPRISONED, spectatee);
	STAT(CAPTURE_PROGRESS, client) = STAT(CAPTURE_PROGRESS, spectatee);
}

MUTATOR_HOOKFUNCTION(jb, MakePlayerObserver)
{
	entity player = M_ARGV(0, entity);

	if(STAT(JB_ISPRISONED, player))
		JB_Release(player, NULL);

	STAT(ROUNDLOST, player) = false;
}

MUTATOR_HOOKFUNCTION(jb, ClientDisconnect)
{
	entity player = M_ARGV(0, entity);

	if(STAT(JB_ISPRISONED, player))
		JB_Release(player, NULL);

	STAT(ROUNDLOST, player) = false;
}

MUTATOR_HOOKFUNCTION(jb, PlayerPreThink)
{
	entity player = M_ARGV(0, entity);

	if(gameover)
	{
		STAT(JB_ISPRISONED, player) = false;
		return;
	}

	if(!round_handler_IsRoundStarted())
	{
		player.jb_isprisoned_prev = 0;
		STAT(CAPTURE_PROGRESS, player) = 0;
		return;
	}

	int ps = min(1, STAT(JB_ISPRISONED, player));
	if(ps != player.jb_isprisoned_prev)
	{
		if(!ps)
			Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_JAILBREAK_FREE, player.netname);
		player.jb_isprisoned_prev = ps;
	}

	if(time - player.pointupdatetime >= 0.01)
		STAT(CAPTURE_PROGRESS, player) = 0;

	if(time - player.jb_prisontime < 0.5)
		return;

	if(STAT(JB_ISPRISONED, player) == 1)
	{
		LOG_DEBUG("Warning: ", player.netname, "^7managed to leave the jail without touching the jail sector! Attempting to put them back in\n");
		JB_TeleportToJail(player, NULL);
	}
	else if(STAT(JB_ISPRISONED, player))
	if(time > player.jb_jail_resettime)
		JB_Release(player, NULL);
}

MUTATOR_HOOKFUNCTION(jb, PlayerDamage_Calculate)
{
	entity frag_target = M_ARGV(2, entity);
	float frag_deathtype = M_ARGV(3, float);

	if(STAT(JB_ISPRISONED, frag_target) && frag_deathtype != DEATH_FIRE.m_id)
		M_ARGV(4, float) = 0; // damage

	entity tmp_entity;
	if(STAT(CAPTURE_PROGRESS, frag_target))
	for(tmp_entity = jb_worldcplist; tmp_entity; tmp_entity = tmp_entity.jb_worldcpnext)
	{
		if(tmp_entity.jb_capturingplayer == frag_target)
			STAT(CAPTURE_PROGRESS, tmp_entity) = bound(0, STAT(CAPTURE_PROGRESS, tmp_entity) - autocvar_g_jailbreak_controlpoint_unlock_damage_pushback, 1);
	}
}

MUTATOR_HOOKFUNCTION(jb, ForbidThrowCurrentWeapon)
{
	entity player = M_ARGV(0, entity);

	if(STAT(JB_ISPRISONED, player))
		return true;
}

MUTATOR_HOOKFUNCTION(jb, GiveFragsForKill)
{
	if(jb_roundover)
	{
		M_ARGV(2, float) = 0;
		return true;
	}
}

MUTATOR_HOOKFUNCTION(jb, GetTeamCount)
{
	M_ARGV(0, float) = jb_teams;
}

MUTATOR_HOOKFUNCTION(jb, AllowMobSpawning)
{
	entity caller = M_ARGV(0, entity);

	if(STAT(JB_ISPRISONED, caller))
	{
		M_ARGV(1, string) = "You can't spawn monsters in prison!";
		return true;
	}
}

MUTATOR_HOOKFUNCTION(jb, ForbidWeaponUse)
{
	entity player = M_ARGV(0, entity);

	if (STAT(JB_ISPRISONED, player))
		return true;
}

MUTATOR_HOOKFUNCTION(jb, MonsterValidTarget)
{
	entity player = M_ARGV(1, entity);

	if (STAT(JB_ISPRISONED, player))
		return true;
}

MUTATOR_HOOKFUNCTION(jb, TurretValidateTarget)
{
	entity turret_target = M_ARGV(1, entity);

	if(STAT(JB_ISPRISONED, turret_target))
	{
		M_ARGV(3, float) = -6;
		return true;
	}

	return false;
}

// spawn functions
#define JB_SPAWNFUNC(e,s,t) spawnfunc(e) { this.team = t; s(this); }

JB_SPAWNFUNC(info_jailbreak_jailspawn_red, JB_SetupJailSpawnpoint, NUM_TEAM_1)
JB_SPAWNFUNC(info_jailbreak_jailspawn_blue, JB_SetupJailSpawnpoint, NUM_TEAM_2)
JB_SPAWNFUNC(info_jailbreak_jailspawn_yellow, JB_SetupJailSpawnpoint, NUM_TEAM_3)
JB_SPAWNFUNC(info_jailbreak_jailspawn_pink, JB_SetupJailSpawnpoint, NUM_TEAM_4)

JB_SPAWNFUNC(func_jailbreak_jail_red, JB_SetupJail, NUM_TEAM_1)
JB_SPAWNFUNC(func_jailbreak_jail_blue, JB_SetupJail, NUM_TEAM_2)
JB_SPAWNFUNC(func_jailbreak_jail_yellow, JB_SetupJail, NUM_TEAM_3)
JB_SPAWNFUNC(func_jailbreak_jail_pink, JB_SetupJail, NUM_TEAM_4)

JB_SPAWNFUNC(info_jailbreak_jailcamera_red, JB_SetupJailCamera, NUM_TEAM_1)
JB_SPAWNFUNC(info_jailbreak_jailcamera_blue, JB_SetupJailCamera, NUM_TEAM_2)
JB_SPAWNFUNC(info_jailbreak_jailcamera_yellow, JB_SetupJailCamera, NUM_TEAM_3)
JB_SPAWNFUNC(info_jailbreak_jailcamera_pink, JB_SetupJailCamera, NUM_TEAM_4)

JB_SPAWNFUNC(info_jailbreak_torturespawn_red, JB_SetupTortureSpawnpoint, NUM_TEAM_1)
JB_SPAWNFUNC(info_jailbreak_torturespawn_blue, JB_SetupTortureSpawnpoint, NUM_TEAM_2)
JB_SPAWNFUNC(info_jailbreak_torturespawn_yellow, JB_SetupTortureSpawnpoint, NUM_TEAM_3)
JB_SPAWNFUNC(info_jailbreak_torturespawn_pink, JB_SetupTortureSpawnpoint, NUM_TEAM_4)

JB_SPAWNFUNC(jailbreak_controlpoint_red, JB_SetupControlPoint, NUM_TEAM_1)
JB_SPAWNFUNC(jailbreak_controlpoint_blue, JB_SetupControlPoint, NUM_TEAM_2)
JB_SPAWNFUNC(jailbreak_controlpoint_yellow, JB_SetupControlPoint, NUM_TEAM_3)
JB_SPAWNFUNC(jailbreak_controlpoint_pink, JB_SetupControlPoint, NUM_TEAM_4)
JB_SPAWNFUNC(jailbreak_controlpoint_neutral, JB_SetupControlPoint, 0)

// scores
void jb_ScoreRules(int teams)
{
	ScoreRules_basics(teams, SFL_SORT_PRIO_PRIMARY, 0, true); // SFL_SORT_PRIO_PRIMARY
	ScoreInfo_SetLabel_TeamScore(ST_JB_ROUNDS,			"rounds",		SFL_SORT_PRIO_PRIMARY);
	ScoreInfo_SetLabel_PlayerScore(SP_JB_JBREAKS,		"jbs",		0);
	ScoreInfo_SetLabel_PlayerScore(SP_JB_FREED,			"freed",		SFL_SORT_PRIO_SECONDARY);
	ScoreInfo_SetLabel_PlayerScore(SP_JB_DEFENSE,		"def",		0);
	ScoreRules_basics_end();
}

// initialization
void jb_DelayedInit(entity this)
{
	entity tmp_entity;

	SUB_ForEachTarget_Init();
	for(tmp_entity = jb_worldcplist; tmp_entity; tmp_entity = tmp_entity.jb_worldcpnext)
		SUB_ForEachTarget(tmp_entity, JB_AddDoor, true, tmp_entity.jb_team_initial, '0 0 0', string_null, tmp_entity);
}

void jb_Initialize()
{
	jb_teams = autocvar_g_jailbreak_teams_override;
	if (jb_teams < 2) jb_teams = autocvar_g_jailbreak_teams;
	jb_teams = bound(2, jb_teams, 4);

	int teams = 0;
	if(jb_teams >= 1) teams |= BIT(0);
	if(jb_teams >= 2) teams |= BIT(1);
	if(jb_teams >= 3) teams |= BIT(2);
	if(jb_teams >= 4) teams |= BIT(3);

	jb_teams = teams; // now set it?

	jb_ScoreRules(jb_teams);

	round_handler_Spawn(JB_CheckTeams, JB_CheckWinner, JB_RoundStart);
	round_handler_Init(5, autocvar_g_jailbreak_warmup, autocvar_g_jailbreak_round_timelimit);

	g_jailbreak_claim = autocvar_g_jailbreak_controlpoint_claim;

	g_jailbreak_jail_deathmatch = autocvar_g_jailbreak_jail_deathmatch;
	InitializeEntity(NULL, jb_DelayedInit, INITPRIO_GAMETYPE);
}

#endif

#endif
