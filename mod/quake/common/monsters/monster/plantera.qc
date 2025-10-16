#include "plantera.qh"

#ifdef SVQC
const int anim_plantera = 0; // no actual animations!

.float plantera_idle_timer;

void plantera_run1(entity this);
void plantera_side1(entity this);
void plantera_attack(entity this);

/*
=================
PlanteraCheckAttack
=================
*/
bool PlanteraCheckAttack(entity this)
{
	if(time < this.attack_finished)
		return false;
	if(!this.enemy_visible)
		return false;

	if(this.enemy_range == RANGE_FAR)
	{
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
			plantera_run1(this);
		}
		return false;
	}
		
	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, false, this);

	if(trace_ent != targ)
	{	// don't have a clear shot, so move to a side
		if(this.attack_state != AS_DODGING)
		{
			this.attack_state = AS_DODGING;
			plantera_run1(this);
		}
		return false;
	}

	float chance = 0;	
	if(this.enemy_range == RANGE_MELEE)
		chance = 0;
	else if(this.enemy_range == RANGE_NEAR)
		chance = 0.2;
	else if(this.enemy_range == RANGE_MID)
		chance = 0.6;

	if(time > this.attack2_finished && random() < chance)
	{
		// doesn't cancel out movement, just fire at will!
		this.attack2_finished = time + 3 + (random() * 3);
		plantera_attack(this);
	}

	if(this.enemy_range == RANGE_MID)
	{
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
			plantera_run1(this);
		}
	}
	else
	{
		if(vdist(targ.origin - this.origin, >, 300))
		{
			if(this.attack_state != AS_DODGING)
			{
				this.attack_state = AS_DODGING;
				plantera_side1(this);
			}
		}
		else
		{
			if(this.attack_state != AS_SLIDING)
			{
				this.attack_state = AS_SLIDING;
				plantera_side1(this);
			}
		}
	}
	
	return false;
}

void PumpkinExplode(entity this)
{
	float damg = (this.dmg) ? this.dmg : 40;
	T_RadiusDamage(this, this.owner, damg, this.projectiledeathtype, NULL);

	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);

	BecomeExplosion(this);
}

void PumpkinTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner
	if(toucher.takedamage == DAMAGE_AIM)
	{
		PumpkinExplode(this);
		return;
	}
	_sound(this, CH_VOICE, "blob/land1.wav", 1, ATTN_NORM);	// bounce sound
	if(this.velocity == '0 0 0')
		this.avelocity = '0 0 0';
}

void plantera_attack(entity this)
{
	_sound(this, CH_WEAPON_SINGLE, "weapons/grenade.wav", 1, ATTN_NORM);

	entity missile = spawn();
	missile.flags = FL_PROJECTILE;
	missile.owner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;
	missile.projectiledeathtype = DEATH_MONSTER_PLANTERA.m_id;
	missile.clipgroup = this.clipgroup;
	missile.classname = "pumpkin_grenade";
	missile.dmg = 50;
	missile.noise = "weapons/grape_impact.wav";

// set missile speed	

	vector dir = normalize(this.enemy.origin - this.origin);

	missile.velocity = dir * 600;
	missile.velocity_z = 200;

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);

	settouch(missile, PumpkinTouch);
	missile.nextthink = time + 2.5;
	setthink(missile, PumpkinExplode);
	_setmodel(missile, "progs/plantera_pumpkin.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, this.origin + '0 0 70');

	IL_PUSH(g_projectiles, missile);
}

void plantera_idlesound(entity this)
{
	if(time > this.plantera_idle_timer && random() < 0.2)
	{
		this.plantera_idle_timer = time + 3 + (random() * 10);
		sound(this, CH_VOICE, SND_MON_PLANTERA_SIGHT_RANDOM(), 1, ATTN_BOSS);
	}
}

void PlanteraStopSide(entity this)
{
	this.attack_state = AS_STRAIGHT;
	setthink(this, plantera_run1);
}

void plantera_stand1(entity this);
void plantera_stand6(entity this) { set_anim(this, anim_plantera, plantera_stand1); ai_stand(this); }
void plantera_stand5(entity this) { set_anim(this, anim_plantera, plantera_stand6); ai_stand(this); }
void plantera_stand4(entity this) { set_anim(this, anim_plantera, plantera_stand5); ai_stand(this); }
void plantera_stand3(entity this) { set_anim(this, anim_plantera, plantera_stand4); ai_stand(this); }
void plantera_stand2(entity this) { set_anim(this, anim_plantera, plantera_stand3); ai_stand(this); }
void plantera_stand1(entity this) { set_anim(this, anim_plantera, plantera_stand2); ai_stand(this); plantera_idlesound(this); }

void plantera_walk1(entity this);
void plantera_walk8(entity this) { set_anim(this, anim_plantera, plantera_walk1); ai_walk(this, 8); }
void plantera_walk7(entity this) { set_anim(this, anim_plantera, plantera_walk8); ai_walk(this, 8); }
void plantera_walk6(entity this) { set_anim(this, anim_plantera, plantera_walk7); ai_walk(this, 8); }
void plantera_walk5(entity this) { set_anim(this, anim_plantera, plantera_walk6); ai_walk(this, 8); }
void plantera_walk4(entity this) { set_anim(this, anim_plantera, plantera_walk5); ai_walk(this, 8); }
void plantera_walk3(entity this) { set_anim(this, anim_plantera, plantera_walk4); ai_walk(this, 8); }
void plantera_walk2(entity this) { set_anim(this, anim_plantera, plantera_walk3); ai_walk(this, 8); }
void plantera_walk1(entity this) { set_anim(this, anim_plantera, plantera_walk2); ai_walk(this, 8); plantera_idlesound(this); }

void plantera_side8(entity this) { set_anim(this, anim_plantera, plantera_run1); ai_run(this, 12); PlanteraStopSide(this); }
void plantera_side7(entity this) { set_anim(this, anim_plantera, plantera_side8); ai_run(this, 12); }
void plantera_side6(entity this) { set_anim(this, anim_plantera, plantera_side7); ai_run(this, 12); }
void plantera_side5(entity this) { set_anim(this, anim_plantera, plantera_side6); ai_run(this, 12); }
void plantera_side4(entity this) { set_anim(this, anim_plantera, plantera_side5); ai_run(this, 12); }
void plantera_side3(entity this) { set_anim(this, anim_plantera, plantera_side4); ai_run(this, 12); }
void plantera_side2(entity this) { set_anim(this, anim_plantera, plantera_side3); ai_run(this, 12); }
void plantera_side1(entity this) { set_anim(this, anim_plantera, plantera_side2); ai_run(this, 12); plantera_idlesound(this); }

void plantera_run6(entity this) { set_anim(this, anim_plantera, plantera_run1); ai_run(this, 12); }
void plantera_run5(entity this) { set_anim(this, anim_plantera, plantera_run6); ai_run(this, 12); }
void plantera_run4(entity this) { set_anim(this, anim_plantera, plantera_run5); ai_run(this, 12); }
void plantera_run3(entity this) { set_anim(this, anim_plantera, plantera_run4); ai_run(this, 12); }
void plantera_run2(entity this) { set_anim(this, anim_plantera, plantera_run3); ai_run(this, 12); }
void plantera_run1(entity this) { set_anim(this, anim_plantera, plantera_run2); ai_run(this, 12); plantera_idlesound(this); }

//===========================================================================

void plantera_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(time < this.pain_finished)
		return;
	this.pain_finished = time + 0.1;
	spamsound(this, CH_VOICE, SND_MON_PLANTERA_PAIN, 1, ATTN_BOSS);
}

//===========================================================================

void plantera_clearparts(entity this)
{
	if(this.(plantera_vinel1)) delete(this.(plantera_vinel1));
	if(this.(plantera_vinel2)) delete(this.(plantera_vinel2));
	if(this.(plantera_viner1)) delete(this.(plantera_viner1));
	if(this.(plantera_viner2)) delete(this.(plantera_viner2));
	if(this.(plantera_swordl)) delete(this.(plantera_swordl));
	if(this.(plantera_swordr)) delete(this.(plantera_swordr));
	if(this.(plantera_head)) delete(this.(plantera_head));
}

void plantera_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CH_VOICE, "plantera/death.wav", 1, ATTN_BOSS);
	spawn_touchblood(this, 60, inflictor);
	ThrowGib(this, this, "progs/gib1.mdl", -100);
	ThrowGib(this, this, "progs/gib2.mdl", -100);
	ThrowGib(this, this, "progs/gib3.mdl", -100);
	ThrowGib(this, this, "progs/gib1.mdl", -100);
	ThrowGib(this, this, "progs/gib2.mdl", -100);
	ThrowGib(this, this, "progs/gib3.mdl", -100);
	ThrowGib(this, this, "progs/gib1.mdl", -100);
	ThrowGib(this, this, "progs/gib2.mdl", -100);
	ThrowGib(this, this, "progs/gib3.mdl", -100);

	plantera_clearparts(this);
	delete(this);
}

// TODO: this surely already exists... somewhere!
// moves v1 towards v2 at increment steps, no snapping
vector vec_drag(vector v1, vector v2, float increment)
{
	if(v1.x < v2.x) v1.x += increment;
	if(v1.y < v2.y) v1.y += increment;
	if(v1.z < v2.z) v1.z += increment;

	if(v1.x > v2.x) v1.x -= increment;
	if(v1.y > v2.y) v1.y -= increment;
	if(v1.z > v2.z) v1.z -= increment;

	return v1;
}

vector plantera_randomangle(entity this)
{
	vector ang = '0 0 0';
	// never set X axis rotation
	ang.y = crandom() * 70;
	ang.z = crandom() * 70;
	return ang;
}

.float plantera_hurttime;
void plantera_sword_touch(entity this, entity toucher)
{
	entity own = this.realowner;

	if(toucher.flags & FL_PROJECTILE)
		return;
	if(time < toucher.plantera_hurttime)
		return;

	if(!toucher.takedamage || !Damage_ValidTarget(toucher, own))
		return;
	
	if(toucher == this.owner || toucher.owner == own)
		return;

	toucher.plantera_hurttime = time + 0.2; // no spam please

	float damage = (this.dmg) ? this.dmg : 40;
	
	T_Damage(toucher, own, own, damage, DEATH_MONSTER_PLANTERA.m_id);
}

void plantera_blade_touch(entity this, entity toucher)
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
		particle(findbetterlocation(this.origin, 8), '0 0 0', 30, 128);
		delete(this);
		return;
	}
}

.float plantera_blade_dmgtime;
void plantera_blade_think(entity this)
{
	if(time > this.count)
	{
		delete(this);
		return;
	}

	// hack to ensure the projectile keeps going even if it hits a target
	this.nextthink = time;

	float velmax = 2000;
	float vel = vlen(this.velocity);
	if(vel == 0)
		vel = 1; // hack to make sure avelocity never divs by 0

	this.avelocity_x = -480 * (vel / bound(100, velmax, 1000));

	if(vel < velmax)
	{
		// copied from PM_Accelerate
		float wishspeed = velmax;
		vector wishdir = this.movedir;
		float currentspeed = (this.velocity * wishdir);
		float addspeed = wishspeed - currentspeed;
		if(addspeed > 0)
		{
			float accelspeed = 1 * PHYS_INPUT_TIMELENGTH * wishspeed;
			if(accelspeed > addspeed)
				accelspeed = addspeed;

			this.velocity += accelspeed * wishdir;
		}
	}

	if(time <= this.plantera_blade_dmgtime)
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

		this.plantera_blade_dmgtime = time + 0.2; // prevent instant death
	});
}

void plantera_blade_attack(entity this, vector org)
{
	entity missile = new(plantera_blade);
	missile.flags = FL_PROJECTILE;
	missile.owner = this;
	missile.realowner = this;
	missile.clipgroup = this.clipgroup;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_TRIGGER;
	missile.dphitcontentsmask = DPCONTENTS_SOLID;
	missile.projectiledeathtype = DEATH_MONSTER_PLANTERA.m_id;
	missile.cnt = 64; // rough area of effect during travel
	missile.dmg = 50;
	missile.bouncefactor = 1;
	missile.bouncestop = 0.1;

	vector dir = normalize(this.enemy.origin - this.origin);
	missile.movedir = dir;
	missile.velocity = missile.movedir * 50;
	//missile.velocity_z = 200;

	missile.angles = vectoangles(missile.velocity);
	//missile.angles_z = (random() > 0.5) ? 30 : -30;

	settouch(missile, plantera_blade_touch);

	missile.count = time + 8;
	missile.nextthink = time;
	setthink(missile, plantera_blade_think);

	_setmodel(missile, "progs/plantera_blade.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, org);

	IL_PUSH(g_projectiles, missile);
}

.vector ideal_angle;
void plantera_part_think(entity this)
{
	this.nextthink = time;

	if(this.owner.health <= 0 || wasfreed(this.owner))
	{
		delete(this);
		return;
	}

	if(this.model == "progs/plantera_head.mdl")
	{
		if(time < this.delay)
			return;
		this.delay = time + 0.1;

		if(time >= this.attack_finished)
		{
			this.cnt = ((random() > 0.5) ? -4 : 4); // rotate twice (120 degrees)
			this.attack_finished = time + 5 + (random() * 5);
		}
		else if(this.cnt < 0)
		{
			this.cnt += 1;
			this.angles_y = anglemods(this.angles_y - 30);
		}
		else if(this.cnt > 0)
		{
			this.cnt -= 1;
			this.angles_y = anglemods(this.angles_y + 30);
		}

		//this.angles_x = sin(this.angles_x * DEG2RAD * time);
	}
	else if(this.model == "progs/plantera_sword.mdl")
	{
		vector org = gettaginfo(this, 0);

		if(this.owner.enemy && time > this.attack_finished)
		{
			this.attack_finished = time + 3 + (random() * 3);
			plantera_blade_attack(this.owner, org);
		}
		
		FOREACH_ENTITY_RADIUS(org, 64, it != this,
		{
			if (it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY)
				plantera_sword_touch(this, it);
		});
	}
	else if(this.count)
	{
		vector ideal = this.ideal_angle;
		ideal *= this.angle;

		float aspeed = ((this.attack_state) ? 3 : 1);
		this.angles = vec_drag(this.angles, ideal, aspeed);

		if(time >= this.attack_finished)
		{
			if(random() < 0.3)
			{
				this.attack_finished = time + 1;
				this.ideal_angle = '0 90 0';
				this.attack_state = 1;
			}
			else
			{
				this.attack_finished = time + 0.5 + random();
				this.ideal_angle = plantera_randomangle(this);
				this.attack_state = 0;
			}
		}
	}
}

void plantera_setmover(entity this, int direction)
{
	this.angle = direction;
	this.count = 1;

	this.angles = plantera_randomangle(this);
	this.ideal_angle = this.angles;
}

entity plantera_spawnpart(entity this, entity attach, string partmdl, vector offset, bool domove, int moveangle)
{
	entity fist = new(plantera_part);
	fist.solid = SOLID_BBOX;
	_setmodel(fist, partmdl);
	setsize(fist, '-24 -24 -16', '24 24 24');
	set_movetype(fist, MOVETYPE_NONE);
	fist.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	fist.pos1 = offset;
	fist.clipgroup = this.clipgroup;
	fist.projectiledeathtype = DEATH_MONSTER_PLANTERA.m_id;
	fist.owner = this;
	fist.realowner = this;
	setthink(fist, plantera_part_think);
	fist.nextthink = time;
	fist.dmg = 40;
	fist.attack_finished = time + 1 + (2 * random());
	fist.cnt = 0;
	fist.goalentity = attach;

	setattachment(fist, attach, "");
	setorigin(fist, offset);
	//fist.angles = this.angles;

	if(domove)
		plantera_setmover(fist, moveangle);

	this.(fld) = fist;
	
	return fist;
}

void plantera_spawnparts(entity this)
{
	entity part;
	part = plantera_spawnpart(this, this, "progs/plantera_vinel.mdl", '20 -60 80', true, 1);
	part = plantera_spawnpart(this, part, "progs/plantera_vinel.mdl", '0 -120 0', true, 1);
	plantera_spawnpart(this, part, "progs/plantera_sword.mdl", '0 -120 0', false, 0);

	part = plantera_spawnpart(this, this, "progs/plantera_viner.mdl", '20 60 80', true, -1);
	part = plantera_spawnpart(this, part, "progs/plantera_viner.mdl", '0 120 0', true, -1);
	plantera_spawnpart(this, part, "progs/plantera_sword.mdl", '0 120 0', false, 0);

	plantera_spawnpart(this, this, "progs/plantera_head.mdl", '20 0 112', false, 0);
}

/*QUAKED monster_plantera (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_plantera) { monster_start(this, true, MON_PLANTERA); }
#endif // SVQC

#ifdef SVQC
METHOD(Plantera, mr_setup, bool(Plantera this, entity actor))
{
	TC(Plantera, this);

	precache_model("progs/plantera_phase2.mdl");
	precache_model("progs/plantera_claw.mdl");
	precache_model("progs/plantera_grabber.mdl");
	precache_sound("plantera/death.wav");
	precache_sound("weapons/grenade.wav");
	precache_sound("weapons/grape_impact.wav");
	precache_sound("blob/land1.wav");

	actor.health = 1000;
	actor.th_stand = plantera_stand1;
	actor.th_walk = plantera_walk1;
	actor.th_run = plantera_run1;
	actor.th_pain = plantera_pain;
	actor.th_die = plantera_die;

	actor.checkattack = PlanteraCheckAttack;

	plantera_spawnparts(actor);

	return true;
}
METHOD(Plantera, mr_sight, bool(Plantera this, entity actor))
{
	TC(Plantera, this);

	if(time <= actor.plantera_idle_timer)
		return true; // too soon!

	sound(actor, CH_VOICE, SND_MON_PLANTERA_SIGHT_RANDOM(), 1, ATTN_BOSS);

	actor.plantera_idle_timer = time + 10;

	return true;
}
#endif
