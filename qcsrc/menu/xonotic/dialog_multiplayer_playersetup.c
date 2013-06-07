#ifdef INTERFACE
CLASS(XonoticPlayerSettingsTab) EXTENDS(XonoticTab)
	METHOD(XonoticPlayerSettingsTab, fill, void(entity))
	METHOD(XonoticPlayerSettingsTab, draw, void(entity))
	ATTRIB(XonoticPlayerSettingsTab, title, string, _("Player Setup"))
	ATTRIB(XonoticPlayerSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(XonoticPlayerSettingsTab, rows, float, 22)
	ATTRIB(XonoticPlayerSettingsTab, columns, float, 6.2) // added extra .2 for center space 
	ATTRIB(XonoticPlayerSettingsTab, playerNameLabel, entity, NULL)
	ATTRIB(XonoticPlayerSettingsTab, playerNameLabelAlpha, float, 0)
ENDCLASS(XonoticPlayerSettingsTab)
entity makeXonoticPlayerSettingsTab();
#endif

#ifdef IMPLEMENTATION
entity makeXonoticPlayerSettingsTab()
{
	entity me;
	me = spawnXonoticPlayerSettingsTab();
	me.configureDialog(me);
	return me;
}
void XonoticPlayerSettingsTab_draw(entity me)
{
	if(cvar_string("_cl_name") == "Player")
		me.playerNameLabel.alpha = ((mod(time * 2, 2) < 1) ? 1 : 0);
	else
		me.playerNameLabel.alpha = me.playerNameLabelAlpha;
	SUPER(XonoticPlayerSettingsTab).draw(me);
}
void XonoticPlayerSettingsTab_fill(entity me)
{
	entity e, pms, label, box;
	float i;

	me.TR(me);
		me.TD(me, 1, 0.5, me.playerNameLabel = makeXonoticTextLabel(0, _("Name:")));
			me.playerNameLabelAlpha = me.playerNameLabel.alpha;
		me.TD(me, 1, 2.5, label = makeXonoticTextLabel(0, string_null));
			label.allowCut = 1;
			label.allowColors = 1;
			label.alpha = 1;
	me.TR(me);
		me.TD(me, 1, 3.0, box = makeXonoticInputBox(1, "_cl_name"));
			box.forbiddenCharacters = "\r\n\\\"$"; // don't care, isn't getting saved
			box.maxLength = -127; // negative means encoded length in bytes
			box.saveImmediately = 1;
			box.enableClearButton = 0;
			label.textEntity = box;
	me.TR(me);
		me.TD(me, 5, 1, e = makeXonoticColorpicker(box));
		me.TD(me, 5, 2, e = makeXonoticCharmap(box));
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);

	me.TR(me);
		me.TDempty(me, 1);
		me.TD(me, 1, 2, e = makeXonoticTextLabel(0.5, _("Model:")));
	me.TR(me);
		me.TDempty(me, 1);
		pms = makeXonoticPlayerModelSelector();
		me.TD(me, 1, 0.3, e = makeXonoticButton("<<", '0 0 0'));
			e.onClick = PlayerModelSelector_Prev_Click;
			e.onClickEntity = pms;
		me.TD(me, me.rows - (me.currentRow + 2), 1.4, pms);
		me.TD(me, 1, 0.3, e = makeXonoticButton(">>", '0 0 0'));
			e.onClick = PlayerModelSelector_Next_Click;
			e.onClickEntity = pms;
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0.5, _("Glowing color:")));
		for(i = 0; i < 15; ++i)
		{
			if(mod(i, 5) == 0)
				me.TR(me);
			me.TDNoMargin(me, 1, 0.2, e = makeXonoticColorButton(1, 0, i), '0 1 0');
		}
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0.5, _("Detail color:")));
		for(i = 0; i < 15; ++i)
		{
			if(mod(i, 5) == 0)
				me.TR(me);
			me.TDNoMargin(me, 1, 0.2, e = makeXonoticColorButton(2, 1, i), '0 1 0');
		}

	// crosshair_enabled: 0 = no crosshair options, 1 = no crosshair selection, but everything else enabled, 2 = all crosshair options enabled
	// FIXME: In the future, perhaps make one global crosshair_type cvar which has 0 for disabled, 1 for custom, 2 for per weapon, etc?
	me.gotoRC(me, 0, 3.2); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 3, e = makeXonoticRadioButton(3, "crosshair_enabled", "0", _("No crosshair")));
	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticRadioButton(3, "crosshair_per_weapon", string_null, _("Per weapon crosshair")));
		makeMulti(e, "crosshair_enabled");
	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticRadioButton(3, "crosshair_enabled", "2", _("Custom crosshair")));
	me.TR(me);
		me.TDempty(me, 0.1);
		for(i = 1; i <= 14; ++i) {
			me.TDNoMargin(me, 1, 2 / 14, e = makeXonoticCrosshairButton(4, i), '1 1 0');
				setDependentAND(e, "crosshair_per_weapon", 0, 0, "crosshair_enabled", 1, 2);
		}
		// show a larger preview of the selected crosshair
		me.TDempty(me, 0.1);
		me.TDNoMargin(me, 3, 0.8, e = makeXonoticCrosshairButton(7, -1), '1 1 0'); // crosshair -1 makes this a preview
			setDependentAND(e, "crosshair_per_weapon", 0, 0, "crosshair_enabled", 1, 2);
	me.TR(me);
		me.TDempty(me, 0.1);
		for(i = 15; i <= 28; ++i) {
			me.TDNoMargin(me, 1, 2 / 14, e = makeXonoticCrosshairButton(4, i), '1 1 0');
				setDependentAND(e, "crosshair_per_weapon", 0, 0, "crosshair_enabled", 1, 2);
		}
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Crosshair size:")));
			setDependent(e, "crosshair_enabled", 1, 2);
		me.TD(me, 1, 2, e = makeXonoticSlider(0.1, 1.0, 0.01, "crosshair_size"));
			setDependent(e, "crosshair_enabled", 1, 2);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Crosshair alpha:")));
			setDependent(e, "crosshair_enabled", 1, 2);
		me.TD(me, 1, 2, e = makeXonoticSlider(0, 1, 0.1, "crosshair_alpha"));
			setDependent(e, "crosshair_enabled", 1, 2);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Crosshair color:")));
			setDependent(e, "crosshair_enabled", 1, 2);
		me.TD(me, 1, 1, e = makeXonoticRadioButton(5, "crosshair_color_special", "1", _("Per weapon")));
			setDependent(e, "crosshair_enabled", 1, 2);
		me.TD(me, 1, 1, e = makeXonoticRadioButton(5, "crosshair_color_special", "2", _("By health")));
			setDependent(e, "crosshair_enabled", 1, 2);
	me.TR(me);
		me.TDempty(me, 0.1);
		me.TD(me, 1, 0.9, e = makeXonoticRadioButton(5, "crosshair_color_special", "0", _("Custom")));
			setDependent(e, "crosshair_enabled", 1, 2);
		me.TD(me, 2, 2, e = makeXonoticColorpickerString("crosshair_color", "crosshair_color"));
			setDependentAND(e, "crosshair_color_special", 0, 0, "crosshair_enabled", 1, 2);
	me.TR(me);
	me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.5);
		me.TD(me, 1, 2, e = makeXonoticButton(_("Other crosshair settings"), '0 0 0'));
			e.onClick = DialogOpenButton_Click;
			e.onClickEntity = main.crosshairDialog;
		setDependent(e, "crosshair_enabled", 1, 2);
		// TODO: show status of crosshair dot and hittest and pickups and such here with text
	me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.5);
		me.TD(me, 1, 2, e = makeXonoticButton(_("Model settings"), '0 0 0'));
			e.onClick = DialogOpenButton_Click;
			e.onClickEntity = main.modelDialog;
		// TODO: show csqc model settings like forcemyplayer and deglowing/ghosting bodies with text here
	me.TR(me);
		me.TDempty(me, 0.5);
		me.TD(me, 1, 2, e = makeXonoticButton(_("View settings"), '0 0 0'));
			e.onClick = DialogOpenButton_Click;
			e.onClickEntity = main.viewDialog;
		// TODO: show fov and other settings with text here
	me.TR(me);
		me.TDempty(me, 0.5);
		me.TD(me, 1, 2, e = makeXonoticButton(_("Weapon settings"), '0 0 0'));
			e.onClick = DialogOpenButton_Click;
			e.onClickEntity = main.weaponsDialog;
		// I don't really think this is useful as is, and especially it doesn't look very clean...
		// In the future, if ALL of these buttons had some information, then it would be justified/clean
		//me.TD(me, 1, 1, e0 = makeXonoticTextLabel(0, string_null)); 
		//	e0.textEntity = main.weaponsDialog;
		//	e0.allowCut = 1;
	me.TR(me);
		me.TDempty(me, 0.5);
		me.TD(me, 1, 2, e = makeXonoticButton(_("HUD settings"), '0 0 0'));
			e.onClick = DialogOpenButton_Click;
			e.onClickEntity = main.hudDialog;
		// TODO: show hud config name with text here 

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, makeXonoticCommandButton(_("Apply immediately"), '0 0 0', "color -1 -1;name \"$_cl_name\";sendcvar cl_weaponpriority;sendcvar cl_autoswitch;sendcvar cl_forceplayermodels;sendcvar cl_forceplayermodelsfromxonotic;playermodel $_cl_playermodel;playerskin $_cl_playerskin", COMMANDBUTTON_APPLY));
}
#endif
