//FEATURE: Akimbo mutator for all your dual wielding needs

AUTOCVAR(g_akimbo, bool, false, "Enable Akimbo mutator (requires g_weaponswitch_debug 2)");

REGISTER_MUTATOR(akimbo, autocvar_g_akimbo && !g_nexball && autocvar_g_weaponswitch_debug == 2);

MUTATOR_HOOKFUNCTION(akimbo, ItemTouch)
{
	if(MUTATOR_RETURNVALUE == MUT_ITEMTOUCH_RETURN)
		return false; // already handled, probably didn't pick it up

	entity item = M_ARGV(0, entity);
	entity player = M_ARGV(1, entity);

	if(Item_IsLoot(item) && item.weapon && (STAT(WEAPONS, player) & item.itemdef.m_weapon.m_wepset) && item.owner != player && !(item.itemdef.m_weapon.spawnflags & WEP_FLAG_NODUAL))
		PS(player).dual_weapons |= item.itemdef.m_weapon.m_wepset; // dual it up!
}

MUTATOR_HOOKFUNCTION(akimbo, FilterItem)
{
	entity item = M_ARGV(0, entity);

	if(Item_IsLoot(item) && item.weapon && item.owner && IS_PLAYER(item.owner))
		PS(item.owner).dual_weapons &= ~item.itemdef.m_weapon.m_wepset; // no longer akimbo'd (we don't check blacklist here, no need)
}
