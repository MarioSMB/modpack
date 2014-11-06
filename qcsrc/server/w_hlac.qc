#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ HLAC,
/* function  */ w_hlac,
/* ammotype  */ IT_CELLS,
/* impulse   */ 6,
/* flags     */ WEP_FLAG_MUTATORBLOCKED | WEP_FLAG_RELOADABLE | WEP_TYPE_SPLASH,
/* rating    */ BOT_PICKUP_RATING_MID,
/* model     */ "hlac",
/* shortname */ "hlac",
/* fullname  */ _("Heavy Laser Assault Cannon")
);
#else
#ifdef SVQC

void W_HLAC_Touch (void)
{
	PROJECTILE_TOUCH;

	self.event_damage = func_null;

	if(self.projectiledeathtype & HITTYPE_SECONDARY)
		RadiusDamage (self, self.realowner, autocvar_g_balance_hlac_secondary_damage, autocvar_g_balance_hlac_secondary_edgedamage, autocvar_g_balance_hlac_secondary_radius, world, autocvar_g_balance_hlac_secondary_force, self.projectiledeathtype, other);
	else
		RadiusDamage (self, self.realowner, autocvar_g_balance_hlac_primary_damage, autocvar_g_balance_hlac_primary_edgedamage, autocvar_g_balance_hlac_primary_radius, world, autocvar_g_balance_hlac_primary_force, self.projectiledeathtype, other);

	remove (self);
}

void W_HLAC_Attack (void)
{
	entity missile;
    float spread;

	W_DecreaseAmmo(ammo_cells, autocvar_g_balance_hlac_primary_ammo, autocvar_g_balance_hlac_reload_ammo);

    spread = autocvar_g_balance_hlac_primary_spread_min + (autocvar_g_balance_hlac_primary_spread_add * self.misc_bulletcounter);
    spread = min(spread,autocvar_g_balance_hlac_primary_spread_max);
    if(self.crouch)
        spread = spread * autocvar_g_balance_hlac_primary_spread_crouchmod;

	W_SetupShot (self, FALSE, 3, W_Sound("lasergun_fire"), CH_WEAPON_A, autocvar_g_balance_hlac_primary_damage, self.weapon);
	Send_Effect(EFFECT_LASER_MUZZLEFLASH, w_shotorg, w_shotdir * 1000, 1);
	if (!autocvar_g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	missile = spawn ();
	missile.owner = missile.realowner = self;
	missile.classname = "hlacbolt";
	missile.bot_dodge = TRUE;

    missile.bot_dodgerating = autocvar_g_balance_hlac_primary_damage;

	missile.movetype = MOVETYPE_FLY;
	PROJECTILE_MAKETRIGGER(missile);

	setorigin (missile, w_shotorg);
	setsize(missile, '0 0 0', '0 0 0');

	W_SetupProjectileVelocity(missile, autocvar_g_balance_hlac_primary_speed, spread);
	//missile.angles = vectoangles (missile.velocity); // csqc

	missile.touch = W_HLAC_Touch;
	missile.think = SUB_Remove;

    missile.nextthink = time + autocvar_g_balance_hlac_primary_lifetime;

	missile.flags = FL_PROJECTILE;
	missile.projectiledeathtype = WEP_HLAC;

	CSQCProjectile(missile, TRUE, PROJECTILE_HLAC, TRUE);

	other = missile; MUTATOR_CALLHOOK(EditProjectile);
}

void W_HLAC_Attack2f (void)
{
	entity missile;
    float spread;

    spread = autocvar_g_balance_hlac_secondary_spread;


    if(self.crouch)
        spread = spread * autocvar_g_balance_hlac_secondary_spread_crouchmod;

	W_SetupShot (self, FALSE, 3, W_Sound("lasergun_fire"), CH_WEAPON_A, autocvar_g_balance_hlac_secondary_damage, self.weapon);
	Send_Effect(EFFECT_LASER_MUZZLEFLASH, w_shotorg, w_shotdir * 1000, 1);

	missile = spawn ();
	missile.owner = missile.realowner = self;
	missile.classname = "hlacbolt";
	missile.bot_dodge = TRUE;

    missile.bot_dodgerating = autocvar_g_balance_hlac_secondary_damage;

	missile.movetype = MOVETYPE_FLY;
	PROJECTILE_MAKETRIGGER(missile);

	setorigin (missile, w_shotorg);
	setsize(missile, '0 0 0', '0 0 0');

	W_SetupProjectileVelocity(missile, autocvar_g_balance_hlac_secondary_speed, spread);
	//missile.angles = vectoangles (missile.velocity); // csqc

	missile.touch = W_HLAC_Touch;
	missile.think = SUB_Remove;

    missile.nextthink = time + autocvar_g_balance_hlac_secondary_lifetime;

	missile.flags = FL_PROJECTILE;
	missile.missile_flags = MIF_SPLASH;
	missile.projectiledeathtype = WEP_HLAC | HITTYPE_SECONDARY;

	CSQCProjectile(missile, TRUE, PROJECTILE_HLAC, TRUE);

	other = missile; MUTATOR_CALLHOOK(EditProjectile);
}

void W_HLAC_Attack2 (void)
{
    float i;

	W_DecreaseAmmo(ammo_cells, autocvar_g_balance_hlac_secondary_ammo, autocvar_g_balance_hlac_reload_ammo);

    for(i=autocvar_g_balance_hlac_secondary_shots;i>0;--i)
        W_HLAC_Attack2f();

	if (!autocvar_g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}
}

// weapon frames
void HLAC_fire1_02()
{
	if(self.weapon != self.switchweapon) // abort immediately if switching
	{
		w_ready();
		return;
	}

	if (self.BUTTON_ATCK)
	{
		if (!weapon_action(self.weapon, WR_CHECKAMMO1))
		if (!(self.items & IT_UNLIMITED_WEAPON_AMMO))
		{
			W_SwitchWeapon_Force(self, w_getbestweapon(self));
			w_ready();
			return;
		}

		ATTACK_FINISHED(self) = time + autocvar_g_balance_hlac_primary_refire * W_WeaponRateFactor();
		W_HLAC_Attack();
		self.misc_bulletcounter = self.misc_bulletcounter + 1;
        weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_hlac_primary_refire, HLAC_fire1_02);
	}
	else
	{
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_hlac_primary_animtime, w_ready);
	}
}

void spawnfunc_weapon_hlac (void)
{
	weapon_defaultspawnfunc(WEP_HLAC);
}

float w_hlac(float req)
{
	float ammo_amount;
	if (req == WR_AIM)
        self.BUTTON_ATCK = bot_aim(autocvar_g_balance_hlac_primary_speed, 0, autocvar_g_balance_hlac_primary_lifetime, FALSE);
	else if (req == WR_THINK)
	{
		if(autocvar_g_balance_hlac_reload_ammo && self.clip_load < min(autocvar_g_balance_hlac_primary_ammo, autocvar_g_balance_hlac_secondary_ammo)) // forced reload
			weapon_action(self.weapon, WR_RELOAD);
		else if (self.BUTTON_ATCK)
		{
			if (weapon_prepareattack(0, autocvar_g_balance_hlac_primary_refire))
			{
				self.misc_bulletcounter = 0;
				W_HLAC_Attack();
				weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_hlac_primary_refire, HLAC_fire1_02);
			}
		}

		else if (self.BUTTON_ATCK2 && autocvar_g_balance_hlac_secondary)
		{
			if (weapon_prepareattack(1, autocvar_g_balance_hlac_secondary_refire))
			{
				W_HLAC_Attack2();
				weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_hlac_secondary_animtime, w_ready);
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
        precache_model ("models/weapons/g_hlac.md3");
		precache_model ("models/weapons/v_hlac.md3");
		precache_model ("models/weapons/h_hlac.iqm");
		precache_sound (W_Sound("lasergun_fire"));
		//precache_sound (W_Sound("reload")); // until weapons have individual reload sounds, precache the reload sound somewhere else

	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_HLAC);
		self.current_ammo = ammo_cells;
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_cells >= autocvar_g_balance_hlac_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_HLAC]) >= autocvar_g_balance_hlac_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		ammo_amount = self.ammo_cells >= autocvar_g_balance_hlac_secondary_ammo;
		ammo_amount += self.(weapon_load[WEP_HLAC]) >= autocvar_g_balance_hlac_secondary_ammo;
		return ammo_amount;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(min(autocvar_g_balance_hlac_primary_ammo, autocvar_g_balance_hlac_secondary_ammo), autocvar_g_balance_hlac_reload_ammo, autocvar_g_balance_hlac_reload_time, W_Sound("reload"));
	}
	else if (req == WR_SUICIDEMESSAGE)
	{
		return WEAPON_HLAC_SUICIDE;
	}
	else if (req == WR_KILLMESSAGE)
	{
		return WEAPON_HLAC_MURDER;
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_hlac(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 6;
		pointparticles(particleeffectnum("laser_impact"), org2, w_backoff * 1000, 1);
		if(!w_issilent)
			sound(self, CH_SHOTS, "weapons/laserimpact.wav", VOL_BASE, ATTEN_NORM);
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/laserimpact.wav");
	}
	return TRUE;
}
#endif
#endif
