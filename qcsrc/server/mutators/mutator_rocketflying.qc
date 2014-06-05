MUTATOR_HOOKFUNCTION(rocketflying_EditProjectile)
{
	if(other.classname == "rocket" || other.classname == "mine")
	{
		// kill detonate delay of rockets
		other.spawnshieldtime = time;
	}
	return 0;
}

MUTATOR_HOOKFUNCTION(rocketflying_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":RocketFlying");
	return 0;
}

MUTATOR_HOOKFUNCTION(rocketflying_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Rocket Flying");
	return 0;
}

MUTATOR_DEFINITION(mutator_rocketflying)
{
	MUTATOR_HOOK(EditProjectile, rocketflying_EditProjectile, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, rocketflying_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, rocketflying_BuildMutatorsPrettyString, CBC_ORDER_ANY);

	return 0;
}
