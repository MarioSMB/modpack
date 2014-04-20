#ifdef INTERFACE
CLASS(XonoticQuitDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticQuitDialog, fill, void(entity))
	ATTRIB(XonoticQuitDialog, title, string, _("Quit"))
	ATTRIB(XonoticQuitDialog, color, vector, SKINCOLOR_DIALOG_QUIT)
	ATTRIB(XonoticQuitDialog, intendedWidth, float, 0.5)
	ATTRIB(XonoticQuitDialog, rows, float, 3)
	ATTRIB(XonoticQuitDialog, columns, float, 2)
	ATTRIB(XonoticQuitDialog, name, string, "Quit")
ENDCLASS(XonoticQuitDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticQuitDialog_fill(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, 1, 2, makeXonoticTextLabel(0.5, _("Are you sure you want to quit?")));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticCommandButton(_("Yes"), '1 0 0', "echo ]quit\nquit", 0));
		me.TD(me, 1, 1, e = makeXonoticButton(_("No"), '0 1 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}
#endif
