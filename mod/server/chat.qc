vector Get_Num_Color(float x, float maxvalue)
{
	vector color;
	if(x >= maxvalue) {
		color = '1 0 0';
	}
	else if(x > maxvalue * 0.75) {
		color.x = 0.9 + (x-150)*0.02 * 0.1; // red value between 0.9 -> 1
		color.y = 0.4 - (x-150)*0.02 * 0.4; //green value between 0.4 -> 0
		color.z = 0;
	}
	else if(x > maxvalue * 0.5) {
		color.x = 1 - (x-100)*0.02 * 0.6; //red value between 1 -> 0.4
		color.y = 1 - (x-100)*0.02 * 0.1; // green value between 1 -> 0.9
		color.z = 1 - (x-100)*0.02; // blue value between 1 -> 0
	}
	else if(x > maxvalue * 0.25) {
		color.x = 0.2 + (x-50)*0.02 * 0.8; // red value between 0.2 -> 1
		color.y = 1;
		color.z = 1;
	}
	else if(x > maxvalue * 0.1) {
		color.x = (x-20)*90/27/100; // red value between 0 -> 1
		color.y = (x-20)*90/27/100 * 0.2; // green value between 0 -> 0.2
		color.z = 1;
	}
	else {
		color.x = 1;
		color.y = 0;
		color.z = 0;
	}

	return color;
}

MUTATOR_HOOKFUNCTION(mutator_mod, FormatMessage)
{
	switch(format_escape)
	{
		case "H": format_replacement = strcat(rgb_to_hexcolor(Get_Num_Color((healtharmor_maxdamage(floor(self.health + 1), floor(self.armorvalue + 1), autocvar_g_balance_armor_blockpercent, DEATH_WEAPON.m_id)).x, g_pickup_healthsmall_max)), ftos(floor(self.health))); break;
	}
	return false;
}
