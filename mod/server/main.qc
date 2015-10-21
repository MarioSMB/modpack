AUTOCVAR_SAVE(cl_nodamagetext,                    bool,   false,      _("Disabler for damage text"));

STATIC_INIT(mod_cvars)
{
	if(!cvar("cl_nodamagetext"))
		localcmd("set cl_damagetext 1\n");
	localcmd("set hud_panel_minigamemenu 1\n");

	registercvar("hud_panel_quickmenu_file", "quickmenu.txt");
}

STATIC_INIT_LATE(mod_cvars_override)
{
	localcmd("\nunset hud_panel_quickmenu_file\nhud_panel_quickmenu_file quickmenu.txt\n");
}

REGISTER_MUTATOR(mutator_mod, true);

MUTATOR_HOOKFUNCTION(mutator_mod, BuildMutatorsString) {
    ret_string = strcat(ret_string, ":mod");
}

MUTATOR_HOOKFUNCTION(mutator_mod, BuildMutatorsPrettyString) {
    ret_string = strcat(ret_string, ", Mod");
}
