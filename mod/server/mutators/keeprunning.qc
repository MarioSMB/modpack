REGISTER_MUTATOR(kr, cvar("g_keeprunning") && !g_cts);

AUTOCVAR_NOREF(g_keeprunning, bool, false, _("Just keep moving!"));

.float kr_timer;

MUTATOR_HOOKFUNCTION(kr, PlayerPreThink)
{
	entity player = M_ARGV(0, entity);

	// TODO: damage while in vehicle?
	if(IS_PLAYER(player))
	if(player.movement == '0 0 0' && vdist(player.velocity, <, 15) && !IS_DEAD(player) && time >= player.kr_timer && !player.vehicle)
	{
		if(player.event_damage)
			player.event_damage(player, player, player, 1, DEATH_ROT.m_id, player.origin, '0 0 0');
		player.kr_timer = time + 0.5 + random() * 0.5;
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
