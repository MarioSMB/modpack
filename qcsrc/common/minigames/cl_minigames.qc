// Draw a square in the center of the avaliable area
void minigame_hud_simpleboard(vector pos, vector mySize, string board_texture)
{
	if ( mySize_x > mySize_y )
	{
		pos_x += (mySize_x-mySize_y)/2;
		mySize_x = mySize_y;
	}
	else
	{
		pos_y += (mySize_y-mySize_x)/2;
		mySize_x = mySize_x;
	}
	
	if(panel_bg_padding)
	{
		pos += '1 1 0' * panel_bg_padding;
		mySize -= '2 2 0' * panel_bg_padding;
	}
	
	if(panel.current_panel_bg != "0" && panel.current_panel_bg != "")
		draw_BorderPicture(pos - '1 1 0' * panel_bg_border, 
					panel.current_panel_bg, 
					mySize + '1 1 0' * 2 * panel_bg_border, 
					panel_bg_color, panel_bg_alpha, 
					 '1 1 0' * (panel_bg_border/BORDER_MULTIPLIER));
	drawpic(pos, board_texture, mySize, '1 1 1', panel_bg_alpha, DRAWFLAG_NORMAL);
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

void HUD_MinigameCreate_CurrentButton();
void deactivate_minigame()
{
	active_minigame = world;
	if ( !HUD_MinigameCreate_IsOpened() )
		setcursormode(0);
	else
		HUD_MinigameCreate_CurrentButton();
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
	
	if ( HUD_MinigameCreate_IsOpened() )
		HUD_MinigameCreate_CurrentButton();
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
	
	dprint("\nCL Reading entity: ",ftos(num_for_edict(self)),
		" classname:",self.classname," enttype:",ftos(self.enttype),"\n");
	dprint(" sf:",ftos(sf)," netname:",self.netname,"\n");
}