#include "crosshair.qh"

#include "../common/viewloc.qh"

void draw_cursor(vector pos, vector ofs, string img, vector col, float a)
{
	ofs = eX * (ofs.x * SIZE_CURSOR.x) + eY * (ofs.y * SIZE_CURSOR.y);
	drawpic(pos - ofs, strcat(draw_currentSkin, img), SIZE_CURSOR, col, a, DRAWFLAG_NORMAL);
}

void draw_cursor_normal(vector pos, vector col, float a)
{
	draw_cursor(pos, OFFSET_CURSOR, "/cursor", col, a);
}

vector project_3d_to_2d(vector vec)
{
	vec = cs_project(vec);
	return vec;
}

vector crosshair_getcolor(entity this, float health_stat)
{
	static float rainbow_last_flicker;
	static vector rainbow_prev_color;
	vector wcross_color = '0 0 0';
	entity thiswep = viewmodels[0]; // TODO: unhardcode
	switch(autocvar_crosshair_color_special)
	{
		case 1: // crosshair_color_per_weapon
		{
			if(thiswep.activeweapon != WEP_Null)
			{
				Weapon wep = thiswep.activeweapon;
				wcross_color = wep.w_crosshair_color;
				break;
			}
			else { goto normalcolor; }
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

.entity tag_entity;
void HUD_Crosshair_ApplyPlayerAlpha(float new_alpha)
{
	csqcplayer.alpha = new_alpha;
	FOREACH_ENTITY_CLASS("ENT_CLIENT_MODEL", it.tag_entity == csqcplayer,
	{
		it.alpha = new_alpha;
	});
	FOREACH_ENTITY_CLASS("ENT_CLIENT_TANK", it.count,
	{
		it.alpha = new_alpha;
	});
}

void HUD_Crosshair(entity this)
{
	// reset player's alpha here upon death since forced scoreboard prevents running the crosshair_chase code
	if(autocvar_chase_active && autocvar_crosshair_chase && STAT(HEALTH) <= 0 && csqcplayer)
	{
		csqcplayer.alpha = csqcplayer.m_alpha;
		HUD_Crosshair_ApplyPlayerAlpha(csqcplayer.alpha);
	}

	if (autocvar_chase_active && autocvar_chase_front)
	{
		if (csqcplayer.alpha != csqcplayer.m_alpha)
			HUD_Crosshair_ApplyPlayerAlpha(csqcplayer.m_alpha);
		return;
	}

	if(!sb_showscores && !cursor_active && !intermission && !(STAT(HEALTH) <= 0) && (!csqcplayer.viewloc || (csqcplayer.viewloc.spawnflags & VIEWLOC_FREEAIM)))
	{
		if (!autocvar_crosshair_enabled) // main toggle for crosshair rendering
			return;

		int i, j;

		string wcross_style;
		float wcross_alpha, wcross_resolution;
		wcross_style = autocvar_crosshair;
		if (csqcplayer.viewloc && (csqcplayer.viewloc.spawnflags & VIEWLOC_FREEAIM) && autocvar_crosshair_2d != "")
			wcross_style = autocvar_crosshair_2d;
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

		static int crosshair_chase_state = 0;

		vector wcross_forward = view_forward;
		if(STAT(ITEMS) & IT_TANK)
		{
#if 1
			if(csqcplayer)
			{
				makevectors(csqcplayer.angles);
				wcross_forward = v_forward;
				wcross_forward.z = 0 - wcross_forward.z;
			}
			else if(wcross_forward.z < 0)
				wcross_forward.z *= 0.1;
#else
			if(wcross_forward.z < 0)
				wcross_forward.z *= 0.1;
#endif
		}

		// wcross_origin = '0.5 0 0' * vid_conwidth + '0 0.5 0' * vid_conheight;
		if(csqcplayer.viewloc && (csqcplayer.viewloc.spawnflags & VIEWLOC_FREEAIM))
			wcross_origin = viewloc_mousepos;
		else if(autocvar_chase_active && autocvar_crosshair_chase)
		{
			vector player_org = ((csqcplayer) ? csqcplayer.origin + csqcplayer.view_ofs : view_origin);
			float my_alpha = (!csqcplayer.m_alpha) ? 1 : csqcplayer.m_alpha;
			float chase_playeralpha = bound(0.001, autocvar_crosshair_chase_playeralpha, 1);
			if(csqcplayer && chase_playeralpha < 1 && my_alpha > chase_playeralpha)
			{
				crosshair_chase_state = 2;
				bool hit = false;
				if (pointinsidebox(view_origin, csqcplayer.absmin, csqcplayer.absmax))
					hit = true;
				else
				{
					traceline(view_origin, view_origin + 65535 * wcross_forward, MOVE_NORMAL, NULL);
					if(trace_ent == csqcplayer)
						hit = true;
				}
				float prev_alpha = csqcplayer.alpha;
				float new_alpha;
				if(hit)
					new_alpha = max(csqcplayer.alpha - frametime * 5, chase_playeralpha);
				else
					new_alpha = min(csqcplayer.alpha + frametime * 5, my_alpha);

				if (new_alpha != prev_alpha)
					HUD_Crosshair_ApplyPlayerAlpha(new_alpha);
			}
			traceline(player_org, player_org + 32768 * wcross_forward, MOVE_WORLDONLY, NULL);
			wcross_origin = vec2(project_3d_to_2d(trace_endpos));
		}
		else
			wcross_origin = vec2(project_3d_to_2d(view_origin + 32768 * wcross_forward));

		if (crosshair_chase_state == 2) // enabled (this frame)
			crosshair_chase_state = 1;
		else if (crosshair_chase_state == 1) // turned off in the previous frame
		{
			// reset player alpha only in this frame
			if (csqcplayer)
				HUD_Crosshair_ApplyPlayerAlpha(csqcplayer.m_alpha);
			crosshair_chase_state = 0; // turned off and alpha reset
		}
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

		if(autocvar_crosshair_per_weapon)
		{
			entity thiswep = viewmodels[0]; // TODO: unhardcode
			Weapon wep = thiswep.activeweapon;

			wcross_resolution *= wep.w_crosshair_size;
			wcross_name = wep.w_crosshair;
		}

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
