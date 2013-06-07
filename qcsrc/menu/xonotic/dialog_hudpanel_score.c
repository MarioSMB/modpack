#ifdef INTERFACE
CLASS(XonoticHUDScoreDialog) EXTENDS(XonoticRootDialog)
	METHOD(XonoticHUDScoreDialog, fill, void(entity))
	ATTRIB(XonoticHUDScoreDialog, title, string, _("Score Panel"))
	ATTRIB(XonoticHUDScoreDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(XonoticHUDScoreDialog, intendedWidth, float, 0.4)
	ATTRIB(XonoticHUDScoreDialog, rows, float, 15)
	ATTRIB(XonoticHUDScoreDialog, columns, float, 4)
	ATTRIB(XonoticHUDScoreDialog, name, string, "HUDscore")
ENDCLASS(XonoticHUDScoreDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticHUDScoreDialog_fill(entity me)
{
	entity e;
	string panelname = "score";

	DIALOG_HUDPANEL_COMMON();

	me.TR(me);
		me.TD(me, 1, 4, e = makeXonoticTextLabel(0, _("Score:")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Rankings:")));
		me.TD(me, 1, 2.6/3, e = makeXonoticRadioButton(1, "hud_panel_score_rankings", "0", _("Off")));
		me.TD(me, 1, 2.6/3, e = makeXonoticRadioButton(1, "hud_panel_score_rankings", "1", _("And me")));
		me.TD(me, 1, 2.6/3, e = makeXonoticRadioButton(1, "hud_panel_score_rankings", "2", _("Pure")));
}
#endif
