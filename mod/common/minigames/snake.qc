#include "snake.qh"
REGISTER_MINIGAME(snake, "Snake"); // SNAAAAKE

const float SNAKE_TURN_MOVE  = 0x0100; // the snake is moving, player must control it
const float SNAKE_TURN_WIN   = 0x0200; // multiplayer victory
const float SNAKE_TURN_LOSS  = 0x0400; // they did it?!
const float SNAKE_TURN_TYPE  = 0x0f00; // turn type mask

const int SNAKE_TURN_TEAM  = 0x000f; // turn team mask

const int SNAKE_SF_PLAYERSCORE = MINIG_SF_CUSTOM;

const int SNAKE_LET_CNT = 15;
const int SNAKE_NUM_CNT = 15;

const int SNAKE_TILE_SIZE = 15;

const int SNAKE_TEAMS = 6;

bool autocvar_sv_minigames_snake_wrap = true;
float autocvar_sv_minigames_snake_delay_initial = 0.7;
float autocvar_sv_minigames_snake_delay_multiplier = 50;
float autocvar_sv_minigames_snake_delay_min = 0.1;
bool autocvar_sv_minigames_snake_eat_players = false;
#ifdef SVQC
int autocvar_sv_minigames_snake_lives = 3;
#endif

.int snake_score;

.float snake_delay;
.vector snake_dir;

.entity snake_next, snake_last, snake_prev;

.bool snake_tail;

.int snake_lives[SNAKE_TEAMS + 1];

.int snake_lost_teams;

bool snake_alone(entity minig)
{
	int headcount = 0;
	entity e = NULL;
	while ( ( e = findentity(e,owner,minig) ) )
		if ( e.classname == "minigame_board_piece" && e.cnt == 1 )
			++headcount;

	return headcount <= 1;
}

// find same game piece given its tile name
entity snake_find_piece(entity minig, string tile)
{
	entity e = NULL;
	while ( ( e = findentity(e,owner,minig) ) )
		if ( e.classname == "minigame_board_piece" && e.netname == tile )
			return e;
	return NULL;
}

// find same game piece given its cnt
entity snake_find_cnt(entity minig, int steam, int tile)
{
	entity e = NULL;
	while ( ( e = findentity(e,owner,minig) ) )
		if ( e.classname == "minigame_board_piece" && e.cnt == tile && e.team == steam )
			return e;
	return NULL;
}

// check if the tile name is valid (15x15 grid)
bool snake_valid_tile(string tile)
{
	if ( !tile )
		return false;
	int number = minigame_tile_number(tile);
	int letter = minigame_tile_letter(tile);
	return 0 <= number && number < SNAKE_NUM_CNT && 0 <= letter && letter < SNAKE_LET_CNT;
}

entity snake_find_head(entity minig, int steam)
{
	entity e = NULL;
	while ( ( e = findentity(e,owner,minig) ) )
		if ( e.classname == "minigame_board_piece" && e.cnt == 1 && e.team == steam )
			return e;
	return NULL;
}

void snake_new_mouse(entity minigame)
{
	RandomSelection_Init();
	int i, j;
	for(i = 0; i < SNAKE_LET_CNT; ++i)
	for(j = 0; j < SNAKE_NUM_CNT; ++j)
	{
		string pos = minigame_tile_buildname(i, j);
		if(!snake_find_piece(minigame, pos))
			RandomSelection_AddString(pos, 1, 1);
	}

	entity piece = msle_spawn(minigame,new(minigame_board_piece));
	piece.team = 0;
	piece.netname = strzone(RandomSelection_chosen_string);
	minigame_server_sendflags(piece,MINIG_SF_ALL);

	minigame_server_sendflags(minigame,MINIG_SF_UPDATE);
}

entity snake_get_player(entity minigame, int pteam);
int snake_winning_team(entity minigame)
{
	int winning_team = 0;
	for(int i = 1; i <= SNAKE_TEAMS; ++i)
	{
		entity pl = snake_get_player(minigame, i);
		if(pl && minigame.snake_lives[i] > 0)
		{
			if(winning_team)
				return 0;
			winning_team = i;
		}
	}

	return winning_team;
}

void snake_check_winner(entity minigame)
{
	if(snake_alone(minigame) && !minigame.snake_lost_teams)
		return;

	int winner = snake_winning_team(minigame);

	int alivecnt = 0;
	for(int i = 1; i <= SNAKE_TEAMS; ++i)
	{
		entity pl = snake_get_player(minigame, i);
		if(pl && minigame.snake_lives[i] > 0)
			++alivecnt;
	}

	if(!alivecnt)
	{
		minigame.minigame_flags = SNAKE_TURN_LOSS;
		minigame_server_sendflags(minigame,MINIG_SF_UPDATE);
		return;
	}

	if(winner)
	{
		minigame.minigame_flags = SNAKE_TURN_WIN | winner;
		minigame_server_sendflags(minigame,MINIG_SF_UPDATE);
	}
}

void snake_move_head(entity minigame, entity head);
void snake_head_think(entity this)
{
	entity minigame = this.owner;

	if(minigame.minigame_flags & SNAKE_TURN_MOVE)
		snake_move_head(minigame, this);

	snake_check_winner(minigame);

	this.nextthink = time + this.snake_delay;
}

void minigame_setup_snake(entity minigame, int pteam)
{
	RandomSelection_Init();
	int i, j;
	for(i = 1; i < SNAKE_LET_CNT - 1; ++i)
	for(j = 1; j < SNAKE_NUM_CNT - 1; ++j)
	{
		string pos = minigame_tile_buildname(i, j);
		if(!snake_find_piece(minigame, pos))
			RandomSelection_AddString(pos, 1, 1);
	}

	entity piece = msle_spawn(minigame,new(minigame_board_piece));
	piece.team = pteam;
	piece.netname = strzone(RandomSelection_chosen_string);
	piece.cnt = 1;
	piece.snake_next = NULL;
	piece.snake_prev = NULL;
	piece.snake_last = piece;
	setthink(piece, snake_head_think);
	piece.snake_delay = autocvar_sv_minigames_snake_delay_initial;
	piece.nextthink = time + 0.1;
	minigame_server_sendflags(piece,MINIG_SF_ALL);
}

void snake_setup_pieces(entity minigame)
{
	snake_new_mouse(minigame);

	minigame_server_sendflags(minigame,MINIG_SF_UPDATE);
}

entity snake_get_player(entity minigame, int pteam)
{
	entity e;
#ifdef SVQC
	for(e = minigame.minigame_players; e; e = e.list_next)
#elif defined(CSQC)
	e = NULL;
	while( (e = findentity(e,owner,minigame)) )
		if ( e.classname == "minigame_player" )
#endif
	if(e.team == pteam)
		return e;
	return NULL;
}

void snake_add_score(entity minigame, int pteam, int thescore)
{
#ifdef SVQC
	if(!minigame)
		return;
	entity pl = snake_get_player(minigame, pteam);
	if(pl)
	{
		pl.snake_score += thescore;
		pl.SendFlags |= SNAKE_SF_PLAYERSCORE;
	}
#endif
}

void snake_move_body(entity minigame, entity head, bool ate_mouse)
{
	for(entity e = head.snake_last; e; e = e.snake_prev)
	{
		if(!e || e == head) { break; }

		entity nextpiece = e.snake_prev; // can be head

		strcpy(e.netname, nextpiece.netname);
		e.snake_dir = nextpiece.snake_dir;
		minigame_server_sendflags(e, MINIG_SF_UPDATE);
	}

	if(ate_mouse)
	{
		entity tail = head.snake_last;

		tail.snake_tail = false;

		int newcnt = tail.cnt + 1;
		head.snake_delay = max(autocvar_sv_minigames_snake_delay_min, autocvar_sv_minigames_snake_delay_initial - (newcnt / autocvar_sv_minigames_snake_delay_multiplier));
		snake_add_score(minigame, head.team, 1);

		entity piece = msle_spawn(minigame,new(minigame_board_piece));
		piece.cnt = newcnt;
		piece.team = head.team;
		piece.snake_prev = tail;
		piece.snake_dir = tail.snake_dir;
		piece.snake_next = NULL;
		piece.snake_tail = true;
		piece.netname = strzone(tail.netname);

		tail.snake_next = piece;
		head.snake_last = piece;

		minigame_server_sendflags(piece,MINIG_SF_UPDATE);

		//minigame_server_sendflags(minigame,MINIG_SF_UPDATE);
	}
}

void snake_eat_team(entity minigame, int pteam)
{
	entity head = snake_find_head(minigame, pteam);
	if(!head) { return; }

	minigame.snake_lives[pteam] -= 1;

	entity pl = snake_get_player(minigame, pteam);
#ifdef SVQC
	pl.SendFlags |= SNAKE_SF_PLAYERSCORE;
#endif

	head.nextthink = time + 1; // make sure they don't to eat us somehow

	entity e = NULL;
	while ( ( e = findentity(e,owner,minigame) ) )
		if ( e.classname == "minigame_board_piece" && e.cnt && e.team == pteam )
		{
			strfree(e.netname);
			delete(e);
		}

	if(minigame.snake_lives[pteam] <= 0)
		minigame.snake_lost_teams |= BIT(pteam);

	if(pl && minigame.snake_lives[pteam] > 0)
		minigame_setup_snake(minigame, pteam);
}

void snake_move_head(entity minigame, entity head)
{
	if(!head.snake_dir.x && !head.snake_dir.y)
		return; // nope!

	string newpos;

	if(autocvar_sv_minigames_snake_wrap)
		newpos = minigame_relative_tile(head.netname, head.snake_dir.x, head.snake_dir.y, SNAKE_NUM_CNT, SNAKE_LET_CNT);
	else
	{
		int myx = minigame_tile_letter(head.netname);
		int myy = minigame_tile_number(head.netname);

		myx += head.snake_dir.x;
		myy += head.snake_dir.y;

		newpos = minigame_tile_buildname(myx, myy);
	}

	entity hit = snake_find_piece(minigame, newpos);

	if(!snake_valid_tile(newpos) || (hit && hit.cnt && hit.team == head.team))
	{
		if(snake_alone(minigame))
		{
			minigame.minigame_flags = SNAKE_TURN_LOSS;
			minigame_server_sendflags(minigame,MINIG_SF_UPDATE);
		}
		else
		{
			snake_add_score(minigame, head.team, -1);
			snake_eat_team(minigame, head.team);
		}

		return;
	}

	bool ate_mouse = (hit && !hit.cnt);

	// move the body first, then set the new head position?
	snake_move_body(minigame, head, ate_mouse);

	strcpy(head.netname, newpos);
	minigame_server_sendflags(head,MINIG_SF_UPDATE);

	// above check makes sure it's not our team
	if(autocvar_sv_minigames_snake_eat_players)
	{
		if(hit.cnt && hit.cnt < head.cnt)
		{
			snake_eat_team(minigame, hit.team);
			snake_add_score(minigame, head.team, 1);
		}
		else if(hit.cnt && hit.cnt >= head.cnt)
		{
			snake_add_score(minigame, head.team, -1);
			snake_eat_team(minigame, head.team);
		}
	}
	else if(hit.cnt)
	{
		snake_add_score(minigame, head.team, -1);
		snake_eat_team(minigame, head.team);
	}

	if(ate_mouse)
	{
		strfree(hit.netname);
		delete(hit);

		snake_new_mouse(minigame);
	}
}

// make a move
void snake_move(entity minigame, entity player, string dxs, string dys )
{
	if ( minigame.minigame_flags & SNAKE_TURN_MOVE )
	if ( dxs || dys )
	{
		//if ( snake_valid_tile(pos) )
		//if ( snake_find_piece(minigame, pos) )
		{
			entity head = snake_find_head(minigame, player.team);
			if(!head)
				return; // their head is already dead

			int dx = ((dxs) ? bound(-1, stof(dxs), 1) : 0);
			int dy = ((dys) ? bound(-1, stof(dys), 1) : 0);
			if(dx == 0 && dy == 0)
				dy = 1; // force upward direction if they try to cheat

			int myl = minigame_tile_letter(head.netname);
			int myn = minigame_tile_number(head.netname);

			entity check_piece = snake_find_piece(minigame, minigame_tile_buildname(myl + dx, myn + dy));
			if(check_piece && check_piece.cnt == 2)
				return; // nope!

			if(head.snake_dir == '0 0 0')
				head.nextthink = time; // TODO: make sure this can't be exploited!
			head.snake_dir.x = dx;
			head.snake_dir.y = dy;
			head.snake_dir.z = 0;
			minigame_server_sendflags(head,MINIG_SF_UPDATE);
			minigame_server_sendflags(minigame,MINIG_SF_UPDATE);
		}
	}
}

#ifdef SVQC


// required function, handle server side events
int snake_server_event(entity minigame, string event, ...)
{
	switch(event)
	{
		case "start":
		{
			snake_setup_pieces(minigame);
			minigame.minigame_flags = SNAKE_TURN_MOVE;
			minigame.snake_lost_teams = 0;

			if(SNAKE_TEAMS > 1)
			{
				for(int i = 1; i <= SNAKE_TEAMS; ++i)
					minigame.snake_lives[i] = autocvar_sv_minigames_snake_lives;
			}
			else
				minigame.snake_lives[1] = 1;

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

			if(pl_num >= SNAKE_TEAMS) { return false; }

			int t = 1; // Team 1 by default

			for(int i = 1; i <= SNAKE_TEAMS; ++i)
			{
				entity e = snake_get_player(minigame, i);
				if(!e)
				{
					t = i;
					break;
				}
			}

			if(!snake_find_head(minigame, t) && !(minigame.snake_lost_teams & BIT(t)))
			{
				entity pl = ...(1,entity);
				if(pl)
				{
					//pl.snake_lives = ((SNAKE_TEAMS > 1) ? autocvar_sv_minigames_snake_lives : 1);
					// send score anyway, lives are set
					pl.SendFlags |= SNAKE_SF_PLAYERSCORE;
				}
				minigame_setup_snake(minigame, t);
			}

			return t;
		}
		case "cmd":
		{
			switch(argv(0))
			{
				case "move":
					snake_move(minigame, ...(0,entity), ((...(1,int)) >= 2 ? argv(1) : string_null), ((...(1,int)) == 3 ? argv(2) : string_null));
					return true;
			}

			return false;
		}
		case "network_send":
		{
			entity sent = ...(0,entity);
			int sf = ...(1,int);
			if ( sent.classname == "minigame_board_piece" && (sf & MINIG_SF_UPDATE) )
			{
				int letter = minigame_tile_letter(sent.netname);
				int number = minigame_tile_number(sent.netname);

				WriteByte(MSG_ENTITY,letter);
				WriteByte(MSG_ENTITY,number);

				WriteByte(MSG_ENTITY,sent.cnt);
				WriteByte(MSG_ENTITY,sent.snake_tail);

				int dx = sent.snake_dir.x;
				int dy = sent.snake_dir.y;
				if(dx == -1) dx = 2;
				if(dy == -1) dy = 2;
				WriteByte(MSG_ENTITY,dx);
				WriteByte(MSG_ENTITY,dy);
			}
			else if ( sent.classname == "minigame_player" && (sf & SNAKE_SF_PLAYERSCORE ) )
			{
				WriteLong(MSG_ENTITY,sent.snake_score);
				WriteByte(MSG_ENTITY,max(0, minigame.snake_lives[sent.team]));
			}
			else if ( sent.classname == "minigame" && (sf & MINIG_SF_UPDATE ) )
			{
				WriteByte(MSG_ENTITY,autocvar_sv_minigames_snake_wrap);
			}
			return false;
		}
	}

	return false;
}


#elif defined(CSQC)

vector snake_boardpos; // HUD board position
vector snake_boardsize;// HUD board size

bool snake_wrap;

vector snake_teamcolor(int steam)
{
	switch(steam)
	{
		case 1: return '1 0 0';
		case 2: return '0 0 1';
		case 3: return '1 1 0';
		case 4: return '1 0 1';
		case 5: return '0 1 0';
		case 6: return '0 1 1';
	}

	return '1 1 1';
}

// Required function, draw the game board
void snake_hud_board(vector pos, vector mySize)
{
	minigame_hud_fitsqare(pos, mySize);
	snake_boardpos = pos;
	snake_boardsize = mySize;

	minigame_hud_simpleboard(pos,mySize,minigame_texture("snake/board"));

	vector tile_size = minigame_hud_denormalize_size('1 1 0' / SNAKE_TILE_SIZE,pos,mySize);
	vector tile_pos;

	entity e;
	FOREACH_MINIGAME_ENTITY(e)
	{
		if ( e.classname == "minigame_board_piece" )
		{
			tile_pos = minigame_tile_pos(e.netname,SNAKE_NUM_CNT,SNAKE_LET_CNT);
			tile_pos = minigame_hud_denormalize(tile_pos,pos,mySize);

			vector tile_color = snake_teamcolor(e.team);

			string thepiece = "snake/mouse";
			if(e.cnt)
				thepiece = "snake/body";
			if(e.snake_tail)
				thepiece = "snake/tail";
			if(e.cnt == 1)
			{
				int dx = minigame_tile_letter(e.netname) + e.snake_dir.x * 2;
				int dy = minigame_tile_number(e.netname) + e.snake_dir.y * 2;
				entity mouse = snake_find_piece(active_minigame, minigame_tile_buildname(dx, dy));
				thepiece = "snake/head";
				if(mouse && mouse.team != e.team)
				{
					float myang = 0;
					int myx = minigame_tile_letter(e.netname);
					int myy = minigame_tile_number(e.netname);
					if(myx - 2 == dx)
						myang = M_PI*3/2;
					if(myx + 2 == dx)
						myang = M_PI/2;
					if(myy - 2 == dy)
						myang = M_PI;

					int newx = minigame_tile_letter(e.netname) + e.snake_dir.x;
					int newy = minigame_tile_number(e.netname) + e.snake_dir.y;
					string newpos = minigame_tile_buildname(newx, newy);

					vector my_pos = minigame_tile_pos(newpos,SNAKE_NUM_CNT,SNAKE_LET_CNT);
					my_pos = minigame_hud_denormalize(my_pos,pos,mySize);

					drawrotpic(my_pos, myang, minigame_texture("snake/tongue"),
							tile_size, tile_size/2, tile_color,
							panel_fg_alpha, DRAWFLAG_NORMAL );
				}
			}

			if(e.cnt == 1 || e.snake_tail)
			{
				vector thedir = e.snake_dir;
				float theang = 0;
				if(e.snake_tail)
				{
					int thex = minigame_tile_letter(e.netname);
					int they = minigame_tile_number(e.netname);
					entity t = snake_find_cnt(active_minigame, e.team, e.cnt - 1);
					int tx = minigame_tile_letter(t.netname);
					int ty = minigame_tile_number(t.netname);

					if(thex - 1 == tx)
					{
						thedir_y = 0;
						thedir_x = -1;
					}
					if(they + 1 == ty)
					{
						thedir_x = 0;
						thedir_y = 1;
					}
					if(they - 1 == ty)
					{
						thedir_x = 0;
						thedir_y = -1;
					}
				}

				if(thedir_y == -1)
					theang = M_PI;
				if(thedir_x == 1)
					theang = M_PI/2;
				if(thedir_x == -1)
					theang = M_PI*3/2;

				drawrotpic(tile_pos, theang, minigame_texture(thepiece),
							tile_size, tile_size/2, tile_color,
							panel_fg_alpha, DRAWFLAG_NORMAL );
			}
			else
			{
				minigame_drawpic_centered( tile_pos,
						minigame_texture(thepiece),
						tile_size, tile_color, panel_fg_alpha, DRAWFLAG_NORMAL );
			}
		}
	}

	if ( (active_minigame.minigame_flags & SNAKE_TURN_LOSS) || (active_minigame.minigame_flags & SNAKE_TURN_WIN) || (active_minigame.snake_lives[minigame_self.team] <= 0) )
	{
		int scores = minigame_self.snake_score;

		vector winfs = hud_fontsize*2;
		string scores_text, victory_text;
		victory_text = "Game over!";
		scores_text = strcat("Score: ", ftos(scores));

		if(active_minigame.minigame_flags & SNAKE_TURN_WIN)
		if((active_minigame.minigame_flags & SNAKE_TURN_TEAM) == minigame_self.team)
			victory_text = "You win!";
		if(active_minigame.snake_lives[minigame_self.team] <= 0)
			victory_text = "You ran out of lives!";

		vector win_pos = pos+eY*(mySize_y-winfs_y)/2;
		vector win_sz;
		win_sz = minigame_drawcolorcodedstring_wrapped(mySize_x,win_pos,
			sprintf("%s %s", victory_text, scores_text),
			winfs, 0, DRAWFLAG_NORMAL, 0.5);

		drawfill(win_pos-eY*hud_fontsize_y,win_sz+2*eY*hud_fontsize_y,'0.3 0.3 1',0.8,DRAWFLAG_ADDITIVE);

		minigame_drawcolorcodedstring_wrapped(mySize_x,win_pos,
			sprintf("%s %s", victory_text, scores_text),
			winfs, panel_fg_alpha, DRAWFLAG_NORMAL, 0.5);
	}
}


// Required function, draw the game status panel
void snake_hud_status(vector pos, vector mySize)
{
	HUD_Panel_DrawBg();
	vector ts = minigame_drawstring_wrapped(mySize.x, pos, active_minigame.descriptor.message,
		hud_fontsize * 2, '0.25 0.47 0.72', panel_fg_alpha, DRAWFLAG_NORMAL,0.5);
	ts.y += hud_fontsize.y;
	pos.y += ts.y;
	mySize.y -= ts.y;

	vector player_fontsize = hud_fontsize * 1.75;
	ts.y = player_fontsize.y + (mySize.y - SNAKE_TEAMS * player_fontsize.y) / SNAKE_TEAMS;
	ts.x = mySize_x;
	vector mypos;

	entity e;
	FOREACH_MINIGAME_ENTITY(e)
	{
		if ( e.classname == "minigame_player" )
		{
			mypos = pos + eY * (e.team - 1) * ts.y;

			if (e == minigame_self)
			{
				const vector hl_size = '1 1 0';
				drawfill(mypos + hl_size, ts - 2 * hl_size, snake_teamcolor(e.team), 0.25 * panel_fg_alpha, DRAWFLAG_ADDITIVE);
				drawborderlines(hl_size.x, mypos + hl_size, ts - 2 * hl_size, snake_teamcolor(e.team), panel_fg_alpha, DRAWFLAG_NORMAL);
			}
			else
				drawfill(mypos, ts, snake_teamcolor(e.team), 0.25 * panel_fg_alpha, DRAWFLAG_ADDITIVE);

			minigame_drawcolorcodedstring_trunc(mySize.x - hud_fontsize.x * 0.5, mypos + eX * hud_fontsize.x * 0.25,
				entcs_GetName(e.minigame_playerslot - 1),
				player_fontsize, panel_fg_alpha, DRAWFLAG_NORMAL);

			mypos.y += player_fontsize.y;
			drawstring_aspect(mypos, ftos(e.snake_score), ts - eY * player_fontsize.y - eX * ts.x * (3 / 4),
								'0.7 0.84 1', panel_fg_alpha, DRAWFLAG_NORMAL);
			drawstring_aspect(mypos + eX * ts.x * (1 / 4), strcat("1UP: ", ftos(active_minigame.snake_lives[e.team])), ts - eY * player_fontsize.y - eX * ts.x * (1 / 4),
								'1 0.44 0.54', panel_fg_alpha, DRAWFLAG_NORMAL);
		}
	}
}

// Turn a set of flags into a help message
string snake_turn_to_string(int turnflags)
{
	if ( turnflags & SNAKE_TURN_LOSS )
		return _("Game over!");

	if ( turnflags & SNAKE_TURN_WIN )
	{
		if ( (turnflags&SNAKE_TURN_TEAM) != minigame_self.team )
			return _("You ran out of lives!");
		return _("You win!");
	}

	if(active_minigame.snake_lives[minigame_self.team] <= 0)
		return _("You ran out of lives!");

	if ( (snake_find_head(active_minigame, minigame_self.team)).snake_dir == '0 0 0' )
		return _("Press an arrow key to begin the game");

	if ( turnflags & SNAKE_TURN_MOVE )
		if(snake_wrap)
			return _("Avoid the snake's body, collect the mice!");
		else
			return _("Avoid the screen edges and the snake's body, collect the mice!");

	return "";
}

// Make the correct move
void snake_set_direction(entity minigame, int dx, int dy)
{
	//if ( minigame.minigame_flags == SNAKE_TURN_MOVE )
	//{
		minigame_cmd("move ",ftos(dx), " ", ftos(dy));
	//}
}

// Required function, handle client events
int snake_client_event(entity minigame, string event, ...)
{
	switch(event)
	{
		case "activate":
		{
			strcpy(minigame.message, snake_turn_to_string(minigame.minigame_flags));
			return false;
		}
		case "deactivate":
		{
			strfree(minigame.message);
			return false;
		}
		case "key_pressed":
		{
			//if((minigame.minigame_flags & SNAKE_TURN_TEAM) == minigame_self.team)
			{
				switch ( ...(0,int) )
				{
					case K_RIGHTARROW:
					case K_KP_RIGHTARROW:
						snake_set_direction(minigame, 1, 0);
						return true;
					case K_LEFTARROW:
					case K_KP_LEFTARROW:
						snake_set_direction(minigame, -1, 0);
						return true;
					case K_UPARROW:
					case K_KP_UPARROW:
						snake_set_direction(minigame, 0, 1);
						return true;
					case K_DOWNARROW:
					case K_KP_DOWNARROW:
						snake_set_direction(minigame, 0, -1);
						return true;
				}
			}

			return false;
		}
		case "network_receive":
		{
			entity sent = ...(0,entity);
			int sf = ...(1,int);
			if ( sent.classname == "minigame" )
			{
				if ( sf & MINIG_SF_UPDATE )
				{
					snake_wrap = ReadByte();
					strcpy(sent.message, snake_turn_to_string(sent.minigame_flags));
					//if ( sent.minigame_flags & minigame_self.team )
						minigame_prompt();
				}
			}
			else if(sent.classname == "minigame_board_piece")
			{
				if(sf & MINIG_SF_UPDATE)
				{
					int letter = ReadByte();
					int number = ReadByte();
					strcpy(sent.netname, minigame_tile_buildname(letter, number));

					sent.cnt = ReadByte();
					sent.snake_tail = ReadByte();

					int dx = ReadByte();
					int dy = ReadByte();

					if(dx == 2) dx = -1;
					if(dy == 2) dy = -1;

					sent.snake_dir.x = dx;
					sent.snake_dir.y = dy;
					sent.snake_dir.z = 0;
				}
			}
			else if ( sent.classname == "minigame_player" && (sf & SNAKE_SF_PLAYERSCORE ) )
			{
				sent.snake_score = ReadLong();
				minigame.snake_lives[sent.team] = ReadByte();
			}

			return false;
		}
	}

	return false;
}

#endif
