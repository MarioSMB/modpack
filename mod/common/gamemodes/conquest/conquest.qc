#ifndef IMPLEMENTATION
#ifdef SVQC
	AUTOCVAR_NOREF(g_conquest, bool, false, "Conquest: take control points until the enemy has nowhere to spawn");
#endif
#include "conquest.qh"

#ifdef SVQC
void cq_DelayedInit(entity this);

REGISTER_MUTATOR(cq, false)
{
	MUTATOR_ONADD
	{
		if (time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");
		InitializeEntity(NULL, cq_DelayedInit, INITPRIO_GAMETYPE);

		ActivateTeamplay();
		//SetLimits(autocvar_g_tdm_point_limit, autocvar_g_tdm_point_leadlimit, autocvar_timelimit_override, -1);
		have_team_spawns = -1; // request team spawns
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		// we actually cannot roll back cq_DelayedInit here
		// BUT: we don't need to! If this gets called, adding always
		// succeeds.
	}

	MUTATOR_ONREMOVE
	{
		LOG_INFO("This is a game type and it cannot be removed at runtime.");
		return -1;
	}

	return 0;
}
#endif

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC
AUTOCVAR_NOREF(g_conquest_respawn_delay_small, float, 0, "");
AUTOCVAR_NOREF(g_conquest_respawn_delay_small_count, float, 0, "");
AUTOCVAR_NOREF(g_conquest_respawn_delay_large, float, 0, "");
AUTOCVAR_NOREF(g_conquest_respawn_delay_large_count, float, 0, "");
AUTOCVAR_NOREF(g_conquest_respawn_delay_max, float, 0, "");
AUTOCVAR_NOREF(g_conquest_respawn_waves, float, 0, "");
AUTOCVAR_NOREF(g_conquest_weapon_stay, float, 0, "");
AUTOCVAR(g_conquest_spawn_close_to_death, bool, true, "default to closest spawnpoint to death location");
AUTOCVAR(g_conquest_capture_distance_default, float, 512, "maximum distance from control point at which players can capture/liberate");
AUTOCVAR(g_conquest_capture_sps, float, 100, "capture/liberation speed");
AUTOCVAR(g_conquest_controlpoint_health_default, float, 500, "");
AUTOCVAR(g_conquest_spawn_choose, bool, true, "Allow players to choose the control point to be spawned at");
AUTOCVAR(g_conquest_teleport_radius, float, 1024, "");
AUTOCVAR(g_conquest_teleport_wait, float, 5, "Time before player can teleport again");
AUTOCVAR(g_conquest_click_radius, float, 500, "");
AUTOCVAR(g_conquest_warmup, float, 5, "");
AUTOCVAR(g_conquest_round_timelimit, float, 360, "");

bool cq_ControlPoint_Send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_CONQUEST_CONTROLPOINT);
	WriteByte(MSG_ENTITY, sf);

	if(sf & CQSF_SETUP)
	{
		WriteCoord(MSG_ENTITY, this.origin_x);
		WriteCoord(MSG_ENTITY, this.origin_y);
		WriteCoord(MSG_ENTITY, this.origin_z);

		WriteCoord(MSG_ENTITY, this.angles_y);

		WriteLong(MSG_ENTITY, this.cq_capdistance);
	}

	if(sf & CQSF_STATE)
	{
		WriteByte(MSG_ENTITY, this.cq_status);
	}

	if(sf & CQSF_TEAM)
	{
		WriteByte(MSG_ENTITY, this.team);
	}

	if(sf & CQSF_HEALTH)
	{
		WriteByte(MSG_ENTITY, ceil((this.health / this.max_health) * 255));
		WriteLong(MSG_ENTITY, autocvar_g_conquest_capture_sps);
	}

	if(sf & CQSF_NAME)
	{
		WriteString(MSG_ENTITY, this.netname);
	}


	return true;
}

void cq_ControlPoint_SwitchTeam(entity this, int newteam, int newstatus, bool showmessage)
{
	// TODO: add sounds
	// TODO: clean this up!

	if(showmessage)
	if(newstatus == CP_NEUTRAL && this.cq_status != CP_NEUTRAL)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, APP_TEAM_NUM(this.team, INFO_CONQUEST_LIBERATE), this.netname);
		Send_Notification(NOTIF_TEAM, this, MSG_CENTER, APP_TEAM_NUM(newteam, CENTER_CONQUEST_LOST), this.netname);

		FOREACH_CLIENT(IS_PLAYER(it) && IS_REAL_CLIENT(it),
		{
			if(it.team == newteam)
				Send_Notification(NOTIF_ONE, it, MSG_CENTER, APP_TEAM_NUM(this.team, CENTER_CONQUEST_LIBERATE_TEAM), this.netname);
			else if(DIFF_TEAM(it, this))
				Send_Notification(NOTIF_ONE, it, MSG_CENTER, APP_TEAM_NUM(newteam, CENTER_CONQUEST_LIBERATE), this.netname);
		});
	}

	this.team = newteam;
	this.cq_status = newstatus;

	entity act = NULL;

	switch(this.cq_status)
	{
		case CP_NEUTRAL:
		{
			this.skin = 0;
			break;
		}

		case CP_CAPTURED:
		{
			act = this;
			this.skin = Team_TeamToNumber(this.team) + 1;

			if(showmessage)
			{
				Send_Notification(NOTIF_ALL, NULL, MSG_INFO, APP_TEAM_NUM(this.team, INFO_CONQUEST_CAPTURE), this.netname);
				Send_Notification(NOTIF_TEAM, this, MSG_CENTER, CENTER_CONQUEST_CAPTURE_TEAM, this.netname);

				FOREACH_CLIENT(IS_PLAYER(it),
				{
					if(DIFF_TEAM(it, this))
						Send_Notification(NOTIF_ONE, it, MSG_CENTER, APP_TEAM_NUM(this.team, CENTER_CONQUEST_CAPTURE), this.netname);
				});
			}

			break;
		}

		default: { dprint("Control point without status?\n"); break; }
	}

	SUB_UseTargets(this, act, NULL);

	this.SendFlags |= CQSF_STATE | CQSF_TEAM;
}

void cq_ControlPoint_Think(entity this)
{
	this.nextthink = time + CQ_CP_THINKRATE;

	if(!round_handler_IsRoundStarted()) { return; }

	float old_health = this.health;

	FOREACH_CLIENT(IS_PLAYER(it),
	{
		if(!IS_DEAD(it))
		if(!it.vehicle)
		if(!STAT(FROZEN, it))
		{
			if(vdist(it.origin - this.origin, <=, this.cq_capdistance))
			{
				traceline(CENTER_OR_VIEWOFS(it), CENTER_OR_VIEWOFS(this), MOVE_WORLDONLY, it);
				if(trace_fraction == 1.0)
				{
					if(SAME_TEAM(it, this))
						this.health = min(this.max_health, this.health + autocvar_g_conquest_capture_sps * CQ_CP_THINKRATE);
					else
						this.health = max(0, this.health - autocvar_g_conquest_capture_sps * CQ_CP_THINKRATE);

					switch(this.cq_status)
					{
						case CP_CAPTURED:
						{
							if(this.health == 0)
							{
								PlayerScore_Add(it, SP_CONQUEST_LIBERATED, 1);
								Send_Effect(EFFECT_EXPLOSION_BIG, findbetterlocation(this.origin, 16), '0 0 0', 1);
								cq_ControlPoint_SwitchTeam(this, it.team, CP_NEUTRAL, true);
							}

							break;
						}

						case CP_NEUTRAL:
						{
							if(this.health == 0)
								cq_ControlPoint_SwitchTeam(this, it.team, CP_NEUTRAL, true);

							if(this.health == this.max_health)
							{
								PlayerScore_Add(it, SP_CONQUEST_CAPTURED, 1);
								cq_ControlPoint_SwitchTeam(this, it.team, CP_CAPTURED, true);
							}

							break;
						}
					}
				}
			}
		}
	});

	if(this.health != old_health)
		this.SendFlags |= CQSF_HEALTH;
}

void cq_ControlPoint_Reset(entity this)
{
	if(this.cq_originalteam)
		this.cq_status = CP_CAPTURED;
	else
	{
		this.cq_status = CP_NEUTRAL;
		this.health = 0;
	}
	this.SendFlags |= CQSF_HEALTH;
	cq_ControlPoint_SwitchTeam(this, this.cq_originalteam, this.cq_status, false);
}

spawnfunc(conquest_controlpoint)
{
	if(!g_conquest) { delete(this); return; }

	this.cq_worldcpnext = cq_worldcplist; // link control point into cq_worldcplist
	cq_worldcplist = this;

	this.model = ""; // should we support custom models?

	setsize(this, CQ_CP_MIN, CQ_CP_MAX);

	if(this.netname == "")		{ this.netname = "a spawnpoint"; }
	if(!this.health)			{ this.health = autocvar_g_conquest_controlpoint_health_default; }
	if(!this.cq_capdistance)	{ this.cq_capdistance = autocvar_g_conquest_capture_distance_default; }

	this.classname = "conquest_controlpoint";
	this.max_health = this.health;
	this.solid = SOLID_TRIGGER;
	this.nextthink = time + CQ_CP_THINKRATE;
	setthink(this, cq_ControlPoint_Think);
	this.reset = cq_ControlPoint_Reset;

	if(this.team)
		this.cq_status = CP_CAPTURED;
	else
	{
		this.cq_status = CP_NEUTRAL;
		this.health = 0;
	}

	this.cq_originalteam = this.team;

	waypoint_spawnforitem(this);
	Net_LinkEntity(this, false, 0, cq_ControlPoint_Send);
	this.SendFlags = CQSF_SETUP | CQSF_STATE | CQSF_TEAM | CQSF_HEALTH | CQSF_NAME;
	cq_ControlPoint_SwitchTeam(this, this.team, this.cq_status, false);
}

// round handler
void cq_CountAlivePlayers()
{
	total_players = redalive = bluealive = yellowalive = pinkalive = 0;

	FOREACH_CLIENT(IS_PLAYER(it),
	{
		++total_players;
		redalive += boolean(it.team == NUM_TEAM_1 && !IS_DEAD(it));
		bluealive += boolean(it.team == NUM_TEAM_2 && !IS_DEAD(it));
		yellowalive += boolean(it.team == NUM_TEAM_3 && !IS_DEAD(it));
		pinkalive += boolean(it.team == NUM_TEAM_4 && !IS_DEAD(it));
	});
}

#define CQ_ALIVE_TEAMS() ((redalive > 0) + (bluealive > 0) + (yellowalive > 0) + (pinkalive > 0))
#define CQ_ALIVE_TEAMS_OK() (CQ_ALIVE_TEAMS() == NumTeams(cq_teams))

int cq_getWinnerTeam()
{
	entity tmp_entity;
	int redcp = 0, bluecp = 0, yellowcp = 0, pinkcp = 0;
	for(tmp_entity = cq_worldcplist; tmp_entity; tmp_entity = tmp_entity.cq_worldcpnext)
	{
		if(tmp_entity.cq_status == CP_CAPTURED)
		switch(tmp_entity.team)
		{
			case NUM_TEAM_1: ++redcp; break;
			case NUM_TEAM_2: ++bluecp; break;
			case NUM_TEAM_3: ++yellowcp; break;
			case NUM_TEAM_4: ++pinkcp; break;
		}
	}

	int winner_team = 0;
	if(redcp >= 1) { winner_team = NUM_TEAM_1; }
	if(bluecp >= 1)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_2;
	}
	if(yellowcp >= 1)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_3;
	}
	if(pinkcp >= 1)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_4;
	}
	if(winner_team)
		return winner_team;
	return -1; // nobody owns anything
}

bool cq_CheckWinner()
{
	if(round_handler_GetEndTime() > 0 && round_handler_GetEndTime() - time <= 0)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_OVER);
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_ROUND_OVER);
		round_handler_Init(5, autocvar_g_conquest_warmup, autocvar_g_conquest_round_timelimit);
		return true;
	}

	cq_CountAlivePlayers();

	entity tmp_entity;
	int redcp = 0, bluecp = 0, yellowcp = 0, pinkcp = 0, neutralcp = 0;
	for(tmp_entity = cq_worldcplist; tmp_entity; tmp_entity = tmp_entity.cq_worldcpnext)
	{
		if(tmp_entity.cq_status == CP_CAPTURED)
		switch(tmp_entity.team)
		{
			case NUM_TEAM_1: ++redcp; break;
			case NUM_TEAM_2: ++bluecp; break;
			case NUM_TEAM_3: ++yellowcp; break;
			case NUM_TEAM_4: ++pinkcp; break;
		}
		else { ++neutralcp; }
	}
	if(((redcp > 0) + (bluecp > 0) + (yellowcp > 0) + (pinkcp > 0) + (neutralcp > 0)) > 1) // more than 1 team owns control points
		return false;

	int winner_team = cq_getWinnerTeam();
	if(winner_team > 0)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, APP_TEAM_NUM(winner_team, CENTER_ROUND_TEAM_WIN));
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, APP_TEAM_NUM(winner_team, INFO_ROUND_TEAM_WIN));
		TeamScore_AddToTeam(winner_team, ST_CONQUEST_ROUNDS, +1);
	}
	else if(winner_team == -1)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_TIED);
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_ROUND_TIED);
	}

	round_handler_Init(5, autocvar_g_conquest_warmup, autocvar_g_conquest_round_timelimit);
	return true;
}

bool cq_CheckTeams()
{
	static float prev_missing_teams_mask;
	allowed_to_spawn = true;
	cq_CountAlivePlayers();
	if(CQ_ALIVE_TEAMS_OK())
	{
		if(prev_missing_teams_mask > 0)
			Kill_Notification(NOTIF_ALL, NULL, MSG_CENTER, CPID_MISSING_TEAMS);
		prev_missing_teams_mask = -1;
		return 1;
	}
	if(total_players == 0)
	{
		if(prev_missing_teams_mask > 0)
			Kill_Notification(NOTIF_ALL, NULL, MSG_CENTER, CPID_MISSING_TEAMS);
		prev_missing_teams_mask = -1;
		return 0;
	}
	float missing_teams_mask = (!redalive) + (!bluealive) * 2;
	if(ca_teams >= 3) missing_teams_mask += (!yellowalive) * 4;
	if(ca_teams >= 4) missing_teams_mask += (!pinkalive) * 8;
	if(prev_missing_teams_mask != missing_teams_mask)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_MISSING_TEAMS, missing_teams_mask);
		prev_missing_teams_mask = missing_teams_mask;
	}
	return 0;
}


// ======================
// Teleportation Handling
// ======================

/*
 * Find control point or generator owned by the same team this which is nearest to pos
 * if max_dist is positive, only control points within this range will be considered
 */
entity cq_Nearest_ControlPoint(entity this, vector pos, float max_dist)
{
	entity tmp_entity, closest_target = NULL;
	for(tmp_entity = cq_worldcplist; tmp_entity; tmp_entity = tmp_entity.cq_worldcpnext)
	{
		if(SAME_TEAM(tmp_entity, this))
		if(tmp_entity.cq_status == CP_CAPTURED)
		if(max_dist <= 0 || vdist(tmp_entity.origin - pos, <=, max_dist))
		if(vlen2(tmp_entity.origin - pos) <= vlen2(closest_target.origin - pos) || closest_target == NULL)
			closest_target = tmp_entity;
	}

	return closest_target;
}

/*
 * Find control point or generator owned by the same team this which is nearest to pos
 * if max_dist is positive, only control points within this range will be considered
 * This function only check distances on the XY plane, disregarding Z
 */
entity cq_Nearest_ControlPoint_2D(entity this, vector pos, float max_dist)
{
	entity tmp_entity, closest_target = NULL;
	vector delta;
	float smallest_distance = 0, distance;

	for(tmp_entity = cq_worldcplist; tmp_entity; tmp_entity = tmp_entity.cq_worldcpnext)
	{
		delta = tmp_entity.origin - pos;
		delta_z = 0;
		distance = vlen(delta);

		if(SAME_TEAM(tmp_entity, this))
		if(tmp_entity.cq_status == CP_CAPTURED)
		if(max_dist <= 0 || distance <= max_dist)
		if(closest_target == NULL || distance <= smallest_distance )
		{
			closest_target = tmp_entity;
			smallest_distance = distance;
		}
	}

	return closest_target;
}
/**
 * find the number of control points and generators in the same team as this
 */
int cq_Count_MyControlPoints(entity this)
{
	int n = 0;
	entity tmp_entity;
	for(tmp_entity = cq_worldcplist; tmp_entity; tmp_entity = tmp_entity.cq_worldcpnext)
	{
		if(SAME_TEAM(tmp_entity, this))
		if(tmp_entity.cq_status == CP_CAPTURED)
			n++;
	}
	return n;
}

/**
 * Teleport player to a random position near tele_target
 * if tele_effects is true, teleport sound+particles are created
 * return false on failure
 */
bool cq_Teleport(entity player, entity tele_target, float range, bool tele_effects)
{
	if ( !tele_target )
		return false;

	int i;
	vector loc;
	float theta;
	for(i = 0; i < 16; ++i)
	{
		theta = random() * 2 * M_PI;
		loc_y = sin(theta);
		loc_x = cos(theta);
		loc_z = 0;
		loc *= random() * range;

		loc += tele_target.origin + '0 0 128';

		tracebox(loc, PL_MIN_CONST, PL_MAX_CONST, loc, MOVE_NORMAL, player);
		if(trace_fraction == 1.0 && !trace_startsolid)
		{
			traceline(tele_target.origin, loc, MOVE_NOMONSTERS, tele_target); // double check to make sure we're not spawning outside the NULL
			if(trace_fraction == 1.0)
			{
				if ( tele_effects )
				{
					Send_Effect(EFFECT_TELEPORT, player.origin, '0 0 0', 1);
					sound (player, CH_TRIGGER, SND_TELEPORT, VOL_BASE, ATTEN_NORM);
				}
				setorigin(player, loc);
				player.teleport_antispam = time + autocvar_g_conquest_teleport_wait;

				if ( tele_effects )
					Send_Effect(EFFECT_TELEPORT, player.origin + v_forward * 32, '0 0 0', 1);
				return true;
			}
		}
	}

	return false;
}


// ==================
// Legacy Bot Support
// ==================

void havocbot_role_cq_liberating(entity this);

void havocbot_goalrating_defendpoints(entity this, float ratingscale, vector org, float sradius)
{
	entity head;
	float distance;

	for(head = cq_worldcplist; head; head = head.cq_worldcpnext)
	{
		if (SAME_TEAM(head, this))
		{
			if (head.health < head.max_health)
			{
				distance = vlen(head.origin - org);
				if (distance > sradius)
					continue;
				navigation_routerating(this, head, ratingscale, 2000);
			}
			else
			{
				// If control point is not under attack, seek it out anyway
				navigation_routerating(this, head, ratingscale/3, 2000);
			}
		}
	}
}

void havocbot_goalrating_enemypoints(entity this, float ratingscale, vector org, float sradius)
{
	for(entity head = cq_worldcplist; head; head = head.cq_worldcpnext)
	{
		if (DIFF_TEAM(head, this))
		{
			if(vdist(head.origin - org, >, sradius))
				continue;
			navigation_routerating(this, head, ratingscale, 2000);
		}
	}
}

void havocbot_role_cq_offense(entity this)
{
	if(this.deadflag != DEAD_NO)
		return;

	if (!this.havocbot_role_timeout)
		this.havocbot_role_timeout = time + random() * 10 + 20;

	// Count how many control points on team are owned.
	int owned = 0;
	for(entity head = cq_worldcplist; head; head = head.cq_worldcpnext)
	{
		if ((SAME_TEAM(head, this)) && (head.cq_status == CP_CAPTURED))
			owned++;
	}

	// If only one left on team or if role has timed out then start trying to liberate control points.
	if ((owned == 0) || (time > this.havocbot_role_timeout))
	{
		dprint("changing role to liberating\n");
		this.havocbot_role = havocbot_role_cq_liberating;
		this.havocbot_role_timeout = 0;
		return;
	}

	if (time > this.bot_strategytime)
	{
		this.bot_strategytime = time + autocvar_bot_ai_strategyinterval;

		navigation_goalrating_start(this);
		havocbot_goalrating_items(this, 10000, this.origin, 10000);
		havocbot_goalrating_enemypoints(this, 20000, this.origin, 10000);
		havocbot_goalrating_defendpoints(this, 9000, this.origin, 10000);
		//havocbot_goalrating_waypoints(1, this.origin, 1000);
		navigation_goalrating_end(this);
	}
}

void havocbot_role_cq_liberating(entity this)
{
	if(this.deadflag != DEAD_NO)
		return;

	if (!this.havocbot_role_timeout)
		this.havocbot_role_timeout = time + random() * 10 + 20;

	if (time > this.havocbot_role_timeout)
	{
		dprint("changing role to offense\n");
		this.havocbot_role = havocbot_role_cq_offense;
		this.havocbot_role_timeout = 0;
		return;
	}

	if (time > this.bot_strategytime)
	{
		this.bot_strategytime = time + autocvar_bot_ai_strategyinterval;

		navigation_goalrating_start(this);
		havocbot_goalrating_items(this, 8000, this.origin, 10000);
		havocbot_goalrating_enemyplayers(this, 10000, this.origin, 10000);
		havocbot_goalrating_defendpoints(this, 20000, this.origin, 10000);
		//havocbot_goalrating_waypoints(this, 1, this.origin, 1000);
		navigation_goalrating_end(this);
	}
}


// =============
// Compatibility
// =============

void cq_Setup_Compat_dom(entity this)
{
	// if map already has control points, don't spawn more
	if(cq_worldcplist && (!cq_worldcplist.cq_compat || cq_worldcplist.cq_compat != COMPAT_DOM))
	{
		setthink(this, SUB_Remove);
		this.nextthink = time;
		return;
	}

	int redcp = 0, bluecp = 0, yellowcp = 0, pinkcp = 0;

	entity head;
	for(head = cq_worldcplist; head; head = head.cq_worldcpnext)
	{
		switch(head.team)
		{
			case NUM_TEAM_1: ++redcp; break;
			case NUM_TEAM_2: ++bluecp; break;
			case NUM_TEAM_3: ++yellowcp; break;
			case NUM_TEAM_4: ++pinkcp; break;
		}
	}

	if(!redcp) { this.team = NUM_TEAM_1; }
	if(!bluecp) { this.team = NUM_TEAM_2; }
	if(!yellowcp && NumTeams(cq_teams) >= 3) { this.team = NUM_TEAM_3; }
	if(!pinkcp && NumTeams(cq_teams) >= 4) { this.team = NUM_TEAM_4; }

	this.cq_compat = COMPAT_DOM; // compatibility flag

	spawnfunc_conquest_controlpoint(this);
}

void cq_Setup_Compat_ons(entity this)
{
	// if map already has control points, don't spawn more
	if(cq_worldcplist && (!cq_worldcplist.cq_compat || cq_worldcplist.cq_compat != COMPAT_ONS))
	{
		setthink(this, SUB_Remove);
		this.nextthink = time;
		return;
	}

	// teams are already setup for onslaught

	this.cq_compat = COMPAT_ONS; // compatibility flag

	spawnfunc_conquest_controlpoint(this);
}


// ==============
// Hook Functions
// ==============

MUTATOR_HOOKFUNCTION(cq, MakePlayerObserver)
{
	entity player = M_ARGV(0, entity);

	player.cq_deathloc = '0 0 0';
}

MUTATOR_HOOKFUNCTION(cq, ClientDisconnect)
{
	entity player = M_ARGV(0, entity);

	player.cq_deathloc = '0 0 0';
}

MUTATOR_HOOKFUNCTION(cq, PlayerDies)
{
	entity frag_target = M_ARGV(2, entity);

	frag_target.cq_deathloc = frag_target.origin;

	if ( autocvar_g_conquest_spawn_choose )
	if ( cq_Count_MyControlPoints(frag_target) > 1 )
		stuffcmd(frag_target, "qc_cmd_cl hud clickradar\n");
}

MUTATOR_HOOKFUNCTION(cq, reset_map_global)
{
	for(entity e = cq_worldcplist; e; e = e.cq_worldcpnext)
		e.reset(e); // do this now as teams aren't setup in time for PlayerSpawn

	FOREACH_CLIENT(IS_PLAYER(it),
	{
		PutClientInServer(it);
	});
}

MUTATOR_HOOKFUNCTION(cq, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);

	if ( autocvar_g_conquest_spawn_choose )
	if ( player.cq_spawn_by )
	if ( cq_Teleport(player,player.cq_spawn_by,autocvar_g_conquest_teleport_radius,false) )
	{
		player.cq_spawn_by = NULL;
		return;
	}

	bool random_target = !(autocvar_g_conquest_spawn_close_to_death);
	int owned_count = cq_Count_MyControlPoints(player);
	entity tmp_entity, closest_target = NULL;
	vector spawn_loc = player.cq_deathloc;

	// new joining player or round reset, don't bother checking
	//if(spawn_loc == '0 0 0') { return false; }

	if(random_target) { RandomSelection_Init(); }

	for(tmp_entity = cq_worldcplist; tmp_entity; tmp_entity = tmp_entity.cq_worldcpnext)
	{
		if(SAME_TEAM(tmp_entity, player) || (!tmp_entity.team && !owned_count))
		if(tmp_entity.cq_status == CP_CAPTURED || !owned_count)
		if(random_target)
			RandomSelection_AddEnt(tmp_entity, 1, 1);
		else if(vlen2(tmp_entity.origin - spawn_loc) <= vlen2(closest_target.origin - spawn_loc) || closest_target == NULL)
			closest_target = tmp_entity;
	}

	if(random_target) { closest_target = RandomSelection_chosen_ent; }

	if(!closest_target)
	{
		for(tmp_entity = cq_worldcplist; tmp_entity; tmp_entity = tmp_entity.cq_worldcpnext)
		{
			if(SAME_TEAM(tmp_entity, player) || (!tmp_entity.team && !owned_count))
			if(tmp_entity.cq_status == CP_CAPTURED || !owned_count)
			{
				closest_target = tmp_entity;
				break;
			}
		}
	}

	if(closest_target)
	{
		int i;
		vector loc;
		for(i = 0; i < 10; ++i)
		{
			loc = closest_target.origin + '0 0 96';
			if(random() >= 0.5)
				loc += ('1 1 0' * random()) * 1024;
			else
				loc -= ('1 1 0' * random()) * 1024;
			tracebox(loc, PL_MIN_CONST, PL_MAX_CONST, loc, MOVE_NORMAL, player);
			if(trace_fraction == 1.0 && !trace_startsolid)
			{
				traceline(closest_target.origin, loc, MOVE_NOMONSTERS, closest_target); // double check to make sure we're not spawning outside the NULL
				if(trace_fraction == 1.0)
				{
					setorigin(player, loc);
					player.angles = normalize(loc - closest_target.origin);
					return;
				}
			}
		}
	}

	print("Warning: No spawns found for team ", ftos(player.team), "\n");
}

MUTATOR_HOOKFUNCTION(cq, SV_ParseClientCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return ;

	entity player = M_ARGV(0, entity);
	string cmd_name = M_ARGV(1, string);
	int cmd_argc = M_ARGV(2, int);

	if ( cmd_name == "ons_spawn" )
	{
		vector pos = player.origin;
		if(cmd_argc > 1)
			pos_x = stof(argv(1));
		if(cmd_argc > 2)
			pos_y = stof(argv(2));
		if(cmd_argc > 3)
			pos_z = stof(argv(3));

		if ( IS_PLAYER(player) )
		{
			if(!player.vehicle)
			if(!STAT(FROZEN, player))
			{
				entity source_point = cq_Nearest_ControlPoint(player, player.origin, autocvar_g_conquest_teleport_radius);

				if ( !source_point && player.health > 0 )
				{
					sprint(player, "\nYou need to be next to a control point\n");
					return true;
				}


				entity closest_target = cq_Nearest_ControlPoint_2D(player, pos, autocvar_g_conquest_click_radius);

				if ( closest_target == NULL )
				{
					sprint(player, "\nNo control point found\n");
					return true;
				}

				if ( player.health <= 0 )
				{
					player.cq_spawn_by = closest_target;
					player.respawn_flags = player.respawn_flags | RESPAWN_FORCE;
				}
				else
				{
					if ( source_point == closest_target )
					{
						sprint(player, "\nTeleporting to the same point\n");
						return true;
					}

					if ( !cq_Teleport(player,closest_target,autocvar_g_conquest_teleport_radius,true) )
						sprint(player, "\nUnable to teleport there\n");
				}

				return true;
			}

			sprint(player, "\nNo teleportation for you\n");
		}

		return true;
	}
}

MUTATOR_HOOKFUNCTION(cq, PlayerUseKey)
{
	if(MUTATOR_RETURNVALUE || game_stopped) { return false; }

	entity player = M_ARGV(0, entity);

	if((time > player.teleport_antispam) && (player.deadflag == DEAD_NO) && !player.vehicle && !STAT(FROZEN, player))
	{
		entity source_point = cq_Nearest_ControlPoint(player, player.origin, autocvar_g_conquest_teleport_radius);
		if ( source_point )
		{
			stuffcmd(player, "qc_cmd_cl hud clickradar\n");
			return true;
		}
	}
}

MUTATOR_HOOKFUNCTION(cq, OnEntityPreSpawn)
{
	entity ent = M_ARGV(0, entity);

	// onslaught support comes first, as it's most likely to have the best layout
	if(ent.classname == "onslaught_generator" || ent.classname == "onslaught_controlpoint")
	{
		entity cp = spawn();
		cp.team = ent.team;
		setorigin(cp, ent.origin + '0 0 20');
		droptofloor(cp);
		InitializeEntity(cp, cq_Setup_Compat_ons, INITPRIO_FINDTARGET);
		return;
	}
	if(ent.classname == "dom_controlpoint")
	{
		entity cp = spawn();
		// domination doesn't use teams
		setorigin(cp, ent.origin + '0 0 20');
		droptofloor(cp);
		InitializeEntity(cp, cq_Setup_Compat_dom, INITPRIO_FINDTARGET);
		return;
	}
}

MUTATOR_HOOKFUNCTION(cq, HavocBot_ChooseRole)
{
	entity bot = M_ARGV(0, entity);

	bot.havocbot_role = havocbot_role_cq_offense;
	return true;
}

MUTATOR_HOOKFUNCTION(cq, CheckAllowedTeams)
{
	M_ARGV(0, float) = cq_teams;
}

void cq_ScoreRules(int teams)
{
	ScoreRules_basics(teams, SFL_SORT_PRIO_PRIMARY, 0, true);

	ScoreInfo_SetLabel_TeamScore(ST_CONQUEST_ROUNDS, "rounds", SFL_SORT_PRIO_PRIMARY);
	ScoreInfo_SetLabel_PlayerScore(SP_CONQUEST_LIBERATED, "liberated", 0);
	ScoreInfo_SetLabel_PlayerScore(SP_CONQUEST_CAPTURED, "captured", 0);

	ScoreRules_basics_end();
}

void cq_DelayedInit(entity this)
{
	cq_teams = 0;

	entity tmp_entity;
	for(tmp_entity = cq_worldcplist; tmp_entity; tmp_entity = tmp_entity.cq_worldcpnext)
	{
		switch(tmp_entity.team)
		{
			case NUM_TEAM_1: BITSET_ASSIGN(cq_teams, BIT(0)); break;
			case NUM_TEAM_2: BITSET_ASSIGN(cq_teams, BIT(1)); break;
			case NUM_TEAM_3: BITSET_ASSIGN(cq_teams, BIT(2)); break;
			case NUM_TEAM_4: BITSET_ASSIGN(cq_teams, BIT(3)); break;
		}
	}

	if(NumTeams(cq_teams) < 2) // broken map or compatibility
	{
		cq_teams = 0; // so set the default red and blue teams
		BITSET_ASSIGN(cq_teams, BIT(0));
		BITSET_ASSIGN(cq_teams, BIT(1));
	}

	cq_ScoreRules(cq_teams);

	round_handler_Spawn(cq_CheckTeams, cq_CheckWinner, func_null);
	round_handler_Init(5, autocvar_g_conquest_warmup, autocvar_g_conquest_round_timelimit);
}
#endif

#endif
