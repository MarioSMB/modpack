vector Get_Num_Color (float x, float maxvalue)
{
	vector color = '1 0 0';
	if(x >= maxvalue)
		color.x = 1.1 + (x-150)*0.02 * 0.1;
	if(x > maxvalue * 0.75)
		color.x = 0.9 + (x-150)*0.02 * 0.1;
	else if(x > maxvalue * 0.5)
		color.x = 1 - (x-100)*0.02 * 0.1;
	else if(x > maxvalue * 0.25)
		color.x = 0.2 + (x-50)*0.02 * 0.8;
	else
		color.x = (x-20)*90/27/100 * 0.2;

	return color;
}

MUTATOR_HOOKFUNCTION(mutator_mod, FormatMessage)
{
	switch(format_escape)
	{
		case "H": format_replacement = strcat(rgb_to_hexcolor(Get_Num_Color(floor(self.health + 1), g_pickup_healthsmall_max)), ftos(floor(self.health + 1))); break;
	}
	return false;
}
