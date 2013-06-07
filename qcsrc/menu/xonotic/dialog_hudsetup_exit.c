#ifdef INTERFACE
CLASS(XonoticHUDExitDialog) EXTENDS(XonoticRootDialog)
	METHOD(XonoticHUDExitDialog, fill, void(entity))
	ATTRIB(XonoticHUDExitDialog, title, string, _("Panel HUD Setup"))
	ATTRIB(XonoticHUDExitDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(XonoticHUDExitDialog, intendedWidth, float, 0.4)
	ATTRIB(XonoticHUDExitDialog, rows, float, 18)
	ATTRIB(XonoticHUDExitDialog, columns, float, 4)
	ATTRIB(XonoticHUDExitDialog, name, string, "HUDExit")
ENDCLASS(XonoticHUDExitDialog)

#endif

#ifdef IMPLEMENTATION
void XonoticHUDExitDialog_fill(entity me)
{
	entity e;
	float i;

	me.TR(me);
		me.TD(me, 1, 4, makeXonoticTextLabel(0, _("Panel background defaults:")));
	me.TR(me);
		me.TD(me, 1, 1.4, e = makeXonoticTextLabel(0, _("Background:")));
			me.TD(me, 1, 2.6, e = makeXonoticTextSlider("hud_panel_bg"));
				e.addValue(e, _("Disable"), "0");
				e.addValue(e, "border_default", "border_default"); // this is a file name!
				e.configureXonoticTextSliderValues(e);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Color:")));
		me.TD(me, 2, 2.6, e = makeXonoticColorpickerString("hud_panel_bg_color", "hud_panel_bg_color"));
	me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Border size:")));
			me.TD(me, 1, 2.6, e = makeXonoticTextSlider("hud_panel_bg_border"));
				e.addValue(e, _("Disable"), "0");
				for(i = 1; i <= 10; ++i)
					e.addValue(e, strzone(ftos_decimals(i * 2, 0)), strzone(ftos(i * 2)));
				e.configureXonoticTextSliderValues(e);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Alpha:")));
			me.TD(me, 1, 2.6, e = makeXonoticTextSlider("hud_panel_bg_alpha"));
				for(i = 1; i <= 10; ++i)
					e.addValue(e, strzone(ftos_decimals(i/10, 1)), strzone(ftos(i/10)));
				e.configureXonoticTextSliderValues(e);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Team color:")));
			me.TD(me, 1, 2.6, e = makeXonoticTextSlider("hud_panel_bg_color_team"));
				e.addValue(e, _("Disable"), "0");
				for(i = 1; i <= 10; ++i)
					e.addValue(e, strzone(ftos_decimals(i/10, 1)), strzone(ftos(i/10)));
				e.configureXonoticTextSliderValues(e);
	me.TR(me);
		me.TDempty(me, 0.4);
		me.TD(me, 1, 3.6, e = makeXonoticCheckBox(0, "hud_configure_teamcolorforced", _("Test team color in configure mode")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Padding:")));
			me.TD(me, 1, 2.6, e = makeXonoticTextSlider("hud_panel_bg_padding"));
				for(i = 0; i <= 10; ++i)
					e.addValue(e, strzone(ftos_decimals(i - 5, 0)), strzone(ftos(i - 5)));
				e.configureXonoticTextSliderValues(e);

	me.TR(me);
		me.TD(me, 1, 1.4, e = makeXonoticTextLabel(0, _("HUD Dock:")));
			me.TD(me, 1, 2.6, e = makeXonoticTextSlider("hud_dock"));
				e.addValue(e, ZCTX(_("DOCK^Disabled")), "0");
				e.addValue(e, ZCTX(_("DOCK^Small")), "dock_small");
				e.addValue(e, ZCTX(_("DOCK^Medium")), "dock_medium");
				e.addValue(e, ZCTX(_("DOCK^Large")), "dock_large");
				e.configureXonoticTextSliderValues(e);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Color:")));
		me.TD(me, 2, 2.6, e = makeXonoticColorpickerString("hud_dock_color", "hud_dock_color"));
	me.TR(me);
	me.TR(me);	
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Alpha:")));
			me.TD(me, 1, 2.6, e = makeXonoticTextSlider("hud_dock_alpha"));
				for(i = 1; i <= 10; ++i)
					e.addValue(e, strzone(ftos_decimals(i/10, 1)), strzone(ftos(i/10)));
				e.configureXonoticTextSliderValues(e);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Team color:")));
			me.TD(me, 1, 2.6, e = makeXonoticTextSlider("hud_dock_color_team"));
				e.addValue(e, _("Disable"), "0");
				for(i = 1; i <= 10; ++i)
					e.addValue(e, strzone(ftos_decimals(i/10, 1)), strzone(ftos(i/10)));
				e.configureXonoticTextSliderValues(e);
	me.TR(me);
		me.TD(me, 1, 4, makeXonoticTextLabel(0, _("Grid settings:")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 3.8, e = makeXonoticCheckBox(0, "hud_configure_grid", _("Snap panels to grid")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Grid size:")));
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("X:")));
			me.TD(me, 1, 1.1, e = makeXonoticTextSlider("hud_configure_grid_xsize"));
				for(i = 1; i <= 14; ++i)
					e.addValue(e, strzone(ftos_decimals(i/200, 3)), strzone(ftos(i/200)));
				e.configureXonoticTextSliderValues(e);
			setDependent(e, "hud_configure_grid", 1, 1);
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("Y:")));
			me.TD(me, 1, 1.1, e = makeXonoticTextSlider("hud_configure_grid_ysize"));
				for(i = 1; i <= 14; ++i)
					e.addValue(e, strzone(ftos_decimals(i/200, 3)), strzone(ftos(i/200)));
				e.configureXonoticTextSliderValues(e);
			setDependent(e, "hud_configure_grid", 1, 1);

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeXonoticCommandButton(_("Exit setup"), '0 0 0', "_hud_configure 0", 1));
}
#endif
