MUTATOR_HOOKFUNCTION(mutator_mod, BotShouldAttack)
{
	entity targ = M_ARGV(1, entity);

	if(targ.alpha <= 0.5 && targ.alpha != 0)
		return true;
}
