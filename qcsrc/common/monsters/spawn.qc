entity spawnmonster (string monster, float monster_id, entity spawnedby, entity own, vector orig, float respwn, float invincible, float moveflag)
{
       float i;
	entity e = spawn();

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
			RandomSelection_Add(world, i, string_null, 1, 1);

           monster_id = RandomSelection_chosen_float;
	}
	else if(monster != "")
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
			monster_id = MON_FIRST;
	}

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
	
       // initialise checks if monster is valid
	entity oldself = self;
	self = e;
	monster_initialize(monster_id);
	self = oldself;

	return e;
}
