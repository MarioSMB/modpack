AUTOCVAR_SAVE(cl_nodamagetext,	bool,   false,      _("Disabler for damage text"));

STATIC_INIT(mod_cvars)
{
	if(!cvar("cl_nodamagetext"))
		localcmd("set cl_damagetext 1\n");
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

MUTATOR_HOOKFUNCTION(mutator_mod, BuildGameplayTipsString, CBC_ORDER_LAST)
{
    M_ARGV(0, string) = strcat(M_ARGV(0, string), "\n\n ^7Running the SMB mod pack\n^3https://github.com/MarioSMB/modpack");
}
