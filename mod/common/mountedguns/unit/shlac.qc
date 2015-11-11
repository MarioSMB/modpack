#ifdef SVQC

void shlac_touch(void)
{
	PROJECTILE_TOUCH;

	self.event_damage = func_null;

	bool isprimary = !(self.projectiledeathtype & HITTYPE_SECONDARY);

	RadiusDamage(self, self.realowner, WEP_CVAR_BOTH(hlac, isprimary, damage), WEP_CVAR_BOTH(hlac, isprimary, edgedamage), WEP_CVAR_BOTH(hlac, isprimary, radius), 
		self.realowner.vehicle, world, WEP_CVAR_BOTH(hlac, isprimary, force), self.projectiledeathtype, other);

	remove(self);
}

void mg_shlac_attack(string tagname, entity fireentity)
{
	vector v;
	v = gettaginfo(fireentity, gettagindex(fireentity, tagname));
	
	entity missile;
	float spread;

	spread = WEP_CVAR_PRI(hlac, spread_min) * 0.1;

	W_SetupShot (self, false, 3, SND(LASERGUN_FIRE), CH_WEAPON_A, WEP_CVAR_PRI(hlac, damage));
	Send_Effect(EFFECT_BLASTER_MUZZLEFLASH, v, v_forward * 1000, 1);
	if (!autocvar_g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	missile = spawn ();
	//missile.owner = missile.realowner = self;
	missile.owner = self;
	missile.realowner = self.owner;
	missile.classname = "hlacbolt";
	missile.bot_dodge = true;

	missile.bot_dodgerating = WEP_CVAR_PRI(hlac, damage);

	missile.movetype = MOVETYPE_FLY;
	PROJECTILE_MAKETRIGGER(missile);

	setorigin (missile, v);
	setsize(missile, '0 0 0', '0 0 0');

	//W_SetupProjectileVelocity(missile, WEP_CVAR_PRI(hlac, speed), spread);
	missile.velocity = w_shotdir * WEP_CVAR_PRI(hlac, speed);
	missile.velocity = W_CalculateProjectileVelocity(missile.realowner.velocity, missile.velocity, true);
	//missile.angles = vectoangles (missile.velocity); // csqc

	missile.touch = shlac_touch;
	missile.think = SUB_Remove;

	missile.nextthink = time + WEP_CVAR_PRI(hlac, lifetime);

	missile.flags = FL_PROJECTILE;
	missile.projectiledeathtype = WEP_HLAC.m_id;

	CSQCProjectile(missile, true, PROJECTILE_HLAC, true);

	MUTATOR_CALLHOOK(EditProjectile, self, missile);
}

void mg_shlac_fire(entity mg_shlac, entity player, entity gunmount) 
{
	mg_shlac.cnt = time;
	if(mg_shlac.vehicle_ammo1 >= autocvar_g_mountedgun_shlac_railgun_ammo_cost && gunmount.attack_finished_single[0] <= time)
	{
		vector v;
		mg_shlac.misc_bulletcounter += 1;

		self = mg_shlac;
		
		makevectors(self.angles);
		v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun1"));
			v_forward = normalize(v_forward);
	
		mg_shlac_attack("tag_mgun1", gunmount);
		mg_shlac_attack("tag_mgun2", gunmount);
		mg_shlac_attack("tag_mgun3", gunmount);
		mg_shlac_attack("tag_mgun4", gunmount);
		mg_shlac_attack("tag_mgun5", gunmount);

		self = mg_shlac;

		mg_shlac.vehicle_ammo1 -= autocvar_g_mountedgun_shlac_railgun_ammo_cost;
		gunmount.attack_finished_single[0] = time + autocvar_g_mountedgun_shlac_railgun_refire;
		player.vehicle_ammo1 = (mg_shlac.vehicle_ammo1 / autocvar_g_mountedgun_shlac_railgun_ammo_max) * 100;
	}
}

#endif
