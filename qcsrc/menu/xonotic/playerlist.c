#ifdef INTERFACE
CLASS(XonoticPlayerList) EXTENDS(XonoticListBox)
	ATTRIB(XonoticPlayerList, rowsPerItem, float, 1)
	METHOD(XonoticPlayerList, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(XonoticPlayerList, drawListBoxItem, void(entity, float, vector, float))
	ATTRIB(XonoticPlayerList, realFontSize, vector, '0 0 0')
	ATTRIB(XonoticPlayerList, columnNameOrigin, float, 0)
	ATTRIB(XonoticPlayerList, columnNameSize, float, 0)
	ATTRIB(XonoticPlayerList, columnScoreOrigin, float, 0)
	ATTRIB(XonoticPlayerList, columnScoreSize, float, 0)
	ATTRIB(XonoticPlayerList, realUpperMargin, float, 0)
	ATTRIB(XonoticPlayerList, origin, vector, '0 0 0')
	ATTRIB(XonoticPlayerList, itemAbsSize, vector, '0 0 0')
	METHOD(XonoticPlayerList, setPlayerList, void(entity, string))
	METHOD(XonoticPlayerList, getPlayerList, string(entity, float, float))
	ATTRIB(XonoticPlayerList, playerList, float, -1)
ENDCLASS(XonoticPlayerList)
entity makeXonoticPlayerList();
#endif

#ifdef IMPLEMENTATION

#define PLAYERPARM_SCORE 0
#define PLAYERPARM_PING 1
#define PLAYERPARM_TEAM 2
#define PLAYERPARM_NAME 3
#define PLAYERPARM_COUNT 4

entity makeXonoticPlayerList()
{
	entity me;
	me = spawnXonoticPlayerList();
	me.configureXonoticListBox(me);
	return me;
}

void XonoticPlayerList_setPlayerList(entity me, string plist)
{
	float buf,i,n;
	string s;

	buf = buf_create();
	me.nItems = tokenizebyseparator(plist, "\n");
	for(i = 0; i < me.nItems; ++i)
	{
		bufstr_set(buf, i * PLAYERPARM_COUNT + PLAYERPARM_NAME, argv(i)); // -666 100 "^4Nex ^2Player"
	}

	for(i = 0; i < me.nItems; ++i)
	{
		s = bufstr_get(buf, i * PLAYERPARM_COUNT + PLAYERPARM_NAME);
		n = tokenize_console(s);

		if(n == 4)
		{
			bufstr_set(buf, i * PLAYERPARM_COUNT + PLAYERPARM_SCORE, argv(0)); // -666
			bufstr_set(buf, i * PLAYERPARM_COUNT + PLAYERPARM_PING,  argv(1)); // 100
			bufstr_set(buf, i * PLAYERPARM_COUNT + PLAYERPARM_TEAM,  argv(2)); // 0 for spec, else 1, 2, 3, 4
			bufstr_set(buf, i * PLAYERPARM_COUNT + PLAYERPARM_NAME,  argv(3)); // ^4Nex ^2Player
		}
		else
		{
			bufstr_set(buf, i * PLAYERPARM_COUNT + PLAYERPARM_SCORE, argv(0)); // -666
			bufstr_set(buf, i * PLAYERPARM_COUNT + PLAYERPARM_PING,  argv(1)); // 100
			bufstr_set(buf, i * PLAYERPARM_COUNT + PLAYERPARM_TEAM,  "-1");
			bufstr_set(buf, i * PLAYERPARM_COUNT + PLAYERPARM_NAME,  argv(2)); // ^4Nex ^2Player
		}
	}
	me.playerList = buf;
}

string XonoticPlayerList_getPlayerList(entity me, float i, float key)
{
	return bufstr_get(me.playerList, i * PLAYERPARM_COUNT + key);
}

void XonoticPlayerList_resizeNotify(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.itemAbsSize = '0 0 0';
	SUPER(XonoticPlayerList).resizeNotify(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (me.itemAbsSize_y = (absSize_y * me.itemHeight));
	me.realFontSize_x = me.fontSize / (me.itemAbsSize_x = (absSize_x * (1 - me.controlWidth)));
	me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);

	// this list does 1 char left and right margin
	me.columnScoreSize = 5 * me.realFontSize_x;
	me.columnNameSize = 1 - 3 * me.realFontSize_x - me.columnScoreSize;

	me.columnNameOrigin = me.realFontSize_x;
	me.columnScoreOrigin = me.columnNameOrigin + me.columnNameSize + me.realFontSize_x;
}

void XonoticPlayerList_drawListBoxItem(entity me, float i, vector absSize, float isSelected)
{
	string s;
	string score;
	float t;
	vector rgb;

	t = stof(me.getPlayerList(me, i, PLAYERPARM_TEAM));
	if(t == 1)
		rgb = colormapPaletteColor(4, 0);
	else if(t == 2)
		rgb = colormapPaletteColor(13, 0);
	else if(t == 3)
		rgb = colormapPaletteColor(12, 0);
	else if(t == 4)
		rgb = colormapPaletteColor(9, 0);
	else
		rgb = '1 1 1';
	
	s = me.getPlayerList(me, i, PLAYERPARM_NAME);
	score = me.getPlayerList(me, i, PLAYERPARM_SCORE);

	if(substring(score, strlen(score) - 10, 10) == ":spectator")
	{
		score = _("spectator");
	}
	else
	{
		if((t = strstrofs(score, ":", 0)) >= 0)
			score = substring(score, 0, t);
		if((t = strstrofs(score, ",", 0)) >= 0)
			score = substring(score, 0, t);
			
		if(stof(score) == -666)
			score = _("spectator");
	}

	s = draw_TextShortenToWidth(s, me.columnNameSize, 1, me.realFontSize);
	score = draw_TextShortenToWidth(score, me.columnScoreSize, 0, me.realFontSize);

	draw_Text(me.realUpperMargin2 * eY + (me.columnNameOrigin + 0.00 * (me.columnNameSize - draw_TextWidth(s, 1, me.realFontSize))) * eX, s, me.realFontSize, '1 1 1', 1, 1);
	draw_Text(me.realUpperMargin2 * eY + (me.columnScoreOrigin + 1.00 * (me.columnScoreSize - draw_TextWidth(score, 1, me.realFontSize))) * eX, score, me.realFontSize, rgb, 1, 0);
}

#endif
