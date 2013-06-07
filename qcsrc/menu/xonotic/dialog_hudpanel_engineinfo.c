#ifdef INTERFACE
CLASS(XonoticHUDEngineInfoDialog) EXTENDS(XonoticRootDialog)
	METHOD(XonoticHUDEngineInfoDialog, fill, void(entity))
	ATTRIB(XonoticHUDEngineInfoDialog, title, string, _("Engine Info Panel"))
	ATTRIB(XonoticHUDEngineInfoDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(XonoticHUDEngineInfoDialog, intendedWidth, float, 0.4)
	ATTRIB(XonoticHUDEngineInfoDialog, rows, float, 15)
	ATTRIB(XonoticHUDEngineInfoDialog, columns, float, 4)
	ATTRIB(XonoticHUDEngineInfoDialog, name, string, "HUDengineinfo")
ENDCLASS(XonoticHUDEngineInfoDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticHUDEngineInfoDialog_fill(entity me)
{
	entity e;
	string panelname = "engineinfo";

	DIALOG_HUDPANEL_COMMON();

	me.TR(me);
		me.TD(me, 1, 4, e = makeXonoticTextLabel(0, _("Engine info:")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 3.8, e = makeXonoticCheckBox(0, "hud_panel_engineinfo_framecounter_exponentialmovingaverage", _("Use an averaging algorithm for fps")));
}
#endif
