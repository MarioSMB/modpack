#ifdef INTERFACE
CLASS(XonoticCrosshairDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticCrosshairDialog, toString, string(entity))
	METHOD(XonoticCrosshairDialog, fill, void(entity))
	METHOD(XonoticCrosshairDialog, showNotify, void(entity))
	ATTRIB(XonoticCrosshairDialog, title, string, _("Crosshair settings"))
	ATTRIB(XonoticCrosshairDialog, color, vector, SKINCOLOR_DIALOG_CROSSHAIR)
	ATTRIB(XonoticCrosshairDialog, intendedWidth, float, 0.5)
	ATTRIB(XonoticCrosshairDialog, rows, float, 18)
	ATTRIB(XonoticCrosshairDialog, columns, float, 3)
ENDCLASS(XonoticCrosshairDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticCrosshairDialog_showNotify(entity me)
{
	loadAllCvars(me);
}
string XonoticCrosshairDialog_toString(entity me)
{
	return "hi"; // TODO: show status of crosshair dot and hittest and pickups and such here with text
}
void XonoticCrosshairDialog_fill(entity me)
{
	entity e;
	
	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticCheckBox(0, "crosshair_dot", _("Enable center crosshair dot")));
		setDependent(e, "crosshair_enabled", 1, 2);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Dot size:")));
			setDependentAND(e, "crosshair_dot", 1, 1, "crosshair_enabled", 1, 2);
		me.TD(me, 1, 2, e = makeXonoticSlider(0.2, 2, 0.1, "crosshair_dot_size"));
			setDependentAND(e, "crosshair_dot", 1, 1, "crosshair_enabled", 1, 2);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Dot alpha:")));
			setDependentAND(e, "crosshair_dot", 1, 1, "crosshair_enabled", 1, 2);
		me.TD(me, 1, 2, e = makeXonoticSlider(0.1, 1, 0.1, "crosshair_dot_alpha"));
			setDependentAND(e, "crosshair_dot", 1, 1, "crosshair_enabled", 1, 2);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Dot color:")));
			setDependentAND(e, "crosshair_dot", 1, 1, "crosshair_enabled", 1, 2);
		me.TD(me, 1, 2, e = makeXonoticRadioButton(1, "crosshair_dot_color_custom", "0", _("Use normal crosshair color")));
			setDependentAND(e, "crosshair_dot", 1, 1, "crosshair_enabled", 1, 2);
	me.TR(me);
		me.TDempty(me, 0.1);
		me.TD(me, 1, 0.8, e = makeXonoticRadioButton(1, "crosshair_dot_color_custom", "1", _("Custom")));
			setDependentAND(e, "crosshair_dot", 1, 1, "crosshair_enabled", 1, 2);
		me.TD(me, 2, 2, e = makeXonoticColorpickerString("crosshair_dot_color", "crosshair_dot_color"));
			setDependentAND3(e, "crosshair_dot", 1, 1, "crosshair_enabled", 1, 2, "crosshair_dot_color_custom", 1, 1);
	me.TR(me);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticTextLabel(0, _("Crosshair animations:")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticCheckBox(0, "crosshair_effect_scalefade", _("Smooth effects of crosshairs")));
			setDependent(e, "crosshair_enabled", 1, 2);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticCheckBox(0, "crosshair_ring", _("Use rings to indicate weapon status")));
			makeMulti(e, "crosshair_ring_reload");
			setDependent(e, "crosshair_enabled", 1, 2);
	me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Hit testing:")));
		me.TD(me, 1, 2, e = makeXonoticTextSlider("crosshair_hittest"));
			e.addValue(e, ZCTX(_("HTTST^Disabled")), "0");
			e.addValue(e, ZCTX(_("HTTST^TrueAim")), "1");
			e.addValue(e, ZCTX(_("HTTST^Enemies")), "1.25");
			e.configureXonoticTextSliderValues(e);
			setDependent(e, "crosshair_enabled", 1, 2);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticCheckBox(0, "crosshair_hittest_blur", _("Blur crosshair if the shot is obstructed")));
			setDependentAND(e, "crosshair_hittest", 1, 100, "crosshair_enabled", 1, 2);
	me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticCheckBoxEx(0.5, 0, "crosshair_hitindication", _("Animate when hitting an enemy")));
			setDependent(e, "crosshair_enabled", 1, 2);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticCheckBoxEx(0.25, 0, "crosshair_pickup", _("Animate when picking up an item")));
			setDependent(e, "crosshair_enabled", 1, 2);
			
	me.TR(me);
			
	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeXonoticButton(_("OK"), '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}
#endif
