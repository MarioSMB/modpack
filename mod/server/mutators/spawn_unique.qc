REGISTER_MUTATOR(su, cvar("g_spawn_unique"));

AUTOCVAR_NOREF(g_spawn_unique, bool, false, _("Prevent spawning at the same spawn point twice if possible"));

.entity su_last_point;

MUTATOR_HOOKFUNCTION(su, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);

	player.su_last_point = M_ARGV(1, entity); // spot
}

MUTATOR_HOOKFUNCTION(su, Spawn_Score)
{
	entity player = M_ARGV(0, entity);

	// give it a low score if we've already been there
	if(M_ARGV(1, entity) == player.su_last_point) // spot
		M_ARGV(2, vector) = '0.1 0 0'; // score
}
