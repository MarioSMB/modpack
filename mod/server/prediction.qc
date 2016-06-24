AUTOCVAR(g_physics_predictall, bool, false, "Allow prediction for all move types (may have some issues, requires post-0.8.1 DarkPlaces engine on the server)");

REGISTER_MUTATOR(prediction, true); // always enable, allow toggling midmatch

MUTATOR_HOOKFUNCTION(prediction, PlayerPhysics)
{
	if(autocvar_g_physics_predictall)
	{
		entity player = M_ARGV(0, entity);
		if(player.disableclientprediction == -1 || !player.disableclientprediction)
		if(player.movetype != MOVETYPE_FOLLOW && !player.vehicle && !gameover && !IS_SPEC(player)) // unpredictable
			player.disableclientprediction = -1; // should be early enough for this to take effect
	}
}

MUTATOR_HOOKFUNCTION(prediction, PlayerPreThink)
{
	// we need to repeat some of the checks here, as physics isn't called on the server after a certain point
	if(autocvar_g_physics_predictall)
	{
		entity player = M_ARGV(0, entity);
		if(gameover || IS_SPEC(player))
			player.disableclientprediction = 0;
	}
}

MUTATOR_HOOKFUNCTION(prediction, VehicleEnter)
{
	if(autocvar_g_physics_predictall)
	{
		entity player = M_ARGV(0, entity);
		player.disableclientprediction = 0; // no prediction for vehicles (yet)
	}
}
