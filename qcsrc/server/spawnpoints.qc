float SpawnPoint_Send(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_SPAWNPOINT);

	WriteByte(MSG_ENTITY, self.team);
	WriteShort(MSG_ENTITY, self.origin_x);
	WriteShort(MSG_ENTITY, self.origin_y);
	WriteShort(MSG_ENTITY, self.origin_z);

	return TRUE;
}

float SpawnEvent_Send(entity to, float sf)
{
	float send;
	
	WriteByte(MSG_ENTITY, ENT_CLIENT_SPAWNEVENT);

	if(autocvar_g_spawn_alloweffects)
	{
		WriteByte(MSG_ENTITY, num_for_edict(self.owner));
		WriteShort(MSG_ENTITY, self.owner.origin_x);
		WriteShort(MSG_ENTITY, self.owner.origin_y);
		WriteShort(MSG_ENTITY, self.owner.origin_z);
		send = TRUE;
	}
	else if((to == self.owner) || (IS_SPEC(to) && (to.enemy == self.owner)) )
	{
		WriteByte(MSG_ENTITY, 0);
		send = TRUE;
	}
	else { send = FALSE; }

	return send;
}

void spawnpoint_use()
{
	if(teamplay)
	if(have_team_spawns > 0)
	{
		self.team = activator.team;
		some_spawn_has_been_used = 1;
	}
	print("spawnpoint was used!\n");
}

void relocate_spawnpoint()
{
    // nudge off the floor
    setorigin(self, self.origin + '0 0 1');

    tracebox(self.origin, PL_MIN, PL_MAX, self.origin, TRUE, self);
    if (trace_startsolid)
    {
        vector o;
        o = self.origin;
        self.mins = PL_MIN;
        self.maxs = PL_MAX;
        if (!move_out_of_solid(self))
            objerror("could not get out of solid at all!");
        print("^1NOTE: this map needs FIXING. Spawnpoint at ", vtos(o - '0 0 1'));
        print(" needs to be moved out of solid, e.g. by '", ftos(self.origin_x - o_x));
        print(" ", ftos(self.origin_y - o_y));
        print(" ", ftos(self.origin_z - o_z), "'\n");
        if (autocvar_g_spawnpoints_auto_move_out_of_solid)
        {
            if (!spawnpoint_nag)
                print("\{1}^1NOTE: this map needs FIXING (it contains spawnpoints in solid, see server log)\n");
            spawnpoint_nag = 1;
        }
        else
        {
            setorigin(self, o);
            self.mins = self.maxs = '0 0 0';
            objerror("player spawn point in solid, mapper sucks!\n");
            return;
        }
    }

    self.use = spawnpoint_use;
    self.team_saved = self.team;
    if (!self.cnt)
        self.cnt = 1;

    if (have_team_spawns != 0)
        if (self.team)
            have_team_spawns = 1;
    have_team_spawns_forteam[self.team] = 1;

    if (autocvar_r_showbboxes)
    {
        // show where spawnpoints point at too
        makevectors(self.angles);
        entity e;
        e = spawn();
        e.classname = "info_player_foo";
        setorigin(e, self.origin + v_forward * 24);
        setsize(e, '-8 -8 -8', '8 8 8');
        e.solid = SOLID_TRIGGER;
    }

	// Don't show team spawns in non-team matches,
	// and don't show non-team spawns in team matches.
	// (Unless useallspawns is activated)
	if(
		!(
			( // if this passes, there is a DM spawn on a team match
				teamplay
				&& (self.team != NUM_TEAM_1)
				&& (self.team != NUM_TEAM_2)
				&& (self.team != NUM_TEAM_3)
				&& (self.team != NUM_TEAM_4)
			)
			||
			( // if this passes, there is a team spawn on a DM match
				!teamplay
				&&
				(
					(self.team == NUM_TEAM_1)
					|| (self.team == NUM_TEAM_2)
					|| (self.team == NUM_TEAM_3)
					|| (self.team == NUM_TEAM_4)
				)
			)
		)
		||
		autocvar_g_spawn_useallspawns
	)
	{ Net_LinkEntity(self, FALSE, 0, SpawnPoint_Send); }
}

void spawnfunc_info_player_survivor (void)
{
	spawnfunc_info_player_deathmatch();
}

void spawnfunc_info_player_start (void)
{
	spawnfunc_info_player_deathmatch();
}

void spawnfunc_info_player_deathmatch (void)
{
	self.classname = "info_player_deathmatch";
	relocate_spawnpoint();
}

// Returns:
//   _x: prio (-1 if unusable)
//   _y: weight
vector Spawn_Score(entity spot, float mindist, float teamcheck)
{
	float shortest, thisdist;
	float prio;
	entity player;

	prio = 0;

	// filter out spots for the wrong team
	if(teamcheck >= 0)
		if(spot.team != teamcheck)
			return '-1 0 0';

	if(race_spawns)
		if(spot.target == "")
			return '-1 0 0';

	if(IS_REAL_CLIENT(self))
	{
		if(spot.restriction == 1)
			return '-1 0 0';
	}
	else
	{
		if(spot.restriction == 2)
			return '-1 0 0';
	}

	shortest = vlen(world.maxs - world.mins);
	FOR_EACH_PLAYER(player) if (player != self)
	{
		thisdist = vlen(player.origin - spot.origin);
		if (thisdist < shortest)
			shortest = thisdist;
	}
	if(shortest > mindist)
		prio += SPAWN_PRIO_GOOD_DISTANCE;

	spawn_score = prio * '1 0 0' + shortest * '0 1 0';
	spawn_spot = spot;

	// filter out spots for assault
	if(spot.target != "") {
		entity ent;
		float found;

		found = 0;
		for(ent = world; (ent = find(ent, targetname, spot.target)); )
		{
			++found;
			if(ent.spawn_evalfunc)
			{
				entity oldself = self;
				self = ent;
				spawn_score = ent.spawn_evalfunc(oldself, spot, spawn_score);
				self = oldself;
				if(spawn_score_x < 0)
					return spawn_score;
			}
		}

		if(!found)
		{
			dprint("WARNING: spawnpoint at ", vtos(spot.origin), " could not find its target ", spot.target, "\n");
			return '-1 0 0';
		}
	}

	MUTATOR_CALLHOOK(Spawn_Score);
	return spawn_score;
}

void Spawn_ScoreAll(entity firstspot, float mindist, float teamcheck)
{
	entity spot;
	for(spot = firstspot; spot; spot = spot.chain)
		spot.spawnpoint_score = Spawn_Score(spot, mindist, teamcheck);
}

entity Spawn_FilterOutBadSpots(entity firstspot, float mindist, float teamcheck)
{
	entity spot, spotlist, spotlistend;

	spotlist = world;
	spotlistend = world;

	Spawn_ScoreAll(firstspot, mindist, teamcheck);

	for(spot = firstspot; spot; spot = spot.chain)
	{
		if(spot.spawnpoint_score_x >= 0) // spawning allowed here
		{
			if(spotlistend)
				spotlistend.chain = spot;
			spotlistend = spot;
			if(!spotlist)
				spotlist = spot;
		}
	}
	if(spotlistend)
		spotlistend.chain = world;

	return spotlist;
}

entity Spawn_WeightedPoint(entity firstspot, float lower, float upper, float exponent)
{
	// weight of a point: bound(lower, mindisttoplayer, upper)^exponent
	// multiplied by spot.cnt (useful if you distribute many spawnpoints in a small area)
	entity spot;

	RandomSelection_Init();
	for(spot = firstspot; spot; spot = spot.chain)
		RandomSelection_Add(spot, 0, string_null, pow(bound(lower, spot.spawnpoint_score_y, upper), exponent) * spot.cnt, (spot.spawnpoint_score_y >= lower) * 0.5 + spot.spawnpoint_score_x);

	return RandomSelection_chosen_ent;
}

/*
=============
SelectSpawnPoint

Finds a point to respawn
=============
*/
entity SelectSpawnPoint (float anypoint)
{
	float teamcheck;
	entity spot, firstspot;

	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;

	if(anypoint || autocvar_g_spawn_useallspawns)
		teamcheck = -1;
	else if(have_team_spawns > 0)
	{
		if(have_team_spawns_forteam[self.team] == 0)
		{
			// we request a spawn for a team, and we have team
			// spawns, but that team has no spawns?
			if(have_team_spawns_forteam[0])
				// try noteam spawns
				teamcheck = 0;
			else
				// if not, any spawn has to do
				teamcheck = -1;
		}
		else
			teamcheck = self.team; // MUST be team
	}
	else if(have_team_spawns == 0 && have_team_spawns_forteam[0])
		teamcheck = 0; // MUST be noteam
	else
		teamcheck = -1;
		// if we get here, we either require team spawns but have none, or we require non-team spawns and have none; use any spawn then


	// get the entire list of spots
	firstspot = findchain(classname, "info_player_deathmatch");
	// filter out the bad ones
	// (note this returns the original list if none survived)
	if(anypoint)
	{
		spot = Spawn_WeightedPoint(firstspot, 1, 1, 1);
	}
	else
	{
		float mindist;
		if(g_arena && arena_roundbased)
			mindist = 800;
		else
			mindist = 100;
		firstspot = Spawn_FilterOutBadSpots(firstspot, mindist, teamcheck);

		// there is 50/50 chance of choosing a random spot or the furthest spot
		// (this means that roughly every other spawn will be furthest, so you
		// usually won't get fragged at spawn twice in a row)
		if (random() > autocvar_g_spawn_furthest)
			spot = Spawn_WeightedPoint(firstspot, 1, 1, 1);
		else
			spot = Spawn_WeightedPoint(firstspot, 1, 5000, 5); // chooses a far far away spawnpoint
	}

	if (!spot)
	{
		if(autocvar_spawn_debug)
			GotoNextMap(0);
		else
		{
			if(some_spawn_has_been_used)
				return world; // team can't spawn any more, because of actions of other team
			else
				error("Cannot find a spawn point - please fix the map!");
		}
	}

	return spot;
}
