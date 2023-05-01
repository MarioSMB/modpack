#include "grenling.qh"

#ifdef SVQC
void gren_run1(entity this);
void gren_side1(entity this);
void gren_fast1(entity this);

bool GrenCheckAttack(entity this)
{
	if(time < this.attack_finished)
		return false;
	if(this.enemy_range == RANGE_FAR)
	{
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
			gren_run1(this);
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
			gren_run1(this);
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
			gren_run1(this);
		}
	}
	return false;
}

void GrenAttackFinished(entity this)
{
	this.attack_state = AS_STRAIGHT;
	setthink(this, gren_run1);
}

void GrenStopSide(entity this)
{
	this.attack_state = AS_STRAIGHT;
	setthink(this, gren_run1);
}

void GrenStartSide(entity this)
{
	this.attack_state = AS_SLIDING;
	setthink(this, gren_side1);
}

void Gren_idlesound(entity this)
{
	float wr = random() * 5;
	if(this.waitmin < time)
	{
		this.waitmin = (time + 2);
		if(wr > 3.5)
			_sound(this, CHAN_ITEM, "monsters/grenling/grcoon.wav", 1, ATTN_IDLE);
		if(wr < 3)
			_sound(this, CHAN_AUTO, "monsters/grenling/grhover.wav", 1, ATTN_IDLE);
		if(wr < 2)
			_sound(this, CHAN_AUTO, "monsters/grenling/grtalk1.wav", 1, ATTN_NORM);
		if(wr > 4)
			_sound(this, CHAN_AUTO, "monsters/grenling/grtalk2.wav", 1, ATTN_NORM);
	}
}

void gren_stand1(entity this);
void gren_stand6(entity this) { set_anim(this, 31, gren_stand1); ai_stand(this); }
void gren_stand5(entity this) { set_anim(this, 30, gren_stand6); ai_stand(this); }
void gren_stand4(entity this) { set_anim(this, 29, gren_stand5); ai_stand(this); }
void gren_stand3(entity this) { set_anim(this, 28, gren_stand4); ai_stand(this); }
void gren_stand2(entity this) { set_anim(this, 27, gren_stand3); ai_stand(this); }
void gren_stand1(entity this) { set_anim(this, 26, gren_stand2); ai_stand(this); }

void gren_walk1(entity this);
void gren_walk8(entity this) { set_anim(this, 55, gren_walk1); ai_walk(this, 8); }
void gren_walk7(entity this) { set_anim(this, 54, gren_walk8); ai_walk(this, 8); }
void gren_walk6(entity this) { set_anim(this, 53, gren_walk7); ai_walk(this, 8); }
void gren_walk5(entity this) { set_anim(this, 52, gren_walk6); ai_walk(this, 8); }
void gren_walk4(entity this) { set_anim(this, 51, gren_walk5); ai_walk(this, 8); }
void gren_walk3(entity this) { set_anim(this, 50, gren_walk4); ai_walk(this, 8); }
void gren_walk2(entity this) { set_anim(this, 49, gren_walk3); ai_walk(this, 8); }
void gren_walk1(entity this) { set_anim(this, 48, gren_walk2); ai_walk(this, 8); Gren_idlesound(this); }

void gren_side1(entity this);
void gren_side8(entity this) { set_anim(this, 45, gren_run1); ai_run(this, 16); GrenStopSide(this); }
void gren_side7(entity this) { set_anim(this, 44, gren_side8); ai_run(this, 16); }
void gren_side6(entity this) { set_anim(this, 43, gren_side7); ai_run(this, 16); }
void gren_side5(entity this) { set_anim(this, 42, gren_side6); ai_run(this, 16); }
void gren_side4(entity this) { set_anim(this, 41, gren_side5); ai_run(this, 16); }
void gren_side3(entity this) { set_anim(this, 40, gren_side4); ai_run(this, 16); }
void gren_side2(entity this) { set_anim(this, 39, gren_side3); ai_run(this, 16); }
void gren_side1(entity this) { set_anim(this, 38, gren_side2); ai_run(this, 16); Gren_idlesound(this); }

void gren_run1(entity this);
void gren_run6(entity this) { set_anim(this, 37, gren_run1); ai_run(this, 24); }
void gren_run5(entity this) { set_anim(this, 36, gren_run6); ai_run(this, 24); }
void gren_run4(entity this) { set_anim(this, 35, gren_run5); ai_run(this, 24); }
void gren_run3(entity this) { set_anim(this, 34, gren_run4); ai_run(this, 24); }
void gren_run2(entity this) { set_anim(this, 33, gren_run3); ai_run(this, 24); }
void gren_run1(entity this) { set_anim(this, 32, gren_run2); ai_run(this, 24); Gren_idlesound(this); }

void Gren_Swipe(entity this)
{
	if(!this.enemy)
		return;
	ai_charge(this, 0);
	if(vdist(this.enemy.origin - this.origin, >, 100))
	{
		_sound(this, CHAN_WEAPON, "monsters/grenling/grswipe.wav", 1, ATTN_NORM);
		return;
	}
	if(!CanDamage(this.enemy, this))
	{
		_sound(this, CHAN_WEAPON, "monsters/grenling/grswipe.wav", 1, ATTN_NORM);
		return;
	}
	float ldmg = (((random() + random()) + random()) * 3);
	T_Damage(this.enemy, this, this, ldmg);
	_sound(this, CHAN_AUTO, "monsters/grenling/grcut.wav", 1, ATTN_NORM);
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
}

void gren_fast8(entity this)
{
	set_anim(this, 71, gren_run1);
	ai_charge(this, 24);
	SUB_AttackFinished(this, 2);
	GrenAttackFinished(this);
}
void gren_fast7(entity this) { set_anim(this, 70, gren_fast8); ai_charge(this, 24); }
void gren_fast6(entity this) { set_anim(this, 69, gren_fast7); ai_charge(this, 24); }
void gren_fast5(entity this) { set_anim(this, 68, gren_fast6); ai_charge(this, 24); Gren_Swipe(this); }
void gren_fast4(entity this) { set_anim(this, 67, gren_fast5); ai_charge(this, 24); }
void gren_fast3(entity this) { set_anim(this, 66, gren_fast4); ai_charge(this, 24); }
void gren_fast2(entity this) { set_anim(this, 65, gren_fast3); ai_charge(this, 24); }
void gren_fast1(entity this) { set_anim(this, 64, gren_fast2); ai_charge(this, 24); }

void gren_fastb10(entity this)
{
	set_anim(this, 81, gren_run1);
	ai_charge(this, 24);
	SUB_AttackFinished(this, 2);
}
void gren_fastb9(entity this) { set_anim(this, 80, gren_fastb10); ai_charge(this, 24); Gren_Swipe(this); }
void gren_fastb8(entity this) { set_anim(this, 79, gren_fastb9); ai_charge(this, 24); }
void gren_fastb7(entity this) { set_anim(this, 78, gren_fastb8); ai_charge(this, 24); }
void gren_fastb6(entity this) { set_anim(this, 77, gren_fastb7); ai_charge(this, 24); }
void gren_fastb5(entity this) { set_anim(this, 76, gren_fastb6); ai_charge(this, 24); Gren_Swipe(this); }
void gren_fastb4(entity this) { set_anim(this, 75, gren_fastb5); ai_charge(this, 24); }
void gren_fastb3(entity this) { set_anim(this, 74, gren_fastb4); ai_charge(this, 24); }
void gren_fastb2(entity this) { set_anim(this, 73, gren_fastb3); ai_charge(this, 24); }
void gren_fastb1(entity this) { set_anim(this, 72, gren_fastb2); ai_charge(this, 24); }

void gren_fastc11(entity this)
{
	set_anim(this, 92, gren_run1);
	ai_charge(this, 24);
	SUB_AttackFinished(this, 2);
	GrenAttackFinished(this);
}
void gren_fastc10(entity this) { set_anim(this, 91, gren_fastc11); ai_charge(this, 24); }
void gren_fastc9(entity this) { set_anim(this, 90, gren_fastc10); ai_charge(this, 24); Gren_Swipe(this); }
void gren_fastc8(entity this) { set_anim(this, 89, gren_fastc9); ai_charge(this, 24); }
void gren_fastc7(entity this) { set_anim(this, 88, gren_fastc8); ai_charge(this, 24); }
void gren_fastc6(entity this) { set_anim(this, 87, gren_fastc7); ai_charge(this, 24); }
void gren_fastc5(entity this) { set_anim(this, 86, gren_fastc6); ai_charge(this, 24); Gren_Swipe(this); }
void gren_fastc4(entity this) { set_anim(this, 85, gren_fastc5); ai_charge(this, 24); }
void gren_fastc3(entity this) { set_anim(this, 84, gren_fastc4); ai_charge(this, 24); }
void gren_fastc2(entity this) { set_anim(this, 83, gren_fastc3); ai_charge(this, 24); }
void gren_fastc1(entity this) { set_anim(this, 82, gren_fastc2); ai_charge(this, 24); Gren_Swipe(this); }

void gren_fast(entity this)
{
	if(random() <= 0.3)
		gren_fast1(this);
	else if(random() <= 0.6)
		gren_fastb1(this);
	else
		gren_fastc1(this);
}

void gren_pain7(entity this) { set_anim(this, 99, gren_run1); GrenStopSide(this); }
void gren_pain6(entity this) { set_anim(this, 98, gren_pain7); }
void gren_pain5(entity this) { set_anim(this, 97, gren_pain6); }
void gren_pain4(entity this) { set_anim(this, 96, gren_pain5); }
void gren_pain3(entity this) { set_anim(this, 95, gren_pain4); }
void gren_pain2(entity this) { set_anim(this, 94, gren_pain3); }
void gren_pain1(entity this) { set_anim(this, 93, gren_pain2); }

void gren_painb7(entity this) { set_anim(this, 106, gren_run1); GrenStopSide(this); }
void gren_painb6(entity this) { set_anim(this, 105, gren_painb7); }
void gren_painb5(entity this) { set_anim(this, 104, gren_painb6); }
void gren_painb4(entity this) { set_anim(this, 103, gren_painb5); }
void gren_painb3(entity this) { set_anim(this, 102, gren_painb4); }
void gren_painb2(entity this) { set_anim(this, 101, gren_painb3); }
void gren_painb1(entity this) { set_anim(this, 100, gren_painb2); }

void gren_death10(entity this) { set_anim(this, 116, gren_death10); CorpseThink(this); }
void gren_death9(entity this) { set_anim(this, 115, gren_death10); }
void gren_death8(entity this) { set_anim(this, 114, gren_death9); }
void gren_death7(entity this) { set_anim(this, 113, gren_death8); }
void gren_death6(entity this) { set_anim(this, 112, gren_death7); }
void gren_death5(entity this) { set_anim(this, 111, gren_death6); }
void gren_death4(entity this) { set_anim(this, 110, gren_death5); }
void gren_death3(entity this) { set_anim(this, 109, gren_death4); }
void gren_death2(entity this) { set_anim(this, 108, gren_death3); }
void gren_death1(entity this)
{
	set_anim(this, 107, gren_death2);
	this.velocity_x = -200 + (400 * random());
	this.velocity_y = -200 + (400 * random());
	this.velocity_z = 100 + (100 * random());
	UNSET_ONGROUND(this);
	_sound(this, CHAN_VOICE, "monsters/grenling/grdie1.wav", 1, ATTN_NORM);
	this.solid = SOLID_NOT;
	setsize(this, '-29 -21 -8', '29 24 4');
}

void gren_deathb11(entity this) { set_anim(this, 129, gren_deathb11); CorpseThink(this); }
void gren_deathb10(entity this) { set_anim(this, 128, gren_deathb11); }
void gren_deathb9(entity this) { set_anim(this, 127, gren_deathb10); }
void gren_deathb8(entity this) { set_anim(this, 126, gren_deathb9); }
void gren_deathb7(entity this) { set_anim(this, 125, gren_deathb8); }
void gren_deathb6(entity this) { set_anim(this, 124, gren_deathb7); }
void gren_deathb5(entity this) { set_anim(this, 123, gren_deathb6); }
void gren_deathb4(entity this) { set_anim(this, 122, gren_deathb5); }
void gren_deathb3(entity this) { set_anim(this, 121, gren_deathb4); }
void gren_deathb2(entity this) { set_anim(this, 120, gren_deathb3); }
void gren_deathb1(entity this)
{
	set_anim(this, 119, gren_deathb2);
	this.velocity_x = -200 + (400 * random());
	this.velocity_y = -200 + (400 * random());
	this.velocity_z = 100 + (100 * random());
	UNSET_ONGROUND(this);
	_sound(this, CHAN_VOICE, "monsters/grenling/grdie2.wav", 1, ATTN_NORM);
	this.solid = SOLID_NOT;
	setsize(this, '-8 -8 -8', '8 8 4');
}

void gren_die(entity this, entity inflictor, entity attacker)
{
	if(this.health < -40)
	{
		_sound(this, CHAN_VOICE, "monsters/grenling/grdie1.wav", 1, ATTN_NORM);
		ThrowHead(this, "progs/h_gren.mdl", this.health);
		ThrowGib(this, "progs/grenbone.mdl", this.health);
		ThrowGib(this, "progs/grenbone.mdl", this.health);
		ThrowGib(this, "progs/grenbone.mdl", this.health);
		ThrowGib(this, "progs/grenbone.mdl", this.health);
		ThrowGib(this, "progs/gib2.mdl", this.health);
		ThrowGib(this, "progs/gib2.mdl", this.health);
		return;
	}
	if(random() < 0.5)
		gren_death1(this);
	else
		gren_deathb1(this);
}

void Gren_Pain(entity this, entity attacker, float damage)
{
	if((random() * 70) > damage)
		return;
	if(this.pain_finished > time)
		return;
	if(random() > 0.5)
	{
		_sound(this, CHAN_BODY, "monsters/grenling/grpain1.wav", 1, ATTN_NORM);
		gren_pain1(this);
		this.pain_finished = time + 0.2;
	}
	else
	{
		_sound(this, CHAN_BODY, "monsters/grenling/grpain2.wav", 1, ATTN_NORM);
		gren_painb1(this);
		this.pain_finished = time + 0.4;
	}
}

string gren_sight(entity this)
{
	return ((random() > 0.5) ? "monsters/grenling/grsight1.wav" : "monsters/grenling/grsight2.wav");
}
string gren_deathmessage(entity this) { return "was ripped to shreds by a Grenling"; }
string grenling_deathmessage(entity this) { return "was torn to pieces by a Grenling"; }

spawnfunc(monster_grenling)
{
	if(!MP_IMPEL) { delete(this); return; }
	monster_start(this, MON_GRENLING);
}
spawnfunc(monster_gren)
{
	if(!MP_IMPEL) { delete(this); return; }
	monster_start(this, MON_GRENLING);
	if(!wasfreed(this))
		this.deathmessage = gren_deathmessage;
}
#endif // SVQC

#ifdef SVQC
METHOD(Grenling, mr_setup, bool(Grenling this, entity actor))
{
    TC(Grenling, this);

	precache_model("progs/grenbone.mdl");
	precache_model("progs/w_spike.mdl");
	precache_sound("monsters/grenling/grswipe.wav");
	precache_sound("monsters/grenling/grcut.wav");
	precache_sound("monsters/grenling/grtalk1.wav");
	precache_sound("monsters/grenling/grtalk2.wav");
	precache_sound("monsters/grenling/grcoon.wav");
	precache_sound("monsters/grenling/grdie1.wav");
	precache_sound("monsters/grenling/grdie2.wav");
	precache_sound("monsters/grenling/grhover.wav");
	precache_sound("monsters/grenling/grpain1.wav");
	precache_sound("monsters/grenling/grpain2.wav");
	precache_sound("monsters/grenling/grsight1.wav");
	precache_sound("monsters/grenling/grsight2.wav");

    actor.health = 130;
	float rand = random() * 6;
	if(rand < 1)
		actor.th_stand = gren_stand1;
	else if(rand < 2)
		actor.th_stand = gren_stand2;
	else if(rand < 3)
		actor.th_stand = gren_stand3;
	else if(rand < 4)
		actor.th_stand = gren_stand4;
	else if(rand < 5)
		actor.th_stand = gren_stand5;
	else
		actor.th_stand = gren_stand6;
	actor.th_walk = gren_walk1;
	actor.th_run = gren_run1;
	actor.th_melee = gren_fast;
	actor.th_pain = Gren_Pain;
	actor.th_die = gren_die;

	actor.sightsound = gren_sight;
	actor.deathmessage = grenling_deathmessage;

    return true;
}
#endif
