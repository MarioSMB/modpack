// this is to keep the mod compatible with the latest stable release
// should be cleaned up each release
STATIC_INIT(mod_compat_cvars)
{
	registercvar("g_vampirehook", "0");
	registercvar("g_vampirehook_damage", "2");
	registercvar("g_vampirehook_damagerate", "0.2");
	registercvar("g_vampirehook_health_steal", "2");
	registercvar("g_vampirehook_teamheal", "1");

	registercvar("g_breakablehook", "0");
	registercvar("g_breakablehook_owner", "0");

	registercvar("sv_minigames", "0");
	registercvar("sv_minigames_observer", "1");
	registercvar("sv_minigames_pong_paddle_size", "0.3");
	registercvar("sv_minigames_pong_paddle_speed", "1");
	registercvar("sv_minigames_pong_ball_wait", "1");
	registercvar("sv_minigames_pong_ball_speed", "1.5");
	registercvar("sv_minigames_pong_ball_radius", "0.03125");
	registercvar("sv_minigames_pong_ball_number", "1");
	registercvar("sv_minigames_pong_ai_thinkspeed", "0.1");
	registercvar("sv_minigames_pong_ai_tolerance", "0.33");
}
