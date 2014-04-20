#ifdef INTERFACE
CLASS(XonoticSingleplayerDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticSingleplayerDialog, fill, void(entity))
	ATTRIB(XonoticSingleplayerDialog, title, string, _("Singleplayer"))
	ATTRIB(XonoticSingleplayerDialog, color, vector, SKINCOLOR_DIALOG_SINGLEPLAYER)
	ATTRIB(XonoticSingleplayerDialog, intendedWidth, float, 0.80)
	ATTRIB(XonoticSingleplayerDialog, rows, float, 24)
	ATTRIB(XonoticSingleplayerDialog, columns, float, 5)
	ATTRIB(XonoticSingleplayerDialog, campaignBox, entity, NULL)
ENDCLASS(XonoticSingleplayerDialog)
#endif

#ifdef IMPLEMENTATION

void InstantAction_LoadMap(entity btn, entity dummy)
{
	float pmin = 2, pmax = 16, pstep = 1;

	cvar_set("timelimit_override", "10");
	cvar_set("g_lms_lives_override", "9");

	if(random() < 0.4) // 40% are DM
	{
		MapInfo_SwitchGameType(MAPINFO_TYPE_DEATHMATCH);
		pmin = 2;
		pmax = 8;
		pstep = 1;
	}
	else if(random() < 0.5) // half of the remaining 60%, i.e. 30%, are CTF
	{
		MapInfo_SwitchGameType(MAPINFO_TYPE_CTF);
		pmin = 4;
		pmax = 12;
		pstep = 2;
	}
	else if(random() < 0.5) // half of the remaining 30%, i.e. 15%, are TDM
	{
		MapInfo_SwitchGameType(MAPINFO_TYPE_TEAM_DEATHMATCH);
		pmin = 4;
		pmax = 8;
		pstep = 2;
	}
	else if(random() < 0.666) // 2/3 of the remaining 15%, i.e. 10%, are KH
	{
		MapInfo_SwitchGameType(MAPINFO_TYPE_KEYHUNT);
		pmin = 6;
		pmax = 6;
		pstep = 6; // works both for 2 and 3 teams
		// TODO find team count of map, set pstep=2 or 3, and use 2v2(v2) games at least
	}
	else // somehow distribute the remaining 5%
	{
		float r;
		r = floor(random() * 4);
		switch(r)
		{
			default:
			case 0:
				MapInfo_SwitchGameType(MAPINFO_TYPE_LMS);
				pmin = 2;
				pmax = 6;
				pstep = 1;
				cvar_set("timelimit_override", "-1");
				break;
			case 1:
				MapInfo_SwitchGameType(MAPINFO_TYPE_DOMINATION);
				pmin = 2;
				pmax = 8;
				pstep = 2;
				break;
			case 2:
				MapInfo_SwitchGameType(MAPINFO_TYPE_ONSLAUGHT);
				pmin = 6;
				pmax = 16;
				pstep = 2;
				break;
			case 3:
				MapInfo_SwitchGameType(MAPINFO_TYPE_ASSAULT);
				pmin = 4;
				pmax = 16;
				pstep = 2;
				break;
			// CA, Freezetag: bot AI does not work, add them once it does
		}
	}

	// find random map
	MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 0);
	string s;
	do
	{
		float m;
		m = floor(random() * MapInfo_count);
		s = MapInfo_BSPName_ByID(m);
	}
	while(!fexists(sprintf("maps/%s.waypoints", s)));
	MapInfo_LoadMap(s, 1);

	// configure bots
	float p;
	pmin = pstep * ceil(pmin / pstep);
	pmax = pstep * floor(pmax / pstep);
	p = pmin + pstep * floor(random() * ((pmax - pmin) / pstep + 1));
	cvar_set("bot_number", ftos(p - 1));

	// make sure we go back to menu
	cvar_set("lastlevel", "1");
}

void XonoticSingleplayerDialog_fill(entity me)
{
	entity e, btnPrev, btnNext, lblTitle;

	me.TR(me);
		me.TDempty(me, (me.columns - 3) / 2);
		me.TD(me, 2, 3, e = makeXonoticBigButton(_("Instant action! (random map with bots)"), '0 0 0'));
			e.onClick = InstantAction_LoadMap;
			e.onClickEntity = NULL;
	me.TR(me);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, btnPrev = makeXonoticButton("<<", '0 0 0'));
		me.TD(me, 1, me.columns - 2, lblTitle = makeXonoticTextLabel(0.5, _("???")));
		me.TD(me, 1, 1, btnNext = makeXonoticButton(">>", '0 0 0'));
	me.TR(me);
		me.TD(me, me.rows - 6, me.columns, me.campaignBox = makeXonoticCampaignList());
			btnPrev.onClick = MultiCampaign_Prev;
			btnPrev.onClickEntity = me.campaignBox;
			btnNext.onClick = MultiCampaign_Next;
			btnNext.onClickEntity = me.campaignBox;
			me.campaignBox.buttonNext = btnNext;
			me.campaignBox.buttonPrev = btnPrev;
			me.campaignBox.labelTitle = lblTitle;
			me.campaignBox.campaignGo(me.campaignBox, 0);

	me.gotoRC(me, me.rows - 2, 0);
		me.TD(me, 1, 2, e = makeXonoticTextLabel(0.5, _("Campaign Difficulty:")));
		me.TD(me, 1, 1, e = makeXonoticRadioButton(1, "g_campaign_skill", "-2", ZCTX(_("CSKL^Easy"))));
		me.TD(me, 1, 1, e = makeXonoticRadioButton(1, "g_campaign_skill", "-1", ZCTX(_("CSKL^Medium"))));
		me.TD(me, 1, 1, e = makeXonoticRadioButton(1, "g_campaign_skill", "0", ZCTX(_("CSKL^Hard"))));
		me.TR(me);
		me.TD(me, 1, me.columns, e = makeXonoticButton(_("Start Singleplayer!"), '0 0 0'));
			e.onClick = CampaignList_LoadMap;
			e.onClickEntity = me.campaignBox;
}
#endif
