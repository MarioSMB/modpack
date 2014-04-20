#ifdef INTERFACE
CLASS(XonoticCvarList) EXTENDS(XonoticListBox)
	METHOD(XonoticCvarList, configureXonoticCvarList, void(entity))
	ATTRIB(XonoticCvarList, rowsPerItem, float, 1)
	METHOD(XonoticCvarList, drawListBoxItem, void(entity, float, vector, float))
	METHOD(XonoticCvarList, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(XonoticCvarList, keyDown, float(entity, float, float, float))

	METHOD(XonoticCvarList, destroy, void(entity))

	ATTRIB(XonoticCvarList, realFontSize, vector, '0 0 0')
	ATTRIB(XonoticCvarList, realUpperMargin, float, 0)
	ATTRIB(XonoticCvarList, columnNameOrigin, float, 0)
	ATTRIB(XonoticCvarList, columnNameSize, float, 0)
	ATTRIB(XonoticCvarList, columnValueOrigin, float, 0)
	ATTRIB(XonoticCvarList, columnValueSize, float, 0)

	METHOD(XonoticCvarList, mouseRelease, float(entity, vector))
	METHOD(XonoticCvarList, setSelected, void(entity, float))
	METHOD(XonoticCvarList, updateCvarType, float(entity))

	ATTRIB(XonoticCvarList, controlledTextbox, entity, NULL)
	ATTRIB(XonoticCvarList, cvarNameBox, entity, NULL)
	ATTRIB(XonoticCvarList, cvarDescriptionBox, entity, NULL)
	ATTRIB(XonoticCvarList, cvarTypeBox, entity, NULL)
	ATTRIB(XonoticCvarList, cvarValueBox, entity, NULL)
	ATTRIB(XonoticCvarList, cvarDefaultBox, entity, NULL)
	ATTRIB(XonoticCvarList, cvarNeedsForcing, float, 0)

	ATTRIB(XonoticCvarList, handle, float, -1)
	ATTRIB(XonoticCvarList, cvarName, string, string_null)
	ATTRIB(XonoticCvarList, cvarDescription, string, string_null)
	ATTRIB(XonoticCvarList, cvarType, string, string_null)
	ATTRIB(XonoticCvarList, cvarDefault, string, string_null)
ENDCLASS(XonoticCvarList)
entity makeXonoticCvarList();
void CvarList_Filter_Change(entity box, entity me);
void CvarList_Value_Change(entity box, entity me);
void CvarList_Revert_Click(entity btn, entity me);
void CvarList_End_Editing(entity box, entity me);
#endif

#ifdef IMPLEMENTATION
entity makeXonoticCvarList()
{
	entity me;
	me = spawnXonoticCvarList();
	me.configureXonoticCvarList(me);
	return me;
}
void XonoticCvarList_configureXonoticCvarList(entity me)
{
	me.configureXonoticListBox(me);

	me.handle = buf_create();
	buf_cvarlist(me.handle, "", "_");
	me.nItems = buf_getsize(me.handle);
}
void XonoticCvarList_destroy(entity me)
{
	buf_del(me.handle);
}
string autocvar_menu_forced_saved_cvars;
string autocvar_menu_reverted_nonsaved_cvars;
float XonoticCvarList_updateCvarType(entity me)
{
	float t;
	t = cvar_type(me.cvarName);
	me.cvarType = "";
	float needsForcing;
	if(strstrofs(strcat(" ", autocvar_menu_forced_saved_cvars, " "), strcat(" ", me.cvarName, " "), 0) >= 0)
	{
		me.cvarType = strcat(me.cvarType, ", ", _("forced to be saved to config.cfg"));
		needsForcing = 0;
	}
	else if(strstrofs(strcat(" ", autocvar_menu_reverted_nonsaved_cvars, " "), strcat(" ", me.cvarName, " "), 0) >= 0)
	{
		// Currently claims to be saved, but won't be on next startup.
		me.cvarType = strcat(me.cvarType, ", ", _("will not be saved"));
		needsForcing = 1;
	}
	else if(t & CVAR_TYPEFLAG_SAVED)
	{
		me.cvarType = strcat(me.cvarType, ", ", _("will be saved to config.cfg"));
		needsForcing = 0;
	}
	else
	{
		me.cvarType = strcat(me.cvarType, ", ", _("will not be saved"));
		needsForcing = 1;
	}
	if(t & CVAR_TYPEFLAG_PRIVATE)
		me.cvarType = strcat(me.cvarType, ", ", _("private"));
	if(t & CVAR_TYPEFLAG_ENGINE)
		me.cvarType = strcat(me.cvarType, ", ", _("engine setting"));
	if(t & CVAR_TYPEFLAG_READONLY)
		me.cvarType = strcat(me.cvarType, ", ", _("read only"));
	me.cvarType = strzone(substring(me.cvarType, 2, strlen(me.cvarType) - 2));
	me.cvarTypeBox.setText(me.cvarTypeBox, me.cvarType);
	return needsForcing;
}
void XonoticCvarList_setSelected(entity me, float i)
{
	string s;

	SUPER(XonoticCvarList).setSelected(me, i);
	if(me.nItems == 0)
		return;

	if(me.cvarName)
		strunzone(me.cvarName);
	if(me.cvarDescription)
		strunzone(me.cvarDescription);
	if(me.cvarType)
		strunzone(me.cvarType);
	if(me.cvarDefault)
		strunzone(me.cvarDefault);
	me.cvarName = strzone(bufstr_get(me.handle, me.selectedItem));
	me.cvarDescription = strzone(cvar_description(me.cvarName));
	me.cvarDefault = strzone(cvar_defstring(me.cvarName));
	me.cvarNameBox.setText(me.cvarNameBox, me.cvarName);
	me.cvarDescriptionBox.setText(me.cvarDescriptionBox, me.cvarDescription);
	float needsForcing = me.updateCvarType(me);
	me.cvarDefaultBox.setText(me.cvarDefaultBox, me.cvarDefault);

	// this one can handle tempstrings
	s = cvar_string(me.cvarName);
	me.cvarNeedsForcing = 0;
	me.cvarValueBox.setText(me.cvarValueBox, s);
	me.cvarNeedsForcing = needsForcing;
	me.cvarValueBox.cursorPos = strlen(s);
}
void CvarList_Filter_Change(entity box, entity me)
{
	buf_cvarlist(me.handle, box.text, "_");
	me.nItems = buf_getsize(me.handle);

	me.setSelected(me, 0);
}
void XonoticCvarList_resizeNotify(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	SUPER(XonoticCvarList).resizeNotify(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (absSize_y * me.itemHeight);
	me.realFontSize_x = me.fontSize / (absSize_x * (1 - me.controlWidth));
	me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);

	me.columnNameOrigin = 0;
	me.columnValueSize = me.realFontSize_x * 20;
	me.columnNameSize = 1 - me.columnValueSize - me.realFontSize_x;
	me.columnValueOrigin = me.columnNameOrigin + me.columnNameSize + me.realFontSize_x;

	me.setSelected(me, me.selectedItem);
}
void XonoticCvarList_drawListBoxItem(entity me, float i, vector absSize, float isSelected)
{
	string k, v, d;
	float t;

	vector theColor;
	float theAlpha;

	string s;

	if(isSelected)
		draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);

	k = bufstr_get(me.handle, i);

	v = cvar_string(k);
	d = cvar_defstring(k);
	t = cvar_type(k);
	if(strstrofs(strcat(" ", autocvar_menu_forced_saved_cvars, " "), strcat(" ", k, " "), 0) >= 0)
		theAlpha = SKINALPHA_CVARLIST_SAVED;
	else if(strstrofs(strcat(" ", autocvar_menu_reverted_nonsaved_cvars, " "), strcat(" ", k, " "), 0) >= 0)
		theAlpha = SKINALPHA_CVARLIST_TEMPORARY;
	else if(t & CVAR_TYPEFLAG_SAVED)
		theAlpha = SKINALPHA_CVARLIST_SAVED;
	else
		theAlpha = SKINALPHA_CVARLIST_TEMPORARY;
	if(v == d)
		theColor = SKINCOLOR_CVARLIST_UNCHANGED;
	else
		theColor = SKINCOLOR_CVARLIST_CHANGED;

	s = draw_TextShortenToWidth(k, me.columnNameSize, 0, me.realFontSize);
	draw_Text(me.realUpperMargin * eY + me.columnNameOrigin * eX, s, me.realFontSize, theColor, theAlpha, 0);
	s = draw_TextShortenToWidth(v, me.columnValueSize, 0, me.realFontSize);
	draw_Text(me.realUpperMargin * eY + me.columnValueOrigin * eX, s, me.realFontSize, theColor, theAlpha, 0);
}

float XonoticCvarList_keyDown(entity me, float scan, float ascii, float shift)
{
	if (scan == K_MOUSE3 || ((shift & S_CTRL) && scan == K_SPACE))
	{
		CvarList_Revert_Click(world, me);
		return 1;
	}
	else if(scan == K_ENTER)
	{
		me.cvarValueBox.parent.setFocus(me.cvarValueBox.parent, me.cvarValueBox);
		return 1;
	}
	else if(SUPER(XonoticCvarList).keyDown(me, scan, ascii, shift))
		return 1;
	else if(!me.controlledTextbox)
		return 0;
	else
		return me.controlledTextbox.keyDown(me.controlledTextbox, scan, ascii, shift);
}

float XonoticCvarList_mouseRelease(entity me, vector pos)
{
	if(me.pressed == 2)
		me.cvarValueBox.parent.setFocus(me.cvarValueBox.parent, me.cvarValueBox);
	return SUPER(XonoticCvarList).mouseRelease(me, pos);
}

void CvarList_Value_Change(entity box, entity me)
{
	cvar_set(me.cvarNameBox.text, box.text);
	if(me.cvarNeedsForcing)
	{
		localcmd(sprintf("\nseta %1$s \"$%1$s\"\n", me.cvarName));
		cvar_set("menu_reverted_nonsaved_cvars", substring(strreplace(strcat(" ", me.cvarName, " "), " ", strcat(" ", autocvar_menu_reverted_nonsaved_cvars, " ")), 1, -2));
		if (autocvar_menu_forced_saved_cvars == "")
			cvar_set("menu_forced_saved_cvars", me.cvarName);
		else
			cvar_set("menu_forced_saved_cvars", strcat(autocvar_menu_forced_saved_cvars, " ", me.cvarName));
		me.cvarNeedsForcing = 0;
		me.updateCvarType(me);
	}
}

void CvarList_Revert_Click(entity btn, entity me)
{
	me.cvarValueBox.setText(me.cvarValueBox, me.cvarDefault);
	me.cvarValueBox.cursorPos = strlen(me.cvarDefault);
	if(strstrofs(strcat(" ", autocvar_menu_forced_saved_cvars, " "), strcat(" ", me.cvarName, " "), 0) >= 0)
	{
		cvar_set("menu_forced_saved_cvars", substring(strreplace(strcat(" ", me.cvarName, " "), " ", strcat(" ", autocvar_menu_forced_saved_cvars, " ")), 1, -2));
		if (autocvar_menu_reverted_nonsaved_cvars == "")
			cvar_set("menu_reverted_nonsaved_cvars", me.cvarName);
		else
			cvar_set("menu_reverted_nonsaved_cvars", strcat(autocvar_menu_reverted_nonsaved_cvars, " ", me.cvarName));
	}
	me.cvarNeedsForcing = me.updateCvarType(me);
}

void CvarList_End_Editing(entity box, entity me)
{
	box.parent.setFocus(box.parent, me);
}

#endif
