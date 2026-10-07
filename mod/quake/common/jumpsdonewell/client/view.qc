#include "view.qh"

#include "sbar.qh"

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

void Draw_Circle_full(vector shotorg, float crange, vector sw_color, float a);
void draw_blob()
{
	entity this = csqcplayer;
	if(!this || intermission || IS_DEAD(this))
		return;

	tracebox(this.origin, this.mins, this.maxs, this.origin - '0 0 4096', MOVE_NOMONSTERS, this);
	float shadowdist = vlen(this.origin - trace_endpos);
	float shadowval = bound(0, (400 - shadowdist) * 0.001, 0.5);
	float myscale = (this.scale) ? this.scale : 1;
	Draw_Circle_full(trace_endpos + '0 0 1', 16 * myscale, '0.01 0.01 0.01', shadowval);
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
	if(IS_DEAD(this) || time < STAT(NO_CONTROL_TIME) || intermission)
		return;

	if(vdist(vec2(this.velocity), >, 0))
	{
		vector wanted_angles = vectoangles(vec2(this.velocity));
		float framescale = ((IS_ONGROUND(this)) ? 1200 : 500);

		player_model_angles.y = turn_angle(player_model_angles_y, wanted_angles_y, frametime * framescale);
	}

	this.angles.y = player_model_angles.y;
}

void JDW_SetCamera()
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

float playery;
void View_JumpsDoneWell()
{
	vector oldvangle = getpropertyvec(VF_CL_VIEWANGLES);
	//vector oldangle = getpropertyvec(VF_ANGLES);

	vector moveval = input_movevalues;
	moveval.y *= -1;
	vector real_angles = vec3(0, playery, 0);
	if(vdist(moveval, >, 0))
		real_angles = vectoangles(moveval);
	playery = real_angles.y;
	setproperty(VF_CL_VIEWANGLES, vec3(0, real_angles.y, 0)); // do this early to ensure nothing else attempts to use it

	if(getworldbasename() == "map2")
		view_angles = '15 0 0';
	MAKE_VECTORS(view_angles, view_forward, view_right, view_up);

	setproperty(VF_CL_VIEWANGLES, oldvangle);

	// jumps done well sets a custom view angle
	playerz = view_origin.z;
	playerx = view_origin.x;
	if(cameraz < playerz - 60)
		cameraz = playerz - 60;
	if(cameraz > playerz + 30)
		cameraz = playerz + 30;
	view_origin.z = cameraz;
	if(getworldbasename() == "map2")
		view_origin += '-600 0 150';
	else
	{
		view_origin -= view_forward * 600;
		view_origin += view_up * 150;
	}

	player_listen();
}

void JDW_DrawWorld()
{
	// can't do this pre-clearscene!
	// TODO: maybe the rest doesn't need to be done then either...
	draw_blob();
}

void HUD_JumpsDoneWell()
{
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
}
