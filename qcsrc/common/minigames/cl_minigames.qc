// Draw a square in the center of the avaliable area
void minigame_hud_simpleboard(vector pos, vector mySize, string board_texture)
{
	if(panel.current_panel_bg != "0" && panel.current_panel_bg != "")
		draw_BorderPicture(pos - '1 1 0' * panel_bg_border, 
					panel.current_panel_bg, 
					mySize + '1 1 0' * 2 * panel_bg_border, 
					panel_bg_color, panel_bg_alpha, 
					 '1 1 0' * (panel_bg_border/BORDER_MULTIPLIER));
	drawpic(pos, board_texture, mySize, '1 1 1', panel_bg_alpha, DRAWFLAG_NORMAL);
}

// De-normalize (2D vector) v from relative coordinate inside pos mySize
vector minigame_hud_denormalize(vector v, vector pos, vector mySize)
{
	v_x = pos_x + v_x * mySize_x;
	v_y = pos_y + v_y * mySize_y;
	return v;
}
// De-normalize (2D vector) v from relative size inside pos mySize
vector minigame_hud_denormalize_size(vector v, vector pos, vector mySize)
{
	v_x = v_x * mySize_x;
	v_y = v_y * mySize_y;
	return v;
}

// Normalize (2D vector) v to relative coordinate inside pos mySize
vector minigame_hud_normalize(vector v, vector pos, vector mySize)
{
	v_x = ( v_x - pos_x ) / mySize_x;
	v_y = ( v_y - pos_y ) / mySize_y;
	return v;
}

// Check if the mouse is inside the given area
float minigame_hud_mouse_in(vector pos, vector sz)
{
	return mousepos_x >= pos_x && mousepos_x < pos_x + sz_x &&
	       mousepos_y >= pos_y && mousepos_y < pos_y + sz_y ;
}

void initialize_minigames()
{
	entity last_minig = world;
	entity minig;
	#define MINIGAME(name) \
		minig = spawn(); \
		minig.netname = strzone(strtolower(#name)); \
		minig.minigame_hud_board = minigame_hud_board_##name; \
		minig.minigame_hud_status = minigame_hud_status_##name; \
		minig.minigame_event = minigame_event_##name; \
		if ( !last_minig ) minigame_descriptors = minig; \
		else last_minig.chain = minig; \
		last_minig = minig;
		
	REGISTERED_MINIGAMES
	
	#undef MINIGAME
}

string minigame_texture_skin(string skinname, string name)
{
	return sprintf("gfx/hud/%s/minigames/%s", skinname, name);
}
string minigame_texture(string name)
{
	string path = minigame_texture_skin(autocvar_menu_skin,name);
	if ( precache_pic(path) == "" )
		path = minigame_texture_skin("default", name);
	return path;
}

void HUD_MinigameMenu_CurrentButton();
void deactivate_minigame()
{
	active_minigame = world;
	if ( !HUD_MinigameMenu_IsOpened() )
		setcursormode(0);
	else
		HUD_MinigameMenu_CurrentButton();
}

void activate_minigame(entity minigame)
{
	if ( !minigame )
	{
		deactivate_minigame();
		return;
	}
	
	if ( !minigame.descriptor || minigame.classname != "minigame" )
	{
		dprint("Trying to activate unregistered minigame ",minigame.netname," in client\n");
		return;
	}
	
	if ( minigame == active_minigame )
		return;
	
	if ( active_minigame )
		deactivate_minigame();
	
	active_minigame = minigame;
	
	if(autocvar_hud_cursormode)
		setcursormode(1);
	
	if ( HUD_MinigameMenu_IsOpened() )
		HUD_MinigameMenu_CurrentButton();
}

void ent_read_minigame()
{
	float sf = ReadByte();
	if ( sf & MINIG_SF_CREATE )
	{
		self.classname = strzone(ReadString());
		self.netname = strzone(ReadString());
	}
	
	if ( self.classname == "minigame" )
	{
		if ( sf & MINIG_SF_CREATE )
		{
			self.descriptor = minigame_get_descriptor(ReadString());
			if ( !self.descriptor )
				dprint("Got a minigame without a client-side descriptor!\n");
			else
				self.minigame_event = self.descriptor.minigame_event;
		}
		
		if ( sf & MINIG_SF_PLAYERS )
		{
			float ent;
			float n;
			float foundself = 0;
			for ( n = ReadByte(); n > 0; n-- )
			{
				ent = ReadLong();
				dprint("Player: ",GetPlayerName(ent-1),"\n");
				if ( ent == player_localentnum )
					foundself = 1;
			}
			if ( foundself && self != active_minigame )
			{
				dprint("Found myself, CS activate!\n");
				activate_minigame(self);
			}
			else if ( active_minigame == self && !foundself )
			{
				dprint("Didn't find myself, CS deactivate!\n");
				deactivate_minigame();
			}
		}
	}
	else if ( self.classname == "minigame_board_tile" )
	{
		if ( sf & MINIG_SF_CREATE )
		{
			string owner_name = ReadString();
			self.owner = world;
			do
				self.owner = find(self.owner,netname,owner_name);
			while ( self.owner && self.owner.classname != "minigame" );
			if ( !self.owner )
				dprint("Got a minigame tile without a minigame!\n");
			self.origin_x = ReadCoord();
			self.origin_y = ReadCoord();
		}
	}
	
	dprint("\nCL Reading entity: ",ftos(num_for_edict(self)),
		" classname:",self.classname," enttype:",ftos(self.enttype),"\n");
	dprint(" sf:",ftos(sf)," netname:",self.netname,"\n");
}