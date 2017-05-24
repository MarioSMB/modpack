AUTOCVAR(g_akimbo, bool, false, "Enable Akimbo mutator (requires g_weaponswitch_debug 2)");

REGISTER_MUTATOR(akimbo, autocvar_g_akimbo && !g_nexball && autocvar_g_weaponswitch_debug == 2);

bool akimbo_weapon_blacklisted(Weapon wep)
{
	switch(wep)
	{
		case WEP_DEVASTATOR:
		case WEP_VORTEX:
		case WEP_RPG:
		case WEP_FIREBALL:
		case WEP_PORTO:
		case WEP_CRYLINK:
			return true;
		default:
			return false;
	}

	return false;
}

MUTATOR_HOOKFUNCTION(akimbo, ItemTouch)
{
	if(MUTATOR_RETURNVALUE == MUT_ITEMTOUCH_RETURN)
		return false; // already handled, probably didn't pick it up

	entity item = M_ARGV(0, entity);
	entity player = M_ARGV(1, entity);

	if(item.classname == "droppedweapon" && item.weapon && (player.weapons & item.itemdef.m_weapon.m_wepset) && item.owner != player && !akimbo_weapon_blacklisted(item.itemdef.m_weapon))
		player.dual_weapons |= item.itemdef.m_weapon.m_wepset; // dual it up!
}

MUTATOR_HOOKFUNCTION(akimbo, FilterItem)
{
	entity item = M_ARGV(0, entity);

	if(item.classname == "droppedweapon" && item.weapon && item.owner)
		item.owner.dual_weapons &= ~item.itemdef.m_weapon.m_wepset; // no longer akimbo'd (we don't check blacklist here, no need)
}
