#ifdef INTERFACE
CLASS(XonoticHUDPressedKeysDialog) EXTENDS(XonoticRootDialog)
	METHOD(XonoticHUDPressedKeysDialog, fill, void(entity))
	ATTRIB(XonoticHUDPressedKeysDialog, title, string, _("Pressed Keys Panel"))
	ATTRIB(XonoticHUDPressedKeysDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(XonoticHUDPressedKeysDialog, intendedWidth, float, 0.4)
	ATTRIB(XonoticHUDPressedKeysDialog, rows, float, 15)
	ATTRIB(XonoticHUDPressedKeysDialog, columns, float, 4)
	ATTRIB(XonoticHUDPressedKeysDialog, name, string, "HUDpressedkeys")
ENDCLASS(XonoticHUDPressedKeysDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticHUDPressedKeysDialog_fill(entity me)
{
	entity e;
	string panelname = "pressedkeys";

	me.TR(me);
		me.TD(me, 1, 4, e = makeXonoticTextSlider("hud_panel_pressedkeys"));
			e.addValue(e, _("Panel disabled"), "0");
			e.addValue(e, _("Panel enabled when spectating"), "1");
			e.addValue(e, _("Panel always enabled"), "2");
			e.configureXonoticTextSliderValues(e);

	DIALOG_HUDPANEL_COMMON_NOTOGGLE();

	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Forced aspect:")));
			me.TD(me, 1, 2.6, e = makeXonoticSlider(0.2, 4, 0.1, "hud_panel_pressedkeys_aspect"));
}
#endif
