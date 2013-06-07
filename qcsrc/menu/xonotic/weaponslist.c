#ifdef INTERFACE
CLASS(XonoticWeaponsList) EXTENDS(XonoticListBox)
	METHOD(XonoticWeaponsList, configureXonoticWeaponsList, void(entity))
	METHOD(XonoticWeaponsList, toString, string(entity))
	ATTRIB(XonoticWeaponsList, rowsPerItem, float, 1)
	METHOD(XonoticWeaponsList, draw, void(entity))
	METHOD(XonoticWeaponsList, drawListBoxItem, void(entity, float, vector, float))
	METHOD(XonoticWeaponsList, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(XonoticWeaponsList, keyDown, float(entity, float, float, float))
	ATTRIB(XonoticWeaponsList, realFontSize, vector, '0 0 0')
	ATTRIB(XonoticWeaponsList, realUpperMargin, float, 0)
	METHOD(XonoticWeaponsList, mouseDrag, float(entity, vector))
ENDCLASS(XonoticWeaponsList)
entity makeXonoticWeaponsList();
void WeaponsList_MoveUp_Click(entity btn, entity me);
void WeaponsList_MoveDown_Click(entity box, entity me);
#endif

#ifdef IMPLEMENTATION
entity makeXonoticWeaponsList()
{
	entity me;
	me = spawnXonoticWeaponsList();
	me.configureXonoticWeaponsList(me);
	return me;
}
void XonoticWeaponsList_configureXonoticWeaponsList(entity me)
{
	me.configureXonoticListBox(me);
}
void XonoticWeaponsList_draw(entity me)
{
	// read in cvar?
	string s, t;
	s = W_NumberWeaponOrder(cvar_string("cl_weaponpriority"));
	t = W_FixWeaponOrder(s, 1);
	if(t != s)
		cvar_set("cl_weaponpriority", W_NameWeaponOrder(t));
	me.nItems = tokenize_console(t);
	SUPER(XonoticWeaponsList).draw(me);
}
void WeaponsList_MoveUp_Click(entity box, entity me)
{
	if(me.selectedItem > 0)
	{
		cvar_set("cl_weaponpriority", swapInPriorityList(cvar_string("cl_weaponpriority"), me.selectedItem - 1, me.selectedItem));
		me.selectedItem -= 1;
	}
}
void WeaponsList_MoveDown_Click(entity box, entity me)
{
	if(me.selectedItem < me.nItems - 1)
	{
		cvar_set("cl_weaponpriority", swapInPriorityList(cvar_string("cl_weaponpriority"), me.selectedItem, me.selectedItem + 1));
		me.selectedItem += 1;
	}
}
void XonoticWeaponsList_resizeNotify(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	SUPER(XonoticWeaponsList).resizeNotify(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (absSize_y * me.itemHeight);
	me.realFontSize_x = me.fontSize / (absSize_x * (1 - me.controlWidth));
	me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);
}
float XonoticWeaponsList_mouseDrag(entity me, vector pos)
{
	float f, i;
	i = me.selectedItem;
	f = SUPER(XonoticWeaponsList).mouseDrag(me, pos);
	
	if(me.pressed != 1) // don't change priority if the person is just scrolling
	{
		if(me.selectedItem != i)
			cvar_set("cl_weaponpriority", swapInPriorityList(cvar_string("cl_weaponpriority"), me.selectedItem, i));
	}
	
	return f;
}
string XonoticWeaponsList_toString(entity me)
{
	float n, i;
	string s;
	entity e;
	n = tokenize_console(W_NumberWeaponOrder(cvar_string("cl_weaponpriority")));
	s = "";
	for(i = 0; i < n; ++i)
	{
		e = get_weaponinfo(stof(argv(i)));
		s = strcat(s, e.message, ", ");
	}
	return substring(s, 0, strlen(s) - 2);
}
void XonoticWeaponsList_drawListBoxItem(entity me, float i, vector absSize, float isSelected)
{
	entity e;
	if(isSelected)
		draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);
	e = get_weaponinfo(stof(argv(i)));
	string msg = e.message;
	if(e.spawnflags & WEP_FLAG_MUTATORBLOCKED)
		msg = sprintf(_("%s (mutator weapon)"), msg);
	draw_Text(me.realUpperMargin * eY, msg, me.realFontSize, '1 1 1', SKINALPHA_TEXT, 0);
}

float XonoticWeaponsList_keyDown(entity me, float scan, float ascii, float shift)
{
	if(ascii == 43) // +
	{
		WeaponsList_MoveUp_Click(NULL, me);
		return 1;
	}
	else if(scan == 45) // -
	{
		WeaponsList_MoveDown_Click(NULL, me);
		return 1;
	}
	else if(SUPER(XonoticWeaponsList).keyDown(me, scan, ascii, shift))
		return 1;
	return 0;
}
#endif
