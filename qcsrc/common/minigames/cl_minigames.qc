// Draw a square in the center of the avaliable area
void minigame_hud_simpleboard(vector pos, vector mySize, string board_texture)
{
	if ( mySize_x > mySize_y )
	{
		pos_x += (mySize_x-mySize_y)/2;
		mySize_x = mySize_y;
	}
	else
	{
		pos_y += (mySize_y-mySize_x)/2;
		mySize_x = mySize_x;
	}
	
	if(panel_bg_padding)
	{
		pos += '1 1 0' * panel_bg_padding;
		mySize -= '2 2 0' * panel_bg_padding;
	}
	
	if(panel.current_panel_bg != "0" && panel.current_panel_bg != "")
		draw_BorderPicture(pos - '1 1 0' * panel_bg_border, 
					panel.current_panel_bg, 
					mySize + '1 1 0' * 2 * panel_bg_border, 
					panel_bg_color, panel_bg_alpha, 
					 '1 1 0' * (panel_bg_border/BORDER_MULTIPLIER));
	drawpic(pos, board_texture, mySize, '1 1 1', panel_bg_alpha, DRAWFLAG_NORMAL);
}


void initialize_minigames()
{
	entity last_minig = world;
	entity minig;
	#define MINIGAME(name) \
		minig = spawn(); \
		minig.netname = strzone(strtolower(#name)); \
		minig.minigame_hud_board = minigame_hud_board_##name; \
		minig.minigame_hud_status = minigame_hud_status_##name; \
		minig.minigame_input = minigame_input_##name; \
		if ( !last_minig ) minigame_descriptors = minig; \
		else last_minig.chain = minig; \
		last_minig = minig;
		
	REGISTERED_MINIGAMES
	
	#undef MINIGAME
}

string minigame_texture_skin(string skinname, string name)
{
	return sprintf("gfx/hud/%s/minigames/%s", skinname, name);
}
string minigame_texture(string name)
{
	string path = minigame_texture_skin(autocvar_menu_skin,name);
	if ( precache_pic(path) == "" )
		path = minigame_texture_skin("default", name);
	return path;
}

void activate_minigame(string name)
{
	active_minigame = minigame_get_descriptor(name);
	if ( !active_minigame )
		dprint("Trying to activate unregistered minigame ",name," in client\n");
	else if(autocvar_hud_cursormode)
		setcursormode(1);
}

void deactivate_minigame()
{
	active_minigame = world;
	setcursormode(0);
}