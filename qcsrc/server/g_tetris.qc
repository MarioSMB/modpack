/*

Installation:

compile with -DTETRIS

*/

#ifdef TETRIS

.vector tet_org;

float tet_vs_current_id;
float tet_vs_current_timeout;
.float tet_vs_id, tet_vs_addlines;
.float tet_highest_line;
.float tetris_on, tet_gameovertime, tet_drawtime, tet_autodown;
.vector piece_pos;
.float piece_type, next_piece, tet_score, tet_lines;
.float tet_piece_bucket;

// tetris_on states:
//   1 = running
//   2 = game over
//   3 = waiting for VS players

var float tet_high_score = 0;

vector TET_START_PIECE_POS = '5 1 0';
float TET_LINES = 22;
float TET_DISPLAY_LINES = 20;
float TET_WIDTH = 10;
string TET_EMPTY_LINE = "0000000000"; // must match TET_WIDTH
//character values
float TET_BORDER = 139;
float TET_BLOCK = 133;
float TET_SPACE = 160; // blankness



float TETKEY_UP = 1;
float TETKEY_DOWN = 2;
float TETKEY_LEFT = 4;
float TETKEY_RIGHT = 8;
float TETKEY_ROTLEFT = 16;
float TETKEY_ROTRIGHT = 32;
float TETKEY_DROP = 64;
string TET_PADDING_RIGHT = "\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0"; // get away from crosshair

float PIECES = 7;

float tet_line_buf;

float	SVC_CENTERPRINTa		= 26;

float Tetris_Level()
{
	return ((floor((self.tet_lines / 10)) + 1));
}

void tetsnd(string snd)
{
	play2(self, strcat("sounds/tetris/", snd));
}

/*
*********************************

Library Functions

*********************************
*/
void SetLine(float ln, string vl)
{
	if(ln < 1 || ln > TET_LINES)
		error("WTF");
	bufstr_set(tet_line_buf, ln + TET_LINES * num_for_edict(self), vl);
}

string GetLine(float ln)
{
	if(ln < 1 || ln > TET_LINES)
		error("WTF");
	if(ln < 1 || ln > TET_LINES)
		return TET_EMPTY_LINE;
	return bufstr_get(tet_line_buf, ln + TET_LINES * num_for_edict(self));
}

float GetXBlock(float x, string dat)
{
	if(x < 1 || x > TET_WIDTH)
		error("WTF");
	return stof(substring(dat, x-1, 1));
}

string SetXBlock(float x, string dat, float new)
{
	return strcat(
		substring(dat, 0, x-1),
		ftos(new),
		substring(dat, x, -1)
	);
}


float GetSquare(float x, float y)
{
	return GetXBlock(x,  GetLine(y));
}

void SetSquare(float x, float y, float val)
{
	string dat;
	dat = GetLine(y);
	dat  = SetXBlock(x, dat, val);
	SetLine(y, dat);
}

float PieceColor(float pc)
{
	if (pc == 1)
		return 3; // O
	else if (pc == 2)
		return 4; // J
	else if (pc == 3)
		return 7; // L // we don't have orange, let's use white instead!
	else if (pc == 4)
		return 5; // I
	else if (pc == 5)
		return 1; // Z
	else if (pc == 6)
		return 2; // S
	else if (pc == 7)
		return 6; // T
	else
		return 0;
}
vector PieceShape(float pc)
{
	if (pc == 1)
		return '20 20 0'; // O
	else if (pc == 2)
		return '1 21 0'; // J
	else if (pc == 3)
		return '16 21 0'; // L
	else if (pc == 4)
		return '0 85 0'; // I
	else if (pc == 5)
		return '5 20 0'; // Z
	else if (pc == 6)
		return '20 5 0'; // S
	else if (pc == 7)
		return '4 21 0'; // T
	else
		return '0 0 0';
}
vector PieceSize(float pc)
{
	if (pc == 1)
		return '2 2 0'; // O
	else if (pc == 2)
		return '3 2 0'; // J
	else if (pc == 3)
		return '3 2 0'; // L
	else if (pc == 4)
		return '4 1 0'; // I
	else if (pc == 5)
		return '3 2 0'; // Z
	else if (pc == 6)
		return '3 2 0'; // S
	else if (pc == 7)
		return '3 2 0'; // T
	else
		return '0 0 0';
}
vector PieceCenter(float pc)
{
	if(pc == 1)
		return '2.5 1.5 0'; // O
	else if (pc == 2)
		return '2 2 0'; // J
	else if (pc == 3)
		return '2 2 0'; // L
	else if (pc == 4)
		return '2.5 2.5 0'; // I
	else if (pc == 5)
		return '2 2 0'; // Z
	else if (pc == 6)
		return '2 2 0'; // S
	else if (pc == 7)
		return '2 2 0'; // T
	else
		return '0 0 0';
}

// do x 1..4 and y 1..4 in case of rotation
float PieceMetric(float x, float y, float rot, float pc)
{
	float t;
	vector ce;

	// return bits of a piece
	ce = PieceCenter(pc);
	if (rot == 1) // 90 degrees
	{
		// x+cx, y+cy -> -y+cx, x+cy
		// X, Y       -> -Y+cy+cx, X-cx+cy
		//   x = X-cx
		//   y = Y-cy
		t = y;
		y = x - ce_x + ce_y;
		x = -t + ce_x + ce_y;
	}
	else if (rot == 2)//180
	{
		x = 2 * ce_x - x;
		y = 2 * ce_y - y;
	}
	else if (rot == 3) // 270
	{
		// x+cx, y+cy -> y+cx, -x+cy
		// X, Y       -> Y-cy+cx, -X+cx+cy
		//   x = X-cx
		//   y = Y-cy
		t = y;
		y = -x + ce_y + ce_x;
		x =  t - ce_y + ce_x;
	}
	if (x < 1 || y < 1 || x > 4 || y > 2)
		return 0;
	ce = PieceShape(pc);
	if (y == 1)
		return !!(ce_x & pow(4, x-1)); // first row
	else if (y == 2)
		return !!(ce_y & pow(4, x-1)); // second row
	else
		return 0; // illegal parms
}
vector tet_piecemins;
vector tet_piecemaxs;
void PieceMinsMaxs(float rot, float pc)
{
	vector sz, ce;
	float t;
	vector v;

	sz = PieceSize(pc);
	ce = PieceCenter(pc);
	// 1 = 2..2
	// 2 = 2..3
	// 3 = 1..3
	// 4 = 1..4
	tet_piecemins_x = floor(3.0 - sz_x * 0.5);
	tet_piecemaxs_x = floor(2.0 + sz_x * 0.5);
	if(sz_y == 1)
	{
		// special case for "I"
		tet_piecemins_y = tet_piecemaxs_y = 2;
	}
	else
	{
		tet_piecemins_y = 1;
		tet_piecemaxs_y = sz_y;
	}
	//print(sprintf("ce%v sz%v mi%v ma%v\n", ce, sz, tet_piecemins, tet_piecemaxs));
	if (rot == 1) // 90 degrees
	{
		t = tet_piecemins_y;
		tet_piecemins_y = -tet_piecemins_x + ce_y + ce_x;
		tet_piecemins_x = t - ce_y + ce_x;
		t = tet_piecemaxs_y;
		tet_piecemaxs_y = -tet_piecemaxs_x + ce_y + ce_x;
		tet_piecemaxs_x = t - ce_y + ce_x;
		// swap mins_y, maxs_y
		t = tet_piecemins_y;
		tet_piecemins_y = tet_piecemaxs_y;
		tet_piecemaxs_y = t;
		// TODO OPTIMIZE
	}
	else if (rot == 2)//180
	{
		v = tet_piecemins;
		tet_piecemins = 2 * ce - tet_piecemaxs;
		tet_piecemaxs = 2 * ce - v;
	}
	else if (rot == 3) // 270
	{
		t = tet_piecemins_y;
		tet_piecemins_y = tet_piecemins_x - ce_x + ce_y;
		tet_piecemins_x = -t + ce_x + ce_y;
		t = tet_piecemaxs_y;
		tet_piecemaxs_y = tet_piecemaxs_x - ce_x + ce_y;
		tet_piecemaxs_x = -t + ce_x + ce_y;
		// swap mins_x, maxs_x
		t = tet_piecemins_x;
		tet_piecemins_x = tet_piecemaxs_x;
		tet_piecemaxs_x = t;
		// TODO OPTIMIZE
	}
#ifdef VERIFY
	print(vtos(tet_piecemins), "-");
	print(vtos(tet_piecemaxs), "\n");
	if(tet_piecemins_x > tet_piecemaxs_x)
		error("inconsistent mins/maxs");
	if(tet_piecemins_y > tet_piecemaxs_y)
		error("inconsistent mins/maxs");
	float i, j;
	vector realmins, realmaxs;
	realmins = '4 4 0';
	realmaxs = '1 1 0';
	for(i = 1; i <= 4; ++i)
		for(j = 1; j <= 4; ++j)
			if(PieceMetric(i, j, rot, pc))
			{
				realmins_x = min(realmins_x, i);
				realmins_y = min(realmins_y, j);
				realmaxs_x = max(realmaxs_x, i);
				realmaxs_y = max(realmaxs_y, j);
			}
	if(realmins != tet_piecemins || realmaxs != tet_piecemaxs)
		error(sprintf("incorrect mins/maxs: %v %v in %d rot %d mins %v maxs %v\n", realmins, realmaxs, rot, pc, tet_piecemins, tet_piecemaxs));
#endif
}
/*
*********************************

Draw

*********************************
*/


/* some prydon gate functions to make life easier....

somewhat modified because we don't need all the fanciness Prydon Gate is capable of

*/

void WriteTetrisString(string s)
{
	WriteUnterminatedString(MSG_ONE, strconv(0, 2, 2, s));
}

float pnum(float num, float dig)
{
	float f, i;
	if (num < 0)
	{
		WriteChar(MSG_ONE, 173);
		num = 0 - num;
	}
	f = floor(num / 10);
	num = num - (f * 10);
	if (f)
		dig = pnum(f, dig+1);
	else
	{
		// pad to 6
		for (i = 0; i < (5 - dig); i = i + 1)
			WriteChar(MSG_ONE, TET_SPACE);
	}
	WriteChar(MSG_ONE, 176 + num);
	return dig;
}

void DrawLine(float ln)
{
	float x, d;
	WriteChar(MSG_ONE, TET_BORDER);

	for (x = 1; x <= TET_WIDTH; x = x + 1)
	{
		d = GetSquare(x, ln + TET_LINES - TET_DISPLAY_LINES);
		if (d)
		{
			WriteChar(MSG_ONE, '^');
			WriteChar(MSG_ONE, d + '0');
			WriteChar(MSG_ONE, TET_BLOCK);
		}
		else
			WriteChar(MSG_ONE, TET_SPACE);
	}
	WriteChar(MSG_ONE, '^');
	WriteChar(MSG_ONE, '7');
	WriteChar(MSG_ONE, TET_BORDER);
}

void DrawPiece(float pc, float ln)
{
	float x, d, piece_ln, pcolor;
	vector piece_dat;
	pcolor = PieceColor(pc);
	WriteChar(MSG_ONE, TET_SPACE); // pad to 6

	piece_dat = PieceShape(pc);
	if (ln == 1)
		piece_ln = piece_dat_x;
	else
		piece_ln = piece_dat_y;
	for (x = 1; x <= 4; x = x + 1)
	{
		if (piece_ln & pow(4, x-1))
		{
			WriteChar(MSG_ONE, '^');
			WriteChar(MSG_ONE, pcolor + '0');
			WriteChar(MSG_ONE, TET_BLOCK);
		}
		else
			WriteChar(MSG_ONE, TET_SPACE);
	}
	WriteChar(MSG_ONE, TET_SPACE);	// pad to 6
}
void Draw_Tetris()
{
	float i;
	entity head;
	msg_entity = self;
	WriteChar(MSG_ONE, SVC_CENTERPRINTa);
	if(autocvar_g_bastet)
	{
		WriteTetrisString("NEVER GONNA GIVE YOU");
		WriteChar(MSG_ONE, 10);
	}
	// decoration
	for (i = 1; i <= (TET_WIDTH + 2); i = i + 1)
		WriteChar(MSG_ONE, TET_BORDER);
	WriteTetrisString("      ");
	WriteUnterminatedString(MSG_ONE, TET_PADDING_RIGHT);
	WriteChar(MSG_ONE, 10);
	for (i = 1; i <= TET_DISPLAY_LINES; i = i + 1)
	{
		if(self.tetris_on == 2)
			WriteTetrisString(" GAME  OVER ");
		else if(self.tetris_on == 3)
			WriteTetrisString("PLEASE  WAIT");
		else
			DrawLine(i);
		if (i == 1)
			WriteTetrisString(autocvar_g_bastet ? " THAT " : " NEXT ");
		else if (i == 3)
			DrawPiece(self.next_piece, 1);
		else if (i == 4)
			DrawPiece(self.next_piece, 2);
		else if (i == 6)
			WriteTetrisString(" LINES");
		else if (i == 7)
			pnum(self.tet_lines, 0);
		else if (i == 9)
			WriteTetrisString(" SCORE");
		else if (i == 10)
			pnum(self.tet_score, 0);
		else if (i == 12)
			WriteTetrisString(" HIGH ");
		else if (i == 13)
			WriteTetrisString(" SCORE");
		else if (i == 14)
			pnum(tet_high_score, 0);
		else if (i == 16)
			WriteTetrisString(" LEVEL");
		else if (i == 17)
			pnum(Tetris_Level(), 0);
		else
			WriteTetrisString("      ");
		WriteUnterminatedString(MSG_ONE, TET_PADDING_RIGHT);
		WriteChar(MSG_ONE, 10);
	}
	// decoration

	for (i = 1; i <= (TET_WIDTH + 2); i = i + 1)
		WriteChar(MSG_ONE, TET_BORDER);
	WriteTetrisString("      ");
	WriteUnterminatedString(MSG_ONE, TET_PADDING_RIGHT);
	WriteChar(MSG_ONE, 10);

	// VS game status
	if(self.tet_vs_id)
	{
		WriteChar(MSG_ONE, 10);
		WriteChar(MSG_ONE, 10);
		if(self.tetris_on == 3)
		{
			WriteUnterminatedString(MSG_ONE, strcat("WAITING FOR OTHERS (", ftos(ceil(tet_vs_current_timeout - time)), " SEC)\n"));
		}

		WriteChar(MSG_ONE, 10);
		FOR_EACH_REALCLIENT(head) if(head.tetris_on) if(head.tet_vs_id == self.tet_vs_id)
		{
			if(head == self)
				WriteUnterminatedString(MSG_ONE, ">");
			else
				WriteUnterminatedString(MSG_ONE, " ");
			if(head.tetris_on == 2)
				WriteUnterminatedString(MSG_ONE, "   X_X");
			else
				pnum(head.tet_highest_line, 0);
			WriteUnterminatedString(MSG_ONE, " ");
			WriteUnterminatedString(MSG_ONE, head.netname);
			WriteChar(MSG_ONE, 10);
		}
	}

	WriteChar(MSG_ONE, 0);
}
/*
*********************************

Game Functions

*********************************
*/

// reset the game
void ResetTetris()
{
	float i;

	if(!tet_line_buf)
		tet_line_buf = buf_create();

	for (i=1; i<=TET_LINES; i = i + 1)
		SetLine(i, TET_EMPTY_LINE);
	self.piece_pos = '0 0 0';
	self.piece_type = 0;
	self.next_piece = self.tet_lines = self.tet_score = 0;
	self.tet_piece_bucket = 0;
}

void Tet_GameExit()
{
	centerprint(self, " ");
	self.tetris_on = 0;
	self.tet_vs_id = 0;
	ResetTetris();
	self.movetype = MOVETYPE_WALK;
}

void PrintField()
{
	string l;
	float r, c;
	for(r = 1; r <= TET_LINES; ++r)
	{
		l = GetLine(r);
		print(">");
		for(c = 1; c <= TET_WIDTH; ++c)
		{
			print(ftos(GetXBlock(c, l)));
		}
		print("\n");
	}
}

float BastetEvaluate()
{
	float height;
	string l;
	float lines;
	float score, score_save;
	string occupied, occupied_save;
	float occupied_count, occupied_count_save;
	float i, j, line;

	score = 0;

	// adds a bonus for each free dot above the occupied blocks profile
	occupied = TET_EMPTY_LINE;
	occupied_count = TET_WIDTH;
	height = 0;
	lines = 0;
	for(i = 1; i <= TET_LINES; ++i)
	{
		l = GetLine(i);
		if(l == TET_EMPTY_LINE)
		{
			height = i;
			continue;
		}
		line = 1;
		occupied_save = occupied;
		occupied_count_save = occupied_count;
		score_save = score;
		for(j = 1; j <= TET_WIDTH; ++j)
		{
			if(GetXBlock(j, l))
			{
				if(!GetXBlock(j, occupied))
				{
					occupied = SetXBlock(j, occupied, 1);
					--occupied_count;
				}
			}
			else
				line = 0;
			score += 10000 * occupied_count;
		}
		if(line)
		{
			occupied = occupied_save;
			occupied_count = occupied_count_save;
			score = score_save + 100000000 + 10000 * TET_WIDTH + 1000;
			++lines;
		}
	}

	score += 1000 * height;

	return score;
}

float CheckMetrics(float piece, float orgx, float orgy, float rot);
void ClearPiece(float piece, float orgx, float orgy, float rot);
void CementPiece(float piece, float orgx, float orgy, float rot);
float bastet_profile_evaluate_time;
float bastet_profile_checkmetrics_time;
float BastetSearch(float buf, float pc, float x, float y, float rot, float move_bias)
// returns best score, or -1 if position is impossible
{
	string r;
	float b;
	float s, sm;
	float t1, t2;

	if(move_bias < 0)
		return 0; // DO NOT WANT

	if(x < 1 || x > TET_WIDTH || y < 1 || y > TET_LINES)
		return -1; // impossible
	if(rot < 0) rot = 3;
	if(rot > 3) rot = 0;

	// did we already try?
	b = x + (TET_WIDTH+2) * (y + (TET_LINES+2) * rot);
	r = bufstr_get(buf, b);
	if(r != "") // already tried
		return stof(r);

	bufstr_set(buf, b, "0"); // in case we READ that, not that bad - we already got that value in another branch then anyway



	t1 = gettime(GETTIME_HIRES);
	if(CheckMetrics(pc, x, y, rot))
	{
		t2 = gettime(GETTIME_HIRES);
		bastet_profile_checkmetrics_time += (t2 - t1);
		// try all moves
		sm = 1;
		s = BastetSearch(buf, pc, x-1, y, rot, move_bias - 1); if(s > sm) sm = s;
		s = BastetSearch(buf, pc, x+1, y, rot, move_bias - 1); if(s > sm) sm = s;
		s = BastetSearch(buf, pc, x, y, rot+1, move_bias - 1); if(s > sm) sm = s;
		s = BastetSearch(buf, pc, x, y, rot-1, move_bias - 1); if(s > sm) sm = s;

		s = BastetSearch(buf, pc, x, y+1, rot, move_bias + 2); if(s > sm) sm = s;
		if(s < 0)
		{
			//print(sprintf("MAY CEMENT AT: %d %d %d\n", x, y, rot));
			// moving down did not work - that means we can fixate the block here
			t1 = gettime(GETTIME_HIRES);

			CementPiece(pc, x, y, rot);
			s = BastetEvaluate();
			ClearPiece(pc, x, y, rot);

			t2 = gettime(GETTIME_HIRES);
			bastet_profile_evaluate_time += (t2 - t1);

			if(s > sm) sm = s;
		}
	}
	else
	{
		t2 = gettime(GETTIME_HIRES);
		bastet_profile_checkmetrics_time += (t2 - t1);
		sm = -1; // impassible
	}

	bufstr_set(buf, b, ftos(sm));

	return sm;
}

float bastet_piece[7];
float bastet_score[7];
float bastet_piecetime[7];
float BastetPiece()
{
	float b;

	bastet_profile_evaluate_time = 0;
	bastet_profile_checkmetrics_time = 0;
	var float t1 = gettime(GETTIME_HIRES);

	b = buf_create(); bastet_piece[0] = 1; bastet_score[0] = BastetSearch(b, 1, TET_START_PIECE_POS_x, 1+TET_START_PIECE_POS_y, TET_START_PIECE_POS_y, TET_WIDTH) + 100 * random() + bastet_piecetime[0]; buf_del(b);
	b = buf_create(); bastet_piece[1] = 2; bastet_score[1] = BastetSearch(b, 2, TET_START_PIECE_POS_x, 1+TET_START_PIECE_POS_y, TET_START_PIECE_POS_y, TET_WIDTH) + 100 * random() + bastet_piecetime[1]; buf_del(b);
	b = buf_create(); bastet_piece[2] = 3; bastet_score[2] = BastetSearch(b, 3, TET_START_PIECE_POS_x, 1+TET_START_PIECE_POS_y, TET_START_PIECE_POS_y, TET_WIDTH) + 100 * random() + bastet_piecetime[2]; buf_del(b);
	b = buf_create(); bastet_piece[3] = 4; bastet_score[3] = BastetSearch(b, 4, TET_START_PIECE_POS_x, 1+TET_START_PIECE_POS_y, TET_START_PIECE_POS_y, TET_WIDTH) + 100 * random() + bastet_piecetime[3]; buf_del(b);
	b = buf_create(); bastet_piece[4] = 5; bastet_score[4] = BastetSearch(b, 5, TET_START_PIECE_POS_x, 1+TET_START_PIECE_POS_y, TET_START_PIECE_POS_y, TET_WIDTH) + 100 * random() + bastet_piecetime[4]; buf_del(b);
	b = buf_create(); bastet_piece[5] = 6; bastet_score[5] = BastetSearch(b, 6, TET_START_PIECE_POS_x, 1+TET_START_PIECE_POS_y, TET_START_PIECE_POS_y, TET_WIDTH) + 100 * random() + bastet_piecetime[5]; buf_del(b);
	b = buf_create(); bastet_piece[6] = 7; bastet_score[6] = BastetSearch(b, 7, TET_START_PIECE_POS_x, 1+TET_START_PIECE_POS_y, TET_START_PIECE_POS_y, TET_WIDTH) + 100 * random() + bastet_piecetime[6]; buf_del(b);

	var float t2 = gettime(GETTIME_HIRES);
	dprint(sprintf("Time taken: %.6f seconds (of this, ev = %.2f%%, cm = %.2f%%)\n", t2 - t1, 100 * bastet_profile_evaluate_time / (t2 - t1), 100 * bastet_profile_checkmetrics_time / (t2 - t1)));

	// sort
	float i, j, k, p, s;

/*
	for(i = 0; i < 7; ++i)
	{
		print(sprintf("piece %s value = %d\n", substring("OJLIZST", bastet_piece[i]-1, 1), bastet_score[i]));
	}
*/

	for(i = 0; i < 7; ++i)
	{
		k = i;
		p = bastet_piece[k];
		s = bastet_score[k];
		for(j = i + 1; j < 7; ++j)
		{
			if(bastet_score[j] < s)
			{
				k = j;
				s = bastet_score[k];
				p = bastet_piece[k];
			}
		}
		if(k != i)
		{
			bastet_score[k] = bastet_score[i];
			bastet_piece[k] = bastet_piece[i];
			bastet_score[i] = s;
			bastet_piece[i] = p;
		}
	}

	b = random();
	if(b < 0.8)
		j = 0;
	else if(b < 0.92)
		j = 1;
	else if(b < 0.98)
		j = 2;
	else
		j = 3;
	j = bastet_piece[j];

	for(i = 0; i < 7; ++i)
	{
		if(i == j-1)
			bastet_piecetime[i] = 0.2 * bastet_piecetime[i];
		else
			bastet_piecetime[i] = 1.8 * bastet_piecetime[i] + 1000;
	}

	return j;
}


/*
*********************************

Game Mechanics

*********************************
*/
.float tet_piece_bucket;
float RandomPiece()
{
	float i, j;
	float p, q;
	float b;
	float seen;

	if(self.tet_piece_bucket > 1)
	{
		p = mod(self.tet_piece_bucket, 7);
		self.tet_piece_bucket = floor(self.tet_piece_bucket / 7);
		return p + 1;
	}
	else
	{
		p = floor(random() * 7);
		seen = pow(2, p);
		b = 1;
		for(i = 6; i > 0; --i)
		{
			q = floor(random() * i);
			for(j = 0; j <= q; ++j)
				if(seen & pow(2, j))
					++q;
			if(seen & pow(2, q))
				error("foo 1");
			if(q >= 7)
				error("foo 2");
			seen |= pow(2, q);
			b *= 7;
			b += q;
		}
		self.tet_piece_bucket = b;
		return p + 1;
	}
}

void TetAddScore(float n)
{
	self.tet_score = self.tet_score + n * Tetris_Level();
	if (self.tet_score > tet_high_score)
		tet_high_score = self.tet_score;
}
float CheckMetrics(float piece, float orgx, float orgy, float rot) /*FIXDECL*/
{
	// check to see if the piece, if moved to the locations will overlap

	float x, y;
	string l;
	// why did I start counting from 1, damnit
	orgx = orgx - 1;
	orgy = orgy - 1;

	PieceMinsMaxs(rot, piece);
	if (tet_piecemins_x+orgx<1 || tet_piecemaxs_x+orgx > TET_WIDTH || tet_piecemins_y+orgy<1 || tet_piecemaxs_y+orgy> TET_LINES)
		return FALSE; // ouside the level
	for (y = tet_piecemins_y; y <= tet_piecemaxs_y; y = y + 1)
	{
		l = GetLine(y + orgy);
		if(l != TET_EMPTY_LINE)
		for (x = tet_piecemins_x; x <= tet_piecemaxs_x; x = x + 1)
			if (PieceMetric(x, y, rot, piece))
				if (GetXBlock(x + orgx, l))
					return FALSE; // uhoh, gonna hit something.
	}
	return TRUE;
}

void ClearPiece(float piece, float orgx, float orgy, float rot) /*FIXDECL*/
{
	float x, y;
	// why did I start counting from 1, damnit
	orgx = orgx - 1;
	orgy = orgy - 1;

	PieceMinsMaxs(rot, piece);
	for (y = tet_piecemins_y; y <= tet_piecemaxs_y; y = y + 1)
	{
		for (x = tet_piecemins_x; x <= tet_piecemaxs_x; x = x + 1)
		{
			if (PieceMetric(x, y, rot, piece))
			{
				SetSquare(x + orgx, y + orgy, 0);
			}
		}
	}
}
void CementPiece(float piece, float orgx, float orgy, float rot) /*FIXDECL*/
{
	float pcolor;
	float x, y;
	// why did I start counting from 1, damnit
	orgx = orgx - 1;
	orgy = orgy - 1;

	pcolor = PieceColor(piece);

	PieceMinsMaxs(rot, piece);
	for (y = tet_piecemins_y; y <= tet_piecemaxs_y; y = y + 1)
	{
		for (x = tet_piecemins_x; x <= tet_piecemaxs_x; x = x + 1)
		{
			if (PieceMetric(x, y, rot, piece))
			{
				SetSquare(x + orgx, y + orgy, pcolor);
			}
		}
	}
}

float LINE_LOW = 349525;
float LINE_HIGH = 699050; // above number times 2

void AddLines(float n)
{
	entity head;
	if(!self.tet_vs_id)
		return;
	FOR_EACH_REALCLIENT(head) if(head != self) if(head.tetris_on) if(head.tet_vs_id == self.tet_vs_id)
		head.tet_vs_addlines += n;
}

void CompletedLines()
{
	float y, cleared, added, pos, i;
	string ln;

	cleared = 0;
	y = TET_LINES;
	for(;;)
	{
		ln = GetLine(y);
		if(strstrofs(ln, "0", 0) < 0)
			cleared = cleared + 1;
		else
			y = y - 1;
		if(y < 1)
			break;
		if(y - cleared < 1)
			ln = TET_EMPTY_LINE;
		else
			ln = GetLine(y - cleared);
		SetLine(y, ln);
	}

	if(cleared >= 4)
		AddLines(cleared);
	else if(cleared >= 1)
		AddLines(cleared - 1);

	self.tet_lines = self.tet_lines + cleared;
	TetAddScore(cleared * cleared * 10);

	added = self.tet_vs_addlines;
	self.tet_vs_addlines = 0;

	if(added)
	{
		for(y = 1; y <= TET_LINES - added; ++y)
		{
			SetLine(y, GetLine(y + added));
		}
		for(y = max(1, TET_LINES - added + 1); y <= TET_LINES; ++y)
		{
			pos = floor(random() * TET_WIDTH);
			ln = TET_EMPTY_LINE;
			for(i = 1; i <= TET_WIDTH; ++i)
				if(i != pos)
					ln = SetXBlock(i, ln, floor(random() * 7 + 1));
			SetLine(y, ln);
		}
	}

	self.tet_highest_line = 0;
	for(y = 1; y <= TET_LINES; ++y)
		if(GetLine(y) != TET_EMPTY_LINE)
		{
			self.tet_highest_line = TET_LINES + 1 - y;
			break;
		}

	if(added)
		tetsnd("tetadd");
	else if(cleared >= 4)
		tetsnd("tetris");
	else if(cleared)
		tetsnd("tetline");
	else
		tetsnd("tetland");
}

void HandleGame(float keyss)
{

	// first off, we need to see if we need a new piece
	vector piece_data;
	vector check_pos;
	vector old_pos;
	float brand_new;
	float i;
	brand_new = 0;


	if (self.piece_type == 0)
	{
		self.piece_pos = TET_START_PIECE_POS; // that's about middle top, we count from 1 ARGH

		if(autocvar_g_bastet)
		{
			self.piece_type = BastetPiece();
			self.next_piece = bastet_piece[6];
		}
		else
		{
			if (self.next_piece)
				self.piece_type = self.next_piece;
			else
				self.piece_type = RandomPiece();
			self.next_piece =  RandomPiece();
		}
		keyss = 0; // no movement first frame
		self.tet_autodown = time + 0.2;
		brand_new = 1;
	}
	else
		ClearPiece(self.piece_type, self.piece_pos_x, self.piece_pos_y, self.piece_pos_z);

	// next we need to check the piece metrics against what's on the level
	// based on the key order

	old_pos = check_pos = self.piece_pos;

	float nudge;
	nudge = 0;
	if (keyss & TETKEY_RIGHT)
	{
		check_pos_x = check_pos_x + 1;
		tetsnd("tetmove");
	}
	else if (keyss & TETKEY_LEFT)
	{
		check_pos_x = check_pos_x - 1;
		tetsnd("tetmove");
	}
	else if (keyss & TETKEY_ROTRIGHT)
	{
		check_pos_z = check_pos_z + 1;
		piece_data = PieceShape(self.piece_type);
		nudge = 1;
		tetsnd("tetrot");
	}
	else if (keyss & TETKEY_ROTLEFT)
	{
		check_pos_z = check_pos_z - 1;
		piece_data = PieceShape(self.piece_type);
		nudge = 1;
		tetsnd("tetrot");
	}
	// bounds check
	if (check_pos_z > 3)
		check_pos_z = 0;
	else if (check_pos_z < 0)
		check_pos_z = 3;

	// reality check
	if (CheckMetrics(self.piece_type, check_pos_x, check_pos_y, check_pos_z))
		self.piece_pos = check_pos;
	else if (brand_new)
	{
		self.tetris_on = 2;
		self.tet_gameovertime = time + 5;
		return;
	}
	else
	{
		for(i = 1; i <= nudge; ++i)
		{
			if(CheckMetrics(self.piece_type, check_pos_x + i, check_pos_y, check_pos_z))
				self.piece_pos = check_pos + '1 0 0' * i;
			else if(CheckMetrics(self.piece_type, check_pos_x - i, check_pos_y, check_pos_z))
				self.piece_pos = check_pos - '1 0 0' * i;
			else
				continue;
			break;
		}
	}
	check_pos = self.piece_pos;
	if(keyss & TETKEY_DROP)
	{
		// drop to bottom, but do NOT cement it yet
		// this allows sliding it
		++check_pos_y;
		while(CheckMetrics(self.piece_type, check_pos_x, check_pos_y + 1, check_pos_z))
			++check_pos_y;
		self.tet_autodown = time + 2 / (1 + Tetris_Level());
	}
	else if (keyss & TETKEY_DOWN)
	{
		check_pos_y = check_pos_y + 1;
		self.tet_autodown = time + 2 / (1 + Tetris_Level());
	}
	else if (self.tet_autodown < time)
	{
		check_pos_y = check_pos_y + 1;
		self.tet_autodown = time + 2 / (1 + Tetris_Level());
	}
	if (CheckMetrics(self.piece_type, check_pos_x, check_pos_y, check_pos_z))
	{
		if(old_pos != check_pos)
			self.tet_drawtime = 0;
		self.piece_pos = check_pos;
	}
	else
	{
		CementPiece(self.piece_type, self.piece_pos_x, self.piece_pos_y, self.piece_pos_z);
		TetAddScore(1);
		CompletedLines();
		self.piece_type = 0;
		self.tet_drawtime = 0;
		return;
	}
	CementPiece(self.piece_type, self.piece_pos_x, self.piece_pos_y, self.piece_pos_z);
}

/*
*********************************

Important Linking Into Quake stuff

*********************************
*/


void TetrisImpulse()
{
	if(self.tetris_on == 0 || self.tetris_on == 2) // from "off" or "game over"
	{
		self.tetris_on = 3;

		if(time < tet_vs_current_timeout)
		{
			// join VS game
			self.tet_vs_id = tet_vs_current_id;
		}
		else
		{
			// start new VS game
			++tet_vs_current_id;
			tet_vs_current_timeout = time + 15;
			self.tet_vs_id = tet_vs_current_id;
			bprint("^1TET^7R^1IS: ", self.netname, "^1 started a new game. Do ^7impulse 100^1 to join.\n");
		}
		self.tet_highest_line = 0;
		ResetTetris();
		self.tet_org = self.origin;
		self.movetype = MOVETYPE_NOCLIP;
	}
	else if(self.tetris_on == 1) // from "on"
	{
		Tet_GameExit();
		self.impulse = 0;
	}
}


float TetrisPreFrame()
{
	if (!self.tetris_on)
		return 0;

	self.tet_org = self.origin;
	if (self.tet_drawtime > time)
		return 1;
	Draw_Tetris();
	if(self.tetris_on == 3)
		self.tet_drawtime = ceil(time - tet_vs_current_timeout + 0.1) + tet_vs_current_timeout;
	else
		self.tet_drawtime = time + 0.5;
	return 1;
}
float frik_anglemoda(float v)
{
	return v - floor(v/360) * 360;
}
float angcompa(float y1, float y2)
{
	y1 = frik_anglemoda(y1);
	y2 = frik_anglemoda(y2);

	float answer;
	answer = y1 - y2;
	if (answer > 180)
		answer = answer - 360;
	else if (answer < -180)
		answer = answer + 360;
	return answer;
}

.float tetkey_down, tetkey_rotright, tetkey_left, tetkey_right, tetkey_rotleft, tetkey_drop;

float TetrisKeyRepeat(.float fld, float f)
{
	if(f)
	{
		if(self.fld == 0) // initial key press
		{
			self.fld = time + 0.3;
			return 1;
		}
		else if(time > self.fld)
		{
			self.fld = time + 0.1;
			return 1;
		}
		else
		{
			// repeating too fast
			return 0;
		}
	}
	else
	{
		self.fld = 0;
		return 0;
	}
}

float TetrisPostFrame()
{
	float keysa;

	keysa = 0;

	if (!self.tetris_on)
		return 0;

	if(self.tetris_on == 2 && time > self.tet_gameovertime)
	{
		Tet_GameExit();
		return 0;
	}

	if(self.tetris_on == 3 && time > tet_vs_current_timeout)
	{
		self.tetris_on = 1; // start VS game
		self.tet_drawtime = 0;
	}

	setorigin(self, self.tet_org);
	self.movetype = MOVETYPE_NONE;

	if(self.tetris_on == 1)
	{
		if(TetrisKeyRepeat(tetkey_down, self.movement_x < 0))
			keysa |= TETKEY_DOWN;

		if(TetrisKeyRepeat(tetkey_rotright, self.movement_x > 0))
			keysa |= TETKEY_ROTRIGHT;

		if(TetrisKeyRepeat(tetkey_left, self.movement_y < 0))
			keysa |= TETKEY_LEFT;

		if(TetrisKeyRepeat(tetkey_right, self.movement_y > 0))
			keysa |= TETKEY_RIGHT;

		if(TetrisKeyRepeat(tetkey_rotleft, self.BUTTON_CROUCH))
			keysa |= TETKEY_ROTLEFT;

		if(TetrisKeyRepeat(tetkey_drop, self.BUTTON_JUMP))
			keysa |= TETKEY_DROP;

		HandleGame(keysa);
	}

	return 1;
}

#else

float TetrisPostFrame()
{
	if (autocvar_g_bastet)
	{
		cvar_set("g_bastet", "0");
		print("The useless cvar has been toggled.\n");
	}
	return 0;
}

#endif
