MUTATOR_HOOKFUNCTION(invincibleprojectiles_EditProjectile)
{
	if(other.health)
	{
		// disable health which in effect disables damage calculations
		other.health = 0;
	}
	return 0;
}

MUTATOR_HOOKFUNCTION(invincibleprojectiles_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":InvincibleProjectiles");
	return 0;
}

MUTATOR_HOOKFUNCTION(invincibleprojectiles_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Invincible Projectiles");
	return 0;
}

MUTATOR_DEFINITION(mutator_invincibleprojectiles)
{
	MUTATOR_HOOK(EditProjectile, invincibleprojectiles_EditProjectile, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, invincibleprojectiles_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, invincibleprojectiles_BuildMutatorsPrettyString, CBC_ORDER_ANY);

	return 0;
}
