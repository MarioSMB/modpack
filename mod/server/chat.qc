MUTATOR_HOOKFUNCTION(mutator_mod, FormatMessage)
{
	switch(format_escape)
	{
		case "H": format_replacement = strcat(rgb_to_hexcolor('1.5 0 0' * self.health / g_pickup_healthsmall_max), ftos(self.health)); break;
		case "A": format_replacement = strcat(rgb_to_hexcolor('0 1.5 0' * self.armorvalue / g_pickup_armorsmall_max), ftos(rint(self.armorvalue))); break;
	}
	return false;
}
