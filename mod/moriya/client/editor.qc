float grid_size;

float last_scroll_time;

NET_HANDLE(ed_update, bool)
{
	cl_editor_update_selection();
	return true;
}

STATIC_INIT_LATE(editor_init)
{
	registercommand("toggleeditmode");
	
	grid_size = 16;
}

float selected_entity_index;

string entlist[] = {"item_coin", "monster_spirit", "item_ring"};

vector entity_menu_scroll;

string editor_selection_org;
string editor_selection_ang;
string editor_selection_spawnflags;
string editor_selection_target;
string editor_selection_targetname;

void send_org() { localcmd(sprintf("cmd edit_setprop origin %s\n", editor_selection_org)); }
void send_ang() { localcmd(sprintf("cmd edit_setprop angles %s\n", editor_selection_ang)); }
void send_spawnflags() { localcmd(sprintf("cmd edit_setprop spawnflags %s\n", editor_selection_spawnflags)); }
void send_target() { localcmd(sprintf("cmd edit_setprop target %s\n", editor_selection_target)); }
void send_targetname() { localcmd(sprintf("cmd edit_setprop targetname %s\n", editor_selection_targetname)); }

void entity_list(string id, vector pos, vector size)
{
	sui_fill(pos, size, '0.2 0.2 0.2', 0.75, 0);
	sui_list_view_begin(strcat(id, "scrl"), pos, size, vec2(size.x - 6, 16), 3, '0 6 0');
	sui_pos = '0 0 0';
	for(float index = sui_list_item(); index > -1; index = sui_list_item())
	{
		sui_push_frame(sui_pos, vec2(size.x - 6, 16));
		string iid = strcat(id, ftos(index));
		sui_action_element('0 0 0', vec2(size.x -6, 16), iid);
		if(sui_is_hovered(iid))
			sui_fill('0 0 0', vec2(size.x - 6, 16), '1 1 1', 0.1, 0);
		if(sui_is_clicked(iid))
			selected_entity_index = index;
		sui_set_align(vec2(SUI_ALIGN_START, SUI_ALIGN_CENTER));
		if(selected_entity_index == index)
			sui_fill('0 0 0', vec2(size.x - 6, 16), '1 1 1', 0.2, 0);
		sui_drawtext('0 0 0', '8 8 0', entlist[index], '1 1 1', 1, 0);
		sui_pop_frame();
	}
	sui_list_view_end();	
}

var void() current_apply;
void() no_apply = {};
float prop_editor_cursor;
string entity_prop_input(string id, vector pos, vector size, string label, string str, void() apply)
{
	sui_push_frame(pos, size);
	vector tsize = vec2(size.y/2, size.y/2);
	string inid = strcat("in_", id);
	sui_drawtext('0 0 0', tsize, label, '1 1 1', 1, 0);
	sui_text = str;
	sui_cursor = prop_editor_cursor;
	sui_text_input(inid, vec2(0, tsize.y), vec2(size.x, tsize.y));
	str = sui_text;
	prop_editor_cursor = sui_cursor;
	sui_fill(vec2(0, tsize.y), vec2(size.x, tsize.y), '0.2 0.2 0.2', 0.5, 0);
	sui_drawtext(vec2(0, tsize.y), tsize, str, '1 1 1', 1, 0);
	if(sui_is_last_clicked(inid))
	{
		sui_fill(vec2(tsize.x*prop_editor_cursor, tsize.y), tsize, '1 1 1', 0.5, 0);
		current_apply = apply;
	}

	sui_pop_frame();
	return str;
}


void entity_prop_editor(vector pos, vector size)
{
	sui_fill(pos, size, '0 0 0', 0.5, 0);
	float xpos = 4;
	float ypos = 4;
	float insize = 16;
	
	editor_selection_org = entity_prop_input("org", vec2(xpos, ypos), vec2(size.x - 8, insize), "Origin", editor_selection_org, send_org);
	ypos += insize;
	editor_selection_ang = entity_prop_input("ang", vec2(xpos, ypos), vec2(size.x - 8, insize), "Angles", editor_selection_ang, send_ang);
	ypos += insize;
	editor_selection_spawnflags = entity_prop_input("sf", vec2(xpos, ypos), vec2(size.x - 8, insize), "Spawnflags", editor_selection_spawnflags, send_spawnflags);
	ypos += insize;
	editor_selection_target = entity_prop_input("target", vec2(xpos, ypos), vec2(size.x - 8, insize), "Target", editor_selection_target, send_target);
	ypos += insize;
	editor_selection_targetname = entity_prop_input("targetname", vec2(xpos, ypos), vec2(size.x - 8, insize), "Targetname", editor_selection_targetname, send_targetname);
	ypos += insize;
}

void cl_editor_draw()
{
	if(!STAT(ED_MODE))
		return;
	
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_END));
	sui_drawtext('0 -8 0', '16 16 0', "EDIT MODE", '1 0.1 0.1', 1, 0);
	sui_drawtext('0 -32 0', '8 8 0', sprintf("Grid size: %d", grid_size), '1 1 1', 1, 0);
	
	sui_set_align(vec2(SUI_ALIGN_CENTER, SUI_ALIGN_CENTER));
	sui_fill('0 0 0', '4 4 0', '0 0 0', 0.5, 0);
	sui_fill('0 0 0', '2 2 0', '1 1 1', 0.75, 0);
	
	vector ent_menu_size = '140 200 0';
	sui_set_align(vec2(SUI_ALIGN_START, SUI_ALIGN_END));
	sui_push_frame('0 0 0', ent_menu_size);
	
	sui_fill('0 0 0', ent_menu_size, '0 0 0', 0.5, 0);
	sui_offset = entity_menu_scroll;
	entity_list("entlist", '0 0 0', ent_menu_size - '2 2 0');
	entity_menu_scroll = sui_offset;
	
	sui_pop_frame();
	
	sui_set_align(vec2(SUI_ALIGN_END, SUI_ALIGN_END));
	ent_menu_size = '140 140 0';
	sui_push_frame('0 0 0', ent_menu_size);
	entity_prop_editor('0 0 0', ent_menu_size);
	
	sui_pop_frame();
	
	cheats_used = true;
}

void cl_editor_update_selection()
{
	editor_selection_org = sprintf("%v", ReadVector());
	editor_selection_ang = sprintf("%v", ReadVector());
	editor_selection_spawnflags = sprintf("%.0f", ReadFloat());
	editor_selection_target = ReadString();
	editor_selection_targetname = ReadString();
}

// This must be called in CSQC_ConsoleCommand
// input entity self
// input string cmd: same as in CSQC_ConsoleCommand
// output float: true if command was handled, false if not
bool cl_editor_command(string cmd)
{
	// cmd is actually argv(1)
	if(cmd == "toggleeditmode")
	{
		if(STAT(ED_MODE))
			setcursormode(false);
		else
			setcursormode(true);
		localcmd("cmd toggleeditmode\n");
		return true;
	}
	return false;
}

bool cl_editor_input_event(float evtype, float scanx, float chary, float devid)
{
	if(!STAT(ED_MODE))
		return false;
	
	switch(evtype)
	{
		case IE_KEYDOWN:
			if(substring(sui_get_last_clicked(), 0, 3) == "in_")
				return true;
			
			if(chr2str(chary) == "n")
				localcmd(sprintf("cmd edit_add %s\n", entlist[selected_entity_index]));
			if(scanx == K_MOUSE1)
			{ 
				if(getmousepos() == '0 0 0')
					localcmd("cmd edit_select\n");
				return true;
			}
			if(scanx == K_UPARROW)
			{
				localcmd("cmd edit_move 0\n");
				return true;
			}
			if(scanx == K_DOWNARROW)
			{
				localcmd("cmd edit_move 1\n");
				return true;
			}
			if(scanx == K_LEFTARROW)
			{
				if(ctrl_held && shift_held)
					localcmd("cmd edit_rotate 15\n");
				else if(shift_held)
					localcmd("cmd edit_rotate 45\n");
				else
					localcmd("cmd edit_move 2\n");
				return true;
			}
			if(scanx == K_RIGHTARROW)
			{
				if(ctrl_held && shift_held)
					localcmd("cmd edit_rotate -15\n");
				else if(shift_held)
					localcmd("cmd edit_rotate -45\n");
				else
					localcmd("cmd edit_move 3\n");
				return true;
			}
			if(scanx == K_PGUP)
			{
				localcmd("cmd edit_move 4\n");
				return true;
			}
			if(scanx == K_PGDN)
			{
				localcmd("cmd edit_move 5\n");
				return true;
			}
			if(scanx == K_DEL)
			{
				localcmd("cmd edit_delete\n");
				return true;
			}
			
			if(scanx == K_MOUSE2)
			{
				setcursormode(false);
				return true;
			}
			break;
		case IE_KEYUP:
			if(scanx == K_MWHEELUP) 
			{
				if(time - last_scroll_time < 0.1)
					return false;
				grid_size *= 2;
				grid_size = min(256, grid_size);
				localcmd(sprintf("cmd edit_grid %f\n", grid_size));
				last_scroll_time = time;
				return true;
			}
			if(scanx == K_MWHEELDOWN) 
			{
				if(time - last_scroll_time < 0.1)
					return false;
				grid_size *= 0.5;
				grid_size = max(1, grid_size);
				localcmd(sprintf("cmd edit_grid %f\n", grid_size));
				last_scroll_time = time;
				return true;
			}
			
			if(scanx == K_ENTER)
			{
				if(current_apply) current_apply();
				current_apply = no_apply;
				return true;
			}
			
			if(scanx == K_MOUSE2)
			{
				setcursormode(true);
				return true;
			}
			break;
		case IE_MOUSEDELTA:
			break;
		case IE_MOUSEABS:
			break;
	}
	
	return false;
}
