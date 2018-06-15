// this is to keep the mod compatible with the latest stable release
// should be cleaned up each release
STATIC_INIT(mod_compat_cvars)
{
	// we need this until after 0.8.3!
	if(getkeybind(K_F8) == "") { localcmd("\nbind f8 \"cl_cmd hud quickmenu\"\n"); }
}
