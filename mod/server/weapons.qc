// FEATURE: Shotgun bonk sound support, works if a sound is placed in sound/weapons/shotgun_melee_impact.ogg

AUTOCVAR(g_mod_weapons, bool, false, "Enable extra weapons provided by the mod");

SOUND(SHOTGUN_MELEE_IMPACT, W_Sound("shotgun_melee_impact"));

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

MUTATOR_HOOKFUNCTION(mutator_mod, PlayerDamaged)
{
	entity frag_target = M_ARGV(1, entity);
	int frag_deathtype = M_ARGV(5, int);

	if(DEATH_ISWEAPON(frag_deathtype, WEP_SHOTGUN) && (frag_deathtype & HITTYPE_SECONDARY))
	{
		// cheap check to see if it exists
		sound(frag_target, CH_SHOTS, SND_SHOTGUN_MELEE_IMPACT, VOL_BASE, ATTEN_NORM);
	}
}
