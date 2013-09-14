#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ ROCKET_LAUNCHER,
/* function  */ w_rlauncher,
/* ammotype  */ IT_ROCKETS,
/* impulse   */ 9,
/* flags     */ WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_FLAG_CANCLIMB | WEP_TYPE_SPLASH,
/* rating    */ BOT_PICKUP_RATING_HIGH,
/* model     */ "rl",
/* shortname */ "rocketlauncher",
/* fullname  */ _("Rocket Launcher")
);
#else
#ifdef SVQC
.float rl_release;
.float rl_detonate_later;

void W_Rocket_Unregister()
{
	if(self.realowner && self.realowner.lastrocket == self)
	{
		self.realowner.lastrocket = world;
		// self.realowner.rl_release = 1;
	}
}

void W_Rocket_Explode ()
{
	W_Rocket_Unregister();

	if(other.takedamage == DAMAGE_AIM)
		if(IS_PLAYER(other))
			if(DIFF_TEAM(self.realowner, other))
				if(other.deadflag == DEAD_NO)
					if(IsFlying(other))
						Send_Notification(NOTIF_ONE, self.realowner, MSG_ANNCE, ANNCE_ACHIEVEMENT_AIRSHOT);

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	RadiusDamage (self, self.realowner, autocvar_g_balance_rocketlauncher_damage, autocvar_g_balance_rocketlauncher_edgedamage, autocvar_g_balance_rocketlauncher_radius, world, autocvar_g_balance_rocketlauncher_force, self.projectiledeathtype, other);

	if (self.realowner.weapon == WEP_ROCKET_LAUNCHER)
	{
		if(self.realowner.ammo_rockets < autocvar_g_balance_rocketlauncher_ammo)
		{
			self.realowner.cnt = WEP_ROCKET_LAUNCHER;
			ATTACK_FINISHED(self.realowner) = time;
			self.realowner.switchweapon = w_getbestweapon(self.realowner);
		}
	}
	remove (self);
}

void W_Rocket_DoRemoteExplode ()
{
	W_Rocket_Unregister();

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	RadiusDamage (self, self.realowner, autocvar_g_balance_rocketlauncher_remote_damage, autocvar_g_balance_rocketlauncher_remote_edgedamage, autocvar_g_balance_rocketlauncher_remote_radius, world, autocvar_g_balance_rocketlauncher_remote_force, self.projectiledeathtype | HITTYPE_BOUNCE, world);

	if (self.realowner.weapon == WEP_ROCKET_LAUNCHER)
	{
		if(self.realowner.ammo_rockets < autocvar_g_balance_rocketlauncher_ammo)
		{
			self.realowner.cnt = WEP_ROCKET_LAUNCHER;
			ATTACK_FINISHED(self.realowner) = time;
			self.realowner.switchweapon = w_getbestweapon(self.realowner);
		}
	}
	remove (self);
}

void W_Rocket_RemoteExplode()
{
	if(self.realowner.deadflag == DEAD_NO)
	if(self.realowner.lastrocket)
	{
		if((self.spawnshieldtime >= 0)
			? (time >= self.spawnshieldtime) // timer
			: (vlen(NearestPointOnBox(self.realowner, self.origin) - self.origin) > autocvar_g_balance_rocketlauncher_remote_radius) // safety device
		)
		{
			W_Rocket_DoRemoteExplode();
		}
	}
}

vector rocket_steerto(vector thisdir, vector goaldir, float maxturn_cos)
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

void W_Rocket_Think (void)
{
	vector desireddir, olddir, newdir, desiredorigin, goal;
#if 0
	float cosminang, cosmaxang, cosang;
#endif
	float velspeed, f;
	self.nextthink = time;
	if (time > self.cnt)
	{
		other = world;
		self.projectiledeathtype |= HITTYPE_BOUNCE;
		W_Rocket_Explode ();
		return;
	}

	// accelerate
	makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0');
	velspeed = autocvar_g_balance_rocketlauncher_speed * g_weaponspeedfactor - (self.velocity * v_forward);
	if (velspeed > 0)
		self.velocity = self.velocity + v_forward * min(autocvar_g_balance_rocketlauncher_speedaccel * g_weaponspeedfactor * frametime, velspeed);

	// laser guided, or remote detonation
	if (self.realowner.weapon == WEP_ROCKET_LAUNCHER)
	{
		if(self == self.realowner.lastrocket)
		if not(self.realowner.rl_release)
		if not(self.BUTTON_ATCK2)
		if(autocvar_g_balance_rocketlauncher_guiderate)
		if(time > self.pushltime)
		if(self.realowner.deadflag == DEAD_NO)
		{
			f = autocvar_g_balance_rocketlauncher_guideratedelay;
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
			goal = desiredorigin + ((self.origin - desiredorigin) * desireddir + autocvar_g_balance_rocketlauncher_guidegoal) * desireddir;
			newdir = rocket_steerto(olddir, normalize(goal - self.origin), cos(autocvar_g_balance_rocketlauncher_guiderate * f * frametime * DEG2RAD));

			self.velocity = newdir * velspeed;
			self.angles = vectoangles(self.velocity);

			if(!self.count)
			{
				pointparticles(particleeffectnum("rocket_guide"), self.origin, self.velocity, 1);
				// TODO add a better sound here
				sound (self.realowner, CH_WEAPON_B, "weapons/rocket_mode.wav", VOL_BASE, ATTEN_NORM);
				self.count = 1;
			}
		}

		if(self.rl_detonate_later)
			W_Rocket_RemoteExplode();
	}

	if(self.csqcprojectile_clientanimate == 0)
		UpdateCSQCProjectile(self);
}

void W_Rocket_Touch (void)
{
	if(WarpZone_Projectile_Touch())
	{
		if(wasfreed(self))
			W_Rocket_Unregister();
		return;
	}
	W_Rocket_Unregister();
	W_Rocket_Explode ();
}

void W_Rocket_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;
	
	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt
		
	self.health = self.health - damage;
	self.angles = vectoangles(self.velocity);
	
	if (self.health <= 0)
		W_PrepareExplosionByDamage(attacker, W_Rocket_Explode);
}

void W_Rocket_Attack (float deathtype)
{
	entity missile;
	entity flash;

	W_DecreaseAmmo(ammo_rockets, autocvar_g_balance_rocketlauncher_ammo, autocvar_g_balance_rocketlauncher_reload_ammo);

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 5, "weapons/rocket_fire.wav", CH_WEAPON_A, autocvar_g_balance_rocketlauncher_damage, self.weapon);
	pointparticles(particleeffectnum("rocketlauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	missile = WarpZone_RefSys_SpawnSameRefSys(self);
	missile.owner = missile.realowner = self;
	self.lastrocket = missile;
	if(autocvar_g_balance_rocketlauncher_detonatedelay >= 0)
		missile.spawnshieldtime = time + autocvar_g_balance_rocketlauncher_detonatedelay;
	else
		missile.spawnshieldtime = -1;
	missile.pushltime = time + autocvar_g_balance_rocketlauncher_guidedelay;
	missile.classname = "rocket";
	missile.bot_dodge = TRUE;
	missile.bot_dodgerating = autocvar_g_balance_rocketlauncher_damage * 2; // * 2 because it can be detonated inflight which makes it even more dangerous

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = autocvar_g_balance_rocketlauncher_damageforcescale;
	missile.health = autocvar_g_balance_rocketlauncher_health;
	missile.event_damage = W_Rocket_Damage;
	missile.damagedbycontents = TRUE;

	missile.movetype = MOVETYPE_FLY;
	PROJECTILE_MAKETRIGGER(missile);
	missile.projectiledeathtype = deathtype;
	setsize (missile, '-3 -3 -3', '3 3 3'); // give it some size so it can be shot

	setorigin (missile, w_shotorg - v_forward * 3); // move it back so it hits the wall at the right point
	W_SetupProjectileVelocity(missile, autocvar_g_balance_rocketlauncher_speedstart, 0);
	missile.angles = vectoangles (missile.velocity);

	missile.touch = W_Rocket_Touch;
	missile.think = W_Rocket_Think;
	missile.nextthink = time;
	missile.cnt = time + autocvar_g_balance_rocketlauncher_lifetime;
	missile.flags = FL_PROJECTILE;
	missile.missile_flags = MIF_SPLASH; 

	CSQCProjectile(missile, autocvar_g_balance_rocketlauncher_guiderate == 0 && autocvar_g_balance_rocketlauncher_speedaccel == 0, PROJECTILE_ROCKET, FALSE); // because of fly sound

	// muzzle flash for 1st person view
	flash = spawn ();
	setmodel (flash, "models/flash.md3"); // precision set below
	SUB_SetFade (flash, time, 0.1);
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '5 0 0');

	// common properties
	other = missile; MUTATOR_CALLHOOK(EditProjectile);
}

void spawnfunc_weapon_rocketlauncher (void); // defined in t_items.qc

float w_rlauncher(float req)
{
	entity rock;
	float rockfound;
	float ammo_amount;

	if (req == WR_AIM)
	{
		// aim and decide to fire if appropriate
		self.BUTTON_ATCK = bot_aim(autocvar_g_balance_rocketlauncher_speed, 0, autocvar_g_balance_rocketlauncher_lifetime, FALSE);
		if(skill >= 2) // skill 0 and 1 bots won't detonate rockets!
		{
			// decide whether to detonate rockets
			entity missile, targetlist, targ;
			float edgedamage, coredamage, edgeradius, recipricoledgeradius, d;
			float selfdamage, teamdamage, enemydamage;
			edgedamage = autocvar_g_balance_rocketlauncher_edgedamage;
			coredamage = autocvar_g_balance_rocketlauncher_damage;
			edgeradius = autocvar_g_balance_rocketlauncher_radius;
			recipricoledgeradius = 1 / edgeradius;
			selfdamage = 0;
			teamdamage = 0;
			enemydamage = 0;
			targetlist = findchainfloat(bot_attack, TRUE);
			missile = find(world, classname, "rocket");
			while (missile)
			{
				if (missile.realowner != self)
				{
					missile = find(missile, classname, "rocket");
					continue;
				}
				targ = targetlist;
				while (targ)
				{
					d = vlen(targ.origin + (targ.mins + targ.maxs) * 0.5 - missile.origin);
					d = bound(0, edgedamage + (coredamage - edgedamage) * sqrt(1 - d * recipricoledgeradius), 10000);
					// count potential damage according to type of target
					if (targ == self)
						selfdamage = selfdamage + d;
					else if (targ.team == self.team && teamplay)
						teamdamage = teamdamage + d;
					else if (bot_shouldattack(targ))
						enemydamage = enemydamage + d;
					targ = targ.chain;
				}
				missile = find(missile, classname, "rocket");
			}
			float desirabledamage;
			desirabledamage = enemydamage;
			if (time > self.invincible_finished && time > self.spawnshieldtime)
				desirabledamage = desirabledamage - selfdamage * autocvar_g_balance_selfdamagepercent;
			if (teamplay && self.team)
				desirabledamage = desirabledamage - teamdamage;

			missile = find(world, classname, "rocket");
			while (missile)
			{
				if (missile.realowner != self)
				{
					missile = find(missile, classname, "rocket");
					continue;
				}
				makevectors(missile.v_angle);
				targ = targetlist;
				if (skill > 9) // normal players only do this for the target they are tracking
				{
					targ = targetlist;
					while (targ)
					{
						if (
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
			if (desirabledamage >= 0.75 * coredamage) //this should do group damage in rare fortunate events
				self.BUTTON_ATCK2 = TRUE;
			if ((skill > 6.5) && (selfdamage > self.health))
				self.BUTTON_ATCK2 = FALSE;
			//if(self.BUTTON_ATCK2 == TRUE)
			//	dprint(ftos(desirabledamage),"\n");
			if (self.BUTTON_ATCK2 == TRUE) self.BUTTON_ATCK = FALSE;
		}
	}
	else if (req == WR_THINK)
	{
		if(autocvar_g_balance_rocketlauncher_reload_ammo && self.clip_load < autocvar_g_balance_rocketlauncher_ammo) // forced reload
			weapon_action(self.weapon, WR_RELOAD);
		else
		{
			if (self.BUTTON_ATCK)
			{
				if(self.rl_release || autocvar_g_balance_rocketlauncher_guidestop)
				if(weapon_prepareattack(0, autocvar_g_balance_rocketlauncher_refire))
				{
					W_Rocket_Attack(WEP_ROCKET_LAUNCHER);
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_rocketlauncher_animtime, w_ready);
					self.rl_release = 0;
				}
			}
			else
				self.rl_release = 1;

			if (self.BUTTON_ATCK2)
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
					sound (self, CH_WEAPON_B, "weapons/rocket_det.wav", VOL_BASE, ATTEN_NORM);
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/flash.md3");
		precache_model ("models/weapons/g_rl.md3");
		precache_model ("models/weapons/v_rl.md3");
		precache_model ("models/weapons/h_rl.iqm");
		precache_sound ("weapons/rocket_det.wav");
		precache_sound ("weapons/rocket_fire.wav");
		precache_sound ("weapons/rocket_mode.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_ROCKET_LAUNCHER);
		self.current_ammo = ammo_rockets;
		self.rl_release = 1;
	}
	else if (req == WR_CHECKAMMO1)
	{
		// don't switch while guiding a missile
		if (ATTACK_FINISHED(self) <= time || self.weapon != WEP_ROCKET_LAUNCHER)
		{
			ammo_amount = FALSE;
			if(autocvar_g_balance_rocketlauncher_reload_ammo)
			{
				if(self.ammo_rockets < autocvar_g_balance_rocketlauncher_ammo && self.(weapon_load[WEP_ROCKET_LAUNCHER]) < autocvar_g_balance_rocketlauncher_ammo)
					ammo_amount = TRUE;
			}
			else if(self.ammo_rockets < autocvar_g_balance_rocketlauncher_ammo)
				ammo_amount = TRUE;
			return !ammo_amount;
		}
	}
	else if (req == WR_CHECKAMMO2)
		return FALSE;
	else if (req == WR_RESETPLAYER)
	{
		self.rl_release = 0;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(autocvar_g_balance_rocketlauncher_ammo, autocvar_g_balance_rocketlauncher_reload_ammo, autocvar_g_balance_rocketlauncher_reload_time, "weapons/reload.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
	{
		return WEAPON_ROCKETLAUNCHER_SUICIDE;
	}
	else if (req == WR_KILLMESSAGE)
	{
		if((w_deathtype & HITTYPE_BOUNCE) || (w_deathtype & HITTYPE_SPLASH))
			return WEAPON_ROCKETLAUNCHER_MURDER_SPLASH;
		else
			return WEAPON_ROCKETLAUNCHER_MURDER_DIRECT;
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_rlauncher(float req)
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
