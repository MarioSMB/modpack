#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ HMG,
/* function  */ w_hmg,
/* ammotype  */ IT_NAILS,
/* impulse   */ 3,
/* flags     */ WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN | WEP_FLAG_SUPERWEAPON,
/* rating    */ BOT_PICKUP_RATING_HIGH,
/* model     */ "hmg",
/* shortname */ "hmg",
/* fullname  */ _("Heavy Machine Gun")
);
#else
#ifdef SVQC


// weapon frames

void hmg_fire_auto()
{
	float uzi_spread;
	
	if (!self.BUTTON_ATCK)
	{
		w_ready();
		return;
	}

	if(autocvar_g_balance_hmg_reload_ammo)
	if (!weapon_action(self.weapon, WR_CHECKAMMO1))
	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
	{
		W_SwitchWeapon_Force(self, w_getbestweapon(self));
		w_ready();
		return;
	}

	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_hmg_sustained_ammo, autocvar_g_balance_hmg_reload_ammo);

	W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_hmg_speed >= autocvar_g_antilag_bullets, 0, "weapons/uzi_fire.wav", CH_WEAPON_A, autocvar_g_balance_hmg_sustained_damage, self.weapon);
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	uzi_spread = bound(autocvar_g_balance_hmg_spread_min, autocvar_g_balance_hmg_spread_min + (autocvar_g_balance_hmg_spread_add * self.misc_bulletcounter), autocvar_g_balance_hmg_spread_max);
	fireBallisticBullet(w_shotorg, w_shotdir, uzi_spread, autocvar_g_balance_hmg_speed, 5, autocvar_g_balance_hmg_sustained_damage, autocvar_g_balance_hmg_sustained_force, WEP_HMG, 0, 1, autocvar_g_balance_hmg_bulletconstant);
	endFireBallisticBullet();

	self.misc_bulletcounter = self.misc_bulletcounter + 1;

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	UziFlash();
	W_AttachToShotorg(self.muzzle_flash, '5 0 0');

	if (autocvar_g_casings >= 2) // casing code
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, self);

	ATTACK_FINISHED(self) = time + autocvar_g_balance_hmg_sustained_refire * W_WeaponRateFactor();
	weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_hmg_sustained_refire, hmg_fire_auto);
}

void spawnfunc_weapon_hmg()
{    
	weapon_defaultspawnfunc(WEP_HMG);
}

float w_hmg(float req)
{
	float ammo_amount;
	if (req == WR_AIM)
		if(vlen(self.origin-self.enemy.origin) < 3000 - bound(0, skill, 10) * 200)
			self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
		else
		{
			self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE);
		}
	else if (req == WR_THINK)
	{
		if(autocvar_g_balance_hmg_reload_ammo && self.clip_load < autocvar_g_balance_hmg_sustained_ammo) // forced reload
			weapon_action(self.weapon, WR_RELOAD);		
		else
		{
			if (self.BUTTON_ATCK)
			if (weapon_prepareattack(0, 0))
			{
				self.misc_bulletcounter = 0;
				hmg_fire_auto();
			}

			/*
			if(self.BUTTON_ATCK2)
			if(weapon_prepareattack(1, 0))
			{
				if (!weapon_action(self.weapon, WR_CHECKAMMO2))
				if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
				{
					W_SwitchWeapon_Force(self, w_getbestweapon(self));
					w_ready();
					return FALSE;
				}

				W_DecreaseAmmo(ammo_nails, autocvar_g_balance_hmg_burst_ammo, autocvar_g_balance_hmg_reload_ammo);

				self.misc_bulletcounter = autocvar_g_balance_hmg_burst * -1;
				uzi_mode1_fire_burst();
			}
			*/
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_ok_hmg.md3");
		precache_model ("models/weapons/v_ok_hmg.md3");
		precache_model ("models/weapons/h_ok_hmg.iqm");
		precache_sound ("weapons/uzi_fire.wav");		
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_HMG);
		self.current_ammo = ammo_nails;
	}
	else if (req == WR_CHECKAMMO1)
	{
        ammo_amount = self.ammo_nails >= autocvar_g_balance_hmg_sustained_ammo;

		if(autocvar_g_balance_hmg_reload_ammo)		
            ammo_amount += self.(weapon_load[WEP_HMG]) >= autocvar_g_balance_hmg_sustained_ammo;
		
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
        ammo_amount = self.ammo_nails >= autocvar_g_balance_hmg_sustained_ammo;

		if(autocvar_g_balance_hmg_reload_ammo)
            ammo_amount += self.(weapon_load[WEP_HMG]) >= autocvar_g_balance_hmg_sustained_ammo;
		
		return ammo_amount;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(autocvar_g_balance_hmg_sustained_ammo, autocvar_g_balance_hmg_reload_ammo, autocvar_g_balance_hmg_reload_time, "weapons/reload.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
	{
		return WEAPON_THINKING_WITH_PORTALS;
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
			return WEAPON_LASER_MURDER;
		else
			return WEAPON_HMG_MURDER;
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_hmg(float req)
{
	if(req == WR_IMPACTEFFECT)
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
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/ric1.wav");
		precache_sound("weapons/ric2.wav");
		precache_sound("weapons/ric3.wav");
	}
	return TRUE;
}
#endif
#endif
