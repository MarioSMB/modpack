#include "mayo.qh"

#ifdef SVQC
PRECACHE(Mayo)
{
	precache_sound("hknight/slash1.wav");
	precache_sound("weapons/jarsmash.wav");

	precache_model("progs/grenade_mayo.mdl");
	precache_model("progs/v_mayo.mdl");
	precache_model("progs/g_mayo.mdl");
	precache_model("progs/s_mayo.mdl");
}

void Mayo_PoolAnim(entity this);
void Mayo_PoolTouch(entity this, entity toucher);
void MayoExplode(entity this, bool dopool)
{
	T_RadiusDamage(this, this.owner, 50, this.projectiledeathtype, this.owner);

	_sound(this, CH_WEAPON_SINGLE, "weapons/jarsmash.wav", 1, ATTN_NORM);

	if(dopool)
	{
		vector vel_norm = normalize(this.velocity);
		vector vec = this.origin - vel_norm;
		traceline(vec, vec + vel_norm * 16, false, this);
		if(trace_fraction < 1)
		{
			te_explosion2(this.origin, 10, 10);
			set_movetype(this, MOVETYPE_NONE);
			this.solid = SOLID_TRIGGER;
			_setmodel(this, "progs/s_mayo.mdl");
			setsize(this, '-20 -20 0', '20 20 4');
			setorigin(this, trace_endpos);

			vec = trace_plane_normal;
			this.scale = 1.7;
			this.angles = vectoangles(vec);
			this.angles_x -= 90;
			settouch(this, Mayo_PoolTouch);
			this.frame = 0;
			this.nextthink = time + 4.1;
			setthink(this, Mayo_PoolAnim);
		}
	}
	else
	{
		te_explosion2(this.origin, 10, 10);
		delete(this);
	}
}

void MayoExplodeThink(entity this)
{
	MayoExplode(this, false);
}

void Mayo_PoolTouch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.solid == SOLID_TRIGGER || toucher.health < 1 || toucher.takedamage == DAMAGE_NO || toucher.charmed)
		return;
	if(toucher.m_champion == CHAMPION_Sorlag)
		return;
	if(IS_PLAYER(this.owner) && IS_PLAYER(toucher) && (autocvar_g_friendlyfire_virtual || autocvar_g_friendlyfire <= 0))
		return;

	float poisontime = 7;
	float curtime = StatusEffects_gettime(STATUSEFFECT_Poisoned, toucher);
	if((time + poisontime) > curtime)
		StatusEffects_apply(STATUSEFFECT_Poisoned, toucher, time + poisontime, 0);
}

void Mayo_PoolAnim(entity this)
{
	setthink(this, Mayo_PoolAnim);
	this.nextthink = time + 0.1;
	this.walkframe += 1;
	if(this.walkframe < 10)
		this.frame = this.walkframe;
	else
		delete(this);
}

void MayoTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owne
	bool dopool = false;
	if(toucher.takedamage)
		T_Damage(toucher, this, this.owner, 50, this.projectiledeathtype);
	else
		dopool = true;
	MayoExplode(this, dopool);
}

void W_FireMayo(entity this, .entity weaponentity)
{
	W_TakeAmmo(this, ammo_rockets, 1);
	
	_sound(this, CH_WEAPON_SINGLE, "hknight/slash1.wav", 1, ATTN_NORM);

	this.punchangle_x = -2;

	entity missile = new(grenade);
	missile.owner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;
	missile.projectiledeathtype = WEP_MAYO.m_id;
	missile.scale = 0.5;
// set missile speed	

	makevectors(this.v_angle);

	if(this.v_angle_x)
		missile.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		missile.velocity = qc_aim(this, 10000);
		missile.velocity = missile.velocity * 600;
		missile.velocity_z = 200;
	}

	missile.avelocity = '0 90 0';

	missile.angles = vectoangles(missile.velocity);

	settouch(missile, MayoTouch);
	
// set missile duration
	missile.nextthink = time + 2.5;
	setthink(missile, MayoExplodeThink);

	_setmodel(missile, "progs/grenade_mayo.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, W_Shotorg(this, weaponentity) + v_right * 12);
}

METHOD(Mayo, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_rocket1(actor);
		wep_generic_rocket1(actor.(weaponentity));
		W_FireMayo(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.7);
	}
}
METHOD(Mayo, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_rockets >= 1;
	return ammo_amount;
}
METHOD(Mayo, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
