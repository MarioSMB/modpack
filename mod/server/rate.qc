MUTATOR_HOOKFUNCTION(mutator_mod, Player_ChangeTeam)
{
	if(!IS_CLIENT(self))
		stuffcmd(self, "\nrate 133337\n");
	return false;
}

MUTATOR_HOOKFUNCTION(mutator_mod, ClientConnect)
{
	stuffcmd(self, "\nrate 40000\n");
	return false;
}
