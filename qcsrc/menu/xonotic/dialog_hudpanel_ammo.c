#ifdef INTERFACE
CLASS(XonoticHUDAmmoDialog) EXTENDS(XonoticRootDialog)
	METHOD(XonoticHUDAmmoDialog, fill, void(entity))
	ATTRIB(XonoticHUDAmmoDialog, title, string, _("Ammo Panel"))
	ATTRIB(XonoticHUDAmmoDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(XonoticHUDAmmoDialog, intendedWidth, float, 0.4)
	ATTRIB(XonoticHUDAmmoDialog, rows, float, 15)
	ATTRIB(XonoticHUDAmmoDialog, columns, float, 4)
	ATTRIB(XonoticHUDAmmoDialog, name, string, "HUDammo")
ENDCLASS(XonoticHUDAmmoDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticHUDAmmoDialog_fill(entity me)
{
	entity e;
	string panelname = "ammo";

	DIALOG_HUDPANEL_COMMON();

	me.TR(me);
		me.TD(me, 1, 4, e = makeXonoticTextLabel(0, _("Ammunition display:")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 3.8, e = makeXonoticCheckBox(0, "hud_panel_ammo_onlycurrent", _("Show only current ammo type")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.4, e = makeXonoticTextLabel(0, _("Align icon:")));
			me.TD(me, 1, 2.4/2, e = makeXonoticRadioButton(2, "hud_panel_ammo_iconalign", "0", _("Left")));
			me.TD(me, 1, 2.4/2, e = makeXonoticRadioButton(2, "hud_panel_ammo_iconalign", "1", _("Right")));
}
#endif
