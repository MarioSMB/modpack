#define HUD_Write(s) fputs(fh, s)
// q: quoted, n: not quoted
#define HUD_Write_Cvar_n(cvar) HUD_Write(strcat("seta ", cvar, " ", cvar_string(cvar), "\n"))
#define HUD_Write_Cvar_q(cvar) HUD_Write(strcat("seta ", cvar, " \"", cvar_string(cvar), "\"\n"))
#define HUD_Write_PanelCvar_n(cvar_suf) HUD_Write_Cvar_n(strcat("hud_panel_", panel.panel_name, cvar_suf))
#define HUD_Write_PanelCvar_q(cvar_suf) HUD_Write_Cvar_q(strcat("hud_panel_", panel.panel_name, cvar_suf))
// Save the config
void HUD_Panel_ExportCfg(string cfgname)
{
	float fh;
	string filename = strcat("hud_", autocvar_hud_skin, "_", cfgname, ".cfg");
	fh = fopen(filename, FILE_WRITE);
	if(fh >= 0)
	{
		HUD_Write_Cvar_q("hud_skin");
		HUD_Write_Cvar_q("hud_panel_bg");
		HUD_Write_Cvar_q("hud_panel_bg_color");
		HUD_Write_Cvar_q("hud_panel_bg_color_team");
		HUD_Write_Cvar_q("hud_panel_bg_alpha");
		HUD_Write_Cvar_q("hud_panel_bg_border");
		HUD_Write_Cvar_q("hud_panel_bg_padding");
		HUD_Write_Cvar_q("hud_panel_fg_alpha");
		HUD_Write("\n");

		HUD_Write_Cvar_q("hud_dock");
		HUD_Write_Cvar_q("hud_dock_color");
		HUD_Write_Cvar_q("hud_dock_color_team");
		HUD_Write_Cvar_q("hud_dock_alpha");
		HUD_Write("\n");

		HUD_Write_Cvar_q("hud_progressbar_alpha");
		HUD_Write_Cvar_q("hud_progressbar_strength_color");
		HUD_Write_Cvar_q("hud_progressbar_shield_color");
		HUD_Write_Cvar_q("hud_progressbar_health_color");
		HUD_Write_Cvar_q("hud_progressbar_armor_color");
		HUD_Write_Cvar_q("hud_progressbar_fuel_color");
		HUD_Write_Cvar_q("hud_progressbar_nexball_color");
		HUD_Write_Cvar_q("hud_progressbar_speed_color");
		HUD_Write_Cvar_q("hud_progressbar_acceleration_color");
		HUD_Write_Cvar_q("hud_progressbar_acceleration_neg_color");
		HUD_Write("\n");

		HUD_Write_Cvar_q("_hud_panelorder");
		HUD_Write("\n");

		HUD_Write_Cvar_q("hud_configure_grid");
		HUD_Write_Cvar_q("hud_configure_grid_xsize");
		HUD_Write_Cvar_q("hud_configure_grid_ysize");
		HUD_Write("\n");

		// common cvars for all panels
		float i;
		for (i = 0; i < HUD_PANEL_NUM; ++i)
		{
			panel = hud_panel[i];

			HUD_Write_PanelCvar_n("");
			HUD_Write_PanelCvar_q("_pos");
			HUD_Write_PanelCvar_q("_size");
			HUD_Write_PanelCvar_q("_bg");
			HUD_Write_PanelCvar_q("_bg_color");
			HUD_Write_PanelCvar_q("_bg_color_team");
			HUD_Write_PanelCvar_q("_bg_alpha");
			HUD_Write_PanelCvar_q("_bg_border");
			HUD_Write_PanelCvar_q("_bg_padding");
			switch(i) {
				case HUD_PANEL_WEAPONS:
					HUD_Write_PanelCvar_q("_accuracy");
					HUD_Write_PanelCvar_q("_label");
					HUD_Write_PanelCvar_q("_complainbubble");
					HUD_Write_PanelCvar_q("_complainbubble_padding");
					HUD_Write_PanelCvar_q("_complainbubble_time");
					HUD_Write_PanelCvar_q("_complainbubble_fadetime");
					HUD_Write_PanelCvar_q("_complainbubble_color_outofammo");
					HUD_Write_PanelCvar_q("_complainbubble_color_donthave");
					HUD_Write_PanelCvar_q("_complainbubble_color_unavailable");
					HUD_Write_PanelCvar_q("_ammo");
					HUD_Write_PanelCvar_q("_ammo_color");
					HUD_Write_PanelCvar_q("_ammo_alpha");
					HUD_Write_PanelCvar_q("_aspect");
					HUD_Write_PanelCvar_q("_timeout");
					HUD_Write_PanelCvar_q("_timeout_effect");
					HUD_Write_PanelCvar_q("_timeout_fadebgmin");
					HUD_Write_PanelCvar_q("_timeout_fadefgmin");
					HUD_Write_PanelCvar_q("_timeout_speed_in");
					HUD_Write_PanelCvar_q("_timeout_speed_out");
					HUD_Write_PanelCvar_q("_onlyowned");
					break;
				case HUD_PANEL_AMMO:
					HUD_Write_PanelCvar_q("_onlycurrent");
					HUD_Write_PanelCvar_q("_iconalign");
					HUD_Write_PanelCvar_q("_progressbar");
					HUD_Write_PanelCvar_q("_progressbar_name");
					HUD_Write_PanelCvar_q("_progressbar_xoffset");
					HUD_Write_PanelCvar_q("_text");
					break;
				case HUD_PANEL_POWERUPS:
					HUD_Write_PanelCvar_q("_flip");
					HUD_Write_PanelCvar_q("_iconalign");
					HUD_Write_PanelCvar_q("_baralign");
					HUD_Write_PanelCvar_q("_progressbar");
					HUD_Write_PanelCvar_q("_progressbar_strength");
					HUD_Write_PanelCvar_q("_progressbar_shield");
					HUD_Write_PanelCvar_q("_text");
					break;
				case HUD_PANEL_HEALTHARMOR:
					HUD_Write_PanelCvar_q("_flip");
					HUD_Write_PanelCvar_q("_iconalign");
					HUD_Write_PanelCvar_q("_baralign");
					HUD_Write_PanelCvar_q("_progressbar");
					HUD_Write_PanelCvar_q("_progressbar_health");
					HUD_Write_PanelCvar_q("_progressbar_armor");
					HUD_Write_PanelCvar_q("_progressbar_gfx");
					HUD_Write_PanelCvar_q("_progressbar_gfx_smooth");
					HUD_Write_PanelCvar_q("_text");
					break;
				case HUD_PANEL_NOTIFY:
					HUD_Write_PanelCvar_q("_flip");
					HUD_Write_PanelCvar_q("_fontsize");
					HUD_Write_PanelCvar_q("_time");
					HUD_Write_PanelCvar_q("_fadetime");
					HUD_Write_PanelCvar_q("_icon_aspect");
					break;
				case HUD_PANEL_TIMER:
					HUD_Write_PanelCvar_q("_increment");
					break;
				case HUD_PANEL_RADAR:
					HUD_Write_PanelCvar_q("_foreground_alpha");
					HUD_Write_PanelCvar_q("_rotation");
					HUD_Write_PanelCvar_q("_zoommode");
					HUD_Write_PanelCvar_q("_scale");
					HUD_Write_PanelCvar_q("_maximized_scale");
					HUD_Write_PanelCvar_q("_maximized_size");
					HUD_Write_PanelCvar_q("_maximized_rotation");
					HUD_Write_PanelCvar_q("_maximized_zoommode");
					break;
				case HUD_PANEL_SCORE:
					HUD_Write_PanelCvar_q("_rankings");
					break;
				case HUD_PANEL_VOTE:
					HUD_Write_PanelCvar_q("_alreadyvoted_alpha");
					break;
				case HUD_PANEL_MODICONS:
					HUD_Write_PanelCvar_q("_ca_layout");
					HUD_Write_PanelCvar_q("_dom_layout");
					HUD_Write_PanelCvar_q("_freezetag_layout");
					break;
				case HUD_PANEL_PRESSEDKEYS:
					HUD_Write_PanelCvar_q("_aspect");
					HUD_Write_PanelCvar_q("_attack");
					break;
				case HUD_PANEL_ENGINEINFO:
					HUD_Write_PanelCvar_q("_framecounter_time");
					HUD_Write_PanelCvar_q("_framecounter_decimals");
					break;
				case HUD_PANEL_INFOMESSAGES:
					HUD_Write_PanelCvar_q("_flip");
					break;
				case HUD_PANEL_PHYSICS:
					HUD_Write_PanelCvar_q("_speed_unit");
					HUD_Write_PanelCvar_q("_speed_unit_show");
					HUD_Write_PanelCvar_q("_speed_max");
					HUD_Write_PanelCvar_q("_speed_vertical");
					HUD_Write_PanelCvar_q("_topspeed");
					HUD_Write_PanelCvar_q("_topspeed_time");
					HUD_Write_PanelCvar_q("_acceleration_max");
					HUD_Write_PanelCvar_q("_acceleration_vertical");
					HUD_Write_PanelCvar_q("_flip");
					HUD_Write_PanelCvar_q("_baralign");
					HUD_Write_PanelCvar_q("_progressbar");
					HUD_Write_PanelCvar_q("_progressbar_acceleration_mode");
					HUD_Write_PanelCvar_q("_progressbar_acceleration_scale");
					HUD_Write_PanelCvar_q("_progressbar_acceleration_nonlinear");
					HUD_Write_PanelCvar_q("_text");
					HUD_Write_PanelCvar_q("_text_scale");
					break;
				case HUD_PANEL_CENTERPRINT:
					HUD_Write_PanelCvar_q("_align");
					HUD_Write_PanelCvar_q("_flip");
					HUD_Write_PanelCvar_q("_fontscale");
					HUD_Write_PanelCvar_q("_time");
					HUD_Write_PanelCvar_q("_fade_in");
					HUD_Write_PanelCvar_q("_fade_out");
					HUD_Write_PanelCvar_q("_fade_subsequent");
					HUD_Write_PanelCvar_q("_fade_subsequent_passone");
					HUD_Write_PanelCvar_q("_fade_subsequent_passone_minalpha");
					HUD_Write_PanelCvar_q("_fade_subsequent_passtwo");
					HUD_Write_PanelCvar_q("_fade_subsequent_passtwo_minalpha");
					HUD_Write_PanelCvar_q("_fade_subsequent_minfontsize");
					HUD_Write_PanelCvar_q("_fade_minfontsize");
					break;
				case HUD_PANEL_QUICKMENU:
					HUD_Write_PanelCvar_q("_align");
					break;
			}
			HUD_Write("\n");
		}
		HUD_Write("menu_sync\n"); // force the menu to reread the cvars, so that the dialogs are updated

		printf(_("^2Successfully exported to %s! (Note: It's saved in data/data/)\n"), filename);
		fclose(fh);
	}
	else
		printf(_("^1Couldn't write to %s\n"), filename);
}

void HUD_Configure_Exit_Force()
{
	if (menu_enabled)
	{
		menu_enabled = 0;
		localcmd("togglemenu\n");
	}
	cvar_set("_hud_configure", "0");
}

// check if move will result in panel being moved into another panel. If so, return snapped vector, otherwise return the given vector
vector HUD_Panel_CheckMove(vector myPos, vector mySize)
{
	float i;
	float myCenter_x, myCenter_y, targCenter_x, targCenter_y;
	vector myTarget;
	myTarget = myPos;

	for (i = 0; i < HUD_PANEL_NUM; ++i) {
		panel = hud_panel[i];
		if(panel == highlightedPanel) continue;
		HUD_Panel_UpdatePosSize()
		if(!panel_enabled) continue;

		panel_pos -= '1 1 0' * panel_bg_border;
		panel_size += '2 2 0' * panel_bg_border;

		if(myPos_y + mySize_y < panel_pos_y)
			continue;
		if(myPos_y > panel_pos_y + panel_size_y)
			continue;

		if(myPos_x + mySize_x < panel_pos_x)
			continue;
		if(myPos_x > panel_pos_x + panel_size_x)
			continue;

		// OK, there IS a collision.

		myCenter_x = myPos_x + 0.5 * mySize_x;
		myCenter_y = myPos_y + 0.5 * mySize_y;

		targCenter_x = panel_pos_x + 0.5 * panel_size_x;
		targCenter_y = panel_pos_y + 0.5 * panel_size_y;

		if(myCenter_x < targCenter_x && myCenter_y < targCenter_y) // top left (of the target panel)
		{
			if(myPos_x + mySize_x - panel_pos_x < myPos_y + mySize_y - panel_pos_y) // push it to the side
				myTarget_x = panel_pos_x - mySize_x;
			else // push it upwards
				myTarget_y = panel_pos_y - mySize_y;
		}
		else if(myCenter_x > targCenter_x && myCenter_y < targCenter_y) // top right
		{
			if(panel_pos_x + panel_size_x - myPos_x < myPos_y + mySize_y - panel_pos_y) // push it to the side
				myTarget_x = panel_pos_x + panel_size_x;
			else // push it upwards
				myTarget_y = panel_pos_y - mySize_y;
		}
		else if(myCenter_x < targCenter_x && myCenter_y > targCenter_y) // bottom left
		{
			if(myPos_x + mySize_x - panel_pos_x < panel_pos_y + panel_size_y - myPos_y) // push it to the side
				myTarget_x = panel_pos_x - mySize_x;
			else // push it downwards
				myTarget_y = panel_pos_y + panel_size_y;
		}
		else if(myCenter_x > targCenter_x && myCenter_y > targCenter_y) // bottom right
		{
			if(panel_pos_x + panel_size_x - myPos_x < panel_pos_y + panel_size_y - myPos_y) // push it to the side
				myTarget_x = panel_pos_x + panel_size_x;
			else // push it downwards
				myTarget_y = panel_pos_y + panel_size_y;
		}
		//if(cvar("hud_configure_checkcollisions_debug"))
			//drawfill(panel_pos, panel_size, '1 1 0', .3, DRAWFLAG_NORMAL);
	}

	return myTarget;
}

void HUD_Panel_SetPos(vector pos)
{
	panel = highlightedPanel;
	HUD_Panel_UpdatePosSize()
	vector mySize;
	mySize = panel_size;

	//if(cvar("hud_configure_checkcollisions_debug"))
		//drawfill(pos, mySize, '1 1 1', .2, DRAWFLAG_NORMAL);

	if(autocvar_hud_configure_grid)
	{
		pos_x = floor((pos_x/vid_conwidth)/hud_configure_gridSize_x + 0.5) * hud_configure_realGridSize_x;
		pos_y = floor((pos_y/vid_conheight)/hud_configure_gridSize_y + 0.5) * hud_configure_realGridSize_y;
	}

	if(hud_configure_checkcollisions)
		pos = HUD_Panel_CheckMove(pos, mySize);

	pos_x = bound(0, pos_x, vid_conwidth - mySize_x);
	pos_y = bound(0, pos_y, vid_conheight - mySize_y);

	string s;
	s = strcat(ftos(pos_x/vid_conwidth), " ", ftos(pos_y/vid_conheight));

	cvar_set(strcat("hud_panel_", highlightedPanel.panel_name, "_pos"), s);
}

// check if resize will result in panel being moved into another panel. If so, return snapped vector, otherwise return the given vector
vector HUD_Panel_CheckResize(vector mySize, vector resizeorigin) {
	float i;

	vector targEndPos;

	float dist_x, dist_y;
	float ratio;
	ratio = mySize_x/mySize_y;

	for (i = 0; i < HUD_PANEL_NUM; ++i) {
		panel = hud_panel[i];
		if(panel == highlightedPanel) continue;
		HUD_Panel_UpdatePosSize()
		if(!panel_enabled) continue;

		panel_pos -= '1 1 0' * panel_bg_border;
		panel_size += '2 2 0' * panel_bg_border;

		targEndPos = panel_pos + panel_size;

		// resizeorigin is WITHIN target panel, just abort any collision testing against that particular panel to produce expected behaviour!
		if(resizeorigin_x > panel_pos_x && resizeorigin_x < targEndPos_x && resizeorigin_y > panel_pos_y && resizeorigin_y < targEndPos_y)
			continue;

		if (resizeCorner == 1)
		{
			// check if this panel is on our way
			if (resizeorigin_x <= panel_pos_x)
				continue;
			if (resizeorigin_y <= panel_pos_y)
				continue;
			if (targEndPos_x <= resizeorigin_x - mySize_x)
				continue;
			if (targEndPos_y <= resizeorigin_y - mySize_y)
				continue;

			// there is a collision:
			// detect which side of the panel we are facing is actually limiting the resizing
			// (which side the resize direction finds for first) and reduce the size up to there
			//
			// dist is the distance between resizeorigin and the "analogous" point of the panel
			// in this case between resizeorigin (bottom-right point) and the bottom-right point of the panel
			dist_x = resizeorigin_x - targEndPos_x;
			dist_y = resizeorigin_y - targEndPos_y;
			if (dist_y <= 0 || dist_x / dist_y > ratio)
				mySize_x = min(mySize_x, dist_x);
			else
				mySize_y = min(mySize_y, dist_y);
		}
		else if (resizeCorner == 2)
		{
			if (resizeorigin_x >= targEndPos_x)
				continue;
			if (resizeorigin_y <= panel_pos_y)
				continue;
			if (panel_pos_x >= resizeorigin_x + mySize_x)
				continue;
			if (targEndPos_y <= resizeorigin_y - mySize_y)
				continue;

			dist_x = panel_pos_x - resizeorigin_x;
			dist_y = resizeorigin_y - targEndPos_y;
			if (dist_y <= 0 || dist_x / dist_y > ratio)
				mySize_x = min(mySize_x, dist_x);
			else
				mySize_y = min(mySize_y, dist_y);
		}
		else if (resizeCorner == 3)
		{
			if (resizeorigin_x <= panel_pos_x)
				continue;
			if (resizeorigin_y >= targEndPos_y)
				continue;
			if (targEndPos_x <= resizeorigin_x - mySize_x)
				continue;
			if (panel_pos_y >= resizeorigin_y + mySize_y)
				continue;

			dist_x = resizeorigin_x - targEndPos_x;
			dist_y = panel_pos_y - resizeorigin_y;
			if (dist_y <= 0 || dist_x / dist_y > ratio)
				mySize_x = min(mySize_x, dist_x);
			else
				mySize_y = min(mySize_y, dist_y);
		}
		else if (resizeCorner == 4)
		{
			if (resizeorigin_x >= targEndPos_x)
				continue;
			if (resizeorigin_y >= targEndPos_y)
				continue;
			if (panel_pos_x >= resizeorigin_x + mySize_x)
				continue;
			if (panel_pos_y >= resizeorigin_y + mySize_y)
				continue;

			dist_x = panel_pos_x - resizeorigin_x;
			dist_y = panel_pos_y - resizeorigin_y;
			if (dist_y <= 0 || dist_x / dist_y > ratio)
				mySize_x = min(mySize_x, dist_x);
			else
				mySize_y = min(mySize_y, dist_y);
		}
		//if(cvar("hud_configure_checkcollisions_debug"))
			//drawfill(panel_pos, panel_size, '1 1 0', .3, DRAWFLAG_NORMAL);
	}

	return mySize;
}

void HUD_Panel_SetPosSize(vector mySize)
{
	panel = highlightedPanel;
	HUD_Panel_UpdatePosSize()
	vector resizeorigin;
	resizeorigin = panel_click_resizeorigin;
	local noref vector myPos; // fteqcc sucks

	// minimum panel size cap
	mySize_x = max(0.025 * vid_conwidth, mySize_x);
	mySize_y = max(0.025 * vid_conheight, mySize_y);

	if(highlightedPanel == HUD_PANEL(CHAT)) // some panels have their own restrictions, like the chat panel (which actually only moves the engine chat print around). Looks bad if it's too small.
	{
		mySize_x = max(17 * autocvar_con_chatsize, mySize_x);
		mySize_y = max(2 * autocvar_con_chatsize + 2 * panel_bg_padding, mySize_y);
	}

	// collision testing|
	// -----------------+

	// we need to know pos at this stage, but it might still change later if we hit a screen edge/other panel (?)
	if(resizeCorner == 1) {
		myPos_x = resizeorigin_x - mySize_x;
		myPos_y = resizeorigin_y - mySize_y;
	} else if(resizeCorner == 2) {
		myPos_x = resizeorigin_x;
		myPos_y = resizeorigin_y - mySize_y;
	} else if(resizeCorner == 3) {
		myPos_x = resizeorigin_x - mySize_x;
		myPos_y = resizeorigin_y;
	} else { // resizeCorner == 4
		myPos_x = resizeorigin_x;
		myPos_y = resizeorigin_y;
	}

	// left/top screen edges
	if(myPos_x < 0)
		mySize_x = mySize_x + myPos_x;
	if(myPos_y < 0)
		mySize_y = mySize_y + myPos_y;

	// bottom/right screen edges
	if(myPos_x + mySize_x > vid_conwidth)
		mySize_x = vid_conwidth - myPos_x;
	if(myPos_y + mySize_y > vid_conheight)
		mySize_y = vid_conheight - myPos_y;

	//if(cvar("hud_configure_checkcollisions_debug"))
		//drawfill(myPos, mySize, '1 1 1', .2, DRAWFLAG_NORMAL);

	// before checkresize, otherwise panel can be snapped partially inside another panel or panel aspect ratio can be broken
	if(autocvar_hud_configure_grid)
	{
		mySize_x = floor((mySize_x/vid_conwidth)/hud_configure_gridSize_x + 0.5) * hud_configure_realGridSize_x;
		mySize_y = floor((mySize_y/vid_conheight)/hud_configure_gridSize_y + 0.5) * hud_configure_realGridSize_y;
	}

	if(hud_configure_checkcollisions)
		mySize = HUD_Panel_CheckResize(mySize, resizeorigin);

	// minimum panel size cap, do this once more so we NEVER EVER EVER have a panel smaller than this, JUST IN CASE above code still makes the panel eg negative (impossible to resize back without changing cvars manually then)
	mySize_x = max(0.025 * vid_conwidth, mySize_x);
	mySize_y = max(0.025 * vid_conheight, mySize_y);

	// do another pos check, as size might have changed by now
	if(resizeCorner == 1) {
		myPos_x = resizeorigin_x - mySize_x;
		myPos_y = resizeorigin_y - mySize_y;
	} else if(resizeCorner == 2) {
		myPos_x = resizeorigin_x;
		myPos_y = resizeorigin_y - mySize_y;
	} else if(resizeCorner == 3) {
		myPos_x = resizeorigin_x - mySize_x;
		myPos_y = resizeorigin_y;
	} else { // resizeCorner == 4
		myPos_x = resizeorigin_x;
		myPos_y = resizeorigin_y;
	}

	//if(cvar("hud_configure_checkcollisions_debug"))
		//drawfill(myPos, mySize, '0 1 0', .3, DRAWFLAG_NORMAL);

	string s;
	s = strcat(ftos(mySize_x/vid_conwidth), " ", ftos(mySize_y/vid_conheight));
	cvar_set(strcat("hud_panel_", highlightedPanel.panel_name, "_size"), s);

	s = strcat(ftos(myPos_x/vid_conwidth), " ", ftos(myPos_y/vid_conheight));
	cvar_set(strcat("hud_panel_", highlightedPanel.panel_name, "_pos"), s);
}

float pressed_key_time;
vector highlightedPanel_initial_pos, highlightedPanel_initial_size;
void HUD_Panel_Arrow_Action(float nPrimary)
{
	if(!highlightedPanel)
		return;

	hud_configure_checkcollisions = (!(hudShiftState & S_CTRL) && autocvar_hud_configure_checkcollisions);

	float step;
	if(autocvar_hud_configure_grid)
	{
		if (nPrimary == K_UPARROW || nPrimary == K_DOWNARROW)
		{
			if (hudShiftState & S_SHIFT)
				step = hud_configure_realGridSize_y;
			else
				step = 2 * hud_configure_realGridSize_y;
		}
		else
		{
			if (hudShiftState & S_SHIFT)
				step = hud_configure_realGridSize_x;
			else
				step = 2 * hud_configure_realGridSize_x;
		}
	}
	else
	{
		if (nPrimary == K_UPARROW || nPrimary == K_DOWNARROW)
			step = vid_conheight;
		else
			step = vid_conwidth;
		if (hudShiftState & S_SHIFT)
			step = (step / 256); // more precision
		else
			step = (step / 64) * (1 + 2 * (time - pressed_key_time));
	}

	panel = highlightedPanel;
	HUD_Panel_UpdatePosSize()

	highlightedPanel_initial_pos = panel_pos;
	highlightedPanel_initial_size = panel_size;

	if (hudShiftState & S_ALT) // resize
	{
		highlightedAction = 1;
		if(nPrimary == K_UPARROW)
			resizeCorner = 1;
		else if(nPrimary == K_RIGHTARROW)
			resizeCorner = 2;
		else if(nPrimary == K_LEFTARROW)
			resizeCorner = 3;
		else // if(nPrimary == K_DOWNARROW)
			resizeCorner = 4;

		// ctrl+arrow reduces the size, instead of increasing it
		// Note that ctrl disables collisions check too, but it's fine
		// since we don't collide with anything reducing the size
		if (hudShiftState & S_CTRL) {
			step = -step;
			resizeCorner = 5 - resizeCorner;
		}

		vector mySize;
		mySize = panel_size;
		panel_click_resizeorigin = panel_pos;
		if(resizeCorner == 1) {
			panel_click_resizeorigin += mySize;
			mySize_y += step;
		} else if(resizeCorner == 2) {
			panel_click_resizeorigin_y += mySize_y;
			mySize_x += step;
		} else if(resizeCorner == 3) {
			panel_click_resizeorigin_x += mySize_x;
			mySize_x += step;
		} else { // resizeCorner == 4
			mySize_y += step;
		}
		HUD_Panel_SetPosSize(mySize);
	}
	else // move
	{
		highlightedAction = 2;
		vector pos;
		pos = panel_pos;
		if(nPrimary == K_UPARROW)
			pos_y -= step;
		else if(nPrimary == K_DOWNARROW)
			pos_y += step;
		else if(nPrimary == K_LEFTARROW)
			pos_x -= step;
		else // if(nPrimary == K_RIGHTARROW)
			pos_x += step;

		HUD_Panel_SetPos(pos);
	}

	panel = highlightedPanel;
	HUD_Panel_UpdatePosSize()

	if (highlightedPanel_initial_pos != panel_pos || highlightedPanel_initial_size != panel_size)
	{
		// backup!
		panel_pos_backup = highlightedPanel_initial_pos;
		panel_size_backup = highlightedPanel_initial_size;
		highlightedPanel_backup = highlightedPanel;
	}
}

const float S_MOUSE1 = 1;
const float S_MOUSE2 = 2;
const float S_MOUSE3 = 4;
float mouseClicked;
float prevMouseClicked; // previous state
float prevMouseClickedTime; // time during previous left mouse click, to check for doubleclicks
vector prevMouseClickedPos; // pos during previous left mouse click, to check for doubleclicks

void HUD_Panel_EnableMenu();
entity tab_panels[HUD_PANEL_MAX];
entity tab_panel;
vector tab_panel_pos;
float tab_backward;
void HUD_Panel_FirstInDrawQ(float id);
void reset_tab_panels()
{
	int i;
	for(i = 0; i < HUD_PANEL_NUM; ++i)
		tab_panels[i] = world;
}
float HUD_Panel_InputEvent(float bInputType, float nPrimary, float nSecondary)
{
	string s;

	if(bInputType == 2)
		return false;

	if(!autocvar__hud_configure)
		return false;

	if(bInputType == 3)
	{
		mousepos_x = nPrimary;
		mousepos_y = nSecondary;
		return true;
	}

	// block any input while a menu dialog is fading
	// don't block mousepos read as it leads to cursor jumps in the interaction with the menu
	if(autocvar__menu_alpha)
	{
		hudShiftState = 0;
		mouseClicked = 0;
		return true;
	}

	// allow console bind to work
	string con_keys;
	float keys;
	con_keys = findkeysforcommand("toggleconsole", 0);
	keys = tokenize(con_keys); // findkeysforcommand returns data for this

	float hit_con_bind = 0, i;
	for (i = 0; i < keys; ++i)
	{
		if(nPrimary == stof(argv(i)))
			hit_con_bind = 1;
	}

	if(bInputType == 0) {
		if(nPrimary == K_ALT) hudShiftState |= S_ALT;
		if(nPrimary == K_CTRL) hudShiftState |= S_CTRL;
		if(nPrimary == K_SHIFT) hudShiftState |= S_SHIFT;
	}
	else if(bInputType == 1) {
		if(nPrimary == K_ALT) hudShiftState -= (hudShiftState & S_ALT);
		if(nPrimary == K_CTRL) hudShiftState -= (hudShiftState & S_CTRL);
		if(nPrimary == K_SHIFT) hudShiftState -= (hudShiftState & S_SHIFT);
	}

	if(nPrimary == K_CTRL)
	{
		if (bInputType == 1) //ctrl has been released
		{
			if (tab_panel)
			{
				//switch to selected panel
				highlightedPanel = tab_panel;
				highlightedAction = 0;
				HUD_Panel_FirstInDrawQ(highlightedPanel.panel_id);
			}
			tab_panel = world;
			reset_tab_panels();
		}
	}

	if(nPrimary == K_MOUSE1)
	{
		if(bInputType == 0) // key pressed
			mouseClicked |= S_MOUSE1;
		else if(bInputType == 1) // key released
			mouseClicked -= (mouseClicked & S_MOUSE1);
	}
	else if(nPrimary == K_MOUSE2)
	{
		if(bInputType == 0) // key pressed
			mouseClicked |= S_MOUSE2;
		else if(bInputType == 1) // key released
			mouseClicked -= (mouseClicked & S_MOUSE2);
	}
	else if(nPrimary == K_ESCAPE)
	{
		if (bInputType == 1)
			return true;
		menu_enabled = 1;
		localcmd("menu_showhudexit\n");
	}
	else if(nPrimary == K_BACKSPACE && hudShiftState & S_CTRL)
	{
		if (bInputType == 1)
			return true;
		if (!menu_enabled)
			cvar_set("_hud_configure", "0");
	}
	else if(nPrimary == K_TAB && hudShiftState & S_CTRL) // select and highlight another panel
	{
		if (bInputType == 1 || mouseClicked)
			return true;

		//FIXME: if a panel is highlighted, has the same pos_x and lays in the same level
		//of other panels then next consecutive ctrl-tab will select the highlighted panel too
		//(it should only after every other panel of the hud)
		//It's a minor bug anyway, we can live with it

		entity starting_panel;
		entity old_tab_panel = tab_panel;
		if (!tab_panel) //first press of TAB
		{
			if (highlightedPanel)
			{
				panel = highlightedPanel;
				HUD_Panel_UpdatePosSize()
			}
			else
				panel_pos = '0 0 0';
			starting_panel = highlightedPanel;
			tab_panel_pos = panel_pos; //to compute level
		}
		else
		{
			if ( ((!tab_backward) && (hudShiftState & S_SHIFT)) || (tab_backward && !(hudShiftState & S_SHIFT)) ) //tab direction changed?
				reset_tab_panels();
			starting_panel = tab_panel;
		}
		tab_backward = (hudShiftState & S_SHIFT);

		float k, level = 0, start_pos_x;
		vector candidate_pos = '0 0 0';
		const float LEVELS_NUM = 4;
		float level_height = vid_conheight / LEVELS_NUM;
:find_tab_panel
		level = floor(tab_panel_pos_y / level_height) * level_height; //starting level
		candidate_pos_x = (!tab_backward) ? vid_conwidth : 0;
		start_pos_x = tab_panel_pos_x;
		tab_panel = world;
		k=0;
		while(++k)
		{
			for(i = 0; i < HUD_PANEL_NUM; ++i)
			{
				panel = hud_panel[i];
				if (panel == tab_panels[i] || panel == starting_panel)
					continue;
				HUD_Panel_UpdatePosSize()
				if (panel_pos_y >= level && (panel_pos_y - level) < level_height)
				if (  ( !tab_backward && panel_pos_x >= start_pos_x && (panel_pos_x < candidate_pos_x || (panel_pos_x == candidate_pos_x && panel_pos_y <= candidate_pos_y)) )
					|| ( tab_backward && panel_pos_x <= start_pos_x && (panel_pos_x > candidate_pos_x || (panel_pos_x == candidate_pos_x && panel_pos_y >= candidate_pos_y)) )  )
				{
					tab_panel = panel;
					tab_panel_pos = candidate_pos = panel_pos;
				}
			}
			if (tab_panel)
				break;
			if (k == LEVELS_NUM) //tab_panel not found
			{
				reset_tab_panels();
				if (!old_tab_panel)
				{
					tab_panel = world;
					return true;
				}
				starting_panel = old_tab_panel;
				old_tab_panel = world;
				goto find_tab_panel; //u must find tab_panel!
			}
			if (!tab_backward)
			{
				level = mod(level + level_height, vid_conheight);
				start_pos_x = 0;
				candidate_pos_x = vid_conwidth;
			}
			else
			{
				level = mod(level - level_height, vid_conheight);
				start_pos_x = vid_conwidth;
				candidate_pos_x = 0;
			}
		}

		tab_panels[tab_panel.panel_id] = tab_panel;
	}
	else if(nPrimary == K_SPACE && hudShiftState & S_CTRL) // enable/disable highlighted panel or dock
	{
		if (bInputType == 1 || mouseClicked)
			return true;

		if (highlightedPanel)
			cvar_set(strcat("hud_panel_", highlightedPanel.panel_name), ftos(!cvar(strcat("hud_panel_", highlightedPanel.panel_name))));
		else
			cvar_set(strcat("hud_dock"), (autocvar_hud_dock == "") ? "dock" : "");
	}
	else if(nPrimary == 'c' && hudShiftState & S_CTRL) // copy highlighted panel size
	{
		if (bInputType == 1 || mouseClicked)
			return true;

		if (highlightedPanel)
		{
			panel = highlightedPanel;
			HUD_Panel_UpdatePosSize()
			panel_size_copied = panel_size;
		}
	}
	else if(nPrimary == 'v' && hudShiftState & S_CTRL) // past copied size on the highlighted panel
	{
		if (bInputType == 1 || mouseClicked)
			return true;

		if (panel_size_copied == '0 0 0' || !highlightedPanel)
			return true;

		panel = highlightedPanel;
		HUD_Panel_UpdatePosSize()

		// reduce size if it'd go beyond screen boundaries
		vector tmp_size = panel_size_copied;
		if (panel_pos_x + panel_size_copied_x > vid_conwidth)
			tmp_size_x = vid_conwidth - panel_pos_x;
		if (panel_pos_y + panel_size_copied_y > vid_conheight)
			tmp_size_y = vid_conheight - panel_pos_y;

		if (panel_size == tmp_size)
			return true;

		// backup first!
		panel_pos_backup = panel_pos;
		panel_size_backup = panel_size;
		highlightedPanel_backup = highlightedPanel;

		s = strcat(ftos(tmp_size_x/vid_conwidth), " ", ftos(tmp_size_y/vid_conheight));
		cvar_set(strcat("hud_panel_", highlightedPanel.panel_name, "_size"), s);
	}
	else if(nPrimary == 'z' && hudShiftState & S_CTRL) // undo last action
	{
		if (bInputType == 1 || mouseClicked)
			return true;
		//restore previous values
		if (highlightedPanel_backup)
		{
			s = strcat(ftos(panel_pos_backup_x/vid_conwidth), " ", ftos(panel_pos_backup_y/vid_conheight));
			cvar_set(strcat("hud_panel_", highlightedPanel_backup.panel_name, "_pos"), s);
			s = strcat(ftos(panel_size_backup_x/vid_conwidth), " ", ftos(panel_size_backup_y/vid_conheight));
			cvar_set(strcat("hud_panel_", highlightedPanel_backup.panel_name, "_size"), s);
			highlightedPanel_backup = world;
		}
	}
	else if(nPrimary == K_UPARROW || nPrimary == K_DOWNARROW || nPrimary == K_LEFTARROW || nPrimary == K_RIGHTARROW)
	{
		if (bInputType == 1)
		{
			pressed_key_time = 0;
			return true;
		}
		else if (pressed_key_time == 0)
			pressed_key_time = time;

		if (!mouseClicked)
			HUD_Panel_Arrow_Action(nPrimary); //move or resize panel
	}
	else if(nPrimary == K_ENTER || nPrimary == K_SPACE || nPrimary == K_KP_ENTER)
	{
		if (bInputType == 1)
			return true;
		if (highlightedPanel)
			HUD_Panel_EnableMenu();
	}
	else if(hit_con_bind)
		return false;

	return true;
}

float HUD_Panel_Check_Mouse_Pos(float allow_move)
{
	float i, j = 0, border;

	while(j < HUD_PANEL_NUM)
	{
		i = panel_order[j];
		j += 1;

		panel = hud_panel[i];
		HUD_Panel_UpdatePosSize()

		border = max(8, panel_bg_border); // FORCED border so a small border size doesn't mean you can't resize

		// move
		if(allow_move && mousepos_x > panel_pos_x && mousepos_y > panel_pos_y && mousepos_x < panel_pos_x + panel_size_x && mousepos_y < panel_pos_y + panel_size_y)
		{
			return 1;
		}
		// resize from topleft border
		else if(mousepos_x >= panel_pos_x - border && mousepos_y >= panel_pos_y - border && mousepos_x <= panel_pos_x + 0.5 * panel_size_x && mousepos_y <= panel_pos_y + 0.5 * panel_size_y)
		{
			return 2;
		}
		// resize from topright border
		else if(mousepos_x >= panel_pos_x + 0.5 * panel_size_x && mousepos_y >= panel_pos_y - border && mousepos_x <= panel_pos_x + panel_size_x + border && mousepos_y <= panel_pos_y + 0.5 * panel_size_y)
		{
			return 3;
		}
		// resize from bottomleft border
		else if(mousepos_x >= panel_pos_x - border && mousepos_y >= panel_pos_y + 0.5 * panel_size_y && mousepos_x <= panel_pos_x + 0.5 * panel_size_x && mousepos_y <= panel_pos_y + panel_size_y + border)
		{
			return 3;
		}
		// resize from bottomright border
		else if(mousepos_x >= panel_pos_x + 0.5 * panel_size_x && mousepos_y >= panel_pos_y + 0.5 * panel_size_y && mousepos_x <= panel_pos_x + panel_size_x + border && mousepos_y <= panel_pos_y + panel_size_y + border)
		{
			return 2;
		}
	}
	return 0;
}

// move a panel to the beginning of the panel order array (which means it gets drawn last, on top of everything else)
void HUD_Panel_FirstInDrawQ(float id)
{
	float i;
	var float place = -1;
	// find out where in the array our current id is, save into place
	for(i = 0; i < HUD_PANEL_NUM; ++i)
	{
		if(panel_order[i] == id)
		{
			place = i;
			break;
		}
	}
	// place last if we didn't find a place for it yet (probably new panel, or screwed up cvar)
	if(place == -1)
		place = HUD_PANEL_NUM - 1;

	// move all ids up by one step in the array until "place"
	for(i = place; i > 0; --i)
	{
		panel_order[i] = panel_order[i-1];
	}
	// now save the new top id
	panel_order[0] = id;

	// let's save them into the cvar by some strcat trickery
	string s = "";
	for(i = 0; i < HUD_PANEL_NUM; ++i)
	{
		s = strcat(s, ftos(panel_order[i]), " ");
	}
	cvar_set("_hud_panelorder", s);
	if(hud_panelorder_prev)
		strunzone(hud_panelorder_prev);
	hud_panelorder_prev = strzone(autocvar__hud_panelorder); // prevent HUD_Main from doing useless update, we already updated here
}

void HUD_Panel_Highlight(float allow_move)
{
	float i, j = 0, border;

	while(j < HUD_PANEL_NUM)
	{
		i = panel_order[j];
		j += 1;

		panel = hud_panel[i];
		HUD_Panel_UpdatePosSize()

		border = max(8, panel_bg_border); // FORCED border so a small border size doesn't mean you can't resize

		// move
		if(allow_move && mousepos_x > panel_pos_x && mousepos_y > panel_pos_y && mousepos_x < panel_pos_x + panel_size_x && mousepos_y < panel_pos_y + panel_size_y)
		{
			highlightedPanel = hud_panel[i];
			HUD_Panel_FirstInDrawQ(i);
			highlightedAction = 1;
			panel_click_distance = mousepos - panel_pos;
			return;
		}
		// resize from topleft border
		else if(mousepos_x >= panel_pos_x - border && mousepos_y >= panel_pos_y - border && mousepos_x <= panel_pos_x + 0.5 * panel_size_x && mousepos_y <= panel_pos_y + 0.5 * panel_size_y)
		{
			highlightedPanel = hud_panel[i];
			HUD_Panel_FirstInDrawQ(i);
			highlightedAction = 2;
			resizeCorner = 1;
			panel_click_distance = mousepos - panel_pos;
			panel_click_resizeorigin = panel_pos + panel_size;
			return;
		}
		// resize from topright border
		else if(mousepos_x >= panel_pos_x + 0.5 * panel_size_x && mousepos_y >= panel_pos_y - border && mousepos_x <= panel_pos_x + panel_size_x + border && mousepos_y <= panel_pos_y + 0.5 * panel_size_y)
		{
			highlightedPanel = hud_panel[i];
			HUD_Panel_FirstInDrawQ(i);
			highlightedAction = 2;
			resizeCorner = 2;
			panel_click_distance_x = panel_size_x - mousepos_x + panel_pos_x;
			panel_click_distance_y = mousepos_y - panel_pos_y;
			panel_click_resizeorigin = panel_pos + eY * panel_size_y;
			return;
		}
		// resize from bottomleft border
		else if(mousepos_x >= panel_pos_x - border && mousepos_y >= panel_pos_y + 0.5 * panel_size_y && mousepos_x <= panel_pos_x + 0.5 * panel_size_x && mousepos_y <= panel_pos_y + panel_size_y + border)
		{
			highlightedPanel = hud_panel[i];
			HUD_Panel_FirstInDrawQ(i);
			highlightedAction = 2;
			resizeCorner = 3;
			panel_click_distance_x = mousepos_x - panel_pos_x;
			panel_click_distance_y = panel_size_y - mousepos_y + panel_pos_y;
			panel_click_resizeorigin = panel_pos + eX * panel_size_x;
			return;
		}
		// resize from bottomright border
		else if(mousepos_x >= panel_pos_x + 0.5 * panel_size_x && mousepos_y >= panel_pos_y + 0.5 * panel_size_y && mousepos_x <= panel_pos_x + panel_size_x + border && mousepos_y <= panel_pos_y + panel_size_y + border)
		{
			highlightedPanel = hud_panel[i];
			HUD_Panel_FirstInDrawQ(i);
			highlightedAction = 2;
			resizeCorner = 4;
			panel_click_distance = panel_size - mousepos + panel_pos;
			panel_click_resizeorigin = panel_pos;
			return;
		}
	}
	highlightedPanel = world;
	highlightedAction = 0;
}

void HUD_Panel_EnableMenu()
{
	menu_enabled = 2;
	localcmd("menu_showhudoptions ", highlightedPanel.panel_name, "\n");
}
float mouse_over_panel;
void HUD_Panel_Mouse()
{
	if(autocvar__menu_alpha == 1)
		return;

	if (!autocvar_hud_cursormode)
	{
		mousepos = mousepos + getmousepos() * autocvar_menu_mouse_speed;

		mousepos_x = bound(0, mousepos_x, vid_conwidth);
		mousepos_y = bound(0, mousepos_y, vid_conheight);
	}

	if(mouseClicked)
	{
		if(prevMouseClicked == 0)
		{
			if (tab_panel)
			{
				//stop ctrl-tab selection
				tab_panel = world;
				reset_tab_panels();
			}
			HUD_Panel_Highlight(mouseClicked & S_MOUSE1); // sets highlightedPanel, highlightedAction, panel_click_distance, panel_click_resizeorigin
									// and calls HUD_Panel_UpdatePosSize() for the highlighted panel
			if (highlightedPanel)
			{
				highlightedPanel_initial_pos = panel_pos;
				highlightedPanel_initial_size = panel_size;
			}
			// doubleclick check
			if ((mouseClicked & S_MOUSE1) && time - prevMouseClickedTime < 0.4 && highlightedPanel && prevMouseClickedPos == mousepos)
			{
				mouseClicked = 0; // to prevent spam, I guess.
				HUD_Panel_EnableMenu();
			}
			else
			{
				if (mouseClicked & S_MOUSE1)
				{
					prevMouseClickedTime = time;
					prevMouseClickedPos = mousepos;
				}
				mouse_over_panel = HUD_Panel_Check_Mouse_Pos(mouseClicked & S_MOUSE1);
			}
		}
		else
		{
			panel = highlightedPanel;
			HUD_Panel_UpdatePosSize()
		}

		if (highlightedPanel)
		{
			drawfill(panel_pos - '1 1 0' * panel_bg_border, panel_size + '2 2 0' * panel_bg_border, '1 1 1', .1, DRAWFLAG_NORMAL);
			if (highlightedPanel_initial_pos != panel_pos || highlightedPanel_initial_size != panel_size)
			{
				hud_configure_checkcollisions = (!(hudShiftState & S_CTRL) && autocvar_hud_configure_checkcollisions);
				// backup!
				panel_pos_backup = highlightedPanel_initial_pos;
				panel_size_backup = highlightedPanel_initial_size;
				highlightedPanel_backup = highlightedPanel;
			}
			else
				// in case the clicked panel is inside another panel and we aren't
				// moving it, avoid the immediate "fix" of its position/size
				// (often unwanted and hateful) by disabling collisions check
				hud_configure_checkcollisions = false;
		}

		if(highlightedAction == 1)
			HUD_Panel_SetPos(mousepos - panel_click_distance);
		else if(highlightedAction == 2)
		{
			vector mySize = '0 0 0';
			if(resizeCorner == 1) {
				mySize_x = panel_click_resizeorigin_x - (mousepos_x - panel_click_distance_x);
				mySize_y = panel_click_resizeorigin_y - (mousepos_y - panel_click_distance_y);
			} else if(resizeCorner == 2) {
				mySize_x = mousepos_x + panel_click_distance_x - panel_click_resizeorigin_x;
				mySize_y = panel_click_distance_y + panel_click_resizeorigin_y - mousepos_y;
			} else if(resizeCorner == 3) {
				mySize_x = panel_click_resizeorigin_x + panel_click_distance_x - mousepos_x;
				mySize_y = mousepos_y + panel_click_distance_y - panel_click_resizeorigin_y;
			} else { // resizeCorner == 4
				mySize_x = mousepos_x - (panel_click_resizeorigin_x - panel_click_distance_x);
				mySize_y = mousepos_y - (panel_click_resizeorigin_y - panel_click_distance_y);
			}
			HUD_Panel_SetPosSize(mySize);
		}
	}
	else
	{
		if(menu_enabled == 2)
			mouse_over_panel = 0;
		else
			mouse_over_panel = HUD_Panel_Check_Mouse_Pos(TRUE);
		if (mouse_over_panel && !tab_panel)
			drawfill(panel_pos - '1 1 0' * panel_bg_border, panel_size + '2 2 0' * panel_bg_border, '1 1 1', .1, DRAWFLAG_NORMAL);
	}
	// draw cursor after performing move/resize to have the panel pos/size updated before mouse_over_panel
	const vector cursorsize = '32 32 0';
	float cursor_alpha = 1 - autocvar__menu_alpha;

	if(!mouse_over_panel)
		drawpic(mousepos, strcat("gfx/menu/", autocvar_menu_skin, "/cursor.tga"), cursorsize, '1 1 1', cursor_alpha, DRAWFLAG_NORMAL);
	else if(mouse_over_panel == 1)
		drawpic(mousepos - cursorsize * 0.5, strcat("gfx/menu/", autocvar_menu_skin, "/cursor_move.tga"), cursorsize, '1 1 1', cursor_alpha, DRAWFLAG_NORMAL);
	else if(mouse_over_panel == 2)
		drawpic(mousepos - cursorsize * 0.5, strcat("gfx/menu/", autocvar_menu_skin, "/cursor_resize.tga"), cursorsize, '1 1 1', cursor_alpha, DRAWFLAG_NORMAL);
	else
		drawpic(mousepos - cursorsize * 0.5, strcat("gfx/menu/", autocvar_menu_skin, "/cursor_resize2.tga"), cursorsize, '1 1 1', cursor_alpha, DRAWFLAG_NORMAL);

	prevMouseClicked = mouseClicked;
}
void HUD_Configure_DrawGrid()
{
	float i;
	if(autocvar_hud_configure_grid && autocvar_hud_configure_grid_alpha)
	{
		hud_configure_gridSize_x = bound(0.005, cvar("hud_configure_grid_xsize"), 0.2);
		hud_configure_gridSize_y = bound(0.005, cvar("hud_configure_grid_ysize"), 0.2);
		hud_configure_realGridSize_x = hud_configure_gridSize_x * vid_conwidth;
		hud_configure_realGridSize_y = hud_configure_gridSize_y * vid_conheight;
		vector s;
		// x-axis
		s = eX + eY * vid_conheight;
		for(i = 1; i < 1/hud_configure_gridSize_x; ++i)
			drawfill(eX * i * hud_configure_realGridSize_x, s, '0.5 0.5 0.5', autocvar_hud_configure_grid_alpha, DRAWFLAG_NORMAL);
		// y-axis
		s = eY + eX * vid_conwidth;
		for(i = 1; i < 1/hud_configure_gridSize_y; ++i)
			drawfill(eY * i * hud_configure_realGridSize_y, s, '0.5 0.5 0.5', autocvar_hud_configure_grid_alpha, DRAWFLAG_NORMAL);
	}
}

float _menu_alpha_prev;
void HUD_Configure_Frame()
{
	float i;
	if(autocvar__hud_configure)
	{
		if(isdemo() || intermission == 2)
		{
			HUD_Configure_Exit_Force();
			return;
		}

		if(!hud_configure_prev || hud_configure_prev == -1)
		{
			if(autocvar_hud_cursormode)
				setcursormode(1);
			hudShiftState = 0;
			for(i = HUD_PANEL_NUM - 1; i >= 0; --i)
				hud_panel[panel_order[i]].update_time = time;
		}

		// NOTE this check is necessary because _menu_alpha isn't updated the frame the menu gets enabled
		if(autocvar__menu_alpha != _menu_alpha_prev)
		{
			if(autocvar__menu_alpha == 0)
				menu_enabled = 0;
			_menu_alpha_prev = autocvar__menu_alpha;
		}

		HUD_Configure_DrawGrid();
	}
	else if(hud_configure_prev)
	{
		if(menu_enabled)
			menu_enabled = 0;
		if(autocvar_hud_cursormode)
			setcursormode(0);
	}
}

const float hlBorderSize = 4;
const string hlBorder = "gfx/hud/default/border_highlighted";
const string hlBorder2 = "gfx/hud/default/border_highlighted2";
void HUD_Panel_HlBorder(float myBorder, vector color, float theAlpha)
{
	drawfill(panel_pos - '1 1 0' * myBorder, panel_size + '2 2 0' * myBorder, '0 0.5 1', .5 * theAlpha, DRAWFLAG_NORMAL);
	drawpic_tiled(panel_pos - '1 1 0' * myBorder, hlBorder, '8 1 0' * hlBorderSize, eX * (panel_size_x + 2 * myBorder) + eY * hlBorderSize, color, theAlpha, DRAWFLAG_NORMAL);
	drawpic_tiled(panel_pos - '1 1 0' * myBorder + eY * (panel_size_y + 2 * myBorder - hlBorderSize), hlBorder, '8 1 0' * hlBorderSize, eX * (panel_size_x + 2 * myBorder) + eY * hlBorderSize, color, theAlpha, DRAWFLAG_NORMAL);
	drawpic_tiled(panel_pos - '1 1 0' * myBorder + eY * hlBorderSize, hlBorder2, '1 8 0' * hlBorderSize, eY * (panel_size_y + 2 * myBorder - 2 * hlBorderSize) + eX * hlBorderSize, color, theAlpha, DRAWFLAG_NORMAL);
	drawpic_tiled(panel_pos - '1 1 0' * myBorder + eY * hlBorderSize + eX * (panel_size_x + 2 * myBorder - hlBorderSize), hlBorder2, '1 8 0' * hlBorderSize, eY * (panel_size_y + 2 * myBorder - 2 * hlBorderSize) + eX * hlBorderSize, color, theAlpha, DRAWFLAG_NORMAL);
}

void HUD_Configure_PostDraw()
{
	if(autocvar__hud_configure)
	{
		if(tab_panel)
		{
			panel = tab_panel;
			HUD_Panel_UpdatePosSize()
			drawfill(panel_pos - '1 1 0' * panel_bg_border, panel_size + '2 2 0' * panel_bg_border, '1 1 1', .2, DRAWFLAG_NORMAL);
		}
		if(highlightedPanel)
		{
			panel = highlightedPanel;
			HUD_Panel_UpdatePosSize()
			HUD_Panel_HlBorder(panel_bg_border + 1.5 * hlBorderSize, '0 0.5 1', 0.25 * (1 - autocvar__menu_alpha));
		}
	}
}
