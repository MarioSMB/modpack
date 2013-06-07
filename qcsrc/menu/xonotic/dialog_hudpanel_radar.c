#ifdef INTERFACE
CLASS(XonoticHUDRadarDialog) EXTENDS(XonoticRootDialog)
	METHOD(XonoticHUDRadarDialog, fill, void(entity))
	ATTRIB(XonoticHUDRadarDialog, title, string, _("Radar Panel"))
	ATTRIB(XonoticHUDRadarDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(XonoticHUDRadarDialog, intendedWidth, float, 0.4)
	ATTRIB(XonoticHUDRadarDialog, rows, float, 15)
	ATTRIB(XonoticHUDRadarDialog, columns, float, 4)
	ATTRIB(XonoticHUDRadarDialog, name, string, "HUDradar")
ENDCLASS(XonoticHUDRadarDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticHUDRadarDialog_fill(entity me)
{
	entity e;
	string panelname = "radar";

	me.TR(me);
		me.TD(me, 1, 4, e = makeXonoticTextSlider("hud_panel_radar"));
			e.addValue(e, _("Panel disabled"), "0");
			e.addValue(e, _("Panel enabled in teamgames"), "1");
			e.addValue(e, _("Panel always enabled"), "2");
			e.configureXonoticTextSliderValues(e);

	DIALOG_HUDPANEL_COMMON_NOTOGGLE();

	me.TR(me);
		me.TD(me, 1, 4, e = makeXonoticTextLabel(0, _("Radar:")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Alpha:")));
		me.TD(me, 1, 2.6, e = makeXonoticSlider(0.1, 1, 0.1, "hud_panel_radar_foreground_alpha"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Rotation:")));
			me.TD(me, 1, 2.6, e = makeXonoticTextSlider("hud_panel_radar_rotation"));
				e.addValue(e, _("Forward"), "0");
				e.addValue(e, _("West"), "1");
				e.addValue(e, _("South"), "2");
				e.addValue(e, _("East"), "3");
				e.addValue(e, _("North"), "4");
				e.configureXonoticTextSliderValues(e);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Scale:")));
		me.TD(me, 1, 2.6, e = makeXonoticSlider(1024, 8192, 512, "hud_panel_radar_scale"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Zoom mode:")));
			me.TD(me, 1, 2.6, e = makeXonoticTextSlider("hud_panel_radar_zoommode"));
				e.addValue(e, _("Zoomed in"), "0");
				e.addValue(e, _("Zoomed out"), "1");
				e.addValue(e, _("Always zoomed"), "2");
				e.addValue(e, _("Never zoomed"), "3");
				e.configureXonoticTextSliderValues(e);
}
#endif
