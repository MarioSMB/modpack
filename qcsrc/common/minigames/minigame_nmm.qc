
#ifdef SVQC

float minigame_event_nmm(entity minigame, string event, ...count)
{
	if ( event == "start" )
	{
		dprint("Starting ",minigame.descriptor.netname,"\n");
		minigame_spawn_board_tile(minigame,"a7",minigame_tile_pos("a7",7,7));
		minigame_spawn_board_tile(minigame,"d7",minigame_tile_pos("d7",7,7));
		minigame_spawn_board_tile(minigame,"g7",minigame_tile_pos("g7",7,7));
		
		minigame_spawn_board_tile(minigame,"b6",minigame_tile_pos("b6",7,7));
		minigame_spawn_board_tile(minigame,"d6",minigame_tile_pos("d6",7,7));
		minigame_spawn_board_tile(minigame,"f6",minigame_tile_pos("f6",7,7));
		
		minigame_spawn_board_tile(minigame,"c5",minigame_tile_pos("c5",7,7));
		minigame_spawn_board_tile(minigame,"d5",minigame_tile_pos("d5",7,7));
		minigame_spawn_board_tile(minigame,"e5",minigame_tile_pos("e5",7,7));
		
		minigame_spawn_board_tile(minigame,"a4",minigame_tile_pos("a4",7,7));
		minigame_spawn_board_tile(minigame,"b4",minigame_tile_pos("b4",7,7));
		minigame_spawn_board_tile(minigame,"c4",minigame_tile_pos("c4",7,7));
		minigame_spawn_board_tile(minigame,"e4",minigame_tile_pos("e4",7,7));
		minigame_spawn_board_tile(minigame,"f4",minigame_tile_pos("f4",7,7));
		minigame_spawn_board_tile(minigame,"g4",minigame_tile_pos("g4",7,7));
		
		minigame_spawn_board_tile(minigame,"c3",minigame_tile_pos("c3",7,7));
		minigame_spawn_board_tile(minigame,"d3",minigame_tile_pos("d3",7,7));
		minigame_spawn_board_tile(minigame,"e3",minigame_tile_pos("e3",7,7));
		
		minigame_spawn_board_tile(minigame,"b2",minigame_tile_pos("b2",7,7));
		minigame_spawn_board_tile(minigame,"d2",minigame_tile_pos("d2",7,7));
		minigame_spawn_board_tile(minigame,"f2",minigame_tile_pos("f2",7,7));
		
		minigame_spawn_board_tile(minigame,"a1",minigame_tile_pos("a1",7,7));
		minigame_spawn_board_tile(minigame,"d1",minigame_tile_pos("d1",7,7));
		minigame_spawn_board_tile(minigame,"g1",minigame_tile_pos("g1",7,7));
		
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

void minigame_hud_board_nmm(vector pos, vector mySize)
{
	minigame_hud_fitsqare(pos, mySize);
	minigame_hud_simpleboard(pos,mySize,minigame_texture("nmm/board"));
	
	vector tile_pos;
	vector tile_size = minigame_hud_denormalize_size('1 1 0'/7,pos,mySize);
	entity e;
	FOREACH_MINIGAME_ENTITY(e)
	{
		if ( e.classname == "minigame_board_tile" )
		{
			tile_pos = minigame_hud_denormalize(e.origin,pos,mySize)-tile_size/2;
			if ( minigame_hud_mouse_in(tile_pos, tile_size) )
				drawpic( tile_pos, minigame_texture("nmm/tile_selected"),
						tile_size, '1 1 1', panel_fg_alpha, BORDER_MULTIPLIER );
		}
	}
}

void minigame_hud_status_nmm(vector pos, vector mySize)
{
	HUD_Panel_DrawBg(0.5);
	vector titlepos = pos;
	vector titlesize = hud_fontsize * 2;
	string titletext = "Test!";
	titlepos_x += stringwidth(titletext, FALSE, titlesize) / 2;
	drawstring(titlepos, titletext, titlesize, '1 0 0', panel_fg_alpha, DRAWFLAG_NORMAL);
}

float minigame_event_nmm(entity minigame, string event, ...count)
{
	if ( event == "key_pressed" && count > 0 )
	{
		if ( ...(0,float) == K_SPACE )
			dprint("You Pressed Space!\n");
		else 
			dprint("You pressed ",ftos(...(0,float)),"\n");
	}
	else if ( event == "mouse_pressed" && count > 0 && ...(0,float) == K_MOUSE1 )
	{
		vector pos, sz;
		minigame_hud_panelarea(pos,sz,MINIGAME_BOARD);
		minigame_hud_fitsqare(pos, sz);
		vector mousep = minigame_hud_normalize(mousepos,pos,sz);
		dprint("Clicked ",minigame_tile_name(mousep,7,7),"\n");
	}
	
	return 0;
}

#endif 
