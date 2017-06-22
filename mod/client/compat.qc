// this is to keep the mod compatible with the latest stable release
// should be cleaned up each release
STATIC_INIT(mod_compat_cvars)
{
	// we keep the keybindings, since stock uses a... more obstructive key
	if(getkeybind(K_F8) == "") { localcmd("\nbind f8 \"cl_cmd hud quickmenu\"\n"); }
	if(getkeybind(K_F9) == "") { localcmd("\nbind f9 \"cl_cmd hud minigame\"\n"); }

	if(!(cvar_type("g_xonoticversion") & CVAR_TYPEFLAG_EXISTS))
		localcmd("\nexec _xonotic_compat.cfg\n");
}
