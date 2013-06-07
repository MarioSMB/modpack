#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ HAGAR,
/* function  */ w_hagar,
/* ammotype  */ IT_ROCKETS,
/* impulse   */ 8,
/* flags     */ WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_FLAG_CANCLIMB | WEP_TYPE_SPLASH,
/* rating    */ BOT_PICKUP_RATING_MID,
/* model     */ "hagar",
/* shortname */ "hagar",
/* fullname  */ _("Hagar")
);
#else
#ifdef SVQC
// NO bounce protection, as bounces are limited!

void W_Hagar_Explode (void)
{
	self.event_damage = func_null;
	RadiusDamage (self, self.realowner, autocvar_g_balance_hagar_primary_damage, autocvar_g_balance_hagar_primary_edgedamage, autocvar_g_balance_hagar_primary_radius, world, autocvar_g_balance_hagar_primary_force, self.projectiledeathtype, other);

	remove (self);
}

void W_Hagar_Explode2 (void)
{
	self.event_damage = func_null;
	RadiusDamage (self, self.realowner, autocvar_g_balance_hagar_secondary_damage, autocvar_g_balance_hagar_secondary_edgedamage, autocvar_g_balance_hagar_secondary_radius, world, autocvar_g_balance_hagar_secondary_force, self.projectiledeathtype, other);

	remove (self);
}

void W_Hagar_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;
		
	float is_linkexplode = ( ((inflictor.owner != world) ? (inflictor.owner == self.owner) : TRUE)
		&& (inflictor.projectiledeathtype & HITTYPE_SECONDARY) 
		&& (self.projectiledeathtype & HITTYPE_SECONDARY));
	
	if(is_linkexplode)
		is_linkexplode = (is_linkexplode && autocvar_g_balance_hagar_secondary_load_linkexplode);
	else
		is_linkexplode = -1; // not secondary load, so continue as normal without exception.

	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, is_linkexplode))
		return; // g_projectiles_damage says to halt

	self.health = self.health - damage;
	self.angles = vectoangles(self.velocity);
	
	if (self.health <= 0)
		W_PrepareExplosionByDamage(attacker, self.think);
}

void W_Hagar_Touch (void)
{
	PROJECTILE_TOUCH;
	self.use ();
}

void W_Hagar_Touch2 (void)
{
	PROJECTILE_TOUCH;

	if(self.cnt > 0 || other.takedamage == DAMAGE_AIM) {
		self.use();
	} else {
		self.cnt++;
		pointparticles(particleeffectnum("hagar_bounce"), self.origin, self.velocity, 1);
		self.angles = vectoangles (self.velocity);
		self.owner = world;
		self.projectiledeathtype |= HITTYPE_BOUNCE;
	}
}

void W_Hagar_Attack (void)
{
	entity missile;

	W_DecreaseAmmo(ammo_rockets, autocvar_g_balance_hagar_primary_ammo, autocvar_g_balance_hagar_reload_ammo);

	W_SetupShot (self, FALSE, 2, "weapons/hagar_fire.wav", CH_WEAPON_A, autocvar_g_balance_hagar_primary_damage, self.weapon);

	pointparticles(particleeffectnum("hagar_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	missile = spawn ();
	missile.owner = missile.realowner = self;
	missile.classname = "missile";
	missile.bot_dodge = TRUE;
	missile.bot_dodgerating = autocvar_g_balance_hagar_primary_damage;
	
	missile.takedamage = DAMAGE_YES;
	missile.health = autocvar_g_balance_hagar_primary_health;
	missile.damageforcescale = autocvar_g_balance_hagar_primary_damageforcescale;
	missile.event_damage = W_Hagar_Damage;
	missile.damagedbycontents = TRUE;
	
	missile.touch = W_Hagar_Touch;
	missile.use = W_Hagar_Explode;
	missile.think = adaptor_think2use_hittype_splash;
	missile.nextthink = time + autocvar_g_balance_hagar_primary_lifetime;
	PROJECTILE_MAKETRIGGER(missile);
	missile.projectiledeathtype = WEP_HAGAR;
	setorigin (missile, w_shotorg);
	setsize(missile, '0 0 0', '0 0 0');

	missile.movetype = MOVETYPE_FLY;
	W_SETUPPROJECTILEVELOCITY(missile, g_balance_hagar_primary);

	missile.angles = vectoangles (missile.velocity);
	missile.flags = FL_PROJECTILE;
	missile.missile_flags = MIF_SPLASH; 

	CSQCProjectile(missile, TRUE, PROJECTILE_HAGAR, TRUE);

	other = missile; MUTATOR_CALLHOOK(EditProjectile);
}

void W_Hagar_Attack2 (void)
{
	entity missile;

	W_DecreaseAmmo(ammo_rockets, autocvar_g_balance_hagar_secondary_ammo, autocvar_g_balance_hagar_reload_ammo);

	W_SetupShot (self, FALSE, 2, "weapons/hagar_fire.wav", CH_WEAPON_A, autocvar_g_balance_hagar_secondary_damage, self.weapon);

	pointparticles(particleeffectnum("hagar_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	missile = spawn ();
	missile.owner = missile.realowner = self;
	missile.classname = "missile";
	missile.bot_dodge = TRUE;
	missile.bot_dodgerating = autocvar_g_balance_hagar_secondary_damage;
	
	missile.takedamage = DAMAGE_YES;
	missile.health = autocvar_g_balance_hagar_secondary_health;
	missile.damageforcescale = autocvar_g_balance_hagar_secondary_damageforcescale;
	missile.event_damage = W_Hagar_Damage;
	missile.damagedbycontents = TRUE;

	missile.touch = W_Hagar_Touch2;
	missile.cnt = 0;
	missile.use = W_Hagar_Explode2;
	missile.think = adaptor_think2use_hittype_splash;
	missile.nextthink = time + autocvar_g_balance_hagar_secondary_lifetime_min + random() * autocvar_g_balance_hagar_secondary_lifetime_rand;
	PROJECTILE_MAKETRIGGER(missile);
	missile.projectiledeathtype = WEP_HAGAR | HITTYPE_SECONDARY;
	setorigin (missile, w_shotorg);
	setsize(missile, '0 0 0', '0 0 0');

	missile.movetype = MOVETYPE_BOUNCEMISSILE;
	W_SETUPPROJECTILEVELOCITY(missile, g_balance_hagar_secondary);

	missile.angles = vectoangles (missile.velocity);
	missile.flags = FL_PROJECTILE;
	missile.missile_flags = MIF_SPLASH; 

	CSQCProjectile(missile, TRUE, PROJECTILE_HAGAR_BOUNCING, TRUE);

	other = missile; MUTATOR_CALLHOOK(EditProjectile);
}

.float hagar_loadstep, hagar_loadblock, hagar_loadbeep, hagar_warning;
void W_Hagar_Attack2_Load_Release (void)
{
	// time to release the rockets we've loaded

	entity missile;
	float counter, shots, spread_pershot;
	vector s;
	vector forward, right, up;

	if(!self.hagar_load)
		return;

	weapon_prepareattack_do(1, autocvar_g_balance_hagar_secondary_refire);

	W_SetupShot (self, FALSE, 2, "weapons/hagar_fire.wav", CH_WEAPON_A, autocvar_g_balance_hagar_secondary_damage, self.weapon);
	pointparticles(particleeffectnum("hagar_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	forward = v_forward;
	right = v_right;
	up = v_up;

	shots = self.hagar_load;
	missile = world;
	for(counter = 0; counter < shots; ++counter)
	{
		missile = spawn ();
		missile.owner = missile.realowner = self;
		missile.classname = "missile";
		missile.bot_dodge = TRUE;
		missile.bot_dodgerating = autocvar_g_balance_hagar_secondary_damage;
		
		missile.takedamage = DAMAGE_YES;
		missile.health = autocvar_g_balance_hagar_secondary_health;
		missile.damageforcescale = autocvar_g_balance_hagar_secondary_damageforcescale;
		missile.event_damage = W_Hagar_Damage;
		missile.damagedbycontents = TRUE;

		missile.touch = W_Hagar_Touch; // not bouncy
		missile.use = W_Hagar_Explode2;
		missile.think = adaptor_think2use_hittype_splash;
		missile.nextthink = time + autocvar_g_balance_hagar_secondary_lifetime_min + random() * autocvar_g_balance_hagar_secondary_lifetime_rand;
		PROJECTILE_MAKETRIGGER(missile);
		missile.projectiledeathtype = WEP_HAGAR | HITTYPE_SECONDARY;
		setorigin (missile, w_shotorg);
		setsize(missile, '0 0 0', '0 0 0');
		missile.movetype = MOVETYPE_FLY;
		missile.missile_flags = MIF_SPLASH; 
		
		// per-shot spread calculation: the more shots there are, the less spread is applied (based on the bias cvar)
		spread_pershot = ((shots - 1) / (autocvar_g_balance_hagar_secondary_load_max - 1)); 
		spread_pershot = (1 - (spread_pershot * autocvar_g_balance_hagar_secondary_load_spread_bias));
		spread_pershot = (autocvar_g_balance_hagar_secondary_spread * spread_pershot * g_weaponspreadfactor);
		
		// pattern spread calculation
		s = '0 0 0';
		if (counter == 0)
			s = '0 0 0';
		else
		{
			makevectors('0 360 0' * (0.75 + (counter - 0.5) / (shots - 1)));
			s_y = v_forward_x;
			s_z = v_forward_y;
		}
		s = s * autocvar_g_balance_hagar_secondary_load_spread * g_weaponspreadfactor;
		
		W_SetupProjectileVelocityEx(missile, w_shotdir + right * s_y + up * s_z, v_up, autocvar_g_balance_hagar_secondary_speed, 0, 0, spread_pershot, FALSE);

		missile.angles = vectoangles (missile.velocity);
		missile.flags = FL_PROJECTILE;

		CSQCProjectile(missile, TRUE, PROJECTILE_HAGAR, TRUE);

		other = missile; MUTATOR_CALLHOOK(EditProjectile);
	}

	weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_hagar_secondary_load_animtime, w_ready);
	self.hagar_loadstep = time + autocvar_g_balance_hagar_secondary_refire * W_WeaponRateFactor();
	self.hagar_load = 0;
}

void W_Hagar_Attack2_Load (void)
{
	// loadable hagar secondary attack, must always run each frame
	
	if(time < game_starttime)
		return;

	float loaded, enough_ammo;
	loaded = self.hagar_load >= autocvar_g_balance_hagar_secondary_load_max;

	// this is different than WR_CHECKAMMO when it comes to reloading
	if(autocvar_g_balance_hagar_reload_ammo)
		enough_ammo = self.(weapon_load[WEP_HAGAR]) >= autocvar_g_balance_hagar_secondary_ammo;
	else
		enough_ammo = self.ammo_rockets >= autocvar_g_balance_hagar_secondary_ammo;

	if(self.BUTTON_ATCK2)
	{
		if(self.BUTTON_ATCK && autocvar_g_balance_hagar_secondary_load_abort)
		{
			if(self.hagar_load)
			{
				// if we pressed primary fire while loading, unload all rockets and abort
				self.weaponentity.state = WS_READY;
				W_DecreaseAmmo(ammo_rockets, autocvar_g_balance_hagar_secondary_ammo * self.hagar_load * -1, autocvar_g_balance_hagar_reload_ammo); // give back ammo
				self.hagar_load = 0;
				sound(self, CH_WEAPON_A, "weapons/hagar_beep.wav", VOL_BASE, ATTN_NORM);

				// pause until we can load rockets again, once we re-press the alt fire button
				self.hagar_loadstep = time + autocvar_g_balance_hagar_secondary_load_speed * W_WeaponRateFactor();

				// require letting go of the alt fire button before we can load again
				self.hagar_loadblock = TRUE;
			}
		}
		else
		{
			// check if we can attempt to load another rocket
			if(!loaded && enough_ammo)
			{
				if(!self.hagar_loadblock && self.hagar_loadstep < time)
				{
					W_DecreaseAmmo(ammo_rockets, autocvar_g_balance_hagar_secondary_ammo, autocvar_g_balance_hagar_reload_ammo);
					self.weaponentity.state = WS_INUSE;
					self.hagar_load += 1;
					sound(self, CH_WEAPON_B, "weapons/hagar_load.wav", VOL_BASE * 0.8, ATTN_NORM); // sound is too loud according to most

					if (self.hagar_load >= autocvar_g_balance_hagar_secondary_load_max)
						self.hagar_loadstep = time + autocvar_g_balance_hagar_secondary_load_hold * W_WeaponRateFactor();
					else
						self.hagar_loadstep = time + autocvar_g_balance_hagar_secondary_load_speed * W_WeaponRateFactor();
				}
			}
			else if(!self.hagar_loadbeep && self.hagar_load) // prevents the beep from playing each frame
			{
				// if this is the last rocket we can load, play a beep sound to notify the player
				sound(self, CH_WEAPON_A, "weapons/hagar_beep.wav", VOL_BASE, ATTN_NORM);
				self.hagar_loadbeep = TRUE;
			}
		}
	}
	else if(self.hagar_loadblock)
	{
		// the alt fire button has been released, so re-enable loading if blocked
		self.hagar_loadblock = FALSE;
	}

	if(self.hagar_load)
	{
		// play warning sound if we're about to release
		if((loaded || !enough_ammo) && self.hagar_loadstep - 0.5 < time && autocvar_g_balance_hagar_secondary_load_hold >= 0)
		{
			if(!self.hagar_warning && self.hagar_load) // prevents the beep from playing each frame
			{
				// we're about to automatically release after holding time, play a beep sound to notify the player
				sound(self, CH_WEAPON_A, "weapons/hagar_beep.wav", VOL_BASE, ATTN_NORM);
				self.hagar_warning = TRUE;
			}
		}
		
		// release if player let go of button or if they've held it in too long
		if(!self.BUTTON_ATCK2 || ((loaded || !enough_ammo) && self.hagar_loadstep < time && autocvar_g_balance_hagar_secondary_load_hold >= 0))
		{
			self.weaponentity.state = WS_READY;
			W_Hagar_Attack2_Load_Release();
		}
	}
	else
	{
		self.hagar_loadbeep = FALSE;
		self.hagar_warning = FALSE;
	}

	// we aren't checking ammo during an attack, so we must do it here
	if not(weapon_action(self.weapon, WR_CHECKAMMO1) + weapon_action(self.weapon, WR_CHECKAMMO2))
	{
		// note: this doesn't force the switch
		W_SwitchToOtherWeapon(self);
		return;
	}
}

void spawnfunc_weapon_hagar (void)
{
	weapon_defaultspawnfunc(WEP_HAGAR);
}

float w_hagar(float req)
{
	float ammo_amount;
	if (req == WR_AIM)
		if (random()>0.15)
			self.BUTTON_ATCK = bot_aim(autocvar_g_balance_hagar_primary_speed, 0, autocvar_g_balance_hagar_primary_lifetime, FALSE);
		else
		{
			// not using secondary_speed since these are only 15% and should cause some ricochets without re-aiming
			self.BUTTON_ATCK2 = bot_aim(autocvar_g_balance_hagar_primary_speed, 0, autocvar_g_balance_hagar_primary_lifetime, FALSE);
		}
	else if (req == WR_THINK)
	{
		float loadable_secondary;
		loadable_secondary = (autocvar_g_balance_hagar_secondary_load && autocvar_g_balance_hagar_secondary);

		if (loadable_secondary)
			W_Hagar_Attack2_Load(); // must always run each frame
		if(autocvar_g_balance_hagar_reload_ammo && self.clip_load < min(autocvar_g_balance_hagar_primary_ammo, autocvar_g_balance_hagar_secondary_ammo)) // forced reload
			weapon_action(self.weapon, WR_RELOAD);
		else if (self.BUTTON_ATCK && !self.hagar_load && !self.hagar_loadblock) // not while secondary is loaded or awaiting reset
		{
			if (weapon_prepareattack(0, autocvar_g_balance_hagar_primary_refire))
			{
				W_Hagar_Attack();
				weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_hagar_primary_refire, w_ready);
			}
		}
		else if (self.BUTTON_ATCK2 && !loadable_secondary && autocvar_g_balance_hagar_secondary)
		{
			if (weapon_prepareattack(1, autocvar_g_balance_hagar_secondary_refire))
			{
				W_Hagar_Attack2();
				weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_hagar_secondary_refire, w_ready);
			}
		}
	}
	else if (req == WR_GONETHINK)
	{
		// we lost the weapon and want to prepare switching away
		if(self.hagar_load)
		{
			self.weaponentity.state = WS_READY;
			W_Hagar_Attack2_Load_Release();
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_hagar.md3");
		precache_model ("models/weapons/v_hagar.md3");
		precache_model ("models/weapons/h_hagar.iqm");
		precache_sound ("weapons/hagar_fire.wav");
		precache_sound ("weapons/hagar_load.wav");
		precache_sound ("weapons/hagar_beep.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_HAGAR);
		self.current_ammo = ammo_rockets;
		self.hagar_loadblock = FALSE;

		if(self.hagar_load)
		{
			W_DecreaseAmmo(ammo_rockets, autocvar_g_balance_hagar_secondary_ammo * self.hagar_load * -1, autocvar_g_balance_hagar_reload_ammo); // give back ammo if necessary
			self.hagar_load = 0;
		}
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_rockets >= autocvar_g_balance_hagar_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_HAGAR]) >= autocvar_g_balance_hagar_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		ammo_amount = self.ammo_rockets >= autocvar_g_balance_hagar_secondary_ammo;
		ammo_amount += self.(weapon_load[WEP_HAGAR]) >= autocvar_g_balance_hagar_secondary_ammo;
		return ammo_amount;
	}
	else if (req == WR_RESETPLAYER)
	{
		self.hagar_load = 0;
	}
	else if (req == WR_PLAYERDEATH)
	{
		// if we have any rockets loaded when we die, release them
		if(self.hagar_load && autocvar_g_balance_hagar_secondary_load_releasedeath)
			W_Hagar_Attack2_Load_Release();
	}
	else if (req == WR_RELOAD)
	{
		if not(self.hagar_load) // require releasing loaded rockets first
			W_Reload(min(autocvar_g_balance_hagar_primary_ammo, autocvar_g_balance_hagar_secondary_ammo), autocvar_g_balance_hagar_reload_ammo, autocvar_g_balance_hagar_reload_time, "weapons/reload.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
	{
		return WEAPON_HAGAR_SUICIDE;
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
			return WEAPON_HAGAR_MURDER_BURST;
		else
			return WEAPON_HAGAR_MURDER_SPRAY;
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_hagar(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 6;
		pointparticles(particleeffectnum("hagar_explode"), org2, '0 0 0', 1);
		if(!w_issilent)
		{
			if (w_random<0.15)
				sound(self, CH_SHOTS, "weapons/hagexp1.wav", VOL_BASE, ATTN_NORM);
			else if (w_random<0.7)
				sound(self, CH_SHOTS, "weapons/hagexp2.wav", VOL_BASE, ATTN_NORM);
			else
				sound(self, CH_SHOTS, "weapons/hagexp3.wav", VOL_BASE, ATTN_NORM);
		}
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/hagexp1.wav");
		precache_sound("weapons/hagexp2.wav");
		precache_sound("weapons/hagexp3.wav");
	}
	return TRUE;
}
#endif
#endif
