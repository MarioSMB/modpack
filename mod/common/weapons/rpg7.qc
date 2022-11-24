//FEATURE: New weapon: RPG-7, for when a regular rocket launcher isn't enough

#include "rpg7.qh"

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

	float damg = WEP_CVAR(rpg7, damage);
	if(IS_VEHICLE(directhitentity))
		damg *= 3;

	.entity weaponentity = this.weaponentity_fld;
	RadiusDamage(
		this,
		this.realowner,
		damg,
		WEP_CVAR(rpg7, edgedamage),
		WEP_CVAR(rpg7, radius),
		NULL,
		NULL,
		WEP_CVAR(rpg7, force),
		this.projectiledeathtype,
		weaponentity,
		directhitentity
	);

	Weapon thiswep = WEP_RPG;
	if(this.realowner.(weaponentity).m_weapon == thiswep)
	{
		if(GetResource(this.realowner, thiswep.ammo_type) < WEP_CVAR(rpg7, ammo))
		if(!(this.realowner.items & IT_UNLIMITED_AMMO))
		{
			this.realowner.cnt = WEP_RPG.m_id;
			ATTACK_FINISHED(this.realowner, weaponentity) = time;
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
	vector forward, right, up;
	MAKE_VECTORS(this.angles.x * '-1 0 0 ' + this.angles.y * '0 1 0', forward, right, up);
	float velspeed = WEP_CVAR(rpg7, speed) * W_WeaponSpeedFactor(this.realowner) - (this.velocity * forward);
	if(velspeed > 0)
		this.velocity = this.velocity + forward * min(WEP_CVAR(rpg7, speedaccel) * W_WeaponSpeedFactor(this.realowner) * frametime, velspeed);

	if(this.csqcprojectile_clientanimate == 0)
		UpdateCSQCProjectile(this);
}

void W_RPG7_Touch(entity this, entity toucher)
{
	PROJECTILE_TOUCH(this, toucher);

	W_RPG7_Explode(this, toucher);
}

void W_RPG7_Damage(entity this, entity inflictor, entity attacker, float damage, int deathtype, .entity weaponentity, vector hitloc, vector force)
{
	if(GetResource(this, RES_HEALTH) <= 0)
		return;

	if(!W_CheckProjectileDamage(inflictor.realowner, this.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt

	TakeResource(this, RES_HEALTH, damage);
	this.angles = vectoangles(this.velocity);

	if(GetResource(this, RES_HEALTH) <= 0)
		W_PrepareExplosionByDamage(this, attacker, W_RPG7_Explode_think);
}

void W_RPG7_Attack(Weapon thiswep, entity actor, .entity weaponentity)
{
	W_DecreaseAmmo(thiswep, actor, WEP_CVAR(rpg7, ammo), weaponentity);

	W_SetupShot_ProjectileSize(actor, weaponentity, '-3 -3 -3', '3 3 3', false, 5, SND_RPG_FIRE, CH_WEAPON_A, WEP_CVAR(rpg7, damage), WEP_RPG.m_id);
	W_MuzzleFlash(thiswep, actor, weaponentity, w_shotorg, w_shotdir);

	entity missile = WarpZone_RefSys_SpawnSameRefSys(actor);
	missile.weaponentity_fld = weaponentity;
	missile.owner = missile.realowner = actor;
	missile.classname = "rpg";
	missile.bot_dodge = true;
	missile.bot_dodgerating = WEP_CVAR(rpg7, damage);

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = WEP_CVAR(rpg7, damageforcescale);
	SetResourceExplicit(missile, RES_HEALTH, WEP_CVAR(rpg7, health));
	missile.event_damage = W_RPG7_Damage;
	missile.damagedbycontents = true;
	IL_PUSH(g_damagedbycontents, missile);

	set_movetype(missile, MOVETYPE_FLY);
	PROJECTILE_MAKETRIGGER(missile);
	missile.projectiledeathtype = WEP_RPG.m_id;
	setsize(missile, '-3 -3 -3', '3 3 3'); // give it some size so it can be shot

	setorigin(missile, w_shotorg - v_forward * 3); // move it back so it hits the wall at the right point
	W_SetupProjVelocity_Basic(missile, WEP_CVAR(rpg7, speedstart), 0);
	missile.angles = vectoangles(missile.velocity);

	settouch(missile, W_RPG7_Touch);
	setthink(missile, W_RPG7_Think);
	missile.nextthink = time;
	missile.cnt = time + WEP_CVAR(rpg7, lifetime);
	missile.flags = FL_PROJECTILE;
	IL_PUSH(g_projectiles, missile);
	IL_PUSH(g_bot_dodge, missile);
	missile.missile_flags = MIF_SPLASH;

	CSQCProjectile(missile, WEP_CVAR(rpg7, speedaccel) == 0, PROJECTILE_RPG, false); // because of fly sound

	// common properties
	MUTATOR_CALLHOOK(EditProjectile, actor, missile);
}

METHOD(RPG7, wr_aim, void(entity thiswep, entity actor, .entity weaponentity))
{
    // aim and decide to fire if appropriate
    PHYS_INPUT_BUTTON_ATCK(actor) = bot_aim(actor, weaponentity, WEP_CVAR(rpg7, speed), 0, WEP_CVAR(rpg7, lifetime), false, true);
}

METHOD(RPG7, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
    if(WEP_CVAR(rpg7, reload_ammo) && actor.(weaponentity).clip_load < WEP_CVAR(rpg7, ammo)) { // forced reload
        thiswep.wr_reload(thiswep, actor, weaponentity);
    } else {
    	actor.(weaponentity).tuba_instrument = 0; // full
        actor.(weaponentity).weaponname = "rpg7";
        if(fire & 1)
        {
            if(weapon_prepareattack(thiswep, actor, weaponentity, false, WEP_CVAR(rpg7, refire)))
            {
                W_RPG7_Attack(thiswep, actor, weaponentity);
                weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, WEP_CVAR(rpg7, animtime), w_ready);

                actor.(weaponentity).tuba_instrument = 1; // empty
                actor.(weaponentity).weaponname = "rpg7_empty";
            }
        }
    }
}
METHOD(RPG7, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
    float ammo_amount = GetResource(actor, thiswep.ammo_type) >= WEP_CVAR(rpg7, ammo);
    ammo_amount += actor.(weaponentity).(weapon_load[WEP_RPG.m_id]) >= WEP_CVAR(rpg7, ammo);
    return ammo_amount;
}
METHOD(RPG7, wr_checkammo2, bool(entity thiswep, entity actor, .entity weaponentity))
{
    return false;
}
METHOD(RPG7, wr_reload, void(entity thiswep, entity actor, .entity weaponentity))
{
    W_Reload(actor, weaponentity, WEP_CVAR(rpg7, ammo), SND_RELOAD);
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
	if(WEP_CVAR(rpg7, reload_ammo) && actor.(weaponentity).clip_load < WEP_CVAR(rpg7, ammo))
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
