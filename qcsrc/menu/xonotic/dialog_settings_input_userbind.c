#ifdef INTERFACE
CLASS(XonoticUserbindEditDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticUserbindEditDialog, loadUserBind, void(entity, string, string, string))
	METHOD(XonoticUserbindEditDialog, fill, void(entity))
	ATTRIB(XonoticUserbindEditDialog, title, string, _("User defined key bind"))
	ATTRIB(XonoticUserbindEditDialog, color, vector, SKINCOLOR_DIALOG_USERBIND)
	ATTRIB(XonoticUserbindEditDialog, intendedWidth, float, 0.7)
	ATTRIB(XonoticUserbindEditDialog, rows, float, 4)
	ATTRIB(XonoticUserbindEditDialog, columns, float, 3)
	ATTRIB(XonoticUserbindEditDialog, keybindBox, entity, NULL)

	ATTRIB(XonoticUserbindEditDialog, nameBox, entity, NULL)
	ATTRIB(XonoticUserbindEditDialog, commandPressBox, entity, NULL)
	ATTRIB(XonoticUserbindEditDialog, commandReleaseBox, entity, NULL)
ENDCLASS(XonoticUserbindEditDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticUserbindEditDialog_Save(entity btn, entity me)
{
	me.keybindBox.editUserbind(me.keybindBox, me.nameBox.text, me.commandPressBox.text, me.commandReleaseBox.text);
	Dialog_Close(btn, me);
}

void XonoticUserbindEditDialog_loadUserBind(entity me, string theName, string theCommandPress, string theCommandRelease)
{
	me.nameBox.setText(me.nameBox, theName);
		me.nameBox.keyDown(me.nameBox, K_END, 0, 0);
	me.commandPressBox.setText(me.commandPressBox, theCommandPress);
		me.nameBox.keyDown(me.commandPressBox, K_END, 0, 0);
	me.commandReleaseBox.setText(me.commandReleaseBox, theCommandRelease);
		me.nameBox.keyDown(me.commandReleaseBox, K_END, 0, 0);
}

void XonoticUserbindEditDialog_fill(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Name:")));
		me.TD(me, 1, me.columns - 1, me.nameBox = makeXonoticInputBox(0, string_null));
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Command when pressed:")));
		me.TD(me, 1, me.columns - 1, me.commandPressBox = makeXonoticInputBox(0, string_null));
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Command when released:")));
		me.TD(me, 1, me.columns - 1, me.commandReleaseBox = makeXonoticInputBox(0, string_null));
	me.TR(me);
		me.TD(me, 1, me.columns / 2, e = makeXonoticButton(_("Save"), '0 0 0'));
			e.onClick = XonoticUserbindEditDialog_Save;
			e.onClickEntity = me;
		me.TD(me, 1, me.columns / 2, e = makeXonoticButton(_("Cancel"), '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}
#endif
