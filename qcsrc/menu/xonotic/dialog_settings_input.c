#ifdef INTERFACE
CLASS(XonoticInputSettingsTab) EXTENDS(XonoticTab)
	METHOD(XonoticInputSettingsTab, fill, void(entity))
	ATTRIB(XonoticInputSettingsTab, title, string, _("Input"))
	ATTRIB(XonoticInputSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(XonoticInputSettingsTab, rows, float, 17)
	ATTRIB(XonoticInputSettingsTab, columns, float, 6.2) // added extra .2 for center space
ENDCLASS(XonoticInputSettingsTab)
entity makeXonoticInputSettingsTab();
#endif

#ifdef IMPLEMENTATION
entity makeXonoticInputSettingsTab()
{
	entity me;
	me = spawnXonoticInputSettingsTab();
	me.configureDialog(me);
	return me;
}
void XonoticInputSettingsTab_fill(entity me)
{
	entity e;
	entity kb;

	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticTextLabel(0, _("Key bindings:")));
	me.TR(me);
		me.TD(me, me.rows - 4, 3, kb = makeXonoticKeyBinder());
	me.gotoRC(me, me.rows - 3, 0);
		me.TD(me, 1, 1, e = makeXonoticButton(_("Change key..."), '0 0 0'));
			e.onClick = KeyBinder_Bind_Change;
			e.onClickEntity = kb;
			kb.keyGrabButton = e;
		me.TD(me, 1, 1, e = makeXonoticButton(_("Edit..."), '0 0 0'));
			e.onClick = KeyBinder_Bind_Edit;
			e.onClickEntity = kb;
			kb.userbindEditButton = e;
			kb.userbindEditDialog = main.userbindEditDialog;
			main.userbindEditDialog.keybindBox = kb;
		me.TD(me, 1, 1, e = makeXonoticButton(_("Clear"), '0 0 0'));
			e.onClick = KeyBinder_Bind_Clear;
			e.onClickEntity = kb;
			kb.clearButton = e;

	me.gotoRC(me, 0, 3.2); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 3, e = makeXonoticCheckBox(0, "con_closeontoggleconsole", _("Pressing \"enter console\" key also closes it")));
	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticCheckBox(1, "cl_movement_track_canjump", _("Automatically repeat jumping if holding jump")));
	me.TR(me);
	me.TR(me);
		if(cvar_type("joy_enable") & CVAR_TYPEFLAG_ENGINE)
			me.TD(me, 1, 3, e = makeXonoticCheckBox(0, "joy_enable", _("Use joystick input")));
		else if(cvar_type("joystick") & CVAR_TYPEFLAG_ENGINE)
			me.TD(me, 1, 3, e = makeXonoticCheckBox(0, "joystick", _("Use joystick input")));
		else
		{
			me.TD(me, 1, 3, e = makeXonoticCheckBox(0, string_null, _("Use joystick input")));
			e.disabled = 1; // the option is never available in this case, just there for show
		}
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticTextLabel(0, _("Mouse:")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Sensitivity:")));
		me.TD(me, 1, 2, e = makeXonoticSlider(1, 32, 0.2, "sensitivity"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticCheckBox(0, "m_filter", _("Smooth aiming")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticCheckBox(1.022, "m_pitch", _("Invert aiming")));
	me.TR(me);
		me.TDempty(me, 0.2);
		if(cvar_type("vid_dgamouse") & CVAR_TYPEFLAG_ENGINE)
			me.TD(me, 1, 2.8, e = makeXonoticCheckBox(0, "vid_dgamouse", _("Disable system mouse acceleration")));
		else if(cvar_type("apple_mouse_noaccel") & CVAR_TYPEFLAG_ENGINE)
			me.TD(me, 1, 2.8, e = makeXonoticCheckBox(0, "apple_mouse_noaccel", _("Disable system mouse acceleration")));
		else
		{
			me.TD(me, 1, 2.8, e = makeXonoticCheckBox(0, string_null, _("Disable system mouse acceleration")));
			e.disabled = 1; // the option is never available in this case, just there for show
		}
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticCheckBox(0, "m_accelerate", _("Enable built in mouse acceleration")));


	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, makeXonoticCommandButton(_("Apply immediately"), '0 0 0', "sendcvar cl_movement_track_canjump", COMMANDBUTTON_APPLY));
}
#endif
