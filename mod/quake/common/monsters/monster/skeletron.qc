#include "skeletron.qh"

#ifdef SVQC
const int anim_skeletron = 0;
const int anim_skeletron_spin = 1; // '1 8 0'

const int CLIPGROUP_SKELETRON = 24; // randomly picked! search for CLIPGROUP_ to find others used

.entity skeletron_elbowl;
.entity skeletron_forearml;
.entity skeletron_elbowr;
.entity skeletron_forearmr;
.entity skeletron_handl;
.entity skeletron_handr;

..entity skeletron_field;

.float skeletron_spindelay;

.float skeletron_dmgtime;

void skeletron_spin1(entity this);
void skeletron_run1(entity this);
void skeletron_side1(entity this);

void Skeletron_SpinTouch(entity this, entity toucher);

void skeletron_skull_attack(entity this, vector org);

void skeletron_updateresist(entity this, bool spinning);

/*
=================
SkeletronCheckAttack
=================
*/
bool SkeletronCheckAttack(entity this)
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
			skeletron_run1(this);
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
			skeletron_run1(this);
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

	int hands = 0;
	if(this.(skeletron_handr))
		hands += 1;
	if(this.(skeletron_handl))
		hands += 1;

	// won't be called when spinning
	if(autocvar_skill >= 2 && hands < 2 && time > this.attack2_finished && random() < chance)
	{
		// doesn't cancel out movement, just fire at will!
		this.attack2_finished = time + (random() * ((hands == 0) ? 0.6 : 1.3));

		skeletron_skull_attack(this, this.origin + '0 0 16');
	}

	if(time > this.skeletron_spindelay && random() < chance)
	{
		this.skeletron_spindelay = time + 20;
		if(autocvar_skill >= 2)
			this.attack_finished = time + 5; // shorter but quicker
		else
			this.attack_finished = time + 7;
		skeletron_updateresist(this, true);
		this.attack_state = AS_STRAIGHT;
		settouch(this, Skeletron_SpinTouch);
		_sound(this, CH_VOICE, "skeletron/sight.wav", 1, ATTN_BOSS);
		skeletron_spin1(this);
		return true;
	}

	if(this.enemy_range == RANGE_MID)
	{
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
			skeletron_run1(this);
		}
	}
	else
	{
		if(vdist(targ.origin - this.origin, >, 300))
		{
			if(this.attack_state != AS_DODGING)
			{
				this.attack_state = AS_DODGING;
				skeletron_side1(this);
			}
		}
		else
		{
			if(this.attack_state != AS_SLIDING)
			{
				this.attack_state = AS_SLIDING;
				skeletron_side1(this);
			}
		}
	}
	
	return false;
}

void Skeletron_SpinTouch(entity this, entity toucher)
{
	if(this.health <= 0 || !this.takedamage)
		return;

	if(toucher.takedamage && this.skeletron_dmgtime < time)
	{
		float damage = (time > this.attack_finished) ? 20 : 40;
		float ldmg = damage + 10*random();
		T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_SKELETRON.m_id);
		this.skeletron_dmgtime = time + 0.5;
	}
}

void SkeletronStopSide(entity this)
{
	this.attack_state = AS_STRAIGHT;
	setthink(this, skeletron_run1);
}

void skeletron_stand1(entity this);
void skeletron_stand6(entity this) { set_anim(this, anim_skeletron, skeletron_stand1); ai_stand(this); }
void skeletron_stand5(entity this) { set_anim(this, anim_skeletron, skeletron_stand6); ai_stand(this); }
void skeletron_stand4(entity this) { set_anim(this, anim_skeletron, skeletron_stand5); ai_stand(this); }
void skeletron_stand3(entity this) { set_anim(this, anim_skeletron, skeletron_stand4); ai_stand(this); }
void skeletron_stand2(entity this) { set_anim(this, anim_skeletron, skeletron_stand3); ai_stand(this); }
void skeletron_stand1(entity this) { set_anim(this, anim_skeletron, skeletron_stand2); ai_stand(this); }

void skeletron_walk1(entity this);
void skeletron_walk8(entity this) { set_anim(this, anim_skeletron, skeletron_walk1); ai_walk(this, 8); }
void skeletron_walk7(entity this) { set_anim(this, anim_skeletron, skeletron_walk8); ai_walk(this, 8); }
void skeletron_walk6(entity this) { set_anim(this, anim_skeletron, skeletron_walk7); ai_walk(this, 8); }
void skeletron_walk5(entity this) { set_anim(this, anim_skeletron, skeletron_walk6); ai_walk(this, 8); }
void skeletron_walk4(entity this) { set_anim(this, anim_skeletron, skeletron_walk5); ai_walk(this, 8); }
void skeletron_walk3(entity this) { set_anim(this, anim_skeletron, skeletron_walk4); ai_walk(this, 8); }
void skeletron_walk2(entity this) { set_anim(this, anim_skeletron, skeletron_walk3); ai_walk(this, 8); }
void skeletron_walk1(entity this) { set_anim(this, anim_skeletron, skeletron_walk2); ai_walk(this, 8); }

void skeletron_side8(entity this) { set_anim(this, anim_skeletron, skeletron_run1); ai_run(this, 12); SkeletronStopSide(this); }
void skeletron_side7(entity this) { set_anim(this, anim_skeletron, skeletron_side8); ai_run(this, 12); }
void skeletron_side6(entity this) { set_anim(this, anim_skeletron, skeletron_side7); ai_run(this, 12); }
void skeletron_side5(entity this) { set_anim(this, anim_skeletron, skeletron_side6); ai_run(this, 12); }
void skeletron_side4(entity this) { set_anim(this, anim_skeletron, skeletron_side5); ai_run(this, 12); }
void skeletron_side3(entity this) { set_anim(this, anim_skeletron, skeletron_side4); ai_run(this, 12); }
void skeletron_side2(entity this) { set_anim(this, anim_skeletron, skeletron_side3); ai_run(this, 12); }
void skeletron_side1(entity this) { set_anim(this, anim_skeletron, skeletron_side2); ai_run(this, 12); }

void skeletron_checkspin(entity this)
{
	if(time >= this.attack_finished)
	{
		skeletron_updateresist(this, false);
		settouch(this, func_null);
		set_anim(this, anim_skeletron, skeletron_run1);
	}
}

float skel_spinspeed(entity this)
{
	return (autocvar_skill >= 2) ? 32 : 22;
}

void skeletron_spin8(entity this) { set_animofs(this, anim_skeletron_spin, 8, skeletron_spin1); ai_charge(this, skel_spinspeed(this)); skeletron_checkspin(this); }
void skeletron_spin7(entity this) { set_animofs(this, anim_skeletron_spin, 7, skeletron_spin8); ai_charge(this, skel_spinspeed(this)); skeletron_checkspin(this); }
void skeletron_spin6(entity this) { set_animofs(this, anim_skeletron_spin, 6, skeletron_spin7); ai_charge(this, skel_spinspeed(this)); skeletron_checkspin(this); }
void skeletron_spin5(entity this) { set_animofs(this, anim_skeletron_spin, 5, skeletron_spin6); ai_charge(this, skel_spinspeed(this)); skeletron_checkspin(this); }
void skeletron_spin4(entity this) { set_animofs(this, anim_skeletron_spin, 4, skeletron_spin5); ai_charge(this, skel_spinspeed(this)); skeletron_checkspin(this); }
void skeletron_spin3(entity this) { set_animofs(this, anim_skeletron_spin, 3, skeletron_spin4); ai_charge(this, skel_spinspeed(this)); skeletron_checkspin(this); }
void skeletron_spin2(entity this) { set_animofs(this, anim_skeletron_spin, 2, skeletron_spin3); ai_charge(this, skel_spinspeed(this)); skeletron_checkspin(this); }
void skeletron_spin1(entity this) { set_animofs(this, anim_skeletron_spin, 1, skeletron_spin2); ai_charge(this, skel_spinspeed(this)); skeletron_checkspin(this); }

void skeletron_run6(entity this) { set_anim(this, anim_skeletron, skeletron_run1); ai_run(this, 12); }
void skeletron_run5(entity this) { set_anim(this, anim_skeletron, skeletron_run6); ai_run(this, 12); }
void skeletron_run4(entity this) { set_anim(this, anim_skeletron, skeletron_run5); ai_run(this, 12); }
void skeletron_run3(entity this) { set_anim(this, anim_skeletron, skeletron_run4); ai_run(this, 12); }
void skeletron_run2(entity this) { set_anim(this, anim_skeletron, skeletron_run3); ai_run(this, 12); }
void skeletron_run1(entity this) { set_anim(this, anim_skeletron, skeletron_run2); ai_run(this, 12); }

//===========================================================================

void skeletron_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(time < this.pain_finished)
		return;
	this.pain_finished = time + 0.1;
	spamsound(this, CH_VOICE, SND_MON_SKELETRON_PAIN, 1, ATTN_BOSS);
}

//===========================================================================

void skeletron_updateresist(entity this, bool spinning)
{
	float resist_amount = 0;
	if(!spinning && autocvar_skill >= 2)
	{
		if(this.(skeletron_handr))
			resist_amount += 0.33;
		if(this.(skeletron_handl))
			resist_amount += 0.33;
	}
	this.resist_shells = this.resist_nails = resist_amount;
	this.resist_rockets = this.resist_cells = resist_amount;
}

void skeletron_clearhitboxes(entity this)
{
	FOREACH_ENTITY_CLASS("monster_hitbox", it.realowner == this,
	{
		setthink(it, SUB_Remove);
		it.nextthink = time;
		settouch(it, func_null);
		it.solid = SOLID_NOT;
	});
}

void skeletron_cleararm(entity this, bool right)
{
	// NOTE: deletion nullifies the fields and clears hitboxes
	if(right)
	{
		if(this.(skeletron_elbowr)) delete(this.(skeletron_elbowr));
		if(this.(skeletron_forearmr)) delete(this.(skeletron_forearmr));
		if(this.(skeletron_handr)) delete(this.(skeletron_handr));
	}
	else
	{
		if(this.(skeletron_elbowl)) delete(this.(skeletron_elbowl));
		if(this.(skeletron_forearml)) delete(this.(skeletron_forearml));
		if(this.(skeletron_handl)) delete(this.(skeletron_handl));
	}

	// now update resistances?
	skeletron_updateresist(this, (time < this.attack_finished));
}

void skeletron_gib(entity this)
{
	_sound(this, CH_VOICE, "skeletron/death.wav", 1, ATTN_BOSS);
	spawn_touchblood(this, 60, this.enemy);
	ThrowGib(this, this, "progs/gib1.mdl", -100);
	ThrowGib(this, this, "progs/gib2.mdl", -100);
	ThrowGib(this, this, "progs/gib3.mdl", -100);
	ThrowGib(this, this, "progs/gib1.mdl", -100);
	ThrowGib(this, this, "progs/gib2.mdl", -100);
	ThrowGib(this, this, "progs/gib3.mdl", -100);
	ThrowGib(this, this, "progs/gib1.mdl", -100);
	ThrowGib(this, this, "progs/gib2.mdl", -100);
	ThrowGib(this, this, "progs/gib3.mdl", -100);
}

void skeletron_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.enemy = inflictor; // for gib effect

	skeletron_cleararm(this, true);
	skeletron_cleararm(this, false);

	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			skeletron_gib(this);
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	skeletron_gib(this);
	delete(this);
}

// TODO: this surely already exists... somewhere!
// moves v1 towards v2 at increment steps, no snapping
vector vec_drag(vector v1, vector v2, float increment);

vector skeletron_randomangle(entity this)
{
	vector ang = '0 0 0';
	// never set X axis rotation
	ang.y = crandom() * 70;
	ang.z = crandom() * 70;
	return ang;
}

void skeletron_hand_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CH_VOICE, "skeletron/death.wav", 1, ATTN_BOSS);
	spawn_touchblood(this, 60, inflictor);

	if(this.model == "progs/skeletron_handr.mdl")
		skeletron_cleararm(this.owner, true);
	else
		skeletron_cleararm(this.owner, false);
}

.float skeletron_hurttime;
void skeletron_hand_touch(entity this, entity toucher)
{
	entity own = this.realowner;
	if(toucher.classname == "monster_hitbox")
		toucher = toucher.realowner; // saves some messing around to do it early

	if(toucher.flags & FL_PROJECTILE)
		return;
	if(time < toucher.skeletron_hurttime)
		return;

	if(!toucher.takedamage || !Damage_ValidTarget(toucher, own))
		return;
	
	if(toucher == this.owner || toucher.owner == own || toucher.owner == this)
		return; // try to not kill our own hands

	toucher.skeletron_hurttime = time + 0.2; // no spam please

	float damage = (this.dmg) ? this.dmg : 40;
	
	T_Damage(toucher, own, own, damage, DEATH_MONSTER_SKELETRON.m_id);
}

void skeletron_skull_touch(entity this, entity toucher)
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
		float damage = (this.dmg) ? this.dmg : 40;
	
		T_Damage(toucher, this, this.owner, damage, DEATH_MONSTER_SKELETRON.m_id);
	}

	te_explosion2(findbetterlocation(this.origin, 8), 240, 5);
	delete(this);
}

void skeletron_skull_think(entity this)
{
	if(time > this.count)
	{
		delete(this);
		return;
	}

	this.nextthink = time;

	float velmax = 1200;
	float vel = vlen(this.velocity);
	if(vel == 0)
		vel = 1; // hack to make sure avelocity never divs by 0

	// gently home in
	entity targ = this.owner.enemy;
	if(targ && time < this.cnt)
	{
		vector targ_org = CENTER_OR_VIEWOFS(targ);
		vector desireddir = normalize(targ_org - this.origin);
		vector olddir = normalize(this.velocity);
		float turnrate = 0.2;
		vector newdir = normalize(olddir + desireddir * turnrate);
		this.velocity = newdir * vel;
	}

	if(vel < velmax)
	{
		// copied from PM_Accelerate
		float wishspeed = velmax;
		vector wishdir = normalize(this.velocity);
		float currentspeed = (this.velocity * wishdir);
		float addspeed = wishspeed - currentspeed;
		if(addspeed > 0)
		{
			float accelspeed = 0.25 * PHYS_INPUT_TIMELENGTH * wishspeed;
			if(accelspeed > addspeed)
				accelspeed = addspeed;

			this.velocity += accelspeed * wishdir;
		}
	}

	this.angles = vectoangles(this.velocity);
	//UpdateCSQCProjectile(this);
}

void skeletron_skull_attack(entity this, vector org)
{
	entity missile = new(cursed_skull);
	missile.solid = SOLID_BBOX;
	missile.flags = FL_PROJECTILE;
	missile.owner = this;
	missile.realowner = this;
	missile.clipgroup = this.clipgroup;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.projectiledeathtype = DEATH_MONSTER_SKELETRON.m_id;
	missile.dmg = 50;

	vector dir = normalize(this.enemy.origin - this.origin);
	missile.velocity = dir * 100;
	//missile.velocity_z = 200;

	missile.angles = vectoangles(missile.velocity);
	//missile.angles_z = (random() > 0.5) ? 30 : -30;

	settouch(missile, skeletron_skull_touch);

	missile.cnt = time + 1.25; // keep homing for this long
	missile.count = time + 8;
	missile.nextthink = time;
	setthink(missile, skeletron_skull_think);

	_setmodel(missile, "progs/cursed_skull.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, org);

	IL_PUSH(g_projectiles, missile);

	//CSQCProjectile(missile, false, PROJECTILE_CURSED_SKULL, true);
}

.vector ideal_angle;
void skeletron_part_think(entity this)
{
	this.nextthink = time;

	if(this.owner.health <= 0 || wasfreed(this.owner))
	{
		delete(this);
		return;
	}

	if(this.model == "progs/skeletron_handr.mdl" || this.model == "progs/skeletron_handl.mdl")
	{
		vector org = gettaginfo(this, 0);
		
		FOREACH_ENTITY_RADIUS(org, 64, it != this,
		{
			if (it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY)
				skeletron_hand_touch(this, it);
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
			if(!this.owner.enemy || time < this.owner.attack_finished || random() < 0.4)
			{
				this.attack_finished = time + 1;
				this.ideal_angle = '0 0 -45';
				this.attack_state = 1;
			}
			else
			{
				this.attack_finished = time + 0.5 + random();
				this.ideal_angle = '0 90 0'; // in front? TODO: randomness!
				this.attack_state = 0;
			}
		}
	}
}

void skeletron_part_delete(entity this)
{
	skeletron_clearhitboxes(this);

	if(this.owner)
		this.owner.(this.skeletron_field) = NULL;
	delete_fn(this);
}

void skeletron_setmover(entity this, int direction)
{
	this.angle = direction;
	this.count = 1;

	this.angles = skeletron_randomangle(this);
	this.ideal_angle = this.angles;
}


// called by hitboxes
void skeletron_hitbox_proc(entity this)
{
	if(this.owner.health < 1 || !this.owner || wasfreed(this.owner))
	{
		delete(this);
		return;
	}

	setthink(this, skeletron_hitbox_proc);
	this.nextthink = time;

	// position to current hand
	vector org = gettaginfo(this.owner, 0);
	setorigin(this, org);
	this.angles = this.owner.angles;
}

void skeletron_spawnhitbox(entity this)
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
	setthink(ent, skeletron_hitbox_proc);
	ent.nextthink = time;
}

entity skeletron_spawnpart(entity this, entity attach, string partmdl, vector offset, .entity fld, bool isarm, int moveangle)
{
	entity fist = new(skeletron_part);
	fist.solid = SOLID_NOT;
	_setmodel(fist, partmdl);
	setsize(fist, '-24 -24 -16', '24 24 24');
	set_movetype(fist, MOVETYPE_NONE);
	fist.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	fist.pos1 = offset;
	fist.clipgroup = this.clipgroup;
	fist.projectiledeathtype = DEATH_MONSTER_SKELETRON.m_id;
	fist.owner = this;
	fist.realowner = this;
	setthink(fist, skeletron_part_think);
	fist.nextthink = time;
	fist.dmg = 40;
	fist.skeletron_field = fld;
	fist.attack_finished = time + 1 + (2 * random());
	fist.cnt = 0;
	fist.dtor = skeletron_part_delete;
	fist.goalentity = attach;
	fist.colormod = this.colormod;

	setattachment(fist, attach, "");
	setorigin(fist, offset);
	//fist.angles = this.angles;

	if(isarm)
		skeletron_setmover(fist, moveangle);
	else
	{
		// attached entities cannot be targeted directly
		// so spawn a hitbox for it...
		fist.takedamage = DAMAGE_AIM;
		fist.health = 500;
		fist.max_health = fist.health;
		fist.th_pain = skeletron_pain;
		fist.th_die = skeletron_hand_die;
		skeletron_spawnhitbox(fist);
	}

	this.(fld) = fist;
	
	return fist;
}

void skeletron_spawnparts(entity this)
{
	entity part;
	part = skeletron_spawnpart(this, this, "progs/skeletron_elbowr.mdl", '20 -60 -16', skeletron_elbowr, true, 1);
	part = skeletron_spawnpart(this, part, "progs/skeletron_forearmr.mdl", '0 -120 0', skeletron_forearmr, true, 1);
	skeletron_spawnpart(this, part, "progs/skeletron_handr.mdl", '0 -120 0', skeletron_handr, false, 0);

	part = skeletron_spawnpart(this, this, "progs/skeletron_elbowl.mdl", '20 60 -16', skeletron_elbowl, true, -1);
	part = skeletron_spawnpart(this, part, "progs/skeletron_forearml.mdl", '0 120 0', skeletron_forearml, true, -1);
	skeletron_spawnpart(this, part, "progs/skeletron_handl.mdl", '0 120 0', skeletron_handl, false, 0);
}

/*QUAKED monster_skeletron (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_skeletron) { monster_start(this, true, MON_SKELETRON); }
#endif // SVQC

#ifdef SVQC
METHOD(Skeletron, mr_setup, bool(Skeletron this, entity actor))
{
	TC(Skeletron, this);

	precache_model("progs/cursed_skull.mdl");
	precache_model("progs/skeletron_elbowl.mdl");
	precache_model("progs/skeletron_elbowr.mdl");
	precache_model("progs/skeletron_forearml.mdl");
	precache_model("progs/skeletron_forearmr.mdl");
	precache_model("progs/skeletron_handl.mdl");
	precache_model("progs/skeletron_handr.mdl");
	precache_sound("skeletron/death.wav");
	precache_sound("weapons/grenade.wav");
	precache_sound("weapons/grape_impact.wav");
	precache_sound("blob/land1.wav");
	precache_sound("skeletron/sight.wav");

	if(!actor.clipgroup)
		actor.clipgroup = CLIPGROUP_SKELETRON;

	actor.health = 5000;
	actor.th_stand = skeletron_stand1;
	actor.th_walk = skeletron_walk1;
	actor.th_run = skeletron_run1;
	actor.th_pain = skeletron_pain;
	actor.th_die = skeletron_die;

	actor.checkattack = SkeletronCheckAttack;

	skeletron_spawnparts(actor);

	// after hands are spawned
	skeletron_updateresist(actor, false);

	return true;
}
METHOD(Skeletron, mr_sight, bool(Skeletron this, entity actor))
{
	TC(Skeletron, this);

	_sound(actor, CH_VOICE, "skeletron/sight.wav", 1, ATTN_BOSS);

	return true;
}
#endif
