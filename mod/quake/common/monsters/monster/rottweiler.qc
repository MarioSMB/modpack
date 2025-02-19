#include "rottweiler.qh"

#include "spider_droid.qh"

#ifdef SVQC
const int anim_dog_attack = 0; //'0 7 0'
const int anim_dog_death = 8; //'8 16 0'
const int anim_dog_deathb = 17; //'17 25 0'
const int anim_dog_pain = 26; //'26 31 0'
const int anim_dog_painb = 32; //'32 47 0'
const int anim_dog_run = 48; //'48 59 0'
const int anim_dog_leap = 60; //'60 48 0'
const int anim_dog_stand = 69; //'69 77 0'
const int anim_dog_walk = 78; //'78 85 0'


void dog_leap1(entity this);
void dog_run1(entity this);

/*
================
dog_bite

================
*/
void dog_bite(entity this)
{
	if(!this.enemy)
		return;

	ai_charge(this, 10);

	if(!CanDamage(this.enemy, this))
		return;

	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
		
	float ldmg =(random() + random() + random()) * 8;
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_ROTTWEILER.m_id);
}

void Dog_JumpTouch(entity this, entity toucher)
{
	if(this.health <= 0 || !this.takedamage)
		return;
		
	if(toucher.takedamage && this.attack_finished < time)
	{
		if(vdist(this.velocity, >, 300))
		{
			float ldmg = 10 + 10*random();
			T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_ROTTWEILER.m_id);
			this.attack_finished = time + 0.5;
		}
	}

	if(!t_checkbottom(this))
	{
		if(IS_ONGROUND(this) && this.exptime == 0)
		{	// jump randomly to not get hung up
			//dprint("popjump\n");
			settouch(this, func_null);
			setthink(this, dog_leap1);
			this.nextthink = time + 0.1;

//			this.velocity_x =(random() - 0.5) * 600;
//			this.velocity_y =(random() - 0.5) * 600;
//			this.velocity_z = 200;
//			this.flags = this.flags - FL_ONGROUND;
		}
		return;	// not on ground yet
	}

	settouch(this, func_null);
	if(this.exptime != 0)
		return;

	setthink(this, dog_run1);
	this.nextthink = time + 0.1;
}

void dog_stand1(entity this);
void dog_stand9(entity this) { set_animofs(this, anim_dog_stand, 9, dog_stand1); ai_stand(this); }
void dog_stand8(entity this) { set_animofs(this, anim_dog_stand, 8, dog_stand9); ai_stand(this); }
void dog_stand7(entity this) { set_animofs(this, anim_dog_stand, 7, dog_stand8); ai_stand(this); }
void dog_stand6(entity this) { set_animofs(this, anim_dog_stand, 6, dog_stand7); ai_stand(this); }
void dog_stand5(entity this) { set_animofs(this, anim_dog_stand, 5, dog_stand6); ai_stand(this); }
void dog_stand4(entity this) { set_animofs(this, anim_dog_stand, 4, dog_stand5); ai_stand(this); }
void dog_stand3(entity this) { set_animofs(this, anim_dog_stand, 3, dog_stand4); ai_stand(this); }
void dog_stand2(entity this) { set_animofs(this, anim_dog_stand, 2, dog_stand3); ai_stand(this); }
void dog_stand1(entity this) { set_animofs(this, anim_dog_stand, 1, dog_stand2); ai_stand(this); }

void dog_walk1(entity this);
void dog_walk8(entity this) { set_animofs(this, anim_dog_walk, 8, dog_walk1); ai_walk(this, 8); }
void dog_walk7(entity this) { set_animofs(this, anim_dog_walk, 7, dog_walk8); ai_walk(this, 8); }
void dog_walk6(entity this) { set_animofs(this, anim_dog_walk, 6, dog_walk7); ai_walk(this, 8); }
void dog_walk5(entity this) { set_animofs(this, anim_dog_walk, 5, dog_walk6); ai_walk(this, 8); }
void dog_walk4(entity this) { set_animofs(this, anim_dog_walk, 4, dog_walk5); ai_walk(this, 8); }
void dog_walk3(entity this) { set_animofs(this, anim_dog_walk, 3, dog_walk4); ai_walk(this, 8); }
void dog_walk2(entity this) { set_animofs(this, anim_dog_walk, 2, dog_walk3); ai_walk(this, 8); }
void dog_walk1(entity this)
{
	set_animofs(this, anim_dog_walk, 1, dog_walk2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "dog/idle.wav", 1, ATTN_IDLE);
	ai_walk(this, 8);
}

void dog_run1(entity this);
void dog_run12(entity this) { set_animofs(this, anim_dog_run, 12, dog_run1); ai_run(this, 32); }
void dog_run11(entity this) { set_animofs(this, anim_dog_run, 11, dog_run12); ai_run(this, 64); }
void dog_run10(entity this) { set_animofs(this, anim_dog_run, 10, dog_run11); ai_run(this, 20); }
void dog_run9(entity this) { set_animofs(this, anim_dog_run, 9, dog_run10); ai_run(this, 32); }
void dog_run8(entity this) { set_animofs(this, anim_dog_run, 8, dog_run9); ai_run(this, 32); }
void dog_run7(entity this) { set_animofs(this, anim_dog_run, 7, dog_run8); ai_run(this, 16); }
void dog_run6(entity this) { set_animofs(this, anim_dog_run, 6, dog_run7); ai_run(this, 32); }
void dog_run5(entity this) { set_animofs(this, anim_dog_run, 5, dog_run6); ai_run(this, 64); }
void dog_run4(entity this) { set_animofs(this, anim_dog_run, 4, dog_run5); ai_run(this, 20); }
void dog_run3(entity this) { set_animofs(this, anim_dog_run, 3, dog_run4); ai_run(this, 32); }
void dog_run2(entity this) { set_animofs(this, anim_dog_run, 2, dog_run3); ai_run(this, 32); }
void dog_run1(entity this)
{
	set_animofs(this, anim_dog_run, 1, dog_run2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "dog/idle.wav", 1, ATTN_IDLE);
	ai_run(this, 16);
}

void dog_atta8(entity this) { set_animofs(this, anim_dog_attack, 8, dog_run1); ai_charge(this, 10); }
void dog_atta7(entity this) { set_animofs(this, anim_dog_attack, 7, dog_atta8); ai_charge(this, 10); }
void dog_atta6(entity this) { set_animofs(this, anim_dog_attack, 6, dog_atta7); ai_charge(this, 10); }
void dog_atta5(entity this) { set_animofs(this, anim_dog_attack, 5, dog_atta6); ai_charge(this, 10); }
void dog_atta4(entity this)
{
	set_animofs(this, anim_dog_attack, 4, dog_atta5);
	dog_bite(this);
}
void dog_atta3(entity this) { set_animofs(this, anim_dog_attack, 3, dog_atta4); ai_charge(this, 10); }
void dog_atta2(entity this) { set_animofs(this, anim_dog_attack, 2, dog_atta3); ai_charge(this, 10); }
void dog_atta1(entity this) { set_animofs(this, anim_dog_attack, 1, dog_atta2); ai_charge(this, 10); }

void dog_die1(entity this);
void dog_leap9(entity this)
{
	set_animofs(this, anim_dog_leap, 9, dog_leap9);
	if(IS_ONGROUND(this))
	{
		setthink(this, dog_run1);
		settouch(this, func_null);
	}
}
void dog_leap8(entity this) { set_animofs(this, anim_dog_leap, 8, dog_leap9); }
void dog_leap7(entity this) { set_animofs(this, anim_dog_leap, 7, dog_leap8); }
void dog_leap6(entity this) { set_animofs(this, anim_dog_leap, 6, dog_leap7); }
void dog_leap5(entity this) { set_animofs(this, anim_dog_leap, 5, dog_leap6); }
void dog_leap4(entity this) { set_animofs(this, anim_dog_leap, 4, dog_leap5); }
void dog_leap3(entity this) { set_animofs(this, anim_dog_leap, 3, dog_leap4); }
void dog_leap2(entity this) { set_animofs(this, anim_dog_leap, 2, dog_leap3); ai_face(this); }
void dog_leap1(entity this)
{
	set_animofs(this, anim_dog_leap, 1, dog_leap2);
	if(this.health <= 0)
	{
		LOG_DEBUG("dog_leap2: dead");
		settouch(this, func_null);
		setthink(this, dog_die1);
		return;
	}
	ai_face(this);

	settouch(this, Dog_JumpTouch);
	fixedmakevectors(this.angles);
	setorigin(this, this.origin + '0 0 1');
	this.velocity = v_forward * 300 + '0 0 200';
	UNSET_ONGROUND(this);
}

void dog_pain6(entity this) { set_animofs(this, anim_dog_pain, 6, dog_run1); }
void dog_pain5(entity this) { set_animofs(this, anim_dog_pain, 5, dog_pain6); }
void dog_pain4(entity this) { set_animofs(this, anim_dog_pain, 4, dog_pain5); }
void dog_pain3(entity this) { set_animofs(this, anim_dog_pain, 3, dog_pain4); }
void dog_pain2(entity this) { set_animofs(this, anim_dog_pain, 2, dog_pain3); }
void dog_pain1(entity this) { set_animofs(this, anim_dog_pain, 1, dog_pain2); }

void dog_painb16(entity this) { set_animofs(this, anim_dog_painb, 16, dog_run1); }
void dog_painb15(entity this) { set_animofs(this, anim_dog_painb, 15, dog_painb16); }
void dog_painb14(entity this) { set_animofs(this, anim_dog_painb, 14, dog_painb15); }
void dog_painb13(entity this) { set_animofs(this, anim_dog_painb, 13, dog_painb14); }
void dog_painb12(entity this) { set_animofs(this, anim_dog_painb, 12, dog_painb13); }
void dog_painb11(entity this) { set_animofs(this, anim_dog_painb, 11, dog_painb12); }
void dog_painb10(entity this) { set_animofs(this, anim_dog_painb, 10, dog_painb11); ai_pain(this, 10); }
void dog_painb9(entity this) { set_animofs(this, anim_dog_painb, 9, dog_painb10); }
void dog_painb8(entity this) { set_animofs(this, anim_dog_painb, 8, dog_painb9); ai_pain(this, 4); }
void dog_painb7(entity this) { set_animofs(this, anim_dog_painb, 7, dog_painb8); }
void dog_painb6(entity this) { set_animofs(this, anim_dog_painb, 6, dog_painb7); ai_pain(this, 2); }
void dog_painb5(entity this) { set_animofs(this, anim_dog_painb, 5, dog_painb6); ai_pain(this, 12); }
void dog_painb4(entity this) { set_animofs(this, anim_dog_painb, 4, dog_painb5); ai_pain(this, 12); }
void dog_painb3(entity this) { set_animofs(this, anim_dog_painb, 3, dog_painb4); ai_pain(this, 4); }
void dog_painb2(entity this) { set_animofs(this, anim_dog_painb, 2, dog_painb3); }
void dog_painb1(entity this) { set_animofs(this, anim_dog_painb, 1, dog_painb2); }

void dog_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	_sound(this, CH_VOICE, "dog/dpain1.wav", 1, ATTN_NORM);

	if(attacker || random() > 0.5)
	{
		dog_pain1(this);
		this.pain_finished = time + 1;
	}
	else
	{
		dog_painb1(this);
		this.pain_finished = time + 1;
	}
}

void dog_die9(entity this)
{
	set_animofs(this, anim_dog_death, 9, dog_die9);
	CorpseThink(this);
}
void dog_die8(entity this) { set_animofs(this, anim_dog_death, 8, dog_die9); }
void dog_die7(entity this) { set_animofs(this, anim_dog_death, 7, dog_die8); }
void dog_die6(entity this) { set_animofs(this, anim_dog_death, 6, dog_die7); }
void dog_die5(entity this) { set_animofs(this, anim_dog_death, 5, dog_die6); }
void dog_die4(entity this) { set_animofs(this, anim_dog_death, 4, dog_die5); }
void dog_die3(entity this) { set_animofs(this, anim_dog_death, 3, dog_die4); }
void dog_die2(entity this) { set_animofs(this, anim_dog_death, 2, dog_die3); }
void dog_die1(entity this) { set_animofs(this, anim_dog_death, 1, dog_die2); }

void dog_dieb9(entity this)
{
	set_animofs(this, anim_dog_deathb, 9, dog_dieb9);
	CorpseThink(this);
}
void dog_dieb8(entity this) { set_animofs(this, anim_dog_deathb, 8, dog_dieb9); }
void dog_dieb7(entity this) { set_animofs(this, anim_dog_deathb, 7, dog_dieb8); }
void dog_dieb6(entity this) { set_animofs(this, anim_dog_deathb, 6, dog_dieb7); }
void dog_dieb5(entity this) { set_animofs(this, anim_dog_deathb, 5, dog_dieb6); }
void dog_dieb4(entity this) { set_animofs(this, anim_dog_deathb, 4, dog_dieb5); }
void dog_dieb3(entity this) { set_animofs(this, anim_dog_deathb, 3, dog_dieb4); }
void dog_dieb2(entity this) { set_animofs(this, anim_dog_deathb, 2, dog_dieb3); }
void dog_dieb1(entity this) { set_animofs(this, anim_dog_deathb, 1, dog_dieb2); }

void dog_die(entity this, entity inflictor, entity attacker, int deathtype)
{
// check for gib
	if(this.health < -35)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowGib(this, inflictor, "progs/grenbone.mdl", this.health);
		ThrowGib(this, inflictor, "progs/grenbone.mdl", this.health);
		ThrowGib(this, inflictor, "progs/grenbone.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowHead(this, inflictor, "progs/h_dog.mdl", this.health);
		return;
	}

// regular death
	_sound(this, CH_VOICE, "dog/ddeath.wav", 1, ATTN_NORM);
	this.solid = SOLID_NOT;

	if(random() > 0.5)
		dog_die1(this);
	else
		dog_dieb1(this);
}

//============================================================================

/*
==============
CheckDogMelee

Returns true if a melee attack would hit right now
==============
*/
bool CheckDogMelee(entity this)
{
	if(this.enemy_range == RANGE_MELEE)
	{	// FIXME: check canreach
		this.attack_state = AS_MELEE;
		return true;
	}
	return false;
}

/*
==============
CheckDogJump

==============
*/
bool CheckDogJump(entity this)
{
	if(this.origin_z + this.mins_z > this.enemy.origin_z + this.enemy.mins_z
	+ 0.75 * this.enemy.size_z)
		return false;
		
	if(this.origin_z + this.maxs_z < this.enemy.origin_z + this.enemy.mins_z
	+ 0.25 * this.enemy.size_z)
		return false;
		
	vector dist = vec2(this.enemy.origin - this.origin);
	
	if(vdist(dist, <, 80))
		return false;
		
	if(vdist(dist, >, 150))
		return false;
		
	return true;
}

bool DogCheckAttack(entity this)
{
// if close enough for slashing, go for it
	if(CheckDogMelee(this))
	{
		this.attack_state = AS_MELEE;
		return true;
	}
	
	if(CheckDogJump(this))
	{
		this.attack_state = AS_MISSILE;
		return true;
	}
	
	return false;
}

/*QUAKED monster_dog(1 0 0)(-32 -32 -24)(32 32 40) Ambush
*/
spawnfunc(monster_dog)
{
	if(substring(world.model, 0, 9) == "maps/mcj_")
	{
		monster_start(this, true, MON_GOAT);
		return;
	}

	if(coop == 2 && orig_random(this) < 0.5)
	{
		monster_start(this, true, MON_SPIDER_DROID);
		return;
	}
	monster_start(this, true, MON_ROTTWEILER);
}
#endif // SVQC

#ifdef SVQC
METHOD(Rottweiler, mr_setup, bool(Rottweiler this, entity actor))
{
    TC(Rottweiler, this);

	precache_model("progs/grenbone.mdl");
	precache_sound("dog/dattack1.wav");
	precache_sound("dog/ddeath.wav");
	precache_sound("dog/dpain1.wav");
	precache_sound("dog/idle.wav");

    actor.health = 25;
    actor.th_stand = dog_stand1;
	actor.th_walk = dog_walk1;
	actor.th_run = dog_run1;
	actor.th_pain = dog_pain;
	actor.th_die = dog_die;
	actor.th_melee = dog_atta1;
	actor.th_missile = dog_leap1;

	actor.checkattack = DogCheckAttack;

    return true;
}
#endif
