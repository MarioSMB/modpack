#include "prydon.qh"

STATIC_INIT(prydon)
{
	cvar_settemp("scr_centertime", "50");
	cvar_settemp("hud_panel_centerprint_time", "50");
	cvar_settemp("cl_bob", "0");
	cvar_settemp("cl_rollangle", "0");
	cvar_settemp("cl_prydoncursor", "1");
	localcmd("alias m_on \"v_cshift 0 0 0 128\"\n");
	localcmd("alias m_off \"v_cshift 0 0 0 0\"\n");
	localcmd("+strafe\n");
	localcmd("-mlook\n");
}
