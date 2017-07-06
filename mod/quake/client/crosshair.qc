//const int SHOTTYPE_HITTEAM = 1;
//const int SHOTTYPE_HITOBSTRUCTION = 2;
//const int SHOTTYPE_HITWORLD = 3;
//const int SHOTTYPE_HITENEMY = 4;

bool autocvar_crosshair_enabled;
string autocvar_crosshair;
float autocvar_crosshair_size;
float autocvar_crosshair_alpha;
bool autocvar_crosshair_effect_scalefade;
float autocvar_crosshair_effect_time;
//int autocvar_chase_active;
//bool autocvar_crosshair_hittest_blur;
float autocvar__menu_alpha;
bool autocvar_crosshair_dot;
int autocvar_crosshair_dot_color_custom;
string autocvar_crosshair_dot_color;
float autocvar_crosshair_dot_size;
float autocvar_crosshair_dot_alpha;
//bool autocvar_crosshair_hittest;

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

vector project_3d_to_2d(vector vec)
{
	vec = cs_project(vec);
	if(cs_project_is_b0rked > 0)
	{
		vector vf_size = getpropertyvec(VF_SIZE);
		float vid_width = vf_size.x;
		float vid_height = vf_size.y;

		vec.x *= autocvar_vid_conwidth / vid_width;
		vec.y *= autocvar_vid_conheight / vid_height;
	}
	return vec;
}

int autocvar_crosshair_color_special;
float autocvar_crosshair_color_special_rainbow_brightness;
float autocvar_crosshair_color_special_rainbow_delay;
string autocvar_crosshair_color;

vector crosshair_getcolor(entity this, float health_stat)
{
	static float rainbow_last_flicker;
	static vector rainbow_prev_color;
	vector wcross_color = '0 0 0';
	switch(autocvar_crosshair_color_special)
	{
		case 1: // crosshair_color_per_weapon
		{
			goto normalcolor;
		}

		case 2: // crosshair_color_by_health
		{
			float x = health_stat;

			//x = red
			//y = green
			//z = blue

			wcross_color.z = 0;

			if(x > 200)
			{
				wcross_color.x = 0;
				wcross_color.y = 1;
			}
			else if(x > 150)
			{
				wcross_color.x = 0.4 - (x-150)*0.02 * 0.4;
				wcross_color.y = 0.9 + (x-150)*0.02 * 0.1;
			}
			else if(x > 100)
			{
				wcross_color.x = 1 - (x-100)*0.02 * 0.6;
				wcross_color.y = 1 - (x-100)*0.02 * 0.1;
				wcross_color.z = 1 - (x-100)*0.02;
			}
			else if(x > 50)
			{
				wcross_color.x = 1;
				wcross_color.y = 1;
				wcross_color.z = 0.2 + (x-50)*0.02 * 0.8;
			}
			else if(x > 20)
			{
				wcross_color.x = 1;
				wcross_color.y = (x-20)*90/27/100;
				wcross_color.z = (x-20)*90/27/100 * 0.2;
			}
			else
			{
				wcross_color.x = 1;
				wcross_color.y = 0;
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
LABEL(normalcolor)
		default: { wcross_color = stov(autocvar_crosshair_color); break; }
	}

	return wcross_color;
}

void HUD_Crosshair(entity this)
{
	if(!sb_showscores && !intermission)
	{
		if (!autocvar_crosshair_enabled) // main toggle for crosshair rendering
			return;

		int i, j;

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
		//int shottype;

		vector view_origin = getpropertyvec(VF_ORIGIN);
		vector view_angles = getpropertyvec(VF_ANGLES);
		makevectors(view_angles);
		vector view_forward = v_forward;

		// wcross_origin = '0.5 0 0' * vid_conwidth + '0 0.5 0' * vid_conheight;
		wcross_origin = vec2(project_3d_to_2d(view_origin + 32768 * view_forward));
		/*if(autocvar_crosshair_hittest)
		{
			vector wcross_oldorigin;
			wcross_oldorigin = wcross_origin;
			shottype = TrueAimCheck();
			if(shottype == SHOTTYPE_HITWORLD)
			{
				vector v = wcross_origin - wcross_oldorigin;
				v.x /= vid_conwidth;
				v.y /= vid_conheight;
				if(vdist(v, >, 0.01))
					shottype = SHOTTYPE_HITOBSTRUCTION;
			}
			if(!autocvar_crosshair_hittest_showimpact)
				wcross_origin = wcross_oldorigin;
		}
		else
			shottype = SHOTTYPE_HITWORLD;*/

		string wcross_name = "";
		float wcross_scale = 1, wcross_blur = 0;

		if(wcross_name == "")
			wcross_name = strcat("gfx/crosshair", wcross_style);

		// MAIN CROSSHAIR COLOR DECISION
		vector wcross_color = crosshair_getcolor(NULL, getstatf(STAT_HEALTH));

		if(autocvar_crosshair_effect_scalefade)
		{
			wcross_scale = wcross_resolution;
			wcross_resolution = 1;
		}

		/*if(shottype == SHOTTYPE_HITENEMY)
			wcross_scale *= autocvar_crosshair_hittest; // is not queried if hittest is 0
		if(shottype == SHOTTYPE_HITTEAM)
			wcross_scale /= autocvar_crosshair_hittest; // is not queried if hittest is 0*/

		float f = fabs(autocvar_crosshair_effect_time);
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

		/*if(shottype == SHOTTYPE_HITTEAM || (shottype == SHOTTYPE_HITOBSTRUCTION && autocvar_crosshair_hittest_blur && !autocvar_chase_active))
		{
			wcross_blur = 1;
			wcross_alpha *= 0.75;
		}*/

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
		vector wcross_size = draw_getimagesize(wcross_name) * wcross_scale;

		if(wcross_scale >= 0.001 && wcross_alpha >= 0.001)
		{
#define CROSSHAIR_DO_BLUR(M,sz,wcross_name,wcross_alpha) \
			MACRO_BEGIN { \
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
			} MACRO_END

#define CROSSHAIR_DRAW_SINGLE(i,j,sz,wcross_name,wcross_alpha) \
			drawpic(wcross_origin - ('0.5 0 0' * (sz * wcross_size.x + i * wcross_blur) + '0 0.5 0' * (sz * wcross_size.y + j * wcross_blur)), wcross_name, sz * wcross_size, wcross_color, wcross_alpha, DRAWFLAG_NORMAL)

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
				// FIXME why don't we use wcross_alpha here?
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
