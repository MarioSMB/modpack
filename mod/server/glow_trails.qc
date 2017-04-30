AUTOCVAR(g_glow_trails, bool, false, "Show glowy trails behind players");
AUTOCVAR(g_glow_trails_teamcolor, bool, true, "Color the trails by player's team (or color in non-teamplay) instead of a set color");
AUTOCVAR(g_glow_trails_size, int, 25, "Length of the trails");
AUTOCVAR(g_glow_trails_color, int, 254, "Color of the trails if team coloring is off");

REGISTER_MUTATOR(glow_trails, true); // always enable, allow toggling midmatch

MUTATOR_HOOKFUNCTION(glow_trails, PlayerPreThink)
{
	if(!autocvar_g_glow_trails)
		return;

	entity player = M_ARGV(0, entity);
	player.glow_trail = autocvar_g_glow_trails;
	player.glow_size = autocvar_g_glow_trails_size;

	if(autocvar_g_glow_trails_teamcolor)
	{
		if(teamplay)
		{
			switch(player.team)
			{
				case NUM_TEAM_1: player.glow_color = 251; break;
				case NUM_TEAM_2: player.glow_color = 210; break;
				case NUM_TEAM_3: player.glow_color = 110; break;
				case NUM_TEAM_4: player.glow_color = 145; break;
				default:		 player.glow_color = 254; break;
			}
		}
		else
			player.glow_color = player.clientcolors; // TODO
	}
	else
		player.glow_color = autocvar_g_glow_trails_color;
}

MUTATOR_HOOKFUNCTION(glow_trails, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);

	player.glow_trail = false; // just disable it for now
}
