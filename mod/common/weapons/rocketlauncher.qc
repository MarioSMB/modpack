#ifndef IMPLEMENTATION
MODEL(ROCKETLAUNCHER_MUZZLEFLASH,           "models/flash.md3");
MODEL(ROCKETLAUNCHER_VIEW,                  W_Model("h_rocketlauncher.iqm"));
MODEL(ROCKETLAUNCHER_WORLD,                 W_Model("v_rocketlauncher.md3"));
MODEL(ROCKETLAUNCHER_ITEM,                  W_Model("g_rocketlauncher.md3"));

SOUND(ROCKETLAUNCHER_FIRE, "quake_weapons/sgun1.wav");

CLASS(RocketLauncher, Weapon)
/* ammotype  */ ATTRIB(RocketLauncher, ammo_field, .int, ammo_rockets)
/* impulse   */ ATTRIB(RocketLauncher, impulse, int, 7)
/* flags     */ ATTRIB(RocketLauncher, spawnflags, int, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_FLAG_CANCLIMB | WEP_TYPE_SPLASH);
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
/* wepname   */ ATTRIB(RocketLauncher, message, string, _("Rocket Launcher"));
ENDCLASS(RocketLauncher)
REGISTER_WEAPON(ROCKETLAUNCHER, NEW(RocketLauncher));

#ifdef SVQC
STATIC_INIT(rocketlauncher_cvars)
{
	localcmd("\ng_balance_rocketlauncher_ammo 4\n");
	localcmd("\ng_balance_rocketlauncher_animtime 0.4\n");
	localcmd("\ng_balance_rocketlauncher_damage 110\n");
	localcmd("\ng_balance_rocketlauncher_damageforcescale 1\n");
	localcmd("\ng_balance_rocketlauncher_detonatedelay 0.02\n");
	localcmd("\ng_balance_rocketlauncher_edgedamage 50\n");
	localcmd("\ng_balance_rocketlauncher_force 300\n");
	localcmd("\ng_balance_rocketlauncher_health 30\n");
	localcmd("\ng_balance_rocketlauncher_lifetime 3\n");
	localcmd("\ng_balance_rocketlauncher_radius 130\n");
	localcmd("\ng_balance_rocketlauncher_refire 1.1\n");
	localcmd("\ng_balance_rocketlauncher_reload_ammo 0\n");
	localcmd("\ng_balance_rocketlauncher_reload_time 2\n");
	localcmd("\ng_balance_rocketlauncher_speed 1000\n");
	localcmd("\ng_balance_rocketlauncher_speedaccel 1000\n");
	localcmd("\ng_balance_rocketlauncher_speedstart 800\n");
	localcmd("\ng_balance_rocketlauncher_switchdelay_drop 0.2\n");
	localcmd("\ng_balance_rocketlauncher_switchdelay_raise 0.2\n");
	localcmd("\ng_balance_rocketlauncher_weaponreplace \"\"\n");
	localcmd("\ng_balance_rocketlauncher_weaponstart 0\n");
	localcmd("\ng_balance_rocketlauncher_weaponstartoverride -1\n");
	localcmd("\ng_balance_rocketlauncher_weaponthrowable 1\n");
}
#endif

#define ROCKETLAUNCHER_SETTINGS(w_cvar,w_prop) ROCKETLAUNCHER_SETTINGS_LIST(w_cvar, w_prop, ROCKETLAUNCHER, rocketlauncher)
#define ROCKETLAUNCHER_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, NONE, ammo) \
	w_cvar(id, sn, NONE, animtime) \
	w_cvar(id, sn, NONE, damage) \
	w_cvar(id, sn, NONE, damageforcescale) \
	w_cvar(id, sn, NONE, detonatedelay) \
	w_cvar(id, sn, NONE, edgedamage) \
	w_cvar(id, sn, NONE, force) \
	w_cvar(id, sn, NONE, health) \
	w_cvar(id, sn, NONE, lifetime) \
	w_cvar(id, sn, NONE, radius) \
	w_cvar(id, sn, NONE, refire) \
	w_cvar(id, sn, NONE, speed) \
	w_cvar(id, sn, NONE, speedaccel) \
	w_cvar(id, sn, NONE, speedstart) \
	w_prop(id, sn, float,  reloading_ammo, reload_ammo) \
	w_prop(id, sn, float,  reloading_time, reload_time) \
	w_prop(id, sn, float,  switchdelay_raise, switchdelay_raise) \
	w_prop(id, sn, float,  switchdelay_drop, switchdelay_drop) \
	w_prop(id, sn, string, weaponreplace, weaponreplace) \
	w_prop(id, sn, float,  weaponstart, weaponstart) \
	w_prop(id, sn, float,  weaponstartoverride, weaponstartoverride) \
	w_prop(id, sn, float,  weaponthrowable, weaponthrowable)

#ifdef SVQC
ROCKETLAUNCHER_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
#endif
#endif
#ifdef IMPLEMENTATION
#ifdef SVQC
spawnfunc(weapon_qrocketlauncher) { weapon_defaultspawnfunc(WEP_ROCKETLAUNCHER.m_id); }

void W_RocketLauncher_Unregister(void)
{SELFPARAM();
	if(self.realowner && self.realowner.lastrocket == self)
	{
		self.realowner.lastrocket = world;
		// self.realowner.rl_release = 1;
	}
}

void W_RocketLauncher_Explode(void)
{SELFPARAM();
	W_RocketLauncher_Unregister();

	if(other.takedamage == DAMAGE_AIM)
		if(IS_PLAYER(other))
			if(DIFF_TEAM(self.realowner, other))
				if(other.deadflag == DEAD_NO)
					if(IsFlying(other))
						Send_Notification(NOTIF_ONE, self.realowner, MSG_ANNCE, ANNCE_ACHIEVEMENT_AIRSHOT);

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	RadiusDamage(
		self,
		self.realowner,
		WEP_CVAR(rocketlauncher, damage),
		WEP_CVAR(rocketlauncher, edgedamage),
		WEP_CVAR(rocketlauncher, radius),
		world,
		world,
		WEP_CVAR(rocketlauncher, force),
		self.projectiledeathtype,
		other
	);

	if(self.realowner.weapon == WEP_ROCKETLAUNCHER.m_id)
	{
		if(self.realowner.WEP_AMMO(ROCKETLAUNCHER) < WEP_CVAR(rocketlauncher, ammo))
		if(!(self.realowner.items & IT_UNLIMITED_WEAPON_AMMO))
		{
			self.realowner.cnt = WEP_ROCKETLAUNCHER.m_id;
			ATTACK_FINISHED(self.realowner) = time;
			self.realowner.switchweapon = w_getbestweapon(self.realowner);
		}
	}
	remove(self);
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

void W_RocketLauncher_Think(void)
{SELFPARAM();
	float velspeed;
	self.nextthink = time;
	if(time > self.cnt)
	{
		other = world;
		self.projectiledeathtype |= HITTYPE_BOUNCE;
		W_RocketLauncher_Explode();
		return;
	}

	// accelerate
	makevectors(self.angles.x * '-1 0 0' + self.angles.y * '0 1 0');
	velspeed = WEP_CVAR(rocketlauncher, speed) * W_WeaponSpeedFactor() - (self.velocity * v_forward);
	if(velspeed > 0)
		self.velocity = self.velocity + v_forward * min(WEP_CVAR(rocketlauncher, speedaccel) * W_WeaponSpeedFactor() * frametime, velspeed);

	if(self.csqcprojectile_clientanimate == 0)
		UpdateCSQCProjectile(self);
}

void W_RocketLauncher_Touch(void)
{SELFPARAM();
	if(WarpZone_Projectile_Touch())
	{
		if(wasfreed(self))
			W_RocketLauncher_Unregister();
		return;
	}
	W_RocketLauncher_Unregister();
	W_RocketLauncher_Explode();
}

void W_RocketLauncher_Damage(entity inflictor, entity attacker, float damage, int deathtype, vector hitloc, vector force)
{SELFPARAM();
	if(self.health <= 0)
		return;

	if(!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt

	self.health = self.health - damage;
	self.angles = vectoangles(self.velocity);

	if(self.health <= 0)
		W_PrepareExplosionByDamage(attacker, W_RocketLauncher_Explode);
}

void W_RocketLauncher_Attack(Weapon thiswep)
{SELFPARAM();
	entity missile;
	entity flash;

	W_DecreaseAmmo(thiswep, self, WEP_CVAR(rocketlauncher, ammo));

	W_SetupShot_ProjectileSize(self, '-3 -3 -3', '3 3 3', false, 5, SND(ROCKETLAUNCHER_FIRE), CH_WEAPON_A, WEP_CVAR(rocketlauncher, damage));
	Send_Effect(EFFECT_ROCKET_MUZZLEFLASH, w_shotorg, w_shotdir * 1000, 1);

	missile = WarpZone_RefSys_SpawnSameRefSys(self);
	missile.owner = missile.realowner = self;
	self.lastrocket = missile;
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

	missile.touch = W_RocketLauncher_Touch;
	missile.think = W_RocketLauncher_Think;
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
	W_AttachToShotorg(self, flash, '5 0 0');

	// common properties
	MUTATOR_CALLHOOK(EditProjectile, self, missile);
}

		#if 0
		METHOD(RocketLauncher, wr_aim, void(entity thiswep))
		{
			// aim and decide to fire if appropriate
			self.BUTTON_ATCK = bot_aim(WEP_CVAR(rocketlauncher, speed), 0, WEP_CVAR(rocketlauncher, lifetime), false);
			if(skill >= 2) // skill 0 and 1 bots won't detonate rockets!
			{
				// decide whether to detonate rockets
				entity missile, targetlist, targ;
				targetlist = findchainfloat(bot_attack, true);
				for(missile = world; (missile = find(missile, classname, "rocket")); ) if(missile.realowner == self)
				{
					targ = targetlist;
					while(targ)
					{
						if(targ != missile.realowner && vlen(targ.origin - missile.origin) < WEP_CVAR(rocketlauncher, radius))
						{
							self.BUTTON_ATCK2 = true;
							break;
						}
						targ = targ.chain;
					}
				}

				if(self.BUTTON_ATCK2) self.BUTTON_ATCK = false;
			}
		}
		#else
		METHOD(RocketLauncher, wr_aim, void(entity thiswep))
		{
			// aim and decide to fire if appropriate
			self.BUTTON_ATCK = bot_aim(WEP_CVAR(rocketlauncher, speed), 0, WEP_CVAR(rocketlauncher, lifetime), false);
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
					if(missile.realowner != self)
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
						if(targ == self)
							selfdamage = selfdamage + d;
						else if(targ.team == self.team && teamplay)
							teamdamage = teamdamage + d;
						else if(bot_shouldattack(targ))
							enemydamage = enemydamage + d;
						targ = targ.chain;
					}
					missile = find(missile, classname, "rocket");
				}
				float desirabledamage;
				desirabledamage = enemydamage;
				if(time > self.invincible_finished && time > self.spawnshieldtime)
					desirabledamage = desirabledamage - selfdamage * autocvar_g_balance_selfdamagepercent;
				if(teamplay && self.team)
					desirabledamage = desirabledamage - teamdamage;

				missile = find(world, classname, "rocket");
				while(missile)
				{
					if(missile.realowner != self)
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
							)self.BUTTON_ATCK2 = true;
							targ = targ.chain;
						}
					}else{
						float distance; distance= bound(300,vlen(self.origin-self.enemy.origin),30000);
						//As the distance gets larger, a correct detonation gets near imposible
						//Bots are assumed to use the rocket spawnfunc_light to see if the rocket gets near a player
						if(v_forward * normalize(missile.origin - self.enemy.origin)< 0.1)
							if(IS_PLAYER(self.enemy))
								if(desirabledamage >= 0.1*coredamage)
									if(random()/distance*300 > frametime*bound(0,(10-skill)*0.2,1))
										self.BUTTON_ATCK2 = true;
					//	dprint(ftos(random()/distance*300),">");dprint(ftos(frametime*bound(0,(10-skill)*0.2,1)),"\n");
					}

					missile = find(missile, classname, "rocket");
				}
				// if we would be doing at X percent of the core damage, detonate it
				// but don't fire a new shot at the same time!
				if(desirabledamage >= 0.75 * coredamage) //this should do group damage in rare fortunate events
					self.BUTTON_ATCK2 = true;
				if((skill > 6.5) && (selfdamage > self.health))
					self.BUTTON_ATCK2 = false;
				//if(self.BUTTON_ATCK2 == true)
				//	dprint(ftos(desirabledamage),"\n");
				if(self.BUTTON_ATCK2 == true) self.BUTTON_ATCK = false;
			}
		}
		#endif
		METHOD(RocketLauncher, wr_think, void(entity thiswep, entity actor, bool fire1, bool fire2))
		{
			if(WEP_CVAR(rocketlauncher, reload_ammo) && actor.clip_load < WEP_CVAR(rocketlauncher, ammo)) { // forced reload
				Weapon w = get_weaponinfo(actor.weapon);
				w.wr_reload(w);
			} else {
				if(fire1)
				{
					if(weapon_prepareattack(thiswep, actor, false, WEP_CVAR(rocketlauncher, refire)))
					{
						W_RocketLauncher_Attack(thiswep);
						weapon_thinkf(actor, WFRAME_FIRE1, WEP_CVAR(rocketlauncher, animtime), w_ready);
					}
				}
			}
		}
		METHOD(RocketLauncher, wr_init, void(entity thiswep))
		{
			ROCKETLAUNCHER_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP);
		}
		METHOD(RocketLauncher, wr_checkammo1, bool(entity thiswep))
		{
			#if 0
			// don't switch while guiding a missile
			if(ATTACK_FINISHED(self) <= time || self.weapon != WEP_ROCKETLAUNCHER.m_id)
			{
				ammo_amount = false;
				if(WEP_CVAR(rocketlauncher, reload_ammo))
				{
					if(self.WEP_AMMO(ROCKETLAUNCHER) < WEP_CVAR(rocketlauncher, ammo) && self.(weapon_load[WEP_ROCKETLAUNCHER.m_id]) < WEP_CVAR(rocketlauncher, ammo))
						ammo_amount = true;
				}
				else if(self.WEP_AMMO(ROCKETLAUNCHER) < WEP_CVAR(rocketlauncher, ammo))
					ammo_amount = true;
				return !ammo_amount;
			}
			#endif
			#if 0
			if(self.rl_release == 0)
			{
				LOG_INFOF("W_RocketLauncher(WR_CHECKAMMO1): %d, %.2f, %d: TRUE\n", self.rl_release, self.WEP_AMMO(ROCKETLAUNCHER), WEP_CVAR(rocketlauncher, ammo));
				return true;
			}
			else
			{
				ammo_amount = self.WEP_AMMO(ROCKETLAUNCHER) >= WEP_CVAR(rocketlauncher, ammo);
				ammo_amount += self.(weapon_load[WEP_ROCKETLAUNCHER.m_id]) >= WEP_CVAR(rocketlauncher, ammo);
				LOG_INFOF("W_RocketLauncher(WR_CHECKAMMO1): %d, %.2f, %d: %s\n", self.rl_release, self.WEP_AMMO(ROCKETLAUNCHER), WEP_CVAR(rocketlauncher, ammo), (ammo_amount ? "TRUE" : "FALSE"));
				return ammo_amount;
			}
			#else
			float ammo_amount = self.WEP_AMMO(ROCKETLAUNCHER) >= WEP_CVAR(rocketlauncher, ammo);
			ammo_amount += self.(weapon_load[WEP_ROCKETLAUNCHER.m_id]) >= WEP_CVAR(rocketlauncher, ammo);
			return ammo_amount;
			#endif
		}
		METHOD(RocketLauncher, wr_checkammo2, bool(entity thiswep))
		{
			return false;
		}
		METHOD(RocketLauncher, wr_config, void(entity thiswep))
		{
			ROCKETLAUNCHER_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS);
		}
		METHOD(RocketLauncher, wr_reload, void(entity thiswep))
		{
			W_Reload(self, WEP_CVAR(rocketlauncher, ammo), SND(RELOAD));
		}
		METHOD(RocketLauncher, wr_suicidemessage, int(entity thiswep))
		{
			return WEAPON_DEVASTATOR_SUICIDE;
		}
		METHOD(RocketLauncher, wr_killmessage, int(entity thiswep))
		{
			if((w_deathtype & HITTYPE_BOUNCE) || (w_deathtype & HITTYPE_SPLASH))
				return WEAPON_DEVASTATOR_MURDER_SPLASH;
			else
				return WEAPON_DEVASTATOR_MURDER_DIRECT;
		}

#endif
#ifdef CSQC

		METHOD(RocketLauncher, wr_impacteffect, void(entity thiswep))
		{
			vector org2;
			org2 = w_org + w_backoff * 12;
			pointparticles(particleeffectnum(EFFECT_ROCKET_EXPLODE), org2, '0 0 0', 1);
			if(!w_issilent)
				sound(self, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTN_NORM);
		}

#endif
#endif
