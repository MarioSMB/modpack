#ifdef INTERFACE
CLASS(XonoticKeyBinder) EXTENDS(XonoticListBox)
	METHOD(XonoticKeyBinder, configureXonoticKeyBinder, void(entity))
	ATTRIB(XonoticKeyBinder, rowsPerItem, float, 1)
	METHOD(XonoticKeyBinder, drawListBoxItem, void(entity, float, vector, float))
	METHOD(XonoticKeyBinder, clickListBoxItem, void(entity, float, vector))
	METHOD(XonoticKeyBinder, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(XonoticKeyBinder, setSelected, void(entity, float))
	METHOD(XonoticKeyBinder, keyDown, float(entity, float, float, float))
	METHOD(XonoticKeyBinder, keyGrabbed, void(entity, float, float))

	ATTRIB(XonoticKeyBinder, realFontSize, vector, '0 0 0')
	ATTRIB(XonoticKeyBinder, realUpperMargin, float, 0)
	ATTRIB(XonoticKeyBinder, columnFunctionOrigin, float, 0)
	ATTRIB(XonoticKeyBinder, columnFunctionSize, float, 0)
	ATTRIB(XonoticKeyBinder, columnKeysOrigin, float, 0)
	ATTRIB(XonoticKeyBinder, columnKeysSize, float, 0)

	ATTRIB(XonoticKeyBinder, lastClickedKey, float, -1)
	ATTRIB(XonoticKeyBinder, lastClickedTime, float, 0)
	ATTRIB(XonoticKeyBinder, previouslySelected, float, -1)
	ATTRIB(XonoticKeyBinder, inMouseHandler, float, 0)
	ATTRIB(XonoticKeyBinder, userbindEditButton, entity, NULL)
	ATTRIB(XonoticKeyBinder, keyGrabButton, entity, NULL)
	ATTRIB(XonoticKeyBinder, clearButton, entity, NULL)
	ATTRIB(XonoticKeyBinder, userbindEditDialog, entity, NULL)
	METHOD(XonoticKeyBinder, editUserbind, void(entity, string, string, string))
ENDCLASS(XonoticKeyBinder)
entity makeXonoticKeyBinder();
void KeyBinder_Bind_Change(entity btn, entity me);
void KeyBinder_Bind_Clear(entity btn, entity me);
void KeyBinder_Bind_Edit(entity btn, entity me);
#endif

#ifdef IMPLEMENTATION

const string KEY_NOT_BOUND_CMD = "// not bound";

#define MAX_KEYS_PER_FUNCTION 2
#define MAX_KEYBINDS 256
string Xonotic_KeyBinds_Functions[MAX_KEYBINDS];
string Xonotic_KeyBinds_Descriptions[MAX_KEYBINDS];
var float Xonotic_KeyBinds_Count = -1;

void Xonotic_KeyBinds_Read()
{
	float fh;
	string s;

	Xonotic_KeyBinds_Count = 0;
	fh = fopen(language_filename("keybinds.txt"), FILE_READ);
	if(fh < 0)
		return;
	while((s = fgets(fh)))
	{
		if(tokenize_console(s) != 2)
			continue;
		Xonotic_KeyBinds_Functions[Xonotic_KeyBinds_Count] = strzone(argv(0));
		Xonotic_KeyBinds_Descriptions[Xonotic_KeyBinds_Count] = strzone(argv(1));
		++Xonotic_KeyBinds_Count;
		if(Xonotic_KeyBinds_Count >= MAX_KEYBINDS)
			break;
	}
	fclose(fh);
}

entity makeXonoticKeyBinder()
{
	entity me;
	me = spawnXonoticKeyBinder();
	me.configureXonoticKeyBinder(me);
	return me;
}
void replace_bind(string from, string to)
{
	float n, j, k;
	n = tokenize(findkeysforcommand(from, 0)); // uses '...' strings
	for(j = 0; j < n; ++j)
	{
		k = stof(argv(j));
		if(k != -1)
			localcmd("\nbind \"", keynumtostring(k), "\" \"", to, "\"\n");
	}
	if(n)
		cvar_set("_hud_showbinds_reload", "1");
}
void XonoticKeyBinder_configureXonoticKeyBinder(entity me)
{
	me.configureXonoticListBox(me);
	if(Xonotic_KeyBinds_Count < 0)
		Xonotic_KeyBinds_Read();
	me.nItems = Xonotic_KeyBinds_Count;
	me.setSelected(me, 0);

	// TEMP: Xonotic 0.1 to later
	replace_bind("impulse 1", "weapon_group_1");
	replace_bind("impulse 2", "weapon_group_2");
	replace_bind("impulse 3", "weapon_group_3");
	replace_bind("impulse 4", "weapon_group_4");
	replace_bind("impulse 5", "weapon_group_5");
	replace_bind("impulse 6", "weapon_group_6");
	replace_bind("impulse 7", "weapon_group_7");
	replace_bind("impulse 8", "weapon_group_8");
	replace_bind("impulse 9", "weapon_group_9");
	replace_bind("impulse 14", "weapon_group_0");
}
void XonoticKeyBinder_resizeNotify(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	SUPER(XonoticKeyBinder).resizeNotify(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (absSize_y * me.itemHeight);
	me.realFontSize_x = me.fontSize / (absSize_x * (1 - me.controlWidth));
	me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);

	me.columnFunctionOrigin = 0;
	me.columnKeysSize = me.realFontSize_x * 12;
	me.columnFunctionSize = 1 - me.columnKeysSize - 2 * me.realFontSize_x;
	me.columnKeysOrigin = me.columnFunctionOrigin + me.columnFunctionSize + me.realFontSize_x;

	if(me.userbindEditButton)
		me.userbindEditButton.disabled = (substring(Xonotic_KeyBinds_Descriptions[me.selectedItem], 0, 1) != "$");
}
void KeyBinder_Bind_Change(entity btn, entity me)
{
	string func;

	func = Xonotic_KeyBinds_Functions[me.selectedItem];
	if(func == "")
		return;

	me.keyGrabButton.forcePressed = 1;
	me.clearButton.disabled = 1;
	keyGrabber = me;
}
void XonoticKeyBinder_keyGrabbed(entity me, float key, float ascii)
{
	float n, j, k, nvalid;
	string func;

	me.keyGrabButton.forcePressed = 0;
	me.clearButton.disabled = 0;

	if(key == K_ESCAPE)
		return;

	func = Xonotic_KeyBinds_Functions[me.selectedItem];
	if(func == "")
		return;

	n = tokenize(findkeysforcommand(func, 0)); // uses '...' strings
	nvalid = 0;
	for(j = 0; j < n; ++j)
	{
		k = stof(argv(j));
		if(k != -1)
			++nvalid;
	}
	if(nvalid >= MAX_KEYS_PER_FUNCTION)
	{
		for(j = 0; j < n; ++j)
		{
			k = stof(argv(j));
			if(k != -1)
				//localcmd("\nunbind \"", keynumtostring(k), "\"\n");
				localcmd("\nbind \"", keynumtostring(k), "\" \"", KEY_NOT_BOUND_CMD, "\"\n");
		}
	}
	localcmd("\nbind \"", keynumtostring(key), "\" \"", func, "\"\n");
	localcmd("-zoom\n"); // to make sure we aren't in togglezoom'd state
	cvar_set("_hud_showbinds_reload", "1");
}
void XonoticKeyBinder_editUserbind(entity me, string theName, string theCommandPress, string theCommandRelease)
{
	string func, descr;

	if(!me.userbindEditDialog)
		return;

	func = Xonotic_KeyBinds_Functions[me.selectedItem];
	if(func == "")
		return;

	descr = Xonotic_KeyBinds_Descriptions[me.selectedItem];
	if(substring(descr, 0, 1) != "$")
		return;
	descr = substring(descr, 1, strlen(descr) - 1);

	// Hooray! It IS a user bind!
	cvar_set(strcat(descr, "_description"), theName);
	cvar_set(strcat(descr, "_press"), theCommandPress);
	cvar_set(strcat(descr, "_release"), theCommandRelease);
}
void KeyBinder_Bind_Edit(entity btn, entity me)
{
	string func, descr;

	if(!me.userbindEditDialog)
		return;

	func = Xonotic_KeyBinds_Functions[me.selectedItem];
	if(func == "")
		return;

	descr = Xonotic_KeyBinds_Descriptions[me.selectedItem];
	if(substring(descr, 0, 1) != "$")
		return;
	descr = substring(descr, 1, strlen(descr) - 1);

	// Hooray! It IS a user bind!
	me.userbindEditDialog.loadUserBind(me.userbindEditDialog, cvar_string(strcat(descr, "_description")), cvar_string(strcat(descr, "_press")), cvar_string(strcat(descr, "_release")));

	DialogOpenButton_Click(btn, me.userbindEditDialog);
}
void KeyBinder_Bind_Clear(entity btn, entity me)
{
	float n, j, k;
	string func;

	func = Xonotic_KeyBinds_Functions[me.selectedItem];
	if(func == "")
		return;

	n = tokenize(findkeysforcommand(func, 0)); // uses '...' strings
	for(j = 0; j < n; ++j)
	{
		k = stof(argv(j));
		if(k != -1)
			//localcmd("\nunbind \"", keynumtostring(k), "\"\n");
			localcmd("\nbind \"", keynumtostring(k), "\" \"", KEY_NOT_BOUND_CMD, "\"\n");
	}
	localcmd("-zoom\n"); // to make sure we aren't in togglezoom'd state
	cvar_set("_hud_showbinds_reload", "1");
}
void XonoticKeyBinder_clickListBoxItem(entity me, float i, vector where)
{
	if(i == me.lastClickedServer)
		if(time < me.lastClickedTime + 0.3)
		{
			// DOUBLE CLICK!
			KeyBinder_Bind_Change(NULL, me);
		}
	me.lastClickedServer = i;
	me.lastClickedTime = time;
}
void XonoticKeyBinder_setSelected(entity me, float i)
{
	// handling of "unselectable" items
	i = floor(0.5 + bound(0, i, me.nItems - 1));
	if(me.pressed == 0 || me.pressed == 1) // keyboard or scrolling - skip unselectable items
	{
		if(i > me.previouslySelected)
		{
			while((i < me.nItems - 1) && (Xonotic_KeyBinds_Functions[i] == ""))
				++i;
		}
		while((i > 0) && (Xonotic_KeyBinds_Functions[i] == ""))
			--i;
		while((i < me.nItems - 1) && (Xonotic_KeyBinds_Functions[i] == ""))
			++i;
	}
	if(me.pressed == 3) // released the mouse - fall back to last valid item
	{
		if(Xonotic_KeyBinds_Functions[i] == "")
			i = me.previouslySelected;
	}
	if(Xonotic_KeyBinds_Functions[i] != "")
		me.previouslySelected = i;
	if(me.userbindEditButton)
		me.userbindEditButton.disabled = (substring(Xonotic_KeyBinds_Descriptions[i], 0, 1) != "$");
	SUPER(XonoticKeyBinder).setSelected(me, i);
}
float XonoticKeyBinder_keyDown(entity me, float key, float ascii, float shift)
{
	float r;
	r = 1;
	switch(key)
	{
		case K_ENTER:
		case K_KP_ENTER:
		case K_SPACE:
			KeyBinder_Bind_Change(me, me);
			break;
		case K_DEL:
		case K_KP_DEL:
		case K_BACKSPACE:
			KeyBinder_Bind_Clear(me, me);
			break;
		default:
			r = SUPER(XonoticKeyBinder).keyDown(me, key, ascii, shift);
			break;
	}
	return r;
}
void XonoticKeyBinder_drawListBoxItem(entity me, float i, vector absSize, float isSelected)
{
	string s;
	float j, k, n;
	vector theColor;
	float theAlpha;
	string func, descr;
	float extraMargin;

	descr = Xonotic_KeyBinds_Descriptions[i];
	func = Xonotic_KeyBinds_Functions[i];

	if(func == "")
	{
		theAlpha = 1;
		theColor = SKINCOLOR_KEYGRABBER_TITLES;
		theAlpha = SKINALPHA_KEYGRABBER_TITLES;
		extraMargin = 0;
	}
	else
	{
		if(isSelected)
		{
			if(keyGrabber == me)
				draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_WAITING, SKINALPHA_LISTBOX_WAITING);
			else
				draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);
		}
		theAlpha = SKINALPHA_KEYGRABBER_KEYS;
		theColor = SKINCOLOR_KEYGRABBER_KEYS;
		extraMargin = me.realFontSize_x * 0.5;
	}

	if(substring(descr, 0, 1) == "$")
	{
		s = substring(descr, 1, strlen(descr) - 1);
		descr = cvar_string(strcat(s, "_description"));
		if(descr == "")
			descr = s;
		if(cvar_string(strcat(s, "_press")) == "")
			if(cvar_string(strcat(s, "_release")) == "")
				theAlpha *= SKINALPHA_DISABLED;
	}

	s = draw_TextShortenToWidth(descr, me.columnFunctionSize, 0, me.realFontSize);
	draw_Text(me.realUpperMargin * eY + extraMargin * eX, s, me.realFontSize, theColor, theAlpha, 0);
	if(func != "")
	{
		n = tokenize(findkeysforcommand(func, 0)); // uses '...' strings
		s = "";
		for(j = 0; j < n; ++j)
		{
			k = stof(argv(j));
			if(k != -1)
			{
				if(s != "")
					s = strcat(s, ", ");
				s = strcat(s, keynumtostring(k));
			}
		}
		s = draw_TextShortenToWidth(s, me.columnKeysSize, 0, me.realFontSize);
		draw_CenterText(me.realUpperMargin * eY + (me.columnKeysOrigin + 0.5 * me.columnKeysSize) * eX, s, me.realFontSize, theColor, theAlpha, 0);
	}
}
#endif
