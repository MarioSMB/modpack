#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ HLAC,
/* function  */ W_HLAC,
/* ammotype  */ ammo_cells,
/* impulse   */ 6,
/* flags     */ WEP_FLAG_MUTATORBLOCKED | WEP_FLAG_RELOADABLE | WEP_TYPE_SPLASH,
/* rating    */ BOT_PICKUP_RATING_MID,
/* color     */ '0 1 0',
/* modelname */ "hlac",
/* simplemdl */ "foobar",
/* crosshair */ "gfx/crosshairhlac 0.6",
/* wepimg    */ "weaponhlac",
/* refname   */ "hlac",
/* wepname   */ _("Heavy Laser Assault Cannon")
);

#define HLAC_SETTINGS(w_cvar,w_prop) HLAC_SETTINGS_LIST(w_cvar, w_prop, HLAC, hlac)
#define HLAC_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, BOTH, ammo) \
	w_cvar(id, sn, BOTH, animtime) \
	w_cvar(id, sn, BOTH, damage) \
	w_cvar(id, sn, BOTH, edgedamage) \
	w_cvar(id, sn, BOTH, force) \
	w_cvar(id, sn, BOTH, lifetime) \
	w_cvar(id, sn, BOTH, radius) \
	w_cvar(id, sn, BOTH, refire) \
	w_cvar(id, sn, BOTH, speed) \
	w_cvar(id, sn, BOTH, spread_crouchmod) \
	w_cvar(id, sn, PRI,  spread_add) \
	w_cvar(id, sn, PRI,  spread_max) \
	w_cvar(id, sn, PRI,  spread_min) \
	w_cvar(id, sn, NONE, secondary) \
	w_cvar(id, sn, SEC,  shots) \
	w_cvar(id, sn, SEC,  spread) \
	w_prop(id, sn, float,  reloading_ammo, reload_ammo) \
	w_prop(id, sn, float,  reloading_time, reload_time) \
	w_prop(id, sn, float,  switchdelay_raise, switchdelay_raise) \
	w_prop(id, sn, float,  switchdelay_drop, switchdelay_drop) \
	w_prop(id, sn, string, weaponreplace, weaponreplace) \
	w_prop(id, sn, float,  weaponstart, weaponstart) \
	w_prop(id, sn, float,  weaponstartoverride, weaponstartoverride) \
	w_prop(id, sn, float,  weaponthrowable, weaponthrowable)

#ifdef SVQC
HLAC_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
#endif
#else
#ifdef SVQC
void spawnfunc_weapon_hlac(void) { weapon_defaultspawnfunc(WEP_HLAC); }

void W_HLAC_Touch(void)
{
	float isprimary;

	PROJECTILE_TOUCH;

	self.event_damage = func_null;
	
	isprimary = !(self.projectiledeathtype & HITTYPE_SECONDARY);
	
	RadiusDamage(self, self.realowner, WEP_CVAR_BOTH(hlac, isprimary, damage), WEP_CVAR_BOTH(hlac, isprimary, edgedamage), WEP_CVAR_BOTH(hlac, isprimary, radius), world, world, WEP_CVAR_BOTH(hlac, isprimary, force), self.projectiledeathtype, other);

	remove(self);
}

void W_HLAC_Attack(void)
{
	entity missile;
    float spread;

	W_DecreaseAmmo(WEP_CVAR_PRI(hlac, ammo));

    spread = WEP_CVAR_PRI(hlac, spread_min) + (WEP_CVAR_PRI(hlac, spread_add) * self.misc_bulletcounter);
    spread = min(spread,WEP_CVAR_PRI(hlac, spread_max));
    if(self.crouch)
        spread = spread * WEP_CVAR_PRI(hlac, spread_crouchmod);

	W_SetupShot(self, FALSE, 3, "weapons/lasergun_fire.wav", CH_WEAPON_A, WEP_CVAR_PRI(hlac, damage));
	pointparticles(particleeffectnum("laser_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);
	if(!autocvar_g_norecoil)
	{
		self.punchangle_x = random() - 0.5;
		self.punchangle_y = random() - 0.5;
	}

	missile = spawn();
	missile.owner = missile.realowner = self;
	missile.classname = "hlacbolt";
	missile.bot_dodge = TRUE;

    missile.bot_dodgerating = WEP_CVAR_PRI(hlac, damage);

	missile.movetype = MOVETYPE_FLY;
	PROJECTILE_MAKETRIGGER(missile);

	setorigin(missile, w_shotorg);
	setsize(missile, '0 0 0', '0 0 0');

	W_SetupProjVelocity_Basic(missile, WEP_CVAR_PRI(hlac, speed), spread);
	//missile.angles = vectoangles(missile.velocity); // csqc

	missile.touch = W_HLAC_Touch;
	missile.think = SUB_Remove;

    missile.nextthink = time + WEP_CVAR_PRI(hlac, lifetime);

	missile.flags = FL_PROJECTILE;
	missile.projectiledeathtype = WEP_HLAC;

	CSQCProjectile(missile, TRUE, PROJECTILE_HLAC, TRUE);

	other = missile; MUTATOR_CALLHOOK(EditProjectile);
}

void W_HLAC_Attack2(void)
{
	entity missile;
    float spread;

    spread = WEP_CVAR_SEC(hlac, spread);


    if(self.crouch)
        spread = spread * WEP_CVAR_SEC(hlac, spread_crouchmod);

	W_SetupShot(self, FALSE, 3, "weapons/lasergun_fire.wav", CH_WEAPON_A, WEP_CVAR_SEC(hlac, damage));
	pointparticles(particleeffectnum("laser_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	missile = spawn();
	missile.owner = missile.realowner = self;
	missile.classname = "hlacbolt";
	missile.bot_dodge = TRUE;

    missile.bot_dodgerating = WEP_CVAR_SEC(hlac, damage);

	missile.movetype = MOVETYPE_FLY;
	PROJECTILE_MAKETRIGGER(missile);

	setorigin(missile, w_shotorg);
	setsize(missile, '0 0 0', '0 0 0');

	W_SetupProjVelocity_Basic(missile, WEP_CVAR_SEC(hlac, speed), spread);
	//missile.angles = vectoangles(missile.velocity); // csqc

	missile.touch = W_HLAC_Touch;
	missile.think = SUB_Remove;

    missile.nextthink = time + WEP_CVAR_SEC(hlac, lifetime);

	missile.flags = FL_PROJECTILE;
	missile.missile_flags = MIF_SPLASH; 
	missile.projectiledeathtype = WEP_HLAC | HITTYPE_SECONDARY;

	CSQCProjectile(missile, TRUE, PROJECTILE_HLAC, TRUE);

	other = missile; MUTATOR_CALLHOOK(EditProjectile);
}

// weapon frames
void W_HLAC_Attack_Frame(void)
{
	if(self.weapon != self.switchweapon) // abort immediately if switching
	{
		w_ready();
		return;
	}

	if(self.BUTTON_ATCK)
	{
		if(!WEP_ACTION(self.weapon, WR_CHECKAMMO1))
		if(!(self.items & IT_UNLIMITED_WEAPON_AMMO))
		{
			W_SwitchWeapon_Force(self, w_getbestweapon(self));
			w_ready();
			return;
		}

		ATTACK_FINISHED(self) = time + WEP_CVAR_PRI(hlac, refire) * W_WeaponRateFactor();
		W_HLAC_Attack();
		self.misc_bulletcounter = self.misc_bulletcounter + 1;
        weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_PRI(hlac, refire), W_HLAC_Attack_Frame);
	}
	else
	{
		weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_PRI(hlac, animtime), w_ready);
	}
}

void W_HLAC_Attack2_Frame(void)
{
    float i;

	W_DecreaseAmmo(WEP_CVAR_SEC(hlac, ammo));

    for(i=WEP_CVAR_SEC(hlac, shots);i>0;--i)
        W_HLAC_Attack2();

	if(!autocvar_g_norecoil)
	{
		self.punchangle_x = random() - 0.5;
		self.punchangle_y = random() - 0.5;
	}
}

float W_HLAC(float req)
{
	float ammo_amount;
	switch(req)
	{
		case WR_AIM:
		{
			self.BUTTON_ATCK = bot_aim(WEP_CVAR_PRI(hlac, speed), 0, WEP_CVAR_PRI(hlac, lifetime), FALSE);
			return TRUE;
		}
		case WR_THINK:
		{
			if(autocvar_g_balance_hlac_reload_ammo && self.clip_load < min(WEP_CVAR_PRI(hlac, ammo), WEP_CVAR_SEC(hlac, ammo))) // forced reload
				WEP_ACTION(self.weapon, WR_RELOAD);
			else if(self.BUTTON_ATCK)
			{
				if(weapon_prepareattack(0, WEP_CVAR_PRI(hlac, refire)))
				{
					self.misc_bulletcounter = 0;
					W_HLAC_Attack();
					weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_PRI(hlac, refire), W_HLAC_Attack_Frame);
				}
			}

			else if(self.BUTTON_ATCK2 && WEP_CVAR(hlac, secondary))
			{
				if(weapon_prepareattack(1, WEP_CVAR_SEC(hlac, refire)))
				{
					W_HLAC_Attack2_Frame();
					weapon_thinkf(WFRAME_FIRE2, WEP_CVAR_SEC(hlac, animtime), w_ready);
				}
			}
			
			return TRUE;
		}
		case WR_INIT:
		{
			precache_model("models/weapons/g_hlac.md3");
			precache_model("models/weapons/v_hlac.md3");
			precache_model("models/weapons/h_hlac.iqm");
			precache_sound("weapons/lasergun_fire.wav");
			HLAC_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP)
			return TRUE;
		}
		case WR_CHECKAMMO1:
		{
			ammo_amount = self.WEP_AMMO(HLAC) >= WEP_CVAR_PRI(hlac, ammo);
			ammo_amount += self.(weapon_load[WEP_HLAC]) >= WEP_CVAR_PRI(hlac, ammo);
			return ammo_amount;
		}
		case WR_CHECKAMMO2:
		{
			ammo_amount = self.WEP_AMMO(HLAC) >= WEP_CVAR_SEC(hlac, ammo);
			ammo_amount += self.(weapon_load[WEP_HLAC]) >= WEP_CVAR_SEC(hlac, ammo);
			return ammo_amount;
		}
		case WR_CONFIG:
		{
			HLAC_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS)
			return TRUE;
		}
		case WR_RELOAD:
		{
			W_Reload(min(WEP_CVAR_PRI(hlac, ammo), WEP_CVAR_SEC(hlac, ammo)), "weapons/reload.wav");
			return TRUE;
		}
		case WR_SUICIDEMESSAGE:
		{
			return WEAPON_HLAC_SUICIDE;
		}
		case WR_KILLMESSAGE:
		{
			return WEAPON_HLAC_MURDER;
		}
	}
	return FALSE;
}
#endif
#ifdef CSQC
float W_HLAC(float req)
{
	switch(req)
	{
		case WR_IMPACTEFFECT:
		{
			vector org2;
			org2 = w_org + w_backoff * 6;
			pointparticles(particleeffectnum("laser_impact"), org2, w_backoff * 1000, 1);
			if(!w_issilent)
				sound(self, CH_SHOTS, "weapons/laserimpact.wav", VOL_BASE, ATTN_NORM);
				
			return TRUE;
		}
		case WR_INIT:
		{
			precache_sound("weapons/laserimpact.wav");
			return TRUE;
		}
		case WR_ZOOMRETICLE:
		{
			// no weapon specific image for this weapon
			return FALSE;
		}
	}
	return FALSE;
}
#endif
#endif
