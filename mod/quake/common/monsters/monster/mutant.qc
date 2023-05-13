#include "fiend.qh"

#ifdef SVQC
const int anim_mutant_stand = 0; //'0 12 0'
const int anim_mutant_walk = 13; //'13 20 0'
const int anim_mutant_run = 21; //'21 26 0'
const int anim_mutant_leap = 27; //'27 38 0'
const int anim_mutant_pain = 39; //'39 44 0'
const int anim_mutant_death = 45; //'45 53 0'
const int anim_mutant_attacka = 54; //'54 68 0'


//============================================================================

void Mutant_JumpTouch(entity this, entity toucher);

void mutant_stand1(entity this);
void mutant_stand13(entity this) { set_animofs(this, anim_mutant_stand, 1, mutant_stand1); ai_stand(this); }
void mutant_stand12(entity this) { set_animofs(this, anim_mutant_stand, 12, mutant_stand13); ai_stand(this); }
void mutant_stand11(entity this) { set_animofs(this, anim_mutant_stand, 11, mutant_stand12); ai_stand(this); }
void mutant_stand10(entity this) { set_animofs(this, anim_mutant_stand, 10, mutant_stand11); ai_stand(this); }
void mutant_stand9(entity this) { set_animofs(this, anim_mutant_stand, 9, mutant_stand10); ai_stand(this); }
void mutant_stand8(entity this) { set_animofs(this, anim_mutant_stand, 8, mutant_stand9); ai_stand(this); }
void mutant_stand7(entity this) { set_animofs(this, anim_mutant_stand, 7, mutant_stand8); ai_stand(this); }
void mutant_stand6(entity this) { set_animofs(this, anim_mutant_stand, 6, mutant_stand7); ai_stand(this); }
void mutant_stand5(entity this) { set_animofs(this, anim_mutant_stand, 5, mutant_stand6); ai_stand(this); }
void mutant_stand4(entity this) { set_animofs(this, anim_mutant_stand, 4, mutant_stand5); ai_stand(this); }
void mutant_stand3(entity this) { set_animofs(this, anim_mutant_stand, 3, mutant_stand4); ai_stand(this); }
void mutant_stand2(entity this) { set_animofs(this, anim_mutant_stand, 2, mutant_stand3); ai_stand(this); }
void mutant_stand1(entity this) { set_animofs(this, anim_mutant_stand, 1, mutant_stand2); ai_stand(this); }

void mutant_walk1(entity this);
void mutant_walk8(entity this) { set_animofs(this, anim_mutant_walk, 8, mutant_walk1); ai_walk(this, 10); }
void mutant_walk7(entity this) { set_animofs(this, anim_mutant_walk, 7, mutant_walk8); ai_walk(this, 10); }
void mutant_walk6(entity this) { set_animofs(this, anim_mutant_walk, 6, mutant_walk7); ai_walk(this, 6); }
void mutant_walk5(entity this) { set_animofs(this, anim_mutant_walk, 5, mutant_walk6); ai_walk(this, 4); }
void mutant_walk4(entity this) { set_animofs(this, anim_mutant_walk, 4, mutant_walk5); ai_walk(this, 7); }
void mutant_walk3(entity this) { set_animofs(this, anim_mutant_walk, 3, mutant_walk4); ai_walk(this, 6); }
void mutant_walk2(entity this) { set_animofs(this, anim_mutant_walk, 2, mutant_walk3); ai_walk(this, 6); }
void mutant_walk1(entity this)
{
	set_animofs(this, anim_mutant_walk, 1, mutant_walk2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "mutant/mutidle1.wav", 1, ATTN_IDLE);
	ai_walk(this, 8);
}

void mutant_run1(entity this);
void mutant_run6(entity this) { set_animofs(this, anim_mutant_run, 6, mutant_run1); ai_run(this, 36); }
void mutant_run5(entity this) { set_animofs(this, anim_mutant_run, 5, mutant_run6); ai_run(this, 15); _sound(this, CH_VOICE, "mutant/step3.wav", 1, ATTN_IDLE); }
void mutant_run4(entity this) { set_animofs(this, anim_mutant_run, 4, mutant_run5); ai_run(this, 20); }
void mutant_run3(entity this) { set_animofs(this, anim_mutant_run, 3, mutant_run4); ai_run(this, 36); }
void mutant_run2(entity this) { set_animofs(this, anim_mutant_run, 2, mutant_run3); ai_run(this, 15); _sound(this, CH_VOICE, "mutant/step1.wav", 1, ATTN_IDLE); }
void mutant_run1(entity this)
{
	set_animofs(this, anim_mutant_run, 1, mutant_run2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "mutant/mutidle1.wav", 1, ATTN_IDLE);
	ai_run(this, 20);
}

void mutant_die1(entity this);
void mutant_jump1(entity this);
void mutant_jump12(entity this) { set_animofs(this, anim_mutant_leap, 12, mutant_run1); }
void mutant_jump11(entity this) { set_animofs(this, anim_mutant_leap, 11, mutant_jump12); }
void mutant_jump10(entity this)
{
	set_animofs(this, anim_mutant_leap, 10, mutant_jump1);
	if(this.exptime != 0)
		return;
	// physics says we're on ground
	if(IS_ONGROUND(this))
	{
		settouch(this, func_null);
		setthink(this, mutant_jump11);
		return;
	}
	// still jumping
	setthink(this, mutant_jump10);
}
void mutant_jump9(entity this) { set_animofs(this, anim_mutant_leap, 9, mutant_jump10); }
void mutant_jump8(entity this) { set_animofs(this, anim_mutant_leap, 8, mutant_jump9); }
void mutant_jump7(entity this) { set_animofs(this, anim_mutant_leap, 7, mutant_jump8); }
void mutant_jump6(entity this) { set_animofs(this, anim_mutant_leap, 6, mutant_jump7); }
void mutant_jump5(entity this) { set_animofs(this, anim_mutant_leap, 5, mutant_jump6); }
void mutant_jump4(entity this)
{
	set_animofs(this, anim_mutant_leap, 4, mutant_jump5);
	if(this.health <= 0)
	{
		dprint("mutant_jump4: dead\n");
		settouch(this, func_null);
		setthink(this, mutant_die1);
		return;
	}
	ai_face(this);
	settouch(this, Mutant_JumpTouch);
	this.origin_z += 1;
	fixedmakevectors(this.angles);
	this.velocity = v_forward * 600 + '0 0 250';
	UNSET_ONGROUND(this);
}
// if three seconds pass, assume mutant is stuck and jump again
void mutant_jump3(entity this) { set_animofs(this, anim_mutant_leap, 3, mutant_jump4); ai_face(this); }
void mutant_jump2(entity this) { set_animofs(this, anim_mutant_leap, 2, mutant_jump3); ai_face(this); }
void mutant_jump1(entity this) { set_animofs(this, anim_mutant_leap, 1, mutant_jump2); ai_face(this); }

void Mutant_Melee(entity this, float side);
void mutant_atta15(entity this) { set_animofs(this, anim_mutant_attacka, 15, mutant_run1); ai_charge(this, 2); }
void mutant_atta14(entity this) { set_animofs(this, anim_mutant_attacka, 14, mutant_atta15); ai_charge(this, 4); }
void mutant_atta13(entity this) { set_animofs(this, anim_mutant_attacka, 13, mutant_atta14); ai_charge(this, 4); }
void mutant_atta12(entity this) { set_animofs(this, anim_mutant_attacka, 12, mutant_atta13); ai_charge(this, 4); Mutant_Melee(this, -200); }
void mutant_atta11(entity this) { set_animofs(this, anim_mutant_attacka, 11, mutant_atta12); ai_charge(this, 2); }
void mutant_atta10(entity this) { set_animofs(this, anim_mutant_attacka, 10, mutant_atta11); ai_charge(this, 5); Mutant_Melee(this, 200); }
void mutant_atta9(entity this) { set_animofs(this, anim_mutant_attacka, 9, mutant_atta10); ai_charge(this, 1); }
void mutant_atta8(entity this) { set_animofs(this, anim_mutant_attacka, 8, mutant_atta9); ai_charge(this, 2); }
void mutant_atta7(entity this) { set_animofs(this, anim_mutant_attacka, 7, mutant_atta8); ai_charge(this, 4); }
void mutant_atta6(entity this) { set_animofs(this, anim_mutant_attacka, 6, mutant_atta7); ai_charge(this, 4); }
void mutant_atta5(entity this) { set_animofs(this, anim_mutant_attacka, 5, mutant_atta6); ai_charge(this, 4); Mutant_Melee(this, -200); }
void mutant_atta4(entity this) { set_animofs(this, anim_mutant_attacka, 4, mutant_atta5); ai_charge(this, 2); }
void mutant_atta3(entity this) { set_animofs(this, anim_mutant_attacka, 3, mutant_atta4); ai_charge(this, 5); Mutant_Melee(this, 200); }
void mutant_atta2(entity this) { set_animofs(this, anim_mutant_attacka, 2, mutant_atta3); ai_charge(this, 1); }
void mutant_atta1(entity this) { set_animofs(this, anim_mutant_attacka, 1, mutant_atta2); ai_charge(this, 4); }

void mutant_pain6(entity this) { set_animofs(this, anim_mutant_pain, 6, mutant_run1); }
void mutant_pain5(entity this) { set_animofs(this, anim_mutant_pain, 5, mutant_pain6); }
void mutant_pain4(entity this) { set_animofs(this, anim_mutant_pain, 4, mutant_pain5); }
void mutant_pain3(entity this) { set_animofs(this, anim_mutant_pain, 3, mutant_pain4); }
void mutant_pain2(entity this) { set_animofs(this, anim_mutant_pain, 2, mutant_pain3); }
void mutant_pain1(entity this) { set_animofs(this, anim_mutant_pain, 1, mutant_pain2); }

void mutant_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.health < this.max_health * 0.6)
		this.skin = 1;

	if(gettouch(this) == Mutant_JumpTouch)
		return;

	if(this.pain_finished > time)
		return;

	this.pain_finished = time + 1;
	if(random() > 0.5)
    	_sound(this, CH_VOICE, "mutant/mutpain1.wav", 1, ATTN_NORM);
    else
    	_sound(this, CH_VOICE, "mutant/mutpain2.wav", 1, ATTN_NORM);

	if(random()*200 > damage)
		return;		// didn't flinch
		
	mutant_pain1(this);
}

void mutant_die9(entity this) { set_animofs(this, anim_mutant_death, 9, mutant_die9); CorpseThink(this); }
void mutant_die8(entity this) { set_animofs(this, anim_mutant_death, 8, mutant_die9); }
void mutant_die7(entity this) { set_animofs(this, anim_mutant_death, 7, mutant_die8); }
void mutant_die6(entity this) { set_animofs(this, anim_mutant_death, 6, mutant_die7); }
void mutant_die5(entity this) { set_animofs(this, anim_mutant_death, 5, mutant_die6); this.solid = SOLID_NOT; }
void mutant_die4(entity this) { set_animofs(this, anim_mutant_death, 4, mutant_die5); }
void mutant_die3(entity this) { set_animofs(this, anim_mutant_death, 3, mutant_die4); }
void mutant_die2(entity this) { set_animofs(this, anim_mutant_death, 2, mutant_die3); }
void mutant_die1(entity this)
{
	set_animofs(this, anim_mutant_death, 1, mutant_die2);
	_sound(this, CH_VOICE, "mutant/mutdeth1.wav", 1, ATTN_NORM);
}

void mutant_die(entity this, entity inflictor, entity attacker, int deathtype)
{
// check for gib
	if(this.health < -80)
	{
		this.skin = 0;
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, "progs/h_mutant.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib2.mdl", this.health);
		ThrowGib(this, "progs/gib3.mdl", this.health);
		ThrowGib(this, "progs/gib3.mdl", this.health);
		return;
	}

	this.skin = 1;

// regular death
	mutant_die1(this);
}


void Mutant_MeleeAttack(entity this)
{
	mutant_atta1(this);
}

/*
==============
CheckMutantMelee

Returns true if a melee attack would hit right now
==============
*/
bool CheckMutantMelee(entity this)
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
CheckMutantJump

==============
*/
bool CheckMutantJump(entity this)
{
	if(this.origin_z + this.mins_z > this.enemy.origin_z + this.enemy.mins_z
		+ 0.75 * this.enemy.size_z)
		return false;
		
	if(this.origin_z + this.maxs_z < this.enemy.origin_z + this.enemy.mins_z
		+ 0.25 * this.enemy.size_z)
		return false;
		
	vector dist = vec2(this.enemy.origin - this.origin);
	
	if(vdist(dist, <, 100))
		return false;
		
	if(vdist(dist, >, 200))
	{
		if(random() < 0.9)
			return false;
	}
		
	return true;
}

bool MutantCheckAttack(entity this)
{
// if close enough for slashing, go for it
	if(CheckMutantMelee(this))
	{
		this.attack_state = AS_MELEE;
		return true;
	}

	if(CheckMutantJump(this))
	{
		this.attack_state = AS_MISSILE;
        _sound(this, CH_VOICE, "mutant/mutsght1.wav", 1, ATTN_NORM);
		return true;
	}

	return false;
}


//===========================================================================

void Mutant_Melee(entity this, float side)
{
	ai_face(this);
	t_walkmove(this, this.ideal_yaw, 12);	// allow a little closing

	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;
		
    _sound(this, CH_WEAPON_SINGLE, "mutant/mutatck1.wav", 1, ATTN_NORM);
	float ldmg = 5 + 2 * random();
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_MUTANT.m_id);	

	fixedmakevectors(this.angles);
	SpawnMeatSpray(this, this.origin + v_forward*16, side * v_right);
}


void Mutant_JumpTouch(entity this, entity toucher)
{
	if(this.health <= 0 || (!this.takedamage))
		return;

	if(toucher.takedamage && (!MP_MG || this.attack_finished < time))
	{
		if(vdist(this.velocity, >, 400))
		{
			float ldmg = 25 + 10 * random();
			T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_MUTANT.m_id);
			if(MP_MG)
				this.attack_finished = time + 0.5;	
		}
	}

	if(!t_checkbottom(this))
	{
		if(IS_ONGROUND(this) && this.exptime == 0)
		{	// jump randomly to not get hung up
			//dprint("popjump\n");
			settouch(this, func_null);
			setthink(this, mutant_jump1);
			this.nextthink = time + 0.1;
		}
		return;	// not on ground yet
	}
}

/*QUAKED monster_mutant(1 0 0)(-32 -32 -24)(32 32 64) Ambush
*/
spawnfunc(monster_mutant) { monster_start(this, true, MON_MUTANT); }
#endif // SVQC

#ifdef SVQC
METHOD(Mutant, mr_setup, bool(Mutant this, entity actor))
{
    TC(Mutant, this);

	precache_sound("mutant/mutidle1.wav");
	precache_sound("mutant/mutatck1.wav");
	precache_sound("mutant/mutatck2.wav");
	precache_sound("mutant/mutatck3.wav");
	//precache_sound("mutant/mutjump.wav"); // jump
	precache_sound("mutant/step1.wav"); 
	precache_sound("mutant/step3.wav");
	precache_sound("mutant/mutdeth1.wav");
	precache_sound("mutant/mutpain1.wav");
	precache_sound("mutant/mutpain2.wav");
	precache_sound("mutant/mutsght1.wav");
	precache_sound("mutant/mutsrch1.wav");

	actor.health = 220;
	actor.th_stand = mutant_stand1;
	actor.th_walk = mutant_walk1;
	actor.th_run = mutant_run1;
	actor.th_die = mutant_die;
	actor.th_melee = Mutant_MeleeAttack;
	actor.th_missile = mutant_jump1;
	actor.th_pain = mutant_pain;

	actor.checkattack = MutantCheckAttack;
	actor.skin = 0;

	return true;
}
#endif
