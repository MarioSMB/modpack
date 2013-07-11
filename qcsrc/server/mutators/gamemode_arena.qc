.float spawned;
float maxspawned;
float numspawned;
.entity spawnqueue_next;
.entity spawnqueue_prev;
.float spawnqueue_in;
entity spawnqueue_first;
entity spawnqueue_last;

void Spawnqueue_Insert(entity e)
{
	if(e.spawnqueue_in)
		return;
	dprint(strcat("Into queue: ", e.netname, "\n"));
	e.spawnqueue_in = TRUE;
	e.spawnqueue_prev = spawnqueue_last;
	e.spawnqueue_next = world;
	if(spawnqueue_last)
		spawnqueue_last.spawnqueue_next = e;
	spawnqueue_last = e;
	if(!spawnqueue_first)
		spawnqueue_first = e;
}

void Spawnqueue_Remove(entity e)
{
	if(!e.spawnqueue_in)
		return;
	dprint(strcat("Out of queue: ", e.netname, "\n"));
	e.spawnqueue_in = FALSE;
	if(e == spawnqueue_first)
		spawnqueue_first = e.spawnqueue_next;
	if(e == spawnqueue_last)
		spawnqueue_last = e.spawnqueue_prev;
	if(e.spawnqueue_prev)
		e.spawnqueue_prev.spawnqueue_next = e.spawnqueue_next;
	if(e.spawnqueue_next)
		e.spawnqueue_next.spawnqueue_prev = e.spawnqueue_prev;
	e.spawnqueue_next = world;
	e.spawnqueue_prev = world;
}

void Spawnqueue_Unmark(entity e)
{
	if(!e.spawned)
		return;
	e.spawned = FALSE;
	numspawned = numspawned - 1;
}

void Spawnqueue_Mark(entity e)
{
	if(e.spawned)
		return;
	e.spawned = TRUE;
	numspawned = numspawned + 1;
}

float Arena_CheckWinner()
{
	entity e;

	if(round_handler_GetEndTime() > 0 && round_handler_GetEndTime() - time <= 0)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_OVER);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_OVER);
		round_handler_Init(5, autocvar_g_arena_warmup, autocvar_g_arena_round_timelimit);
		return 1;
	}

	if(numspawned > 1)
		return 0;

	entity champion;
	champion = world;
	FOR_EACH_CLIENT(e)
	{
		if(e.spawned && IS_PLAYER(e))
			champion = e;
	}

	if(champion)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_PLAYER_WIN, champion.netname);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_PLAYER_WIN, champion.netname);
		UpdateFrags(champion, +1);
	}
	else
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_TIED);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_TIED);
	}
	round_handler_Init(5, autocvar_g_arena_warmup, autocvar_g_arena_round_timelimit);
	return 1;
}

void Arena_AddChallengers()
{
	entity e;
	if(time < 2) // don't force players to spawn so early
		return;
	e = self;
	while(numspawned < maxspawned && spawnqueue_first)
	{
		self = spawnqueue_first;

		bprint ("^4", self.netname, "^4 is the next challenger\n");

		Spawnqueue_Remove(self);
		Spawnqueue_Mark(self);

		self.classname = "player";
		PutClientInServer();
	}
	self = e;
}

float prev_numspawned;
float Arena_CheckPlayers()
{
	Arena_AddChallengers();

	if(numspawned >= 2)
	{
		if(prev_numspawned > 0)
			Kill_Notification(NOTIF_ALL, world, MSG_CENTER_CPID, CPID_MISSING_PLAYERS);
		prev_numspawned = -1;
		return 1;
	}

	if(prev_numspawned != numspawned && numspawned == 1)
	{
		if(maxspawned - numspawned > 0)
			Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_MISSING_PLAYERS, maxspawned - numspawned);
		prev_numspawned = numspawned;
	}

	return 0;
}

void Arena_RoundStart()
{
	entity e;
	FOR_EACH_PLAYER(e)
		e.player_blocked = 0;
}

MUTATOR_HOOKFUNCTION(arena_ClientDisconnect)
{
	Spawnqueue_Unmark(self);
	Spawnqueue_Remove(self);
	return 1;
}

MUTATOR_HOOKFUNCTION(arena_reset_map_players)
{
	FOR_EACH_CLIENT(self)
	{
		if(self.spawned)
		{
			PutClientInServer();
			self.player_blocked = 1;
		}
		else
			PutObserverInServer();
	}
	return 1;
}

MUTATOR_HOOKFUNCTION(arena_MakePlayerObserver)
{
	if(self.version_mismatch)
	{
		self.frags = FRAGS_SPECTATOR;
		Spawnqueue_Unmark(self);
		Spawnqueue_Remove(self);
	}
	else
	{
		self.frags = FRAGS_LMS_LOSER;
		Spawnqueue_Insert(self);
	}
	return 1;
}

MUTATOR_HOOKFUNCTION(arena_PutClientInServer)
{
	if(!self.spawned)
		self.classname = "observer";
	return 1;
}

MUTATOR_HOOKFUNCTION(arena_ClientConnect)
{
	self.classname = "observer";
	Spawnqueue_Insert(self);
	return 1;
}

MUTATOR_HOOKFUNCTION(arena_PlayerSpawn)
{
	Spawnqueue_Remove(self);
	Spawnqueue_Mark(self);
	if(arena_roundbased)
		self.player_blocked = 1;
	return 1;
}

MUTATOR_HOOKFUNCTION(arena_ForbidPlayerScore_Clear)
{
	return 1;
}

MUTATOR_HOOKFUNCTION(arena_GiveFragsForKill)
{
	if(arena_roundbased)
		frag_score = 0; // score will be given to the champion when the round ends
	return 1;
}

MUTATOR_HOOKFUNCTION(arena_PlayerDies)
{
	// put dead players in the spawn queue
	if(arena_roundbased)
		self.respawn_flags = (RESPAWN_FORCE | RESPAWN_SILENT);
	else
		self.respawn_flags = RESPAWN_SILENT;
	Spawnqueue_Unmark(self);
	return 1;
}

MUTATOR_HOOKFUNCTION(arena_SV_StartFrame)
{
	if(gameover) return 1;
	if(time <= game_starttime || !arena_roundbased)
		Arena_AddChallengers();
	return 1;
}

MUTATOR_HOOKFUNCTION(arena_FilterItem)
{
	if(autocvar_g_powerups <= 0)
	if(self.flags & FL_POWERUP)
		return TRUE;
		
	return FALSE;
}

void arena_Initialize()
{
	maxspawned = max(2, autocvar_g_arena_maxspawned);
	arena_roundbased = autocvar_g_arena_roundbased;
	if(arena_roundbased)
	{
		round_handler_Spawn(Arena_CheckPlayers, Arena_CheckWinner, Arena_RoundStart);
		round_handler_Init(5, autocvar_g_arena_warmup, autocvar_g_arena_round_timelimit);
	}
}

MUTATOR_DEFINITION(gamemode_arena)
{
	MUTATOR_HOOK(ClientDisconnect, arena_ClientDisconnect, CBC_ORDER_ANY);
	MUTATOR_HOOK(reset_map_players, arena_reset_map_players, CBC_ORDER_ANY);
	MUTATOR_HOOK(MakePlayerObserver, arena_MakePlayerObserver, CBC_ORDER_ANY);
	MUTATOR_HOOK(PutClientInServer, arena_PutClientInServer, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientConnect, arena_ClientConnect, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, arena_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(ForbidPlayerScore_Clear, arena_ForbidPlayerScore_Clear, CBC_ORDER_ANY);
	MUTATOR_HOOK(GiveFragsForKill, arena_GiveFragsForKill, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, arena_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(SV_StartFrame, arena_SV_StartFrame, CBC_ORDER_ANY);
	MUTATOR_HOOK(FilterItem, arena_FilterItem, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		if(time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");
		arena_Initialize();
	}

	MUTATOR_ONREMOVE
	{
		print("This is a game type and it cannot be removed at runtime.");
		return -1;
	}

	return 0;
}
