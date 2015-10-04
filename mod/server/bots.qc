MUTATOR_HOOKFUNCTION(mutator_mod, BotShouldAttack)
{
	if(checkentity.alpha <= 0.5 && checkentity.alpha != 0)
		return true;
	return false;
}
