AUTOCVAR(_independent_players_list, string, "", "List of players who cannot physically interact with anyone else, for the troublemakers who need not be banned");

REGISTER_MUTATOR(independent_players, true); // always enabled, allows toggling mid-match

MUTATOR_HOOKFUNCTION(independent_players, PlayerSpawn)
{
	if(g_prophunt)
		return;
	entity player = M_ARGV(0, entity);
	if(autocvar__independent_players_list != "" && PlayerInList(player, autocvar__independent_players_list))
		MAKE_INDEPENDENT_PLAYER(player);
}
