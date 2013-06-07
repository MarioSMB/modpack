.float bloodloss_timer;

MUTATOR_HOOKFUNCTION(bloodloss_PlayerThink)
{
	if(IS_PLAYER(self))
	if(self.health <= autocvar_g_bloodloss && self.deadflag == DEAD_NO)
	{
		self.BUTTON_CROUCH = TRUE;
		
		if(time >= self.bloodloss_timer)
		{
			self.event_damage(self, self, 1, DEATH_ROT, self.origin, '0 0 0');
			self.bloodloss_timer = time + 0.5 + random() * 0.5;
		}
	}
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(bloodloss_PlayerJump)
{
	if(self.health <= autocvar_g_bloodloss)
		return TRUE;
		
	return FALSE;
}

MUTATOR_HOOKFUNCTION(bloodloss_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":bloodloss");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(bloodloss_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Blood loss");
	return FALSE;
}

MUTATOR_DEFINITION(mutator_bloodloss)
{
	MUTATOR_HOOK(PlayerPreThink, bloodloss_PlayerThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerJump, bloodloss_PlayerJump, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, bloodloss_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, bloodloss_BuildMutatorsPrettyString, CBC_ORDER_ANY);

	return FALSE;
}
