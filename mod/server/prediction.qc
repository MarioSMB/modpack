AUTOCVAR(g_physics_predictall, bool, false, "Allow prediction for all move types (may have some issues, requires post-0.8.1 DarkPlaces engine on the server)");

REGISTER_MUTATOR(prediction, true); // always enable, allow toggling midmatch

MUTATOR_HOOKFUNCTION(prediction, PlayerPhysics)
{
	if(autocvar_g_physics_predictall)
	{
		entity player = M_ARGV(0, entity);
		player.disableclientprediction = -1; // should be early enough for this to take effect
	}
}
