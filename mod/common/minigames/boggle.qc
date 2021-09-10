//FEATURE: Boggle minigame, a fun word search game

#include "words.qh" // defines MINIGAME_SUPPORT_WORDS

#ifdef MINIGAME_SUPPORT_WORDS

REGISTER_MINIGAME(boggle, "Boggle");

const int BOGGLE_TURN_MOVE  = 0x0100; // player has to create words on the board
const int BOGGLE_TURN_WAIT  = 0x0200; // player has to click ready
const int BOGGLE_TURN_DRAW  = 0x0400; // player can make no more moves
const int BOGGLE_TURN_TYPE  = 0x0f00; // turn type mask

const int BOGGLE_SF_PLAYERSCORE = MINIG_SF_CUSTOM;

const int BOGGLE_LET_CNT = 4;
const int BOGGLE_NUM_CNT = 4;

const int BOGGLE_TILE_SIZE = 5;

AUTOCVAR(sv_minigames_boggle_timelimit, float, 180, ""); // 3 minutes

.string boggle_letter;
.int boggle_wordscore;
.int boggle_score;

.float boggle_timer_start; // start time of boggle timer, for calculating end time

.LinkedList boggle_words;

REGISTER_STAT(BOGGLE_TIMER, float)

#ifdef SVQC
REGISTER_MUTATOR(boggle_timer, true);

MUTATOR_HOOKFUNCTION(boggle_timer, PlayerPreThink)
{
	entity player = M_ARGV(0, entity);

	if(CS(player).active_minigame)
		STAT(BOGGLE_TIMER, player) = (CS(player).active_minigame.boggle_timer_start + autocvar_sv_minigames_boggle_timelimit) - time;
	else
		STAT(BOGGLE_TIMER, player) = 0;
}
#endif

entity boggle_spawn_list_item(entity minigame, string word)
{
	entity e = new(boggle_list_item);
	e.netname = strzone(word);
	LL_PUSH(minigame.boggle_words, e);
	return e;
}

bool boggle_word_in_list(entity minigame, string word)
{
	LL_EACH(minigame.boggle_words, true, LAMBDA(
		if(it.netname == word)
			return true;
	));

	return false;
}

// find same game piece given its tile name
entity boggle_find_piece(entity minig, string tile)
{
	entity e = NULL;
	while( ( e = findentity(e,owner,minig) ) )
		if( e.classname == "minigame_board_piece" )
		{
			if(e.netname == tile)
				return e;
		}
	return NULL;
}

bool boggle_draw(entity minigame)
{
	int valid = 0;
	entity e = NULL;
	while( ( e = findentity(e,owner,minigame) ) )
		if( e.classname == "minigame_board_piece" )
		{
			++valid;
		}

	return ((valid > 0) ? true : false);
}

// check if the tile name is valid (5x5 grid)
bool boggle_valid_tile(string tile)
{
	if ( !tile )
		return false;
	int number = minigame_tile_number(tile);
	int letter = minigame_tile_letter(tile);
	return 0 <= number && number < BOGGLE_NUM_CNT && 0 <= letter && letter < BOGGLE_LET_CNT;
}

bool boggle_adjacent(string word, string tile)
{
	string last = string_null;
	FOREACH_WORD(word, boggle_valid_tile(it), LAMBDA(last = it));
	if(!last)
		return true; // if there's currently no last set, just accept it
	int dnumber = fabs ( minigame_tile_number(last) - minigame_tile_number(tile) );
	int dletter = fabs ( minigame_tile_letter(last) - minigame_tile_letter(tile) );

	return (dnumber <= 1 && dletter <= 1);
}

string boggle_letters[16] = 
{
	"A A E E G N", "A B B J O O",
	"A C H O P S", "A F F K P S",
	"A O O T T W", "C I M O T U",
	"D E I L R X", "D E L R V Y",
	"D I S T T Y", "E E G H N W",
	"E E I N S U", "E H R T V W",
	"E I O S S T", "E L R T T Y",
	"H I M N U Qu","H L N N R Z",
};

string boggle_get_letter(int try)
{
	RandomSelection_Init();

	//LOG_INFO(ftos(try));

	FOREACH_WORD(boggle_letters[try], true, LAMBDA(RandomSelection_AddString(it, 1, 1)));

	string dotry = RandomSelection_chosen_string;

	RandomSelection_Init();

	FOREACH_WORD(dotry, true, LAMBDA(RandomSelection_AddString(it, 1, 1)));

	return RandomSelection_chosen_string;
}

int boggle_get_unused(int used_bit)
{
	RandomSelection_Init();

	for(int i = 0; i < 16; ++i)
		if(!(used_bit & BIT(i)))
			RandomSelection_AddFloat(i, 1, 1);

	return RandomSelection_chosen_float;
}

void boggle_setup_pieces(entity minigame)
{
	int i, t;
	int used = 0;
	for(i = 0; i < BOGGLE_NUM_CNT; ++i)
	for(t = 0; t < BOGGLE_LET_CNT; ++t)
	{
		string try = minigame_tile_buildname(i,t);
		if(!boggle_valid_tile(try))
			continue;
		int touse = boggle_get_unused(used);
		used |= BIT(touse);
	    string letter = strzone(boggle_get_letter(touse));
		entity piece = msle_spawn(minigame,new(minigame_board_piece));
		piece.boggle_letter = letter;
		piece.team = 1; // init default team?
		piece.netname = strzone(minigame_tile_buildname(t,i));
		minigame_server_sendflags(piece,MINIG_SF_ALL);
	}

	minigame_server_sendflags(minigame,MINIG_SF_UPDATE);
}

entity boggle_get_player(entity minigame, int pteam)
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

void boggle_add_wordscore(entity minigame, int pteam, int thescore)
{
#ifdef SVQC
	if(!minigame)
		return;
	entity pl = boggle_get_player(minigame, pteam);
	if(pl)
	{
		pl.boggle_wordscore += thescore;
		pl.SendFlags |= BOGGLE_SF_PLAYERSCORE;
	}
#endif
}

void boggle_add_score(entity minigame, int pteam, int thescore)
{
#ifdef SVQC
	if(!minigame)
		return;
	entity pl = boggle_get_player(minigame, pteam);
	if(pl)
	{
		pl.boggle_score += thescore;
		pl.SendFlags |= BOGGLE_SF_PLAYERSCORE;
	}
#endif
}

// make a move
void boggle_move(entity minigame, entity player, string letters )
{
	if ( minigame.minigame_flags & BOGGLE_TURN_MOVE )
	{
		string theword = "";
		string prev = "";
		FOREACH_WORD(letters, boggle_valid_tile(it), LAMBDA(
			entity piece = boggle_find_piece(minigame, it);
			if(!piece) break;
			if(prev != "")
			if(!boggle_adjacent(prev, it))
				return; // NOPE!
			prev = it;
			theword = strcat(theword, piece.boggle_letter);
		));

		if(strlen(theword) <= 2)
			return; // no 2 letter words

		if(Find_Word_Entity(theword) && !boggle_word_in_list(minigame, theword))
		{
			boggle_spawn_list_item(minigame, theword);
			boggle_add_wordscore(minigame, player.team, 1);
			boggle_add_score(minigame, player.team, strlen(theword) - 2); // 1 point per 3 letter word
		}

		minigame_server_sendflags(minigame,MINIG_SF_UPDATE);

		minigame.minigame_flags = BOGGLE_TURN_MOVE;
	}
}

void boggle_end_round(entity this)
{
	if ( !this.descriptor || this.classname != "minigame" )
		return;

	this.minigame_flags = BOGGLE_TURN_DRAW;
	this.boggle_timer_start = 0;

	minigame_server_sendflags(this,MINIG_SF_UPDATE);
}

void boggle_begin_round(entity minigame)
{
	if(minigame.minigame_flags & BOGGLE_TURN_WAIT)
	{
		minigame_server_sendflags(minigame,MINIG_SF_UPDATE);
		minigame.minigame_flags = BOGGLE_TURN_MOVE;
		minigame.boggle_timer_start = time;

		if(autocvar_sv_minigames_boggle_timelimit > 0)
			defer(minigame, autocvar_sv_minigames_boggle_timelimit, boggle_end_round);
	}
}

#ifdef SVQC

// required function, handle server side events
int boggle_server_event(entity minigame, string event, ...)
{
	switch(event)
	{
		case "start":
		{
			minigame.boggle_words = LL_NEW();
			boggle_setup_pieces(minigame);
			minigame.minigame_flags = BOGGLE_TURN_WAIT;
			return true;
		}
		case "end":
		{
			LL_CLEAR(minigame.boggle_words, { strfree(it.netname); });

			entity e = NULL;
			while( (e = findentity(e, owner, minigame)) )
			if(e.classname == "minigame_board_piece")
			{
				strfree(e.netname);
				strfree(e.boggle_letter);
				delete(e);
			}
			return false;
		}
		case "join":
		{
			int pl_num = minigame_count_players(minigame);

			// Don't allow more than 1 player
			if(pl_num >= 1) { return false; }

			// Team 1 by default
			return 1;
		}
		case "cmd":
		{
			switch(argv(0))
			{
				case "move":
					boggle_move(minigame, ...(0,entity), (...(1,int) == 2 ? argv(1) : string_null));
					return true;
				case "ready":
					boggle_begin_round(minigame);
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
				WriteString(MSG_ENTITY,sent.boggle_letter);
			}
			else if ( sent.classname == "minigame_player" && (sf & BOGGLE_SF_PLAYERSCORE ) )
			{
				WriteLong(MSG_ENTITY,sent.boggle_wordscore);
				WriteLong(MSG_ENTITY,sent.boggle_score);
			}
			return false;
		}
	}

	return false;
}


#elif defined(CSQC)

string boggle_curr_pos; // identifier of the tile under the mouse
vector boggle_boardpos; // HUD board position
vector boggle_boardsize;// HUD board size

string boggle_word;

bool boggle_mouse_pressed;

// Required function, draw the game board
void boggle_hud_board(vector pos, vector mySize)
{
	minigame_hud_fitsqare(pos, mySize);
	boggle_boardpos = pos;
	boggle_boardsize = mySize;

	minigame_hud_simpleboard(pos,mySize,minigame_texture("boggle/board"));

	vector tile_size = minigame_hud_denormalize_size('1 1 0' / BOGGLE_TILE_SIZE,pos,mySize);
	vector tile_pos;

	entity e;
	FOREACH_MINIGAME_ENTITY(e)
	{
		if ( e.classname == "minigame_board_piece" )
		{
			tile_pos = minigame_tile_pos(e.netname,BOGGLE_NUM_CNT,BOGGLE_LET_CNT);
			tile_pos = minigame_hud_denormalize(tile_pos,pos,mySize);

			vector tile_color = '1 1 1';

			if(e.netname == boggle_curr_pos)
				tile_color = '0 0 1';
			if(strhasword(boggle_word, e.netname))
				tile_color = '1 0 0';

			minigame_drawpic_centered( tile_pos,
					minigame_texture("boggle/piece"),
					tile_size * 0.8, tile_color, panel_fg_alpha, DRAWFLAG_NORMAL );

			if(e.boggle_letter && e.boggle_letter != "")
			{
				vector text_size = tile_size * 0.5;
				drawstring(tile_pos - text_size / 2, e.boggle_letter, text_size, '0 0 0', panel_fg_alpha, DRAWFLAG_NORMAL);
			}
		}
	}

	if ( active_minigame.minigame_flags & BOGGLE_TURN_DRAW )
	{
		vector winfs = hud_fontsize*2;

		vector win_pos = pos+eY*(mySize_y-winfs_y)/2;
		vector win_sz;
		win_sz = minigame_drawcolorcodedstring_wrapped(mySize_x,win_pos,
			"Time's up!",
			winfs, 0, DRAWFLAG_NORMAL, 0.5);

		drawfill(win_pos-eY*hud_fontsize_y,win_sz+2*eY*hud_fontsize_y,'1 1 1',0.5,DRAWFLAG_ADDITIVE);

		minigame_drawcolorcodedstring_wrapped(mySize_x,win_pos,
			"Time's up!",
			winfs, panel_fg_alpha, DRAWFLAG_NORMAL, 0.5);
	}
}


// Required function, draw the game status panel
void boggle_hud_status(vector pos, vector mySize)
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
	//vector tile_size = '48 48 0';

	mypos = pos;
	drawfill(mypos,eX*mySize_x+eY*player_fontsize_y,'1 1 1',0.5,DRAWFLAG_ADDITIVE);
	//mypos_y += player_fontsize_y;
	//mypos_y += player_fontsize_y; // double it?
	//drawfill(mypos,eX*mySize_x+eY*tile_size_y,'1 1 1',0.25,DRAWFLAG_ADDITIVE);

	entity e;
	FOREACH_MINIGAME_ENTITY(e)
	{
		if ( e.classname == "minigame_player" )
		{
			mypos = pos;
			minigame_drawcolorcodedstring_trunc(mySize_x,mypos,
				entcs_GetName(e.minigame_playerslot-1),
				player_fontsize, panel_fg_alpha, DRAWFLAG_NORMAL);

			mypos_y += player_fontsize_y;
			//drawpic( mypos,
			//		minigame_texture("boggle/piece"),
			//		tile_size, '1 0 0', panel_fg_alpha, DRAWFLAG_NORMAL );

			//mypos_x += tile_size_x;

			drawstring(mypos,sprintf("Words: %d", e.boggle_wordscore),'28 28 0',
					   '0.7 0.84 1', panel_fg_alpha, DRAWFLAG_NORMAL);

			mypos_y += player_fontsize_y;

			drawstring(mypos,sprintf("Score: %d", e.boggle_score),'28 28 0',
					   '0.7 0.84 1', panel_fg_alpha, DRAWFLAG_NORMAL);

			if(active_minigame.minigame_flags & BOGGLE_TURN_MOVE)
			if(STAT(BOGGLE_TIMER) > 0)
			{
				mypos_y += player_fontsize_y;

				drawstring(mypos,sprintf("Time left: %s", count_seconds(STAT(BOGGLE_TIMER))),'28 28 0',
						   '0.7 0.84 1', panel_fg_alpha, DRAWFLAG_NORMAL);
			}
		}
	}
}

// Turn a set of flags into a help message
string boggle_turn_to_string(int turnflags)
{
	if (turnflags & BOGGLE_TURN_DRAW )
		return "Game over!";

	if(turnflags & BOGGLE_TURN_WAIT)
		return "Press \"Ready\" to begin";

	if ( turnflags & BOGGLE_TURN_MOVE )
		return "Drag the mouse to select as many words as you can before time runs out!";

	return "";
}

void boggle_set_word(string s)
{
	strfree(boggle_word);
	if(s)
		s = strzone(s);
	boggle_word = s;
}

void boggle_set_next_letter(entity minigame, string s)
{
	entity piece = boggle_find_piece(minigame, s);
	if(!piece)
		return;

	boggle_set_word(strcat(boggle_word, " ", piece.netname));
}

// Make the correct move
void boggle_make_move(entity minigame)
{
	if ( minigame.minigame_flags == BOGGLE_TURN_MOVE )
	{
		if(boggle_word != "")
		{
			minigame_cmd("move \"", boggle_word, "\"");
			boggle_set_word("");
		}
	}
}

// TODO: make this not snap to the nearest tile
string boggle_tile_name(vector pos, int rows, int columns)
{
	//if ( pos_x < 0 || pos_x > 1 || pos_y < 0 || pos_y > 1 )
		//return ""; // no tile

	/*int letter = floor(pos_x * columns);
	int number = floor((1-pos_y) * rows);
	return minigame_tile_buildname(letter, number);*/

	vector tile_size = minigame_hud_denormalize_size('1 1 0' / BOGGLE_TILE_SIZE,boggle_boardpos,boggle_boardsize);
	vector tile_pos;
	entity e;
	FOREACH_MINIGAME_ENTITY(e)
	{
		if ( e.classname == "minigame_board_piece" )
		{
			tile_pos = minigame_tile_pos(e.netname,BOGGLE_NUM_CNT,BOGGLE_LET_CNT);
			tile_pos = minigame_hud_denormalize(tile_pos,boggle_boardpos,boggle_boardsize);

			if(minigame_hud_mouse_in(tile_pos - '48 48 0', tile_size))
				return e.netname;
		}
	}

	return "";
}


void boggle_set_curr_pos(string s)
{
	strfree(boggle_curr_pos);
	if ( s )
		s = strzone(s);
	boggle_curr_pos = s;
}

// Required function, handle client events
int boggle_client_event(entity minigame, string event, ...)
{
	switch(event)
	{
		case "activate":
		{
			boggle_set_curr_pos("");
			boggle_set_word("");
			boggle_mouse_pressed = false;
			minigame.message = boggle_turn_to_string(minigame.minigame_flags);
			return false;
		}
		case "key_pressed":
		{
			if(minigame.minigame_flags & BOGGLE_TURN_MOVE)
			{
				switch ( ...(0,int) )
				{
					case K_RIGHTARROW:
					case K_KP_RIGHTARROW:
						if ( ! boggle_curr_pos )
							boggle_set_curr_pos("a3");
						else
							boggle_set_curr_pos( minigame_relative_tile(boggle_curr_pos,1,0,BOGGLE_NUM_CNT,BOGGLE_LET_CNT));
						return true;
					case K_LEFTARROW:
					case K_KP_LEFTARROW:
						if ( ! boggle_curr_pos )
							boggle_set_curr_pos("c3");
						else
							boggle_set_curr_pos(minigame_relative_tile(boggle_curr_pos,-1,0,BOGGLE_NUM_CNT,BOGGLE_LET_CNT));
						return true;
					case K_UPARROW:
					case K_KP_UPARROW:
						if ( ! boggle_curr_pos )
							boggle_set_curr_pos("a1");
						else
							boggle_set_curr_pos(minigame_relative_tile(boggle_curr_pos,0,1,BOGGLE_NUM_CNT,BOGGLE_LET_CNT));
						return true;
					case K_DOWNARROW:
					case K_KP_DOWNARROW:
						if ( ! boggle_curr_pos )
							boggle_set_curr_pos("a3");
						else
							boggle_set_curr_pos(minigame_relative_tile(boggle_curr_pos,0,-1,BOGGLE_NUM_CNT,BOGGLE_LET_CNT));
						return true;
					case K_ENTER:
					case K_KP_ENTER:
						boggle_make_move(minigame);
						return true;
					case K_SPACE:
						if(boggle_curr_pos && !strhasword(boggle_word, boggle_curr_pos))
						if(boggle_adjacent(boggle_word, boggle_curr_pos))
							boggle_set_next_letter(minigame, boggle_curr_pos);
						return true;
				}
			}

			return false;
		}
		case "mouse_pressed":
		{
			if(...(0,int) == K_MOUSE1)
			{
				boggle_mouse_pressed = true;
				if(boggle_curr_pos && !strhasword(boggle_word, boggle_curr_pos))
				if(boggle_adjacent(boggle_word, boggle_curr_pos))
				{
					boggle_set_next_letter(minigame, boggle_curr_pos);
				}
				return true;
			}

			return false;
		}
		case "mouse_released":
		{
			if(...(0,int) == K_MOUSE1)
			{
				boggle_make_move(minigame);
				boggle_mouse_pressed = false;
				return true;
			}

			return false;
		}
		case "mouse_moved":
		{
			//vector mouse_pos = minigame_hud_normalize(mousepos,boggle_boardpos,boggle_boardsize);
			if ( minigame.minigame_flags == BOGGLE_TURN_MOVE )
				boggle_set_curr_pos(boggle_tile_name(mousepos,BOGGLE_NUM_CNT,BOGGLE_LET_CNT));
			if ( ! boggle_valid_tile(boggle_curr_pos) )
				boggle_set_curr_pos("");

			if(boggle_mouse_pressed && boggle_curr_pos && !strhasword(boggle_word, boggle_curr_pos))
			if(boggle_adjacent(boggle_word, boggle_curr_pos))
			{
				boggle_set_next_letter(minigame, boggle_curr_pos);
			}

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
					sent.message = boggle_turn_to_string(sent.minigame_flags);
					if ( sent.minigame_flags & minigame_self.team )
						minigame_prompt();
				}
			}
			else if(sent.classname == "minigame_board_piece" && (sf & MINIG_SF_UPDATE))
			{
				strfree(sent.boggle_letter);
				sent.boggle_letter = strzone(ReadString());
			}
			else if ( sent.classname == "minigame_player" && (sf & BOGGLE_SF_PLAYERSCORE ) )
			{
				sent.boggle_wordscore = ReadLong();
				sent.boggle_score = ReadLong();
			}

			return false;
		}
		case "menu_show":
		{
			HUD_MinigameMenu_CustomEntry(...(0,entity),"Ready","ready");
			return false;
		}
		case "menu_click":
		{
			if(...(0,string) == "ready")
			{
				minigame_cmd("ready");
			}
			return false;
		}
	}

	return false;
}

#endif

#endif
