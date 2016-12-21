STATIC_INIT(mod_cvars)
{
	localcmd("set hud_panel_minigamemenu 1\n");
}

STATIC_INIT_LATE(mod_cvars_override)
{
	localcmd("\nset hud_panel_quickmenu_file quickmenu.txt\n");

	localcmd("\nalias ignore \"cmd ignore ${* ?}\"\n");
	localcmd("\nalias unignore \"cmd unignore ${* ?}\"\n");

	registercvar("_rrestarted", "0");

	if(!cvar("_rrestarted"))
	{
		cvar_set("_rrestarted", "1");
		localcmd("\ndefer 1 r_restart\n");
	}
}

REGISTER_MUTATOR(mutator_mod, true);

MUTATOR_HOOKFUNCTION(mutator_mod, BuildMutatorsString)
{
    M_ARGV(0, string) = strcat(M_ARGV(0, string), ":mod");
}
