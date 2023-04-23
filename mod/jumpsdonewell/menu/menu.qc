#include "menu.qh"

#include "../common/sui_sys.qh"

const vector MENU_BG = '0.2 0.2 0.2';
const vector MENU_BG_DARK = '0.1 0.1 0.1';
const vector MENU_BORDER = '0.3 0.3 0.4';
const vector MENU_BUTTON = '0.3 0.3 0.5';
const vector MENU_BUTTON_BORDER = '0.35 0.35 0.55';
const vector MENU_TEXT_1 = '1 1 1';
const vector MENU_TEXT_2 = '0.7 0.75 0.75';
const vector MENU_HIGHLIGHT = '1 1 1';
const vector MENU_DARKEN = '1 1 1';

const vector MENU_TEXT_SMALL = '8 8 0';
const vector MENU_TEXT_MEDIUM = '16 16 0';
const vector MENU_TEXT_LARGE = '24 24 0';

void input_tester()
{
	sui_char = 0;
	string printme = "";
	while(sui_get_input())
	{
		printme = strcat(printme, chr2str(sui_char));
	}
	if(printme != "")
		LOG_INFO("INPUT: ", printme); 
}

bool my_button(string id, vector pos, vector size, string text)
{
	sui_push_frame(pos, size);
	vector basecolor = (sui_is_hovered(id)) ? MENU_BUTTON + MENU_HIGHLIGHT * 0.1 : MENU_BUTTON; 
	basecolor = (sui_is_held(id)) ? MENU_BUTTON - MENU_DARKEN * 0.1 : basecolor;
	sui_fill('0 0 0', size, basecolor, 0.6, 0);
	sui_border_box('0 0 0', size, 1, MENU_BUTTON_BORDER, 0.4, 0);
	
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_CENTER));
	sui_drawtext('0 0 0', MENU_TEXT_SMALL, text, MENU_TEXT_1, 1, 0);	
	sui_action_element('0 0 0', size, id);
	sui_pop_frame();
	
	return sui_is_clicked(id);
}


float my_slider(string id, vector pos, vector size, vector minmaxsteps, float value)
{
	sui_push_frame(pos, size);
	
	value = sui_slidercontrol(id, '0 0 0', size, minmaxsteps, value, sui_slider_noop);
	float maxval = minmaxsteps.y;
	float sliderx = (value / maxval) * size.x;
	sui_fill(vec2(0, size.y * 0.25), vec2(size.x, size.y * 0.5), MENU_BG_DARK, 1.0, 0);
	
	float is_active = (sui_is_held(id) || (sui_is_hovered(id) && !sui_click_held()));
	vector slider_ctrl_color = (is_active) ? MENU_BUTTON + MENU_HIGHLIGHT * 0.1 : MENU_BUTTON;
	sui_fill(vec2(sliderx - 2, 0), vec2(4, size.y), slider_ctrl_color, 1.0, 0);
	
	sui_pop_frame();

	return value;
}

void cvar_slider(vector pos, vector size, vector minmaxsteps, string cvar_s, string name, string format)
{
	float current = cvar(cvar_s);
	float old = current;
	sui_push_frame(pos, vec2(size.x, size.y * 0.5 - 4));
	sui_drawtext('0 0 0', MENU_TEXT_SMALL, name, MENU_TEXT_1, 1, 0);
	sui_set_align(vec2(SUI_ALIGN_END, SUI_ALIGN_START));
	sui_drawtext('0 0 0', MENU_TEXT_SMALL, sprintf(format, current), MENU_TEXT_1, 1, 0);
	sui_pop_frame();
	current = my_slider(strcat(cvar_s, "sldr"), vec2(pos_x, pos_y + size.y * 0.5), vec2(size.x, size.y * 0.5), minmaxsteps, current);
	if(current != old)
		cvar_set(cvar_s, ftos(current));
}

string bindlist_name[6] = {"Forward", "Back", "Left", "Right", "Attack", "Jump"};

string bindlist_command[6] = {"+forward", "+back", "+moveleft", "+moveright", "+attack","+jump"};

void bind_button(string id, vector pos, vector size, string name, string command)
{
	sui_push_frame(pos, size);
	sui_set_align(vec2(SUI_ALIGN_START, SUI_ALIGN_CENTER));
	string key = sui_binder(id, '0 0 0', size, name, command);
	if (sui_is_hovered(id)) sui_fill('0 0 0', size, MENU_HIGHLIGHT, 0.1, 0);
	sui_drawtext('6 0 0', MENU_TEXT_SMALL, name, MENU_TEXT_1, 1, 0);
	sui_set_align(vec2(SUI_ALIGN_END, SUI_ALIGN_CENTER));
	sui_drawtext('-6 0 0', MENU_TEXT_SMALL, key, MENU_TEXT_1, 1, 0);
	
	sui_pop_frame();
}


void bind_list(string id, vector pos, vector size)
{
	sui_fill(pos, size, MENU_BG_DARK, 0.75, 0);
	sui_list_view_begin(strcat(id, "scrl"), pos, size, vec2(size.x - 6, 24), 5, '0 6 0');
	sui_pos = '0 0 0';
	for(float index = sui_list_item(); index > -1; index = sui_list_item())
	{
		sui_push_frame(sui_pos, vec2(size.x - 6, 24));
		bind_button(strcat(id, ftos(index)), '0 0 0', vec2(size.x - 6, 24), bindlist_name[index], bindlist_command[index]);
		sui_pop_frame();
	}
	sui_list_view_end();
}

vector binds_scroll;
void settings_menu()
{
	vector pos = '0 0 0';
	vector size = '360 280 0';
	
	sui_push_frame(pos, size);

	sui_fill('0 0 0', size, MENU_BG, 0.75, 0);
	sui_border_box('0 0 0', size, 2, MENU_BORDER, 0.3, 0);
	
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_START));
	sui_drawtext('0 4 0', MENU_TEXT_MEDIUM, "Settings", MENU_TEXT_1, 1, 0);


	sui_set_align(vec2(SUI_ALIGN_START, SUI_ALIGN_START));
	
	float xpos = 8;
	float ypos = 32;
	float width = size.x * 0.5 - 8 * 2;
	sui_drawtext(vec2(xpos, ypos), MENU_TEXT_SMALL, "Controls", MENU_TEXT_1, 1, 0);
	ypos += 16;
	sui_offset = binds_scroll;
	bind_list("bindlist", vec2(xpos, ypos), vec2(width, 160));
	binds_scroll = sui_offset;
	ypos += 160 + 8;

	cvar_slider(vec2(xpos, ypos), vec2(width, 32), '0.1 10 0', "sensitivity", "Sensitivity", "%.2f");
	ypos += 32;

	ypos = 32;
	xpos = 8 + width + 8 + 8;
	
	cvar_slider(vec2(xpos, ypos), vec2(width, 32), '0 1 0', "volume", "Volume", "%.2f");
	ypos += 32 + 4;
	cvar_slider(vec2(xpos, ypos), vec2(width, 32), '0 1 0', "bgmvolume", "Music Volume", "%.2f");
	ypos += 32 + 4 + 8;
	
	sui_drawtext(vec2(xpos, ypos), MENU_TEXT_SMALL, "Video", MENU_TEXT_1, 1, 0);
	ypos += 16;
	if(my_button("fs_btn", vec2(xpos, ypos), vec2(width, 20), "Fullscreen"))
		localcmd("vid_fullscreen 1; vid_restart\n");
	ypos += 24;
	if(my_button("wn_btn", vec2(xpos, ypos), vec2(width, 20), "Windowed"))
		localcmd("vid_fullscreen 0; vid_restart\n");
	ypos += 24;
	sui_drawtext(vec2(xpos, ypos), MENU_TEXT_SMALL, "Window can be resized.", MENU_TEXT_1, 0.8, 0);
	ypos += 16;
	sui_set_align(vec2(SUI_ALIGN_END, SUI_ALIGN_END));
	if(my_button("stg_back", '-8 -8 0', '80 20 0', "Back"))
		current_menu = MENU_MAIN;
	
	sui_pop_frame();
}

void help_menu()
{
	vector pos = '0 0 0';
	vector size = '360 280 0';
	
	sui_push_frame(pos, size);

	sui_fill('0 0 0', size, MENU_BG, 0.75, 0);
	sui_border_box('0 0 0', size, 2, MENU_BORDER, 0.3, 0);
	
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_START));
	sui_drawtext('0 4 0', MENU_TEXT_MEDIUM, "Help", MENU_TEXT_1, 1, 0);
	
	float xpos = 0;
	float ypos = 32;
	sui_drawtext(vec2(xpos, ypos), MENU_TEXT_SMALL, "How to play (Default)", MENU_TEXT_1, 1, 0);
	ypos += 32;
	sui_drawtext(vec2(xpos, ypos), MENU_TEXT_SMALL, "ARROWS to move", MENU_TEXT_1, 1, 0);
	ypos += 32;
	sui_drawtext(vec2(xpos, ypos), MENU_TEXT_SMALL, "Z to attack", MENU_TEXT_1, 1, 0);
	ypos += 32;
	sui_drawtext(vec2(xpos, ypos), MENU_TEXT_SMALL, "X to jump", MENU_TEXT_1, 1, 0);
	ypos += 32;
	sui_drawtext(vec2(xpos, ypos), MENU_TEXT_SMALL, "Pick up items to get stronger and overcome", MENU_TEXT_1, 1, 0);
	ypos += 16;
	sui_drawtext(vec2(xpos, ypos), MENU_TEXT_SMALL, "obstacles that way.", MENU_TEXT_1, 1, 0);
	
	sui_set_align(vec2(SUI_ALIGN_END, SUI_ALIGN_END));
	if(my_button("hlp_back", '-8 -8 0', '80 20 0', "Back"))
		current_menu = MENU_MAIN;

	sui_pop_frame();	
}

void main_menu()
{
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_START));
	sui_drawtext('0 64 0', MENU_TEXT_LARGE, "Jumps Done Well", '1 1 1', 1, 0);
	
	vector pos = '0 -24 0';
	vector size = '120 140 0';
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_END));
	sui_push_frame(pos, size);
	
	sui_fill('0 0 0', size, MENU_BG, 0.3, 0);
	sui_border_box('0 0 0', size, 2, MENU_BORDER, 0.2, 0);
	
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_START));
	
	if(my_button("mm_start", '0 8 0', vec2(size.x - 16, 20), "New Game"))
		localcmd("map map2\n");
	if(my_button("mm_settings", '0 32 0', vec2(size.x - 16, 20), "Settings"))
		current_menu = MENU_SETTINGS;
	if(my_button("mm_help", '0 56 0', vec2(size.x - 16, 20), "Help"))
		current_menu = MENU_HELP;
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_END));
	if(my_button("mm_quit", '0 -8 0', vec2(size.x - 16, 20), "Quit"))
		localcmd("quit\n");
	sui_pop_frame();	
}

void root_menu(vector size)
{
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_CENTER));
	sui_fill('0 0 0', size, '0 0 0', 0.5, 0);
	switch (current_menu)
	{
		case MENU_MAIN: main_menu(); break;
		case MENU_SETTINGS: settings_menu(); break;
		case MENU_HELP: help_menu();
		default: break;
	}
}
