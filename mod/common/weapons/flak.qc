#ifndef IMPLEMENTATION
MODEL(FLAK_MUZZLEFLASH,           "models/flash.md3");
MODEL(FLAK_VIEW,                  W_Model("h_flak.iqm"));
MODEL(FLAK_WORLD,                 W_Model("v_flak.md3"));
MODEL(FLAK_ITEM,                  W_Model("g_flak.md3"));

MODEL(PROJECTILE_FLAK,                  "models/tracer.mdl");
MODEL(PROJECTILE_FLAK_BOMB,             "models/rocket.md3");

EFFECT(0, FLAK_BOUNCE, "flak_bounce")

SOUND(FLAK_CASINGS1, W_Sound("casings1"));
SOUND(FLAK_CASINGS2, W_Sound("casings2"));
SOUND(FLAK_CASINGS3, W_Sound("casings3"));
string SND_FLAK_CASINGS_RANDOM() {
    return Sounds[SND_FLAK_CASINGS1.m_id + floor(prandom() * 3)].sound_str();
}

SOUND(FLAK_FIRE, W_Sound("flak_fire"));
SOUND(FLAK_FIRE2, W_Sound("flak_fire2"));
SOUND(FLAK_FIRE3, W_Sound("flak_fire3"));

CLASS(Flak, Weapon)
/* ammotype  */ ATTRIB(Flak, ammo_field, .int, ammo_shells)
/* impulse   */ ATTRIB(Flak, impulse, int,8)
/* flags     */ ATTRIB(Flak, spawnflags, int, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_SPLASH);
/* rating    */ ATTRIB(Flak, bot_pickupbasevalue, float, BOT_PICKUP_RATING_MID);
/* color     */ ATTRIB(Flak, wpcolor, vector, '1 1 0');
/* modelname */ ATTRIB(Flak, mdl, string, "flak");
#ifndef MENUQC
/* model     */ ATTRIB(Flak, m_model, Model, MDL_FLAK_ITEM);
#endif
/* crosshair */ ATTRIB(Flak, w_crosshair, string, "gfx/crosshairflak");
/* crosshair */ ATTRIB(Flak, w_crosshair_size, float, 0.8);
/* wepimg    */ ATTRIB(Flak, model2, string, "weaponflak");
/* refname   */ ATTRIB(Flak, netname, string, "flak");
/* wepname   */ ATTRIB(Flak, message, string, _("Flak Cannon"));
ENDCLASS(Flak)
REGISTER_WEAPON(FLAK, NEW(Flak));

const int PROJECTILE_FLAK = 45;
const int PROJECTILE_FLAK_BOMB = 46;

MSG_INFO_NOTIF(1, INFO_WEAPON_FLAK_MURDER_SPLASH,      3, 2, "spree_inf s1 s2 s3loc spree_end", "s2 s1",  "weaponflak",   _("^BG%s%s^K1 took ^BG%s^K1's Flak%s%s"), "")
MSG_INFO_NOTIF(1, INFO_WEAPON_FLAK_MURDER_SPRAY,       3, 2, "spree_inf s1 s2 s3loc spree_end", "s2 s1",  "weaponflak",   _("^BG%s%s^K1 was shredded by ^BG%s^K1's Flak Cannon%s%s"), "")
MSG_INFO_NOTIF(1, INFO_WEAPON_FLAK_SUICIDE,            2, 1, "s1 s2loc spree_lost", "s1",                 "weaponflak",   _("^BG%s^K1 was shredded by their own Flak Cannon%s%s"), "")

MSG_MULTI_NOTIF(1, WEAPON_FLAK_MURDER_SPLASH,      NO_MSG,        INFO_WEAPON_FLAK_MURDER_SPLASH,      NO_MSG)
MSG_MULTI_NOTIF(1, WEAPON_FLAK_MURDER_SPRAY,       NO_MSG,        INFO_WEAPON_FLAK_MURDER_SPRAY,       NO_MSG)
MSG_MULTI_NOTIF(1, WEAPON_FLAK_SUICIDE,            NO_MSG,        INFO_WEAPON_FLAK_SUICIDE,            CENTER_DEATH_SELF_GENERIC)

#ifdef SVQC
STATIC_INIT(flak_cvars)
{
	localcmd("\ng_balance_flak_primary_damage 7\n");
	localcmd("\ng_balance_flak_primary_damage_bouncefactor 0.5\n");
	localcmd("\ng_balance_flak_primary_count 34\n");
	localcmd("\ng_balance_flak_primary_refire 0.5\n");
	localcmd("\ng_balance_flak_primary_animtime 0.2\n");
	localcmd("\ng_balance_flak_primary_ammo 2\n");
	localcmd("\ng_balance_flak_primary_speed 2000\n");
	localcmd("\ng_balance_flak_primary_speed_up 0\n");
	localcmd("\ng_balance_flak_primary_spread_up 6\n");
	localcmd("\ng_balance_flak_primary_spread_side 11\n");
	localcmd("\ng_balance_flak_primary_lifetime 1.5\n");
	localcmd("\ng_balance_flak_primary_gravity 1\n");
	localcmd("\ng_balance_flak_primary_force 25\n");
	localcmd("\ng_balance_flak_primary_passthrough 0.5\n");
	localcmd("\ng_balance_flak_primary_bouncefactor 0.25\n");
	localcmd("\ng_balance_flak_secondary_damage 4\n");
	localcmd("\ng_balance_flak_secondary_damage_bouncefactor 0.5\n");
	localcmd("\ng_balance_flak_secondary_count 24\n");
	localcmd("\ng_balance_flak_secondary_refire 0.7\n");
	localcmd("\ng_balance_flak_secondary_animtime 0.3\n");
	localcmd("\ng_balance_flak_secondary_ammo 3\n");
	localcmd("\ng_balance_flak_secondary_speed 1000\n");
	localcmd("\ng_balance_flak_secondary_speed_up 0\n");
	localcmd("\ng_balance_flak_secondary_spread_up 7\n");
	localcmd("\ng_balance_flak_secondary_spread_side 15\n");
	localcmd("\ng_balance_flak_secondary_lifetime 1.5\n");
	localcmd("\ng_balance_flak_secondary_gravity 1\n");
	localcmd("\ng_balance_flak_secondary_force 25\n");
	localcmd("\ng_balance_flak_secondary_passthrough 0.5\n");
	localcmd("\ng_balance_flak_secondary_bouncefactor 0.25\n");
	localcmd("\ng_balance_flak_bomb 1\n");
	localcmd("\ng_balance_flak_bomb_ammo 3\n");
	localcmd("\ng_balance_flak_bomb_count 24\n");
	localcmd("\ng_balance_flak_bomb_damage 45\n");
	localcmd("\ng_balance_flak_bomb_edgedamage 5\n");
	localcmd("\ng_balance_flak_bomb_radius 140\n");
	localcmd("\ng_balance_flak_bomb_force 300\n");
	localcmd("\ng_balance_flak_bomb_lifetime 3\n");
	localcmd("\ng_balance_flak_bomb_health 50\n");
	localcmd("\ng_balance_flak_bomb_damageforcescale 4\n");
	localcmd("\ng_balance_flak_bomb_speed 1800\n");
	localcmd("\ng_balance_flak_bomb_speed_up 200\n");
	localcmd("\ng_balance_flak_bomb_spread_up 7\n");
	localcmd("\ng_balance_flak_bomb_spread_side 15\n");
	localcmd("\ng_balance_flak_switchdelay_drop 0.2\n");
	localcmd("\ng_balance_flak_switchdelay_raise 0.2\n");
	localcmd("\ng_balance_flak_weaponreplace \"\"\n");
	localcmd("\ng_balance_flak_weaponstart 0\n");
	localcmd("\ng_balance_flak_weaponstartoverride -1\n");
	localcmd("\ng_balance_flak_weaponthrowable 1\n");
}
#endif

#define FLAK_SETTINGS(w_cvar,w_prop) FLAK_SETTINGS_LIST(w_cvar, w_prop, FLAK, flak)
#define FLAK_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, BOTH, ammo) \
	w_cvar(id, sn, BOTH, animtime) \
	w_cvar(id, sn, BOTH, bouncefactor) \
	w_cvar(id, sn, BOTH, count) \
	w_cvar(id, sn, BOTH, damage) \
	w_cvar(id, sn, BOTH, damage_bouncefactor) \
	w_cvar(id, sn, BOTH, force) \
	w_cvar(id, sn, BOTH, gravity) \
	w_cvar(id, sn, BOTH, refire) \
	w_cvar(id, sn, BOTH, speed) \
	w_cvar(id, sn, BOTH, speed_up) \
	w_cvar(id, sn, BOTH, spread_side) \
	w_cvar(id, sn, BOTH, spread_up) \
	w_cvar(id, sn, BOTH, passthrough) \
	w_cvar(id, sn, BOTH, lifetime) \
	w_cvar(id, sn, NONE, bomb_ammo) \
	w_cvar(id, sn, NONE, bomb) \
	w_cvar(id, sn, NONE, bomb_count) \
	w_cvar(id, sn, NONE, bomb_damage) \
	w_cvar(id, sn, NONE, bomb_damageforcescale) \
	w_cvar(id, sn, NONE, bomb_edgedamage) \
	w_cvar(id, sn, NONE, bomb_force) \
	w_cvar(id, sn, NONE, bomb_health) \
	w_cvar(id, sn, NONE, bomb_lifetime) \
	w_cvar(id, sn, NONE, bomb_radius) \
	w_cvar(id, sn, NONE, bomb_speed) \
	w_cvar(id, sn, NONE, bomb_speed_up) \
	w_cvar(id, sn, NONE, bomb_spread_side) \
	w_cvar(id, sn, NONE, bomb_spread_up) \
	w_prop(id, sn, float,  reloading_ammo, reload_ammo) \
	w_prop(id, sn, float,  reloading_time, reload_time) \
	w_prop(id, sn, float,  switchdelay_raise, switchdelay_raise) \
	w_prop(id, sn, float,  switchdelay_drop, switchdelay_drop) \
	w_prop(id, sn, string, weaponreplace, weaponreplace) \
	w_prop(id, sn, float,  weaponstart, weaponstart) \
	w_prop(id, sn, float,  weaponstartoverride, weaponstartoverride) \
	w_prop(id, sn, float,  weaponthrowable, weaponthrowable)

#ifdef SVQC
FLAK_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
#endif
#endif
#ifdef IMPLEMENTATION
#ifdef SVQC
spawnfunc(weapon_flak) { weapon_defaultspawnfunc(this, WEP_FLAK); }

void W_Flak_Projectile_Touch(void)
{
	PROJECTILE_TOUCH;

	if(other.takedamage)
	{
		float damage, bnc, frc;
		bool isprimary = !(self.projectiledeathtype & HITTYPE_SECONDARY);

		if(other != self.enemy && (other != self.realowner || (self.projectiledeathtype & HITTYPE_BOUNCE)))
		{
			bnc = pow(WEP_CVAR_BOTH(flak, isprimary, damage_bouncefactor), self.cnt);
			damage = WEP_CVAR_BOTH(flak, isprimary, damage) * bnc;
			frc = WEP_CVAR_BOTH(flak, isprimary, force) * bnc;

			vector force = normalize(NearestPointOnBox(other, self.origin) - self.origin + self.velocity) * frc;

			self.owner = self.realowner;
			Damage(other, self, self.realowner, damage, self.projectiledeathtype, self.origin, force);

			if(accuracy_isgooddamage(self.realowner, other))
 				{ accuracy_add(self.realowner, WEP_FLAK.m_id, 0, damage); }
		}

		//Send_Effect(EFFECT_FLAK_BOUNCE, self.origin, self.velocity, 1);

		bool passThrough = WEP_CVAR_BOTH(flak, isprimary, passthrough);

		if(passThrough <= 0)
		{
			remove(self);
			return;
		}

		// semi-fix for "melee" hits
		if(other == self.realowner && !(self.projectiledeathtype & HITTYPE_BOUNCE))
			self.velocity = self.velocity * -1;

		// pass through - we don't want to bounce here, overwrite velocity later
		self.oldvelocity = self.velocity * passThrough;

		// we don't want to hit the same entity again right away
		self.owner = other;
		if(other.iscreature)
			self.enemy = other;
	}
	else if(other.solid == SOLID_BSP || !other)
	{
		if(other)
			spamsound(self, CH_SHOTS, SND_FLAK_CASINGS_RANDOM(), VOL_BASE * 0.7, ATTN_NORM);
		//pointparticles(particleeffectnum("flak_bounce"), self.origin, self.velocity, 1);
		self.owner = world;
		self.projectiledeathtype |= HITTYPE_BOUNCE;
		self.cnt += 1;
	}
}

void W_Flak_Projectile_Think(void)
{
	if(time > self.spawnshieldtime)
	{
		remove(self);
		return;
	}

	if(self.oldvelocity)
	{
		self.velocity = self.oldvelocity;
		self.oldvelocity = '0 0 0';
		UpdateCSQCProjectile(self);
	}

	self.nextthink = time;
}

entity W_Flak_Projectile(entity o, bool isprimary, float damage, float grav, float lt, float spd, float upspd, float bnc, int deathtype)
{
	entity e = spawn();
	e.owner = e.realowner = o;
	e.classname = "flak_proj";
	e.bot_dodge = true;
	e.bot_dodgerating = damage;
	e.movetype = MOVETYPE_BOUNCE;
	PROJECTILE_MAKETRIGGER(e);
	e.projectiledeathtype = deathtype;
	e.gravity = grav;
	e.bouncefactor = bnc;
	setorigin(e, w_shotorg);
	setsize(e, '0 0 -3', '0 0 -3');

	e.spawnshieldtime = time + lt;
	e.nextthink = time;
	e.think = W_Flak_Projectile_Think;
	e.touch = W_Flak_Projectile_Touch;
	W_SetupProjVelocity_Explicit(e, v_forward, v_up, spd, upspd, 0, 0, false);

	e.angles = vectoangles(e.velocity);
	e.flags = FL_PROJECTILE;
	e.missile_flags = MIF_ARC;

	CSQCProjectile(e, true, PROJECTILE_FLAK, true);   

	// common properties
	MUTATOR_CALLHOOK(EditProjectile, o, e);
	return e;
}

void W_Flak_Attack1(Weapon thiswep, bool isprimary)
{
	float pcount = WEP_CVAR_BOTH(flak, isprimary, count), i;
	int dtype = (isprimary) ? WEP_FLAK.m_id : (WEP_FLAK.m_id | HITTYPE_SECONDARY | HITTYPE_BOUNCE);

	W_DecreaseAmmo(thiswep, self, WEP_CVAR_BOTH(flak, isprimary, ammo));

	W_SetupShot_ProjectileSize(self, '0 0 -3', '0 0 -3', false, 4, ((isprimary) ? SND(FLAK_FIRE2) : SND(FLAK_FIRE)), CH_WEAPON_A, WEP_CVAR_BOTH(flak, isprimary, damage) * pcount);
	w_shotdir = v_forward;
	vector a;

	for(i = 0; i < pcount; ++i)
	{
		a = fixedvectoangles(w_shotdir);

		fixedmakevectors(a + '1 0 0' *  random() * WEP_CVAR_BOTH(flak, isprimary, spread_up) + '0 1 0' * crandom() * WEP_CVAR_BOTH(flak, isprimary, spread_side));

		W_Flak_Projectile(self, isprimary,
						  WEP_CVAR_BOTH(flak, isprimary, damage),
						  WEP_CVAR_BOTH(flak, isprimary, gravity),
						  WEP_CVAR_BOTH(flak, isprimary, lifetime),
						  WEP_CVAR_BOTH(flak, isprimary, speed),
						  WEP_CVAR_BOTH(flak, isprimary, speed_up),
						  WEP_CVAR_BOTH(flak, isprimary, bouncefactor),
						  dtype);
	}

	entity flash = spawn();
	setmodel(flash, MDL_FLAK_MUZZLEFLASH);
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(self, flash, '5 0 0');
}

void W_Flak_Bomb_Explode(void)
{
	vector dir = normalize(self.velocity);
	dir = dir - 2 * (dir * trace_plane_normal) * trace_plane_normal; 

	if(other.takedamage == DAMAGE_AIM)
		if(IS_PLAYER(other))
			if(DIFF_TEAM(self.realowner, other))
				if(other.deadflag == DEAD_NO)
					if(IsFlying(other))
						Send_Notification(NOTIF_ONE, self.realowner, MSG_ANNCE, ANNCE_ACHIEVEMENT_AIRSHOT);

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;
	RadiusDamage(self, self.owner, WEP_CVAR(flak, bomb_damage), WEP_CVAR(flak, bomb_edgedamage), WEP_CVAR(flak, bomb_radius),
				 world, world, WEP_CVAR(flak, bomb_force), self.projectiledeathtype, other);

	float i, c = WEP_CVAR(flak, bomb_count);
	w_shotorg = self.origin;

	float spread_up, spread_side;

	if(other.takedamage == DAMAGE_AIM && other.iscreature)
	{
		spread_side = 360;
		spread_up = 360;
	}
	else
	{
		spread_side = WEP_CVAR(flak, bomb_spread_side);
		spread_up = WEP_CVAR(flak, bomb_spread_up);
	}

	for(i = 0; i < c; ++i)
	{
		vector a = fixedvectoangles(dir);

		fixedmakevectors(a + '1 0 0' * crandom() * spread_up
						   + '0 1 0' * crandom() * spread_side);

		entity p = W_Flak_Projectile(self.realowner, false,
						  WEP_CVAR_SEC(flak, damage),
						  WEP_CVAR_SEC(flak, gravity),
						  WEP_CVAR_SEC(flak, lifetime),
						  WEP_CVAR_SEC(flak, speed),
						  WEP_CVAR_SEC(flak, speed_up),
						  WEP_CVAR_SEC(flak, bouncefactor),
						  WEP_FLAK.m_id | HITTYPE_SECONDARY | HITTYPE_BOUNCE);

		// do not hit the direct hit entity with shrapnel right away (causes very inconsistent behavior)
		p.owner = other;
	}

	remove (self);
}

void W_Flak_Bomb_Touch(void)
{
	PROJECTILE_TOUCH;
	self.use();
}

void W_Flak_Bomb_Damage(entity inflictor, entity attacker, float damage, int deathtype, vector hitloc, vector force)
{
	if(self.health <= 0)
		return;

	if(!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt

	self.health = self.health - damage;

	if(self.health <= 0)
		W_PrepareExplosionByDamage(attacker, self.use);
}

void W_Flak_Attack3(Weapon thiswep)
{
	if(!(self.items & IT_UNLIMITED_WEAPON_AMMO))
		self.ammo_rockets -= WEP_CVAR(flak, bomb_ammo);

	W_DecreaseAmmo(thiswep, self, WEP_CVAR_SEC(flak, ammo));

	W_SetupShot_ProjectileSize (self, '0 0 -3', '0 0 -3', false, 4, SND(FLAK_FIRE3), CH_WEAPON_A, WEP_CVAR(flak, bomb_damage));
	w_shotdir = v_forward;

	entity e = spawn();
	e.owner = e.realowner = self;
	e.classname = "flak_bomb";
	e.bot_dodge = true;
	e.bot_dodgerating = WEP_CVAR(flak, bomb_damage);
	e.movetype = MOVETYPE_BOUNCE;
	PROJECTILE_MAKETRIGGER(e);
	e.projectiledeathtype = WEP_FLAK.m_id | HITTYPE_SECONDARY;
	setsize(e, '0 0 -3', '0 0 -3');
	setorigin(e, w_shotorg);

	e.nextthink = time + WEP_CVAR(flak, bomb_lifetime);
	e.think = adaptor_think2use;
	e.use = W_Flak_Bomb_Explode;
	e.touch = W_Flak_Bomb_Touch;
	e.takedamage = DAMAGE_YES;
	e.health = WEP_CVAR(flak, bomb_health);
	e.damageforcescale = WEP_CVAR(flak, bomb_damageforcescale);
	e.event_damage = W_Flak_Bomb_Damage;
	W_SetupProjVelocity_Explicit(e, w_shotdir, v_up, WEP_CVAR(flak, bomb_speed), WEP_CVAR(flak, bomb_speed_up), 0, 0, false);

	e.angles = vectoangles(e.velocity);
	e.flags = FL_PROJECTILE;
	e.missile_flags = MIF_SPLASH | MIF_ARC | MIF_PROXY;

	CSQCProjectile(e, true, PROJECTILE_FLAK_BOMB, true);

	// common properties
	MUTATOR_CALLHOOK(EditProjectile, self, e);
}

		METHOD(Flak, wr_aim, void(entity thiswep))
		{
			if(random() < 0.35 && WEP_CVAR(flak, bomb) && self.ammo_rockets >= WEP_CVAR(flak, bomb_ammo))
				self.BUTTON_ATCK2 = bot_aim(WEP_CVAR(flak, bomb_speed), WEP_CVAR(flak, bomb_speed_up), WEP_CVAR(flak, bomb_lifetime), true);
			else
				self.BUTTON_ATCK = bot_aim(WEP_CVAR_PRI(flak, speed), WEP_CVAR_PRI(flak, speed_up), WEP_CVAR_PRI(flak, lifetime), true);
		}
		METHOD(Flak, wr_think, void(entity thiswep, entity actor, int slot, int fire))
		{
			if(fire & 1)
			if(weapon_prepareattack(thiswep, actor, slot, false, WEP_CVAR_PRI(flak, refire)))
			{
				W_Flak_Attack1(thiswep, true);
				weapon_thinkf(actor, slot, WFRAME_FIRE1, WEP_CVAR_PRI(flak, animtime), w_ready);
			}

			if(fire & 2)
			if(weapon_prepareattack(thiswep, actor, slot, true, WEP_CVAR_SEC(flak, refire)))
			{
				if(WEP_CVAR(flak, bomb))
					W_Flak_Attack3(thiswep);
				else
					W_Flak_Attack1(thiswep, false);
				weapon_thinkf(actor, slot, WFRAME_FIRE2, WEP_CVAR_SEC(flak, animtime), w_ready);
			}
		}
		METHOD(Flak, wr_init, void(entity thiswep))
		{
			FLAK_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP);
		}
		METHOD(Flak, wr_checkammo1, bool(entity thiswep))
		{
			bool ammo_amount = self.WEP_AMMO(FLAK) >= WEP_CVAR_PRI(flak, ammo);
			ammo_amount += self.(weapon_load[WEP_FLAK.m_id]) >= WEP_CVAR_PRI(flak, ammo);
			return ammo_amount;
		}
		METHOD(Flak, wr_checkammo2, bool(entity thiswep))
		{
			// can't use above logic here, as we have 2 ammo types - WEAPONTODO
			return self.ammo_shells >= WEP_CVAR_SEC(flak, ammo) && (!WEP_CVAR(flak, bomb) || self.ammo_rockets >= WEP_CVAR(flak, bomb_ammo));
		}
		METHOD(Flak, wr_config, void(entity thiswep))
		{
			FLAK_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS);
		}
		METHOD(Flak, wr_reload, void(entity thiswep))
		{
			W_Reload(self, min(WEP_CVAR_PRI(flak, ammo), WEP_CVAR_SEC(flak, ammo), WEP_CVAR(flak, bomb_ammo)), SND(RELOAD));
		}
		METHOD(Flak, wr_suicidemessage, int(entity thiswep))
		{
			return WEAPON_FLAK_SUICIDE;
		}
		METHOD(Flak, wr_killmessage, int(entity thiswep))
		{
			if((w_deathtype & HITTYPE_BOUNCE) || (w_deathtype & HITTYPE_SPLASH))
				return WEAPON_FLAK_MURDER_SPLASH;
			else
				return WEAPON_FLAK_MURDER_SPRAY;
		}

#endif
#ifdef CSQC
.float flak_last_bounce;
void Flak_Touch(void)
{
	if(time >= self.flak_last_bounce)
	{
		self.flak_last_bounce = time + 0.1; // spam
    	__pointparticles(particleeffectnum(EFFECT_FLAK_BOUNCE), self.move_origin, self.move_velocity, 1);
	}
}

REGISTER_MUTATOR(projectile_flak, true);

MUTATOR_HOOKFUNCTION(projectile_flak, Ent_Projectile)
{
	switch(self.cnt)
	{
		#define CASE(id) case PROJECTILE_##id: setmodel(self, MDL_PROJECTILE_##id);
		CASE(FLAK) self.traileffect = EFFECT_RIFLE_WEAK.m_id; return true;
		CASE(FLAK_BOMB) self.traileffect = EFFECT_TR_KNIGHTSPIKE.m_id; return true;
		#undef CASE
	}

	return false;
}

MUTATOR_HOOKFUNCTION(projectile_flak, EditProjectile)
{
	switch(self.cnt)
	{
		case PROJECTILE_FLAK_BOMB:
			self.mins = '-3 -3 -3';
			self.maxs = '3 3 3';
			break;
		case PROJECTILE_FLAK:
			self.mins = '-2 -2 -2';
			self.maxs = '2 2 2';
			self.move_movetype = MOVETYPE_BOUNCE;
			self.move_touch = Flak_Touch;
			break;
	}

	return false;
}

		METHOD(Flak, wr_impacteffect, void(entity thiswep))
		{
			vector org2;
			org2 = w_org + w_backoff * 12;
			__pointparticles(particleeffectnum(EFFECT_ROCKET_EXPLODE), org2, '0 0 0', 1);
			if(!w_issilent)
				sound(self, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTN_NORM);
		}

#endif
#endif
