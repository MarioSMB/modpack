#ifdef INTERFACE
CLASS(XonoticHUDNotificationDialog) EXTENDS(XonoticRootDialog)
	METHOD(XonoticHUDNotificationDialog, fill, void(entity))
	ATTRIB(XonoticHUDNotificationDialog, title, string, _("Notification Panel"))
	ATTRIB(XonoticHUDNotificationDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(XonoticHUDNotificationDialog, intendedWidth, float, 0.4)
	ATTRIB(XonoticHUDNotificationDialog, rows, float, 15)
	ATTRIB(XonoticHUDNotificationDialog, columns, float, 4)
	ATTRIB(XonoticHUDNotificationDialog, name, string, "HUDnotify")
ENDCLASS(XonoticHUDNotificationDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticHUDNotificationDialog_fill(entity me)
{
	entity e;
	string panelname = "notify";

	DIALOG_HUDPANEL_COMMON();

	me.TR(me);
		me.TD(me, 1, 4, e = makeXonoticTextLabel(0, _("Notifications:")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 3.8, e = makeXonoticCheckBox(0, "hud_panel_notify_print", _("Also print notifications to the console")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 3.8, e = makeXonoticCheckBox(0, "hud_panel_notify_flip", _("Flip notify order")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Entry lifetime:")));
			me.TD(me, 1, 2.6, e = makeXonoticSlider(3, 15, 1, "hud_panel_notify_time"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Entry fadetime:")));
			me.TD(me, 1, 2.6, e = makeXonoticSlider(0.5, 5, 0.5, "hud_panel_notify_fadetime"));
}
#endif
