float gravity_delay;
float old_gravity;
MUTATOR_HOOKFUNCTION(gravity_PlayerPhysics)
{
	if(gameover) return FALSE;
	if(time < gravity_delay) return FALSE;
	
    if(random() > autocvar_g_random_gravity_negative_chance) 
        cvar_set("sv_gravity", ftos(bound(autocvar_g_random_gravity_min, random() - random() * -autocvar_g_random_gravity_negative, autocvar_g_random_gravity_max)));
    else
        cvar_set("sv_gravity", ftos(bound(autocvar_g_random_gravity_min, random() * autocvar_g_random_gravity_positive, autocvar_g_random_gravity_max)));
	
	gravity_delay = time + autocvar_g_random_gravity_delay; 
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(gravity_MatchEnd)
{
	// attempt to restore old gravity
	cvar_set("sv_gravity", ftos(old_gravity));

	return FALSE;
}

MUTATOR_HOOKFUNCTION(gravity_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":RG");
	return 0;
}

MUTATOR_HOOKFUNCTION(gravity_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Random Gravity");
	return 0;
}

MUTATOR_DEFINITION(mutator_random_gravity)
{
	MUTATOR_HOOK(PlayerPhysics, gravity_PlayerPhysics, CBC_ORDER_ANY);
	MUTATOR_HOOK(MatchEnd, gravity_MatchEnd, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, gravity_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, gravity_BuildMutatorsPrettyString, CBC_ORDER_ANY);
	
	MUTATOR_ONADD
	{
		old_gravity = cvar("sv_gravity");
	}
	
	MUTATOR_ONREMOVE
	{
		cvar_set("sv_gravity", ftos(old_gravity));
	}

	return FALSE;
}
