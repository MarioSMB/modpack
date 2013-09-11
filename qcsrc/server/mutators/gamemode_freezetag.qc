.float freezetag_frozen_time;
.float freezetag_frozen_timeout;
.float freezetag_revive_progress;
.float revivals_row;

#define ICE_MAX_ALPHA 1
#define ICE_MIN_ALPHA 0.1
float freezetag_teams;

void freezetag_count_alive_players()
{
	entity e;
	total_players = redalive = bluealive = yellowalive = pinkalive = 0;
	FOR_EACH_PLAYER(e) {
		if(e.team == NUM_TEAM_1 && e.health >= 1)
		{
			++total_players;
			if (e.frozen != 1) ++redalive;
		}
		else if(e.team == NUM_TEAM_2 && e.health >= 1)
		{
			++total_players;
			if (e.frozen != 1) ++bluealive;
		}
		else if(e.team == NUM_TEAM_3 && e.health >= 1)
		{
			++total_players;
			if (e.frozen != 1) ++yellowalive;
		}
		else if(e.team == NUM_TEAM_4 && e.health >= 1)
		{
			++total_players;
			if (e.frozen != 1) ++pinkalive;
		}
	}
	FOR_EACH_REALCLIENT(e) {
		e.redalive_stat = redalive;
		e.bluealive_stat = bluealive;
		e.yellowalive_stat = yellowalive;
		e.pinkalive_stat = pinkalive;
	}
}
#define FREEZETAG_ALIVE_TEAMS() ((redalive > 0) + (bluealive > 0) + (yellowalive > 0) + (pinkalive > 0))
#define FREEZETAG_ALIVE_TEAMS_OK() (FREEZETAG_ALIVE_TEAMS() == freezetag_teams)

float prev_total_players;
float freezetag_CheckTeams()
{
	if(FREEZETAG_ALIVE_TEAMS_OK())
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
		if(freezetag_teams >= 3)
		if(!yellowalive) p3 = NUM_TEAM_3;
		if(freezetag_teams >= 4)
		if(!pinkalive) p4 = NUM_TEAM_4;
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_MISSING_TEAMS, p1, p2, p3, p4);
		prev_total_players = total_players;
	}
	return 0;
}

float freezetag_getWinnerTeam()
{
	float winner_team = 0;
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

float freezetag_CheckWinner()
{
	entity e;
	if(round_handler_GetEndTime() > 0 && round_handler_GetEndTime() - time <= 0)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_OVER);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_OVER);
		FOR_EACH_PLAYER(e)
			e.freezetag_frozen_timeout = 0;
		round_handler_Init(5, autocvar_g_freezetag_warmup, autocvar_g_freezetag_round_timelimit);
		return 1;
	}

	if(FREEZETAG_ALIVE_TEAMS() > 1)
		return 0;

	float winner_team;
	winner_team = freezetag_getWinnerTeam();
	if(winner_team > 0)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, APP_TEAM_NUM_4(winner_team, CENTER_ROUND_TEAM_WIN_));
		Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_NUM_4(winner_team, INFO_ROUND_TEAM_WIN_));
		TeamScore_AddToTeam(winner_team, ST_SCORE, +1);
	}
	else if(winner_team == -1)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_TIED);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_TIED);
	}

	FOR_EACH_PLAYER(e)
		e.freezetag_frozen_timeout = 0;
	round_handler_Init(5, autocvar_g_freezetag_warmup, autocvar_g_freezetag_round_timelimit);
	return 1;
}

void freezetag_Add_Score(entity attacker)
{
	if(attacker == self)
	{
		// you froze your own dumb self
		// counted as "suicide" already
		PlayerScore_Add(self, SP_SCORE, -1);
	}
	else if(IS_PLAYER(attacker))
	{
		// got frozen by an enemy
		// counted as "kill" and "death" already
		PlayerScore_Add(self, SP_SCORE, -1);
		PlayerScore_Add(attacker, SP_SCORE, +1);
	}
	// else nothing - got frozen by the game type rules themselves
}

void freezetag_Freeze(entity attacker)
{
	if(self.frozen)
		return;
		
	if(autocvar_g_freezetag_frozen_maxtime > 0)
		self.freezetag_frozen_timeout = time + autocvar_g_freezetag_frozen_maxtime;
	
	self.revivals_row = 0;
	Freeze(self, 0, 1, TRUE);
	
	freezetag_count_alive_players();

	freezetag_Add_Score(attacker);
}

void freezetag_Unfreeze(entity attacker)
{
	self.freezetag_frozen_time = 0;
	self.freezetag_frozen_timeout = 0;
	
	Unfreeze(self);
}

// ================
// Bot player logic
// ================

void() havocbot_role_ft_freeing;
void() havocbot_role_ft_offense;

void havocbot_goalrating_freeplayers(float ratingscale, vector org, float sradius)
{
	entity head;
	float distance;

	FOR_EACH_PLAYER(head)
	{
		if ((head != self) && (head.team == self.team))
		{
			if (head.frozen == 1)
			{
				distance = vlen(head.origin - org);
				if (distance > sradius)
					continue;
				navigation_routerating(head, ratingscale, 2000);
			}
			else
			{
				// If teamate is not frozen still seek them out as fight better
				// in a group.
				navigation_routerating(head, ratingscale/3, 2000);
			}
		}
	}
}

void havocbot_role_ft_offense()
{
	entity head;
	float unfrozen;

	if(self.deadflag != DEAD_NO)
		return;

	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + random() * 10 + 20;

	// Count how many players on team are unfrozen.
	unfrozen = 0;
	FOR_EACH_PLAYER(head)
	{
		if ((head.team == self.team) && (head.frozen != 1))
			unfrozen++;
	}

	// If only one left on team or if role has timed out then start trying to free players.
	if (((unfrozen == 0) && (!self.frozen)) || (time > self.havocbot_role_timeout))
	{
		dprint("changing role to freeing\n");
		self.havocbot_role = havocbot_role_ft_freeing;
		self.havocbot_role_timeout = 0;
		return;
	}

	if (time > self.bot_strategytime)
	{
		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;

		navigation_goalrating_start();
		havocbot_goalrating_items(10000, self.origin, 10000);
		havocbot_goalrating_enemyplayers(20000, self.origin, 10000);
		havocbot_goalrating_freeplayers(9000, self.origin, 10000);
		//havocbot_goalrating_waypoints(1, self.origin, 1000);
		navigation_goalrating_end();
	}
}

void havocbot_role_ft_freeing()
{
	if(self.deadflag != DEAD_NO)
		return;

	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + random() * 10 + 20;

	if (time > self.havocbot_role_timeout)
	{
		dprint("changing role to offense\n");
		self.havocbot_role = havocbot_role_ft_offense;
		self.havocbot_role_timeout = 0;
		return;
	}

	if (time > self.bot_strategytime)
	{
		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;

		navigation_goalrating_start();
		havocbot_goalrating_items(8000, self.origin, 10000);
		havocbot_goalrating_enemyplayers(10000, self.origin, 10000);
		havocbot_goalrating_freeplayers(20000, self.origin, 10000);
		//havocbot_goalrating_waypoints(1, self.origin, 1000);
		navigation_goalrating_end();
	}
}


// ==============
// Hook Functions
// ==============

MUTATOR_HOOKFUNCTION(freezetag_RemovePlayer)
{
	self.health = 0; // neccessary to update correctly alive stats
	self.revivals_row = 0;
	freezetag_Unfreeze(world);
	freezetag_count_alive_players();
	return 1;
}

MUTATOR_HOOKFUNCTION(freezetag_PlayerDies)
{
	if(round_handler_IsActive())
	if(round_handler_CountdownRunning())
	{
		if(self.frozen)
			freezetag_Unfreeze(world);
		freezetag_count_alive_players();
		return 1; // let the player die so that he can respawn whenever he wants
	}

	// Cases DEATH_TEAMCHANGE and DEATH_AUTOTEAMCHANGE are needed to fix a bug whe
	// you succeed changing team through the menu: you both really die (gibbing) and get frozen
	if(ITEM_DAMAGE_NEEDKILL(frag_deathtype)
		|| frag_deathtype == DEATH_TEAMCHANGE || frag_deathtype == DEATH_AUTOTEAMCHANGE)
	{
		// let the player die, he will be automatically frozen when he respawns
		if(self.frozen != 1)
		{
			freezetag_Add_Score(frag_attacker);
			freezetag_count_alive_players();
		}
		else
			freezetag_Unfreeze(world); // remove ice
		self.health = 0; // Unfreeze resets health
		self.freezetag_frozen_timeout = -2; // freeze on respawn
		return 1;
	}

	if(self.frozen)
		return 1;
		
	if(g_minstagib)
		frag_target.ammo_cells = start_ammo_cells; // we need more ammo in minstagib, otherwise the player will defrost & die again

	freezetag_Freeze(frag_attacker);

	if(frag_attacker == frag_target || frag_attacker == world)
	{
		if(IS_PLAYER(frag_target))
			Send_Notification(NOTIF_ONE, frag_target, MSG_CENTER, CENTER_FREEZETAG_SELF);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_FREEZETAG_SELF, frag_target.netname);
	}
	else
	{
		if(IS_PLAYER(frag_target))
			Send_Notification(NOTIF_ONE, frag_target, MSG_CENTER, CENTER_FREEZETAG_FROZEN, frag_attacker.netname);
		if(IS_PLAYER(frag_attacker))
			Send_Notification(NOTIF_ONE, frag_attacker, MSG_CENTER, CENTER_FREEZETAG_FREEZE, frag_target.netname);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_FREEZETAG_FREEZE, frag_target.netname, frag_attacker.netname);
	}

	return 1;
}

MUTATOR_HOOKFUNCTION(freezetag_PlayerSpawn)
{
	if(self.freezetag_frozen_timeout == -1) // if PlayerSpawn is called by reset_map_players
		return 1; // do nothing, round is starting right now

	if(self.freezetag_frozen_timeout == -2) // player was dead
	{
		freezetag_Freeze(world);
		return 1;
	}

	freezetag_count_alive_players();

	if(round_handler_IsActive())
	if(round_handler_IsRoundStarted())
	{
		Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_FREEZETAG_SPAWN_LATE);
		freezetag_Freeze(world);
	}

	return 1;
}

MUTATOR_HOOKFUNCTION(freezetag_reset_map_players)
{
	FOR_EACH_PLAYER(self)
	{
		if (self.frozen)
			freezetag_Unfreeze(world);
		self.freezetag_frozen_timeout = -1;
		PutClientInServer();
		self.freezetag_frozen_timeout = 0;
	}
	freezetag_count_alive_players();
	return 1;
}

MUTATOR_HOOKFUNCTION(freezetag_GiveFragsForKill)
{
	frag_score = 0; // no frags counted in Freeze Tag
	return 1;
}

.float reviving; // temp var
MUTATOR_HOOKFUNCTION(freezetag_PlayerPreThink)
{
	float n;

	if(gameover)
		return 1;

	if(self.frozen == 1)
	{
		// keep health = 1
		self.pauseregen_finished = time + autocvar_g_balance_pause_health_regen;
	}

	if(round_handler_IsActive())
	if(!round_handler_IsRoundStarted())
		return 1;

	entity o;
	o = world;
	if(self.freezetag_frozen_timeout > 0 && time < self.freezetag_frozen_timeout)
		self.iceblock.alpha = ICE_MIN_ALPHA + (ICE_MAX_ALPHA - ICE_MIN_ALPHA) * (self.freezetag_frozen_timeout - time) / (self.freezetag_frozen_timeout - self.freezetag_frozen_time);

	if(self.freezetag_frozen_timeout > 0 && time >= self.freezetag_frozen_timeout)
		n = -1;
	else
	{
		vector revive_extra_size = '1 1 1' * autocvar_g_freezetag_revive_extra_size;
		n = 0;
		FOR_EACH_PLAYER(other) if(self != other)
		{
			if(other.frozen == 0)
			{
				if(!IsDifferentTeam(other, self))
				{
					if(boxesoverlap(self.absmin - revive_extra_size, self.absmax + revive_extra_size, other.absmin, other.absmax))
					{
						if(!o)
							o = other;
						if(self.frozen == 1)
							other.reviving = TRUE;
						++n;
					}
				}
			}
		}
	}

	if(n && self.frozen == 1) // OK, there is at least one teammate reviving us
	{
		self.revive_progress = bound(0, self.revive_progress + frametime * max(1/60, autocvar_g_freezetag_revive_speed), 1);
		self.health = max(1, self.revive_progress * autocvar_g_balance_health_start);

		if(self.revive_progress >= 1)
		{
			freezetag_Unfreeze(self);
			freezetag_count_alive_players();

			if(n == -1)
			{
				Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_FREEZETAG_AUTO_REVIVED, autocvar_g_freezetag_frozen_maxtime);
				Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_FREEZETAG_AUTO_REVIVED, self.netname, autocvar_g_freezetag_frozen_maxtime);
				return 1;
			}

			// EVERY team mate nearby gets a point (even if multiple!)
			FOR_EACH_PLAYER(other)
			{
				if(other.reviving)
				{
					PlayerScore_Add(other, SP_FREEZETAG_REVIVALS, +1);
					PlayerScore_Add(other, SP_SCORE, +1);
					
					if ( autocvar_g_nades_napalm_bonus_freezetag )
					{
						other.revivals_row++;
						if ( other.revivals_row >= autocvar_g_nades_napalm_bonus_freezetag )
						{
							other.revivals_row = 0;
							nades_GiveBonus(other);
						}
					}
				}
			}

			Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_FREEZETAG_REVIVED, o.netname);
			Send_Notification(NOTIF_ONE, o, MSG_CENTER, CENTER_FREEZETAG_REVIVE, self.netname);
			Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_FREEZETAG_REVIVED, self.netname, o.netname);
		}

		FOR_EACH_PLAYER(other)
		{
			if(other.reviving)
			{
				other.revive_progress = self.revive_progress;
				other.reviving = FALSE;
			}
		}
	}
	else if(!n && self.frozen == 1) // only if no teammate is nearby will we reset
	{
		self.revive_progress = bound(0, self.revive_progress - frametime * autocvar_g_freezetag_revive_clearspeed, 1);
		self.health = max(1, self.revive_progress * autocvar_g_balance_health_start);
	}
	else if(!n && !self.frozen)
	{
		self.revive_progress = 0; // thawing nobody
	}

	return 1;
}

MUTATOR_HOOKFUNCTION(freezetag_PlayerDamage_Calculate)
{
	if(frag_target.frozen == 1 && frag_deathtype != DEATH_HURTTRIGGER)
	{
		if(autocvar_g_freezetag_revive_falldamage > 0)
		if(frag_deathtype == DEATH_FALL)
		if(frag_damage >= autocvar_g_freezetag_revive_falldamage)
		{
			freezetag_Unfreeze(frag_target);
			frag_target.health = autocvar_g_freezetag_revive_falldamage_health;
			pointparticles(particleeffectnum("iceorglass"), frag_target.origin, '0 0 0', 3);
			Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_FREEZETAG_REVIVED_FALL, frag_target.netname);
			Send_Notification(NOTIF_ONE, frag_target, MSG_CENTER, CENTER_FREEZETAG_REVIVE_FALL);
		}
	
		frag_damage = 0;
		frag_force = frag_force * autocvar_g_freezetag_frozen_force;
	}
	return 1;
}

MUTATOR_HOOKFUNCTION(freezetag_BotRoles)
{
	if not(self.deadflag)
	{
		if (random() < 0.5)
			self.havocbot_role = havocbot_role_ft_freeing;
		else
			self.havocbot_role = havocbot_role_ft_offense;
	}

	return TRUE;
}

MUTATOR_HOOKFUNCTION(freezetag_GetTeamCount)
{
	freezetag_teams = autocvar_g_freezetag_teams_override;
	if(freezetag_teams < 2)
		freezetag_teams = autocvar_g_freezetag_teams;
	freezetag_teams = bound(2, freezetag_teams, 4);
	ret_float = freezetag_teams;
	return 0;
}

void freezetag_Initialize()
{
	precache_model("models/ice/ice.md3");

	freezetag_teams = autocvar_g_freezetag_teams_override;
	if(freezetag_teams < 2)
		freezetag_teams = autocvar_g_freezetag_teams;
	freezetag_teams = bound(2, freezetag_teams, 4);
	ScoreRules_freezetag(freezetag_teams);

	round_handler_Spawn(freezetag_CheckTeams, freezetag_CheckWinner, func_null);
	round_handler_Init(5, autocvar_g_freezetag_warmup, autocvar_g_freezetag_round_timelimit);

	addstat(STAT_REDALIVE, AS_INT, redalive_stat);
	addstat(STAT_BLUEALIVE, AS_INT, bluealive_stat);
	addstat(STAT_YELLOWALIVE, AS_INT, yellowalive_stat);
	addstat(STAT_PINKALIVE, AS_INT, pinkalive_stat);
}

MUTATOR_DEFINITION(gamemode_freezetag)
{
	MUTATOR_HOOK(MakePlayerObserver, freezetag_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientDisconnect, freezetag_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, freezetag_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, freezetag_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(reset_map_players, freezetag_reset_map_players, CBC_ORDER_ANY);
	MUTATOR_HOOK(GiveFragsForKill, freezetag_GiveFragsForKill, CBC_ORDER_FIRST);
	MUTATOR_HOOK(PlayerPreThink, freezetag_PlayerPreThink, CBC_ORDER_FIRST);
	MUTATOR_HOOK(PlayerDamage_Calculate, freezetag_PlayerDamage_Calculate, CBC_ORDER_ANY);
	MUTATOR_HOOK(HavocBot_ChooseRule, freezetag_BotRoles, CBC_ORDER_ANY);
	MUTATOR_HOOK(GetTeamCount, freezetag_GetTeamCount, CBC_ORDER_EXCLUSIVE);

	MUTATOR_ONADD
	{
		if(time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");
		freezetag_Initialize();
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		// we actually cannot roll back freezetag_Initialize here
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
