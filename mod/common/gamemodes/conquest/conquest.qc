//FEATURE: Conquest gamemode, a more ambitious version of domination and a game of capture the spawn point

#ifndef IMPLEMENTATION
#ifdef SVQC
	AUTOCVAR_NOREF(g_conquest, bool, false, "Conquest: take control points until the enemy has nowhere to spawn");
#endif
#include "conquest.qh"

#ifdef SVQC
void cq_DelayedInit(entity this);

REGISTER_MUTATOR(cq, false)
{
	MUTATOR_STATIC();
	MUTATOR_ONADD
	{
		GameRules_teams(true);

		InitializeEntity(NULL, cq_DelayedInit, INITPRIO_GAMETYPE);
	}

	return false;
}
#endif

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC
AUTOCVAR_NOREF(g_cq_respawn_delay_small, float, 0, "");
AUTOCVAR_NOREF(g_cq_respawn_delay_small_count, float, 0, "");
AUTOCVAR_NOREF(g_cq_respawn_delay_large, float, 0, "");
AUTOCVAR_NOREF(g_cq_respawn_delay_large_count, float, 0, "");
AUTOCVAR_NOREF(g_cq_respawn_delay_max, float, 0, "");
AUTOCVAR_NOREF(g_cq_respawn_waves, float, 0, "");
AUTOCVAR_NOREF(g_cq_weapon_stay, float, 0, "");
AUTOCVAR(g_conquest_capture_distance_default, float, 512, "maximum distance from control point at which players can capture/liberate");
AUTOCVAR(g_conquest_capture_sps, float, 100, "capture/liberation speed");
AUTOCVAR(g_conquest_controlpoint_health_default, float, 500, "");
AUTOCVAR(g_conquest_warmup, float, 5, "");
AUTOCVAR(g_conquest_round_timelimit, float, 360, "");

bool cq_ControlPoint_Send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_CONQUEST_CONTROLPOINT);
	WriteByte(MSG_ENTITY, sf);

	if(sf & CQSF_SETUP)
	{
		WriteVector(MSG_ENTITY, this.origin);

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
		WriteByte(MSG_ENTITY, ceil((GetResource(this, RES_HEALTH) / this.max_health) * 255));
		WriteCoord(MSG_ENTITY, this.cq_capspeed);
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
			this.skin = Team_TeamToIndex(this.team) + 1;

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

		default: { LOG_DEBUG("Control point without status?"); break; }
	}

	SUB_UseTargets(this, act, NULL);

	this.SendFlags |= CQSF_STATE | CQSF_TEAM;
}

void cq_ControlPoint_Think(entity this)
{
	this.nextthink = time + CQ_CP_THINKRATE;

	if(!round_handler_IsRoundStarted()) { return; }

	float old_health = GetResource(this, RES_HEALTH);

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
						SetResourceExplicit(this, RES_HEALTH, min(this.max_health, GetResource(this, RES_HEALTH) + this.cq_capspeed * CQ_CP_THINKRATE));
					else
						SetResourceExplicit(this, RES_HEALTH, max(0, GetResource(this, RES_HEALTH) - this.cq_capspeed * CQ_CP_THINKRATE));

					switch(this.cq_status)
					{
						case CP_CAPTURED:
						{
							if(GetResource(this, RES_HEALTH) == 0)
							{
								GameRules_scoring_add(it, CONQUEST_LIBERATED, 1);
								Send_Effect(EFFECT_EXPLOSION_BIG, findbetterlocation(this.origin, 16), '0 0 0', 1);
								cq_ControlPoint_SwitchTeam(this, it.team, CP_NEUTRAL, true);
							}

							break;
						}

						case CP_NEUTRAL:
						{
							if(GetResource(this, RES_HEALTH) == 0)
								cq_ControlPoint_SwitchTeam(this, it.team, CP_NEUTRAL, true);

							if(GetResource(this, RES_HEALTH) == this.max_health)
							{
								GameRules_scoring_add(it, CONQUEST_CAPTURED, 1);
								cq_ControlPoint_SwitchTeam(this, it.team, CP_CAPTURED, true);
							}

							break;
						}
					}
				}
			}
		}
	});

	if(GetResource(this, RES_HEALTH) != old_health)
		this.SendFlags |= CQSF_HEALTH;
}

void cq_ControlPoint_Reset(entity this)
{
	this.cq_status = CP_NEUTRAL;
	SetResourceExplicit(this, RES_HEALTH, 0);
	this.SendFlags |= CQSF_HEALTH;
	cq_ControlPoint_SwitchTeam(this, 0, this.cq_status, false);
}

spawnfunc(conquest_controlpoint)
{
	if(!g_conquest) { delete(this); return; }

	this.cq_worldcpnext = cq_worldcplist; // link control point into cq_worldcplist
	cq_worldcplist = this;

	this.model = ""; // should we support custom models?

	setsize(this, CQ_CP_MIN, CQ_CP_MAX);

	if(this.netname == "")		{ this.netname = "a spawnpoint"; }
	if(!this.cq_capdistance)	{ this.cq_capdistance = autocvar_g_conquest_capture_distance_default; }
	if(!this.cq_capspeed) 		{ this.cq_capspeed = autocvar_g_conquest_capture_sps; }

	this.classname = "conquest_controlpoint";
	this.max_health = autocvar_g_conquest_controlpoint_health_default;
	this.solid = SOLID_TRIGGER;
	this.nextthink = time + CQ_CP_THINKRATE;
	setthink(this, cq_ControlPoint_Think);
	this.reset = cq_ControlPoint_Reset;

	this.cq_status = CP_NEUTRAL;
	SetResourceExplicit(this, RES_HEALTH, 0);

	waypoint_spawnforitem(this);
	Net_LinkEntity(this, false, 0, cq_ControlPoint_Send);
	this.SendFlags = CQSF_SETUP | CQSF_STATE | CQSF_TEAM | CQSF_HEALTH | CQSF_NAME;
	cq_ControlPoint_SwitchTeam(this, 0, this.cq_status, false);
}

// round handler
void cq_CountAlivePlayers()
{
	total_players = 0;
	for (int i = 1; i <= NUM_TEAMS; ++i)
	{
		Team_SetNumberOfAlivePlayers(Team_GetTeamFromIndex(i), 0);
	}
	FOREACH_CLIENT(IS_PLAYER(it) && Entity_HasValidTeam(it),
	{
		++total_players;
		if (IS_DEAD(it))
		{
			continue;
		}
		entity team_ = Entity_GetTeam(it);
		int num_alive = Team_GetNumberOfAlivePlayers(team_);
		++num_alive;
		Team_SetNumberOfAlivePlayers(team_, num_alive);
	});
}

#define CQ_ALIVE_TEAMS_OK() (Team_GetNumberOfAliveTeams() == NumTeams(cq_teams))

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
	for (int i = 1; i <= NUM_TEAMS; ++i)
	{
		if ((cq_teams & Team_IndexToBit(i)) &&
			(Team_GetNumberOfAlivePlayers(Team_GetTeamFromIndex(i)) == 0))
		{
			missing_teams_mask |= Team_IndexToBit(i);
		}
	}
	if(prev_missing_teams_mask != missing_teams_mask)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_MISSING_TEAMS, missing_teams_mask);
		prev_missing_teams_mask = missing_teams_mask;
	}
	return false;
}


// ==================
// Legacy Bot Support
// ==================

void havocbot_role_cq_liberating(entity this);

void havocbot_goalrating_defendpoints(entity this, float ratingscale, vector org, float sradius)
{
	for(entity head = cq_worldcplist; head; head = head.cq_worldcpnext)
	{
		if (SAME_TEAM(head, this))
		{
			if (GetResource(head, RES_HEALTH) < head.max_health)
			{
				float distance = vlen(head.origin - org);
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

	if (navigation_goalrating_timeout(this))
	{
		navigation_goalrating_timeout_set(this);

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

	if (navigation_goalrating_timeout(this))
	{
		navigation_goalrating_timeout_set(this);

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

MUTATOR_HOOKFUNCTION(cq, reset_map_global)
{
	for(entity e = cq_worldcplist; e; e = e.cq_worldcpnext)
		e.reset(e); // do this now as teams aren't setup in time for PlayerSpawn

	FOREACH_CLIENT(IS_PLAYER(it),
	{
		PutClientInServer(it);
	});
}

MUTATOR_HOOKFUNCTION(cq, OnEntityPreSpawn)
{
	entity ent = M_ARGV(0, entity);

	// onslaught support comes first, as it's most likely to have the best layout
	if(ent.classname == "onslaught_generator" || ent.classname == "onslaught_controlpoint")
	{
		entity cp = spawn();
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

MUTATOR_HOOKFUNCTION(cq, TeamBalance_CheckAllowedTeams)
{
	M_ARGV(0, float) = cq_teams;
	return true;
}

void cq_ScoreRules(int teams)
{
	GameRules_scoring(teams, SFL_SORT_PRIO_PRIMARY, 0, {
		field_team(ST_CONQUEST_ROUNDS, "rounds", SFL_SORT_PRIO_PRIMARY);
		field(SP_CONQUEST_LIBERATED, "liberated", 0);
		field(SP_CONQUEST_CAPTURED, "captured", 0);
	});
}

void cq_DelayedInit(entity this)
{
	cq_teams = autocvar_g_conquest_teams_override;
	if (cq_teams < 2)
		cq_teams = cvar("g_conquest_teams"); // read the cvar directly as it gets written earlier in the same frame (not so, but whatever)

	cq_teams = BITS(bound(2, cq_teams, 4));

	cq_ScoreRules(cq_teams);

	round_handler_Spawn(cq_CheckTeams, cq_CheckWinner, func_null);
	round_handler_Init(5, autocvar_g_conquest_warmup, autocvar_g_conquest_round_timelimit);
}
#endif

#endif
