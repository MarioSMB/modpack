#include "../common/sui_sys.qh"
#include "sbar.qh"

void HUD_CenterPrint ();

float drawframetime;

int vid_width, vid_height;
float vid_pixelheight;

float autocvar_vid_conwidth;
float autocvar_vid_conheight;
float autocvar_vid_pixelheight;

float contentavgalpha, liquidalpha_prev;
vector liquidcolor_prev;

// TODO: item pickup flashing? maybe not (seizure fest)
// requires some kind of stat
bool autocvar_hud_contents;
float autocvar_hud_contents_fadeintime = 0.02;
float autocvar_hud_contents_fadeouttime = 0.1;
float autocvar_hud_contents_lava_alpha = 0.7;
vector autocvar_hud_contents_lava_color = '0.8 0.1 0';
float autocvar_hud_contents_slime_alpha = 0.7;
vector autocvar_hud_contents_slime_color = '0 0.4 0.1';
float autocvar_hud_contents_water_alpha = 0.5;
vector autocvar_hud_contents_water_color = '0.4 0.3 0.3';

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

//float autocvar_fov;
void View_UpdateFov()
{
	vector fov;
	fov = GetViewLocationFOV(50);

	setproperty(VF_FOV, fov);
}

entity sky;
float FONT_USER = 8;
PRECACHE(sky_init)
{
	sky = new(sky);
	setmodel(sky, MDL_SKY);
	sky.scale = 1.25;
	sky.drawmask = MASK_NORMAL;

	drawfont = FONT_USER + 1; // TODO: belongs in a separate init function!
}

float turn_angle(float a, float b, float amount)
{
	a = anglemods(a);
	b = anglemods(b);
	float diff = b - a;
	
	if (fabs(diff) < amount)
	{
		return b;
	}
	
	if (diff < -180)
	{
		b += 360;	
	}
	else if (diff > 180)
	{
		b -= 360;
	}
	
	if (fabs(b - a) < amount)
	{
		return b;
	}
	if (a < b)
		return a + amount;
	else
		return a - amount;	
}

float angle_diff_signed(float a, float b)
{
	float diff = (a - b + 180) % 360 - 180;
	if(diff < -180)
		diff += 360;
	if(diff > 180)
		diff += 360;
	// if (fabs(diff) > 180) printf("diff %f, a %f, b %f\n", diff, a, b);
	return diff;
}

float angle_diff(float a, float b)
{
	return fabs((a - b + 180) % 360 - 180);
}

vector player_model_angles;
void CSQCPlayer_SmoothAngle(entity this)
{
	if(IS_DEAD(this) || IS_DASHING(this))
		return;

	if(vdist(vec2(this.velocity), >, 0))
	{
		vector wanted_angles = vectoangles(vec2(this.velocity));
		float framescale = ((IS_ONGROUND(this)) ? 1200 : 500);

		player_model_angles.y = turn_angle(player_model_angles_y, wanted_angles_y, frametime * framescale);
	}

	this.angles.y = player_model_angles.y;
}

void Custom_SetCamera()
{
	vector v0 = pmove_vel; // TRICK: pmove_vel is set by the engine when we get here. No need to network velocity
	float vh = PHYS_VIEWHEIGHT(NULL);
	entity e = csqcplayer;
	if (e)
	{
		if (servercommandframe == 0 || clientcommandframe == 0)
		{
			InterpolateOrigin_Do(e);
			e.view_ofs = '0 0 1' * vh;

			// get onground state from the server
			e.flags = BITSET(e.flags, FL_ONGROUND, pmove_onground);

			CSQCPlayer_SetMinsMaxs(e);

			// override it back just in case
			e.view_ofs = '0 0 1' * vh;

			// set velocity
			e.velocity = v0;
		}
		else
		{
			int flg = e.iflags; e.iflags &= ~(IFLAG_ORIGIN | IFLAG_ANGLES);
			InterpolateOrigin_Do(e);
			e.iflags = flg;

			if (csqcplayer_status == CSQCPLAYERSTATUS_FROMSERVER)
			{
				vector o = e.origin;
				csqcplayer_status = CSQCPLAYERSTATUS_PREDICTED;
				CSQCPlayer_PredictTo(e, servercommandframe + 1, false);
				CSQCPlayer_SetPredictionError(e.origin - o, e.velocity - v0, pmove_onground - IS_ONGROUND(e));
				e.origin = o;
				e.velocity = v0;

				// get onground state from the server
				e.flags = BITSET(e.flags, FL_ONGROUND, pmove_onground);

				CSQCPlayer_SavePrediction(e);
			}
			CSQCPlayer_PredictTo(e, clientcommandframe + 1, true);

			CSQCPlayer_SetMinsMaxs(e);

			//if (!IS_DEAD(e))
				//e.angles.y = input_angles.y;
			CSQCPlayer_SmoothAngle(e);
		}

		// relink
		setorigin(e, e.origin);
	}

	const entity view = CSQCModel_server2csqc(player_localentnum - 1);
	if (view)
	{
		if (view != csqcplayer)
		{
			InterpolateOrigin_Do(view);
			view.view_ofs = '0 0 1' * vh;
		}
		setproperty(VF_ORIGIN, view.origin);
		//setproperty(VF_ANGLES, view_angles);
	}
	CSQCPLAYER_HOOK_POSTCAMERASETUP();
}

float runcycle;
float jumpcycle;
float rollaccum;
float oldframe;

void suwako_listen()
{
	if(!csqcplayer)
		return;
	entity this = csqcplayer;
	float speed = vlen(vec2(this.velocity));
	if(this.frame != oldframe)
		jumpcycle = 0;
	this.frame2 = this.frame;
	oldframe = this.frame;
	//this.frame = 0;
	vector wanted_angles = this.angles;
	if (speed > 0)
	{
		float blendcontrol = min(1.0, speed / 120);
		this.lerpfrac = blendcontrol;
		wanted_angles = vectoangles(vec2(this.velocity.x, this.velocity.y));
	}
	
	tracebox(this.origin, this.mins, this.maxs, this.origin - '0 0 2', 0, this);
	bool onground = trace_fraction < 1;
	if(onground && this.frame2 == 1)
	{
		this.frame2time = runcycle;
		runcycle += frametime * (0.6 + speed * 0.0035);
		jumpcycle = 0.0;	
	}
	else
	{
		this.lerpfrac = 1;
		this.frame2time = jumpcycle;
		jumpcycle += frametime * 1;
	}
	
	if(this.frame2 == 7)
	{
		this.lerpfrac = 1;
		this.frame2time = jumpcycle;
		jumpcycle += frametime;
	}
	
	float oldyaw = player_model_angles.y;
	
	if(speed > 0)
	{
		if(onground)
			player_model_angles.y = turn_angle(player_model_angles_y, wanted_angles_y, frametime * 1200);
		else
			player_model_angles.y = turn_angle(player_model_angles_y, wanted_angles_y, frametime * 500);
	}
	
	float newyaw = player_model_angles.y;
	
	if(rollaccum > 0)
		rollaccum = max(rollaccum - 5 * frametime, 0);
	else if(rollaccum < 0)
		rollaccum = min(rollaccum + 5 * frametime, 0);

	float yawdiff = angle_diff_signed(oldyaw, newyaw);
	if(yawdiff != 0)
	{
		if(yawdiff > 0 && rollaccum < yawdiff)
			rollaccum = min(5, rollaccum + yawdiff * 0.15);
		if(yawdiff < 0 && rollaccum > yawdiff)
			rollaccum = max(-5, rollaccum + yawdiff * 0.15);
	}
	
	player_model_angles.z = rollaccum * (speed / 150);

	this.angles = player_model_angles;
	this.angles.x = 0;
}

bool autocvar__hud_showbinds_reload;
float playery;
void CSQC_UpdateView(entity this, float w, float h)
{
	++framecount;

	drawfontscale = '1 1 0';

	stats_get();

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

	cvar_settemp("chase_active", "1");
	vector oldvangle = getpropertyvec(VF_CL_VIEWANGLES);
	vector oldangle = getpropertyvec(VF_ANGLES);

	vector moveval = input_movevalues;
	moveval.y *= -1;
	vector real_angles = vec3(0, playery, 0);
	if(vdist(moveval, >, 0))
		real_angles = vectoangles(moveval);
	playery = real_angles.y;
	setproperty(VF_CL_VIEWANGLES, vec3(0, real_angles.y, 0)); // do this early to ensure nothing else attempts to use it

	ticrate = STAT(MOVEVARS_TICRATE) * STAT(MOVEVARS_TIMESCALE);

	Custom_SetCamera();

	// Render the Scene
	view_origin = getpropertyvec(VF_ORIGIN);
	view_angles = getpropertyvec(VF_ANGLES);
	MAKE_VECTORS(view_angles, view_forward, view_right, view_up);

	if(drawtime == 0)
		drawframetime = 0.01666667; // when we don't know fps yet, we assume 60fps
	else
		drawframetime = bound(0.000001, time - drawtime, 1);
	drawtime = time;

	// ALWAYS Clear Current Scene First
	setproperty(VF_CL_VIEWANGLES, oldvangle);
	setproperty(VF_ANGLES, oldangle);
	clearscene();

	view_origin -= view_forward * 600;
	view_origin += view_up * 150;

	float water_level = STAT(WATERLEVEL) - 6;
	if(STAT(WATERLEVEL) && view_origin.z < water_level)
		view_origin.z = water_level;

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

	suwako_listen();

	// Draw the Crosshair
	setproperty(VF_DRAWCROSSHAIR, 0);

	// Draw the Engine Status Bar (the default Quake HUD)
	setproperty(VF_DRAWENGINESBAR, 0);

	IL_EACH(g_drawables, it.draw, it.draw(it));
	addentities(MASK_NORMAL | MASK_ENGINE | MASK_ENGINEVIEWMODELS);
	renderscene();

	// Now the the scene has been rendered, begin with the 2D drawing functions

	draw_hud(w, h);

	sui_begin(w, h);

	cl_editor_draw();

	sui_end();

	HUD_CenterPrint();

	Net_Flush();

	// let's reset the view back to normal for the end
	setproperty(VF_MIN, '0 0 0');
	setproperty(VF_SIZE, '1 0 0' * w + '0 1 0' * h);

	IL_ENDFRAME();
}
