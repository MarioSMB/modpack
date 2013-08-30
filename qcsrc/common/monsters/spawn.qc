entity spawnmonster (string monster, float mnster, entity spawnedby, entity own, vector orig, float respwn, float moveflag)
{
	// ensure spawnfunc database is initialized
	initialize_field_db();
	
	entity e = spawn();
	
	e.spawnflags = MONSTERFLAG_SPAWNED;
	
	if not(respwn)
		e.spawnflags |= MONSTERFLAG_NORESPAWN;
	
	setorigin(e, orig);
	
	if(monster != "")
	{
		float i, found = 0;
		entity mon;
		for(i = MON_FIRST; i <= MON_LAST; ++i)
		{
			mon = get_monsterinfo(i);
			if(mon.netname == monster)
			{
				found = TRUE;
				break;
			}
		}
		if not(found)
			monster = (get_monsterinfo(MON_FIRST)).netname;
	}
		
	if(monster == "")
	if(mnster)
		monster = (get_monsterinfo(mnster)).netname;
	
	e.realowner = spawnedby;
	
	if(moveflag)
		e.monster_moveflags = moveflag;
	
	if(IS_PLAYER(spawnedby))
	{
		if(teamplay && autocvar_g_monsters_teams)
			e.team = spawnedby.team; // colors handled in spawn code
			
		if(e.team)
			e.colormap = 1024;
		else
			e.colormap = spawnedby.colormap;
			
		if(autocvar_g_monsters_owners)
			e.monster_owner = own; // using .owner makes the monster non-solid for its master
			
		e.angles = spawnedby.angles;
	}
		
	monster = strcat("$ spawnfunc_monster_", monster);
		
	target_spawn_edit_entity(e, monster, world, world, world, world, world);
		
	return e;
}
