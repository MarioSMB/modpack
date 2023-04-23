#include "../common/sui_sys.qh"

#include "menu.qh"

// required engine functions

bool menu_active;
vector screensize;

float splash_time;

float time;
float frametime;
float menuPrevTime;
vector menuMousePos;

void draw_drawMousePointer(vector where)
{
	string cursor = strcat("gfx/menu/", cvar_string("menu_skin"), "/cursor");
	drawpic(where - '0.25 0.125 0', cursor, '32 32 0', '1 1 1', 1, 0);
}

vector randomofs()
{
	return vec2(random() - 0.5, random() - 0.5) * 2;
}

void m_open();
void m_init()
{
	if(!cvar("_menu_initialized"))
		splash_time = time + 2.5;
	else
		m_open();
	current_menu = MENU_MAIN;
	//setcursormode(true);
	cvar_set("_menu_initialized", "1");
	drawfont = FONT_USER + 1;
}

void m_shutdown() { }

void m_draw(int width, int height)
{
	screensize.x = cvar("vid_conwidth");
	screensize.y = cvar("vid_conheight");
	screensize.z = 0;
	float t = gettime();
	frametime = min(0.2, t - menuPrevTime);
	menuPrevTime = t;
	time += frametime;

	sui_begin(screensize.x, screensize.y);
	if(menu_active)
		root_menu(screensize);

	vector rawMousePos = getmousepos();
	vector newMouse = rawMousePos; //globalToBox(rawMousePos, draw_shift, draw_scale);
	if (rawMousePos != '0 0 0' && newMouse != menuMousePos)
	{
		menuMousePos = newMouse;
		sui_input_event(IE_MOUSEABS, menuMousePos.x, menuMousePos.y, 0);
	}

	if(time < splash_time)
	{
		sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_CENTER));
		float diff = splash_time - time;
		float a;
		if(diff > 2.5)
		{
			a = 1 - (diff - 2.5) * 2;
			float xstretch = (diff - 2.5) * 4;
			sui_fill('0 0 0', screensize, '0 0 0', 1, 0);
			sui_pic(randomofs() * 1, vec2(screensize.y * (0.7 + xstretch), screensize.y * 0.7), "gfx/splash.tga", '1 1 1', a * 0.75, 1);
			sui_pic(randomofs() * 1, vec2(screensize.y * (0.7 + xstretch), screensize.y * 0.7), "gfx/splash.tga", '1 1 1', a * 0.75, 1);
		}
		else 
		{
			a = diff * 0.6;
			sui_fill('0 0 0', screensize, '0 0 0', a * 2, 0);
			sui_pic(randomofs() * a, vec2(screensize.y * 0.7, screensize.y * 0.7), "gfx/splash.tga", '1 1 1', a, 1);
			sui_pic(randomofs() * a, vec2(screensize.y * (0.7 + random() * 0.05), screensize.y * 0.7), "gfx/splash.tga", '1 1 1', a * 0.5, 1);
		}
	}
	
	sui_end();

	if(menu_active)
		draw_drawMousePointer(menuMousePos);

	IL_ENDFRAME();
}

void m_close()
{
	setkeydest(0);
	setmousetarget(MT_CLIENT);
	menu_active = false;
}

void m_open()
{
	setkeydest(2);
	setmousetarget(MT_CLIENT);
	menu_active = true;
}

void m_keyup(float key, float ascii)
{
	sui_input_event(IE_KEYUP, key, ascii, 0);
}

void m_keydown(float key, float ascii)
{
	float used = sui_input_event(IE_KEYDOWN, key, ascii, 0);
	
	if(!used)
	{
		string cmd = getkeybind_bindmap(key, 0);
		if(cmd == "togglemenu")
			m_close();
	}
}

void m_toggle(int mode)
{
	if(menu_active)
		m_close();
	else
		m_open();
}
