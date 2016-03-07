REGISTER_MUTATOR(su, cvar("g_spawn_unique"));

AUTOCVAR(g_spawn_unique, bool, false, _("Prevent spawning at the same spawn point twice if possible"));

.entity su_last_point;

MUTATOR_HOOKFUNCTION(su, PlayerSpawn)
{
	self.su_last_point = spawn_spot;
	return false;
}

MUTATOR_HOOKFUNCTION(su, Spawn_Score)
{
	// give it a low score if we've already been there
	if(spawn_spot == self.su_last_point)
		spawn_score = '0.1 0 0';
	return false;
}
