#ifdef INTERFACE
CLASS(XonoticAdvancedDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticAdvancedDialog, fill, void(entity))
	METHOD(XonoticAdvancedDialog, showNotify, void(entity))
	METHOD(XonoticAdvancedDialog, close, void(entity))
	ATTRIB(XonoticAdvancedDialog, title, string, _("Advanced server settings"))
	ATTRIB(XonoticAdvancedDialog, color, vector, SKINCOLOR_DIALOG_ADVANCED)
	ATTRIB(XonoticAdvancedDialog, intendedWidth, float, 0.5)
	ATTRIB(XonoticAdvancedDialog, rows, float, 17)
	ATTRIB(XonoticAdvancedDialog, columns, float, 3)
	ATTRIB(XonoticAdvancedDialog, refilterEntity, entity, NULL)
ENDCLASS(XonoticAdvancedDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticAdvancedDialog_showNotify(entity me)
{
	loadAllCvars(me);
}

void XonoticAdvancedDialog_fill(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, 1, 3, makeXonoticTextLabel(0, _("Game settings:")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, makeXonoticCheckBox(0, "sv_spectate", _("Allow spectating")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, makeXonoticTextLabel(0, _("Spawn shield:")));
		me.TD(me, 1, 1.6, makeXonoticSlider(0, 15, 0.5, "g_spawnshieldtime"));
	me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, makeXonoticTextLabel(0, _("Game speed:")));
		me.TD(me, 1, 1.6, makeXonoticSlider(0.5, 2.0, 0.1, "slowmo"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 3, makeXonoticTextLabel(0, _("Teamplay settings:")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, makeXonoticTextLabel(0, _("Friendly fire scale:")));
		me.TD(me, 1, 1.6, makeXonoticSlider(0, 1.0, 0.05, "g_friendlyfire"));
	me.TR(me);
		me.TDempty(me, 0.4);
		me.TD(me, 1, 2.6, makeXonoticCheckBox(0, "g_friendlyfire_virtual", _("Virtual friendly fire (effect only)")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, makeXonoticTextLabel(0, _("Friendly fire penalty:")));
		me.TD(me, 1, 1.6, makeXonoticSlider(0, 1.0, 0.05, "g_mirrordamage"));
	me.TR(me);
		me.TDempty(me, 0.4);
		me.TD(me, 1, 2.6, makeXonoticCheckBox(0, "g_mirrordamage_virtual", _("Virtual penalty (effect only)")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, makeXonoticTextLabel(0, _("Teams:")));
		me.TD(me, 1, 1.6, e = makeXonoticTextSlider("g_tdm_teams_override g_domination_teams_override g_ca_teams_override g_freezetag_teams_override g_keyhunt_teams_override"));
			e.addValue(e, "Default", "0");
			e.addValue(e, "2 teams", "2");
			e.addValue(e, "3 teams", "3");
			e.addValue(e, "4 teams", "4");
			e.configureXonoticTextSliderValues(e);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, makeXonoticTextLabel(0, _("Map voting:")));
		me.TD(me, 1, 2, e = makeXonoticTextSlider("g_maplist_votable"));
			e.addValue(e, _("No voting"), "0");
			e.addValue(e, _("2 choices"), "2");
			e.addValue(e, _("3 choices"), "3");
			e.addValue(e, _("4 choices"), "4");
			e.addValue(e, _("5 choices"), "5");
			e.addValue(e, _("6 choices"), "6");
			e.addValue(e, _("7 choices"), "7");
			e.addValue(e, _("8 choices"), "8");
			e.addValue(e, _("9 choices"), "9");
			e.configureXonoticTextSliderValues(e);
	me.TR(me);
		me.TD(me, 1, 3, makeXonoticCheckBoxEx(0.5, 0, "sv_vote_simple_majority_factor", _("Simple majority wins vcall")));

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeXonoticButton(_("OK"), '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}

void XonoticAdvancedDialog_close(entity me)
{
	if(me.refilterEntity)
		me.refilterEntity.refilter(me.refilterEntity);
	SUPER(XonoticAdvancedDialog).close(me);
}
#endif
