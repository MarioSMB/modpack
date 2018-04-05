REGISTER_MUTATOR(stop_caz, true);

MUTATOR_HOOKFUNCTION(stop_caz, VoteCommand_Parse)
{
	entity caller = M_ARGV(0, entity);
	if(caller.netname == "caz")
		return MUT_VOTEPARSE_UNACCEPTABLE;
}
