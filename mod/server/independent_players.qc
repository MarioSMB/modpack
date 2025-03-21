AUTOCVAR(_independent_players_list, string, "", "Enable to allow passing through teammates, requires sv_qcphysics and a compatible engine");

REGISTER_MUTATOR(independent_players, true); // always enabled, allows toggling mid-match

MUTATOR_HOOKFUNCTION(independent_players, PlayerSpawn)
{
	if(g_prophunt)
		return;
	entity player = M_ARGV(0, entity);
	if(autocvar__independent_players_list != "" && PlayerInList(player, autocvar__independent_players_list))
		MAKE_INDEPENDENT_PLAYER(player);
}
