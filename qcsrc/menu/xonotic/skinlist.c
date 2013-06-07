#ifdef INTERFACE
CLASS(XonoticSkinList) EXTENDS(XonoticListBox)
	METHOD(XonoticSkinList, configureXonoticSkinList, void(entity))
	ATTRIB(XonoticSkinList, rowsPerItem, float, 4)
	METHOD(XonoticSkinList, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(XonoticSkinList, drawListBoxItem, void(entity, float, vector, float))
	METHOD(XonoticSkinList, getSkins, void(entity))
	METHOD(XonoticSkinList, setSkin, void(entity))
	METHOD(XonoticSkinList, loadCvars, void(entity))
	METHOD(XonoticSkinList, saveCvars, void(entity))
	METHOD(XonoticSkinList, skinParameter, string(entity, float, float))
	METHOD(XonoticSkinList, clickListBoxItem, void(entity, float, vector))
	METHOD(XonoticSkinList, keyDown, float(entity, float, float, float))
	METHOD(XonoticSkinList, destroy, void(entity))

	ATTRIB(XonoticSkinList, skinlist, float, -1)
	ATTRIB(XonoticSkinList, realFontSize, vector, '0 0 0')
	ATTRIB(XonoticSkinList, columnPreviewOrigin, float, 0)
	ATTRIB(XonoticSkinList, columnPreviewSize, float, 0)
	ATTRIB(XonoticSkinList, columnNameOrigin, float, 0)
	ATTRIB(XonoticSkinList, columnNameSize, float, 0)
	ATTRIB(XonoticSkinList, realUpperMargin1, float, 0)
	ATTRIB(XonoticSkinList, realUpperMargin2, float, 0)
	ATTRIB(XonoticSkinList, origin, vector, '0 0 0')
	ATTRIB(XonoticSkinList, itemAbsSize, vector, '0 0 0')

	ATTRIB(XonoticSkinList, lastClickedSkin, float, -1)
	ATTRIB(XonoticSkinList, lastClickedTime, float, 0)

	ATTRIB(XonoticSkinList, name, string, "skinselector")
ENDCLASS(XonoticSkinList)

entity makeXonoticSkinList();
void SetSkin_Click(entity btn, entity me);
#endif

#ifdef IMPLEMENTATION

#define SKINPARM_NAME 0
#define SKINPARM_TITLE 1
#define SKINPARM_AUTHOR 2
#define SKINPARM_PREVIEW 3
#define SKINPARM_COUNT 4

entity makeXonoticSkinList()
{
	entity me;
	me = spawnXonoticSkinList();
	me.configureXonoticSkinList(me);
	return me;
}

void XonoticSkinList_configureXonoticSkinList(entity me)
{
	me.configureXonoticListBox(me);
	me.getSkins(me);
	me.loadCvars(me);
}

void XonoticSkinList_loadCvars(entity me)
{
	string s;
	float i, n;
	s = cvar_string("menu_skin");
	n = me.nItems;
	for(i = 0; i < n; ++i)
	{
		if(me.skinParameter(me, i, SKINPARM_NAME) == s)
		{
			me.selectedItem = i;
			break;
		}
	}
}

void XonoticSkinList_saveCvars(entity me)
{
	cvar_set("menu_skin", me.skinParameter(me, me.selectedItem, SKINPARM_NAME));
}

string XonoticSkinList_skinParameter(entity me, float i, float key)
{
	return bufstr_get(me.skinlist, i * SKINPARM_COUNT + key);
}

void XonoticSkinList_getSkins(entity me)
{
	float glob, buf, i, n, fh;
	string s;

	buf = buf_create();
	glob = search_begin("gfx/menu/*/skinvalues.txt", TRUE, TRUE);
	if(glob < 0)
	{
		me.skinlist = buf;
		me.nItems = 0;
		return;
	}

	n = search_getsize(glob);
	for(i = 0; i < n; ++i)
	{
		s = search_getfilename(glob, i);
		bufstr_set(buf, i * SKINPARM_COUNT + SKINPARM_NAME, substring(s, 9, strlen(s) - 24)); // the * part
		bufstr_set(buf, i * SKINPARM_COUNT + SKINPARM_TITLE, _("<TITLE>"));
		bufstr_set(buf, i * SKINPARM_COUNT + SKINPARM_AUTHOR, _("<AUTHOR>"));
		if(draw_PictureSize(strcat("/gfx/menu/", substring(s, 9, strlen(s) - 24), "/skinpreview")) == '0 0 0')
			bufstr_set(buf, i * SKINPARM_COUNT + SKINPARM_PREVIEW, "nopreview_menuskin");
		else
			bufstr_set(buf, i * SKINPARM_COUNT + SKINPARM_PREVIEW, strcat("/gfx/menu/", substring(s, 9, strlen(s) - 24), "/skinpreview"));
		fh = fopen(language_filename(s), FILE_READ);
		if(fh < 0)
		{
			print("Warning: can't open skinvalues.txt file\n");
			continue;
		}
		while((s = fgets(fh)))
		{
			// these two are handled by skinlist.qc
			if(substring(s, 0, 6) == "title ")
				bufstr_set(buf, i * SKINPARM_COUNT + SKINPARM_TITLE, substring(s, 6, strlen(s) - 6));
			else if(substring(s, 0, 7) == "author ")
				bufstr_set(buf, i * SKINPARM_COUNT + SKINPARM_AUTHOR, substring(s, 7, strlen(s) - 7));
		}
		fclose(fh);
	}

	search_end(glob);

	me.skinlist = buf;
	me.nItems = n;
}

void XonoticSkinList_destroy(entity me)
{
	buf_del(me.skinlist);
}

void XonoticSkinList_resizeNotify(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.itemAbsSize = '0 0 0';
	SUPER(XonoticSkinList).resizeNotify(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (me.itemAbsSize_y = (absSize_y * me.itemHeight));
	me.realFontSize_x = me.fontSize / (me.itemAbsSize_x = (absSize_x * (1 - me.controlWidth)));
	me.realUpperMargin1 = 0.5 * (1 - 2.5 * me.realFontSize_y);
	me.realUpperMargin2 = me.realUpperMargin1 + 1.5 * me.realFontSize_y;

	me.columnPreviewOrigin = 0;
	me.columnPreviewSize = me.itemAbsSize_y / me.itemAbsSize_x * 4 / 3;
	me.columnNameOrigin = me.columnPreviewOrigin + me.columnPreviewSize + me.realFontSize_x;
	me.columnNameSize = 1 - me.columnPreviewSize - 2 * me.realFontSize_x;
}

void XonoticSkinList_drawListBoxItem(entity me, float i, vector absSize, float isSelected)
{
	string s;
	
	if(isSelected)
		draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);
		
	s = me.skinParameter(me, i, SKINPARM_PREVIEW);
	draw_Picture(me.columnPreviewOrigin * eX, s, me.columnPreviewSize * eX + eY, '1 1 1', 1);
	
	s = me.skinParameter(me, i, SKINPARM_NAME);
	s = sprintf(_("%s: %s"), s, me.skinParameter(me, i, SKINPARM_TITLE));
	s = draw_TextShortenToWidth(s, me.columnNameSize, 0, me.realFontSize);
	draw_Text(me.realUpperMargin1 * eY + (me.columnNameOrigin + 0.00 * (me.columnNameSize - draw_TextWidth(s, 0, me.realFontSize))) * eX, s, me.realFontSize, SKINCOLOR_SKINLIST_TITLE, SKINALPHA_TEXT, 0);

	s = me.skinParameter(me, i, SKINPARM_AUTHOR);
	s = draw_TextShortenToWidth(s, me.columnNameSize, 0, me.realFontSize);
	draw_Text(me.realUpperMargin2 * eY + (me.columnNameOrigin + 1.00 * (me.columnNameSize - draw_TextWidth(s, 0, me.realFontSize))) * eX, s, me.realFontSize, SKINCOLOR_SKINLIST_AUTHOR, SKINALPHA_TEXT, 0);
}

void XonoticSkinList_setSkin(entity me)
{
	me.saveCvars(me);
	localcmd("\nmenu_restart\nmenu_cmd skinselect\n");
}

void SetSkin_Click(entity btn, entity me)
{
	me.setSkin(me);
}

void XonoticSkinList_clickListBoxItem(entity me, float i, vector where)
{
	if(i == me.lastClickedSkin)
		if(time < me.lastClickedTime + 0.3)
		{
			// DOUBLE CLICK!
			me.setSelected(me, i);
			me.setSkin(me);
		}
	me.lastClickedSkin = i;
	me.lastClickedTime = time;
}

float XonoticSkinList_keyDown(entity me, float scan, float ascii, float shift)
{
	if(scan == K_ENTER || scan == K_KP_ENTER) {
		me.setSkin(me);
		return 1;
	}
	else
		return SUPER(XonoticSkinList).keyDown(me, scan, ascii, shift);
}
#endif
