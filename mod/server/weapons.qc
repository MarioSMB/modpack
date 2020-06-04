AUTOCVAR(g_mod_weapons, bool, false, "Enable extra weapons provided by the mod");

REGISTER_MUTATOR(mod_weapons, autocvar_g_mod_weapons)
{
	MUTATOR_ONADD
	{
		// mark the guns as ok to use by e.g. impulse 99
		FOREACH(Weapons, it != WEP_Null, {
			if(it.spawnflags & WEP_FLAG_MODWEAPON)
				it.spawnflags &= ~WEP_FLAG_MUTATORBLOCKED;
		});
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		FOREACH(Weapons, it != WEP_Null, {
			if(it.spawnflags & WEP_FLAG_MODWEAPON)
				it.spawnflags |= WEP_FLAG_MUTATORBLOCKED;
		});
	}

	return false;
}
