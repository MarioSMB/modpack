#ifdef INTERFACE
CLASS(XonoticHUDTimerDialog) EXTENDS(XonoticRootDialog)
	METHOD(XonoticHUDTimerDialog, fill, void(entity))
	ATTRIB(XonoticHUDTimerDialog, title, string, _("Timer Panel"))
	ATTRIB(XonoticHUDTimerDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(XonoticHUDTimerDialog, intendedWidth, float, 0.4)
	ATTRIB(XonoticHUDTimerDialog, rows, float, 15)
	ATTRIB(XonoticHUDTimerDialog, columns, float, 4)
	ATTRIB(XonoticHUDTimerDialog, name, string, "HUDtimer")
ENDCLASS(XonoticHUDTimerDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticHUDTimerDialog_fill(entity me)
{
	entity e;
	string panelname = "timer";

	DIALOG_HUDPANEL_COMMON();

	me.TR(me);
		me.TD(me, 1, 4, e = makeXonoticTextLabel(0, _("Timer:")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 3.8, e = makeXonoticCheckBox(0, "hud_panel_timer_increment", _("Show elapsed time")));
}
#endif
