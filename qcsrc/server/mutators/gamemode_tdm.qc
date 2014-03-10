/*QUAKED spawnfunc_tdm_team (0 .5 .8) (-16 -16 -24) (16 16 32)
Team declaration for TDM gameplay, this allows you to decide what team names and control point models are used in your map.
Note: If you use spawnfunc_tdm_team entities you must define at least 2!  However, unlike domination, you don't need to make a blank one too.
Keys:
"netname" Name of the team (for example Red, Blue, Green, Yellow, Life, Death, Offense, Defense, etc)...
"cnt" Scoreboard color of the team (for example 4 is red and 13 is blue)... */
void spawnfunc_tdm_team()
{
	if(!g_tdm) { remove(self); return; }

	self.classname = "tdm_team";
	self.team = self.cnt + 1;
}

// code from here on is just to support maps that don't have team entities
void tdm_SpawnTeam (string teamname, float teamcolor)
{
	entity oldself;
	oldself = self;
	self = spawn();
	self.classname = "tdm_team";
	self.netname = teamname;
	self.cnt = teamcolor;

	spawnfunc_tdm_team();

	self = oldself;
}

void tdm_DelayedInit()
{
	// if no teams are found, spawn defaults
	if(find(world, classname, "tdm_team") == world)
	{
		print("No ""tdm_team"" entities found on this map, creating them anyway.\n");

		float numteams = autocvar_g_tdm_teams_override;

		if(numteams < 2 || numteams > 4) { numteams = autocvar_g_tdm_teams; }
		numteams = bound(2, numteams, 4);

		tdm_SpawnTeam("Red", NUM_TEAM_1 - 1);
		tdm_SpawnTeam("Blue", NUM_TEAM_2 - 1);
		if(numteams >= 3) { tdm_SpawnTeam("Yellow", NUM_TEAM_3 - 1); }
		if(numteams >= 4) { tdm_SpawnTeam("Pink", NUM_TEAM_4 - 1); }
	}
}

MUTATOR_HOOKFUNCTION(tdm_GetTeamCount)
{
	ret_string = "tdm_team";
	return TRUE;
}

MUTATOR_HOOKFUNCTION(tdm_CountFrags)
{
	// announce remaining frags
	return TRUE;
}

MUTATOR_DEFINITION(gamemode_tdm)
{
	MUTATOR_HOOK(GetTeamCount, tdm_GetTeamCount, CBC_ORDER_ANY);
	MUTATOR_HOOK(Scores_CountFragsRemaining, tdm_CountFrags, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		if(time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");
		InitializeEntity(world, tdm_DelayedInit, INITPRIO_GAMETYPE);
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		// we actually cannot roll back tdm_Initialize here
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
