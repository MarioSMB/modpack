entity spawnmonster (string monster, float monster_id, entity spawnedby, entity own, vector orig, float respwn, float invincible, float moveflag)
{
	// ensure spawnfunc database is initialized
	//initialize_field_db();

	entity e = spawn();
	float i;

	e.spawnflags = MONSTERFLAG_SPAWNED;

	if(!respwn)
		e.spawnflags |= MONSTERFLAG_NORESPAWN;

	if(invincible)
		e.spawnflags |= MONSTERFLAG_INVINCIBLE;

	setorigin(e, orig);

	if(monster == "random")
	{
		RandomSelection_Init();
		for(i = MON_FIRST; i <= MON_LAST; ++i)
			RandomSelection_Add(world, 0, (get_monsterinfo(i)).netname, 1, 1);

		monster = RandomSelection_chosen_string;
	}

	if(monster != "")
	{
		float found = 0;
		entity mon;
		for(i = MON_FIRST; i <= MON_LAST; ++i)
		{
			mon = get_monsterinfo(i);
			if(mon.netname == monster)
			{
				found = TRUE;
				monster_id = mon.monsterid; // we have the monster, old monster id is no longer required
				break;
			}
		}
		if(!found)
			monster = (get_monsterinfo(MON_FIRST)).netname;
	}

	if(monster == "")
	if(monster_id)
		monster = (get_monsterinfo(monster_id)).netname;

	e.realowner = spawnedby;

	if(moveflag)
		e.monster_moveflags = moveflag;

	if(IS_PLAYER(spawnedby))
	{
		if(teamplay && autocvar_g_monsters_teams)
			e.team = spawnedby.team; // colors handled in spawn code

		if(autocvar_g_monsters_owners)
			e.monster_owner = own; // using .owner makes the monster non-solid for its master

		e.angles = spawnedby.angles;
	}

	//monster = strcat("$ spawnfunc_monster_", monster);
	
	entity oldself = self;
	self = e;
	monster_initialize(monster_id);
	self = oldself;

	//target_spawn_edit_entity(e, monster, world, world, world, world, world);

	return e;
}
