void INF_count_alive_players()
{
	entity e;
    float i;
	for(i = 1; i <= infection_teams; ++i) { aliveplayers[i] = 0; }
	FOR_EACH_PLAYER(e)
	{
		++total_players;

		if(e.health > 0)
			aliveplayers[e.inf_team] += 1;
	}
}

void INF_count_survivors()
{
	entity e;
    float i;
	for(i = 1; i <= infection_teams; ++i) { aliveplayers[i] = 0; }
	FOR_EACH_PLAYER(e)
	{
		++total_players;
		if(e.inf_realteam == e.inf_team)
		//if(e.health > 0) // TODO: check if this is needed?
			aliveplayers[e.inf_realteam] += 1;
	}
}

float inf_alive_teams()
{
	float total_alive = 0;
	float i;
	for(i = 1; i <= infection_teams; ++i)
	if(aliveplayers[i] >= 1)
		total_alive += 1;
		
	return total_alive;
}
#define INF_ALIVE_TEAMS_OK() (inf_alive_teams() == infection_teams)

float Infection_CheckWinner()
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
	
	INF_count_survivors();
	if(inf_alive_teams() > 1)
		return 0;
		
	float winner_team = 0;

	FOR_EACH_CLIENT(e)
	{
		if(e.inf_realteam == e.inf_team)
		if(IS_PLAYER(e))
		if(e.inf_nextteam == 0)
			winner_team = e.inf_realteam;
	}

	if(winner_team)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_INFECTION_WIN);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_INFECTION_WIN);
		FOR_EACH_CLIENT(e)
		{
			if(e.inf_team == e.inf_realteam)
			if(e.inf_realteam == winner_team)
			{
				PlayerScore_Add(e, SP_INF_ROUNDS, +1);
				UpdateFrags(e, +1);
			}
		}
	}
	else
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_TIED);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_TIED);
	}

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
	{
		head.inf_realteam = head.inf_team;
		head.inf_nextteam = 0;
	}
}

float INF_CheckTeams()
{
	allowed_to_spawn = TRUE;
	INF_count_alive_players();
	if(INF_ALIVE_TEAMS_OK())
	{
		if(prev_total_players > 0)
			Kill_Notification(NOTIF_ALL, world, MSG_CENTER_CPID, CPID_MISSING_PLAYERS);
		prev_total_players = -1;
		return 1;
	}
	if(prev_total_players != total_players)
	{
		float plcnt = 0, i;
		for(i = 1; i <= infection_teams; ++i)
		{
			if(aliveplayers[i] < 1)
				++plcnt;
		}
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_MISSING_PLAYERS, plcnt);
		prev_total_players = total_players;
	}
	return 0;
}

float inf_PickSmallestTeam()
{
	INF_count_alive_players();
	float i, smallest_team = 0;

	for(i = 1; i <= infection_teams; ++i)
	{
		if(aliveplayers[i] <= aliveplayers[smallest_team])
			smallest_team = i;
	}

	return smallest_team;
}

MUTATOR_HOOKFUNCTION(inf_RemovePlayer)
{
	self.inf_team = 0;
	self.inf_realteam = 0;
	self.inf_nextteam = 0;
	return FALSE;
}

MUTATOR_HOOKFUNCTION(inf_BotAttack)
{
	if(self.inf_team == checkentity.inf_team)
		return TRUE;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(inf_PlayerThink)
{
	// temporary hack to fix colors
	setcolor(self, 16 * self.inf_team + self.inf_team);
	return FALSE;
}

MUTATOR_HOOKFUNCTION(inf_PlayerSpawn)
{
	if(self.inf_nextteam) // respawning player
	{
		self.inf_team = self.inf_nextteam;
		self.inf_nextteam = 0;
	}
	else if(!self.inf_team) // new joining player
		self.inf_realteam = self.inf_team = inf_PickSmallestTeam();
		
	setcolor(self, 16 * self.inf_team + self.inf_team);

	return FALSE;
}

MUTATOR_HOOKFUNCTION(inf_PlayerDamage)
{
	if(IS_PLAYER(frag_target))
	if(IS_PLAYER(frag_attacker))
	if(frag_attacker != frag_target)
	if(frag_target.inf_team == frag_attacker.inf_team)
	{
		frag_damage = 0;
		frag_attacker.typehitsound += 1;
	}
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(inf_PlayerDies)
{
	if(IS_PLAYER(frag_attacker) && frag_attacker.inf_team != frag_target.inf_team)
	{
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_INFECTION_INFECTED, frag_target.netname, frag_attacker.netname);
		Send_Notification(NOTIF_ONE, frag_target, MSG_CENTER, CENTER_INFECTION_INFECTED, frag_attacker.netname);
		frag_target.inf_nextteam = frag_attacker.inf_team;
		
		PlayerScore_Add(frag_target, SP_SCORE, -1);
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(inf_ResetMap)
{
	FOR_EACH_PLAYER(self)
	{
		if(self.inf_realteam && self.inf_realteam != self.inf_team)
			self.inf_team = self.inf_realteam;
		self.inf_nextteam = 0;
		PutClientInServer(); // player re-spawns on new team?
	}
	
	FOR_EACH_SPEC(self) if(IS_BOT_CLIENT(self))
	{
		self.inf_realteam = self.inf_team = inf_PickSmallestTeam();
		self.inf_nextteam = 0;

		PutClientInServer();
	}
	
	return TRUE;
}

MUTATOR_HOOKFUNCTION(inf_ForbidPlayerScore_Clear)
{
	return TRUE;
}

// scoreboard stuff
void inf_ScoreRules()
{
	ScoreRules_basics(0, SFL_SORT_PRIO_PRIMARY, 0, TRUE);
	ScoreInfo_SetLabel_PlayerScore(SP_INF_ROUNDS, "survivals", SFL_SORT_PRIO_PRIMARY);
	ScoreRules_basics_end();
}

void inf_Initialize()
{
	allowed_to_spawn = TRUE;
	
	infection_teams = autocvar_g_infection_teams;

	inf_ScoreRules();

	round_handler_Spawn(INF_CheckTeams, Infection_CheckWinner, INF_RoundStart);
	round_handler_Init(5, autocvar_g_infection_warmup, autocvar_g_infection_round_timelimit);
}

MUTATOR_DEFINITION(gamemode_infection)
{
	MUTATOR_HOOK(MakePlayerObserver, inf_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, inf_PlayerThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, inf_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDamage_Calculate, inf_PlayerDamage, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientDisconnect, inf_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(BotShouldAttack, inf_BotAttack, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, inf_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(reset_map_players, inf_ResetMap, CBC_ORDER_ANY);
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
