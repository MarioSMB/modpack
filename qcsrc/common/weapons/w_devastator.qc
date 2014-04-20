#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ DEVASTATOR,
/* function  */ W_Devastator,
/* ammotype  */ ammo_rockets,
/* impulse   */ 9,
/* flags     */ WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_FLAG_CANCLIMB | WEP_TYPE_SPLASH,
/* rating    */ BOT_PICKUP_RATING_HIGH,
/* color     */ '1 1 0',
/* modelname */ "rl",
/* simplemdl */ "foobar",
/* crosshair */ "gfx/crosshairrocketlauncher 0.5875",
/* wepimg    */ "weaponrocketlauncher",
/* refname   */ "devastator",
/* wepname   */ _("Devastator")
);

#define DEVASTATOR_SETTINGS(w_cvar,w_prop) DEVASTATOR_SETTINGS_LIST(w_cvar, w_prop, DEVASTATOR, devastator)
#define DEVASTATOR_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, NONE, ammo) \
	w_cvar(id, sn, NONE, animtime) \
	w_cvar(id, sn, NONE, damage) \
	w_cvar(id, sn, NONE, damageforcescale) \
	w_cvar(id, sn, NONE, detonatedelay) \
	w_cvar(id, sn, NONE, edgedamage) \
	w_cvar(id, sn, NONE, force) \
	w_cvar(id, sn, NONE, guidedelay) \
	w_cvar(id, sn, NONE, guidegoal) \
	w_cvar(id, sn, NONE, guiderate) \
	w_cvar(id, sn, NONE, guideratedelay) \
	w_cvar(id, sn, NONE, guidestop) \
	w_cvar(id, sn, NONE, health) \
	w_cvar(id, sn, NONE, lifetime) \
	w_cvar(id, sn, NONE, radius) \
	w_cvar(id, sn, NONE, refire) \
	w_cvar(id, sn, NONE, remote_damage) \
	w_cvar(id, sn, NONE, remote_edgedamage) \
	w_cvar(id, sn, NONE, remote_force) \
	w_cvar(id, sn, NONE, remote_jump_damage) \
	w_cvar(id, sn, NONE, remote_jump_radius) \
	w_cvar(id, sn, NONE, remote_jump_velocity_z_add) \
	w_cvar(id, sn, NONE, remote_jump_velocity_z_max) \
	w_cvar(id, sn, NONE, remote_jump_velocity_z_min) \
	w_cvar(id, sn, NONE, remote_radius) \
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
DEVASTATOR_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
.float rl_release;
.float rl_detonate_later;
#endif
#else
#ifdef SVQC
void spawnfunc_weapon_devastator(void) { weapon_defaultspawnfunc(WEP_DEVASTATOR); }
void spawnfunc_weapon_rocketlauncher(void) { spawnfunc_weapon_devastator(); }

void W_Devastator_Unregister(void)
{
	if(self.realowner && self.realowner.lastrocket == self)
	{
		self.realowner.lastrocket = world;
		// self.realowner.rl_release = 1;
	}
}

void W_Devastator_Explode(void)
{
	W_Devastator_Unregister();

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
		WEP_CVAR(devastator, damage),
		WEP_CVAR(devastator, edgedamage),
		WEP_CVAR(devastator, radius),
		world,
		world,
		WEP_CVAR(devastator, force),
		self.projectiledeathtype,
		other
	);

	if(self.realowner.weapon == WEP_DEVASTATOR)
	{
		if(self.realowner.WEP_AMMO(DEVASTATOR) < WEP_CVAR(devastator, ammo))
		{
			self.realowner.cnt = WEP_DEVASTATOR;
			ATTACK_FINISHED(self.realowner) = time;
			self.realowner.switchweapon = w_getbestweapon(self.realowner);
		}
	}
	remove(self);
}

void W_Devastator_DoRemoteExplode(void)
{
	W_Devastator_Unregister();

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	float handled_as_rocketjump = FALSE;

	entity head = WarpZone_FindRadius(
		self.origin,
		WEP_CVAR(devastator, remote_jump_radius),
		FALSE
	);
	
	while(head)
	{
		if(head.takedamage && (head == self.realowner))
		{
			float distance_to_head = vlen(self.origin - head.WarpZone_findradius_nearest);
			if(distance_to_head <= WEP_CVAR(devastator, remote_jump_radius))
			{
				// we handled this as a rocketjump :)
				handled_as_rocketjump = TRUE;

				// modify velocity 
				head.velocity_x *= 0.9;
				head.velocity_y *= 0.9;
				head.velocity_z = bound(
					WEP_CVAR(devastator, remote_jump_velocity_z_min),
					head.velocity_z + WEP_CVAR(devastator, remote_jump_velocity_z_add),
					WEP_CVAR(devastator, remote_jump_velocity_z_max)
				);

				// now do the damage
				RadiusDamage(
					self,
					head,
					WEP_CVAR(devastator, remote_jump_damage),
					WEP_CVAR(devastator, remote_jump_damage),
					WEP_CVAR(devastator, remote_jump_radius),
					world,
					head,
					0,
					self.projectiledeathtype | HITTYPE_BOUNCE,
					world
				);
				break;
			}
		}
		head = head.chain;
	}

	RadiusDamage(
		self,
		self.realowner,
		WEP_CVAR(devastator, remote_damage),
		WEP_CVAR(devastator, remote_edgedamage),
		WEP_CVAR(devastator, remote_radius),
		(handled_as_rocketjump ? head : world),
		world,
		WEP_CVAR(devastator, remote_force),
		self.projectiledeathtype | HITTYPE_BOUNCE,
		world
	);

	if(self.realowner.weapon == WEP_DEVASTATOR)
	{
		if(self.realowner.WEP_AMMO(DEVASTATOR) < WEP_CVAR(devastator, ammo))
		{
			self.realowner.cnt = WEP_DEVASTATOR;
			ATTACK_FINISHED(self.realowner) = time;
			self.realowner.switchweapon = w_getbestweapon(self.realowner);
		}
	}
	remove(self);
}

void W_Devastator_RemoteExplode(void)
{
	if(self.realowner.deadflag == DEAD_NO)
	if(self.realowner.lastrocket)
	{
		if((self.spawnshieldtime >= 0)
			? (time >= self.spawnshieldtime) // timer
			: (vlen(NearestPointOnBox(self.realowner, self.origin) - self.origin) > WEP_CVAR(devastator, remote_radius)) // safety device
		)
		{
			W_Devastator_DoRemoteExplode();
		}
	}
}

vector W_Devastator_SteerTo(vector thisdir, vector goaldir, float maxturn_cos)
{
	if(thisdir * goaldir > maxturn_cos)
		return goaldir;
	if(thisdir * goaldir < -0.9998) // less than 1 degree and opposite
		return thisdir; // refuse to guide (better than letting a numerical error happen)
	float f, m2;
	vector v;
	// solve:
	//   g = normalize(thisdir + goaldir * X)
	//   thisdir * g = maxturn
	//
	//   gg = thisdir + goaldir * X
	//   (thisdir * gg)^2 = maxturn^2 * (gg * gg)
	//
	//   (1 + (thisdir * goaldir) * X)^2 = maxturn^2 * (1 + X*X + 2 * X * thisdir * goaldir)
	f = thisdir * goaldir;
	//   (1 + f * X)^2 = maxturn^2 * (1 + X*X + 2 * X * f)
	//   0 = (m^2 - f^2) * x^2 + (2 * f * (m^2 - 1)) * x + (m^2 - 1)
	m2 = maxturn_cos * maxturn_cos;
	v = solve_quadratic(m2 - f * f, 2 * f * (m2 - 1), m2 - 1);
	return normalize(thisdir + goaldir * v_y); // the larger solution!
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

void W_Devastator_Think(void)
{
	vector desireddir, olddir, newdir, desiredorigin, goal;
	float velspeed, f;
	self.nextthink = time;
	if(time > self.cnt)
	{
		other = world;
		self.projectiledeathtype |= HITTYPE_BOUNCE;
		W_Devastator_Explode();
		return;
	}

	// accelerate
	makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0');
	velspeed = WEP_CVAR(devastator, speed) * g_weaponspeedfactor - (self.velocity * v_forward);
	if(velspeed > 0)
		self.velocity = self.velocity + v_forward * min(WEP_CVAR(devastator, speedaccel) * g_weaponspeedfactor * frametime, velspeed);

	// laser guided, or remote detonation
	if(self.realowner.weapon == WEP_DEVASTATOR)
	{
		if(self == self.realowner.lastrocket)
		if(!self.realowner.rl_release)
		if(!self.BUTTON_ATCK2)
		if(WEP_CVAR(devastator, guiderate))
		if(time > self.pushltime)
		if(self.realowner.deadflag == DEAD_NO)
		{
			f = WEP_CVAR(devastator, guideratedelay);
			if(f)
				f = bound(0, (time - self.pushltime) / f, 1);
			else
				f = 1;

			velspeed = vlen(self.velocity);

			makevectors(self.realowner.v_angle);
			desireddir = WarpZone_RefSys_TransformVelocity(self.realowner, self, v_forward);
			desiredorigin = WarpZone_RefSys_TransformOrigin(self.realowner, self, self.realowner.origin + self.realowner.view_ofs);
			olddir = normalize(self.velocity);

			// now it gets tricky... we want to move like some curve to approximate the target direction
			// but we are limiting the rate at which we can turn!
			goal = desiredorigin + ((self.origin - desiredorigin) * desireddir + WEP_CVAR(devastator, guidegoal)) * desireddir;
			newdir = W_Devastator_SteerTo(olddir, normalize(goal - self.origin), cos(WEP_CVAR(devastator, guiderate) * f * frametime * DEG2RAD));

			self.velocity = newdir * velspeed;
			self.angles = vectoangles(self.velocity);

			if(!self.count)
			{
				pointparticles(particleeffectnum("rocket_guide"), self.origin, self.velocity, 1);
				// TODO add a better sound here
				sound(self.realowner, CH_WEAPON_B, "weapons/rocket_mode.wav", VOL_BASE, ATTN_NORM);
				self.count = 1;
			}
		}

		if(self.rl_detonate_later)
			W_Devastator_RemoteExplode();
	}

	if(self.csqcprojectile_clientanimate == 0)
		UpdateCSQCProjectile(self);
}

void W_Devastator_Touch(void)
{
	if(WarpZone_Projectile_Touch())
	{
		if(wasfreed(self))
			W_Devastator_Unregister();
		return;
	}
	W_Devastator_Unregister();
	W_Devastator_Explode();
}

void W_Devastator_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(self.health <= 0)
		return;
	
	if(!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt
		
	self.health = self.health - damage;
	self.angles = vectoangles(self.velocity);
	
	if(self.health <= 0)
		W_PrepareExplosionByDamage(attacker, W_Devastator_Explode);
}

void W_Devastator_Attack(void)
{
	entity missile;
	entity flash;

	W_DecreaseAmmo(WEP_CVAR(devastator, ammo));

	W_SetupShot_ProjectileSize(self, '-3 -3 -3', '3 3 3', FALSE, 5, "weapons/rocket_fire.wav", CH_WEAPON_A, WEP_CVAR(devastator, damage));
	pointparticles(particleeffectnum("rocketlauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	missile = WarpZone_RefSys_SpawnSameRefSys(self);
	missile.owner = missile.realowner = self;
	self.lastrocket = missile;
	if(WEP_CVAR(devastator, detonatedelay) >= 0)
		missile.spawnshieldtime = time + WEP_CVAR(devastator, detonatedelay);
	else
		missile.spawnshieldtime = -1;
	missile.pushltime = time + WEP_CVAR(devastator, guidedelay);
	missile.classname = "rocket";
	missile.bot_dodge = TRUE;
	missile.bot_dodgerating = WEP_CVAR(devastator, damage) * 2; // * 2 because it can be detonated inflight which makes it even more dangerous

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = WEP_CVAR(devastator, damageforcescale);
	missile.health = WEP_CVAR(devastator, health);
	missile.event_damage = W_Devastator_Damage;
	missile.damagedbycontents = TRUE;

	missile.movetype = MOVETYPE_FLY;
	PROJECTILE_MAKETRIGGER(missile);
	missile.projectiledeathtype = WEP_DEVASTATOR;
	setsize(missile, '-3 -3 -3', '3 3 3'); // give it some size so it can be shot

	setorigin(missile, w_shotorg - v_forward * 3); // move it back so it hits the wall at the right point
	W_SetupProjVelocity_Basic(missile, WEP_CVAR(devastator, speedstart), 0);
	missile.angles = vectoangles(missile.velocity);

	missile.touch = W_Devastator_Touch;
	missile.think = W_Devastator_Think;
	missile.nextthink = time;
	missile.cnt = time + WEP_CVAR(devastator, lifetime);
	missile.flags = FL_PROJECTILE;
	missile.missile_flags = MIF_SPLASH; 

	CSQCProjectile(missile, WEP_CVAR(devastator, guiderate) == 0 && WEP_CVAR(devastator, speedaccel) == 0, PROJECTILE_ROCKET, FALSE); // because of fly sound

	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/flash.md3"); // precision set below
	SUB_SetFade(flash, time, 0.1);
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '5 0 0');

	// common properties
	other = missile; MUTATOR_CALLHOOK(EditProjectile);
}

float W_Devastator(float req)
{
	entity rock;
	float rockfound;
	float ammo_amount;
	switch(req)
	{
		#if 0
		case WR_AIM:
		{
			// aim and decide to fire if appropriate
			self.BUTTON_ATCK = bot_aim(WEP_CVAR(devastator, speed), 0, WEP_CVAR(devastator, lifetime), FALSE);
			if(skill >= 2) // skill 0 and 1 bots won't detonate rockets!
			{
				// decide whether to detonate rockets
				entity missile, targetlist, targ;
				targetlist = findchainfloat(bot_attack, TRUE);
				for(missile = world; (missile = find(missile, classname, "rocket")); ) if(missile.realowner == self)
				{
					targ = targetlist;
					while(targ)
					{
						if(targ != missile.realowner && vlen(targ.origin - missile.origin) < WEP_CVAR(devastator, radius))
						{
							self.BUTTON_ATCK2 = TRUE;
							break;
						}
						targ = targ.chain;
					}
				}
				
				if(self.BUTTON_ATCK2) self.BUTTON_ATCK = FALSE;
			}
			
			return TRUE;
		}
		#else
		case WR_AIM:
		{
			// aim and decide to fire if appropriate
			self.BUTTON_ATCK = bot_aim(WEP_CVAR(devastator, speed), 0, WEP_CVAR(devastator, lifetime), FALSE);
			if(skill >= 2) // skill 0 and 1 bots won't detonate rockets!
			{
				// decide whether to detonate rockets
				entity missile, targetlist, targ;
				float edgedamage, coredamage, edgeradius, recipricoledgeradius, d;
				float selfdamage, teamdamage, enemydamage;
				edgedamage = WEP_CVAR(devastator, edgedamage);
				coredamage = WEP_CVAR(devastator, damage);
				edgeradius = WEP_CVAR(devastator, radius);
				recipricoledgeradius = 1 / edgeradius;
				selfdamage = 0;
				teamdamage = 0;
				enemydamage = 0;
				targetlist = findchainfloat(bot_attack, TRUE);
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
							)self.BUTTON_ATCK2 = TRUE;
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
										self.BUTTON_ATCK2 = TRUE;
					//	dprint(ftos(random()/distance*300),">");dprint(ftos(frametime*bound(0,(10-skill)*0.2,1)),"\n");
					}

					missile = find(missile, classname, "rocket");
				}
				// if we would be doing at X percent of the core damage, detonate it
				// but don't fire a new shot at the same time!
				if(desirabledamage >= 0.75 * coredamage) //this should do group damage in rare fortunate events
					self.BUTTON_ATCK2 = TRUE;
				if((skill > 6.5) && (selfdamage > self.health))
					self.BUTTON_ATCK2 = FALSE;
				//if(self.BUTTON_ATCK2 == TRUE)
				//	dprint(ftos(desirabledamage),"\n");
				if(self.BUTTON_ATCK2 == TRUE) self.BUTTON_ATCK = FALSE;
			}
			
			return TRUE;
		}
		#endif
		case WR_THINK:
		{
			if(WEP_CVAR(devastator, reload_ammo) && self.clip_load < WEP_CVAR(devastator, ammo)) // forced reload
				WEP_ACTION(self.weapon, WR_RELOAD);
			else
			{
				if(self.BUTTON_ATCK)
				{
					if(self.rl_release || WEP_CVAR(devastator, guidestop))
					if(weapon_prepareattack(0, WEP_CVAR(devastator, refire)))
					{
						W_Devastator_Attack();
						weapon_thinkf(WFRAME_FIRE1, WEP_CVAR(devastator, animtime), w_ready);
						self.rl_release = 0;
					}
				}
				else
					self.rl_release = 1;

				if(self.BUTTON_ATCK2)
				{
					rockfound = 0;
					for(rock = world; (rock = find(rock, classname, "rocket")); ) if(rock.realowner == self)
					{
						if(!rock.rl_detonate_later)
						{
							rock.rl_detonate_later = TRUE;
							rockfound = 1;
						}
					}
					if(rockfound)
						sound(self, CH_WEAPON_B, "weapons/rocket_det.wav", VOL_BASE, ATTN_NORM);
				}
			}
			
			return TRUE;
		}
		case WR_INIT:
		{
			if(autocvar_sv_precacheweapons)
			{
				precache_model("models/flash.md3");
				precache_model("models/weapons/g_rl.md3");
				precache_model("models/weapons/v_rl.md3");
				precache_model("models/weapons/h_rl.iqm");
				precache_sound("weapons/rocket_det.wav");
				precache_sound("weapons/rocket_fire.wav");
				precache_sound("weapons/rocket_mode.wav");
			}
			DEVASTATOR_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP)
			return TRUE;
		}
		case WR_SETUP:
		{
			self.rl_release = 1;
			return TRUE;
		}
		case WR_CHECKAMMO1:
		{
			#if 0
			// don't switch while guiding a missile
			if(ATTACK_FINISHED(self) <= time || self.weapon != WEP_DEVASTATOR)
			{
				ammo_amount = FALSE;
				if(WEP_CVAR(devastator, reload_ammo))
				{
					if(self.WEP_AMMO(DEVASTATOR) < WEP_CVAR(devastator, ammo) && self.(weapon_load[WEP_DEVASTATOR]) < WEP_CVAR(devastator, ammo))
						ammo_amount = TRUE;
				}
				else if(self.WEP_AMMO(DEVASTATOR) < WEP_CVAR(devastator, ammo))
					ammo_amount = TRUE;
				return !ammo_amount;
			}
			#endif
			#if 0
			if(self.rl_release == 0)
			{
				printf("W_Devastator(WR_CHECKAMMO1): %d, %.2f, %d: TRUE\n", self.rl_release, self.WEP_AMMO(DEVASTATOR), WEP_CVAR(devastator, ammo));
				return TRUE;
			}
			else
			{
				ammo_amount = self.WEP_AMMO(DEVASTATOR) >= WEP_CVAR(devastator, ammo);
				ammo_amount += self.(weapon_load[WEP_DEVASTATOR]) >= WEP_CVAR(devastator, ammo);
				printf("W_Devastator(WR_CHECKAMMO1): %d, %.2f, %d: %s\n", self.rl_release, self.WEP_AMMO(DEVASTATOR), WEP_CVAR(devastator, ammo), (ammo_amount ? "TRUE" : "FALSE"));
				return ammo_amount;
			}
			#else
			ammo_amount = self.WEP_AMMO(DEVASTATOR) >= WEP_CVAR(devastator, ammo);
			ammo_amount += self.(weapon_load[WEP_DEVASTATOR]) >= WEP_CVAR(devastator, ammo);
			return ammo_amount;
			#endif
		}
		case WR_CHECKAMMO2:
		{
			return FALSE;
		}
		case WR_CONFIG:
		{
			DEVASTATOR_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS)
			return TRUE;
		}
		case WR_RESETPLAYER:
		{
			self.rl_release = 0;
			return TRUE;
		}
		case WR_RELOAD:
		{
			W_Reload(WEP_CVAR(devastator, ammo), "weapons/reload.wav");
			return TRUE;
		}
		case WR_SUICIDEMESSAGE:
		{
			return WEAPON_DEVASTATOR_SUICIDE;
		}
		case WR_KILLMESSAGE:
		{
			if((w_deathtype & HITTYPE_BOUNCE) || (w_deathtype & HITTYPE_SPLASH))
				return WEAPON_DEVASTATOR_MURDER_SPLASH;
			else
				return WEAPON_DEVASTATOR_MURDER_DIRECT;
		}
	}
	return FALSE;
}
#endif
#ifdef CSQC
float W_Devastator(float req)
{
	switch(req)
	{
		case WR_IMPACTEFFECT:
		{
			vector org2;
			org2 = w_org + w_backoff * 12;
			pointparticles(particleeffectnum("rocket_explode"), org2, '0 0 0', 1);
			if(!w_issilent)
				sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
				
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
