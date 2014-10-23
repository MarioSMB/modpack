
#include "minigames.qh"

// ====================================================================
// Minigame Board
// ====================================================================

float HUD_Minigame_InputEvent(float bInputType, float nPrimary, float nSecondary)
{
	if( !minigame_isactive() || autocvar__hud_configure )
		return false;

	if(bInputType == 3)
	{
		mousepos_x = nPrimary;
		mousepos_y = nSecondary;
		active_minigame.minigame_event(active_minigame,"mouse_move",mousepos);
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
		
		if ( nPrimary == K_ESCAPE && bInputType == 0 )
		{
			/// TODO: maybe show confirmation dialog
			localcmd ( "cmd minigame end" );
			return true;
		}
		else
		{
			// allow some binds binds
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
		}
		
		if ( bInputType == 0 )
			return active_minigame.minigame_event(active_minigame,"key_pressed",nPrimary);
		else if ( bInputType == 1 )
			return active_minigame.minigame_event(active_minigame,"key_released",nPrimary);
		/// TODO: bInputType == 2?
	}
	
	return false;

}

void HUD_Minigame_Mouse()
{
	if( !minigame_isactive() || autocvar__hud_configure )
		return;
	
	if(!autocvar_hud_cursormode)
	{
		mousepos = mousepos + getmousepos() * autocvar_menu_mouse_speed;

		mousepos_x = bound(0, mousepos_x, vid_conwidth);
		mousepos_y = bound(0, mousepos_y, vid_conheight);
	}

	HUD_Panel_UpdateCvars();
	
	const vector cursorsize = '32 32 0';
	drawpic(mousepos-'8 4 0', strcat("gfx/menu/", autocvar_menu_skin, "/cursor.tga"), cursorsize, '1 1 1', 0.8, DRAWFLAG_NORMAL);
}

void HUD_MinigameBoard ()
{
	entity hud_minigame;
	
	if(!autocvar__hud_configure)
		hud_minigame = active_minigame;
	else 
		hud_minigame = minigame_get_descriptor("test");
	
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
		hud_minigame = active_minigame;
	else
		hud_minigame = minigame_get_descriptor("test");
	
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
// Minigame Create
// ====================================================================

// Minigame menu options: list head
entity HUD_MinigameCreate_entries;
// Minigame menu options: list tail
entity HUD_MinigameCreate_last_entry;

// Minigame menu options: insert entry after the given location
void HUD_MinigameCreate_InsertEntry(entity new, entity prev)
{
	if ( !HUD_MinigameCreate_entries )
	{
		HUD_MinigameCreate_entries = new;
		HUD_MinigameCreate_last_entry = new;
		return;
	}
	
	new.owner = prev;
	new.chain = prev.chain;
	if ( prev.chain )
		prev.chain.owner = new;
	else
		HUD_MinigameCreate_last_entry = new;
	prev.chain = new;
	
}

// Minigame menu options: create entry
entity HUD_MinigameCreate_SpawnEntry(string s, vector offset, vector fontsize, vector color,void() click)
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

void HUD_MinigameCreate_ClickCreate_Entry()
{
	localcmd(strcat("cmd minigame start ",self.netname,"\n"));
}

void HUD_MinigameCreate_ClickCreate()
{
	entity e;
	if ( self.flags & 2 )
	{
		self.flags &= ~2;
		for ( e = self.chain; e != world && e.classname == "minigame_create_entry"; e = self.chain )
		{
			self.chain = e.chain;
			remove(e);
		}
	}
	else
	{
		entity curr;
		
		for ( e = HUD_MinigameCreate_entries; e != world; e = e.chain )
		{
			if ( e.flags & 2 )
			{
				curr = self;
				self = e;
				e.use();
				self = curr;
			}
		}
		
		self.flags |= 2;
		
		entity prev = self;
		vector item_fontsize = hud_fontsize*1.25;
		vector item_offset = '1 0 0' * item_fontsize_x;
		for ( e = minigame_descriptors; e != world; e = e.chain )
		{
			curr = HUD_MinigameCreate_SpawnEntry(
				e.netname,item_offset,item_fontsize,'0.8 0.8 0.8',
				HUD_MinigameCreate_ClickCreate_Entry );
			curr.netname = e.netname;
			curr.classname = "minigame_create_entry";
			HUD_MinigameCreate_InsertEntry( curr, prev );
			prev = curr;
		}
	}
}

void HUD_MinigameCreate_ClickJoin()
{
	entity e;
	if ( self.flags & 2 )
	{
		self.flags &= ~2;
		for ( e = self.chain; e != world && e.classname == "minigame_join_entry"; e = self.chain )
		{
			self.chain = e.chain;
			remove(e);
		}
	}
	else
	{
		entity curr;
		
		for ( e = HUD_MinigameCreate_entries; e != world; e = e.chain )
		{
			if ( e.flags & 2 )
			{
				curr = self;
				self = e;
				e.use();
				self = curr;
			}
		}
		
		self.flags |= 2;
		
		//TODO Create entries
	}
}

void HUD_MinigameCreate_DrawEntry(vector pos, string s, vector fontsize, vector color)
{
	string entry = textShortenToWidth(s, panel_size_x, fontsize, stringwidth_colors);
	drawstring(pos, entry, fontsize, color, panel_fg_alpha, DRAWFLAG_NORMAL);
}

float HUD_MinigameCreate_IsOpened()
{
	return !!HUD_MinigameCreate_entries;
}

void HUD_MinigameCreate_Close()
{
	if ( HUD_MinigameCreate_IsOpened() )
	{
		entity e, p;
		for ( e = HUD_MinigameCreate_entries; e != world; e = p )
		{
			p = e.chain;
			remove(e);
		}
		HUD_MinigameCreate_entries = world;
		HUD_MinigameCreate_last_entry = world;
		if(autocvar_hud_cursormode)
			setcursormode(0);
	}
}

void HUD_MinigameCreate_Open()
{
	if ( active_minigame )
		return;
	if ( !HUD_MinigameCreate_IsOpened() )
	{
		HUD_MinigameCreate_InsertEntry( HUD_MinigameCreate_SpawnEntry(
			"Create", '0 0 0', hud_fontsize*1.5,'0.7 0.84 1', HUD_MinigameCreate_ClickCreate),
			HUD_MinigameCreate_last_entry );
		HUD_MinigameCreate_InsertEntry ( HUD_MinigameCreate_SpawnEntry(
			"Join",'0 0 0',hud_fontsize*1.5,'0.7 0.84 1', HUD_MinigameCreate_ClickJoin),
			HUD_MinigameCreate_last_entry );
		HUD_MinigameCreate_InsertEntry ( HUD_MinigameCreate_SpawnEntry(
			"Exit",'0 0 0',hud_fontsize*1.5,'0.7 0.84 1', HUD_MinigameCreate_Close),
			HUD_MinigameCreate_last_entry );
		if(autocvar_hud_cursormode)
			setcursormode(1);
		mouseClicked =  0;
	}
}

float HUD_MinigameCreate_InputEvent(float bInputType, float nPrimary, float nSecondary)
{
	if( !HUD_MinigameCreate_IsOpened() || autocvar__hud_configure )
		return false;

	if(bInputType == 3)
	{
		mousepos_x = nPrimary;
		mousepos_y = nSecondary;
		return true;
	}
	else
	{
		if(nPrimary == K_MOUSE1)
		{
			if(bInputType == 0) mouseClicked |= S_MOUSE1;
			else if (bInputType == 1) mouseClicked -= (mouseClicked & S_MOUSE1);
			return true;
		}
		if (nPrimary == K_MOUSE2)
		{
			if(bInputType == 0) mouseClicked |= S_MOUSE2;
			else if (bInputType == 1) mouseClicked -= (mouseClicked & S_MOUSE2);
			return true;
		}
		
		if ( nPrimary == K_ESCAPE && bInputType == 0 )
		{
			HUD_MinigameCreate_Close();
			return true;
		}
		else
		{
			// allow some binds binds
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
		}
	}
	
	// TODO: Up/down keys
	
	return false;

}

void HUD_MinigameCreate_Mouse()
{
	if( !HUD_MinigameCreate_IsOpened() || autocvar__hud_configure )
		return;
	
	if(mouseClicked & S_MOUSE2)
	{
		HUD_MinigameCreate_Close();
		return;
	}
	
	panel = HUD_PANEL(MINIGAME_CREATE);
	
	if(!autocvar_hud_cursormode)
	{
		mousepos = mousepos + getmousepos() * autocvar_menu_mouse_speed;

		mousepos_x = bound(0, mousepos_x, vid_conwidth);
		mousepos_y = bound(0, mousepos_y, vid_conheight);
	}

	HUD_Panel_UpdateCvars()

	if(panel_bg_padding)
	{
		panel_pos += '1 1 0' * panel_bg_padding;
		panel_size -= '2 2 0' * panel_bg_padding;
	}
	
	panel_pos_y += hud_fontsize_y*2;
	
	entity active = world;
	entity e;
	vector sz;
	for ( e = HUD_MinigameCreate_entries; e != world; e = e.chain )
	{
		sz = eX*panel_size_x + eY*e.size_y;
		e.flags &= ~1;
		if ( !active && mousepos_y >= panel_pos_y && mousepos_y <= panel_pos_y + sz_y )
		{
			active = e;
			e.flags |= 1;
		}
		panel_pos_y += e.size_y;
	}
	if ( (mouseClicked & S_MOUSE1) && active )
	{
		e = self;
		self = active;
		active.use();
		self = e;
		mouseClicked = 0;
	}

	const vector cursorsize = '32 32 0';
	drawpic(mousepos-'8 4 0', strcat("gfx/menu/", autocvar_menu_skin, "/cursor.tga"), cursorsize, '1 1 1', 0.8, DRAWFLAG_NORMAL);
}

void HUD_MinigameCreate ()
{
	if ( autocvar__hud_configure && !HUD_MinigameCreate_IsOpened() )
	{
		HUD_MinigameCreate_Open();
	}
	
	if ( !HUD_MinigameCreate_IsOpened() )
		return;
	
	HUD_Panel_UpdateCvars();
	
	HUD_Panel_DrawBg(1);
	
	if(panel_bg_padding)
	{
		panel_pos += '1 1 0' * panel_bg_padding;
		panel_size -= '2 2 0' * panel_bg_padding;
	}

	HUD_MinigameCreate_DrawEntry(panel_pos,"Minigames",hud_fontsize*2,'0.25 0.47 0.72');
	panel_pos_y += hud_fontsize_y*2;
	
	entity e;
	vector color;
	for ( e = HUD_MinigameCreate_entries; e != world; e = e.chain )
	{
		color = e.colormod;
		if ( e.flags & 2 )
		{
			drawfill(panel_pos, eX*panel_size_x + eY*e.size_y, e.colormod, 
					panel_fg_alpha, DRAWFLAG_NORMAL);
			color = '0 0 0';
		}
		HUD_MinigameCreate_DrawEntry(panel_pos+e.origin,e.message,e.size,color);
		if ( e.flags & 1 )
			drawfill(panel_pos, eX*panel_size_x + eY*e.size_y,'1 1 1', 0.1, DRAWFLAG_ADDITIVE);
		panel_pos_y += e.size_y;
	}
}
