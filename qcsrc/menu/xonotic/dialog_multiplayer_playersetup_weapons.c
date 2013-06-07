#ifdef INTERFACE
CLASS(XonoticWeaponsDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticWeaponsDialog, toString, string(entity))
	METHOD(XonoticWeaponsDialog, fill, void(entity))
	METHOD(XonoticWeaponsDialog, showNotify, void(entity))
	ATTRIB(XonoticWeaponsDialog, title, string, _("Weapon settings"))
	ATTRIB(XonoticWeaponsDialog, color, vector, SKINCOLOR_DIALOG_WEAPONS)
	ATTRIB(XonoticWeaponsDialog, intendedWidth, float, 0.7)
	ATTRIB(XonoticWeaponsDialog, rows, float, 12)
	ATTRIB(XonoticWeaponsDialog, columns, float, 5.2)
	ATTRIB(XonoticWeaponsDialog, weaponsList, entity, NULL)
ENDCLASS(XonoticWeaponsDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticWeaponsDialog_showNotify(entity me)
{
        loadAllCvars(me);
}
string XonoticWeaponsDialog_toString(entity me)
{
	return me.weaponsList.toString(me.weaponsList);
}
void XonoticWeaponsDialog_fill(entity me)
{
	entity e;

	me.TR(me);
		me.TD(me, 1, 2, makeXonoticTextLabel(0, _("Weapon priority list:")));
	me.TR(me);
		me.TD(me, 8, 2, e = me.weaponsList = makeXonoticWeaponsList());
	me.gotoRC(me, 9, 0);
		me.TD(me, 1, 1, e = makeXonoticButton(_("Up"), '0 0 0'));
			e.onClick = WeaponsList_MoveUp_Click;
			e.onClickEntity = me.weaponsList;
		me.TD(me, 1, 1, e = makeXonoticButton(_("Down"), '0 0 0'));
			e.onClick = WeaponsList_MoveDown_Click;
			e.onClickEntity = me.weaponsList;
			
	me.gotoRC(me, 0, 2.2); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 3, e = makeXonoticCheckBox(0, "cl_weaponpriority_useforcycling", _("Use priority list for weapon cycling")));
	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticCheckBox(0, "cl_autoswitch", _("Auto switch weapons on pickup")));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticCheckBox(0, "r_drawviewmodel", _("Draw 1st person weapon model")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.9, e = makeXonoticRadioButton(1, "cl_gunalign", "4", _("Left align")));
			setDependent(e, "r_drawviewmodel", 1, 1);
		me.TD(me, 1, 0.9, e = makeXonoticRadioButton(1, "cl_gunalign", "1", _("Center")));
			setDependent(e, "r_drawviewmodel", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticRadioButton(1, "cl_gunalign", "3", _("Right align")));
			setDependent(e, "r_drawviewmodel", 1, 1);
	me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticCheckBox(0, "cl_followmodel", _("Gun model swaying")));
		makeMulti(e, "cl_leanmodel");
		setDependent(e, "r_drawviewmodel", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticCheckBox(0, "cl_bobmodel", _("Gun model bobbing")));
		setDependent(e, "r_drawviewmodel", 1, 1);
	//me.TR(me);
	//me.TR(me);
	//	me.TDempty(me, 0.2);
	//	me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, ZCTX(_("VWMDL^Scale"))));
	//	setDependent(e, "r_drawviewmodel", 1, 1);
	//	me.TD(me, 1, 2, e = makeXonoticSlider(0.1, 2, 0.1, "cl_viewmodel_scale"));
	//	setDependent(e, "r_drawviewmodel", 1, 1);
			
	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeXonoticButton(_("OK"), '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}
#endif
