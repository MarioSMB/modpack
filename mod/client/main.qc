bool autocvar_g_mod = true;

STATIC_INIT(mod_cvars)
{
	localcmd("set hud_panel_quickmenu_file quickmenu.txt\n");
}

REGISTER_MUTATOR(mutator_mod, cvar("g_mod"));

MUTATOR_HOOKFUNCTION(mutator_mod, BuildMutatorsString) {
    ret_string = strcat(ret_string, ":mod");
}

MUTATOR_HOOKFUNCTION(mutator_mod, BuildMutatorsPrettyString) {
    ret_string = strcat(ret_string, ", Mod");
}
