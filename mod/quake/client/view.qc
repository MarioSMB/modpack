float drawtime;
float drawframetime;

int cs_project_is_b0rked;

float autocvar_vid_conwidth;
float autocvar_vid_conheight;

float contentavgalpha, liquidalpha_prev;
vector liquidcolor_prev;

// TODO: item pickup flashing? maybe not (seizure fest)
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
	// improved polyblend
	if(autocvar_hud_contents)
	{
		float contentalpha_temp, incontent, liquidalpha, contentfadetime;
		vector liquidcolor;

		switch(pointcontents(getpropertyvec(VF_ORIGIN)))
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
			drawfill('0 0 0', vec2(autocvar_vid_conwidth, autocvar_vid_conheight), liquidcolor_prev, contentavgalpha * liquidalpha_prev, DRAWFLAG_NORMAL);
	}
}

bool autocvar_cl_enginesbar = false;

void Sbar_Draw();
void HUD_Crosshair(entity this);
void CSQC_UpdateView(entity this, float w, float h)
{
	++framecount;

	stats_get();

	CSQCPlayer_SetCamera();

	ticrate = STAT(MOVEVARS_TICRATE) * STAT(MOVEVARS_TIMESCALE);

	if(drawtime == 0)
		drawframetime = 0.01666667; // when we don't know fps yet, we assume 60fps
	else
		drawframetime = bound(0.000001, time - drawtime, 1);
	drawtime = time;

	// ALWAYS Clear Current Scene First
	clearscene();

	// Assign Standard Viewflags
	// Draw the World (and sky)
	setproperty(VF_DRAWWORLD, 1);

	// Draw the Crosshair
	setproperty(VF_DRAWCROSSHAIR, 0);

	// Draw the Engine Status Bar (the default Quake HUD)
	setproperty(VF_DRAWENGINESBAR, autocvar_cl_enginesbar);

	addentities(MASK_NORMAL | MASK_ENGINE | MASK_ENGINEVIEWMODELS);
	renderscene();

	// now switch to 2D drawing mode by calling a 2D drawing function
	// then polygon drawing will draw as 2D stuff, and NOT get queued until the
	// next R_RenderScene call
	drawstring('0 0 0', "", '1 1 0', '1 1 1', 0, 0);

	HUD_Contents();

	Sbar_Draw();
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

	if(intermission && !completed_time)
		completed_time = time;

	Net_Flush();

	IL_ENDFRAME();
}
