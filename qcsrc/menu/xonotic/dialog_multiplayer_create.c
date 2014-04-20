#ifdef INTERFACE
CLASS(XonoticServerCreateTab) EXTENDS(XonoticTab)
	METHOD(XonoticServerCreateTab, fill, void(entity))
	METHOD(XonoticServerCreateTab, gameTypeChangeNotify, void(entity))
	ATTRIB(XonoticServerCreateTab, title, string, _("Create"))
	ATTRIB(XonoticServerCreateTab, intendedWidth, float, 0.9)
	ATTRIB(XonoticServerCreateTab, rows, float, 22)
	ATTRIB(XonoticServerCreateTab, columns, float, 6.2) // added extra .2 for center space

	ATTRIB(XonoticServerCreateTab, mapListBox, entity, NULL)
	ATTRIB(XonoticServerCreateTab, sliderFraglimit, entity, NULL)
	ATTRIB(XonoticServerCreateTab, sliderTimelimit, entity, NULL)
	ATTRIB(XonoticServerCreateTab, checkboxFraglimit, entity, NULL)
	ATTRIB(XonoticServerCreateTab, checkboxFraglimitMapinfo, entity, NULL)
ENDCLASS(XonoticServerCreateTab)
entity makeXonoticServerCreateTab();
#endif

#ifdef IMPLEMENTATION

entity makeXonoticServerCreateTab()
{
	entity me;
	me = spawnXonoticServerCreateTab();
	me.configureDialog(me);
	return me;
}

void XonoticServerCreateTab_fill(entity me)
{
	entity e, e0;

	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticTextLabel(0, _("Game type:")));
	me.TR(me);
		me.TD(me, 8, 3, e = makeXonoticGametypeList());
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
		//me.TD(me, 1, 3, e = makeXonoticTextLabel(0, _("Match settings:"))); // pointless, overcrowds the dialog imo
	me.TR(me);
		me.sliderTimelimit = makeXonoticSlider(1.0, 60.0, 1, "timelimit_override");
		me.TD(me, 1, 1, e = makeXonoticSliderCheckBox(0, 1, me.sliderTimelimit, _("Time limit:")));
		me.TD(me, 1, 2, me.sliderTimelimit);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticSliderCheckBox(-1, 0, me.sliderTimelimit, _("Use map specified default")));
	me.TR(me);
		me.sliderFraglimit = makeXonoticSlider(1.0, 2000.0, 5, "fraglimit_override");
		me.TD(me, 1, 1, e = makeXonoticSliderCheckBox(0, 1, me.sliderFraglimit, _("Point limit:")));
			me.checkboxFraglimit = e;
		me.TD(me, 1, 2, me.sliderFraglimit);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticSliderCheckBox(-1, 0, me.sliderFraglimit, _("Use map specified default")));
			me.checkboxFraglimitMapinfo = e;
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Player slots:")));
		me.TD(me, 1, 2, makeXonoticSlider(1, 32, 1, "menu_maxplayers"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Number of bots:")));
		me.TD(me, 1, 2, makeXonoticSlider(0, 9, 1, "bot_number"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Bot skill:")));
			setDependent(e, "bot_number", 0, -1);
		me.TD(me, 1, 2, e = makeXonoticTextSlider("skill"));
			e.addValue(e, _("Botlike"), "0");
			e.addValue(e, _("Beginner"), "1");
			e.addValue(e, _("You will win"), "2");
			e.addValue(e, _("You can win"), "3");
			e.addValue(e, _("You might win"), "4");
			e.addValue(e, _("Advanced"), "5");
			e.addValue(e, _("Expert"), "6");
			e.addValue(e, _("Pro"), "7");
			e.addValue(e, _("Assassin"), "8");
			e.addValue(e, _("Unhuman"), "9");
			e.addValue(e, _("Godlike"), "10");
			e.configureXonoticTextSliderValues(e);
			setDependent(e, "bot_number", 0, -1);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticButton(_("Mutators..."), '0 0 0'));
			e.onClick = DialogOpenButton_Click;
			e.onClickEntity = main.mutatorsDialog;
			main.mutatorsDialog.refilterEntity = me.mapListBox;
		me.TD(me, 1, 2, e0 = makeXonoticTextLabel(0, string_null));
			e0.textEntity = main.mutatorsDialog;
			e0.allowCut = 1;
	me.TR(me);
		me.TDempty(me, 0.5);
		me.TD(me, 1, 2, e = makeXonoticButton(_("Advanced settings..."), '0 0 0'));
			e.onClick = DialogOpenButton_Click;
			e.onClickEntity = main.advancedDialog;
			main.advancedDialog.refilterEntity = me.mapListBox;

	me.gotoRC(me, 0, 3.2); me.setFirstColumn(me, me.currentColumn);
		me.mapListBox = makeXonoticMapList();
		me.TD(me, 1, 3, e = makeXonoticTextLabel(0, _("Map list:")));
			makeCallback(e, me.mapListBox, me.mapListBox.refilterCallback);
	me.TR(me);
		me.TD(me, me.rows - 4, 3, me.mapListBox);
	me.gotoRC(me, me.rows - 3, 3.5);
		me.TDempty(me, 0.25);
		me.TD(me, 1, 1.125, e = makeXonoticButton(_("Select all"), '0 0 0'));
			e.onClick = MapList_All;
			e.onClickEntity = me.mapListBox;
		me.TD(me, 1, 1.125, e = makeXonoticButton(_("Select none"), '0 0 0'));
			e.onClick = MapList_None;
			e.onClickEntity = me.mapListBox;
		me.TDempty(me, 0.25);

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeXonoticButton(_("Start Multiplayer!"), '0 0 0'));
			e.onClick = MapList_LoadMap;
			e.onClickEntity = me.mapListBox;
			me.mapListBox.startButton = e;

	me.gameTypeChangeNotify(me);
}

void GameType_ConfigureSliders(entity e, entity l, entity l2, string pLabel, float pMin, float pMax, float pStep, string pCvar)
{
	if(pCvar == "")
	{
		e.configureXonoticSlider(e, pMin, pMax, pStep, string_null);
		l.setText(l, pLabel);
		e.disabled = l.disabled = l2.disabled = TRUE;
	}
	else
	{
		e.configureXonoticSlider(e, pMin, pMax, pStep, pCvar);
		l.setText(l, pLabel);
		e.disabled = l.disabled = l2.disabled = FALSE;
	}
}

void XonoticServerCreateTab_gameTypeChangeNotify(entity me)
{
	// tell the map list to update
	float gt;
	entity e, l, l2;
	gt = MapInfo_CurrentGametype();
	e = me.sliderFraglimit;
	l = me.checkboxFraglimit;
	l2 = me.checkboxFraglimitMapinfo;
	switch(gt)
	{
		case MAPINFO_TYPE_CTF:        GameType_ConfigureSliders(e, l, l2, _("Capture limit:"),   1,   20, 1, "capturelimit_override");     break;
		case MAPINFO_TYPE_DOMINATION: GameType_ConfigureSliders(e, l, l2, _("Point limit:"),    50,  500, 10, "g_domination_point_limit"); break;
		case MAPINFO_TYPE_KEYHUNT:    GameType_ConfigureSliders(e, l, l2, _("Point limit:"),   200, 1500, 50, "g_keyhunt_point_limit");    break;
		case MAPINFO_TYPE_LMS:        GameType_ConfigureSliders(e, l, l2, _("Lives:"),           3,   50,  1, "g_lms_lives_override");     break;
		case MAPINFO_TYPE_RACE:       GameType_ConfigureSliders(e, l, l2, _("Laps:"),            1,   25,  1, "g_race_laps_limit");        break;
		case MAPINFO_TYPE_NEXBALL:    GameType_ConfigureSliders(e, l, l2, _("Goals:"),           1,   50,  1, "g_nexball_goallimit");      break;
		case MAPINFO_TYPE_ASSAULT:    GameType_ConfigureSliders(e, l, l2, _("Point limit:"),    50,  500, 10, "");                         break;
		case MAPINFO_TYPE_ONSLAUGHT:  GameType_ConfigureSliders(e, l, l2, _("Point limit:"),    50,  500, 10, "");                         break;
		case MAPINFO_TYPE_CTS:        GameType_ConfigureSliders(e, l, l2, _("Point limit:"),    50,  500, 10, "");                         break;
		case MAPINFO_TYPE_INVASION:   GameType_ConfigureSliders(e, l, l2, _("Point limit:"),     5,    0,  5, "");                         break;
		default:                      GameType_ConfigureSliders(e, l, l2, _("Frag limit:"),      5,  100,  5, "fraglimit_override");       break;
	}
	me.mapListBox.refilter(me.mapListBox);
}

#endif
