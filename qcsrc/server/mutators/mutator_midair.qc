.float midair_shieldtime;

MUTATOR_HOOKFUNCTION(midair_PlayerDamage)
{
	if(IS_PLAYER(frag_attacker))
	if(IS_PLAYER(frag_target))
	if(time < self.midair_shieldtime)
		frag_damage = FALSE;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(midair_PlayerPowerups)
{
	if(time >= game_starttime)
	if(self.flags & FL_ONGROUND)
	{
		self.effects |= (EF_ADDITIVE | EF_FULLBRIGHT);
		self.midair_shieldtime = max(self.midair_shieldtime, time + autocvar_g_midair_shieldtime);
	}
		
	return FALSE;
}

MUTATOR_HOOKFUNCTION(midair_PlayerSpawn)
{
	if(IS_BOT_CLIENT(self))
		self.bot_moveskill = 0; // disable bunnyhopping

	return FALSE;
}

MUTATOR_HOOKFUNCTION(midair_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":midair");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(midair_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Midair");
	return FALSE;
}

MUTATOR_DEFINITION(mutator_midair)
{
	MUTATOR_HOOK(PlayerDamage_Calculate, midair_PlayerDamage, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPowerups, midair_PlayerPowerups, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, midair_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, midair_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, midair_BuildMutatorsPrettyString, CBC_ORDER_ANY);

	return FALSE;
}
