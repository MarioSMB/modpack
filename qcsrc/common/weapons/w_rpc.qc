#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id	 */ RPC,
/* function	 */ W_RocketPropelledChainsaw,
/* ammotype	 */ ammo_rockets,
/* impulse	 */ 7,
/* flags	 */ WEP_FLAG_MUTATORBLOCKED | WEP_FLAG_HIDDEN | WEP_FLAG_NORMAL | WEP_FLAG_CANCLIMB | WEP_FLAG_RELOADABLE | WEP_TYPE_SPLASH | WEP_FLAG_SUPERWEAPON,
/* rating	 */ BOT_PICKUP_RATING_HIGH,
/* color     */ '0.5 0.5 0',
/* modelname */ "ok_rl",
/* simplemdl */ "foobar",
/* crosshair */ "gfx/crosshairrocketlauncher 0.5875",
/* wepimg    */ "weaponrpc",
/* refname   */ "rpc",
/* wepname	 */ _("Rocket Propelled Chainsaw")
);

#define RPC_SETTINGS(w_cvar,w_prop) RPC_SETTINGS_LIST(w_cvar, w_prop, RPC, rpc)
#define RPC_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, NONE, ammo) \
	w_cvar(id, sn, NONE, animtime) \
	w_cvar(id, sn, NONE, damage) \
	w_cvar(id, sn, NONE, damage2) \
	w_cvar(id, sn, NONE, damageforcescale) \
	w_cvar(id, sn, NONE, edgedamage) \
	w_cvar(id, sn, NONE, force) \
	w_cvar(id, sn, NONE, health) \
	w_cvar(id, sn, NONE, lifetime) \
	w_cvar(id, sn, NONE, radius) \
	w_cvar(id, sn, NONE, refire) \
	w_cvar(id, sn, NONE, speed) \
	w_cvar(id, sn, NONE, speedaccel) \
	w_prop(id, sn, float,  reloading_ammo, reload_ammo) \
	w_prop(id, sn, float,  reloading_time, reload_time) \
	w_prop(id, sn, float,  switchdelay_raise, switchdelay_raise) \
	w_prop(id, sn, float,  switchdelay_drop, switchdelay_drop) \
	w_prop(id, sn, string, weaponreplace, weaponreplace) \
	w_prop(id, sn, float,  weaponstart, weaponstart) \
	w_prop(id, sn, float,  weaponstartoverride, weaponstartoverride) \
	w_prop(id, sn, float,  weaponthrowable, weaponthrowable)

#ifdef SVQC
RPC_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
#endif
#else
#ifdef SVQC
void spawnfunc_weapon_rpc() { weapon_defaultspawnfunc(WEP_RPC); }

void W_RocketPropelledChainsaw_Explode()
{
	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	RadiusDamage (self, self.realowner, WEP_CVAR(rpc, damage), WEP_CVAR(rpc, edgedamage), WEP_CVAR(rpc, radius), world, world, WEP_CVAR(rpc, force), self.projectiledeathtype, other);

	remove (self);
}

void W_RocketPropelledChainsaw_Touch (void)
{
	if(WarpZone_Projectile_Touch())
		if(wasfreed(self))
			return;

	W_RocketPropelledChainsaw_Explode();
}

void W_RocketPropelledChainsaw_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;

	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt

	self.health = self.health - damage;

	if (self.health <= 0)
		W_PrepareExplosionByDamage(attacker, W_RocketPropelledChainsaw_Explode);
}

void W_RocketPropelledChainsaw_Think()
{
	if(self.cnt <= time)
	{
		remove(self);
		return;
	}

	self.cnt = vlen(self.velocity);
	self.wait = self.cnt * sys_frametime;
	self.pos1 = normalize(self.velocity);

	tracebox(self.origin, self.mins, self.maxs, self.origin + self.pos1 * (2 * self.wait), MOVE_NORMAL, self);
	if(IS_PLAYER(trace_ent))
		Damage (trace_ent, self, self.realowner, WEP_CVAR(rpc, damage2), self.projectiledeathtype, self.origin, normalize(self.origin - other.origin) * WEP_CVAR(rpc, force));

	self.velocity = self.pos1 * (self.cnt + (WEP_CVAR(rpc, speedaccel) * sys_frametime));

	UpdateCSQCProjectile(self);
	self.nextthink = time;
}

void W_RocketPropelledChainsaw_Attack (void)
{
	entity missile = spawn(); //WarpZone_RefSys_SpawnSameRefSys(self);
	entity flash = spawn ();

	W_DecreaseAmmo(WEP_CVAR(rpc, ammo));
	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 5, W_Sound("rocket_fire"), CH_WEAPON_A, WEP_CVAR(rpc, damage));
	Send_Effect(EFFECT_ROCKET_MUZZLEFLASH, w_shotorg, w_shotdir * 1000, 1);
	PROJECTILE_MAKETRIGGER(missile);

	missile.owner = missile.realowner = self;
	missile.bot_dodge = TRUE;
	missile.bot_dodgerating = WEP_CVAR(rpc, damage) * 2;

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = WEP_CVAR(rpc, damageforcescale);
	missile.health = WEP_CVAR(rpc, health);
	missile.event_damage = W_RocketPropelledChainsaw_Damage;
	missile.damagedbycontents = TRUE;
	missile.movetype = MOVETYPE_FLY;

	missile.projectiledeathtype = WEP_RPC;
	setsize (missile, '-3 -3 -3', '3 3 3'); // give it some size so it can be shot

	setorigin (missile, w_shotorg - v_forward * 3); // move it back so it hits the wall at the right point
	W_SetupProjVelocity_Basic(missile, WEP_CVAR(rpc, speed), 0);

	missile.touch = W_RocketPropelledChainsaw_Touch;

	missile.think = W_RocketPropelledChainsaw_Think;
	missile.cnt = time + WEP_CVAR(rpc, lifetime);
	missile.nextthink = time;
	missile.flags = FL_PROJECTILE;

	CSQCProjectile(missile, TRUE, PROJECTILE_RPC, FALSE);

	setmodel(flash, "models/flash.md3"); // precision set below
	SUB_SetFade (flash, time, 0.1);
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '5 0 0');
	missile.pos1 = missile.velocity;

	other = missile; MUTATOR_CALLHOOK(EditProjectile);
}

float W_RocketPropelledChainsaw(float req)
{
	float ammo_amount = FALSE;
	switch(req)
	{
		case WR_AIM:
		{
			self.BUTTON_ATCK = bot_aim(WEP_CVAR(rpc, speed), 0, WEP_CVAR(rpc, lifetime), FALSE);
			return TRUE;
		}
		case WR_THINK:
		{
			if(WEP_CVAR(rpc, reload_ammo) && self.clip_load < WEP_CVAR(rpc, ammo))
				WEP_ACTION(self.weapon, WR_RELOAD);
			else
			{
				if (self.BUTTON_ATCK)
				{
					if(weapon_prepareattack(0, WEP_CVAR(rpc, refire)))
					{
						W_RocketPropelledChainsaw_Attack();
						weapon_thinkf(WFRAME_FIRE1, WEP_CVAR(rpc, animtime), w_ready);
					}
				}

				if (self.BUTTON_ATCK2)
				{
					// to-do
				}
			}

			return TRUE;
		}
		case WR_INIT:
		{
			precache_model ("models/flash.md3");
			precache_model("models/weapons/h_ok_rl.iqm");
			precache_model("models/weapons/v_ok_rl.md3");
			precache_model("models/weapons/g_ok_rl.md3");
			precache_sound (W_Sound("rocket_fire"));
			RPC_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP)
			return TRUE;
		}
		case WR_CHECKAMMO1:
		{
			ammo_amount = self.WEP_AMMO(RPC) >= WEP_CVAR(rpc, ammo);
			ammo_amount += self.(weapon_load[WEP_RPC]) >= WEP_CVAR(rpc, ammo);
			return ammo_amount;
		}
		case WR_CHECKAMMO2:
		{
			return FALSE;
		}
		case WR_CONFIG:
		{
			RPC_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS)
			return TRUE;
		}
		case WR_RELOAD:
		{
			W_Reload(WEP_CVAR(rpc, ammo), W_Sound("reload"));
			return TRUE;
		}
		case WR_SUICIDEMESSAGE:
		{
			if((w_deathtype & HITTYPE_BOUNCE) || (w_deathtype & HITTYPE_SPLASH))
				return WEAPON_RPC_SUICIDE_SPLASH;
			else
				return WEAPON_RPC_SUICIDE_DIRECT;
		}
		case WR_KILLMESSAGE:
		{
			if(w_deathtype & HITTYPE_SECONDARY)
				return WEAPON_BLASTER_MURDER;
			else if((w_deathtype & HITTYPE_BOUNCE) || (w_deathtype & HITTYPE_SPLASH))
				return WEAPON_RPC_MURDER_SPLASH;
			else
				return WEAPON_RPC_MURDER_DIRECT;
		}
	}

	return FALSE;
}
#endif

#ifdef CSQC
float W_RocketPropelledChainsaw(float req)
{
	switch(req)
	{
		case WR_IMPACTEFFECT:
		{
			vector org2;
			org2 = w_org + w_backoff * 12;
			pointparticles(particleeffectnum("rocket_explode"), org2, '0 0 0', 1);
			if(!w_issilent)
				sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);

			return TRUE;
		}
		case WR_INIT:
		{
			precache_sound("weapons/rocket_impact.wav");
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
