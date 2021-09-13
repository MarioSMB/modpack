//FEATURE: Voracity minigame, a little number navigation game

REGISTER_MINIGAME(vr, "Voracity");

const int VR_TURN_TAKE  = 0x0100; // player has to take a piece (or more) from the board
const int VR_TURN_WIN   = 0x0200; // no moves possible, but we consider this a win (impossible to take all pieces)
const int VR_TURN_TYPE  = 0x0f00; // turn type mask

const int VR_SF_PLAYERSCORE = MINIG_SF_CUSTOM;

const int VR_LET_CNT = 19;
const int VR_NUM_CNT = 19;

const int VR_TILE_SIZE = 19;

const int VR_SPECTATOR_TEAM = 255; // must be above max teams and equal to or below 255

const vector VR_DIR_UP = '0 1 0';
const vector VR_DIR_DN = '0 -1 0';
const vector VR_DIR_LF = '-1 0 0';
const vector VR_DIR_RT = '1 0 0';

.int vr_score;
.entity vr_targ;

// find same game piece given its tile name
entity vr_find_piece(entity minig, string tile)
{
	entity e = NULL;
	while ( ( e = findentity(e,owner,minig) ) )
		if ( e.classname == "minigame_board_piece" && e.netname == tile )
			return e;
	return NULL;
}

// Checks if the player can still move
bool vr_test_dir(entity minigame, entity targ, vector dir);
bool vr_winning_piece(entity minigame, entity targ)
{
	if(!targ)
		return true; // end game if there's no main piece (TODO: make the starter piece placement better!)

	bool valid = false;
	valid |= vr_test_dir(minigame, targ, VR_DIR_UP);
	valid |= vr_test_dir(minigame, targ, VR_DIR_DN);
	valid |= vr_test_dir(minigame, targ, VR_DIR_LF);
	valid |= vr_test_dir(minigame, targ, VR_DIR_RT);

	if(!valid)
		return true; // no more valid moves
	
	return false;
}

// check if the tile name is valid (19x19 grid)
bool vr_valid_tile(string tile)
{
	if ( !tile )
		return false;
	float number = minigame_tile_number(tile);
	float letter = minigame_tile_letter(tile);
	return 0 <= number && number < VR_NUM_CNT && 0 <= letter && letter < VR_LET_CNT;
}

void vr_setup_pieces(entity minigame)
{
	int targnum = bound(0, floor(random() * VR_NUM_CNT), VR_NUM_CNT);
	int targlet = bound(0, floor(random() * VR_LET_CNT), VR_LET_CNT);
	int j, t;
	for(j = 0; j < VR_NUM_CNT; ++j)
	{
		for(t = 0; t < VR_LET_CNT; ++t)
		{
			entity piece = msle_spawn(minigame,new(minigame_board_piece));
			piece.team = 1; // init default team?
			piece.netname = strzone(minigame_tile_buildname(t,j));
			piece.cnt = max(1, floor(random() * 8));
			if(t == targlet && j == targnum)
			{
				minigame.vr_targ = piece;
				piece.cnt = 0;
			}
			minigame_server_sendflags(piece,MINIG_SF_ALL);
		}
	}

	minigame_server_sendflags(minigame,MINIG_SF_UPDATE);
}

void vr_add_score(entity minigame, int thescore)
{
#ifdef SVQC
	if(!minigame)
		return;
	if(minigame.minigame_players)
	{
		minigame.minigame_players.vr_score += thescore;
		minigame.minigame_players.SendFlags |= VR_SF_PLAYERSCORE;
	}
#endif
}

vector vr_dir_fromname(string bdir)
{
	if(bdir == "up" || bdir == "u")
		return VR_DIR_UP; // up
	if(bdir == "down" || bdir == "dn" || bdir == "d")
		return VR_DIR_DN; /// down
	if(bdir == "left" || bdir == "lt" || bdir == "l")
		return VR_DIR_LF; // left
	if(bdir == "right" || bdir == "rt" || bdir == "r")
		return VR_DIR_RT; // right

	return '0 0 0'; // no move
}

bool vr_test_dir(entity minigame, entity targ, vector dir)
{
	int letter = minigame_tile_letter(targ.netname);
	int number = minigame_tile_number(targ.netname);
	entity piece = vr_find_piece(minigame, minigame_tile_buildname(letter + dir.x, number + dir.y));
	if(!piece)
		return false;

	int pscore = piece.cnt;

	for(int j = 1; j <= pscore; ++j)
	{
		string pos = minigame_tile_buildname(letter + (dir.x * j), number + (dir.y * j));
		if(!vr_valid_tile(pos) || !vr_find_piece(minigame, pos))
			return false;
	}

	return true;
}

// make a move
void vr_move(entity minigame, entity player, string dir )
{
	if ( minigame.minigame_flags & VR_TURN_TAKE )
	if ( dir )
	{
		//if ( vr_valid_tile(dir) )
		//if ( vr_find_piece(minigame, dir) )
		{
			string thedir = strtolower(dir);
			vector bdir = vr_dir_fromname(thedir);
			if(!bdir)
				return;

			entity targ = minigame.vr_targ;
			int tlet = minigame_tile_letter(targ.netname);
			int tnum = minigame_tile_number(targ.netname);

			string piece_pos = minigame_tile_buildname(tlet + bdir.x, tnum + bdir.y);
			entity thepiece = vr_find_piece(minigame, piece_pos);
			if(!thepiece)
				return; // no piece, just abort

			if(!vr_test_dir(minigame, targ, bdir))
				return; // move can't be performed, abort!

			// move is possible
			int pscore = thepiece.cnt;
			for(int j = 1; j <= pscore; ++j)
			{
				string pos = minigame_tile_buildname(tlet + (bdir.x * j), tnum + (bdir.y * j));
				entity piece = vr_find_piece(minigame, pos); // assume exists?!
				strfree(piece.netname);
				delete(piece);
			}

			string endpos = minigame_tile_buildname(tlet + (bdir.x * pscore), tnum + (bdir.y * pscore));
			if(targ.netname) { strunzone(targ.netname); }
			targ.netname = strzone(endpos);
			minigame_server_sendflags(targ,MINIG_SF_ALL);

			vr_add_score(minigame,pscore);

			minigame_server_sendflags(minigame,MINIG_SF_UPDATE);

			if ( vr_winning_piece(minigame, targ) )
				minigame.minigame_flags = VR_TURN_WIN;
			else
				minigame.minigame_flags = VR_TURN_TAKE;
		}
	}
}

#ifdef SVQC


// required function, handle server side events
int vr_server_event(entity minigame, string event, ...)
{
	switch(event)
	{
		case "start":
		{
			vr_setup_pieces(minigame);
			minigame.minigame_flags = VR_TURN_TAKE;
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
			minigame.vr_targ = NULL;
			return false;
		}
		case "join":
		{
			int pl_num = minigame_count_players(minigame);

			// Don't allow more than 1 player
			// not sure if this should be a multiplayer game (might get crazy)
			if(pl_num >= 1) { return VR_SPECTATOR_TEAM; }

			// Team 1 by default
			return 1;
		}
		case "cmd":
		{
			entity player = ...(0,entity);
			bool event_blocked = (player.team == BD_SPECTATOR_TEAM);
			switch(argv(0))
			{
				case "move": 
					if(event_blocked)
						return true;
					vr_move(minigame, ...(0,entity), ...(1,int) == 2 ? argv(1) : string_null ); 
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
				WriteByte(MSG_ENTITY,sent.cnt);
			}
			else if ( sent.classname == "minigame_player" && (sf & VR_SF_PLAYERSCORE ) )
			{
				WriteLong(MSG_ENTITY,sent.vr_score);
			}
			return false;
		}
	}
	
	return false;
}


#elif defined(CSQC)

vector vr_boardpos; // HUD board position
vector vr_boardsize;// HUD board size

// Required function, draw the game board
void vr_hud_board(vector pos, vector mySize)
{
	minigame_hud_fitsqare(pos, mySize);
	vr_boardpos = pos;
	vr_boardsize = mySize;
	
	minigame_hud_simpleboard(pos,mySize,minigame_texture("vr/board"));

	vector tile_size = minigame_hud_denormalize_size('1 1 0' / VR_TILE_SIZE,pos,mySize);
	vector tile_pos;

	entity e;
	FOREACH_MINIGAME_ENTITY(e)
	{
		if ( e.classname == "minigame_board_piece" )
		{
			tile_pos = minigame_tile_pos(e.netname,VR_NUM_CNT,VR_LET_CNT);
			tile_pos = minigame_hud_denormalize(tile_pos,pos,mySize);
			string thepiece = "vr/tile";
			if(!e.cnt)
				thepiece = "vr/piece";

			vector my_color = ((active_minigame.minigame_flags & VR_TURN_WIN) ? '0.3 0.3 0.3' : ((!e.cnt) ? '1 1 1' : '0.6 0.6 0.6'));
			minigame_drawpic_centered( tile_pos,  
					minigame_texture(thepiece),
					tile_size, my_color, panel_fg_alpha, DRAWFLAG_NORMAL );
			if(e.cnt)
			{
				my_color = ((active_minigame.minigame_flags & VR_TURN_WIN) ? '0.5 0.5 0.5' : '1 1 1');
				vector text_size = tile_size * 0.5;
				drawstring(tile_pos - text_size / 2, itos(e.cnt), text_size, my_color, panel_fg_alpha, DRAWFLAG_NORMAL);
			}
		}
	}

	if ( active_minigame.minigame_flags & VR_TURN_WIN )
	{
		int scores = 0;
		FOREACH_MINIGAME_ENTITY(e)
			if(e.classname == "minigame_player" && e.team != VR_SPECTATOR_TEAM)
				scores = e.vr_score;

		vector winfs = hud_fontsize*2;
		string scores_text;
		scores_text = strcat("Score: ", ftos(scores));
		
		vector win_pos = pos+eY*(mySize.y-winfs_y)/2;
		vector win_sz;
		win_sz = minigame_drawcolorcodedstring_wrapped(mySize.x,win_pos,
			sprintf("Game over! %s", scores_text), 
			winfs, 0, DRAWFLAG_NORMAL, 0.5);
		
		drawfill(win_pos-eY*hud_fontsize_y,win_sz+2*eY*hud_fontsize_y,'0.3 0.3 1',0.8,DRAWFLAG_ADDITIVE);
		
		minigame_drawcolorcodedstring_wrapped(mySize.x,win_pos,
			sprintf("Game over! %s", scores_text), 
			winfs, panel_fg_alpha, DRAWFLAG_NORMAL, 0.5);
	}
}


// Required function, draw the game status panel
void vr_hud_status(vector pos, vector mySize)
{
	HUD_Panel_DrawBg();
	vector ts;
	ts = minigame_drawstring_wrapped(mySize.x,pos,active_minigame.descriptor.message,
		hud_fontsize * 2, '0.25 0.47 0.72', panel_fg_alpha, DRAWFLAG_NORMAL,0.5);
	
	pos_y += ts_y;
	mySize.y -= ts_y;
	
	vector player_fontsize = hud_fontsize * 1.75;
	ts_y = ( mySize.y - 2*player_fontsize.y ) / 2;
	ts_x = mySize.x;
	vector mypos;
	vector tile_size = '48 48 0';

	if(minigame_self.team != VR_SPECTATOR_TEAM)
	{
		mypos = pos;
		drawfill(mypos,eX*mySize.x+eY*player_fontsize.y,'1 1 1',0.5,DRAWFLAG_ADDITIVE);
		mypos_y += player_fontsize.y;
		drawfill(mypos,eX*mySize.x+eY*tile_size_y,'1 1 1',0.25,DRAWFLAG_ADDITIVE);
	}

	entity e;
	FOREACH_MINIGAME_ENTITY(e)
	{
		if ( e.classname == "minigame_player" && e.team != VR_SPECTATOR_TEAM )
		{
			mypos = pos;
			minigame_drawcolorcodedstring_trunc(mySize.x,mypos,
				entcs_GetName(e.minigame_playerslot-1),
				player_fontsize, panel_fg_alpha, DRAWFLAG_NORMAL);
			
			mypos_y += player_fontsize.y;
			//drawpic( mypos,  
			//		minigame_texture("vr/piece"),
			//		tile_size, '1 0 0', panel_fg_alpha, DRAWFLAG_NORMAL );
			
			//mypos_x += tile_size_x;

			drawstring(mypos,ftos(e.vr_score),tile_size,
					   '0.7 0.84 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		}
	}
}

// Turn a set of flags into a help message
string vr_turn_to_string(int turnflags)
{
	if(minigame_self.team == VR_SPECTATOR_TEAM)
		return _("You are spectating");

	if ( turnflags & VR_TURN_WIN )
		return _("No more valid moves, you win");
	
	if ( turnflags & VR_TURN_TAKE )
		return _("Click on a piece next to the target");
	
	return "";
}

// Make the correct move
void vr_make_move(entity minigame, string dir)
{
	if ( minigame.minigame_flags == VR_TURN_TAKE )
	{
		minigame_cmd("move ",dir);
	}
}

// Required function, handle client events
int vr_client_event(entity minigame, string event, ...)
{
	switch(event)
	{
		case "activate":
		{
			minigame.message = vr_turn_to_string(minigame.minigame_flags);
			return false;
		}
		case "key_pressed":
		case "key_released":
		{
			bool event_blocked = ((event == "key_released")
				|| !(minigame.minigame_flags & VR_TURN_TAKE) || (minigame_self.team == VR_SPECTATOR_TEAM));
			if (!(minigame.minigame_flags & VR_TURN_WIN))
			{
				switch ( ...(0,int) )
				{
					case K_RIGHTARROW:
					case K_KP_RIGHTARROW:
						if (event_blocked)
							return true;
						vr_make_move(minigame, "r");
						return true;
					case K_LEFTARROW:
					case K_KP_LEFTARROW:
						if (event_blocked)
							return true;
						vr_make_move(minigame, "l");
						return true;
					case K_UPARROW:
					case K_KP_UPARROW:
						if (event_blocked)
							return true;
						vr_make_move(minigame, "u");
						return true;
					case K_DOWNARROW:
					case K_KP_DOWNARROW:
						if (event_blocked)
							return true;
						vr_make_move(minigame, "d");
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
					sent.message = vr_turn_to_string(sent.minigame_flags);
				}
			}
			else if(sent.classname == "minigame_board_piece")
			{
				if(sf & MINIG_SF_UPDATE)
				{
					sent.cnt = ReadByte();
					if(!sent.cnt)
						minigame.vr_targ = sent;
				}
			}
			else if ( sent.classname == "minigame_player" && (sf & VR_SF_PLAYERSCORE ) )
			{
				sent.vr_score = ReadLong();
			}

			return false;
		}
	}

	return false;
}

#endif