#ifdef INTERFACE
CLASS(XonoticHUDHealthArmorDialog) EXTENDS(XonoticRootDialog)
	METHOD(XonoticHUDHealthArmorDialog, fill, void(entity))
	ATTRIB(XonoticHUDHealthArmorDialog, title, string, _("Health/Armor Panel"))
	ATTRIB(XonoticHUDHealthArmorDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(XonoticHUDHealthArmorDialog, intendedWidth, float, 0.4)
	ATTRIB(XonoticHUDHealthArmorDialog, rows, float, 15)
	ATTRIB(XonoticHUDHealthArmorDialog, columns, float, 4)
	ATTRIB(XonoticHUDHealthArmorDialog, name, string, "HUDhealtharmor")
ENDCLASS(XonoticHUDHealthArmorDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticHUDHealthArmorDialog_fill(entity me)
{
	entity e;
	string panelname = "healtharmor";

	DIALOG_HUDPANEL_COMMON();

	me.TR(me);
		me.TD(me, 1, 4, e = makeXonoticCheckBox(0, "hud_panel_healtharmor_progressbar", _("Enable status bar")));
	me.TR(me);
		me.TD(me, 1, 4, e = makeXonoticTextLabel(0, _("Status bar alignment:")));
			setDependent(e, "hud_panel_healtharmor_progressbar", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
			me.TD(me, 1, 0.95, e = makeXonoticRadioButton(2, "hud_panel_healtharmor_baralign", "0", _("Left")));
			setDependent(e, "hud_panel_healtharmor_progressbar", 1, 1);
			me.TD(me, 1, 0.95, e = makeXonoticRadioButton(2, "hud_panel_healtharmor_baralign", "1", _("Right")));
			setDependent(e, "hud_panel_healtharmor_progressbar", 1, 1);
			me.TD(me, 1, 0.95, e = makeXonoticRadioButton(2, "hud_panel_healtharmor_baralign", "2", _("Inward")));
			setDependent(e, "hud_panel_healtharmor_progressbar", 1, 1);
			me.TD(me, 1, 0.95, e = makeXonoticRadioButton(2, "hud_panel_healtharmor_baralign", "3", _("Outward")));
			setDependent(e, "hud_panel_healtharmor_progressbar", 1, 1);
	me.TR(me);
		me.TD(me, 1, 4, e = makeXonoticTextLabel(0, _("Icon alignment:")));
	me.TR(me);
		me.TDempty(me, 0.2);
			me.TD(me, 1, 0.95, e = makeXonoticRadioButton(3, "hud_panel_healtharmor_iconalign", "0", _("Left")));
			me.TD(me, 1, 0.95, e = makeXonoticRadioButton(3, "hud_panel_healtharmor_iconalign", "1", _("Right")));
			me.TD(me, 1, 0.95, e = makeXonoticRadioButton(3, "hud_panel_healtharmor_iconalign", "2", _("Inward")));
			me.TD(me, 1, 0.95, e = makeXonoticRadioButton(3, "hud_panel_healtharmor_iconalign", "3", _("Outward")));
	me.TR(me);
		me.TD(me, 1, 4, e = makeXonoticCheckBox(0, "hud_panel_healtharmor_flip", _("Flip health and armor positions")));
}
#endif
