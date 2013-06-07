#ifdef INTERFACE
CLASS(XonoticCvarsDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticCvarsDialog, fill, void(entity))
	METHOD(XonoticCvarsDialog, showNotify, void(entity))
	ATTRIB(XonoticCvarsDialog, title, string, _("Advanced settings"))
	ATTRIB(XonoticCvarsDialog, color, vector, SKINCOLOR_DIALOG_CVARS)
	ATTRIB(XonoticCvarsDialog, intendedWidth, float, 0.8)
	ATTRIB(XonoticCvarsDialog, rows, float, 24)
	ATTRIB(XonoticCvarsDialog, columns, float, 6)
ENDCLASS(XonoticCvarsDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticCvarsDialog_showNotify(entity me)
{
	loadAllCvars(me);
}
void XonoticCvarsDialog_fill(entity me) // in this dialog, use SKINCOLOR_CVARLIST_CONTROLS to color ALL controls 
{

	entity e, cvarlist;

	cvarlist = makeXonoticCvarList();

	cvarlist.color = 
		cvarlist.colorF = 
		cvarlist.color2 = 
		cvarlist.colorC = 
		SKINCOLOR_CVARLIST_CONTROLS;

	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Cvar filter:")));
		me.TD(me, 1, me.columns - 1, e = makeXonoticInputBox(0, string_null));
			e.color = SKINCOLOR_CVARLIST_CONTROLS;
			e.colorF = SKINCOLOR_CVARLIST_CONTROLS;
			e.cb_color = SKINCOLOR_CVARLIST_CONTROLS;
			e.cb_colorC = SKINCOLOR_CVARLIST_CONTROLS;
			e.cb_colorF = SKINCOLOR_CVARLIST_CONTROLS;
			e.onChange = CvarList_Filter_Change;
			e.onChangeEntity = cvarlist;
			cvarlist.controlledTextbox = e; // this COULD also be the Value box, but this leads to accidentally editing stuff
	me.TR(me);
		me.TD(me, me.rows - me.currentRow - 7, me.columns, cvarlist);
	me.gotoRC(me, me.rows - 6, 0);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Setting:")));
		me.TD(me, 1, me.columns - 1, e = makeXonoticTextLabel(0, string_null));
			cvarlist.cvarNameBox = e;
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Type:")));
		me.TD(me, 1, me.columns - 1, e = makeXonoticTextLabel(0, string_null));
			cvarlist.cvarTypeBox = e;
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Value:")));
		me.TD(me, 1, me.columns - 2, e = makeXonoticInputBox(0, string_null));
			cvarlist.cvarValueBox = e;
			e.color = SKINCOLOR_CVARLIST_CONTROLS;
			e.colorF = SKINCOLOR_CVARLIST_CONTROLS;
			e.cb_color = SKINCOLOR_CVARLIST_CONTROLS;
			e.cb_colorC = SKINCOLOR_CVARLIST_CONTROLS;
			e.cb_colorF = SKINCOLOR_CVARLIST_CONTROLS;
			e.onChange = CvarList_Value_Change;
			e.onChangeEntity = cvarlist;
			e.onEnter = CvarList_End_Editing;
			e.onEnterEntity = cvarlist;
		me.TD(me, 1, 1, e = makeXonoticButton(string_null, SKINCOLOR_CVARLIST_CONTROLS));
			cvarlist.cvarDefaultBox = e;
			e.onClick = CvarList_Revert_Click;
			e.onClickEntity = cvarlist;
			e.allowCut = 1;
			e.marginLeft = e.marginRight = 0.5;
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Description:")));
		me.TD(me, 1, me.columns - 1, e = makeXonoticTextLabel(0, string_null));
			cvarlist.cvarDescriptionBox = e;
			e.allowWrap = 1;
	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeXonoticButton(_("OK"), SKINCOLOR_CVARLIST_CONTROLS));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}

#endif
