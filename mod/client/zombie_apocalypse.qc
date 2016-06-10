REGISTER_MUTATOR(za, true);

MUTATOR_HOOKFUNCTION(za, WantEventchase)
{
	entity player = M_ARGV(0, entity);

	if(substring(player.model, 0, 16) == "models/monsters/")
		return true;
	return false;
}
