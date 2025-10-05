#include "biter.qh"

#ifdef SVQC
const int anim_biter_stand = 0; //'0 12 0'
const int anim_biter_walk = 13; //'13 20 0'
const int anim_biter_run = 21; //'21 26 0'
const int anim_biter_leap = 27; //'27 38 0'
const int anim_biter_pain = 39; //'39 44 0'
const int anim_biter_death = 45; //'45 53 0'
const int anim_biter_attacka = 54; //'54 68 0'


//============================================================================

void Biter_JumpTouch(entity this, entity toucher);

void biter_stand1(entity this);
void biter_stand13(entity this) { set_animofs(this, anim_biter_stand, 1, biter_stand1); ai_stand(this); }
void biter_stand12(entity this) { set_animofs(this, anim_biter_stand, 12, biter_stand13); ai_stand(this); }
void biter_stand11(entity this) { set_animofs(this, anim_biter_stand, 11, biter_stand12); ai_stand(this); }
void biter_stand10(entity this) { set_animofs(this, anim_biter_stand, 10, biter_stand11); ai_stand(this); }
void biter_stand9(entity this) { set_animofs(this, anim_biter_stand, 9, biter_stand10); ai_stand(this); }
void biter_stand8(entity this) { set_animofs(this, anim_biter_stand, 8, biter_stand9); ai_stand(this); }
void biter_stand7(entity this) { set_animofs(this, anim_biter_stand, 7, biter_stand8); ai_stand(this); }
void biter_stand6(entity this) { set_animofs(this, anim_biter_stand, 6, biter_stand7); ai_stand(this); }
void biter_stand5(entity this) { set_animofs(this, anim_biter_stand, 5, biter_stand6); ai_stand(this); }
void biter_stand4(entity this) { set_animofs(this, anim_biter_stand, 4, biter_stand5); ai_stand(this); }
void biter_stand3(entity this) { set_animofs(this, anim_biter_stand, 3, biter_stand4); ai_stand(this); }
void biter_stand2(entity this) { set_animofs(this, anim_biter_stand, 2, biter_stand3); ai_stand(this); }
void biter_stand1(entity this) { set_animofs(this, anim_biter_stand, 1, biter_stand2); ai_stand(this); }

void biter_walk1(entity this);
void biter_walk8(entity this) { set_animofs(this, anim_biter_walk, 8, biter_walk1); ai_walk(this, 10); }
void biter_walk7(entity this) { set_animofs(this, anim_biter_walk, 7, biter_walk8); ai_walk(this, 10); monster_footstep(this, false); }
void biter_walk6(entity this) { set_animofs(this, anim_biter_walk, 6, biter_walk7); ai_walk(this, 6); }
void biter_walk5(entity this) { set_animofs(this, anim_biter_walk, 5, biter_walk6); ai_walk(this, 4); monster_footstep(this, false); }
void biter_walk4(entity this) { set_animofs(this, anim_biter_walk, 4, biter_walk5); ai_walk(this, 7); }
void biter_walk3(entity this) { set_animofs(this, anim_biter_walk, 3, biter_walk4); ai_walk(this, 6); }
void biter_walk2(entity this) { set_animofs(this, anim_biter_walk, 2, biter_walk3); ai_walk(this, 6); monster_footstep(this, false); }
void biter_walk1(entity this)
{
	set_animofs(this, anim_biter_walk, 1, biter_walk2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "biter/idle.wav", 1, ATTN_IDLE);
	ai_walk(this, 8);
	monster_footstep(this, false);
}

void biter_run1(entity this);
void biter_run6(entity this) { set_animofs(this, anim_biter_run, 6, biter_run1); ai_run(this, 36); }
void biter_run5(entity this) { set_animofs(this, anim_biter_run, 5, biter_run6); ai_run(this, 15); monster_footstep(this, false); }
void biter_run4(entity this) { set_animofs(this, anim_biter_run, 4, biter_run5); ai_run(this, 20); }
void biter_run3(entity this) { set_animofs(this, anim_biter_run, 3, biter_run4); ai_run(this, 36); }
void biter_run2(entity this) { set_animofs(this, anim_biter_run, 2, biter_run3); ai_run(this, 15); monster_footstep(this, false); }
void biter_run1(entity this)
{
	set_animofs(this, anim_biter_run, 1, biter_run2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "biter/idle.wav", 1, ATTN_IDLE);
	ai_run(this, 20);
}

void biter_die1(entity this);
void biter_jump1(entity this);
void biter_jump12(entity this) { set_animofs(this, anim_biter_leap, 12, biter_run1); }
void biter_jump11(entity this) { set_animofs(this, anim_biter_leap, 11, biter_jump12); _sound(this, CH_VOICE, "biter/land.wav", 1, ATTN_NORM); }
void biter_jump10(entity this)
{
	set_animofs(this, anim_biter_leap, 10, biter_jump1);
	if(this.exptime != 0)
		return;
	// physics says we're on ground
	if(IS_ONGROUND(this))
	{
		settouch(this, func_null);
		setthink(this, biter_jump11);
		return;
	}
	// still jumping
	setthink(this, biter_jump10);
}
void biter_jump9(entity this) { set_animofs(this, anim_biter_leap, 9, biter_jump10); }
void biter_jump8(entity this) { set_animofs(this, anim_biter_leap, 8, biter_jump9); }
void biter_jump7(entity this) { set_animofs(this, anim_biter_leap, 7, biter_jump8); }
void biter_jump6(entity this) { set_animofs(this, anim_biter_leap, 6, biter_jump7); }
void biter_jump5(entity this) { set_animofs(this, anim_biter_leap, 5, biter_jump6); }
void biter_jump4(entity this)
{
	set_animofs(this, anim_biter_leap, 4, biter_jump5);
	if(this.health <= 0)
	{
		settouch(this, func_null);
		setthink(this, biter_die1);
		return;
	}
	ai_face(this);
	settouch(this, Biter_JumpTouch);
	this.origin_z += 1;
	fixedmakevectors(this.angles);
	this.velocity = v_forward * 600 + '0 0 250';
	UNSET_ONGROUND(this);
}
// if three seconds pass, assume biter is stuck and jump again
void biter_jump3(entity this) { set_animofs(this, anim_biter_leap, 3, biter_jump4); ai_face(this); }
void biter_jump2(entity this) { set_animofs(this, anim_biter_leap, 2, biter_jump3); ai_face(this); }
void biter_jump1(entity this) { set_animofs(this, anim_biter_leap, 1, biter_jump2); ai_face(this); }

void Biter_Melee(entity this, float side);
void biter_atta15(entity this) { set_animofs(this, anim_biter_attacka, 15, biter_run1); ai_charge(this, 4); }
void biter_atta14(entity this) { set_animofs(this, anim_biter_attacka, 14, biter_atta15); ai_charge(this, 4); }
void biter_atta13(entity this) { set_animofs(this, anim_biter_attacka, 13, biter_atta14); ai_charge(this, 8); }
void biter_atta12(entity this) { set_animofs(this, anim_biter_attacka, 12, biter_atta13); ai_charge(this, 5); }
void biter_atta11(entity this)
{
	set_animofs(this, anim_biter_attacka, 11, biter_atta12);
	Biter_Melee(this, -200);
}
void biter_atta10(entity this) { set_animofs(this, anim_biter_attacka, 10, biter_atta11); ai_charge(this, 2); monster_footstep(this, false); }
void biter_atta9(entity this) { set_animofs(this, anim_biter_attacka, 9, biter_atta10); ai_charge(this, 4); }
void biter_atta8(entity this) { set_animofs(this, anim_biter_attacka, 8, biter_atta9); ai_charge(this, 8); }
void biter_atta7(entity this) { set_animofs(this, anim_biter_attacka, 7, biter_atta8); ai_charge(this, 6); }
void biter_atta6(entity this) { set_animofs(this, anim_biter_attacka, 6, biter_atta7); ai_charge(this, 1); }
void biter_atta5(entity this)
{
	set_animofs(this, anim_biter_attacka, 5, biter_atta6);
	ai_charge(this, 2);
	Biter_Melee(this, 200);
}
void biter_atta4(entity this) { set_animofs(this, anim_biter_attacka, 4, biter_atta5); ai_charge(this, 1); }
void biter_atta3(entity this) { set_animofs(this, anim_biter_attacka, 3, biter_atta4); ai_charge(this, 0); }
void biter_atta2(entity this) { set_animofs(this, anim_biter_attacka, 2, biter_atta3); ai_charge(this, 0); monster_footstep(this, false); }
void biter_atta1(entity this) { set_animofs(this, anim_biter_attacka, 1, biter_atta2); ai_charge(this, 4); }

void biter_pain6(entity this) { set_animofs(this, anim_biter_pain, 6, biter_run1); }
void biter_pain5(entity this) { set_animofs(this, anim_biter_pain, 5, biter_pain6); }
void biter_pain4(entity this) { set_animofs(this, anim_biter_pain, 4, biter_pain5); }
void biter_pain3(entity this) { set_animofs(this, anim_biter_pain, 3, biter_pain4); }
void biter_pain2(entity this) { set_animofs(this, anim_biter_pain, 2, biter_pain3); }
void biter_pain1(entity this) { set_animofs(this, anim_biter_pain, 1, biter_pain2); }

void biter_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(gettouch(this) == Biter_JumpTouch)
		return;

	if(this.pain_finished > time)
		return;

	this.pain_finished = time + 1;
	if(random() < 0.5)
		_sound(this, CH_VOICE, "biter/pain1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "biter/pain2.wav", 1, ATTN_NORM);

	if(random()*200 > damage)
		return;		// didn't flinch
		
	biter_pain1(this);
}

void biter_die9(entity this) 
{
	set_animofs(this, anim_biter_death, 9, biter_die9);
	CorpseThink(this);
}
void biter_die8(entity this) { set_animofs(this, anim_biter_death, 8, biter_die9); }
void biter_die7(entity this) { set_animofs(this, anim_biter_death, 7, biter_die8); }
void biter_die6(entity this) { set_animofs(this, anim_biter_death, 6, biter_die7); }
void biter_die5(entity this) { set_animofs(this, anim_biter_death, 5, biter_die6); }
void biter_die4(entity this) { set_animofs(this, anim_biter_death, 4, biter_die5); }
void biter_die3(entity this) { set_animofs(this, anim_biter_death, 3, biter_die4); }
void biter_die2(entity this) { set_animofs(this, anim_biter_death, 2, biter_die3); }
void biter_die1(entity this)
{
	set_animofs(this, anim_biter_death, 1, biter_die2);
	if(random() < 0.5)
		_sound(this, CH_VOICE, "biter/death1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "biter/death2.wav", 1, ATTN_NORM);
	this.solid = SOLID_NOT;
}

void biter_die(entity this, entity inflictor, entity attacker, int deathtype)
{
// check for gib
	if(this.health < -30)
	{
		_sound(this, CH_VOICE, "biter/gib.wav", 1, ATTN_NORM);
		ThrowHead(this, inflictor, "progs/h_biter.mdl", this.health);
		ThrowGib(this, inflictor, "progs/h_biter.mdl", this.health);
		ThrowGib(this, inflictor, "progs/bone.mdl", this.health);
		ThrowGib(this, inflictor, "progs/bone.mdl", this.health);
		ThrowGib(this, inflictor, "progs/bone.mdl", this.health);
		ThrowGib(this, inflictor, "progs/bone.mdl", this.health);
		ThrowGib(this, inflictor, "progs/bone.mdl", this.health);
		return;
	}

// regular death
	biter_die1(this);
}


void Biter_MeleeAttack(entity this)
{
	biter_atta1(this);
}

/*
==============
CheckBiterMelee

Returns true if a melee attack would hit right now
==============
*/
bool CheckBiterMelee(entity this)
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
CheckBiterJump

==============
*/
bool CheckBiterJump(entity this)
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

bool BiterCheckAttack(entity this)
{
// if close enough for slashing, go for it
	if(CheckBiterMelee(this))
	{
		this.attack_state = AS_MELEE;
		return true;
	}

	if(CheckBiterJump(this))
	{
		this.attack_state = AS_MISSILE;
		_sound(this, CH_VOICE, "biter/jump.wav", 1, ATTN_NORM);
		return true;
	}

	return false;
}


//===========================================================================

void Biter_Melee(entity this, float side)
{
	ai_face(this);
	t_walkmove(this, this.ideal_yaw, 12);	// allow a little closing

	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;
		
	_sound(this, CH_WEAPON_SINGLE, "demon/dhit2.wav", 1, ATTN_NORM);
	float ldmg = 10 + 5*random();
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_BITER.m_id);	

	fixedmakevectors(this.angles);
	SpawnMeatSpray(this, this.origin + v_forward*16, side * v_right);
}


void Biter_JumpTouch(entity this, entity toucher)
{
	if(this.health <= 0 || (!this.takedamage))
		return;

	ai_jumpbreakable(this, toucher, 50);				// Damage any breakables

	if(toucher.takedamage && this.attack_finished < time)
	{
		if(vdist(this.velocity, >, 400))
		{
			float ldmg = 40 + 10*random();
			T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_BITER.m_id);
			this.attack_finished = time + 0.5;
		}
	}

	if(!t_checkbottom(this))
	{
		if(IS_ONGROUND(this) && this.exptime == 0)
		{	// jump randomly to not get hung up
			//dprint("popjump\n");
			settouch(this, func_null);
			setthink(this, biter_jump1);
			this.nextthink = time + 0.1;
		}
		return;	// not on ground yet
	}
}

/*QUAKED monster_biter(1 0 0)(-32 -32 -24)(32 32 64) Ambush
*/
spawnfunc(monster_biter) { monster_start(this, true, MON_BITER); }
#endif // SVQC

#ifdef SVQC
METHOD(Biter, mr_setup, bool(Biter this, entity actor))
{
	TC(Biter, this);

	precache_sound("biter/death1.wav");
	precache_sound("biter/death2.wav");
	precache_sound("biter/gib.wav");
	precache_sound("biter/idle.wav");
	precache_sound("biter/jump.wav");
	precache_sound("biter/land.wav");
	precache_sound("biter/pain1.wav");
	precache_sound("biter/pain2.wav");

	precache_sound("demon/dhit2.wav");

	precache_model("progs/bone.mdl");

	actor.health = 150;
	actor.th_stand = biter_stand1;
	actor.th_walk = biter_walk1;
	actor.th_run = biter_run1;
	actor.th_die = biter_die;
	actor.th_melee = Biter_MeleeAttack;		// one of two attacks
	actor.th_missile = biter_jump1;			// jump attack
	actor.th_pain = biter_pain;

	actor.checkattack = BiterCheckAttack;

	// Custom feet sounds
	actor.stepc1 = "biter/step1.wav";
	actor.stepc2 = "biter/step2.wav";
	actor.stepc3 = "biter/step3.wav";
	actor.stepc4 = "biter/step4.wav";
	actor.stepc5 = "biter/step5.wav";
	precache_sound(actor.stepc1);
	precache_sound(actor.stepc2);
	precache_sound(actor.stepc3);
	precache_sound(actor.stepc4);
	precache_sound(actor.stepc5);
	actor.steptype = FS_TYPECUSTOM;

	return true;
}
#endif
