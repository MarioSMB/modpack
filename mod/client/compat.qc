// this is to keep the mod compatible with the latest stable release
// should be cleaned up each release
STATIC_INIT(mod_compat_cvars)
{
	// assume luma defaults
	registercvar("hud_panel_quickmenu", "1");
	registercvar("hud_panel_quickmenu_pos", "0.600000 0.445000");
	registercvar("hud_panel_quickmenu_size", "0.220000 0.240000");
	registercvar("hud_panel_quickmenu_align", "0");
	registercvar("hud_panel_quickmenu_bg", "");
	registercvar("hud_panel_quickmenu_bg_color", "");
	registercvar("hud_panel_quickmenu_bg_color_team", "");
	registercvar("hud_panel_quickmenu_bg_alpha", "");
	registercvar("hud_panel_quickmenu_bg_border", "");
	registercvar("hud_panel_quickmenu_bg_padding", "");
	registercvar("hud_panel_quickmenu_align", "");
	registercvar("hud_panel_quickmenu_time", "5");

	if(getkeybind(K_F8) == "") { localcmd("\nbind f8 \"cl_cmd hud quickmenu\"\n"); }
	if(getkeybind(K_F9) == "") { localcmd("\nbind f9 \"cl_cmd hud minigame\"\n"); }

	localcmd("\nalias quickmenu \"cl_cmd hud quickmenu ${* ?}\"\n");
	localcmd("\nalias editmob \"cmd editmob ${* ?}\"\n");
	localcmd("\nalias spawnmob \"cmd editmob spawn ${* ?}\"\n");
	localcmd("\nalias killmob \"cmd editmob kill ${* ?}\"\n");

	// these need to be defined for minigames to work
	registercvar("hud_panel_minigameboard", "1");
	registercvar("hud_panel_minigameboard_pos", "0.22 0.15");
	registercvar("hud_panel_minigameboard_size", "0.50 0.60");
	registercvar("hud_panel_minigameboard_bg", "border_small");
	registercvar("hud_panel_minigameboard_bg_color", "");
	registercvar("hud_panel_minigameboard_bg_color_team", "");
	registercvar("hud_panel_minigameboard_bg_alpha", "");
	registercvar("hud_panel_minigameboard_bg_border", "");
	registercvar("hud_panel_minigameboard_bg_padding", "");
	
	registercvar("hud_panel_minigamestatus", "1");
	registercvar("hud_panel_minigamestatus_pos", "0.74 0.15");
	registercvar("hud_panel_minigamestatus_size", "0.2 0.60");
	registercvar("hud_panel_minigamestatus_bg", "border_small");
	registercvar("hud_panel_minigamestatus_bg_color", "");
	registercvar("hud_panel_minigamestatus_bg_color_team", "");
	registercvar("hud_panel_minigamestatus_bg_alpha", "");
	registercvar("hud_panel_minigamestatus_bg_border", "");
	registercvar("hud_panel_minigamestatus_bg_padding", "");
	
	registercvar("hud_panel_minigamehelp", "1");
	registercvar("hud_panel_minigamehelp_pos", "0.22 0.78");
	registercvar("hud_panel_minigamehelp_size", "0.50 0.20");
	registercvar("hud_panel_minigamehelp_bg", "");
	registercvar("hud_panel_minigamehelp_bg_color", "");
	registercvar("hud_panel_minigamehelp_bg_color_team", "");
	registercvar("hud_panel_minigamehelp_bg_alpha", "");
	registercvar("hud_panel_minigamehelp_bg_border", "");
	registercvar("hud_panel_minigamehelp_bg_padding", "");
	
	registercvar("hud_panel_minigamemenu", "0");
	registercvar("hud_panel_minigamemenu_pos", "0 0.26");
	registercvar("hud_panel_minigamemenu_size", "0.2 0.49");
	registercvar("hud_panel_minigamemenu_bg", "border_small");
	registercvar("hud_panel_minigamemenu_bg_color", "");
	registercvar("hud_panel_minigamemenu_bg_color_team", "");
	registercvar("hud_panel_minigamemenu_bg_alpha", "");
	registercvar("hud_panel_minigamemenu_bg_border", "");
	registercvar("hud_panel_minigamemenu_bg_padding", "");

	if(!(cvar_type("g_xonoticversion") & CVAR_TYPEFLAG_EXISTS))
		localcmd("\nexec _xonotic_compat.cfg\n");
}
