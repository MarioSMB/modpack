#include "radial_menu.qh"

#ifdef SVQC
NET_HANDLE(radial, bool)
{
	RadialMenu menu = ReadRegistered(RadialMenus);
	int index = ReadByte();

	if(menu && menu.m_select)
		menu.m_select(sender, index);
	
	return true;
}
#endif

#ifdef CSQC
bool autocvar_cl_quake_radialmenu = true;
float autocvar_cl_quake_radialmenu_size = 180;
float autocvar_cl_quake_radialmenu_deadzone = 70;
float autocvar_cl_quake_radialmenu_separator_width = 2;
const float M_PI_DOUBLE = 6.28318530718;

void radial_close();

int radial_hovered_index;
int radial_item_count;

vector radial_mousepos;

const float RADIAL_ICON_PADDING = 0.75;
const float RADIAL_ICON_HOVERED_SIZE = 1.25;
const float RADIAL_ICON_DEPTHSCALE = 0.45;

float radial_getslice(vector center)
{
	vector delta = radial_mousepos - center;
	delta.z = 0;
	if(vdist(delta, <, autocvar_cl_quake_radialmenu_deadzone))
		return -1;
	float ang = atan2(delta.y, delta.x);
	if(ang < 0)
		ang += M_PI_DOUBLE;
	return floor((ang / M_PI_DOUBLE) * radial_item_count);
}

void radial_drawslice(vector center, float r_start, float r_end, float startang, float endang, vector col, float alph)
{
	int segments = 24;
	float ang_step = (endang - startang) / segments;

	for(int j = 0; j < segments; ++j)
	{
		float a1 = startang + (j * ang_step);
		float a2 = startang + ((j + 1) * ang_step);

		float c1 = cos(a1);
		float s1 = sin(a1);
		float c2 = cos(a2);
		float s2 = sin(a2);

		vector p1_inner;
		p1_inner.x = center.x + (c1 * r_start);
		p1_inner.y = center.y + (s1 * r_start);
		p1_inner.z = 0;

		vector p1_outer;
		p1_outer.x = center.x + (c1 * r_end);
		p1_outer.y = center.y + (s1 * r_end);
		p1_outer.z = 0;

		vector p2_outer;
		p2_outer.x = center.x + (c2 * r_end);
		p2_outer.y = center.y + (s2 * r_end);
		p2_outer.z = 0;

		vector p2_inner;
		p2_inner.x = center.x + (c2 * r_start);
		p2_inner.y = center.y + (s2 * r_start);
		p2_inner.z = 0;

		R_BeginPolygon("", DRAWFLAG_NORMAL, true);
		R_PolygonVertex(p1_inner, '0 0 0', col, alph);
		R_PolygonVertex(p1_outer, '1 0 0', col, alph);
		R_PolygonVertex(p2_outer, '1 1 0', col, alph);
		R_PolygonVertex(p2_inner, '0 1 0', col, alph);
		R_EndPolygon();
	}
}

void radial_drawseparator(vector center, float r_start, float r_end, float ang, vector col, float alph, float width)
{
	float ca = cos(ang);
	float sa = sin(ang);

	float perpx = -sa;
	float perpy = ca;

	float half_w = width * 0.5;
	float offsetx = perpx * half_w;
	float offsety = perpy * half_w;

	float startx = center.x + (ca * r_start);
	float starty = center.y + (sa * r_start);

	float end_x = center.x + (ca * r_end);
	float end_y = center.y + (sa * r_end);

	vector p1;
	p1.x = startx - offsetx;
	p1.y = starty - offsety;
	p1.z = 0;

	vector p2;
	p2.x = end_x - offsetx;
	p2.y = end_y - offsety;
	p2.z = 0;

	vector p3;
	p3.x = end_x + offsetx;
	p3.y = end_y + offsety;
	p3.z = 0;

	vector p4;
	p4.x = startx + offsetx;
	p4.y = starty + offsety;
	p4.z = 0;

	// 6. Draw via the DarkPlaces 2D pixel space layout pipeline
	R_BeginPolygon("", DRAWFLAG_NORMAL, true);
	R_PolygonVertex(p1, '0 0 0', col, alph);
	R_PolygonVertex(p2, '1 0 0', col, alph);
	R_PolygonVertex(p3, '1 1 0', col, alph);
	R_PolygonVertex(p4, '0 1 0', col, alph);
	R_EndPolygon();
}


bool radial_allowed()
{
	if(!autocvar_cl_quake_radialmenu || STAT(CANNON)
		|| (player_localnum + 1) != player_localentnum || (STAT(ITEMS) & IT_TANK))
		return false;
	return true;
}

void cl_radial_draw()
{
	if(!radial_menu)
		return;

	bool isactive = (radial_menu.m_condition && radial_menu.m_condition(radial_menu));

	if(!radial_allowed() || !isactive)
	{
		if(radial_menu)
			radial_close();
		return;
	}

	vector center = '0.5 0 0' * vid_conwidth + '0 0.5 0' * vid_conheight;
	radial_hovered_index = radial_getslice(center);
	float rad = autocvar_cl_quake_radialmenu_size; // TODO: scaled

	for(int j = 0; j < radial_item_count; ++j)
	{
		float startang = (j / radial_item_count) * M_PI_DOUBLE;
		float endang = ((j + 1) / radial_item_count) * M_PI_DOUBLE;
		float angle_span = endang - startang;

		bool is_selected = (j == radial_hovered_index);
		vector slice_color = (is_selected) ? '0.2 0.5 1' : '0.1 0.1 0.1';
		float slice_alpha = (is_selected) ? 0.75 : 0.4;
		float deadzone = autocvar_cl_quake_radialmenu_deadzone;

		radial_drawslice(center, deadzone + 2, rad, startang, endang, slice_color, slice_alpha);

		if(autocvar_cl_quake_radialmenu_separator_width > 0)
			radial_drawseparator(center, deadzone + 2, rad, endang, '0.1 0.1 0.1', 0.6, autocvar_cl_quake_radialmenu_separator_width);

		float slice_depth = rad - deadzone;
		float placement_rad = deadzone + (slice_depth * 0.5);
		float max_slice_width = (placement_rad * angle_span) * RADIAL_ICON_PADDING;
		float max_slice_height = slice_depth * 0.85;

		float targ_size = slice_depth * RADIAL_ICON_DEPTHSCALE;
		if(targ_size > max_slice_width)
			targ_size = max_slice_width;
		if(targ_size > max_slice_height)
			targ_size = max_slice_height;

		if(is_selected)
		{
			targ_size *= RADIAL_ICON_HOVERED_SIZE;
			if(targ_size > (placement_rad * angle_span))
				targ_size = placement_rad * angle_span;
		}

		vector icon_size = '0 0 0';
		icon_size.x = targ_size;
		icon_size.y = targ_size;

		float textang = startang + ((endang - startang) * 0.5);
		vector picpos = '0 0 0';
		picpos.x = center.x + (cos(textang) * placement_rad);
		picpos.y = center.y + (sin(textang) * placement_rad);

		picpos.x -= (icon_size.x * 0.5);
		picpos.y -= (icon_size.y * 0.5);

		//vector text_color = '1 1 1';
		//string icon = string_null;
		if(radial_menu.m_drawentry)
			radial_menu.m_drawentry(j, picpos, icon_size);
		//if(icon)
			//drawpic_aspect(picpos, icon, icon_size, text_color, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
		//drawstring(textpos, radial_text(j), '12 12 0', text_color, 1, 0);
	}

	//vector hub_color = (radial_hovered_index == -1) ? '0.2 0.2 0.2' : '0.08 0.08 0.08';
	//radial_drawslice(center, 0, deadzone, 0, M_PI_DOUBLE, hub_color, 0.9);
}

void radial_open(RadialMenu menu)
{
	// put mouse in the center of our pretty pie
	radial_mousepos = '0.5 0 0' * autocvar_vid_conwidth + '0 0.5 0' * autocvar_vid_conheight;

	radial_hovered_index = -1;
	radial_item_count = menu.count;
	radial_menu = menu;
	//cursor_active |= GUI_OPEN_RADIAL;
	//setcursormode(cursor_active);
}

void radial_close()
{
	radial_hovered_index = -1;
	radial_item_count = 0;
	radial_menu = NULL;
	//cursor_active &= ~GUI_OPEN_RADIAL;
	//setcursormode(cursor_active);
}

void radial_send()
{
	int channel = MSG_C2S;
	WriteHeader(channel, radial);
	WriteRegistered(RadialMenus, channel, radial_menu);
	WriteByte(channel, radial_hovered_index);
}

void radial_select()
{
	// may happen if we're over the deadzone, don't change selection!
	if(radial_hovered_index == -1)
	{
		radial_close();
		return;
	}

	radial_send();

	radial_close();
}

void cl_radial_mouse()
{
	if(!radial_menu)
		return;

	radial_mousepos += getmousepos() * autocvar_menu_mouse_speed;
	radial_mousepos.x = bound(0, radial_mousepos.x, vid_conwidth);
	radial_mousepos.y = bound(0, radial_mousepos.y, vid_conheight);

	float cursor_alpha = 1 - autocvar__menu_alpha;
	draw_cursor_normal(radial_mousepos, '1 1 1', cursor_alpha);
}

bool cl_radial_input_event(float bInputType, float nPrimary, float nSecondary)
{
	if(!radial_allowed())
		return false;

	if(radial_menu && bInputType == 3)
	{
		mousepos.x = nPrimary;
		mousepos.y = nSecondary;
		return true;
	}

	if(bInputType == 2)
		return false;

	// at this point bInputType can only be 0 or 1 (key pressed or released)
	bool key_pressed = (bInputType == 0);

	bool is_key = false;
	string atk_keys = findkeysforcommand("+fire2", 0);
	int keys = tokenize(atk_keys);
	for(int j = 0; j < keys; ++j)
	{
		if(nPrimary == stof(argv(j)))
		{
			is_key = true;
			break;
		}
	}

	if(is_key || (atk_keys == "" && nPrimary == K_MOUSE2))
	{
		// released while menu is open
		if(!key_pressed && radial_menu)
		{
			radial_select();
			return true;
		}
		// pressed while menu is closed
		if(key_pressed && !radial_menu)
		{
			RadialMenu desired = NULL;
			FOREACH(RadialMenus, it.m_condition && it.count > 0,
			{
				if(it.m_condition(it))
				{
					desired = it;
					break;
				}
			});

			if(desired)
			{
				radial_open(desired);
				return true;
			}
		}

		if(key_pressed && radial_menu)
			return true; // force handling?
	}

#if 0
	if(radial_menu && key_pressed && nPrimary >= '0' && nPrimary <= '9')
	{
		int index = stoi(chr2str(nPrimary));
		if(index == 0)
			index = 10;
		index -= 1; // zero indexed
		if(index < radial_menu.count)
		{
			radial_hovered_index = index;
			radial_select();
			return true;
		}
	}
#endif

	return false;
}
#endif
