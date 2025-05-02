//FEATURE: Conquest gamemode, a more ambitious version of domination in which you need to stand by control points to capture them

#ifndef IMPLEMENTATION
#ifdef SVQC
	AUTOCVAR_NOREF(g_conquest, bool, false, "Conquest: control the points to win the game");
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
AUTOCVAR_NOREF(g_cq_respawn_delay_small, float, 1, "");
AUTOCVAR_NOREF(g_cq_respawn_delay_small_count, float, 1, "");
AUTOCVAR_NOREF(g_cq_respawn_delay_large, float, 5, "");
AUTOCVAR_NOREF(g_cq_respawn_delay_large_count, float, 5, "");
AUTOCVAR_NOREF(g_cq_respawn_delay_max, float, 0, "");
AUTOCVAR_NOREF(g_cq_respawn_waves, float, 0, "");
AUTOCVAR_NOREF(g_cq_weapon_stay, float, 0, "");
AUTOCVAR(g_conquest_score_rate, float, 10, "time in seconds between score evaluations");
AUTOCVAR(g_conquest_score_amount, float, 5, "amount of points each control point gives per evaluation");
AUTOCVAR(g_conquest_capture_distance_default, float, 512, "maximum distance from control point at which players can capture/liberate");
AUTOCVAR(g_conquest_capture_speed, float, 25, "capture/liberation speed, a score that reaches the control point's health value");
AUTOCVAR(g_conquest_capture_vehicle, bool, false, "allow capturing control points while inside a vehicle");
AUTOCVAR(g_conquest_controlpoint_health_default, float, 500, "");

bool cq_ControlPoint_Send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_CONQUEST_CONTROLPOINT);
	WriteByte(MSG_ENTITY, sf);

	if(sf & CQSF_SETUP)
	{
		WriteVector(MSG_ENTITY, this.origin);

		WriteAngle(MSG_ENTITY, this.angles_y);

		WriteLong(MSG_ENTITY, this.target_range);
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
		WriteCoord(MSG_ENTITY, this.speed);
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
	int oldstatus = this.cq_status;

	if(showmessage && newstatus == CP_NEUTRAL && this.cq_status != CP_NEUTRAL)
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

			if(showmessage && oldstatus != newstatus)
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

	if(oldstatus != newstatus)
		SUB_UseTargets(this, act, NULL);

	this.SendFlags |= CQSF_STATE | CQSF_TEAM;
}

int cq_found_players[17];
void cq_ControlPoint_Think(entity this)
{
	this.nextthink = time + CQ_CP_THINKRATE;

	if(game_stopped || time < game_starttime)
		return;

	float old_health = GetResource(this, RES_HEALTH);
	int found_teammates = 0, found_enemies = 0;
	for(int j = 0; j < 17; ++j)
		cq_found_players[j] = 0;

	entity head = WarpZone_FindRadius(this.origin, this.target_range, true);
	while(head)
	{
		if(IS_PLAYER(head) && !IS_DEAD(head) && (!head.vehicle || autocvar_g_conquest_capture_vehicle))
		{
			if(SAME_TEAM(head, this))
				++found_teammates;
			else
			{
				cq_found_players[head.team] += 1;
				++found_enemies;
			}
		}
		head = head.chain;
	}

	// nasty hack to check if there's a stalemate (too many enemy teams to capture)
	int highest_cnt = 0;
	bool have_stalemate = false;
	int best_team = 0;
	for(int j = 0; j < 17; ++j)
	{
		int tempcnt = cq_found_players[j];
		if(!tempcnt)
			continue;
		if(tempcnt == highest_cnt)
			have_stalemate = true;
		else if(tempcnt > highest_cnt || !highest_cnt)
		{
			have_stalemate = false;
			highest_cnt = tempcnt;
			best_team = j;
		}
	}

	if(found_teammates)
		SetResourceExplicit(this, RES_HEALTH, min(this.max_health, GetResource(this, RES_HEALTH) + (this.speed * found_teammates) * CQ_CP_THINKRATE));
	if(found_enemies && found_enemies >= found_teammates) // if they're lower, then the teammates will be able to capture (TODO)
		SetResourceExplicit(this, RES_HEALTH, max(0, GetResource(this, RES_HEALTH) - (this.speed * found_enemies) * CQ_CP_THINKRATE));

	switch(this.cq_status)
	{
		case CP_CAPTURED:
		{
			if(GetResource(this, RES_HEALTH) == 0)
			{
				//GameRules_scoring_add(it, CONQUEST_LIBERATED, 1);
				Send_Effect(EFFECT_EXPLOSION_BIG, findbetterlocation(this.origin, 16), '0 0 0', 1);
				cq_ControlPoint_SwitchTeam(this, best_team, CP_NEUTRAL, true);
			}

			break;
		}
		case CP_NEUTRAL:
		{
			if(GetResource(this, RES_HEALTH) == 0)
				cq_ControlPoint_SwitchTeam(this, ((have_stalemate) ? 0 : best_team), CP_NEUTRAL, false);

			if(have_stalemate)
				break; // if there's a stalemate, don't allow capturing!

			if(GetResource(this, RES_HEALTH) == this.max_health)
			{
				//TeamScore_AddToTeam(this.team, ST_SCORE, score);
				cq_ControlPoint_SwitchTeam(this, this.team, CP_CAPTURED, true);
			}

			break;
		}
	}

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

	if(this.netname == "")		{ this.netname = "a control point"; }
	if(!this.target_range)		{ this.target_range = autocvar_g_conquest_capture_distance_default; }
	if(!this.speed) 			{ this.speed = autocvar_g_conquest_capture_speed; }
	if(!this.frags) 			{ this.frags = autocvar_g_conquest_score_amount; }

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

	// TODO: is this actually necessary?
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		PutClientInServer(it);
	});
}

MUTATOR_HOOKFUNCTION(cq, SV_StartFrame)
{
	if(game_stopped || time < game_starttime || time < conquest_scoretimer)	// game has ended, don't keep giving points
		return;

	conquest_scoretimer = time + autocvar_g_conquest_score_rate;

	for(entity e = cq_worldcplist; e; e = e.cq_worldcpnext)
	{
		if(!e.team)
			continue; // neutral
		TeamScore_AddToTeam(e.team, ST_SCORE, e.frags);
	}
}

// TODO: remove this, the maps aren't designed for gameplay
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
	GameRules_scoring(teams, 0, SFL_SORT_PRIO_PRIMARY, {
		field(SP_CONQUEST_LIBERATED, _("SCO^liberated"), 0);
		field(SP_CONQUEST_CAPTURED, _("SCO^captured"), 0);
	});
}

void cq_DelayedInit(entity this)
{
	cq_teams = autocvar_g_conquest_teams_override;
	if (cq_teams < 2)
		cq_teams = cvar("g_conquest_teams"); // read the cvar directly as it gets written earlier in the same frame (not so, but whatever)

	cq_teams = BITS(bound(2, cq_teams, 4));

	cq_ScoreRules(cq_teams);
}
#endif

#endif
