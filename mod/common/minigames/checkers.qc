REGISTER_MINIGAME(checkers, "Checkers");

const float CHECKERS_TURN_MOVE  = 0x0100; // player has to click on a piece on the board
const float CHECKERS_TURN_WIN   = 0x0200; // player has won
const float CHECKERS_TURN_DRAW  = 0x0400; // player can make no more moves
const float CHECKERS_TURN_TYPE  = 0x0f00; // turn type mask

const float CHECKERS_TURN_TEAM1 = 0x0001;
const float CHECKERS_TURN_TEAM2 = 0x0002;
const float CHECKERS_TURN_TEAM  = 0x000f; // turn team mask

const int CHECKERS_LET_CNT = 8;
const int CHECKERS_NUM_CNT = 8;

const int CHECKERS_TILE_SIZE = 8;

const int CHECKERS_TEAMS = 2;
const int CHECKERS_SPECTATOR_TEAM = 255; // must be above max teams and equal to or below 255

const int CHECKERS_FINE = 0;
const int CHECKERS_CHECK = 1;
const int CHECKERS_CHECKMATE = 2;

.int checkers_id;

.int cnt; // indicator for the currently forced piece

.bool checkers_forcemove;

.int checkers_nexteam;

#define checkers_board_pieces(X) \
	X(Empty     ,   " ")    \
	X(Pawn      ,   "P")    \
	X(King      ,   "X")    \
	/**/

#ifdef CSQC
#define lambda(name, shortname) shortname,
string checkers_piece_name[] = {checkers_board_pieces(lambda)};
#undef lambda
#endif

enum {
#define lambda(name, shortname) checkers_piece__##name,
	checkers_board_pieces(lambda)
#undef lambda
};

//<editor-fold desc="Move">
#define checkers_responses(X) \
	X(NotYourTurn, "Not your turn") \
	X(Illegal, "Illegal move") \
	X(Obstructed, "Illegal move (piece in the way)") \
	X(Ok, "OK") \
	X(Promotion, "Promotion!") \
	/**/

enum {
#define lambda(id, text) checkers_response__##id,
	checkers_responses(lambda)
#undef lambda
};

#define CHECKERS_GOOD_MOVE(X) (X == checkers_response__Ok || X == checkers_response__Promotion)

entity checkers_find_piece(entity minig, string tile)
{
	entity e = NULL;
	while ( ( e = findentity(e,owner,minig) ) )
		if ( e.classname == "minigame_board_piece" && e.netname == tile )
			return e;
	return NULL;
}

// check if the tile name is valid (5x5 grid)
bool checkers_valid_tile(string tile)
{
	if ( !tile )
		return false;
	int number = minigame_tile_number(tile);
	int letter = minigame_tile_letter(tile);
	return 0 <= number && number < CHECKERS_NUM_CNT && 0 <= letter && letter < CHECKERS_LET_CNT;
}

bool checkers_nomoves(entity minigame, int pteam);
#define sgn(x) (x > 0 ? 1 : x < 0 ? -1 : 0)
int checkers_move_try(entity minigame, string thepiece, string pos, bool force_jump, entity ignore)
{
	entity p = checkers_find_piece(minigame, thepiece);
	entity to_p = checkers_find_piece(minigame, pos);
	if(to_p) return checkers_response__Obstructed;
	int t = p.team;
	int to_t = (to_p) ? to_p.team : 0;

	int fx = minigame_tile_letter(thepiece);
	int fy = minigame_tile_number(thepiece);

	int tx = minigame_tile_letter(pos);
	int ty = minigame_tile_number(pos);

	int dx = tx - fx, dy = ty - fy;
	if (!dx && !dy) return checkers_response__Illegal;

	int sx = sgn(dx), sy = sgn(dy); // direction
	int adx = fabs(dx), ady = fabs(dy); // difference

#define scan() do { \
	int x = fx, y = fy; \
	do { \
		x += sx, y += sy; \
		to_p = checkers_find_piece(minigame, minigame_tile_buildname(x, y)); \
		to_t = (to_p) ? to_p.team : 0; \
		bool last = x == tx && y == ty; \
		if (to_p && (last || t == to_t)) return checkers_response__Obstructed; \
	} while (!(x == tx && y == ty)); \
} while (0)
	switch (p.checkers_id) {
		case checkers_piece__Pawn:
		case checkers_piece__King: {
			const int dir = (t == 1) ? 1 : -1;
			if (sy != dir && p.checkers_id == checkers_piece__Pawn) return checkers_response__Illegal;
			if (adx != ady) return checkers_response__Illegal;
			if (adx > 2) return checkers_response__Illegal;
			if (force_jump && adx != 2) return checkers_response__Illegal;
			bool want_capture = (adx == 2 && ady == 2);
			if(want_capture)
			{
				int p_dir = 1; // default to right
				int y_dir = 1;
				if(sx == -1) p_dir = -1;
				if(sy == -1) y_dir = -1;
				to_p = checkers_find_piece(minigame, minigame_tile_buildname(fx + p_dir, fy + y_dir));
			}
			to_t = (to_p) ? to_p.team : 0;

			bool capture = want_capture && to_p && to_t != t;
			if (adx == 2 && !capture) return checkers_response__Illegal;
			if (to_p && !capture) return checkers_response__Obstructed;
			if (ty == ((t == 1) ? 7 : 0) && p.checkers_id != checkers_piece__King) return checkers_response__Promotion;
			break;
		}
		default:
			return checkers_response__Illegal;
	}
	return checkers_response__Ok;
#undef scan
}

// TODO: simplify
string checkers_tryallmoves(entity minigame, entity piece, bool force_jump)
{
	int i, j;
	for(i = 0; i < CHECKERS_NUM_CNT; ++i)
	for(j = 0; j < CHECKERS_LET_CNT; ++j)
	{
		string newpos = minigame_tile_buildname(j, i);
		if(newpos == piece.netname) continue;
		int r = checkers_move_try(minigame, piece.netname, newpos, force_jump, NULL);

		if(CHECKERS_GOOD_MOVE(r))
			return newpos;
	}

	return "";
}

bool checkers_nomoves(entity minigame, int pteam)
{
	int safe = 0;
	entity e = NULL;
	while ( ( e = findentity(e,owner,minigame) ) )
		if ( e.classname == "minigame_board_piece" )
		{
			if(e.team != pteam) continue;
			if(checkers_tryallmoves(minigame, e, false) != "")
				safe += 1;
		}
	return (safe <= 0);
}

bool checkers_move_piece(entity minigame, entity piece, string pos, int promote)
{
	if(!piece) { return false; }

	bool taken = false;

	entity thepiece = checkers_find_piece(minigame, pos);
	if(thepiece)
	{
		LOG_TRACE("Checkers: Trying to move a piece onto an existing piece, THIS SHOULD NOT HAPPEN!");
		return false;
	}

	int letter = minigame_tile_letter(piece.netname);
	int number = minigame_tile_number(piece.netname);

	int to_number = minigame_tile_number(pos);
	int to_letter = minigame_tile_letter(pos);

	thepiece = NULL;
	int ang = 0;
	if(number + 2 == to_number)
		ang = 1;
	else if(number - 2 == to_number)
		ang = -1;

	if(ang != 0) // wanted capture
	{
		int yang = 0;
		if(letter + 2 == to_letter)
			yang = 1;
		else if(letter - 2 == to_letter)
			yang = -1;
		string thepos = minigame_tile_buildname(letter + yang, number + ang);
		thepiece = checkers_find_piece(minigame, thepos);
		if(thepiece.team == piece.team)
			thepiece = NULL; // revert what we did, it's no use
	}

	if(thepiece)
	{
		taken = true;
		strfree(thepiece.netname);
		delete(thepiece);
	}

	FOREACH_ENTITY_ENT_ORDERED(owner, minigame,
	{
		if(it.classname != "minigame_board_piece") continue;
		if(it.checkers_id != checkers_piece__Pawn && it.checkers_id != checkers_piece__King) continue;
		minigame_server_sendflags(it,MINIG_SF_UPDATE);
	});

	strcpy(piece.netname, pos);
	piece.cnt = 0;
	if(promote)
		piece.checkers_id = promote;

	minigame_server_sendflags(piece,MINIG_SF_ALL);

	return taken;
}

int checkers_get_promotion_piece(string promote)
{
	return checkers_piece__King;
}

// make a move
void checkers_move(entity minigame, entity player, string thepiece, string pos, string promotion)
{
	if(minigame.minigame_flags & CHECKERS_TURN_MOVE)
	if(pos && player.team == (minigame.minigame_flags & CHECKERS_TURN_TEAM))
	if(checkers_valid_tile(pos) && checkers_find_piece(minigame, thepiece))
	{
		entity piece = checkers_find_piece(minigame, thepiece);
		if(minigame.checkers_forcemove && !piece.cnt)
			return;
		if(piece.team != player.team)
			return; // fail!

		int r = checkers_move_try(minigame, thepiece, pos, minigame.checkers_forcemove, NULL);
		int promote = checkers_piece__Empty;
		bool taken = false;

		switch (r)
		{
			default:
				return;
			case checkers_response__Promotion:
				promote = checkers_get_promotion_piece(promotion);
			case checkers_response__Ok:
				taken = checkers_move_piece(minigame, piece, pos, promote);
				break;
		}

		if(taken && checkers_tryallmoves(minigame, piece, true) != "")
		{
			// don't change teams! instead, we're going to force a piece to be the next to move
			minigame.checkers_forcemove = true;
			piece.cnt = 1;
		}
		else
		{
			minigame.checkers_forcemove = false;
			minigame.checkers_nexteam = minigame_next_team(player.team,CHECKERS_TEAMS);
		}

		int mypcount = 0, theirpcount = 0;
		FOREACH_ENTITY_ENT_ORDERED(owner, minigame,
		{
			if(it.classname != "minigame_board_piece") continue;
			if(it.team == player.team)
				++mypcount;
			else
				++theirpcount;
		});

		if(mypcount <= 0 && theirpcount <= 0) // if both sides have no actual pieces, it's a draw
			minigame.minigame_flags = CHECKERS_TURN_DRAW;
		else if(mypcount >= 1 && !theirpcount) // special rule: enemy has no pieces while we have some, call it a victory!
			minigame.minigame_flags = CHECKERS_TURN_WIN | player.team;
		else if(checkers_nomoves(minigame, minigame.chess_nexteam))
			minigame.minigame_flags = CHECKERS_TURN_WIN | player.team;
		else
			minigame.minigame_flags = CHECKERS_TURN_MOVE | minigame.checkers_nexteam;

		minigame_server_sendflags(minigame,MINIG_SF_UPDATE);
	}
}

void checkers_spawn_piece(entity minigame, string pos, int pteam, int pid)
{
	entity piece = msle_spawn(minigame,new(minigame_board_piece));
	piece.team = pteam;
	piece.checkers_id = pid;
	piece.netname = strzone(pos);
	minigame_server_sendflags(piece,MINIG_SF_ALL);
}

void checkers_setup_pieces(entity minigame)
{
	int i;
	// red team
	// row one
	for(i = 0; i < CHECKERS_LET_CNT; i += 2)
		checkers_spawn_piece(minigame, minigame_tile_buildname(i,0), 1, checkers_piece__Pawn);
	// row two
	for(i = 1; i < CHECKERS_LET_CNT; i += 2)
		checkers_spawn_piece(minigame, minigame_tile_buildname(i,1), 1, checkers_piece__Pawn);
	// row three
	for(i = 0; i < CHECKERS_LET_CNT; i += 2)
		checkers_spawn_piece(minigame, minigame_tile_buildname(i,2), 1, checkers_piece__Pawn);

	// blue team
	// row one
	for(i = 1; i < CHECKERS_LET_CNT; i += 2)
		checkers_spawn_piece(minigame, minigame_tile_buildname(i,5), 2, checkers_piece__Pawn);
	// row two
	for(i = 0; i < CHECKERS_LET_CNT; i += 2)
		checkers_spawn_piece(minigame, minigame_tile_buildname(i,6), 2, checkers_piece__Pawn);
	// row three
	for(i = 1; i < CHECKERS_LET_CNT; i += 2)
		checkers_spawn_piece(minigame, minigame_tile_buildname(i,7), 2, checkers_piece__Pawn);

	minigame_server_sendflags(minigame,MINIG_SF_UPDATE);
}

#ifdef SVQC


// required function, handle server side events
int checkers_server_event(entity minigame, string event, ...)
{
	switch(event)
	{
		case "start":
		{
			checkers_setup_pieces(minigame);
			minigame.minigame_flags = (CHECKERS_TURN_MOVE | CHECKERS_TURN_TEAM1);
			return true;
		}
		case "end":
		{
			entity e = NULL;
			while( (e = findentity(e, owner, minigame)) )
			if(e.classname == "minigame_board_piece")
			{
				strfree(e.netname);
				delete(e);
			}
			return false;
		}
		case "join":
		{
			int pl_num = minigame_count_players(minigame);

			// Don't allow more than 2 players
			if(pl_num >= CHECKERS_TEAMS) { return CHECKERS_SPECTATOR_TEAM; }

			// Get the right team
			if(minigame.minigame_players)
				return minigame_next_team(minigame.minigame_players.team, CHECKERS_TEAMS);

			// Team 1 by default
			return 1;
		}
		case "cmd":
		{
			entity player = ...(0,entity);
			bool event_blocked = (player.team == CHECKERS_SPECTATOR_TEAM);
			switch(argv(0))
			{
				case "move":
					if(event_blocked)
						return true;
					checkers_move(minigame, ...(0,entity), (...(1,int) >= 3 ? argv(1) : string_null), (...(1,int) >= 3 ? argv(2) : string_null), (...(1,int) >= 4 ? strtolower(argv(3)) : string_null));
					return true;
			}

			return false;
		}
		case "network_send":
		{
			entity sent = ...(0,entity);
			int sf = ...(1,int);
			if ( sent.classname == "minigame" && (sf & MINIG_SF_UPDATE ) )
			{
				WriteByte(MSG_ENTITY,sent.checkers_forcemove);
			}
			else if(sent.classname == "minigame_board_piece")
			{
				WriteByte(MSG_ENTITY,sent.checkers_id);
				WriteByte(MSG_ENTITY,sent.cnt);
			}
			return false;
		}
	}
	
	return false;
}


#elif defined(CSQC)

entity checkers_curr_piece; // identifier for the currently selected piece
string checkers_curr_pos; // identifier of the tile under the mouse
vector checkers_boardpos; // HUD board position
vector checkers_boardsize;// HUD board size

LinkedList checkers_available_moves;
.int checkers_avail_type;

int checkers_curr_promotion;

entity checkers_spawn_list_item(entity minigame, string pos, int resp)
{
	entity e = new(checkers_list_item);
	e.netname = strzone(pos);
	e.checkers_avail_type = resp;
	e.enemy = checkers_find_piece(minigame, pos);
	LL_PUSH(checkers_available_moves, e);
	return e;
}

void checkers_set_curr_piece(entity minigame, entity piece)
{
	// if there was already a current piece, remove what was left of it
	if(checkers_curr_piece)
	{
		LL_DELETE(checkers_available_moves,
		{
			strfree(it.netname);
		});
	}

	checkers_curr_piece = piece;
	if(!checkers_curr_piece) return;

	checkers_available_moves = LL_NEW();
	minigame.checkers_nexteam = minigame_self.team; // may or may not still be needed for the move checks

	int i, j;
	for(i = 0; i < CHECKERS_NUM_CNT; ++i)
	for(j = 0; j < CHECKERS_LET_CNT; ++j)
	{
		string newpos = minigame_tile_buildname(j, i);
		if(newpos == checkers_curr_piece.netname) continue;
		int r = checkers_move_try(minigame, checkers_curr_piece.netname, newpos, minigame.checkers_forcemove, NULL);

		if(CHECKERS_GOOD_MOVE(r))
		{
			switch (r)
			{
				case checkers_response__Promotion:
				case checkers_response__Ok:
					checkers_spawn_list_item(minigame, newpos, r);

					int letter = minigame_tile_letter(checkers_curr_piece.netname);
					int number = minigame_tile_number(checkers_curr_piece.netname);

					int to_number = minigame_tile_number(newpos);
					int to_letter = minigame_tile_letter(newpos);

					entity thepiece = NULL;

					if(checkers_curr_piece.checkers_id == checkers_piece__Pawn)
					if(to_number != number && to_letter != letter)
					{
						int ang = 0;
						if(letter + 1 == to_letter)
							ang = 1;
						if(letter - 1 == to_letter)
							ang = -1;

						thepiece = checkers_find_piece(minigame, minigame_tile_buildname(letter + ang, number));
						if(thepiece.team == checkers_curr_piece.team)
							thepiece = NULL; // revert what we did, it's no use
					}
					if(thepiece)
						checkers_spawn_list_item(minigame, thepiece.netname, r);
					break;
			}
		}
	}
}

// Required function, draw the game board
void checkers_hud_board(vector pos, vector mySize)
{
	minigame_hud_fitsqare(pos, mySize);
	checkers_boardpos = pos;
	checkers_boardsize = mySize;
	
	minigame_hud_simpleboard(pos,mySize,minigame_texture("checkers/board"));

	vector tile_size = minigame_hud_denormalize_size('1 1 0' / CHECKERS_TILE_SIZE,pos,mySize);
	vector tile_pos = '0 0 0';

	entity thepiece = checkers_find_piece(active_minigame, checkers_curr_pos);

	if((active_minigame.minigame_flags & CHECKERS_TURN_TEAM) == minigame_self.team )
	if(checkers_valid_tile(checkers_curr_pos))
	if(thepiece.team == minigame_self.team || !thepiece)
	{
		tile_pos = minigame_tile_pos(checkers_curr_pos,CHECKERS_NUM_CNT,CHECKERS_LET_CNT);
		tile_pos = minigame_hud_denormalize(tile_pos,pos,mySize);

		//entity isthere = thepiece;

		//if(isthere)
			minigame_drawpic_centered(tile_pos,
					minigame_texture("checkers/tile_available"),
					tile_size, '0.5 0.5 0.5', panel_fg_alpha, DRAWFLAG_NORMAL);
	}

	FOREACH_ENTITY_ENT_ORDERED(owner, active_minigame,
	{
		if ( it.classname == "minigame_board_piece" )
		{
			tile_pos = minigame_tile_pos(it.netname,CHECKERS_NUM_CNT,CHECKERS_LET_CNT);
			tile_pos = minigame_hud_denormalize(tile_pos,pos,mySize);

			vector tile_color = '1 1 1';

			if(it.netname == checkers_curr_pos)
			if(checkers_curr_piece || it.team != minigame_self.team || (it.cnt && it.team == minigame_self.team))
			if(checkers_curr_piece.netname != checkers_curr_pos)
			{
				minigame_drawpic_centered( tile_pos,  
						minigame_texture(((it.team != minigame_self.team) ? "checkers/tile_active" : "checkers/tile_selected")),
						tile_size, tile_color, panel_fg_alpha, DRAWFLAG_NORMAL );
			}
			if(it == checkers_curr_piece)
			{
				minigame_drawpic_centered( tile_pos,  
						minigame_texture("checkers/tile_selected"),
						tile_size, tile_color, panel_fg_alpha, DRAWFLAG_ADDITIVE );
			}

			minigame_drawpic_centered( tile_pos,  
					minigame_texture(sprintf("checkers/piece%d-%s", it.team, strtolower(checkers_piece_name[it.checkers_id]))),
					tile_size, tile_color, panel_fg_alpha, DRAWFLAG_NORMAL );
		}
	});

	if(checkers_curr_piece)
	{
		LL_EACH(checkers_available_moves, true,
		{
			string pic = ((it.enemy && it.enemy.team != minigame_self.team) ? "checkers/tile_active" : "checkers/tile_available");
			if(it.checkers_avail_type == checkers_response__Promotion)
			{
				tile_pos = minigame_tile_pos(it.netname,CHECKERS_NUM_CNT,CHECKERS_LET_CNT);
				tile_pos = minigame_hud_denormalize(tile_pos,pos,mySize);
				minigame_drawpic_centered(tile_pos,
					minigame_texture("checkers/tile_promoted"),
					tile_size, '1 1 1', panel_fg_alpha * 0.7, DRAWFLAG_NORMAL);
				pic = sprintf("checkers/piece%d-%s", minigame_self.team, strtolower(checkers_piece_name[checkers_curr_promotion]));
			}
			//LOG_DEBUG("Checkers: drawing list item at tile: ", it.netname, "\n");
			tile_pos = minigame_tile_pos(it.netname,CHECKERS_NUM_CNT,CHECKERS_LET_CNT);
			tile_pos = minigame_hud_denormalize(tile_pos,pos,mySize);
			minigame_drawpic_centered(tile_pos,
				minigame_texture(pic),
				tile_size, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		});
	}

	if ( active_minigame.minigame_flags & CHECKERS_TURN_WIN )
	{
		vector winfs = hud_fontsize*2;
		string player_name = "";
		FOREACH_ENTITY_ENT_ORDERED(owner, active_minigame,
		{
			if ( it.classname == "minigame_player" && 
					it.team == (active_minigame.minigame_flags & CHECKERS_TURN_TEAM) )
				player_name = entcs_GetName(it.minigame_playerslot-1);
		});
		
		vector win_pos = pos+eY*(mySize_y-winfs_y)/2;
		vector win_sz;
		win_sz = minigame_drawcolorcodedstring_wrapped(mySize_x,win_pos,
			sprintf("%s^7 won the game!",player_name), 
			winfs, 0, DRAWFLAG_NORMAL, 0.5);
		
		drawfill(win_pos-eY*hud_fontsize_y,win_sz+2*eY*hud_fontsize_y,'1 1 1',0.5,DRAWFLAG_ADDITIVE);
		
		minigame_drawcolorcodedstring_wrapped(mySize_x,win_pos,
			sprintf("%s^7 won the game!",player_name), 
			winfs, panel_fg_alpha, DRAWFLAG_NORMAL, 0.5);
	}
}


// Required function, draw the game status panel
void checkers_hud_status(vector pos, vector mySize)
{
	HUD_Panel_DrawBg();
	vector ts;
	ts = minigame_drawstring_wrapped(mySize_x,pos,active_minigame.descriptor.message,
		hud_fontsize * 2, '0.25 0.47 0.72', panel_fg_alpha, DRAWFLAG_NORMAL,0.5);
	
	pos_y += ts_y;
	mySize_y -= ts_y;
	
	vector player_fontsize = hud_fontsize * 1.75;
	ts_y = ( mySize_y - 2*player_fontsize_y ) / 2;
	ts_x = mySize_x;
	vector mypos;
	vector tile_size = '48 48 0';

	if(minigame_self.team != CHECKERS_SPECTATOR_TEAM)
	{
		mypos = pos;
		if ( (active_minigame.minigame_flags&CHECKERS_TURN_TEAM) == 2 )
			mypos_y  += player_fontsize_y + ts_y;
		drawfill(mypos,eX*mySize_x+eY*player_fontsize_y,'1 1 1',0.5,DRAWFLAG_ADDITIVE);
		mypos_y += player_fontsize_y;
		drawfill(mypos,eX*mySize_x+eY*tile_size_y,'1 1 1',0.25,DRAWFLAG_ADDITIVE);
	}

	entity e;
	FOREACH_MINIGAME_ENTITY(e)
	{
		if ( e.classname == "minigame_player" && e.team != CHECKERS_SPECTATOR_TEAM )
		{
			mypos = pos;
			if ( e.team == 2 )
				mypos_y  += player_fontsize_y + ts_y;
			minigame_drawcolorcodedstring_trunc(mySize_x,mypos,
				entcs_GetName(e.minigame_playerslot-1),
				player_fontsize, panel_fg_alpha, DRAWFLAG_NORMAL);
			
			mypos_y += player_fontsize_y;
			//drawpic( mypos,  
					//minigame_texture(strcat("checkers/piece",ftos(e.team))),
					//ftile_size, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL );
			
			mypos_x += tile_size_x;
		}
	};
}

// Turn a set of flags into a help message
string checkers_turn_to_string(int turnflags)
{
	if(minigame_self.team == CHECKERS_SPECTATOR_TEAM)
		return _("You are spectating");

	if ( turnflags & CHECKERS_TURN_WIN )
		return "Well done, you win!";
	
	if ( turnflags & CHECKERS_TURN_MOVE )
		return "Strategize?!";
	
	return "";
}

// Make the correct move
void checkers_make_move(entity minigame)
{
	if ( minigame.minigame_flags == (CHECKERS_TURN_MOVE|minigame_self.team) )
	{
		entity piece = checkers_find_piece(minigame,checkers_curr_pos);
		if(piece.team == minigame_self.team && (!minigame.checkers_forcemove || piece.cnt))
			checkers_set_curr_piece(minigame, piece);
		else if(checkers_curr_piece)
		{
			minigame_cmd("move ", checkers_curr_piece.netname, " ", checkers_curr_pos, " ", strtolower(checkers_piece_name[checkers_curr_promotion]));
			checkers_set_curr_piece(minigame, NULL);
		}
	}
}

void checkers_set_curr_pos(string s)
{
	strfree(checkers_curr_pos);
	if ( s )
		s = strzone(s);
	checkers_curr_pos = s;
}

void checkers_select_promotion(entity minigame, string pos)
{
	if(checkers_curr_piece)
	LL_EACH(checkers_available_moves, true,
	{
		if(it.checkers_avail_type == checkers_response__Promotion && it.netname == pos)
		{
			checkers_curr_promotion += 1;
			if(checkers_curr_promotion >= checkers_piece__King)
				checkers_curr_promotion = checkers_piece__Pawn;
			break;
		}
	});
}

// Required function, handle client events
int checkers_client_event(entity minigame, string event, ...)
{
	switch(event)
	{
		case "activate":
		{
			checkers_set_curr_pos("");
			checkers_curr_promotion = checkers_piece__King;
			checkers_curr_piece = NULL;
			minigame.message = checkers_turn_to_string(minigame.minigame_flags);
			return false;
		}
		case "key_pressed":
		case "key_released":
		{
			bool event_blocked = ((event == "key_released")
				|| ((minigame.minigame_flags & CHECKERS_TURN_TEAM) != minigame_self.team));
			if (!(minigame.minigame_flags & CHECKERS_TURN_WIN))
			{
				switch ( ...(0,int) )
				{
					case K_RIGHTARROW:
					case K_KP_RIGHTARROW:
						if (event_blocked)
							return true;
						if ( ! checkers_curr_pos )
							checkers_set_curr_pos("e4");
						else
							checkers_set_curr_pos( minigame_relative_tile(checkers_curr_pos,1,0,CHECKERS_NUM_CNT,CHECKERS_LET_CNT));
						return true;
					case K_LEFTARROW:
					case K_KP_LEFTARROW:
						if (event_blocked)
							return true;
						if ( ! checkers_curr_pos )
							checkers_set_curr_pos("c4");
						else
							checkers_set_curr_pos(minigame_relative_tile(checkers_curr_pos,-1,0,CHECKERS_NUM_CNT,CHECKERS_LET_CNT));
						return true;
					case K_UPARROW:
					case K_KP_UPARROW:
						if (event_blocked)
							return true;
						if ( ! checkers_curr_pos )
							checkers_set_curr_pos("d5");
						else
							checkers_set_curr_pos(minigame_relative_tile(checkers_curr_pos,0,1,CHECKERS_NUM_CNT,CHECKERS_LET_CNT));
						return true;
					case K_DOWNARROW:
					case K_KP_DOWNARROW:
						if (event_blocked)
							return true;
						if ( ! checkers_curr_pos )
							checkers_set_curr_pos("d3");
						else
							checkers_set_curr_pos(minigame_relative_tile(checkers_curr_pos,0,-1,CHECKERS_NUM_CNT,CHECKERS_LET_CNT));
						return true;
					case K_ENTER:
					case K_KP_ENTER:
						if (event_blocked)
							return true;
						checkers_make_move(minigame);
						return true;
					case K_SPACE:
						if (event_blocked)
							return true;
						checkers_select_promotion(minigame, checkers_curr_pos);
						return true;
				}
			}

			return false;
		}
		case "mouse_pressed":
		{
			if(minigame_self.team == CHECKERS_SPECTATOR_TEAM)
				return false;
			if(...(0,int) == K_MOUSE1)
			{
				checkers_make_move(minigame);
				return true;
			}
			else if(...(0,int) == K_MOUSE2)
			{
				checkers_select_promotion(minigame, checkers_curr_pos);
				return true;
			}

			return false;
		}
		case "mouse_moved":
		{
			vector mouse_pos = minigame_hud_normalize(mousepos,checkers_boardpos,checkers_boardsize);
			if ( minigame.minigame_flags == (CHECKERS_TURN_MOVE|minigame_self.team) )
			{
				checkers_set_curr_pos(minigame_tile_name(mouse_pos,CHECKERS_NUM_CNT,CHECKERS_LET_CNT));
			}
			if ( ! checkers_valid_tile(checkers_curr_pos) )
				checkers_set_curr_pos(string_null);

			return true;
		}
		case "network_receive":
		{
			entity sent = ...(0,entity);
			int sf = ...(1,int);
			if ( sent.classname == "minigame" )
			{
				if ( sf & MINIG_SF_UPDATE )
				{
					sent.message = checkers_turn_to_string(sent.minigame_flags);
					if ( sent.minigame_flags & minigame_self.team )
						minigame_prompt();
					else
						checkers_set_curr_piece(minigame, NULL);
					sent.checkers_forcemove = ReadByte();
				}
			}
			if(sent.classname == "minigame_board_piece")
			{
				sent.checkers_id = ReadByte();
				sent.cnt = ReadByte();
				if(sent.cnt && sent.team == minigame_self.team)
					checkers_set_curr_piece(minigame, sent);
			}

			return false;
		}
	}

	return false;
}

#endif