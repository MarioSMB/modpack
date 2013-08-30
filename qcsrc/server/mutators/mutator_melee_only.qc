MUTATOR_HOOKFUNCTION(melee_SetStartItems)
{
	start_ammo_shells = 0;
	warmup_start_ammo_shells = 0;
	
	start_weapons = WEPSET_SHOTGUN;
	warmup_start_weapons = WEPSET_SHOTGUN;
		
	return FALSE;
}

MUTATOR_HOOKFUNCTION(melee_FilterItem)
{
	switch (self.items)
	{
		case IT_5HP:
		case IT_ARMOR_SHARD:
			return FALSE;
	}
	
	return TRUE;
}

MUTATOR_HOOKFUNCTION(melee_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":MeleeOnly");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(melee_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Melee Only Arena");
	return FALSE;
}

MUTATOR_DEFINITION(mutator_melee_only)
{
	MUTATOR_HOOK(SetStartItems, melee_SetStartItems, CBC_ORDER_ANY);
	MUTATOR_HOOK(FilterItem, melee_FilterItem, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, melee_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, melee_BuildMutatorsPrettyString, CBC_ORDER_ANY);

	return FALSE;
}
