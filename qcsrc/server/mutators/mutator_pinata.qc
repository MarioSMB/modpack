MUTATOR_HOOKFUNCTION(pinata_PlayerDies)
{
	float j;
	for(j = WEP_FIRST; j <= WEP_LAST; ++j)
	if(self.weapons & WepSet_FromWeapon(j))
	if(self.switchweapon != j)
	if(W_IsWeaponThrowable(j))
		W_ThrowNewWeapon(self, j, FALSE, self.origin + (self.mins + self.maxs) * 0.5, randomvec() * 175 + '0 0 325');
		
	return TRUE;
}

MUTATOR_HOOKFUNCTION(pinata_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":Pinata");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(pinata_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Piñata");
	return FALSE;
}

MUTATOR_DEFINITION(mutator_pinata)
{
	MUTATOR_HOOK(PlayerDies, pinata_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, pinata_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, pinata_BuildMutatorsPrettyString, CBC_ORDER_ANY);

	return FALSE;
}
