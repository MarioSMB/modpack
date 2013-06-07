#ifdef INTERFACE
CLASS(XonoticLanguageList) EXTENDS(XonoticListBox)
	METHOD(XonoticLanguageList, configureXonoticLanguageList, void(entity))
	ATTRIB(XonoticLanguageList, rowsPerItem, float, 1)
	METHOD(XonoticLanguageList, drawListBoxItem, void(entity, float, vector, float))
	METHOD(XonoticLanguageList, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(XonoticLanguageList, setSelected, void(entity, float))
	METHOD(XonoticLanguageList, loadCvars, void(entity))
	METHOD(XonoticLanguageList, saveCvars, void(entity))

	ATTRIB(XonoticLanguageList, realFontSize, vector, '0 0 0')
	ATTRIB(XonoticLanguageList, realUpperMargin, float, 0)
	ATTRIB(XonoticLanguageList, columnNameOrigin, float, 0)
	ATTRIB(XonoticLanguageList, columnNameSize, float, 0)

	METHOD(XonoticLanguageList, clickListBoxItem, void(entity, float, vector)) // double click handling
	METHOD(XonoticLanguageList, keyDown, float(entity, float, float, float)) // enter handling
	ATTRIB(XonoticLanguageList, lastClickedLanguage, float, -1)
	ATTRIB(XonoticLanguageList, lastClickedTime, float, 0)

	METHOD(XonoticLanguageList, destroy, void(entity))

	ATTRIB(XonoticLanguageList, languagelist, float, -1)
	METHOD(XonoticLanguageList, getLanguages, void(entity))
	METHOD(XonoticLanguageList, setLanguage, void(entity))
	METHOD(XonoticLanguageList, languageParameter, string(entity, float, float))

	ATTRIB(XonoticLanguageList, name, string, "languageselector") // change this to make it noninteractive (for first run dialog)

	ATTRIB(XonoticLanguageList, doubleClickCommand, string, "prvm_language \"$_menu_prvm_language\"\nmenu_restart\nmenu_cmd languageselect")
ENDCLASS(XonoticLanguageList)

entity makeXonoticLanguageList();
void SetLanguage_Click(entity btn, entity me);
#endif

#ifdef IMPLEMENTATION

#define LANGPARM_ID 0
#define LANGPARM_NAME 1
#define LANGPARM_NAME_LOCALIZED 2
#define LANGPARM_COUNT 3

entity makeXonoticLanguageList()
{
	entity me;
	me = spawnXonoticLanguageList();
	me.configureXonoticLanguageList(me);
	return me;
}

void XonoticLanguageList_configureXonoticLanguageList(entity me)
{
	me.configureXonoticListBox(me);
	me.getLanguages(me);
	me.loadCvars(me);
}

void XonoticLanguageList_drawListBoxItem(entity me, float i, vector absSize, float isSelected)
{
	string s;
	if(isSelected)
		draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);
	s = me.languageParameter(me, i, LANGPARM_NAME_LOCALIZED);
	draw_Text(me.realUpperMargin * eY + (me.columnNameOrigin + (me.columnNameSize - draw_TextWidth(s, 0, me.realFontSize)) * 0.5) * eX, s, me.realFontSize, '1 1 1', SKINALPHA_TEXT, 0);
}

void XonoticLanguageList_resizeNotify(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	SUPER(XonoticLanguageList).resizeNotify(me, relOrigin, relSize, absOrigin, absSize);
	me.realFontSize_y = me.fontSize / (absSize_y * me.itemHeight);
	me.realFontSize_x = me.fontSize / (absSize_x * (1 - me.controlWidth));
	me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);
	me.columnNameOrigin = 0;
	me.columnNameSize = 1;
}

void XonoticLanguageList_setSelected(entity me, float i)
{
	SUPER(XonoticLanguageList).setSelected(me, i);
	me.saveCvars(me);
}

void XonoticLanguageList_loadCvars(entity me)
{
	string s;
	float i, n;
	s = cvar_string("_menu_prvm_language");
	n = me.nItems;

	// default to English
	for(i = 0; i < n; ++i)
	{
		if(me.languageParameter(me, i, LANGPARM_ID) == "en")
		{
			me.selectedItem = i;
			break;
		}
	}

        // otherwise, find the language
	for(i = 0; i < n; ++i)
	{
		if(me.languageParameter(me, i, LANGPARM_ID) == s)
		{
			me.selectedItem = i;
			break;
		}
	}

	// save it off (turning anything unknown into "en")
	me.saveCvars(me);
}

void XonoticLanguageList_saveCvars(entity me)
{
	cvar_set("_menu_prvm_language", me.languageParameter(me, me.selectedItem, LANGPARM_ID));
}

void XonoticLanguageList_clickListBoxItem(entity me, float i, vector where)
{
	if(i == me.lastClickedLanguage)
		if(time < me.lastClickedTime + 0.3)
		{
			// DOUBLE CLICK!
			me.setSelected(me, i);
			me.setLanguage(me);
		}
	me.lastClickedLanguage = i;
	me.lastClickedTime = time;
}

float XonoticLanguageList_keyDown(entity me, float scan, float ascii, float shift)
{
	if(scan == K_ENTER || scan == K_KP_ENTER) {
		me.setLanguage(me);
		return 1;
	}
	else
		return SUPER(XonoticLanguageList).keyDown(me, scan, ascii, shift);
}

void XonoticLanguageList_destroy(entity me)
{
	buf_del(me.languagelist);
}

void XonoticLanguageList_getLanguages(entity me)
{
	float buf, i, n, fh;
	string s;

	buf = buf_create();

	fh = fopen("languages.txt", FILE_READ);
	i = 0;
	while((s = fgets(fh)))
	{
		n = tokenize_console(s);
		if(n < 3)
			continue;
		bufstr_set(buf, i * LANGPARM_COUNT + LANGPARM_ID, argv(0));
		bufstr_set(buf, i * LANGPARM_COUNT + LANGPARM_NAME, argv(1));
		bufstr_set(buf, i * LANGPARM_COUNT + LANGPARM_NAME_LOCALIZED, argv(2));
		++i;
	}
	fclose(fh);

	me.languagelist = buf;
	me.nItems = i;
}

void XonoticLanguageList_setLanguage(entity me)
{
	localcmd(sprintf("\n%s\n", me.doubleClickCommand));
}

string XonoticLanguageList_languageParameter(entity me, float i, float key)
{
	return bufstr_get(me.languagelist, i * LANGPARM_COUNT + key);
}

void SetLanguage_Click(entity btn, entity me)
{
	me.setLanguage(me);
}

#endif
