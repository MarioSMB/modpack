#ifdef INTERFACE
CLASS(XonoticHUDRaceTimerDialog) EXTENDS(XonoticRootDialog)
	METHOD(XonoticHUDRaceTimerDialog, fill, void(entity))
	ATTRIB(XonoticHUDRaceTimerDialog, title, string, _("Race Timer Panel"))
	ATTRIB(XonoticHUDRaceTimerDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(XonoticHUDRaceTimerDialog, intendedWidth, float, 0.4)
	ATTRIB(XonoticHUDRaceTimerDialog, rows, float, 15)
	ATTRIB(XonoticHUDRaceTimerDialog, columns, float, 4)
	ATTRIB(XonoticHUDRaceTimerDialog, name, string, "HUDracetimer")
ENDCLASS(XonoticHUDRaceTimerDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticHUDRaceTimerDialog_fill(entity me)
{
	entity e;
	string panelname = "racetimer";

	DIALOG_HUDPANEL_COMMON();
}
#endif
