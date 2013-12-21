float total_players;
float redalive, bluealive, yellowalive, pinkalive;
float inf_teams;
float allowed_to_spawn;
.float inf_realteam;
.float inf_nextteam;

void INF_count_alive_players()
{
	entity e;
	total_players = redalive = bluealive = yellowalive = pinkalive = 0;
	FOR_EACH_PLAYER(e)
	{
		++total_players;
		redalive += (e.team == NUM_TEAM_1);
		bluealive += (e.team == NUM_TEAM_2);
		yellowalive += (e.team == NUM_TEAM_3);
		pinkalive += (e.team == NUM_TEAM_4);
	}
}

float INF_GetWinnerTeam()
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

#define INF_ALIVE_TEAMS() ((redalive > 0) + (bluealive > 0) + (yellowalive > 0) + (pinkalive > 0))
#define INF_ALIVE_TEAMS_OK() (INF_ALIVE_TEAMS() == inf_teams)
float INF_CheckWinner()
{
	entity e;
	if(round_handler_GetEndTime() > 0 && round_handler_GetEndTime() - time <= 0)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_OVER);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_OVER);
		allowed_to_spawn = FALSE;
		round_handler_Init(5, autocvar_g_infection_warmup, autocvar_g_infection_round_timelimit);
		FOR_EACH_PLAYER(e)
			nades_Clear(e);
		return 1;
	}

	INF_count_alive_players();
	if(INF_ALIVE_TEAMS() > 1)
		return 0;

	float winner_team = INF_GetWinnerTeam();
	if(winner_team > 0)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, APP_TEAM_NUM_4(winner_team, CENTER_ROUND_TEAM_WIN_));
		Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_NUM_4(winner_team, INFO_ROUND_TEAM_WIN_));
	
		if(TeamScore_AddToTeam(winner_team, ST_INF_ROUNDS, 0) + 1 >= autocvar_fraglimit)
		FOR_EACH_PLAYER(e) 
			MoveToTeam(e, e.inf_realteam, 8);

		TeamScore_AddToTeam(winner_team, ST_INF_ROUNDS, +1);
	}
	else if(winner_team == -1)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_TIED);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_TIED);
	}

	allowed_to_spawn = FALSE;
	round_handler_Init(5, autocvar_g_infection_warmup, autocvar_g_infection_round_timelimit);
	
	FOR_EACH_PLAYER(e)
		nades_Clear(e);

	return 1;
}

void INF_RoundStart()
{
	allowed_to_spawn = warmup_stage;

	entity head;
	FOR_EACH_PLAYER(head)
		head.inf_realteam = head.team;
}

float prev_total_players;
float INF_CheckTeams()
{
	allowed_to_spawn = TRUE;
	INF_count_alive_players();
	if(INF_ALIVE_TEAMS_OK())
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
		if(inf_teams >= 3) { if(!yellowalive) p3 = NUM_TEAM_3; } else p3 = 1;
		if(inf_teams >= 4) { if(!pinkalive) p4 = NUM_TEAM_4; } else p4 = 1;
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_MISSING_TEAMS, p1, p2, p3, p4);
		prev_total_players = total_players;
	}
	return 0;
}

MUTATOR_HOOKFUNCTION(inf_RemovePlayer)
{
	self.inf_realteam = 0;
	self.inf_nextteam = 0;
	return FALSE;
}

MUTATOR_HOOKFUNCTION(inf_PlayerSpawn)
{
	if(self.inf_nextteam)
	{
		MoveToTeam(self, self.inf_nextteam, 8);
		self.inf_nextteam = 0;
	}
	
	if(!self.inf_realteam)
	if(round_handler_IsRoundStarted())
		self.inf_realteam = self.team;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(inf_PlayerDies)
{
	if(IS_PLAYER(frag_attacker) && DIFF_TEAM(frag_attacker, frag_target))
	{
		Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_NUM_4(frag_attacker.team, INFO_INFECTION_INFECTED), frag_target.netname);
		Send_Notification(NOTIF_ONE, frag_target, MSG_CENTER, APP_TEAM_NUM_4(frag_attacker.team, CENTER_INFECTION_INFECTED));
		frag_target.inf_nextteam = frag_attacker.team;
		frag_target.respawn_flags |= RESPAWN_FORCE;
		
		PlayerScore_Add(frag_target, SP_SCORE, -1);
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(inf_ResetMap)
{
	FOR_EACH_PLAYER(self)
	{
		self.inf_nextteam = 0; // just incase
		if(self.inf_realteam && self.inf_realteam != self.team)
			MoveToTeam(self, self.inf_realteam, 8);
		PutClientInServer(); // player re-spawns on new team?
	}
	
	FOR_EACH_SPEC(self) if(IS_BOT_CLIENT(self))
	{
		if(self.bot_forced_team==1)
			self.team = NUM_TEAM_1;
		else if(self.bot_forced_team==2)
			self.team = NUM_TEAM_2;
		else if(self.bot_forced_team==3)
			self.team = NUM_TEAM_3;
		else if(self.bot_forced_team==4)
			self.team = NUM_TEAM_4;
		else
			JoinBestTeam(self, FALSE, TRUE);
			
		PutClientInServer();
	}
	
	return TRUE;
}

MUTATOR_HOOKFUNCTION(inf_GetTeamCount)
{
	ret_float = inf_teams;
	return TRUE;
}

MUTATOR_HOOKFUNCTION(inf_ForbidPlayerScore_Clear)
{
	return TRUE;
}

void inf_Initialize()
{
	allowed_to_spawn = TRUE;

	inf_teams = bound(2, autocvar_g_infection_teams, 4);
	ScoreRules_inf(inf_teams);

	round_handler_Spawn(INF_CheckTeams, INF_CheckWinner, INF_RoundStart);
	round_handler_Init(5, autocvar_g_infection_warmup, autocvar_g_infection_round_timelimit);
}

MUTATOR_DEFINITION(gamemode_infection)
{
	MUTATOR_HOOK(MakePlayerObserver, inf_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, inf_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientDisconnect, inf_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, inf_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(reset_map_players, inf_ResetMap, CBC_ORDER_ANY);
	MUTATOR_HOOK(GetTeamCount, inf_GetTeamCount, CBC_ORDER_ANY);
	MUTATOR_HOOK(ForbidPlayerScore_Clear, inf_ForbidPlayerScore_Clear, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		if(time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");
		inf_Initialize();
	}

	MUTATOR_ONREMOVE
	{
		print("This is a game type and it cannot be removed at runtime.");
		return -1;
	}

	return FALSE;
}
