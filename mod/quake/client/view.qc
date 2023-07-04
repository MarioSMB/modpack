#include "view.qh"

#include "../common/constants.qh"
#include <common/physics/movetypes/movetypes.qh>
#include "../common/sui_sys.qh"
#include "../common/status_effects/cl_status_effects.qh"
#include "../common/weapons/all.qh"
#include "../common/viewloc.qh"
#include "../common/wepent.qh"
#include "../common/util.qh"
#include "../server/triggers/trigger/viewloc.qh"

void CSQCModel_InterpolateAnimation_Do(entity this);

// shared across viewmodel effects and dynamic hud code
vector cl_followmodel_ofs;
float cl_followmodel_time;

float autocvar_cl_viewmodel_scale;
float autocvar_cl_viewmodel_alpha = 1;

bool autocvar_cl_bobmodel;
float autocvar_cl_bobmodel_speed;
float autocvar_cl_bobmodel_side;
float autocvar_cl_bobmodel_up;

float autocvar_cl_followmodel;
float autocvar_cl_followmodel_speed = 0.3;
float autocvar_cl_followmodel_limit = 135;
float autocvar_cl_followmodel_velocity_lowpass = 0.05;
float autocvar_cl_followmodel_highpass = 0.05;
float autocvar_cl_followmodel_lowpass = 0.03;
bool autocvar_cl_followmodel_velocity_absolute;

float autocvar_cl_leanmodel;
float autocvar_cl_leanmodel_speed = 0.3;
float autocvar_cl_leanmodel_limit = 30;
float autocvar_cl_leanmodel_highpass1 = 0.2;
float autocvar_cl_leanmodel_highpass = 0.2;
float autocvar_cl_leanmodel_lowpass = 0.05;

#define avg_factor(avg_time) (1 - exp(-frametime / max(0.001, avg_time)))

#define lowpass(value, frac, ref_store, ret) \
	ret = ref_store = ref_store * (1 - frac) + (value) * frac;

#define lowpass_limited(value, frac, limit, ref_store, ret) MACRO_BEGIN \
	float __ignore; lowpass(value, frac, ref_store, __ignore); \
	ret = ref_store = bound((value) - (limit), ref_store, (value) + (limit)); \
MACRO_END

#define highpass(value, frac, ref_store, ret) MACRO_BEGIN \
	float __f = 0; lowpass(value, frac, ref_store, __f); \
	ret = (value) - __f; \
MACRO_END

#define highpass_limited(value, frac, limit, ref_store, ret) MACRO_BEGIN \
	float __f = 0; lowpass_limited(value, frac, limit, ref_store, __f); \
	ret = (value) - __f; \
MACRO_END

#define lowpass2(value, frac, ref_store, ref_out) MACRO_BEGIN \
	lowpass(value.x, frac, ref_store.x, ref_out.x); \
	lowpass(value.y, frac, ref_store.y, ref_out.y); \
MACRO_END

#define highpass2(value, frac, ref_store, ref_out) MACRO_BEGIN \
	highpass(value.x, frac, ref_store.x, ref_out.x); \
	highpass(value.y, frac, ref_store.y, ref_out.y); \
MACRO_END

#define highpass2_limited(value, frac, limit, ref_store, ref_out) MACRO_BEGIN \
	highpass_limited(value.x, frac, limit, ref_store.x, ref_out.x); \
	highpass_limited(value.y, frac, limit, ref_store.y, ref_out.y); \
MACRO_END

#define lowpass3(value, frac, ref_store, ref_out) MACRO_BEGIN \
	lowpass(value.x, frac, ref_store.x, ref_out.x); \
	lowpass(value.y, frac, ref_store.y, ref_out.y); \
	lowpass(value.z, frac, ref_store.z, ref_out.z); \
MACRO_END

#define highpass3(value, frac, ref_store, ref_out) MACRO_BEGIN \
	highpass(value.x, frac, ref_store.x, ref_out.x); \
	highpass(value.y, frac, ref_store.y, ref_out.y); \
	highpass(value.z, frac, ref_store.z, ref_out.z); \
MACRO_END

void calc_followmodel_ofs(entity view)
{
	if(cl_followmodel_time == time)
		return; // cl_followmodel_ofs already calculated for this frame

	float frac;
	vector gunorg = '0 0 0';
	static vector vel_average;
	static vector gunorg_adjustment_highpass;
	static vector gunorg_adjustment_lowpass;

	vector vel;
	if (autocvar_cl_followmodel_velocity_absolute)
		vel = view.velocity;
	else
	{
		vector forward, right, up;
		MAKE_VECTORS(view_angles, forward, right, up);
		vel.x = view.velocity * forward;
		vel.y = view.velocity * right * -1;
		vel.z = view.velocity * up;
	}

	vel.x = bound(vel_average.x - autocvar_cl_followmodel_limit, vel.x, vel_average.x + autocvar_cl_followmodel_limit);
	vel.y = bound(vel_average.y - autocvar_cl_followmodel_limit, vel.y, vel_average.y + autocvar_cl_followmodel_limit);
	vel.z = bound(vel_average.z - autocvar_cl_followmodel_limit, vel.z, vel_average.z + autocvar_cl_followmodel_limit);

	frac = avg_factor(autocvar_cl_followmodel_velocity_lowpass);
	lowpass3(vel, frac, vel_average, gunorg);

	gunorg *= -autocvar_cl_followmodel_speed * 0.042;

	// perform highpass/lowpass on the adjustment vectors (turning velocity into acceleration!)
	// trick: we must do the lowpass LAST, so the lowpass vector IS the final vector!
	frac = avg_factor(autocvar_cl_followmodel_highpass);
	highpass3(gunorg, frac, gunorg_adjustment_highpass, gunorg);
	frac = avg_factor(autocvar_cl_followmodel_lowpass);
	lowpass3(gunorg, frac, gunorg_adjustment_lowpass, gunorg);

	if (autocvar_cl_followmodel_velocity_absolute)
	{
		vector fixed_gunorg;
		vector forward, right, up;
		MAKE_VECTORS(view_angles, forward, right, up);
		fixed_gunorg.x = gunorg * forward;
		fixed_gunorg.y = gunorg * right * -1;
		fixed_gunorg.z = gunorg * up;
		gunorg = fixed_gunorg;
	}

	cl_followmodel_ofs = gunorg;
	cl_followmodel_time = time;
}

vector leanmodel_ofs(entity view)
{
	float frac;
	vector gunangles = '0 0 0';
	static vector gunangles_prev = '0 0 0';
	static vector gunangles_highpass = '0 0 0';
	static vector gunangles_adjustment_highpass;
	static vector gunangles_adjustment_lowpass;

	if (view.csqcmodel_teleported)
		gunangles_prev = view_angles;

	// in the highpass, we _store_ the DIFFERENCE to the actual view angles...
	gunangles_highpass += gunangles_prev;
	PITCH(gunangles_highpass) += 360 * floor((PITCH(view_angles) - PITCH(gunangles_highpass)) / 360 + 0.5);
	YAW(gunangles_highpass) += 360 * floor((YAW(view_angles) - YAW(gunangles_highpass)) / 360 + 0.5);
	ROLL(gunangles_highpass) += 360 * floor((ROLL(view_angles) - ROLL(gunangles_highpass)) / 360 + 0.5);
	frac = avg_factor(autocvar_cl_leanmodel_highpass1);
	highpass2_limited(view_angles, frac, autocvar_cl_leanmodel_limit, gunangles_highpass, gunangles);
	gunangles_prev = view_angles;
	gunangles_highpass -= gunangles_prev;

	PITCH(gunangles) *= -autocvar_cl_leanmodel_speed;
	YAW(gunangles) *= -autocvar_cl_leanmodel_speed;

	// we assume here: PITCH = 0, YAW = 1, ROLL = 2
	frac = avg_factor(autocvar_cl_leanmodel_highpass);
	highpass2(gunangles, frac, gunangles_adjustment_highpass, gunangles);
	frac = avg_factor(autocvar_cl_leanmodel_lowpass);
	lowpass2(gunangles, frac, gunangles_adjustment_lowpass, gunangles);

	gunangles.x = -gunangles.x; // pitch was inverted, now that actually matters

	return gunangles;
}

vector bobmodel_ofs(entity view)
{
	bool clonground = IS_ONGROUND(view);
	static bool oldonground;
	static float hitgroundtime;
	if (clonground)
	{
		float f = time; // cl.movecmd[0].time
		if (!oldonground)
			hitgroundtime = f;
	}
	oldonground = clonground;

	// calculate for swinging gun model
	// the gun bobs when running on the ground, but doesn't bob when you're in the air.
	vector gunorg = '0 0 0';
	static float bobmodel_scale = 0;
	static float time_ofs = 0; // makes the effect always restart in the same way
	if (clonground)
	{
		if (time - hitgroundtime > 0.05)
			bobmodel_scale = min(1, bobmodel_scale + frametime * 5);
	}
	else
		bobmodel_scale = max(0, bobmodel_scale - frametime * 5);

	float xyspeed = bound(0, vlen(vec2(view.velocity)), 400);
	if (bobmodel_scale && xyspeed)
	{
		float bspeed = xyspeed * 0.01 * autocvar_cl_viewmodel_scale * bobmodel_scale;
		float s = (time - time_ofs) * autocvar_cl_bobmodel_speed;
		gunorg.y = bspeed * autocvar_cl_bobmodel_side * sin(s);
		gunorg.z = bspeed * autocvar_cl_bobmodel_up * cos(s * 2);
	}
	else
		time_ofs = time;

	return gunorg;
}

void viewmodel_animate(entity this)
{
	if (autocvar_chase_active || STAT(HEALTH) <= 0 || STAT(SKATING)) return;

	entity view = CSQCModel_server2csqc(player_localentnum - 1);

	if (autocvar_cl_followmodel)
	{
		calc_followmodel_ofs(view);
		this.origin += cl_followmodel_ofs;
	}

	if (autocvar_cl_leanmodel)
		this.angles += leanmodel_ofs(view);

	// vertical view bobbing code
	// TODO: cl_bob

	// horizontal view bobbing code
	// TODO: cl_bob2

	// fall bobbing code
	// causes the view to swing down and back up when touching the ground
	// TODO: cl_bobfall

	// gun model bobbing code
	if (autocvar_cl_bobmodel)
		this.origin += bobmodel_ofs(view);
}

.string name_last;

void viewmodel_draw(entity this)
{
	CSQCModel_InterpolateAnimation_Do(this);

	int mask = (intermission || (STAT(HEALTH) <= 0) || autocvar_chase_active || STAT(SKATING)) ? 0 : MASK_NORMAL;
	float a = ((autocvar_cl_viewmodel_alpha) ? bound(-1, autocvar_cl_viewmodel_alpha, this.m_alpha) : this.m_alpha);
	int wepskin = this.m_skin;
	Weapon wep = this.activeweapon;
	entity me = CSQCModel_server2csqc(player_localentnum - 1);
	int fx = ((me.csqcmodel_effects & EFMASK_CHEAP)
		| EF_NODEPTHTEST)
		&~ (EF_FULLBRIGHT); // can mask team color, so get rid of it
	bool swapskin = this.skin != wepskin;
	this.drawmask = mask;
	this.alpha = a;
	this.skin = wepskin;
	this.csqcmodel_effects = fx;
	CSQCModel_Effects_Apply(this);
	if(a >= 0)
	{
		string name = wep.mdl;
		string newname = wep.wr_viewmodel(wep, this);
		if(newname)
			name = newname;
		bool swap = name != this.name_last;
		if (swap || swapskin)
		{
			CSQCModel_InterpolateAnimation_1To2_PreNote(this, BIT(23));
			CSQCModel_InterpolateAnimation_1To2_Note(this, BIT(23), true);
			this.lerpfrac = 0; // reset frames
		}

		{
			this.name_last = name;
			CL_WeaponEntity_SetModel(this, name);
			this.origin += autocvar_cl_gunoffset;
		}
	}
	float f = 0; // 0..1; 0: fully active
	this.angles_x = (-90 * f * f);
	viewmodel_animate(this);
	setorigin(this, this.origin);
}

STATIC_INIT(viewmodel) {
    viewmodels = new(viewmodel);

    // forces lerping to work at 10 fps, needed for smooth weapon animations
    cvar_settemp("cl_lerpanim_maxdelta_framegroups", "0.1");
    // random fix for collision issues
    cvar_settemp("mod_q1bsp_polygoncollisions", "0");
}

// visual overlay while in liquids
void HUD_Contents()
{
	if(!autocvar_hud_contents)
		return;

	// improved polyblend
	float contentalpha_temp, incontent, liquidalpha, contentfadetime;
	vector liquidcolor;

	switch(pointcontents(view_origin))
	{
		case CONTENT_WATER:
			liquidalpha = autocvar_hud_contents_water_alpha;
			liquidcolor = autocvar_hud_contents_water_color;
			incontent = 1;
			break;

		case CONTENT_LAVA:
			liquidalpha = autocvar_hud_contents_lava_alpha;
			liquidcolor = autocvar_hud_contents_lava_color;
			incontent = 1;
			break;

		case CONTENT_SLIME:
			liquidalpha = autocvar_hud_contents_slime_alpha;
			liquidcolor = autocvar_hud_contents_slime_color;
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
		drawfill('0 0 0', vec2(vid_conwidth, vid_conheight), liquidcolor_prev, contentavgalpha * liquidalpha_prev, DRAWFLAG_NORMAL);
}

vector GetViewLocationFOV(float fov)
{
	float frustumy = tan(fov * M_PI / 360.0) * 0.75;
	float frustumx = frustumy * vid_width / vid_height / vid_pixelheight;
	float fovx = atan2(frustumx, 1) / M_PI * 360.0;
	float fovy = atan2(frustumy, 1) / M_PI * 360.0;
	return '1 0 0' * fovx + '0 1 0' * fovy;
}

float autocvar_fov;
void View_UpdateFov()
{
	vector fov;
	if(csqcplayer && csqcplayer.viewloc)
		fov = GetViewLocationFOV(110); // enforce 110 fov, so things don't look odd
	else
		fov = GetViewLocationFOV(autocvar_fov);

	setproperty(VF_FOV, fov);
}

void draw_drawMousePointer(vector where)
{
	string cursor = strcat("gfx/menu/", cvar_string("menu_skin"), "/cursor");
	drawpic(where - '0.25 0.125 0', cursor, '32 32 0', '1 1 1', 1, 0);
}

float eventchase_current_distance;
float eventchase_running;
int WantEventchase(entity this, bool want_vehiclechase)
{
	if(STAT(SKATING))
		return 1;
	if(this.viewloc)
		return 1;
	return 0;
}

void View_EventChase(entity this)
{
	// event chase camera
	if(autocvar_chase_active <= 0) // greater than 0 means it's enabled manually, and this code is skipped
	{
		if(autocvar_chase_active == -2)
			cvar_set("chase_active", "0");

		int eventchase = WantEventchase(this, false);
		if (eventchase)
		{
			eventchase_running = true;

			// make special vector since we can't use view_origin (It is one frame old as of this code, it gets set later with the results this code makes.)
			vector current_view_origin = (csqcplayer ? csqcplayer.origin : pmove_org);

			// detect maximum viewoffset and use it
			vector view_offset = '0 0 24';

			if(view_offset)
			{
				traceline(current_view_origin, current_view_origin + view_offset + ('0 0 1' * autocvar_cl_eventchase_maxs.z), MOVE_WORLDONLY, this);
				if(trace_fraction == 1) { current_view_origin += view_offset; }
				else { current_view_origin.z += max(0, (trace_endpos.z - current_view_origin.z) - autocvar_cl_eventchase_maxs.z); }
			}

			// We must enable chase_active to get a third person view (weapon viewmodel hidden and own player model showing).
			// Ideally, there should be another way to enable third person cameras, such as through setproperty()
			// -1 enables chase_active while marking it as set by this code, and not by the user (which would be 1)
			if(!autocvar_chase_active) { cvar_set("chase_active", "-1"); }

			// make the camera smooth back
			float chase_distance = 100;

			if(autocvar_cl_eventchase_speed && eventchase_current_distance < chase_distance)
				eventchase_current_distance += autocvar_cl_eventchase_speed * (chase_distance - eventchase_current_distance) * frametime; // slow down the further we get
			else if(eventchase_current_distance != chase_distance)
				eventchase_current_distance = chase_distance;

			vector forward, right, up;
			MAKE_VECTORS(view_angles, forward, right, up);

			vector eventchase_target_origin = (current_view_origin - (forward * eventchase_current_distance));
			tracebox(current_view_origin, autocvar_cl_eventchase_mins, autocvar_cl_eventchase_maxs, eventchase_target_origin, MOVE_WORLDONLY, this);

			// If the boxtrace fails, revert back to line tracing.
			if(!this.viewloc)
			if(trace_startsolid)
			{
				eventchase_target_origin = (current_view_origin - (forward * eventchase_current_distance));
				traceline(current_view_origin, eventchase_target_origin, MOVE_WORLDONLY, this);
				setproperty(VF_ORIGIN, (trace_endpos - (forward * autocvar_cl_eventchase_mins.z)));
			}
			else { setproperty(VF_ORIGIN, trace_endpos); }

			if(!this.viewloc)
				setproperty(VF_ANGLES, view_angles);
		}

		if (eventchase <= 0 && autocvar_chase_active < 0) // time to disable chase_active if it was set by this code
		{
			eventchase_running = false;
			cvar_set("chase_active", "0");
			eventchase_current_distance = 0; // start from 0 next time
		}
	}
}

void ViewLocation_Mouse()
{
	viewloc_mousepos += getmousepos() * autocvar_menu_mouse_speed;
	viewloc_mousepos.x = bound(0, viewloc_mousepos.x, vid_conwidth);
	viewloc_mousepos.y = bound(0, viewloc_mousepos.y, vid_conheight);

	//float cursor_alpha = 1 - autocvar__menu_alpha;
	//cursor_type = CURSOR_NORMAL;
	//draw_cursor(viewloc_mousepos, '0.5 0.5 0', "/cursor_move", '1 1 1', cursor_alpha);
}

void HUD_Mouse(entity player)
{
	if(autocvar__menu_alpha == 1)
		return;

	if(!cursor_active)
	{
		if(player.viewloc && (player.viewloc.spawnflags & VIEWLOC_FREEAIM))
			ViewLocation_Mouse(); // NOTE: doesn't use cursormode
	}
}

bool autocvar__hud_showbinds_reload;
void Sbar_Draw();
void HUD_Crosshair(entity this);
void CSQC_UpdateView(entity this, float w, float h)
{
	++framecount;

	drawfontscale = '1 1 0';

	stats_get();

	ReplicateVars(REPLICATEVARS_CHECK);

	if(autocvar__hud_showbinds_reload) // menu can set this one
	{
		// Xonotic expects this to be 0 and reloads the keybind database
		// simply switch it off again to avoid an unnecessary reload upon joining a Xonotic server
		cvar_set("_hud_showbinds_reload", "0");
	}

	vector vf_size = getpropertyvec(VF_SIZE);
	vector vf_min = getpropertyvec(VF_MIN);
	vid_width = vf_size.x;
	vid_height = vf_size.y;

	ticrate = STAT(MOVEVARS_TICRATE) * STAT(MOVEVARS_TIMESCALE);

	CSQCPlayer_SetCamera();

	entity local_player = ((csqcplayer) ? csqcplayer : CSQCModel_server2csqc(player_localentnum - 1));
	if(!local_player)
		local_player = this; // fall back!

	View_EventChase(local_player);

	// viewmodel_draw needs to use the view_angles set by the engine on every CSQC_UpdateView call
	if(autocvar_r_drawviewmodel)
		viewmodel_draw(viewmodels);

	// Render the Scene
	view_origin = getpropertyvec(VF_ORIGIN);
	view_angles = getpropertyvec(VF_ANGLES);
	MAKE_VECTORS(view_angles, view_forward, view_right, view_up);

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

	if(intermission && !intermission_time)
		intermission_time = time;

	// ALWAYS Clear Current Scene First
	clearscene();

	setproperty(VF_ORIGIN, view_origin);
	setproperty(VF_ANGLES, view_angles);

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

	View_UpdateFov();

	// Draw the Crosshair
	setproperty(VF_DRAWCROSSHAIR, 0);

	// Draw the Engine Status Bar (the default Quake HUD)
	setproperty(VF_DRAWENGINESBAR, 0);

	IL_EACH(g_drawables, it.draw, it.draw(it));

	addentities(MASK_NORMAL | MASK_ENGINE | MASK_ENGINEVIEWMODELS);
	renderscene();

	// Now the the scene has been rendered, begin with the 2D drawing functions

	HUD_Contents();

	Sbar_Draw();
	HUD_CenterPrint();
	HUD_Crosshair(this);

	status_effects_HUD_Powerups_add();

	sui_begin(vid_conwidth, vid_conheight);

	cl_shop_draw();

	sui_end();

	if(cursor_active && !intermission)
		draw_drawMousePointer(_cursor_position);

	HUD_Mouse(local_player);

	if(intermission && !completed_time)
		completed_time = time;

	Net_Flush();

	// let's reset the view back to normal for the end
	setproperty(VF_MIN, '0 0 0');
	setproperty(VF_SIZE, '1 0 0' * w + '0 1 0' * h);

	IL_ENDFRAME();
}
