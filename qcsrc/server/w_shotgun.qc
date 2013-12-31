#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ SHOTGUN,
/* function  */ w_shotgun,
/* ammotype  */ IT_SHELLS,
/* impulse   */ 2,
/* flags     */ WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN,
/* rating    */ BOT_PICKUP_RATING_LOW,
/* model     */ "shotgun",
/* shortname */ "shotgun",
/* fullname  */ _("Shotgun")
);
#else
#ifdef SVQC

void W_Shotgun_Attack (float deathtype)
{
	float	sc;
	float	ammoamount;
	float	bullets;
	float	d;
	float	f;
	float	spread;
	float	solidpenetration;
	entity flash;

	ammoamount = autocvar_g_balance_shotgun_primary_ammo;
	bullets = autocvar_g_balance_shotgun_primary_bullets;
	d = autocvar_g_balance_shotgun_primary_damage;
	f = autocvar_g_balance_shotgun_primary_force;
	spread = autocvar_g_balance_shotgun_primary_spread;
	solidpenetration = autocvar_g_balance_shotgun_primary_solidpenetration;

	W_DecreaseAmmo(ammo_shells, ammoamount, autocvar_g_balance_shotgun_reload_ammo);

	W_SetupShot (self, TRUE, 5, "weapons/shotgun_fire.wav", CH_WEAPON_A, d * bullets, self.weapon);
	for (sc = 0;sc < bullets;sc = sc + 1)
		fireBullet(w_shotorg, w_shotdir, spread, solidpenetration, d, f, WEP_SHOTGUN, 0);

	pointparticles(particleeffectnum("shotgun_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_shotgun_primary_ammo);

	// casing code
	if (autocvar_g_casings >= 1)
		for (sc = 0;sc < ammoamount;sc = sc + 1)
			SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 30) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 1, self);

	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '5 0 0');
}

.float swing_prev;
.entity swing_alreadyhit;
void shotgun_meleethink (void)
{
	// declarations
	float i, f, swing, swing_factor, swing_damage, meleetime, is_player, is_monster;
	entity target_victim;
	vector targpos;

	if(!self.cnt) // set start time of melee
	{
		self.cnt = time;
		W_PlayStrengthSound(self.realowner);
	}

	makevectors(self.realowner.v_angle); // update values for v_* vectors

	// calculate swing percentage based on time
	meleetime = autocvar_g_balance_shotgun_secondary_melee_time * W_WeaponRateFactor();
	swing = bound(0, (self.cnt + meleetime - time) / meleetime, 10);
	f = ((1 - swing) * autocvar_g_balance_shotgun_secondary_melee_traces);

	// check to see if we can still continue, otherwise give up now
	if((self.realowner.deadflag != DEAD_NO) && autocvar_g_balance_shotgun_secondary_melee_no_doubleslap)
	{
		remove(self);
		return;
	}

	// if okay, perform the traces needed for this frame
	for(i=self.swing_prev; i < f; ++i)
	{
		swing_factor = ((1 - (i / autocvar_g_balance_shotgun_secondary_melee_traces)) * 2 - 1);

		targpos = (self.realowner.origin + self.realowner.view_ofs
			+ (v_forward * autocvar_g_balance_shotgun_secondary_melee_range)
			+ (v_up * swing_factor * autocvar_g_balance_shotgun_secondary_melee_swing_up)
			+ (v_right * swing_factor * autocvar_g_balance_shotgun_secondary_melee_swing_side));

		WarpZone_traceline_antilag(self, self.realowner.origin + self.realowner.view_ofs, targpos, FALSE, self, ANTILAG_LATENCY(self.realowner));

		// draw lightning beams for debugging
		//te_lightning2(world, targpos, self.realowner.origin + self.realowner.view_ofs + v_forward * 5 - v_up * 5);
		//te_customflash(targpos, 40,  2, '1 1 1');

		is_player = (IS_PLAYER(trace_ent) || trace_ent.classname == "body");
		is_monster = IS_MONSTER(trace_ent);

		if((trace_fraction < 1) // if trace is good, apply the damage and remove self
			&& (trace_ent.takedamage == DAMAGE_AIM)
			&& (trace_ent != self.swing_alreadyhit)
			&& ((is_player || is_monster) || autocvar_g_balance_shotgun_secondary_melee_nonplayerdamage))
		{
			target_victim = trace_ent; // so it persists through other calls

			if(is_player || is_monster) // this allows us to be able to nerf the non-player damage done in e.g. assault or onslaught.
				swing_damage = (autocvar_g_balance_shotgun_secondary_damage * min(1, swing_factor + 1));
			else
				swing_damage = (autocvar_g_balance_shotgun_secondary_melee_nonplayerdamage * min(1, swing_factor + 1));

			//print(strcat(self.realowner.netname, " hitting ", target_victim.netname, " with ", strcat(ftos(swing_damage), " damage (factor: ", ftos(swing_factor), ") at "), ftos(time), " seconds.\n"));

			Damage(target_victim, self.realowner, self.realowner,
				swing_damage, WEP_SHOTGUN | HITTYPE_SECONDARY,
				self.realowner.origin + self.realowner.view_ofs,
				v_forward * autocvar_g_balance_shotgun_secondary_force);

			if(accuracy_isgooddamage(self.realowner, target_victim)) { accuracy_add(self.realowner, WEP_SHOTGUN, 0, swing_damage); }

			// draw large red flash for debugging
			//te_customflash(targpos, 200, 2, '15 0 0');

			if(autocvar_g_balance_shotgun_secondary_melee_multihit) // allow multiple hits with one swing, but not against the same player twice.
			{
				self.swing_alreadyhit = target_victim;
				continue; // move along to next trace
			}
			else
			{
				remove(self);
				return;
			}
		}
	}

	if(time >= self.cnt + meleetime)
	{
		// melee is finished
		remove(self);
		return;
	}
	else
	{
		// set up next frame
		self.swing_prev = i;
		self.nextthink = time;
	}
}

// alternate secondary weapon frames
void shotgun_fire2_04()
{
	if (!weapon_action(self.weapon, WR_CHECKAMMO2))
	if (!(self.items & IT_UNLIMITED_WEAPON_AMMO))
	{
		W_SwitchWeapon_Force(self, w_getbestweapon(self));
		w_ready();
		return;
	}

	W_Shotgun_Attack(WEP_SHOTGUN);
	weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_shotgun_secondary_alt_animtime, w_ready);
}
void shotgun_fire2_03()
{
	if (!weapon_action(self.weapon, WR_CHECKAMMO2))
	if (!(self.items & IT_UNLIMITED_WEAPON_AMMO))
	{
		W_SwitchWeapon_Force(self, w_getbestweapon(self));
		w_ready();
		return;
	}

	W_Shotgun_Attack(WEP_SHOTGUN);
	weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_shotgun_secondary_alt_animtime,shotgun_fire2_04);
}
void shotgun_fire2_02()
{
	W_Shotgun_Attack(WEP_SHOTGUN);
	weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_shotgun_secondary_alt_animtime, shotgun_fire2_03);
}

void W_Shotgun_Attack2 (void)
{
	sound (self, CH_WEAPON_A, "weapons/shotgun_melee.wav", VOL_BASE, ATTEN_NORM);
	weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_shotgun_secondary_animtime, w_ready);

	entity meleetemp;
	meleetemp = spawn();
	meleetemp.realowner = self;
	meleetemp.think = shotgun_meleethink;
	meleetemp.nextthink = time + autocvar_g_balance_shotgun_secondary_melee_delay * W_WeaponRateFactor();
	W_SetupShot_Range(self, TRUE, 0, "", 0, autocvar_g_balance_shotgun_secondary_damage, autocvar_g_balance_shotgun_secondary_melee_range, self.weapon);
}

void spawnfunc_weapon_shotgun(); // defined in t_items.qc

.float shotgun_primarytime;

float w_shotgun(float req)
{
	float ammo_amount;
	if (req == WR_AIM)
		if(vlen(self.origin-self.enemy.origin) <= autocvar_g_balance_shotgun_secondary_melee_range)
			self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE);
		else
			self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);

	else if (req == WR_THINK)
	{
		if(autocvar_g_balance_shotgun_reload_ammo && self.clip_load < autocvar_g_balance_shotgun_primary_ammo) // forced reload
		{
			// don't force reload an empty shotgun if its melee attack is active
			if (!(autocvar_g_balance_shotgun_secondary && self.ammo_shells < autocvar_g_balance_shotgun_primary_ammo))
				weapon_action(self.weapon, WR_RELOAD);
		}
		else
		{
			if (self.BUTTON_ATCK)
			{
				if (time >= self.shotgun_primarytime || autocvar_g_balance_shotgun_secondary_alt) // handle refire separately so the secondary can be fired straight after a primary
				{
					if(weapon_prepareattack(0, ((autocvar_g_balance_shotgun_secondary_alt) ? autocvar_g_balance_shotgun_primary_refire : autocvar_g_balance_shotgun_primary_animtime)))
					{
						W_Shotgun_Attack(WEP_SHOTGUN);
						self.shotgun_primarytime = time + autocvar_g_balance_shotgun_primary_refire * W_WeaponRateFactor();
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_shotgun_primary_animtime, w_ready);
					}
				}
			}
			if (self.BUTTON_ATCK2 && autocvar_g_balance_shotgun_secondary_alt)
			{
				if (weapon_prepareattack(1, autocvar_g_balance_shotgun_secondary_alt_refire))
				{
					W_Shotgun_Attack(WEP_SHOTGUN);
					self.shotgun_primarytime = time + autocvar_g_balance_shotgun_secondary_alt_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_shotgun_secondary_alt_animtime, shotgun_fire2_03);
				}
			}
		}
		if (self.clip_load >= 0) // we are not currently reloading
		if (!self.crouch) // no crouchmelee please
		if (self.BUTTON_ATCK2 && autocvar_g_balance_shotgun_secondary && !autocvar_g_balance_shotgun_secondary_alt)
		if (weapon_prepareattack(1, autocvar_g_balance_shotgun_secondary_refire))
		{
			// attempt forcing playback of the anim by switching to another anim (that we never play) here...
			weapon_thinkf(WFRAME_FIRE1, 0, W_Shotgun_Attack2);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_shotgun.md3");
		precache_model ("models/weapons/v_shotgun.md3");
		precache_model ("models/weapons/h_shotgun.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/shotgun_fire.wav");
		precache_sound ("weapons/shotgun_melee.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_SHOTGUN);
		self.current_ammo = ammo_shells;
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_shells >= autocvar_g_balance_shotgun_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_SHOTGUN]) >= autocvar_g_balance_shotgun_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		if(autocvar_g_balance_shotgun_secondary_alt)
		{
			ammo_amount = self.ammo_shells >= autocvar_g_balance_shotgun_secondary_alt_ammo;
			ammo_amount += self.(weapon_load[WEP_SHOTGUN]) >= autocvar_g_balance_shotgun_secondary_alt_ammo;
			return ammo_amount;
		}
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(autocvar_g_balance_shotgun_primary_ammo, autocvar_g_balance_shotgun_reload_ammo, autocvar_g_balance_shotgun_reload_time, "weapons/reload.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
	{
		return WEAPON_THINKING_WITH_PORTALS;
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
			return WEAPON_SHOTGUN_MURDER_SLAP;
		else
			return WEAPON_SHOTGUN_MURDER;
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_shotgun(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 2;
		pointparticles(particleeffectnum("shotgun_impact"), org2, w_backoff * 1000, 1);
		if(!w_issilent && time - self.prevric > 0.25)
		{
			if(w_random < 0.0165)
				sound(self, CH_SHOTS, "weapons/ric1.wav", VOL_BASE, ATTEN_NORM);
			else if(w_random < 0.033)
				sound(self, CH_SHOTS, "weapons/ric2.wav", VOL_BASE, ATTEN_NORM);
			else if(w_random < 0.05)
				sound(self, CH_SHOTS, "weapons/ric3.wav", VOL_BASE, ATTEN_NORM);
			self.prevric = time;
		}
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
