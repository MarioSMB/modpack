#include "pumpking.qh"

#ifdef SVQC
const int anim_pumpking = 0; // no actual animations!

.entity pumpking_vinel1;
.entity pumpking_vinel2;
.entity pumpking_viner1;
.entity pumpking_viner2;
.entity pumpking_swordl;
.entity pumpking_swordr;
.entity pumpking_head;

..entity pumpking_field;

.float pumpking_idle_timer;

void pumpking_run1(entity this);
void pumpking_side1(entity this);
void pumpking_attack(entity this);

/*
=================
PumpkingCheckAttack
=================
*/
bool PumpkingCheckAttack(entity this)
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
			pumpking_run1(this);
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
			pumpking_run1(this);
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
		pumpking_attack(this);
	}

	if(this.enemy_range == RANGE_MID)
	{
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
			pumpking_run1(this);
		}
	}
	else
	{
		if(vdist(targ.origin - this.origin, >, 300))
		{
			if(this.attack_state != AS_DODGING)
			{
				this.attack_state = AS_DODGING;
				pumpking_side1(this);
			}
		}
		else
		{
			if(this.attack_state != AS_SLIDING)
			{
				this.attack_state = AS_SLIDING;
				pumpking_side1(this);
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

void pumpking_attack(entity this)
{
	_sound(this, CH_WEAPON_SINGLE, "weapons/grenade.wav", 1, ATTN_NORM);

	entity missile = spawn();
	missile.flags = FL_PROJECTILE;
	missile.owner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;
	missile.projectiledeathtype = DEATH_MONSTER_PUMPKING.m_id;
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
	_setmodel(missile, "progs/pumpking_pumpkin.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, this.origin + '0 0 70');

	IL_PUSH(g_projectiles, missile);
}

void pumpking_idlesound(entity this)
{
	if(time > this.pumpking_idle_timer && random() < 0.2)
	{
		this.pumpking_idle_timer = time + 3 + (random() * 10);
		sound(this, CH_VOICE, SND_MON_PUMPKING_SIGHT_RANDOM(), 1, ATTN_BOSS);
	}
}

void PumpkingStopSide(entity this)
{
	this.attack_state = AS_STRAIGHT;
	setthink(this, pumpking_run1);
}

void pumpking_stand1(entity this);
void pumpking_stand6(entity this) { set_anim(this, anim_pumpking, pumpking_stand1); ai_stand(this); }
void pumpking_stand5(entity this) { set_anim(this, anim_pumpking, pumpking_stand6); ai_stand(this); }
void pumpking_stand4(entity this) { set_anim(this, anim_pumpking, pumpking_stand5); ai_stand(this); }
void pumpking_stand3(entity this) { set_anim(this, anim_pumpking, pumpking_stand4); ai_stand(this); }
void pumpking_stand2(entity this) { set_anim(this, anim_pumpking, pumpking_stand3); ai_stand(this); }
void pumpking_stand1(entity this) { set_anim(this, anim_pumpking, pumpking_stand2); ai_stand(this); pumpking_idlesound(this); }

void pumpking_walk1(entity this);
void pumpking_walk8(entity this) { set_anim(this, anim_pumpking, pumpking_walk1); ai_walk(this, 8); }
void pumpking_walk7(entity this) { set_anim(this, anim_pumpking, pumpking_walk8); ai_walk(this, 8); }
void pumpking_walk6(entity this) { set_anim(this, anim_pumpking, pumpking_walk7); ai_walk(this, 8); }
void pumpking_walk5(entity this) { set_anim(this, anim_pumpking, pumpking_walk6); ai_walk(this, 8); }
void pumpking_walk4(entity this) { set_anim(this, anim_pumpking, pumpking_walk5); ai_walk(this, 8); }
void pumpking_walk3(entity this) { set_anim(this, anim_pumpking, pumpking_walk4); ai_walk(this, 8); }
void pumpking_walk2(entity this) { set_anim(this, anim_pumpking, pumpking_walk3); ai_walk(this, 8); }
void pumpking_walk1(entity this) { set_anim(this, anim_pumpking, pumpking_walk2); ai_walk(this, 8); pumpking_idlesound(this); }

void pumpking_side8(entity this) { set_anim(this, anim_pumpking, pumpking_run1); ai_run(this, 12); PumpkingStopSide(this); }
void pumpking_side7(entity this) { set_anim(this, anim_pumpking, pumpking_side8); ai_run(this, 12); }
void pumpking_side6(entity this) { set_anim(this, anim_pumpking, pumpking_side7); ai_run(this, 12); }
void pumpking_side5(entity this) { set_anim(this, anim_pumpking, pumpking_side6); ai_run(this, 12); }
void pumpking_side4(entity this) { set_anim(this, anim_pumpking, pumpking_side5); ai_run(this, 12); }
void pumpking_side3(entity this) { set_anim(this, anim_pumpking, pumpking_side4); ai_run(this, 12); }
void pumpking_side2(entity this) { set_anim(this, anim_pumpking, pumpking_side3); ai_run(this, 12); }
void pumpking_side1(entity this) { set_anim(this, anim_pumpking, pumpking_side2); ai_run(this, 12); pumpking_idlesound(this); }

void pumpking_run6(entity this) { set_anim(this, anim_pumpking, pumpking_run1); ai_run(this, 12); }
void pumpking_run5(entity this) { set_anim(this, anim_pumpking, pumpking_run6); ai_run(this, 12); }
void pumpking_run4(entity this) { set_anim(this, anim_pumpking, pumpking_run5); ai_run(this, 12); }
void pumpking_run3(entity this) { set_anim(this, anim_pumpking, pumpking_run4); ai_run(this, 12); }
void pumpking_run2(entity this) { set_anim(this, anim_pumpking, pumpking_run3); ai_run(this, 12); }
void pumpking_run1(entity this) { set_anim(this, anim_pumpking, pumpking_run2); ai_run(this, 12); pumpking_idlesound(this); }

//===========================================================================

void pumpking_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(time < this.pain_finished)
		return;
	this.pain_finished = time + 0.1;
	spamsound(this, CH_VOICE, SND_MON_PUMPKING_PAIN, 1, ATTN_BOSS);
}

//===========================================================================

void pumpking_clearparts(entity this)
{
	if(this.(pumpking_vinel1)) delete(this.(pumpking_vinel1));
	if(this.(pumpking_vinel2)) delete(this.(pumpking_vinel2));
	if(this.(pumpking_viner1)) delete(this.(pumpking_viner1));
	if(this.(pumpking_viner2)) delete(this.(pumpking_viner2));
	if(this.(pumpking_swordl)) delete(this.(pumpking_swordl));
	if(this.(pumpking_swordr)) delete(this.(pumpking_swordr));
	if(this.(pumpking_head)) delete(this.(pumpking_head));
}

void pumpking_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CH_VOICE, "pumpking/death.wav", 1, ATTN_BOSS);
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

	pumpking_clearparts(this);
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

vector pumpking_randomangle(entity this)
{
	vector ang = '0 0 0';
	// never set X axis rotation
	ang.y = crandom() * 70;
	ang.z = crandom() * 70;
	return ang;
}

.float pumpking_hurttime;
void pumpking_sword_touch(entity this, entity toucher)
{
	entity own = this.realowner;

	if(toucher.flags & FL_PROJECTILE)
		return;
	if(time < toucher.pumpking_hurttime)
		return;

	if(!toucher.takedamage || !Damage_ValidTarget(toucher, own))
		return;
	
	if(toucher == this.owner || toucher.owner == own)
		return;

	toucher.pumpking_hurttime = time + 0.2; // no spam please

	float damage = (this.dmg) ? this.dmg : 40;
	
	T_Damage(toucher, own, own, damage, DEATH_MONSTER_PUMPKING.m_id);
}

void pumpking_blade_touch(entity this, entity toucher)
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

.float pumpking_blade_dmgtime;
void pumpking_blade_think(entity this)
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

	if(time <= this.pumpking_blade_dmgtime)
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

		this.pumpking_blade_dmgtime = time + 0.2; // prevent instant death
	});
}

void pumpking_blade_attack(entity this, vector org)
{
	entity missile = new(pumpking_blade);
	missile.flags = FL_PROJECTILE;
	missile.owner = this;
	missile.realowner = this;
	missile.clipgroup = this.clipgroup;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_TRIGGER;
	missile.dphitcontentsmask = DPCONTENTS_SOLID;
	missile.projectiledeathtype = DEATH_MONSTER_PUMPKING.m_id;
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

	settouch(missile, pumpking_blade_touch);

	missile.count = time + 8;
	missile.nextthink = time;
	setthink(missile, pumpking_blade_think);

	_setmodel(missile, "progs/pumpking_blade.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, org);

	IL_PUSH(g_projectiles, missile);
}

.vector ideal_angle;
void pumpking_part_think(entity this)
{
	this.nextthink = time;

	if(this.owner.health <= 0 || wasfreed(this.owner))
	{
		delete(this);
		return;
	}

	if(this.model == "progs/pumpking_head.mdl")
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
	else if(this.model == "progs/pumpking_sword.mdl")
	{
		vector org = gettaginfo(this, 0);

		if(this.owner.enemy && time > this.attack_finished)
		{
			this.attack_finished = time + 3 + (random() * 3);
			pumpking_blade_attack(this.owner, org);
		}
		
		FOREACH_ENTITY_RADIUS(org, 64, it != this,
		{
			if (it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY)
				pumpking_sword_touch(this, it);
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
				this.ideal_angle = pumpking_randomangle(this);
				this.attack_state = 0;
			}
		}
	}
}

void pumpking_part_delete(entity this)
{
	if(this.owner)
		this.owner.(this.pumpking_field) = NULL;
	delete_fn(this);
}

void pumpking_setmover(entity this, int direction)
{
	this.angle = direction;
	this.count = 1;

	this.angles = pumpking_randomangle(this);
	this.ideal_angle = this.angles;
}

entity pumpking_spawnpart(entity this, entity attach, string partmdl, vector offset, .entity fld, bool domove, int moveangle)
{
	entity fist = new(pumpking_part);
	fist.solid = SOLID_BBOX;
	_setmodel(fist, partmdl);
	setsize(fist, '-24 -24 -16', '24 24 24');
	set_movetype(fist, MOVETYPE_NONE);
	fist.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	fist.pos1 = offset;
	fist.clipgroup = this.clipgroup;
	fist.projectiledeathtype = DEATH_MONSTER_PUMPKING.m_id;
	fist.owner = this;
	fist.realowner = this;
	setthink(fist, pumpking_part_think);
	fist.nextthink = time;
	fist.dmg = 40;
	fist.pumpking_field = fld;
	fist.attack_finished = time + 1 + (2 * random());
	fist.cnt = 0;
	fist.dtor = pumpking_part_delete;
	fist.goalentity = attach;

	setattachment(fist, attach, "");
	setorigin(fist, offset);
	//fist.angles = this.angles;

	if(domove)
		pumpking_setmover(fist, moveangle);

	this.(fld) = fist;
	
	return fist;
}

void pumpking_spawnparts(entity this)
{
	entity part;
	part = pumpking_spawnpart(this, this, "progs/pumpking_vinel.mdl", '20 -60 80', pumpking_vinel1, true, 1);
	part = pumpking_spawnpart(this, part, "progs/pumpking_vinel.mdl", '0 -120 0', pumpking_vinel2, true, 1);
	pumpking_spawnpart(this, part, "progs/pumpking_sword.mdl", '0 -120 0', pumpking_swordl, false, 0);

	part = pumpking_spawnpart(this, this, "progs/pumpking_viner.mdl", '20 60 80', pumpking_viner1, true, -1);
	part = pumpking_spawnpart(this, part, "progs/pumpking_viner.mdl", '0 120 0', pumpking_viner2, true, -1);
	pumpking_spawnpart(this, part, "progs/pumpking_sword.mdl", '0 120 0', pumpking_swordr, false, 0);

	pumpking_spawnpart(this, this, "progs/pumpking_head.mdl", '20 0 112', pumpking_head, false, 0);
}

/*QUAKED monster_pumpking (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_pumpking) { monster_start(this, true, MON_PUMPKING); }
#endif // SVQC

#ifdef SVQC
METHOD(Pumpking, mr_setup, bool(Pumpking this, entity actor))
{
	TC(Pumpking, this);

	precache_model("progs/pumpking_head.mdl");
	precache_model("progs/pumpking_sword.mdl");
	precache_model("progs/pumpking_vinel.mdl");
	precache_model("progs/pumpking_viner.mdl");
	precache_model("progs/pumpking_pumpkin.mdl");
	precache_model("progs/pumpking_blade.mdl");
	precache_sound("pumpking/death.wav");
	precache_sound("weapons/grenade.wav");
	precache_sound("weapons/grape_impact.wav");
	precache_sound("blob/land1.wav");

	actor.health = 4000;
	actor.th_stand = pumpking_stand1;
	actor.th_walk = pumpking_walk1;
	actor.th_run = pumpking_run1;
	actor.th_pain = pumpking_pain;
	actor.th_die = pumpking_die;

	actor.checkattack = PumpkingCheckAttack;

	pumpking_spawnparts(actor);

	return true;
}
METHOD(Pumpking, mr_sight, bool(Pumpking this, entity actor))
{
	TC(Pumpking, this);

	if(time <= actor.pumpking_idle_timer)
		return true; // too soon!

	sound(actor, CH_VOICE, SND_MON_PUMPKING_SIGHT_RANDOM(), 1, ATTN_BOSS);

	actor.pumpking_idle_timer = time + 10;

	return true;
}
#endif
