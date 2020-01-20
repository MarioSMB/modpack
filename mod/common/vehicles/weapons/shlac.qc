#ifdef SVQC

void vwep_shlac_attack(entity actor, string tagname, entity gunmount, entity fireentity)
{
	vector v = gettaginfo(fireentity, gettagindex(fireentity, tagname));

	vehicles_projectile(gunmount, EFFECT_BLASTER_MUZZLEFLASH, SND_LASERGUN_FIRE,
                               v, normalize(v_forward + randomvec() * 0.001) * WEP_CVAR_PRI(hlac, speed),
                               WEP_CVAR_PRI(hlac, damage), WEP_CVAR_PRI(hlac, radius), WEP_CVAR_PRI(hlac, force),  0,
                               WEP_HLAC.m_id, PROJECTILE_HLAC, 0, true, true, actor);
}

#endif
