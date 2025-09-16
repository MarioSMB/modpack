#include "driller.qh"

#ifdef SVQC
PRECACHE(Crossbow)
{
	precache_model("progs/v_driller.mdl");
	//precache_model("progs/g_driller.mdl");

	precache_model("progs/s_drill_explode.spr");
	precache_model("progs/drill.mdl");

	precache_sound("weapons/drill_shot.wav");
	precache_sound("weapons/drill_loop.wav");
}

void s_drillexplode6(entity this) { set_anim(this, 5, SUB_Remove); }
void s_drillexplode5(entity this) { set_anim(this, 4, s_drillexplode6); }
void s_drillexplode4(entity this) { set_anim(this, 3, s_drillexplode5); }
void s_drillexplode3(entity this) { set_anim(this, 2, s_drillexplode4); }
void s_drillexplode2(entity this) { set_anim(this, 1, s_drillexplode3); }
void s_drillexplode1(entity this) { set_anim(this, 0, s_drillexplode2); }

void drill_explode(entity this)
{
	float mydmg = (this.dmg) ? this.dmg : 100;
	//float damg = mydmg + random() * (mydmg * 0.2);

	T_RadiusDamage(this, this.owner, mydmg * 1.2, this.projectiledeathtype, NULL);

	sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);

	this.origin = this.origin - 8 * normalize(this.velocity);

	Send_Effect(EFFECT_TE_PLASMABIG, this.origin, '0 0 0', 1);

	entity newmis = spawn();
	set_movetype(newmis, MOVETYPE_NONE);
	newmis.solid = SOLID_NOT;
	_setmodel(newmis, "progs/s_drill_explode.spr");
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, findbetterlocation(this.origin, 8));
	s_drillexplode1(newmis);

	delete(this);
}

void drill_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
// hit something that bleeds
	if(toucher && toucher.solid != SOLID_BSP) // yoder mod, jan 05 2021
	{
		// handled by hack
	}
	else
	{
		drill_explode(this);
		return;
	}

	//delete(this);
}

.float drill_dmgtime;
void drill_think(entity this)
{
	if(time > this.count)
	{
		delete(this);
		return;
	}

	// hack to ensure the projectile keeps going even if it hits a target
	this.nextthink = time;
	float myspeed = (time <= this.drill_dmgtime) ? 20 : this.speed;
	this.velocity = this.pos2 * myspeed;

	if(time <= this.drill_dmgtime)
		return; // cooldown to prevent damage spam

	FOREACH_ENTITY_RADIUS(this.origin, this.cnt, it.takedamage && it != this.owner,
	{
		if(it.clipgroup && it.clipgroup == this.clipgroup)
			continue;
		float damg = ((this.dmg) ? this.dmg : 30);
		if(it.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD)
			damg = 120;
		spawn_touchblood(this, damg, it);
		T_Damage(it, this, this.owner, damg, this.projectiledeathtype);

		this.drill_dmgtime = time + 0.1; // prevent instant death

		Send_Effect(EFFECT_DRILL_TOUCH, this.origin, this.pos2 * -400, 1);
		_sound(this, CH_WEAPON_SINGLE, "weapons/drill_loop.wav", 0.8, ATTN_NORM);
	});
}

void W_FireDriller(entity this, .entity weaponentity)
{
	W_TakeAmmo(this, ammo_drills, 1);
	
	_sound(this, CH_WEAPON_SINGLE, "weapons/drill_shot.wav", 1, ATTN_NORM);

	this.punchangle_x = -2;

	makevectors(this.v_angle);

	vector dir = qc_aim(this, 1000);
	// NOTE: position fix by Seven and Sajt applied here
	entity missile = launch_spike(this, W_Shotorg(this, weaponentity) + v_up * -4, dir);
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_TRIGGER;
	missile.dphitcontentsmask = DPCONTENTS_SOLID;
	missile.speed = 1000;
	missile.pos2 = dir;
	missile.count = time + 6;
	missile.cnt = 32;
	settouch(missile, drill_touch);
	missile.dmg = 35;
	missile.classname = "drill";
	missile.projectiledeathtype = WEP_DRILLER.m_id;
	_setmodel(missile, "progs/drill.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	missile.modelflags = MF_TRACER;

	setthink(missile, drill_think);
	missile.nextthink = time;

	this.punchangle_x = -2;
}

METHOD(Driller, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_rocket1(actor);
		wep_generic_rocket1(actor.(weaponentity));
		W_FireDriller(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 1);
	}
}
METHOD(Driller, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_drills >= 1;
	return ammo_amount;
}
METHOD(Driller, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Driller, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
