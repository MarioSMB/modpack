AUTOCVAR(g_mod_weapons, bool, false, "Enable extra weapons provided by the mod");

bool isModWeapon(int w)
{
	switch(w)
	{
		case WEP_LIGHTSABRE.m_id:
		case WEP_RPG.m_id:
		case WEP_FLAK.m_id:
		case WEP_ASSAULTRIFLE.m_id:
		case WEP_UZI.m_id:
		case WEP_CHAINSAW.m_id:
			return true;
		default:
			return false;
	}
}

REGISTER_MUTATOR(mod_weapons, autocvar_g_mod_weapons)
{
	MUTATOR_ONADD
	{
		// mark the guns as ok to use by e.g. impulse 99
		FOREACH(Weapons, it != WEP_Null, {
			if(isModWeapon(it.m_id))
				it.spawnflags &= ~WEP_FLAG_MUTATORBLOCKED;
		});
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		FOREACH(Weapons, it != WEP_Null, {
			if(isModWeapon(it.m_id))
				it.spawnflags |= WEP_FLAG_MUTATORBLOCKED;
		});
	}

	return false;
}
