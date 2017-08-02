#ifdef SVQC

void vwep_shlac_touch(entity this, entity toucher)
{
	PROJECTILE_TOUCH(this, toucher);

	this.event_damage = func_null;

	bool isprimary = !(this.projectiledeathtype & HITTYPE_SECONDARY);

	RadiusDamage(this, this.realowner, WEP_CVAR_BOTH(hlac, isprimary, damage), WEP_CVAR_BOTH(hlac, isprimary, edgedamage), WEP_CVAR_BOTH(hlac, isprimary, radius), 
					   this.realowner.vehicle, NULL, WEP_CVAR_BOTH(hlac, isprimary, force), this.projectiledeathtype, toucher);

	delete(this);
}

void vwep_shlac_attack(entity actor, string tagname, entity gunmount, entity fireentity)
{
	vector v = gettaginfo(fireentity, gettagindex(fireentity, tagname));

	//float spread = WEP_CVAR_PRI(hlac, spread_min) * 0.1;

	W_SetupShot (actor, weaponentities[0], false, 3, SND_LASERGUN_FIRE, CH_WEAPON_A, WEP_CVAR_PRI(hlac, damage));
	Send_Effect(EFFECT_BLASTER_MUZZLEFLASH, v, v_forward * 1000, 1);
	if (!autocvar_g_norecoil)
	{
		actor.punchangle_x = random () - 0.5;
		actor.punchangle_y = random () - 0.5;
	}

	entity missile = new(hlacbolt);
	//missile.owner = missile.realowner = actor;
	missile.owner = gunmount;
	missile.realowner = actor;
	missile.bot_dodge = true;

	missile.bot_dodgerating = WEP_CVAR_PRI(hlac, damage);

	set_movetype(missile, MOVETYPE_FLY);
	PROJECTILE_MAKETRIGGER(missile);

	setorigin (missile, v);
	setsize(missile, '0 0 0', '0 0 0');

	//W_SetupProjectileVelocity(missile, WEP_CVAR_PRI(hlac, speed), spread);
	missile.velocity = w_shotdir * WEP_CVAR_PRI(hlac, speed);
	missile.velocity = W_CalculateProjectileVelocity(missile.realowner, missile.realowner.velocity, missile.velocity, true);
	//missile.angles = vectoangles (missile.velocity); // csqc

	settouch(missile, vwep_shlac_touch);
	setthink(missile, SUB_Remove);

	missile.nextthink = time + WEP_CVAR_PRI(hlac, lifetime);

	missile.flags = FL_PROJECTILE;
	IL_PUSH(g_projectiles, missile);
	IL_PUSH(g_bot_dodge, missile);
	missile.projectiledeathtype = WEP_HLAC.m_id;

	CSQCProjectile(missile, true, PROJECTILE_HLAC, true);

	MUTATOR_CALLHOOK(EditProjectile, actor, missile);
}

#endif
