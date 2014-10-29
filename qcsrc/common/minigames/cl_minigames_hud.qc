
#include "minigames.qh"

float HUD_mouse_over(entity somepanel)
{
	vector pos = stov(cvar_string(strcat("hud_panel_", somepanel.panel_name, "_pos")));
	vector sz = stov(cvar_string(strcat("hud_panel_", somepanel.panel_name, "_size")));
	return mousepos_x >= pos_x*vid_conwidth  && mousepos_x <= (pos_x+sz_x)*vid_conwidth && 
	       mousepos_y >= pos_y*vid_conheight && mousepos_y <= (pos_y+sz_y)*vid_conheight ;
}

// ====================================================================
// Minigame Board
// ====================================================================

void HUD_MinigameBoard ()
{
	entity hud_minigame;
	
	if(!autocvar__hud_configure)
		hud_minigame = active_minigame.descriptor;
	else 
		hud_minigame = minigame_get_descriptor("nmm");
	
	if ( !hud_minigame )
		return;
	
	HUD_Panel_UpdateCvars();
	
	
	vector pos, mySize;
	pos = panel_pos;
	mySize = panel_size;
	
	hud_minigame.minigame_hud_board(pos,mySize);
}

// ====================================================================
// Minigame Status
// ====================================================================
void HUD_MinigameStatus ()
{
	entity hud_minigame;
	
	if(!autocvar__hud_configure)
		hud_minigame = active_minigame.descriptor;
	else
		hud_minigame = minigame_get_descriptor("nmm");
	
	if ( !hud_minigame )
		return;
	
	HUD_Panel_UpdateCvars();
	
	
	vector pos, mySize;
	pos = panel_pos;
	mySize = panel_size;
	
	if(panel_bg_padding)
	{
		pos += '1 1 0' * panel_bg_padding;
		mySize -= '2 2 0' * panel_bg_padding;
	}
	
	hud_minigame.minigame_hud_status(pos,mySize);
}

// ====================================================================
// Minigame Menu
// ====================================================================

// Minigame menu options: list head
entity HUD_MinigameMenu_entries;
// Minigame menu options: list tail
entity HUD_MinigameMenu_last_entry;

// Minigame menu options: insert entry after the given location
void HUD_MinigameMenu_InsertEntry(entity new, entity prev)
{
	if ( !HUD_MinigameMenu_entries )
	{
		HUD_MinigameMenu_entries = new;
		HUD_MinigameMenu_last_entry = new;
		return;
	}
	
	new.owner = prev;
	new.chain = prev.chain;
	if ( prev.chain )
		prev.chain.owner = new;
	else
		HUD_MinigameMenu_last_entry = new;
	prev.chain = new;
	
}


// minigame menu item uder the mouse
entity HUD_MinigameMenu_activeitem;

// Click the given item
void HUD_MinigameMenu_Click(entity menuitem)
{
	if ( menuitem )
	{
		entity e = self;
		self = menuitem;
		menuitem.use();
		self = e;
	}
}

// Minigame menu options: Remove the given entry
// Precondition: the given entry is actually in the list
void HUD_MinigameMenu_EraseEntry ( entity e )
{
	// remove child items (if any)
	if ( e.flags & 2 )
	{
		HUD_MinigameMenu_Click(e);
	}
	
	if ( e.owner )
		e.owner.chain = e.chain;
	else
		HUD_MinigameMenu_entries = e.chain;
				
	if ( e.chain )
		e.chain.owner = e.owner;
	else
		HUD_MinigameMenu_last_entry = e.owner;
	
	if ( HUD_MinigameMenu_activeitem == e )
		HUD_MinigameMenu_activeitem = world;
	
	remove(e);
}

// Minigame menu options: create entry
entity HUD_MinigameMenu_SpawnEntry(string s, vector offset, vector fontsize, vector color,void() click)
{
	entity entry = spawn();
	entry.message = s;
	entry.origin = offset;
	entry.size = fontsize;
	entry.colormod = color;
	entry.flags = 0;
	entry.use = click;
	panel_pos_y += fontsize_y;
	return entry;
}

// Spawn a child entry of a collapsable entry
entity HUD_MinigameMenu_SpawnSubEntry(string s, void() click, string it_classname)
{
	vector item_fontsize = hud_fontsize*1.25;
	vector item_offset = '1 0 0' * item_fontsize_x;
	entity item = HUD_MinigameMenu_SpawnEntry(
				s,item_offset,item_fontsize,'0.8 0.8 0.8', click );
	item.classname = it_classname;
	return item;
}

// Click action for Create sub-entries
void HUD_MinigameMenu_ClickCreate_Entry()
{
	localcmd(strcat("cmd minigame start ",self.netname,"\n"));
}

// Helper click action for collapsible entries
// returns true when you have to create the sub-entries
float HUD_MinigameMenu_Click_ExpandCollapse(string collapse_classname)
{
	entity e;
	if ( self.flags & 2 )
	{
		if ( HUD_MinigameMenu_activeitem && 
				HUD_MinigameMenu_activeitem.classname == collapse_classname )
			HUD_MinigameMenu_activeitem = world;
		self.flags &= ~2;
		for ( e = self.chain; e != world && e.classname == collapse_classname; e = self.chain )
		{
			if ( e.flags & 2 )
				HUD_MinigameMenu_Click(e);
			self.chain = e.chain;
			remove(e);
		}
		if ( self.chain )
			self.chain.owner = self;
	}
	else
	{
		for ( e = HUD_MinigameMenu_entries; e != world; e = e.chain )
		{
			if ( e.flags & 2 && e.origin_x == self.origin_x)
				HUD_MinigameMenu_Click(e);
		}
		
		self.flags |= 2;
		
		return true;
	}
	return false;
}

// Click action for the Create menu
void HUD_MinigameMenu_ClickCreate()
{
	if ( HUD_MinigameMenu_Click_ExpandCollapse("hud_minigamemenu_create_entry") )
	{
		entity e;
		entity curr;
		entity prev = self;
		for ( e = minigame_descriptors; e != world; e = e.chain )
		{
			curr = HUD_MinigameMenu_SpawnSubEntry(
				e.message, HUD_MinigameMenu_ClickCreate_Entry,
				"hud_minigamemenu_create_entry" );
			curr.netname = e.netname;
			curr.model = strzone(minigame_texture(strcat(e.netname,"/icon")));
			HUD_MinigameMenu_InsertEntry( curr, prev );
			prev = curr;
		}
	}
}

// Click action for Join sub-entries
void HUD_MinigameMenu_ClickJoin_Entry()
{
	localcmd(strcat("cmd minigame join ",self.netname,"\n"));
	HUD_MinigameMenu_EraseEntry(self);
}

// Click action for the Join menu
void HUD_MinigameMenu_ClickJoin()
{
	if ( HUD_MinigameMenu_Click_ExpandCollapse("hud_minigamemenu_join_entry") )
	{
		entity e = world;
		entity curr;
		entity prev = self;
		while( (e = find(e,classname,"minigame")) )
		{
			if ( e != active_minigame )
			{
				curr = HUD_MinigameMenu_SpawnSubEntry(
					e.netname, HUD_MinigameMenu_ClickJoin_Entry,
					"hud_minigamemenu_join_entry" );
				curr.netname = e.netname;
				curr.model = strzone(minigame_texture(strcat(e.descriptor.netname,"/icon")));
				HUD_MinigameMenu_InsertEntry( curr, prev );
				prev = curr;
			}
		}
	}
}

// Temporary placeholder for un-implemented Click actions
void HUD_MinigameMenu_ClickNoop()
{
	dprint("Placeholder for ",self.message,"\n");
}

// Click action for Quit
void HUD_MinigameMenu_ClickQuit()
{
	localcmd("cmd minigame end\n");
}

// Click action for Invite sub-entries
void HUD_MinigameMenu_ClickInvite_Entry()
{
	localcmd(strcat("cmd minigame invite #",self.netname,"\n"));
}

// Click action for the Invite menu
void HUD_MinigameMenu_ClickInvite()
{
	if ( HUD_MinigameMenu_Click_ExpandCollapse("hud_minigamemenu_invite_entry") )
	{
		float i;
		entity e;
		entity prev = self;
		for(i = 0; i < maxclients; ++i)
		{
			if(player_localnum != i && playerslots[i] && GetPlayerName(i) != "" &&
				!findfloat(world,minigame_playerslot,i+1) )
			{
				e = HUD_MinigameMenu_SpawnSubEntry(
					strzone(GetPlayerName(i)), HUD_MinigameMenu_ClickInvite_Entry,
					"hud_minigamemenu_invite_entry");
				e.flags |= 1;
				e.netname = strzone(ftos(i+1));
				e.origin_x *= 2;
				HUD_MinigameMenu_InsertEntry(e,prev);
				prev = e;
			}
		}
	}
}

// Click action for the Current Game menu
void HUD_MinigameMenu_ClickCurrentGame()
{
	if ( HUD_MinigameMenu_Click_ExpandCollapse("hud_minigamemenu_current_entry") )
	{
		HUD_MinigameMenu_InsertEntry( HUD_MinigameMenu_SpawnSubEntry(
			"Quit", HUD_MinigameMenu_ClickQuit,
			"hud_minigamemenu_current_entry"), self);
		
		HUD_MinigameMenu_InsertEntry( HUD_MinigameMenu_SpawnSubEntry(
			"Load", HUD_MinigameMenu_ClickNoop,
			"hud_minigamemenu_current_entry"), self);
		
		HUD_MinigameMenu_InsertEntry( HUD_MinigameMenu_SpawnSubEntry(
			"Save", HUD_MinigameMenu_ClickNoop,
			"hud_minigamemenu_current_entry"), self);
		
		HUD_MinigameMenu_InsertEntry( HUD_MinigameMenu_SpawnSubEntry(
			"Invite", HUD_MinigameMenu_ClickInvite,
			"hud_minigamemenu_current_entry"), self);
	}
}
// Whether the minigame menu panel is open
float HUD_MinigameMenu_IsOpened()
{
	return !!HUD_MinigameMenu_entries;
}

// Close the minigame menu panel
void HUD_MinigameMenu_Close()
{
	if ( HUD_MinigameMenu_IsOpened() )
	{
		entity e, p;
		for ( e = HUD_MinigameMenu_entries; e != world; e = p )
		{
			p = e.chain;
			remove(e);
		}
		HUD_MinigameMenu_entries = world;
		HUD_MinigameMenu_last_entry = world;
		HUD_MinigameMenu_activeitem = world;
		if(autocvar_hud_cursormode)
		if ( !active_minigame )
			setcursormode(0);
	}
}

// toggle a button to manage the current game
void HUD_MinigameMenu_CurrentButton()
{
	entity e;
	if ( active_minigame )
	{
		for ( e = HUD_MinigameMenu_last_entry; e != world; e = e.owner )
			if ( e.classname == "hud_minigamemenu_exit" )
			{
				entity currb = HUD_MinigameMenu_SpawnEntry(
					"Current Game", '0 0 0', hud_fontsize*1.5,'0.7 0.84 1', HUD_MinigameMenu_ClickCurrentGame );
				currb.classname = "hud_minigamemenu_current";
				currb.model = strzone(minigame_texture(strcat(active_minigame.descriptor.netname,"/icon")));
				HUD_MinigameMenu_InsertEntry(currb,e.owner);
				HUD_MinigameMenu_Click(currb);
				return;
			}
	}
	else 
	{
		entity p;
		for ( e = HUD_MinigameMenu_last_entry; e != world; e = p.owner )
		{
			p = e;
			if ( e.classname == "hud_minigamemenu_current" )
			{
				p = e.chain;
				if ( !p )
					p = HUD_MinigameMenu_last_entry;
				HUD_MinigameMenu_EraseEntry(e);
				return;
			}
		}
	}
}

// Open the minigame menu panel
void HUD_MinigameMenu_Open()
{
	if ( !HUD_MinigameMenu_IsOpened() )
	{
		HUD_MinigameMenu_InsertEntry( HUD_MinigameMenu_SpawnEntry(
			"Create", '0 0 0', hud_fontsize*1.5,'0.7 0.84 1', HUD_MinigameMenu_ClickCreate),
			HUD_MinigameMenu_last_entry );
		HUD_MinigameMenu_InsertEntry ( HUD_MinigameMenu_SpawnEntry(
			"Join",'0 0 0',hud_fontsize*1.5,'0.7 0.84 1', HUD_MinigameMenu_ClickJoin),
			HUD_MinigameMenu_last_entry );
		entity exit = HUD_MinigameMenu_SpawnEntry(
			"Exit Menu",'0 0 0',hud_fontsize*1.5,'0.7 0.84 1', HUD_MinigameMenu_Close);
		exit.classname = "hud_minigamemenu_exit";
		HUD_MinigameMenu_InsertEntry ( exit, HUD_MinigameMenu_last_entry );
		HUD_MinigameMenu_CurrentButton();
		HUD_MinigameMenu_activeitem = world;
		if(autocvar_hud_cursormode)
			setcursormode(1);
	}
}

// Handles mouse input on to minigame menu panel
void HUD_MinigameMenu_MouseInput()
{
	panel = HUD_PANEL(MINIGAME_MENU);

	HUD_Panel_UpdateCvars()

	if(panel_bg_padding)
	{
		panel_pos += '1 1 0' * panel_bg_padding;
		panel_size -= '2 2 0' * panel_bg_padding;
	}
	
	entity e;
	
	panel_pos_y += hud_fontsize_y*2;
	
	HUD_MinigameMenu_activeitem = world;
	vector sz;
	for ( e = HUD_MinigameMenu_entries; e != world; e = e.chain )
	{
		sz = eX*panel_size_x + eY*e.size_y;
		if ( e.model )
			sz_y = 22;
		if ( !HUD_MinigameMenu_activeitem && mousepos_y >= panel_pos_y && mousepos_y <= panel_pos_y + sz_y )
		{
			HUD_MinigameMenu_activeitem = e;
		}
		panel_pos_y += sz_y;
	}
}

// Draw a menu entry
void HUD_MinigameMenu_DrawEntry(vector pos, string s, vector fontsize, vector color)
{
	minigame_drawstring_trunc(panel_size_x-pos_x+panel_pos_x, pos, s,
							  fontsize, color, panel_fg_alpha, DRAWFLAG_NORMAL);
}
// Draw a color-coded menu
void HUD_MinigameMenu_DrawColoredEntry(vector pos, string s, vector fontsize)
{
	minigame_drawcolorcodedstring_trunc(panel_size_x-pos_x+panel_pos_x, pos, s,
							  fontsize, panel_fg_alpha, DRAWFLAG_NORMAL);
}

// minigame menu panel UI
void HUD_MinigameMenu ()
{
	if ( autocvar__hud_configure && !HUD_MinigameMenu_IsOpened() )
	{
		HUD_MinigameMenu_Open();
	}
	
	if ( !HUD_MinigameMenu_IsOpened() )
		return;
	
	HUD_Panel_UpdateCvars();
	
	HUD_Panel_DrawBg(1);
	
	if(panel_bg_padding)
	{
		panel_pos += '1 1 0' * panel_bg_padding;
		panel_size -= '2 2 0' * panel_bg_padding;
	}

	HUD_MinigameMenu_DrawEntry(panel_pos,"Minigames",hud_fontsize*2,'0.25 0.47 0.72');
	panel_pos_y += hud_fontsize_y*2;
	
	entity e;
	vector color;
	vector offset;
	float itemh;
	vector imgsz = '22 22 0'; // NOTE: if changed, edit where HUD_MinigameMenu_activeitem is selected
	for ( e = HUD_MinigameMenu_entries; e != world; e = e.chain )
	{
		color = e.colormod;
		
		offset = e.origin;
		itemh = e.size_y;
		
		if ( e.model )
			itemh = imgsz_y;
		
		if ( e.flags & 2 )
		{
			drawfill(panel_pos, eX*panel_size_x + eY*itemh, e.colormod, 
					panel_fg_alpha, DRAWFLAG_NORMAL);
			color = '0 0 0';
		}

		if ( e.model )
		{
			drawpic( panel_pos+offset, e.model, imgsz, '1 1 1', panel_fg_alpha, DRAWFLAG_NORMAL );
			offset_x += imgsz_x;
			offset_y = (imgsz_y-e.size_y) / 2;
		}
		
		if ( e.flags & 1 )
			HUD_MinigameMenu_DrawColoredEntry(panel_pos+offset,e.message,e.size);
		else
			HUD_MinigameMenu_DrawEntry(panel_pos+offset,e.message,e.size,color);
		
		if ( e == HUD_MinigameMenu_activeitem )
			drawfill(panel_pos, eX*panel_size_x + eY*itemh,'1 1 1', 0.25, DRAWFLAG_ADDITIVE);
		
		panel_pos_y += itemh;
	}
}


// ====================================================================
// Minigame Panel Input
// ====================================================================
float HUD_Minigame_InputEvent(float bInputType, float nPrimary, float nSecondary)
{
		
	if( !(minigame_isactive() || HUD_MinigameMenu_IsOpened()) || autocvar__hud_configure )
		return false;

	if(bInputType == 3)
	{
		mousepos_x = nPrimary;
		mousepos_y = nSecondary;
		if ( minigame_isactive() && HUD_mouse_over(HUD_PANEL(MINIGAME_BOARD)) )
			active_minigame.minigame_event(active_minigame,"mouse_moved",mousepos);
		return true;
		
	}
	else
	{
		
		if(bInputType == 0) {
			if(nPrimary == K_ALT) hudShiftState |= S_ALT;
			if(nPrimary == K_CTRL) hudShiftState |= S_CTRL;
			if(nPrimary == K_SHIFT) hudShiftState |= S_SHIFT;
			if(nPrimary == K_MOUSE1) mouseClicked |= S_MOUSE1;
			if(nPrimary == K_MOUSE2) mouseClicked |= S_MOUSE2;
		}
		else if(bInputType == 1) {
			if(nPrimary == K_ALT) hudShiftState -= (hudShiftState & S_ALT);
			if(nPrimary == K_CTRL) hudShiftState -= (hudShiftState & S_CTRL);
			if(nPrimary == K_SHIFT) hudShiftState -= (hudShiftState & S_SHIFT);
			if(nPrimary == K_MOUSE1) mouseClicked -= (mouseClicked & S_MOUSE1);
			if(nPrimary == K_MOUSE2) mouseClicked -= (mouseClicked & S_MOUSE2);
		}
		
		// allow some binds
		string con_keys;
		float keys;
		float i;
		con_keys = findkeysforcommand("toggleconsole", 0);
		keys = tokenize(con_keys); // findkeysforcommand returns data for this
		for (i = 0; i < keys; ++i)
		{
			if(nPrimary == stof(argv(i)))
				return false;
		}
		
		if ( minigame_isactive() && ( bInputType == 0 || bInputType == 1 ) )
		{
			string device = "";
			string action = bInputType == 0 ? "pressed" : "released";
			if ( nPrimary >= K_MOUSE1 && nPrimary <= K_MOUSE16 )
			{
				if ( HUD_mouse_over(HUD_PANEL(MINIGAME_BOARD)) )
					device = "mouse";
			}
			else
				device = "key";
			
			if ( device && active_minigame.minigame_event(
					active_minigame,strcat(device,"_",action),nPrimary) )
				return true;
			
			/*if ( nPrimary == K_ESCAPE && bInputType == 0 )
			{
				/// TODO: maybe show confirmation dialog
				localcmd ( "cmd minigame end" );
			}*/
			/// TODO: bInputType == 2?
		}
		
		if ( HUD_MinigameMenu_IsOpened() && bInputType == 0 )
		{
			if ( nPrimary == K_MOUSE1 && HUD_MinigameMenu_activeitem &&
				HUD_mouse_over(HUD_PANEL(MINIGAME_MENU)) )
			{
				HUD_MinigameMenu_Click(HUD_MinigameMenu_activeitem);
				return true;
			}
			if ( nPrimary == K_UPARROW || nPrimary == K_KP_UPARROW )
			{
				if ( HUD_MinigameMenu_activeitem && HUD_MinigameMenu_activeitem.owner )
					HUD_MinigameMenu_activeitem = HUD_MinigameMenu_activeitem.owner;
				else
					HUD_MinigameMenu_activeitem = HUD_MinigameMenu_last_entry;
				return true;
			}
			else if ( nPrimary == K_DOWNARROW || nPrimary == K_KP_DOWNARROW )
			{
				if ( HUD_MinigameMenu_activeitem && HUD_MinigameMenu_activeitem.chain )
					HUD_MinigameMenu_activeitem = HUD_MinigameMenu_activeitem.chain;
				else
					HUD_MinigameMenu_activeitem = HUD_MinigameMenu_entries;
				return true;
			}
			else if ( nPrimary == K_HOME || nPrimary == K_KP_HOME )
			{
				HUD_MinigameMenu_activeitem = HUD_MinigameMenu_entries;
				return true;
			}
			else if ( nPrimary == K_END || nPrimary == K_KP_END )
			{
				HUD_MinigameMenu_activeitem = HUD_MinigameMenu_entries;
				return true;
			}
			else if ( nPrimary == K_KP_ENTER || nPrimary == K_ENTER || nPrimary == K_SPACE )
			{
				HUD_MinigameMenu_Click(HUD_MinigameMenu_activeitem);
				return true;
			}
			else if ( nPrimary == K_ESCAPE )
			{
				HUD_MinigameMenu_Close();
				return true;
			}
		}
	}
	
	return false;

}

void HUD_Minigame_Mouse()
{		
	if( !(minigame_isactive() || HUD_MinigameMenu_IsOpened()) || autocvar__hud_configure )
		return;
	
	if(!autocvar_hud_cursormode)
	{
		mousepos = mousepos + getmousepos() * autocvar_menu_mouse_speed;

		mousepos_x = bound(0, mousepos_x, vid_conwidth);
		mousepos_y = bound(0, mousepos_y, vid_conheight);
	}
	
	if ( HUD_MinigameMenu_IsOpened() && HUD_mouse_over(HUD_PANEL(MINIGAME_MENU)) )
		HUD_MinigameMenu_MouseInput();
	
	const vector cursorsize = '32 32 0';
	drawpic(mousepos-'8 4 0', strcat("gfx/menu/", autocvar_menu_skin, "/cursor.tga"), cursorsize, '1 1 1', 0.8, DRAWFLAG_NORMAL);
}