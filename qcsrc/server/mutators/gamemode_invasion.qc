void spawnfunc_invasion_spawnpoint()
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

		RandomSelection_Add(world, i, string_null, 1, 1);
	}

	return RandomSelection_chosen_float;
}

entity invasion_PickSpawn()
{
	entity e;

	RandomSelection_Init();

	for(e = world;(e = find(e, classname, "invasion_spawnpoint")); )
	{
		RandomSelection_Add(e, 0, string_null, 1, ((time >= e.spawnshieldtime) ? 0.2 : 1)); // give recently used spawnpoints a very low rating
		e.spawnshieldtime = time + autocvar_g_invasion_spawnpoint_spawn_delay;
	}

	return RandomSelection_chosen_ent;
}

void invasion_SpawnChosenMonster(float mon)
{
	entity spawn_point, monster;

	spawn_point = invasion_PickSpawn();

	if(spawn_point == world)
	{
		dprint("Warning: couldn't find any invasion_spawnpoint spawnpoints, attempting to spawn monsters in random locations\n");
		entity e = spawn();
		setsize(e, (get_monsterinfo(mon)).mins, (get_monsterinfo(mon)).maxs);

		if(MoveToRandomMapLocation(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 1024, 256))
			monster = spawnmonster("", mon, world, world, e.origin, FALSE, FALSE, 2);
		else return;

		e.think = SUB_Remove;
		e.nextthink = time + 0.1;
	}
	else
		monster = spawnmonster("", ((spawn_point.monsterid) ? spawn_point.monsterid : mon), spawn_point, spawn_point, spawn_point.origin, FALSE, FALSE, 2);
	
	if(spawn_point) monster.target2 = spawn_point.target2;
	monster.spawnshieldtime = time;
	if(spawn_point && spawn_point.target_range) monster.target_range = spawn_point.target_range;
	
	if(teamplay)
	if(spawn_point && spawn_point.team && inv_monsters_perteam[spawn_point.team] > 0)
		monster.team = spawn_point.team;
	else
	{
		RandomSelection_Init();
		if(inv_monsters_perteam[NUM_TEAM_1] > 0) RandomSelection_Add(world, NUM_TEAM_1, string_null, 1, 1);
		if(inv_monsters_perteam[NUM_TEAM_2] > 0) RandomSelection_Add(world, NUM_TEAM_2, string_null, 1, 1);
		if(invasion_teams >= 3) if(inv_monsters_perteam[NUM_TEAM_3] > 0) { RandomSelection_Add(world, NUM_TEAM_3, string_null, 1, 1); }
		if(invasion_teams >= 4) if(inv_monsters_perteam[NUM_TEAM_4] > 0) { RandomSelection_Add(world, NUM_TEAM_4, string_null, 1, 1); }
		
		monster.team = RandomSelection_chosen_float;
	}
	
	if(teamplay)
	{
		monster_setupcolors(monster);
	
		if(monster.sprite)
		{
			WaypointSprite_UpdateTeamRadar(monster.sprite, RADARICON_DANGER, ((monster.team) ? Team_ColorRGB(monster.team) : '1 0 0'));

			monster.sprite.team = 0;
			monster.sprite.SendFlags |= 1;
		}
	}
	
	monster.monster_attack = FALSE; // it's the player's job to kill all the monsters

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
			Monster_Remove(head);

		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_OVER);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_OVER);
		round_handler_Init(5, autocvar_g_invasion_warmup, autocvar_g_invasion_round_timelimit);
		return 1;
	}

	float total_alive_monsters = 0, supermonster_count = 0, red_alive = 0, blue_alive = 0, yellow_alive = 0, pink_alive = 0;;

	FOR_EACH_MONSTER(head) if(head.health > 0)
	{
		if((get_monsterinfo(head.monsterid)).spawnflags & MON_FLAG_SUPERMONSTER)
			++supermonster_count;
		++total_alive_monsters;

		if(teamplay)
		switch(head.team)
		{
			case NUM_TEAM_1: ++red_alive; break;
			case NUM_TEAM_2: ++blue_alive; break;
			case NUM_TEAM_3: ++yellow_alive; break;
			case NUM_TEAM_4: ++pink_alive; break;
		}
	}

	if((total_alive_monsters + inv_numkilled) < inv_maxspawned && inv_maxcurrent < inv_maxspawned)
	{
		if(time >= inv_lastcheck)
		{
			invasion_SpawnMonsters(supermonster_count);
			inv_lastcheck = time + autocvar_g_invasion_spawn_delay;
		}

		return 0;
	}

	if(inv_numspawned < 1)
		return 0; // nothing has spawned yet
		
	if(teamplay)
	{
		if(((red_alive > 0) + (blue_alive > 0) + (yellow_alive > 0) + (pink_alive > 0)) > 1)
			return 0;
	}
	else if(inv_numkilled < inv_maxspawned)
		return 0;

	entity winner = world;
	float winning_score = 0, winner_team = 0;


	if(teamplay)
	{
		if(red_alive > 0) { winner_team = NUM_TEAM_1; }
		if(blue_alive > 0)
		if(winner_team) { winner_team = 0; }
		else { winner_team = NUM_TEAM_2; }
		if(yellow_alive > 0)
		if(winner_team) { winner_team = 0; }
		else { winner_team = NUM_TEAM_3; }
		if(pink_alive > 0)
		if(winner_team) { winner_team = 0; }
		else { winner_team = NUM_TEAM_4; }
	}	
	else
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
		Monster_Remove(head);

	if(teamplay)
	{
		if(winner_team)
		{
			Send_Notification(NOTIF_ALL, world, MSG_CENTER, APP_TEAM_NUM_4(winner_team, CENTER_ROUND_TEAM_WIN_));
			Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_NUM_4(winner_team, INFO_ROUND_TEAM_WIN_));
		}
	}
	else if(winner)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_PLAYER_WIN, winner.netname);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_PLAYER_WIN, winner.netname);
	}

	round_handler_Init(5, autocvar_g_invasion_warmup, autocvar_g_invasion_round_timelimit);

	nades_Clear(world, TRUE);

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

	if(teamplay)
	{
		DistributeEvenly_Init(inv_maxspawned, invasion_teams);
		inv_monsters_perteam[NUM_TEAM_1] = DistributeEvenly_Get(1);
		inv_monsters_perteam[NUM_TEAM_2] = DistributeEvenly_Get(1);
		if(invasion_teams >= 3) inv_monsters_perteam[NUM_TEAM_3] = DistributeEvenly_Get(1);
		if(invasion_teams >= 4) inv_monsters_perteam[NUM_TEAM_4] = DistributeEvenly_Get(1);
	}
}

MUTATOR_HOOKFUNCTION(invasion_MonsterDies)
{
	if(!(self.spawnflags & MONSTERFLAG_RESPAWNED))
	{
		inv_numkilled += 1;
		inv_maxcurrent -= 1;
		if(teamplay) { inv_monsters_perteam[self.team] -= 1; }

		if(IS_PLAYER(frag_attacker))
		if(SAME_TEAM(frag_attacker, self)) // in non-teamplay modes, same team = same player, so this works
			PlayerScore_Add(frag_attacker, SP_KILLS, -1);
		else
		{
			PlayerScore_Add(frag_attacker, SP_KILLS, +1);
			if(teamplay)
				TeamScore_AddToTeam(frag_attacker.team, ST_INV_KILLS, +1);
		}
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
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_INVASION_SUPERMONSTER, self.monster_name);

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

MUTATOR_HOOKFUNCTION(invasion_StartFrame)
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

MUTATOR_HOOKFUNCTION(invasion_BotShouldAttack)
{
	if(!IS_MONSTER(other))
		return TRUE;
	
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
	if(IS_MONSTER(frag_target))
		return MUT_ACCADD_INVALID;
	return MUT_ACCADD_INDIFFERENT;
}

MUTATOR_HOOKFUNCTION(invasion_AllowMobSpawning)
{
	ret_string = "You can't spawn monsters during an invasion!";
	return TRUE;
}

MUTATOR_HOOKFUNCTION(invasion_GetTeamCount)
{
	ret_float = invasion_teams;
	return FALSE;
}

void invasion_ScoreRules(float inv_teams)
{
	if(inv_teams) { CheckAllowedTeams(world); }
	ScoreRules_basics(inv_teams, 0, 0, FALSE);
	if(inv_teams) ScoreInfo_SetLabel_TeamScore(ST_INV_KILLS, "frags", SFL_SORT_PRIO_PRIMARY);
	ScoreInfo_SetLabel_PlayerScore(SP_KILLS, "frags", ((inv_teams) ? SFL_SORT_PRIO_SECONDARY : SFL_SORT_PRIO_PRIMARY));
	ScoreRules_basics_end();
}

void invasion_DelayedInit() // Do this check with a delay so we can wait for teams to be set up.
{
	if(autocvar_g_invasion_teams)
		invasion_teams = bound(2, autocvar_g_invasion_teams, 4);
	else
		invasion_teams = 0;
	
	independent_players = 1; // to disable extra useless scores

	invasion_ScoreRules(invasion_teams);

	independent_players = 0;

	round_handler_Spawn(Invasion_CheckPlayers, Invasion_CheckWinner, Invasion_RoundStart);
	round_handler_Init(5, autocvar_g_invasion_warmup, autocvar_g_invasion_round_timelimit);

	allowed_to_spawn = TRUE;

	inv_roundcnt = 0;
	inv_maxrounds = 15; // 15?
}

void invasion_Initialize()
{	
	InitializeEntity(world, invasion_DelayedInit, INITPRIO_GAMETYPE);
}

MUTATOR_DEFINITION(gamemode_invasion)
{
	MUTATOR_HOOK(MonsterDies, invasion_MonsterDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(MonsterSpawn, invasion_MonsterSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(OnEntityPreSpawn, invasion_OnEntityPreSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(SV_StartFrame, invasion_StartFrame, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerRegen, invasion_PlayerRegen, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, invasion_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDamage_Calculate, invasion_PlayerDamage, CBC_ORDER_ANY);
	MUTATOR_HOOK(SV_ParseClientCommand, invasion_PlayerCommand, CBC_ORDER_ANY);
	MUTATOR_HOOK(BotShouldAttack, invasion_BotShouldAttack, CBC_ORDER_ANY);
	MUTATOR_HOOK(SetStartItems, invasion_SetStartItems, CBC_ORDER_ANY);
	MUTATOR_HOOK(AccuracyTargetValid, invasion_AccuracyTargetValid, CBC_ORDER_ANY);
	MUTATOR_HOOK(AllowMobSpawning, invasion_AllowMobSpawning, CBC_ORDER_ANY);
	MUTATOR_HOOK(GetTeamCount, invasion_GetTeamCount, CBC_ORDER_ANY);

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
