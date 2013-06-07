float total_players;
float redalive, bluealive, yellowalive, pinkalive;
.float redalive_stat, bluealive_stat, yellowalive_stat, pinkalive_stat;
float ca_teams;
float allowed_to_spawn;

void CA_count_alive_players()
{
	entity e;
	total_players = redalive = bluealive = yellowalive = pinkalive = 0;
	FOR_EACH_PLAYER(e) {
		if(e.team == NUM_TEAM_1)
		{
			++total_players;
			if (e.health >= 1) ++redalive;
		}
		else if(e.team == NUM_TEAM_2)
		{
			++total_players;
			if (e.health >= 1) ++bluealive;
		}
		else if(e.team == NUM_TEAM_3)
		{
			++total_players;
			if (e.health >= 1) ++yellowalive;
		}
		else if(e.team == NUM_TEAM_4)
		{
			++total_players;
			if (e.health >= 1) ++pinkalive;
		}
	}
	FOR_EACH_REALCLIENT(e) {
		e.redalive_stat = redalive;
		e.bluealive_stat = bluealive;
		e.yellowalive_stat = yellowalive;
		e.pinkalive_stat = pinkalive;
	}
}

float CA_GetWinnerTeam()
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

#define CA_ALIVE_TEAMS() ((redalive > 0) + (bluealive > 0) + (yellowalive > 0) + (pinkalive > 0))
#define CA_ALIVE_TEAMS_OK() (CA_ALIVE_TEAMS() == ca_teams)
float CA_CheckWinner()
{
	if(round_handler_GetEndTime() > 0 && round_handler_GetEndTime() - time <= 0)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_OVER);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_OVER);
		allowed_to_spawn = FALSE;
		round_handler_Init(5, autocvar_g_ca_warmup, autocvar_g_ca_round_timelimit);
		return 1;
	}

	CA_count_alive_players();
	if(CA_ALIVE_TEAMS() > 1)
		return 0;

	float winner_team = CA_GetWinnerTeam();
	if(winner_team > 0)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, APP_TEAM_NUM_4(winner_team, CENTER_ROUND_TEAM_WIN_));
		Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_NUM_4(winner_team, INFO_ROUND_TEAM_WIN_));
		TeamScore_AddToTeam(winner_team, ST_CA_ROUNDS, +1);
	}
	else if(winner_team == -1)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_TIED);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_TIED);
	}

	allowed_to_spawn = FALSE;
	round_handler_Init(5, autocvar_g_ca_warmup, autocvar_g_ca_round_timelimit);
	return 1;
}

void CA_RoundStart()
{
	if(inWarmupStage)
		allowed_to_spawn = TRUE;
	else
		allowed_to_spawn = FALSE;
}

float prev_total_players;
float CA_CheckTeams()
{
	allowed_to_spawn = TRUE;
	CA_count_alive_players();
	if(CA_ALIVE_TEAMS_OK())
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
		if(ca_teams >= 3)
		if(!yellowalive) p3 = NUM_TEAM_3;
		if(ca_teams >= 4)
		if(!pinkalive) p4 = NUM_TEAM_4;
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_MISSING_TEAMS, p1, p2, p3, p4);
		prev_total_players = total_players;
	}
	return 0;
}

MUTATOR_HOOKFUNCTION(ca_PlayerSpawn)
{
	self.caplayer = 1;
	return 1;
}

MUTATOR_HOOKFUNCTION(ca_PutClientInServer)
{
	if(!allowed_to_spawn)
	{
		self.classname = "observer";
		if(!self.caplayer)
		{
			self.caplayer = 0.5;
			if(IS_REAL_CLIENT(self))
				sprint(self, "You will join the game in the next round.\n");
		}
	}
	return 1;
}

MUTATOR_HOOKFUNCTION(ca_reset_map_players)
{
	FOR_EACH_CLIENT(self)
	{
		if(self.caplayer)
		{
			self.classname = "player";
			self.caplayer = 1;
			PutClientInServer();
		}
	}
	return 1;
}

MUTATOR_HOOKFUNCTION(ca_ClientConnect)
{
	self.classname = "observer";
	return 1;
}

MUTATOR_HOOKFUNCTION(ca_reset_map_global)
{
	allowed_to_spawn = TRUE;
	return 1;
}

MUTATOR_HOOKFUNCTION(ca_GetTeamCount)
{
	ca_teams = autocvar_g_ca_teams_override;
	if(ca_teams < 2)
		ca_teams = autocvar_g_ca_teams;
	ca_teams = bound(2, ca_teams, 4);
	ret_float = ca_teams;
	return 1;
}

MUTATOR_HOOKFUNCTION(ca_PlayerDies)
{
	if(!allowed_to_spawn)
		self.respawn_flags =  RESPAWN_SILENT;
	return 1;
}

MUTATOR_HOOKFUNCTION(ca_ForbidPlayerScore_Clear)
{
	return 1;
}

MUTATOR_HOOKFUNCTION(ca_MakePlayerObserver)
{
	if(self.killindicator_teamchange == -2)
		self.caplayer = 0;
	if(self.caplayer)
		self.frags = FRAGS_LMS_LOSER;
	return 1;
}

MUTATOR_HOOKFUNCTION(ca_ForbidThrowCurrentWeapon)
{
	return 1;
}

MUTATOR_HOOKFUNCTION(ca_GiveFragsForKill)
{
	frag_score = 0; // score will be given to the winner team when the round ends
	return 1;
}

MUTATOR_HOOKFUNCTION(ca_SetStartItems)
{
	start_health = cvar("g_lms_start_health");
	start_armorvalue = cvar("g_lms_start_armor");

	start_ammo_shells = cvar("g_lms_start_ammo_shells");
	start_ammo_nails = cvar("g_lms_start_ammo_nails");
	start_ammo_rockets = cvar("g_lms_start_ammo_rockets");
	start_ammo_cells = cvar("g_lms_start_ammo_cells");
	start_ammo_fuel = cvar("g_lms_start_ammo_fuel");
	
	start_items &~= IT_UNLIMITED_AMMO;

	return 0;
}

// scoreboard setup
void ca_ScoreRules()
{
	ScoreRules_basics(2, SFL_SORT_PRIO_PRIMARY, 0, TRUE);
	ScoreInfo_SetLabel_TeamScore  (ST_CA_ROUNDS,    "rounds",    SFL_SORT_PRIO_PRIMARY);
	ScoreRules_basics_end();
}

void ca_DelayedInit() // Do this check with a delay so we can wait for teams to be set up.
{
	ca_ScoreRules();
}

void ca_Initialize()
{
	allowed_to_spawn = TRUE;

	round_handler_Spawn(CA_CheckTeams, CA_CheckWinner, CA_RoundStart);
	round_handler_Init(5, autocvar_g_ca_warmup, autocvar_g_ca_round_timelimit);

	addstat(STAT_REDALIVE, AS_INT, redalive_stat);
	addstat(STAT_BLUEALIVE, AS_INT, bluealive_stat);
	addstat(STAT_YELLOWALIVE, AS_INT, yellowalive_stat);
	addstat(STAT_PINKALIVE, AS_INT, pinkalive_stat);

	InitializeEntity(world, ca_DelayedInit, INITPRIO_GAMETYPE);
}

MUTATOR_DEFINITION(gamemode_ca)
{
	MUTATOR_HOOK(PlayerSpawn, ca_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PutClientInServer, ca_PutClientInServer, CBC_ORDER_ANY);
	MUTATOR_HOOK(MakePlayerObserver, ca_MakePlayerObserver, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientConnect, ca_ClientConnect, CBC_ORDER_ANY);
	MUTATOR_HOOK(reset_map_global, ca_reset_map_global, CBC_ORDER_ANY);
	MUTATOR_HOOK(reset_map_players, ca_reset_map_players, CBC_ORDER_ANY);
	MUTATOR_HOOK(GetTeamCount, ca_GetTeamCount, CBC_ORDER_EXCLUSIVE);
	MUTATOR_HOOK(PlayerDies, ca_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(ForbidPlayerScore_Clear, ca_ForbidPlayerScore_Clear, CBC_ORDER_ANY);
	MUTATOR_HOOK(ForbidThrowCurrentWeapon, ca_ForbidThrowCurrentWeapon, CBC_ORDER_ANY);
	MUTATOR_HOOK(GiveFragsForKill, ca_GiveFragsForKill, CBC_ORDER_FIRST);
	MUTATOR_HOOK(SetStartItems, ca_SetStartItems, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		if(time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");
		ca_Initialize();
	}

	MUTATOR_ONREMOVE
	{
		print("This is a game type and it cannot be removed at runtime.");
		return -1;
	}

	return 0;
}
