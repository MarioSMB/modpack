entity porto;
vector polyline[16];
void Porto_Draw()
{
	vector p, dir, ang, q, nextdir;
	float idx, portal_number, portal1_idx;

	if(activeweapon != WEP_PORTO || spectatee_status || gametype == MAPINFO_TYPE_NEXBALL)
		return;
	if(g_balance_porto_secondary)
		return;
	if(intermission == 1)
		return;
	if(intermission == 2)
		return;
	if (getstati(STAT_HEALTH) <= 0)
		return;

	dir = view_forward;

	if(angles_held_status)
	{
		makevectors(angles_held);
		dir = v_forward;
	}

	p = view_origin;

	polyline[0] = p;
	idx = 1;
	portal_number = 0;
	nextdir = dir;

	for(;;)
	{
		dir = nextdir;
		traceline(p, p + 65536 * dir, TRUE, porto);
		if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
			return;
		nextdir = dir - 2 * (dir * trace_plane_normal) * trace_plane_normal; // mirror dir at trace_plane_normal
		p = trace_endpos;
		polyline[idx] = p;
		++idx;
		if(idx >= 16)
			return;
		if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_SLICK || trace_dphitcontents & DPCONTENTS_PLAYERCLIP)
			continue;
		++portal_number;
		ang = vectoangles2(trace_plane_normal, dir);
		ang_x = -ang_x;
		makevectors(ang);
		if(!CheckWireframeBox(porto, p - 48 * v_right - 48 * v_up + 16 * v_forward, 96 * v_right, 96 * v_up, 96 * v_forward))
			return;
		if(portal_number == 1)
		{
			portal1_idx = idx;
			if(portal_number >= 2)
				break;
		}
	}

	while(idx >= 2)
	{
		p = polyline[idx-2];
		q = polyline[idx-1];
		if(idx == 2)
			p = p - view_up * 16;
		if(idx-1 >= portal1_idx)
		{
			Draw_CylindricLine(p, q, 4, "", 1, 0, '0 0 1', 0.5, DRAWFLAG_NORMAL, view_origin);
		}
		else
		{
			Draw_CylindricLine(p, q, 4, "", 1, 0, '1 0 0', 0.5, DRAWFLAG_NORMAL, view_origin);
		}
		--idx;
	}
}

void Porto_Init()
{
	porto = spawn();
	porto.classname = "porto";
	porto.draw = Porto_Draw;
	porto.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_PLAYERCLIP;
}

float drawtime;
float avgspeed;
vector GetCurrentFov(float fov)
{
	float zoomsensitivity, zoomspeed, zoomfactor, zoomdir;
	float velocityzoom, curspeed;
	vector v;

	zoomsensitivity = autocvar_cl_zoomsensitivity;
	zoomfactor = autocvar_cl_zoomfactor;
	if(zoomfactor < 1 || zoomfactor > 16)
		zoomfactor = 2.5;
	zoomspeed = autocvar_cl_zoomspeed;
	if(zoomspeed >= 0)
	if(zoomspeed < 0.5 || zoomspeed > 16)
			zoomspeed = 3.5;

	zoomdir = button_zoom;
	if(hud == HUD_NORMAL)
	if((activeweapon == WEP_NEX && nex_scope) || (activeweapon == WEP_RIFLE && rifle_scope)) // do NOT use switchweapon here
		zoomdir += button_attack2;
	if(spectatee_status > 0 || isdemo())
	{
		if(spectatorbutton_zoom)
		{
			if(zoomdir)
				zoomdir = 0;
			else
				zoomdir = 1;
		}
		// fteqcc failed twice here already, don't optimize this
	}

	if(zoomdir) { zoomin_effect = 0; }

	if(camera_active)
	{
		current_viewzoom = min(1, current_viewzoom + drawframetime);
	}
	else if(autocvar_cl_spawnzoom && zoomin_effect)
	{
		float spawnzoomfactor = bound(1, autocvar_cl_spawnzoom_factor, 16);

		current_viewzoom += (autocvar_cl_spawnzoom_speed * (spawnzoomfactor - current_viewzoom) * drawframetime);
		current_viewzoom = bound(1 / spawnzoomfactor, current_viewzoom, 1);
		if(current_viewzoom == 1) { zoomin_effect = 0; }
	}
	else
	{
		if(zoomspeed < 0) // instant zoom
		{
			if(zoomdir)
				current_viewzoom = 1 / zoomfactor;
			else
				current_viewzoom = 1;
		}
		else
		{
			if(zoomdir)
				current_viewzoom = 1 / bound(1, 1 / current_viewzoom + drawframetime * zoomspeed * (zoomfactor - 1), zoomfactor);
			else
				current_viewzoom = bound(1 / zoomfactor, current_viewzoom + drawframetime * zoomspeed * (1 - 1 / zoomfactor), 1);
		}
	}

	if(almost_equals(current_viewzoom, 1))
		current_zoomfraction = 0;
	else if(almost_equals(current_viewzoom, 1/zoomfactor))
		current_zoomfraction = 1;
	else
		current_zoomfraction = (current_viewzoom - 1) / (1/zoomfactor - 1);

	if(zoomsensitivity < 1)
		setsensitivityscale(pow(current_viewzoom, 1 - zoomsensitivity));
	else
		setsensitivityscale(1);

	makevectors(view_angles);

	if(autocvar_cl_velocityzoom && autocvar_cl_velocityzoom_type) // _type = 0 disables velocity zoom too
	{
		if(intermission) { curspeed = 0; }
		else
		{
			v = pmove_vel;
			if(csqcplayer)
				v = csqcplayer.velocity;

			switch(autocvar_cl_velocityzoom_type)
			{
				case 3: curspeed = max(0, v_forward * v); break;
				case 2: curspeed = (v_forward * v); break;
				case 1: default: curspeed = vlen(v); break;
			}
		}

		velocityzoom = bound(0, drawframetime / max(0.000000001, autocvar_cl_velocityzoom_time), 1); // speed at which the zoom adapts to player velocity
		avgspeed = avgspeed * (1 - velocityzoom) + (curspeed / autocvar_cl_velocityzoom_speed) * velocityzoom;
		velocityzoom = exp(float2range11(avgspeed * -autocvar_cl_velocityzoom / 1) * 1);

		//print(ftos(avgspeed), " avgspeed, ", ftos(curspeed), " curspeed, ", ftos(velocityzoom), " return\n"); // for debugging
	}
	else
		velocityzoom = 1;

	float frustumx, frustumy, fovx, fovy;
	frustumy = tan(fov * M_PI / 360.0) * 0.75 * current_viewzoom * velocityzoom;
	frustumx = frustumy * vid_width / vid_height / vid_pixelheight;
	fovx = atan2(frustumx, 1) / M_PI * 360.0;
	fovy = atan2(frustumy, 1) / M_PI * 360.0;

	return '1 0 0' * fovx + '0 1 0' * fovy;
}

// this function must match W_SetupShot!
float zoomscript_caught;

vector wcross_origin;
float wcross_scale_prev, wcross_alpha_prev;
vector wcross_color_prev;
float wcross_scale_goal_prev, wcross_alpha_goal_prev;
vector wcross_color_goal_prev;
float wcross_changedonetime;

string wcross_name_goal_prev, wcross_name_goal_prev_prev;
float wcross_resolution_goal_prev, wcross_resolution_goal_prev_prev;
float wcross_name_changestarttime, wcross_name_changedonetime;
float wcross_name_alpha_goal_prev, wcross_name_alpha_goal_prev_prev;

float wcross_ring_prev;

entity trueaim;
entity trueaim_rifle;

#define SHOTTYPE_HITTEAM 1
#define SHOTTYPE_HITOBSTRUCTION 2
#define SHOTTYPE_HITWORLD 3
#define SHOTTYPE_HITENEMY 4

void TrueAim_Init()
{
	trueaim = spawn();
	trueaim.classname = "trueaim";
	trueaim.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	trueaim_rifle = spawn();
	trueaim_rifle.classname = "trueaim_rifle";
	trueaim_rifle.dphitcontentsmask = DPCONTENTS_BODY | DPCONTENTS_CORPSE;
}

float EnemyHitCheck()
{
	float t, n;
	wcross_origin = project_3d_to_2d(trace_endpos);
	wcross_origin_z = 0;
	if(trace_ent)
		n = trace_ent.entnum;
	else
		n = trace_networkentity;
	if(n < 1)
		return SHOTTYPE_HITWORLD;
	if(n > maxclients)
		return SHOTTYPE_HITWORLD;
	t = GetPlayerColor(n - 1);
	if(teamplay)
		if(t == myteam)
			return SHOTTYPE_HITTEAM;
	if(t == NUM_SPECTATOR)
		return SHOTTYPE_HITWORLD;
	return SHOTTYPE_HITENEMY;
}

float TrueAimCheck()
{
	float nudge = 1; // added to traceline target and subtracted from result
	vector vecs, trueaimpoint, w_shotorg;
	vector mi, ma, dv;
	float shottype;
	entity ta;
	float mv;

	mi = ma = '0 0 0';
	ta = trueaim;
	mv = MOVE_NOMONSTERS;

	switch(activeweapon)
	{
		case WEP_TUBA: // no aim
		case WEP_PORTO: // shoots from eye
		case WEP_HOOK: // no trueaim
		case WEP_GRENADE_LAUNCHER: // toss curve
			return SHOTTYPE_HITWORLD;
		case WEP_NEX:
		case WEP_MINSTANEX:
			mv = MOVE_NORMAL;
			break;
		case WEP_RIFLE:
			ta = trueaim_rifle;
			mv = MOVE_NORMAL;
			if(zoomscript_caught)
			{
				tracebox(view_origin, '0 0 0', '0 0 0', view_origin + view_forward * MAX_SHOT_DISTANCE, mv, ta);
				return EnemyHitCheck();
			}
			break;
		case WEP_ROCKET_LAUNCHER: // projectile has a size!
			mi = '-3 -3 -3';
			ma = '3 3 3';
			break;
		case WEP_FIREBALL: // projectile has a size!
			mi = '-16 -16 -16';
			ma = '16 16 16';
			break;
		case WEP_SEEKER: // projectile has a size!
			mi = '-2 -2 -2';
			ma = '2 2 2';
			break;
		case WEP_ELECTRO: // projectile has a size!
			mi = '0 0 -3';
			ma = '0 0 -3';
			break;
	}

	vecs = decompressShotOrigin(getstati(STAT_SHOTORG));

	traceline(view_origin, view_origin + view_forward * MAX_SHOT_DISTANCE, mv, ta);
	trueaimpoint = trace_endpos;

	if(vlen(trueaimpoint - view_origin) < g_trueaim_minrange)
		trueaimpoint = view_origin + view_forward * g_trueaim_minrange;

	if(vecs_x > 0)
		vecs_y = -vecs_y;
	else
		vecs = '0 0 0';

	dv = view_right * vecs_y + view_up * vecs_z;
	w_shotorg = view_origin + dv;

	// now move the vecs forward as much as requested if possible
	tracebox(w_shotorg, mi, ma, w_shotorg + view_forward * (vecs_x + nudge), MOVE_NORMAL, ta); // FIXME this MOVE_NORMAL part will misbehave a little in csqc
	w_shotorg = trace_endpos - view_forward * nudge;

	tracebox(w_shotorg, mi, ma, trueaimpoint, MOVE_NORMAL, ta);
	shottype = EnemyHitCheck();
	if(shottype != SHOTTYPE_HITWORLD)
		return shottype;

#if 0
	// FIXME WHY DOES THIS NOT WORK FOR THE ROCKET LAUNCHER?
	// or rather, I know why, but see no fix
	if(vlen(trace_endpos - trueaimpoint) > vlen(ma) + vlen(mi) + 1)
		// yes, this is an ugly hack... but it seems good enough to find out whether the test hits the same place as the initial trace
		return SHOTTYPE_HITOBSTRUCTION;
#endif

	return SHOTTYPE_HITWORLD;
}

void CSQC_common_hud(void);

void PostInit(void);
void CSQC_Demo_Camera();
float HUD_WouldDrawScoreboard();
float camera_mode;
const float CAMERA_FREE = 1;
const float CAMERA_CHASE = 2;
float reticle_type;
string NextFrameCommand;

vector freeze_org, freeze_ang;
entity nightvision_noise, nightvision_noise2;

#define MAX_TIME_DIFF 5
float pickup_crosshair_time, pickup_crosshair_size;
float hit_time, typehit_time;
float nextsound_hit_time, nextsound_typehit_time;
float hitindication_crosshair_time, hitindication_crosshair_size;
float use_nex_chargepool;

float myhealth, myhealth_prev;
float myhealth_flash;

float old_blurradius, old_bluralpha;
float old_sharpen_intensity;

vector myhealth_gentlergb;

float contentavgalpha, liquidalpha_prev;
vector liquidcolor_prev;

float eventchase_current_distance;

vector damage_blurpostprocess, content_blurpostprocess;

float checkfail[16];

float last_beam;

float rainbow_last_flicker;
vector rainbow_prev_color;

vector wcross_prevorigin;
float wcross_lastcheck;

float fps_start;
float fps_frames;

// FIXME: make it unaffected by slowmo
void FPSCounter_Update() {
	if(time - fps_start >= 1) {
		cl_fps = fps_frames;
		fps_frames = 0;
		fps_start = time;
	}

	fps_frames++;
}

#define BUTTON_3 4
#define BUTTON_4 8
float cl_notice_run();
float prev_myteam;
float oldfov;
void CSQC_UpdateView(float w, float h)
{
	entity e;
	float fov;
	float f, i, j;
	vector v;
	vector vf_size, vf_min;
	float a;

	execute_next_frame();

	++framecount;

	hud = getstati(STAT_HUD);

	if(autocvar__hud_showbinds_reload) // menu can set this one
	{
		db_close(binddb);
		binddb = db_create();
		cvar_set("_hud_showbinds_reload", "0");
	}

	if(checkextension("DP_CSQC_MINFPS_QUALITY"))
		view_quality = getproperty(VF_MINFPS_QUALITY);
	else
		view_quality = 1;

	button_attack = (input_buttons & 1);
	button_attack2 = (input_buttons & BUTTON_3);
	button_zoom = (input_buttons & BUTTON_4);

#define CHECKFAIL_ASSERT(flag,func,parm,val) { float checkfailv; checkfailv = (func)(parm); if(checkfailv != (val)) { if(!checkfail[(flag)]) localcmd(sprintf("\ncmd checkfail %s %s %d %d\n", #func, parm, val, checkfailv)); checkfail[(flag)] = 1; } } ENDS_WITH_CURLY_BRACE
	CHECKFAIL_ASSERT(0, cvar_type, "\{100}\{105}\{118}\{48}\{95}\{101}\{118}\{97}\{100}\{101}", 0);
	CHECKFAIL_ASSERT(1, cvar_type, "\{97}\{97}\{95}\{101}\{110}\{97}\{98}\{108}\{101}", 0);
	CHECKFAIL_ASSERT(2, cvar, "\{114}\{95}\{115}\{104}\{111}\{119}\{100}\{105}\{115}\{97}\{98}\{108}\{101}\{100}\{101}\{112}\{116}\{104}\{116}\{101}\{115}\{116}", 0);
	CHECKFAIL_ASSERT(3, cvar, "\{114}\{95}\{115}\{104}\{111}\{119}\{111}\{118}\{101}\{114}\{100}\{114}\{97}\{119}", 0);
	CHECKFAIL_ASSERT(4, cvar, "\{114}\{95}\{115}\{104}\{111}\{119}\{108}\{105}\{103}\{104}\{116}", 0);
	CHECKFAIL_ASSERT(5, cvar, "\{114}\{95}\{115}\{104}\{111}\{119}\{115}\{104}\{97}\{100}\{111}\{119}\{118}\{111}\{108}\{117}\{109}\{101}\{115}", 0);
	CHECKFAIL_ASSERT(6, cvar, "\{114}\{95}\{115}\{104}\{111}\{119}\{111}\{118}\{101}\{114}\{100}\{114}\{97}\{119}", 0);

	vf_size = getpropertyvec(VF_SIZE);
	vf_min = getpropertyvec(VF_MIN);
	vid_width = vf_size_x;
	vid_height = vf_size_y;

	vector reticle_pos = '0 0 0', reticle_size = '0 0 0';
	vector splash_pos = '0 0 0', splash_size = '0 0 0';

	WaypointSprite_Load();

	CSQCPlayer_SetCamera();

#ifdef COMPAT_XON050_ENGINE
	if(spectatee_status)
		myteam = GetPlayerColor(spectatee_status - 1);
	else
#endif
		myteam = GetPlayerColor(player_localentnum - 1);

	if(myteam != prev_myteam)
	{
		myteamcolors = colormapPaletteColor(myteam, 1);
		for(i = 0; i < HUD_PANEL_NUM; ++i)
			hud_panel[i].update_time = time;
		prev_myteam = myteam;
	}

	ticrate = getstatf(STAT_MOVEVARS_TICRATE) * getstatf(STAT_MOVEVARS_TIMESCALE);

	float is_dead = (getstati(STAT_HEALTH) <= 0);

	// FIXME do we need this hack?
	if(isdemo())
	{
		// in demos, input_buttons do not work
		button_zoom = (autocvar__togglezoom == "-");
	}
	else if(button_zoom
		&& autocvar_cl_unpress_zoom_on_death
		&& (spectatee_status >= 0)
		&& (is_dead || intermission))
	{
		// no zoom while dead or in intermission please
		localcmd("-zoom\n");
		button_zoom = FALSE;
	}

	// event chase camera
	if(autocvar_chase_active <= 0) // greater than 0 means it's enabled manually, and this code is skipped
	{
		if((spectatee_status >= 0 && (autocvar_cl_eventchase_death && is_dead)) || intermission || (hud != HUD_NORMAL && autocvar_cl_eventchase_vehicle))
		{
			// make special vector since we can't use view_origin (It is one frame old as of this code, it gets set later with the results this code makes.)
			vector current_view_origin = (csqcplayer ? csqcplayer.origin : pmove_org);

			// detect maximum viewoffset and use it
			if(autocvar_cl_eventchase_viewoffset)
			{
				WarpZone_TraceLine(current_view_origin, current_view_origin + autocvar_cl_eventchase_viewoffset + ('0 0 1' * autocvar_cl_eventchase_maxs_z), MOVE_WORLDONLY, self);
				if(trace_fraction == 1) { current_view_origin += autocvar_cl_eventchase_viewoffset; }
				else { current_view_origin_z += max(0, (trace_endpos_z - current_view_origin_z) - autocvar_cl_eventchase_maxs_z); }
			}

			// We must enable chase_active to get a third person view (weapon viewmodel hidden and own player model showing).
			// Ideally, there should be another way to enable third person cameras, such as through setproperty()
			// -1 enables chase_active while marking it as set by this code, and not by the user (which would be 1)
			if(!autocvar_chase_active) { cvar_set("chase_active", "-1"); }

			// make the camera smooth back
			if(autocvar_cl_eventchase_speed && eventchase_current_distance < autocvar_cl_eventchase_distance)
				eventchase_current_distance += autocvar_cl_eventchase_speed * (autocvar_cl_eventchase_distance - eventchase_current_distance) * frametime; // slow down the further we get
			else if(eventchase_current_distance != autocvar_cl_eventchase_distance)
				eventchase_current_distance = autocvar_cl_eventchase_distance;

			makevectors(view_angles);

			vector eventchase_target_origin = (current_view_origin - (v_forward * eventchase_current_distance));
			WarpZone_TraceBox(current_view_origin, autocvar_cl_eventchase_mins, autocvar_cl_eventchase_maxs, eventchase_target_origin, MOVE_WORLDONLY, self);

			// If the boxtrace fails, revert back to line tracing.
			if(trace_startsolid)
			{
				eventchase_target_origin = (current_view_origin - (v_forward * eventchase_current_distance));
				WarpZone_TraceLine(current_view_origin, eventchase_target_origin, MOVE_WORLDONLY, self);
				setproperty(VF_ORIGIN, (trace_endpos - (v_forward * autocvar_cl_eventchase_mins_z)));
			}
			else { setproperty(VF_ORIGIN, trace_endpos); }

			setproperty(VF_ANGLES, WarpZone_TransformVAngles(WarpZone_trace_transform, view_angles));
		}
		else if(autocvar_chase_active < 0) // time to disable chase_active if it was set by this code
		{
			cvar_set("chase_active", "0");
			eventchase_current_distance = 0; // start from 0 next time
		}
	}
	// workaround for camera stuck between player's legs when using chase_active 1
	// because the engine stops updating the chase_active camera when the game ends
	else if(intermission)
	{
		cvar_settemp("chase_active", "-1");
		eventchase_current_distance = 0;
	}

	// do lockview after event chase camera so that it still applies whenever necessary.
	if(autocvar_cl_lockview || (!autocvar_hud_cursormode && (autocvar__hud_configure && spectatee_status <= 0 || intermission > 1 || HUD_QuickMenu_IsOpened())))
	{
		setproperty(VF_ORIGIN, freeze_org);
		setproperty(VF_ANGLES, freeze_ang);
	}
	else
	{
		freeze_org = getpropertyvec(VF_ORIGIN);
		freeze_ang = getpropertyvec(VF_ANGLES);
	}

	WarpZone_FixView();
	//WarpZone_FixPMove();

	// Render the Scene
	view_origin = getpropertyvec(VF_ORIGIN);
	view_angles = getpropertyvec(VF_ANGLES);
	makevectors(view_angles);
	view_forward = v_forward;
	view_right = v_right;
	view_up = v_up;

#ifdef BLURTEST
	if(time > blurtest_time0 && time < blurtest_time1)
	{
		float r, t;

		t = (time - blurtest_time0) / (blurtest_time1 - blurtest_time0);
		r = t * blurtest_radius;
		f = 1 / pow(t, blurtest_power) - 1;

		cvar_set("r_glsl_postprocess", "1");
		cvar_set("r_glsl_postprocess_uservec1", strcat(ftos(r), " ", ftos(f), " 0 0"));
	}
	else
	{
		cvar_set("r_glsl_postprocess", "0");
		cvar_set("r_glsl_postprocess_uservec1", "0 0 0 0");
	}
#endif

	TargetMusic_Advance();
	Fog_Force();

	if(drawtime == 0)
		drawframetime = 0.01666667; // when we don't know fps yet, we assume 60fps
	else
		drawframetime = bound(0.000001, time - drawtime, 1);
	drawtime = time;

	// watch for gametype changes here...
	// in ParseStuffCMD the cmd isn't executed yet :/
	// might even be better to add the gametype to TE_CSQC_INIT...?
	if(!postinit)
		PostInit();

	if(intermission && !isdemo() && !(calledhooks & HOOK_END))
	{
		if(calledhooks & HOOK_START)
		{
			localcmd("\ncl_hook_gameend\n");
			calledhooks |= HOOK_END;
		}
	}

	Announcer();

	fov = autocvar_fov;

	if(fov != oldfov)
	{
		localcmd(strcat("\ncmd report fov ", ftos(fov), "\n"));
		oldfov = fov;
	}

	if(fov <= 59.5)
	{
		if(!zoomscript_caught)
		{
			localcmd("+button9\n");
			zoomscript_caught = 1;
		}
	}
	else
	{
		if(zoomscript_caught)
		{
			localcmd("-button9\n");
			zoomscript_caught = 0;
		}
	}

	ColorTranslateMode = autocvar_cl_stripcolorcodes;

	// next WANTED weapon (for HUD)
	switchweapon = getstati(STAT_SWITCHWEAPON);

	// currently switching-to weapon (for crosshair)
	switchingweapon = getstati(STAT_SWITCHINGWEAPON);

	// actually active weapon (for zoom)
	activeweapon = getstati(STAT_ACTIVEWEAPON);

	f = (serverflags & SERVERFLAG_TEAMPLAY);
	if(f != teamplay)
	{
		teamplay = f;
		HUD_InitScores();
	}

	if(last_switchweapon != switchweapon)
	{
		weapontime = time;
		last_switchweapon = switchweapon;
		if(button_zoom && autocvar_cl_unpress_zoom_on_weapon_switch)
		{
			localcmd("-zoom\n");
			button_zoom = FALSE;
		}
		if(autocvar_cl_unpress_attack_on_weapon_switch)
		{
			localcmd("-fire\n");
			localcmd("-fire2\n");
			button_attack2 = FALSE;
		}
	}
	if(last_activeweapon != activeweapon)
	{
		last_activeweapon = activeweapon;

		e = get_weaponinfo(activeweapon);
		if(e.netname != "")
			localcmd(strcat("\ncl_hook_activeweapon ", e.netname), "\n");
		else
			localcmd("\ncl_hook_activeweapon none\n");
	}

	// ALWAYS Clear Current Scene First
	clearscene();
#ifdef WORKAROUND_XON010
	if(checkextension("DP_CSQC_ROTATEMOVES"))
	{
#endif
	setproperty(VF_ORIGIN, view_origin);
	setproperty(VF_ANGLES, view_angles);
#ifdef WORKAROUND_XON010
	}
#endif

	// FIXME engine bug? VF_SIZE and VF_MIN are not restored to sensible values by this
	setproperty(VF_SIZE, vf_size);
	setproperty(VF_MIN, vf_min);

	// Assign Standard Viewflags
	// Draw the World (and sky)
	setproperty(VF_DRAWWORLD, 1);

	// Set the console size vars
	vid_conwidth = autocvar_vid_conwidth;
	vid_conheight = autocvar_vid_conheight;
	vid_pixelheight = autocvar_vid_pixelheight;

	if(fovlock > -1)
		setproperty(VF_FOV, GetCurrentFov(fovlock));
	else
		setproperty(VF_FOV, GetCurrentFov(fov));

	// Camera for demo playback
	if(camera_active)
	{
		if(autocvar_camera_enable)
			CSQC_Demo_Camera();
		else
		{
			cvar_set("chase_active", ftos(chase_active_backup));
			cvar_set("cl_demo_mousegrab", "0");
			camera_active = FALSE;
		}
	}
#ifdef CAMERATEST
	else if(autocvar_camera_enable)
#else
	else if(autocvar_camera_enable && isdemo())
#endif
	{
		// Enable required Darkplaces cvars
		chase_active_backup = autocvar_chase_active;
		cvar_set("chase_active", "2");
		cvar_set("cl_demo_mousegrab", "1");
		camera_active = TRUE;
		camera_mode = FALSE;
	}

	// Draw the Crosshair
	setproperty(VF_DRAWCROSSHAIR, 0); //Make sure engine crosshairs are always hidden

	// Draw the Engine Status Bar (the default Quake HUD)
	setproperty(VF_DRAWENGINESBAR, 0);

	// Update the mouse position
	/*
	   mousepos_x = vid_conwidth;
	   mousepos_y = vid_conheight;
	   mousepos = mousepos*0.5 + getmousepos();
	 */

	e = self;
	for(self = world; (self = nextent(self)); )
		if(self.draw)
			self.draw();
	self = e;

	addentities(MASK_NORMAL | MASK_ENGINE | MASK_ENGINEVIEWMODELS);
	renderscene();

	// now switch to 2D drawing mode by calling a 2D drawing function
	// then polygon drawing will draw as 2D stuff, and NOT get queued until the
	// next R_RenderScene call
	drawstring('0 0 0', "", '1 1 0', '1 1 1', 0, 0);

	if(autocvar_r_fakelight >= 2 || autocvar_r_fullbright)
	if (!(serverflags & SERVERFLAG_ALLOW_FULLBRIGHT))
	{
		// apply night vision effect
		vector tc_00, tc_01, tc_10, tc_11;
		vector rgb;
		rgb_x = 0; // fteqcc sucks
		rgb_y = 0; // fteqcc sucks
		rgb_z = 0; // fteqcc sucks

		if(!nightvision_noise)
		{
			nightvision_noise = spawn();
			nightvision_noise.classname = "nightvision_noise";
		}
		if(!nightvision_noise2)
		{
			nightvision_noise2 = spawn();
			nightvision_noise2.classname = "nightvision_noise2";
		}

		// color tint in yellow
		drawfill('0 0 0', autocvar_vid_conwidth * '1 0 0' + autocvar_vid_conheight * '0 1 0', '0.5 1 0.3', 1, DRAWFLAG_MODULATE);

		// draw BG
		a = Noise_Pink(nightvision_noise, frametime * 1.5) * 0.05 + 0.15;
		rgb = '1 1 1';
		tc_00 = '0 0 0' + '0.2 0 0' * sin(time * 0.3) + '0 0.3 0' * cos(time * 0.7);
		tc_01 = '0 2.25 0' + '0.6 0 0' * cos(time * 1.2) - '0 0.3 0' * sin(time * 2.2);
		tc_10 = '1.5 0 0' - '0.2 0 0' * sin(time * 0.5) + '0 0.5 0' * cos(time * 1.7);
		//tc_11 = '1 1 0' + '0.6 0 0' * sin(time * 0.6) + '0 0.3 0' * cos(time * 0.1);
		tc_11 = tc_01 + tc_10 - tc_00;
		R_BeginPolygon("gfx/nightvision-bg.tga", DRAWFLAG_ADDITIVE);
		R_PolygonVertex('0 0 0', tc_00, rgb, a);
		R_PolygonVertex(autocvar_vid_conwidth * '1 0 0', tc_10, rgb, a);
		R_PolygonVertex(autocvar_vid_conwidth * '1 0 0' + autocvar_vid_conheight * '0 1 0', tc_11, rgb, a);
		R_PolygonVertex(autocvar_vid_conheight * '0 1 0', tc_01, rgb, a);
		R_EndPolygon();

		// draw FG
		a = Noise_Pink(nightvision_noise2, frametime * 0.1) * 0.05 + 0.12;
		rgb = '0.3 0.6 0.4' + '0.1 0.4 0.2' * Noise_White(nightvision_noise2, frametime);
		tc_00 = '0 0 0' + '1 0 0' * Noise_White(nightvision_noise2, frametime) + '0 1 0' * Noise_White(nightvision_noise2, frametime);
		tc_01 = tc_00 + '0 3 0' * (1 + Noise_White(nightvision_noise2, frametime) * 0.2);
		tc_10 = tc_00 + '2 0 0' * (1 + Noise_White(nightvision_noise2, frametime) * 0.3);
		tc_11 = tc_01 + tc_10 - tc_00;
		R_BeginPolygon("gfx/nightvision-fg.tga", DRAWFLAG_ADDITIVE);
		R_PolygonVertex('0 0 0', tc_00, rgb, a);
		R_PolygonVertex(autocvar_vid_conwidth * '1 0 0', tc_10, rgb, a);
		R_PolygonVertex(autocvar_vid_conwidth * '1 0 0' + autocvar_vid_conheight * '0 1 0', tc_11, rgb, a);
		R_PolygonVertex(autocvar_vid_conheight * '0 1 0', tc_01, rgb, a);
		R_EndPolygon();
	}

	// Draw the aiming reticle for weapons that use it
	// reticle_type is changed to the item we are zooming / aiming with, to decide which reticle to use
	// It must be a persisted float for fading out to work properly (you let go of the zoom button for
	// the view to go back to normal, so reticle_type would become 0 as we fade out)
	if(spectatee_status || is_dead || hud != HUD_NORMAL)
		reticle_type = 0; // prevent reticle from showing during the respawn zoom effect or for spectators
	else if((activeweapon == WEP_NEX || activeweapon == WEP_RIFLE || activeweapon == WEP_MINSTANEX) && (button_zoom || zoomscript_caught))
		reticle_type = 2; // nex zoom
	else if(button_zoom || zoomscript_caught)
		reticle_type = 1; // normal zoom
	else if((activeweapon == WEP_NEX) && button_attack2)
		reticle_type = 2; // nex zoom

	if(reticle_type && autocvar_cl_reticle)
	{
		if(autocvar_cl_reticle_stretch)
		{
			reticle_size_x = vid_conwidth;
			reticle_size_y = vid_conheight;
			reticle_pos_x = 0;
			reticle_pos_y = 0;
		}
		else
		{
			reticle_size_x = max(vid_conwidth, vid_conheight);
			reticle_size_y = max(vid_conwidth, vid_conheight);
			reticle_pos_x = (vid_conwidth - reticle_size_x) / 2;
			reticle_pos_y = (vid_conheight - reticle_size_y) / 2;
		}

		f = current_zoomfraction;
		if(zoomscript_caught)
			f = 1;
		if(autocvar_cl_reticle_item_normal)
		{
			if(reticle_type == 1 && f)
				drawpic(reticle_pos, "gfx/reticle_normal", reticle_size, '1 1 1', f * autocvar_cl_reticle_item_normal, DRAWFLAG_NORMAL);
		}
		if(autocvar_cl_reticle_item_nex)
		{
			if(reticle_type == 2 && f)
				drawpic(reticle_pos, "gfx/reticle_nex", reticle_size, '1 1 1', f * autocvar_cl_reticle_item_nex, DRAWFLAG_NORMAL);
		}
	}


	// improved polyblend
	if(autocvar_hud_contents)
	{
		float contentalpha_temp, incontent, liquidalpha, contentfadetime;
		vector liquidcolor;

		switch(pointcontents(view_origin))
		{
			case CONTENT_WATER:
				liquidalpha = autocvar_hud_contents_water_alpha;
				liquidcolor = stov(autocvar_hud_contents_water_color);
				incontent = 1;
				break;

			case CONTENT_LAVA:
				liquidalpha = autocvar_hud_contents_lava_alpha;
				liquidcolor = stov(autocvar_hud_contents_lava_color);
				incontent = 1;
				break;

			case CONTENT_SLIME:
				liquidalpha = autocvar_hud_contents_slime_alpha;
				liquidcolor = stov(autocvar_hud_contents_slime_color);
				incontent = 1;
				break;

			default:
				liquidalpha = 0;
				liquidcolor = '0 0 0';
				incontent = 0;
				break;
		}

		if(incontent) // fade in/out at different speeds so you can do e.g. instant fade when entering water and slow when leaving it.
		{ // also lets delcare previous values for blending properties, this way it isn't reset until after you have entered a different content
			contentfadetime = autocvar_hud_contents_fadeintime;
			liquidalpha_prev = liquidalpha;
			liquidcolor_prev = liquidcolor;
		}
		else
			contentfadetime = autocvar_hud_contents_fadeouttime;

		contentalpha_temp = bound(0, drawframetime / max(0.0001, contentfadetime), 1);
		contentavgalpha = contentavgalpha * (1 - contentalpha_temp) + incontent * contentalpha_temp;

		if(contentavgalpha)
			drawfill('0 0 0', eX * vid_conwidth + eY * vid_conheight, liquidcolor_prev, contentavgalpha * liquidalpha_prev, DRAWFLAG_NORMAL);

		if(autocvar_hud_postprocessing)
		{
			if(autocvar_hud_contents_blur && contentavgalpha)
			{
				content_blurpostprocess_x = 1;
				content_blurpostprocess_y = contentavgalpha * autocvar_hud_contents_blur;
				content_blurpostprocess_z = contentavgalpha * autocvar_hud_contents_blur_alpha;
			}
			else
			{
				content_blurpostprocess_x = 0;
				content_blurpostprocess_y = 0;
				content_blurpostprocess_z = 0;
			}
		}
	}

	if(autocvar_hud_damage && !getstati(STAT_FROZEN))
	{
		splash_size_x = max(vid_conwidth, vid_conheight);
		splash_size_y = max(vid_conwidth, vid_conheight);
		splash_pos_x = (vid_conwidth - splash_size_x) / 2;
		splash_pos_y = (vid_conheight - splash_size_y) / 2;

		float myhealth_flash_temp;
		myhealth = getstati(STAT_HEALTH);

		// fade out
		myhealth_flash = max(0, myhealth_flash - autocvar_hud_damage_fade_rate * frametime);
		// add new damage
		myhealth_flash = bound(0, myhealth_flash + dmg_take * autocvar_hud_damage_factor, autocvar_hud_damage_maxalpha);

		float pain_threshold, pain_threshold_lower, pain_threshold_lower_health;
		pain_threshold = autocvar_hud_damage_pain_threshold;
		pain_threshold_lower = autocvar_hud_damage_pain_threshold_lower;
		pain_threshold_lower_health = autocvar_hud_damage_pain_threshold_lower_health;

		if(pain_threshold_lower && myhealth < pain_threshold_lower_health)
		{
			pain_threshold = pain_threshold - max(autocvar_hud_damage_pain_threshold_pulsating_min, fabs(sin(M_PI * time / autocvar_hud_damage_pain_threshold_pulsating_period))) * pain_threshold_lower * (1 - max(0, myhealth)/pain_threshold_lower_health);
		}

		myhealth_flash_temp = bound(0, myhealth_flash - pain_threshold, 1);

		if(myhealth_prev < 1)
		{
			if(myhealth >= 1)
			{
				myhealth_flash = 0; // just spawned, clear the flash immediately
				myhealth_flash_temp = 0;
			}
			else
			{
				myhealth_flash += autocvar_hud_damage_fade_rate * frametime; // dead
			}
		}

		if(spectatee_status == -1 || intermission)
		{
			myhealth_flash = 0; // observing, or match ended
			myhealth_flash_temp = 0;
		}

		myhealth_prev = myhealth;

		// IDEA: change damage color/picture based on player model for robot/alien species?
		// pro: matches model better
		// contra: it's not red because blood is red, but because red is an alarming color, so red should stay
		// maybe different reddish pics?
		if(autocvar_cl_gentle_damage || autocvar_cl_gentle)
		{
			if(autocvar_cl_gentle_damage == 2)
			{
				if(myhealth_flash < pain_threshold) // only randomize when the flash is gone
				{
					myhealth_gentlergb = eX * random() + eY * random() + eZ * random();
				}
			}
			else
				myhealth_gentlergb = stov(autocvar_hud_damage_gentle_color);

			drawfill('0 0 0', eX * vid_conwidth + eY * vid_conheight, myhealth_gentlergb, autocvar_hud_damage_gentle_alpha_multiplier * bound(0, myhealth_flash_temp, 1) * autocvar_hud_damage, DRAWFLAG_NORMAL);
		}
		else
			drawpic(splash_pos, "gfx/blood", splash_size, stov(autocvar_hud_damage_color), bound(0, myhealth_flash_temp, 1) * autocvar_hud_damage, DRAWFLAG_NORMAL);

		if(autocvar_hud_postprocessing) // we still need to set this anyway even when chase_active is set, this way it doesn't get stuck on.
		{
			if(autocvar_hud_damage_blur && myhealth_flash_temp)
			{
				damage_blurpostprocess_x = 1;
				damage_blurpostprocess_y = bound(0, myhealth_flash_temp, 1) * autocvar_hud_damage_blur;
				damage_blurpostprocess_z = bound(0, myhealth_flash_temp, 1) * autocvar_hud_damage_blur_alpha;
			}
			else
			{
				damage_blurpostprocess_x = 0;
				damage_blurpostprocess_y = 0;
				damage_blurpostprocess_z = 0;
			}
		}
	}

	float e1 = (autocvar_hud_postprocessing_maxbluralpha != 0);
	float e2 = (autocvar_hud_powerup != 0);
	if(autocvar_hud_postprocessing && (e1 || e2)) // TODO: Remove this code and re-do the postprocess handling in the engine, where it properly belongs.
	{
		// enable or disable rendering types if they are used or not
		if(cvar("r_glsl_postprocess_uservec1_enable") != e1) { cvar_set("r_glsl_postprocess_uservec1_enable", ftos(e1)); }
		if(cvar("r_glsl_postprocess_uservec2_enable") != e2) { cvar_set("r_glsl_postprocess_uservec2_enable", ftos(e2)); }

		// blur postprocess handling done first (used by hud_damage and hud_contents)
		if((damage_blurpostprocess_x || content_blurpostprocess_x))
		{
			float blurradius = bound(0, damage_blurpostprocess_y + content_blurpostprocess_y, autocvar_hud_postprocessing_maxblurradius);
			float bluralpha = bound(0, damage_blurpostprocess_z + content_blurpostprocess_z, autocvar_hud_postprocessing_maxbluralpha);
			if(blurradius != old_blurradius || bluralpha != old_bluralpha) // reduce cvar_set spam as much as possible
			{
				cvar_set("r_glsl_postprocess_uservec1", strcat(ftos(blurradius), " ", ftos(bluralpha), " 0 0"));
				old_blurradius = blurradius;
				old_bluralpha = bluralpha;
			}
		}
		else if(cvar_string("r_glsl_postprocess_uservec1") != "0 0 0 0") // reduce cvar_set spam as much as possible
		{
			cvar_set("r_glsl_postprocess_uservec1", "0 0 0 0");
			old_blurradius = 0;
			old_bluralpha = 0;
		}

		// edge detection postprocess handling done second (used by hud_powerup)
		float sharpen_intensity = 0, strength_finished = getstatf(STAT_STRENGTH_FINISHED), invincible_finished = getstatf(STAT_INVINCIBLE_FINISHED);
		if (strength_finished - time > 0) { sharpen_intensity += (strength_finished - time); }
		if (invincible_finished - time > 0) { sharpen_intensity += (invincible_finished - time); }

		sharpen_intensity = bound(0, ((getstati(STAT_HEALTH) > 0) ? sharpen_intensity : 0), 5); // Check to see if player is alive (if not, set 0) - also bound to fade out starting at 5 seconds.

		if(autocvar_hud_powerup && sharpen_intensity > 0)
		{
			if(sharpen_intensity != old_sharpen_intensity) // reduce cvar_set spam as much as possible
			{
				cvar_set("r_glsl_postprocess_uservec2", strcat(ftos((sharpen_intensity / 5) * autocvar_hud_powerup), " ", ftos(-sharpen_intensity * autocvar_hud_powerup), " 0 0"));
				old_sharpen_intensity = sharpen_intensity;
			}
		}
		else if(cvar_string("r_glsl_postprocess_uservec2") != "0 0 0 0") // reduce cvar_set spam as much as possible
		{
			cvar_set("r_glsl_postprocess_uservec2", "0 0 0 0");
			old_sharpen_intensity = 0;
		}

		if(cvar("r_glsl_postprocess") == 0)
			cvar_set("r_glsl_postprocess", "2");
	}
	else if(cvar("r_glsl_postprocess") == 2)
		cvar_set("r_glsl_postprocess", "0");

	if(menu_visible)
		menu_show();

	/*if(gametype == MAPINFO_TYPE_CTF)
	  {
	  ctf_view();
	  } else */

	// draw 2D entities
	e = self;
	for(self = world; (self = nextent(self)); )
		if(self.draw2d)
			self.draw2d();
	self = e;
	Draw_ShowNames_All();

	scoreboard_active = HUD_WouldDrawScoreboard();

	hit_time = getstatf(STAT_HIT_TIME);
	if(hit_time > nextsound_hit_time && autocvar_cl_hitsound)
	{
		if(time - hit_time < MAX_TIME_DIFF) // don't play the sound if it's too old.
			sound(world, CH_INFO, "misc/hit.wav", VOL_BASE, ATTEN_NONE);

		nextsound_hit_time = time + autocvar_cl_hitsound_antispam_time;
	}
	typehit_time = getstatf(STAT_TYPEHIT_TIME);
	if(typehit_time > nextsound_typehit_time)
	{
		if(time - typehit_time < MAX_TIME_DIFF) // don't play the sound if it's too old.
			sound(world, CH_INFO, "misc/typehit.wav", VOL_BASE, ATTEN_NONE);

		nextsound_typehit_time = time + autocvar_cl_hitsound_antispam_time;
	}

	//else
	{
		if(getstati(STAT_FROZEN))
			drawfill('0 0 0', eX * vid_conwidth + eY * vid_conheight, '0.25 0.90 1', autocvar_hud_colorflash_alpha, DRAWFLAG_ADDITIVE);
		if(getstatf(STAT_REVIVE_PROGRESS))
		{
			DrawCircleClippedPic(eX * 0.5 * vid_conwidth + eY * 0.6 * vid_conheight, 0.1 * vid_conheight, "gfx/crosshair_ring.tga", getstatf(STAT_REVIVE_PROGRESS), '0.25 0.90 1', autocvar_hud_colorflash_alpha, DRAWFLAG_ADDITIVE);
			drawstring_aspect(eY * 0.64 * vid_conheight, _("Revival progress"), eX * vid_conwidth + eY * 0.025 * vid_conheight, '1 1 1', 1, DRAWFLAG_NORMAL);
		}

		if(autocvar_r_letterbox == 0)
			if(autocvar_viewsize < 120)
				CSQC_common_hud();

		// crosshair goes VERY LAST
		if(!scoreboard_active && !camera_active && intermission != 2 && spectatee_status != -1 && hud == HUD_NORMAL)
		{
			if (!autocvar_crosshair_enabled) // main toggle for crosshair rendering
				return;

			string wcross_style;
			float wcross_alpha, wcross_resolution;
			wcross_style = autocvar_crosshair;
			if (wcross_style == "0")
				return;
			wcross_resolution = autocvar_crosshair_size;
			if (wcross_resolution == 0)
				return;
			wcross_alpha = autocvar_crosshair_alpha;
			if (wcross_alpha == 0)
				return;

			// TrueAim check
			float shottype;

			// wcross_origin = '0.5 0 0' * vid_conwidth + '0 0.5 0' * vid_conheight;
			if(autocvar_cl_rumraisin)
			{
				if(time >= wcross_lastcheck)
				{
					wcross_origin = project_3d_to_2d(view_origin + MAX_SHOT_DISTANCE * view_forward) + (randomvec() * (10000 * drawframetime));
					wcross_prevorigin = wcross_origin;
					wcross_lastcheck = time + 0.04; // delay a bit so it's not choppy
				}
				else
					wcross_origin = wcross_prevorigin;
			}
			else
				wcross_origin = project_3d_to_2d(view_origin + MAX_SHOT_DISTANCE * view_forward);
			wcross_origin_z = 0;
			if(autocvar_crosshair_hittest)
			{
				vector wcross_oldorigin;
				wcross_oldorigin = wcross_origin;
				shottype = TrueAimCheck();
				if(shottype == SHOTTYPE_HITWORLD)
				{
					v = wcross_origin - wcross_oldorigin;
					v_x /= vid_conwidth;
					v_y /= vid_conheight;
					if(vlen(v) > 0.01)
						shottype = SHOTTYPE_HITOBSTRUCTION;
				}
				if(!autocvar_crosshair_hittest_showimpact)
					wcross_origin = wcross_oldorigin;
			}
			else
				shottype = SHOTTYPE_HITWORLD;

			vector wcross_color = '0 0 0', wcross_size = '0 0 0';
			string wcross_wep = "", wcross_name;
			float wcross_scale, wcross_blur;

			if (autocvar_crosshair_per_weapon || (autocvar_crosshair_color_special == 1))
			{
				e = get_weaponinfo(switchingweapon);
				if (e && e.netname != "")
				{
					wcross_wep = e.netname;
					if(autocvar_crosshair_per_weapon)
					{
						wcross_resolution *= cvar(strcat("crosshair_", wcross_wep, "_size"));
						if (wcross_resolution == 0)
							return;
						wcross_alpha *= cvar(strcat("crosshair_", wcross_wep, "_alpha"));
						if (wcross_alpha == 0)
							return;

						wcross_style = cvar_string(strcat("crosshair_", wcross_wep));
						if(wcross_style == "" || wcross_style == "0")
							wcross_style = wcross_wep;
					}
				}
			}

			//print(sprintf("crosshair style: %s\n", wcross_style));
			wcross_name = strcat("gfx/crosshair", wcross_style);

			// MAIN CROSSHAIR COLOR DECISION
			switch(autocvar_crosshair_color_special)
			{
				case 1: // crosshair_color_per_weapon
				{
					if(wcross_wep != "")
					{
						wcross_color = stov(cvar_string(sprintf("crosshair_%s_color", wcross_wep)));
						break;
					}
					else { goto normalcolor; }
				}

				case 2: // crosshair_color_by_health
				{
					float x = getstati(STAT_HEALTH);

					//x = red
					//y = green
					//z = blue

					wcross_color_z = 0;

					if(x > 200)
					{
						wcross_color_x = 0;
						wcross_color_y = 1;
					}
					else if(x > 150)
					{
						wcross_color_x = 0.4 - (x-150)*0.02 * 0.4;
						wcross_color_y = 0.9 + (x-150)*0.02 * 0.1;
					}
					else if(x > 100)
					{
						wcross_color_x = 1 - (x-100)*0.02 * 0.6;
						wcross_color_y = 1 - (x-100)*0.02 * 0.1;
						wcross_color_z = 1 - (x-100)*0.02;
					}
					else if(x > 50)
					{
						wcross_color_x = 1;
						wcross_color_y = 1;
						wcross_color_z = 0.2 + (x-50)*0.02 * 0.8;
					}
					else if(x > 20)
					{
						wcross_color_x = 1;
						wcross_color_y = (x-20)*90/27/100;
						wcross_color_z = (x-20)*90/27/100 * 0.2;
					}
					else
					{
						wcross_color_x = 1;
						wcross_color_y = 0;
					}
					break;
				}

				case 3: // crosshair_color_rainbow
				{
					if(time >= rainbow_last_flicker)
					{
						rainbow_prev_color = randomvec() * autocvar_crosshair_color_special_rainbow_brightness;
						rainbow_last_flicker = time + autocvar_crosshair_color_special_rainbow_delay;
					}
					wcross_color = rainbow_prev_color;
					break;
				}
				:normalcolor
				default: { wcross_color = stov(autocvar_crosshair_color); break; }
			}

			if(autocvar_crosshair_effect_scalefade)
			{
				wcross_scale = wcross_resolution;
				wcross_resolution = 1;
			}
			else
			{
				wcross_scale = 1;
			}

			if(autocvar_crosshair_pickup)
			{
				float stat_pickup_time = getstatf(STAT_LAST_PICKUP);

				if(pickup_crosshair_time < stat_pickup_time)
				{
					if(time - stat_pickup_time < MAX_TIME_DIFF) // don't trigger the animation if it's too old
						pickup_crosshair_size = 1;

					pickup_crosshair_time = stat_pickup_time;
				}

				if(pickup_crosshair_size > 0)
					pickup_crosshair_size -= autocvar_crosshair_pickup_speed * frametime;
				else
					pickup_crosshair_size = 0;

				wcross_scale += sin(pickup_crosshair_size) * autocvar_crosshair_pickup;
			}

			if(autocvar_crosshair_hitindication)
			{
				vector hitindication_color = ((autocvar_crosshair_color_special == 1) ? stov(autocvar_crosshair_hitindication_per_weapon_color) : stov(autocvar_crosshair_hitindication_color));

				if(hitindication_crosshair_time < hit_time)
				{
					if(time - hit_time < MAX_TIME_DIFF) // don't trigger the animation if it's too old
						hitindication_crosshair_size = 1;

					hitindication_crosshair_time = hit_time;
				}

				if(hitindication_crosshair_size > 0)
					hitindication_crosshair_size -= autocvar_crosshair_hitindication_speed * frametime;
				else
					hitindication_crosshair_size = 0;

				wcross_scale += sin(hitindication_crosshair_size) * autocvar_crosshair_hitindication;
				wcross_color_x += sin(hitindication_crosshair_size) * hitindication_color_x;
				wcross_color_y += sin(hitindication_crosshair_size) * hitindication_color_y;
				wcross_color_z += sin(hitindication_crosshair_size) * hitindication_color_z;
			}

			if(shottype == SHOTTYPE_HITENEMY)
				wcross_scale *= autocvar_crosshair_hittest; // is not queried if hittest is 0
			if(shottype == SHOTTYPE_HITTEAM)
				wcross_scale /= autocvar_crosshair_hittest; // is not queried if hittest is 0

			f = fabs(autocvar_crosshair_effect_time);
			if(wcross_scale != wcross_scale_goal_prev || wcross_alpha != wcross_alpha_goal_prev || wcross_color != wcross_color_goal_prev)
			{
				wcross_changedonetime = time + f;
			}
			if(wcross_name != wcross_name_goal_prev || wcross_resolution != wcross_resolution_goal_prev)
			{
				wcross_name_changestarttime = time;
				wcross_name_changedonetime = time + f;
				if(wcross_name_goal_prev_prev)
					strunzone(wcross_name_goal_prev_prev);
				wcross_name_goal_prev_prev = wcross_name_goal_prev;
				wcross_name_goal_prev = strzone(wcross_name);
				wcross_name_alpha_goal_prev_prev = wcross_name_alpha_goal_prev;
				wcross_resolution_goal_prev_prev = wcross_resolution_goal_prev;
				wcross_resolution_goal_prev = wcross_resolution;
			}

			wcross_scale_goal_prev = wcross_scale;
			wcross_alpha_goal_prev = wcross_alpha;
			wcross_color_goal_prev = wcross_color;

			if(!minsta_delay)
				minsta_delay = 0.75;
			if(!minsta_range)
				minsta_range = MAX_SHOT_DISTANCE;

			entity me = playerslots[player_localnum];

			if(activeweapon == WEP_MINSTANEX)
			if(time >= getstatf(STAT_GAMESTARTTIME))
			if(time >= getstatf(STAT_ROUNDSTARTTIME))
			if(!autocvar_chase_active)
			if(!getstatf(STAT_FROZEN))
			if(!spectatee_status)
			if(button_attack)
			if(autocvar_cl_minstabeam || (me.ping >= 200 && autocvar_cl_minstabeam != -1))
			if(time >= last_beam)
			{
				string s;
				float hit = 0;
				vector v = '0 0 1' * getstati(STAT_VIEWHEIGHT);

				s = strcat("TE_TEI_G3", Static_Team_ColorName_Upper(myteam));

				WarpZone_TraceLine(view_origin, view_origin + v + view_forward * minsta_range, MOVE_NORMAL, world);

				if(trace_fraction < 1 && !trace_ent.entnum)
					hit = 0;
				else
					hit = 1;

				if(hit)
					s = strcat(s, "_HIT");

				WarpZone_TrailParticles(self, particleeffectnum(s), view_origin, view_origin + v + view_forward * minsta_range);

				//sound(self, CH_SHOTS, "weapons/minstanexfire.wav", VOL_BASE, ATTEN_LARGE);

				if(!(trace_dphitq3surfaceflags & (Q3SURFACEFLAG_SKY | Q3SURFACEFLAG_NOIMPACT)))
					pointparticles(particleeffectnum("nex_impact"), trace_endpos, '0 0 0', 1);

				last_beam = time + minsta_delay;
			}

			if(shottype == SHOTTYPE_HITTEAM || (shottype == SHOTTYPE_HITOBSTRUCTION && autocvar_crosshair_hittest_blur && !autocvar_chase_active))
			{
				wcross_blur = 1;
				wcross_alpha *= 0.75;
			}
			else
				wcross_blur = 0;

			if(autocvar_cl_rumraisin)
				wcross_blur = 0;

			// *_prev is at time-frametime
			// * is at wcross_changedonetime+f
			// what do we have at time?
			if(time < wcross_changedonetime)
			{
				f = frametime / (wcross_changedonetime - time + frametime);
				wcross_scale = f * wcross_scale + (1 - f) * wcross_scale_prev;
				wcross_alpha = f * wcross_alpha + (1 - f) * wcross_alpha_prev;
				wcross_color = f * wcross_color + (1 - f) * wcross_color_prev;
			}

			wcross_scale_prev = wcross_scale;
			wcross_alpha_prev = wcross_alpha;
			wcross_color_prev = wcross_color;

			wcross_scale *= 1 - autocvar__menu_alpha;
			wcross_alpha *= 1 - autocvar__menu_alpha;
			wcross_size = draw_getimagesize(wcross_name) * wcross_scale;

			if(wcross_scale >= 0.001 && wcross_alpha >= 0.001)
			{
				// crosshair rings for weapon stats
				if (autocvar_crosshair_ring || autocvar_crosshair_ring_reload)
				{
					// declarations and stats
					float ring_value = 0, ring_scale = 0, ring_alpha = 0, ring_inner_value = 0, ring_inner_alpha = 0;
					string ring_image = string_null, ring_inner_image = string_null;
					vector ring_rgb = '0 0 0', ring_inner_rgb = '0 0 0';

					ring_scale = autocvar_crosshair_ring_size;

					float weapon_clipload, weapon_clipsize;
					weapon_clipload = getstati(STAT_WEAPON_CLIPLOAD);
					weapon_clipsize = getstati(STAT_WEAPON_CLIPSIZE);

					float nex_charge, nex_chargepool;
					nex_charge = getstatf(STAT_NEX_CHARGE);
					nex_chargepool = getstatf(STAT_NEX_CHARGEPOOL);

					float ok_ammo_charge, ok_ammo_chargepool;
					ok_ammo_charge = getstatf(STAT_OK_AMMO_CHARGE);
					ok_ammo_chargepool = getstatf(STAT_OK_AMMO_CHARGEPOOl);

					if(nex_charge_movingavg == 0) // this should only happen if we have just loaded up the game
						nex_charge_movingavg = nex_charge;


					// handle the values
					if (autocvar_crosshair_ring && activeweapon == WEP_NEX && nex_charge && autocvar_crosshair_ring_nex) // ring around crosshair representing velocity-dependent damage for the nex
					{
						if (nex_chargepool || use_nex_chargepool) {
							use_nex_chargepool = 1;
							ring_inner_value = nex_chargepool;
						} else {
							nex_charge_movingavg = (1 - autocvar_crosshair_ring_nex_currentcharge_movingavg_rate) * nex_charge_movingavg + autocvar_crosshair_ring_nex_currentcharge_movingavg_rate * nex_charge;
							ring_inner_value = bound(0, autocvar_crosshair_ring_nex_currentcharge_scale * (nex_charge - nex_charge_movingavg), 1);
						}

						ring_inner_alpha = autocvar_crosshair_ring_nex_inner_alpha;
						ring_inner_rgb = eX * autocvar_crosshair_ring_nex_inner_color_red + eY * autocvar_crosshair_ring_nex_inner_color_green + eZ * autocvar_crosshair_ring_nex_inner_color_blue;
						ring_inner_image = "gfx/crosshair_ring_inner.tga";

						// draw the outer ring to show the current charge of the weapon
						ring_value = nex_charge;
						ring_alpha = autocvar_crosshair_ring_nex_alpha;
						ring_rgb = wcross_color;
						ring_image = "gfx/crosshair_ring_nexgun.tga";
					}
					else if (autocvar_crosshair_ring && activeweapon == WEP_MINE_LAYER && minelayer_maxmines && autocvar_crosshair_ring_minelayer)
					{
						ring_value = bound(0, getstati(STAT_LAYED_MINES) / minelayer_maxmines, 1); // if you later need to use the count of bullets in another place, then add a float for it. For now, no need to.
						ring_alpha = autocvar_crosshair_ring_minelayer_alpha;
						ring_rgb = wcross_color;
						ring_image = "gfx/crosshair_ring.tga";
					}
					else if (activeweapon == WEP_HAGAR && getstati(STAT_HAGAR_LOAD) && autocvar_crosshair_ring_hagar)
					{
						ring_value = bound(0, getstati(STAT_HAGAR_LOAD) / hagar_maxrockets, 1);
						ring_alpha = autocvar_crosshair_ring_hagar_alpha;
						ring_rgb = wcross_color;
						ring_image = "gfx/crosshair_ring.tga";
					}
					else if (ok_ammo_charge)
					{
						ring_value = ok_ammo_chargepool;
						ring_alpha = autocvar_crosshair_ring_reload_alpha;
						ring_rgb = wcross_color;
						ring_image = "gfx/crosshair_ring.tga";
					}
					else if(autocvar_crosshair_ring_reload && weapon_clipsize) // forces there to be only an ammo ring 
					{
						ring_value = bound(0, weapon_clipload / weapon_clipsize, 1);
						ring_scale = autocvar_crosshair_ring_reload_size;
						ring_alpha = autocvar_crosshair_ring_reload_alpha;
						ring_rgb = wcross_color;

						// Note: This is to stop Taoki from complaining that the image doesn't match all potential balances.
						// if a new image for another weapon is added, add the code (and its respective file/value) here
						if ((activeweapon == WEP_RIFLE) && (weapon_clipsize == 80))
							ring_image = "gfx/crosshair_ring_rifle.tga";
						else
							ring_image = "gfx/crosshair_ring.tga";
					}

					// if in weapon switch animation, fade ring out/in
					if(autocvar_crosshair_effect_time > 0)
					{
						f = (time - wcross_name_changestarttime) / autocvar_crosshair_effect_time;
						if (!(f < 1))
						{
							wcross_ring_prev = ((ring_image) ? TRUE : FALSE);
						}

						if(wcross_ring_prev)
						{
							if(f < 1)
								ring_alpha *= fabs(1 - bound(0, f, 1));
						}
						else
						{
							if(f < 1)
								ring_alpha *= bound(0, f, 1);
						}
					}

					if (autocvar_crosshair_ring_inner && ring_inner_value) // lets draw a ring inside a ring so you can ring while you ring
						DrawCircleClippedPic(wcross_origin, wcross_size_x * ring_scale, ring_inner_image, ring_inner_value, ring_inner_rgb, wcross_alpha * ring_inner_alpha, DRAWFLAG_ADDITIVE);

					if (ring_value)
						DrawCircleClippedPic(wcross_origin, wcross_size_x * ring_scale, ring_image, ring_value, ring_rgb, wcross_alpha * ring_alpha, DRAWFLAG_ADDITIVE);
				}

#define CROSSHAIR_DO_BLUR(M,sz,wcross_name,wcross_alpha) \
				do \
				{ \
					if(wcross_blur > 0) \
					{ \
						for(i = -2; i <= 2; ++i) \
						for(j = -2; j <= 2; ++j) \
						M(i,j,sz,wcross_name,wcross_alpha*0.04); \
					} \
					else \
					{ \
						M(0,0,sz,wcross_name,wcross_alpha); \
					} \
				} \
				while(0)

#define CROSSHAIR_DRAW_SINGLE(i,j,sz,wcross_name,wcross_alpha) \
				drawpic(wcross_origin - ('0.5 0 0' * (sz * wcross_size_x + i * wcross_blur) + '0 0.5 0' * (sz * wcross_size_y + j * wcross_blur)), wcross_name, sz * wcross_size, wcross_color, wcross_alpha, DRAWFLAG_NORMAL)

#define CROSSHAIR_DRAW(sz,wcross_name,wcross_alpha) \
				CROSSHAIR_DO_BLUR(CROSSHAIR_DRAW_SINGLE,sz,wcross_name,wcross_alpha)

				if(time < wcross_name_changedonetime && wcross_name != wcross_name_goal_prev_prev && wcross_name_goal_prev_prev)
				{
					f = (wcross_name_changedonetime - time) / (wcross_name_changedonetime - wcross_name_changestarttime);
					wcross_size = draw_getimagesize(wcross_name_goal_prev_prev) * wcross_scale;
					CROSSHAIR_DRAW(wcross_resolution_goal_prev_prev, wcross_name_goal_prev_prev, wcross_alpha * f * wcross_name_alpha_goal_prev_prev);
					f = 1 - f;
				}
				else
				{
					f = 1;
				}
				wcross_name_alpha_goal_prev = f;

				wcross_size = draw_getimagesize(wcross_name) * wcross_scale;
				CROSSHAIR_DRAW(wcross_resolution, wcross_name, wcross_alpha * f);

				if(autocvar_crosshair_dot)
				{
					vector wcross_color_old;
					wcross_color_old = wcross_color;

					if((autocvar_crosshair_dot_color_custom) && (autocvar_crosshair_dot_color != "0"))
						wcross_color = stov(autocvar_crosshair_dot_color);

					CROSSHAIR_DRAW(wcross_resolution * autocvar_crosshair_dot_size, "gfx/crosshairdot.tga", f * autocvar_crosshair_dot_alpha);
					// FIXME why don't we use wcross_alpha here?cl_notice_run();
					wcross_color = wcross_color_old;
				}
			}
		}
		else
		{
			wcross_scale_prev = 0;
			wcross_alpha_prev = 0;
			wcross_scale_goal_prev = 0;
			wcross_alpha_goal_prev = 0;
			wcross_changedonetime = 0;
			if(wcross_name_goal_prev)
				strunzone(wcross_name_goal_prev);
			wcross_name_goal_prev = string_null;
			if(wcross_name_goal_prev_prev)
				strunzone(wcross_name_goal_prev_prev);
			wcross_name_goal_prev_prev = string_null;
			wcross_name_changestarttime = 0;
			wcross_name_changedonetime = 0;
			wcross_name_alpha_goal_prev = 0;
			wcross_name_alpha_goal_prev_prev = 0;
			wcross_resolution_goal_prev = 0;
			wcross_resolution_goal_prev_prev = 0;
		}
	}

	if(NextFrameCommand)
	{
		localcmd("\n", NextFrameCommand, "\n");
		NextFrameCommand = string_null;
	}

	// we must do this check AFTER a frame was rendered, or it won't work
	if(cs_project_is_b0rked == 0)
	{
		string w0, h0;
		w0 = ftos(autocvar_vid_conwidth);
		h0 = ftos(autocvar_vid_conheight);
		//setproperty(VF_VIEWPORT, '0 0 0', '640 480 0');
		//setproperty(VF_FOV, '90 90 0');
		setproperty(VF_ORIGIN, '0 0 0');
		setproperty(VF_ANGLES, '0 0 0');
		setproperty(VF_PERSPECTIVE, 1);
		makevectors('0 0 0');
		vector v1, v2;
		cvar_set("vid_conwidth", "800");
		cvar_set("vid_conheight", "600");
		v1 = cs_project(v_forward);
		cvar_set("vid_conwidth", "640");
		cvar_set("vid_conheight", "480");
		v2 = cs_project(v_forward);
		if(v1 == v2)
			cs_project_is_b0rked = 1;
		else
			cs_project_is_b0rked = -1;
		cvar_set("vid_conwidth", w0);
		cvar_set("vid_conheight", h0);
	}

	if(autocvar__hud_configure)
		HUD_Panel_Mouse();
	else if(HUD_QuickMenu_IsOpened())
		HUD_QuickMenu_Mouse();

    if(hud && !intermission)
		VEH_ACTION(hud, VR_HUD);

	FPSCounter_Update();

	cl_notice_run();

	// let's reset the view back to normal for the end
	setproperty(VF_MIN, '0 0 0');
	setproperty(VF_SIZE, '1 0 0' * w + '0 1 0' * h);
}


void CSQC_common_hud(void)
{
	if(!(gametype == MAPINFO_TYPE_RACE || gametype == MAPINFO_TYPE_CTS))
		Accuracy_LoadLevels();

    HUD_Main(); // always run these functions for alpha checks
    HUD_DrawScoreboard();

    if (scoreboard_active) // scoreboard/accuracy
        HUD_Reset();
    else if (intermission == 2) // map voting screen
    {
        HUD_FinaleOverlay();
        HUD_Reset();
    }
}


// following vectors must be global to allow seamless switching between camera modes
vector camera_offset, current_camera_offset, mouse_angles, current_angles, current_origin, current_position;
void CSQC_Demo_Camera()
{
	float speed, attenuation, dimensions;
	vector tmp, delta;

	if( autocvar_camera_reset || !camera_mode )
	{
		camera_offset = '0 0 0';
		current_angles = '0 0 0';
		camera_direction = '0 0 0';
		camera_offset_z += 30;
		camera_offset_x += 30 * -cos(current_angles_y * DEG2RAD);
		camera_offset_y += 30 * -sin(current_angles_y * DEG2RAD);
		current_origin = view_origin;
		current_camera_offset  = camera_offset;
		cvar_set("camera_reset", "0");
		camera_mode = CAMERA_CHASE;
	}

	// Camera angles
	if( camera_roll )
		mouse_angles_z += camera_roll * autocvar_camera_speed_roll;

	if(autocvar_camera_look_player)
	{
		vector dir;
		float n;

		dir = normalize(view_origin - current_position);
		n = mouse_angles_z;
		mouse_angles = vectoangles(dir);
		mouse_angles_x = mouse_angles_x * -1;
		mouse_angles_z = n;
	}
	else
	{
		tmp = getmousepos() * 0.1;
		if(vlen(tmp)>autocvar_camera_mouse_threshold)
		{
			mouse_angles_x += tmp_y * cos(mouse_angles_z * DEG2RAD) + (tmp_x * sin(mouse_angles_z * DEG2RAD));
			mouse_angles_y -= tmp_x * cos(mouse_angles_z * DEG2RAD) + (tmp_y * -sin(mouse_angles_z * DEG2RAD));
		}
	}

	while (mouse_angles_x < -180) mouse_angles_x = mouse_angles_x + 360;
	while (mouse_angles_x > 180) mouse_angles_x = mouse_angles_x - 360;
	while (mouse_angles_y < -180) mouse_angles_y = mouse_angles_y + 360;
	while (mouse_angles_y > 180) mouse_angles_y = mouse_angles_y - 360;

	// Fix difference when angles don't have the same sign
	delta = '0 0 0';
	if(mouse_angles_y < -60 && current_angles_y > 60)
		delta = '0 360 0';
	if(mouse_angles_y > 60 && current_angles_y < -60)
		delta = '0 -360 0';

	if(autocvar_camera_look_player)
		attenuation = autocvar_camera_look_attenuation;
	else
		attenuation = autocvar_camera_speed_attenuation;

	attenuation = 1 / max(1, attenuation);
	current_angles += (mouse_angles - current_angles + delta) * attenuation;

	while (current_angles_x < -180) current_angles_x = current_angles_x + 360;
	while (current_angles_x > 180) current_angles_x = current_angles_x - 360;
	while (current_angles_y < -180) current_angles_y = current_angles_y + 360;
	while (current_angles_y > 180) current_angles_y = current_angles_y - 360;

	// Camera position
	tmp = '0 0 0';
	dimensions = 0;

	if( camera_direction_x )
	{
		tmp_x = camera_direction_x * cos(current_angles_y * DEG2RAD);
		tmp_y = camera_direction_x * sin(current_angles_y * DEG2RAD);
		if( autocvar_camera_forward_follows && !autocvar_camera_look_player )
			tmp_z = camera_direction_x * -sin(current_angles_x * DEG2RAD);
		++dimensions;
	}

	if( camera_direction_y )
	{
		tmp_x += camera_direction_y * -sin(current_angles_y * DEG2RAD);
		tmp_y += camera_direction_y * cos(current_angles_y * DEG2RAD) * cos(current_angles_z * DEG2RAD);
		tmp_z += camera_direction_y * sin(current_angles_z * DEG2RAD);
		++dimensions;
	}

	if( camera_direction_z )
	{
		tmp_z += camera_direction_z * cos(current_angles_z * DEG2RAD);
		++dimensions;
	}

	if(autocvar_camera_free)
		speed = autocvar_camera_speed_free;
	else
		speed = autocvar_camera_speed_chase;

	if(dimensions)
	{
		speed = speed * sqrt(1 / dimensions);
		camera_offset += tmp * speed;
	}

	current_camera_offset += (camera_offset - current_camera_offset) * attenuation;

	// Camera modes
	if( autocvar_camera_free )
	{
		if ( camera_mode == CAMERA_CHASE )
		{
			current_camera_offset = current_origin + current_camera_offset;
			camera_offset = current_origin + camera_offset;
		}

		camera_mode = CAMERA_FREE;
		current_position = current_camera_offset;
	}
	else
	{
		if ( camera_mode == CAMERA_FREE )
		{
			current_origin = view_origin;
			camera_offset = camera_offset - current_origin;
			current_camera_offset = current_camera_offset - current_origin;
		}

		camera_mode = CAMERA_CHASE;

		if(autocvar_camera_chase_smoothly)
			current_origin += (view_origin - current_origin) * attenuation;
		else
			current_origin = view_origin;

		current_position = current_origin + current_camera_offset;
	}

	setproperty(VF_ANGLES, current_angles);
	setproperty(VF_ORIGIN, current_position);
}
