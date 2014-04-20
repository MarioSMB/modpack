void invasion_spawnpoint()
{
	if(!g_invasion) { remove(self); return; }

	self.classname = "invasion_spawnpoint";
}

float invasion_PickMonster(float supermonster_count)
{
	if(autocvar_g_invasion_zombies_only)
		return MON_ZOMBIE;

	float i;
	entity mon;

	RandomSelection_Init();

	for(i = MON_FIRST; i <= MON_LAST; ++i)
	{
		mon = get_monsterinfo(i);
		if((mon.spawnflags & MONSTER_TYPE_FLY) || (mon.spawnflags & MONSTER_TYPE_SWIM) || ((mon.spawnflags & MON_FLAG_SUPERMONSTER) && supermonster_count >= 1))
			continue; // flying/swimming monsters not yet supported

		RandomSelection_Add(world, i, "", 1, 1);
	}

	return RandomSelection_chosen_float;
}

entity invasion_PickSpawn()
{
	entity e;

	RandomSelection_Init();

	for(e = world;(e = find(e, classname, "invasion_spawnpoint")); )
	{
		if(time >= e.spawnshieldtime)
		{
			e.spawnshieldtime = time + 2;
			RandomSelection_Add(e, 0, string_null, 1, 1);
		}
	}

	return RandomSelection_chosen_ent;
}

void invasion_SpawnChosenMonster(float mon)
{
	entity spawn_point, monster;

	spawn_point = invasion_PickSpawn();

	if(spawn_point == world)
	{
		dprint("Warning: couldn't find any invasion_spawnpoint spawnpoints, no monsters will spawn!\n");
		return;
	}

	monster = spawnmonster("", ((spawn_point.monsterid) ? spawn_point.monsterid : mon), spawn_point, spawn_point, spawn_point.origin, FALSE, FALSE, 2);

	monster.target2 = spawn_point.target2;
	monster.spawnshieldtime = time;

	if(inv_roundcnt >= inv_maxrounds)
		monster.spawnflags |= MONSTERFLAG_MINIBOSS; // last round spawns minibosses
}

void invasion_SpawnMonsters(float supermonster_count)
{
	float chosen_monster = invasion_PickMonster(supermonster_count);

	invasion_SpawnChosenMonster(chosen_monster);
}

float Invasion_CheckWinner()
{
	entity head;
	if(round_handler_GetEndTime() > 0 && round_handler_GetEndTime() - time <= 0)
	{
		FOR_EACH_MONSTER(head)
			monster_remove(head);

		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_OVER);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_OVER);
		round_handler_Init(5, autocvar_g_invasion_warmup, autocvar_g_invasion_round_timelimit);

		FOR_EACH_PLAYER(head)
			nades_Clear(head);

		return 1;
	}

	float total_alive_monsters = 0, supermonster_count = 0;

	FOR_EACH_MONSTER(head) if(head.health > 0)
	{
		if((get_monsterinfo(head.monsterid)).spawnflags & MON_FLAG_SUPERMONSTER)
			++supermonster_count;
		++total_alive_monsters;
	}

	if((total_alive_monsters + inv_numkilled) < inv_maxspawned && inv_maxcurrent < inv_maxspawned) // 10 at a time should be plenty
	{
		if(time >= inv_lastcheck)
		{
			invasion_SpawnMonsters(supermonster_count);
			inv_lastcheck = time + autocvar_g_invasion_spawn_delay;
		}

		return 0;
	}

	if(inv_numspawned < 1 || inv_numkilled < inv_maxspawned)
		return 0; // nothing has spawned yet, or there are still alive monsters

	entity winner = world;
	float winning_score = 0;

	FOR_EACH_PLAYER(head)
	{
		float cs = PlayerScore_Add(head, SP_KILLS, 0);
		if(cs > winning_score)
		{
			winning_score = cs;
			winner = head;
		}
	}

	FOR_EACH_MONSTER(head)
		monster_remove(head);

	if(winner)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_PLAYER_WIN, winner.netname);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_PLAYER_WIN, winner.netname);
	}

	round_handler_Init(5, autocvar_g_invasion_warmup, autocvar_g_invasion_round_timelimit);

	FOR_EACH_PLAYER(head)
		nades_Clear(head);

	return 1;
}

float Invasion_CheckPlayers()
{
	return TRUE;
}

void Invasion_RoundStart()
{
	entity e;
	float numplayers = 0;
	FOR_EACH_PLAYER(e)
	{
		e.player_blocked = 0;
		++numplayers;
	}

	if(inv_roundcnt < inv_maxrounds)
		inv_roundcnt += 1; // a limiter to stop crazy counts

	inv_monsterskill = inv_roundcnt + max(1, numplayers * 0.3);

	inv_maxcurrent = 0;
	inv_numspawned = 0;
	inv_numkilled = 0;

	inv_maxspawned = rint(max(autocvar_g_invasion_monster_count, autocvar_g_invasion_monster_count * (inv_roundcnt * 0.5)));
}

MUTATOR_HOOKFUNCTION(invasion_MonsterDies)
{
	if(!(self.spawnflags & MONSTERFLAG_RESPAWNED))
	{
		inv_numkilled += 1;
		inv_maxcurrent -= 1;

		if(IS_PLAYER(frag_attacker))
			PlayerScore_Add(frag_attacker, SP_KILLS, +1);
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(invasion_MonsterSpawn)
{
	if(!(self.spawnflags & MONSTERFLAG_SPAWNED))
		return TRUE;

	if(!(self.spawnflags & MONSTERFLAG_RESPAWNED))
	{
		inv_numspawned += 1;
		inv_maxcurrent += 1;
	}

	self.monster_skill = inv_monsterskill;

	if((get_monsterinfo(self.monsterid)).spawnflags & MON_FLAG_SUPERMONSTER)
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_INVASION_SUPERMONSTER, M_NAME(self.monsterid));

	self.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_BOTCLIP | DPCONTENTS_MONSTERCLIP;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(invasion_OnEntityPreSpawn)
{
	if(startsWith(self.classname, "monster_"))
	if(!(self.spawnflags & MONSTERFLAG_SPAWNED))
		return TRUE;
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(invasion_PlayerThink)
{
	monsters_total = inv_maxspawned; // TODO: make sure numspawned never exceeds maxspawned
	monsters_killed = inv_numkilled;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(invasion_PlayerRegen)
{
	// no regeneration in invasion
	return TRUE;
}

MUTATOR_HOOKFUNCTION(invasion_PlayerSpawn)
{
	self.bot_attack = FALSE;
	return FALSE;
}

MUTATOR_HOOKFUNCTION(invasion_PlayerDamage)
{
	if(IS_PLAYER(frag_attacker) && IS_PLAYER(frag_target) && frag_attacker != frag_target)
	{
		frag_damage = 0;
		frag_force = '0 0 0';
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(invasion_PlayerCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return FALSE;

	if(cmd_name == "debuginvasion")
	{
		sprint(self, strcat("inv_maxspawned = ", ftos(inv_maxspawned), "\n"));
		sprint(self, strcat("inv_numspawned = ", ftos(inv_numspawned), "\n"));
		sprint(self, strcat("inv_numkilled = ", ftos(inv_numkilled), "\n"));
		sprint(self, strcat("inv_roundcnt = ", ftos(inv_roundcnt), "\n"));
		sprint(self, strcat("monsters_total = ", ftos(monsters_total), "\n"));
		sprint(self, strcat("monsters_killed = ", ftos(monsters_killed), "\n"));
		sprint(self, strcat("inv_monsterskill = ", ftos(inv_monsterskill), "\n"));

		return TRUE;
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(invasion_SetStartItems)
{
	start_health = 200;
	start_armorvalue = 200;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(invasion_AccuracyTargetValid)
{
	if(frag_target.flags & FL_MONSTER)
		return MUT_ACCADD_INVALID;
	return MUT_ACCADD_INDIFFERENT;
}

MUTATOR_HOOKFUNCTION(invasion_AllowMobSpawning)
{
	// monster spawning disabled during an invasion
	return TRUE;
}

void invasion_ScoreRules()
{
	ScoreRules_basics(0, 0, 0, FALSE);
	ScoreInfo_SetLabel_PlayerScore(SP_KILLS, "frags", SFL_SORT_PRIO_PRIMARY);
	ScoreRules_basics_end();
}

void invasion_Initialize()
{
	independent_players = 1; // to disable extra useless scores

	invasion_ScoreRules();

	independent_players = 0;

	round_handler_Spawn(Invasion_CheckPlayers, Invasion_CheckWinner, Invasion_RoundStart);
	round_handler_Init(5, autocvar_g_invasion_warmup, autocvar_g_invasion_round_timelimit);

	allowed_to_spawn = TRUE;

	inv_roundcnt = 0;
	inv_maxrounds = 15; // 15?
}

MUTATOR_DEFINITION(gamemode_invasion)
{
	MUTATOR_HOOK(MonsterDies, invasion_MonsterDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(MonsterSpawn, invasion_MonsterSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(OnEntityPreSpawn, invasion_OnEntityPreSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, invasion_PlayerThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerRegen, invasion_PlayerRegen, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, invasion_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDamage_Calculate, invasion_PlayerDamage, CBC_ORDER_ANY);
	MUTATOR_HOOK(SV_ParseClientCommand, invasion_PlayerCommand, CBC_ORDER_ANY);
	MUTATOR_HOOK(SetStartItems, invasion_SetStartItems, CBC_ORDER_ANY);
	MUTATOR_HOOK(AccuracyTargetValid, invasion_AccuracyTargetValid, CBC_ORDER_ANY);
	MUTATOR_HOOK(AllowMobSpawning, invasion_AllowMobSpawning, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		if(time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");
		invasion_Initialize();

		cvar_settemp("g_monsters", "1");
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		// we actually cannot roll back invasion_Initialize here
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
