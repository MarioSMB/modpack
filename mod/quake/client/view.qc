void HUD_CenterPrint ();

float drawtime;
float drawframetime;

int cs_project_is_b0rked;
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
	fov = GetViewLocationFOV(autocvar_fov);

	setproperty(VF_FOV, fov);
}

void Sbar_Draw();
void HUD_Crosshair(entity this);
void CSQC_UpdateView(entity this, float w, float h)
{
	vector vf_size, vf_min;

	++framecount;

	drawfontscale = '1 1 0';

	stats_get();

	vf_size = getpropertyvec(VF_SIZE);
	vf_min = getpropertyvec(VF_MIN);
	vid_width = vf_size.x;
	vid_height = vf_size.y;

	CSQCPlayer_SetCamera();

	ticrate = STAT(MOVEVARS_TICRATE) * STAT(MOVEVARS_TIMESCALE);

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

	addentities(MASK_NORMAL | MASK_ENGINE | MASK_ENGINEVIEWMODELS);
	renderscene();

	// now switch to 2D drawing mode by calling a 2D drawing function
	// then polygon drawing will draw as 2D stuff, and NOT get queued until the
	// next R_RenderScene call
	drawstring('0 0 0', "", '1 1 0', '1 1 1', 0, 0);

	HUD_Contents();

	Sbar_Draw();
	HUD_CenterPrint();
	HUD_Crosshair(this);

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
		vector forward, right, up;
		MAKE_VECTORS('0 0 0', forward, right, up);
		vector v1, v2;
		cvar_set("vid_conwidth", "800");
		cvar_set("vid_conheight", "600");
		v1 = cs_project(forward);
		cvar_set("vid_conwidth", "640");
		cvar_set("vid_conheight", "480");
		v2 = cs_project(forward);
		if(v1 == v2)
			cs_project_is_b0rked = 1;
		else
			cs_project_is_b0rked = -1;
		cvar_set("vid_conwidth", w0);
		cvar_set("vid_conheight", h0);
	}

	if(intermission && !completed_time)
		completed_time = time;

	Net_Flush();

	// let's reset the view back to normal for the end
	setproperty(VF_MIN, '0 0 0');
	setproperty(VF_SIZE, '1 0 0' * w + '0 1 0' * h);

	IL_ENDFRAME();
}
