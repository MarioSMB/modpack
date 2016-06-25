#ifndef IMPLEMENTATION
MODEL(ROCKETLAUNCHER_MUZZLEFLASH,           "models/flash.md3");
MODEL(ROCKETLAUNCHER_VIEW,                  W_Model("h_rocketlauncher.iqm"));
MODEL(ROCKETLAUNCHER_WORLD,                 W_Model("v_rocketlauncher.md3"));
MODEL(ROCKETLAUNCHER_ITEM,                  W_Model("g_rocketlauncher.md3"));

SOUND(ROCKETLAUNCHER_FIRE, "quake_weapons/sgun1");

float autocvar_g_balance_rocketlauncher_ammo = 4;
float autocvar_g_balance_rocketlauncher_animtime = 0.4;
float autocvar_g_balance_rocketlauncher_damage = 110;
float autocvar_g_balance_rocketlauncher_damageforcescale = 1;
float autocvar_g_balance_rocketlauncher_detonatedelay = 0.02;
float autocvar_g_balance_rocketlauncher_edgedamage = 50;
float autocvar_g_balance_rocketlauncher_force = 300;
float autocvar_g_balance_rocketlauncher_health = 30;
float autocvar_g_balance_rocketlauncher_lifetime = 3;
float autocvar_g_balance_rocketlauncher_radius = 130;
float autocvar_g_balance_rocketlauncher_refire = 1.1;
float autocvar_g_balance_rocketlauncher_reload_ammo = 0;
float autocvar_g_balance_rocketlauncher_reload_time = 2;
float autocvar_g_balance_rocketlauncher_speed = 1000;
float autocvar_g_balance_rocketlauncher_speedaccel = 1000;
float autocvar_g_balance_rocketlauncher_speedstart = 800;
float autocvar_g_balance_rocketlauncher_switchdelay_drop = 0.2;
float autocvar_g_balance_rocketlauncher_switchdelay_raise = 0.2;
string autocvar_g_balance_rocketlauncher_weaponreplace = "";
float autocvar_g_balance_rocketlauncher_weaponstart = 0;
float autocvar_g_balance_rocketlauncher_weaponstartoverride = -1;
float autocvar_g_balance_rocketlauncher_weaponthrowable = 1;

CLASS(RocketLauncher, Weapon)
/* ammotype  */ ATTRIB(RocketLauncher, ammo_field, .int, ammo_rockets)
/* impulse   */ ATTRIB(RocketLauncher, impulse, int, 7)
/* flags     */ ATTRIB(RocketLauncher, spawnflags, int, WEP_FLAG_RELOADABLE | WEP_FLAG_CANCLIMB | WEP_TYPE_SPLASH);
/* rating    */ ATTRIB(RocketLauncher, bot_pickupbasevalue, float, BOT_PICKUP_RATING_HIGH);
/* color     */ ATTRIB(RocketLauncher, wpcolor, vector, '1 1 0');
/* modelname */ ATTRIB(RocketLauncher, mdl, string, "rocketlauncher");
#ifndef MENUQC
/* model     */ ATTRIB(RocketLauncher, m_model, Model, MDL_ROCKETLAUNCHER_ITEM);
#endif
/* crosshair */ ATTRIB(RocketLauncher, w_crosshair, string, "gfx/crosshairrocketlauncher");
/* crosshair */ ATTRIB(RocketLauncher, w_crosshair_size, float, 0.7);
/* wepimg    */ ATTRIB(RocketLauncher, model2, string, "weaponrocketlauncher");
/* refname   */ ATTRIB(RocketLauncher, netname, string, "rocketlauncher");
/* wepname   */ ATTRIB(RocketLauncher, m_name, string, _("Rocket Launcher"));

#define X(BEGIN, P, END, class, prefix) \
	BEGIN(class) \
		P(class, prefix, ammo, float, NONE) \
		P(class, prefix, animtime, float, NONE) \
		P(class, prefix, damage, float, NONE) \
		P(class, prefix, damageforcescale, float, NONE) \
		P(class, prefix, detonatedelay, float, NONE) \
		P(class, prefix, edgedamage, float, NONE) \
		P(class, prefix, force, float, NONE) \
		P(class, prefix, health, float, NONE) \
		P(class, prefix, lifetime, float, NONE) \
		P(class, prefix, radius, float, NONE) \
		P(class, prefix, refire, float, NONE) \
		P(class, prefix, speed, float, NONE) \
		P(class, prefix, speedaccel, float, NONE) \
		P(class, prefix, speedstart, float, NONE) \
		P(class, prefix, reload_ammo, float, NONE) \
        P(class, prefix, reload_time, float, NONE) \
        P(class, prefix, switchdelay_raise, float, NONE) \
        P(class, prefix, switchdelay_drop, float, NONE) \
        P(class, prefix, weaponreplace, string, NONE) \
        P(class, prefix, weaponstart, float, NONE) \
        P(class, prefix, weaponstartoverride, float, NONE) \
        P(class, prefix, weaponthrowable, float, NONE) \
	END()
    W_MOD_PROPS(X, RocketLauncher, rocketlauncher)
#undef X

ENDCLASS(RocketLauncher)
REGISTER_WEAPON(ROCKETLAUNCHER, rocketlauncher, NEW(RocketLauncher));

#endif
#ifdef IMPLEMENTATION
#ifdef SVQC
spawnfunc(weapon_qrocketlauncher) { weapon_defaultspawnfunc(this, WEP_ROCKETLAUNCHER); }

void W_RocketLauncher_Unregister(entity this)
{
	if(this.realowner && this.realowner.lastrocket == this)
	{
		this.realowner.lastrocket = world;
		// this.realowner.rl_release = 1;
	}
}

void W_RocketLauncher_Explode(entity this, entity directhitentity)
{
	W_RocketLauncher_Unregister(this);

	if(directhitentity.takedamage == DAMAGE_AIM)
		if(IS_PLAYER(directhitentity))
			if(DIFF_TEAM(this.realowner, directhitentity))
				if(!IS_DEAD(directhitentity))
					if(IsFlying(directhitentity))
						Send_Notification(NOTIF_ONE, this.realowner, MSG_ANNCE, ANNCE_ACHIEVEMENT_AIRSHOT);

	this.event_damage = func_null;
	this.takedamage = DAMAGE_NO;

	RadiusDamage(
		this,
		this.realowner,
		WEP_CVAR(rocketlauncher, damage),
		WEP_CVAR(rocketlauncher, edgedamage),
		WEP_CVAR(rocketlauncher, radius),
		world,
		world,
		WEP_CVAR(rocketlauncher, force),
		this.projectiledeathtype,
		directhitentity
	);

	Weapon thiswep = WEP_ROCKETLAUNCHER;
	if(PS(this.realowner).m_weapon == thiswep)
	{
		if(this.realowner.(thiswep.ammo_field) < WEP_CVAR(rocketlauncher, ammo))
		if(!(this.realowner.items & IT_UNLIMITED_WEAPON_AMMO))
		{
			this.realowner.cnt = WEP_ROCKETLAUNCHER.m_id;
			int slot = 0;
			ATTACK_FINISHED(this.realowner, slot) = time;
			PS(this.realowner).m_switchweapon = w_getbestweapon(this.realowner);
		}
	}
	remove(this);
}

void W_RocketLauncher_Explode_think(entity this)
{
	W_RocketLauncher_Explode(this, NULL);
}

// assume thisdir == -goaldir:
//   f == -1
//   v = solve_qadratic(m2 - 1, -2 * (m2 - 1), m2 - 1)
//   (m2 - 1) x^2 - 2 * (m2 - 1) * x + (m2 - 1) = 0
//   x^2 - 2 * x + 1 = 0
//   (x - 1)^2 = 0
//   x = 1
//   normalize(thisdir + goaldir)
//   normalize(0)

void W_RocketLauncher_Think(entity this)
{
	float velspeed;
	this.nextthink = time;
	if(time > this.cnt)
	{
		this.projectiledeathtype |= HITTYPE_BOUNCE;
		W_RocketLauncher_Explode(this, NULL);
		return;
	}

	// accelerate
	makevectors(this.angles.x * '-1 0 0' + this.angles.y * '0 1 0');
	velspeed = WEP_CVAR(rocketlauncher, speed) * W_WeaponSpeedFactor(this.realowner) - (this.velocity * v_forward);
	if(velspeed > 0)
		this.velocity = this.velocity + v_forward * min(WEP_CVAR(rocketlauncher, speedaccel) * W_WeaponSpeedFactor(this.realowner) * frametime, velspeed);

	if(this.csqcprojectile_clientanimate == 0)
		UpdateCSQCProjectile(this);
}

void W_RocketLauncher_Touch(entity this, entity toucher)
{
	if(WarpZone_Projectile_Touch(this, toucher))
	{
		if(wasfreed(this))
			W_RocketLauncher_Unregister(this);
		return;
	}
	W_RocketLauncher_Unregister(this);
	W_RocketLauncher_Explode(this, toucher);
}

void W_RocketLauncher_Damage(entity this, entity inflictor, entity attacker, float damage, int deathtype, vector hitloc, vector force)
{
	if(this.health <= 0)
		return;

	if(!W_CheckProjectileDamage(inflictor.realowner, this.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt

	this.health = this.health - damage;
	this.angles = vectoangles(this.velocity);

	if(this.health <= 0)
		W_PrepareExplosionByDamage(this, attacker, W_RocketLauncher_Explode_think);
}

void W_RocketLauncher_Attack(Weapon thiswep, entity actor)
{
	entity missile;
	entity flash;

	W_DecreaseAmmo(thiswep, actor, WEP_CVAR(rocketlauncher, ammo));

	W_SetupShot_ProjectileSize(actor, '-3 -3 -3', '3 3 3', false, 5, SND_ROCKETLAUNCHER_FIRE, CH_WEAPON_A, WEP_CVAR(rocketlauncher, damage));
	Send_Effect(EFFECT_ROCKET_MUZZLEFLASH, w_shotorg, w_shotdir * 1000, 1);

	missile = WarpZone_RefSys_SpawnSameRefSys(actor);
	missile.owner = missile.realowner = actor;
	actor.lastrocket = missile;
	if(WEP_CVAR(rocketlauncher, detonatedelay) >= 0)
		missile.spawnshieldtime = time + WEP_CVAR(rocketlauncher, detonatedelay);
	else
		missile.spawnshieldtime = -1;
	missile.classname = "rocket";
	missile.bot_dodge = true;
	missile.bot_dodgerating = WEP_CVAR(rocketlauncher, damage) * 2; // * 2 because it can be detonated inflight which makes it even more dangerous

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = WEP_CVAR(rocketlauncher, damageforcescale);
	missile.health = WEP_CVAR(rocketlauncher, health);
	missile.event_damage = W_RocketLauncher_Damage;
	missile.damagedbycontents = true;

	missile.movetype = MOVETYPE_FLY;
	PROJECTILE_MAKETRIGGER(missile);
	missile.projectiledeathtype = WEP_ROCKETLAUNCHER.m_id;
	setsize(missile, '-3 -3 -3', '3 3 3'); // give it some size so it can be shot

	setorigin(missile, w_shotorg - v_forward * 3); // move it back so it hits the wall at the right point
	W_SetupProjVelocity_Basic(missile, WEP_CVAR(rocketlauncher, speedstart), 0);
	missile.angles = vectoangles(missile.velocity);

	settouch(missile, W_RocketLauncher_Touch);
	setthink(missile, W_RocketLauncher_Think);
	missile.nextthink = time;
	missile.cnt = time + WEP_CVAR(rocketlauncher, lifetime);
	missile.flags = FL_PROJECTILE;
	missile.missile_flags = MIF_SPLASH;

	CSQCProjectile(missile, WEP_CVAR(rocketlauncher, speedaccel) == 0, PROJECTILE_ROCKET, false); // because of fly sound

	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, MDL_ROCKETLAUNCHER_MUZZLEFLASH); // precision set below
	SUB_SetFade(flash, time, 0.1);
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(actor, flash, '5 0 0');

	// common properties
	MUTATOR_CALLHOOK(EditProjectile, actor, missile);
}

		#if 0
		METHOD(RocketLauncher, wr_aim, void(entity thiswep, entity actor))
		{
			// aim and decide to fire if appropriate
			PHYS_INPUT_BUTTON_ATCK(actor) = bot_aim(actor, WEP_CVAR(rocketlauncher, speed), 0, WEP_CVAR(rocketlauncher, lifetime), false);
			if(skill >= 2) // skill 0 and 1 bots won't detonate rockets!
			{
				// decide whether to detonate rockets
				entity missile, targetlist, targ;
				targetlist = findchainfloat(bot_attack, true);
				for(missile = world; (missile = find(missile, classname, "rocket")); ) if(missile.realowner == actor)
				{
					targ = targetlist;
					while(targ)
					{
						if(targ != missile.realowner && vlen(targ.origin - missile.origin) < WEP_CVAR(rocketlauncher, radius))
						{
							PHYS_INPUT_BUTTON_ATCK2(actor) = true;
							break;
						}
						targ = targ.chain;
					}
				}

				if(PHYS_INPUT_BUTTON_ATCK2(actor)) PHYS_INPUT_BUTTON_ATCK(actor) = false;
			}
		}
		#else
		METHOD(RocketLauncher, wr_aim, void(entity thiswep, entity actor))
		{
			// aim and decide to fire if appropriate
			PHYS_INPUT_BUTTON_ATCK(actor) = bot_aim(actor, WEP_CVAR(rocketlauncher, speed), 0, WEP_CVAR(rocketlauncher, lifetime), false);
			if(skill >= 2) // skill 0 and 1 bots won't detonate rockets!
			{
				// decide whether to detonate rockets
				entity missile, targetlist, targ;
				float edgedamage, coredamage, edgeradius, recipricoledgeradius, d;
				float selfdamage, teamdamage, enemydamage;
				edgedamage = WEP_CVAR(rocketlauncher, edgedamage);
				coredamage = WEP_CVAR(rocketlauncher, damage);
				edgeradius = WEP_CVAR(rocketlauncher, radius);
				recipricoledgeradius = 1 / edgeradius;
				selfdamage = 0;
				teamdamage = 0;
				enemydamage = 0;
				targetlist = findchainfloat(bot_attack, true);
				missile = find(world, classname, "rocket");
				while(missile)
				{
					if(missile.realowner != actor)
					{
						missile = find(missile, classname, "rocket");
						continue;
					}
					targ = targetlist;
					while(targ)
					{
						d = vlen(targ.origin + (targ.mins + targ.maxs) * 0.5 - missile.origin);
						d = bound(0, edgedamage + (coredamage - edgedamage) * sqrt(1 - d * recipricoledgeradius), 10000);
						// count potential damage according to type of target
						if(targ == actor)
							selfdamage = selfdamage + d;
						else if(targ.team == actor.team && teamplay)
							teamdamage = teamdamage + d;
						else if(bot_shouldattack(actor, targ))
							enemydamage = enemydamage + d;
						targ = targ.chain;
					}
					missile = find(missile, classname, "rocket");
				}
				float desirabledamage;
				desirabledamage = enemydamage;
				if(time > actor.invincible_finished && time > actor.spawnshieldtime)
					desirabledamage = desirabledamage - selfdamage * autocvar_g_balance_selfdamagepercent;
				if(teamplay && actor.team)
					desirabledamage = desirabledamage - teamdamage;

				missile = find(world, classname, "rocket");
				while(missile)
				{
					if(missile.realowner != actor)
					{
						missile = find(missile, classname, "rocket");
						continue;
					}
					makevectors(missile.v_angle);
					targ = targetlist;
					if(skill > 9) // normal players only do this for the target they are tracking
					{
						targ = targetlist;
						while(targ)
						{
							if(
								(v_forward * normalize(missile.origin - targ.origin)< 0.1)
								&& desirabledamage > 0.1*coredamage
							)PHYS_INPUT_BUTTON_ATCK2(actor) = true;
							targ = targ.chain;
						}
					}else{
						float distance; distance= bound(300,vlen(actor.origin-actor.enemy.origin),30000);
						//As the distance gets larger, a correct detonation gets near imposible
						//Bots are assumed to use the rocket spawnfunc_light to see if the rocket gets near a player
						if(v_forward * normalize(missile.origin - actor.enemy.origin)< 0.1)
							if(IS_PLAYER(actor.enemy))
								if(desirabledamage >= 0.1*coredamage)
									if(random()/distance*300 > frametime*bound(0,(10-skill)*0.2,1))
										PHYS_INPUT_BUTTON_ATCK2(actor) = true;
					//	dprint(ftos(random()/distance*300),">");dprint(ftos(frametime*bound(0,(10-skill)*0.2,1)),"\n");
					}

					missile = find(missile, classname, "rocket");
				}
				// if we would be doing at X percent of the core damage, detonate it
				// but don't fire a new shot at the same time!
				if(desirabledamage >= 0.75 * coredamage) //this should do group damage in rare fortunate events
					PHYS_INPUT_BUTTON_ATCK2(actor) = true;
				if((skill > 6.5) && (selfdamage > actor.health))
					PHYS_INPUT_BUTTON_ATCK2(actor) = false;
				//if(PHYS_INPUT_BUTTON_ATCK2(actor) == true)
				//	dprint(ftos(desirabledamage),"\n");
				if(PHYS_INPUT_BUTTON_ATCK2(actor) == true) PHYS_INPUT_BUTTON_ATCK(actor) = false;
			}
		}
		#endif
		METHOD(RocketLauncher, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
		{
			if(WEP_CVAR(rocketlauncher, reload_ammo) && actor.clip_load < WEP_CVAR(rocketlauncher, ammo)) { // forced reload
				Weapon w = Weapons_from(actor.weapon);
				w.wr_reload(w, actor, weaponentity);
			} else {
				if(fire & 1)
				{
					if(weapon_prepareattack(thiswep, actor, weaponentity, false, WEP_CVAR(rocketlauncher, refire)))
					{
						W_RocketLauncher_Attack(thiswep, actor);
						weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, WEP_CVAR(rocketlauncher, animtime), w_ready);
					}
				}
			}
		}
		METHOD(RocketLauncher, wr_checkammo1, bool(entity thiswep, entity actor))
		{
			float ammo_amount = actor.(thiswep.ammo_field) >= WEP_CVAR(rocketlauncher, ammo);
			ammo_amount += actor.(weapon_load[WEP_ROCKETLAUNCHER.m_id]) >= WEP_CVAR(rocketlauncher, ammo);
			return ammo_amount;
		}
		METHOD(RocketLauncher, wr_checkammo2, bool(entity thiswep, entity actor))
		{
			return false;
		}
		METHOD(RocketLauncher, wr_reload, void(entity thiswep, entity actor, .entity weaponentity))
		{
			W_Reload(actor, WEP_CVAR(rocketlauncher, ammo), SND_RELOAD);
		}
		METHOD(RocketLauncher, wr_suicidemessage, Notification(entity thiswep))
		{
			return WEAPON_DEVASTATOR_SUICIDE;
		}
		METHOD(RocketLauncher, wr_killmessage, Notification(entity thiswep))
		{
			if((w_deathtype & HITTYPE_BOUNCE) || (w_deathtype & HITTYPE_SPLASH))
				return WEAPON_DEVASTATOR_MURDER_SPLASH;
			else
				return WEAPON_DEVASTATOR_MURDER_DIRECT;
		}

#endif
#ifdef CSQC

		METHOD(RocketLauncher, wr_impacteffect, void(entity thiswep, entity actor))
		{
			vector org2;
			org2 = w_org + w_backoff * 12;
			__pointparticles(particleeffectnum(EFFECT_ROCKET_EXPLODE), org2, '0 0 0', 1);
			if(!w_issilent)
				sound(actor, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTN_NORM);
		}

#endif
#endif
