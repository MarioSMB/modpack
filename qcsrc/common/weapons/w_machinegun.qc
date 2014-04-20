#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ MACHINEGUN,
/* function  */ W_MachineGun,
/* ammotype  */ ammo_nails,
/* impulse   */ 3,
/* flags     */ WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN,
/* rating    */ BOT_PICKUP_RATING_MID,
/* color     */ '1 1 0',
/* modelname */ "uzi",
/* simplemdl */ "foobar",
/* crosshair */ "gfx/crosshairuzi 0.6",
/* wepimg    */ "weaponuzi",
/* refname   */ "machinegun",
/* wepname   */ _("Machine Gun")
);

#define MACHINEGUN_SETTINGS(w_cvar,w_prop) MACHINEGUN_SETTINGS_LIST(w_cvar, w_prop, MACHINEGUN, machinegun)
#define MACHINEGUN_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, NONE, spread_min) \
	w_cvar(id, sn, NONE, spread_max) \
	w_cvar(id, sn, NONE, spread_add) \
	w_cvar(id, sn, NONE, mode) \
	w_cvar(id, sn, NONE, first) \
	w_cvar(id, sn, NONE, first_damage) \
	w_cvar(id, sn, NONE, first_force) \
	w_cvar(id, sn, NONE, first_refire) \
	w_cvar(id, sn, NONE, first_spread) \
	w_cvar(id, sn, NONE, first_ammo) \
	w_cvar(id, sn, NONE, solidpenetration) \
	w_cvar(id, sn, NONE, sustained_damage) \
	w_cvar(id, sn, NONE, sustained_force) \
	w_cvar(id, sn, NONE, sustained_refire) \
	w_cvar(id, sn, NONE, sustained_spread) \
	w_cvar(id, sn, NONE, sustained_ammo) \
	w_cvar(id, sn, NONE, burst) \
	w_cvar(id, sn, NONE, burst_refire) \
	w_cvar(id, sn, NONE, burst_refire2) \
	w_cvar(id, sn, NONE, burst_animtime) \
	w_cvar(id, sn, NONE, burst_speed) \
	w_cvar(id, sn, NONE, burst_ammo) \
	w_prop(id, sn, float,  reloading_ammo, reload_ammo) \
	w_prop(id, sn, float,  reloading_time, reload_time) \
	w_prop(id, sn, float,  switchdelay_raise, switchdelay_raise) \
	w_prop(id, sn, float,  switchdelay_drop, switchdelay_drop) \
	w_prop(id, sn, string, weaponreplace, weaponreplace) \
	w_prop(id, sn, float,  weaponstart, weaponstart) \
	w_prop(id, sn, float,  weaponstartoverride, weaponstartoverride) \
	w_prop(id, sn, float,  weaponthrowable, weaponthrowable)

#ifdef SVQC
MACHINEGUN_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
#endif
#else
#ifdef SVQC

void spawnfunc_weapon_machinegun(void)
{
	if(autocvar_sv_q3acompat_machineshotgunswap)
	if(self.classname != "droppedweapon")
	{
		weapon_defaultspawnfunc(WEP_SHOCKWAVE);
		return;
	}
	weapon_defaultspawnfunc(WEP_MACHINEGUN);
}
void spawnfunc_weapon_uzi(void) { spawnfunc_weapon_machinegun(); }

void W_MachineGun_MuzzleFlash_Think(void)
{
	self.frame = self.frame + 2;
	self.scale = self.scale * 0.5;
	self.alpha = self.alpha - 0.25;
	self.nextthink = time + 0.05;

	if(self.alpha <= 0)
	{
		self.think = SUB_Remove;
		self.nextthink = time;
		self.realowner.muzzle_flash = world;
		return;
	}

}

void W_MachineGun_MuzzleFlash(void)
{
	if(self.muzzle_flash == world)
		self.muzzle_flash = spawn();

	// muzzle flash for 1st person view
	setmodel(self.muzzle_flash, "models/uziflash.md3"); // precision set below

	self.muzzle_flash.scale = 0.75;
	self.muzzle_flash.think = W_MachineGun_MuzzleFlash_Think;
	self.muzzle_flash.nextthink = time + 0.02;
	self.muzzle_flash.frame = 2;
	self.muzzle_flash.alpha = 0.75;
	self.muzzle_flash.angles_z = random() * 180;
	self.muzzle_flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	self.muzzle_flash.owner = self.muzzle_flash.realowner = self;
}

void W_MachineGun_Attack(float deathtype)
{
	W_SetupShot(self, TRUE, 0, "weapons/uzi_fire.wav", CH_WEAPON_A, ((self.misc_bulletcounter == 1) ? WEP_CVAR(machinegun, first_damage) : WEP_CVAR(machinegun, sustained_damage)));
	if(!autocvar_g_norecoil)
	{
		self.punchangle_x = random() - 0.5;
		self.punchangle_y = random() - 0.5;
	}

	// this attack_finished just enforces a cooldown at the end of a burst
	ATTACK_FINISHED(self) = time + WEP_CVAR(machinegun, first_refire) * W_WeaponRateFactor();

	if(self.misc_bulletcounter == 1)
		fireBullet(w_shotorg, w_shotdir, WEP_CVAR(machinegun, first_spread), WEP_CVAR(machinegun, solidpenetration), WEP_CVAR(machinegun, first_damage), WEP_CVAR(machinegun, first_force), deathtype, 0);
	else
		fireBullet(w_shotorg, w_shotdir, WEP_CVAR(machinegun, sustained_spread), WEP_CVAR(machinegun, solidpenetration), WEP_CVAR(machinegun, sustained_damage), WEP_CVAR(machinegun, sustained_force), deathtype, 0);

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	W_MachineGun_MuzzleFlash();
	W_AttachToShotorg(self.muzzle_flash, '5 0 0');

	// casing code
	if(autocvar_g_casings >= 2)
		SpawnCasing(((random() * 50 + 50) * v_right) - (v_forward * (random() * 25 + 25)) - ((random() * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, self);

	if(self.misc_bulletcounter == 1)
		W_DecreaseAmmo(WEP_CVAR(machinegun, first_ammo));
	else
		W_DecreaseAmmo(WEP_CVAR(machinegun, sustained_ammo));
}

// weapon frames
void W_MachineGun_Attack_Frame(void)
{
	if(self.weapon != self.switchweapon) // abort immediately if switching
	{
		w_ready();
		return;
	}
	if(self.BUTTON_ATCK)
	{
		if(!WEP_ACTION(self.weapon, WR_CHECKAMMO2))
		if(!(self.items & IT_UNLIMITED_WEAPON_AMMO))
		{
			W_SwitchWeapon_Force(self, w_getbestweapon(self));
			w_ready();
			return;
		}
		self.misc_bulletcounter = self.misc_bulletcounter + 1;
		W_MachineGun_Attack(WEP_MACHINEGUN);
		weapon_thinkf(WFRAME_FIRE1, WEP_CVAR(machinegun, sustained_refire), W_MachineGun_Attack_Frame);
	}
	else
		weapon_thinkf(WFRAME_FIRE1, WEP_CVAR(machinegun, sustained_refire), w_ready);
}


void W_MachineGun_Attack_Auto(void)
{
	float machinegun_spread;

	if(!self.BUTTON_ATCK)
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

	W_DecreaseAmmo(WEP_CVAR(machinegun, sustained_ammo));

	W_SetupShot(self, TRUE, 0, "weapons/uzi_fire.wav", CH_WEAPON_A, WEP_CVAR(machinegun, sustained_damage));
	if(!autocvar_g_norecoil)
	{
		self.punchangle_x = random() - 0.5;
		self.punchangle_y = random() - 0.5;
	}

	machinegun_spread = bound(WEP_CVAR(machinegun, spread_min), WEP_CVAR(machinegun, spread_min) + (WEP_CVAR(machinegun, spread_add) * self.misc_bulletcounter), WEP_CVAR(machinegun, spread_max));
	fireBullet(w_shotorg, w_shotdir, machinegun_spread, WEP_CVAR(machinegun, solidpenetration), WEP_CVAR(machinegun, sustained_damage), WEP_CVAR(machinegun, sustained_force), WEP_MACHINEGUN, 0);

	self.misc_bulletcounter = self.misc_bulletcounter + 1;

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	W_MachineGun_MuzzleFlash();
	W_AttachToShotorg(self.muzzle_flash, '5 0 0');

	if(autocvar_g_casings >= 2) // casing code
		SpawnCasing(((random() * 50 + 50) * v_right) - (v_forward * (random() * 25 + 25)) - ((random() * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, self);

	ATTACK_FINISHED(self) = time + WEP_CVAR(machinegun, first_refire) * W_WeaponRateFactor();
	weapon_thinkf(WFRAME_FIRE1, WEP_CVAR(machinegun, sustained_refire), W_MachineGun_Attack_Auto);
}

void W_MachineGun_Attack_Burst(void)
{
	W_SetupShot(self, TRUE, 0, "weapons/uzi_fire.wav", CH_WEAPON_A, WEP_CVAR(machinegun, sustained_damage));
	if(!autocvar_g_norecoil)
	{
		self.punchangle_x = random() - 0.5;
		self.punchangle_y = random() - 0.5;
	}

	fireBullet(w_shotorg, w_shotdir, WEP_CVAR(machinegun, burst_speed), WEP_CVAR(machinegun, solidpenetration), WEP_CVAR(machinegun, sustained_damage), WEP_CVAR(machinegun, sustained_force), WEP_MACHINEGUN, 0);

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	W_MachineGun_MuzzleFlash();
	W_AttachToShotorg(self.muzzle_flash, '5 0 0');

	if(autocvar_g_casings >= 2) // casing code
		SpawnCasing(((random() * 50 + 50) * v_right) - (v_forward * (random() * 25 + 25)) - ((random() * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, self);

	self.misc_bulletcounter = self.misc_bulletcounter + 1;
	if(self.misc_bulletcounter == 0)
	{
		ATTACK_FINISHED(self) = time + WEP_CVAR(machinegun, burst_refire2) * W_WeaponRateFactor();
		weapon_thinkf(WFRAME_FIRE2, WEP_CVAR(machinegun, burst_animtime), w_ready);
	}
	else
	{
		weapon_thinkf(WFRAME_FIRE2, WEP_CVAR(machinegun, burst_refire), W_MachineGun_Attack_Burst);
	}

}

float W_MachineGun(float req)
{
	float ammo_amount;
	switch(req)
	{
		case WR_AIM:
		{
			if(vlen(self.origin-self.enemy.origin) < 3000 - bound(0, skill, 10) * 200)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE);
			
			return TRUE;
		}
		case WR_THINK:
		{
			if(WEP_CVAR(machinegun, reload_ammo) && self.clip_load < min(max(WEP_CVAR(machinegun, sustained_ammo), WEP_CVAR(machinegun, first_ammo)), WEP_CVAR(machinegun, burst_ammo))) // forced reload
				WEP_ACTION(self.weapon, WR_RELOAD);
			else if(WEP_CVAR(machinegun, mode) == 1)
			{
				if(self.BUTTON_ATCK)
				if(weapon_prepareattack(0, 0))
				{
					self.misc_bulletcounter = 0;
					W_MachineGun_Attack_Auto();
				}

				if(self.BUTTON_ATCK2)
				if(weapon_prepareattack(1, 0))
				{
					if(!WEP_ACTION(self.weapon, WR_CHECKAMMO2))
					if(!(self.items & IT_UNLIMITED_WEAPON_AMMO))
					{
						W_SwitchWeapon_Force(self, w_getbestweapon(self));
						w_ready();
						return FALSE;
					}

					W_DecreaseAmmo(WEP_CVAR(machinegun, burst_ammo));

					self.misc_bulletcounter = WEP_CVAR(machinegun, burst) * -1;
					W_MachineGun_Attack_Burst();
				}
			}
			else
			{

				if(self.BUTTON_ATCK)
				if(weapon_prepareattack(0, 0))
				{
					self.misc_bulletcounter = 1;
					W_MachineGun_Attack(WEP_MACHINEGUN); // sets attack_finished
					weapon_thinkf(WFRAME_FIRE1, WEP_CVAR(machinegun, sustained_refire), W_MachineGun_Attack_Frame);
				}

				if(self.BUTTON_ATCK2 && WEP_CVAR(machinegun, first))
				if(weapon_prepareattack(1, 0))
				{
					self.misc_bulletcounter = 1;
					W_MachineGun_Attack(WEP_MACHINEGUN | HITTYPE_SECONDARY); // sets attack_finished
					weapon_thinkf(WFRAME_FIRE2, WEP_CVAR(machinegun, first_refire), w_ready);
				}
			}
			
			return TRUE;
		}
		case WR_INIT:
		{
			precache_model("models/uziflash.md3");
			precache_model("models/weapons/g_uzi.md3");
			precache_model("models/weapons/v_uzi.md3");
			precache_model("models/weapons/h_uzi.iqm");
			precache_sound("weapons/uzi_fire.wav");
			MACHINEGUN_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP)
			return TRUE;
		}
		case WR_CHECKAMMO1:
		{
			if(WEP_CVAR(machinegun, mode) == 1)
				ammo_amount = self.WEP_AMMO(MACHINEGUN) >= WEP_CVAR(machinegun, sustained_ammo);
			else
				ammo_amount = self.WEP_AMMO(MACHINEGUN) >= WEP_CVAR(machinegun, first_ammo);

			if(WEP_CVAR(machinegun, reload_ammo))
			{
				if(WEP_CVAR(machinegun, mode) == 1)
					ammo_amount += self.(weapon_load[WEP_MACHINEGUN]) >= WEP_CVAR(machinegun, sustained_ammo);
				else
					ammo_amount += self.(weapon_load[WEP_MACHINEGUN]) >= WEP_CVAR(machinegun, first_ammo);
			}
			return ammo_amount;
		}
		case WR_CHECKAMMO2:
		{
			if(WEP_CVAR(machinegun, mode) == 1)
				ammo_amount = self.WEP_AMMO(MACHINEGUN) >= WEP_CVAR(machinegun, burst_ammo);
			else
				ammo_amount = self.WEP_AMMO(MACHINEGUN) >= WEP_CVAR(machinegun, first_ammo);

			if(WEP_CVAR(machinegun, reload_ammo))
			{
				if(WEP_CVAR(machinegun, mode) == 1)
					ammo_amount += self.(weapon_load[WEP_MACHINEGUN]) >= WEP_CVAR(machinegun, burst_ammo);
				else
					ammo_amount += self.(weapon_load[WEP_MACHINEGUN]) >= WEP_CVAR(machinegun, first_ammo);
			}
			return ammo_amount;
		}
		case WR_CONFIG:
		{
			MACHINEGUN_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS)
			return TRUE;
		}
		case WR_RELOAD:
		{
			W_Reload(min(max(WEP_CVAR(machinegun, sustained_ammo), WEP_CVAR(machinegun, first_ammo)), WEP_CVAR(machinegun, burst_ammo)), "weapons/reload.wav");
			return TRUE;
		}
		case WR_SUICIDEMESSAGE:
		{
			return WEAPON_THINKING_WITH_PORTALS;
		}
		case WR_KILLMESSAGE:
		{
			if(w_deathtype & HITTYPE_SECONDARY)
				return WEAPON_MACHINEGUN_MURDER_SNIPE;
			else
				return WEAPON_MACHINEGUN_MURDER_SPRAY;
		}
	}
	return FALSE;
}
#endif
#ifdef CSQC
float W_MachineGun(float req)
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
					sound(self, CH_SHOTS, "weapons/ric1.wav", VOL_BASE, ATTN_NORM);
				else if(w_random < 0.1)
					sound(self, CH_SHOTS, "weapons/ric2.wav", VOL_BASE, ATTN_NORM);
				else if(w_random < 0.2)
					sound(self, CH_SHOTS, "weapons/ric3.wav", VOL_BASE, ATTN_NORM);
					
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
