#ifdef INTERFACE
CLASS(XonoticMonsterToolsDialog) EXTENDS(XonoticRootDialog)
	METHOD(XonoticMonsterToolsDialog, fill, void(entity)) // to be overridden by user to fill the dialog with controls
	ATTRIB(XonoticMonsterToolsDialog, title, string, _("Monster Tools"))
	ATTRIB(XonoticMonsterToolsDialog, color, vector, SKINCOLOR_DIALOG_SANDBOXTOOLS)
	ATTRIB(XonoticMonsterToolsDialog, intendedWidth, float, 0.8)
	ATTRIB(XonoticMonsterToolsDialog, rows, float, 16)
	ATTRIB(XonoticMonsterToolsDialog, columns, float, 4)
	ATTRIB(XonoticMonsterToolsDialog, name, string, "MonsterTools")
ENDCLASS(XonoticMonsterToolsDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticMonsterToolsDialog_fill(entity me)
{
	entity e;

	me.TR(me);
		me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Monster:")));
	me.TR(me);
		me.TD(me, 1, 0.4, e = makeXonoticRadioButton(2, "menu_monsters_edit_spawn", "zombie", _("Zombie")));
		me.TD(me, 1, 0.4, e = makeXonoticRadioButton(2, "menu_monsters_edit_spawn", "spider", _("Spider")));
		me.TD(me, 1, 0.4, e = makeXonoticRadioButton(2, "menu_monsters_edit_spawn", "shambler", _("Shambler")));
		me.TD(me, 1, 0.4, e = makeXonoticRadioButton(2, "menu_monsters_edit_spawn", "mage", _("Mage")));
		me.TD(me, 1, 0.4, e = makeXonoticRadioButton(2, "menu_monsters_edit_spawn", "wyvern", _("Wyvern")));
	me.TR(me);
		me.TDempty(me, 0.1);
		me.TD(me, 1, 0.5, e = makeXonoticCommandButton(_("Spawn"), '0 0 0', "cmd mobspawn $menu_monsters_edit_spawn $menu_monsters_edit_movetarget", 0));
		me.TD(me, 1, 0.5, e = makeXonoticCommandButton(_("Remove"), '0 0 0', "cmd mobkill", 0));
	me.TR(me);
		me.TD(me, 1, 0.5, e = makeXonoticCommandButton(_("Move target:"), '0 0 0', "editmob movetarget $menu_monsters_edit_movetarget", 0));
		me.TD(me, 1, 0.5, e = makeXonoticRadioButton(2, "menu_monsters_edit_movetarget", "1", _("Follow")));
		me.TD(me, 1, 0.5, e = makeXonoticRadioButton(2, "menu_monsters_edit_movetarget", "2", _("Wander")));
		me.TD(me, 1, 0.5, e = makeXonoticRadioButton(2, "menu_monsters_edit_movetarget", "3", _("Spawnpoint")));
		me.TD(me, 1, 0.5, e = makeXonoticRadioButton(2, "menu_monsters_edit_movetarget", "4", _("No moving")));
	me.TR(me);
	me.TD(me, 1, 1.5, e = makeXonoticTextLabel(0, _("Colors:")));
	me.TR(me);
		me.TD(me, 1, 0.5, e = makeXonoticCommandButton(_("Set skin:"), '0 0 0', "editmob skin $menu_monsters_edit_skin", 0));
		me.TD(me, 1, 1.5, e = makeXonoticSlider(0, 99, 1, "menu_monsters_edit_skin"));
	me.TR(me);

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeXonoticButton(_("OK"), '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}
#endif

/* Click. The c-word is here so you can grep for it :-) */
