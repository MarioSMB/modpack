#ifdef INTERFACE
CLASS(XonoticMiscSettingsTab) EXTENDS(XonoticTab)
	METHOD(XonoticMiscSettingsTab, fill, void(entity))
	ATTRIB(XonoticMiscSettingsTab, title, string, _("Misc"))
	ATTRIB(XonoticMiscSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(XonoticMiscSettingsTab, rows, float, 17)
	ATTRIB(XonoticMiscSettingsTab, columns, float, 6.2)
ENDCLASS(XonoticMiscSettingsTab)
entity makeXonoticMiscSettingsTab();
#endif

#ifdef IMPLEMENTATION
entity makeXonoticMiscSettingsTab()
{
	entity me;
	me = spawnXonoticMiscSettingsTab();
	me.configureDialog(me);
	return me;
}
void XonoticMiscSettingsTab_fill(entity me)
{
	entity e;
	//entity sk;

	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticTextLabel(0, _("Network:")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Speed:")));
		me.TD(me, 1, 2, e = makeXonoticTextSlider("_cl_rate"));
			e.addValue(e, _("56k"), "4000");
			e.addValue(e, _("ISDN"), "7000");
			e.addValue(e, _("Slow ADSL"), "15000");
			e.addValue(e, _("Fast ADSL"), "20000");
			e.addValue(e, _("Broadband"), "66666");
			e.configureXonoticTextSliderValues(e);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Input packets/s:")));
		me.TD(me, 1, 2, e = makeXonoticSlider(20, 100, 5, "cl_netfps"));
	me.TR(me);
		if(cvar("developer"))
		{
			me.TDempty(me, 0.2);
			me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Local latency:")));
			me.TD(me, 1, 2, e = makeXonoticSlider(0, 1000, 25, "cl_netlocalping"));
		}
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeXonoticTextLabel(0, _("Client UDP port:")));
		me.TD(me, 1, 1, e = makeXonoticInputBox(0, "cl_port"));
			e.enableClearButton = 0;
	me.TR(me);
		me.TDempty(me, 0.2);
		if(cvar_type("crypto_aeslevel") & CVAR_TYPEFLAG_ENGINE)
			me.TD(me, 1, 2.8, e = makeXonoticCheckBoxEx(2, 1, "crypto_aeslevel", _("Use encryption (AES) when available")));
	me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticCheckBox(0, "shownetgraph", _("Show netgraph")));
	me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticCheckBox(0, "cl_movement", _("Client-side movement prediction")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticCheckBox(0, "cl_movement_errorcompensation", _("Movement error compensation")));
		setDependent(e, "cl_movement", 1, 1);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticTextLabel(0, _("Downloads:")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Maximum:")));
		me.TD(me, 1, 2, e = makeXonoticSlider(1, 5, 1, "cl_curl_maxdownloads"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Speed (kB/s):")));
		me.TD(me, 1, 2, e = makeXonoticSlider(10, 1500, 10, "cl_curl_maxspeed"));
	me.TR(me);

	me.gotoRC(me, 0, 3.2); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 3, e = makeXonoticTextLabel(0, _("Framerate:")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Maximum:")));
		me.TD(me, 1, 2, e = makeXonoticTextSlider("cl_maxfps"));
			e.addValue(e, ZCTX(_("MAXFPS^5 fps")), "5");
			e.addValue(e, ZCTX(_("MAXFPS^10 fps")), "10");
			e.addValue(e, ZCTX(_("MAXFPS^20 fps")), "20");
			e.addValue(e, ZCTX(_("MAXFPS^30 fps")), "30");
			e.addValue(e, ZCTX(_("MAXFPS^40 fps")), "40");
			e.addValue(e, ZCTX(_("MAXFPS^50 fps")), "50");
			e.addValue(e, ZCTX(_("MAXFPS^60 fps")), "60");
			e.addValue(e, ZCTX(_("MAXFPS^70 fps")), "70");
			e.addValue(e, ZCTX(_("MAXFPS^100 fps")), "100");
			e.addValue(e, ZCTX(_("MAXFPS^125 fps")), "125");
			e.addValue(e, ZCTX(_("MAXFPS^200 fps")), "200");
			e.addValue(e, ZCTX(_("MAXFPS^Unlimited")), "0");
			e.configureXonoticTextSliderValues(e);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Target:")));
		me.TD(me, 1, 2, e = makeXonoticTextSlider("cl_minfps"));
			e.addValue(e, ZCTX(_("TRGT^Disabled")), "0");
			e.addValue(e, ZCTX(_("TRGT^30 fps")), "30");
			e.addValue(e, ZCTX(_("TRGT^40 fps")), "40");
			e.addValue(e, ZCTX(_("TRGT^50 fps")), "50");
			e.addValue(e, ZCTX(_("TRGT^60 fps")), "60");
			e.addValue(e, ZCTX(_("TRGT^100 fps")), "100");
			e.addValue(e, ZCTX(_("TRGT^125 fps")), "125");
			e.addValue(e, ZCTX(_("TRGT^200 fps")), "200");
			e.configureXonoticTextSliderValues(e);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Idle limit:")));
		me.TD(me, 1, 2, e = makeXonoticTextSlider("cl_maxidlefps"));
			e.addValue(e, ZCTX(_("IDLFPS^10 fps")), "10");
			e.addValue(e, ZCTX(_("IDLFPS^20 fps")), "20");
			e.addValue(e, ZCTX(_("IDLFPS^30 fps")), "30");
			e.addValue(e, ZCTX(_("IDLFPS^60 fps")), "60");
			e.addValue(e, ZCTX(_("IDLFPS^Unlimited")), "0");
			e.configureXonoticTextSliderValues(e);
	me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticCheckBox(0, "showfps", _("Show frames per second")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticCheckBox(0, "cl_maxfps_alwayssleep", _("Save processing time for other apps")));
		setDependent(e, "cl_maxfps", 1, 1000);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Menu tooltips:")));
		me.TD(me, 1, 2, e = makeXonoticTextSlider("menu_tooltips"));
			e.addValue(e, ZCTX(_("TLTIP^Disabled")), "0");
			e.addValue(e, ZCTX(_("TLTIP^Standard")), "1");
			e.addValue(e, ZCTX(_("TLTIP^Advanced")), "2");
			e.configureXonoticTextSliderValues(e);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticCheckBox(0, "showtime", _("Show current time")));
	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticCheckBox(0, "showdate", _("Show current date")));
	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticCheckBox(0, "developer", _("Enable developer mode")));
	me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.5);
		me.TD(me, 1, 2, e = makeXonoticButton(_("Advanced settings..."), '0 0 0'));
			e.onClick = DialogOpenButton_Click;
			e.onClickEntity = main.cvarsDialog;
	me.TR(me);
}
#endif
