
const float NMM_TURN_PLACE = 0x0100; // player has to place a piece on the board
const float NMM_TURN_MOVE  = 0x0200; // player has to move a piece by one tile
const float NMM_TURN_FLY   = 0x0400; // player has to move a piece anywhere
const float NMM_TURN_TAKE  = 0x0800; // player has to take a non-mill piece
const float NMM_TURN_TAKEANY=0x1000; // combine with NMM_TURN_TAKE, can take mill pieces
const float NMM_TURN_WIN   = 0x2000; // player has won
const float NMM_TURN_TYPE  = 0xff00;
const float NMM_TURN_TEAM1 = 0x0001;
const float NMM_TURN_TEAM2 = 0x0002;
const float NMM_TURN_TEAM  = 0x00ff;

const float NMM_PIECE_DEAD  = 0x0; // captured by the enemy
const float NMM_PIECE_HOME  = 0x1; // not yet placed
const float NMM_PIECE_BOARD = 0x2; // placed on the board

.float  nmm_tile_distance;
.entity nmm_tile_piece;
.string nmm_tile_hmill;
.string nmm_tile_vmill;

// build a string containing the indices of the tile to check for a horizontal mill
string nmm_tile_build_hmill(entity tile)
{
	float number = minigame_tile_number(tile.netname);
	float letter = minigame_tile_letter(tile.netname);
	if ( number == letter || number+letter == 6 )
	{
		float add = letter < 3 ? 1 : -1;
		return strcat(tile.netname," ",
			minigame_tile_buildname(letter+add*tile.nmm_tile_distance,number)," ",
			minigame_tile_buildname(letter+add*2*tile.nmm_tile_distance,number) );
	}
	else if ( letter == 3 )
		return strcat(minigame_tile_buildname(letter-tile.nmm_tile_distance,number)," ",
			tile.netname," ",
			minigame_tile_buildname(letter+tile.nmm_tile_distance,number) );
	else if ( letter < 3 )
		return strcat(minigame_tile_buildname(0,number)," ",
			minigame_tile_buildname(1,number)," ",
			minigame_tile_buildname(2,number) );
	else
		return strcat(minigame_tile_buildname(4,number)," ",
			minigame_tile_buildname(5,number)," ",
			minigame_tile_buildname(6,number) );
}

// build a string containing the indices of the tile to check for a vertical mill
string nmm_tile_build_vmill(entity tile)
{
	float letter = minigame_tile_letter(tile.netname);
	float number = minigame_tile_number(tile.netname);
	if ( letter == number || letter+number == 6 )
	{
		float add = number < 3 ? 1 : -1;
		return strcat(tile.netname," ",
			minigame_tile_buildname(letter,number+add*tile.nmm_tile_distance)," ",
			minigame_tile_buildname(letter,number+add*2*tile.nmm_tile_distance) );
	}
	else if ( number == 3 )
		return strcat(minigame_tile_buildname(letter,number-tile.nmm_tile_distance)," ",
			tile.netname," ",
			minigame_tile_buildname(letter,number+tile.nmm_tile_distance) );
	else if ( number < 3 )
		return strcat(minigame_tile_buildname(letter,0)," ",
			minigame_tile_buildname(letter,1)," ",
			minigame_tile_buildname(letter,2) );
	else
		return strcat(minigame_tile_buildname(letter,4)," ",
			minigame_tile_buildname(letter,5)," ",
			minigame_tile_buildname(letter,6) );
}

// Create an new tile
// \param id       Tile index (eg: a1)
// \param minig    Owner minigame instance 
// \param distance Distance from adjacent tiles
void nmm_spawn_tile(string id, entity minig, float distance)
{
	// TODO global variable + list_next for simpler tile loops
	entity e = spawn();
	e.origin = minigame_tile_pos(id,7,7);
	e.classname = "minigame_nmm_tile";
	e.netname = id;
	e.owner = minig;
	e.team = 0;
	e.nmm_tile_distance = distance;
	e.nmm_tile_hmill = strzone(nmm_tile_build_hmill(e));
	e.nmm_tile_vmill = strzone(nmm_tile_build_vmill(e));
}

// Create a tile square and recursively create inner squares
// \param minig    Owner minigame instance 
// \param offset   Index offset (eg: 1 to start the square at b2, 0 at a1 etc.)
// \param skip     Number of indices to skip between tiles (eg 1: a1, a3)
void nmm_spawn_tile_square( entity minig, float offset, float skip )
{
	float letter = offset;
	float number = offset;
	float i, j;
	for ( i = 0; i < 3; i++ )
	{
		number = offset;
		for ( j = 0; j < 3; j++ )
		{
			if ( i != 1 || j != 1 )
				nmm_spawn_tile(strzone(minigame_tile_buildname(letter,number)),minig, skip+1);
			number += skip+1;
		}
		letter += skip+1;
	}
	
	if ( skip > 0 )
		nmm_spawn_tile_square(minig,offset+1,skip-1);
}

// Remove tiles of a NMM minigame
void nmm_kill_tiles(entity minig)
{
	entity e = world;
	while ( ( e = findentity(e,owner,minig) ) )
		if ( e.classname == "minigame_nmm_tile" )
		{
			strunzone(e.netname);
			strunzone(e.nmm_tile_hmill);
			strunzone(e.nmm_tile_vmill);
			remove(e);
		}
}

// Create the tiles of a NMM minigame
void nmm_init_tiles(entity minig)
{
	nmm_spawn_tile_square(minig,0,2);
}

// Find a tile by its id
entity nmm_find_tile(entity minig, string id)
{
	entity e = world;
	while ( ( e = findentity(e,owner,minig) ) )
		if ( e.classname == "minigame_nmm_tile" && e.netname == id )
			return e;
	return world;
}

// Check whether two tiles are adjacent
float nmm_tile_adjacent(entity tile1, entity tile2)
{
		
	float dnumber = fabs ( minigame_tile_number(tile1.netname) - minigame_tile_number(tile2.netname) );
	float dletter = fabs ( minigame_tile_letter(tile1.netname) - minigame_tile_letter(tile2.netname) );
	
	return ( dnumber == 0 && ( dletter == 1 || dletter == tile1.nmm_tile_distance ) ) ||
		( dletter == 0 && ( dnumber == 1 || dnumber == tile1.nmm_tile_distance ) );
}

// Returns 1 if there is at least 1 free adjacent tile
float nmm_tile_canmove(entity tile)
{
	entity e = world;
	while ( ( e = findentity(e,owner,tile.owner) ) )
		if ( e.classname == "minigame_nmm_tile" && !e.nmm_tile_piece 
				&& nmm_tile_adjacent(e,tile) )
		{
			return 1;
		}
	return 0;
}

// Check if the given tile id appears in the string
float nmm_in_mill_string(entity tile, string s)
{
	float argc = tokenize(s);
	float i;
	for ( i = 0; i < argc; i++ )
	{
		entity e = nmm_find_tile(tile.owner,argv(i));
		if ( !e || !e.nmm_tile_piece || e.nmm_tile_piece.team != tile.nmm_tile_piece.team )
			return 0;
	}
	return 1;
}

// Check if a tile is in a mill
float nmm_in_mill(entity tile)
{
	return tile.nmm_tile_piece &&  ( 
		nmm_in_mill_string(tile,tile.nmm_tile_hmill) ||
		nmm_in_mill_string(tile,tile.nmm_tile_vmill) );
}


#ifdef SVQC
// Find a NMM piece matching some of the given flags and team number
entity nmm_find_piece(entity start, entity minigame, float teamn, float pieceflags)
{
	entity e = start;
	while ( ( e = findentity(e,owner,minigame) ) )
		if ( e.classname == "minigame_board_piece" && 
				(e.minigame_flags & pieceflags) && e.team == teamn )
			return e;
	return world;
}

// Count NMM pieces matching flags and team number
float nmm_count_pieces(entity minigame, float teamn, float pieceflags)
{
	float n = 0;
	entity e = world;
	while (( e = nmm_find_piece(e,minigame, teamn, pieceflags) ))
		n++;
	return n;
}

// required function, handle server side events
float minigame_event_nmm(entity minigame, string event, ...)
{
	switch(event)
	{
		case "start":
		{
			minigame.minigame_flags = NMM_TURN_PLACE|NMM_TURN_TEAM1;
			nmm_init_tiles(minigame);
			float i;
			entity e;
			for ( i = 0; i < 7; i++ )
			{
				e = minigame_spawn_linked_entity(minigame,"minigame_board_piece");
				e.team = 1;
				e.minigame_flags = NMM_PIECE_HOME;
				e = minigame_spawn_linked_entity(minigame,"minigame_board_piece");
				e.team = 2;
				e.minigame_flags = NMM_PIECE_HOME;
			}

			return TRUE;
		}
		case "end":
		{
			nmm_kill_tiles(minigame);
			return FALSE;
		}
		case "join":
		{
			float n = 0;
			entity e;
			for ( e = minigame.minigame_players; e; e = e.list_next )
				n++;
			if ( n >= 2 )
				return 0;
			if ( minigame.minigame_players && minigame.minigame_players.team == 1 )
				return 2;
			return 1;
		}
		case "cmd":
		{
			entity e = ...(0,entity);
			float argc = ...(1,float);
			entity tile = world;
			entity piece = world;
			float move_ok = 0;
			
			if ( e && argc >= 2 && argv(0) == "move" && 
				( minigame.minigame_flags & NMM_TURN_TEAM ) == e.team )
			{
				tile = nmm_find_tile(minigame,argv(1));
				if ( !tile )
				{
					move_ok = 0;
				}
				else if ( minigame.minigame_flags & NMM_TURN_PLACE )
				{
					piece = nmm_find_piece(world,minigame,e.team,NMM_PIECE_HOME);
					if ( !tile.nmm_tile_piece && piece )
					{
						tile.nmm_tile_piece = piece;
						piece.minigame_flags = NMM_PIECE_BOARD;
						piece.origin = tile.origin;
						piece.SendFlags |= MINIG_SF_UPDATE;
						move_ok = 1;
					}
				}
				else if ( minigame.minigame_flags & NMM_TURN_MOVE )
				{
					if ( tile.nmm_tile_piece && tile.nmm_tile_piece.team == e.team )
					{
						piece = tile.nmm_tile_piece;
						entity tile2 = nmm_find_tile(minigame,argv(2));
						if ( tile2 && nmm_tile_adjacent(tile,tile2) && !tile2.nmm_tile_piece )
						{
							tile.nmm_tile_piece = world;
							tile2.nmm_tile_piece = piece;
							piece.origin = tile2.origin;
							piece.SendFlags |= MINIG_SF_UPDATE;
							tile = tile2;
							move_ok = 1;
						}
					}
					
				}
				else if ( minigame.minigame_flags & NMM_TURN_FLY )
				{
					if ( tile.nmm_tile_piece && tile.nmm_tile_piece.team == e.team )
					{
						piece = tile.nmm_tile_piece;
						entity tile2 = nmm_find_tile(minigame,argv(2));
						if ( tile2 && !tile2.nmm_tile_piece )
						{
							tile.nmm_tile_piece = world;
							tile2.nmm_tile_piece = piece;
							piece.origin = tile2.origin;
							piece.SendFlags |= MINIG_SF_UPDATE;
							tile = tile2;
							move_ok = 1;
						}
					}
					
				}
				else if ( minigame.minigame_flags & NMM_TURN_TAKE )
				{
					piece = tile.nmm_tile_piece;
					if ( piece && piece.nmm_tile_piece.team != e.team )
					{
						tile.nmm_tile_piece = world;
						piece.minigame_flags = NMM_PIECE_DEAD;
						piece.SendFlags |= MINIG_SF_UPDATE;
						move_ok = 1;
					}
				}
				
				float nextteam = e.team % 2 + 1;
				float npieces = nmm_count_pieces(minigame,nextteam,NMM_PIECE_HOME|NMM_PIECE_BOARD);
				
				if ( npieces < 3 )
				{
					minigame.minigame_flags = NMM_TURN_WIN | e.team;
					minigame.SendFlags |= MINIG_SF_UPDATE;
				}
				else if ( move_ok)
				{
					if ( !(minigame.minigame_flags & NMM_TURN_TAKE) && nmm_in_mill(tile) )
					{
						minigame.minigame_flags = NMM_TURN_TAKE|e.team;
						float takemill = NMM_TURN_TAKEANY;
						entity f = world;
						while ( ( f = findentity(f,owner,minigame) ) )
							if ( f.classname == "minigame_nmm_tile" && f.nmm_tile_piece  &&
									f.nmm_tile_piece.team == nextteam && !nmm_in_mill(f) )
							{
								takemill = 0;
								break;
							}
						minigame.minigame_flags |= takemill;
					}
					else
					{
						if ( nmm_find_piece(world,minigame,nextteam,NMM_PIECE_HOME) )
							minigame.minigame_flags = NMM_TURN_PLACE|nextteam;
						else if ( npieces == 3 )
							minigame.minigame_flags = NMM_TURN_FLY|nextteam;
						else
						{
							minigame.minigame_flags = NMM_TURN_WIN|e.team;
							entity f = world;
							while ( ( f = findentity(f,owner,minigame) ) )
								if ( f.classname == "minigame_nmm_tile" && f.nmm_tile_piece  &&
									f.nmm_tile_piece.team == nextteam && nmm_tile_canmove(f) )
								{
									minigame.minigame_flags = NMM_TURN_MOVE|nextteam;
									break;
								}
						}
					}
					minigame.SendFlags |= MINIG_SF_UPDATE;
				}
				else
					dprint("Invalid move: ",...(2,string),"\n");

				return TRUE;
			}
		}
	}

	return FALSE;
}

#elif defined(CSQC)

entity nmm_currtile;
entity nmm_fromtile;

vector nmm_boardpos;
vector nmm_boardsize;

// whether the given tile is a valid selection
float nmm_valid_selection(entity tile)
{
	if ( ( tile.owner.minigame_flags & NMM_TURN_TEAM ) != minigame_self.team )
		return 0; // not our turn
	if ( tile.owner.minigame_flags & NMM_TURN_PLACE )
		return !tile.nmm_tile_piece; // need to put a piece on an empty spot
	if ( tile.owner.minigame_flags & NMM_TURN_MOVE )
	{
		if ( tile.nmm_tile_piece && tile.nmm_tile_piece.team == minigame_self.team &&
				nmm_tile_canmove(tile) )
			return 1; //  movable tile
		if ( nmm_fromtile ) // valid destination
			return !tile.nmm_tile_piece && nmm_tile_adjacent(nmm_fromtile,tile);
		return 0;
	}
	if ( tile.owner.minigame_flags & NMM_TURN_FLY )
	{
		if ( nmm_fromtile )
			return !tile.nmm_tile_piece;
		else
			return tile.nmm_tile_piece && tile.nmm_tile_piece.team == minigame_self.team;
	}
	if ( tile.owner.minigame_flags & NMM_TURN_TAKE )
		return tile.nmm_tile_piece && tile.nmm_tile_piece.team != minigame_self.team &&
			( (tile.owner.minigame_flags & NMM_TURN_TAKEANY) || !nmm_in_mill(tile) );
	return 0;
}

// whether it should highlight valid tile selections
float nmm_draw_avaliable(entity tile)
{
	if ( ( tile.owner.minigame_flags & NMM_TURN_TEAM ) != minigame_self.team )
		return 0;
	if ( (tile.owner.minigame_flags & NMM_TURN_TAKE) )
		return 1;
	if ( (tile.owner.minigame_flags & (NMM_TURN_FLY|NMM_TURN_MOVE)) && nmm_fromtile )
		return !tile.nmm_tile_piece;
	return 0;
}

// Required function, draw the game board
void minigame_hud_board_nmm(vector pos, vector mySize)
{
	minigame_hud_fitsqare(pos, mySize);
	nmm_boardpos = pos;
	nmm_boardsize = mySize;
	minigame_hud_simpleboard(pos,mySize,minigame_texture("nmm/board"));
	
	vector tile_size = minigame_hud_denormalize_size('1 1 0'/7,pos,mySize);
	vector tile_pos;
	entity e;
	FOREACH_MINIGAME_ENTITY(e)
	{
		if ( e.classname == "minigame_nmm_tile" )
		{
			tile_pos = minigame_hud_denormalize(e.origin,pos,mySize);
			
			if ( e == nmm_fromtile )
			{
				minigame_drawpic_centered( tile_pos, minigame_texture("nmm/tile_active"),
					tile_size, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL );
			}
			else if ( nmm_draw_avaliable(e) && nmm_valid_selection(e) )
			{
				minigame_drawpic_centered( tile_pos, minigame_texture("nmm/tile_available"),
					tile_size, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL );
			}
			
			if ( e == nmm_currtile )
			{
				minigame_drawpic_centered( tile_pos, minigame_texture("nmm/tile_selected"),
					tile_size, '1 1 1', panel_fg_alpha, DRAWFLAG_ADDITIVE );
			}
			
			if ( e.nmm_tile_piece )
			{
				minigame_drawpic_centered( tile_pos,  
					minigame_texture(strcat("nmm/piece",ftos(e.nmm_tile_piece.team))),
					tile_size*0.8, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL );
			}
			
			//drawstring(tile_pos, e.netname, hud_fontsize, '1 0 0', 1, DRAWFLAG_NORMAL);
		}
	}
	
	if ( active_minigame.minigame_flags & NMM_TURN_WIN )
	{
		vector winfs = hud_fontsize*2;
		string playername = "";
		FOREACH_MINIGAME_ENTITY(e)
			if ( e.classname == "minigame_player" && 
					e.team == (active_minigame.minigame_flags & NMM_TURN_TEAM) )
				playername = GetPlayerName(e.minigame_playerslot-1);
		
		vector win_pos = pos+eY*(mySize_y-winfs_y)/2;
		vector win_sz;
		win_sz = minigame_drawcolorcodedstring_wrapped(mySize_x,win_pos,
			sprintf("%s^7 won the game!",playername), 
			winfs, 0, DRAWFLAG_NORMAL, 0.5);
		
		drawfill(win_pos-eY*hud_fontsize_y,win_sz+2*eY*hud_fontsize_y,'1 1 1',0.5,DRAWFLAG_ADDITIVE);
		
		minigame_drawcolorcodedstring_wrapped(mySize_x,win_pos,
			sprintf("%s^7 won the game!",playername), 
			winfs, panel_fg_alpha, DRAWFLAG_NORMAL, 0.5);
	}
}

// Required function, draw the game status panel
void minigame_hud_status_nmm(vector pos, vector mySize)
{
	HUD_Panel_DrawBg(1);
	vector ts;
	
	ts = minigame_drawstring_wrapped(mySize_x,pos,active_minigame.descriptor.message,
		hud_fontsize * 2, '0.25 0.47 0.72', panel_fg_alpha, DRAWFLAG_NORMAL,0.5);
	pos_y += ts_y;
	mySize_y -= ts_y;
	
	vector player_fontsize = hud_fontsize * 1.75;
	ts_y = ( mySize_y - 2*player_fontsize_y ) / 2;
	ts_x = mySize_x;
	
	float player1x = 0;
	float player2x = 0;
	vector piece_sz = '48 48 0';
	float piece_space = piece_sz_x + ( ts_x - 7 * piece_sz_x ) / 6;
	vector mypos;
	float piece_light = 1;
	entity e = world;
	
	mypos = pos;
	if ( (active_minigame.minigame_flags&NMM_TURN_TEAM) == 2 )
		mypos_y  += player_fontsize_y + ts_y;
	drawfill(mypos,eX*mySize_x+eY*player_fontsize_y,'1 1 1',0.5,DRAWFLAG_ADDITIVE);
	mypos_y += player_fontsize_y;
	drawfill(mypos,eX*mySize_x+eY*piece_sz_y,'1 1 1',0.25,DRAWFLAG_ADDITIVE);
	
	FOREACH_MINIGAME_ENTITY(e)
	{
		if ( e.classname == "minigame_player" )
		{
			mypos = pos;
			if ( e.team == 2 )
				mypos_y  += player_fontsize_y + ts_y;
			minigame_drawcolorcodedstring_trunc(mySize_x,mypos,
				GetPlayerName(e.minigame_playerslot-1),
				player_fontsize, panel_fg_alpha, DRAWFLAG_NORMAL);
		}
		else if ( e.classname == "minigame_board_piece" )
		{
			mypos = pos;
			mypos_y += player_fontsize_y;
			if ( e.team == 2 )
			{
				mypos_x += player2x;
				player2x += piece_space;
				mypos_y  += player_fontsize_y + ts_y;
			}
			else
			{
				mypos_x += player1x;
				player1x += piece_space;
			}
			if ( e.minigame_flags == NMM_PIECE_HOME )
				piece_light = 0.5;
			else if ( e.minigame_flags == NMM_PIECE_BOARD )
				piece_light = 1;
			else
				piece_light = 0.15;
			
			drawpic(mypos, minigame_texture(strcat("nmm/piece",ftos(e.team))), piece_sz,
				'1 1 1'*piece_light, panel_fg_alpha, DRAWFLAG_NORMAL );
		}
	}
}

// Make the correct move
void nmm_make_move(entity minigame)
{
	if ( nmm_currtile )
	{
		if ( minigame.minigame_flags & (NMM_TURN_PLACE|NMM_TURN_TAKE) )
		{
			minigame_cmd("move ",nmm_currtile.netname);
			nmm_fromtile = world;
		}
		else if ( (minigame.minigame_flags & (NMM_TURN_MOVE|NMM_TURN_FLY)) )
		{
			if ( nmm_fromtile == nmm_currtile )
			{
				nmm_fromtile = world;
			}
			else if ( nmm_currtile.nmm_tile_piece && nmm_currtile.nmm_tile_piece.team == minigame_self.team )
			{
				nmm_fromtile = nmm_currtile;
			}
			else if ( nmm_fromtile )
			{
				minigame_cmd("move ",nmm_fromtile.netname," ",nmm_currtile.netname);
				nmm_fromtile = world;
			}
		}
	}
	else
		nmm_fromtile = world;
}

string nmm_turn_to_string(float turnflags)
{
	if ( turnflags & NMM_TURN_WIN )
	{
		if ( (turnflags&NMM_TURN_TEAM) != minigame_self.team )
			return _("You lost the game!");
		return _("You win!");
	}
	
	if ( (turnflags&NMM_TURN_TEAM) != minigame_self.team )
		return _("Wait for your opponent to make their move");
	if ( turnflags & NMM_TURN_PLACE )
		return _("Click on the game board to place your piece");
	if ( turnflags & NMM_TURN_MOVE )
		return _("You can select one of your pieces to move it in one of the surrounding places");
	if ( turnflags & NMM_TURN_FLY )
		return _("You can select one of your pieces to move it anywhere on the board");
	if ( turnflags & NMM_TURN_TAKE )
		return _("You can take one of the opponent's pieces");
	
	return "";
}

// Required function, handle client events
float minigame_event_nmm(entity minigame, string event, ...)
{
	switch(event)
	{
		case "activate":
		{
			nmm_fromtile = world;
			nmm_init_tiles(minigame);
			minigame.message = nmm_turn_to_string(minigame.minigame_flags);
			return FALSE;
		}
		case "deactivate":
		{
			nmm_fromtile = world;
			nmm_kill_tiles(minigame);
			return FALSE;
		}
		case "key_pressed":
		{
			if((minigame.minigame_flags & NMM_TURN_TEAM) == minigame_self.team)
			{
				switch ( ...(0,float) )
				{
					case K_RIGHTARROW:
					case K_KP_RIGHTARROW:
						if ( ! nmm_currtile )
							nmm_currtile = nmm_find_tile(active_minigame,"a7");
						else
						{
							string tileid = nmm_currtile.netname;
							nmm_currtile = world; 
							while ( !nmm_currtile )
							{
								tileid = minigame_relative_tile(tileid,1,0,7,7);
								nmm_currtile = nmm_find_tile(active_minigame,tileid);
							}
						}
						return TRUE;
					case K_LEFTARROW:
					case K_KP_LEFTARROW:
						if ( ! nmm_currtile )
							nmm_currtile = nmm_find_tile(active_minigame,"g7");
						else
						{
							string tileid = nmm_currtile.netname;
							nmm_currtile = world; 
							while ( !nmm_currtile )
							{
								tileid = minigame_relative_tile(tileid,-1,0,7,7);
								nmm_currtile = nmm_find_tile(active_minigame,tileid);
							}
						}
						return TRUE;
					case K_UPARROW:
					case K_KP_UPARROW:
						if ( ! nmm_currtile )
							nmm_currtile = nmm_find_tile(active_minigame,"a1");
						else
						{
							string tileid = nmm_currtile.netname;
							nmm_currtile = world; 
							while ( !nmm_currtile )
							{
								tileid = minigame_relative_tile(tileid,0,1,7,7);
								nmm_currtile = nmm_find_tile(active_minigame,tileid);
							}
						}
						return TRUE;
					case K_DOWNARROW:
					case K_KP_DOWNARROW:
						if ( ! nmm_currtile )
							nmm_currtile = nmm_find_tile(active_minigame,"a7");
						else
						{
							string tileid = nmm_currtile.netname;
							nmm_currtile = world; 
							while ( !nmm_currtile )
							{
								tileid = minigame_relative_tile(tileid,0,-1,7,7);
								nmm_currtile = nmm_find_tile(active_minigame,tileid);
							}
						}
						return TRUE;
					case K_ENTER:
					case K_KP_ENTER:
					case K_SPACE:
						nmm_make_move(minigame);
						return TRUE;
				}
			}

			return FALSE;
		}
		case "mouse_pressed":
		{
			if(...(0,float) == K_MOUSE1)
			{
				nmm_make_move(minigame);
				return TRUE;
			}

			return FALSE;
		}
		case "mouse_moved":
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
					if ( minigame_hud_mouse_in(tile_pos, tile_size) && nmm_valid_selection(e) )
					{
						nmm_currtile = e;
						break;
					}
				}
			}

			return TRUE;
		}
		case "network_receieve":
		{
			if ( self.classname == "minigame_board_piece" && ( ...(1,float) & MINIG_SF_UPDATE ) )
			{
				entity e;
				string tileid = "";
				if ( self.minigame_flags & NMM_PIECE_BOARD )
					tileid = minigame_tile_name(self.origin,7,7);
				FOREACH_MINIGAME_ENTITY(e)
				{
					if ( e.classname == "minigame_nmm_tile" )
					{
						if ( e.nmm_tile_piece == self )
							e.nmm_tile_piece = world;
						if ( e.netname == tileid )
							e.nmm_tile_piece = self;
					}
				}
			}
			else if ( self.classname == "minigame" && ( ...(1,float) & MINIG_SF_UPDATE ) ) 
			{
				self.message = nmm_turn_to_string(self.minigame_flags);
				if ( self.minigame_flags & minigame_self.team )
					minigame_prompt();
			}

			return FALSE;
		}
	}

	return FALSE;
}

#endif 
