#ifdef INTERFACE
CLASS(XonoticHUDPhysicsDialog) EXTENDS(XonoticRootDialog)
	METHOD(XonoticHUDPhysicsDialog, fill, void(entity))
	ATTRIB(XonoticHUDPhysicsDialog, title, string, _("Physics Panel"))
	ATTRIB(XonoticHUDPhysicsDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(XonoticHUDPhysicsDialog, intendedWidth, float, 0.4)
	ATTRIB(XonoticHUDPhysicsDialog, rows, float, 15)
	ATTRIB(XonoticHUDPhysicsDialog, columns, float, 4)
	ATTRIB(XonoticHUDPhysicsDialog, name, string, "HUDphysics")
	ATTRIB(XonoticHUDPhysicsDialog, sliderTopspeedTime, entity, NULL)
ENDCLASS(XonoticHUDPhysicsDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticHUDPhysicsDialog_fill(entity me)
{
	entity e;
	string panelname = "physics";

	me.TR(me);
		me.TD(me, 1, 4, e = makeXonoticTextSlider("hud_panel_physics"));
			e.addValue(e, _("Panel disabled"), "0");
			e.addValue(e, _("Panel enabled"), "1");
			e.addValue(e, _("Panel enabled even observing"), "2");
			e.addValue(e, _("Panel enabled only in Race/CTS"), "3");
			e.configureXonoticTextSliderValues(e);

	DIALOG_HUDPANEL_COMMON_NOTOGGLE();

	me.TR(me);
		me.TD(me, 1, 1.4, e = makeXonoticCheckBox(0, "hud_panel_physics_progressbar", _("Status bar")));
		me.TD(me, 1, 2.6, e = makeXonoticTextSlider("hud_panel_physics_baralign"));
			e.addValue(e, _("Left align")   , "0");
			e.addValue(e, _("Right align")  , "1");
			e.addValue(e, _("Inward align") , "2");
			e.addValue(e, _("Outward align"), "3");
			e.configureXonoticTextSliderValues(e);
			setDependent(e, "hud_panel_physics_progressbar", 1, 3);
	me.TR(me);
		me.TD(me, 1, 4, e = makeXonoticCheckBox(0, "hud_panel_physics_flip", _("Flip speed/acceleration positions")));

//speed
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Speed:")));
		me.TD(me, 1, 3, e = makeXonoticCheckBox(0, "hud_panel_physics_speed_vertical", _("Include vertical speed")));
	// me.TR(me);
		// me.TDempty(me, 0.2);
		// me.TD(me, 1, 1.8, e = makeXonoticTextLabel(0, _("Full status bar at:")));
			// setDependent(e, "hud_panel_physics_progressbar", 1, 1);
		// me.TD(me, 1, 1, e = makeXonoticInputBox(1, "hud_panel_physics_speed_max"));
			// setDependent(e, "hud_panel_physics_progressbar", 1, 1);
		// me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("qu/s")));
			// setDependent(e, "hud_panel_physics_progressbar", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Speed unit:")));
		me.TD(me, 1, 2.6/3*2, e = makeXonoticTextSlider("hud_panel_physics_speed_unit"));
			e.addValue(e, _("qu/s") , "1");
			e.addValue(e, _("m/s")  , "2");
			e.addValue(e, _("km/h") , "3");
			e.addValue(e, _("mph")  , "4");
			e.addValue(e, _("knots"), "5");
			e.configureXonoticTextSliderValues(e);
		me.TD(me, 1, 2.6/3, e = makeXonoticCheckBox(0, "hud_panel_physics_speed_unit_show", _("Show")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 3.8/2, e = makeXonoticCheckBox(0, "hud_panel_physics_topspeed", _("Top speed")));
		me.TD(me, 1, 3.8/2, e = makeXonoticSlider(1, 10, 1, "hud_panel_physics_topspeed_time"));
			setDependent(e, "hud_panel_physics_topspeed", 1, 1);

//acceleration
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Acceleration:")));
		me.TD(me, 1, 3, e = makeXonoticCheckBox(0, "hud_panel_physics_acceleration_vertical", _("Include vertical acceleration")));
	// me.TR(me);
		// me.TDempty(me, 0.2);
		// me.TD(me, 1, 1.8, e = makeXonoticTextLabel(0, _("Full status bar at:")));
			// setDependent(e, "hud_panel_physics_progressbar", 1, 1);
		// me.TD(me, 1, 0.6, e = makeXonoticInputBox(1, "hud_panel_physics_acceleration_max"));
			// setDependent(e, "hud_panel_physics_progressbar", 1, 1);
}
#endif
