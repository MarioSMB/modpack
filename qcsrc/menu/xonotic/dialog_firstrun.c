#ifdef INTERFACE
CLASS(XonoticFirstRunDialog) EXTENDS(XonoticRootDialog)
	METHOD(XonoticFirstRunDialog, fill, void(entity)) // to be overridden by user to fill the dialog with controls
	ATTRIB(XonoticFirstRunDialog, title, string, _("Welcome"))
	ATTRIB(XonoticFirstRunDialog, color, vector, SKINCOLOR_DIALOG_FIRSTRUN)
	ATTRIB(XonoticFirstRunDialog, intendedWidth, float, 0.7)
	ATTRIB(XonoticFirstRunDialog, rows, float, 16)
	ATTRIB(XonoticFirstRunDialog, columns, float, 6)
	ATTRIB(XonoticFirstRunDialog, name, string, "FirstRun")
	ATTRIB(XonoticFirstRunDialog, playerNameLabel, entity, NULL)
	ATTRIB(XonoticFirstRunDialog, playerNameLabelAlpha, float, 0)

	ATTRIB(XonoticFirstRunDialog, closable, float, 0)
ENDCLASS(XonoticFirstRunDialog)
#endif

#ifdef IMPLEMENTATION
float CheckFirstRunButton(entity me)
{
	if(cvar_string("_cl_name") != "Player")
		return 1;
		
	if(cvar_string("_menu_prvm_language") != prvm_language)
		return 1; // OK will then reopen the dialog in another language
		
	if(cvar_string("cl_allow_uid2name") != "-1")
		return 1; 
		
	return 0;
}

void XonoticFirstRunDialog_fill(entity me)
{
	entity e;
	entity label, box;

	me.TR(me);
	me.TR(me);
		me.TDempty(me, 1);
		me.TD(me, 2, 4, e = makeXonoticTextLabel(0, _("Welcome to Xonotic, please select your language preference and enter your player name to get started.  You can change these options later through the menu system.")));
		e.allowWrap = 1;
	me.TR(me);

	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 0.5, me.playerNameLabel = makeXonoticTextLabel(0, _("Name:")));
			me.playerNameLabelAlpha = me.playerNameLabel.alpha;
		me.TD(me, 1, 3.25, label = makeXonoticTextLabel(0, string_null));
			label.allowCut = 1;
			label.allowColors = 1;
			label.alpha = 1;
	me.TR(me);
		me.TD(me, 1, 3.75, box = makeXonoticInputBox(1, "_cl_name"));
			box.forbiddenCharacters = "\r\n\\\"$"; // don't care, isn't getting saved
			box.maxLength = -127; // negative means encoded length in bytes
			box.saveImmediately = 1;
			label.textEntity = box;
	me.TR(me);
		me.TD(me, 5, 1.25, e = makeXonoticColorpicker(box));
		me.TD(me, 5, 2.5, e = makeXonoticCharmap(box));
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	
	me.gotoRC(me, 3, 4); me.setFirstColumn(me, me.currentColumn);
	me.TR(me);
		me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("Text language:")));
	me.TR(me);
		me.TD(me, 6, 2, e = makeXonoticLanguageList());
			e.name = "languageselector_firstrun";
			e.doubleClickCommand = "prvm_language \"$_menu_prvm_language\"; saveconfig; menu_restart";
	me.TR(me);
	me.TR(me);

	me.gotoRC(me, me.rows - 4, 0);
	me.TD(me, 1, me.columns, e = makeXonoticTextLabel(0.5, _("Allow player statistics to use your nickname at stats.xonotic.org?")));
	
	me.gotoRC(me, me.rows - 3, 0);
	me.TDempty(me, 1.5);
	me.TD(me, 1, 1, e = makeXonoticRadioButton(1, "cl_allow_uid2name", "1", ZCTX(_("ALWU2N^Yes"))));
	me.TD(me, 1, 1, e = makeXonoticRadioButton(1, "cl_allow_uid2name", "0", ZCTX(_("ALWU2N^No"))));
	me.TD(me, 1, 1, e = makeXonoticRadioButton(1, "cl_allow_uid2name", "-1", ZCTX(_("ALWU2N^Undecided"))));

	// because of the language selector, this is a menu_restart!
	me.gotoRC(me, me.rows - 1, 0);
	me.TD(me, 1, me.columns, e = makeXonoticCommandButton(_("Save settings"), '0 0 0', "prvm_language \"$_menu_prvm_language\"; saveconfig; menu_restart", COMMANDBUTTON_APPLY));
		setDependentWeird(e, CheckFirstRunButton);
}
#endif
