MUTATOR_HOOKFUNCTION(mutator_mod, Player_ChangeTeam)
{
	if(!IS_CLIENT(self))
		stuffcmd(self, "\nsettemp _cl_rate 133337\n");
	return false;
}
