MUTATOR_HOOKFUNCTION(mutator_mod, FormatMessage)
{
	switch(format_escape)
	{
		case "H": format_replacement = sprintf("%s%d", rgb_to_hexcolor('2 0 0' * (self.health / g_pickup_healthsmall_max)), rint(self.health)); break;
		case "A": format_replacement = sprintf("%s%d", rgb_to_hexcolor('0 2 0' * (self.armorvalue / g_pickup_armorsmall_max)), rint(self.armorvalue)); break;
	}
	return false;
}
