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

#if 0
entity sword;
void sword_predraw(entity this)
{
	if(!csqcplayer || STAT(SWORDPOWER) <= 0)
	{
		this.drawmask = 0;
		return; // no point drawing anything in this case
	}
	this.drawmask = MASK_NORMAL;
	vector handorg = gettaginfo(csqcplayer, gettagindex(csqcplayer, "hand.R"));
	setorigin(this, handorg);
	this.angles = vectoangles2(v_forward, v_up);
}
#endif

float cameraz;
PRECACHE(JumpsDoneWell_Init)
{
	cameraz = 900000;
#if 0
	sword = new(sword);
	setmodel(sword, MDL_SWORD_EQUIP);
	sword.drawmask = MASK_NORMAL;
	setpredraw(sword, sword_predraw);
#endif
}

void draw_blob()
{
	if(!csqcplayer)
		return;

	entity this = csqcplayer;
	tracebox(this.origin, this.mins, this.maxs, this.origin - '0 0 4096', MOVE_NOMONSTERS, this);
	float shadowdist = vlen(this.origin - trace_endpos);
	float shadowval = bound(0, (400 - shadowdist) * 0.001, 0.5);
	particles_alphamin = particles_alphamax = shadowval;
	boxparticles(particleeffectnum(EFFECT_BLOBSHADOW), this, trace_endpos, trace_endpos, '0 0 0', '0 0 0', 1, PARTICLES_USEALPHA);
}

float attack_time;
int attack_side;
float last_attack_frame;
void draw_slash(entity this)
{
	vector ofs = '0 0 40';
	float size = 50;
	float umax = (attack_side > 0) ? 0 : 1;
	float umin = (attack_side > 0) ? 1 : 0;
	float alph = (attack_time > 0.26) ? (0.35 - attack_time * 20) : (attack_time * 5);

	vector swing_angle = '0 0 0';
	swing_angle.y = attack_side * 35 + (-attack_side * (0.35 - attack_time) * 6) * 70;
	makevectors(this.angles + swing_angle);

	float side_factor = size * (attack_time - 0.1) * 11;
	float forward_factor = size * 1.5 * (3.0 - attack_time * 4);

	vector color = '0.3 0.5 1' * attack_time * 4;

	R_BeginPolygon("textures/slash", DRAWFLAG_NORMAL, false);
	R_PolygonVertex(this.origin + v_right * side_factor + ofs, vec2(umax, 1), color, alph);
	R_PolygonVertex(this.origin + v_right * side_factor + v_forward * forward_factor + ofs, vec2(umax, 0), color, alph);
	R_PolygonVertex(this.origin - v_right * side_factor + v_forward * forward_factor + ofs, vec2(umin, 0), color, alph);
	R_PolygonVertex(this.origin - v_right * side_factor + ofs, vec2(umin, 1), color, alph);
	R_EndPolygon();
}

void player_listen()
{
	if(!csqcplayer)
		return;

	entity this = csqcplayer;
	if(this.frame == 3 || this.frame == 4 || this.frame == 7)
	{
		if(this.frame != last_attack_frame)
		{
			attack_side = (this.frame == 3) ? -1 : 1;
			attack_time = 0.35;
			if(this.frame == 7)
				attack_time = 0.65;
		}

		last_attack_frame = this.frame;
		attack_time -= frametime;
		if(attack_time < 0)
			attack_time = 0;

		draw_slash(this);
	}
	else
		last_attack_frame = 0;
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

vector player_model_angles;
void CSQCPlayer_SmoothAngle(entity this)
{
	if(IS_DEAD(this) || time < STAT(NO_CONTROL_TIME))
		return;

	if(vdist(vec2(this.velocity), >, 0))
	{
		vector wanted_angles = vectoangles(vec2(this.velocity));
		float framescale = ((IS_ONGROUND(this)) ? 1200 : 500);

		player_model_angles.y = turn_angle(player_model_angles_y, wanted_angles_y, frametime * framescale);
	}

	this.angles.y = player_model_angles.y;
}

void JumpsDoneWell_SetCamera()
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

bool autocvar__hud_showbinds_reload;
void draw_hud();
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

	JumpsDoneWell_SetCamera();

	// Render the Scene
	view_origin = getpropertyvec(VF_ORIGIN);
	view_angles = getpropertyvec(VF_ANGLES);
	if(cvar_string("cl_worldbasename") == "map2")
		view_angles = '15 0 0';
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

	// jumps done well sets a custom view angle
	playerz = view_origin.z;
	playerx = view_origin.x;
	if(cameraz < playerz - 60)
		cameraz = playerz - 60;
	if(cameraz > playerz + 30)
		cameraz = playerz + 30;
	view_origin.z = cameraz;
	if(cvar_string("cl_worldbasename") == "map2")
		view_origin += '-600 0 150';
	else
	{
		view_origin -= view_forward * 600;
		view_origin += view_up * 150;
	}

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

	draw_blob();
	player_listen();

	// Draw the Crosshair
	setproperty(VF_DRAWCROSSHAIR, 0);

	// Draw the Engine Status Bar (the default Quake HUD)
	setproperty(VF_DRAWENGINESBAR, 0);

	IL_EACH(g_drawables, it.draw, it.draw(it));
	addentities(MASK_NORMAL | MASK_ENGINE | MASK_ENGINEVIEWMODELS);
	renderscene();

	// Now the the scene has been rendered, begin with the 2D drawing functions

	if(telefade_time > 0)
	{
		if(telefade_time > 0.5)
			drawfill('0 0 0', vec2(vid_conwidth, vid_conheight), '0 0 0', (1 - telefade_time) * 2, DRAWFLAG_NORMAL);
		else
			drawfill('0 0 0', vec2(vid_conwidth, vid_conheight), '0 0 0', telefade_time * 2, DRAWFLAG_NORMAL);
		telefade_time -= frametime;
	}

	if(revive_time > 0)
	{
		drawfill('0 0 0', vec2(vid_conwidth, vid_conheight), '1 1 1', revive_time, DRAWFLAG_NORMAL);
		revive_time -= frametime;
	}

	draw_hud();

	HUD_CenterPrint();

	Net_Flush();

	// let's reset the view back to normal for the end
	setproperty(VF_MIN, '0 0 0');
	setproperty(VF_SIZE, '1 0 0' * w + '0 1 0' * h);

	IL_ENDFRAME();
}
