const float TTT_TURN_PLACE = 0x0100; // player has to place a piece on the board
const float TTT_TURN_WIN   = 0x0200; // player has won
const float TTT_TURN_DRAW  = 0x0400; // no moves are possible
const float TTT_TURN_NEXT  = 0x0800; // a player wants to start a new match
const float TTT_TURN_TYPE  = 0xff00;

const float TTT_TURN_TEAM1 = 0x0001;
const float TTT_TURN_TEAM2 = 0x0002;
const float TTT_TURN_TEAM  = 0x000f; 

const float TTT_SF_PLAYERSCORE = MINIG_SF_CUSTOM;

// find tic tac toe piece given its tile name
entity ttt_find_piece(entity minig, string tile)
{
	entity e = world;
	while ( ( e = findentity(e,owner,minig) ) )
		if ( e.classname == "minigame_board_piece" && e.netname == tile )
			return e;
	return world;
}

// Checks if the given piece completes a row
float ttt_winning_piece(entity piece)
{
	float number = minigame_tile_number(piece.netname);
	float letter = minigame_tile_letter(piece.netname);
	
	if ( ttt_find_piece(piece.owner,minigame_tile_buildname(0,number)).team == piece.team )
	if ( ttt_find_piece(piece.owner,minigame_tile_buildname(1,number)).team == piece.team )
	if ( ttt_find_piece(piece.owner,minigame_tile_buildname(2,number)).team == piece.team )
		return 1;
	
	if ( ttt_find_piece(piece.owner,minigame_tile_buildname(letter,0)).team == piece.team )
	if ( ttt_find_piece(piece.owner,minigame_tile_buildname(letter,1)).team == piece.team )
	if ( ttt_find_piece(piece.owner,minigame_tile_buildname(letter,2)).team == piece.team )
		return 1;
	
	if ( number == letter )
	if ( ttt_find_piece(piece.owner,minigame_tile_buildname(0,0)).team == piece.team )
	if ( ttt_find_piece(piece.owner,minigame_tile_buildname(1,1)).team == piece.team )
	if ( ttt_find_piece(piece.owner,minigame_tile_buildname(2,2)).team == piece.team )
		return 1;
	
	if ( number == 2-letter )
	if ( ttt_find_piece(piece.owner,minigame_tile_buildname(0,2)).team == piece.team )
	if ( ttt_find_piece(piece.owner,minigame_tile_buildname(1,1)).team == piece.team )
	if ( ttt_find_piece(piece.owner,minigame_tile_buildname(2,0)).team == piece.team )
		return 1;
	
	return 0;
}

float ttt_valid_tile(string tile)
{
	if ( !tile )
		return 0;
	float number = minigame_tile_number(tile);
	float letter = minigame_tile_letter(tile);
	return 0 <= number && number <= 2 && 0 <= letter && letter <= 2;
}

#ifdef SVQC

.float ttt_npieces;
.float ttt_nexteam;

void ttt_move(entity minigame, entity player, float argc )
{
	if ( minigame.minigame_flags & TTT_TURN_PLACE )
	if ( argc == 2 && player.team == (minigame.minigame_flags & TTT_TURN_TEAM) )
	{
		string pos = argv(1);
		if ( ttt_valid_tile(pos) )
		if ( !ttt_find_piece(minigame,pos) )
		{
			entity piece = minigame_spawn_linked_entity(minigame,"minigame_board_piece");
			piece.team = player.team;
			piece.netname = strzone(pos);
			piece.SendFlags = MINIG_SF_ALL;
			minigame.SendFlags |= MINIG_SF_UPDATE;
			minigame.ttt_npieces++;
			minigame.ttt_nexteam = minigame_next_team(player.team,2);
			if ( ttt_winning_piece(piece) )
			{
				player.minigame_flags++;
				player.SendFlags |= TTT_SF_PLAYERSCORE;
				minigame.minigame_flags = TTT_TURN_WIN | player.team;
			}
			else if ( minigame.ttt_npieces >= 9 )
				minigame.minigame_flags = TTT_TURN_DRAW;
			else
				minigame.minigame_flags = TTT_TURN_PLACE | minigame.ttt_nexteam;
		}
	}
}

// required function, handle server side events
float minigame_event_ttt(entity minigame, string event, ...)
{
	if ( event == "start" )
	{
		minigame.minigame_flags = TTT_TURN_PLACE|TTT_TURN_TEAM1;
		return 1;
	}
	else if ( event == "end" )
	{
		entity e = world;
		while ( ( e = findentity(e,owner,minigame) ) )
			if ( e.classname == "minigame_board_piece" )
			{
				strunzone(e.netname);
				remove(e);
			}
	}
	else if ( event == "join" )
	{
		float player_number = 0;
		entity e;
		for ( e = minigame.minigame_players; e; e = e.list_next )
			player_number++;
		
		// Don't allow more than 2 players
		if ( player_number >= 2 )
			return 0;
		// Get the right team
		if ( minigame.minigame_players)
			return minigame_next_team(minigame.minigame_players.team,2);
		// Team 1 by default
		return 1;
	}
	else if ( event == "cmd" )
	{
		if ( argv(0) == "move" )
		{
			ttt_move(minigame, ...(0,entity), ...(1,float));
			return 1;
		}
		else if ( argv(0) == "next" )
		{
			entity player = ...(0,entity);
			if ( minigame.minigame_flags & (TTT_TURN_WIN|TTT_TURN_DRAW) )
			{
				minigame.minigame_flags = TTT_TURN_NEXT | player.team;
				minigame.SendFlags |= MINIG_SF_UPDATE;
			}
			else if ( (minigame.minigame_flags & TTT_TURN_NEXT) &&
					!( minigame.minigame_flags & player.team ) )
			{
				minigame.minigame_flags = TTT_TURN_PLACE | minigame.ttt_nexteam;
				minigame.SendFlags |= MINIG_SF_UPDATE;
				minigame.ttt_npieces = 0;
				entity e = world;
				while ( ( e = findentity(e,owner,minigame) ) )
					if ( e.classname == "minigame_board_piece" )
						remove(e);
			}
			return 1;
		}
	}
	else if ( event == "network_send" )
	{
		entity sent = ...(0,entity);
		float sf = ...(1,float);
		if ( sent.classname == "minigame_player" && (sf & TTT_SF_PLAYERSCORE ) )
		{
			WriteByte(MSG_ENTITY,sent.minigame_flags);
		}
	}
	
	return 0;
}


#elif defined(CSQC)

string ttt_curr_pos; // identifier of the tile under the mouse
vector ttt_boardpos; // HUD board position
vector ttt_boardsize;// HUD board size
.float ttt_checkwin; // Used to optimize checks to display a win

// Required function, draw the game board
void minigame_hud_board_ttt(vector pos, vector mySize)
{
	minigame_hud_fitsqare(pos, mySize);
	ttt_boardpos = pos;
	ttt_boardsize = mySize;
	
	minigame_hud_simpleboard(pos,mySize,minigame_texture("ttt/board"));

	vector tile_size = minigame_hud_denormalize_size('1 1 0'/3,pos,mySize);
	vector tile_pos;

	if ( (active_minigame.minigame_flags & TTT_TURN_TEAM) == minigame_self.team )
	if ( ttt_valid_tile(ttt_curr_pos) )
	{
		tile_pos = minigame_tile_pos(ttt_curr_pos,3,3);
		tile_pos = minigame_hud_denormalize(tile_pos,pos,mySize);
		minigame_drawpic_centered( tile_pos,  
				minigame_texture(strcat("ttt/piece",ftos(minigame_self.team))),
				tile_size, '1 1 1', panel_fg_alpha/2, DRAWFLAG_NORMAL );
	}
	
	entity e;
	FOREACH_MINIGAME_ENTITY(e)
	{
		if ( e.classname == "minigame_board_piece" )
		{
			tile_pos = minigame_tile_pos(e.netname,3,3);
			tile_pos = minigame_hud_denormalize(tile_pos,pos,mySize);
			
			if ( active_minigame.minigame_flags & TTT_TURN_WIN )
			if ( !e.ttt_checkwin )
				e.ttt_checkwin = ttt_winning_piece(e) ? 1 : -1;
			
			float icon_color = 1;
			if ( e.ttt_checkwin == -1 )
				icon_color = 0.4;
			else if ( e.ttt_checkwin == 1 )
			{
				icon_color = 2;
				minigame_drawpic_centered( tile_pos, minigame_texture("ttt/winglow"),
						tile_size, '1 1 1', panel_fg_alpha, DRAWFLAG_ADDITIVE );
			}
				
			minigame_drawpic_centered( tile_pos,  
					minigame_texture(strcat("ttt/piece",ftos(e.team))),
					tile_size, '1 1 1'*icon_color, panel_fg_alpha, DRAWFLAG_NORMAL );
		}
	}
}


// Required function, draw the game status panel
void minigame_hud_status_ttt(vector pos, vector mySize)
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
	vector mypos;
	vector tile_size = '48 48 0';

	entity e;
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
			
			mypos_y += player_fontsize_y;
			drawpic( mypos,  
					minigame_texture(strcat("ttt/piece",ftos(e.team))),
					tile_size, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL );
			
			mypos_x += tile_size_x;
			
			drawstring(mypos,ftos(e.minigame_flags),tile_size,
					   '0.7 0.84 1', panel_fg_alpha, DRAWFLAG_NORMAL);
		}
	}
}

// Make the correct move
void ttt_make_move(entity minigame)
{
	if ( minigame.minigame_flags == (TTT_TURN_PLACE|minigame_self.team) )
	{
		minigame_cmd("move ",ttt_curr_pos);
	}
}

// Turn a set of flags into a help message
string ttt_turn_to_string(float turnflags)
{
	if ( turnflags & TTT_TURN_DRAW )
		return _("Draw");
	
	if ( turnflags & TTT_TURN_WIN )
	{
		if ( (turnflags&TTT_TURN_TEAM) != minigame_self.team )
			return _("You lost the game!");
		return _("You win!");
	}
	
	if ( turnflags & TTT_TURN_NEXT )
	{
		if ( (turnflags&TTT_TURN_TEAM) != minigame_self.team )
			return _("Select \"^1Next Match^7\" on the menu to start a new match!");
		return _("Wait for your opponent to confirm the rematch");
	}
	
	if ( (turnflags & TTT_TURN_TEAM) != minigame_self.team )
		return _("Wait for your opponent to make their move");
	
	if ( turnflags & TTT_TURN_PLACE )
		return _("Click on the game board to place your piece");
	
	return "";
}

void ttt_set_curr_pos(string s)
{
	if ( ttt_curr_pos )
		strunzone(ttt_curr_pos);
	if ( s )
		s = strzone(s);
	ttt_curr_pos = s;
}

// Required function, handle client events
float minigame_event_ttt(entity minigame, string event, ...)
{
	if ( event == "activate" )
	{
		ttt_set_curr_pos("");
		minigame.message = ttt_turn_to_string(minigame.minigame_flags);
	}
	else if ( event == "key_pressed" && (minigame.minigame_flags & TTT_TURN_TEAM) == minigame_self.team )
	{
		switch ( ...(0,float) )
		{
			case K_RIGHTARROW:
			case K_KP_RIGHTARROW:
				if ( ! ttt_curr_pos )
					ttt_set_curr_pos("a3");
				else
					ttt_set_curr_pos(minigame_relative_tile(ttt_curr_pos,1,0,3,3));
				return 1;
			case K_LEFTARROW:
			case K_KP_LEFTARROW:
				if ( ! ttt_curr_pos )
					ttt_set_curr_pos("c3");
				else
					ttt_set_curr_pos(minigame_relative_tile(ttt_curr_pos,-1,0,3,3));
				return 1;
			case K_UPARROW:
			case K_KP_UPARROW:
				if ( ! ttt_curr_pos )
					ttt_set_curr_pos("a1");
				else
					ttt_set_curr_pos(minigame_relative_tile(ttt_curr_pos,0,1,3,3));
				return 1;
			case K_DOWNARROW:
			case K_KP_DOWNARROW:
				if ( ! ttt_curr_pos )
					ttt_set_curr_pos("a3");
				else
					ttt_set_curr_pos(minigame_relative_tile(ttt_curr_pos,0,-1,3,3));
				return 1;
			case K_ENTER:
			case K_KP_ENTER:
			case K_SPACE:
				ttt_make_move(minigame);
				return 1;
		}
		return 0;
	}
	else if ( event == "mouse_pressed" && ...(0,float) == K_MOUSE1 )
	{
		ttt_make_move(minigame);
		return 1;
	}
	else if ( event == "mouse_moved" )
	{
		vector mouse_pos = minigame_hud_normalize(mousepos,ttt_boardpos,ttt_boardsize);
		if ( minigame.minigame_flags == (TTT_TURN_PLACE|minigame_self.team) )
			ttt_set_curr_pos(minigame_tile_name(mouse_pos,3,3));
		if ( ! ttt_valid_tile(ttt_curr_pos) )
			ttt_set_curr_pos("");
		return 1;
	}
	else if ( event == "network_receive" )
	{
		entity sent = ...(0,entity);
		float sf = ...(1,float);
		if ( sent.classname == "minigame" && ( sf & MINIG_SF_UPDATE ) )
		{
			sent.message = ttt_turn_to_string(sent.minigame_flags);
			if ( sent.minigame_flags & minigame_self.team )
				minigame_prompt();
		}
		else if ( sent.classname == "minigame_player" && (sf & TTT_SF_PLAYERSCORE ) )
		{
			sent.minigame_flags = ReadByte();
		}
	}
	else if ( event == "menu_show" )
	{
		HUD_MinigameMenu_CustomEntry(...(0,entity),_("Next Match"),"next");
	}
	else if ( event == "menu_click" && ...(0,string) == "next" )
	{
		minigame_cmd("next");
	}
	
	return 0;
}

#endif