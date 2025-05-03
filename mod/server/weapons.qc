// FEATURE: Shotgun bonk sound support, works if a sound is placed in sound/weapons/shotgun_melee_impact.ogg

SOUND(SHOTGUN_MELEE_IMPACT, W_Sound("shotgun_melee_impact"));

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
