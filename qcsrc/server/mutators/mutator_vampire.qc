MUTATOR_HOOKFUNCTION(vampire_PlayerDamage)
{
	if(time < self.spawnshieldtime)
		return 0;
	if(frag_attacker == frag_target)
		return 0;
		
	// gain health from damage dealt to enemies
	frag_attacker.health = frag_attacker.health + bound(0, damage_take, self.health);
	return 0;
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
