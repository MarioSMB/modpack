#ifdef INTERFACE
CLASS(XonoticHUDConfirmDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticHUDConfirmDialog, fill, void(entity))
	ATTRIB(XonoticHUDConfirmDialog, title, string, _("Enter HUD editor"))
	ATTRIB(XonoticHUDConfirmDialog, color, vector, SKINCOLOR_DIALOG_HUDCONFIRM)
	ATTRIB(XonoticHUDConfirmDialog, intendedWidth, float, 0.5)
	ATTRIB(XonoticHUDConfirmDialog, rows, float, 4)
	ATTRIB(XonoticHUDConfirmDialog, columns, float, 2)
ENDCLASS(XonoticHUDConfirmDialog)
#endif

#ifdef IMPLEMENTATION
void HUDSetup_Start(entity me, entity btn)
{
	if not(gamestatus & (GAME_CONNECTED | GAME_ISSERVER))
		localcmd("map hudsetup/hudsetup", "\n");
	else
		localcmd("togglemenu 0\n");
		
	localcmd("_hud_configure 1", "\n");
}

void XonoticHUDConfirmDialog_fill(entity me)
{
	entity e;

	me.TR(me);
		me.TD(me, 1, 2, e = makeXonoticTextLabel(0.5, _("In order for the HUD editor to show, you must first be in game.")));
	me.TR(me);
		me.TD(me, 1, 2, e = makeXonoticTextLabel(0.5, _("Do you wish to start a local game to set up the HUD?")));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticButton(ZCTX(_("HDCNFRM^Yes")), '1 0 0'));
			e.onClick = HUDSetup_Start;
			e.onClickEntity = me;
		me.TD(me, 1, 1, e = makeXonoticButton(ZCTX(_("HDCNFRM^No")), '0 1 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}
#endif
