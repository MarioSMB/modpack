#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ HOOK,
/* function  */ w_hook,
/* ammotype  */ IT_CELLS|IT_FUEL,
/* impulse   */ 0,
/* flags     */ WEP_FLAG_CANCLIMB | WEP_TYPE_SPLASH,
/* rating    */ 0,
/* model     */ "hookgun",
/* shortname */ "hook",
/* fullname  */ _("Grappling Hook")
);
#else
#ifdef SVQC
.float dmg;
.float dmg_edge;
.float dmg_radius;
.float dmg_force;
.float dmg_power;
.float dmg_duration;
.float dmg_last;
.float hook_refire;
.float hook_time_hooked;
.float hook_time_fueldecrease;

void W_Hook_ExplodeThink (void)
{
	float dt, dmg_remaining_next, f;

	dt = time - self.teleport_time;
	dmg_remaining_next = pow(bound(0, 1 - dt / self.dmg_duration, 1), self.dmg_power);

	f = self.dmg_last - dmg_remaining_next;
	self.dmg_last = dmg_remaining_next;

	RadiusDamage (self, self.realowner, self.dmg * f, self.dmg_edge * f, self.dmg_radius, self.realowner, self.dmg_force * f, self.projectiledeathtype, world);
	self.projectiledeathtype |= HITTYPE_BOUNCE;
	//RadiusDamage (self, world, self.dmg * f, self.dmg_edge * f, self.dmg_radius, world, self.dmg_force * f, self.projectiledeathtype, world);

	if(dt < self.dmg_duration)
		self.nextthink = time + 0.05; // soon
	else
		remove(self);
}

void W_Hook_Explode2 (void)
{
	self.event_damage = func_null;
	self.touch = func_null;
	self.effects |= EF_NODRAW;

	self.think = W_Hook_ExplodeThink;
	self.nextthink = time;
	self.dmg = autocvar_g_balance_hook_secondary_damage;
	self.dmg_edge = autocvar_g_balance_hook_secondary_edgedamage;
	self.dmg_radius = autocvar_g_balance_hook_secondary_radius;
	self.dmg_force = autocvar_g_balance_hook_secondary_force;
	self.dmg_power = autocvar_g_balance_hook_secondary_power;
	self.dmg_duration = autocvar_g_balance_hook_secondary_duration;
	self.teleport_time = time;
	self.dmg_last = 1;
	self.movetype = MOVETYPE_NONE;
}

void W_Hook_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;
		
	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt	
	
	self.health = self.health - damage;
	
	if (self.health <= 0)
		W_PrepareExplosionByDamage(self.realowner, W_Hook_Explode2);
}

void W_Hook_Touch2 (void)
{
	PROJECTILE_TOUCH;
	self.use();
}

void W_Hook_Attack2()
{
	entity gren;

	W_DecreaseAmmo(ammo_cells, autocvar_g_balance_hook_secondary_ammo, FALSE);
	W_SetupShot (self, FALSE, 4, "weapons/hookbomb_fire.wav", CH_WEAPON_A, autocvar_g_balance_hook_secondary_damage, self.weapon);

	gren = spawn ();
	gren.owner = gren.realowner = self;
	gren.classname = "hookbomb";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = autocvar_g_balance_hook_secondary_damage;
	gren.movetype = MOVETYPE_TOSS;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_HOOK | HITTYPE_SECONDARY;
	setorigin(gren, w_shotorg);
	setsize(gren, '0 0 0', '0 0 0');

	gren.nextthink = time + autocvar_g_balance_hook_secondary_lifetime;
	gren.think = adaptor_think2use_hittype_splash;
	gren.use = W_Hook_Explode2;
	gren.touch = W_Hook_Touch2;
	
	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_hook_secondary_health;
	gren.damageforcescale = autocvar_g_balance_hook_secondary_damageforcescale;
	gren.event_damage = W_Hook_Damage;
	gren.damagedbycontents = TRUE;
	gren.missile_flags = MIF_SPLASH | MIF_ARC;

	gren.velocity = '0 0 1' * autocvar_g_balance_hook_secondary_speed;
	if(autocvar_g_projectiles_newton_style)
		gren.velocity = gren.velocity + self.velocity;

	gren.gravity = autocvar_g_balance_hook_secondary_gravity;
	//W_SetupProjectileVelocity(gren); // just falling down!

	gren.angles = '0 0 0';
	gren.flags = FL_PROJECTILE;

	CSQCProjectile(gren, TRUE, PROJECTILE_HOOKBOMB, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

void spawnfunc_weapon_hook (void)
{
	if(g_grappling_hook) // offhand hook
	{
		startitem_failed = TRUE;
		remove(self);
		return;
	}
	weapon_defaultspawnfunc(WEP_HOOK);
}

float w_hook(float req)
{
	float hooked_time_max, hooked_fuel;
		
	if (req == WR_AIM)
	{
		// ... sorry ...
	}
	else if (req == WR_THINK)
	{
		if ((self.BUTTON_ATCK || (self.BUTTON_ATCK2 && autocvar_g_balance_hook_secondary == 2)) || (!(self.items & IT_JETPACK) && self.BUTTON_HOOK))
		{
			if(!self.hook)
			if not(self.hook_state & HOOK_WAITING_FOR_RELEASE)
			if not(self.hook_state & HOOK_FIRING)
			if (time > self.hook_refire)
			if (weapon_prepareattack(0, -1))
			{
				W_DecreaseAmmo(ammo_fuel, autocvar_g_balance_hook_primary_fuel, FALSE);
				self.hook_state |= HOOK_FIRING;
				weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_hook_primary_animtime, w_ready);				
			}
		}

		if (self.BUTTON_ATCK2 && autocvar_g_balance_hook_secondary == 1)
		{
			if (weapon_prepareattack(1, autocvar_g_balance_hook_secondary_refire))
			{
				W_Hook_Attack2();
				weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_hook_secondary_animtime, w_ready);
			}
		}

		if(self.hook)
		{
			// if hooked, no bombs, and increase the timer
			self.hook_refire = max(self.hook_refire, time + autocvar_g_balance_hook_primary_refire * W_WeaponRateFactor());

			// hook also inhibits health regeneration, but only for 1 second
			if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
				self.pauseregen_finished = max(self.pauseregen_finished, time + autocvar_g_balance_pause_fuel_regen);
		}

		if(self.hook && self.hook.state == 1)
		{
			hooked_time_max = autocvar_g_balance_hook_primary_hooked_time_max;			
			if (hooked_time_max > 0)
			{
				if ( time > self.hook_time_hooked + hooked_time_max )
					self.hook_state |= HOOK_REMOVING;
			}
			
			hooked_fuel = autocvar_g_balance_hook_primary_hooked_fuel;
			if (hooked_fuel > 0)
			{
				if ( time > self.hook_time_fueldecrease )
				{
					if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
					{
						if ( self.ammo_fuel >= (time - self.hook_time_fueldecrease) * hooked_fuel )
						{
							W_DecreaseAmmo(ammo_fuel, (time - self.hook_time_fueldecrease) * hooked_fuel, FALSE);
							self.hook_time_fueldecrease = time;
							// decrease next frame again
						}
						else
						{
							self.ammo_fuel = 0;
							self.hook_state |= HOOK_REMOVING;
							W_SwitchWeapon_Force(self, w_getbestweapon(self));
						}
					}
				}
			}
		}
		else
		{
			self.hook_time_hooked = time;				
			self.hook_time_fueldecrease = time + autocvar_g_balance_hook_primary_hooked_time_free;
		}

		if (self.BUTTON_CROUCH)
		{
			self.hook_state &= ~HOOK_PULLING;
			if ((self.BUTTON_ATCK || (self.BUTTON_ATCK2 && autocvar_g_balance_hook_secondary == 2)) || (!(self.items & IT_JETPACK) && self.BUTTON_HOOK))
				self.hook_state &= ~HOOK_RELEASING;
			else
				self.hook_state |= HOOK_RELEASING;
		}
		else
		{
			self.hook_state |= HOOK_PULLING;
			self.hook_state &= ~HOOK_RELEASING;

			if ((self.BUTTON_ATCK || (self.BUTTON_ATCK2 && autocvar_g_balance_hook_secondary == 2)) || (!(self.items & IT_JETPACK) && self.BUTTON_HOOK))
			{
				// already fired
				if(self.hook)
					self.hook_state |= HOOK_WAITING_FOR_RELEASE;
			}
			else
			{
				self.hook_state |= HOOK_REMOVING;
				self.hook_state &= ~HOOK_WAITING_FOR_RELEASE;
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_hookgun.md3");
		precache_model ("models/weapons/v_hookgun.md3");
		precache_model ("models/weapons/h_hookgun.iqm");
		precache_sound ("weapons/hook_impact.wav"); // done by g_hook.qc
		precache_sound ("weapons/hook_fire.wav");
		precache_sound ("weapons/hookbomb_fire.wav");
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_HOOK);
		self.current_ammo = ammo_fuel;
		self.hook_state &= ~HOOK_WAITING_FOR_RELEASE;
	}
	else if (req == WR_CHECKAMMO1)
	{
		if(self.hook)
			return self.ammo_fuel > 0;
		else
			return self.ammo_fuel >= autocvar_g_balance_hook_primary_fuel;
	}
	else if (req == WR_CHECKAMMO2)
	{
		if(autocvar_g_balance_hook_secondary == 2)
		if(self.hook)
			return self.ammo_fuel > 0;
		else
			return self.ammo_fuel >= autocvar_g_balance_hook_primary_fuel;
			
		return self.ammo_cells >= autocvar_g_balance_hook_secondary_ammo;
	}
	else if (req == WR_RESETPLAYER)
	{
		self.hook_refire = time;
	}
	else if (req == WR_SUICIDEMESSAGE)
	{
		return WEAPON_THINKING_WITH_PORTALS;
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
			return WEAPON_HOOK_MURDER_GRAVITYBOMB;
		else if(w_deathtype & HITTYPE_SPLASH)
			return WEAPON_HOOK_MURDER_LASER;
		else
			return WEAPON_HOOK_MURDER;
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_hook(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 2;
		pointparticles(particleeffectnum("hookbomb_explode"), org2, '0 0 0', 1);
		if(!w_issilent)
			sound(self, CH_SHOTS, "weapons/hookbomb_impact.wav", VOL_BASE, ATTEN_NORM);
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/hookbomb_impact.wav");
	}
	return TRUE;
}
#endif
#endif
