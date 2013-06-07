#ifdef INTERFACE
CLASS(XonoticDemoList) EXTENDS(XonoticListBox)
	METHOD(XonoticDemoList, configureXonoticDemoList, void(entity))
	ATTRIB(XonoticDemoList, rowsPerItem, float, 1)
	METHOD(XonoticDemoList, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(XonoticDemoList, drawListBoxItem, void(entity, float, vector, float))
	METHOD(XonoticDemoList, getDemos, void(entity))
	METHOD(XonoticDemoList, startDemo, void(entity))	
	METHOD(XonoticDemoList, demoName, string(entity, float))
	METHOD(XonoticDemoList, clickListBoxItem, void(entity, float, vector))
	METHOD(XonoticDemoList, keyDown, float(entity, float, float, float))
	METHOD(XonoticDemoList, destroy, void(entity))
	METHOD(XonoticDemoList, showNotify, void(entity))
	
	ATTRIB(XonoticDemoList, listDemo, float, -1)
	ATTRIB(XonoticDemoList, realFontSize, vector, '0 0 0')
	ATTRIB(XonoticDemoList, columnNameOrigin, float, 0)
	ATTRIB(XonoticDemoList, columnNameSize, float, 0)
	ATTRIB(XonoticDemoList, realUpperMargin, float, 0)
	ATTRIB(XonoticDemoList, origin, vector, '0 0 0')
	ATTRIB(XonoticDemoList, itemAbsSize, vector, '0 0 0')
	
	ATTRIB(XonoticDemoList, lastClickedDemo, float, -1)
	ATTRIB(XonoticDemoList, lastClickedTime, float, 0)
	ATTRIB(XonoticDemoList, filterString, string, string_null)	
ENDCLASS(XonoticDemoList)

entity makeXonoticDemoList();
void StartDemo_Click(entity btn, entity me);
void TimeDemo_Click(entity btn, entity me);
void DemoList_Filter_Change(entity box, entity me);
#endif

#ifdef IMPLEMENTATION

entity makeXonoticDemoList()
{
	entity me;
	me = spawnXonoticDemoList();
	me.configureXonoticDemoList(me);
	return me;
}

void XonoticDemoList_configureXonoticDemoList(entity me)
{
	me.configureXonoticListBox(me);
	me.getDemos(me);	
}

string XonoticDemoList_demoName(entity me, float i )
{
	string s;
	s = search_getfilename(me.listDemo, i);
	s = substring(s, 6, strlen(s) - 6 - 4);  // demos/, .dem
	return s;
}


void XonoticDemoList_getDemos(entity me)
{
	string s;
	
	if(me.filterString)
		//subdirectory in filterString allowed	
		s=strcat("demos/*", me.filterString, "*.dem");		
	else
		s="demos/*.dem";
	
	//dprint("Search demos with the pattern ", s, "\n");	
	if(me.listDemo >= 0)
		search_end(me.listDemo);
		
	me.listDemo = search_begin(s, FALSE, TRUE);

	if(me.listDemo < 0)
		me.nItems=0;
	else
		me.nItems=search_getsize(me.listDemo);				
}

void XonoticDemoList_destroy(entity me)
{
	search_end(me.listDemo);
}

void XonoticDemoList_resizeNotify(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.itemAbsSize = '0 0 0';
	SUPER(XonoticDemoList).resizeNotify(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (me.itemAbsSize_y = (absSize_y * me.itemHeight));
	me.realFontSize_x = me.fontSize / (me.itemAbsSize_x = (absSize_x * (1 - me.controlWidth)));
	me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);

	me.columnNameOrigin = me.realFontSize_x;
	me.columnNameSize = 1 - 2 * me.realFontSize_x;
}

void XonoticDemoList_drawListBoxItem(entity me, float i, vector absSize, float isSelected)
{
	string s;
	if(isSelected)
		draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);
		
	s = me.demoName(me,i);
	s = draw_TextShortenToWidth(s, me.columnNameSize, 0, me.realFontSize);
	draw_Text(me.realUpperMargin * eY + (me.columnNameOrigin + 0.00 * (me.columnNameSize - draw_TextWidth(s, 0, me.realFontSize))) * eX, s, me.realFontSize, '1 1 1', SKINALPHA_TEXT, 0);		
}

void XonoticDemoList_showNotify(entity me)
{
	me.getDemos(me);
}

void DemoList_Filter_Change(entity box, entity me)
{	
	if(me.filterString)
		strunzone(me.filterString);
	
	if(box.text != "")
		me.filterString = strzone(box.text);
	else
		me.filterString = string_null;
		
	me.getDemos(me);
}

void XonoticDemoList_startDemo(entity me)
{
	string s;
	s = me.demoName(me,me.selectedItem);
	localcmd("playdemo \"demos/", s, ".dem\" \nwait \ntogglemenu\n");	
}

void StartDemo_Click(entity btn, entity me)
{
	me.startDemo(me);
}

void TimeDemo_Click(entity btn, entity me)
{
	string s;
	s = me.demoName(me,me.selectedItem);
	localcmd("timedemo \"demos/", s, ".dem\" \nwait \ntogglemenu\n");	
}

void XonoticDemoList_clickListBoxItem(entity me, float i, vector where)
{
	if(i == me.lastClickedDemo)
		if(time < me.lastClickedTime + 0.3)
		{
			// DOUBLE CLICK!
			me.setSelected(me, i);
			me.startDemo(me);
		}
	me.lastClickedDemo = i;
	me.lastClickedTime = time;
}

float XonoticDemoList_keyDown(entity me, float scan, float ascii, float shift)
{
	if(scan == K_ENTER || scan == K_KP_ENTER) {
		me.startDemo(me);
		return 1;
	}
	else
		return SUPER(XonoticDemoList).keyDown(me, scan, ascii, shift);
}
#endif

