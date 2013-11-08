#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ SEEKER,
/* function  */ w_seeker,
/* ammotype  */ IT_ROCKETS,
/* impulse   */ 8,
/* flags     */ WEP_FLAG_MUTATORBLOCKED | WEP_FLAG_RELOADABLE | WEP_TYPE_SPLASH,
/* rating    */ BOT_PICKUP_RATING_MID,
/* model     */ "seeker",
/* shortname */ "seeker",
/* fullname  */ _("T.A.G. Seeker")
);
#else
#ifdef SVQC
//.float proxytime; = autoswitch
//.float tl; = wait
.entity tag_target, wps_tag_tracker;
.float tag_time;

// ============================
// Begin: Missile functions, these are general functions to be manipulated by other code
// ============================
void Seeker_Missile_Explode ()
{
	self.event_damage = func_null;
	RadiusDamage (self, self.realowner, autocvar_g_balance_seeker_missile_damage, autocvar_g_balance_seeker_missile_edgedamage, autocvar_g_balance_seeker_missile_radius, world, autocvar_g_balance_seeker_missile_force, self.projectiledeathtype, other);

	remove (self);
}

void Seeker_Missile_Touch()
{
	PROJECTILE_TOUCH;

	Seeker_Missile_Explode();
}

void Seeker_Missile_Think()
{
	entity e;
	vector desireddir, olddir, newdir, eorg;
	float turnrate;
	float dist;
	float spd;

	if (time > self.cnt)
	{
		self.projectiledeathtype |= HITTYPE_SPLASH;
		Seeker_Missile_Explode();
	}

	spd = vlen(self.velocity);
	spd = bound(
		spd - autocvar_g_balance_seeker_missile_decel * frametime,
		autocvar_g_balance_seeker_missile_speed_max,
		spd + autocvar_g_balance_seeker_missile_accel * frametime
	);

	if (self.enemy != world)
		if (self.enemy.takedamage != DAMAGE_AIM || self.enemy.deadflag != DEAD_NO)
			self.enemy = world;

	if (self.enemy != world)
	{
		e               = self.enemy;
		eorg            = 0.5 * (e.absmin + e.absmax);
		turnrate        = autocvar_g_balance_seeker_missile_turnrate; // how fast to turn
		desireddir      = normalize(eorg - self.origin);
		olddir          = normalize(self.velocity); // get my current direction
		dist            = vlen(eorg - self.origin);

		// Do evasive maneuvers for world objects? ( this should be a cpu hog. :P )
		if (autocvar_g_balance_seeker_missile_smart && (dist > autocvar_g_balance_seeker_missile_smart_mindist))
		{
			// Is it a better idea (shorter distance) to trace to the target itself?
			if ( vlen(self.origin + olddir * self.wait) < dist)
				traceline(self.origin, self.origin + olddir * self.wait, FALSE, self);
			else
				traceline(self.origin, eorg, FALSE, self);

			// Setup adaptive tracelength
			self.wait = bound(autocvar_g_balance_seeker_missile_smart_trace_min, vlen(self.origin - trace_endpos), self.wait = autocvar_g_balance_seeker_missile_smart_trace_max);

			// Calc how important it is that we turn and add this to the desierd (enemy) dir.
			desireddir  = normalize(((trace_plane_normal * (1 - trace_fraction)) + (desireddir * trace_fraction)) * 0.5);
		}

		newdir = normalize(olddir + desireddir * turnrate); // take the average of the 2 directions; not the best method but simple & easy
		self.velocity = newdir * spd; // make me fly in the new direction at my flight speed
	}
	else
		dist = 0;

	// Proxy
	if (autocvar_g_balance_seeker_missile_proxy)
	{
		if ( dist <= autocvar_g_balance_seeker_missile_proxy_maxrange)
		{
			if (self.autoswitch == 0)
			{
				self.autoswitch = time + autocvar_g_balance_seeker_missile_proxy_delay;
			}
			else
			{
				if (self.autoswitch <= time)
				{
					Seeker_Missile_Explode();
					self.autoswitch = 0;
				}
			}
		}
		else
		{
			if (self.autoswitch != 0)
				self.autoswitch = 0;
		}
	}
	///////////////

	if (self.enemy.deadflag != DEAD_NO)
	{
		self.enemy = world;
		self.cnt = time + 1 + (random() * 4);
		self.nextthink = self.cnt;
		return;
	}

	//self.angles = vectoangles(self.velocity);			// turn model in the new flight direction
	self.nextthink = time;// + 0.05; // csqc projectiles
	UpdateCSQCProjectile(self);
}



void Seeker_Missile_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;

	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt

	if (self.realowner == attacker)
		self.health = self.health - (damage * 0.25);
	else
		self.health = self.health - damage;

	if (self.health <= 0)
		W_PrepareExplosionByDamage(attacker, Seeker_Missile_Explode);
}

/*
void Seeker_Missile_Animate()
{
	self.frame = self.frame +1;
	self.nextthink = time + 0.05;

	if (self.enemy != world)
		if (self.enemy.takedamage != DAMAGE_AIM || self.enemy.deadflag != DEAD_NO)
			self.enemy = world;

	if(self.frame == 5)
	{
		self.think           = Seeker_Missile_Think;
		self.nextthink       = time;// + cvar("g_balance_seeker_missile_activate_delay"); // cant dealy with csqc projectiles

		if (autocvar_g_balance_seeker_missile_proxy)
			self.movetype    = MOVETYPE_BOUNCEMISSILE;
		else
			self.movetype    = MOVETYPE_FLYMISSILE;
	}

	UpdateCSQCProjectile(self);
}
*/

void Seeker_Fire_Missile(vector f_diff, entity m_target)
{
	entity missile;

	W_DecreaseAmmo(ammo_rockets, autocvar_g_balance_seeker_missile_ammo, autocvar_g_balance_seeker_reload_ammo);

	makevectors(self.v_angle);
	W_SetupShot_ProjectileSize (self, '-2 -2 -2', '2 2 2', FALSE, 2, "weapons/seeker_fire.wav", CH_WEAPON_A, 0, self.weapon);
	w_shotorg += f_diff;
	pointparticles(particleeffectnum("seeker_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	//self.detornator         = FALSE;

	missile                 = spawn();
	missile.owner           = missile.realowner = self;
	missile.classname       = "seeker_missile";
	missile.bot_dodge       = TRUE;
	missile.bot_dodgerating = autocvar_g_balance_seeker_missile_damage;

	missile.think           = Seeker_Missile_Think;
	missile.touch           = Seeker_Missile_Touch;
	missile.event_damage    = Seeker_Missile_Damage;
	missile.nextthink       = time;// + 0.2;// + cvar("g_balance_seeker_missile_activate_delay");
	missile.cnt             = time + autocvar_g_balance_seeker_missile_lifetime;
	missile.enemy           = m_target;
	missile.solid           = SOLID_BBOX;
	missile.scale           = 2;
	missile.takedamage      = DAMAGE_YES;
	missile.health          = autocvar_g_balance_seeker_missile_health;
	missile.damageforcescale = autocvar_g_balance_seeker_missile_damageforcescale;
	missile.damagedbycontents = TRUE;
	//missile.think           = Seeker_Missile_Animate; // csqc projectiles.

	if (missile.enemy != world)
		missile.projectiledeathtype = WEP_SEEKER | HITTYPE_SECONDARY;
	else
		missile.projectiledeathtype = WEP_SEEKER;


	setorigin (missile, w_shotorg);
	setsize (missile, '-4 -4 -4', '4 4 4');
	missile.movetype    = MOVETYPE_FLYMISSILE;
	missile.flags       = FL_PROJECTILE;
	missile.missile_flags = MIF_SPLASH | MIF_GUIDED_TAG;

	W_SETUPPROJECTILEVELOCITY_UP(missile, g_balance_seeker_missile);

	missile.angles = vectoangles (missile.velocity);

	CSQCProjectile(missile, FALSE, PROJECTILE_SEEKER, TRUE);

	other = missile; MUTATOR_CALLHOOK(EditProjectile);
}

// ============================
// Begin: FLAC, close range attack meant for defeating rockets which are coming at you.
// ============================
void Seeker_Flac_Explode ()
{
	self.event_damage = func_null;

	RadiusDamage (self, self.realowner, autocvar_g_balance_seeker_flac_damage, autocvar_g_balance_seeker_flac_edgedamage, autocvar_g_balance_seeker_flac_radius, world, autocvar_g_balance_seeker_flac_force, self.projectiledeathtype, other);

	remove (self);
}

void Seeker_Flac_Touch()
{
	PROJECTILE_TOUCH;

	Seeker_Flac_Explode();
}

void Seeker_Fire_Flac()
{
	entity missile;
	vector f_diff;
	float c;

	W_DecreaseAmmo(ammo_rockets, autocvar_g_balance_seeker_flac_ammo, autocvar_g_balance_seeker_reload_ammo);

	c = mod(self.bulletcounter, 4);
	switch(c)
	{
		case 0:
			f_diff = '-1.25 -3.75 0';
			break;
		case 1:
			f_diff = '+1.25 -3.75 0';
			break;
		case 2:
			f_diff = '-1.25 +3.75 0';
			break;
		case 3:
		default:
			f_diff = '+1.25 +3.75 0';
			break;
	}
	W_SetupShot_ProjectileSize (self, '-2 -2 -2', '2 2 2', FALSE, 2, "weapons/flac_fire.wav", CH_WEAPON_A, autocvar_g_balance_seeker_flac_damage, self.weapon);
	w_shotorg += f_diff;

	pointparticles(particleeffectnum("hagar_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	missile 				= spawn ();
	missile.owner 			= missile.realowner = self;
	missile.classname 		= "missile";
	missile.bot_dodge 		= TRUE;
	missile.bot_dodgerating = autocvar_g_balance_seeker_flac_damage;
	missile.touch 			= Seeker_Flac_Explode;
	missile.use 			= Seeker_Flac_Explode;
	missile.think 			= adaptor_think2use_hittype_splash;
	missile.nextthink 		= time + autocvar_g_balance_seeker_flac_lifetime + autocvar_g_balance_seeker_flac_lifetime_rand;
	missile.solid 			= SOLID_BBOX;
	missile.movetype 		= MOVETYPE_FLY;
	missile.projectiledeathtype = WEP_SEEKER;
	missile.projectiledeathtype = WEP_SEEKER | HITTYPE_SECONDARY;
	missile.flags 				= FL_PROJECTILE;
	missile.missile_flags       = MIF_SPLASH;

	// csqc projectiles
	//missile.angles 				= vectoangles (missile.velocity);
	//missile.scale = 0.4; // BUG: the model is too big

	setorigin (missile, w_shotorg);
	setsize (missile, '-2 -2 -2', '2 2 2');

	W_SETUPPROJECTILEVELOCITY_UP(missile, g_balance_seeker_flac);
	CSQCProjectile(missile, TRUE, PROJECTILE_FLAC, TRUE);

	other = missile; MUTATOR_CALLHOOK(EditProjectile);
}

// ============================
// Begin: Tag and rocket controllers
// ============================
entity Seeker_Tagged_Info(entity isowner, entity istarget)
{
	entity tag;
	for(tag = world; (tag = find(tag, classname, "tag_tracker")); )
		if ((tag.realowner == isowner) && (tag.tag_target == istarget))
			return tag;

	return world;
}

void Seeker_Attack()
{
	entity tracker, closest_target;

	closest_target = world;
	for(tracker = world; (tracker = find(tracker, classname, "tag_tracker")); ) if (tracker.realowner == self)
	{
		if (closest_target)
		{
			if (vlen(self.origin - tracker.tag_target.origin) < vlen(self.origin - closest_target.origin))
				closest_target = tracker.tag_target;
		}
		else
			closest_target = tracker.tag_target;
	}

	traceline(self.origin + self.view_ofs, closest_target.origin, MOVE_NOMONSTERS, self);
	if ((!closest_target) || ((trace_fraction < 1) && (trace_ent != closest_target)))
		closest_target = world;

	Seeker_Fire_Missile('0 0 0', closest_target);
}

void Seeker_Vollycontroller_Think() // TODO: Merge this with Seeker_Attack
{
	float c;
	entity oldself,oldenemy;
	self.cnt = self.cnt - 1;

	if((!(self.realowner.items & IT_UNLIMITED_AMMO) && self.realowner.ammo_rockets < autocvar_g_balance_seeker_missile_ammo) || (self.cnt <= -1) || (self.realowner.deadflag != DEAD_NO) || (self.realowner.switchweapon != WEP_SEEKER))
	{
		remove(self);
		return;
	}

	self.nextthink = time + autocvar_g_balance_seeker_missile_delay * W_WeaponRateFactor();

	oldself = self;
	self = self.realowner;

	oldenemy = self.enemy;
	self.enemy = oldself.enemy;

	c = mod(self.cnt, 4);
	switch(c)
	{
		case 0:
			Seeker_Fire_Missile('-1.25 -3.75 0', self.enemy);
			break;
		case 1:
			Seeker_Fire_Missile('+1.25 -3.75 0', self.enemy);
			break;
		case 2:
			Seeker_Fire_Missile('-1.25 +3.75 0', self.enemy);
			break;
		case 3:
		default:
			Seeker_Fire_Missile('+1.25 +3.75 0', self.enemy);
			break;
	}

	self.enemy = oldenemy;
	self = oldself;
}

void Seeker_Tracker_Think()
{
	// commit suicide if: You die OR target dies OR you switch away from the seeker OR commit suicide if lifetime is up
	if ((self.realowner.deadflag != DEAD_NO) || (self.tag_target.deadflag != DEAD_NO) || (self.realowner.switchweapon != WEP_SEEKER)
	|| (time > self.tag_time + autocvar_g_balance_seeker_tag_tracker_lifetime))
	{
		if (self)
		{
			WaypointSprite_Kill(self.tag_target.wps_tag_tracker);
			remove(self);
		}
		return;
	}

	// Update the think method information
	self.nextthink = time;
}

// ============================
// Begin: Tag projectile
// ============================
void Seeker_Tag_Explode ()
{
	//if(other==self.realowner)
	//    return;
	Damage_DamageInfo(self.origin, 0, 0, 0, self.velocity, WEP_SEEKER | HITTYPE_BOUNCE, other.species, self);

	remove (self);
}

void Seeker_Tag_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;
	self.health = self.health - damage;
	if (self.health <= 0)
		Seeker_Tag_Explode();
}

void Seeker_Tag_Touch()
{
	vector dir;
	vector org2;
	entity e;

	PROJECTILE_TOUCH;

	dir     = normalize (self.realowner.origin - self.origin);
	org2    = findbetterlocation (self.origin, 8);

	te_knightspike(org2);

	self.event_damage = func_null;
	Damage_DamageInfo(self.origin, 0, 0, 0, self.velocity, WEP_SEEKER | HITTYPE_BOUNCE | HITTYPE_SECONDARY, other.species, self);

	if (other.takedamage == DAMAGE_AIM && other.deadflag == DEAD_NO)
	{
		// check to see if this person is already tagged by me
		entity tag = Seeker_Tagged_Info(self.realowner, other);

		if (tag != world)
		{
			if (other.wps_tag_tracker && (autocvar_g_balance_seeker_type == 1)) // don't attach another waypointsprite without killing the old one first
				WaypointSprite_Kill(other.wps_tag_tracker);

			tag.tag_time = time;
		}
		else
		{
			//sprint(self.realowner, strcat("You just tagged ^2", other.netname, "^7 with a tracking device!\n"));
			e             = spawn();
			e.cnt         = autocvar_g_balance_seeker_missile_count;
			e.classname   = "tag_tracker";
			e.owner       = self.owner;
			e.realowner   = self.realowner;

			if	(autocvar_g_balance_seeker_type == 1)
			{
				e.tag_target  = other;
				e.tag_time    = time;
				e.think       = Seeker_Tracker_Think;
			}
			else
			{
				e.enemy     = other;
				e.think     = Seeker_Vollycontroller_Think;
			}

			e.nextthink   = time;
		}

		if	(autocvar_g_balance_seeker_type == 1)
		{
			WaypointSprite_Spawn("tagged-target", autocvar_g_balance_seeker_tag_tracker_lifetime, 0, other, '0 0 64', self.realowner, 0, other, wps_tag_tracker, TRUE, RADARICON_TAGGED, '0.5 1 0');
			WaypointSprite_UpdateRule(other.wps_tag_tracker, 0, SPRITERULE_DEFAULT);
		}
	}

	remove(self);
	return;
}

void Seeker_Fire_Tag()
{
	entity missile;
	W_DecreaseAmmo(ammo_rockets, autocvar_g_balance_seeker_tag_ammo, autocvar_g_balance_seeker_reload_ammo);

	W_SetupShot_ProjectileSize (self, '-2 -2 -2', '2 2 2', FALSE, 2, "weapons/tag_fire.wav", CH_WEAPON_A, autocvar_g_balance_seeker_missile_damage * autocvar_g_balance_seeker_missile_count, self.weapon);

	missile                 = spawn();
	missile.owner           = missile.realowner = self;
	missile.classname       = "seeker_tag";
	missile.bot_dodge       = TRUE;
	missile.bot_dodgerating = 50;
	missile.touch           = Seeker_Tag_Touch;
	missile.think           = SUB_Remove;
	missile.nextthink       = time + autocvar_g_balance_seeker_tag_lifetime;
	missile.movetype        = MOVETYPE_FLY;
	missile.solid           = SOLID_BBOX;

	missile.takedamage       = DAMAGE_YES;
	missile.event_damage     = Seeker_Tag_Damage;
	missile.health           = autocvar_g_balance_seeker_tag_health;
	missile.damageforcescale = autocvar_g_balance_seeker_tag_damageforcescale;

	setorigin (missile, w_shotorg);
	setsize (missile, '-2 -2 -2', '2 2 2');

	missile.flags       = FL_PROJECTILE;
	//missile.missile_flags = MIF_..?;

	missile.movetype    = MOVETYPE_FLY;
	W_SETUPPROJECTILEVELOCITY(missile, g_balance_seeker_tag);
	missile.angles = vectoangles (missile.velocity);

	CSQCProjectile(missile, TRUE, PROJECTILE_TAG, FALSE); // has sound

	other = missile; MUTATOR_CALLHOOK(EditProjectile);
}

// ============================
// Begin: Genereal weapon functions
// ============================
void spawnfunc_weapon_seeker (void)
{
	weapon_defaultspawnfunc(WEP_SEEKER);
}

float w_seeker(float req)
{
	float ammo_amount;

	if (req == WR_AIM)
	{
		if (autocvar_g_balance_seeker_type == 1)
			if (Seeker_Tagged_Info(self, self.enemy) != world)
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_seeker_missile_speed_max, 0, autocvar_g_balance_seeker_missile_lifetime, FALSE);
			else
				self.BUTTON_ATCK2 = bot_aim(autocvar_g_balance_seeker_tag_speed, 0, autocvar_g_balance_seeker_tag_lifetime, FALSE);
		else
			self.BUTTON_ATCK = bot_aim(autocvar_g_balance_seeker_tag_speed, 0, autocvar_g_balance_seeker_tag_lifetime, FALSE);
	}
	else if (req == WR_THINK)
	{
		if(autocvar_g_balance_seeker_reload_ammo && self.clip_load < min(autocvar_g_balance_seeker_missile_ammo, autocvar_g_balance_seeker_tag_ammo)) // forced reload
			weapon_action(self.weapon, WR_RELOAD);

		else if (self.BUTTON_ATCK)
		{
			if (autocvar_g_balance_seeker_type == 1)
			{
				if (weapon_prepareattack(0, autocvar_g_balance_seeker_missile_refire))
				{
					Seeker_Attack();
					weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_seeker_missile_animtime, w_ready);
				}
			}
			else
			{
				if (weapon_prepareattack(0, autocvar_g_balance_seeker_tag_refire))
				{
					Seeker_Fire_Tag();
					weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_seeker_tag_animtime, w_ready);
				}
			}
		}

		else if (self.BUTTON_ATCK2)
		{
			if (autocvar_g_balance_seeker_type == 1)
			{
				if (weapon_prepareattack(0, autocvar_g_balance_seeker_tag_refire))
				{
					Seeker_Fire_Tag();
					weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_seeker_tag_animtime, w_ready);
				}
			}
			else
			{
				if (weapon_prepareattack(0, autocvar_g_balance_seeker_flac_refire))
				{
					Seeker_Fire_Flac();
					weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_seeker_flac_animtime, w_ready);
				}
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_seeker.md3");
		precache_model ("models/weapons/v_seeker.md3");
		precache_model ("models/weapons/h_seeker.iqm");
		precache_sound ("weapons/tag_fire.wav");
		precache_sound ("weapons/flac_fire.wav");
		precache_sound ("weapons/seeker_fire.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_SEEKER);
		self.current_ammo = ammo_rockets;
	}
	else if (req == WR_CHECKAMMO1)
	{
		if (autocvar_g_balance_seeker_type == 1)
		{
			ammo_amount = self.ammo_rockets >= autocvar_g_balance_seeker_missile_ammo;
			ammo_amount += self.(weapon_load[WEP_SEEKER]) >= autocvar_g_balance_seeker_missile_ammo;
		}
		else
		{
			ammo_amount = self.ammo_rockets >= autocvar_g_balance_seeker_tag_ammo;
			ammo_amount += self.(weapon_load[WEP_SEEKER]) >= autocvar_g_balance_seeker_tag_ammo;
		}

		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		if (autocvar_g_balance_seeker_type == 1)
		{
			ammo_amount = self.ammo_rockets >= autocvar_g_balance_seeker_tag_ammo;
			ammo_amount += self.(weapon_load[WEP_SEEKER]) >= autocvar_g_balance_seeker_tag_ammo;
		}
		else
		{
			ammo_amount = self.ammo_rockets >= autocvar_g_balance_seeker_flac_ammo;
			ammo_amount += self.(weapon_load[WEP_SEEKER]) >= autocvar_g_balance_seeker_flac_ammo;
		}

		return ammo_amount;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(min(autocvar_g_balance_seeker_missile_ammo, autocvar_g_balance_seeker_tag_ammo), autocvar_g_balance_seeker_reload_ammo, autocvar_g_balance_seeker_reload_time, "weapons/reload.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
	{
		return WEAPON_SEEKER_SUICIDE;
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
			return WEAPON_SEEKER_MURDER_TAG;
		else
			return WEAPON_SEEKER_MURDER_SPRAY;
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_seeker(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 6;
		if(w_deathtype & HITTYPE_BOUNCE)
		{
			if(w_deathtype & HITTYPE_SECONDARY)
			{
				if(!w_issilent)
					sound(self, CH_SHOTS, "weapons/tag_impact.wav", 1, ATTEN_NORM);
			}
			else
			{
				pointparticles(particleeffectnum("hagar_explode"), org2, '0 0 0', 1);
				if(!w_issilent)
				{
					if (w_random<0.15)
						sound(self, CH_SHOTS, "weapons/tagexp1.wav", 1, ATTEN_NORM);
					else if (w_random<0.7)
						sound(self, CH_SHOTS, "weapons/tagexp2.wav", 1, ATTEN_NORM);
					else
						sound(self, CH_SHOTS, "weapons/tagexp3.wav", 1, ATTEN_NORM);
				}
			}
		}
		else
		{
			pointparticles(particleeffectnum("hagar_explode"), org2, '0 0 0', 1);
			if(!w_issilent)
			{
				if (w_random<0.15)
					sound(self, CH_SHOTS, "weapons/seekerexp1.wav", 1, ATTEN_NORM);
				else if (w_random<0.7)
					sound(self, CH_SHOTS, "weapons/seekerexp2.wav", 1, ATTEN_NORM);
				else
					sound(self, CH_SHOTS, "weapons/seekerexp3.wav", 1, ATTEN_NORM);
			}
		}
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/seekerexp1.wav");
		precache_sound("weapons/seekerexp2.wav");
		precache_sound("weapons/seekerexp3.wav");
		precache_sound("weapons/tagexp1.wav");
		precache_sound("weapons/tagexp2.wav");
		precache_sound("weapons/tagexp3.wav");
		precache_sound("weapons/tag_impact.wav");
	}
	return TRUE;
}
#endif
#endif
