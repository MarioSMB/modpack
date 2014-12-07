void dm_DelayedInit()
{
}

MUTATOR_HOOKFUNCTION(dm_CountFrags)
{
	// announce remaining frags
	return TRUE;
}

MUTATOR_DEFINITION(gamemode_deathmatch)
{
	MUTATOR_HOOK(Scores_CountFragsRemaining, dm_CountFrags, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		if(time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");
		InitializeEntity(world, dm_DelayedInit, INITPRIO_GAMETYPE);
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		// we actually cannot roll back dm_Initialize here
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
