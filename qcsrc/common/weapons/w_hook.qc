#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ HOOK,
/* function  */ W_Hook,
/* ammotype  */ ammo_fuel,
/* impulse   */ 0,
/* flags     */ WEP_FLAG_CANCLIMB | WEP_TYPE_SPLASH,
/* rating    */ 0,
/* color     */ '0 0.5 0',
/* modelname */ "hookgun",
/* simplemdl */ "foobar",
/* crosshair */ "gfx/crosshairhook 0.5",
/* wepimg    */ "weaponhook",
/* refname   */ "hook",
/* wepname   */ _("Grappling Hook")
);

#define HOOK_SETTINGS(w_cvar,w_prop) HOOK_SETTINGS_LIST(w_cvar, w_prop, HOOK, hook)
#define HOOK_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, BOTH, animtime) \
	w_cvar(id, sn, BOTH, refire) \
	w_cvar(id, sn, PRI,  ammo) \
	w_cvar(id, sn, PRI,  hooked_ammo) \
	w_cvar(id, sn, PRI,  hooked_time_free) \
	w_cvar(id, sn, PRI,  hooked_time_max) \
	w_cvar(id, sn, SEC,  damage) \
	w_cvar(id, sn, SEC,  duration) \
	w_cvar(id, sn, SEC,  edgedamage) \
	w_cvar(id, sn, SEC,  force) \
	w_cvar(id, sn, SEC,  gravity) \
	w_cvar(id, sn, SEC,  lifetime) \
	w_cvar(id, sn, SEC,  power) \
	w_cvar(id, sn, SEC,  radius) \
	w_cvar(id, sn, SEC,  speed) \
	w_cvar(id, sn, SEC,  health) \
	w_cvar(id, sn, SEC,  damageforcescale) \
	w_cvar(id, sn, NONE, secondary) \
	w_prop(id, sn, float,  switchdelay_raise, switchdelay_raise) \
	w_prop(id, sn, float,  switchdelay_drop, switchdelay_drop) \
	w_prop(id, sn, string, weaponreplace, weaponreplace) \
	w_prop(id, sn, float,  weaponstart, weaponstart) \
	w_prop(id, sn, float,  weaponstartoverride, weaponstartoverride) \
	w_prop(id, sn, float,  weaponthrowable, weaponthrowable)

#ifdef SVQC
HOOK_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)

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
#endif
#else
#ifdef SVQC

void spawnfunc_weapon_hook(void)
{
	if(g_grappling_hook) // offhand hook
	{
		startitem_failed = TRUE;
		remove(self);
		return;
	}
	weapon_defaultspawnfunc(WEP_HOOK);
}

void W_Hook_ExplodeThink(void)
{
	float dt, dmg_remaining_next, f;

	dt = time - self.teleport_time;
	dmg_remaining_next = pow(bound(0, 1 - dt / self.dmg_duration, 1), self.dmg_power);

	f = self.dmg_last - dmg_remaining_next;
	self.dmg_last = dmg_remaining_next;

	RadiusDamage(self, self.realowner, self.dmg * f, self.dmg_edge * f, self.dmg_radius, self.realowner, world, self.dmg_force * f, self.projectiledeathtype, world);
	self.projectiledeathtype |= HITTYPE_BOUNCE;
	//RadiusDamage(self, world, self.dmg * f, self.dmg_edge * f, self.dmg_radius, world, world, self.dmg_force * f, self.projectiledeathtype, world);

	if(dt < self.dmg_duration)
		self.nextthink = time + 0.05; // soon
	else
		remove(self);
}

void W_Hook_Explode2(void)
{
	self.event_damage = func_null;
	self.touch = func_null;
	self.effects |= EF_NODRAW;

	self.think = W_Hook_ExplodeThink;
	self.nextthink = time;
	self.dmg = WEP_CVAR_SEC(hook, damage);
	self.dmg_edge = WEP_CVAR_SEC(hook, edgedamage);
	self.dmg_radius = WEP_CVAR_SEC(hook, radius);
	self.dmg_force = WEP_CVAR_SEC(hook, force);
	self.dmg_power = WEP_CVAR_SEC(hook, power);
	self.dmg_duration = WEP_CVAR_SEC(hook, duration);
	self.teleport_time = time;
	self.dmg_last = 1;
	self.movetype = MOVETYPE_NONE;
}

void W_Hook_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(self.health <= 0)
		return;
		
	if(!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt	
	
	self.health = self.health - damage;
	
	if(self.health <= 0)
		W_PrepareExplosionByDamage(self.realowner, W_Hook_Explode2);
}

void W_Hook_Touch2(void)
{
	PROJECTILE_TOUCH;
	self.use();
}

void W_Hook_Attack2(void)
{
	entity gren;

	//W_DecreaseAmmo(WEP_CVAR_SEC(hook, ammo)); // WEAPONTODO: Figure out how to handle ammo with hook secondary (gravitybomb)
	W_SetupShot(self, FALSE, 4, "weapons/hookbomb_fire.wav", CH_WEAPON_A, WEP_CVAR_SEC(hook, damage));

	gren = spawn();
	gren.owner = gren.realowner = self;
	gren.classname = "hookbomb";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = WEP_CVAR_SEC(hook, damage);
	gren.movetype = MOVETYPE_TOSS;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_HOOK | HITTYPE_SECONDARY;
	setorigin(gren, w_shotorg);
	setsize(gren, '0 0 0', '0 0 0');

	gren.nextthink = time + WEP_CVAR_SEC(hook, lifetime);
	gren.think = adaptor_think2use_hittype_splash;
	gren.use = W_Hook_Explode2;
	gren.touch = W_Hook_Touch2;
	
	gren.takedamage = DAMAGE_YES;
	gren.health = WEP_CVAR_SEC(hook, health);
	gren.damageforcescale = WEP_CVAR_SEC(hook, damageforcescale);
	gren.event_damage = W_Hook_Damage;
	gren.damagedbycontents = TRUE;
	gren.missile_flags = MIF_SPLASH | MIF_ARC;

	gren.velocity = '0 0 1' * WEP_CVAR_SEC(hook, speed);
	if(autocvar_g_projectiles_newton_style)
		gren.velocity = gren.velocity + self.velocity;

	gren.gravity = WEP_CVAR_SEC(hook, gravity);
	//W_SetupProjVelocity_Basic(gren); // just falling down!

	gren.angles = '0 0 0';
	gren.flags = FL_PROJECTILE;

	CSQCProjectile(gren, TRUE, PROJECTILE_HOOKBOMB, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

float W_Hook(float req)
{
	float hooked_time_max, hooked_fuel;
		
	switch(req)
	{
		case WR_AIM:
		{
			// no bot AI for hook (yet?)
			return TRUE;
		}
		case WR_THINK:
		{
			if(self.BUTTON_ATCK || (!(self.items & IT_JETPACK) && self.BUTTON_HOOK))
			{
				if(!self.hook)
				if(!(self.hook_state & HOOK_WAITING_FOR_RELEASE))
				if(!(self.hook_state & HOOK_FIRING))
				if(time > self.hook_refire)
				if(weapon_prepareattack(0, -1))
				{
					W_DecreaseAmmo(WEP_CVAR_PRI(hook, ammo));
					self.hook_state |= HOOK_FIRING;
					weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_PRI(hook, animtime), w_ready);				
				}
			}

			if(self.BUTTON_ATCK2)
			{
				if(weapon_prepareattack(1, WEP_CVAR_SEC(hook, refire)))
				{
					W_Hook_Attack2();
					weapon_thinkf(WFRAME_FIRE2, WEP_CVAR_SEC(hook, animtime), w_ready);
				}
			}

			if(self.hook)
			{
				// if hooked, no bombs, and increase the timer
				self.hook_refire = max(self.hook_refire, time + WEP_CVAR_PRI(hook, refire) * W_WeaponRateFactor());

				// hook also inhibits health regeneration, but only for 1 second
				if(!(self.items & IT_UNLIMITED_WEAPON_AMMO))
					self.pauseregen_finished = max(self.pauseregen_finished, time + autocvar_g_balance_pause_fuel_regen);
			}

			if(self.hook && self.hook.state == 1)
			{
				hooked_time_max = WEP_CVAR_PRI(hook, hooked_time_max);			
				if(hooked_time_max > 0)
				{
					if( time > self.hook_time_hooked + hooked_time_max )
						self.hook_state |= HOOK_REMOVING;
				}
				
				hooked_fuel = WEP_CVAR_PRI(hook, hooked_ammo);
				if(hooked_fuel > 0)
				{
					if( time > self.hook_time_fueldecrease )
					{
						if(!(self.items & IT_UNLIMITED_WEAPON_AMMO))
						{
							if( self.ammo_fuel >= (time - self.hook_time_fueldecrease) * hooked_fuel )
							{
								W_DecreaseAmmo((time - self.hook_time_fueldecrease) * hooked_fuel);
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
				self.hook_time_fueldecrease = time + WEP_CVAR_PRI(hook, hooked_time_free);
			}

			if(self.BUTTON_CROUCH)
			{
				self.hook_state &= ~HOOK_PULLING;
				if(self.BUTTON_ATCK || (!(self.items & IT_JETPACK) && self.BUTTON_HOOK))
					self.hook_state &= ~HOOK_RELEASING;
				else
					self.hook_state |= HOOK_RELEASING;
			}
			else
			{
				self.hook_state |= HOOK_PULLING;
				self.hook_state &= ~HOOK_RELEASING;

				if(self.BUTTON_ATCK || (!(self.items & IT_JETPACK) && self.BUTTON_HOOK))
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
			
			return TRUE;
		}
		case WR_INIT:
		{
			precache_model("models/weapons/g_hookgun.md3");
			precache_model("models/weapons/v_hookgun.md3");
			precache_model("models/weapons/h_hookgun.iqm");
			precache_sound("weapons/hook_impact.wav"); // done by g_hook.qc
			precache_sound("weapons/hook_fire.wav");
			precache_sound("weapons/hookbomb_fire.wav");
			HOOK_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP)
			return TRUE;
		}
		case WR_SETUP:
		{
			self.hook_state &= ~HOOK_WAITING_FOR_RELEASE;
			return TRUE;
		}
		case WR_CHECKAMMO1:
		{
			if(self.hook)
				return self.ammo_fuel > 0;
			else
				return self.ammo_fuel >= WEP_CVAR_PRI(hook, ammo);
		}
		case WR_CHECKAMMO2:
		{
			// infinite ammo for now
			return TRUE; // self.ammo_cells >= WEP_CVAR_SEC(hook, ammo); // WEAPONTODO: see above
		}
		case WR_CONFIG:
		{
			HOOK_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS)
			return TRUE;
		}
		case WR_RESETPLAYER:
		{
			self.hook_refire = time;
			return TRUE;
		}
		case WR_SUICIDEMESSAGE:
		{
			return FALSE;
		}
		case WR_KILLMESSAGE:
		{
			return WEAPON_HOOK_MURDER;
		}
	}
	return FALSE;
}
#endif
#ifdef CSQC
float W_Hook(float req)
{
	switch(req)
	{
		case WR_IMPACTEFFECT:
		{
			vector org2;
			org2 = w_org + w_backoff * 2;
			pointparticles(particleeffectnum("hookbomb_explode"), org2, '0 0 0', 1);
			if(!w_issilent)
				sound(self, CH_SHOTS, "weapons/hookbomb_impact.wav", VOL_BASE, ATTN_NORM);
				
			return TRUE;
		}
		case WR_INIT:
		{
			precache_sound("weapons/hookbomb_impact.wav");
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
