
#ifdef SVQC

float minigame_event_test(entity minigame, string event, ...count)
{
	if ( event == "start" )
	{
		dprint("Starting ",minigame.descriptor.netname,"\n");
		return 1;
	}
	else if ( event == "join" && count > 0 )
	{
		dprint(...(0,entity).netname," joined ",minigame.descriptor.netname,"\n");
		return 1;
	}
	else if ( event == "part" && count > 0 )
	{
		dprint(...(0,entity).netname," parted ",minigame.descriptor.netname,"\n");
		return 1;
	}
	else if ( event == "end" )
	{
		dprint("Game ended ",minigame.descriptor.netname,"\n");
		return 1;
	}
	dprint("Unhandled event: ",event,"\n");
	return 0;
}

#elif defined(CSQC)

void minigame_hud_board_test(vector pos, vector mySize)
{
	minigame_hud_fitsqare(pos, mySize);
	minigame_hud_simpleboard(pos,mySize,minigame_texture("common/chessboard"));
}

void minigame_hud_status_test(vector pos, vector mySize)
{
	HUD_Panel_DrawBg(0.5);
	vector titlepos = pos;
	vector titlesize = hud_fontsize * 2;
	string titletext = "Test!";
	titlepos_x += stringwidth(titletext, FALSE, titlesize) / 2;
	drawstring(titlepos, titletext, titlesize, '1 0 0', panel_fg_alpha, DRAWFLAG_NORMAL);
}

float minigame_event_test(entity minigame, string event, ...count)
{
	if ( event == "key_pressed" && count > 0 )
	{
		if ( ...(0,float) == K_SPACE )
			dprint("You Pressed Space!\n");
		else 
			dprint("You pressed ",ftos(...(0,float)),"\n");
	}
	else if ( event == "mouse_pressed" && count > 0 )
	{
		dprint("You clicked with ",ftos(...(0,float)),"\n");
	}
	
	return 0;
}

#endif 
