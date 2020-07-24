//FEATURE: Teammate collisions, pass through teammates instead of bumping into them!

AUTOCVAR(g_team_collisions, bool, false, "Enable to allow passing through teammates, requires sv_qcphysics and a compatible engine");

REGISTER_MUTATOR(team_collisions, true); // always enabled, allows toggling mid-match

MUTATOR_HOOKFUNCTION(team_collisions, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);
	if(teamplay && autocvar_g_team_collisions && Team_IsValidTeam(player.team)) // allow toggling mid match
		player.clipgroup = player.team;
}

MUTATOR_HOOKFUNCTION(team_collisions, EditProjectile)
{
	entity player = M_ARGV(0, entity);
	entity proj = M_ARGV(1, entity);

	// in teamplay matches, make the projectile's clipgroup match the player's
	if(teamplay && autocvar_g_team_collisions && Team_IsValidTeam(player.team)) // allow toggling mid match
		proj.clipgroup = player.clipgroup;
}