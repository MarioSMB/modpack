float cq_ControlPoint_Send(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_CONQUEST_CONTROLPOINT);
	WriteByte(MSG_ENTITY, sf);

	if(sf & CQSF_SETUP)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);

		WriteCoord(MSG_ENTITY, self.angles_y);

		WriteLong(MSG_ENTITY, self.cq_capdistance);
	}

	if(sf & CQSF_STATE)
	{
		WriteByte(MSG_ENTITY, self.cq_status);
	}

	if(sf & CQSF_TEAM)
	{
		WriteByte(MSG_ENTITY, self.team);
	}

	if(sf & CQSF_HEALTH)
	{
		WriteByte(MSG_ENTITY, ceil((self.health / self.max_health) * 255));
		WriteLong(MSG_ENTITY, autocvar_g_conquest_capture_sps);
	}

	if(sf & CQSF_NAME)
	{
		WriteString(MSG_ENTITY, self.netname);
	}


	return TRUE;
}

void cq_ControlPoint_SwitchTeam(float newteam, float newstatus, float showmessage)
{
	// TODO: add sounds
	// TODO: clean this up!

	if(showmessage)
	if(newstatus == CP_NEUTRAL && self.cq_status != CP_NEUTRAL)
	{
		Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(self, INFO_CONQUEST_LIBERATE_), self.netname);
		Send_Notification(NOTIF_TEAM, self, MSG_CENTER, APP_TEAM_NUM_4(newteam, CENTER_CONQUEST_LOST_), self.netname);

		entity player;
		FOR_EACH_REALPLAYER(player)
		{
			if(player.team == newteam)
				Send_Notification(NOTIF_ONE, player, MSG_CENTER, APP_TEAM_ENT_4(self, CENTER_CONQUEST_LIBERATE_TEAM_), self.netname);
			else if(DIFF_TEAM(player, self))
				Send_Notification(NOTIF_ONE, player, MSG_CENTER, APP_TEAM_NUM_4(newteam, CENTER_CONQUEST_LIBERATE_), self.netname);
		}
	}

	self.team = newteam;
	self.cq_status = newstatus;

	switch(self.cq_status)
	{
		case CP_NEUTRAL:
		{
			activator = world;
			self.skin = 0;
			break;
		}

		case CP_CAPTURED:
		{
			activator = self;
			self.skin = Team_TeamToNumber(self.team) + 1;

			if(showmessage)
			{
				Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(self, INFO_CONQUEST_CAPTURE_), self.netname);
				Send_Notification(NOTIF_TEAM, self, MSG_CENTER, CENTER_CONQUEST_CAPTURE_TEAM, self.netname);

				entity player;
				FOR_EACH_PLAYER(player)
				{
					if(DIFF_TEAM(player, self))
						Send_Notification(NOTIF_ONE, player, MSG_CENTER, APP_TEAM_ENT_4(self, CENTER_CONQUEST_CAPTURE_), self.netname);
				}
			}

			break;
		}

		default: { dprint("Control point without status?\n"); break; }
	}

	SUB_UseTargets();

	self.SendFlags |= CQSF_STATE | CQSF_TEAM;
}

void cq_ControlPoint_Think()
{
	self.nextthink = time + CQ_CP_THINKRATE;

	if(!round_handler_IsRoundStarted()) { return; }

	float dist, old_health = self.health;
	entity player;

	FOR_EACH_PLAYER(player)
	{
		if(!player.deadflag)
		if(!player.vehicle)
		if(!player.frozen)
		{
			dist = vlen(player.origin - self.origin);
			if(dist <= self.cq_capdistance)
			{
				traceline(CENTER_OR_VIEWOFS(player), CENTER_OR_VIEWOFS(self), MOVE_WORLDONLY, player);
				if(trace_fraction == 1.0)
				{
					if(SAME_TEAM(player, self))
						self.health = min(self.max_health, self.health + autocvar_g_conquest_capture_sps * CQ_CP_THINKRATE);
					else
						self.health = max(0, self.health - autocvar_g_conquest_capture_sps * CQ_CP_THINKRATE);

					switch(self.cq_status)
					{
						case CP_CAPTURED:
						{
							if(self.health == 0)
							{
								PlayerScore_Add(player, SP_CONQUEST_LIBERATED, 1);
								pointparticles(particleeffectnum("explosion_big"), findbetterlocation(self.origin, 16), '0 0 0', 1);
								cq_ControlPoint_SwitchTeam(player.team, CP_NEUTRAL, TRUE);
							}

							break;
						}

						case CP_NEUTRAL:
						{
							if(self.health == 0)
								cq_ControlPoint_SwitchTeam(player.team, CP_NEUTRAL, TRUE);

							if(self.health == self.max_health)
							{
								PlayerScore_Add(player, SP_CONQUEST_CAPTURED, 1);
								cq_ControlPoint_SwitchTeam(player.team, CP_CAPTURED, TRUE);
							}

							break;
						}
					}
				}
			}
		}
	}

	if(self.health != old_health)
		self.SendFlags |= CQSF_HEALTH;
}

void cq_ControlPoint_Reset()
{
	if(self.cq_originalteam)
		self.cq_status = CP_CAPTURED;
	else
	{
		self.cq_status = CP_NEUTRAL;
		self.health = 0;
	}
	self.SendFlags |= CQSF_HEALTH | CQSF_TEAM;
	cq_ControlPoint_SwitchTeam(self.cq_originalteam, self.cq_status, FALSE);
}

void spawnfunc_conquest_controlpoint()
{
	if(!g_conquest) { remove(self); return; }

	self.cq_worldcpnext = cq_worldcplist; // link control point into cq_worldcplist
	cq_worldcplist = self;

	self.model = ""; // should we support custom models?

	setsize(self, CQ_CP_MIN, CQ_CP_MAX);

	if(self.netname == "")		{ self.netname = "a spawnpoint"; }
	if(!self.health)			{ self.health = autocvar_g_conquest_controlpoint_health_default; }
	if(!self.cq_capdistance)	{ self.cq_capdistance = autocvar_g_conquest_capture_distance_default; }

	self.classname = "conquest_controlpoint";
	self.max_health = self.health;
	self.solid = SOLID_TRIGGER;
	self.nextthink = time + CQ_CP_THINKRATE;
	self.think = cq_ControlPoint_Think;
	self.reset = cq_ControlPoint_Reset;

	if(self.team == NUM_TEAM_4 && cq_teams < 4)
		self.team = NUM_TEAM_2;
	if(self.team == NUM_TEAM_3 && cq_teams < 3)
		self.team = NUM_TEAM_1;

	if(self.team)
		self.cq_status = CP_CAPTURED;
	else
	{
		self.cq_status = CP_NEUTRAL;
		self.health = 0;
	}

	self.cq_originalteam = self.team;

	waypoint_spawnforitem(self);
	Net_LinkEntity(self, FALSE, 0, cq_ControlPoint_Send);
	self.SendFlags = CQSF_SETUP | CQSF_STATE | CQSF_TEAM | CQSF_HEALTH | CQSF_NAME;
	cq_ControlPoint_SwitchTeam(self.team, self.cq_status, FALSE);
}

// round handler
void cq_CountAlivePlayers()
{
	entity e;
	total_players = redalive = bluealive = yellowalive = pinkalive = 0;

	FOR_EACH_PLAYER(e)
	{
		++total_players;
		redalive += (e.team == NUM_TEAM_1 && e.deadflag == DEAD_NO);
		bluealive += (e.team == NUM_TEAM_2 && e.deadflag == DEAD_NO);
		yellowalive += (e.team == NUM_TEAM_3 && e.deadflag == DEAD_NO);
		pinkalive += (e.team == NUM_TEAM_4 && e.deadflag == DEAD_NO);
	}
}

#define CQ_ALIVE_TEAMS() ((redalive > 0) + (bluealive > 0) + (yellowalive > 0) + (pinkalive > 0))
#define CQ_ALIVE_TEAMS_OK() (CQ_ALIVE_TEAMS() == cq_teams)

float cq_getWinnerTeam()
{
	entity tmp_entity;
	float redcp = 0, bluecp = 0, yellowcp = 0, pinkcp = 0;
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

	float winner_team = 0;
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

float cq_CheckWinner()
{
	if(round_handler_GetEndTime() > 0 && round_handler_GetEndTime() - time <= 0)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_OVER);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_OVER);
		round_handler_Init(5, autocvar_g_conquest_warmup, autocvar_g_conquest_round_timelimit);
		return 1;
	}

	cq_CountAlivePlayers();

	entity tmp_entity;
	float redcp = 0, bluecp = 0, yellowcp = 0, pinkcp = 0, neutralcp = 0;
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
		return 0;

	float winner_team;
	winner_team = cq_getWinnerTeam();
	if(winner_team > 0)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, APP_TEAM_NUM_4(winner_team, CENTER_ROUND_TEAM_WIN_));
		Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_NUM_4(winner_team, INFO_ROUND_TEAM_WIN_));
		TeamScore_AddToTeam(winner_team, ST_CONQUEST_ROUNDS, +1);
	}
	else if(winner_team == -1)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_TIED);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_TIED);
	}

	round_handler_Init(5, autocvar_g_conquest_warmup, autocvar_g_conquest_round_timelimit);
	return 1;
}

float prev_total_players;
float cq_CheckTeams()
{
	cq_CountAlivePlayers();
	if(CQ_ALIVE_TEAMS_OK())
	{
		Kill_Notification(NOTIF_ALL, world, MSG_CENTER_CPID, CPID_MISSING_TEAMS);
		prev_total_players = -1;
		return 1;
	}
	if(prev_total_players != total_players)
	{
		float p1 = 0, p2 = 0, p3 = 0, p4 = 0;
		if(!redalive) p1 = NUM_TEAM_1;
		if(!bluealive) p2 = NUM_TEAM_2;
		if(cq_teams >= 3)
		if(!yellowalive) p3 = NUM_TEAM_3;
		if(cq_teams >= 4)
		if(!pinkalive) p4 = NUM_TEAM_4;
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_MISSING_TEAMS, p1, p2, p3, p4);
		prev_total_players = total_players;
	}
	return 0;
}


// ======================
// Teleportation Handling
// ======================

/*
 * Find control point or generator owned by the same team self which is nearest to pos
 * if max_dist is positive, only control points within this range will be considered
 */
entity cq_Nearest_ControlPoint(vector pos, float max_dist)
{
	entity tmp_entity, closest_target = world;
	for(tmp_entity = cq_worldcplist; tmp_entity; tmp_entity = tmp_entity.cq_worldcpnext)
	{
		if(SAME_TEAM(tmp_entity, self))
		if(tmp_entity.cq_status == CP_CAPTURED)
		if(max_dist <= 0 || vlen(tmp_entity.origin - pos) <= max_dist)
		if(vlen(tmp_entity.origin - pos) <= vlen(closest_target.origin - pos) || closest_target == world)
			closest_target = tmp_entity;
	}

	return closest_target;
}

/*
 * Find control point or generator owned by the same team self which is nearest to pos
 * if max_dist is positive, only control points within this range will be considered
 * This function only check distances on the XY plane, disregarding Z
 */
entity cq_Nearest_ControlPoint_2D(vector pos, float max_dist)
{
	entity tmp_entity, closest_target = world;
	vector delta;
	float smallest_distance = 0, distance;

	for(tmp_entity = cq_worldcplist; tmp_entity; tmp_entity = tmp_entity.cq_worldcpnext)
	{
		delta = tmp_entity.origin - pos;
		delta_z = 0;
		distance = vlen(delta);

		if(SAME_TEAM(tmp_entity, self))
		if(tmp_entity.cq_status == CP_CAPTURED)
		if(max_dist <= 0 || distance <= max_dist)
		if(closest_target == world || distance <= smallest_distance )
		{
			closest_target = tmp_entity;
			smallest_distance = distance;
		}
	}

	return closest_target;
}
/**
 * find the number of control points and generators in the same team as self
 */
float cq_Count_SelfControlPoints()
{
	float n = 0;
	entity tmp_entity;
	for(tmp_entity = cq_worldcplist; tmp_entity; tmp_entity = tmp_entity.cq_worldcpnext)
	{
		if(SAME_TEAM(tmp_entity, self))
		if(tmp_entity.cq_status == CP_CAPTURED)
			n++;
	}
	return n;
}

/**
 * Teleport player to a random position near tele_target
 * if tele_effects is true, teleport sound+particles are created
 * return FALSE on failure
 */
float cq_Teleport(entity player, entity tele_target, float range, float tele_effects)
{
	if ( !tele_target )
		return FALSE;

	float i;
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

		tracebox(loc, PL_MIN, PL_MAX, loc, MOVE_NORMAL, player);
		if(trace_fraction == 1.0 && !trace_startsolid)
		{
			traceline(tele_target.origin, loc, MOVE_NOMONSTERS, tele_target); // double check to make sure we're not spawning outside the world
			if(trace_fraction == 1.0)
			{
				if ( tele_effects )
				{
					pointparticles(particleeffectnum("teleport"), player.origin, '0 0 0', 1);
					sound (player, CH_TRIGGER, "misc/teleport.wav", VOL_BASE, ATTEN_NORM);
				}
				setorigin(player, loc);
				player.teleport_antispam = time + autocvar_g_conquest_teleport_wait;

				if ( tele_effects )
					pointparticles(particleeffectnum("teleport"), player.origin + v_forward * 32, '0 0 0', 1);
				return TRUE;
			}
		}
	}

	return FALSE;
}


// ==================
// Legacy Bot Support
// ==================

void havocbot_role_cq_liberating();

void havocbot_goalrating_defendpoints(float ratingscale, vector org, float sradius)
{
	entity head;
	float distance;

	for(head = cq_worldcplist; head; head = head.cq_worldcpnext)
	{
		if (SAME_TEAM(head, self))
		{
			if (head.health < head.max_health)
			{
				distance = vlen(head.origin - org);
				if (distance > sradius)
					continue;
				navigation_routerating(head, ratingscale, 2000);
			}
			else
			{
				// If control point is not under attack, seek it out anyway
				navigation_routerating(head, ratingscale/3, 2000);
			}
		}
	}
}

void havocbot_goalrating_enemypoints(float ratingscale, vector org, float sradius)
{
	entity head;
	float distance;

	for(head = cq_worldcplist; head; head = head.cq_worldcpnext)
	{
		if (DIFF_TEAM(head, self))
		{
			distance = vlen(head.origin - org);
			if (distance > sradius)
				continue;
			navigation_routerating(head, ratingscale, 2000);
		}
	}
}

void havocbot_role_cq_offense()
{
	entity head;
	float owned;

	if(self.deadflag != DEAD_NO)
		return;

	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + random() * 10 + 20;

	// Count how many control points on team are owned.
	owned = 0;
	for(head = cq_worldcplist; head; head = head.cq_worldcpnext)
	{
		if ((SAME_TEAM(head, self)) && (head.cq_status == CP_CAPTURED))
			owned++;
	}

	// If only one left on team or if role has timed out then start trying to liberate control points.
	if ((owned == 0) || (time > self.havocbot_role_timeout))
	{
		dprint("changing role to liberating\n");
		self.havocbot_role = havocbot_role_cq_liberating;
		self.havocbot_role_timeout = 0;
		return;
	}

	if (time > self.bot_strategytime)
	{
		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;

		navigation_goalrating_start();
		havocbot_goalrating_items(10000, self.origin, 10000);
		havocbot_goalrating_enemypoints(20000, self.origin, 10000);
		havocbot_goalrating_defendpoints(9000, self.origin, 10000);
		//havocbot_goalrating_waypoints(1, self.origin, 1000);
		navigation_goalrating_end();
	}
}

void havocbot_role_cq_liberating()
{
	if(self.deadflag != DEAD_NO)
		return;

	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + random() * 10 + 20;

	if (time > self.havocbot_role_timeout)
	{
		dprint("changing role to offense\n");
		self.havocbot_role = havocbot_role_cq_offense;
		self.havocbot_role_timeout = 0;
		return;
	}

	if (time > self.bot_strategytime)
	{
		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;

		navigation_goalrating_start();
		havocbot_goalrating_items(8000, self.origin, 10000);
		havocbot_goalrating_enemyplayers(10000, self.origin, 10000);
		havocbot_goalrating_defendpoints(20000, self.origin, 10000);
		//havocbot_goalrating_waypoints(1, self.origin, 1000);
		navigation_goalrating_end();
	}
}


// =============
// Compatibility
// =============

void cq_Setup_Compat_dom()
{
	// if map already has control points, don't spawn more
	if(cq_worldcplist && (!cq_worldcplist.cq_compat || cq_worldcplist.cq_compat != COMPAT_DOM))
	{
		self.think = SUB_Remove;
		self.nextthink = time;
		return;
	}

	float redcp = 0, bluecp = 0, yellowcp = 0, pinkcp = 0;

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

	if(!redcp) { self.team = NUM_TEAM_1; }
	if(!bluecp) { self.team = NUM_TEAM_2; }
	if(!yellowcp && cq_teams >= 3) { self.team = NUM_TEAM_3; }
	if(!pinkcp && cq_teams >= 4) { self.team = NUM_TEAM_4; }

	self.cq_compat = COMPAT_DOM; // compatibility flag

	spawnfunc_conquest_controlpoint();
}

void cq_Setup_Compat_ons()
{
	// if map already has control points, don't spawn more
	if(cq_worldcplist && (!cq_worldcplist.cq_compat || cq_worldcplist.cq_compat != COMPAT_ONS))
	{
		self.think = SUB_Remove;
		self.nextthink = time;
		return;
	}

	// teams are already setup for onslaught

	self.cq_compat = COMPAT_ONS; // compatibility flag

	spawnfunc_conquest_controlpoint();
}


// ==============
// Hook Functions
// ==============

MUTATOR_HOOKFUNCTION(conquest_RemovePlayer)
{
	self.cq_deathloc = '0 0 0';
	return FALSE;
}

MUTATOR_HOOKFUNCTION(conquest_PlayerDies)
{
	frag_target.cq_deathloc = frag_target.origin;

	if ( autocvar_g_conquest_spawn_choose )
	if ( cq_Count_SelfControlPoints() > 1 )
		stuffcmd(self, "qc_cmd_cl hud clickradar\n");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(conquest_ResetMap)
{
	for(self = cq_worldcplist; self; self = self.cq_worldcpnext)
		self.reset(); // do this now as teams aren't setup in time for PlayerSpawn

	FOR_EACH_PLAYER(self)
		PutClientInServer();
	return FALSE;
}

MUTATOR_HOOKFUNCTION(conquest_PlayerSpawn)
{
	if ( autocvar_g_conquest_spawn_choose )
	if ( self.cq_spawn_by )
	if ( cq_Teleport(self,self.cq_spawn_by,autocvar_g_conquest_teleport_radius,FALSE) )
	{
		self.cq_spawn_by = world;
		return FALSE;
	}

	float random_target = !(autocvar_g_conquest_spawn_close_to_death), owned_count = cq_Count_SelfControlPoints();
	entity tmp_entity, closest_target = world;
	vector spawn_loc = self.cq_deathloc;

	// new joining player or round reset, don't bother checking
	//if(spawn_loc == '0 0 0') { return FALSE; }

	if(random_target) { RandomSelection_Init(); }

	for(tmp_entity = cq_worldcplist; tmp_entity; tmp_entity = tmp_entity.cq_worldcpnext)
	{
		if(SAME_TEAM(tmp_entity, self) || (!tmp_entity.team && !owned_count))
		if(tmp_entity.cq_status == CP_CAPTURED || !owned_count)
		if(random_target)
			RandomSelection_Add(tmp_entity, 0, string_null, 1, 1);
		else if(vlen(tmp_entity.origin - spawn_loc) <= vlen(closest_target.origin - spawn_loc) || closest_target == world)
			closest_target = tmp_entity;
	}

	if(random_target) { closest_target = RandomSelection_chosen_ent; }

	if(!closest_target)
	{
		for(tmp_entity = cq_worldcplist; tmp_entity; tmp_entity = tmp_entity.cq_worldcpnext)
		{
			if(SAME_TEAM(tmp_entity, self) || (!tmp_entity.team && !owned_count))
			if(tmp_entity.cq_status == CP_CAPTURED || !owned_count)
			{
				closest_target = tmp_entity;
				break;
			}
		}
	}

	if(closest_target)
	{
		float i;
		vector loc;
		for(i = 0; i < 10; ++i)
		{
			loc = closest_target.origin + '0 0 96';
			if(random() >= 0.5)
				loc += ('1 1 0' * random()) * 1024;
			else
				loc -= ('1 1 0' * random()) * 1024;
			tracebox(loc, PL_MIN, PL_MAX, loc, MOVE_NORMAL, self);
			if(trace_fraction == 1.0 && !trace_startsolid)
			{
				traceline(closest_target.origin, loc, MOVE_NOMONSTERS, closest_target); // double check to make sure we're not spawning outside the world
				if(trace_fraction == 1.0)
				{
					setorigin(self, loc);
					self.angles = normalize(loc - closest_target.origin);
					return FALSE;
				}
			}
		}
	}

	print("Warning: No spawns found for team ", ftos(self.team), "\n");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(conquest_SV_ParseClientCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return FALSE;

	if ( cmd_name == "cq_spawn" )
	{
		vector pos = self.origin;
		if(cmd_argc > 1)
			pos_x = stof(argv(1));
		if(cmd_argc > 2)
			pos_y = stof(argv(2));
		if(cmd_argc > 3)
			pos_z = stof(argv(3));

		if ( IS_PLAYER(self) )
		{
			if(!self.vehicle)
			if(!self.frozen)
			{
				entity source_point = cq_Nearest_ControlPoint(self.origin, autocvar_g_conquest_teleport_radius);

				if ( !source_point && self.health > 0 )
				{
					sprint(self, "\nYou need to be next to a control point\n");
					return 1;
				}


				entity closest_target = cq_Nearest_ControlPoint_2D(pos, autocvar_g_conquest_click_radius);

				if ( closest_target == world )
				{
					sprint(self, "\nNo control point found\n");
					return 1;
				}

				if ( self.health <= 0 )
				{
					self.cq_spawn_by = closest_target;
					self.respawn_flags = self.respawn_flags | RESPAWN_FORCE;
				}
				else
				{
					if ( source_point == closest_target )
					{
						sprint(self, "\nTeleporting to the same point\n");
						return 1;
					}

					if ( !cq_Teleport(self,closest_target,autocvar_g_conquest_teleport_radius,TRUE) )
						sprint(self, "\nUnable to teleport there\n");
				}

				return 1;
			}

			sprint(self, "\nNo teleportation for you\n");
		}

		return 1;
	}
	return 0;
}

MUTATOR_HOOKFUNCTION(conquest_PlayerUseKey)
{
	if(MUTATOR_RETURNVALUE || gameover) { return FALSE; }

	if((time > self.teleport_antispam) && (self.deadflag == DEAD_NO) && !self.vehicle && !self.frozen)
	{
		entity source_point = cq_Nearest_ControlPoint(self.origin, autocvar_g_conquest_teleport_radius);
		if ( source_point )
		{
			stuffcmd(self, "qc_cmd_cl hud clickradar\n");
			return TRUE;
		}
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(conquest_OnEntityPreSpawn)
{
	// onslaught support comes first, as it's most likely to have the best layout
	if(self.classname == "onslaught_generator" || self.classname == "onslaught_controlpoint")
	{
		entity cp = spawn(), oldself = self;
		cp.team = self.team;
		setorigin(cp, self.origin + '0 0 20');
		self = cp;
		droptofloor();
		InitializeEntity(cp, cq_Setup_Compat_ons, INITPRIO_FINDTARGET);
		self = oldself;
		return FALSE;
	}
	if(self.classname == "dom_controlpoint")
	{
		entity cp = spawn(), oldself = self;
		// domination doesn't use teams
		setorigin(cp, self.origin + '0 0 20');
		self = cp;
		droptofloor();
		InitializeEntity(cp, cq_Setup_Compat_dom, INITPRIO_FINDTARGET);
		self = oldself;
		return FALSE;
	}
	return FALSE;
}

MUTATOR_HOOKFUNCTION(conquest_BotRoles)
{
	self.havocbot_role = havocbot_role_cq_offense;
	return TRUE;
}

MUTATOR_HOOKFUNCTION(conquest_GetTeamCount)
{
	ret_float = cq_teams;
	return FALSE;
}

void cq_ScoreRules(float teams)
{
	ScoreRules_basics(teams, SFL_SORT_PRIO_PRIMARY, 0, TRUE);

	ScoreInfo_SetLabel_TeamScore(ST_CONQUEST_ROUNDS, "rounds", SFL_SORT_PRIO_PRIMARY);
	ScoreInfo_SetLabel_PlayerScore(SP_CONQUEST_LIBERATED, "liberated", 0);
	ScoreInfo_SetLabel_PlayerScore(SP_CONQUEST_CAPTURED, "captured", 0);

	ScoreRules_basics_end();
}

void cq_DelayedInit()
{
	cq_teams = autocvar_g_conquest_teams;
	if(autocvar_g_conquest_teams_override >= 2) { cq_teams = autocvar_g_conquest_teams_override; }
	cq_teams = bound(2, cq_teams, 4);
	cq_ScoreRules(cq_teams);

	round_handler_Spawn(cq_CheckTeams, cq_CheckWinner, func_null);
	round_handler_Init(5, autocvar_g_conquest_warmup, autocvar_g_conquest_round_timelimit);
}

MUTATOR_DEFINITION(gamemode_conquest)
{
	//precache_model("models/conquest/spawn.md3");
	//precache_model("models/conquest/flag.md3");
	//precache_model("models/conquest/stand.md3");

	MUTATOR_HOOK(MakePlayerObserver, conquest_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientDisconnect, conquest_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, conquest_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, conquest_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(reset_map_global, conquest_ResetMap, CBC_ORDER_ANY);
	MUTATOR_HOOK(SV_ParseClientCommand, conquest_SV_ParseClientCommand, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerUseKey, conquest_PlayerUseKey, CBC_ORDER_ANY);
	MUTATOR_HOOK(OnEntityPreSpawn, conquest_OnEntityPreSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(HavocBot_ChooseRole, conquest_BotRoles, CBC_ORDER_ANY);
	MUTATOR_HOOK(GetTeamCount, conquest_GetTeamCount, CBC_ORDER_ANY);


	MUTATOR_ONADD
	{
		if(time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");

		InitializeEntity(world, cq_DelayedInit, INITPRIO_GAMETYPE);
	}

	MUTATOR_ONREMOVE
	{
		error("This is a game type and it cannot be removed at runtime.");
	}

	return 0;
}
