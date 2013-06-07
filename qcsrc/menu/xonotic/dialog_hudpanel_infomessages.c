#ifdef INTERFACE
CLASS(XonoticHUDInfoMessagesDialog) EXTENDS(XonoticRootDialog)
	METHOD(XonoticHUDInfoMessagesDialog, fill, void(entity))
	ATTRIB(XonoticHUDInfoMessagesDialog, title, string, _("Info Messages Panel"))
	ATTRIB(XonoticHUDInfoMessagesDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(XonoticHUDInfoMessagesDialog, intendedWidth, float, 0.4)
	ATTRIB(XonoticHUDInfoMessagesDialog, rows, float, 15)
	ATTRIB(XonoticHUDInfoMessagesDialog, columns, float, 4)
	ATTRIB(XonoticHUDInfoMessagesDialog, name, string, "HUDinfomessages")
ENDCLASS(XonoticHUDInfoMessagesDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticHUDInfoMessagesDialog_fill(entity me)
{
	entity e;
	string panelname = "infomessages";

	DIALOG_HUDPANEL_COMMON();

	me.TR(me);
		me.TD(me, 1, 4, e = makeXonoticTextLabel(0, _("Info messages:")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 3.8, e = makeXonoticCheckBox(0, "hud_panel_infomessages_flip", _("Flip align")));
}
#endif
