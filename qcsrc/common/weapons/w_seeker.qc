#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ SEEKER,
/* function  */ W_Seeker,
/* ammotype  */ ammo_rockets,
/* impulse   */ 8,
/* flags     */ WEP_FLAG_MUTATORBLOCKED | WEP_FLAG_RELOADABLE | WEP_TYPE_SPLASH,
/* rating    */ BOT_PICKUP_RATING_MID,
/* color     */ '0.5 1 0',
/* modelname */ "seeker",
/* simplemdl */ "foobar",
/* crosshair */ "gfx/crosshairseeker 0.8",
/* wepimg    */ "weaponseeker",
/* refname   */ "seeker",
/* wepname   */ _("T.A.G. Seeker")
);

#define SEEKER_SETTINGS(w_cvar,w_prop) SEEKER_SETTINGS_LIST(w_cvar, w_prop, SEEKER, seeker)
#define SEEKER_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, NONE, type) \
	w_cvar(id, sn, NONE, flac_ammo) \
	w_cvar(id, sn, NONE, flac_animtime) \
	w_cvar(id, sn, NONE, flac_damage) \
	w_cvar(id, sn, NONE, flac_edgedamage) \
	w_cvar(id, sn, NONE, flac_force) \
	w_cvar(id, sn, NONE, flac_lifetime) \
	w_cvar(id, sn, NONE, flac_lifetime_rand) \
	w_cvar(id, sn, NONE, flac_radius) \
	w_cvar(id, sn, NONE, flac_refire) \
	w_cvar(id, sn, NONE, flac_speed) \
	w_cvar(id, sn, NONE, flac_speed_up) \
	w_cvar(id, sn, NONE, flac_speed_z) \
	w_cvar(id, sn, NONE, flac_spread) \
	w_cvar(id, sn, NONE, missile_accel) \
	w_cvar(id, sn, NONE, missile_ammo) \
	w_cvar(id, sn, NONE, missile_animtime) \
	w_cvar(id, sn, NONE, missile_count) \
	w_cvar(id, sn, NONE, missile_damage) \
	w_cvar(id, sn, NONE, missile_damageforcescale) \
	w_cvar(id, sn, NONE, missile_decel) \
	w_cvar(id, sn, NONE, missile_delay) \
	w_cvar(id, sn, NONE, missile_edgedamage) \
	w_cvar(id, sn, NONE, missile_force) \
	w_cvar(id, sn, NONE, missile_health) \
	w_cvar(id, sn, NONE, missile_lifetime) \
	w_cvar(id, sn, NONE, missile_proxy) \
	w_cvar(id, sn, NONE, missile_proxy_delay) \
	w_cvar(id, sn, NONE, missile_proxy_maxrange) \
	w_cvar(id, sn, NONE, missile_radius) \
	w_cvar(id, sn, NONE, missile_refire) \
	w_cvar(id, sn, NONE, missile_smart) \
	w_cvar(id, sn, NONE, missile_smart_mindist) \
	w_cvar(id, sn, NONE, missile_smart_trace_max) \
	w_cvar(id, sn, NONE, missile_smart_trace_min) \
	w_cvar(id, sn, NONE, missile_speed) \
	w_cvar(id, sn, NONE, missile_speed_max) \
	w_cvar(id, sn, NONE, missile_speed_up) \
	w_cvar(id, sn, NONE, missile_speed_z) \
	w_cvar(id, sn, NONE, missile_spread) \
	w_cvar(id, sn, NONE, missile_turnrate) \
	w_cvar(id, sn, NONE, tag_ammo) \
	w_cvar(id, sn, NONE, tag_animtime) \
	w_cvar(id, sn, NONE, tag_damageforcescale) \
	w_cvar(id, sn, NONE, tag_health) \
	w_cvar(id, sn, NONE, tag_lifetime) \
	w_cvar(id, sn, NONE, tag_refire) \
	w_cvar(id, sn, NONE, tag_speed) \
	w_cvar(id, sn, NONE, tag_spread) \
	w_cvar(id, sn, NONE, tag_tracker_lifetime) \
	w_prop(id, sn, float,  reloading_ammo, reload_ammo) \
	w_prop(id, sn, float,  reloading_time, reload_time) \
	w_prop(id, sn, float,  switchdelay_raise, switchdelay_raise) \
	w_prop(id, sn, float,  switchdelay_drop, switchdelay_drop) \
	w_prop(id, sn, string, weaponreplace, weaponreplace) \
	w_prop(id, sn, float,  weaponstart, weaponstart) \
	w_prop(id, sn, float,  weaponstartoverride, weaponstartoverride) \
	w_prop(id, sn, float,  weaponthrowable, weaponthrowable)

#ifdef SVQC
SEEKER_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
.entity tag_target, wps_tag_tracker;
.float tag_time;
#endif
#else
#ifdef SVQC
void spawnfunc_weapon_seeker(void) { weapon_defaultspawnfunc(WEP_SEEKER); }

// ============================
// Begin: Missile functions, these are general functions to be manipulated by other code
// ============================
void W_Seeker_Missile_Explode(void)
{
	self.event_damage = func_null;
	RadiusDamage(self, self.realowner, WEP_CVAR(seeker, missile_damage), WEP_CVAR(seeker, missile_edgedamage), WEP_CVAR(seeker, missile_radius), world, world, WEP_CVAR(seeker, missile_force), self.projectiledeathtype, other);

	remove(self);
}

void W_Seeker_Missile_Touch(void)
{
	PROJECTILE_TOUCH;

	W_Seeker_Missile_Explode();
}

void W_Seeker_Missile_Think(void)
{
	entity e;
	vector desireddir, olddir, newdir, eorg;
	float turnrate;
	float dist;
	float spd;

	if(time > self.cnt)
	{
		self.projectiledeathtype |= HITTYPE_SPLASH;
		W_Seeker_Missile_Explode();
	}

	spd = vlen(self.velocity);
	spd = bound(
		spd - WEP_CVAR(seeker, missile_decel) * frametime,
		WEP_CVAR(seeker, missile_speed_max),
		spd + WEP_CVAR(seeker, missile_accel) * frametime
	);

	if(self.enemy != world)
		if(self.enemy.takedamage != DAMAGE_AIM || self.enemy.deadflag != DEAD_NO)
			self.enemy = world;

	if(self.enemy != world)
	{
		e               = self.enemy;
		eorg            = 0.5 * (e.absmin + e.absmax);
		turnrate        = WEP_CVAR(seeker, missile_turnrate); // how fast to turn
		desireddir      = normalize(eorg - self.origin);
		olddir          = normalize(self.velocity); // get my current direction
		dist            = vlen(eorg - self.origin);

		// Do evasive maneuvers for world objects? ( this should be a cpu hog. :P )
		if(WEP_CVAR(seeker, missile_smart) && (dist > WEP_CVAR(seeker, missile_smart_mindist)))
		{
			// Is it a better idea (shorter distance) to trace to the target itself?
			if( vlen(self.origin + olddir * self.wait) < dist)
				traceline(self.origin, self.origin + olddir * self.wait, FALSE, self);
			else
				traceline(self.origin, eorg, FALSE, self);

			// Setup adaptive tracelength
			self.wait = bound(WEP_CVAR(seeker, missile_smart_trace_min), vlen(self.origin - trace_endpos), self.wait = WEP_CVAR(seeker, missile_smart_trace_max));

			// Calc how important it is that we turn and add this to the desierd (enemy) dir.
			desireddir  = normalize(((trace_plane_normal * (1 - trace_fraction)) + (desireddir * trace_fraction)) * 0.5);
		}

		newdir = normalize(olddir + desireddir * turnrate); // take the average of the 2 directions; not the best method but simple & easy
		self.velocity = newdir * spd; // make me fly in the new direction at my flight speed
	}
	else
		dist = 0;

	// Proxy
	if(WEP_CVAR(seeker, missile_proxy))
	{
		if(dist <= WEP_CVAR(seeker, missile_proxy_maxrange))
		{
			if(self.autoswitch == 0)
			{
				self.autoswitch = time + WEP_CVAR(seeker, missile_proxy_delay);
			}
			else
			{
				if(self.autoswitch <= time)
				{
					W_Seeker_Missile_Explode();
					self.autoswitch = 0;
				}
			}
		}
		else
		{
			if(self.autoswitch != 0)
				self.autoswitch = 0;
		}
	}
	///////////////

	if(self.enemy.deadflag != DEAD_NO)
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



void W_Seeker_Missile_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(self.health <= 0)
		return;

	if(!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt

	if(self.realowner == attacker)
		self.health = self.health - (damage * 0.25);
	else
		self.health = self.health - damage;

	if(self.health <= 0)
		W_PrepareExplosionByDamage(attacker, W_Seeker_Missile_Explode);
}

/*
void W_Seeker_Missile_Animate(void)
{
	self.frame = self.frame +1;
	self.nextthink = time + 0.05;

	if(self.enemy != world)
		if(self.enemy.takedamage != DAMAGE_AIM || self.enemy.deadflag != DEAD_NO)
			self.enemy = world;

	if(self.frame == 5)
	{
		self.think           = W_Seeker_Missile_Think;
		self.nextthink       = time;// + cvar("g_balance_seeker_missile_activate_delay"); // cant dealy with csqc projectiles

		if(autocvar_g_balance_seeker_missile_proxy)
			self.movetype    = MOVETYPE_BOUNCEMISSILE;
		else
			self.movetype    = MOVETYPE_FLYMISSILE;
	}

	UpdateCSQCProjectile(self);
}
*/

void W_Seeker_Fire_Missile(vector f_diff, entity m_target)
{
	entity missile;

	W_DecreaseAmmo(WEP_CVAR(seeker, missile_ammo));

	makevectors(self.v_angle);
	W_SetupShot_ProjectileSize(self, '-2 -2 -2', '2 2 2', FALSE, 2, "weapons/seeker_fire.wav", CH_WEAPON_A, 0);
	w_shotorg += f_diff;
	pointparticles(particleeffectnum("seeker_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	//self.detornator         = FALSE;

	missile                 = spawn();
	missile.owner           = missile.realowner = self;
	missile.classname       = "seeker_missile";
	missile.bot_dodge       = TRUE;
	missile.bot_dodgerating = WEP_CVAR(seeker, missile_damage);

	missile.think           = W_Seeker_Missile_Think;
	missile.touch           = W_Seeker_Missile_Touch;
	missile.event_damage    = W_Seeker_Missile_Damage;
	missile.nextthink       = time;// + 0.2;// + cvar("g_balance_seeker_missile_activate_delay");
	missile.cnt             = time + WEP_CVAR(seeker, missile_lifetime);
	missile.enemy           = m_target;
	missile.solid           = SOLID_BBOX;
	missile.scale           = 2;
	missile.takedamage      = DAMAGE_YES;
	missile.health          = WEP_CVAR(seeker, missile_health);
	missile.damageforcescale = WEP_CVAR(seeker, missile_damageforcescale);
	missile.damagedbycontents = TRUE;
	//missile.think           = W_Seeker_Missile_Animate; // csqc projectiles.

	if(missile.enemy != world)
		missile.projectiledeathtype = WEP_SEEKER | HITTYPE_SECONDARY;
	else
		missile.projectiledeathtype = WEP_SEEKER;


	setorigin(missile, w_shotorg);
	setsize(missile, '-4 -4 -4', '4 4 4');
	missile.movetype    = MOVETYPE_FLYMISSILE;
	missile.flags       = FL_PROJECTILE;
	missile.missile_flags = MIF_SPLASH | MIF_GUIDED_TAG;

	W_SetupProjVelocity_UP_PRE(missile, seeker, missile_);

	missile.angles = vectoangles(missile.velocity);

	CSQCProjectile(missile, FALSE, PROJECTILE_SEEKER, TRUE);

	other = missile; MUTATOR_CALLHOOK(EditProjectile);
}

// ============================
// Begin: FLAC, close range attack meant for defeating rockets which are coming at you.
// ============================
void W_Seeker_Flac_Explode(void)
{
	self.event_damage = func_null;

	RadiusDamage(self, self.realowner, WEP_CVAR(seeker, flac_damage), WEP_CVAR(seeker, flac_edgedamage), WEP_CVAR(seeker, flac_radius), world, world, WEP_CVAR(seeker, flac_force), self.projectiledeathtype, other);

	remove(self);
}

void W_Seeker_Flac_Touch(void)
{
	PROJECTILE_TOUCH;

	W_Seeker_Flac_Explode();
}

void W_Seeker_Fire_Flac(void)
{
	entity missile;
	vector f_diff;
	float c;

	W_DecreaseAmmo(WEP_CVAR(seeker, flac_ammo));

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
	W_SetupShot_ProjectileSize(self, '-2 -2 -2', '2 2 2', FALSE, 2, "weapons/flac_fire.wav", CH_WEAPON_A, WEP_CVAR(seeker, flac_damage));
	w_shotorg += f_diff;

	pointparticles(particleeffectnum("hagar_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	missile 				= spawn();
	missile.owner 			= missile.realowner = self;
	missile.classname 		= "missile";
	missile.bot_dodge 		= TRUE;
	missile.bot_dodgerating = WEP_CVAR(seeker, flac_damage);
	missile.touch 			= W_Seeker_Flac_Explode;
	missile.use 			= W_Seeker_Flac_Explode;
	missile.think 			= adaptor_think2use_hittype_splash;
	missile.nextthink 		= time + WEP_CVAR(seeker, flac_lifetime) + WEP_CVAR(seeker, flac_lifetime_rand);
	missile.solid 			= SOLID_BBOX;
	missile.movetype 		= MOVETYPE_FLY;
	missile.projectiledeathtype = WEP_SEEKER;
	missile.projectiledeathtype = WEP_SEEKER | HITTYPE_SECONDARY;
	missile.flags 				= FL_PROJECTILE;
	missile.missile_flags       = MIF_SPLASH;

	// csqc projectiles
	//missile.angles 				= vectoangles(missile.velocity);
	//missile.scale = 0.4; // BUG: the model is too big

	setorigin(missile, w_shotorg);
	setsize(missile, '-2 -2 -2', '2 2 2');

	W_SetupProjVelocity_UP_PRE(missile, seeker, flac_);
	CSQCProjectile(missile, TRUE, PROJECTILE_FLAC, TRUE);

	other = missile; MUTATOR_CALLHOOK(EditProjectile);
}

// ============================
// Begin: Tag and rocket controllers
// ============================
entity W_Seeker_Tagged_Info(entity isowner, entity istarget)
{
	entity tag;
	for(tag = world; (tag = find(tag, classname, "tag_tracker")); )
		if((tag.realowner == isowner) && (tag.tag_target == istarget))
			return tag;

	return world;
}

void W_Seeker_Attack(void)
{
	entity tracker, closest_target;

	closest_target = world;
	for(tracker = world; (tracker = find(tracker, classname, "tag_tracker")); ) if (tracker.realowner == self)
	{
		if(closest_target)
		{
			if(vlen(self.origin - tracker.tag_target.origin) < vlen(self.origin - closest_target.origin))
				closest_target = tracker.tag_target;
		}
		else
			closest_target = tracker.tag_target;
	}

	traceline(self.origin + self.view_ofs, closest_target.origin, MOVE_NOMONSTERS, self);
	if((!closest_target) || ((trace_fraction < 1) && (trace_ent != closest_target)))
		closest_target = world;

	W_Seeker_Fire_Missile('0 0 0', closest_target);
}

void W_Seeker_Vollycontroller_Think(void) // TODO: Merge this with W_Seeker_Attack
{
	float c;
	entity oldself,oldenemy;
	self.cnt = self.cnt - 1;

	if((!(self.realowner.items & IT_UNLIMITED_AMMO) && self.realowner.WEP_AMMO(SEEKER) < WEP_CVAR(seeker, missile_ammo)) || (self.cnt <= -1) || (self.realowner.deadflag != DEAD_NO) || (self.realowner.switchweapon != WEP_SEEKER))
	{
		remove(self);
		return;
	}

	self.nextthink = time + WEP_CVAR(seeker, missile_delay) * W_WeaponRateFactor();

	oldself = self;
	self = self.realowner;

	oldenemy = self.enemy;
	self.enemy = oldself.enemy;

	c = mod(self.cnt, 4);
	switch(c)
	{
		case 0:
			W_Seeker_Fire_Missile('-1.25 -3.75 0', self.enemy);
			break;
		case 1:
			W_Seeker_Fire_Missile('+1.25 -3.75 0', self.enemy);
			break;
		case 2:
			W_Seeker_Fire_Missile('-1.25 +3.75 0', self.enemy);
			break;
		case 3:
		default:
			W_Seeker_Fire_Missile('+1.25 +3.75 0', self.enemy);
			break;
	}

	self.enemy = oldenemy;
	self = oldself;
}

void W_Seeker_Tracker_Think(void)
{
	// commit suicide if: You die OR target dies OR you switch away from the seeker OR commit suicide if lifetime is up
	if((self.realowner.deadflag != DEAD_NO) || (self.tag_target.deadflag != DEAD_NO) || (self.realowner.switchweapon != WEP_SEEKER)
	|| (time > self.tag_time + WEP_CVAR(seeker, tag_tracker_lifetime)))
	{
		if(self)
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
void W_Seeker_Tag_Explode(void)
{
	//if(other==self.realowner)
	//    return;
	Damage_DamageInfo(self.origin, 0, 0, 0, self.velocity, WEP_SEEKER | HITTYPE_BOUNCE, other.species, self);

	remove(self);
}

void W_Seeker_Tag_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(self.health <= 0)
		return;
	self.health = self.health - damage;
	if(self.health <= 0)
		W_Seeker_Tag_Explode();
}

void W_Seeker_Tag_Touch(void)
{
	vector dir;
	vector org2;
	entity e;

	PROJECTILE_TOUCH;

	dir     = normalize(self.realowner.origin - self.origin);
	org2    = findbetterlocation(self.origin, 8);

	te_knightspike(org2);

	self.event_damage = func_null;
	Damage_DamageInfo(self.origin, 0, 0, 0, self.velocity, WEP_SEEKER | HITTYPE_BOUNCE | HITTYPE_SECONDARY, other.species, self);

	if(other.takedamage == DAMAGE_AIM && other.deadflag == DEAD_NO)
	{
		// check to see if this person is already tagged by me
		entity tag = W_Seeker_Tagged_Info(self.realowner, other);

		if(tag != world)
		{
			if(other.wps_tag_tracker && (WEP_CVAR(seeker, type) == 1)) // don't attach another waypointsprite without killing the old one first
				WaypointSprite_Kill(other.wps_tag_tracker);

			tag.tag_time = time;
		}
		else
		{
			//sprint(self.realowner, strcat("You just tagged ^2", other.netname, "^7 with a tracking device!\n"));
			e             = spawn();
			e.cnt         = WEP_CVAR(seeker, missile_count);
			e.classname   = "tag_tracker";
			e.owner       = self.owner;
			e.realowner   = self.realowner;

			if(WEP_CVAR(seeker, type) == 1)
			{
				e.tag_target  = other;
				e.tag_time    = time;
				e.think       = W_Seeker_Tracker_Think;
			}
			else
			{
				e.enemy     = other;
				e.think     = W_Seeker_Vollycontroller_Think;
			}

			e.nextthink   = time;
		}

		if(WEP_CVAR(seeker, type) == 1)
		{
			WaypointSprite_Spawn("tagged-target", WEP_CVAR(seeker, tag_tracker_lifetime), 0, other, '0 0 64', self.realowner, 0, other, wps_tag_tracker, TRUE, RADARICON_TAGGED, '0.5 1 0');
			WaypointSprite_UpdateRule(other.wps_tag_tracker, 0, SPRITERULE_DEFAULT);
		}
	}

	remove(self);
	return;
}

void W_Seeker_Fire_Tag(void)
{
	entity missile;
	W_DecreaseAmmo(WEP_CVAR(seeker, tag_ammo));

	W_SetupShot_ProjectileSize(self, '-2 -2 -2', '2 2 2', FALSE, 2, "weapons/tag_fire.wav", CH_WEAPON_A, WEP_CVAR(seeker, missile_damage) * WEP_CVAR(seeker, missile_count));

	missile                 = spawn();
	missile.owner           = missile.realowner = self;
	missile.classname       = "seeker_tag";
	missile.bot_dodge       = TRUE;
	missile.bot_dodgerating = 50;
	missile.touch           = W_Seeker_Tag_Touch;
	missile.think           = SUB_Remove;
	missile.nextthink       = time + WEP_CVAR(seeker, tag_lifetime);
	missile.movetype        = MOVETYPE_FLY;
	missile.solid           = SOLID_BBOX;

	missile.takedamage       = DAMAGE_YES;
	missile.event_damage     = W_Seeker_Tag_Damage;
	missile.health           = WEP_CVAR(seeker, tag_health);
	missile.damageforcescale = WEP_CVAR(seeker, tag_damageforcescale);

	setorigin(missile, w_shotorg);
	setsize(missile, '-2 -2 -2', '2 2 2');

	missile.flags       = FL_PROJECTILE;
	//missile.missile_flags = MIF_..?;

	missile.movetype    = MOVETYPE_FLY;
	W_SetupProjVelocity_PRE(missile, seeker, tag_);
	missile.angles = vectoangles(missile.velocity);

	CSQCProjectile(missile, TRUE, PROJECTILE_TAG, FALSE); // has sound

	other = missile; MUTATOR_CALLHOOK(EditProjectile);
}

// ============================
// Begin: Genereal weapon functions
// ============================

float W_Seeker(float req)
{
	float ammo_amount;

	switch(req)
	{
		case WR_AIM:
		{
			if(WEP_CVAR(seeker, type) == 1)
				if(W_Seeker_Tagged_Info(self, self.enemy) != world)
					self.BUTTON_ATCK = bot_aim(WEP_CVAR(seeker, missile_speed_max), 0, WEP_CVAR(seeker, missile_lifetime), FALSE);
				else
					self.BUTTON_ATCK2 = bot_aim(WEP_CVAR(seeker, tag_speed), 0, WEP_CVAR(seeker, tag_lifetime), FALSE);
			else
				self.BUTTON_ATCK = bot_aim(WEP_CVAR(seeker, tag_speed), 0, WEP_CVAR(seeker, tag_lifetime), FALSE);
			return TRUE;
		}
		case WR_THINK:
		{
			if(autocvar_g_balance_seeker_reload_ammo && self.clip_load < min(WEP_CVAR(seeker, missile_ammo), WEP_CVAR(seeker, tag_ammo))) // forced reload
				WEP_ACTION(self.weapon, WR_RELOAD);

			else if(self.BUTTON_ATCK)
			{
				if(WEP_CVAR(seeker, type) == 1)
				{
					if(weapon_prepareattack(0, WEP_CVAR(seeker, missile_refire)))
					{
						W_Seeker_Attack();
						weapon_thinkf(WFRAME_FIRE2, WEP_CVAR(seeker, missile_animtime), w_ready);
					}
				}
				else
				{
					if(weapon_prepareattack(0, WEP_CVAR(seeker, tag_refire)))
					{
						W_Seeker_Fire_Tag();
						weapon_thinkf(WFRAME_FIRE2, WEP_CVAR(seeker, tag_animtime), w_ready);
					}
				}
			}

			else if(self.BUTTON_ATCK2)
			{
				if(WEP_CVAR(seeker, type) == 1)
				{
					if(weapon_prepareattack(0, WEP_CVAR(seeker, tag_refire)))
					{
						W_Seeker_Fire_Tag();
						weapon_thinkf(WFRAME_FIRE2, WEP_CVAR(seeker, tag_animtime), w_ready);
					}
				}
				else
				{
					if(weapon_prepareattack(0, WEP_CVAR(seeker, flac_refire)))
					{
						W_Seeker_Fire_Flac();
						weapon_thinkf(WFRAME_FIRE2, WEP_CVAR(seeker, flac_animtime), w_ready);
					}
				}
			}

			return TRUE;
		}
		case WR_INIT:
		{
			precache_model("models/weapons/g_seeker.md3");
			precache_model("models/weapons/v_seeker.md3");
			precache_model("models/weapons/h_seeker.iqm");
			precache_sound("weapons/tag_fire.wav");
			precache_sound("weapons/flac_fire.wav");
			precache_sound("weapons/seeker_fire.wav");
			SEEKER_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP)
			return TRUE;
		}
		case WR_CHECKAMMO1:
		{
			if(WEP_CVAR(seeker, type) == 1)
			{
				ammo_amount = self.WEP_AMMO(SEEKER) >= WEP_CVAR(seeker, missile_ammo);
				ammo_amount += self.(weapon_load[WEP_SEEKER]) >= WEP_CVAR(seeker, missile_ammo);
			}
			else
			{
				ammo_amount = self.WEP_AMMO(SEEKER) >= WEP_CVAR(seeker, tag_ammo);
				ammo_amount += self.(weapon_load[WEP_SEEKER]) >= WEP_CVAR(seeker, tag_ammo);
			}
			return ammo_amount;
		}
		case WR_CHECKAMMO2:
		{
			if(WEP_CVAR(seeker, type) == 1)
			{
				ammo_amount = self.WEP_AMMO(SEEKER) >= WEP_CVAR(seeker, tag_ammo);
				ammo_amount += self.(weapon_load[WEP_SEEKER]) >= WEP_CVAR(seeker, tag_ammo);
			}
			else
			{
				ammo_amount = self.WEP_AMMO(SEEKER) >= WEP_CVAR(seeker, flac_ammo);
				ammo_amount += self.(weapon_load[WEP_SEEKER]) >= WEP_CVAR(seeker, flac_ammo);
			}
			return ammo_amount;
		}
		case WR_CONFIG:
		{
			SEEKER_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS)
			return TRUE;
		}
		case WR_RELOAD:
		{
			W_Reload(min(WEP_CVAR(seeker, missile_ammo), WEP_CVAR(seeker, tag_ammo)), "weapons/reload.wav");
			return TRUE;
		}
		case WR_SUICIDEMESSAGE:
		{
			return WEAPON_SEEKER_SUICIDE;
		}
		case WR_KILLMESSAGE:
		{
			if(w_deathtype & HITTYPE_SECONDARY)
				return WEAPON_SEEKER_MURDER_TAG;
			else
				return WEAPON_SEEKER_MURDER_SPRAY;
		}
	}
	return FALSE;
}
#endif
#ifdef CSQC
float W_Seeker(float req)
{
	switch(req)
	{
		case WR_IMPACTEFFECT:
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
						if(w_random<0.15)
							sound(self, CH_SHOTS, "weapons/tagexp1.wav", 1, ATTEN_NORM);
						else if(w_random<0.7)
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
					if(w_random<0.15)
						sound(self, CH_SHOTS, "weapons/seekerexp1.wav", 1, ATTEN_NORM);
					else if(w_random<0.7)
						sound(self, CH_SHOTS, "weapons/seekerexp2.wav", 1, ATTEN_NORM);
					else
						sound(self, CH_SHOTS, "weapons/seekerexp3.wav", 1, ATTEN_NORM);
				}
			}
			return TRUE;
		}
		case WR_INIT:
		{
			precache_sound("weapons/seekerexp1.wav");
			precache_sound("weapons/seekerexp2.wav");
			precache_sound("weapons/seekerexp3.wav");
			precache_sound("weapons/tagexp1.wav");
			precache_sound("weapons/tagexp2.wav");
			precache_sound("weapons/tagexp3.wav");
			precache_sound("weapons/tag_impact.wav");
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
