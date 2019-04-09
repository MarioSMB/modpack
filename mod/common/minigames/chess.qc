REGISTER_MINIGAME(chess, "Chess");

const float CHESS_TURN_MOVE  = 0x0100; // player has to click on a piece on the board
const float CHESS_TURN_WIN   = 0x0200; // player has won
const float CHESS_TURN_DRAW  = 0x0400; // player can make no more moves
const float CHESS_TURN_TYPE  = 0x0f00; // turn type mask

const float CHESS_TURN_TEAM1 = 0x0001;
const float CHESS_TURN_TEAM2 = 0x0002;
const float CHESS_TURN_TEAM  = 0x000f; // turn team mask

const int CHESS_LET_CNT = 8;
const int CHESS_NUM_CNT = 8;

const int CHESS_TILE_SIZE = 8;

const int CHESS_TEAMS = 2;

const int CHESS_FINE = 0;
const int CHESS_CHECK = 1;
const int CHESS_CHECKMATE = 2;

.int chess_id;

.int chess_nexteam;

.bool chess_moved;

.bool chess_king_checked;

.bool chess_passant;

#define board_pieces(X) \
	X(Empty     ,   " ")    \
	X(Pawn      ,   "P")    \
	X(Knight    ,   "K")    \
	X(Bishop    ,   "B")    \
	X(Rook      ,   "R")    \
	X(Queen     ,   "Q")    \
	X(King      ,   "X")    \
	/**/

#define lambda(name, shortname) shortname,
string piece_name[] = {board_pieces(lambda)};
#undef lambda

enum {
#define lambda(name, shortname) piece__##name,
	board_pieces(lambda)
#undef lambda
};

//<editor-fold desc="Move">
#define responses(X) \
	X(NotYourTurn, "Not your turn") \
	X(Illegal, "Illegal move") \
	X(Obstructed, "Illegal move (piece in the way)") \
	X(Ok, "OK") \
	X(Promotion, "Promotion!") \
	X(CastleK, "Castle kingside!") \
	X(CastleQ, "Castle queenside!") \
	/**/

enum {
#define lambda(id, text) response__##id,
	responses(lambda)
#undef lambda
};

#define CHESS_GOOD_MOVE(X) (X == response__Ok || X == response__Promotion || X == response__CastleK || X == response__CastleQ)

entity chess_find_piece(entity minig, string tile, entity ignore)
{
	entity e = NULL;
	while ( ( e = findentity(e,owner,minig) ) )
		if ( e.classname == "minigame_board_piece" && e.netname == tile && e != ignore )
			return e;
	return NULL;
}

// check if the tile name is valid (5x5 grid)
bool chess_valid_tile(string tile)
{
	if ( !tile )
		return false;
	int number = minigame_tile_number(tile);
	int letter = minigame_tile_letter(tile);
	return 0 <= number && number < CHESS_NUM_CNT && 0 <= letter && letter < CHESS_LET_CNT;
}

bool chess_check(entity minig, entity piece);
int chess_kingstatus(entity minigame, int pteam);
bool chess_king_checkspot(entity minigame, entity king, string topos);
#define sgn(x) (x > 0 ? 1 : x < 0 ? -1 : 0)
int chess_move_try(entity minigame, string thepiece, string pos, bool recurse_king, entity ignore)
{
	entity p = chess_find_piece(minigame, thepiece, ignore);
	entity to_p = chess_find_piece(minigame, pos, ignore);
	int t = p.team;
	int to_t = (to_p) ? to_p.team : 0;

	int fx = minigame_tile_letter(thepiece);
	int fy = minigame_tile_number(thepiece);

	int tx = minigame_tile_letter(pos);
	int ty = minigame_tile_number(pos);

	int dx = tx - fx, dy = ty - fy;
	if (!dx && !dy) return response__Illegal;

	int sx = sgn(dx), sy = sgn(dy);
	int adx = fabs(dx), ady = fabs(dy);

#define scan() do { \
	int x = fx, y = fy; \
	do { \
		x += sx, y += sy; \
		to_p = chess_find_piece(minigame, minigame_tile_buildname(x, y), ignore); \
		to_t = (to_p) ? to_p.team : 0; \
		bool last = x == tx && y == ty; \
		if (to_p && (!last || t == to_t)) return response__Obstructed; \
	} while (!(x == tx && y == ty)); \
} while (0)
	switch (p.chess_id) {
		case piece__Pawn: {
			const int dir = (t == 1) ? 1 : -1;
			if (sy != dir) return response__Illegal;
			if (ady > 2) return response__Illegal;
			if (ady == 2) {
				const int home = ((t == 1) ? 1 : 6);
				if (fy != home) return response__Illegal;
			}
			bool want_capture = adx == 1 && ady == 1;
			to_p = chess_find_piece(minigame, pos, ignore);
			if(!to_p && want_capture)
			{
				int p_dir = 1; // default to right
				if(sx == -1) p_dir = -1;
				to_p = chess_find_piece(minigame, minigame_tile_buildname(fx + p_dir, fy), ignore);
				if(!to_p.chess_passant)
					to_p = NULL; // nope
			}
			to_t = (to_p) ? to_p.team : 0;

			bool capture = want_capture && to_p && to_t != t;
			if (dx && !capture) return response__Illegal;
			if (to_p && !capture) return response__Obstructed;
			if (ty == ((t == 1) ? 7 : 0)) return response__Promotion;
			break;
		}
		case piece__Knight:
			if (dx && dy && (adx + ady == 3)) {
				to_p = chess_find_piece(minigame, minigame_tile_buildname(tx, ty), ignore);
				to_t = (to_p) ? to_p.team : 0;
				if (to_p && to_t == t) return response__Obstructed;
			} else {
				return response__Illegal;
			}
			break;
		case piece__Bishop:
			if (adx == ady) {
				scan();
			} else {
				return response__Illegal;
			}
			break;
		case piece__Rook:
			if (!dx != !dy) {
				scan();
			} else {
				return response__Illegal;
			}
			break;
		case piece__Queen:
			if (adx == ady || !dx != !dy) {
				scan();
			} else {
				return response__Illegal;
			}
			break;
		case piece__King:
			if(adx == 2 && !ady) // castling
			{
				if(sx == 1)
				{
					if(p.chess_moved || p.chess_king_checked)
						return response__Illegal;

					entity cto;
					cto = chess_find_piece(minigame, minigame_tile_buildname(fx + 1, fy), ignore);
					if(cto) { return response__Illegal; } // team doesn't matter, we don't want to go here
					cto = chess_find_piece(minigame, minigame_tile_buildname(fx + 2, fy), ignore);
					if(cto) { return response__Illegal; } // team doesn't matter, we don't want to go here
					cto = chess_find_piece(minigame, minigame_tile_buildname(fx + 3, fy), ignore);

					if(cto.chess_moved) { return response__Illegal; }

					return response__CastleK;
				}
				else if(sx == -1)
				{
					if(p.chess_moved || p.chess_king_checked)
						return response__Illegal;

					entity cto;
					cto = chess_find_piece(minigame, minigame_tile_buildname(fx - 1, fy), ignore);
					if(cto) { return response__Illegal; } // team doesn't matter, we don't want to go here
					cto = chess_find_piece(minigame, minigame_tile_buildname(fx - 2, fy), ignore);
					if(cto) { return response__Illegal; } // team doesn't matter, we don't want to go here
					cto = chess_find_piece(minigame, minigame_tile_buildname(fx - 3, fy), ignore);
					if(cto) { return response__Illegal; } // team doesn't matter, we don't want to go here
					cto = chess_find_piece(minigame, minigame_tile_buildname(fx - 4, fy), ignore);

					if(cto.chess_moved) { return response__Illegal; }

					return response__CastleQ;
				}
					
			}
			else if (adx <= 1 && ady <= 1) {
				scan();
				if(recurse_king)
				if(chess_king_checkspot(minigame, p, pos)) // NOTE: doesn't listen to ignore entity
					return response__Illegal;
			} else {
				return response__Illegal;
			}
			break;
		default:
			return response__Illegal;
	}
	return response__Ok;
}

bool chess_check_king_in_spot(entity minigame, string piece, string topos)
{
	entity thepiece = chess_find_piece(minigame, piece, NULL);
	if(!thepiece || thepiece.chess_id == piece__King) return false; // no use even attempting to continue, or king (king does its own checks)

	entity oldpiece = chess_find_piece(minigame, topos, NULL);
	entity ignore = oldpiece;

	string thepos = thepiece.netname;
	thepiece.netname = topos;

	entity e = NULL;
	while ( ( e = findentity(e,owner,minigame) ) )
		if ( e.classname == "minigame_board_piece" && e.team == thepiece.team && e.chess_id == piece__King && e != ignore )
		{
			if(chess_check(minigame, e))
			{
				thepiece.netname = thepos;
				return true;
			}
		}

	thepiece.netname = thepos;

	return false;
}

bool chess_king_checkspot(entity minig, entity king, string topos)
{
	int kteam = king.team;
	string oldpos = king.netname;
	entity oldpiece = chess_find_piece(minig, topos, NULL);

	if(oldpiece && oldpiece.team == king.team)
		return false; // can't move there!
	king.netname = topos;

	entity ignore = oldpiece;

	entity e = NULL;
	while ( ( e = findentity(e,owner,minig) ) )
		if ( e.classname == "minigame_board_piece" && e.team != kteam )
		{
			int try = chess_move_try(minig, e.netname, topos, false, ignore);
			if(CHESS_GOOD_MOVE(try))
			{
				king.netname = oldpos;
				return true;
			}
		}

	king.netname = oldpos;

	return false;
}

bool chess_check(entity minig, entity king)
{
	int kteam = king.team;

	entity e = NULL;
	while ( ( e = findentity(e,owner,minig) ) )
		if ( e.classname == "minigame_board_piece" && e.team != kteam && e.chess_id != piece__King )
		{
			int try = chess_move_try(minig, e.netname, king.netname, false, NULL);
			if(CHESS_GOOD_MOVE(try))
				return true;
		}

	return false;
}

// renamed, as it would be silly to check other pieces here
bool chess_king_canmove(entity minigame, entity piece)
{
	int i, j;
	for(i = 0; i < CHESS_NUM_CNT; ++i)
		for(j = 0; j < CHESS_LET_CNT; ++j)
		{
			string newpos = minigame_tile_buildname(j, i);
			if(newpos == piece.netname) continue;
			if(chess_king_checkspot(minigame, piece, newpos))
				continue;
			int try = chess_move_try(minigame, piece.netname, newpos, true, NULL);

			if(CHESS_GOOD_MOVE(try))
			{
				LOG_INFO("Can move to ", newpos, ", apparently");
				return true; // don't bother wasting more resources, we have a valid spot
			}
		}

	return false;
}

bool chess_tryallmoves(entity minigame, entity piece)
{
	int i, j;
	for(i = 0; i < CHESS_NUM_CNT; ++i)
	for(j = 0; j < CHESS_LET_CNT; ++j)
	{
		string newpos = minigame_tile_buildname(j, i);
		if(newpos == piece.netname) continue;
		int r = chess_move_try(minigame, piece.netname, newpos, true, NULL);

		if(CHESS_GOOD_MOVE(r))
		{
			if(chess_check_king_in_spot(minigame, piece.netname, newpos))
				continue;
			return true;
		}
	}

	return false;
}

bool chess_king_canbesaved(entity minigame, entity king)
{
	entity e = NULL;
	while ( ( e = findentity(e,owner,minigame) ) )
	{
		if(e.classname != "minigame_board_piece") continue;
		if(e.team != king.team || e == king) continue;

		if(chess_tryallmoves(minigame, e))
			return true;
	}

	return false;
}

int chess_kingstatus(entity minigame, int pteam)
{
	return = CHESS_FINE;

	entity e = NULL;
	while ( ( e = findentity(e,owner,minigame) ) )
		if ( e.classname == "minigame_board_piece" )
		{
			if(e.team != pteam || e.chess_id != piece__King) continue;
			if(!chess_check(minigame, e)) continue;
			return = CHESS_CHECK;
			e.chess_king_checked = true;
			if(!chess_king_canmove(minigame, e))
			if(!chess_king_canbesaved(minigame, e))
				return CHESS_CHECKMATE;
		}
}

bool chess_move_piece(entity minigame, entity piece, string pos, int promote)
{
	if(!piece) { return false; }

	entity thepiece = chess_find_piece(minigame, pos, NULL);
	if(thepiece.team == piece.team)
	{
		LOG_TRACE("Chess: Trying to move a piece onto an existing piece we own, THIS SHOULD NOT HAPPEN!");
		return false;
	}

	if(thepiece)
	{
		if(thepiece.netname) { strunzone(thepiece.netname); }
		delete(thepiece);
		thepiece = NULL;
	}

	int letter = minigame_tile_letter(piece.netname);
	int number = minigame_tile_number(piece.netname);

	int to_number = minigame_tile_number(pos);
	int to_letter = minigame_tile_letter(pos);

	if(piece.chess_id == piece__Pawn)
	if(to_number != number && to_letter != letter)
	{
		int ang = 0;
		if(letter + 1 == to_letter)
			ang = 1;
		if(letter - 1 == to_letter)
			ang = -1;

		thepiece = chess_find_piece(minigame, minigame_tile_buildname(letter + ang, number), NULL);
		if(!thepiece.chess_passant || thepiece.team == piece.team)
			thepiece = NULL; // revert what we did, it's no use
	}

	if(thepiece)
	{
		if(thepiece.netname) { strunzone(thepiece.netname); }
		delete(thepiece);
	}

	FOREACH_ENTITY_ENT_ORDERED(owner, minigame,
	{
		if(it.classname != "minigame_board_piece") continue;
		if(it.chess_id != piece__Pawn) continue;
		if(!it.chess_passant) continue;
		it.chess_passant = false;
		minigame_server_sendflags(it,MINIG_SF_UPDATE);
	});

	int num_dir = ((piece.team == 1) ? 2 : -2);

	if(piece.chess_id == piece__Pawn && (number + num_dir) == to_number)
		piece.chess_passant = true;

	if(piece.netname) { strunzone(piece.netname); }
	piece.netname = strzone(pos);
	piece.chess_moved = true;
	if(promote)
		piece.chess_id = promote;

	minigame_server_sendflags(piece,MINIG_SF_ALL);

	return true;
}

int chess_get_promotion_piece(string promote)
{
	for(int i = piece__Pawn; i < piece__King; ++i)
	{
		if(strtolower(piece_name[i]) == promote)
			return i;
	}

	return piece__Queen;
}

// make a move
void chess_move(entity minigame, entity player, string thepiece, string pos, string promotion)
{
	if(minigame.minigame_flags & CHESS_TURN_MOVE)
	if(pos && player.team == (minigame.minigame_flags & CHESS_TURN_TEAM))
	if(chess_valid_tile(pos) && chess_find_piece(minigame, thepiece, NULL))
	{
		entity piece = chess_find_piece(minigame, thepiece, NULL);
		if(piece.team != player.team)
			return; // fail!

		if(piece.chess_id == piece__King)
		if(chess_king_checkspot(minigame, piece, pos))
			return;
		int r = chess_move_try(minigame, thepiece, pos, true, NULL);
		int promote = piece__Empty;
		int rletter = 0, rnumber = 0;
		string thepos = string_null;
		entity rook = NULL;
		string thenewpos = string_null;
		if(CHESS_GOOD_MOVE(r))
		{
			if(chess_check_king_in_spot(minigame, thepiece, pos))
				return;
		}

		switch (r)
		{
			default:
				return;
			case response__CastleK:
				rletter = minigame_tile_letter(piece.netname);
				rnumber = minigame_tile_number(piece.netname);
				thepos = minigame_tile_buildname(rletter + 3, rnumber);
				rook = chess_find_piece(minigame, thepos, NULL);
				if(!rook)
					return; // wtf
				thenewpos = minigame_tile_buildname(rletter + 1, rnumber);
				chess_move_piece(minigame, rook, thenewpos, 0);
				chess_move_piece(minigame, piece, pos, 0);
				break;
			case response__CastleQ:
				rletter = minigame_tile_letter(piece.netname);
				rnumber = minigame_tile_number(piece.netname);
				thepos = minigame_tile_buildname(rletter - 4, rnumber);
				rook = chess_find_piece(minigame, thepos, NULL);
				if(!rook)
					return; // wtf
				thenewpos = minigame_tile_buildname(rletter - 1, rnumber);
				chess_move_piece(minigame, rook, thenewpos, 0);
				chess_move_piece(minigame, piece, pos, 0);
				break;
			case response__Promotion:
				promote = chess_get_promotion_piece(promotion);
			case response__Ok:
				chess_move_piece(minigame, piece, pos, promote);
				break;
		}

		minigame.chess_nexteam = minigame_next_team(player.team,CHESS_TEAMS);

		int mypcount = 0, theirpcount = 0;
		FOREACH_ENTITY_ENT_ORDERED(owner, minigame,
		{
			if(it.classname != "minigame_board_piece") continue;
			if(it.team == player.team)
				++mypcount;
			else
				++theirpcount;
		});

		if(mypcount <= 1 && theirpcount <= 1) // if both sides have no actual pieces, it's a draw (kings can't take eachother)
			minigame.minigame_flags = CHESS_TURN_DRAW; // TODO: also end up in a draw if more than 20 checks have been made
		else if(mypcount >= 1 && !theirpcount) // special rule: enemy has no pieces while we have some, call it a victory!
			minigame.minigame_flags = CHESS_TURN_WIN | player.team;
		else if(chess_kingstatus(minigame, minigame.chess_nexteam) == CHESS_CHECKMATE)
			minigame.minigame_flags = CHESS_TURN_WIN | player.team;
		else
			minigame.minigame_flags = CHESS_TURN_MOVE | minigame.chess_nexteam;

		minigame_server_sendflags(minigame,MINIG_SF_UPDATE);
	}
}

void chess_spawn_piece(entity minigame, string pos, int pteam, int pid)
{
	entity piece = msle_spawn(minigame,"minigame_board_piece");
	piece.team = pteam;
	piece.chess_id = pid;
	piece.netname = strzone(pos);
	minigame_server_sendflags(piece,MINIG_SF_ALL);
}

void chess_setup_pieces(entity minigame)
{
	// pawns
	int i;
	for(i = 0; i < CHESS_LET_CNT; ++i)
		chess_spawn_piece(minigame, minigame_tile_buildname(i,1), 1, piece__Pawn);
	for(i = 0; i < CHESS_LET_CNT; ++i)
		chess_spawn_piece(minigame, minigame_tile_buildname(i,6), 2, piece__Pawn);

	// white
	chess_spawn_piece(minigame, "a1", 1, piece__Rook);
	chess_spawn_piece(minigame, "h1", 1, piece__Rook);
	chess_spawn_piece(minigame, "b1", 1, piece__Knight);
	chess_spawn_piece(minigame, "g1", 1, piece__Knight);
	chess_spawn_piece(minigame, "c1", 1, piece__Bishop);
	chess_spawn_piece(minigame, "f1", 1, piece__Bishop);
	chess_spawn_piece(minigame, "d1", 1, piece__Queen);
	chess_spawn_piece(minigame, "e1", 1, piece__King);

	// black
	chess_spawn_piece(minigame, "a8", 2, piece__Rook);
	chess_spawn_piece(minigame, "h8", 2, piece__Rook);
	chess_spawn_piece(minigame, "b8", 2, piece__Knight);
	chess_spawn_piece(minigame, "g8", 2, piece__Knight);
	chess_spawn_piece(minigame, "c8", 2, piece__Bishop);
	chess_spawn_piece(minigame, "f8", 2, piece__Bishop);
	chess_spawn_piece(minigame, "d8", 2, piece__Queen);
	chess_spawn_piece(minigame, "e8", 2, piece__King);

	minigame_server_sendflags(minigame,MINIG_SF_UPDATE);
}

#ifdef SVQC


// required function, handle server side events
int chess_server_event(entity minigame, string event, ...)
{
	switch(event)
	{
		case "start":
		{
			chess_setup_pieces(minigame);
			minigame.minigame_flags = (CHESS_TURN_MOVE | CHESS_TURN_TEAM1);
			return true;
		}
		case "end":
		{
			FOREACH_ENTITY_ENT_ORDERED(owner, minigame,
			{
				if(it.netname) { strunzone(it.netname); }
				delete(it);
			});
			return false;
		}
		case "join":
		{
			int pl_num = minigame_count_players(minigame);

			// Don't allow more than 2 players
			if(pl_num >= CHESS_TEAMS) { return false; }

			// Get the right team
			if(minigame.minigame_players)
				return minigame_next_team(minigame.minigame_players.team, CHESS_TEAMS);

			// Team 1 by default
			return 1;
		}
		case "cmd":
		{
			switch(argv(0))
			{
				case "move": 
					chess_move(minigame, ...(0,entity), (...(1,int) >= 3 ? argv(1) : string_null), (...(1,int) >= 3 ? argv(2) : string_null), (...(1,int) >= 4 ? strtolower(argv(3)) : string_null));
					return true;
			}

			return false;
		}
		case "network_send":
		{
			entity sent = ...(0,entity);
			int sf = ...(1,int);
			if(sent.classname == "minigame_board_piece")
			{
				WriteByte(MSG_ENTITY,sent.chess_id);
				if(sf & MINIG_SF_UPDATE)
				{
					int sendf = 0;
					if(sent.chess_passant)
						sendf |= BIT(0);
					if(sent.chess_moved)
						sendf |= BIT(1);
					if(sent.chess_king_checked)
						sendf |= BIT(2);
					WriteByte(MSG_ENTITY,sendf);
				}
			}
			return false;
		}
	}
	
	return false;
}


#elif defined(CSQC)

entity chess_curr_piece; // identifier for the currently selected piece
string chess_curr_pos; // identifier of the tile under the mouse
vector chess_boardpos; // HUD board position
vector chess_boardsize;// HUD board size

LinkedList chess_available_moves;
.int chess_avail_type;

int chess_curr_promotion;

entity chess_spawn_list_item(entity minigame, string pos, int resp)
{
	entity e = new(chess_list_item);
	e.netname = strzone(pos);
	e.chess_avail_type = resp;
	e.enemy = chess_find_piece(minigame, pos, NULL);
	LL_PUSH(chess_available_moves, e);
	return e;
}

void chess_set_curr_piece(entity minigame, entity piece)
{
	// if there was already a current piece, remove what was left of it
	if(chess_curr_piece)
	{
		LL_DELETE(chess_available_moves,
		{
			strfree(it.netname);
		});
	}

	chess_curr_piece = piece;
	if(!chess_curr_piece) return;

	chess_available_moves = LL_NEW();
	minigame.chess_nexteam = minigame_self.team; // may or may not still be needed for the move checks

	string tpos = string_null;

	int i, j;
	for(i = 0; i < CHESS_NUM_CNT; ++i)
	for(j = 0; j < CHESS_LET_CNT; ++j)
	{
		string newpos = minigame_tile_buildname(j, i);
		if(newpos == chess_curr_piece.netname) continue;
		int r = chess_move_try(minigame, chess_curr_piece.netname, newpos, true, NULL);

		if(CHESS_GOOD_MOVE(r))
		{
			if(chess_curr_piece.chess_id == piece__King)
			if(chess_king_checkspot(minigame, chess_curr_piece, newpos))
				continue;
			if(chess_check_king_in_spot(minigame, chess_curr_piece.netname, newpos))
				continue;

			switch (r)
			{
				case response__CastleK:
					tpos = minigame_tile_buildname(j + 1, i);

					chess_spawn_list_item(minigame, tpos, r);
					chess_spawn_list_item(minigame, newpos, r);
					break;
				case response__CastleQ:
					tpos = minigame_tile_buildname(j - 2, i);

					chess_spawn_list_item(minigame, tpos, r);
					chess_spawn_list_item(minigame, newpos, r);
					break;
				case response__Promotion:
				case response__Ok:
					chess_spawn_list_item(minigame, newpos, r);

					int letter = minigame_tile_letter(chess_curr_piece.netname);
					int number = minigame_tile_number(chess_curr_piece.netname);

					int to_number = minigame_tile_number(newpos);
					int to_letter = minigame_tile_letter(newpos);

					entity thepiece = NULL;

					if(chess_curr_piece.chess_id == piece__Pawn)
					if(to_number != number && to_letter != letter)
					{
						int ang = 0;
						if(letter + 1 == to_letter)
							ang = 1;
						if(letter - 1 == to_letter)
							ang = -1;

						thepiece = chess_find_piece(minigame, minigame_tile_buildname(letter + ang, number), NULL);
						if(!thepiece.chess_passant || thepiece.team == chess_curr_piece.team)
							thepiece = NULL; // revert what we did, it's no use
					}
					if(thepiece)
						chess_spawn_list_item(minigame, thepiece.netname, r);
					break;
			}
		}
	}
}

// Required function, draw the game board
void chess_hud_board(vector pos, vector mySize)
{
	minigame_hud_fitsqare(pos, mySize);
	chess_boardpos = pos;
	chess_boardsize = mySize;
	
	minigame_hud_simpleboard(pos,mySize,minigame_texture("chess/board"));

	vector tile_size = minigame_hud_denormalize_size('1 1 0' / CHESS_TILE_SIZE,pos,mySize);
	vector tile_pos = '0 0 0';

	entity thepiece = chess_find_piece(active_minigame, chess_curr_pos, NULL);

	if((active_minigame.minigame_flags & CHESS_TURN_TEAM) == minigame_self.team )
	if(chess_valid_tile(chess_curr_pos))
	if(thepiece.team == minigame_self.team || !thepiece)
	{
		tile_pos = minigame_tile_pos(chess_curr_pos,CHESS_NUM_CNT,CHESS_LET_CNT);
		tile_pos = minigame_hud_denormalize(tile_pos,pos,mySize);

		//entity isthere = thepiece;

		//if(isthere)
			minigame_drawpic_centered(tile_pos,
					minigame_texture("chess/tile_available"),
					tile_size, '0.5 0.5 0.5', panel_fg_alpha, DRAWFLAG_NORMAL);
	}

	FOREACH_ENTITY_ENT_ORDERED(owner, active_minigame,
	{
		if ( it.classname == "minigame_board_piece" )
		{
			tile_pos = minigame_tile_pos(it.netname,CHESS_NUM_CNT,CHESS_LET_CNT);
			tile_pos = minigame_hud_denormalize(tile_pos,pos,mySize);

			vector tile_color = '1 1 1';

			if(it.netname == chess_curr_pos)
			if(chess_curr_piece || it.team != minigame_self.team)
			if(chess_curr_piece.netname != chess_curr_pos)
			{
				minigame_drawpic_centered( tile_pos,  
						minigame_texture(((it.team != minigame_self.team) ? "chess/tile_active" : "chess/tile_selected")),
						tile_size, tile_color, panel_fg_alpha, DRAWFLAG_NORMAL );
			}
			if(it == chess_curr_piece)
			{
				minigame_drawpic_centered( tile_pos,  
						minigame_texture("chess/tile_selected"),
						tile_size, tile_color, panel_fg_alpha, DRAWFLAG_ADDITIVE );
			}

			minigame_drawpic_centered( tile_pos,  
					minigame_texture(sprintf("chess/piece%d-%s", it.team, strtolower(piece_name[it.chess_id]))),
					tile_size, tile_color, panel_fg_alpha, DRAWFLAG_NORMAL );
		}
	});

	if(chess_curr_piece)
	{
		LL_EACH(chess_available_moves, true,
		{
			string pic = ((it.enemy && it.enemy.team != minigame_self.team) ? "chess/tile_active" : "chess/tile_available");
			if(it.chess_avail_type == response__Promotion)
			{
				tile_pos = minigame_tile_pos(it.netname,CHESS_NUM_CNT,CHESS_LET_CNT);
				tile_pos = minigame_hud_denormalize(tile_pos,pos,mySize);
				minigame_drawpic_centered(tile_pos,
					minigame_texture("chess/tile_promoted"),
					tile_size, '1 1 1', panel_fg_alpha * 0.7, DRAWFLAG_NORMAL);
				pic = sprintf("chess/piece%d-%s", minigame_self.team, strtolower(piece_name[chess_curr_promotion]));
			}
			//LOG_DEBUG("Chess: drawing list item at tile: ", it.netname, "\n");
			tile_pos = minigame_tile_pos(it.netname,CHESS_NUM_CNT,CHESS_LET_CNT);
			tile_pos = minigame_hud_denormalize(tile_pos,pos,mySize);
			minigame_drawpic_centered(tile_pos,
				minigame_texture(pic),
				tile_size, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		});
	}

	if ( active_minigame.minigame_flags & CHESS_TURN_WIN )
	{
		vector winfs = hud_fontsize*2;
		string playername = "";
		FOREACH_ENTITY_ENT_ORDERED(owner, active_minigame,
		{
			if ( it.classname == "minigame_player" && 
					it.team == (active_minigame.minigame_flags & CHESS_TURN_TEAM) )
				playername = entcs_GetName(it.minigame_playerslot-1);
		});
		
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
void chess_hud_status(vector pos, vector mySize)
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

	mypos = pos;
	if ( (active_minigame.minigame_flags&CHESS_TURN_TEAM) == 2 )
		mypos_y  += player_fontsize_y + ts_y;
	drawfill(mypos,eX*mySize_x+eY*player_fontsize_y,'1 1 1',0.5,DRAWFLAG_ADDITIVE);
	mypos_y += player_fontsize_y;
	drawfill(mypos,eX*mySize_x+eY*tile_size_y,'1 1 1',0.25,DRAWFLAG_ADDITIVE);

	FOREACH_ENTITY_ENT_ORDERED(owner, active_minigame,
	{
		if ( it.classname == "minigame_player" )
		{
			mypos = pos;
			if ( it.team == 2 )
				mypos_y  += player_fontsize_y + ts_y;
			minigame_drawcolorcodedstring_trunc(mySize_x,mypos,
				entcs_GetName(it.minigame_playerslot-1),
				player_fontsize, panel_fg_alpha, DRAWFLAG_NORMAL);
			
			mypos_y += player_fontsize_y;
			//drawpic( mypos,  
					//minigame_texture(strcat("chess/piece",ftos(it.team))),
					//ftile_size, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL );
			
			mypos_x += tile_size_x;
		}
	});
}

// Turn a set of flags into a help message
string chess_turn_to_string(int turnflags)
{
	if ( turnflags & CHESS_TURN_WIN )
		return "Well done, you win!";
	
	if ( turnflags & CHESS_TURN_MOVE )
		return "Strategize!";
	
	return "";
}

// Make the correct move
void chess_make_move(entity minigame)
{
	if ( minigame.minigame_flags == (CHESS_TURN_MOVE|minigame_self.team) )
	{
		entity piece = chess_find_piece(minigame,chess_curr_pos,NULL);
		if(piece.team == minigame_self.team)
			chess_set_curr_piece(minigame, piece);
		else if(chess_curr_piece)
		{
			minigame_cmd("move ", chess_curr_piece.netname, " ", chess_curr_pos, " ", strtolower(piece_name[chess_curr_promotion]));
			chess_set_curr_piece(minigame, NULL);
		}
	}
}

void chess_set_curr_pos(string s)
{
	if ( chess_curr_pos )
		strunzone(chess_curr_pos);
	if ( s )
		s = strzone(s);
	chess_curr_pos = s;
}

void chess_select_promotion(entity minigame, string pos)
{
	if(chess_curr_piece)
	LL_EACH(chess_available_moves, true,
	{
		if(it.chess_avail_type == response__Promotion && it.netname == pos)
		{
			chess_curr_promotion += 1;
			if(chess_curr_promotion >= piece__King)
				chess_curr_promotion = piece__Pawn;
			break;
		}
	});
}

// Required function, handle client events
int chess_client_event(entity minigame, string event, ...)
{
	switch(event)
	{
		case "activate":
		{
			chess_set_curr_pos("");
			chess_curr_promotion = piece__Queen;
			chess_curr_piece = NULL;
			minigame.message = chess_turn_to_string(minigame.minigame_flags);
			return false;
		}
		case "key_pressed":
		{
			if((minigame.minigame_flags & CHESS_TURN_TEAM) == minigame_self.team)
			{
				switch ( ...(0,int) )
				{
					case K_RIGHTARROW:
					case K_KP_RIGHTARROW:
						if ( ! chess_curr_pos )
							chess_set_curr_pos("e4");
						else
							chess_set_curr_pos( minigame_relative_tile(chess_curr_pos,1,0,CHESS_NUM_CNT,CHESS_LET_CNT));
						return true;
					case K_LEFTARROW:
					case K_KP_LEFTARROW:
						if ( ! chess_curr_pos )
							chess_set_curr_pos("c4");
						else
							chess_set_curr_pos(minigame_relative_tile(chess_curr_pos,-1,0,CHESS_NUM_CNT,CHESS_LET_CNT));
						return true;
					case K_UPARROW:
					case K_KP_UPARROW:
						if ( ! chess_curr_pos )
							chess_set_curr_pos("d5");
						else
							chess_set_curr_pos(minigame_relative_tile(chess_curr_pos,0,1,CHESS_NUM_CNT,CHESS_LET_CNT));
						return true;
					case K_DOWNARROW:
					case K_KP_DOWNARROW:
						if ( ! chess_curr_pos )
							chess_set_curr_pos("d3");
						else
							chess_set_curr_pos(minigame_relative_tile(chess_curr_pos,0,-1,CHESS_NUM_CNT,CHESS_LET_CNT));
						return true;
					case K_ENTER:
					case K_KP_ENTER:
						chess_make_move(minigame);
						return true;
					case K_SPACE:
						chess_select_promotion(minigame, chess_curr_pos);
						return true;
				}
			}

			return false;
		}
		case "mouse_pressed":
		{
			if(...(0,int) == K_MOUSE1)
			{
				chess_make_move(minigame);
				return true;
			}
			else if(...(0,int) == K_MOUSE2)
			{
				chess_select_promotion(minigame, chess_curr_pos);
				return true;
			}

			return false;
		}
		case "mouse_moved":
		{
			vector mouse_pos = minigame_hud_normalize(mousepos,chess_boardpos,chess_boardsize);
			if ( minigame.minigame_flags == (CHESS_TURN_MOVE|minigame_self.team) )
			{
				chess_set_curr_pos(minigame_tile_name(mouse_pos,CHESS_NUM_CNT,CHESS_LET_CNT));
			}
			if ( ! chess_valid_tile(chess_curr_pos) )
				chess_set_curr_pos(string_null);

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
					sent.message = chess_turn_to_string(sent.minigame_flags);
					if ( sent.minigame_flags & minigame_self.team )
						minigame_prompt();
					else
						chess_set_curr_piece(minigame, NULL);
				}
			}
			if(sent.classname == "minigame_board_piece")
			{
				sent.chess_id = ReadByte();

				if(sf & MINIG_SF_UPDATE)
				{
					int sendf = ReadByte();
					sent.chess_passant = (sendf & BIT(0));
					sent.chess_moved = (sendf & BIT(1));
					sent.chess_king_checked = (sendf & BIT(2));
				}
			}

			return false;
		}
	}

	return false;
}

#endif