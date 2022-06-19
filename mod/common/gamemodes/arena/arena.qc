//FEATURE: Arena gamemode returning from the early days, the duel gamemode that pits 2 players against eachother until someone scores enough victories

#ifndef IMPLEMENTATION
#ifdef SVQC
AUTOCVAR_NOREF(g_arena, bool, false, "Arena: players compete in a sequence of duels, player with most victories is winner");
#endif
#include "arena.qh"
#endif

#ifdef IMPLEMENTATION

#ifdef CSQC

REGISTER_MUTATOR(cl_arena, true);

MUTATOR_HOOKFUNCTION(cl_arena, DrawInfoMessages)
{
	if(spectatee_status && !intermission && gametype == MAPINFO_TYPE_ARENA)
	{
		string s = _("^1Wait for your turn to join");
		vector pos = M_ARGV(0, vector);
		vector mySize = M_ARGV(1, vector);
		int img_curr_group = -1;
		vector fontsize = '0.2 0.2 0' * mySize.y;
		InfoMessage(s);
	}
}

#endif

#ifdef SVQC

AUTOCVAR(g_arena_point_limit, int, -1, "Arena point limit overriding the mapinfo specified one (use 0 to play without limit, and -1 to use mapinfo's limit)");
AUTOCVAR(g_arena_point_leadlimit, int, -1, "Arena point lead limit overriding the mapinfo specified one (use 0 to play without limit, and -1 to use mapinfo's limit)");

void arena_Initialize();
REGISTER_MUTATOR(arena, false)
{
	MUTATOR_STATIC();
	MUTATOR_ONADD
	{
		GameRules_limit_score(autocvar_g_arena_point_limit);
		GameRules_limit_lead(autocvar_g_arena_point_leadlimit);

		arena_Initialize();
	}

	return false;
}

AUTOCVAR(g_arena_maxspawned, int, 2, "maximum number of players to spawn at once (the rest is spectating, waiting for their turn)");
AUTOCVAR(g_arena_roundbased, bool, true, "if disabled, the next player will spawn as soon as someone dies");
AUTOCVAR(g_arena_round_timelimit, float, 180, "");
AUTOCVAR(g_arena_warmup, float, 5, "time, newly spawned players have to prepare themselves in round based matches");

.bool spawned;
int numspawned;
.entity spawnqueue_next;
.entity spawnqueue_prev;
.bool spawnqueue_in;
entity spawnqueue_first;
entity spawnqueue_last;

void Spawnqueue_Insert(entity e)
{
	if(e.spawnqueue_in)
		return;
	LOG_DEBUG("Into queue: ", e.netname, "\n");
	e.spawnqueue_in = true;
	e.spawnqueue_prev = spawnqueue_last;
	e.spawnqueue_next = NULL;
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
	LOG_DEBUG("Out of queue: ", e.netname, "\n");
	e.spawnqueue_in = false;
	if(e == spawnqueue_first)
		spawnqueue_first = e.spawnqueue_next;
	if(e == spawnqueue_last)
		spawnqueue_last = e.spawnqueue_prev;
	if(e.spawnqueue_prev)
		e.spawnqueue_prev.spawnqueue_next = e.spawnqueue_next;
	if(e.spawnqueue_next)
		e.spawnqueue_next.spawnqueue_prev = e.spawnqueue_prev;
	e.spawnqueue_next = NULL;
	e.spawnqueue_prev = NULL;
}

void Spawnqueue_Unmark(entity e)
{
	if(!e.spawned)
		return;
	e.spawned = false;
	numspawned = numspawned - 1;
}

void Spawnqueue_Mark(entity e)
{
	if(e.spawned)
		return;
	e.spawned = true;
	numspawned = numspawned + 1;
}

bool Arena_CheckWinner()
{
	if(round_handler_GetEndTime() > 0 && round_handler_GetEndTime() - time <= 0)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_OVER);
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_ROUND_OVER);
		round_handler_Init(5, autocvar_g_arena_warmup, autocvar_g_arena_round_timelimit);
		return true;
	}

	if(numspawned > 1)
		return false;

	entity champion = NULL;

	FOREACH_CLIENT(it.spawned && IS_PLAYER(it),
	{
		champion = it;
		break; // only 1 champion
	});

	if(champion)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_PLAYER_WIN, champion.netname);
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_ROUND_PLAYER_WIN, champion.netname);
		UpdateFrags(champion, +1);
	}
	else
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_TIED);
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_ROUND_TIED);
	}
	round_handler_Init(5, autocvar_g_arena_warmup, autocvar_g_arena_round_timelimit);
	return true;
}

void Arena_AddChallengers()
{
	if(time < 2) // don't force players to spawn so early
		return;
	entity player = NULL;
	while(numspawned < maxspawned && spawnqueue_first)
	{
		player = spawnqueue_first;

		bprint ("^4", player.netname, "^4 is the next challenger\n");

		Spawnqueue_Remove(player);
		Spawnqueue_Mark(player);

		TRANSMUTE(Player, player);
		PutClientInServer(player);
	}
}

int prev_numspawned;
bool Arena_CheckPlayers()
{
	Arena_AddChallengers();

	if(numspawned >= 2)
	{
		if(prev_numspawned > 0)
			Kill_Notification(NOTIF_ALL, NULL, MSG_CENTER, CPID_MISSING_PLAYERS);
		prev_numspawned = -1;
		return true;
	}

	if(prev_numspawned != numspawned && numspawned == 1)
	{
		if(maxspawned - numspawned > 0)
			Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_MISSING_PLAYERS, maxspawned - numspawned);
		prev_numspawned = numspawned;
	}

	return false;
}

void Arena_RoundStart()
{
	FOREACH_CLIENT(true,
	{
		it.player_blocked = 0;
	});
}

MUTATOR_HOOKFUNCTION(arena, ClientDisconnect)
{
	entity player = M_ARGV(0, entity);

	Spawnqueue_Unmark(player);
	Spawnqueue_Remove(player);
	return true;
}

MUTATOR_HOOKFUNCTION(arena, reset_map_players)
{
	FOREACH_CLIENT(true,
	{
		if(it.spawned)
		{
			PutClientInServer(it);
			it.player_blocked = 1;
		}
		else
			PutObserverInServer(it, true, true);
	});
	return true;
}

MUTATOR_HOOKFUNCTION(arena, MakePlayerObserver)
{
	entity player = M_ARGV(0, entity);

	if(CS(player).version_mismatch)
	{
		player.frags = FRAGS_SPECTATOR;
		Spawnqueue_Unmark(player);
		Spawnqueue_Remove(player);
	}
	else
	{
		player.frags = FRAGS_PLAYER_OUT_OF_GAME;
		Spawnqueue_Insert(player);
	}
	return true;
}

MUTATOR_HOOKFUNCTION(arena, PutClientInServer)
{
	entity player = M_ARGV(0, entity);

	if(!player.spawned)
		TRANSMUTE(Observer, player);
	return true;
}

MUTATOR_HOOKFUNCTION(arena, ClientConnect)
{
	entity player = M_ARGV(0, entity);

	TRANSMUTE(Observer, player);
	Spawnqueue_Insert(player); // TODO: check spec time
	return true;
}

MUTATOR_HOOKFUNCTION(arena, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);

	Spawnqueue_Remove(player);
	Spawnqueue_Mark(player);
	if(arena_roundbased)
		player.player_blocked = 1;
	return true; // true?
}

MUTATOR_HOOKFUNCTION(arena, ForbidPlayerScore_Clear)
{
	return true;
}

MUTATOR_HOOKFUNCTION(arena, GiveFragsForKill)
{
	if(arena_roundbased)
		M_ARGV(2, float) = 0; // frag score
	return true;
}

MUTATOR_HOOKFUNCTION(arena, PlayerDies)
{
	entity frag_target = M_ARGV(2, entity);

	// put dead players in the spawn queue
	if(arena_roundbased)
		frag_target.respawn_flags = (RESPAWN_FORCE | RESPAWN_SILENT);
	else
		frag_target.respawn_flags = RESPAWN_SILENT;
	Spawnqueue_Unmark(frag_target);
	return true;
}

MUTATOR_HOOKFUNCTION(arena, SV_StartFrame)
{
	if(game_stopped) return true;
	if(time <= game_starttime || !arena_roundbased)
		Arena_AddChallengers();
	return true;
}

MUTATOR_HOOKFUNCTION(arena, OnEntityPreSpawn)
{
	entity ent = M_ARGV(0, entity);

	if(ent.gametype)
	{
		if(strstrofs(ent.gametype, "tournament", 0) < 0)
			return true;
	}
}

MUTATOR_HOOKFUNCTION(arena, Bot_FixCount, CBC_ORDER_EXCLUSIVE)
{
	FOREACH_CLIENT(IS_REAL_CLIENT(it), {
		if (IS_PLAYER(it) || g_arena)
			++M_ARGV(0, int);
		++M_ARGV(1, int);
	});
	return true;
}

MUTATOR_HOOKFUNCTION(arena, ForbidSpawn)
{
	return true; // always prevent manual joining in arena, that's done automatically...
}

MUTATOR_HOOKFUNCTION(arena, ClientCommand_Spectate)
{
	return MUT_SPECCMD_RETURN; // no spectating manually here, same reason
}

MUTATOR_HOOKFUNCTION(arena, ReadyRestart_Deny)
{
	// no readyrestart in arena
	return true;
}

MUTATOR_HOOKFUNCTION(arena, GetPlayerStatus)
{
	return true;
}

MUTATOR_HOOKFUNCTION(arena, Scores_CountFragsRemaining)
{
	return true; // 3 frags remain!
}

MUTATOR_HOOKFUNCTION(arena, ReadLevelCvars)
{
	// no warmups
	warmup_stage = 0;
}

MUTATOR_HOOKFUNCTION(arena, FilterItem)
{
    entity item = M_ARGV(0, entity);

	if (autocvar_g_powerups <= 0)
	if (item.flags & FL_POWERUP)
		return true;
}

// initialization
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

#endif

#endif
