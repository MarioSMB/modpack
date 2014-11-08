#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ FIREBALL,
/* function  */ W_Fireball,
/* ammotype  */ ammo_none,
/* impulse   */ 9,
/* flags     */ WEP_FLAG_SUPERWEAPON | WEP_TYPE_SPLASH,
/* rating    */ BOT_PICKUP_RATING_MID,
/* color     */ '1 0.5 0',
/* modelname */ "fireball",
/* simplemdl */ "foobar",
/* crosshair */ "gfx/crosshairfireball",
/* wepimg    */ "weaponfireball",
/* refname   */ "fireball",
/* wepname   */ _("Fireball")
);

#define FIREBALL_SETTINGS(w_cvar,w_prop) FIREBALL_SETTINGS_LIST(w_cvar, w_prop, FIREBALL, fireball)
#define FIREBALL_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, BOTH, animtime) \
	w_cvar(id, sn, BOTH, refire) \
	w_cvar(id, sn, BOTH, damage) \
	w_cvar(id, sn, BOTH, damageforcescale) \
	w_cvar(id, sn, BOTH, speed) \
	w_cvar(id, sn, BOTH, spread) \
	w_cvar(id, sn, BOTH, lifetime) \
	w_cvar(id, sn, BOTH, laserburntime) \
	w_cvar(id, sn, BOTH, laserdamage) \
	w_cvar(id, sn, BOTH, laseredgedamage) \
	w_cvar(id, sn, BOTH, laserradius) \
	w_cvar(id, sn, PRI,  edgedamage) \
	w_cvar(id, sn, PRI,  force) \
	w_cvar(id, sn, PRI,  radius) \
	w_cvar(id, sn, PRI,  health) \
	w_cvar(id, sn, PRI,  refire2) \
	w_cvar(id, sn, PRI,  bfgdamage) \
	w_cvar(id, sn, PRI,  bfgforce) \
	w_cvar(id, sn, PRI,  bfgradius) \
	w_cvar(id, sn, SEC,  damagetime) \
	w_cvar(id, sn, SEC,  speed_up) \
	w_cvar(id, sn, SEC,  speed_z) \
	w_prop(id, sn, float,  switchdelay_raise, switchdelay_raise) \
	w_prop(id, sn, float,  switchdelay_drop, switchdelay_drop) \
	w_prop(id, sn, string, weaponreplace, weaponreplace) \
	w_prop(id, sn, float,  weaponstart, weaponstart) \
	w_prop(id, sn, float,  weaponstartoverride, weaponstartoverride) \
	w_prop(id, sn, float,  weaponthrowable, weaponthrowable)

#ifdef SVQC
FIREBALL_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
.float bot_primary_fireballmooth; // whatever a mooth is
.vector fireball_impactvec;
.float fireball_primarytime;
#endif
#else
#ifdef SVQC
void spawnfunc_weapon_fireball(void) { weapon_defaultspawnfunc(WEP_FIREBALL); }

void W_Fireball_Explode(void)
{
	entity e;
	float dist;
	float points;
	vector dir;
	float d;

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	// 1. dist damage
	d = (self.realowner.health + self.realowner.armorvalue);
	RadiusDamage(self, self.realowner, WEP_CVAR_PRI(fireball, damage), WEP_CVAR_PRI(fireball, edgedamage), WEP_CVAR_PRI(fireball, radius), world, world, WEP_CVAR_PRI(fireball, force), self.projectiledeathtype, other);
	if(self.realowner.health + self.realowner.armorvalue >= d)
	if(!self.cnt)
	{
		modeleffect_spawn("models/sphere/sphere.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, WEP_CVAR_PRI(fireball, bfgradius), 0.2, 0.05, 0.25);

		// 2. bfg effect
		// NOTE: this cannot be made warpzone aware by design. So, better intentionally ignore warpzones here.
		for(e = findradius(self.origin, WEP_CVAR_PRI(fireball, bfgradius)); e; e = e.chain)
		if(e != self.realowner) if(e.takedamage == DAMAGE_AIM) if(!IS_PLAYER(e) || !self.realowner || DIFF_TEAM(e, self))
		{
			// can we see fireball?
			traceline(e.origin + e.view_ofs, self.origin, MOVE_NORMAL, e);
			if(/* trace_startsolid || */ trace_fraction != 1) // startsolid should be never happening anyway
				continue;
			// can we see player who shot fireball?
			traceline(e.origin + e.view_ofs, self.realowner.origin + self.realowner.view_ofs, MOVE_NORMAL, e);
			if(trace_ent != self.realowner)
			if(/* trace_startsolid || */ trace_fraction != 1)
				continue;
			dist = vlen(self.origin - e.origin - e.view_ofs);
			points = (1 - sqrt(dist / WEP_CVAR_PRI(fireball, bfgradius)));
			if(points <= 0)
				continue;
			dir = normalize(e.origin + e.view_ofs - self.origin);

			if(accuracy_isgooddamage(self.realowner, e))
				accuracy_add(self.realowner, WEP_FIREBALL, 0, WEP_CVAR_PRI(fireball, bfgdamage) * points);

			Damage(e, self, self.realowner, WEP_CVAR_PRI(fireball, bfgdamage) * points, self.projectiledeathtype | HITTYPE_BOUNCE | HITTYPE_SPLASH, e.origin + e.view_ofs, WEP_CVAR_PRI(fireball, bfgforce) * dir);
			Send_Effect(EFFECT_FIREBALL_BFGDAMAGE, e.origin, -1 * dir, 1);
		}
	}

	remove(self);
}

void W_Fireball_TouchExplode(void)
{
	PROJECTILE_TOUCH;
	W_Fireball_Explode();
}

void W_Fireball_LaserPlay(float dt, float dist, float damage, float edgedamage, float burntime)
{
	entity e;
	float d;
	vector p;

	if(damage <= 0)
		return;

	RandomSelection_Init();
	for(e = WarpZone_FindRadius(self.origin, dist, TRUE); e; e = e.chain)
	if(e != self.realowner) if(e.takedamage == DAMAGE_AIM) if(!IS_PLAYER(e) || !self.realowner || DIFF_TEAM(e, self))
	{
		p = e.origin;
		p_x += e.mins_x + random() * (e.maxs_x - e.mins_x);
		p_y += e.mins_y + random() * (e.maxs_y - e.mins_y);
		p_z += e.mins_z + random() * (e.maxs_z - e.mins_z);
		d = vlen(WarpZone_UnTransformOrigin(e, self.origin) - p);
		if(d < dist)
		{
			e.fireball_impactvec = p;
			RandomSelection_Add(e, 0, string_null, 1 / (1 + d), !Fire_IsBurning(e));
		}
	}
	if(RandomSelection_chosen_ent)
	{
		d = vlen(WarpZone_UnTransformOrigin(RandomSelection_chosen_ent, self.origin) - RandomSelection_chosen_ent.fireball_impactvec);
		d = damage + (edgedamage - damage) * (d / dist);
		Fire_AddDamage(RandomSelection_chosen_ent, self.realowner, d * burntime, burntime, self.projectiledeathtype | HITTYPE_BOUNCE);
		Send_Effect(EFFECT_FIREBALL_LASER, self.origin, RandomSelection_chosen_ent.fireball_impactvec - self.origin, 1);
	}
}

void W_Fireball_Think(void)
{
	if(time > self.pushltime)
	{
		self.cnt = 1;
		self.projectiledeathtype |= HITTYPE_SPLASH;
		W_Fireball_Explode();
		return;
	}

	W_Fireball_LaserPlay(0.1, WEP_CVAR_PRI(fireball, laserradius), WEP_CVAR_PRI(fireball, laserdamage), WEP_CVAR_PRI(fireball, laseredgedamage), WEP_CVAR_PRI(fireball, laserburntime));

	self.nextthink = time + 0.1;
}

void W_Fireball_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(self.health <= 0)
		return;

	if(!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt

	self.health = self.health - damage;
	if(self.health <= 0)
	{
		self.cnt = 1;
		W_PrepareExplosionByDamage(attacker, W_Fireball_Explode);
	}
}

void W_Fireball_Attack1(void)
{
	entity proj;

	W_SetupShot_ProjectileSize(self, '-16 -16 -16', '16 16 16', FALSE, 2, W_Sound("fireball_fire2"), CH_WEAPON_A, WEP_CVAR_PRI(fireball, damage) + WEP_CVAR_PRI(fireball, bfgdamage));

	Send_Effect(EFFECT_FIREBALL_MUZZLEFLASH, w_shotorg, w_shotdir * 1000, 1);

	proj = spawn();
	proj.classname = "plasma_prim";
	proj.owner = proj.realowner = self;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = WEP_CVAR_PRI(fireball, damage);
	proj.pushltime = time + WEP_CVAR_PRI(fireball, lifetime);
	proj.use = W_Fireball_Explode;
	proj.think = W_Fireball_Think;
	proj.nextthink = time;
	proj.health = WEP_CVAR_PRI(fireball, health);
	proj.team = self.team;
	proj.event_damage = W_Fireball_Damage;
	proj.takedamage = DAMAGE_YES;
	proj.damageforcescale = WEP_CVAR_PRI(fireball, damageforcescale);
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = WEP_FIREBALL;
	setorigin(proj, w_shotorg);

	proj.movetype = MOVETYPE_FLY;
	W_SetupProjVelocity_PRI(proj, fireball);
	proj.angles = vectoangles(proj.velocity);
	proj.touch = W_Fireball_TouchExplode;
	setsize(proj, '-16 -16 -16', '16 16 16');
	proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH | MIF_PROXY;

	CSQCProjectile(proj, TRUE, PROJECTILE_FIREBALL, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

void W_Fireball_AttackEffect(float i, vector f_diff)
{
	W_SetupShot_ProjectileSize(self, '-16 -16 -16', '16 16 16', FALSE, 0, "", 0, 0);
	w_shotorg += f_diff_x * v_up + f_diff_y * v_right;
	Send_Effect(EFFECT_FIREBALL_PRE_MUZZLEFLASH, w_shotorg, w_shotdir * 1000, 1);
}

void W_Fireball_Attack1_Frame4(void)
{
	W_Fireball_Attack1();
	weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_PRI(fireball, animtime), w_ready);
}

void W_Fireball_Attack1_Frame3(void)
{
	W_Fireball_AttackEffect(0, '+1.25 +3.75 0');
	weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_PRI(fireball, animtime), W_Fireball_Attack1_Frame4);
}

void W_Fireball_Attack1_Frame2(void)
{
	W_Fireball_AttackEffect(0, '-1.25 +3.75 0');
	weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_PRI(fireball, animtime), W_Fireball_Attack1_Frame3);
}

void W_Fireball_Attack1_Frame1(void)
{
	W_Fireball_AttackEffect(1, '+1.25 -3.75 0');
	weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_PRI(fireball, animtime), W_Fireball_Attack1_Frame2);
}

void W_Fireball_Attack1_Frame0(void)
{
	W_Fireball_AttackEffect(0, '-1.25 -3.75 0');
	sound(self, CH_WEAPON_SINGLE, W_Sound("fireball_prefire2"), VOL_BASE, ATTEN_NORM);
	weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_PRI(fireball, animtime), W_Fireball_Attack1_Frame1);
}

void W_Fireball_Firemine_Think(void)
{
	if(time > self.pushltime)
	{
		remove(self);
		return;
	}

	// make it "hot" once it leaves its owner
	if(self.owner)
	{
		if(vlen(self.origin - self.owner.origin - self.owner.view_ofs) > WEP_CVAR_SEC(fireball, laserradius))
		{
			self.cnt += 1;
			if(self.cnt == 3)
				self.owner = world;
		}
		else
			self.cnt = 0;
	}

	W_Fireball_LaserPlay(0.1, WEP_CVAR_SEC(fireball, laserradius), WEP_CVAR_SEC(fireball, laserdamage), WEP_CVAR_SEC(fireball, laseredgedamage), WEP_CVAR_SEC(fireball, laserburntime));

	self.nextthink = time + 0.1;
}

void W_Fireball_Firemine_Touch(void)
{
	PROJECTILE_TOUCH;
	if(other.takedamage == DAMAGE_AIM)
	if(Fire_AddDamage(other, self.realowner, WEP_CVAR_SEC(fireball, damage), WEP_CVAR_SEC(fireball, damagetime), self.projectiledeathtype) >= 0)
	{
		remove(self);
		return;
	}
	self.projectiledeathtype |= HITTYPE_BOUNCE;
}

void W_Fireball_Attack2(void)
{
	entity proj;
	vector f_diff;
	float c;

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
	W_SetupShot_ProjectileSize(self, '-4 -4 -4', '4 4 4', FALSE, 2, W_Sound("fireball_fire"), CH_WEAPON_A, WEP_CVAR_SEC(fireball, damage));
	traceline(w_shotorg, w_shotorg + f_diff_x * v_up + f_diff_y * v_right, MOVE_NORMAL, self);
	w_shotorg = trace_endpos;

	Send_Effect(EFFECT_FIREBALL_MUZZLEFLASH, w_shotorg, w_shotdir * 1000, 1);

	proj = spawn();
	proj.owner = proj.realowner = self;
	proj.classname = "grenade";
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = WEP_CVAR_SEC(fireball, damage);
	proj.movetype = MOVETYPE_BOUNCE;
	proj.projectiledeathtype = WEP_FIREBALL | HITTYPE_SECONDARY;
	proj.touch = W_Fireball_Firemine_Touch;
	PROJECTILE_MAKETRIGGER(proj);
	setsize(proj, '-4 -4 -4', '4 4 4');
	setorigin(proj, w_shotorg);
	proj.think = W_Fireball_Firemine_Think;
	proj.nextthink = time;
	proj.damageforcescale = WEP_CVAR_SEC(fireball, damageforcescale);
	proj.pushltime = time + WEP_CVAR_SEC(fireball, lifetime);
	W_SetupProjVelocity_UP_SEC(proj, fireball);

	proj.angles = vectoangles(proj.velocity);
	proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH | MIF_PROXY | MIF_ARC;

	CSQCProjectile(proj, TRUE, PROJECTILE_FIREMINE, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

float W_Fireball(float req)
{
	switch(req)
	{
		case WR_AIM:
		{
			self.BUTTON_ATCK = FALSE;
			self.BUTTON_ATCK2 = FALSE;
			if(self.bot_primary_fireballmooth == 0)
			{
				if(bot_aim(WEP_CVAR_PRI(fireball, speed), 0, WEP_CVAR_PRI(fireball, lifetime), FALSE))
				{
					self.BUTTON_ATCK = TRUE;
					if(random() < 0.02) self.bot_primary_fireballmooth = 0;
				}
			}
			else
			{
				if(bot_aim(WEP_CVAR_SEC(fireball, speed), WEP_CVAR_SEC(fireball, speed_up), WEP_CVAR_SEC(fireball, lifetime), TRUE))
				{
					self.BUTTON_ATCK2 = TRUE;
					if(random() < 0.01) self.bot_primary_fireballmooth = 1;
				}
			}
			
			return TRUE;
		}
		case WR_THINK:
		{
			if(self.BUTTON_ATCK)
			{
				if(time >= self.fireball_primarytime)
				if(weapon_prepareattack(0, WEP_CVAR_PRI(fireball, refire)))
				{
					W_Fireball_Attack1_Frame0();
					self.fireball_primarytime = time + WEP_CVAR_PRI(fireball, refire2) * W_WeaponRateFactor();
				}
			}
			else if(self.BUTTON_ATCK2)
			{
				if(weapon_prepareattack(1, WEP_CVAR_SEC(fireball, refire)))
				{
					W_Fireball_Attack2();
					weapon_thinkf(WFRAME_FIRE2, WEP_CVAR_SEC(fireball, animtime), w_ready);
				}
			}
			
			return TRUE;
		}
		case WR_INIT:
		{
			precache_model("models/weapons/g_fireball.md3");
			precache_model("models/weapons/v_fireball.md3");
			precache_model("models/weapons/h_fireball.iqm");
			precache_model("models/sphere/sphere.md3");
			precache_sound(W_Sound("fireball_fire"));
			precache_sound(W_Sound("fireball_fire2"));
			precache_sound(W_Sound("fireball_prefire2"));
			FIREBALL_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP)
			return TRUE;
		}
		case WR_SETUP:
		{
			self.ammo_field = ammo_none;
			return TRUE;
		}
		case WR_CHECKAMMO1:
		case WR_CHECKAMMO2:
		{
			return TRUE; // fireball has infinite ammo
		}
		case WR_CONFIG:
		{
			FIREBALL_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS)
			return TRUE;
		}
		case WR_RESETPLAYER:
		{
			self.fireball_primarytime = time;
			return TRUE;
		}
		case WR_SUICIDEMESSAGE:
		{
			if(w_deathtype & HITTYPE_SECONDARY)
				return WEAPON_FIREBALL_SUICIDE_FIREMINE;
			else
				return WEAPON_FIREBALL_SUICIDE_BLAST;
		}
		case WR_KILLMESSAGE:
		{
			if(w_deathtype & HITTYPE_SECONDARY)
				return WEAPON_FIREBALL_MURDER_FIREMINE;
			else
				return WEAPON_FIREBALL_MURDER_BLAST;
		}
	}
	return FALSE;
}
#endif
#ifdef CSQC
float W_Fireball(float req)
{
	switch(req)
	{
		case WR_IMPACTEFFECT:
		{
			vector org2;
			if(w_deathtype & HITTYPE_SECONDARY)
			{
				// firemine goes out silently
			}
			else
			{
				org2 = w_org + w_backoff * 16;
				pointparticles(particleeffectnum("fireball_explode"), org2, '0 0 0', 1);
				if(!w_issilent)
					sound(self, CH_SHOTS, "weapons/fireball_impact2.wav", VOL_BASE, ATTEN_NORM * 0.25); // long range boom
			}
			
			return TRUE;
		}
		case WR_INIT:
		{
			precache_sound("weapons/fireball_impact2.wav");
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
