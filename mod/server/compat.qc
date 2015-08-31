// this is to keep the mod compatible with the latest stable release
// should be cleaned up each release
STATIC_INIT(mod_compat_cvars)
{
	localcmd("\nset g_vampirehook 0\n");
	localcmd("\nset g_vampirehook_damage 2\n");
	localcmd("\nset g_vampirehook_damagerate 0.2\n");
	localcmd("\nset g_vampirehook_health_steal 2\n");
	localcmd("\nset g_vampirehook_teamheal 1\n");

	localcmd("\nset g_breakablehook 0\n");
	localcmd("\nset g_breakablehook_owner 0\n");
}
