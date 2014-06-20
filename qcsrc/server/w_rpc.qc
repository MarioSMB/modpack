#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id	 */ RPC,
/* function	 */ w_rpc,
/* ammotype	 */ IT_ROCKETS,
/* impulse	 */ 7,
/* flags	 */ WEP_FLAG_MUTATORBLOCKED | WEP_FLAG_HIDDEN | WEP_FLAG_NORMAL | WEP_FLAG_CANCLIMB | WEP_FLAG_RELOADABLE | WEP_TYPE_SPLASH | WEP_FLAG_SUPERWEAPON,
/* rating	 */ BOT_PICKUP_RATING_HIGH,
/* model	 */ "ok_rl",
/* shortname */ "rpc",
/* fullname	 */ _("Rocket Propelled Chainsaw")
);
#else
#ifdef SVQC

void W_RPC_Explode()
{
	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	RadiusDamage (self, self.realowner, autocvar_g_balance_rpc_damage, autocvar_g_balance_rpc_edgedamage, autocvar_g_balance_rpc_radius, world, autocvar_g_balance_rpc_force, self.projectiledeathtype, other);

	remove (self);
}

void W_RPC_Touch (void)
{
	if(WarpZone_Projectile_Touch())
		if(wasfreed(self))
			return;

	//if(other.solid != SOLID_BSP)
	//	  return;

	W_RPC_Explode();
}

void W_RPC_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;

	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt

	self.health = self.health - damage;

	if (self.health <= 0)
		W_PrepareExplosionByDamage(attacker, W_RPC_Explode);
}

void W_RPC_Think()
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
		Damage (trace_ent, self, self.realowner, autocvar_g_balance_rpc_damage2, self.projectiledeathtype, self.origin, normalize(self.origin - other.origin) * autocvar_g_balance_rpc_force);

	self.velocity = self.pos1 * (self.cnt + (autocvar_g_balance_rpc_speedaccel * sys_frametime));

	UpdateCSQCProjectile(self);
	self.nextthink = time;
}

void W_RPC_Attack (void)
{
	entity missile = spawn(); //WarpZone_RefSys_SpawnSameRefSys(self);
	entity flash = spawn ();

	W_DecreaseAmmo(ammo_rockets, autocvar_g_balance_rpc_ammo, autocvar_g_balance_rpc_reload_ammo);
	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 5, "weapons/rocket_fire.wav", CH_WEAPON_A, autocvar_g_balance_rpc_damage, self.weapon);
	pointparticles(particleeffectnum("rocketlauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);
	PROJECTILE_MAKETRIGGER(missile);

	missile.owner = missile.realowner = self;
	missile.bot_dodge = TRUE;
	missile.bot_dodgerating = autocvar_g_balance_rpc_damage * 2;

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = autocvar_g_balance_rpc_damageforcescale;
	missile.health = autocvar_g_balance_rpc_health;
	missile.event_damage = W_RPC_Damage;
	missile.damagedbycontents = TRUE;
	missile.movetype = MOVETYPE_FLY;

	missile.projectiledeathtype = WEP_RPC;
	setsize (missile, '-3 -3 -3', '3 3 3'); // give it some size so it can be shot

	setorigin (missile, w_shotorg - v_forward * 3); // move it back so it hits the wall at the right point
	W_SetupProjectileVelocity(missile, autocvar_g_balance_rpc_speed, 0);

	missile.touch = W_RPC_Touch;

	missile.think = W_RPC_Think;
	//missile.think = SUB_Remove;
	missile.cnt = time + autocvar_g_balance_rpc_lifetime;
	missile.nextthink = time;
	//missile.nextthink = time + autocvar_g_balance_rpc_lifetime;
	missile.flags = FL_PROJECTILE;

	CSQCProjectile(missile, TRUE, PROJECTILE_RPC, FALSE);
	//CSQCProjectile(missile, TRUE, PROJECTILE_ROCKET, FALSE);

	setmodel(flash, "models/flash.md3"); // precision set below
	SUB_SetFade (flash, time, 0.1);
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '5 0 0');
	missile.pos1 = missile.velocity;

	other = missile; MUTATOR_CALLHOOK(EditProjectile);
	//BITXOR_ASSIGN(self.weaponentity.effects, EF_RESTARTANIM_BIT);
}

void spawnfunc_weapon_rpc()
{
	weapon_defaultspawnfunc(WEP_RPC);
}

float w_rpc(float req)
{
	float ammo_amount = FALSE;

	if (req == WR_AIM)
	{
		self.BUTTON_ATCK = bot_aim(autocvar_g_balance_rpc_speed, 0, autocvar_g_balance_rpc_lifetime, FALSE);
	}
	else if (req == WR_THINK)
	{
		if(autocvar_g_balance_rpc_reload_ammo && self.clip_load < autocvar_g_balance_rpc_ammo)
			weapon_action(self.weapon, WR_RELOAD);
		else
		{
			if (self.BUTTON_ATCK)
			{
				if(weapon_prepareattack(0, autocvar_g_balance_rpc_refire))
				{
					W_RPC_Attack();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_rpc_animtime, w_ready);
				}
			}

			if (self.BUTTON_ATCK2)
			{
				// to-do
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/flash.md3");
		precache_model("models/weapons/h_ok_rl.iqm");
		precache_model("models/weapons/v_ok_rl.md3");
		precache_model("models/weapons/g_ok_rl.md3");
		precache_model("models/weapons/ok_rocket.md3");
		precache_sound ("weapons/rocket_fire.wav");
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_RPC);
		self.current_ammo = ammo_rockets;
	}
	else if (req == WR_CHECKAMMO1)
	{
		if(autocvar_g_balance_rpc_reload_ammo)
		{
			if(self.ammo_rockets < autocvar_g_balance_rpc_ammo && self.(weapon_load[WEP_RPC]) < autocvar_g_balance_rpc_ammo)
				ammo_amount = TRUE;
		}
		else if(self.ammo_rockets < autocvar_g_balance_rpc_ammo)
			ammo_amount = TRUE;

		return !ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
		return FALSE;
	else if (req == WR_RESETPLAYER)
	{
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(autocvar_g_balance_rpc_ammo, autocvar_g_balance_rpc_reload_ammo, autocvar_g_balance_rpc_reload_time, "weapons/reload.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
	{
		if(((w_deathtype & HITTYPE_BOUNCE) || (w_deathtype & HITTYPE_SPLASH)))
			return WEAPON_RPC_SUICIDE_SPLASH;
		else
			return WEAPON_RPC_SUICIDE_DIRECT;
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
			return WEAPON_LASER_MURDER;
		else if((w_deathtype & HITTYPE_BOUNCE) || (w_deathtype & HITTYPE_SPLASH))
			return WEAPON_RPC_MURDER_SPLASH;
		else
			return WEAPON_RPC_MURDER_DIRECT;
	}
	return TRUE;
}
#endif

#ifdef CSQC
float w_rpc(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 12;
		pointparticles(particleeffectnum("rocket_explode"), org2, '0 0 0', 1);
		if(!w_issilent)
			sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/rocket_impact.wav");
	}
	return TRUE;
}
#endif
#endif
