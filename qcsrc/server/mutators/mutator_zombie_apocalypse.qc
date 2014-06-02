float za_spawn_delay;

void za_SpawnMonster()
{
	if(gameover) { return; }

	entity e = spawn(), mon;

	if(MoveToRandomMapLocation(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 1024, 256))
		mon = spawnmonster(autocvar_g_za_spawnmonster, 0, self, self, e.origin, FALSE, FALSE, 2);

	e.think = SUB_Remove;
	e.nextthink = time + 0.1;
}

MUTATOR_HOOKFUNCTION(za_StartFrame)
{
	if(time < za_spawn_delay || autocvar_g_za_max_monsters <= 0 || !autocvar_g_za)
		return FALSE;

	float n_monsters = 0, maxmon = autocvar_g_za_max_monsters;
	entity head;

	// count dead monsters too (zombies)
	FOR_EACH_MONSTER(head) ++n_monsters;

	while(n_monsters < maxmon)
	{
		++n_monsters;
		za_SpawnMonster();
	}

	za_spawn_delay = time + autocvar_g_za_spawn_delay;

	return FALSE;
}

MUTATOR_DEFINITION(mutator_zombie_apocalypse)
{
	MUTATOR_HOOK(SV_StartFrame, za_StartFrame, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		za_spawn_delay = time + game_starttime;

		float i;
		entity mon;
		for(i = MON_FIRST; i <= MON_LAST; ++i)
		{
			mon = get_monsterinfo(i);
			if(mon.netname == autocvar_g_za_spawnmonster || autocvar_g_za_spawnmonster == "random")
				MON_ACTION(i, MR_PRECACHE);
		}
	}

	return FALSE;
}
