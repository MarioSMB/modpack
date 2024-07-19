//FEATURE: Random Spawns mutator, spawn at random locations throughout the map

AUTOCVAR(g_random_spawns, bool, false, "Spawn at random locations instead of spawn points");
AUTOCVAR(g_random_spawns_attempts, int, 10, "Try this many times to find a suitable location");
REGISTER_MUTATOR(random_spawns, autocvar_g_random_spawns);

MUTATOR_HOOKFUNCTION(random_spawns, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);

	vector oldang = player.angles;

	if(MoveToRandomMapLocation(player, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, autocvar_g_random_spawns_attempts, 1024, 256))
	{
		player.angles = oldang;
		player.angles_z = 0;
	}
}
