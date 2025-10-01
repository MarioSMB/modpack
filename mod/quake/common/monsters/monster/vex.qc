#include "vex.qh"

#ifdef SVQC
const int anim_vex_death = 0;
const int anim_vex_fly = 2;

void vex_run1(entity this);
void vex_side1(entity this);
void vex_fast1(entity this);

void vex_vanish(entity this)
{
	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

bool VexCheckAttack(entity this)
{
	if(time < this.attack_finished)
		return false;
	if(this.enemy_range == RANGE_FAR)
	{
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
			vex_run1(this);
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
			vex_run1(this);
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
			vex_run1(this);
		}
	}
	return false;
}

void VexAttackFinished(entity this)
{
	this.attack_state = AS_DODGING;
	setthink(this, vex_run1);
}

void VexStopSide(entity this)
{
	this.attack_state = AS_STRAIGHT;
	setthink(this, vex_run1);
}

void VexStartSide(entity this)
{
	this.attack_state = AS_SLIDING;
	setthink(this, vex_side1);
}

void Vex_idlesound(entity this)
{
	if(this.waitmin < time)
	{
		this.waitmin = time + 2;
		sound(this, CH_VOICE, SND_MON_VEX_IDLE_RANDOM(), 1, ATTN_NORM);
	}
}

void vex_stand1(entity this);
void vex_stand6(entity this) { set_anim(this, anim_vex_fly, vex_stand1); ai_stand(this); }
void vex_stand5(entity this) { set_anim(this, anim_vex_fly, vex_stand6); ai_stand(this); }
void vex_stand4(entity this) { set_anim(this, anim_vex_fly, vex_stand5); ai_stand(this); }
void vex_stand3(entity this) { set_anim(this, anim_vex_fly, vex_stand4); ai_stand(this); }
void vex_stand2(entity this) { set_anim(this, anim_vex_fly, vex_stand3); ai_stand(this); }
void vex_stand1(entity this) { set_anim(this, anim_vex_fly, vex_stand2); ai_stand(this); }

void vex_walk1(entity this);
void vex_walk8(entity this) { set_anim(this, anim_vex_fly, vex_walk1); ai_walk(this, 8); }
void vex_walk7(entity this) { set_anim(this, anim_vex_fly, vex_walk8); ai_walk(this, 8); }
void vex_walk6(entity this) { set_anim(this, anim_vex_fly, vex_walk7); ai_walk(this, 8); }
void vex_walk5(entity this) { set_anim(this, anim_vex_fly, vex_walk6); ai_walk(this, 8); }
void vex_walk4(entity this) { set_anim(this, anim_vex_fly, vex_walk5); ai_walk(this, 8); }
void vex_walk3(entity this) { set_anim(this, anim_vex_fly, vex_walk4); ai_walk(this, 8); }
void vex_walk2(entity this) { set_anim(this, anim_vex_fly, vex_walk3); ai_walk(this, 8); }
void vex_walk1(entity this) { set_anim(this, anim_vex_fly, vex_walk2); ai_walk(this, 8); Vex_idlesound(this); }

void vex_side1(entity this);
void vex_side8(entity this) { set_anim(this, anim_vex_fly, vex_run1); ai_run(this, 16); VexStopSide(this); }
void vex_side7(entity this) { set_anim(this, anim_vex_fly, vex_side8); ai_run(this, 16); }
void vex_side6(entity this) { set_anim(this, anim_vex_fly, vex_side7); ai_run(this, 16); }
void vex_side5(entity this) { set_anim(this, anim_vex_fly, vex_side6); ai_run(this, 16); }
void vex_side4(entity this) { set_anim(this, anim_vex_fly, vex_side5); ai_run(this, 16); }
void vex_side3(entity this) { set_anim(this, anim_vex_fly, vex_side4); ai_run(this, 16); }
void vex_side2(entity this) { set_anim(this, anim_vex_fly, vex_side3); ai_run(this, 16); }
void vex_side1(entity this) { set_anim(this, anim_vex_fly, vex_side2); ai_run(this, 16); Vex_idlesound(this); }

float vex_runspeed(entity this)
{
	if(this.enemy && this.attack_state == AS_DODGING && vdist(this.enemy.origin - this.origin, >=, 300))
		this.attack_state = AS_STRAIGHT;

	float dist = 24;
	if(this.attack_state == AS_DODGING)
		return dist * -0.5;
	return dist;
}

void vex_run1(entity this);
void vex_run6(entity this) { set_anim(this, anim_vex_fly, vex_run1); ai_run(this, vex_runspeed(this)); }
void vex_run5(entity this) { set_anim(this, anim_vex_fly, vex_run6); ai_run(this, vex_runspeed(this)); }
void vex_run4(entity this) { set_anim(this, anim_vex_fly, vex_run5); ai_run(this, vex_runspeed(this)); }
void vex_run3(entity this) { set_anim(this, anim_vex_fly, vex_run4); ai_run(this, vex_runspeed(this)); }
void vex_run2(entity this) { set_anim(this, anim_vex_fly, vex_run3); ai_run(this, vex_runspeed(this)); }
void vex_run1(entity this) { set_anim(this, anim_vex_fly, vex_run2); ai_run(this, vex_runspeed(this)); Vex_idlesound(this); }

void vex_swipe(entity this)
{
	if(!this.enemy)
		return;
	ai_charge(this, 0);
	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;
	float ldmg = (((random() + random()) + random()) * 3);
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_VEX.m_id);
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
}

void vex_fast8(entity this)
{
	set_anim(this, anim_vex_fly, vex_run1);
	ai_charge(this, 24);
	this.attack_finished = time + 4;
	VexAttackFinished(this);
}
void vex_fast7(entity this) { set_anim(this, anim_vex_fly, vex_fast8); ai_charge(this, 24); }
void vex_fast6(entity this) { set_anim(this, anim_vex_fly, vex_fast7); ai_charge(this, 24); }
void vex_fast5(entity this) { set_anim(this, anim_vex_fly, vex_fast6); ai_charge(this, 24); vex_swipe(this); }
void vex_fast4(entity this) { set_anim(this, anim_vex_fly, vex_fast5); ai_charge(this, 24); }
void vex_fast3(entity this) { set_anim(this, anim_vex_fly, vex_fast4); ai_charge(this, 24); }
void vex_fast2(entity this) { set_anim(this, anim_vex_fly, vex_fast3); ai_charge(this, 24); }
void vex_fast1(entity this) { set_anim(this, anim_vex_fly, vex_fast2); ai_charge(this, 24); }

void vex_fastb10(entity this)
{
	set_anim(this, anim_vex_fly, vex_run1);
	ai_charge(this, 24);
	this.attack_finished = time + 4;
}
void vex_fastb9(entity this) { set_anim(this, anim_vex_fly, vex_fastb10); ai_charge(this, 24); vex_swipe(this); }
void vex_fastb8(entity this) { set_anim(this, anim_vex_fly, vex_fastb9); ai_charge(this, 24); }
void vex_fastb7(entity this) { set_anim(this, anim_vex_fly, vex_fastb8); ai_charge(this, 24); }
void vex_fastb6(entity this) { set_anim(this, anim_vex_fly, vex_fastb7); ai_charge(this, 24); }
void vex_fastb5(entity this) { set_anim(this, anim_vex_fly, vex_fastb6); ai_charge(this, 24); }
void vex_fastb4(entity this) { set_anim(this, anim_vex_fly, vex_fastb5); ai_charge(this, 24); }
void vex_fastb3(entity this) { set_anim(this, anim_vex_fly, vex_fastb4); ai_charge(this, 24); }
void vex_fastb2(entity this) { set_anim(this, anim_vex_fly, vex_fastb3); ai_charge(this, 24); }
void vex_fastb1(entity this) { set_anim(this, anim_vex_fly, vex_fastb2); ai_charge(this, 24); }

void vex_fastc11(entity this)
{
	set_anim(this, anim_vex_fly, vex_run1);
	ai_charge(this, 24);
	this.attack_finished = time + 4;
	VexAttackFinished(this);
}
void vex_fastc10(entity this) { set_anim(this, anim_vex_fly, vex_fastc11); ai_charge(this, 24); }
void vex_fastc9(entity this) { set_anim(this, anim_vex_fly, vex_fastc10); ai_charge(this, 24); vex_swipe(this); }
void vex_fastc8(entity this) { set_anim(this, anim_vex_fly, vex_fastc9); ai_charge(this, 24); }
void vex_fastc7(entity this) { set_anim(this, anim_vex_fly, vex_fastc8); ai_charge(this, 24); }
void vex_fastc6(entity this) { set_anim(this, anim_vex_fly, vex_fastc7); ai_charge(this, 24); }
void vex_fastc5(entity this) { set_anim(this, anim_vex_fly, vex_fastc6); ai_charge(this, 24); }
void vex_fastc4(entity this) { set_anim(this, anim_vex_fly, vex_fastc5); ai_charge(this, 24); }
void vex_fastc3(entity this) { set_anim(this, anim_vex_fly, vex_fastc4); ai_charge(this, 24); }
void vex_fastc2(entity this) { set_anim(this, anim_vex_fly, vex_fastc3); ai_charge(this, 24); }
void vex_fastc1(entity this) { set_anim(this, anim_vex_fly, vex_fastc2); ai_charge(this, 24); }

void vex_fast(entity this)
{
	sound(this, CH_VOICE, SND_MON_VEX_CHARGE_RANDOM(), 1, ATTN_NORM);

	if(random() <= 0.3)
		vex_fast1(this);
	else if(random() <= 0.6)
		vex_fastb1(this);
	else
		vex_fastc1(this);
}

void vex_pain7(entity this) { set_anim(this, anim_vex_fly, vex_run1); VexStopSide(this); }
void vex_pain6(entity this) { set_anim(this, anim_vex_fly, vex_pain7); }
void vex_pain5(entity this) { set_anim(this, anim_vex_fly, vex_pain6); }
void vex_pain4(entity this) { set_anim(this, anim_vex_fly, vex_pain5); }
void vex_pain3(entity this) { set_anim(this, anim_vex_fly, vex_pain4); }
void vex_pain2(entity this) { set_anim(this, anim_vex_fly, vex_pain3); }
void vex_pain1(entity this) { set_anim(this, anim_vex_fly, vex_pain2); }

void vex_death10(entity this) { set_anim(this, anim_vex_death, vex_death10); vex_vanish(this); }
void vex_death9(entity this) { set_anim(this, anim_vex_death, vex_death10); }
void vex_death8(entity this) { set_anim(this, anim_vex_death, vex_death9); }
void vex_death7(entity this) { set_anim(this, anim_vex_death, vex_death8); }
void vex_death6(entity this) { set_anim(this, anim_vex_death, vex_death7); }
void vex_death5(entity this) { set_anim(this, anim_vex_death, vex_death6); }
void vex_death4(entity this) { set_anim(this, anim_vex_death, vex_death5); }
void vex_death3(entity this) { set_anim(this, anim_vex_death, vex_death4); }
void vex_death2(entity this) { set_anim(this, anim_vex_death, vex_death3); }
void vex_death1(entity this)
{
	set_anim(this, anim_vex_death, vex_death2);
	set_movetype(this, MOVETYPE_TOSS);
	this.velocity_x = -200 + (400 * random());
	this.velocity_y = -200 + (400 * random());
	this.velocity_z = 100 + (100 * random());
	UNSET_ONGROUND(this);
	this.solid = SOLID_NOT;
}

void vex_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(random() < 0.5)
		_sound(this, CH_VOICE, "vex/death1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "vex/death2.wav", 1, ATTN_NORM);

	vex_death1(this);
}

void vex_pain(entity this, entity attacker, float damage, int deathtype)
{
	if((random() * 70) > damage)
		return;
	if(this.pain_finished > time)
		return;
	if(random() < 0.5)
		_sound(this, CH_VOICE, "vex/hurt1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "vex/hurt2.wav", 1, ATTN_NORM);
	this.pain_finished = time + 0.2;
	vex_pain1(this);
}

spawnfunc(monster_vex) { monster_start(this, true, MON_VEX); }
#endif // SVQC

#ifdef SVQC
METHOD(Vex, mr_setup, bool(Vex this, entity actor))
{
    TC(Vex, this);

	precache_sound("vex/death1.wav");
	precache_sound("vex/death2.wav");
	precache_sound("vex/hurt1.wav");
	precache_sound("vex/hurt2.wav");

    actor.health = 50;
	actor.th_stand = vex_stand1;
	actor.th_walk = vex_walk1;
	actor.th_run = vex_run1;
	actor.th_melee = vex_fast;
	actor.th_pain = vex_pain;
	actor.th_die = vex_die;
	//actor.checkattack = VexCheckAttack;

    return true;
}
#endif
