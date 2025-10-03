#include "demon_eye.qh"

#ifdef SVQC
void demon_eye_run1(entity this);
void demon_eye_side1(entity this);

void demon_eye_anim(entity this, void(entity) tnk)
{
	this.walkframe += 1;
	if(this.walkframe > 4)
		this.walkframe = 0;
	this.frame = this.walkframe;
	this.nextthink = time + 0.1;
	setthink(this, tnk);
}

bool DemonEyeCheckAttack(entity this)
{
	if(time < this.attack_finished)
		return false;
	if(this.enemy_range == RANGE_FAR)
	{
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
			demon_eye_run1(this);
		}
		return false;
	}
	entity targ = this.enemy;
	vector spot1 = (this.origin + this.view_ofs);
	vector spot2 = (targ.origin + targ.view_ofs);
	traceline(spot1, spot2, false, this);
	if(trace_ent != targ)
	{
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
			demon_eye_run1(this);
		}
		return false;
	}
	if(this.enemy_range == RANGE_MELEE)
		return true;
	if(this.enemy_range == RANGE_MID)
	{
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
			demon_eye_run1(this);
		}
	}
	return false;
}

void DemonEyeAttackFinished(entity this)
{
	this.attack_state = AS_STRAIGHT;
	setthink(this, demon_eye_run1);
}

void DemonEyeStopSide(entity this)
{
	this.attack_state = AS_STRAIGHT;
	setthink(this, demon_eye_run1);
}

void DemonEyeStartSide(entity this)
{
	this.attack_state = AS_SLIDING;
	setthink(this, demon_eye_side1);
}

void demon_eye_stand1(entity this);
void demon_eye_stand6(entity this) { demon_eye_anim(this, demon_eye_stand1); ai_stand(this); }
void demon_eye_stand5(entity this) { demon_eye_anim(this, demon_eye_stand6); ai_stand(this); }
void demon_eye_stand4(entity this) { demon_eye_anim(this, demon_eye_stand5); ai_stand(this); }
void demon_eye_stand3(entity this) { demon_eye_anim(this, demon_eye_stand4); ai_stand(this); }
void demon_eye_stand2(entity this) { demon_eye_anim(this, demon_eye_stand3); ai_stand(this); }
void demon_eye_stand1(entity this) { demon_eye_anim(this, demon_eye_stand2); ai_stand(this); }

void demon_eye_walk1(entity this);
void demon_eye_walk8(entity this) { demon_eye_anim(this, demon_eye_walk1); ai_walk(this, 8); }
void demon_eye_walk7(entity this) { demon_eye_anim(this, demon_eye_walk8); ai_walk(this, 8); }
void demon_eye_walk6(entity this) { demon_eye_anim(this, demon_eye_walk7); ai_walk(this, 8); }
void demon_eye_walk5(entity this) { demon_eye_anim(this, demon_eye_walk6); ai_walk(this, 8); }
void demon_eye_walk4(entity this) { demon_eye_anim(this, demon_eye_walk5); ai_walk(this, 8); }
void demon_eye_walk3(entity this) { demon_eye_anim(this, demon_eye_walk4); ai_walk(this, 8); }
void demon_eye_walk2(entity this) { demon_eye_anim(this, demon_eye_walk3); ai_walk(this, 8); }
void demon_eye_walk1(entity this) { demon_eye_anim(this, demon_eye_walk2); ai_walk(this, 8); }

void demon_eye_side8(entity this) { demon_eye_anim(this, demon_eye_run1); ai_run(this, 16); DemonEyeStopSide(this); }
void demon_eye_side7(entity this) { demon_eye_anim(this, demon_eye_side8); ai_run(this, 16); }
void demon_eye_side6(entity this) { demon_eye_anim(this, demon_eye_side7); ai_run(this, 16); }
void demon_eye_side5(entity this) { demon_eye_anim(this, demon_eye_side6); ai_run(this, 16); }
void demon_eye_side4(entity this) { demon_eye_anim(this, demon_eye_side5); ai_run(this, 16); }
void demon_eye_side3(entity this) { demon_eye_anim(this, demon_eye_side4); ai_run(this, 16); }
void demon_eye_side2(entity this) { demon_eye_anim(this, demon_eye_side3); ai_run(this, 16); }
void demon_eye_side1(entity this) { demon_eye_anim(this, demon_eye_side2); ai_run(this, 16); }

void demon_eye_run6(entity this) { demon_eye_anim(this, demon_eye_run1); ai_run(this, 24); }
void demon_eye_run5(entity this) { demon_eye_anim(this, demon_eye_run6); ai_run(this, 24); }
void demon_eye_run4(entity this) { demon_eye_anim(this, demon_eye_run5); ai_run(this, 24); }
void demon_eye_run3(entity this) { demon_eye_anim(this, demon_eye_run4); ai_run(this, 24); }
void demon_eye_run2(entity this) { demon_eye_anim(this, demon_eye_run3); ai_run(this, 24); }
void demon_eye_run1(entity this) { demon_eye_anim(this, demon_eye_run2); ai_run(this, 24); }

void demon_eye_swipe(entity this)
{
	if(!this.enemy)
		return;
	ai_charge(this, 0);
	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;
	float ldmg = (((random() + random()) + random()) * 3);
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_DEMON_EYE.m_id);
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
}

void demon_eye_fast8(entity this)
{
	demon_eye_anim(this, demon_eye_run1);
	ai_charge(this, 24);
	this.attack_finished = time + 2;
	DemonEyeAttackFinished(this);
}
void demon_eye_fast7(entity this) { demon_eye_anim(this, demon_eye_fast8); ai_charge(this, 24); }
void demon_eye_fast6(entity this) { demon_eye_anim(this, demon_eye_fast7); ai_charge(this, 24); }
void demon_eye_fast5(entity this) { demon_eye_anim(this, demon_eye_fast6); ai_charge(this, 24); demon_eye_swipe(this); }
void demon_eye_fast4(entity this) { demon_eye_anim(this, demon_eye_fast5); ai_charge(this, 24); }
void demon_eye_fast3(entity this) { demon_eye_anim(this, demon_eye_fast4); ai_charge(this, 24); }
void demon_eye_fast2(entity this) { demon_eye_anim(this, demon_eye_fast3); ai_charge(this, 24); }
void demon_eye_fast1(entity this) { demon_eye_anim(this, demon_eye_fast2); ai_charge(this, 24); }

void demon_eye_fastb10(entity this)
{
	demon_eye_anim(this, demon_eye_run1);
	ai_charge(this, 24);
	this.attack_finished = time + 2;
}
void demon_eye_fastb9(entity this) { demon_eye_anim(this, demon_eye_fastb10); ai_charge(this, 24); demon_eye_swipe(this); }
void demon_eye_fastb8(entity this) { demon_eye_anim(this, demon_eye_fastb9); ai_charge(this, 24); }
void demon_eye_fastb7(entity this) { demon_eye_anim(this, demon_eye_fastb8); ai_charge(this, 24); }
void demon_eye_fastb6(entity this) { demon_eye_anim(this, demon_eye_fastb7); ai_charge(this, 24); }
void demon_eye_fastb5(entity this) { demon_eye_anim(this, demon_eye_fastb6); ai_charge(this, 24); demon_eye_swipe(this); }
void demon_eye_fastb4(entity this) { demon_eye_anim(this, demon_eye_fastb5); ai_charge(this, 24); }
void demon_eye_fastb3(entity this) { demon_eye_anim(this, demon_eye_fastb4); ai_charge(this, 24); }
void demon_eye_fastb2(entity this) { demon_eye_anim(this, demon_eye_fastb3); ai_charge(this, 24); }
void demon_eye_fastb1(entity this) { demon_eye_anim(this, demon_eye_fastb2); ai_charge(this, 24); }

void demon_eye_fastc11(entity this)
{
	demon_eye_anim(this, demon_eye_run1);
	ai_charge(this, 24);
	this.attack_finished = time + 2;
	DemonEyeAttackFinished(this);
}
void demon_eye_fastc10(entity this) { demon_eye_anim(this, demon_eye_fastc11); ai_charge(this, 24); }
void demon_eye_fastc9(entity this) { demon_eye_anim(this, demon_eye_fastc10); ai_charge(this, 24); demon_eye_swipe(this); }
void demon_eye_fastc8(entity this) { demon_eye_anim(this, demon_eye_fastc9); ai_charge(this, 24); }
void demon_eye_fastc7(entity this) { demon_eye_anim(this, demon_eye_fastc8); ai_charge(this, 24); }
void demon_eye_fastc6(entity this) { demon_eye_anim(this, demon_eye_fastc7); ai_charge(this, 24); }
void demon_eye_fastc5(entity this) { demon_eye_anim(this, demon_eye_fastc6); ai_charge(this, 24); demon_eye_swipe(this); }
void demon_eye_fastc4(entity this) { demon_eye_anim(this, demon_eye_fastc5); ai_charge(this, 24); }
void demon_eye_fastc3(entity this) { demon_eye_anim(this, demon_eye_fastc4); ai_charge(this, 24); }
void demon_eye_fastc2(entity this) { demon_eye_anim(this, demon_eye_fastc3); ai_charge(this, 24); }
void demon_eye_fastc1(entity this) { demon_eye_anim(this, demon_eye_fastc2); ai_charge(this, 24); demon_eye_swipe(this); }

void demon_eye_fast(entity this)
{
	if(random() <= 0.3)
		demon_eye_fast1(this);
	else if(random() <= 0.6)
		demon_eye_fastb1(this);
	else
		demon_eye_fastc1(this);
}

void demon_eye_pain7(entity this) { demon_eye_anim(this, demon_eye_run1); DemonEyeStopSide(this); }
void demon_eye_pain6(entity this) { demon_eye_anim(this, demon_eye_pain7); }
void demon_eye_pain5(entity this) { demon_eye_anim(this, demon_eye_pain6); }
void demon_eye_pain4(entity this) { demon_eye_anim(this, demon_eye_pain5); }
void demon_eye_pain3(entity this) { demon_eye_anim(this, demon_eye_pain4); }
void demon_eye_pain2(entity this) { demon_eye_anim(this, demon_eye_pain3); }
void demon_eye_pain1(entity this) { demon_eye_anim(this, demon_eye_pain2); }

void demon_eye_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CH_VOICE, "demon_eye/death.wav", 1, ATTN_NORM);

	ThrowHead(this, inflictor, "progs/gib1.mdl", this.health);
	ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
	ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
	ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
}

void demon_eye_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	_sound(this, CHAN_BODY, "demon_eye/pain.wav", 1, ATTN_NORM);
	demon_eye_pain1(this);
	this.pain_finished = time + 0.2;
}

spawnfunc(monster_demon_eye) { monster_start(this, true, MON_DEMON_EYE); }
#endif // SVQC

#ifdef SVQC
METHOD(DemonEye, mr_setup, bool(DemonEye this, entity actor))
{
    TC(DemonEye, this);

	precache_sound("demon_eye/pain.wav");
	precache_sound("demon_eye/death.wav");

	actor.skin = bound(0, floor(random() * 5), 4);

    actor.health = 75;
	actor.th_stand = demon_eye_stand1;
	actor.th_walk = demon_eye_walk1;
	actor.th_run = demon_eye_run1;
	actor.th_melee = demon_eye_fast;
	actor.th_pain = demon_eye_pain;
	actor.th_die = demon_eye_die;
	//actor.checkattack = DemonEyeCheckAttack;

    return true;
}
#endif
