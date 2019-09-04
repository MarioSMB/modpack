//FEATURE: New weapon: Flak Cannon, a UT-like weapon that fires a bunch of bouncing bullets

#include "flak.qh"

#ifdef SVQC
REGISTER_MUTATOR(flak_rockets, true);

MUTATOR_HOOKFUNCTION(flak_rockets, FilterItem)
{
	entity item = M_ARGV(0, entity);

	if(STAT(WEAPONS, item) & WEPSET(FLAK))
		SetResourceExplicit(item, RES_ROCKETS, cvar("g_pickup_rockets_weapon"));
}

void W_Flak_Projectile_Touch(entity this, entity toucher)
{
	PROJECTILE_TOUCH(this, toucher);

	if(toucher.takedamage)
	{
		bool isprimary = !(this.projectiledeathtype & HITTYPE_SECONDARY);

		if(toucher != this.enemy && (toucher != this.realowner || (this.projectiledeathtype & HITTYPE_BOUNCE)))
		{
			float bnc = (WEP_CVAR_BOTH(flak, isprimary, damage_bouncefactor) ** this.cnt);
			float damage = WEP_CVAR_BOTH(flak, isprimary, damage) * bnc;
			float frc = WEP_CVAR_BOTH(flak, isprimary, force) * bnc;

			vector force = normalize(NearestPointOnBox(toucher, this.origin) - this.origin + this.velocity) * frc;

			this.owner = this.realowner;
			Damage(toucher, this, this.realowner, damage, this.projectiledeathtype, this.weaponentity_fld, this.origin, force);

			if(accuracy_isgooddamage(this.realowner, toucher))
 				{ accuracy_add(this.realowner, WEP_FLAK, 0, damage); }
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
			spamsound(this, CH_SHOTS, SND_FLAK_CASINGS_RANDOM(), VOL_BASE * 0.7, ATTN_NORM);
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

entity W_Flak_Projectile(entity o, .entity weaponentity, bool isprimary, float damage, float grav, float lt, float spd, float upspd, float bnc, int deathtype)
{
	entity e = new(flak_proj);
	e.owner = e.realowner = o;
	e.bot_dodge = true;
	e.bot_dodgerating = damage;
	IL_PUSH(g_bot_dodge, e);
	set_movetype(e, MOVETYPE_BOUNCE);
	PROJECTILE_MAKETRIGGER(e);
	e.projectiledeathtype = deathtype;
	e.weaponentity_fld = weaponentity,
	e.gravity = grav;
	e.bouncefactor = bnc;
	setorigin(e, w_shotorg);
	setsize(e, '1 1 1', '1 1 1');

	e.spawnshieldtime = time + lt;
	e.nextthink = time;
	setthink(e, W_Flak_Projectile_Think);
	settouch(e, W_Flak_Projectile_Touch);
	W_SetupProjVelocity_Explicit(e, v_forward, v_up, spd, upspd, 0, 0, false);

	e.angles = vectoangles(e.velocity);
	e.flags = FL_PROJECTILE;
	IL_PUSH(g_projectiles, e);
	e.missile_flags = MIF_ARC;

	CSQCProjectile(e, true, ((isprimary) ? PROJECTILE_FLAK_PRIMARY : PROJECTILE_FLAK_SECONDARY), true);   

	// common properties
	MUTATOR_CALLHOOK(EditProjectile, o, e);
	return e;
}

void W_Flak_Attack1(Weapon thiswep, entity actor, .entity weaponentity, bool isprimary)
{
	int pcount = WEP_CVAR_BOTH(flak, isprimary, count);
	int dtype = (isprimary) ? WEP_FLAK.m_id : (WEP_FLAK.m_id | HITTYPE_SECONDARY | HITTYPE_BOUNCE);

	W_DecreaseAmmo(thiswep, actor, WEP_CVAR_BOTH(flak, isprimary, ammo), weaponentity);

	W_SetupShot_ProjectileSize(actor, weaponentity, '1 1 1', '1 1 1', false, 4, ((isprimary) ? SND_FLAK_FIRE2 : SND_FLAK_FIRE), CH_WEAPON_A, WEP_CVAR_BOTH(flak, isprimary, damage) * pcount, dtype);
	w_shotdir = v_forward;

	for(int i = 0; i < pcount; ++i)
	{
		vector a = fixedvectoangles(w_shotdir);

		fixedmakevectors(a + '1 0 0' *  random() * WEP_CVAR_BOTH(flak, isprimary, spread_up) + '0 1 0' * crandom() * WEP_CVAR_BOTH(flak, isprimary, spread_side));

		W_Flak_Projectile(actor, weaponentity, isprimary,
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
				 world, world, WEP_CVAR(flak, bomb_force), this.projectiledeathtype, this.weaponentity_fld, directhitentity);

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

		entity p = W_Flak_Projectile(this.realowner, this.weaponentity_fld, false,
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

	delete (this);
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

void W_Flak_Bomb_Damage(entity this, entity inflictor, entity attacker, float damage, int deathtype, .entity weaponentity, vector hitloc, vector force)
{
	if(GetResource(this, RES_HEALTH) <= 0)
		return;

	if(!W_CheckProjectileDamage(inflictor.realowner, this.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt

	TakeResource(this, RES_HEALTH, damage);

	if(GetResource(this, RES_HEALTH) <= 0)
		W_PrepareExplosionByDamage(this, attacker, adaptor_think2use);
}

void W_Flak_Attack3(Weapon thiswep, entity actor, .entity weaponentity)
{
	if(!(actor.items & IT_UNLIMITED_WEAPON_AMMO))
		TakeResource(actor, RES_ROCKETS, WEP_CVAR(flak, bomb_ammo));

	W_DecreaseAmmo(thiswep, actor, WEP_CVAR_SEC(flak, ammo), weaponentity);

	W_SetupShot_ProjectileSize (actor, weaponentity, '-3 -3 -3', '3 3 3', false, 4, SND_FLAK_FIRE3, CH_WEAPON_A, WEP_CVAR(flak, bomb_damage), WEP_FLAK.m_id | HITTYPE_SECONDARY);
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
	e.weaponentity_fld = weaponentity;
	setsize(e, '-3 -3 -3', '3 3 3');
	setorigin(e, w_shotorg);

	e.nextthink = time + WEP_CVAR(flak, bomb_lifetime);
	setthink(e, adaptor_think2use);
	e.use = W_Flak_Bomb_Explode_use;
	settouch(e, W_Flak_Bomb_Touch);
	e.takedamage = DAMAGE_YES;
	SetResourceExplicit(e, RES_HEALTH, WEP_CVAR(flak, bomb_health));
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
			if(random() < 0.35 && WEP_CVAR(flak, bomb) && GetResource(actor, RES_ROCKETS) >= WEP_CVAR(flak, bomb_ammo))
				PHYS_INPUT_BUTTON_ATCK2(actor) = bot_aim(actor, weaponentity, WEP_CVAR(flak, bomb_speed), WEP_CVAR(flak, bomb_speed_up), WEP_CVAR(flak, bomb_lifetime), true);
			else
				PHYS_INPUT_BUTTON_ATCK(actor) = bot_aim(actor, weaponentity, WEP_CVAR_PRI(flak, speed), WEP_CVAR_PRI(flak, speed_up), WEP_CVAR_PRI(flak, lifetime), true);
		}
		METHOD(Flak, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
		{
			if(WEP_CVAR(flak, reload_ammo) && actor.(weaponentity).clip_load < min(WEP_CVAR_PRI(flak, ammo), WEP_CVAR_SEC(flak, ammo), WEP_CVAR(flak, bomb_ammo))) // forced reload
				thiswep.wr_reload(thiswep, actor, weaponentity);
			else
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
		}
		METHOD(Flak, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
		{
			bool ammo_amount = GetResource(actor, thiswep.ammo_type) >= WEP_CVAR_PRI(flak, ammo);
			ammo_amount += actor.(weapon_load[WEP_FLAK.m_id]) >= WEP_CVAR_PRI(flak, ammo);
			return ammo_amount;
		}
		METHOD(Flak, wr_checkammo2, bool(entity thiswep, entity actor, .entity weaponentity))
		{
			// can't use above logic here, as we have 2 ammo types - WEAPONTODO
			return GetResource(actor, RES_SHELLS) >= WEP_CVAR_SEC(flak, ammo) && (!WEP_CVAR(flak, bomb) || GetResource(actor, RES_ROCKETS) >= WEP_CVAR(flak, bomb_ammo));
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
		this.flak_last_bounce = time + 0.3; // spam
    	pointparticles(EFFECT_FLAK_BOUNCE, this.origin, this.velocity, 1);
	}
}

REGISTER_MUTATOR(projectile_flak, true);

MUTATOR_HOOKFUNCTION(projectile_flak, Ent_Projectile)
{
	entity proj = M_ARGV(0, entity);

	switch(proj.cnt)
	{
		#define HANDLE(id) case PROJECTILE_##id: setmodel(proj, MDL_PROJECTILE_##id);
		HANDLE(FLAK_PRIMARY) proj.traileffect = EFFECT_FLAK_BULLET.m_id; return true;
		HANDLE(FLAK_SECONDARY) proj.traileffect = EFFECT_FLAK_BULLET.m_id; return true;
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
		case PROJECTILE_FLAK_PRIMARY:
		case PROJECTILE_FLAK_SECONDARY:
			bool isprimary = (proj.cnt == PROJECTILE_FLAK_PRIMARY);
			proj.mins = '-1 -1 -1';
			proj.maxs = '1 1 1';
			proj.bouncefactor = WEP_CVAR_BOTH(flak, isprimary, bouncefactor);
			proj.gravity = WEP_CVAR_BOTH(flak, isprimary, gravity);
			set_movetype(proj, MOVETYPE_BOUNCE);
			settouch(proj, Flak_Touch);
			break;
	}
}

METHOD(Flak, wr_impacteffect, void(entity thiswep, entity actor))
{
	vector org2;
	org2 = w_org + w_backoff * 12;
	pointparticles(EFFECT_GRENADE_EXPLODE, org2, '0 0 0', 1);
	if(!w_issilent)
		sound(actor, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTN_NORM);
}

#endif
