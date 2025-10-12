#include "bee.qh"

#ifdef SVQC
void bee_run1(entity this);
void bee_side1(entity this);

void bee_anim(entity this, void(entity) tnk)
{
	this.walkframe += 1;
	if(this.walkframe > 3)
		this.walkframe = 0;
	this.frame = this.walkframe;
	this.nextthink = time + 0.1;
	setthink(this, tnk);
}

bool BeeCheckAttack(entity this)
{
	if(time < this.attack_finished)
		return false;
	if(this.enemy_range == RANGE_FAR)
	{
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
			bee_run1(this);
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
			bee_run1(this);
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
			bee_run1(this);
		}
	}
	return false;
}

void BeeAttackFinished(entity this)
{
	this.attack_state = AS_STRAIGHT;
	setthink(this, bee_run1);
}

void BeeStopSide(entity this)
{
	this.attack_state = AS_STRAIGHT;
	setthink(this, bee_run1);
}

void BeeStartSide(entity this)
{
	this.attack_state = AS_SLIDING;
	setthink(this, bee_side1);
}

void bee_stand1(entity this);
void bee_stand6(entity this) { bee_anim(this, bee_stand1); ai_stand(this); }
void bee_stand5(entity this) { bee_anim(this, bee_stand6); ai_stand(this); }
void bee_stand4(entity this) { bee_anim(this, bee_stand5); ai_stand(this); }
void bee_stand3(entity this) { bee_anim(this, bee_stand4); ai_stand(this); }
void bee_stand2(entity this) { bee_anim(this, bee_stand3); ai_stand(this); }
void bee_stand1(entity this) { bee_anim(this, bee_stand2); ai_stand(this); }

void bee_walk1(entity this);
void bee_walk8(entity this) { bee_anim(this, bee_walk1); ai_walk(this, 8); }
void bee_walk7(entity this) { bee_anim(this, bee_walk8); ai_walk(this, 8); }
void bee_walk6(entity this) { bee_anim(this, bee_walk7); ai_walk(this, 8); }
void bee_walk5(entity this) { bee_anim(this, bee_walk6); ai_walk(this, 8); }
void bee_walk4(entity this) { bee_anim(this, bee_walk5); ai_walk(this, 8); }
void bee_walk3(entity this) { bee_anim(this, bee_walk4); ai_walk(this, 8); }
void bee_walk2(entity this) { bee_anim(this, bee_walk3); ai_walk(this, 8); }
void bee_walk1(entity this) { bee_anim(this, bee_walk2); ai_walk(this, 8); }

void bee_side8(entity this) { bee_anim(this, bee_run1); ai_run(this, 16); BeeStopSide(this); }
void bee_side7(entity this) { bee_anim(this, bee_side8); ai_run(this, 16); }
void bee_side6(entity this) { bee_anim(this, bee_side7); ai_run(this, 16); }
void bee_side5(entity this) { bee_anim(this, bee_side6); ai_run(this, 16); }
void bee_side4(entity this) { bee_anim(this, bee_side5); ai_run(this, 16); }
void bee_side3(entity this) { bee_anim(this, bee_side4); ai_run(this, 16); }
void bee_side2(entity this) { bee_anim(this, bee_side3); ai_run(this, 16); }
void bee_side1(entity this) { bee_anim(this, bee_side2); ai_run(this, 16); }

void bee_run6(entity this) { bee_anim(this, bee_run1); ai_run(this, 24); }
void bee_run5(entity this) { bee_anim(this, bee_run6); ai_run(this, 24); }
void bee_run4(entity this) { bee_anim(this, bee_run5); ai_run(this, 24); }
void bee_run3(entity this) { bee_anim(this, bee_run4); ai_run(this, 24); }
void bee_run2(entity this) { bee_anim(this, bee_run3); ai_run(this, 24); }
void bee_run1(entity this) { bee_anim(this, bee_run2); ai_run(this, 24); }

void bee_swipe(entity this)
{
	if(!this.enemy)
		return;
	ai_charge(this, 0);
	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;
	float ldmg = 2 + (random() * 2);
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_BEE.m_id);
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
}

void bee_fast8(entity this)
{
	bee_anim(this, bee_run1);
	ai_charge(this, 24);
	this.attack_finished = time + 2;
	BeeAttackFinished(this);
}
void bee_fast7(entity this) { bee_anim(this, bee_fast8); ai_charge(this, 24); }
void bee_fast6(entity this) { bee_anim(this, bee_fast7); ai_charge(this, 24); }
void bee_fast5(entity this) { bee_anim(this, bee_fast6); ai_charge(this, 24); bee_swipe(this); }
void bee_fast4(entity this) { bee_anim(this, bee_fast5); ai_charge(this, 24); }
void bee_fast3(entity this) { bee_anim(this, bee_fast4); ai_charge(this, 24); }
void bee_fast2(entity this) { bee_anim(this, bee_fast3); ai_charge(this, 24); }
void bee_fast1(entity this) { bee_anim(this, bee_fast2); ai_charge(this, 24); }

void bee_fastb10(entity this)
{
	bee_anim(this, bee_run1);
	ai_charge(this, 24);
	this.attack_finished = time + 2;
}
void bee_fastb9(entity this) { bee_anim(this, bee_fastb10); ai_charge(this, 24); bee_swipe(this); }
void bee_fastb8(entity this) { bee_anim(this, bee_fastb9); ai_charge(this, 24); }
void bee_fastb7(entity this) { bee_anim(this, bee_fastb8); ai_charge(this, 24); }
void bee_fastb6(entity this) { bee_anim(this, bee_fastb7); ai_charge(this, 24); }
void bee_fastb5(entity this) { bee_anim(this, bee_fastb6); ai_charge(this, 24); bee_swipe(this); }
void bee_fastb4(entity this) { bee_anim(this, bee_fastb5); ai_charge(this, 24); }
void bee_fastb3(entity this) { bee_anim(this, bee_fastb4); ai_charge(this, 24); }
void bee_fastb2(entity this) { bee_anim(this, bee_fastb3); ai_charge(this, 24); }
void bee_fastb1(entity this) { bee_anim(this, bee_fastb2); ai_charge(this, 24); }

void bee_fastc11(entity this)
{
	bee_anim(this, bee_run1);
	ai_charge(this, 24);
	this.attack_finished = time + 2;
	BeeAttackFinished(this);
}
void bee_fastc10(entity this) { bee_anim(this, bee_fastc11); ai_charge(this, 24); }
void bee_fastc9(entity this) { bee_anim(this, bee_fastc10); ai_charge(this, 24); bee_swipe(this); }
void bee_fastc8(entity this) { bee_anim(this, bee_fastc9); ai_charge(this, 24); }
void bee_fastc7(entity this) { bee_anim(this, bee_fastc8); ai_charge(this, 24); }
void bee_fastc6(entity this) { bee_anim(this, bee_fastc7); ai_charge(this, 24); }
void bee_fastc5(entity this) { bee_anim(this, bee_fastc6); ai_charge(this, 24); bee_swipe(this); }
void bee_fastc4(entity this) { bee_anim(this, bee_fastc5); ai_charge(this, 24); }
void bee_fastc3(entity this) { bee_anim(this, bee_fastc4); ai_charge(this, 24); }
void bee_fastc2(entity this) { bee_anim(this, bee_fastc3); ai_charge(this, 24); }
void bee_fastc1(entity this) { bee_anim(this, bee_fastc2); ai_charge(this, 24); bee_swipe(this); }

void bee_fast(entity this)
{
	if(random() <= 0.3)
		bee_fast1(this);
	else if(random() <= 0.6)
		bee_fastb1(this);
	else
		bee_fastc1(this);
}

void bee_pain7(entity this) { bee_anim(this, bee_run1); BeeStopSide(this); }
void bee_pain6(entity this) { bee_anim(this, bee_pain7); }
void bee_pain5(entity this) { bee_anim(this, bee_pain6); }
void bee_pain4(entity this) { bee_anim(this, bee_pain5); }
void bee_pain3(entity this) { bee_anim(this, bee_pain4); }
void bee_pain2(entity this) { bee_anim(this, bee_pain3); }
void bee_pain1(entity this) { bee_anim(this, bee_pain2); }

void bee_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CH_VOICE, "bee/death.wav", 1, ATTN_NORM);

	particle(this.origin, '0 0 0', 79, (random() * 40) * 1);
	particle(this.origin, '0 0 0', 74, (random() * 40) * 5);
	particle(this.origin, '0 0 0', 69, (random() * 40) * 2);

	delete(this);
}

void bee_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	_sound(this, CHAN_BODY, "bee/pain.wav", 1, ATTN_NORM);
	bee_pain1(this);
	this.pain_finished = time + 0.2;
}

spawnfunc(monster_bee) { monster_start(this, true, MON_BEE); }
#endif // SVQC

#ifdef SVQC
METHOD(Bee, mr_setup, bool(Bee this, entity actor))
{
    TC(Bee, this);

	precache_sound("bee/pain.wav");
	precache_sound("bee/death.wav");

	actor.poisonous = true;

    actor.health = 25;
	actor.th_stand = bee_stand1;
	actor.th_walk = bee_walk1;
	actor.th_run = bee_run1;
	actor.th_melee = bee_fast;
	actor.th_pain = bee_pain;
	actor.th_die = bee_die;
	//actor.checkattack = BeeCheckAttack;

    return true;
}
#endif
