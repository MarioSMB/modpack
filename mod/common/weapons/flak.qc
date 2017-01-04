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
Sound SND_FLAK_CASINGS_RANDOM() {
    return Sounds_from(SND_FLAK_CASINGS1.m_id + floor(prandom() * 3));
}

SOUND(FLAK_FIRE, W_Sound("flak_fire"));
SOUND(FLAK_FIRE2, W_Sound("flak_fire2"));
SOUND(FLAK_FIRE3, W_Sound("flak_fire3"));

CLASS(Flak, Weapon)
/* ammotype  */ ATTRIB(Flak, ammo_field, .int, ammo_shells);
/* impulse   */ ATTRIB(Flak, impulse, int,8);
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
/* wepname   */ ATTRIB(Flak, m_name, string, _("Flak Cannon"));

#define X(BEGIN, P, END, class, prefix) \
	BEGIN(class) \
		P(class, prefix, ammo, float, BOTH) \
		P(class, prefix, animtime, float, BOTH) \
		P(class, prefix, bouncefactor, float, BOTH) \
		P(class, prefix, count, float, BOTH) \
		P(class, prefix, damage, float, BOTH) \
		P(class, prefix, damage_bouncefactor, float, BOTH) \
		P(class, prefix, force, float, BOTH) \
		P(class, prefix, gravity, float, BOTH) \
		P(class, prefix, refire, float, BOTH) \
		P(class, prefix, speed, float, BOTH) \
		P(class, prefix, speed_up, float, BOTH) \
		P(class, prefix, spread_side, float, BOTH) \
		P(class, prefix, spread_up, float, BOTH) \
		P(class, prefix, passthrough, float, BOTH) \
		P(class, prefix, lifetime, float, BOTH) \
		P(class, prefix, bomb, float, NONE) \
		P(class, prefix, bomb_ammo, float, NONE) \
		P(class, prefix, bomb_count, float, NONE) \
		P(class, prefix, bomb_damage, float, NONE) \
		P(class, prefix, bomb_edgedamage, float, NONE) \
		P(class, prefix, bomb_damageforcescale, float, NONE) \
		P(class, prefix, bomb_force, float, NONE) \
		P(class, prefix, bomb_health, float, NONE) \
		P(class, prefix, bomb_lifetime, float, NONE) \
		P(class, prefix, bomb_radius, float, NONE) \
		P(class, prefix, bomb_speed, float, NONE) \
		P(class, prefix, bomb_speed_up, float, NONE) \
		P(class, prefix, bomb_speed_side, float, NONE) \
		P(class, prefix, bomb_spread_side, float, NONE) \
		P(class, prefix, bomb_spread_up, float, NONE) \
		P(class, prefix, reload_ammo, float, NONE) \
        P(class, prefix, reload_time, float, NONE) \
        P(class, prefix, switchdelay_raise, float, NONE) \
        P(class, prefix, switchdelay_drop, float, NONE) \
        P(class, prefix, weaponreplace, string, NONE) \
        P(class, prefix, weaponstart, float, NONE) \
        P(class, prefix, weaponstartoverride, float, NONE) \
        P(class, prefix, weaponthrowable, float, NONE) \
	END()
    W_PROPS(X, Flak, flak)
#undef X

ENDCLASS(Flak)
REGISTER_WEAPON(FLAK, flak, NEW(Flak));

const int PROJECTILE_FLAK = 45;
const int PROJECTILE_FLAK_BOMB = 46;

MSG_INFO_NOTIF(WEAPON_FLAK_MURDER_SPLASH,      1, 3, 2, "spree_inf s1 s2 s3loc spree_end", "s2 s1",  "weaponflak",   _("^BG%s%s^K1 took ^BG%s^K1's Flak%s%s"), "")
MSG_INFO_NOTIF(WEAPON_FLAK_MURDER_SPRAY,       1, 3, 2, "spree_inf s1 s2 s3loc spree_end", "s2 s1",  "weaponflak",   _("^BG%s%s^K1 was shredded by ^BG%s^K1's Flak Cannon%s%s"), "")
MSG_INFO_NOTIF(WEAPON_FLAK_SUICIDE,            1, 2, 1, "s1 s2loc spree_lost", "s1",                 "weaponflak",   _("^BG%s^K1 was shredded by their own Flak Cannon%s%s"), "")

MSG_MULTI_NOTIF(WEAPON_FLAK_MURDER_SPLASH,      1, NULL,        INFO_WEAPON_FLAK_MURDER_SPLASH,      NULL)
MSG_MULTI_NOTIF(WEAPON_FLAK_MURDER_SPRAY,       1, NULL,        INFO_WEAPON_FLAK_MURDER_SPRAY,       NULL)
MSG_MULTI_NOTIF(WEAPON_FLAK_SUICIDE,            1, NULL,        INFO_WEAPON_FLAK_SUICIDE,            CENTER_DEATH_SELF_GENERIC)

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

#endif
#ifdef IMPLEMENTATION
#ifdef SVQC
spawnfunc(weapon_flak) { weapon_defaultspawnfunc(this, WEP_FLAK); }

REGISTER_MUTATOR(flak_rockets, true);

MUTATOR_HOOKFUNCTION(flak_rockets, FilterItem)
{
	entity item = M_ARGV(0, entity);

	if(item.weapons & WEPSET(FLAK))
		item.ammo_rockets = cvar("g_pickup_rockets_weapon");
}

void W_Flak_Projectile_Touch(entity this, entity toucher)
{
	PROJECTILE_TOUCH(this, toucher);

	if(toucher.takedamage)
	{
		float damage, bnc, frc;
		bool isprimary = !(this.projectiledeathtype & HITTYPE_SECONDARY);

		if(toucher != this.enemy && (toucher != this.realowner || (this.projectiledeathtype & HITTYPE_BOUNCE)))
		{
			bnc = (WEP_CVAR_BOTH(flak, isprimary, damage_bouncefactor) ** this.cnt);
			damage = WEP_CVAR_BOTH(flak, isprimary, damage) * bnc;
			frc = WEP_CVAR_BOTH(flak, isprimary, force) * bnc;

			vector force = normalize(NearestPointOnBox(toucher, this.origin) - this.origin + this.velocity) * frc;

			this.owner = this.realowner;
			Damage(toucher, this, this.realowner, damage, this.projectiledeathtype, this.origin, force);

			if(accuracy_isgooddamage(this.realowner, toucher))
 				{ accuracy_add(this.realowner, WEP_FLAK.m_id, 0, damage); }
		}

		//Send_Effect(EFFECT_FLAK_BOUNCE, this.origin, this.velocity, 1);

		bool passThrough = WEP_CVAR_BOTH(flak, isprimary, passthrough);

		if(passThrough <= 0)
		{
			delete(this);
			return;
		}

		// semi-fix for "melee" hits
		if(toucher == this.realowner && !(this.projectiledeathtype & HITTYPE_BOUNCE))
			this.velocity = this.velocity * -1;

		// pass through - we don't want to bounce here, overwrite velocity later
		this.oldvelocity = this.velocity * passThrough;

		// we don't want to hit the same entity again right away
		this.owner = toucher;
		if(toucher.iscreature)
			this.enemy = toucher;
	}
	else if(toucher.solid == SOLID_BSP || !toucher)
	{
		if(toucher)
			spamsound(this, CH_SHOTS, SND(FLAK_CASINGS_RANDOM()), VOL_BASE * 0.7, ATTN_NORM);
		//pointparticles(particleeffectnum("flak_bounce"), this.origin, this.velocity, 1);
		this.owner = world;
		this.projectiledeathtype |= HITTYPE_BOUNCE;
		this.cnt += 1;
	}
}

void W_Flak_Projectile_Think(entity this)
{
	if(time > this.spawnshieldtime)
	{
		delete(this);
		return;
	}

	if(this.oldvelocity)
	{
		this.velocity = this.oldvelocity;
		this.oldvelocity = '0 0 0';
		UpdateCSQCProjectile(this);
	}

	this.nextthink = time;
}

entity W_Flak_Projectile(entity o, bool isprimary, float damage, float grav, float lt, float spd, float upspd, float bnc, int deathtype)
{
	entity e = new(flak_proj);
	e.owner = e.realowner = o;
	e.bot_dodge = true;
	e.bot_dodgerating = damage;
	IL_PUSH(g_bot_dodge, e);
	set_movetype(e, MOVETYPE_BOUNCE);
	PROJECTILE_MAKETRIGGER(e);
	e.projectiledeathtype = deathtype;
	e.gravity = grav;
	e.bouncefactor = bnc;
	setorigin(e, w_shotorg);
	setsize(e, '0 0 -3', '0 0 -3');

	e.spawnshieldtime = time + lt;
	e.nextthink = time;
	setthink(e, W_Flak_Projectile_Think);
	settouch(e, W_Flak_Projectile_Touch);
	W_SetupProjVelocity_Explicit(e, v_forward, v_up, spd, upspd, 0, 0, false);

	e.angles = vectoangles(e.velocity);
	e.flags = FL_PROJECTILE;
	IL_PUSH(g_projectiles, e);
	e.missile_flags = MIF_ARC;

	CSQCProjectile(e, true, PROJECTILE_FLAK, true);   

	// common properties
	MUTATOR_CALLHOOK(EditProjectile, o, e);
	return e;
}

void W_Flak_Attack1(Weapon thiswep, entity actor, .entity weaponentity, bool isprimary)
{
	float pcount = WEP_CVAR_BOTH(flak, isprimary, count), i;
	int dtype = (isprimary) ? WEP_FLAK.m_id : (WEP_FLAK.m_id | HITTYPE_SECONDARY | HITTYPE_BOUNCE);

	W_DecreaseAmmo(thiswep, actor, WEP_CVAR_BOTH(flak, isprimary, ammo), weaponentity);

	W_SetupShot_ProjectileSize(actor, weaponentity, '0 0 -3', '0 0 -3', false, 4, ((isprimary) ? SND_FLAK_FIRE2 : SND_FLAK_FIRE), CH_WEAPON_A, WEP_CVAR_BOTH(flak, isprimary, damage) * pcount);
	w_shotdir = v_forward;
	vector a;

	for(i = 0; i < pcount; ++i)
	{
		a = fixedvectoangles(w_shotdir);

		fixedmakevectors(a + '1 0 0' *  random() * WEP_CVAR_BOTH(flak, isprimary, spread_up) + '0 1 0' * crandom() * WEP_CVAR_BOTH(flak, isprimary, spread_side));

		W_Flak_Projectile(actor, isprimary,
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
	setthink(flash, SUB_Remove);
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(actor, weaponentity, flash, '5 0 0');
}

void W_Flak_Bomb_Explode(entity this, entity directhitentity)
{
	vector dir = normalize(this.velocity);
	dir = dir - 2 * (dir * trace_plane_normal) * trace_plane_normal; 

	if(directhitentity.takedamage == DAMAGE_AIM)
		if(IS_PLAYER(directhitentity))
			if(DIFF_TEAM(this.realowner, directhitentity))
				if(!IS_DEAD(directhitentity))
					if(IsFlying(directhitentity))
						Send_Notification(NOTIF_ONE, this.realowner, MSG_ANNCE, ANNCE_ACHIEVEMENT_AIRSHOT);

	this.event_damage = func_null;
	this.takedamage = DAMAGE_NO;
	RadiusDamage(this, this.owner, WEP_CVAR(flak, bomb_damage), WEP_CVAR(flak, bomb_edgedamage), WEP_CVAR(flak, bomb_radius),
				 world, world, WEP_CVAR(flak, bomb_force), this.projectiledeathtype, directhitentity);

	float i, c = WEP_CVAR(flak, bomb_count);
	w_shotorg = this.origin;

	float spread_up, spread_side;

	if(directhitentity.takedamage == DAMAGE_AIM && directhitentity.iscreature)
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

		entity p = W_Flak_Projectile(this.realowner, false,
						  WEP_CVAR_SEC(flak, damage),
						  WEP_CVAR_SEC(flak, gravity),
						  WEP_CVAR_SEC(flak, lifetime),
						  WEP_CVAR_SEC(flak, speed),
						  WEP_CVAR_SEC(flak, speed_up),
						  WEP_CVAR_SEC(flak, bouncefactor),
						  WEP_FLAK.m_id | HITTYPE_SECONDARY | HITTYPE_BOUNCE);

		// do not hit the direct hit entity with shrapnel right away (causes very inconsistent behavior)
		if(directhitentity)
			p.owner = directhitentity;
	}

	remove (this);
}

void W_Flak_Bomb_Explode_use(entity this, entity actor, entity trigger)
{
	W_Flak_Bomb_Explode(this, trigger);
}

void W_Flak_Bomb_Touch(entity this, entity toucher)
{
	PROJECTILE_TOUCH(this, toucher);
	this.use(this, NULL, toucher);
}

void W_Flak_Bomb_Damage(entity this, entity inflictor, entity attacker, float damage, int deathtype, vector hitloc, vector force)
{
	if(this.health <= 0)
		return;

	if(!W_CheckProjectileDamage(inflictor.realowner, this.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt

	this.health = this.health - damage;

	if(this.health <= 0)
		W_PrepareExplosionByDamage(this, attacker, adaptor_think2use);
}

void W_Flak_Attack3(Weapon thiswep, entity actor, .entity weaponentity)
{
	if(!(actor.items & IT_UNLIMITED_WEAPON_AMMO))
		actor.ammo_rockets -= WEP_CVAR(flak, bomb_ammo);

	W_DecreaseAmmo(thiswep, actor, WEP_CVAR_SEC(flak, ammo), weaponentity);

	W_SetupShot_ProjectileSize (actor, weaponentity, '-3 -3 -3', '3 3 3', false, 4, SND_FLAK_FIRE3, CH_WEAPON_A, WEP_CVAR(flak, bomb_damage));
	w_shotdir = v_forward;

	entity e = spawn();
	e.owner = e.realowner = actor;
	e.classname = "flak_bomb";
	e.bot_dodge = true;
	e.bot_dodgerating = WEP_CVAR(flak, bomb_damage);
	IL_PUSH(g_bot_dodge, e);
	set_movetype(e, MOVETYPE_BOUNCE);
	PROJECTILE_MAKETRIGGER(e);
	e.projectiledeathtype = WEP_FLAK.m_id | HITTYPE_SECONDARY;
	setsize(e, '-3 -3 -3', '3 3 3');
	setorigin(e, w_shotorg);

	e.nextthink = time + WEP_CVAR(flak, bomb_lifetime);
	setthink(e, adaptor_think2use);
	e.use = W_Flak_Bomb_Explode_use;
	settouch(e, W_Flak_Bomb_Touch);
	e.takedamage = DAMAGE_YES;
	e.health = WEP_CVAR(flak, bomb_health);
	e.damageforcescale = WEP_CVAR(flak, bomb_damageforcescale);
	e.event_damage = W_Flak_Bomb_Damage;
	W_SetupProjVelocity_Explicit(e, w_shotdir, v_up, WEP_CVAR(flak, bomb_speed), WEP_CVAR(flak, bomb_speed_up), 0, 0, false);

	e.angles = vectoangles(e.velocity);
	e.flags = FL_PROJECTILE;
	IL_PUSH(g_projectiles, e);
	e.missile_flags = MIF_SPLASH | MIF_ARC | MIF_PROXY;

	CSQCProjectile(e, true, PROJECTILE_FLAK_BOMB, true);

	// common properties
	MUTATOR_CALLHOOK(EditProjectile, actor, e);
}

		METHOD(Flak, wr_aim, void(entity thiswep, entity actor, .entity weaponentity))
		{
			if(random() < 0.35 && WEP_CVAR(flak, bomb) && actor.ammo_rockets >= WEP_CVAR(flak, bomb_ammo))
				PHYS_INPUT_BUTTON_ATCK2(actor) = bot_aim(actor, weaponentity, WEP_CVAR(flak, bomb_speed), WEP_CVAR(flak, bomb_speed_up), WEP_CVAR(flak, bomb_lifetime), true);
			else
				PHYS_INPUT_BUTTON_ATCK(actor) = bot_aim(actor, weaponentity, WEP_CVAR_PRI(flak, speed), WEP_CVAR_PRI(flak, speed_up), WEP_CVAR_PRI(flak, lifetime), true);
		}
		METHOD(Flak, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
		{
			if(fire & 1)
			if(weapon_prepareattack(thiswep, actor, weaponentity, false, WEP_CVAR_PRI(flak, refire)))
			{
				W_Flak_Attack1(thiswep, actor, weaponentity, true);
				weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, WEP_CVAR_PRI(flak, animtime), w_ready);
			}

			if(fire & 2)
			if(weapon_prepareattack(thiswep, actor, weaponentity, true, WEP_CVAR_SEC(flak, refire)))
			{
				if(WEP_CVAR(flak, bomb))
					W_Flak_Attack3(thiswep, actor, weaponentity);
				else
					W_Flak_Attack1(thiswep, actor, weaponentity, false);
				weapon_thinkf(actor, weaponentity, WFRAME_FIRE2, WEP_CVAR_SEC(flak, animtime), w_ready);
			}
		}
		METHOD(Flak, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
		{
			bool ammo_amount = actor.(thiswep.ammo_field) >= WEP_CVAR_PRI(flak, ammo);
			ammo_amount += actor.(weapon_load[WEP_FLAK.m_id]) >= WEP_CVAR_PRI(flak, ammo);
			return ammo_amount;
		}
		METHOD(Flak, wr_checkammo2, bool(entity thiswep, entity actor, .entity weaponentity))
		{
			// can't use above logic here, as we have 2 ammo types - WEAPONTODO
			return actor.ammo_shells >= WEP_CVAR_SEC(flak, ammo) && (!WEP_CVAR(flak, bomb) || actor.ammo_rockets >= WEP_CVAR(flak, bomb_ammo));
		}
		METHOD(Flak, wr_reload, void(entity thiswep, entity actor, .entity weaponentity))
		{
			W_Reload(actor, weaponentity, min(WEP_CVAR_PRI(flak, ammo), WEP_CVAR_SEC(flak, ammo), WEP_CVAR(flak, bomb_ammo)), SND_RELOAD);
		}
		METHOD(Flak, wr_suicidemessage, Notification(entity thiswep))
		{
			return WEAPON_FLAK_SUICIDE;
		}
		METHOD(Flak, wr_killmessage, Notification(entity thiswep))
		{
			if((w_deathtype & HITTYPE_BOUNCE) || (w_deathtype & HITTYPE_SPLASH))
				return WEAPON_FLAK_MURDER_SPLASH;
			else
				return WEAPON_FLAK_MURDER_SPRAY;
		}

#endif
#ifdef CSQC
.float flak_last_bounce;
void Flak_Touch(entity this, entity toucher)
{
	if(time >= this.flak_last_bounce)
	{
		this.flak_last_bounce = time + 0.1; // spam
    	__pointparticles(particleeffectnum(EFFECT_FLAK_BOUNCE), this.origin, this.velocity, 1);
	}
}

REGISTER_MUTATOR(projectile_flak, true);

MUTATOR_HOOKFUNCTION(projectile_flak, Ent_Projectile)
{
	entity proj = M_ARGV(0, entity);

	switch(proj.cnt)
	{
		#define HANDLE(id) case PROJECTILE_##id: setmodel(proj, MDL_PROJECTILE_##id);
		HANDLE(FLAK) proj.traileffect = EFFECT_RIFLE_WEAK.m_id; return true;
		HANDLE(FLAK_BOMB) proj.traileffect = EFFECT_TR_KNIGHTSPIKE.m_id; return true;
		#undef HANDLE
	}

	return false;
}

MUTATOR_HOOKFUNCTION(projectile_flak, EditProjectile)
{
	entity proj = M_ARGV(0, entity);

	switch(proj.cnt)
	{
		case PROJECTILE_FLAK_BOMB:
			proj.mins = '-3 -3 -3';
			proj.maxs = '3 3 3';
			break;
		case PROJECTILE_FLAK:
			proj.mins = '-2 -2 -2';
			proj.maxs = '2 2 2';
			set_movetype(proj, MOVETYPE_BOUNCE);
			settouch(proj, Flak_Touch);
			break;
	}
}

METHOD(Flak, wr_impacteffect, void(entity thiswep, entity actor))
{
	vector org2;
	org2 = w_org + w_backoff * 12;
	pointparticles(EFFECT_ROCKET_EXPLODE, org2, '0 0 0', 1);
	if(!w_issilent)
		sound(actor, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTN_NORM);
}

#endif
#endif
