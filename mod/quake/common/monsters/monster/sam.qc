#include "sam.qh"

#ifdef SVQC
const int anim_sam_stand = 0; //'0 12 0'
const int anim_sam_walk = 13; //'13 20 0'
const int anim_sam_run = 21; //'21 26 0'
const int anim_sam_leap = 27; //'27 38 0'
const int anim_sam_pain = 39; //'39 44 0'
const int anim_sam_death = 45; //'45 53 0'
const int anim_sam_attacka = 54; //'54 68 0'


//============================================================================

void Sam_JumpTouch(entity this, entity toucher);

void sam1_stand1(entity this);
void sam1_stand13(entity this) { set_animofs(this, anim_sam_stand, 1, sam1_stand1); ai_stand(this); }
void sam1_stand12(entity this) { set_animofs(this, anim_sam_stand, 12, sam1_stand13); ai_stand(this); }
void sam1_stand11(entity this) { set_animofs(this, anim_sam_stand, 11, sam1_stand12); ai_stand(this); }
void sam1_stand10(entity this) { set_animofs(this, anim_sam_stand, 10, sam1_stand11); ai_stand(this); }
void sam1_stand9(entity this) { set_animofs(this, anim_sam_stand, 9, sam1_stand10); ai_stand(this); }
void sam1_stand8(entity this) { set_animofs(this, anim_sam_stand, 8, sam1_stand9); ai_stand(this); }
void sam1_stand7(entity this) { set_animofs(this, anim_sam_stand, 7, sam1_stand8); ai_stand(this); }
void sam1_stand6(entity this) { set_animofs(this, anim_sam_stand, 6, sam1_stand7); ai_stand(this); }
void sam1_stand5(entity this) { set_animofs(this, anim_sam_stand, 5, sam1_stand6); ai_stand(this); }
void sam1_stand4(entity this) { set_animofs(this, anim_sam_stand, 4, sam1_stand5); ai_stand(this); }
void sam1_stand3(entity this) { set_animofs(this, anim_sam_stand, 3, sam1_stand4); ai_stand(this); }
void sam1_stand2(entity this) { set_animofs(this, anim_sam_stand, 2, sam1_stand3); ai_stand(this); }
void sam1_stand1(entity this) { set_animofs(this, anim_sam_stand, 1, sam1_stand2); ai_stand(this); }

void sam1_walk1(entity this);
void sam1_walk8(entity this) { set_animofs(this, anim_sam_walk, 8, sam1_walk1); ai_walk(this, 10); }
void sam1_walk7(entity this) { set_animofs(this, anim_sam_walk, 7, sam1_walk8); ai_walk(this, 10); }
void sam1_walk6(entity this) { set_animofs(this, anim_sam_walk, 6, sam1_walk7); ai_walk(this, 6); }
void sam1_walk5(entity this) { set_animofs(this, anim_sam_walk, 5, sam1_walk6); ai_walk(this, 4); monster_footstep(this, false); }
void sam1_walk4(entity this) { set_animofs(this, anim_sam_walk, 4, sam1_walk5); ai_walk(this, 7); }
void sam1_walk3(entity this) { set_animofs(this, anim_sam_walk, 3, sam1_walk4); ai_walk(this, 6); }
void sam1_walk2(entity this) { set_animofs(this, anim_sam_walk, 2, sam1_walk3); ai_walk(this, 6); }
void sam1_walk1(entity this)
{
	set_animofs(this, anim_sam_walk, 1, sam1_walk2);
	if(random() < 0.2)
	{
		if(random() > 0.5)
			_sound(this, CH_VOICE, "sam/cybhoof.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "sam/cybmet.wav", 1, ATTN_IDLE);
	}
	ai_walk(this, 8);
	monster_footstep(this, false);
}

void sam1_run1(entity this);
void sam1_run6(entity this) { set_animofs(this, anim_sam_run, 6, sam1_run1); ai_run(this, 36); }
void sam1_run5(entity this) { set_animofs(this, anim_sam_run, 5, sam1_run6); ai_run(this, 15); monster_footstep(this, false); }
void sam1_run4(entity this) { set_animofs(this, anim_sam_run, 4, sam1_run5); ai_run(this, 20); }
void sam1_run3(entity this) { set_animofs(this, anim_sam_run, 3, sam1_run4); ai_run(this, 36); }
void sam1_run2(entity this) { set_animofs(this, anim_sam_run, 2, sam1_run3); ai_run(this, 15); monster_footstep(this, false); }
void sam1_run1(entity this)
{
	set_animofs(this, anim_sam_run, 1, sam1_run2);
	if(random() < 0.2)
	{
		if(random() > 0.5)
			_sound(this, CH_VOICE, "sam/cybhoof.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "sam/cybmet.wav", 1, ATTN_IDLE);
	}
	ai_run(this, 20);
}

void sam1_die1(entity this);
void sam1_jump1(entity this);
void sam1_jump12(entity this) { set_animofs(this, anim_sam_leap, 12, sam1_run1); }
void sam1_jump11(entity this) { set_animofs(this, anim_sam_leap, 11, sam1_jump12); monster_footstep(this, false); }
void sam1_jump10(entity this)
{
	set_animofs(this, anim_sam_leap, 10, sam1_jump1);
	if(this.exptime != 0)
		return;
	// physics says we're on ground
	if(IS_ONGROUND(this))
	{
		settouch(this, func_null);
		setthink(this, sam1_jump11);
		return;
	}
	// still jumping
	setthink(this, sam1_jump10);
}
void sam1_jump9(entity this) { set_animofs(this, anim_sam_leap, 9, sam1_jump10); }
void sam1_jump8(entity this) { set_animofs(this, anim_sam_leap, 8, sam1_jump9); }
void sam1_jump7(entity this) { set_animofs(this, anim_sam_leap, 7, sam1_jump8); }
void sam1_jump6(entity this) { set_animofs(this, anim_sam_leap, 6, sam1_jump7); }
void sam1_jump5(entity this) { set_animofs(this, anim_sam_leap, 5, sam1_jump6); }
void sam1_jump4(entity this)
{
	set_animofs(this, anim_sam_leap, 4, sam1_jump5);
	if(this.health <= 0)
	{
		//dprint("sam1_jump4: dead\n");
		settouch(this, func_null);
		setthink(this, sam1_die1);
		return;
	}
	ai_face(this);
	settouch(this, Sam_JumpTouch);
	this.origin_z += 1;
	fixedmakevectors(this.angles);
	this.velocity = v_forward * 600 + '0 0 250';
	UNSET_ONGROUND(this);
}
// if three seconds pass, assume sam is stuck and jump again
void sam1_jump3(entity this) { set_animofs(this, anim_sam_leap, 3, sam1_jump4); ai_face(this); }
void sam1_jump2(entity this) { set_animofs(this, anim_sam_leap, 2, sam1_jump3); ai_face(this); }
void sam1_jump1(entity this) { set_animofs(this, anim_sam_leap, 1, sam1_jump2); ai_face(this); }

void Sam_Melee(entity this, float side);
void sam1_atta15(entity this) { set_animofs(this, anim_sam_attacka, 15, sam1_run1); ai_charge(this, 4); }
void sam1_atta14(entity this) { set_animofs(this, anim_sam_attacka, 14, sam1_atta15); ai_charge(this, 4); }
void sam1_atta13(entity this) { set_animofs(this, anim_sam_attacka, 13, sam1_atta14); ai_charge(this, 8); }
void sam1_atta12(entity this) { set_animofs(this, anim_sam_attacka, 12, sam1_atta13); ai_charge(this, 5); }
void sam1_atta11(entity this)
{
	set_animofs(this, anim_sam_attacka, 11, sam1_atta12);
	Sam_Melee(this, -200);
}
void sam1_atta10(entity this) { set_animofs(this, anim_sam_attacka, 10, sam1_atta11); ai_charge(this, 2); monster_footstep(this, false); }
void sam1_atta9(entity this) { set_animofs(this, anim_sam_attacka, 9, sam1_atta10); ai_charge(this, 4); }
void sam1_atta8(entity this) { set_animofs(this, anim_sam_attacka, 8, sam1_atta9); ai_charge(this, 8); }
void sam1_atta7(entity this) { set_animofs(this, anim_sam_attacka, 7, sam1_atta8); ai_charge(this, 6); }
void sam1_atta6(entity this) { set_animofs(this, anim_sam_attacka, 6, sam1_atta7); ai_charge(this, 1); }
void sam1_atta5(entity this)
{
	set_animofs(this, anim_sam_attacka, 5, sam1_atta6);
	ai_charge(this, 2);
	Sam_Melee(this, 200);
}
void sam1_atta4(entity this) { set_animofs(this, anim_sam_attacka, 4, sam1_atta5); ai_charge(this, 1); }
void sam1_atta3(entity this) { set_animofs(this, anim_sam_attacka, 3, sam1_atta4); ai_charge(this, 0); }
void sam1_atta2(entity this) { set_animofs(this, anim_sam_attacka, 2, sam1_atta3); ai_charge(this, 0); monster_footstep(this, false); }
void sam1_atta1(entity this) { set_animofs(this, anim_sam_attacka, 1, sam1_atta2); ai_charge(this, 4); }

void sam1_pain6(entity this) { set_animofs(this, anim_sam_pain, 6, sam1_run1); }
void sam1_pain5(entity this) { set_animofs(this, anim_sam_pain, 5, sam1_pain6); }
void sam1_pain4(entity this) { set_animofs(this, anim_sam_pain, 4, sam1_pain5); }
void sam1_pain3(entity this) { set_animofs(this, anim_sam_pain, 3, sam1_pain4); }
void sam1_pain2(entity this) { set_animofs(this, anim_sam_pain, 2, sam1_pain3); }
void sam1_pain1(entity this) { set_animofs(this, anim_sam_pain, 1, sam1_pain2); }

void sam1_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	if(gettouch(this) == Sam_JumpTouch)
		return;

	this.pain_finished = time + 1;
	_sound(this, CH_VOICE, "sam/cybpain.wav", 1, ATTN_NORM);

	if(random()*200 > damage)
		return;		// didn't flinch
		
	sam1_pain1(this);
}

void sam1_die9(entity this) 
{
	set_animofs(this, anim_sam_death, 9, sam1_die9);
	CorpseThink(this);
}
void sam1_die8(entity this) { set_animofs(this, anim_sam_death, 8, sam1_die9); }
void sam1_die7(entity this) { set_animofs(this, anim_sam_death, 7, sam1_die8); }
void sam1_die6(entity this) { set_animofs(this, anim_sam_death, 6, sam1_die7); }
void sam1_die5(entity this) { set_animofs(this, anim_sam_death, 5, sam1_die6); }
void sam1_die4(entity this) { set_animofs(this, anim_sam_death, 4, sam1_die5); }
void sam1_die3(entity this) { set_animofs(this, anim_sam_death, 3, sam1_die4); }
void sam1_die2(entity this) { set_animofs(this, anim_sam_death, 2, sam1_die3); }
void sam1_die1(entity this)
{
	set_animofs(this, anim_sam_death, 1, sam1_die2);
	if(random() > 0.5)
		_sound(this, CH_VOICE, "sam/servo.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "sam/cybdie.wav", 1, ATTN_NORM);
	this.solid = SOLID_NOT;
}

void sam_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
			ThrowGib(this, inflictor, "progs/h_sam.mdl", this.health);
			ThrowGib(this, inflictor, "progs/gib1_sam.mdl", this.health);
			ThrowGib(this, inflictor, "progs/gib2_sam.mdl", this.health);
			ThrowGib(this, inflictor, "progs/gib3_sam.mdl", this.health);
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

// regular death
	sam1_die1(this);
}


void Sam_MeleeAttack(entity this)
{
	sam1_atta1(this);
}

/*
==============
CheckSamMelee

Returns true if a melee attack would hit right now
==============
*/
bool CheckSamMelee(entity this)
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
CheckSamJump

==============
*/
bool CheckSamJump(entity this)
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

bool SamCheckAttack(entity this)
{
// if close enough for slashing, go for it
	if(CheckSamMelee(this))
	{
		this.attack_state = AS_MELEE;
		return true;
	}

	if(CheckSamJump(this))
	{
		this.attack_state = AS_MISSILE;
		_sound(this, CH_VOICE, "sam/cybfire.wav", 1, ATTN_NORM);
		return true;
	}

	return false;
}


//===========================================================================

void Sam_Melee(entity this, float side)
{
	ai_face(this);
	t_walkmove(this, this.ideal_yaw, 12);	// allow a little closing

	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;

	_sound(this, CH_WEAPON_SINGLE, "sam/boom.wav", 1, ATTN_NORM);
	float ldmg = 10 + 5*random();
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_SAM.m_id);	

	fixedmakevectors(this.angles);
	SpawnMeatSpray(this, this.origin + v_forward*16, side * v_right);
}


void Sam_JumpTouch(entity this, entity toucher)
{
	if(this.health <= 0 || (!this.takedamage))
		return;

	ai_jumpbreakable(this, toucher, 50);				// Damage any breakables

	if(toucher.takedamage && this.attack_finished < time)
	{
		if(vdist(this.velocity, >, 400))
		{
			float ldmg = 40 + 10*random();
			T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_SAM.m_id);
			this.attack_finished = time + 0.5;
		}
	}

	if(!t_checkbottom(this))
	{
		if(IS_ONGROUND(this) && this.exptime == 0)
		{	// jump randomly to not get hung up
			//dprint("popjump\n");
			settouch(this, func_null);
			setthink(this, sam1_jump1);
			this.nextthink = time + 0.1;
		}
		return;	// not on ground yet
	}
}

/*QUAKED monster_sam(1 0 0)(-32 -32 -24)(32 32 64) Ambush
*/
spawnfunc(monster_sam) { monster_start(this, true, MON_SAM); }
#endif // SVQC

#ifdef SVQC
METHOD(Sam, mr_setup, bool(Sam this, entity actor))
{
	TC(Sam, this);

	precache_model("progs/h_sam.mdl");
	precache_model("progs/gib1_sam.mdl");
	precache_model("progs/gib2_sam.mdl");
	precache_model("progs/gib3_sam.mdl");
	precache_sound("sam/servo.wav");
	precache_sound("sam/cybdie.wav");
	precache_sound("sam/boom.wav");
	precache_sound("sam/cybfire.wav");
	precache_sound("sam/cybpain.wav");
	precache_sound("sam/cybhoof.wav");
	precache_sound("sam/cybmet.wav");
	precache_sound("sam/cybsee.wav");
	precache_sound("sam/sam.wav");

	actor.health = 350;
	actor.gibhealth = -80;
	actor.th_stand = sam1_stand1;
	actor.th_walk = sam1_walk1;
	actor.th_run = sam1_run1;
	actor.th_die = sam_die;
	actor.th_melee = Sam_MeleeAttack;		// one of two attacks
	actor.th_missile = sam1_jump1;			// jump attack
	actor.th_pain = sam1_pain;

	actor.checkattack = SamCheckAttack;

	actor.steptype = FS_TYPESLOW;

	return true;
}
METHOD(Sam, mr_sight, bool(Sam this, entity actor))
{
	TC(Sam, this);

	if(random() <= 0.2)
		_sound(actor, CH_VOICE, "sam/sam.wav", 1, ATTN_NORM);
	else
		_sound(actor, CH_VOICE, "sam/cybsee.wav", 1, ATTN_NORM);

	return true;
}
#endif
