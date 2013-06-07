#ifdef INTERFACE
CLASS(XonoticCreditsList) EXTENDS(XonoticListBox)
	METHOD(XonoticCreditsList, configureXonoticCreditsList, void(entity))
	ATTRIB(XonoticCreditsList, rowsPerItem, float, 1)
	METHOD(XonoticCreditsList, draw, void(entity))
	METHOD(XonoticCreditsList, drawListBoxItem, void(entity, float, vector, float))
	METHOD(XonoticCreditsList, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(XonoticCreditsList, keyDown, float(entity, float, float, float))
	METHOD(XonoticCreditsList, destroy, void(entity))

	ATTRIB(XonoticCreditsList, realFontSize, vector, '0 0 0')
	ATTRIB(XonoticCreditsList, realUpperMargin, float, 0)
	ATTRIB(XonoticCreditsList, bufferIndex, float, 0)
	ATTRIB(XonoticCreditsList, scrolling, float, 0)

	ATTRIB(XonoticListBox, alphaBG, float, 0)
ENDCLASS(XonoticCreditsList)
entity makeXonoticCreditsList();
#endif

#ifdef IMPLEMENTATION
entity makeXonoticCreditsList()
{
	entity me;
	me = spawnXonoticCreditsList();
	me.configureXonoticCreditsList(me);
	return me;
}
void XonoticCreditsList_configureXonoticCreditsList(entity me)
{
	me.configureXonoticListBox(me);
	// load the file
	me.bufferIndex = buf_load(language_filename("xonotic-credits.txt"));
	me.nItems = buf_getsize(me.bufferIndex);
}
void XonoticCreditsList_destroy(entity me)
{
	buf_del(me.bufferIndex);
}
void XonoticCreditsList_draw(entity me)
{
	float i;
	if(me.scrolling)
	{
		me.scrollPos = bound(0, (time - me.scrolling) * me.itemHeight, me.nItems * me.itemHeight - 1);
		i = min(me.selectedItem, floor((me.scrollPos + 1) / me.itemHeight - 1));
		i = max(i, ceil(me.scrollPos / me.itemHeight));
		me.setSelected(me, i);
	}
	SUPER(XonoticCreditsList).draw(me);
}
void XonoticCreditsList_resizeNotify(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	SUPER(XonoticCreditsList).resizeNotify(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (absSize_y * me.itemHeight);
	me.realFontSize_x = me.fontSize / (absSize_x * (1 - me.controlWidth));
	me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);
}
void XonoticCreditsList_drawListBoxItem(entity me, float i, vector absSize, float isSelected)
{
	// layout: Ping, Credits name, Map name, NP, TP, MP
	string s;
	float theAlpha;
	vector theColor;

	s = bufstr_get(me.bufferIndex, i);

	if(substring(s, 0, 2) == "**")
	{
		s = substring(s, 2, strlen(s) - 2);
		theColor = SKINCOLOR_CREDITS_TITLE;
		theAlpha = SKINALPHA_CREDITS_TITLE;
	}
	else if(substring(s, 0, 1) == "*")
	{
		s = substring(s, 1, strlen(s) - 1);
		theColor = SKINCOLOR_CREDITS_FUNCTION;
		theAlpha = SKINALPHA_CREDITS_FUNCTION;
	}
	else
	{
		theColor = SKINCOLOR_CREDITS_PERSON;
		theAlpha = SKINALPHA_CREDITS_PERSON;
	}

	draw_CenterText(me.realUpperMargin * eY + 0.5 * eX, s, me.realFontSize, theColor, theAlpha, 0);
}

float XonoticCreditsList_keyDown(entity me, float key, float ascii, float shift)
{
	float i;
	me.dragScrollTimer = time;
	me.scrolling = 0;
	if(key == K_PGUP || key == K_KP_PGUP)
		me.scrollPos = max(me.scrollPos - 0.5, 0);
	else if(key == K_PGDN || key == K_KP_PGDN)
		me.scrollPos = min(me.scrollPos + 0.5, me.nItems * me.itemHeight - 1);
	else if(key == K_UPARROW || key == K_KP_UPARROW)
		me.scrollPos = max(me.scrollPos - me.itemHeight, 0);
	else if(key == K_DOWNARROW || key == K_KP_DOWNARROW)
		me.scrollPos = min(me.scrollPos + me.itemHeight, me.nItems * me.itemHeight - 1);
	else
		return SUPER(XonoticCreditsList).keyDown(me, key, ascii, shift);

	i = min(me.selectedItem, floor((me.scrollPos + 1) / me.itemHeight - 1));
	i = max(i, ceil(me.scrollPos / me.itemHeight));
	me.setSelected(me, i);

	return 1;
}
#endif
