#ifdef INTERFACE
CLASS(XonoticHUDDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticHUDDialog, toString, string(entity))
	METHOD(XonoticHUDDialog, fill, void(entity))
	METHOD(XonoticHUDDialog, showNotify, void(entity))
	ATTRIB(XonoticHUDDialog, title, string, _("HUD settings"))
	ATTRIB(XonoticHUDDialog, color, vector, SKINCOLOR_DIALOG_HUD)
	ATTRIB(XonoticHUDDialog, intendedWidth, float, 0.5)
	ATTRIB(XonoticHUDDialog, rows, float, 18)
	ATTRIB(XonoticHUDDialog, columns, float, 3)
ENDCLASS(XonoticHUDDialog)
void HUDSetup_Start(entity me, entity btn);
#endif

#ifdef IMPLEMENTATION
void HUDSetup_Check_Gamestatus(entity me, entity btn)
{
	if not(gamestatus & (GAME_CONNECTED | GAME_ISSERVER)) // we're not in a match, ask the player if they want to start one anyway
	{
		DialogOpenButton_Click(me, main.hudconfirmDialog);
	}
	else // already in a match, lets just cut to the point and open up the hud editor directly
	{
		HUDSetup_Start(me, btn);
	}
}
void XonoticHUDDialog_showNotify(entity me)
{
	loadAllCvars(me);
}
string XonoticHUDDialog_toString(entity me)
{
	return "hi"; // TODO: show hud config name with text here 
}
void XonoticHUDDialog_fill(entity me)
{
	entity e;
	
	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticTextLabel(0, _("Damage:")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Overlay:")));
		me.TD(me, 1, 2, e = makeXonoticSlider(0, 1, 0.05, "hud_damage"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Factor:")));
		setDependent(e, "hud_damage", 0.001, 100);
		me.TD(me, 1, 2, e = makeXonoticSlider(0.025, 0.1, 0.025, "hud_damage_factor"));
		setDependent(e, "hud_damage", 0.001, 100);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Fade rate:")));
		setDependent(e, "hud_damage", 0.001, 100);
		me.TD(me, 1, 2, e = makeXonoticSlider(0.25, 1, 0.05, "hud_damage_fade_rate"));
		setDependent(e, "hud_damage", 0.001, 100);
	me.TR(me);
	
	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticCheckBox(1, "cl_hidewaypoints", _("Waypoints")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Scale:")));
		setDependent(e, "cl_hidewaypoints", 0, 0);
		me.TD(me, 1, 2, e = makeXonoticSlider(0.5, 1.5, 0.05, "g_waypointsprite_scale"));
		setDependent(e, "cl_hidewaypoints", 0, 0);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Alpha:")));
		setDependent(e, "cl_hidewaypoints", 0, 0);
		me.TD(me, 1, 2, e = makeXonoticSlider(0.1, 1, 0.05, "g_waypointsprite_alpha"));
		setDependent(e, "cl_hidewaypoints", 0, 0);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Edge offset:")));
		setDependent(e, "cl_hidewaypoints", 0, 0);
		me.TD(me, 1, 2, e = makeXonoticSlider(0, 0.3, 0.01, "g_waypointsprite_edgeoffset_bottom"));
		makeMulti(e, "g_waypointsprite_edgeoffset_top g_waypointsprite_edgeoffset_left g_waypointsprite_edgeoffset_right");
		setDependent(e, "cl_hidewaypoints", 0, 0);
	me.TR(me);
	
	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticCheckBox(0, "hud_shownames", _("Show names above players")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticCheckBoxEx(25, 0, "hud_shownames_crosshairdistance", _("Only when near crosshair")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticCheckBox(0, "hud_shownames_status", _("Display health and armor")));
	me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.5);
		me.TD(me, 1, 2, e = makeXonoticButton(_("Enter HUD editor"), '0 0 0'));
			e.onClick = HUDSetup_Check_Gamestatus;
			e.onClickEntity = me;
		// TODO: show hud config name with text here 
		
	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeXonoticButton(_("OK"), '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}
#endif