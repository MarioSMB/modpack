MUTATOR_HOOKFUNCTION(mutator_mod, FormatMessage)
{
	entity player = M_ARGV(0, entity);

	switch(M_ARGV(1, string)) // escape
	{
		case "H": M_ARGV(2, string) = sprintf("%s%d", rgb_to_hexcolor(('1 0 0' * player.health / g_pickup_healthsmall_max) + ('0 0 1' * ( player.health - 100) / g_pickup_healthsmall_max)), rint(player.health)); break;
		case "A": M_ARGV(2, string) = sprintf("%s%d", rgb_to_hexcolor(('0 2 0' * player.armorvalue / g_pickup_armorsmall_max) + ('0 0 1' * ( player.armorvalue - 100) / g_pickup_armorsmall_max)), rint(player.armorvalue)); break;
	}
}
