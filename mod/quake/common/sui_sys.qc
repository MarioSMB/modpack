#include "sui_sys.qh"

// Shpuld's Simple UI lib - sui
// Created 11/2018
//
// sui is a simple QuakeC UI lib for drawing and handling game interfaces.
// The API is made simple and easy to build upon, but cuts have been made
// to keep complexity low.
//
#ifndef SVQC


// framing

// pseudo windowing, sets a new "frame" for whatever we're drawing, instead of
// always using screen [0, 0] as min and [screen_width, screen_height] as max.
// also allows for aligning content to frame start/end/center on both axis

void sui_reset_align()
{
	_frames_align[_frame_index] = vec2(SUI_ALIGN_START, SUI_ALIGN_START);
}

void sui_set_align(vector align)
{
	_frames_align[_frame_index] = align;
}

vector sui_transform_point(vector point)
{
	int idx = _frame_index;
	switch(_frames_align[idx].x) 
	{
		case SUI_ALIGN_START:	point.x += _frames_pos[idx].x; break;
		case SUI_ALIGN_CENTER:	point.x += _frames_pos[idx].x + _frames_size[idx].x * 0.5; break;
		case SUI_ALIGN_END:		point.x += _frames_pos[idx].x + _frames_size[idx].x; break;
	}
	switch(_frames_align[idx].y) 
	{
		case SUI_ALIGN_START:	point.y += _frames_pos[idx].y; break;
		case SUI_ALIGN_CENTER:	point.y += _frames_pos[idx].y + _frames_size[idx].y * 0.5; break;
		case SUI_ALIGN_END:		point.y += _frames_pos[idx].y + _frames_size[idx].y; break;
	}
	return point;
}

vector sui_transform_box(vector point, vector size)
{
	int idx = _frame_index;
	vector curalign = _frames_align[idx];
	switch(curalign.x) 
	{
		case SUI_ALIGN_START:
			point.x += _frames_pos[idx].x;
			break;
		case SUI_ALIGN_CENTER:
			point.x += _frames_pos[idx].x + _frames_size[idx].x * 0.5 - size.x * 0.5;
			break;
		case SUI_ALIGN_END:
			point.x += _frames_pos[idx].x + _frames_size[idx].x - size.x;
			break;
	}
	switch(curalign.y) 
	{
		case SUI_ALIGN_START:
			point.y += _frames_pos[idx].y;
			break;
		case SUI_ALIGN_CENTER:
			point.y += _frames_pos[idx].y + _frames_size[idx].y * 0.5 - size.y * 0.5;
			break;
		case SUI_ALIGN_END:
			point.y += _frames_pos[idx].y + _frames_size[idx].y - size.y;
			break;
	}
	return point;
}

vector sui_current_frame_pos()
{ 
	return _frames_pos[_frame_index];
}

vector sui_current_frame_size()
{
	 return _frames_size[_frame_index];
}

bool _sui_is_clipping;
vector _sui_clip_area_mins;
vector _sui_clip_area_maxs;
void sui_clip_to_frame()
{
	vector pos = _frames_pos[_frame_index];
	vector size = _frames_size[_frame_index];
	_sui_is_clipping = true;
	_sui_clip_area_mins = pos;
	_sui_clip_area_maxs = pos + size;
#ifdef CSQC
	drawsetcliparea_builtin(pos.x, pos.y, size.x, size.y);
#else
	drawsetcliparea(pos.x, pos.y, size.x, size.y);
#endif
}

void sui_reset_clip()
{
	_sui_is_clipping = false;
	drawresetcliparea();
}

bool sui_is_clipping()
{
	return _sui_is_clipping;
}

void sui_push_frame(vector pos, vector size)
{
	pos = sui_transform_box(pos, size);
	
	_frame_index += 1;
	if(_frame_index >= MAX_FRAMES)
	{
		LOG_INFOF("^3sui warning: amount of frames = %.0f exceeds MAX_FRAMES = %.0f, consider increasing MAX_FRAMES", _frame_index, MAX_FRAMES);
		return;
	}
	
	_frames_pos[_frame_index] = pos;
	_frames_size[_frame_index] = size;
	_frames_align[_frame_index] = vec2(SUI_ALIGN_START, SUI_ALIGN_START); // TODO allow customizing this
}

void sui_pop_frame()
{
	if(_frame_index > 0)
		_frame_index -= 1;
}

void sui_reset_frame()
{
	_frame_index = 0;
	sui_reset_align();
}


// actions

// interaction for sui elements, relies a lot on reading globals to see which
// element id is under cursor or held or whatever, not the most elegant
// solution but in this highly imperative world of QuakeC we can live with it

// TODO better naming
bool is_2dpoint_in_bounds(vector point, vector min, vector max)
{
	if(point.x <= min.x || point.y <= min.y) return false;
	if(point.x > max.x || point.y > max.y) return false;
	return true;
}

// TODO better naming
bool is_2dpoint_in_bbox(vector point, vector pos, vector size)
{
	return is_2dpoint_in_bounds(point, pos, pos + size);
}

void _action_element_count_sanity()
{
	if(_action_elements_index > MAX_ACTION_ELEMENTS)
	{
		// let the user know if they're hitting the bounds
		LOG_INFOF("^3sui warning: amount of action elements = %.0f exceeds MAX_ACTION_ELEMENTS = %.0f, consider increasing MAX_ACTION_ELEMENTS", _action_elements_index, MAX_ACTION_ELEMENTS);
	}
}

const int MAX_MOUSE_ACTIONS = 16;
string _hover_actions[MAX_MOUSE_ACTIONS];
string _click_actions[MAX_MOUSE_ACTIONS];
string _hold_actions[MAX_MOUSE_ACTIONS];
string _release_actions[MAX_MOUSE_ACTIONS];
string _last_clicked_actions[MAX_MOUSE_ACTIONS];

int _hover_action_count;
int _click_action_count;
int _hold_action_count;
int _release_action_count;
int _last_clicked_action_count;


// Resets things you might want to persist normally
void sui_reset_actions()
{
	_hover_action_count = 0;
	_click_action_count = 0;
	_hold_action_count = 0;
	_release_action_count = 0;
	_last_clicked_action_count = 0;
	_holding_click = false;
}

// Per frame reset?
void sui_reset_click()
{
	_hold_action_count = 0;
	_click_action_count = 0;
	_holding_click = false;
}

bool sui_click_held()
{
	return _holding_click;
}


// click: on mouse1 button down AND button op, once

// Returns true if id was the topmost click (what usually is cared about the most)
bool sui_is_clicked(string id)
{
	return _click_action_count > 0 && _click_actions[0] == id;
}

// Returns the index of the clicked id, -1 if wasn't hit at all. 0 is topmost
int sui_click_index(string id)
{
	for (int i = 0; i < _click_action_count; ++i)
	{
		if(_click_actions[i] == id)
			return i;
	}
	return -1;
}


// hover: mouse is on top of the action element id

bool sui_is_hovered(string id)
{
	return _hover_action_count > 0 && _hover_actions[0] == id;
}

int sui_hover_index(string id)
{
	for(int i = 0; i < _hover_action_count; ++i)
	{
		if(_hover_actions[i] == id)
			return i;
	}
	return -1;
}


// hold: mouse button was clicked on top of this id and is held down, but not necessarily over this id anymore

bool sui_is_held(string id)
{
	return _hold_action_count > 0 && _hold_actions[0] == id;
}

int sui_hold_index(string id)
{
	for(int i = 0; i < _hold_action_count; ++i)
	{
		if(_hold_actions[i] == id)
			return i;
	}
	return -1;
}


// last clicked: is this the last action element that was clicked, good for focusing on input boxes for example

bool sui_is_last_clicked(string id)
{
	return _last_clicked_action_count > 0 && _last_clicked_actions[0] == id;
}

int sui_last_clicked_index(string id)
{
	for(int i = 0; i < _last_clicked_action_count; ++i)
	{
		if(_last_clicked_actions[i] == id)
			return i;
	}
	return -1;
}

string sui_get_last_clicked()
{
	if(_last_clicked_action_count == 0)
		return "";
	return _last_clicked_actions[0];
}


// release: a thing was held, but now it was released, once

bool sui_is_released(string id)
{
	return _release_action_count > 0 && _release_actions[0] == id;
}

int sui_release_index(string id)
{
	for(int i = 0; i < _release_action_count; ++i)
	{
		if(_release_actions[i] == id)
			return i;
	}
	return -1;
}


bool mouse_action_sanity(float num)
{
	if(num >= MAX_MOUSE_ACTIONS)
	{
		LOG_INFOF("^3sui warning: you have exceeded the amount of overlapping action elements with %.0f, MAX_MOUSE_ACTIONS = %.0f", num, MAX_MOUSE_ACTIONS);
		return true;
	}
	return false;
}

// mouse move, mostly just update hovers

void _sui_mouse_move(vector pos)
{
	_cursor_position = pos;
	_action_element_count_sanity();
	
	// Reset hover, it'll be back to what it used to be before draw gets called if mouse is still on same element
	_hover_action_count = 0;
	
	// Iterate front to back, so topmost element gets the click/hover
	for(int i = min(MAX_ACTION_ELEMENTS, _action_elements_index) - 1; i >= 0; --i)
	{
		if(is_2dpoint_in_bbox(_cursor_position, _action_elements_pos[i], _action_elements_size[i]))
		{
			if(mouse_action_sanity(_hover_action_count))
				break;
			
			if(_hover_action_count == 0)
				_cursor_relative_hover = _cursor_position - _action_elements_pos[i]; 
			strcpy(_hover_actions[_hover_action_count], _action_elements_id[i]);
			_hover_action_count += 1;
		}
	}
}

// JERK ALERT: hard to pass input params for it without them just being the globals
// ... so it just straight up uses the globals... optimization
void _sui_mouse1_down()
{
	// Cheap but it should work...
	_cursor_click = _cursor_position;
	_cursor_relative_click = _cursor_relative_hover;
	for(int i = 0; i < _hover_action_count; ++i)
		_hold_actions[i] = _hover_actions[i];
	_hold_action_count = _hover_action_count;
	_holding_click = true;
	_last_clicked_action_count = 0;
}

void _sui_mouse1_up()
{
	// Can't be cheap here, we have to get the action fn of the element anyway so..
	_action_element_count_sanity();
	
	// Assume we won't hit anything
	_click_action_count = 0;
	_last_clicked_action_count = 0;
	
	// Iterate front to back, so topmost element gets the click/hover
	for(int i = min(MAX_ACTION_ELEMENTS, _action_elements_index) - 1; i >= 0; --i)
	{
		// If the thing wasn't the same thing we started pressing down on, ignore
		for(int j = 0; j < _hold_action_count; ++j)
		{
			if(_hold_actions[j] == _action_elements_id[i]) // yes this element was held
			{		
				// Still in bounds?
				if(is_2dpoint_in_bbox(_cursor_position, _action_elements_pos[i], _action_elements_size[i]))
				{
					if(mouse_action_sanity(_click_action_count))
						break;
					
					// Register click
					_click_actions[_click_action_count] = _action_elements_id[i];
					_last_clicked_actions[_last_clicked_action_count] = _action_elements_id[i];
					_click_action_count += 1;
					_last_clicked_action_count += 1;
				}
			}
		}
	}
	
	// In case someone is keeping state on hold and wants to do stuff on release, even if cursor has moved
	for(int i = 0; i < _hold_action_count; ++i)
		_release_actions[i] = _hold_actions[i];
	_release_action_count = _hold_action_count;
	_hold_action_count = 0;
	_holding_click = false;
}

void sui_action_element(vector pos, vector size, string id)
{
	if(!_sui_draw_initialized) 
	{
		LOG_INFO("^1sui error: adding sui elements before sui_pre_draw!\n^1  Always do your sui menus between sui_pre_draw and sui_draw!");
	}
	if(_action_elements_index >= MAX_ACTION_ELEMENTS)
	{
		// Silently fail here, sui will let us know another way, increase the count
		// so that the error in click/mousemove handlers prints correct numbers.
		_action_elements_index += 1;
		return;
	}
	
	pos = sui_transform_box(pos, size);
	
	if(_sui_is_clipping)
	{
		vector oldpos = pos;
		pos.x = max(pos.x, _sui_clip_area_mins.x);
		pos.y = max(pos.y, _sui_clip_area_mins.y);
		
		size -= pos - oldpos;
		
		size.x -= bound(0, (pos.x + size.x - _sui_clip_area_maxs.x), size.x);
		size.y -= bound(0, (pos.y + size.y - _sui_clip_area_maxs.y), size.y);
	}
	
	_action_elements_pos[_action_elements_index] = pos;
	_action_elements_size[_action_elements_index] = size;
	strcpy(_action_elements_id[_action_elements_index], id);
	
	_action_elements_index += 1;
}


// Input related stuff

string _sui_binding_command;
string _sui_binding_command_name;

const int MAX_INPUTS = 64;

float _input_buffer_char[MAX_INPUTS];
float _input_buffer_scan[MAX_INPUTS];
int _input_index;
int _input_length;

// probably good to use it like while (sui_get_input(char, scan)) { ... }
float sui_get_input()
{
	if(_input_index >= _input_length)
		return false;
	
	sui_char = _input_buffer_char[_input_index];
	sui_scan = _input_buffer_scan[_input_index];
	++_input_index;
	
	return true;
}

// if 2 controls want to read the same input for some reason..
void sui_reread_input()
{
	_input_index = 0;
}

void sui_clear_input()
{
	_input_length = 0;
	_input_index = 0;
}

bool _sui_add_input(float char, float scan)
{
	// TODO check if input was listened, return false if not
	if (_input_length >= MAX_INPUTS)
	{
		LOG_INFOF("^3sui warning: exceeded amount of per frame inputs count MAX_INPUTS = %.0f\n^3 - make sure sui_input_event isn't being called without sui_draw being called in update loop\n^3 - consider increasing MAX_INPUTS", MAX_INPUTS);
		return true;
	}
	_input_buffer_char[_input_length] = char;
	_input_buffer_scan[_input_length] = scan;
	_input_length += 1;
	return true;
}

// Listen to a certain keycode if it was pressed, this way sui know it was requested
bool sui_listen_keycode_down(int keycode)
{
	return false;
}

// all text that was input between last and current frame
string sui_listen_text_input()
{
	return "";
}

void sui_handle_text_input(float char, float scan)
{
	int maxlen = 128;
	
	string prev = sui_text;
	string pre_cursor, post_cursor;
	float length = strlen(prev);
	if(char > 31 && char < 128) //an actual input
	{
		if(length >= maxlen)
			return;
		pre_cursor = substring(prev, 0, sui_cursor);
		post_cursor = substring(prev, sui_cursor, length);
		
		sui_text = sprintf("%s%s%s", pre_cursor, chr2str(char), post_cursor);
		sui_cursor += 1;
	}
	else if(char == 8) // backspace
	{
		if(sui_cursor <= 0)
			return;
		pre_cursor = substring(prev, 0, sui_cursor - 1);
		post_cursor = substring(prev, sui_cursor, length);
		sui_cursor -= 1;
		sui_cursor = max(0, sui_cursor);
		sui_text = strcat(pre_cursor, post_cursor);
	}
	else if(scan == K_DEL)
	{
		if(sui_cursor >= length)
			return;
		pre_cursor = substring(prev, 0, sui_cursor);
		post_cursor = substring(prev, sui_cursor + 1, length);
		sui_text = strcat(pre_cursor, post_cursor);
	}
	else if(char == 13 || char == 27) // enter or escape
	{
		// Commit and deselect...
		// Let's try a hack..
		_last_clicked_action_count = 0;
	}
	else if(scan == K_LEFTARROW)
	{
		sui_cursor -= 1;
		sui_cursor = max(0, sui_cursor);
	}
	else if(scan == K_RIGHTARROW)
	{
		sui_cursor += 1;
		sui_cursor = min(strlen(prev), sui_cursor);
	}
}

void sui_cap_input_length(float maxlen)
{
	if(strlen(sui_text) > maxlen)
	{
		sui_text = substring(sui_text, 0, -1);
		sui_cursor = strlen(sui_text);
	}
}

void _sui_unbind(string command)
{
	tokenize(findkeysforcommand(command, 0));
	string keyname = keynumtostring(stof(argv(0)));
	string altkeyname = keynumtostring(stof(argv(1)));
	localcmd(sprintf("unbind %s\n", keyname));
	localcmd(sprintf("unbind %s\n", altkeyname));
}

void _sui_do_keybind(float scan, string command)
{
	if(scan == K_ESCAPE) 
	{
		_sui_binding_command = "";
		_sui_binding_command_name = "";
		return;
	}
	if(scan == K_BACKSPACE)
	{
		_sui_unbind(command);
		_sui_binding_command = "";
		_sui_binding_command_name = "";
		return;
	}
	string keyname = keynumtostring(scan);
	_sui_unbind(command);
	localcmd(sprintf("bind %s %s\n", keyname, command));
	_sui_binding_command = "";
	_sui_binding_command_name = "";
}

void sui_start_bind(string command, string command_name)
{
	_sui_binding_command = command;
	_sui_binding_command_name = command_name;
}

// void(float evtype, float scanx, float chary, float devid) sui_input_event
//	 same args is CSQC_InputEvent.
//	 return value tells you if sui used the event or not, in case you want to
//	 not let engine handle it if it was used.
// Sets all the internal sui action stuff, call it in CSQC_InputEvent
bool sui_input_event(float evtype, float scanx, float chary, float devid)
{
	if(!cursor_active)
		return false;
	switch (evtype)
	{
		case IE_MOUSEABS:
		{
			_sui_mouse_move(vec2(scanx, chary));
			return true;
		}
		case IE_MOUSEDELTA:
		{
			// Big question mark...
			// maybe make our own delta based sui_cursor here..
			// maybe just ignore delta and let user fake mouseabs with their own
			// delta cursor by passing different params to this func...?
			// for MVP let's just use mouseabs only
			return false;
		}
		case IE_KEYDOWN:
		{
		#if 0
			if(_sui_binding_command != "")
			{
				// Nothing
				return true;
			}
			else
		#endif
			if(scanx == K_MOUSE1)
			{
				_sui_mouse1_down();
				return true;
			}
			else
			{
			#if 0
				if((scanx == K_ESCAPE || scanx == K_BACKSPACE) && _sui_binding_command != "")
					return true;
				else
			#endif
				if(scanx == K_ESCAPE)
					return false;
				return _sui_add_input(chary, scanx);
			}
		}
		case IE_KEYUP:
		{
		#if 0
			if(_sui_binding_command != "")
			{
				_sui_do_keybind(scanx, _sui_binding_command);
				return true;
			}
			else
		#endif
			if(scanx == K_MOUSE1)
			{
				_sui_mouse1_up();
				return true;
			}
			break;
		}
	}
	
	return false;
}


// void() sui_pre_draw 
// Resets state for sui actions so that no trouble happens. 
// Call it before your menu code per frame in your draw/updateview.
void sui_begin(float width, float height)
{
	_action_elements_index = 0;
	_sui_draw_initialized = true;
	
	sui_reset_frame();
	sui_push_frame('0 0 0', vec2(width, height));
}

void sui_draw_bind_overlay();

// void() sui_end
// Call after your menu code per frame in your draw/updateview.
void sui_end()
{
	// Todo: move overlay drawing elsewhere:
	//sui_draw_bind_overlay();
	// Dirty part:
	_sui_draw_initialized = false;
	// reset "once" type actions
	_click_action_count = 0;
	_release_action_count = 0;
	// empty input buffer
	sui_clear_input();
}


// Different draw components:

void sui_fill(vector pos, vector size, vector color, float alpha, float flags)
{
	pos = sui_transform_box(pos, size);
	
	drawfill(pos, size, color, alpha, flags);
}

void sui_pic(vector pos, vector size, string pic, vector color, float alpha, float flags)
{
	pos = sui_transform_box(pos, size);
	
	drawpic(pos, pic, size, color, alpha, flags);
}

void sui_border_box(vector pos, vector size, float width, vector color, float alpha, float flags)
{
	pos = sui_transform_box(pos, size);
	
	// Top line
	drawfill(pos, vec2(size.x, width), color, alpha, flags);
	// Bottom line
	drawfill(vec2(pos.x, pos.y + size.y - width), vec2(size.x, width), color, alpha, flags);
	// Left line
	drawfill(vec2(pos.x, pos.y + width), vec2(width, size.y - width * 2), color, alpha, flags);
	// Right line
	drawfill(vec2(pos.x + size.x - width, pos.y + width), vec2(width, size.y - width * 2), color, alpha, flags);
}


void sui_drawtext(vector pos, vector size, string text, vector color, float alpha, float flags)
{
	pos = sui_transform_box(pos, vec2(stringwidth(text, 1, size), size.y));
	
	drawstring(pos, text, size, color, alpha, flags);
}

void sui_slider_noop(float value)
{
}

float sui_slidercontrol(string id, vector pos, vector size, vector minmaxsteps, float value, void(float value) action)
{
	sui_action_element(pos, size, id);
	float newvalue = value;
	
	pos = sui_transform_box(pos, size);
	// user is clicking and holding the slider
	if (sui_is_held(id))
	{
		float min = minmaxsteps.x;
		float max = minmaxsteps.y;
		float steps = minmaxsteps.z;
		float click_ratio = (_cursor_position_x - pos.x) / size.x;
		click_ratio = bound(0, click_ratio, 1);
		if(steps > 0)
			click_ratio = rint(click_ratio * steps) / steps;
		newvalue = min + click_ratio * (max - min);
		if(newvalue != value)
			action(newvalue);
	}
	return newvalue;
}

void sui_text_input(string id, vector pos, vector size)
{
	sui_action_element(pos, size, id);
	if(sui_is_clicked(id))
		sui_cursor = strlen(sui_text);
	if(sui_is_last_clicked(id))
	{
		sui_char = 0;
		sui_scan = 0;
		while(sui_get_input())
			sui_handle_text_input(sui_char, sui_scan);
	}
}


void sui_scrollbar(string id, vector size, vector contentsize, vector scrollbar_widths)
{
	vector maxoffset = contentsize - size;
	maxoffset.x = max(0, maxoffset.x);
	maxoffset.y = max(0, maxoffset.y);
	sui_push_frame('0 0 0', size);
	float ofs;
	float length;
	vector barpos, barsize;
	sui_scan = 0;
	sui_char = 0;
	string barname;
	if(maxoffset.y > 0 && contentsize.y > 0)
	{
		sui_set_align(vec2(SUI_ALIGN_END, SUI_ALIGN_START));
		sui_push_frame('0 0 0', vec2(scrollbar_widths.y, size.y));
		ofs = (sui_offset.y / contentsize.y) * size.y;
		length = (size.y / contentsize.y) * size.y;
		barpos = vec2(0, ofs);
		barsize = vec2(scrollbar_widths.y, length);
		barname = strcat(id, "vbar");
		
		if (sui_is_held(barname))
		{
			vector anchor = barpos + _cursor_relative_click;
			anchor = sui_transform_point(anchor);
			float diff = _cursor_position_y - anchor.y;
			sui_offset.y += (diff * contentsize.y) / size.y; //  * contentsize.y; // (size.y / contentsize.y);
		}

		sui_fill(barpos, barsize, '0.1 0.1 0.1' * (1 - sui_is_hovered(barname)), 0.66, 0);
		sui_action_element(barpos, barsize, barname);
		sui_pop_frame();
	} 
	sui_pop_frame();
}

void sui_scroll_view_begin(string id, vector pos, vector size, vector contentsize, vector scrollbar_widths)
{
	// make space for scrollbars
	sui_push_frame(pos, size - vec2(scrollbar_widths.y, scrollbar_widths.x));
	sui_action_element('0 0 0', size, id);
	
	if(sui_hover_index(id) > -1)
	{		
		float scrollamount = 0;
		sui_char = 0;
		sui_scan = 0;
		sui_reread_input();
		while(sui_get_input())
		{
			if(sui_scan == K_MWHEELUP)
				scrollamount -= 20;
			if(sui_scan == K_MWHEELDOWN)
				scrollamount += 20;
		}
		sui_offset.y += scrollamount;
	}
	
	vector maxoffset = contentsize - size;
	maxoffset.x = max(0, maxoffset.x);
	maxoffset.y = max(0, maxoffset.y);
	sui_offset.x = bound(0, sui_offset.x, maxoffset.x);
	sui_offset.y = bound(0, sui_offset.y, maxoffset.y);

	sui_scrollbar(id, size, contentsize, scrollbar_widths);
	
	sui_offset.x = bound(0, sui_offset.x, maxoffset.x);
	sui_offset.y = bound(0, sui_offset.y, maxoffset.y);
	
	sui_clip_to_frame();

	sui_push_frame(-1 * sui_offset, contentsize);
}

void sui_scroll_view_end()
{
	sui_pop_frame();
	sui_reset_clip();
	sui_pop_frame();
}

float _sui_list_item_height;
float _sui_list_first;
float _sui_list_last;
float _sui_list_pos;
int _sui_list_index;
void sui_list_view_begin(string id, vector pos, vector size, vector itemsize, float numitems, vector scrollbar_widths)
{
	vector contentsize = vec2(itemsize.x, itemsize.y * numitems);
	sui_scroll_view_begin(id, pos, size, contentsize, scrollbar_widths);
	
	_sui_list_item_height = itemsize.y;
	float hidden_above = floor(sui_offset.y / itemsize.y);
	_sui_list_first = max(0, hidden_above); // Index of first elem
	_sui_list_last = min(_sui_list_first + rint(size.y / itemsize.y) + 1, numitems);
	_sui_list_pos = hidden_above * itemsize.y;
	_sui_list_index = _sui_list_first;
}

float sui_list_item()
{
	if (_sui_list_index >= _sui_list_last) return -1;
	sui_pos = _sui_list_index * vec2(0, _sui_list_item_height);
	_sui_list_index += 1;
	return _sui_list_index - 1;
}

void sui_list_view_end()
{
	sui_scroll_view_end();
}

string sui_binder(string id, vector pos, vector size, string name, string command)
{
	sui_action_element(pos, size, id);
	if(sui_is_released(id))
		sui_start_bind(command, name);
	
	tokenize(findkeysforcommand(command, 0));
	string keyname = keynumtostring(stof(argv(0)));
	if(keyname == "01")
		keyname = "unbound";
	
	return keyname;
}

void sui_draw_bind_overlay()
{
	if(_sui_binding_command != "")
	{
		vector size = sui_current_frame_size();
		sui_fill(vec2(0, 0), size, '0 0 0', 0.5, 0);
		sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_CENTER));
		float textsize = 16;
		sui_drawtext(vec2(0, -16), vec2(textsize, textsize), "Press a key for", '1 1 1', 1, 0);
		sui_drawtext(vec2(0, 0), vec2(textsize, textsize), sprintf("'%s'", _sui_binding_command_name), '1 1 1', 1, 0);
		sui_drawtext(vec2(0, 16), vec2(textsize - 4, textsize - 4), "ESC to cancel, BACKSPACE to remove", '1 1 1', 1, 0);
	}
}


// -------------------- END OF SUI SYSTEM STUFF --------------------

#endif
