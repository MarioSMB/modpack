entity spawnmonster (string monster, float mnster, entity spawnedby, entity own, vector orig, float respwn, float moveflag)
{
	if(!spawncode_first_load)
	{
		initialize_field_db();
		spawncode_first_load = TRUE;
	}
	
	entity e = spawn();
	
	e.spawnflags = MONSTERFLAG_SPAWNED;
	
	if not(respwn)
		e.spawnflags |= MONSTERFLAG_NORESPAWN;
	
	setorigin(e, orig);
	
	if(monster != "")
	if not(monster_string2id(monster))
		monster = "bruiser";
		
	if(monster == "")
	if(mnster)
		monster = monster_id2string(mnster);
	
	e.realowner = spawnedby;
	
	if(moveflag)
		e.monster_moveflags = moveflag;
	
	if (spawnedby.classname == "td_spawnpoint")
	{
		e.monster_owner = own;
		e.team = spawnedby.team;
	}
	else if(IS_PLAYER(spawnedby))
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
