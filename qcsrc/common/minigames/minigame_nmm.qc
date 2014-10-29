
const float NMM_TURN_PLACE = 0x0100;
const float NMM_TURN_MOVE  = 0x0200;
const float NMM_TURN_FLY   = 0x0400;
const float NMM_TURN_TAKE  = 0x0800;
const float NMM_TURN_WIN   = 0x1000;
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


void nmm_spawn_tile(string id, entity minig, float distance)
{
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

void nmm_spawn_tile_sqaure( entity minig, float offset, float skip )
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
		nmm_spawn_tile_sqaure(minig,offset+1,skip-1);
}

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

void nmm_init_tiles(entity minig)
{
	nmm_spawn_tile_sqaure(minig,0,2);
}

entity nmm_find_tile(entity minig, string id)
{
	entity e = world;
	while ( ( e = findentity(e,owner,minig) ) )
		if ( e.classname == "minigame_nmm_tile" && e.netname == id )
			return e;
	return world;
}

// check whether two tiles are adjacent
float nmm_tile_adjacent(entity tile1, entity tile2)
{
		
	float dnumber = fabs ( minigame_tile_number(tile1.netname) - minigame_tile_number(tile2.netname) );
	float dletter = fabs ( minigame_tile_letter(tile1.netname) - minigame_tile_letter(tile2.netname) );
	
	return ( dnumber == 0 && ( dletter == 1 || dletter == tile1.nmm_tile_distance ) ) ||
		( dletter == 0 && ( dnumber == 1 || dnumber == tile1.nmm_tile_distance ) );
}

// returns 1 if there is at least 1 free adjacent tile
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

entity nmm_find_piece(entity start, entity minigame, float teamn, float pieceflags)
{
	entity e = start;
	while ( ( e = findentity(e,owner,minigame) ) )
		if ( e.classname == "minigame_board_piece" && 
				(e.minigame_flags & pieceflags) && e.team == teamn )
			return e;
	return world;
}

float nmm_count_pieces(entity minigame, float teamn, float pieceflags)
{
	float n = 0;
	entity e = world;
	while (( e = nmm_find_piece(e,minigame, teamn, pieceflags) ))
		n++;
	return n;
}

float minigame_event_nmm(entity minigame, string event, ...count)
{
	if ( event == "start" )
	{
		minigame.minigame_flags = NMM_TURN_PLACE|NMM_TURN_TEAM1;
		nmm_init_tiles(minigame);
		float i;
		entity e;
		for ( i = 0; i < 7; i++ )
		{
			e = minigame_spawn_board_piece(minigame);
			e.team = 1;
			e.minigame_flags = NMM_PIECE_HOME;
			e = minigame_spawn_board_piece(minigame);
			e.team = 2;
			e.minigame_flags = NMM_PIECE_HOME;
		}
			
		return 1;
	}
	else if ( event == "end" )
	{
		nmm_kill_tiles(minigame);
	}
	else if ( event == "join" )
	{
		float n = 0;
		entity e;
		for ( e = minigame.minigame_players; e; e = e.chain )
			n++;
		if ( n >= 2 )
			return 0;
		if ( minigame.minigame_players && minigame.minigame_players.team == 1 )
			return 2;
		return 1;
	}
	else if ( event == "cmd" && count >= 2 )
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
			
			float npieces = nmm_count_pieces(minigame,e.team % 2 + 1,NMM_PIECE_HOME|NMM_PIECE_BOARD);
			
			// TODO check win ( no valid moves )
			
			if ( npieces < 3 )
			{
				minigame.minigame_flags = NMM_TURN_WIN | e.team;
				minigame.SendFlags |= MINIG_SF_UPDATE;
			}
			else if ( move_ok)
			{
				float nextteam = e.team;
				if ( !(minigame.minigame_flags & NMM_TURN_TAKE) && nmm_in_mill(tile) )
				{
					minigame.minigame_flags = NMM_TURN_TAKE;
				}
				else
				{
					nextteam = nextteam % 2 + 1;
					if ( nmm_find_piece(world,minigame,nextteam,NMM_PIECE_HOME) )
						minigame.minigame_flags = NMM_TURN_PLACE;
					else if ( npieces == 3 )
						minigame.minigame_flags = NMM_TURN_FLY;
					else
						minigame.minigame_flags = NMM_TURN_MOVE;
				}
				minigame.minigame_flags |= nextteam;
				minigame.SendFlags |= MINIG_SF_UPDATE;
			}
			else
				dprint("Invalid move: ",...(2,string),"\n");
			return 1;
		}
	}
	return 0;
}

#elif defined(CSQC)

entity nmm_currtile;
entity nmm_fromtile;

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
			else if ( nmm_fromtile && !e.nmm_tile_piece  )
			{
				if ( (e.owner.minigame_flags & NMM_TURN_FLY) || nmm_tile_adjacent(e,nmm_fromtile) )
					minigame_drawpic_centered( tile_pos, minigame_texture("nmm/tile_available"),
						tile_size, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL );
			}
			else if ( e.owner.minigame_flags == (NMM_TURN_TAKE|minigame_self.team) && 
				e.nmm_tile_piece &&
				e.nmm_tile_piece.team != minigame_self.team && !nmm_in_mill(e) )
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
		minigame_drawcolorcodedstring_wrapped(mySize_x,pos+eY*(mySize_y-winfs_y)/2,
			sprintf("%s^7 won the game!",playername), winfs, panel_fg_alpha, 
			DRAWFLAG_NORMAL, 0.5);
	}
}

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
			!nmm_in_mill(tile);
	return 0;
}

void nmm_make_move(entity minigame)
{
	if ( nmm_currtile )
	{
		if ( minigame.minigame_flags & (NMM_TURN_PLACE|NMM_TURN_TAKE) )
		{
			localcmd("cmd minigame move ",nmm_currtile.netname,"\n");
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
				localcmd("cmd minigame move ",nmm_fromtile.netname," ",nmm_currtile.netname,"\n");
				nmm_fromtile = world;
			}
		}
	}
	else
		nmm_fromtile = world;
}

float minigame_event_nmm(entity minigame, string event, ...count)
{
	if ( event == "activate" )
	{
		nmm_init_tiles(minigame);
	}
	else if ( event == "deactivate" )
	{
		nmm_kill_tiles(minigame);
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
				nmm_make_move(minigame);
				return 1;
		}
		return 0;
	}
	else if ( event == "mouse_pressed" && count > 0 && ...(0,float) == K_MOUSE1 )
	{
		nmm_make_move(minigame);
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
				if ( minigame_hud_mouse_in(tile_pos, tile_size) && nmm_valid_selection(e) )
				{
					nmm_currtile = e;
					break;
				}
			}
		}
		return 1;
	}
	else if ( event == "network_receive" )
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
	}
	
	return 0;
}

#endif 
