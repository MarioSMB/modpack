#ifdef INTERFACE
CLASS(XonoticMapList) EXTENDS(XonoticListBox)
	METHOD(XonoticMapList, configureXonoticMapList, void(entity))
	ATTRIB(XonoticMapList, rowsPerItem, float, 4)
	METHOD(XonoticMapList, draw, void(entity))
	METHOD(XonoticMapList, drawListBoxItem, void(entity, float, vector, float))
	METHOD(XonoticMapList, clickListBoxItem, void(entity, float, vector))
	METHOD(XonoticMapList, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(XonoticMapList, refilter, void(entity))
	METHOD(XonoticMapList, refilterCallback, void(entity, entity))
	METHOD(XonoticMapList, keyDown, float(entity, float, float, float))

	ATTRIB(XonoticMapList, realFontSize, vector, '0 0 0')
	ATTRIB(XonoticMapList, columnPreviewOrigin, float, 0)
	ATTRIB(XonoticMapList, columnPreviewSize, float, 0)
	ATTRIB(XonoticMapList, columnNameOrigin, float, 0)
	ATTRIB(XonoticMapList, columnNameSize, float, 0)
	ATTRIB(XonoticMapList, checkMarkOrigin, vector, '0 0 0')
	ATTRIB(XonoticMapList, checkMarkSize, vector, '0 0 0')
	ATTRIB(XonoticMapList, realUpperMargin1, float, 0)
	ATTRIB(XonoticMapList, realUpperMargin2, float, 0)

	ATTRIB(XonoticMapList, lastClickedMap, float, -1)
	ATTRIB(XonoticMapList, lastClickedTime, float, 0)

	ATTRIB(XonoticMapList, lastGametype, float, 0)
	ATTRIB(XonoticMapList, lastFeatures, float, 0)

	ATTRIB(XonoticMapList, origin, vector, '0 0 0')
	ATTRIB(XonoticMapList, itemAbsSize, vector, '0 0 0')

	ATTRIB(XonoticMapList, g_maplistCache, string, string_null)
	METHOD(XonoticMapList, g_maplistCacheToggle, void(entity, float))
	METHOD(XonoticMapList, g_maplistCacheQuery, float(entity, float))

	ATTRIB(XonoticMapList, startButton, entity, NULL)

	METHOD(XonoticMapList, loadCvars, void(entity))

	ATTRIB(XonoticMapList, typeToSearchString, string, string_null)
	ATTRIB(XonoticMapList, typeToSearchTime, float, 0)

	METHOD(XonoticMapList, destroy, void(entity))

	ATTRIB(XonoticListBox, alphaBG, float, 0)
ENDCLASS(XonoticMapList)
entity makeXonoticMapList();
void MapList_All(entity btn, entity me);
void MapList_None(entity btn, entity me);
void MapList_LoadMap(entity btn, entity me);
#endif

#ifdef IMPLEMENTATION
void XonoticMapList_destroy(entity me)
{
	MapInfo_Shutdown();
}

entity makeXonoticMapList()
{
	entity me;
	me = spawnXonoticMapList();
	me.configureXonoticMapList(me);
	return me;
}

void XonoticMapList_configureXonoticMapList(entity me)
{
	me.configureXonoticListBox(me);
	me.refilter(me);
}

void XonoticMapList_loadCvars(entity me)
{
	me.refilter(me);
}

float XonoticMapList_g_maplistCacheQuery(entity me, float i)
{
	return stof(substring(me.g_maplistCache, i, 1));
}
void XonoticMapList_g_maplistCacheToggle(entity me, float i)
{
	string a, b, c, s, bspname;
	float n;
	s = me.g_maplistCache;
	if not(s)
		return;
	b = substring(s, i, 1);
	if(b == "0")
		b = "1";
	else if(b == "1")
		b = "0";
	else
		return; // nothing happens
	a = substring(s, 0, i);
	c = substring(s, i+1, strlen(s) - (i+1));
	strunzone(s);
	me.g_maplistCache = strzone(strcat(a, b, c));
	// TODO also update the actual cvar
	if not((bspname = MapInfo_BSPName_ByID(i)))
		return;
	if(b == "1")
		cvar_set("g_maplist", strcat(bspname, " ", cvar_string("g_maplist")));
	else
	{
		s = "";
		n = tokenize_console(cvar_string("g_maplist"));
		for(i = 0; i < n; ++i)
			if(argv(i) != bspname)
				s = strcat(s, " ", argv(i));
		cvar_set("g_maplist", substring(s, 1, strlen(s) - 1));
	}
}

void XonoticMapList_draw(entity me)
{
	if(me.startButton)
		me.startButton.disabled = ((me.selectedItem < 0) || (me.selectedItem >= me.nItems));
	SUPER(XonoticMapList).draw(me);
}

void XonoticMapList_resizeNotify(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.itemAbsSize = '0 0 0';
	SUPER(XonoticMapList).resizeNotify(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (me.itemAbsSize_y = (absSize_y * me.itemHeight));
	me.realFontSize_x = me.fontSize / (me.itemAbsSize_x = (absSize_x * (1 - me.controlWidth)));
	me.realUpperMargin1 = 0.5 * (1 - 2.5 * me.realFontSize_y);
	me.realUpperMargin2 = me.realUpperMargin1 + 1.5 * me.realFontSize_y;

	me.columnPreviewOrigin = 0;
	me.columnPreviewSize = me.itemAbsSize_y / me.itemAbsSize_x * 4 / 3;
	me.columnNameOrigin = me.columnPreviewOrigin + me.columnPreviewSize + me.realFontSize_x;
	me.columnNameSize = 1 - me.columnPreviewSize - 2 * me.realFontSize_x;

	me.checkMarkSize = (eX * (me.itemAbsSize_y / me.itemAbsSize_x) + eY) * 0.5;
	me.checkMarkOrigin = eY + eX * (me.columnPreviewOrigin + me.columnPreviewSize) - me.checkMarkSize;
}

void XonoticMapList_clickListBoxItem(entity me, float i, vector where)
{
	if(where_x <= me.columnPreviewOrigin + me.columnPreviewSize)
	{
		if(where_x >= 0)
			me.g_maplistCacheToggle(me, i);
	}
	if(where_x >= me.columnNameOrigin)
		if(where_x <= 1)
			{
				if(i == me.lastClickedMap)
					if(time < me.lastClickedTime + 0.3)
					{
						// DOUBLE CLICK!
						// pop up map info screen
						main.mapInfoDialog.loadMapInfo(main.mapInfoDialog, i, me);
						DialogOpenButton_Click_withCoords(NULL, main.mapInfoDialog, me.origin + eX * (me.columnNameOrigin * me.size_x) + eY * ((me.itemHeight * i - me.scrollPos) * me.size_y), eY * me.itemAbsSize_y + eX * (me.itemAbsSize_x * me.columnNameSize));
						return;
					}
				me.lastClickedMap = i;
				me.lastClickedTime = time;
			}
}

void XonoticMapList_drawListBoxItem(entity me, float i, vector absSize, float isSelected)
{
	// layout: Ping, Map name, Map name, NP, TP, MP
	string s;
	float theAlpha;
	float included;

	if(!MapInfo_Get_ByID(i))
		return;

	included = me.g_maplistCacheQuery(me, i);
	if(included || isSelected)
		theAlpha = SKINALPHA_MAPLIST_INCLUDEDFG;
	else
		theAlpha = SKINALPHA_MAPLIST_NOTINCLUDEDFG;

	if(isSelected)
		draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);
	else if(included)
		draw_Fill('0 0 0', '1 1 0', SKINCOLOR_MAPLIST_INCLUDEDBG, SKINALPHA_MAPLIST_INCLUDEDBG);

	if(draw_PictureSize(strcat("/maps/", MapInfo_Map_bspname)) == '0 0 0')
		draw_Picture(me.columnPreviewOrigin * eX, "nopreview_map", me.columnPreviewSize * eX + eY, '1 1 1', theAlpha);
	else
		draw_Picture(me.columnPreviewOrigin * eX, strcat("/maps/", MapInfo_Map_bspname), me.columnPreviewSize * eX + eY, '1 1 1', theAlpha);

	if(included)
		draw_Picture(me.checkMarkOrigin, "checkmark", me.checkMarkSize, '1 1 1', 1);
	s = draw_TextShortenToWidth(strdecolorize(MapInfo_Map_titlestring), me.columnNameSize, 0, me.realFontSize);
	draw_Text(me.realUpperMargin1 * eY + (me.columnNameOrigin + 0.00 * (me.columnNameSize - draw_TextWidth(s, 0, me.realFontSize))) * eX, s, me.realFontSize, SKINCOLOR_MAPLIST_TITLE, theAlpha, 0);
	s = draw_TextShortenToWidth(strdecolorize(MapInfo_Map_author), me.columnNameSize, 0,  me.realFontSize);
	draw_Text(me.realUpperMargin2 * eY + (me.columnNameOrigin + 1.00 * (me.columnNameSize - draw_TextWidth(s, 0, me.realFontSize))) * eX, s, me.realFontSize, SKINCOLOR_MAPLIST_AUTHOR, theAlpha, 0);

	MapInfo_ClearTemps();
}

void XonoticMapList_refilter(entity me)
{
	float i, j, n;
	string s;
	float gt, f;
	gt = MapInfo_CurrentGametype();
	f = MapInfo_CurrentFeatures();
	MapInfo_FilterGametype(gt, f, MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 0);
	me.nItems = MapInfo_count;
	for(i = 0; i < MapInfo_count; ++i)
		draw_PreloadPicture(strcat("/maps/", MapInfo_BSPName_ByID(i)));
	if(me.g_maplistCache)
		strunzone(me.g_maplistCache);
	s = "0";
	for(i = 1; i < MapInfo_count; i *= 2)
		s = strcat(s, s);
	n = tokenize_console(cvar_string("g_maplist"));
	for(i = 0; i < n; ++i)
	{
		j = MapInfo_FindName(argv(i));
		if(j >= 0)
			s = strcat(
				substring(s, 0, j),
				"1",
				substring(s, j+1, MapInfo_count - (j+1))
			);
	}
	me.g_maplistCache = strzone(s);
	if(gt != me.lastGametype || f != me.lastFeatures)
	{
		me.lastGametype = gt;
		me.lastFeatures = f;
		me.setSelected(me, 0);
	}
}

void XonoticMapList_refilterCallback(entity me, entity cb)
{
	me.refilter(me);
}

void MapList_All(entity btn, entity me)
{
	float i;
	string s;
	MapInfo_FilterGametype(MAPINFO_TYPE_ALL, 0, 0, MapInfo_ForbiddenFlags(), 0); // all
	s = "";
	for(i = 0; i < MapInfo_count; ++i)
		s = strcat(s, " ", MapInfo_BSPName_ByID(i));
	cvar_set("g_maplist", substring(s, 1, strlen(s) - 1));
	me.refilter(me);
}

void MapList_None(entity btn, entity me)
{
	cvar_set("g_maplist", "");
	me.refilter(me);
}

void MapList_LoadMap(entity btn, entity me)
{
	string m;
	float i;

	i = me.selectedItem;

	if(btn.parent.instanceOfXonoticMapInfoDialog)
	{
		i = btn.parent.currentMapIndex;
		Dialog_Close(btn, btn.parent);
	}

	if(i >= me.nItems || i < 0)
		return;

	m = MapInfo_BSPName_ByID(i);
	if not(m)
	{
		print(_("Huh? Can't play this (m is NULL). Refiltering so this won't happen again.\n"));
		me.refilter(me);
		return;
	}
	if(MapInfo_CheckMap(m))
	{
		localcmd("\nmenu_loadmap_prepare\n");
		if(cvar("menu_use_default_hostname"))
			localcmd("hostname \"", sprintf(_("%s's Xonotic Server"), strdecolorize(cvar_string("_cl_name"))), "\"\n");
		MapInfo_LoadMap(m, 1);
	}
	else
	{
		print(_("Huh? Can't play this (invalid game type). Refiltering so this won't happen again.\n"));
		me.refilter(me);
		return;
	}
}

float XonoticMapList_keyDown(entity me, float scan, float ascii, float shift)
{
	string ch, save;
	if(me.nItems <= 0)
		return SUPER(XonoticMapList).keyDown(me, scan, ascii, shift);
	if(scan == K_ENTER || scan == K_KP_ENTER)
	{
		// pop up map info screen
		main.mapInfoDialog.loadMapInfo(main.mapInfoDialog, me.selectedItem, me);
		DialogOpenButton_Click_withCoords(NULL, main.mapInfoDialog, me.origin + eX * (me.columnNameOrigin * me.size_x) + eY * ((me.itemHeight * me.selectedItem - me.scrollPos) * me.size_y), eY * me.itemAbsSize_y + eX * (me.itemAbsSize_x * me.columnNameSize));
	}
	else if(scan == K_SPACE)
	{
		me.g_maplistCacheToggle(me, me.selectedItem);
	}
	else if(ascii == 43) // +
	{
		if not(me.g_maplistCacheQuery(me, me.selectedItem))
			me.g_maplistCacheToggle(me, me.selectedItem);
	}
	else if(ascii == 45) // -
	{
		if(me.g_maplistCacheQuery(me, me.selectedItem))
			me.g_maplistCacheToggle(me, me.selectedItem);
	}
	else if(scan == K_BACKSPACE)
	{
		if(time < me.typeToSearchTime)
		{
			save = substring(me.typeToSearchString, 0, strlen(me.typeToSearchString) - 1);
			if(me.typeToSearchString)
				strunzone(me.typeToSearchString);
			me.typeToSearchString = strzone(save);
			me.typeToSearchTime = time + 0.5;
			if(strlen(me.typeToSearchString))
			{
				MapInfo_FindName(me.typeToSearchString);
				if(MapInfo_FindName_firstResult >= 0)
					me.setSelected(me, MapInfo_FindName_firstResult);
			}
		}
	}
	else if(ascii >= 32 && ascii != 127)
	{
		ch = chr(ascii);
		if(time > me.typeToSearchTime)
			save = ch;
		else
			save = strcat(me.typeToSearchString, ch);
		if(me.typeToSearchString)
			strunzone(me.typeToSearchString);
		me.typeToSearchString = strzone(save);
		me.typeToSearchTime = time + 0.5;
		MapInfo_FindName(me.typeToSearchString);
		if(MapInfo_FindName_firstResult >= 0)
			me.setSelected(me, MapInfo_FindName_firstResult);
	}
	else
		return SUPER(XonoticMapList).keyDown(me, scan, ascii, shift);
	return 1;
}

#endif
