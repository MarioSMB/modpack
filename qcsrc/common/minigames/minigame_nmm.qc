
const float NMM_TURN_PLACE = 0x10;
const float NMM_TURN_MOVE  = 0x20;
const float NMM_TURN_FLY   = 0x40;

const float NMM_PIECE_DEAD  = 0x0; // captured by the enemy
const float NMM_PIECE_HOME  = 0x1; // not yet placed
const float NMM_PIECE_BOARD = 0x2; // placed on the board


void nmm_spawn_tile(string id, entity minig)
{
	entity e = spawn();
	e.origin = minigame_tile_pos(id,7,7);
	e.classname = "minigame_nmm_tile";
	e.netname = id;
	e.owner = minig;
	e.minigame_autoclean = 1;
	e.team = 0;
}

void nmm_init_tiles(entity minig)
{
	#define NMMT(id) nmm_spawn_tile(#id,minig);
	
	NMMT(a7)/*----------------------*/NMMT(d7)/*----------------------*/NMMT(g7)
	 /*|*/                             /*|*/                             /*|*/
	 /*|*/       NMMT(b6)/*---------*/NMMT(d6)/*---------*/NMMT(f6)      /*|*/
	 /*|*/        /*|*/                /*|*/                /*|*/        /*|*/
	 /*|*/        /*|*/       NMMT(c5)NMMT(d5)NMMT(e5)      /*|*/        /*|*/  
	 /*|*/        /*|*/        /*|*/           /*|*/        /*|*/        /*|*/
	NMMT(a4)/*-*/NMMT(b4)/*-*/NMMT(c4)        NMMT(e4)/*-*/NMMT(f4)/*-*/NMMT(g4)  
	 /*|*/        /*|*/        /*|*/           /*|*/        /*|*/        /*|*/
	 /*|*/        /*|*/       NMMT(c3)NMMT(d3)NMMT(e3)      /*|*/        /*|*/
	 /*|*/        /*|*/                /*|*/                /*|*/        /*|*/  
	 /*|*/       NMMT(b2)/*---------*/NMMT(d2)/*---------*/NMMT(f2)      /*|*/  
	 /*|*/                             /*|*/                             /*|*/
	NMMT(a1)/*----------------------*/NMMT(d1)/*----------------------*/NMMT(g1)
	   
	#undef NMMT
}

#ifdef SVQC

float minigame_event_nmm(entity minigame, string event, ...count)
{
	if ( event == "start" )
	{
		minigame.minigame_flags = NMM_TURN_PLACE; // TODO send it to client
		nmm_init_tiles(minigame);
		float i;
		entity e;
		for ( i = 0; i < 7; i++ )
		{
			e = minigame_spawn_board_piece(minigame);
			e.team = 0;
			e.minigame_flags = NMM_PIECE_HOME;
			e = minigame_spawn_board_piece(minigame);
			e.team = 1;
			e.minigame_flags = NMM_PIECE_HOME;
		}
			
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

entity nmm_currtile;

vector nmm_boardpos;
vector nmm_boardsize;


entity nmm_get_tile(string id)
{
	entity e;
	FOREACH_MINIGAME_ENTITY(e)
		if ( e.classname == "minigame_nmm_tile" && e.netname == id )
			return e;
	return world;
}


void minigame_hud_board_nmm(vector pos, vector mySize)
{
	minigame_hud_fitsqare(pos, mySize);
	nmm_boardpos = pos;
	nmm_boardsize = mySize;
	minigame_hud_simpleboard(pos,mySize,minigame_texture("nmm/board"));
	
	if ( nmm_currtile )
	{
		vector tile_size = minigame_hud_denormalize_size('1 1 0'/7,pos,mySize);
		vector tile_pos = minigame_hud_denormalize(nmm_currtile.origin,pos,mySize)-tile_size/2;
		drawpic( tile_pos, minigame_texture("nmm/tile_selected"),
				tile_size, '1 1 1', panel_fg_alpha, DRAWFLAG_ADDITIVE );
	}
}

void minigame_hud_status_nmm(vector pos, vector mySize)
{
	HUD_Panel_DrawBg(1);
	vector ts;
	
	ts = minigame_drawstring_wrapped(mySize_x,pos,active_minigame.descriptor.message,
		hud_fontsize * 2, '0.25 0.47 0.72', panel_fg_alpha, DRAWFLAG_NORMAL,0.5);
	pos_y += ts_y;
	
	minigame_drawcolorcodedstring_trunc(mySize_x,pos,GetPlayerName(player_localnum),
		hud_fontsize * 1.75, panel_fg_alpha, DRAWFLAG_NORMAL);
}

void nmm_make_move()
{
	if ( nmm_currtile )
		dprint("Selected ",nmm_currtile.netname,"\n");
}

float minigame_event_nmm(entity minigame, string event, ...count)
{
	if ( event == "activate" )
	{
		nmm_init_tiles(minigame);
	}
	else if ( event == "key_pressed" && count > 0 )
	{
		switch ( ...(0,float) )
		{
			case K_RIGHTARROW:
			case K_KP_RIGHTARROW:
				if ( ! nmm_currtile )
					nmm_currtile = nmm_get_tile("a7");
				else
				{
					string tileid = nmm_currtile.netname;
					nmm_currtile = world; 
					while ( !nmm_currtile )
					{
						tileid = minigame_relative_tile(tileid,1,0,7,7);
						nmm_currtile = nmm_get_tile(tileid);
					}
				}
				return 1;
			case K_LEFTARROW:
			case K_KP_LEFTARROW:
				if ( ! nmm_currtile )
					nmm_currtile = nmm_get_tile("g7");
				else
				{
					string tileid = nmm_currtile.netname;
					nmm_currtile = world; 
					while ( !nmm_currtile )
					{
						tileid = minigame_relative_tile(tileid,-1,0,7,7);
						nmm_currtile = nmm_get_tile(tileid);
					}
				}
				return 1;
			case K_UPARROW:
			case K_KP_UPARROW:
				if ( ! nmm_currtile )
					nmm_currtile = nmm_get_tile("a1");
				else
				{
					string tileid = nmm_currtile.netname;
					nmm_currtile = world; 
					while ( !nmm_currtile )
					{
						tileid = minigame_relative_tile(tileid,0,1,7,7);
						nmm_currtile = nmm_get_tile(tileid);
					}
				}
				return 1;
			case K_DOWNARROW:
			case K_KP_DOWNARROW:
				if ( ! nmm_currtile )
					nmm_currtile = nmm_get_tile("a7");
				else
				{
					string tileid = nmm_currtile.netname;
					nmm_currtile = world; 
					while ( !nmm_currtile )
					{
						tileid = minigame_relative_tile(tileid,0,-1,7,7);
						nmm_currtile = nmm_get_tile(tileid);
					}
				}
				return 1;
			case K_ENTER:
			case K_KP_ENTER:
				nmm_make_move();
				return 1;
		}
		return 0;
	}
	else if ( event == "mouse_pressed" && count > 0 && ...(0,float) == K_MOUSE1 )
	{
		nmm_make_move();
	}
	else if ( event == "mouse_moved" )
	{
		nmm_currtile = world;
		vector tile_pos;
		vector tile_size = minigame_hud_denormalize_size('1 1 0'/7,nmm_boardpos,nmm_boardsize);
		entity e;
		FOREACH_MINIGAME_ENTITY(e)
		{
			if ( e.classname == "minigame_nmm_tile" )
			{
				tile_pos = minigame_hud_denormalize(e.origin,nmm_boardpos,nmm_boardsize)-tile_size/2;
				if ( minigame_hud_mouse_in(tile_pos, tile_size) )
				{
					nmm_currtile = e;
					break;
				}
			}
		}
		return 1;
	}
	
	return 0;
}

#endif 
