AUTOCVAR(g_akimbo, bool, false, "Enable Akimbo mutator (requires g_weaponswitch_debug 2)");

REGISTER_MUTATOR(akimbo, autocvar_g_akimbo && !g_nexball && autocvar_g_weaponswitch_debug == 2);

MUTATOR_HOOKFUNCTION(akimbo, ItemTouch)
{
	if(MUTATOR_RETURNVALUE == MUT_ITEMTOUCH_RETURN)
		return false; // already handled, probably didn't pick it up

	entity item = M_ARGV(0, entity);
	entity player = M_ARGV(1, entity);

	if(item.classname == "droppedweapon" && item.weapon && (player.weapons & item.itemdef.m_weapon.m_wepset) && item.owner != player && !(item.itemdef.m_weapon.spawnflags & WEP_FLAG_NODUAL))
		player.dual_weapons |= item.itemdef.m_weapon.m_wepset; // dual it up!
}

MUTATOR_HOOKFUNCTION(akimbo, FilterItem)
{
	entity item = M_ARGV(0, entity);

	if(item.classname == "droppedweapon" && item.weapon && item.owner)
		item.owner.dual_weapons &= ~item.itemdef.m_weapon.m_wepset; // no longer akimbo'd (we don't check blacklist here, no need)
}
