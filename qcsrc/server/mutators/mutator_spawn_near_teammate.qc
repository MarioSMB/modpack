float autocvar_g_spawn_near_teammate_distance;
.entity msnt_lookat;

MUTATOR_HOOKFUNCTION(msnt_Spawn_Score)
{
	entity p;

	spawn_spot.msnt_lookat = world;

	if(!teamplay)
		return 0;

	RandomSelection_Init();
	FOR_EACH_PLAYER(p) if(p != self) if(p.team == self.team) if(!p.deadflag)
	{
		float l = vlen(spawn_spot.origin - p.origin);
		if(l > autocvar_g_spawn_near_teammate_distance)
			continue;
		if(l < 48)
			continue;
		if(!checkpvs(spawn_spot.origin, p))
			continue;
		RandomSelection_Add(p, 0, string_null, 1, 1);
	}

	if(RandomSelection_chosen_ent)
	{
		spawn_spot.msnt_lookat = RandomSelection_chosen_ent;
		spawn_score_x += SPAWN_PRIO_NEAR_TEAMMATE_FOUND;
	}
	else if(self.team == spawn_spot.team)
		spawn_score_x += SPAWN_PRIO_NEAR_TEAMMATE_SAMETEAM; // prefer same team, if we can't find a spawn near teammate

	return 0;
}

MUTATOR_HOOKFUNCTION(msnt_PlayerSpawn)
{
	if(spawn_spot.msnt_lookat)
	{
		self.angles = vectoangles(spawn_spot.msnt_lookat.origin - self.origin);
		self.angles_x = -self.angles_x;
		/*
		sprint(self, "You should be looking at ", spawn_spot.msnt_lookat.netname, "^7.\n");
		sprint(self, "distance: ", vtos(spawn_spot.msnt_lookat.origin - self.origin), "\n");
		sprint(self, "angles: ", vtos(self.angles), "\n");
		*/
	}

	return 0;
}

MUTATOR_DEFINITION(mutator_spawn_near_teammate)
{
	MUTATOR_HOOK(Spawn_Score, msnt_Spawn_Score, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, msnt_PlayerSpawn, CBC_ORDER_ANY);

	return 0;
}
