void spawnfunc_chess_board()
{
	if(!self.message) { error("Chess: board corner missing message string"); return; }

	self.classname = "chess_board";

	print(vtos(self.origin), self.message, "\n");

	WaypointSprite_SpawnFixed(strzone(strcat("Board corner: ", self.message)), self.origin, self, sprite, RADARICON_DANGER, '0 1 1');
}

string chess_NameFromID(float pid)
{
	switch(pid)
	{
		case CHESS_PIECE_PAWN: return "pawn";
		case CHESS_PIECE_KNIGHT: return "knight";
		case CHESS_PIECE_CASTLE: return "castle";
		case CHESS_PIECE_BISHOP: return "bishop";
		case CHESS_PIECE_QUEEN: return "queen";
		case CHESS_PIECE_KING: return "king";
	}

	return "";
}

float chess_IDFromName(string myname)
{
	switch(myname)
	{
		case "pawn": return CHESS_PIECE_PAWN;
		case "knight": return CHESS_PIECE_KNIGHT;
		case "castle": return CHESS_PIECE_CASTLE;
		case "bishop": return CHESS_PIECE_BISHOP;
		case "queen": return CHESS_PIECE_QUEEN;
		case "king": return CHESS_PIECE_KING;
	}

	return 0;
}

string chess_PrettyNameFromID(float pid)
{
	switch(pid)
	{
		case CHESS_PIECE_PAWN: return "Pawn";
		case CHESS_PIECE_KNIGHT: return "Knight";
		case CHESS_PIECE_CASTLE: return "Castle";
		case CHESS_PIECE_BISHOP: return "Bishop";
		case CHESS_PIECE_QUEEN: return "Queen";
		case CHESS_PIECE_KING: return "King";
	}

	return "";
}

void chess_Piece_Spawn(entity loc, float pid, float teamnumber)
{
	entity piece = spawn();

	piece.classname = "chess_piece";
	piece.chess_id = pid;
	piece.team = teamnumber;
	piece.netname = chess_NameFromID(pid);
	piece.message = chess_PrettyNameFromID(pid);

	setorigin(piece, loc.origin);
	setsize(piece, PL_MIN, PL_MAX);
	precache_model(strcat("models/chess/", piece.netname, ".md3"));
	setmodel(piece, strcat("models/chess/", piece.netname, ".md3"));

	WaypointSprite_SpawnFixed(strzone(piece.message), piece.origin, piece, sprite, RADARICON_DANGER, '0 1 1');

	loc.chess_piece = piece;
}

entity chess_board_base1(float index)
{
	return chess_board_base0[index-1];
}

void chess_SpawnPieces()
{
	chess_Piece_Spawn(chess_board_base0[0], CHESS_PIECE_CASTLE, NUM_TEAM_1);
	chess_Piece_Spawn(chess_board_base0[1], CHESS_PIECE_KNIGHT, NUM_TEAM_1);
	chess_Piece_Spawn(chess_board_base0[2], CHESS_PIECE_BISHOP, NUM_TEAM_1);
	chess_Piece_Spawn(chess_board_base0[3], CHESS_PIECE_QUEEN, NUM_TEAM_1);
	chess_Piece_Spawn(chess_board_base0[4], CHESS_PIECE_KING, NUM_TEAM_1);
	chess_Piece_Spawn(chess_board_base0[5], CHESS_PIECE_BISHOP, NUM_TEAM_1);
	chess_Piece_Spawn(chess_board_base0[6], CHESS_PIECE_KNIGHT, NUM_TEAM_1);
	chess_Piece_Spawn(chess_board_base0[7], CHESS_PIECE_CASTLE, NUM_TEAM_1);

	chess_Piece_Spawn(chess_board_base0[56], CHESS_PIECE_CASTLE, NUM_TEAM_2);
	chess_Piece_Spawn(chess_board_base0[57], CHESS_PIECE_KNIGHT, NUM_TEAM_2);
	chess_Piece_Spawn(chess_board_base0[58], CHESS_PIECE_BISHOP, NUM_TEAM_2);
	chess_Piece_Spawn(chess_board_base0[59], CHESS_PIECE_QUEEN, NUM_TEAM_2);
	chess_Piece_Spawn(chess_board_base0[60], CHESS_PIECE_KING, NUM_TEAM_2);
	chess_Piece_Spawn(chess_board_base0[61], CHESS_PIECE_BISHOP, NUM_TEAM_2);
	chess_Piece_Spawn(chess_board_base0[62], CHESS_PIECE_KNIGHT, NUM_TEAM_2);
	chess_Piece_Spawn(chess_board_base0[63], CHESS_PIECE_CASTLE, NUM_TEAM_2);

	float i;
	for(i = 8; i < 16; ++i) { chess_Piece_Spawn(chess_board_base0[i], CHESS_PIECE_PAWN, NUM_TEAM_1); }
	for(i = 48; i < 56; ++i) { chess_Piece_Spawn(chess_board_base0[i], CHESS_PIECE_PAWN, NUM_TEAM_2); }
}

void chess_Board_Spawn()
{
	// 4 corners
	entity c1 = world, c2 = world, c3 = world, c4 = world, head;

	for(head = world; (head = find(head, classname, "chess_board")); )
	{
		switch(head.message)
		{
			case "corner1": { c1 = head; break; }
			case "corner2": { c2 = head; break; }
			case "corner3": { c3 = head; break; }
			case "corner4": { c4 = head; break; }
		}
	}

	if(!c1 || !c2 || !c3 || !c4)
	{
		error("Chess: board missing a corner piece! Make sure map has all 4 chess_board entities with message set to cornerX (X being 1-4");
		return;
	}
	vector board_min;
	board_min_x = min(c1.origin_x,c2.origin_x,c3.origin_x,c4.origin_x);
	board_min_y = min(c1.origin_y,c2.origin_y,c3.origin_y,c4.origin_y);
	board_min_z = min(c1.origin_z,c2.origin_z,c3.origin_z,c4.origin_z);
	vector board_max;
	board_max_x = max(c1.origin_x,c2.origin_x,c3.origin_x,c4.origin_x);
	board_max_y = max(c1.origin_y,c2.origin_y,c3.origin_y,c4.origin_y);
	board_max_z = max(c1.origin_z,c2.origin_z,c3.origin_z,c4.origin_z);

	float pc, num = 0, ltrnum = 0;
	string ltr = "";
	float cell_width = (board_max_x - board_min_x) / 8;
	float cell_height = (board_max_y - board_min_y) / 8;
	vector cell_offset = '1 0 0' * cell_width/2 + '0 1 0' * cell_height/2;

	for(pc = 0; pc < 64; ++pc)
	{
		if(pc == 8 || pc == 16 || pc == 24 || pc == 32 || pc == 40 || pc == 48 || pc == 56) { ++ltrnum; }
		num = pc % 8;

		ltr = chr2str(str2chr("a", 0) + ltrnum);

		entity piece = spawn();
		piece.cnt = num;
		piece.count = ltrnum;
		piece.netname = ltr;
		piece.message = strcat(ltr, ftos(num+1));

		vector pos;
		pos_x = board_min_x + cell_width*num;
		pos_y = board_min_y + cell_height*ltrnum;
		pos_z = board_max_z;
		setorigin(piece, pos+cell_offset );
		setsize(piece, PL_MIN, PL_MAX);
		//WaypointSprite_SpawnFixed(strzone(piece.message), piece.origin, piece, sprite, RADARICON_DANGER, '0 1 1');

		chess_board_base0[pc] = piece;
	}

	chess_SpawnPieces();
}

entity chess_Board(entity loc, float to)
{
	float newloc = loc.cnt + CHESS_MOVE(to);
	if(newloc > 64 || newloc < 1) { return world; }
	return chess_board_base1(newloc);
}

float chess_Move_Valid(entity oldloc, entity loc);
entity chess_King_SafeMove(entity king, entity loc)
{
	float i;
	entity piece;
	for(i = 1; i <= 64; ++i)
	{
		piece = (chess_board_base1(i)).chess_piece;
		if(piece)
		if(DIFF_TEAM(king, piece))
		if(chess_Move_Valid(chess_board_base1(i), loc))
			return piece;
	}
	return world;
}

float chess_KingWouldBeSafe(entity oldloc, entity loc)
{
	entity tmp_entity, piece, king = world;

	piece = oldloc.chess_piece;
	tmp_entity = loc.chess_piece;

	if(SAME_TEAM(piece, tmp_entity)) { return FALSE; } // oops, let's fail here

	oldloc.chess_piece = world;
	loc.chess_piece = piece;

	float i;
	for(i = 1; i <= 64; ++i)
	{
		if(chess_board_base1(i).chess_piece)
		if(chess_board_base1(i).chess_piece.chess_id == CHESS_PIECE_KING)
		if(SAME_TEAM(chess_board_base1(i).chess_piece, piece))
		{
			king = chess_board_base1(i);
			break;
		}
	}

	float safe = (chess_King_SafeMove(king.chess_piece, king) == world);

	oldloc.chess_piece = piece;
	loc.chess_piece = tmp_entity;

	return safe;
}

float chess_Move_Valid(entity oldloc, entity loc)
{
	entity piece = oldloc.chess_piece;
	float spot_free = (((!loc.chess_piece) || (DIFF_TEAM(piece, loc.chess_piece))) && chess_KingWouldBeSafe(oldloc, loc));

	switch(piece.chess_id)
	{
		case CHESS_PIECE_PAWN:
		{
			if(loc.chess_piece && (chess_Board(oldloc, CHESS_MOVE_UPLEFT) == loc || chess_Board(oldloc, CHESS_MOVE_UPRIGHT) == loc))
				return spot_free;

			if(!piece.chess_moved && chess_Board(oldloc, CHESS_MOVE_UP * 2) == loc && 
			   !(chess_Board(oldloc, CHESS_MOVE_UP * 2)).chess_piece && 
			   !(chess_Board(oldloc, CHESS_MOVE_UP)).chess_piece)
				return spot_free; // special double move handler

			if(chess_Board(oldloc, CHESS_MOVE_UP) == loc)
			{
				if(loc.chess_piece) { return FALSE; }
				return spot_free;
			}
			break;
		}
		case CHESS_PIECE_KNIGHT:
		{
			if(chess_Board(oldloc, 10) == loc) { return spot_free; }
			if(chess_Board(oldloc, -10) == loc) { return spot_free; }
			if(chess_Board(oldloc, 6) == loc) { return spot_free; }
			if(chess_Board(oldloc, -6) == loc) { return spot_free; }
			if(chess_Board(oldloc, 17) == loc) { return spot_free; }
			if(chess_Board(oldloc, -17) == loc) { return spot_free; }
			if(chess_Board(oldloc, 15) == loc) { return spot_free; }
			if(chess_Board(oldloc, -15) == loc) { return spot_free; }
			break;
		}
		case CHESS_PIECE_CASTLE:
		{
			float i;
			for(i = oldloc.cnt + 1; i <= 64; ++i)
			{
				if((chess_board_base1(i)).count != oldloc.count) { break; }
				if((chess_board_base1(i)).chess_piece && (chess_board_base1(i)).chess_piece != loc) { break; }
				if(chess_Board(oldloc, i) == loc)
					return spot_free;
			}
			for(i = oldloc.cnt - 1; i > 0; --i)
			{
				if((chess_board_base1(i)).count != oldloc.count) { break; }
				if((chess_board_base1(i)).chess_piece && (chess_board_base1(i)).chess_piece != loc) { break; }
				if(chess_Board(oldloc, i) == loc)
					return spot_free;
			}
			for(i = oldloc.cnt + 8; i <= 64; i += 8)
			{
				if((chess_board_base1(i)).chess_piece && (chess_board_base1(i)).chess_piece != loc) { break; }
				if(chess_Board(oldloc, i) == loc)
					return spot_free;
			}
			for(i = oldloc.cnt - 8; i > 0; i -= 8)
			{
				if((chess_board_base1(i)).chess_piece && (chess_board_base1(i)).chess_piece != loc) { break; }
				if(chess_Board(oldloc, i) == loc)
					return spot_free;
			}
			break;
		}
		case CHESS_PIECE_BISHOP:
		{
			float i;
			for(i = oldloc.cnt + 9; i <= 64; i += 9)
			{
				if((chess_board_base1(i)).count != oldloc.count) { break; }
				if((chess_board_base1(i)).chess_piece && (chess_board_base1(i)).chess_piece != loc) { break; }
				if(chess_Board(oldloc, i) == loc)
					return spot_free;
			}
			for(i = oldloc.cnt - 9; i > 0; i -= 9)
			{
				if((chess_board_base1(i)).count != oldloc.count) { break; }
				if((chess_board_base1(i)).chess_piece && (chess_board_base1(i)).chess_piece != loc) { break; }
				if(chess_Board(oldloc, i) == loc)
					return spot_free;
			}
			for(i = oldloc.cnt + 7; i <= 64; i += 7)
			{
				if((chess_board_base1(i)).chess_piece && (chess_board_base1(i)).chess_piece != loc) { break; }
				if(chess_Board(oldloc, i) == loc)
					return spot_free;
			}
			for(i = oldloc.cnt - 7; i > 0; i -= 7)
			{
				if((chess_board_base1(i)).chess_piece && (chess_board_base1(i)).chess_piece != loc) { break; }
				if(chess_Board(oldloc, i) == loc)
					return spot_free;
			}
			break;
		}
		case CHESS_PIECE_QUEEN:
		{
			float i;
			for(i = oldloc.cnt + 9; i <= 64; i += 9)
			{
				if((chess_board_base1(i)).count != oldloc.count) { break; }
				if((chess_board_base1(i)).chess_piece && (chess_board_base1(i)).chess_piece != loc) { break; }
				if(chess_Board(oldloc, i) == loc)
					return spot_free;
			}
			for(i = oldloc.cnt - 9; i > 0; i -= 9)
			{
				if((chess_board_base1(i)).count != oldloc.count) { break; }
				if((chess_board_base1(i)).chess_piece && (chess_board_base1(i)).chess_piece != loc) { break; }
				if(chess_Board(oldloc, i) == loc)
					return spot_free;
			}
			for(i = oldloc.cnt + 7; i <= 64; i += 7)
			{
				if((chess_board_base1(i)).chess_piece && (chess_board_base1(i)).chess_piece != loc) { break; }
				if(chess_Board(oldloc, i) == loc)
					return spot_free;
			}
			for(i = oldloc.cnt - 7; i > 0; i -= 7)
			{
				if((chess_board_base1(i)).chess_piece && (chess_board_base1(i)).chess_piece != loc) { break; }
				if(chess_Board(oldloc, i) == loc)
					return spot_free;
			}
			for(i = oldloc.cnt + 1; i <= 64; ++i)
			{
				if((chess_board_base1(i)).count != oldloc.count) { break; }
				if((chess_board_base1(i)).chess_piece && (chess_board_base1(i)).chess_piece != loc) { break; }
				if(chess_Board(oldloc, i) == loc)
					return spot_free;
			}
			for(i = oldloc.cnt - 1; i > 0; --i)
			{
				if((chess_board_base1(i)).count != oldloc.count) { break; }
				if((chess_board_base1(i)).chess_piece && (chess_board_base1(i)).chess_piece != loc) { break; }
				if(chess_Board(oldloc, i) == loc)
					return spot_free;
			}
			for(i = oldloc.cnt + 8; i <= 64; i += 8)
			{
				if((chess_board_base1(i)).chess_piece && (chess_board_base1(i)).chess_piece != loc) { break; }
				if(chess_Board(oldloc, i) == loc)
					return spot_free;
			}
			for(i = oldloc.cnt - 8; i > 0; i -= 8)
			{
				if((chess_board_base1(i)).chess_piece && (chess_board_base1(i)).chess_piece != loc) { break; }
				if(chess_Board(oldloc, i) == loc)
					return spot_free;
			}
			break;
		}
		case CHESS_PIECE_KING:
		{
			float safe = chess_King_SafeMove(piece, loc) == world;
			if(!piece.chess_moved && !piece.chess_check)
			{
				if(chess_current_team == NUM_TEAM_1)
				{
					if(loc.cnt == 7)
					if(!(chess_board_base1(8)).chess_moved)
					if(!(chess_board_base1(6)).chess_piece)
					if(!(chess_board_base1(7)).chess_piece)
						return safe ? 2 : 0;
					if(loc.cnt == 3)
					if(!(chess_board_base1(1)).chess_moved)
					if(!(chess_board_base1(2)).chess_piece)
					if(!(chess_board_base1(3)).chess_piece)
					if(!(chess_board_base1(4)).chess_piece)
						return safe ? 3 : 0;

				}
				else
				{
					if(loc.cnt == 63)
					if(!(chess_board_base1(64)).chess_moved)
					if(!(chess_board_base1(63)).chess_piece)
					if(!(chess_board_base1(62)).chess_piece)
						return safe ? 4 : 0;
					if(loc.cnt == 59)
					if(!(chess_board_base1(57)).chess_moved)
					if(!(chess_board_base1(58)).chess_piece)
					if(!(chess_board_base1(59)).chess_piece)
					if(!(chess_board_base1(60)).chess_piece)
						return safe ? 5 : 0;

				}
			}

			if(chess_Board(oldloc, CHESS_MOVE_UP) == loc) { return safe; }
			if(chess_Board(oldloc, CHESS_MOVE_DN) == loc) { return safe; }
			if(chess_Board(oldloc, CHESS_MOVE_LEFT) == loc) { return safe; }
			if(chess_Board(oldloc, CHESS_MOVE_RIGHT) == loc) { return safe; }
			if(chess_Board(oldloc, CHESS_MOVE_UPRIGHT) == loc) { return safe; }
			if(chess_Board(oldloc, CHESS_MOVE_UPLEFT) == loc) { return safe; }
			if(chess_Board(oldloc, CHESS_MOVE_DNLEFT) == loc) { return safe; }
			if(chess_Board(oldloc, CHESS_MOVE_DNRIGHT) == loc) { return safe; }
			break;
		}
	}

	return FALSE;
}

void chess_Piece_Taken(entity loc)
{
	entity piece = loc.chess_piece;
	pointparticles(particleeffectnum("explosion_medium"), piece.origin, '0 0 0', 1);
	sound(self, CH_SHOTS, W_Sound("rocket_impact"), VOL_BASE, ATTEN_NORM);
}

float chess_Move(entity piece, entity loc)
{
	if(!piece || !loc || !piece.chess_piece) { return FALSE; }
	if(!piece.cnt || !loc.cnt) { return FALSE; }

	float valid_move = chess_Move_Valid(piece, loc);
	if(!valid_move) { return FALSE; }

	entity realpiece = piece.chess_piece;

	if(loc.chess_piece) { chess_Piece_Taken(loc); }

	if(realpiece.chess_id == CHESS_PIECE_PAWN)
	if((loc.count == 8 && realpiece.team == NUM_TEAM_1) || (loc.count == 1 && realpiece.team == NUM_TEAM_2))
	{
		float myteam = realpiece.team;
		// a pawn made it to the end of the board!
		remove(realpiece); // so kill it...

		chess_Piece_Spawn(loc, ((chess_current_player.cvar_cl_chess_selection == "") ? CHESS_PIECE_QUEEN : chess_IDFromName(chess_current_player.cvar_cl_chess_selection)), myteam);
		realpiece = loc.chess_piece; // the below check resets this, but oh well
	}

	piece.chess_piece = world;
	loc.chess_piece = realpiece;

	// silly handling of castling
	switch(valid_move)
	{
		case 2: { (chess_board_base1(6)).chess_piece = (chess_board_base1(8)).chess_piece; (chess_board_base1(8)).chess_piece = world; break; }
		case 3: { (chess_board_base1(4)).chess_piece = (chess_board_base1(1)).chess_piece; (chess_board_base1(1)).chess_piece = world; break; }
		case 4: { (chess_board_base1(62)).chess_piece = (chess_board_base1(64)).chess_piece; (chess_board_base1(64)).chess_piece = world; break; }
		case 5: { (chess_board_base1(60)).chess_piece = (chess_board_base1(57)).chess_piece; (chess_board_base1(57)).chess_piece = world; break; }
	}

	return TRUE;
}

void chess_SwitchTeam()
{
	chess_current_team = (chess_current_team == NUM_TEAM_1) ? NUM_TEAM_2 : NUM_TEAM_1;
	entity head;
	RandomSelection_Init();
	FOR_EACH_PLAYER(head)
	{
		if(head.team == chess_current_team)
			RandomSelection_Add(head, 0, string_null, 1, 1);
	}

	chess_current_player = RandomSelection_chosen_ent;
}

float Sigh(float mv, entity loc) { return chess_KingWouldBeSafe(loc, chess_Board(loc, mv)); }

float chess_PieceCanMove(entity loc)
{
	entity piece = loc.chess_piece;

	switch(piece.chess_id)
	{
		case CHESS_PIECE_PAWN:
			return
			(	((Sigh(7, loc) && DIFF_TEAM(piece, (chess_Board(loc, 7)))) || (Sigh(9, loc) && DIFF_TEAM(piece, (chess_Board(loc, 9)))))
			||	(Sigh(CHESS_MOVE_UP, loc) && !(chess_Board(loc, CHESS_MOVE_UP)).chess_piece)
			||	(Sigh(8, loc) && !piece.chess_moved && !(chess_Board(loc, 8)).chess_piece && !(chess_Board(loc, 8 * 2)).chess_piece)
			);
		case CHESS_PIECE_KNIGHT:
			return
			(	(Sigh(10, loc) && (DIFF_TEAM(piece, (chess_Board(loc, 10))) || !(chess_Board(loc, 10)).chess_piece))
			||	(Sigh(-10, loc) && (DIFF_TEAM(piece, (chess_Board(loc, -10))) || !(chess_Board(loc, -10)).chess_piece))
			||	(Sigh(6, loc) && (DIFF_TEAM(piece, (chess_Board(loc, 6))) || !(chess_Board(loc, 6)).chess_piece))
			||	(Sigh(-6, loc) && (DIFF_TEAM(piece, (chess_Board(loc, -6))) || !(chess_Board(loc, -6)).chess_piece))
			||	(Sigh(17, loc) && (DIFF_TEAM(piece, (chess_Board(loc, 17))) || !(chess_Board(loc, 17)).chess_piece))
			||	(Sigh(-17, loc) && (DIFF_TEAM(piece, (chess_Board(loc, -17))) || !(chess_Board(loc, -17)).chess_piece))
			||	(Sigh(15, loc) && (DIFF_TEAM(piece, (chess_Board(loc, 15))) || !(chess_Board(loc, 15)).chess_piece))
			||	(Sigh(-15, loc) && (DIFF_TEAM(piece, (chess_Board(loc, -15))) || !(chess_Board(loc, -15)).chess_piece))
			);
		case CHESS_PIECE_CASTLE:
		{
			float i;
			for(i = loc.cnt + 1; i <= 64; ++i)
			{
				if((chess_board_base1(i)).count != loc.count) { break; }
				if(chess_KingWouldBeSafe(loc, chess_board_base1(i)))
				if(DIFF_TEAM(piece, chess_board_base1(i)) || !(chess_board_base1(i)).chess_piece) { return TRUE; }
			}
			for(i = loc.cnt - 1; i > 0; --i)
			{
				if((chess_board_base1(i)).count != loc.count) { break; }
				if(chess_KingWouldBeSafe(loc, chess_board_base1(i)))
				if(DIFF_TEAM(piece, chess_board_base1(i)) || !(chess_board_base1(i)).chess_piece) { return TRUE; }
			}
			for(i = loc.cnt + 8; i <= 64; i += 8)
				if(chess_KingWouldBeSafe(loc, chess_board_base1(i)))
				if(DIFF_TEAM(piece, chess_board_base1(i)) || !(chess_board_base1(i)).chess_piece) { return TRUE; }
			for(i = loc.cnt - 8; i > 0; i -= 8)
				if(chess_KingWouldBeSafe(loc, chess_board_base1(i)))
				if(DIFF_TEAM(piece, chess_board_base1(i)) || !(chess_board_base1(i)).chess_piece) { return TRUE; }
			break;
		}
		case CHESS_PIECE_BISHOP:
		{
			float i;
			for(i = loc.cnt + 9; i <= 64; i += 9)
			{
				if((chess_board_base1(i)).count != loc.count) { break; }
				if(chess_KingWouldBeSafe(loc, chess_board_base1(i)))
				if(DIFF_TEAM(piece, chess_board_base1(i)) || !(chess_board_base1(i)).chess_piece) { return TRUE; }
			}
			for(i = loc.cnt - 9; i > 0; i -= 9)
			{
				if((chess_board_base1(i)).count != loc.count) { break; }
				if(chess_KingWouldBeSafe(loc, chess_board_base1(i)))
				if(DIFF_TEAM(piece, chess_board_base1(i)) || !(chess_board_base1(i)).chess_piece) { return TRUE; }
			}
			for(i = loc.cnt + 7; i <= 64; i += 7)
				if(chess_KingWouldBeSafe(loc, chess_board_base1(i)))
				if(DIFF_TEAM(piece, chess_board_base1(i)) || !(chess_board_base1(i)).chess_piece) { return TRUE; }
			for(i = loc.cnt - 7; i > 0; i -= 7)
				if(chess_KingWouldBeSafe(loc, chess_board_base1(i)))
				if(DIFF_TEAM(piece, chess_board_base1(i)) || !(chess_board_base1(i)).chess_piece) { return TRUE; }
			break;
		}
		case CHESS_PIECE_QUEEN:
		{
			float i;
			for(i = loc.cnt + 1; i <= 64; ++i)
			{
				if((chess_board_base1(i)).count != loc.count) { break; }
				if(chess_KingWouldBeSafe(loc, chess_board_base1(i)))
				if(DIFF_TEAM(piece, chess_board_base1(i)) || !(chess_board_base1(i)).chess_piece) { return TRUE; }
			}
			for(i = loc.cnt - 1; i > 0; --i)
			{
				if((chess_board_base1(i)).count != loc.count) { break; }
				if(chess_KingWouldBeSafe(loc, chess_board_base1(i)))
				if(DIFF_TEAM(piece, chess_board_base1(i)) || !(chess_board_base1(i)).chess_piece) { return TRUE; }
			}
			for(i = loc.cnt + 8; i <= 64; i += 8)
				if(chess_KingWouldBeSafe(loc, chess_board_base1(i)))
				if(DIFF_TEAM(piece, chess_board_base1(i)) || !(chess_board_base1(i)).chess_piece) { return TRUE; }
			for(i = loc.cnt - 8; i > 0; i -= 8)
				if(chess_KingWouldBeSafe(loc, chess_board_base1(i)))
				if(DIFF_TEAM(piece, chess_board_base1(i)) || !(chess_board_base1(i)).chess_piece) { return TRUE; }
			for(i = loc.cnt + 9; i <= 64; i += 9)
			{
				if((chess_board_base1(i)).count != loc.count) { break; }
				if(chess_KingWouldBeSafe(loc, chess_board_base1(i)))
				if(DIFF_TEAM(piece, chess_board_base1(i)) || !(chess_board_base1(i)).chess_piece) { return TRUE; }
			}
			for(i = loc.cnt - 9; i > 0; i -= 9)
			{
				if((chess_board_base1(i)).count != loc.count) { break; }
				if(chess_KingWouldBeSafe(loc, chess_board_base1(i)))
				if(DIFF_TEAM(piece, chess_board_base1(i)) || !(chess_board_base1(i)).chess_piece) { return TRUE; }
			}
			for(i = loc.cnt + 7; i <= 64; i += 7)
				if(chess_KingWouldBeSafe(loc, chess_board_base1(i)))
				if(DIFF_TEAM(piece, chess_board_base1(i)) || !(chess_board_base1(i)).chess_piece) { return TRUE; }
			for(i = loc.cnt - 7; i > 0; i -= 7)
				if(chess_KingWouldBeSafe(loc, chess_board_base1(i)))
				if(DIFF_TEAM(piece, chess_board_base1(i)) || !(chess_board_base1(i)).chess_piece) { return TRUE; }
			break;
		}
		case CHESS_PIECE_KING:
			return
			(	chess_King_SafeMove(piece, chess_Board(loc, CHESS_MOVE_UP))
			||	chess_King_SafeMove(piece, chess_Board(loc, CHESS_MOVE_DN))
			||	chess_King_SafeMove(piece, chess_Board(loc, CHESS_MOVE_LEFT))
			||	chess_King_SafeMove(piece, chess_Board(loc, CHESS_MOVE_RIGHT))
			||	chess_King_SafeMove(piece, chess_Board(loc, CHESS_MOVE_UPRIGHT))
			||	chess_King_SafeMove(piece, chess_Board(loc, CHESS_MOVE_UPLEFT))
			||	chess_King_SafeMove(piece, chess_Board(loc, CHESS_MOVE_DNLEFT))
			||	chess_King_SafeMove(piece, chess_Board(loc, CHESS_MOVE_DNRIGHT))
			);
	}

	return FALSE;
}

float chess_CheckMate()
{
	entity king = world, piece = world;
	float i;
	for(i = 1; i <= 64; ++i)
	{
		if(chess_board_base1(i).chess_piece.chess_id == CHESS_PIECE_KING)
		if(chess_board_base1(i).chess_piece.team == chess_current_team)
		{
			king = chess_board_base1(i).chess_piece;
			piece = chess_board_base1(i);
			break;
		}
	}

	if(!king) { print("WTF no king found?\n"); return FALSE; }

	king.chess_checked = chess_King_SafeMove(king, piece);
	king.chess_check = (king.chess_checked != world);

	if(!chess_PieceCanMove(piece))
	if(king.chess_check)
		return TRUE;
	else
	{
		// stalemate... or is it? check to see if another piece can move (starting to get into the resource intensive stuff)
		for(i = 1; i <= 64; ++i)
		{
			if(chess_board_base1(i).chess_piece.team == chess_current_team)
			{
				if(chess_PieceCanMove(chess_board_base1(i)))
					return FALSE; // phew, someone can move!
			}
		}
		return -1; // stalemate!
	}

	return FALSE;
}

// Round handler
void chess_count_alive_players()
{
	entity e;
	total_players = redalive = bluealive = yellowalive = pinkalive = 0;
	FOR_EACH_PLAYER(e)
	{
		switch(e.team)
		{
			case NUM_TEAM_1: ++total_players; if(e.health >= 1 && e.frozen != 1) ++redalive; break;
			case NUM_TEAM_2: ++total_players; if(e.health >= 1 && e.frozen != 1) ++bluealive; break;
		}
	}
	FOR_EACH_REALCLIENT(e)
	{
		e.redalive_stat = redalive;
		e.bluealive_stat = bluealive;
		e.yellowalive_stat = yellowalive;
		e.pinkalive_stat = pinkalive;
	}
}
#define CHESS_ALIVE_TEAMS() ((redalive > 0) + (bluealive > 0))
#define CHESS_ALIVE_TEAMS_OK() (CHESS_ALIVE_TEAMS() == 2)
.float chess_check_delay; // use a custom delay to prevent spam
float Chess_CheckWinner()
{
	entity head;
	if(time >= round_handler.chess_check_delay) { round_handler.chess_check_delay = time + 1; }
	else { return 0; }

	if(round_handler_GetEndTime() > 0 && round_handler_GetEndTime() - time <= 0)
	{
		RandomSelection_Init();
		bprint(chess_current_player.netname, " took too long, choosing another player (if available)\n");
		FOR_EACH_REALPLAYER(head)
		{
			if(head.team == chess_current_team && head != chess_current_player)
				RandomSelection_Add(head, 0, string_null, 1, 1);
		}
		chess_current_player = RandomSelection_chosen_ent;
		if(!chess_current_player)
		{
			bprint("No other teammates found, switching teams\n");
			chess_SwitchTeam();
		}
		round_handler.round_endtime += round_handler.round_timelimit; // extend timelimit for new player
		return 0;
	}

	float checkmate = chess_CheckMate();
	if(checkmate == -1)
	{
		bprint("Stalemate!\n");
		round_handler_Init(5, autocvar_g_chess_warmup, ((autocvar_g_chess_round_timelimit > 0) ? autocvar_g_chess_round_timelimit : 20));
		return 1;
	}
	if(!checkmate) { return FALSE; }

	if(checkmate)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, APP_TEAM_NUM_4(checkmate, CENTER_ROUND_TEAM_WIN_));
		Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_NUM_4(checkmate, INFO_ROUND_TEAM_WIN_));
	}

	round_handler_Init(5, autocvar_g_chess_warmup, ((autocvar_g_chess_round_timelimit > 0) ? autocvar_g_chess_round_timelimit : 20));
	chess_current_player = world;

	nades_Clear(world, TRUE);

	return 1;
}

float prev_total_players;
float Chess_CheckTeams()
{
	chess_count_alive_players();

	if(CHESS_ALIVE_TEAMS_OK())
	{
		if(prev_total_players > 0)
			Kill_Notification(NOTIF_ALL, world, MSG_CENTER_CPID, CPID_MISSING_TEAMS);
		prev_total_players = -1;
		return 1;
	}
	if(prev_total_players != total_players)
	{
		float p1 = 0, p2 = 0, p3 = 0, p4 = 0;
		if(!redalive) p1 = NUM_TEAM_1;
		if(!bluealive) p2 = NUM_TEAM_2;
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_MISSING_TEAMS, p1, p2, p3, p4);
		prev_total_players = total_players;
	}
	return 0;
}

void Chess_RoundStart()
{
	float i;
	for(i = 1; i <= 64; ++i)
	{
		if((chess_board_base1(i)).chess_piece) { remove(chess_board_base1(i).chess_piece.sprite); remove(chess_board_base1(i).chess_piece); }
		chess_board_base1(i).chess_piece = world;
	}

	chess_SpawnPieces();

	chess_SwitchTeam();
}

// mutator hooks
MUTATOR_HOOKFUNCTION(chess_PlayerCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return FALSE;

	if(cmd_name == "chess")
	{
		entity piece = world, move_to = world;
		float i;
		for(i = 1; i <= 64; ++i)
		{
			if((chess_board_base1(i)).message == argv(2)) { piece = chess_board_base1(i); }
			if((chess_board_base1(i)).message == argv(3)) { move_to = chess_board_base1(i); }
		}
		if(chess_current_player != self) { sprint(self, "It is not your turn\n"); return TRUE; }
		if(!argv(2) || !argv(3)) { sprint(self, "You must define a board square to move to. Example: cmd chess b2 b4\n"); return TRUE; }
		if(!chess_Move(piece, move_to)) { sprint(self, "Invalid move\n"); return TRUE; }
		return TRUE;
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(chess_GetCvars)
{
	GetCvars_handleString(get_cvars_s, get_cvars_f, cvar_cl_chess_selection, "cl_chess_selection");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(chess_GetTeamCount)
{
	ret_float = 2;
	return FALSE;
}

void chess_ScoreRules()
{
	ScoreRules_basics(2, SFL_SORT_PRIO_PRIMARY, 0, TRUE);
	ScoreInfo_SetLabel_TeamScore(ST_CHESS_CAPS, "caps", SFL_SORT_PRIO_PRIMARY);
	ScoreInfo_SetLabel_PlayerScore(SP_CHESS_CAPS, "caps", SFL_SORT_PRIO_SECONDARY);
	ScoreInfo_SetLabel_PlayerScore(SP_CHESS_TAKES, "takes", SFL_SORT_PRIO_SECONDARY);
	ScoreRules_basics_end();
}

void chess_DelayedInit() // Do this check with a delay so we can wait for teams to be set up.
{
	independent_players = 1; // to disable extra useless scores

	chess_ScoreRules();

	independent_players = 0;

	round_handler_Spawn(Chess_CheckTeams, Chess_CheckWinner, Chess_RoundStart);
	round_handler_Init(5, autocvar_g_chess_warmup, ((autocvar_g_chess_round_timelimit > 0) ? autocvar_g_chess_round_timelimit : 20));

	allowed_to_spawn = TRUE;

	entity board = spawn();
	InitializeEntity(board, chess_Board_Spawn, INITPRIO_FINDTARGET);
}

void chess_Initialize()
{
	precache_sound(W_Sound("rocket_impact"));
	InitializeEntity(world, chess_DelayedInit, INITPRIO_GAMETYPE);
}

MUTATOR_DEFINITION(gamemode_chess)
{
	MUTATOR_HOOK(SV_ParseClientCommand, chess_PlayerCommand, CBC_ORDER_ANY);
	MUTATOR_HOOK(GetCvars, chess_GetCvars, CBC_ORDER_ANY);
	MUTATOR_HOOK(GetTeamCount, chess_GetTeamCount, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		if(time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");
		chess_Initialize();
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		// we actually cannot roll back chess_Initialize here
		// BUT: we don't need to! If this gets called, adding always
		// succeeds.
	}

	MUTATOR_ONREMOVE
	{
		print("This is a game type and it cannot be removed at runtime.");
		return -1;
	}

	return 0;
}
