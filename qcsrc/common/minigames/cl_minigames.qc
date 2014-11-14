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
	#define MINIGAME(name,nicename) \
		minig = spawn(); \
		minig.classname = "minigame_descriptor"; \
		minig.netname = strzone(strtolower(#name)); \
		minig.message = nicename; \
		minig.minigame_hud_board = minigame_hud_board_##name; \
		minig.minigame_hud_status = minigame_hud_status_##name; \
		minig.minigame_event = minigame_event_##name; \
		if ( !last_minig ) minigame_descriptors = minig; \
		else last_minig.list_next = minig; \
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

#define MSLE(Name,Fields) \
	else if ( self.classname == #Name ) { strunzone(e.netname); Fields }
#define FIELD(Flags, Type, Name) MSLE_CLEAN_##Type(e.Name)
#define MSLE_CLEAN_String(x) strunzone(x);
#define MSLE_CLEAN_Byte(x)
#define MSLE_CLEAN_Char(x)
#define MSLE_CLEAN_Short(x)
#define MSLE_CLEAN_Coord(x)
#define MSLE_CLEAN_Angle(x)
#define MSLE_CLEAN_Float(x)
#define MSLE_CLEAN_Vector(x)
#define MSLE_CLEAN_Vector2D(x)
void minigame_autoclean_entity(entity e)
{
	if ( 0 ) {}
	MINIGAME_SIMPLELINKED_ENTITIES
	
	dprint("CL Auto-cleaned: ",ftos(num_for_edict(e)), " (",e.classname,")\n");
	remove(e);
}
#undef MSLE
#undef FIELD

void HUD_MinigameMenu_CurrentButton();
float auto_close_minigamemenu;
void deactivate_minigame()
{
	if ( !active_minigame )
		return;
	
	active_minigame.minigame_event(active_minigame,"deactivate");
	entity e = world;
	while( (e = findentity(e, owner, self)) )
		if ( e.minigame_autoclean )
		{
			minigame_autoclean_entity(e);
		}

	minigame_self = world;
	active_minigame = world;
	
	if ( auto_close_minigamemenu )
	{
		HUD_MinigameMenu_Close();
		auto_close_minigamemenu = 0;
	}
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
	{
		entity olds = minigame_self;
		deactivate_minigame();
		minigame_self = olds;
	}
	
	if ( minigame_self.owner != minigame )
		minigame_self = world;
	active_minigame = minigame;
	active_minigame.minigame_event(active_minigame,"activate");
	
	if ( HUD_MinigameMenu_IsOpened() )
		HUD_MinigameMenu_CurrentButton();
	else
	{
		auto_close_minigamemenu = 1;
		HUD_MinigameMenu_Open();
	}
}

vector ReadVector2D() { vector v; v_x = ReadCoord(); v_y = ReadCoord(); v_z = 0; return v; }
vector ReadVector() { vector v; v_x = ReadCoord(); v_y = ReadCoord(); v_z = ReadCoord(); return v; }
string() ReadString_Raw = #366;
string ReadString_Zoned() { return strzone(ReadString_Raw()); }
#define ReadFloat ReadCoord
#define ReadString ReadString_Zoned
#define FIELD(Flags, Type,Name) if ( sf & (Flags) ) self.Name = Read##Type();
#define MSLE(Name,Fields) \
	else if ( self.classname == #Name ) { \
		if ( sf & MINIG_SF_CREATE ) minigame_read_owner(); \
		minigame_ent = self.owner; \
		Fields \
	}
void minigame_read_owner()
{
	string owner_name = ReadString_Raw();
	self.owner = world;
	do
		self.owner = find(self.owner,netname,owner_name);
	while ( self.owner && self.owner.classname != "minigame" );
	if ( !self.owner )
		dprint("Got a minigame entity without a minigame!\n");
}
void ent_read_minigame()
{
	float sf = ReadByte();
	if ( sf & MINIG_SF_CREATE )
	{
		self.classname = msle_classname(ReadShort());
		self.netname = ReadString_Zoned();
	}
	
	entity minigame_ent = world;
	
	if ( self.classname == "minigame" )
	{
		minigame_ent = self;
		
		if ( sf & MINIG_SF_CREATE )
		{
			self.descriptor = minigame_get_descriptor(ReadString_Raw());
			if ( !self.descriptor )
				dprint("Got a minigame without a client-side descriptor!\n");
			else
				self.minigame_event = self.descriptor.minigame_event;
		}
		if ( sf & MINIG_SF_UPDATE )
			self.minigame_flags = ReadLong();
	}
	else if ( self.classname == "minigame_player" )
	{
		float activate = 0;
		if ( sf & MINIG_SF_CREATE )
		{
			minigame_read_owner();
			
			float ent = ReadLong();
			self.minigame_playerslot = ent;
			dprint("Player: ",GetPlayerName(ent-1),"\n");
			
			activate = (ent == player_localnum+1 && self.owner && self.owner != active_minigame);
			
		}
		minigame_ent = self.owner;
			
		if ( sf & MINIG_SF_UPDATE )
			self.team = ReadByte();
		
		if ( activate )
		{
			minigame_self = self;
			activate_minigame(self.owner);
		}
	}
	MINIGAME_SIMPLELINKED_ENTITIES
	
	if ( minigame_ent )
		minigame_ent.minigame_event(minigame_ent,"network_receive",self,sf);
	
	dprint("CL Reading entity: ",ftos(num_for_edict(self)),
		" classname:",self.classname," enttype:",ftos(self.enttype) );
	dprint(" sf:",ftos(sf)," netname:",self.netname,"\n\n");
}
#undef ReadFloat
#undef ReadString
#undef FIELD
#undef MSLE

vector minigame_drawstring_wrapped( float maxwidth, vector pos, string text, 
	vector fontsize, vector color, float theAlpha, float drawflags, float align )
{
	getWrappedLine_remaining = text;
	vector mypos = pos;
	while ( getWrappedLine_remaining )
	{
		string line = getWrappedLine(maxwidth,fontsize,stringwidth_nocolors);
		if ( line == "" )
			break;
		mypos_x = pos_x + (maxwidth - stringwidth_nocolors(line, fontsize)) * align;
		drawstring(mypos, line, fontsize, color, theAlpha, drawflags);
		mypos_y += fontsize_y;
	}
	mypos_x = maxwidth;
	mypos_y -= pos_y;
	return mypos;
}

vector minigame_drawcolorcodedstring_wrapped( float maxwidth, vector pos, 
	string text, vector fontsize, float theAlpha, float drawflags, float align )
{
	getWrappedLine_remaining = text;
	vector mypos = pos;
	while ( getWrappedLine_remaining )
	{
		string line = getWrappedLine(maxwidth,fontsize,stringwidth_colors);
		if ( line == "" )
			break;
		mypos_x = pos_x + (maxwidth - stringwidth_colors(line, fontsize)) * align;
		drawcolorcodedstring(mypos, line, fontsize, theAlpha, drawflags);
		mypos_y += fontsize_y;
	}
	mypos_x = maxwidth;
	mypos_y -= pos_y;
	return mypos;
}

void minigame_drawstring_trunc(float maxwidth, vector pos, string text, 
	vector fontsize, vector color, float theAlpha, float drawflags )
{
	string line = textShortenToWidth(text,maxwidth,fontsize,stringwidth_nocolors);
	drawstring(pos, line, fontsize, color, theAlpha, drawflags);
}

void minigame_drawcolorcodedstring_trunc(float maxwidth, vector pos, string text, 
	vector fontsize, float theAlpha, float drawflags )
{
	string line = textShortenToWidth(text,maxwidth,fontsize,stringwidth_colors);
	drawcolorcodedstring(pos, line, fontsize, theAlpha, drawflags);
}

void minigame_drawpic_centered( vector pos, string texture, vector sz, 
	vector color, float thealpha, float drawflags )
{
	drawpic( pos-sz/2, texture, sz, color, thealpha, drawflags );
}

// Workaround because otherwise variadic arguments won't work properly
// It could be a bug in the compiler or in darkplaces
void minigame_cmd_workaround(float dummy, string...cmdargc)
{
	string cmd;
	cmd = "cmd minigame ";
	float i;
	for ( i = 0; i < cmdargc; i++ )
		cmd = strcat(cmd,...(i,string));
	localcmd(strcat(cmd,"\n"));
}