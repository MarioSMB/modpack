//FEATURE: Keep Running mutator which slowly kills players who stand still, a more extreme version of campcheck

AUTOCVAR(g_keeprunning, bool, false, "Just keep moving!");
AUTOCVAR(g_keeprunning_minhealth, int, 0, "");
AUTOCVAR(g_keeprunning_rot_rate, float, 4, "");

REGISTER_MUTATOR(kr, autocvar_g_keeprunning && !g_cts);

MUTATOR_HOOKFUNCTION(kr, PlayerRegen)
{
	entity player = M_ARGV(0, entity);

	if(player.movement == '0 0 0' && vdist(player.velocity, <, 15) && !IS_DEAD(player) && !player.vehicle)
	{
		M_ARGV(3, float) *= autocvar_g_keeprunning_rot_rate;
		M_ARGV(10, float) = autocvar_g_keeprunning_minhealth;
	}
}

MUTATOR_HOOKFUNCTION(kr, BuildMutatorsString)
{
	M_ARGV(0, string) = strcat(M_ARGV(0, string), ":KR");
}

MUTATOR_HOOKFUNCTION(kr, BuildMutatorsPrettyString)
{
	M_ARGV(0, string) = strcat(M_ARGV(0, string), ", Keep Running!");
}
