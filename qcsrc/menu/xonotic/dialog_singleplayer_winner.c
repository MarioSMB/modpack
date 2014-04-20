#ifdef INTERFACE
CLASS(XonoticWinnerDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticWinnerDialog, fill, void(entity))
	ATTRIB(XonoticWinnerDialog, title, string, _("Winner"))
	ATTRIB(XonoticWinnerDialog, color, vector, SKINCOLOR_DIALOG_SINGLEPLAYER)
	ATTRIB(XonoticWinnerDialog, intendedWidth, float, 0.32)
	ATTRIB(XonoticWinnerDialog, rows, float, 12)
	ATTRIB(XonoticWinnerDialog, columns, float, 3)
ENDCLASS(XonoticWinnerDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticWinnerDialog_fill(entity me)
{
	entity e;

	me.TR(me);
		me.TD(me, me.rows - 2, me.columns, e = makeXonoticImage("/gfx/winner", -1));

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeXonoticButton(_("OK"), '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}
#endif
