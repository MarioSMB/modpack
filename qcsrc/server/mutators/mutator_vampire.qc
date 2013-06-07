MUTATOR_HOOKFUNCTION(vampire_PlayerDamage)
{
	if(time >= frag_target.spawnshieldtime)
	if(frag_target != frag_attacker)
	if(frag_target.deadflag == DEAD_NO)
	{
		frag_attacker.health += bound(0, damage_take, frag_target.health);
		frag_attacker.health = bound(0, frag_attacker.health, autocvar_g_balance_health_limit);
	}
		
	return FALSE;
}

MUTATOR_HOOKFUNCTION(vampire_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":Vampire");
	return 0;
}

MUTATOR_HOOKFUNCTION(vampire_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Vampire");
	return 0;
}

MUTATOR_DEFINITION(mutator_vampire)
{
	MUTATOR_HOOK(PlayerDamage_SplitHealthArmor, vampire_PlayerDamage, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, vampire_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, vampire_BuildMutatorsPrettyString, CBC_ORDER_ANY);

	return 0;
}
