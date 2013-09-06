void za_SpawnMonster()
{
	if(gameover) { return; }
	
	entity e = spawn(), mon;
	
	if(MoveToRandomMapLocation(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 1024, 256))
		mon = spawnmonster(autocvar_g_za_spawnmonster, 0, self, self, e.origin, FALSE, 2);
	else
		za_SpawnMonster(); // finding a location failed, retry
		
	e.think = SUB_Remove;
	e.nextthink = time + 0.1;
}

void za_SpawnerThink()
{
	float maxmon, n_monsters = 0;
	entity head;
	maxmon = autocvar_g_za_max_monsters;
	
	// count dead monsters too (zombies)
	FOR_EACH_MONSTER(head) ++n_monsters;
	
	self.nextthink = time + autocvar_g_za_spawn_delay;
	
	while(n_monsters < maxmon)
	{
		++n_monsters;
		za_SpawnMonster();
	}
}

void za_Initialize()
{
	entity e = spawn();
	
	e.classname = "za_spawner";
	e.think = za_SpawnerThink;
	e.nextthink = time + game_starttime + autocvar_g_za_spawn_delay;
}

MUTATOR_DEFINITION(mutator_zombie_apocalypse)
{
	MUTATOR_ONADD
	{
		za_Initialize();
	}

	return FALSE;
}
