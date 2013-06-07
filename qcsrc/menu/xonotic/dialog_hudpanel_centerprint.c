#ifdef INTERFACE
CLASS(XonoticHUDCenterprintDialog) EXTENDS(XonoticRootDialog)
	METHOD(XonoticHUDCenterprintDialog, fill, void(entity))
	ATTRIB(XonoticHUDCenterprintDialog, title, string, _("Centerprint"))
	ATTRIB(XonoticHUDCenterprintDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(XonoticHUDCenterprintDialog, intendedWidth, float, 0.4)
	ATTRIB(XonoticHUDCenterprintDialog, rows, float, 15)
	ATTRIB(XonoticHUDCenterprintDialog, columns, float, 4)
	ATTRIB(XonoticHUDCenterprintDialog, name, string, "HUDcenterprint")
ENDCLASS(XonoticHUDCenterprintDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticHUDCenterprintDialog_fill(entity me)
{
	entity e;
	string panelname = "centerprint";

	DIALOG_HUDPANEL_COMMON();

	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Message duration:")));
		me.TD(me, 1, 2.6, e = makeXonoticSlider(1, 10, 1, "hud_panel_centerprint_time"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Fade time:")));
		me.TD(me, 1, 2.6, e = makeXonoticSlider(0, 1, 0.05, "hud_panel_centerprint_fadetime"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 3.8, e = makeXonoticCheckBox(0, "hud_panel_centerprint_flip", _("Flip messages order")));
	me.TR(me);
		me.TD(me, 1, 4, e = makeXonoticTextLabel(0, _("Text alignment:")));
	me.TR(me);
		me.TDempty(me, 0.2);
			me.TD(me, 1, 3.8/3, e = makeXonoticRadioButton(3, "hud_panel_centerprint_align", "0", _("Left")));
			me.TD(me, 1, 3.8/3, e = makeXonoticRadioButton(3, "hud_panel_centerprint_align", "0.5", _("Center")));
			me.TD(me, 1, 3.8/3, e = makeXonoticRadioButton(3, "hud_panel_centerprint_align", "1", _("Right")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Font scale:")));
		me.TD(me, 1, 2.6, e = makeXonoticSlider(0.5, 2, 0.1, "hud_panel_centerprint_fontscale"));
}
#endif
