#include "amalgam.qh"

#ifdef SVQC
const int anim_amalgam_idle = 0; //'0 38 0'
const int anim_amalgam_shoot = 39; //'39 50 0'
const int anim_amalgam_death = 51; //'51 66 0'
const int anim_amalgam_pain = 67; //'67 70 0'
const int anim_amalgam_painb = 71; //'71 80 0'

/*
==============================================================================

AMALGAM
Originally from reliq
by Fairweather

==============================================================================
*/

void SpawnMeatUndConcreteSpray(entity this, vector org, vector vel)
{
	int r = floor(random() * 9);
	string gibmdl = string_null;
	vector mvel = vel;
	mvel.z += 250 + 50 * random();

	switch(r)
	{
		case 0: gibmdl = "progs/gibs/gib_conc_1.mdl"; break;
		case 1: gibmdl = "progs/gibs/gib_conc_2.mdl"; break;
		case 2: gibmdl = "progs/gibs/gib_conc_3.mdl"; break;
		case 3: gibmdl = "progs/gibs/gib_gen_1.mdl"; break;
		case 4: gibmdl = "progs/gibs/gib_gen_2.mdl"; break;
		case 5: gibmdl = "progs/gibs/gib_gen_3.mdl"; break;
		case 6: gibmdl = "progs/gibs/gib_gen_4.mdl"; break;
		case 7: gibmdl = "progs/gibs/gib_gen_5.mdl"; break;
		default: gibmdl = "progs/gibs/gib_gen_6.mdl"; break;
	}

	entity gib = ThrowGib(this, NULL, gibmdl, 0); // health doesn't matter, we set velocity ourselves
	gib.velocity = mvel;
	gib.avelocity = '3000 1000 2000';
	gib.nextthink = time + 15 + (random() * 15);
}

void SpawnMeatUndConcreteBurst(entity this, vector org, vector vel, int scount, bool randomOrigin)
{
	for(int i = 0; i < scount; i = i + 1)
	{
		vector randvel = vel;
		randvel = randvel + v_right * (crandom() * 200);
		randvel = randvel + v_up * (crandom() * 200);
		randvel = randvel + v_forward * (crandom() * 200);

		if(randomOrigin)
		{
			org.x += crandom() * 24;
			org.y += crandom() * 24;
			org.z += crandom() * 50 + 24;
		}
		SpawnMeatUndConcreteSpray(this, org, randvel);
	}
}

void GoopBlood(entity this, bool forcebig);
void AmalGoop_Touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(!this.cnt)
	{
		_sound(this, CHAN_BODY, "weapons/tink1.wav", 1, ATTN_STATIC);
		this.cnt = true;
	}

	// TODO
	if(IS_PLAYER(this.owner) && (!toucher || toucher.solid == SOLID_BSP))
	{
		this.solid = SOLID_TRIGGER;
		setorigin(this, this.origin);
	}

	// NOTE: in the original they prevented all non-player damage
	// but also included a monster check! presumably it was meant to attack everything valid
	// without activating triggers
	if(!toucher.takedamage)
		return;

	if(this.attack_finished > time)
		return;

	entity attacker = this.owner;
	if(!attacker || wasfreed(attacker))
		attacker = this;

	T_Damage(toucher, this, attacker, this.dmg, this.projectiledeathtype);

	if(random() > 0.5)
		_sound(this, CH_VOICE, "amalg/amalg_goop1.wav", 0.6, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "amalg/amalg_goop2.wav", 0.6, ATTN_NORM);

	GoopBlood(this, 0);

	settouch(this, func_null);
	setthink(this, SUB_Remove);
	this.nextthink = time;
	this.solid = SOLID_NOT;
}

void AmalGoop_Die_Loop(entity this)
{
	this.frame += 1;
	this.alpha -= 0.04;

	if(this.frame >= 20)
	{
		delete(this);
		return;
	}
	setthink(this, AmalGoop_Die_Loop);
	this.nextthink = time + 0.05;
}

void AmalGoop_Die(entity this)
{
	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_NOT;
	this.classname = "impact";
	
	this.nextthink = time;
	
	this.frame = 0;
	this.alpha = 1;
	
	if(this.model == "progs/proj_amalgoop.mdl")
		_setmodel(this, "progs/proj_amalgoop_pop.mdl");
	else
		_setmodel(this, "progs/proj_amalgoop_explo_pop.mdl");
	setsize(this, '0 0 0', '0 0 0');
		
	setthink(this, AmalGoop_Die_Loop);
}

void AmalGoop_Drop(entity this)
{
	entity item = spawn();
	item.origin = this.origin + '0 0 24';

	item.velocity_z = 300 + (random() * 100);
	item.velocity_x = crandom() * 300;
	item.velocity_y = crandom() * 300;
	item.avelocity = '100 100 100';
	
	item.flags = FL_ITEM; // TODO: they're relying on this for the extra hitbox! make a projectile and a separate object for placement
	item.solid = SOLID_TRIGGER;
	set_movetype(item, MOVETYPE_TOSS);
	item.classname = "AmalGoop";
	_setmodel(item, "progs/proj_amalgoop.mdl");
	setsize(item, '0 0 0', '0 0 0');
	//item.angles_y = (random() * (random() * 256));
	
	vector goop_spin = '0 0 0';
	goop_spin_y = (300 + random() * 600);
	item.avelocity = goop_spin;

	item.skin = this.skin;

	_sound(this, CH_WEAPON_SINGLE, "amalg/amalgshoot.wav", .5, ATTN_NORM);

	item.dmg = 8;
	item.projectiledeathtype = DEATH_MONSTER_AMALGAM.m_id;
	settouch(item, AmalGoop_Touch);
	
	//item.think = SUB_Remove;
	setthink(item, AmalGoop_Die);		
	
	//item.nextthink = time + 20;	
	float r = 12 + (random() * 3);
	item.nextthink = time + r;	
}

void AmalGoop_Spam(entity this, int drop_count)
{
	for(int j = 0; j < drop_count; ++j)
	{
		AmalGoop_Drop(this);
	}
}

//this blood sprite stuff is by Kebby
//thanks Kebby! - fw
// defined elsewhere
void x_blood_01(entity this);

void GoopBlood(entity this, bool forcebig)
{
	entity spark = new(goopblood);
	setthink(spark, x_blood_01);
	spark.nextthink = time;
	spark.solid = SOLID_NOT;

	if(forcebig || random() < 0.3)
		_setmodel(spark, "progs/s_blood_128x.spr");
	else if(random() < 0.5)
		_setmodel(spark, "progs/s_blood_96x.spr");
	else
		_setmodel(spark, "progs/s_blood_64x.spr");

	setsize(spark, '0 0 0', '0 0 0');
	setorigin(spark, this.origin + '0 0 16');
}

void amalgamNightmareBoom(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;
	if(!toucher.takedamage)
		return;
	if(this.attack_finished > time)
		return; // ???

	float damage = (this.dmg) ? this.dmg : 8;
	T_RadiusDamage(this, this.owner, damage, DEATH_MONSTER_AMALGAM.m_id, this.owner);

	entity exp = spawn();
	exp.nextthink = time;
	setthink(exp, s_explode1);
	_setmodel(exp, "progs/s_explod.spr");
	setsize(exp, '0 0 0', '0 0 0');
	setorigin(exp, this.origin);

	delete(this);
}

void amalgam_fire(entity this)
{
	_sound(this, CH_WEAPON_SINGLE, "amalg/amalgshoot.wav", 1, ATTN_NORM);

	fixedmakevectors(this.angles);

	vector gorg = this.origin + v_forward * 16;
	vector dir = normalize(this.enemy.origin - gorg);
	vector spread = '0.1 0.1 0' * (-15 + random() * 45);
	dir += (crandom() * spread.x) * v_right + (crandom() * spread.y) * v_up;

	entity goop = launch_spike(this, gorg, dir);
	goop.solid = SOLID_TRIGGER;
	set_movetype(goop, MOVETYPE_TOSS);
	goop.classname = "AmalGoop";
	goop.projectiledeathtype = DEATH_MONSTER_AMALGAM.m_id;
	goop.velocity = dir * (432 + (random() * 200));

	if(autocvar_skill <= 1)
	{
		settouch(goop, AmalGoop_Touch);
		_setmodel(goop, "progs/proj_amalgoop.mdl");
		goop.dmg = 8;
	}
	else if(random() < 0.2)
	{
		settouch(goop, amalgamNightmareBoom);
		_setmodel(goop, "progs/proj_amalgoop_explo.mdl");
		goop.dmg = 35;
	}
	else
	{
		settouch(goop, AmalGoop_Touch);
		_setmodel(goop, "progs/proj_amalgoop.mdl");
		goop.dmg = 8;
	}

	setsize(goop, '0 0 0', '0 0 0');
	//goop.angles_y = (random() * (random() * 256));
	//goop.avelocity = '10 150 10';
	
	vector goop_spin = '0 0 0';
	goop_spin.y = (300 + random() * 600);
	
	goop.avelocity = goop_spin;
	goop.skin = this.skin;

	//goop.think = SUB_Remove;
	setthink(goop, AmalGoop_Die);
	
	//goop.nextthink = time + 15;
	float r = 12 + (random() * 3);
	goop.nextthink = time + r;
}

/*
===========
AmalgamCheckAttack

The player is in view, so decide to move or launch an attack
Returns false if movement should continue
============
*/
bool AmalgamCheckAttack(entity this)
{
	if(time < this.attack_finished)
		return false;
	if(!this.enemy_visible)
		return false;

	if(this.enemy_range >= RANGE_FAR)
		return false;
		
	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, false, this);

	if(trace_ent != targ)
		return false;

	float chance;	
	if(this.enemy_range <= RANGE_MELEE)
		chance = 0.9;
	else if(this.enemy_range == RANGE_NEAR)
		chance = 0.7;
	else if(this.enemy_range == RANGE_MID)
		chance = 0.3;
	else
		chance = 0;

	if(random() < chance)
	{
		this.attack_finished = time + 2 + random();
		this.attack_state = AS_MISSILE;
		return true;
	}
	
	return false;
}

void amalgam_ai_stand(entity this)
{
	if(FindTarget(this))
		return;
	
	if(this.pausetime != -1 && time > this.pausetime && this.goalentity)
	{
		setthink(this, this.th_walk);
		this.nextthink = time + 0.1;
		return;
	}
}

void AmalgamIdleNoise(entity this)
{
	if(random() < 0.4)
		_sound(this, CH_VOICE, "amalg/amalgidle.wav", 1, ATTN_IDLE);
}

void amalgam_stand1(entity this);
void amalgam_stand39(entity this) { set_animofs(this, anim_amalgam_idle, 39, amalgam_stand1); amalgam_ai_stand(this); }
void amalgam_stand38(entity this) { set_animofs(this, anim_amalgam_idle, 38, amalgam_stand39); amalgam_ai_stand(this); }
void amalgam_stand37(entity this) { set_animofs(this, anim_amalgam_idle, 37, amalgam_stand38); amalgam_ai_stand(this); }
void amalgam_stand36(entity this) { set_animofs(this, anim_amalgam_idle, 36, amalgam_stand37); amalgam_ai_stand(this); }
void amalgam_stand35(entity this) { set_animofs(this, anim_amalgam_idle, 35, amalgam_stand36); amalgam_ai_stand(this); }
void amalgam_stand34(entity this) { set_animofs(this, anim_amalgam_idle, 34, amalgam_stand35); amalgam_ai_stand(this); }
void amalgam_stand33(entity this) { set_animofs(this, anim_amalgam_idle, 33, amalgam_stand34); amalgam_ai_stand(this); }
void amalgam_stand32(entity this) { set_animofs(this, anim_amalgam_idle, 32, amalgam_stand33); amalgam_ai_stand(this); }
void amalgam_stand31(entity this) { set_animofs(this, anim_amalgam_idle, 31, amalgam_stand32); amalgam_ai_stand(this); }
void amalgam_stand30(entity this) { set_animofs(this, anim_amalgam_idle, 30, amalgam_stand31); amalgam_ai_stand(this); }
void amalgam_stand29(entity this) { set_animofs(this, anim_amalgam_idle, 29, amalgam_stand30); amalgam_ai_stand(this); }
void amalgam_stand28(entity this) { set_animofs(this, anim_amalgam_idle, 28, amalgam_stand29); amalgam_ai_stand(this); }
void amalgam_stand27(entity this) { set_animofs(this, anim_amalgam_idle, 27, amalgam_stand28); amalgam_ai_stand(this); }
void amalgam_stand26(entity this) { set_animofs(this, anim_amalgam_idle, 26, amalgam_stand27); amalgam_ai_stand(this); }
void amalgam_stand25(entity this) { set_animofs(this, anim_amalgam_idle, 25, amalgam_stand26); amalgam_ai_stand(this); }
void amalgam_stand24(entity this) { set_animofs(this, anim_amalgam_idle, 24, amalgam_stand25); amalgam_ai_stand(this); }
void amalgam_stand23(entity this) { set_animofs(this, anim_amalgam_idle, 23, amalgam_stand24); amalgam_ai_stand(this); }
void amalgam_stand22(entity this) { set_animofs(this, anim_amalgam_idle, 22, amalgam_stand23); amalgam_ai_stand(this); }
void amalgam_stand21(entity this) { set_animofs(this, anim_amalgam_idle, 21, amalgam_stand22); amalgam_ai_stand(this); }
void amalgam_stand20(entity this) { set_animofs(this, anim_amalgam_idle, 20, amalgam_stand21); amalgam_ai_stand(this); }
void amalgam_stand19(entity this) { set_animofs(this, anim_amalgam_idle, 19, amalgam_stand20); amalgam_ai_stand(this); }
void amalgam_stand18(entity this) { set_animofs(this, anim_amalgam_idle, 18, amalgam_stand19); amalgam_ai_stand(this); }
void amalgam_stand17(entity this) { set_animofs(this, anim_amalgam_idle, 17, amalgam_stand18); amalgam_ai_stand(this); AmalgamIdleNoise(this); }
void amalgam_stand16(entity this) { set_animofs(this, anim_amalgam_idle, 16, amalgam_stand17); amalgam_ai_stand(this); }
void amalgam_stand15(entity this) { set_animofs(this, anim_amalgam_idle, 15, amalgam_stand16); amalgam_ai_stand(this); }
void amalgam_stand14(entity this) { set_animofs(this, anim_amalgam_idle, 14, amalgam_stand15); amalgam_ai_stand(this); }
void amalgam_stand13(entity this) { set_animofs(this, anim_amalgam_idle, 13, amalgam_stand14); amalgam_ai_stand(this); }
void amalgam_stand12(entity this) { set_animofs(this, anim_amalgam_idle, 12, amalgam_stand13); amalgam_ai_stand(this); }
void amalgam_stand11(entity this) { set_animofs(this, anim_amalgam_idle, 11, amalgam_stand12); amalgam_ai_stand(this); }
void amalgam_stand10(entity this) { set_animofs(this, anim_amalgam_idle, 10, amalgam_stand11); amalgam_ai_stand(this); }
void amalgam_stand9(entity this) { set_animofs(this, anim_amalgam_idle, 9, amalgam_stand10); amalgam_ai_stand(this); }
void amalgam_stand8(entity this) { set_animofs(this, anim_amalgam_idle, 8, amalgam_stand9); amalgam_ai_stand(this); }
void amalgam_stand7(entity this) { set_animofs(this, anim_amalgam_idle, 7, amalgam_stand8); amalgam_ai_stand(this); }
void amalgam_stand6(entity this) { set_animofs(this, anim_amalgam_idle, 6, amalgam_stand7); amalgam_ai_stand(this); }
void amalgam_stand5(entity this) { set_animofs(this, anim_amalgam_idle, 5, amalgam_stand6); amalgam_ai_stand(this); }
void amalgam_stand4(entity this) { set_animofs(this, anim_amalgam_idle, 4, amalgam_stand5); amalgam_ai_stand(this); }
void amalgam_stand3(entity this) { set_animofs(this, anim_amalgam_idle, 3, amalgam_stand4); amalgam_ai_stand(this); }
void amalgam_stand2(entity this) { set_animofs(this, anim_amalgam_idle, 2, amalgam_stand3); amalgam_ai_stand(this); }
void amalgam_stand1(entity this) { set_animofs(this, anim_amalgam_idle, 1, amalgam_stand2); amalgam_ai_stand(this); AmalgamIdleNoise(this); }

void amalgam_walk1(entity this);
void amalgam_walk39(entity this) { set_animofs(this, anim_amalgam_idle, 24, amalgam_walk1); ai_walk(this, 1); }
void amalgam_walk38(entity this) { set_animofs(this, anim_amalgam_idle, 23, amalgam_walk39); ai_walk(this, 1); }
void amalgam_walk37(entity this) { set_animofs(this, anim_amalgam_idle, 22, amalgam_walk38); ai_walk(this, 1); }
void amalgam_walk36(entity this) { set_animofs(this, anim_amalgam_idle, 24, amalgam_walk37); ai_walk(this, 1); }
void amalgam_walk35(entity this) { set_animofs(this, anim_amalgam_idle, 23, amalgam_walk36); ai_walk(this, 1); }
void amalgam_walk34(entity this) { set_animofs(this, anim_amalgam_idle, 22, amalgam_walk35); ai_walk(this, 1); }
void amalgam_walk33(entity this) { set_animofs(this, anim_amalgam_idle, 21, amalgam_walk34); ai_walk(this, 2); }
void amalgam_walk32(entity this) { set_animofs(this, anim_amalgam_idle, 20, amalgam_walk33); ai_walk(this, 3); }
void amalgam_walk31(entity this) { set_animofs(this, anim_amalgam_idle, 19, amalgam_walk32); ai_walk(this, 3); }
void amalgam_walk30(entity this) { set_animofs(this, anim_amalgam_idle, 18, amalgam_walk31); ai_walk(this, 3); }
void amalgam_walk29(entity this) { set_animofs(this, anim_amalgam_idle, 17, amalgam_walk30); ai_walk(this, 3); }
void amalgam_walk28(entity this) { set_animofs(this, anim_amalgam_idle, 16, amalgam_walk29); ai_walk(this, 1); }
void amalgam_walk27(entity this) { set_animofs(this, anim_amalgam_idle, 15, amalgam_walk28); ai_walk(this, 1); }
void amalgam_walk26(entity this) { set_animofs(this, anim_amalgam_idle, 14, amalgam_walk27); ai_walk(this, 1); }
void amalgam_walk25(entity this) { set_animofs(this, anim_amalgam_idle, 13, amalgam_walk26); ai_walk(this, 0); }
void amalgam_walk24(entity this) { set_animofs(this, anim_amalgam_idle, 24, amalgam_walk25); ai_walk(this, 1); }
void amalgam_walk23(entity this) { set_animofs(this, anim_amalgam_idle, 23, amalgam_walk24); ai_walk(this, 1); }
void amalgam_walk22(entity this) { set_animofs(this, anim_amalgam_idle, 22, amalgam_walk23); ai_walk(this, 1); }
void amalgam_walk21(entity this) { set_animofs(this, anim_amalgam_idle, 21, amalgam_walk22); ai_walk(this, 2); }
void amalgam_walk20(entity this) { set_animofs(this, anim_amalgam_idle, 20, amalgam_walk21); ai_walk(this, 3); }
void amalgam_walk19(entity this) { set_animofs(this, anim_amalgam_idle, 19, amalgam_walk20); ai_walk(this, 3); }
void amalgam_walk18(entity this) { set_animofs(this, anim_amalgam_idle, 18, amalgam_walk19); ai_walk(this, 3); }
void amalgam_walk17(entity this) { set_animofs(this, anim_amalgam_idle, 17, amalgam_walk18); ai_walk(this, 3); AmalgamIdleNoise(this); }
void amalgam_walk16(entity this) { set_animofs(this, anim_amalgam_idle, 16, amalgam_walk17); ai_walk(this, 1); }
void amalgam_walk15(entity this) { set_animofs(this, anim_amalgam_idle, 15, amalgam_walk16); ai_walk(this, 1); }
void amalgam_walk14(entity this) { set_animofs(this, anim_amalgam_idle, 14, amalgam_walk15); ai_walk(this, 1); }
void amalgam_walk13(entity this) { set_animofs(this, anim_amalgam_idle, 13, amalgam_walk14); ai_walk(this, 0); }
void amalgam_walk12(entity this) { set_animofs(this, anim_amalgam_idle, 12, amalgam_walk13); ai_walk(this, 1); }
void amalgam_walk11(entity this) { set_animofs(this, anim_amalgam_idle, 11, amalgam_walk12); ai_walk(this, 2); }
void amalgam_walk10(entity this) { set_animofs(this, anim_amalgam_idle, 10, amalgam_walk11); ai_walk(this, 2); }
void amalgam_walk9(entity this) { set_animofs(this, anim_amalgam_idle, 9, amalgam_walk10); ai_walk(this, 2); }
void amalgam_walk8(entity this) { set_animofs(this, anim_amalgam_idle, 8, amalgam_walk9); ai_walk(this, 4); }
void amalgam_walk7(entity this) { set_animofs(this, anim_amalgam_idle, 7, amalgam_walk8); ai_walk(this, 4); }
void amalgam_walk6(entity this) { set_animofs(this, anim_amalgam_idle, 6, amalgam_walk7); ai_walk(this, 3); }
void amalgam_walk5(entity this) { set_animofs(this, anim_amalgam_idle, 5, amalgam_walk6); ai_walk(this, 2); }
void amalgam_walk4(entity this) { set_animofs(this, anim_amalgam_idle, 4, amalgam_walk5); ai_walk(this, 1); }
void amalgam_walk3(entity this) { set_animofs(this, anim_amalgam_idle, 3, amalgam_walk4); ai_walk(this, 1); }
void amalgam_walk2(entity this) { set_animofs(this, anim_amalgam_idle, 2, amalgam_walk3); ai_walk(this, 1); }
void amalgam_walk1(entity this) { set_animofs(this, anim_amalgam_idle, 1, amalgam_walk2); ai_walk(this, 1); AmalgamIdleNoise(this); }

void amalgam_run1(entity this);
void amalgam_run39(entity this) { set_animofs(this, anim_amalgam_idle, 24, amalgam_run1); ai_run(this, 8); }
void amalgam_run38(entity this) { set_animofs(this, anim_amalgam_idle, 23, amalgam_run39); ai_run(this, 8); }
void amalgam_run37(entity this) { set_animofs(this, anim_amalgam_idle, 22, amalgam_run38); ai_run(this, 8); }
void amalgam_run36(entity this) { set_animofs(this, anim_amalgam_idle, 24, amalgam_run37); ai_run(this, 8); }
void amalgam_run35(entity this) { set_animofs(this, anim_amalgam_idle, 23, amalgam_run36); ai_run(this, 8); }
void amalgam_run34(entity this) { set_animofs(this, anim_amalgam_idle, 22, amalgam_run35); ai_run(this, 8); }
void amalgam_run33(entity this) { set_animofs(this, anim_amalgam_idle, 21, amalgam_run34); ai_run(this, 8); }
void amalgam_run32(entity this) { set_animofs(this, anim_amalgam_idle, 20, amalgam_run33); ai_run(this, 8); }
void amalgam_run31(entity this) { set_animofs(this, anim_amalgam_idle, 19, amalgam_run32); ai_run(this, 8); }
void amalgam_run30(entity this) { set_animofs(this, anim_amalgam_idle, 18, amalgam_run31); ai_run(this, 8); }
void amalgam_run29(entity this) { set_animofs(this, anim_amalgam_idle, 17, amalgam_run30); ai_run(this, 8); }
void amalgam_run28(entity this) { set_animofs(this, anim_amalgam_idle, 16, amalgam_run29); ai_run(this, 8); }
void amalgam_run27(entity this) { set_animofs(this, anim_amalgam_idle, 15, amalgam_run28); ai_run(this, 8); }
void amalgam_run26(entity this) { set_animofs(this, anim_amalgam_idle, 14, amalgam_run27); ai_run(this, 8); }
void amalgam_run25(entity this) { set_animofs(this, anim_amalgam_idle, 13, amalgam_run26); ai_run(this, 8); }
void amalgam_run24(entity this) { set_animofs(this, anim_amalgam_idle, 24, amalgam_run25); ai_run(this, 8); }
void amalgam_run23(entity this) { set_animofs(this, anim_amalgam_idle, 23, amalgam_run24); ai_run(this, 8); }
void amalgam_run22(entity this) { set_animofs(this, anim_amalgam_idle, 22, amalgam_run23); ai_run(this, 8); }
void amalgam_run21(entity this) { set_animofs(this, anim_amalgam_idle, 21, amalgam_run22); ai_run(this, 8); }
void amalgam_run20(entity this) { set_animofs(this, anim_amalgam_idle, 20, amalgam_run21); ai_run(this, 8); }
void amalgam_run19(entity this) { set_animofs(this, anim_amalgam_idle, 19, amalgam_run20); ai_run(this, 8); }
void amalgam_run18(entity this) { set_animofs(this, anim_amalgam_idle, 18, amalgam_run19); ai_run(this, 8); }
void amalgam_run17(entity this) { set_animofs(this, anim_amalgam_idle, 17, amalgam_run18); ai_run(this, 8); }
void amalgam_run16(entity this) { set_animofs(this, anim_amalgam_idle, 16, amalgam_run17); ai_run(this, 8); }
void amalgam_run15(entity this) { set_animofs(this, anim_amalgam_idle, 15, amalgam_run16); ai_run(this, 8); }
void amalgam_run14(entity this) { set_animofs(this, anim_amalgam_idle, 14, amalgam_run15); ai_run(this, 8); }
void amalgam_run13(entity this) { set_animofs(this, anim_amalgam_idle, 13, amalgam_run14); ai_run(this, 8); }
void amalgam_run12(entity this) { set_animofs(this, anim_amalgam_idle, 12, amalgam_run13); ai_run(this, 8); }
void amalgam_run11(entity this) { set_animofs(this, anim_amalgam_idle, 11, amalgam_run12); ai_run(this, 8); }
void amalgam_run10(entity this) { set_animofs(this, anim_amalgam_idle, 10, amalgam_run11); ai_run(this, 8); }
void amalgam_run9(entity this) { set_animofs(this, anim_amalgam_idle, 9, amalgam_run10); ai_run(this, 8); }
void amalgam_run8(entity this) { set_animofs(this, anim_amalgam_idle, 8, amalgam_run9); ai_run(this, 8); }
void amalgam_run7(entity this) { set_animofs(this, anim_amalgam_idle, 7, amalgam_run8); ai_run(this, 8); }
void amalgam_run6(entity this) { set_animofs(this, anim_amalgam_idle, 6, amalgam_run7); ai_run(this, 8); }
void amalgam_run5(entity this) { set_animofs(this, anim_amalgam_idle, 5, amalgam_run6); ai_run(this, 8); }
void amalgam_run4(entity this) { set_animofs(this, anim_amalgam_idle, 4, amalgam_run5); ai_run(this, 8); }
void amalgam_run3(entity this) { set_animofs(this, anim_amalgam_idle, 3, amalgam_run4); ai_run(this, 8); }
void amalgam_run2(entity this) { set_animofs(this, anim_amalgam_idle, 2, amalgam_run3); ai_run(this, 8); }
void amalgam_run1(entity this)
{
	set_animofs(this, anim_amalgam_idle, 1, amalgam_run2); 
	AmalgamIdleNoise(this);
	ai_run(this, 16);
}

void amalgam_atk12(entity this) { set_animofs(this, anim_amalgam_shoot, 12, amalgam_run1); this.angles_y += 20; }
void amalgam_atk11(entity this) { set_animofs(this, anim_amalgam_shoot, 11, amalgam_atk12); amalgam_fire(this); amalgam_fire(this); this.angles_y += 20; }
void amalgam_atk10(entity this) { set_animofs(this, anim_amalgam_shoot, 10, amalgam_atk11); amalgam_fire(this); }
void amalgam_atk9(entity this) { set_animofs(this, anim_amalgam_shoot, 9, amalgam_atk10); amalgam_fire(this); amalgam_fire(this); this.angles_y += 20; }
void amalgam_atk8(entity this) { set_animofs(this, anim_amalgam_shoot, 8, amalgam_atk9); amalgam_fire(this); this.angles_y += 20; }
void amalgam_atk7(entity this) { set_animofs(this, anim_amalgam_shoot, 7, amalgam_atk8); this.angles_y += 20; }
void amalgam_atk6(entity this) { set_animofs(this, anim_amalgam_shoot, 6, amalgam_atk7); this.angles_y += 20; }
void amalgam_atk5(entity this) { set_animofs(this, anim_amalgam_shoot, 5, amalgam_atk6); this.angles_y += 20; }
void amalgam_atk4(entity this) { set_animofs(this, anim_amalgam_shoot, 4, amalgam_atk5); this.angles_y += 20; }
void amalgam_atk3(entity this) { set_animofs(this, anim_amalgam_shoot, 3, amalgam_atk4); this.angles_y += 20; }
void amalgam_atk2(entity this) { set_animofs(this, anim_amalgam_shoot, 2, amalgam_atk3); this.angles_y += 20; }
void amalgam_atk1(entity this)
{
	set_animofs(this, anim_amalgam_shoot, 1, amalgam_atk2);
	this.angles_y += 20;
}

void amalg_pain4(entity this) { set_animofs(this, anim_amalgam_pain, 4, amalgam_run1); }
void amalg_pain3(entity this) { set_animofs(this, anim_amalgam_pain, 3, amalg_pain4); }
void amalg_pain2(entity this) { set_animofs(this, anim_amalgam_pain, 2, amalg_pain3); }
void amalg_pain1(entity this) { set_animofs(this, anim_amalgam_pain, 1, amalg_pain2); this.avelocity_y = 0; }

void amalg_painb6(entity this) { set_animofs(this, anim_amalgam_painb, 6, amalgam_run1); }
void amalg_painb5(entity this) { set_animofs(this, anim_amalgam_painb, 5, amalg_painb6); }
void amalg_painb4(entity this) { set_animofs(this, anim_amalgam_painb, 4, amalg_painb5); }
void amalg_painb3(entity this) { set_animofs(this, anim_amalgam_painb, 3, amalg_painb4); ai_painforward(this, 9); }
void amalg_painb2(entity this) { set_animofs(this, anim_amalgam_painb, 2, amalg_painb3); ai_painforward(this, 13); }
void amalg_painb1(entity this) { set_animofs(this, anim_amalgam_painb, 1, amalg_painb2); this.avelocity_y = 0; }

void amalgam_die17(entity this) { set_animofs(this, anim_amalgam_death, 16, amalgam_die17); AmalGoop_Spam(this, 4); GoopBlood(this, 1); delete(this); }
void amalgam_die16(entity this) { set_animofs(this, anim_amalgam_death, 16, amalgam_die17); makevectors(this.angles); SpawnMeatUndConcreteBurst(this, this.origin + v_forward * 16, crandom() * 100 * v_right, 5, false); }
void amalgam_die15(entity this) { set_animofs(this, anim_amalgam_death, 15, amalgam_die16); AmalGoop_Spam(this, 1); }
void amalgam_die14(entity this) { set_animofs(this, anim_amalgam_death, 14, amalgam_die15); AmalGoop_Spam(this, 1); }
void amalgam_die13(entity this) { set_animofs(this, anim_amalgam_death, 13, amalgam_die14); AmalGoop_Spam(this, 2); }
void amalgam_die12(entity this) { set_animofs(this, anim_amalgam_death, 12, amalgam_die13); AmalGoop_Spam(this, 2); }
void amalgam_die11(entity this) { set_animofs(this, anim_amalgam_death, 11, amalgam_die12); AmalGoop_Spam(this, 2); }
void amalgam_die10(entity this) { set_animofs(this, anim_amalgam_death, 10, amalgam_die11); makevectors(this.angles); SpawnMeatUndConcreteBurst(this, this.origin + v_forward * 16, crandom() * 100 * v_right, 5, false); }
void amalgam_die9(entity this) { set_animofs(this, anim_amalgam_death, 9, amalgam_die10); }
void amalgam_die8(entity this) { set_animofs(this, anim_amalgam_death, 8, amalgam_die9); }
void amalgam_die7(entity this) { set_animofs(this, anim_amalgam_death, 7, amalgam_die8); }
void amalgam_die6(entity this) { set_animofs(this, anim_amalgam_death, 6, amalgam_die7); }
void amalgam_die5(entity this) { set_animofs(this, anim_amalgam_death, 5, amalgam_die6); }
void amalgam_die4(entity this) { set_animofs(this, anim_amalgam_death, 4, amalgam_die5); }
void amalgam_die3(entity this) { set_animofs(this, anim_amalgam_death, 3, amalgam_die4); }
void amalgam_die2(entity this) { set_animofs(this, anim_amalgam_death, 2, amalgam_die3); makevectors(this.angles); SpawnMeatUndConcreteBurst(this, this.origin + v_forward * 16, crandom() * 100 * v_right, 5, false); }
void amalgam_die1(entity this) { set_animofs(this, anim_amalgam_death, 1, amalgam_die2); this.solid = SOLID_NOT; set_movetype(this, MOVETYPE_NONE); }

void amalgam_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			AmalGoop_Spam(this, 12);
			SpawnMeatUndConcreteBurst(this, this.origin, VelocityForDamage(this, inflictor, this.health), 12, true);
			GoopBlood(this, 1);
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	amalgam_die1(this);
}

void amalg_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	float r = random();

	if(random() > 0.8)
	{
		this.pain_finished = time + 3;
		AmalGoop_Spam(this, 5);
		this.nextthink = time;
		if(r > 0.5)
			setthink(this, amalg_pain1);
		else
			setthink(this, amalg_painb1);
	}
	else
		this.pain_finished = time; // prevent spam anyway

	if(r > 0.5)
		_sound(this, CH_VOICE, "amalg/amalgpain1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "amalg/amalgpain2.wav", 1, ATTN_NORM);
}

/*QUAKED monster_amalgam (1 0 0) (-32 -32 -32) (32 32 72) AMBUSH ? ? ? TRIGGERED NOTFOG NOTELEFRAG INSTAWAKE
Amalgam, 60 health points.

Flags:
"ambush" only wake up on seeing the player, not another monster getting angry

"Triggered"	will not spawn until triggered - triggering again will wake him up. Set 'count' to make this a multi-use spawner.
"NoTfog" 	supress teleport glitter when spawned with 'triggered'
"NoTelefrag" will silently fail to spawn if doing so would telefrag an existing monster. will try again automatically 2x/second until it succeeds.
"Instawake" spawn angry at activator

Keys:
"target" entity to trigger when killed
"targetname" entity name
"movedir" set to a velocity to make the monster jump on awakening
*/
/*FGD
@PointClass base(Monster) size(-32 -32 -32, 32 32 72) model({ "path": ":progs/toothy_qbj.mdl", "skin": skin }) = monster_amalgam : "Amalgam" []
*/
spawnfunc(monster_amalgam) { monster_start(this, true, MON_AMALGAM); }
#endif // SVQC

#ifdef SVQC
METHOD(Amalgam, mr_setup, bool(Amalgam this, entity actor))
{
	TC(Amalgam, this);

	precache_model("progs/gibs/gib_conc_1.mdl");
	precache_model("progs/gibs/gib_conc_2.mdl");
	precache_model("progs/gibs/gib_conc_3.mdl");

	precache_model("progs/gibs/gib_gen_1.mdl");
	precache_model("progs/gibs/gib_gen_2.mdl");
	precache_model("progs/gibs/gib_gen_3.mdl");
	precache_model("progs/gibs/gib_gen_4.mdl");
	precache_model("progs/gibs/gib_gen_5.mdl");
	precache_model("progs/gibs/gib_gen_6.mdl");

	precache_model("progs/proj_amalgoop.mdl");
	precache_model("progs/proj_amalgoop_explo.mdl");
	precache_model("progs/proj_amalgoop_pop.mdl");
	precache_model("progs/proj_amalgoop_explo_pop.mdl");
	precache_sound("amalg/amalg_goop1.wav");
	precache_sound("amalg/amalg_goop2.wav");

	precache_sound("amalg/amalgdeath.wav");
	precache_sound("amalg/amalgidle.wav");
	precache_sound("amalg/amalgpain1.wav");
	precache_sound("amalg/amalgpain2.wav");
	precache_sound("amalg/amalgshoot.wav");
	precache_sound("amalg/amalgsight.wav");
	precache_sound("amalg/slab.wav");

	precache_model("progs/s_blood_128x.spr");
	precache_model("progs/s_blood_96x.spr");
	precache_model("progs/s_blood_64x.spr");

	actor.health = 400;
	actor.gibhealth = -150;
	actor.th_stand = amalgam_stand1;
	actor.th_walk = amalgam_walk1;
	actor.th_run = amalgam_run1;
	actor.th_missile = amalgam_atk1;
	actor.th_pain = amalg_pain;
	actor.th_die = amalgam_die;

	actor.checkattack = AmalgamCheckAttack;

	return true;
}
METHOD(Amalgam, mr_sight, bool(Amalgam this, entity actor))
{
	TC(Amalgam, this);

	if(random() <= 0.2)
		_sound(actor, CH_VOICE, "amalg/slab.wav", 1, 0.5);
	else
		_sound(actor, CH_VOICE, "amalg/amalgsight.wav", 1, ATTN_NORM);

	return true;
}
#endif

// kirby power
#ifdef CSQC
PRECACHE(Star_Amalgam)
{
	precache_model("progs/v_star_amalgam.mdl");
}
#endif

#ifdef SVQC
PRECACHE(Star_Amalgam)
{
	precache_model("progs/star_amalgam_plat.mdl");
	precache_sound("break/rock_impact.wav");

	// there might not have been an amalgam in the stage
	// (we can take abilities between levels)
	// so cache what's used
	precache_sound("amalg/amalgshoot.wav");
	precache_model("progs/proj_amalgoop.mdl");
	precache_model("progs/proj_amalgoop_pop.mdl");

	precache_sound("weapons/tink1.wav");
	precache_sound("amalg/amalg_goop1.wav");
	precache_sound("amalg/amalg_goop2.wav");

	precache_sound("amalg/slab.wav");

	precache_model("progs/s_blood_128x.spr");
	precache_model("progs/s_blood_96x.spr");
	precache_model("progs/s_blood_64x.spr");
}

void star_amalgam_spit_fire(entity actor, .entity weaponentity)
{
	makevectors(actor.v_angle);

	float bullet_speed = 1000;
	vector org = CENTER_OR_VIEWOFS(actor);
	vector dir = qc_aim_fromorg(actor, org, bullet_speed);

	vector spread = '0.04 0.04 0';
	vector spread_dir = dir + (crandom() * spread.x) * v_right + (crandom() * spread.y) * v_up;

	entity goop = launch_spike(actor, org, spread_dir);
	goop.solid = SOLID_BBOX;
	set_movetype(goop, MOVETYPE_TOSS);
	goop.classname = "AmalGoop";
	goop.projectiledeathtype = WEP_STAR.m_id;
	goop.velocity = dir * bullet_speed;

	settouch(goop, AmalGoop_Touch);
	_setmodel(goop, "progs/proj_amalgoop.mdl");
	goop.dmg = 24;

	goop.colormod = '0.2 1 0.5'; // green? TODO: custom texture

	setsize(goop, '0 0 0', '0 0 0');
	//goop.angles_y = (random() * (random() * 256));
	//goop.avelocity = '10 150 10';
	
	vector goop_spin = '0 0 0';
	goop_spin.y = (300 + random() * 600);

	goop.avelocity = goop_spin;

	//goop.think = SUB_Remove;
	setthink(goop, AmalGoop_Die);
	
	//goop.nextthink = time + 15;
	float r = 5 + (random() * 3);
	goop.nextthink = time + r;
}

void star_amalgam_spit(entity actor, .entity weaponentity)
{
	_sound(actor, CH_WEAPON_SINGLE, "amalg/amalgshoot.wav", 1, ATTN_NORM);

	star_amalgam_spit_fire(actor, weaponentity);

	if(IS_PLAYER(actor))
		player_shot1(actor);

	wep_generic_shot1(actor.(weaponentity));
	weapon_prepareattack(WEP_STAR, actor, weaponentity, random() * 0.5);
}

void star_amalgam_plat_break(entity this)
{
	_sound(this, CH_TRIGGER_SINGLE, "break/rock_impact.wav", 1, ATTN_NORM);
	te_explosion2(this.origin, 4, 5);

	setthink(this, SUB_Remove);
	this.nextthink = time;
	this.solid = SOLID_NOT;
}

void star_amalgam_plat_think(entity this)
{
	this.nextthink = time;

	// extend duration while standing on it
	if(this.realowner.groundentity == this)
		this.count = max(time + 3, this.count);

	if(time >= this.count)
	{
		star_amalgam_plat_break(this);
		return;
	}

	CSQCMODEL_AUTOUPDATE(this);
}

void star_amalgam_plat_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	star_amalgam_plat_break(this);
}

void star_amalgam_plat_place(entity actor, vector org)
{
	entity block = new(amalgam_plat);
	block.realowner = actor;
	block.solid = SOLID_BBOX;
	setorigin(block, org);
	_setmodel(block, "progs/star_amalgam_plat.mdl");
	setsize(block, '-16 -16 -24', '16 16 16');
	set_movetype(block, MOVETYPE_NONE);
	block.takedamage = DAMAGE_AIM;
	block.health = 75;
	block.count = time + 5;
	setthink(block, star_amalgam_plat_think);
	block.nextthink = time;
	block.th_die = star_amalgam_plat_die;
	block.candrag = true;
	//block.avelocity = '0 96 0';
	block.modelflags = MF_ROTATE;
	block.angles_y = random() * 360; // initially offset it

	CSQCMODEL_AUTOINIT(block);
}

bool star_amalgam_plat(entity actor, .entity weaponentity)
{
	tracebox(actor.origin, '-16 -16 -24', '16 16 16', actor.origin - '0 0 48', MOVE_NORMAL, actor);
	if(trace_fraction != 1.0 || trace_startsolid)
	{
		// falls through to regular attack
		return false;
	}

	_sound(actor, CH_WEAPON_SINGLE, "break/rock_impact.wav", 1, ATTN_NORM);

	star_amalgam_plat_place(actor, trace_endpos);

	if(IS_PLAYER(actor))
		player_shot1(actor);

	wep_generic_shot1(actor.(weaponentity));
	weapon_prepareattack(WEP_STAR, actor, weaponentity, 0.5);
	return true;
}

.float star_lastslab;
void Star_Amalgam_Frame(entity actor, .entity weaponentity, int fire)
{
	if(!(fire & 1) && time >= actor.star_lastslab && !(time < ATTACK_FINISHED(actor, weaponentity)))
	{
		Monster mon = REGISTRY_GET(Monsters, STAT(KIRBY_TYPE, actor));
		if(mon == MON_AMALGAM && actor.groundentity.classname == "amalgam_plat")
		{
			if(random() < 0.8)
			{
				actor.star_lastslab = time + 1;
				return;
			}

			wep_generic_shot1(actor.(weaponentity));
			_sound(actor, CH_WEAPON_B, "amalg/slab.wav", 1, ATTN_NORM);
			actor.star_lastslab = time + 10 + (random() * 4);
		}
	}
}

METHOD(Amalgam, star_fire, void(Amalgam this, entity actor, .entity weaponentity))
{
	// we're always going to do *something*, so always cancel out of flight now
	if(STAT(KIRBY_STATE, actor) == KIRBY_FLYING)
		STAT(KIRBY_STATE, actor) = KIRBY_NORMAL;

	bool swimming = (actor.waterlevel > 1);

	// looking down and in the air!
	if(!IS_ONGROUND(actor) && !swimming && actor.v_angle_x >= 55 && actor.v_angle_x <= 110)
	{
		if(star_amalgam_plat(actor, weaponentity))
			return;
	}

	// regular slice attack
	star_amalgam_spit(actor, weaponentity);
}
#endif
