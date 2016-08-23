STATIC_INIT(mod_cvars)
{
	localcmd("set hud_panel_minigamemenu 1\n");
}

STATIC_INIT_LATE(mod_cvars_override)
{
	localcmd("\nset hud_panel_quickmenu_file quickmenu.txt\n");
}

REGISTER_MUTATOR(mutator_mod, true);

MUTATOR_HOOKFUNCTION(mutator_mod, BuildMutatorsString)
{
    M_ARGV(0, string) = strcat(M_ARGV(0, string), ":mod");
}
