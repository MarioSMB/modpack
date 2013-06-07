MUTATOR_HOOKFUNCTION(norecoil_PlayerThink)
{
	if(IS_PLAYER(self))
		self.punchangle = '0 0 0';
		
	return FALSE;
}

MUTATOR_HOOKFUNCTION(norecoil_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":norecoil");
	return FALSE;
}

MUTATOR_DEFINITION(mutator_norecoil)
{
	MUTATOR_HOOK(PlayerPreThink, norecoil_PlayerThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, norecoil_BuildMutatorsString, CBC_ORDER_ANY);

	return FALSE;
}
