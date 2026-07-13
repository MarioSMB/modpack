#include "skeletron_prime.qh"

#ifdef SVQC
const int anim_skeletron_prime = 0; // 0-1
const int anim_skeletron_prime_spin = 2;

const int CLIPGROUP_SKELETRON_PRIME = 24; // randomly picked! search for CLIPGROUP_ to find others used

enum {
	PRIME_ARM_UPR,
	PRIME_ARM_DOWNR,
	PRIME_ARM_UPL,
	PRIME_ARM_DOWNL
};

enum {
	PRIME_ELBOW,
	PRIME_FOREARM,
	PRIME_CANNON,
	PRIME_SAW,
	PRIME_VICE,
	PRIME_LASER
};

.int prime_arm;
.int prime_type;

.float skeletron_prime_spindelay;

.float skeletron_prime_dmgtime;

void skeletron_prime_spin1(entity this);
void skeletron_prime_run1(entity this);
void skeletron_prime_side1(entity this);

void SkeletronPrime_SpinTouch(entity this, entity toucher);

void skeletron_prime_updateresist(entity this, bool spinning);

/*
=================
SkeletronPrimeCheckAttack
=================
*/
bool SkeletronPrimeCheckAttack(entity this)
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
			skeletron_prime_run1(this);
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
			skeletron_prime_run1(this);
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

	if(time > this.skeletron_prime_spindelay && random() < chance)
	{
		this.skeletron_prime_spindelay = time + 20;
		if(autocvar_skill >= 2)
			this.attack_finished = time + 5; // shorter but quicker
		else
			this.attack_finished = time + 7;
		skeletron_prime_updateresist(this, true);
		this.attack_state = AS_STRAIGHT;
		settouch(this, SkeletronPrime_SpinTouch);
		_sound(this, CH_VOICE, "skeletron_prime/sight.wav", 1, ATTN_BOSS);
		skeletron_prime_spin1(this);
		return true;
	}

	if(this.enemy_range == RANGE_MID)
	{
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
			skeletron_prime_run1(this);
		}
	}
	else
	{
		if(vdist(targ.origin - this.origin, >, 300))
		{
			if(this.attack_state != AS_DODGING)
			{
				this.attack_state = AS_DODGING;
				skeletron_prime_side1(this);
			}
		}
		else
		{
			if(this.attack_state != AS_SLIDING)
			{
				this.attack_state = AS_SLIDING;
				skeletron_prime_side1(this);
			}
		}
	}
	
	return false;
}

void SkeletronPrime_SpinTouch(entity this, entity toucher)
{
	if(this.health <= 0 || !this.takedamage)
		return;

	if(toucher.takedamage && this.skeletron_prime_dmgtime < time)
	{
		float damage = (time > this.attack_finished) ? 30 : 80;
		float ldmg = damage + 10*random();
		T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_SKELETRON_PRIME.m_id);
		this.skeletron_prime_dmgtime = time + 0.5;
	}
}

void SkeletronPrimeStopSide(entity this)
{
	this.attack_state = AS_STRAIGHT;
	setthink(this, skeletron_prime_run1);
}

void prime_anim(entity this)
{
	// abusing walkframe to avoid needing to rewrite animation, sorry not sorry!
	this.walkframe = (this.walkframe == 1) ? 0 : 1;
	this.frame = this.walkframe;
}

void skeletron_prime_stand1(entity this);
void skeletron_prime_stand6(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_stand1); ai_stand(this); }
void skeletron_prime_stand5(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_stand6); ai_stand(this); }
void skeletron_prime_stand4(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_stand5); ai_stand(this); }
void skeletron_prime_stand3(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_stand4); ai_stand(this); }
void skeletron_prime_stand2(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_stand3); ai_stand(this); }
void skeletron_prime_stand1(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_stand2); ai_stand(this); }

void skeletron_prime_walk1(entity this);
void skeletron_prime_walk8(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_walk1); prime_anim(this); ai_walk(this, 8); }
void skeletron_prime_walk7(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_walk8); prime_anim(this); ai_walk(this, 8); }
void skeletron_prime_walk6(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_walk7); prime_anim(this); ai_walk(this, 8); }
void skeletron_prime_walk5(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_walk6); prime_anim(this); ai_walk(this, 8); }
void skeletron_prime_walk4(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_walk5); prime_anim(this); ai_walk(this, 8); }
void skeletron_prime_walk3(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_walk4); prime_anim(this); ai_walk(this, 8); }
void skeletron_prime_walk2(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_walk3); prime_anim(this); ai_walk(this, 8); }
void skeletron_prime_walk1(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_walk2); prime_anim(this); ai_walk(this, 8); }

void skeletron_prime_side8(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_run1); prime_anim(this); ai_run(this, 12); SkeletronPrimeStopSide(this); }
void skeletron_prime_side7(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_side8); prime_anim(this); ai_run(this, 12); }
void skeletron_prime_side6(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_side7); prime_anim(this); ai_run(this, 12); }
void skeletron_prime_side5(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_side6); prime_anim(this); ai_run(this, 12); }
void skeletron_prime_side4(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_side5); prime_anim(this); ai_run(this, 12); }
void skeletron_prime_side3(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_side4); prime_anim(this); ai_run(this, 12); }
void skeletron_prime_side2(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_side3); prime_anim(this); ai_run(this, 12); }
void skeletron_prime_side1(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_side2); prime_anim(this); ai_run(this, 12); }

void skeletron_prime_checkspin(entity this)
{
	if(time >= this.attack_finished)
	{
		skeletron_prime_updateresist(this, false);
		settouch(this, func_null);
		set_anim(this, anim_skeletron_prime, skeletron_prime_run1);
	}
}

float prime_spinspeed(entity this)
{
	// TODO: speed up against distant targets
	return 32;
}

void skeletron_prime_spin8(entity this) { set_animofs(this, anim_skeletron_prime_spin, 8, skeletron_prime_spin1); ai_charge(this, prime_spinspeed(this)); skeletron_prime_checkspin(this); }
void skeletron_prime_spin7(entity this) { set_animofs(this, anim_skeletron_prime_spin, 7, skeletron_prime_spin8); ai_charge(this, prime_spinspeed(this)); skeletron_prime_checkspin(this); }
void skeletron_prime_spin6(entity this) { set_animofs(this, anim_skeletron_prime_spin, 6, skeletron_prime_spin7); ai_charge(this, prime_spinspeed(this)); skeletron_prime_checkspin(this); }
void skeletron_prime_spin5(entity this) { set_animofs(this, anim_skeletron_prime_spin, 5, skeletron_prime_spin6); ai_charge(this, prime_spinspeed(this)); skeletron_prime_checkspin(this); }
void skeletron_prime_spin4(entity this) { set_animofs(this, anim_skeletron_prime_spin, 4, skeletron_prime_spin5); ai_charge(this, prime_spinspeed(this)); skeletron_prime_checkspin(this); }
void skeletron_prime_spin3(entity this) { set_animofs(this, anim_skeletron_prime_spin, 3, skeletron_prime_spin4); ai_charge(this, prime_spinspeed(this)); skeletron_prime_checkspin(this); }
void skeletron_prime_spin2(entity this) { set_animofs(this, anim_skeletron_prime_spin, 2, skeletron_prime_spin3); ai_charge(this, prime_spinspeed(this)); skeletron_prime_checkspin(this); }
void skeletron_prime_spin1(entity this) { set_animofs(this, anim_skeletron_prime_spin, 1, skeletron_prime_spin2); ai_charge(this, prime_spinspeed(this)); skeletron_prime_checkspin(this); }

void skeletron_prime_run6(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_run1); prime_anim(this); ai_run(this, 12); }
void skeletron_prime_run5(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_run6); prime_anim(this); ai_run(this, 12); }
void skeletron_prime_run4(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_run5); prime_anim(this); ai_run(this, 12); }
void skeletron_prime_run3(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_run4); prime_anim(this); ai_run(this, 12); }
void skeletron_prime_run2(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_run3); prime_anim(this); ai_run(this, 12); }
void skeletron_prime_run1(entity this) { set_anim(this, anim_skeletron_prime, skeletron_prime_run2); prime_anim(this); ai_run(this, 12); }

//===========================================================================

void skeletron_prime_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(time < this.pain_finished)
		return;
	this.pain_finished = time + 0.1;
	spamsound(this, CH_VOICE, SND_MON_SKELETRON_PRIME_PAIN, 1, ATTN_BOSS);
}

//===========================================================================

void skeletron_prime_updateresist(entity this, bool spinning)
{
	float resist_amount = (spinning) ? 0.75 : 0;
	this.resist_shells = this.resist_nails = resist_amount;
	this.resist_rockets = this.resist_cells = resist_amount;
}

void skeletron_prime_clearhitboxes(entity this)
{
	FOREACH_ENTITY_CLASS("monster_hitbox", it.realowner == this,
	{
		setthink(it, SUB_Remove);
		it.nextthink = time;
		settouch(it, func_null);
		it.solid = SOLID_NOT;
	});
}

void skeletron_prime_cleararm(entity this, int arm)
{
	// NOTE: deletion clears hitboxes
	IL_EACH(g_primeparts, it.realowner == this && it.prime_arm == arm,
	{
		skeletron_prime_clearhitboxes(it);
		delete(it);
	});
}

void skeletron_prime_gib(entity this)
{
	_sound(this, CH_VOICE, "skeletron_prime/explode.wav", 1, ATTN_BOSS);
	settouch(this, func_null);

	Send_Effect(EFFECT_EXPLOSION_SMALL, CENTER_OR_VIEWOFS(this), '0 0 0', 1);
	ThrowGib(this, this, "progs/rawbone.mdl", this.health);
}

void skeletron_prime_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.enemy = inflictor; // for gib effect

	skeletron_prime_cleararm(this, PRIME_ARM_UPR);
	skeletron_prime_cleararm(this, PRIME_ARM_DOWNR);
	skeletron_prime_cleararm(this, PRIME_ARM_UPL);
	skeletron_prime_cleararm(this, PRIME_ARM_DOWNL);

	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			skeletron_prime_gib(this);
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	skeletron_prime_gib(this);
	delete(this);
}

// TODO: this surely already exists... somewhere!
// moves v1 towards v2 at increment steps, no snapping
vector vec_drag(vector v1, vector v2, float increment);

vector skeletron_prime_randomangle(entity this)
{
	vector ang = '0 0 0';
	// never set X axis rotation
	ang.y = crandom() * 70;
	ang.z = crandom() * 70;
	return ang;
}

void skeletron_prime_hand_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CH_VOICE, "skeletron_prime/explode.wav", 1, ATTN_BOSS);
	spawn_touchblood(this, 60, inflictor);

	skeletron_prime_cleararm(this.owner, this.prime_arm);
}

.float skeletron_prime_hurttime;
void skeletron_prime_weapon_touch(entity this, entity toucher)
{
	entity own = this.realowner;
	if(toucher.classname == "monster_hitbox")
		toucher = toucher.realowner; // saves some messing around to do it early

	if(toucher.flags & FL_PROJECTILE)
		return;
	if(time < toucher.skeletron_prime_hurttime)
		return;

	if(!toucher.takedamage || !Damage_ValidTarget(toucher, own))
		return;
	
	if(toucher == this.owner || toucher.owner == own || toucher.owner == this)
		return; // try to not kill our own hands

	toucher.skeletron_prime_hurttime = time + 0.2; // no spam please

	float damage = (this.dmg) ? this.dmg : 40;
	
	T_Damage(toucher, own, own, damage, DEATH_MONSTER_SKELETRON_PRIME.m_id);
}

void prime_mine_explode(entity this)
{
	float damage = (this.dmg) ? this.dmg * 1.2 : 100;
	T_RadiusDamage(this, this.owner, damage, DEATH_MONSTER_SKELETRON_PRIME.m_id, this.enemy);

	_sound(this, CH_SHOTS, "weapons/r_exp3b.wav", 1, ATTN_NORM);

	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);

	entity exp = spawn();
	exp.nextthink = time;
	setthink(exp, s_explode1);
	_setmodel(exp, "progs/s_explod.spr");
	setsize(exp, '0 0 0', '0 0 0');
	setorigin(exp, this.origin);

	delete(this);
}

void prime_mine_touch(entity this, entity toucher)
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
	if(toucher.takedamage) // yoder mod, jan 05 2021
	{
		float damage = (this.dmg) ? this.dmg : 80;
	
		T_Damage(toucher, this, this.owner, damage, DEATH_MONSTER_SKELETRON_PRIME.m_id);

		this.enemy = toucher; // prevent radius damage on them
		settouch(this, func_null);
		setthink(this, prime_mine_explode);
		this.nextthink = time;
	}
	else if(time >= this.pain_finished)
	{
		this.pain_finished = time;
		_sound(this, CH_VOICE, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	}
}

void prime_mine_fire(entity this, vector org)
{
	_sound(this, CH_WEAPON_SINGLE, "weapons/grenade.wav", 1, ATTN_BOSS);

	entity missile = new(prime_mine);
	missile.solid = SOLID_BBOX;
	missile.flags = FL_PROJECTILE;
	missile.owner = this;
	missile.realowner = this;
	missile.clipgroup = this.clipgroup;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.projectiledeathtype = DEATH_MONSTER_SKELETRON_PRIME.m_id;
	missile.dmg = 80;
	missile.bouncefactor = 0.7;
	missile.bouncestop = 0.01;
	missile.gravity = 1;

	vector dir = normalize(vec2(this.owner.enemy.origin - org));
	missile.velocity = dir * 200;
	missile.velocity_z = 300;

	missile.angles = vectoangles(missile.velocity);
	//missile.angles_z = (random() > 0.5) ? 30 : -30;
	missile.avelocity = '300 300 300';

	settouch(missile, prime_mine_touch);

	missile.nextthink = time + 4;
	setthink(missile, prime_mine_explode);

	_setmodel(missile, "progs/prime_mine.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, org);

	IL_PUSH(g_projectiles, missile);

	//CSQCProjectile(missile, false, PROJECTILE_CURSED_SKULL, true);
}

void prime_laser_fire(entity this, vector org)
{
	entity targ = this.owner.enemy;
	vector targ_org = (targ.absmin + targ.absmax) * 0.5;
	vector enemy_org = ai_shotlead(org, targ_org, targ.velocity, 600);

	entity newmis = LaunchLaser(this, org, enemy_org - org);
	newmis.projectiledeathtype = DEATH_MONSTER_SKELETRON_PRIME.m_id;
	_sound(this, CH_WEAPON_SINGLE, "skeletron_prime/laser_fire.wav", 1, ATTN_NORM);
}

.vector ideal_angle;
void skeletron_prime_part_think(entity this)
{
	this.nextthink = time;

	if(this.owner.health <= 0 || wasfreed(this.owner))
	{
		skeletron_prime_clearhitboxes(this);
		delete(this);
		return;
	}

	switch(this.prime_type)
	{
		case PRIME_CANNON:
		case PRIME_SAW:
		case PRIME_VICE:
		case PRIME_LASER:
		{
			if((this.prime_type == PRIME_VICE || this.prime_type == PRIME_SAW) && time >= this.idle_finished)
			{
				this.idle_finished = time + 0.1;
				this.frame = (this.frame == 1) ? 0 : 1;
			}

			this.ideal_angle = '0 0 0';
			if(this.prime_type == PRIME_LASER)
				this.ideal_angle_y = 90 * this.angle; // aim roughly forward? TODO give it some variation!

			vector org = gettaginfo(this, 0);

			if(this.owner.enemy && time >= this.attack_finished)
			{
				if(this.prime_type == PRIME_CANNON)
				{
					prime_mine_fire(this, org);
					this.attack_finished = time + 1 + random();
				}
				else if(this.prime_type == PRIME_LASER)
				{
					prime_laser_fire(this, org);
					this.attack_finished = time + 1.5 + (random() * 1.5);
				}
			}

			FOREACH_ENTITY_RADIUS(org, 64, it != this,
			{
				if (it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY)
					skeletron_prime_weapon_touch(this, it);
			});
			break;
		}
		// TODO: seperate logic for arms
		case PRIME_ELBOW:
		case PRIME_FOREARM:
		{
			if(time >= this.attack_finished)
			{
				if(!this.owner.enemy || (this.prime_arm == PRIME_ARM_UPR || this.prime_arm == PRIME_ARM_UPL) || time > this.owner.attack_finished || random() < 0.4)
				{
					this.attack_finished = time + 1;
					this.ideal_angle = '0 45 -35';
					if(this.prime_type == PRIME_FOREARM)
						this.ideal_angle_x = -45 * this.angle;
					this.attack_state = 1;
				}
				else
				{
					this.attack_finished = time + 0.5 + random();
					this.ideal_angle = '0 90 0'; // in front? TODO: randomness!
					this.attack_state = 0;
				}
			}
			break;
		}
	}

	vector ideal = this.ideal_angle * this.angle;

	if(this.prime_arm == PRIME_ARM_DOWNR || this.prime_arm == PRIME_ARM_DOWNL)
		ideal.z *= -1;

	float aspeed = ((this.attack_state) ? 3 : 1);
	this.angles = vec_drag(this.angles, ideal, aspeed);
}

void skeletron_prime_setmover(entity this, int direction)
{
	this.angle = direction;

	this.angles = skeletron_prime_randomangle(this);
	this.ideal_angle = this.angles;
}


// called by hitboxes
void skeletron_prime_hitbox_proc(entity this)
{
	if(this.owner.health < 1 || !this.owner || wasfreed(this.owner))
	{
		delete(this);
		return;
	}

	setthink(this, skeletron_prime_hitbox_proc);
	this.nextthink = time;

	// position to current hand
	vector org = gettaginfo(this.owner, 0);
	setorigin(this, org);
	this.angles = this.owner.angles;
}

void skeletron_prime_spawnhitbox(entity this)
{
	entity ent = spawn();
	ent.classname = "monster_hitbox";
	ent.owner = this;
	ent.realowner = this;
	ent.clipgroup = this.clipgroup;
	ent.takedamage = DAMAGE_AIM;
	ent.solid = SOLID_BBOX;
	setsize(ent, '-24 -24 0', '24 24 64');
	ent.angles = this.angles;
	setorigin(ent, this.origin);
	setthink(ent, skeletron_prime_hitbox_proc);
	ent.nextthink = time;
}

entity skeletron_prime_spawnpart(entity this, entity attach, string partmdl, vector offset, int parm, int ptype, int moveangle)
{
	entity fist = new(skeletron_prime_part);
	fist.solid = SOLID_NOT;
	_setmodel(fist, partmdl);
	setsize(fist, '-24 -24 -16', '24 24 24');
	set_movetype(fist, MOVETYPE_NONE);
	fist.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	fist.pos1 = offset;
	fist.clipgroup = this.clipgroup;
	fist.projectiledeathtype = DEATH_MONSTER_SKELETRON_PRIME.m_id;
	fist.owner = this;
	fist.realowner = this;
	setthink(fist, skeletron_prime_part_think);
	fist.nextthink = time;
	fist.dmg = 40;
	fist.attack_finished = time + 1 + (2 * random());
	fist.cnt = 0;
	fist.goalentity = attach;
	fist.prime_arm = parm;
	fist.prime_type = ptype;
	fist.colormod = this.colormod;

	setattachment(fist, attach, "");
	setorigin(fist, offset);
	//fist.angles = this.angles;

	skeletron_prime_setmover(fist, moveangle);

	switch(ptype)
	{
		case PRIME_CANNON:
		case PRIME_SAW:
		case PRIME_VICE:
		case PRIME_LASER:
		{
			// attached entities cannot be targeted directly
			// so spawn a hitbox for it...
			fist.takedamage = DAMAGE_AIM;
			fist.health = 700;
			fist.max_health = fist.health;
			fist.th_pain = skeletron_prime_pain;
			fist.th_die = skeletron_prime_hand_die;
			skeletron_prime_spawnhitbox(fist);
			break;
		}
	}

	IL_PUSH(g_primeparts, fist);
	
	return fist;
}

void skeletron_prime_spawnparts(entity this)
{
	entity part;

	// upper right arm
	part = skeletron_prime_spawnpart(this, this, "progs/skeletron_prime_elbowr.mdl", '-20 -60 -16', PRIME_ARM_UPR, PRIME_ELBOW, 1);
	part = skeletron_prime_spawnpart(this, part, "progs/skeletron_prime_forearmr.mdl", '0 -120 0', PRIME_ARM_UPR, PRIME_FOREARM, 1);
	skeletron_prime_spawnpart(this, part, "progs/skeletron_prime_laser.mdl", '0 -120 0', PRIME_ARM_UPR, PRIME_LASER, 1);

	// lower right arm
	part = skeletron_prime_spawnpart(this, this, "progs/skeletron_prime_elbowr.mdl", '-20 -60 -32', PRIME_ARM_DOWNR, PRIME_ELBOW, 1);
	part = skeletron_prime_spawnpart(this, part, "progs/skeletron_prime_forearmr.mdl", '0 -120 0', PRIME_ARM_DOWNR, PRIME_FOREARM, 1);
	skeletron_prime_spawnpart(this, part, "progs/skeletron_prime_saw.mdl", '0 -120 0', PRIME_ARM_DOWNR, PRIME_SAW, 1);

	// upper left arm
	part = skeletron_prime_spawnpart(this, this, "progs/skeletron_prime_elbowl.mdl", '-20 60 -16', PRIME_ARM_UPL, PRIME_ELBOW, -1);
	part = skeletron_prime_spawnpart(this, part, "progs/skeletron_prime_forearml.mdl", '0 120 0', PRIME_ARM_UPL, PRIME_FOREARM, -1);
	skeletron_prime_spawnpart(this, part, "progs/skeletron_prime_cannon.mdl", '0 120 0', PRIME_ARM_UPL, PRIME_CANNON, -1);

	// lower left arm
	part = skeletron_prime_spawnpart(this, this, "progs/skeletron_prime_elbowl.mdl", '-20 60 -32', PRIME_ARM_DOWNL, PRIME_ELBOW, -1);
	part = skeletron_prime_spawnpart(this, part, "progs/skeletron_prime_forearml.mdl", '0 120 0', PRIME_ARM_DOWNL, PRIME_FOREARM, -1);
	skeletron_prime_spawnpart(this, part, "progs/skeletron_prime_vice.mdl", '0 120 0', PRIME_ARM_DOWNL, PRIME_VICE, -1);
}

/*QUAKED monster_skeletron_prime (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_skeletron_prime) { monster_start(this, true, MON_SKELETRON_PRIME); }
#endif // SVQC

#ifdef SVQC
METHOD(SkeletronPrime, mr_setup, bool(SkeletronPrime this, entity actor))
{
	TC(SkeletronPrime, this);

	precache_model("progs/prime_mine.mdl");
	precache_model("progs/skeletron_prime_elbowl.mdl");
	precache_model("progs/skeletron_prime_elbowr.mdl");
	precache_model("progs/skeletron_prime_forearml.mdl");
	precache_model("progs/skeletron_prime_forearmr.mdl");
	precache_model("progs/skeletron_prime_cannon.mdl");
	precache_model("progs/skeletron_prime_saw.mdl");
	precache_model("progs/skeletron_prime_vice.mdl");
	precache_model("progs/skeletron_prime_laser.mdl");
	precache_sound("skeletron_prime/explode.wav");
	precache_sound("skeletron_prime/sight.wav");
	precache_sound("skeletron_prime/laser_fire.wav");
	precache_sound("weapons/grenade.wav");
	precache_sound("weapons/r_exp3b.wav");
	precache_sound("weapons/bounce.wav");

	if(!actor.clipgroup)
		actor.clipgroup = CLIPGROUP_SKELETRON_PRIME;

	actor.health = 6000;
	actor.th_stand = skeletron_prime_stand1;
	actor.th_walk = skeletron_prime_walk1;
	actor.th_run = skeletron_prime_run1;
	actor.th_pain = skeletron_prime_pain;
	actor.th_die = skeletron_prime_die;

	actor.checkattack = SkeletronPrimeCheckAttack;

	skeletron_prime_spawnparts(actor);

	// after hands are spawned
	skeletron_prime_updateresist(actor, false);

	return true;
}
METHOD(SkeletronPrime, mr_sight, bool(SkeletronPrime this, entity actor))
{
	TC(SkeletronPrime, this);

	_sound(actor, CH_VOICE, "skeletron_prime/sight.wav", 1, ATTN_BOSS);

	return true;
}
#endif
