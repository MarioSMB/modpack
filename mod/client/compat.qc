// this is to keep the mod compatible with the latest stable release
// should be cleaned up each release
STATIC_INIT(mod_compat_cvars)
{
	localcmd("set hud_panel_minigamemenu 1\n");

	// assume luma defaults
	localcmd("set hud_panel_quickmenu 1\n");
	localcmd("set hud_panel_quickmenu_pos \"0.600000 0.445000\"\n");
	localcmd("set hud_panel_quickmenu_size \"0.220000 0.240000\"\n");
	localcmd("set hud_panel_quickmenu_align 0\n");
	localcmd("set hud_panel_quickmenu_bg \"\"\n");
	localcmd("set hud_panel_quickmenu_bg_color \"\"\n");
	localcmd("set hud_panel_quickmenu_bg_color_team \"\"\n");
	localcmd("set hud_panel_quickmenu_bg_alpha \"\"\n");
	localcmd("set hud_panel_quickmenu_bg_border \"\"\n");
	localcmd("set hud_panel_quickmenu_bg_padding \"\"\n");
	localcmd("set hud_panel_quickmenu_align \"\"\n");
}
