#include "rpg.qh"
#ifndef IMPLEMENTATION
AUTOCVAR(g_balance_rpg_ammo, float, 5, "");
AUTOCVAR(g_balance_rpg_animtime, float, 0.75, "");
AUTOCVAR(g_balance_rpg_damage, float, 80, "");
AUTOCVAR(g_balance_rpg_damageforcescale, float, 1, "");
AUTOCVAR(g_balance_rpg_edgedamage, float, 40, "");
AUTOCVAR(g_balance_rpg_force, float, 350, "");
AUTOCVAR(g_balance_rpg_health, float, 30, "");
AUTOCVAR(g_balance_rpg_lifetime, float, 10, "");
AUTOCVAR(g_balance_rpg_radius, float, 350, "");
AUTOCVAR(g_balance_rpg_refire, float, 1.1, "");
AUTOCVAR(g_balance_rpg_reload_ammo, float, 5, "");
AUTOCVAR(g_balance_rpg_reload_time, float, 2, "");
AUTOCVAR(g_balance_rpg_speed, float, 2000, "");
AUTOCVAR(g_balance_rpg_speedaccel, float, 2000, "");
AUTOCVAR(g_balance_rpg_speedstart, float, 1600, "");
AUTOCVAR(g_balance_rpg_switchdelay_drop, float, 0.2, "");
AUTOCVAR(g_balance_rpg_switchdelay_raise, float, 0.2, "");
AUTOCVAR(g_balance_rpg_weaponreplace, string, "", "");
AUTOCVAR(g_balance_rpg_weaponstart, float, 0, "");
AUTOCVAR(g_balance_rpg_weaponstartoverride, float, -1, "");
AUTOCVAR(g_balance_rpg_weaponthrowable, float, 1, "");

CLASS(RPG7, Weapon)
/* spawnfunc */ ATTRIB(RPG7, m_canonical_spawnfunc, string, "weapon_rpg7");
/* ammotype  */ ATTRIB(RPG7, ammo_type, int, RESOURCE_ROCKETS);
/* impulse   */ ATTRIB(RPG7, impulse, int, 9);
/* flags     */ ATTRIB(RPG7, spawnflags, int, WEP_FLAG_RELOADABLE | WEP_FLAG_CANCLIMB | WEP_TYPE_SPLASH | WEP_FLAG_NODUAL);
/* rating    */ ATTRIB(RPG7, bot_pickupbasevalue, float, 8000);
/* color     */ ATTRIB(RPG7, wpcolor, vector, '0.6 0.8 0.7');
/* modelname */ ATTRIB(RPG7, mdl, string, "rpg7");
#ifdef GAMEQC
/* model     */ ATTRIB(RPG7, m_model, Model, MDL_RPG_ITEM);
#endif
/* crosshair */ ATTRIB(RPG7, w_crosshair, string, "gfx/crosshair65");
/* crosshair */ ATTRIB(RPG7, w_crosshair_size, float, 0.7);
/* wepimg    */ ATTRIB(RPG7, model2, string, "weaponrpg");
/* refname   */ ATTRIB(RPG7, netname, string, "rpg7");
/* wepname   */ ATTRIB(RPG7, m_name, string, _("RPG-7"));

#define X(BEGIN, P, END, class, prefix) \
	BEGIN(class) \
		P(class, prefix, ammo, float, NONE) \
        P(class, prefix, animtime, float, NONE) \
        P(class, prefix, damageforcescale, float, NONE) \
        P(class, prefix, damage, float, NONE) \
        P(class, prefix, edgedamage, float, NONE) \
        P(class, prefix, force, float, NONE) \
        P(class, prefix, health, float, NONE) \
        P(class, prefix, lifetime, float, NONE) \
        P(class, prefix, radius, float, NONE) \
        P(class, prefix, refire, float, NONE) \
		P(class, prefix, reload_ammo, float, NONE) \
		P(class, prefix, reload_time, float, NONE) \
        P(class, prefix, speedaccel, float, NONE) \
        P(class, prefix, speedstart, float, NONE) \
        P(class, prefix, speed, float, NONE) \
		P(class, prefix, switchdelay_drop, float, NONE) \
		P(class, prefix, switchdelay_raise, float, NONE) \
		P(class, prefix, weaponreplace, string,NONE) \
		P(class, prefix, weaponstartoverride, float, NONE) \
		P(class, prefix, weaponstart, float, NONE) \
		P(class, prefix, weaponthrowable, float, NONE) \
	END()
	W_MOD_PROPS(X, RPG7, rpg)
#undef X

ENDCLASS(RPG7)
REGISTER_WEAPON(RPG, rpg, NEW(RPG7));

SPAWNFUNC_WEAPON(weapon_rpg7, WEP_RPG)

MSG_INFO_NOTIF(WEAPON_RPG_MURDER_DIRECT,         1,  3, 2, "spree_inf s1 s2 s3loc spree_end", "s2 s1",       "weaponrpg",     _("^BG%s%s^K1 was instagibbed by ^BG%s^K1's RPG%s%s"), "")
MSG_INFO_NOTIF(WEAPON_RPG_MURDER_SPLASH,         1,  3, 2, "spree_inf s1 s2 s3loc spree_end", "s2 s1",       "weaponrpg",     _("^BG%s%s^K1 was blown up by ^BG%s^K1's RPG%s%s"), "")
MSG_INFO_NOTIF(WEAPON_RPG_SUICIDE,               1,  2, 1, "s1 s2loc spree_lost", "s1",                      "weaponrpg",     _("^BG%s^K1 blew themself up with their RPG-7%s%s"), "")

MSG_MULTI_NOTIF(WEAPON_RPG_MURDER_DIRECT,    	 1,  NULL,           INFO_WEAPON_RPG_MURDER_DIRECT,   NULL)
MSG_MULTI_NOTIF(WEAPON_RPG_MURDER_SPLASH,    	 1,  NULL,           INFO_WEAPON_RPG_MURDER_SPLASH,   NULL)
MSG_MULTI_NOTIF(WEAPON_RPG_SUICIDE,          	 1,  NULL,           INFO_WEAPON_RPG_SUICIDE,         CENTER_DEATH_SELF_GENERIC)

#endif
#ifdef IMPLEMENTATION
#ifdef SVQC

void W_RPG7_Explode(entity this, entity directhitentity)
{
	if(directhitentity.takedamage == DAMAGE_AIM)
		if(IS_PLAYER(directhitentity))
			if(DIFF_TEAM(this.realowner, directhitentity))
				if(!IS_DEAD(directhitentity))
					if(IsFlying(directhitentity))
						Send_Notification(NOTIF_ONE, this.realowner, MSG_ANNCE, ANNCE_ACHIEVEMENT_AIRSHOT);

	this.event_damage = func_null;
	this.takedamage = DAMAGE_NO;

	float damg = WEP_CVAR(rpg, damage);
	if(IS_VEHICLE(directhitentity))
		damg *= 3;

	RadiusDamage(
		this,
		this.realowner,
		damg,
		WEP_CVAR(rpg, edgedamage),
		WEP_CVAR(rpg, radius),
		NULL,
		NULL,
		WEP_CVAR(rpg, force),
		this.projectiledeathtype,
		directhitentity
	);

	Weapon thiswep = WEP_RPG;
	.entity weaponentity = this.weaponentity_fld;
	if(this.realowner.(weaponentity).m_weapon == thiswep)
	{
		if(GetResourceAmount(this.realowner, thiswep.ammo_type) < WEP_CVAR(rpg, ammo))
		if(!(this.realowner.items & IT_UNLIMITED_WEAPON_AMMO))
		{
			this.realowner.cnt = WEP_RPG.m_id;
			int slot = weaponslot(weaponentity);
			ATTACK_FINISHED(this.realowner, slot) = time;
			this.realowner.(weaponentity).m_switchweapon = w_getbestweapon(this.realowner, weaponentity);
		}
	}
	delete(this);
}

void W_RPG7_Explode_think(entity this)
{
	W_RPG7_Explode(this, NULL);
}

void W_RPG7_Think(entity this)
{
	this.nextthink = time;
	if(time > this.cnt)
	{
		this.projectiledeathtype |= HITTYPE_BOUNCE;
		W_RPG7_Explode(this, NULL);
		return;
	}

	// accelerate
	makevectors(this.angles.x * '-1 0 0' + this.angles.y * '0 1 0');
	float velspeed = WEP_CVAR(rpg, speed) * W_WeaponSpeedFactor(this.realowner) - (this.velocity * v_forward);
	if(velspeed > 0)
		this.velocity = this.velocity + v_forward * min(WEP_CVAR(rpg, speedaccel) * W_WeaponSpeedFactor(this.realowner) * frametime, velspeed);

	if(this.csqcprojectile_clientanimate == 0)
		UpdateCSQCProjectile(this);
}

void W_RPG7_Touch(entity this, entity toucher)
{
	PROJECTILE_TOUCH(this, toucher);

	W_RPG7_Explode(this, toucher);
}

void W_RPG7_Damage(entity this, entity inflictor, entity attacker, float damage, int deathtype, vector hitloc, vector force)
{
	if(this.health <= 0)
		return;

	if(!W_CheckProjectileDamage(inflictor.realowner, this.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt

	this.health = this.health - damage;
	this.angles = vectoangles(this.velocity);

	if(this.health <= 0)
		W_PrepareExplosionByDamage(this, attacker, W_RPG7_Explode_think);
}

void W_RPG7_Attack(Weapon thiswep, entity actor, .entity weaponentity)
{
	W_DecreaseAmmo(thiswep, actor, WEP_CVAR(rpg, ammo), weaponentity);

	W_SetupShot_ProjectileSize(actor, weaponentity, '-3 -3 -3', '3 3 3', false, 5, SND_RPG_FIRE, CH_WEAPON_A, WEP_CVAR(rpg, damage));
	Send_Effect(EFFECT_ROCKET_MUZZLEFLASH, w_shotorg, w_shotdir * 1000, 1);

	entity missile = WarpZone_RefSys_SpawnSameRefSys(actor);
	missile.weaponentity_fld = weaponentity;
	missile.owner = missile.realowner = actor;
	missile.classname = "rpg";
	missile.bot_dodge = true;
	missile.bot_dodgerating = WEP_CVAR(rpg, damage);

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = WEP_CVAR(rpg, damageforcescale);
	missile.health = WEP_CVAR(rpg, health);
	missile.event_damage = W_RPG7_Damage;
	missile.damagedbycontents = true;
	IL_PUSH(g_damagedbycontents, missile);

	set_movetype(missile, MOVETYPE_FLY);
	PROJECTILE_MAKETRIGGER(missile);
	missile.projectiledeathtype = WEP_RPG.m_id;
	setsize(missile, '-3 -3 -3', '3 3 3'); // give it some size so it can be shot

	setorigin(missile, w_shotorg - v_forward * 3); // move it back so it hits the wall at the right point
	W_SetupProjVelocity_Basic(missile, WEP_CVAR(rpg, speedstart), 0);
	missile.angles = vectoangles(missile.velocity);

	settouch(missile, W_RPG7_Touch);
	setthink(missile, W_RPG7_Think);
	missile.nextthink = time;
	missile.cnt = time + WEP_CVAR(rpg, lifetime);
	missile.flags = FL_PROJECTILE;
	IL_PUSH(g_projectiles, missile);
	IL_PUSH(g_bot_dodge, missile);
	missile.missile_flags = MIF_SPLASH;

	CSQCProjectile(missile, WEP_CVAR(rpg, speedaccel) == 0, PROJECTILE_RPG, false); // because of fly sound

	// muzzle flash for 1st person view
	entity flash = spawn();
	setmodel(flash, MDL_RPG_MUZZLEFLASH); // precision set below
	SUB_SetFade(flash, time, 0.1);
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(actor, weaponentity, flash, '5 0 0');

	// common properties
	MUTATOR_CALLHOOK(EditProjectile, actor, missile);
}

METHOD(RPG7, wr_aim, void(entity thiswep, entity actor, .entity weaponentity))
{
    // aim and decide to fire if appropriate
    PHYS_INPUT_BUTTON_ATCK(actor) = bot_aim(actor, weaponentity, WEP_CVAR(rpg, speed), 0, WEP_CVAR(rpg, lifetime), false);
}

METHOD(RPG7, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
    if(WEP_CVAR(rpg, reload_ammo) && actor.(weaponentity).clip_load < WEP_CVAR(rpg, ammo)) { // forced reload
        thiswep.wr_reload(thiswep, actor, weaponentity);
    } else {
    	actor.(weaponentity).tuba_instrument = 0; // full
        actor.(weaponentity).weaponname = "rpg7";
        if(fire & 1)
        {
            if(weapon_prepareattack(thiswep, actor, weaponentity, false, WEP_CVAR(rpg, refire)))
            {
                W_RPG7_Attack(thiswep, actor, weaponentity);
                weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, WEP_CVAR(rpg, animtime), w_ready);

                actor.(weaponentity).tuba_instrument = 1; // empty
                actor.(weaponentity).weaponname = "rpg7_empty";
            }
        }
    }
}
METHOD(RPG7, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
    float ammo_amount = GetResourceAmount(actor, thiswep.ammo_type) >= WEP_CVAR(rpg, ammo);
    ammo_amount += actor.(weaponentity).(weapon_load[WEP_RPG.m_id]) >= WEP_CVAR(rpg, ammo);
    return ammo_amount;
}
METHOD(RPG7, wr_checkammo2, bool(entity thiswep, entity actor, .entity weaponentity))
{
    return false;
}
METHOD(RPG7, wr_reload, void(entity thiswep, entity actor, .entity weaponentity))
{
    W_Reload(actor, weaponentity, WEP_CVAR(rpg, ammo), SND_RELOAD);
}
METHOD(RPG7, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_RPG_SUICIDE;
}
METHOD(RPG7, wr_killmessage, Notification(entity thiswep))
{
    if((w_deathtype & HITTYPE_BOUNCE) || (w_deathtype & HITTYPE_SPLASH))
        return WEAPON_RPG_MURDER_SPLASH;
    else
        return WEAPON_RPG_MURDER_DIRECT;
}
METHOD(RPG7, wr_pickup, void(entity thiswep, entity actor, .entity weaponentity))
{
	if(WEP_CVAR(rpg, reload_ammo) && actor.(weaponentity).clip_load < WEP_CVAR(rpg, ammo))
	{
		actor.(weaponentity).tuba_instrument = 1; // empty
        actor.(weaponentity).weaponname = "rpg7_empty";
	}
	else
	{
		actor.(weaponentity).tuba_instrument = 0; // full
        actor.(weaponentity).weaponname = "rpg7";
	}
}

#endif
#ifdef CSQC

METHOD(RPG7, wr_impacteffect, void(entity thiswep, entity actor))
{
    vector org2;
    org2 = w_org + w_backoff * 12;
    pointparticles(EFFECT_EXPLOSION_MEDIUM, org2, '0 0 0', 1);
    if(!w_issilent)
        sound(actor, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTN_NORM);
}

METHOD(RPG7, wr_viewmodel, string(RPG7 this, entity wep))
{
	return (wep.tuba_instrument) ? "rpg7_empty" : "rpg7";
}


REGISTER_MUTATOR(cl_rpg, true);

MODEL(PROJECTILE_RPG, "models/rocket.md3");

MUTATOR_HOOKFUNCTION(cl_rpg, Ent_Projectile)
{
	entity proj = M_ARGV(0, entity);

	if(proj.cnt == PROJECTILE_RPG)
	{
		setmodel(proj, MDL_PROJECTILE_RPG);
		proj.traileffect = EFFECT_TR_ROCKET.m_id;
		proj.scale = 2;
		return true;
	}
}

MUTATOR_HOOKFUNCTION(cl_rpg, EditProjectile)
{
	entity proj = M_ARGV(0, entity);

	if(proj.cnt == PROJECTILE_RPG)
	{
		loopsound(proj, CH_SHOTS_SINGLE, SND_ROCKET_FLY, VOL_BASE, ATTEN_NORM);
		proj.mins = '-3 -3 -3';
		proj.maxs = '3 3 3';
	}
}

#endif
#endif
