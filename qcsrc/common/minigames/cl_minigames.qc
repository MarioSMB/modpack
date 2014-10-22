// Draw a square in the center of the avaliable area
void HUD_MinigameBoard_Simpleboard(vector pos, vector mySize, string board)
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
		if ( !last_minig ) minigame_descriptors = minig; \
		else last_minig.chain = minig; \
		last_minig = minig;
		
	REGISTERED_MINIGAMES
	
	#undef MINIGAME
}