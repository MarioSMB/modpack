#ifdef INTERFACE
CLASS(XonoticHUDModIconsDialog) EXTENDS(XonoticRootDialog)
	METHOD(XonoticHUDModIconsDialog, fill, void(entity))
	ATTRIB(XonoticHUDModIconsDialog, title, string, _("Mod Icons Panel"))
	ATTRIB(XonoticHUDModIconsDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(XonoticHUDModIconsDialog, intendedWidth, float, 0.4)
	ATTRIB(XonoticHUDModIconsDialog, rows, float, 15)
	ATTRIB(XonoticHUDModIconsDialog, columns, float, 4)
	ATTRIB(XonoticHUDModIconsDialog, name, string, "HUDmodicons")
ENDCLASS(XonoticHUDModIconsDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticHUDModIconsDialog_fill(entity me)
{
	entity e;
	string panelname = "modicons";

	DIALOG_HUDPANEL_COMMON();
}
#endif
