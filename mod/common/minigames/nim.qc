//FEATURE: Nim minigame, the classic matchstick game with balls

REGISTER_MINIGAME(nim, "Nim");

const int NIM_TURN_PLACE = 0x0100; // player has to place a piece on the board
const int NIM_TURN_WIN   = 0x0200; // player has won
const int NIM_TURN_NEXT  = 0x0800; // a player wants to start a new match

const int NIM_TURN_TEAM1 = 0x0001;
const int NIM_TURN_TEAM2 = 0x0002;
const int NIM_TURN_TEAM  = 0x000f; // turn team mask

// send flags
const int NIM_SF_PLAYERSCORE  = MINIG_SF_CUSTOM;   // send minigame_player scores (won matches)

const int NIM_LET_CNT = 8;
const int NIM_NUM_CNT = 6;

//const int NIM_TILE_SIZE = 6;

const int NIM_TEAMS = 2;

.int nim_nexteam; // (minigame) next team (used to change the starting team on following matches)

// find nim piece given its tile name
entity nim_find_piece(entity minig, string tile)
{
	entity e = NULL;
	while ( ( e = findentity(e,owner,minig) ) )
		if ( e.classname == "minigame_board_piece" && e.netname == tile )
			return e;
	return NULL;
}

// Checks if the given piece completes a row
bool nim_winning_piece(entity minig)
{
	entity e = NULL;
	while ( ( e = findentity(e,owner,minig) ) )
		if ( e.classname == "minigame_board_piece" )
			return false;

	return true;
}

// check if the tile name is valid (6x7 grid)
bool nim_valid_tile(string tile)
{
	if ( !tile )
		return false;
	int number = minigame_tile_number(tile);
	int letter = minigame_tile_letter(tile);
	return 0 <= number && number < NIM_NUM_CNT && 0 <= letter && letter < NIM_LET_CNT;
}

void nim_spawn_piece(entity minigame, string pos)
{
	entity piece = msle_spawn(minigame,"minigame_board_piece");
	piece.team = 1; // not needed, but oh well
	piece.netname = strzone(pos);
	minigame_server_sendflags(piece,MINIG_SF_ALL);
}

void nim_setup_pieces(entity minigame)
{
	int i, j;
	int perteam = 2;
	for(i = NIM_NUM_CNT - 1; i >= 0; --i)
	{
		for(j = 0; j < perteam; ++j)
		{
			nim_spawn_piece(minigame, minigame_tile_buildname(j, i));
		}
		++perteam;
	}
}

// make a move
void nim_move(entity minigame, entity player, string pos )
{
	if ( minigame.minigame_flags & NIM_TURN_PLACE )
	if ( pos && player.team == (minigame.minigame_flags & NIM_TURN_TEAM) )
	{
		entity piece = nim_find_piece(minigame, pos);

		if ( nim_valid_tile(pos) )
		if ( piece )
		{
			int letter = minigame_tile_letter(pos);
			int number = minigame_tile_number(pos);
			int i;
			for(i = letter; i < NIM_LET_CNT; ++i)
			{
				entity thepiece = nim_find_piece(minigame, minigame_tile_buildname(i, number));
				if(!thepiece) break;
				if(thepiece.netname) { strunzone(thepiece.netname); }
				delete(thepiece);
			}

			minigame_server_sendflags(minigame,MINIG_SF_UPDATE);
			minigame.nim_nexteam = minigame_next_team(player.team,NIM_TEAMS);

			if ( nim_winning_piece(minigame) )
			{
				player.minigame_flags++;
				minigame_server_sendflags(player, NIM_SF_PLAYERSCORE);
				minigame.minigame_flags = NIM_TURN_WIN | player.team;
			}
			else
				minigame.minigame_flags = NIM_TURN_PLACE | minigame.nim_nexteam;
		}
	}
}

// request a new match
void nim_next_match(entity minigame, entity player)
{
#ifdef SVQC
	// on multiplayer matches, wait for both players to agree
	if ( minigame.minigame_flags & NIM_TURN_WIN )
	{
		minigame.minigame_flags = NIM_TURN_NEXT | player.team;
		minigame.SendFlags |= MINIG_SF_UPDATE;
	}
	else if ( (minigame.minigame_flags & NIM_TURN_NEXT) &&
			!( minigame.minigame_flags & player.team ) )
#endif
	{
		minigame.minigame_flags = NIM_TURN_PLACE | minigame.nim_nexteam;
		minigame_server_sendflags(minigame,MINIG_SF_UPDATE);
		FOREACH_ENTITY_ENT(owner, minigame, LAMBDA(
			if(it.classname != "minigame_board_piece") continue;
			if(it.netname) { strunzone(it.netname); }
			delete(it);
		));

		nim_setup_pieces(minigame);
	}
}

#ifdef SVQC


// required function, handle server side events
int nim_server_event(entity minigame, string event, ...)
{
	switch(event)
	{
		case "start":
		{
			minigame.minigame_flags = (NIM_TURN_PLACE | NIM_TURN_TEAM1);
			nim_setup_pieces(minigame);
			return true;
		}
		case "end":
		{
			FOREACH_ENTITY_ENT(owner, minigame, LAMBDA(
				if(it.classname != "minigame_board_piece") continue;
				if(it.netname) { strunzone(it.netname); }
				delete(it);
			));
			return false;
		}
		case "join":
		{
			int pl_num = minigame_count_players(minigame);

			// Don't allow more than 2 players
			if(pl_num >= NIM_TEAMS) { return false; }

			// Get the right team
			if(minigame.minigame_players)
				return minigame_next_team(minigame.minigame_players.team, NIM_TEAMS);

			// Team 1 by default
			return 1;
		}
		case "cmd":
		{
			switch(argv(0))
			{
				case "move":
					nim_move(minigame, ...(0,entity), ...(1,int) == 2 ? argv(1) : string_null );
					return true;
				case "next":
					nim_next_match(minigame,...(0,entity));
					return true;
			}

			return false;
		}
		case "network_send":
		{
			entity sent = ...(0,entity);
			int sf = ...(1,int);
			if ( sent.classname == "minigame_player" && (sf & NIM_SF_PLAYERSCORE ) )
			{
				WriteByte(MSG_ENTITY,sent.minigame_flags);
			}
			return false;
		}
	}

	return false;
}


#elif defined(CSQC)

string nim_curr_pos; // identifier of the tile under the mouse
vector nim_boardpos; // HUD board position
vector nim_boardsize;// HUD board size

#define nim_hud_fitboard(pos, mySize, xx) \
	if ( mySize##_x > mySize##_y ) \
	{ \
		pos##_x += (mySize##_x-(mySize##_y / xx))/2; \
		mySize##_x = mySize##_y / xx; \
	} \
	if(panel_bg_padding) \
	{ \
		pos += '1 1 0' * panel_bg_padding; \
		mySize -= '2 2 0' * panel_bg_padding; \
	}


// Required function, draw the game board
void nim_hud_board(vector pos, vector mySize)
{
	float xsize = (NIM_NUM_CNT / NIM_LET_CNT);

	nim_hud_fitboard(pos, mySize, xsize);
	//minigame_hud_fitsqare(pos, mySize);

	nim_boardpos = pos;
	nim_boardsize = mySize;

	minigame_hud_simpleboard(pos,mySize,minigame_texture("nim/board"));

	vector tile_size = minigame_hud_denormalize_size(vec2(1 / NIM_LET_CNT, 1 / NIM_NUM_CNT),pos,mySize);
	vector tile_pos;

	// draw the tiles
	// must be separate from piece drawing, as pieces can be removed
	int i, j;
	int per_row = 2;
	for(i = NIM_NUM_CNT - 1; i >= 0; --i)
	{
		for(j = 0; j < per_row; ++j)
		{
			tile_pos = minigame_tile_pos(minigame_tile_buildname(j,i),NIM_NUM_CNT,NIM_LET_CNT);
			tile_pos = minigame_hud_denormalize(tile_pos,pos,mySize);

			minigame_drawpic_centered( tile_pos,
					minigame_texture("nim/tile"),
					tile_size, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL );
		}
		++per_row;
	}

	FOREACH_ENTITY_ENT(owner, active_minigame,
	{
		if(it.classname != "minigame_board_piece") continue;
		tile_pos = minigame_tile_pos(it.netname,NIM_NUM_CNT,NIM_LET_CNT);
		tile_pos = minigame_hud_denormalize(tile_pos,pos,mySize);
		minigame_drawpic_centered( tile_pos,
				minigame_texture("nim/piece"),
				tile_size, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL );
	});

	if ( (active_minigame.minigame_flags & NIM_TURN_TEAM) == minigame_self.team )
	if ( nim_valid_tile(nim_curr_pos) )
	{
		tile_pos = minigame_tile_pos(nim_curr_pos,NIM_NUM_CNT,NIM_LET_CNT);
		tile_pos = minigame_hud_denormalize(tile_pos,pos,mySize);
		minigame_drawpic_centered( tile_pos,
				minigame_texture("nim/tile_selected"),
				tile_size, '1 1 1', panel_fg_alpha/2, DRAWFLAG_NORMAL );

		int letter = minigame_tile_letter(nim_curr_pos);
		int number = minigame_tile_number(nim_curr_pos);
		for(i = letter; i <= NIM_LET_CNT; ++i)
		{
			entity piece = nim_find_piece(active_minigame, minigame_tile_buildname(i, number));
			if(!piece)
				break;
			tile_pos = minigame_tile_pos(piece.netname,NIM_NUM_CNT,NIM_LET_CNT);
			tile_pos = minigame_hud_denormalize(tile_pos,pos,mySize);
			minigame_drawpic_centered( tile_pos,
					minigame_texture("nim/tile_selected"),
					tile_size, '1 1 1', panel_fg_alpha/2, DRAWFLAG_NORMAL );
		}
	}

	if ( active_minigame.minigame_flags & NIM_TURN_WIN )
	{
		vector winfs = hud_fontsize*2;
		string playername = "";
		FOREACH_ENTITY_ENT(owner, active_minigame,
		{
			if(it.classname != "minigame_player") continue;
			if(it.team == (active_minigame.minigame_flags & NIM_TURN_TEAM))
			{
				playername = entcs_GetName(it.minigame_playerslot-1);
				break;
			}
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
void nim_hud_status(vector pos, vector mySize)
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
	if ( (active_minigame.minigame_flags&NIM_TURN_TEAM) == 2 )
		mypos_y  += player_fontsize_y + ts_y;
	drawfill(mypos,eX*mySize_x+eY*player_fontsize_y,'1 1 1',0.5,DRAWFLAG_ADDITIVE);
	mypos_y += player_fontsize_y;
	drawfill(mypos,eX*mySize_x+eY*tile_size_y,'1 1 1',0.25,DRAWFLAG_ADDITIVE);

	FOREACH_ENTITY_ENT(owner, active_minigame,
	{
		if(it.classname != "minigame_player") continue;
		mypos = pos;
		if ( it.team == 2 )
			mypos_y  += player_fontsize_y + ts_y;
		minigame_drawcolorcodedstring_trunc(mySize_x,mypos,
			entcs_GetName(it.minigame_playerslot-1),
			player_fontsize, panel_fg_alpha, DRAWFLAG_NORMAL);

		mypos_y += player_fontsize_y;
		drawpic( mypos,
				minigame_texture("nim/piece"),
				tile_size, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL );

		mypos_x += tile_size_x;

		drawstring(mypos,ftos(it.minigame_flags),tile_size,
					'0.7 0.84 1', panel_fg_alpha, DRAWFLAG_NORMAL);
	});
}

// Turn a set of flags into a help message
string nim_turn_to_string(int turnflags)
{
	if ( turnflags & NIM_TURN_WIN )
	{
		if ( (turnflags&NIM_TURN_TEAM) != minigame_self.team )
			return _("You lost the game!\nSelect \"^1Next Match^7\" on the menu for a rematch!");
		return _("You win!\nSelect \"^1Next Match^7\" on the menu to start a new match!");
	}

	if ( turnflags & NIM_TURN_NEXT )
	{
		if ( (turnflags&NIM_TURN_TEAM) != minigame_self.team )
			return _("Select \"^1Next Match^7\" on the menu to start a new match!");
		return _("Wait for your opponent to confirm the rematch");
	}

	if ( (turnflags & NIM_TURN_TEAM) != minigame_self.team )
		return _("Wait for your opponent to make their move");

	if ( turnflags & NIM_TURN_PLACE )
		return _("Try to take the last piece on the board");

	return "";
}

// Make the correct move
void nim_make_move(entity minigame)
{
	if ( minigame.minigame_flags == (NIM_TURN_PLACE|minigame_self.team) )
	{
		minigame_cmd("move ",nim_curr_pos);
	}
}

void nim_set_curr_pos(string s)
{
	if ( nim_curr_pos )
		strunzone(nim_curr_pos);
	if ( s )
		s = strzone(s);
	nim_curr_pos = s;
}

// Required function, handle client events
int nim_client_event(entity minigame, string event, ...)
{
	switch(event)
	{
		case "activate":
		{
			nim_set_curr_pos("");
			minigame.message = nim_turn_to_string(minigame.minigame_flags);
			return false;
		}
		case "key_pressed":
		{
			if((minigame.minigame_flags & NIM_TURN_TEAM) == minigame_self.team)
			{
				switch ( ...(0,int) )
				{
					case K_RIGHTARROW:
					case K_KP_RIGHTARROW:
						if ( ! nim_curr_pos )
							nim_set_curr_pos("a3");
						else
							nim_set_curr_pos(minigame_relative_tile(nim_curr_pos,1,0,NIM_NUM_CNT,NIM_LET_CNT));
						return true;
					case K_LEFTARROW:
					case K_KP_LEFTARROW:
						if ( ! nim_curr_pos )
							nim_set_curr_pos("c3");
						else
							nim_set_curr_pos(minigame_relative_tile(nim_curr_pos,-1,0,NIM_NUM_CNT,NIM_LET_CNT));
						return true;
					case K_UPARROW:
					case K_KP_UPARROW:
						if ( ! nim_curr_pos )
							nim_set_curr_pos("a1");
						else
							nim_set_curr_pos(minigame_relative_tile(nim_curr_pos,0,1,6,7));
						return true;
					case K_DOWNARROW:
					case K_KP_DOWNARROW:
						if ( ! nim_curr_pos )
							nim_set_curr_pos("a3");
						else
							nim_set_curr_pos(minigame_relative_tile(nim_curr_pos,0,-1,6,7));
						return true;
					case K_ENTER:
					case K_KP_ENTER:
					case K_SPACE:
						nim_make_move(minigame);
						return true;
				}
			}

			return false;
		}
		case "mouse_pressed":
		{
			if(...(0,int) == K_MOUSE1)
			{
				nim_make_move(minigame);
				return true;
			}

			return false;
		}
		case "mouse_moved":
		{
			vector mouse_pos = minigame_hud_normalize(mousepos,nim_boardpos,nim_boardsize);
			if ( minigame.minigame_flags == (NIM_TURN_PLACE|minigame_self.team) )
			{
				nim_set_curr_pos(minigame_tile_name(mouse_pos,NIM_NUM_CNT,NIM_LET_CNT));
			}
			if ( ! nim_valid_tile(nim_curr_pos) )
				nim_set_curr_pos("");

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
					sent.message = nim_turn_to_string(sent.minigame_flags);
					if ( sent.minigame_flags & minigame_self.team )
						minigame_prompt();
				}
			}
			else if ( sent.classname == "minigame_player" && (sf & NIM_SF_PLAYERSCORE ) )
			{
				sent.minigame_flags = ReadByte();
			}

			return false;
		}
		case "menu_show":
		{
			HUD_MinigameMenu_CustomEntry(...(0,entity),_("Next Match"),"next");
			return false;
		}
		case "menu_click":
		{
			if(...(0,string) == "next")
				minigame_cmd("next");
			return false;
		}
	}

	return false;
}

#endif
