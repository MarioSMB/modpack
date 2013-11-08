#ifdef INTERFACE
CLASS(XonoticHUDQuickMenuDialog) EXTENDS(XonoticRootDialog)
	METHOD(XonoticHUDQuickMenuDialog, fill, void(entity))
	ATTRIB(XonoticHUDQuickMenuDialog, title, string, _("Quick Menu Panel"))
	ATTRIB(XonoticHUDQuickMenuDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(XonoticHUDQuickMenuDialog, intendedWidth, float, 0.4)
	ATTRIB(XonoticHUDQuickMenuDialog, rows, float, 15)
	ATTRIB(XonoticHUDQuickMenuDialog, columns, float, 4)
	ATTRIB(XonoticHUDQuickMenuDialog, name, string, "HUDquickmenu")
ENDCLASS(XonoticHUDQuickMenuDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticHUDQuickMenuDialog_fill(entity me)
{
	entity e;
	string panelname = "quickmenu";

	DIALOG_HUDPANEL_COMMON_NOTOGGLE();

	me.TR(me);
		me.TD(me, 1, 4, e = makeXonoticTextLabel(0, _("Text alignment:")));
	me.TR(me);
		me.TDempty(me, 0.2);
			me.TD(me, 1, 3.8/3, e = makeXonoticRadioButton(3, "hud_panel_quickmenu_align", "0", _("Left")));
			me.TD(me, 1, 3.8/3, e = makeXonoticRadioButton(3, "hud_panel_quickmenu_align", "0.5", _("Center")));
			me.TD(me, 1, 3.8/3, e = makeXonoticRadioButton(3, "hud_panel_quickmenu_align", "1", _("Right")));
}
#endif
