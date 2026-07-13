#include "kangaroo.qh"

#ifdef SVQC

void roo_stand1(entity this);
void roo_run1(entity this);
void roo_stand(entity this);
void roo_run(entity this, float dist);

float MoveToAngle(float s_angle, float e_angle, float rate)
{
	float result = 0;
	if(s_angle > e_angle && s_angle - e_angle > 180)
		e_angle += 360;
	else if(e_angle > s_angle && e_angle - s_angle > 180)
		s_angle += 360;
	if(s_angle > e_angle)
	{
		result = s_angle - rate * frametime;
		if(result < e_angle)
			result = e_angle;
	}
	else
	{
		result = s_angle + rate * frametime;
		if(result > e_angle)
			result = e_angle;
	}
	if(result >= 360)
		result -= 360;
	if(result < 0)
		result += 360;
	return result;
}

void roo_stand5(entity this) { set_anim(this, 5, roo_stand1); }
void roo_stand4(entity this) { set_anim(this, 4, roo_stand5); }
void roo_stand3(entity this) { set_anim(this, 3, roo_stand4); }
void roo_stand2(entity this) { set_anim(this, 2, roo_stand3); }
void roo_stand1(entity this) { set_anim(this, 1, roo_stand2); roo_stand(this); }

void roo_hurt5(entity this) { set_anim(this, 1, roo_run1); }
void roo_hurt4(entity this) { set_anim(this, 1, roo_hurt5); }
void roo_hurt3(entity this) { set_anim(this, 1, roo_hurt4); }
void roo_hurt2(entity this) { set_anim(this, 1, roo_hurt3); }
void roo_hurt1(entity this) { set_anim(this, 1, roo_hurt2); }

void roo_run10(entity this)
{
	set_anim(this, 14, roo_run1);
	roo_run(this, 16);
	if(vdist(this.enemy.origin - this.origin, <, 128))
		this.angles_y = MoveToAngle(this.angles_y, this.angles_y + ((random() < 0.5) * 2 - 1) * 40, 1000);
	else
		this.angles_y = MoveToAngle(this.angles_y, this.angles_y + random() * 40 - 20, 1000);
	//if(vdist(this.origin - this.enemy.origin, >, 384))
		//setthink(this, roo_stand1);
}
void roo_run9(entity this) { set_anim(this, 13, roo_run10); roo_run(this, 18); }
void roo_run8(entity this) { set_anim(this, 12, roo_run9); roo_run(this, 22); }
void roo_run7(entity this) { set_anim(this, 12, roo_run8); roo_run(this, 26); }
void roo_run6(entity this) { set_anim(this, 11, roo_run7); roo_run(this, 26); }
void roo_run5(entity this) { set_anim(this, 10, roo_run6); roo_run(this, 24); }
void roo_run4(entity this) { set_anim(this, 9, roo_run5); roo_run(this, 20); }
void roo_run3(entity this) { set_anim(this, 8, roo_run4); roo_run(this, 18); }
void roo_run2(entity this) { set_anim(this, 7, roo_run3); roo_run(this, 16); }
void roo_run1(entity this) { set_anim(this, 6, roo_run2); roo_run(this, 12); }

void roo_stand(entity this)
{
	// NOTE: not calling ai_stand here as ai_walk is already handled manually
	FindTarget(this);
}

void roo_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(time < this.pain_finished)
		return;
	SpawnBlood(this.origin, '0 0 -5', 100, this);
	if(random() > 0.6)
		return; // chance to not be stunned
	this.pain_finished = time + 0.5;
	roo_hurt1(this);
}

void roo_run(entity this, float dist)
{
	//DropToFloor_QC_DelayedInit(this);
	if(this.enemy)
		ai_run(this, dist);
	else
		ai_walk(this, dist);
#if 0
	// add some randomness to their movement
	if(random() < 0.05)
	{
		this.angles_y = this.angles_y + ((random() > 0.5) * 2 - 1) * 135;
		this.angles_y = ANGLEMOD(this.angles_y);
		setthink(this, this.th_run);
		return;
	}
#endif
	this.nextthink = time + 0.05;
}

void roo_gib(entity this, entity inflictor)
{
	_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
	ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
	ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
	ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
	ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
	ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
	ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
}

void roo_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			roo_gib(this, inflictor);
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	roo_gib(this, inflictor);
	delete(this);
}

void roo_touch(entity this, entity toucher)
{
	if(this.health <= 0 || (!this.takedamage))
		return;
	if(!Damage_ValidTarget(toucher, this))
		return;

	if(toucher.takedamage && this.attack_finished < time && toucher.pain_finished < time)
	{
		float ldmg = 40 + 10*random();
		T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_KANGAROO.m_id);
		this.attack_finished = time + 1;	
	}
}

spawnfunc(monster_kangaroo) { monster_start(this, true, MON_KANGAROO); }
#endif // SVQC

#ifdef SVQC
METHOD(Kangaroo, mr_setup, bool(Kangaroo this, entity actor))
{
    TC(Kangaroo, this);

    precache_model("progs/gib1.mdl");
    precache_model("progs/gib2.mdl");
    precache_model("progs/gib3.mdl");

	actor.health = 120;
	actor.th_stand = roo_stand1;
	actor.th_walk = roo_stand1;
	actor.th_run = roo_run1;
	actor.th_die = roo_die;
	actor.th_pain = roo_pain;

	actor.scale = 2;
	//setsize(actor, this.m_mins * actor.scale, this.m_maxs * actor.scale);
	settouch(actor, roo_touch);

    return true;
}
#endif

// kirby power
#ifdef CSQC
PRECACHE(Star_Kangaroo)
{
	precache_model("progs/v_star_kangaroo.mdl");
}
#endif

#ifdef SVQC
PRECACHE(Star_Kangaroo)
{
	precache_model("progs/boomerang.mdl");
	precache_model("progs/proj_ringshock.mdl");

	precache_sound("break/flesh_impact.wav");
	precache_sound("weapons/sword_swing.wav");
	precache_sound("weapons/disc_catch.wav");
	precache_sound("weapons/impaler/impwall.wav");
	precache_sound("kirby/slam_hit.wav");
	precache_sound("kirby/cutter_slam.wav");
	precache_sound("kirby/cutter_impact.wav");
}

void wep_boomerang_shot4(entity this) { wep_set_anim(this, 4, w_ready); }
void wep_boomerang_shot3(entity this) { wep_set_anim(this, 3, wep_boomerang_shot4); }
void wep_boomerang_shot2(entity this) { wep_set_anim(this, 2, wep_boomerang_shot3); }
void wep_boomerang_shot1(entity this) { wep_set_anim(this, 1, wep_boomerang_shot2); }

.bool star_kangaroo_inair;
.float star_kangaroo_sliced;

void star_kangaroo_slam_trace(entity actor, .entity weaponentity)
{
	vector padding = '4 4 4'; // add a bit of padding for forward attacks
	tracebox(actor.origin, actor.mins - padding, actor.maxs + padding, actor.origin - ('0 0 1' * (actor.maxs_z + 5)), MOVE_NORMAL, actor);

	if(!trace_ent || !trace_ent.takedamage || trace_ent.star_kangaroo_sliced > time || !Damage_ValidTarget(trace_ent, actor))
		return;

	trace_ent.axhitme = true;
	trace_ent.star_kangaroo_sliced = time + 0.4; // no spam

	if(!(trace_ent.monsterdef.spawnflags & MONSTER_TYPE_BOSS) && !(trace_ent.monsterdef.spawnflags & MON_FLAG_STATIONARY))
	{
		float pushforce = 100 / vlen(trace_ent.maxs - trace_ent.mins);

		makevectors(actor.angles);
		trace_ent.velocity = v_forward * (100 * pushforce);
		trace_ent.velocity_z = (-600 * pushforce);
		UNSET_ONGROUND(trace_ent);
	}

	float damage = 50;
	T_Damage(trace_ent, actor, actor, damage, WEP_STAR.m_id);
	_sound(actor, CH_SHOTS, "kirby/slam_hit.wav", 1, ATTN_NORM);
}

void star_kangaroo_slam_impact(entity actor)
{
	_sound(actor, CH_SHOTS, "kirby/cutter_impact.wav", 1, ATTN_NORM);

	makevectors(actor.angles);
	vector org = actor.origin + ('0 0 1' * actor.mins_z) + v_forward * 24;

	T_RadiusDamage(actor, actor, 80, WEP_STAR.m_id, actor);

	// Spawn impact model ring on the ground
	entity swave = spawn();
	swave.mdl = "progs/proj_ringshock.mdl";	
	_setmodel(swave,swave.mdl);
	setsize(swave, '0 0 0', '0 0 0');
	setorigin(swave, org); // on floor, slight up (2 pixels)
	swave.solid = SOLID_NOT;
	set_movetype(swave, MOVETYPE_NONE);
	setthink(swave, ai_shockwave_think);
	swave.nextthink = time + 0.01;	// High time loop
	swave.ltime = swave.nextthink;
	
	// Spawn particle explosion where impact is located
	int vpart = 64 + rint(random()*64);
	particle_explode(org, vpart, 0.5, PARTICLE_BURST_FIRE, PARTICLE_BURST_SHOCKWAVE); 
}

void star_kangaroo_slam_frame(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;

	if(IS_ONGROUND(actor) || actor.waterlevel > 1)
	{
		if(IS_ONGROUND(actor))
			star_kangaroo_slam_impact(actor);
		this.m_frame = 0;
		w_ready(this);
		return;
	}

	if(IS_PLAYER(actor))
		player_shot1(actor);

	ATTACK_FINISHED(actor, weaponentity) = time + 0.5;

	wep_set_anim(this, 13, star_kangaroo_slam_frame);
	this.weapon_nextthink = time; // accurate slam tracing

	star_kangaroo_slam_trace(actor, weaponentity);
}

void star_kangaroo_slam(entity actor, .entity weaponentity)
{
	_sound(actor, CH_WEAPON_SINGLE, "kirby/cutter_slam.wav", 1, ATTN_NORM);
	makevectors(actor.angles);
	actor.velocity = v_forward * 500;
	if(actor.velocity_z > -800)
		actor.velocity_z -= 800;
	actor.oldvelocity = actor.velocity;
	ATTACK_FINISHED(actor, weaponentity) = time + 0.5; // prevent spam
	star_kangaroo_slam_frame(actor.(weaponentity));
}

void star_kangaroo_uppercut_trace(entity actor, .entity weaponentity)
{
	makevectors(actor.angles);
	vector org = actor.origin + v_forward * 64;
	// TODO: custom size? maybe a traceline is better?
	tracebox(org, '-32 -32 -32', '32 32 32', org + ('0 0 1' * (actor.maxs_z + 5)), MOVE_NORMAL, actor);

	if(!trace_ent || trace_ent.star_kangaroo_sliced > time || !trace_ent.takedamage || !Damage_ValidTarget(trace_ent, actor))
		return;

	trace_ent.axhitme = true;
	trace_ent.star_kangaroo_sliced = time + 0.4; // no spam

	// doesn't cancel out of attack!

	if(!(trace_ent.monsterdef.spawnflags & MONSTER_TYPE_BOSS) && !(trace_ent.monsterdef.spawnflags & MON_FLAG_STATIONARY))
	{
		float pushforce = 100 / vlen(trace_ent.maxs - trace_ent.mins);

		//makevectors(actor.angles);
		//trace_ent.velocity = v_forward * (100 * pushforce);
		trace_ent.velocity_z = (750 * pushforce);
		UNSET_ONGROUND(trace_ent);
	}

	float damage = 50;
	T_Damage(trace_ent, actor, actor, damage, WEP_STAR.m_id);
	// same channel as uppercut sound to override it
	_sound(trace_ent, CH_SHOTS, "kirby/slam_hit.wav", 1, ATTN_NORM);
}

void star_kangaroo_uppercut_frame(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;

	// cancel if we land or start falling
	// or if we start flying! no abuse thank you very much
	if(IS_ONGROUND(actor) || actor.waterlevel > 1 || STAT(KIRBY_STATE, actor) == KIRBY_FLYING)
	{
		this.m_frame = 0;
		w_ready(this);
		return;
	}

	// check the future slightly so the attack hasn't already ended
	if(time + 0.1 >= ATTACK_FINISHED(actor, weaponentity))
	{
		star_kangaroo_slam(actor, weaponentity);
		return;
	}

	if(IS_PLAYER(actor))
		player_shot1(actor);

	wep_set_anim(this, 7, star_kangaroo_uppercut_frame);
	this.weapon_nextthink = time; // accurate uppercut tracing

	star_kangaroo_uppercut_trace(actor, weaponentity);
}

void star_kangaroo_uppercut(entity actor, .entity weaponentity)
{
	_sound(actor, CH_WEAPON_SINGLE, "kirby/cutter_slam.wav", 1, ATTN_NORM);
	actor.velocity_z = max(actor.velocity_z + 800, 800);
	ATTACK_FINISHED(actor, weaponentity) = time + 0.4;
	UNSET_ONGROUND(actor);
	actor.(weaponentity).star_kangaroo_inair = true;
	star_kangaroo_uppercut_frame(actor.(weaponentity));
}

void boomerang_touch(entity this, entity toucher)
{
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
	if(toucher.takedamage)
	{
		if(time >= this.pain_finished)
		{
			_sound(this, CH_WEAPON_SINGLE, "break/flesh_impact.wav", 1, ATTN_NORM);
			float damg = (this.dmg) ? this.dmg : 40;
			spawn_touchblood(this, damg, toucher);
			T_Damage(toucher, this, this.realowner, damg, this.projectiledeathtype);
			this.pain_finished = time + 0.1; // prevent instakills on return trip!
		}
		//delete(this);
		this.count = time; // tell it to start going home
		return;
	}

	if(time > this.spamtime)
	{
		this.spamtime = time + 0.1;
		_sound(this, CH_WEAPON_SINGLE, "weapons/impaler/impwall.wav", 1, ATTN_NORM);
		te_gunshot(this.origin);
		//Send_Effect(EFFECT_LIGHT_DISC_BOUNCE, this.origin, normalize(this.velocity) * 16, 1);
	}
}

void boomerang_think(entity this)
{
	this.nextthink = time;
	if(this.cnt < time || !this.owner || this.owner.health < 1)
	{
		delete(this);
		return;
	}

	if(time >= this.count)
	{
		vector vtemp = this.owner.origin + '0 0 10';
		if(vdist(vtemp - this.origin, <=, 24))
		{
			_sound(this, CH_WEAPON_SINGLE, "weapons/disc_catch.wav", 1, ATTN_NORM);
			delete(this);
			return;
		}
		vector dir = normalize(vtemp - this.origin);
		this.velocity = dir * this.speed;
		this.dphitcontentsmask &= ~DPCONTENTS_SOLID;
		// TODO: thanks to the way collision changes on these, returning may need to be a separate projectile
		//UpdateCSQCProjectile(this);
	}

	//UNSET_ONGROUND(this);
	//this.velocity = this.oldvelocity;
	//this.angles = vectoangles(this.velocity);
}

void boomerang_throw(entity this, .entity weaponentity)
{
	//this.punchangle_x = -2;

	_sound(this, CH_WEAPON_SINGLE, "weapons/sword_swing.wav", 1, ATTN_NORM);

	entity boomerang = spawn();
	boomerang.flags = FL_PROJECTILE;
	boomerang.projectiledeathtype = WEP_STAR.m_id;
	boomerang.clipgroup = this.clipgroup;
	boomerang.owner = boomerang.realowner = this;
	set_movetype(boomerang, MOVETYPE_BOUNCEMISSILE);
	boomerang.solid = SOLID_BBOX;
	boomerang.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	boomerang.classname = "boomerang";
	boomerang.effects = EF_FULLBRIGHT;

	makevectors(this.v_angle);
	boomerang.speed = 700;
	vector dir = qc_aim(this, boomerang.speed);
	boomerang.velocity = dir * boomerang.speed;
	boomerang.oldvelocity = boomerang.velocity;
	boomerang.angles = vectoangles(boomerang.velocity);
	boomerang.avelocity = '0 512 0';
	settouch(boomerang, boomerang_touch);
	boomerang.cnt = time + 8; // deletion time
	boomerang.count = time + 0.7; // return time
	boomerang.dmg = 40;
	boomerang.nextthink = time;
	setthink(boomerang, boomerang_think);

	_setmodel(boomerang, "progs/boomerang.mdl");
	setsize(boomerang, '0 0 0', '0 0 0');
	vector org = W_Shotorg(this, weaponentity); // v_forward * 8, not used because it goes through mobs!
	setorigin(boomerang, org);

	IL_PUSH(g_projectiles, boomerang);
}

void star_kangaroo_throw(entity actor, .entity weaponentity)
{
	if(IS_PLAYER(actor))
		player_shot1(actor);

	wep_boomerang_shot1(actor.(weaponentity));

	boomerang_throw(actor, weaponentity);

	weapon_prepareattack(WEP_STAR, actor, weaponentity, 0.3);
}

METHOD(Kangaroo, star_fire, void(Kangaroo this, entity actor, .entity weaponentity))
{
	// we're always going to do *something*, so always cancel out of flight now
	if(STAT(KIRBY_STATE, actor) == KIRBY_FLYING)
		STAT(KIRBY_STATE, actor) = KIRBY_NORMAL;

	bool swimming = (actor.waterlevel > 1);

	// looking down and in the air!
	if(!swimming && actor.v_angle_x >= 55 && actor.v_angle_x <= 110)
	{
		star_kangaroo_slam(actor, weaponentity);
		return;
	}

	// looking up!
	if(!actor.(weaponentity).star_kangaroo_inair && !swimming && actor.v_angle_x <= -55 && actor.v_angle_x >= -110)
	{
		star_kangaroo_uppercut(actor, weaponentity);
		return;
	}

	star_kangaroo_throw(actor, weaponentity);
}
#endif
