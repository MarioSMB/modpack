#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id	 */ HMG,
/* function	 */ W_HeavyMachineGun,
/* ammotype	 */ ammo_nails,
/* impulse	 */ 3,
/* flags	 */ WEP_FLAG_MUTATORBLOCKED | WEP_FLAG_HIDDEN | WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN | WEP_FLAG_SUPERWEAPON,
/* rating	 */ BOT_PICKUP_RATING_HIGH,
/* color     */ '0.5 0.5 0',
/* modelname */ "ok_hmg",
/* simplemdl */ "foobar",
/* crosshair */ "gfx/crosshairuzi 0.6",
/* wepimg    */ "weaponhmg",
/* refname   */ "hmg",
/* wepname   */ _("Heavy Machine Gun")
);

#define HMG_SETTINGS(w_cvar,w_prop) HMG_SETTINGS_LIST(w_cvar, w_prop, HMG, hmg)
#define HMG_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, NONE, spread_min) \
	w_cvar(id, sn, NONE, spread_max) \
	w_cvar(id, sn, NONE, spread_add) \
	w_cvar(id, sn, NONE, solidpenetration) \
	w_cvar(id, sn, NONE, damage) \
	w_cvar(id, sn, NONE, force) \
	w_cvar(id, sn, NONE, refire) \
	w_cvar(id, sn, NONE, ammo) \
	w_prop(id, sn, float,  reloading_ammo, reload_ammo) \
	w_prop(id, sn, float,  reloading_time, reload_time) \
	w_prop(id, sn, float,  switchdelay_raise, switchdelay_raise) \
	w_prop(id, sn, float,  switchdelay_drop, switchdelay_drop) \
	w_prop(id, sn, string, weaponreplace, weaponreplace) \
	w_prop(id, sn, float,  weaponstart, weaponstart) \
	w_prop(id, sn, float,  weaponstartoverride, weaponstartoverride) \
	w_prop(id, sn, float,  weaponthrowable, weaponthrowable)

#ifdef SVQC
HMG_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
#endif
#else
#ifdef SVQC

void spawnfunc_weapon_hmg() { weapon_defaultspawnfunc(WEP_HMG); }

void W_HeavyMachineGun_Attack_Auto()
{
	if (!self.BUTTON_ATCK)
	{
		w_ready();
		return;
	}

	if(!WEP_ACTION(self.weapon, WR_CHECKAMMO1))
	if(!(self.items & IT_UNLIMITED_WEAPON_AMMO))
	{
		W_SwitchWeapon_Force(self, w_getbestweapon(self));
		w_ready();
		return;
	}

	W_DecreaseAmmo(WEP_CVAR(hmg, ammo));

	W_SetupShot (self, TRUE, 0, W_Sound("uzi_fire"), CH_WEAPON_A, WEP_CVAR(hmg, damage));

	if(!autocvar_g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	float hmg_spread = bound(WEP_CVAR(hmg, spread_min), WEP_CVAR(hmg, spread_min) + (WEP_CVAR(hmg, spread_add) * self.misc_bulletcounter), WEP_CVAR(hmg, spread_max));
	fireBullet(w_shotorg, w_shotdir, hmg_spread, WEP_CVAR(hmg, solidpenetration), WEP_CVAR(hmg, damage), WEP_CVAR(hmg, force), WEP_HMG, 0);

	self.misc_bulletcounter = self.misc_bulletcounter + 1;

	Send_Effect(EFFECT_MACHINEGUN_MUZZLEFLASH, w_shotorg, w_shotdir * 1000, 1);

	W_MachineGun_MuzzleFlash();
	W_AttachToShotorg(self.muzzle_flash, '5 0 0');

	if (autocvar_g_casings >= 2) // casing code
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, self);

	ATTACK_FINISHED(self) = time + WEP_CVAR(hmg, refire) * W_WeaponRateFactor();
	weapon_thinkf(WFRAME_FIRE1, WEP_CVAR(hmg, refire), W_HeavyMachineGun_Attack_Auto);
}

float W_HeavyMachineGun(float req)
{
	float ammo_amount;
	switch(req)
	{
		case WR_AIM:
		{
			if(vlen(self.origin-self.enemy.origin) < 3000 - bound(0, bot_skill, 10) * 200)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE);
			
			return TRUE;
		}
		case WR_THINK:
		{
			if(WEP_CVAR(hmg, reload_ammo) && self.clip_load < WEP_CVAR(hmg, ammo)) // forced reload
				WEP_ACTION(self.weapon, WR_RELOAD);
			else
			{
				if (self.BUTTON_ATCK)
				if (weapon_prepareattack(0, 0))
				{
					self.misc_bulletcounter = 0;
					W_HeavyMachineGun_Attack_Auto();
				}
			}

			return TRUE;
		}
		case WR_INIT:
		{
			precache_model ("models/uziflash.md3");
			precache_model ("models/weapons/g_ok_hmg.md3");
			precache_model ("models/weapons/v_ok_hmg.md3");
			precache_model ("models/weapons/h_ok_hmg.iqm");
			precache_sound (W_Sound("uzi_fire"));
			HMG_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP)
			return TRUE;
		}
		case WR_CHECKAMMO1:
		{
			ammo_amount = self.ammo_nails >= WEP_CVAR(hmg, ammo);

			if(autocvar_g_balance_hmg_reload_ammo)
				ammo_amount += self.(weapon_load[WEP_HMG]) >= WEP_CVAR(hmg, ammo);

			return ammo_amount;
		}
		case WR_CHECKAMMO2:
		{
			ammo_amount = self.ammo_nails >= WEP_CVAR(hmg, ammo);

			if(autocvar_g_balance_hmg_reload_ammo)
				ammo_amount += self.(weapon_load[WEP_HMG]) >= WEP_CVAR(hmg, ammo);

			return ammo_amount;
		}
		case WR_CONFIG:
		{
			HMG_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS)
			return TRUE;
		}
		case WR_RELOAD:
		{
			W_Reload(WEP_CVAR(hmg, ammo), W_Sound("reload"));
			return TRUE;
		}
		case WR_SUICIDEMESSAGE:
		{
			return WEAPON_THINKING_WITH_PORTALS;
		}
		case WR_KILLMESSAGE:
		{
			if(w_deathtype & HITTYPE_SECONDARY)
				return WEAPON_HMG_MURDER_SNIPE;
			else
				return WEAPON_HMG_MURDER_SPRAY;
		}
	}
	return FALSE;
}
#endif
#ifdef CSQC
float W_HeavyMachineGun(float req)
{
	switch(req)
	{
		case WR_IMPACTEFFECT:
		{
			vector org2;
			org2 = w_org + w_backoff * 2;
			pointparticles(particleeffectnum("machinegun_impact"), org2, w_backoff * 1000, 1);
			if(!w_issilent)
				if(w_random < 0.05)
					sound(self, CH_SHOTS, "weapons/ric1.wav", VOL_BASE, ATTEN_NORM);
				else if(w_random < 0.1)
					sound(self, CH_SHOTS, "weapons/ric2.wav", VOL_BASE, ATTEN_NORM);
				else if(w_random < 0.2)
					sound(self, CH_SHOTS, "weapons/ric3.wav", VOL_BASE, ATTEN_NORM);

			return TRUE;
		}
		case WR_INIT:
		{
			precache_sound("weapons/ric1.wav");
			precache_sound("weapons/ric2.wav");
			precache_sound("weapons/ric3.wav");
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
