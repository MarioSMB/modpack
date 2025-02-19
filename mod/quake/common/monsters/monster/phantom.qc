#include "phantom.qh"

#ifdef SVQC
void phantom_run1(entity this);
void phantom_side1(entity this);
void phantom_fast1(entity this);

void phantom_vanish(entity this)
{
	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

bool PhantomCheckAttack(entity this)
{
	if(time < this.attack_finished)
		return false;
	if(this.enemy_range == RANGE_FAR)
	{
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
			phantom_run1(this);
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
			phantom_run1(this);
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
			phantom_run1(this);
		}
	}
	return false;
}

void PhantomAttackFinished(entity this)
{
	this.attack_state = AS_STRAIGHT;
	setthink(this, phantom_run1);
}

void PhantomStopSide(entity this)
{
	this.attack_state = AS_STRAIGHT;
	setthink(this, phantom_run1);
}

void PhantomStartSide(entity this)
{
	this.attack_state = AS_SLIDING;
	setthink(this, phantom_side1);
}

void Phantom_idlesound(entity this)
{
	if(this.waitmin < time)
	{
		this.waitmin = time + 2 + (random() * 2);
		if(random() < 0.5)
			sound(this, CH_VOICE, SND_MON_PHANTOM_FLAP_RANDOM(), 1, ATTN_NORM);
		else
			sound(this, CH_VOICE, SND_MON_PHANTOM_IDLE_RANDOM(), 1, ATTN_NORM);
	}
}

void phantom_stand1(entity this);
void phantom_stand6(entity this) { set_anim(this, 31, phantom_stand1); ai_stand(this); }
void phantom_stand5(entity this) { set_anim(this, 30, phantom_stand6); ai_stand(this); }
void phantom_stand4(entity this) { set_anim(this, 29, phantom_stand5); ai_stand(this); }
void phantom_stand3(entity this) { set_anim(this, 28, phantom_stand4); ai_stand(this); }
void phantom_stand2(entity this) { set_anim(this, 27, phantom_stand3); ai_stand(this); }
void phantom_stand1(entity this) { set_anim(this, 26, phantom_stand2); ai_stand(this); Phantom_idlesound(this); }

void phantom_walk1(entity this);
void phantom_walk8(entity this) { set_anim(this, 55, phantom_walk1); ai_walk(this, 8); }
void phantom_walk7(entity this) { set_anim(this, 54, phantom_walk8); ai_walk(this, 8); }
void phantom_walk6(entity this) { set_anim(this, 53, phantom_walk7); ai_walk(this, 8); }
void phantom_walk5(entity this) { set_anim(this, 52, phantom_walk6); ai_walk(this, 8); }
void phantom_walk4(entity this) { set_anim(this, 51, phantom_walk5); ai_walk(this, 8); }
void phantom_walk3(entity this) { set_anim(this, 50, phantom_walk4); ai_walk(this, 8); }
void phantom_walk2(entity this) { set_anim(this, 49, phantom_walk3); ai_walk(this, 8); }
void phantom_walk1(entity this) { set_anim(this, 48, phantom_walk2); ai_walk(this, 8); Phantom_idlesound(this); }

void phantom_side1(entity this);
void phantom_side8(entity this) { set_anim(this, 45, phantom_run1); ai_run(this, 16); PhantomStopSide(this); }
void phantom_side7(entity this) { set_anim(this, 44, phantom_side8); ai_run(this, 16); }
void phantom_side6(entity this) { set_anim(this, 43, phantom_side7); ai_run(this, 16); }
void phantom_side5(entity this) { set_anim(this, 42, phantom_side6); ai_run(this, 16); }
void phantom_side4(entity this) { set_anim(this, 41, phantom_side5); ai_run(this, 16); }
void phantom_side3(entity this) { set_anim(this, 40, phantom_side4); ai_run(this, 16); }
void phantom_side2(entity this) { set_anim(this, 39, phantom_side3); ai_run(this, 16); }
void phantom_side1(entity this) { set_anim(this, 38, phantom_side2); ai_run(this, 16); Phantom_idlesound(this); }

void phantom_run1(entity this);
void phantom_run6(entity this) { set_anim(this, 37, phantom_run1); ai_run(this, 24); }
void phantom_run5(entity this) { set_anim(this, 36, phantom_run6); ai_run(this, 24); }
void phantom_run4(entity this) { set_anim(this, 35, phantom_run5); ai_run(this, 24); }
void phantom_run3(entity this) { set_anim(this, 34, phantom_run4); ai_run(this, 24); }
void phantom_run2(entity this) { set_anim(this, 33, phantom_run3); ai_run(this, 24); }
void phantom_run1(entity this) { set_anim(this, 32, phantom_run2); ai_run(this, 24); Phantom_idlesound(this); }

void phantom_swipe(entity this)
{
	if(!this.enemy)
		return;
	ai_charge(this, 0);
	if(random() < 0.5)
		_sound(this, CH_WEAPON_SINGLE, "phantom/bite1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "phantom/bite2.wav", 1, ATTN_NORM);
	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;
	float ldmg = (((random() + random()) + random()) * 3);
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_PHANTOM.m_id);
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
}

void phantom_fast8(entity this)
{
	set_anim(this, 71, phantom_run1);
	ai_charge(this, 24);
	this.attack_finished = time + 2;
	PhantomAttackFinished(this);
}
void phantom_fast7(entity this) { set_anim(this, 70, phantom_fast8); ai_charge(this, 24); }
void phantom_fast6(entity this) { set_anim(this, 69, phantom_fast7); ai_charge(this, 24); }
void phantom_fast5(entity this) { set_anim(this, 68, phantom_fast6); ai_charge(this, 24); phantom_swipe(this); }
void phantom_fast4(entity this) { set_anim(this, 67, phantom_fast5); ai_charge(this, 24); }
void phantom_fast3(entity this) { set_anim(this, 66, phantom_fast4); ai_charge(this, 24); }
void phantom_fast2(entity this) { set_anim(this, 65, phantom_fast3); ai_charge(this, 24); }
void phantom_fast1(entity this) { set_anim(this, 64, phantom_fast2); ai_charge(this, 24); }

void phantom_fastb10(entity this)
{
	set_anim(this, 81, phantom_run1);
	ai_charge(this, 24);
	this.attack_finished = time + 2;
}
void phantom_fastb9(entity this) { set_anim(this, 80, phantom_fastb10); ai_charge(this, 24); phantom_swipe(this); }
void phantom_fastb8(entity this) { set_anim(this, 79, phantom_fastb9); ai_charge(this, 24); }
void phantom_fastb7(entity this) { set_anim(this, 78, phantom_fastb8); ai_charge(this, 24); }
void phantom_fastb6(entity this) { set_anim(this, 77, phantom_fastb7); ai_charge(this, 24); }
void phantom_fastb5(entity this) { set_anim(this, 76, phantom_fastb6); ai_charge(this, 24); phantom_swipe(this); }
void phantom_fastb4(entity this) { set_anim(this, 75, phantom_fastb5); ai_charge(this, 24); }
void phantom_fastb3(entity this) { set_anim(this, 74, phantom_fastb4); ai_charge(this, 24); }
void phantom_fastb2(entity this) { set_anim(this, 73, phantom_fastb3); ai_charge(this, 24); }
void phantom_fastb1(entity this) { set_anim(this, 72, phantom_fastb2); ai_charge(this, 24); }

void phantom_fastc11(entity this)
{
	set_anim(this, 92, phantom_run1);
	ai_charge(this, 24);
	this.attack_finished = time + 2;
	PhantomAttackFinished(this);
}
void phantom_fastc10(entity this) { set_anim(this, 91, phantom_fastc11); ai_charge(this, 24); }
void phantom_fastc9(entity this) { set_anim(this, 90, phantom_fastc10); ai_charge(this, 24); phantom_swipe(this); }
void phantom_fastc8(entity this) { set_anim(this, 89, phantom_fastc9); ai_charge(this, 24); }
void phantom_fastc7(entity this) { set_anim(this, 88, phantom_fastc8); ai_charge(this, 24); }
void phantom_fastc6(entity this) { set_anim(this, 87, phantom_fastc7); ai_charge(this, 24); }
void phantom_fastc5(entity this) { set_anim(this, 86, phantom_fastc6); ai_charge(this, 24); phantom_swipe(this); }
void phantom_fastc4(entity this) { set_anim(this, 85, phantom_fastc5); ai_charge(this, 24); }
void phantom_fastc3(entity this) { set_anim(this, 84, phantom_fastc4); ai_charge(this, 24); }
void phantom_fastc2(entity this) { set_anim(this, 83, phantom_fastc3); ai_charge(this, 24); }
void phantom_fastc1(entity this) { set_anim(this, 82, phantom_fastc2); ai_charge(this, 24); phantom_swipe(this); }

void phantom_fast(entity this)
{
	if(random() <= 0.3)
		phantom_fast1(this);
	else if(random() <= 0.6)
		phantom_fastb1(this);
	else
		phantom_fastc1(this);
}

void phantom_pain7(entity this) { set_anim(this, 99, phantom_run1); PhantomStopSide(this); }
void phantom_pain6(entity this) { set_anim(this, 98, phantom_pain7); }
void phantom_pain5(entity this) { set_anim(this, 97, phantom_pain6); }
void phantom_pain4(entity this) { set_anim(this, 96, phantom_pain5); }
void phantom_pain3(entity this) { set_anim(this, 95, phantom_pain4); }
void phantom_pain2(entity this) { set_anim(this, 94, phantom_pain3); }
void phantom_pain1(entity this) { set_anim(this, 93, phantom_pain2); }

void phantom_painb7(entity this) { set_anim(this, 106, phantom_run1); PhantomStopSide(this); }
void phantom_painb6(entity this) { set_anim(this, 105, phantom_painb7); }
void phantom_painb5(entity this) { set_anim(this, 104, phantom_painb6); }
void phantom_painb4(entity this) { set_anim(this, 103, phantom_painb5); }
void phantom_painb3(entity this) { set_anim(this, 102, phantom_painb4); }
void phantom_painb2(entity this) { set_anim(this, 101, phantom_painb3); }
void phantom_painb1(entity this) { set_anim(this, 100, phantom_painb2); }

void phantom_death10(entity this) { set_anim(this, 116, phantom_death10); phantom_vanish(this); }
void phantom_death9(entity this) { set_anim(this, 115, phantom_death10); }
void phantom_death8(entity this) { set_anim(this, 114, phantom_death9); }
void phantom_death7(entity this) { set_anim(this, 113, phantom_death8); }
void phantom_death6(entity this) { set_anim(this, 112, phantom_death7); }
void phantom_death5(entity this) { set_anim(this, 111, phantom_death6); }
void phantom_death4(entity this) { set_anim(this, 110, phantom_death5); }
void phantom_death3(entity this) { set_anim(this, 109, phantom_death4); }
void phantom_death2(entity this) { set_anim(this, 108, phantom_death3); }
void phantom_death1(entity this)
{
	set_anim(this, 107, phantom_death2);
	set_movetype(this, MOVETYPE_TOSS);
	this.velocity_x = -200 + (400 * random());
	this.velocity_y = -200 + (400 * random());
	this.velocity_z = 100 + (100 * random());
	UNSET_ONGROUND(this);
	this.solid = SOLID_NOT;
}

void phantom_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	sound(this, CH_VOICE, SND_MON_PHANTOM_DIE_RANDOM(), 1, ATTN_NORM);

	phantom_death1(this);
}

void phantom_pain(entity this, entity attacker, float damage, int deathtype)
{
	if((random() * 70) > damage)
		return;
	if(this.pain_finished > time)
		return;
	sound(this, CHAN_BODY, SND_MON_PHANTOM_PAIN_RANDOM(), 1, ATTN_NORM);
	phantom_pain1(this);
	this.pain_finished = time + 0.2;
}

spawnfunc(monster_phantom) { monster_start(this, true, MON_PHANTOM); }
#endif // SVQC

#ifdef SVQC
METHOD(Phantom, mr_setup, bool(Phantom this, entity actor))
{
    TC(Phantom, this);

	precache_sound("phantom/bite1.wav");
	precache_sound("phantom/bite2.wav");

    actor.health = 70;
	actor.th_stand = phantom_stand1;
	actor.th_walk = phantom_walk1;
	actor.th_run = phantom_run1;
	actor.th_melee = phantom_fast;
	actor.th_pain = phantom_pain;
	actor.th_die = phantom_die;
	//actor.checkattack = PhantomCheckAttack;

    return true;
}
METHOD(Phantom, mr_sight, bool(Phantom this, entity actor))
{
    TC(Phantom, this);

	sound(actor, CH_VOICE, SND_MON_PHANTOM_SIGHT_RANDOM(), 1, ATTN_NORM);

    return true;
}
#endif
