#include "bambler.qh"

#ifdef SVQC
const int anim_bam_stand = 0; //'0 16 0'
const int anim_bam_walk = 17; //'17 28 0'
const int anim_bam_run = 29; //'29 34 0'
const int anim_bam_smash = 35; //'35 46 0'
const int anim_bam_swingr = 47; //'47 55 0'
const int anim_bam_swingl = 56; //'47 64 0'
const int anim_bam_magic = 65; //'65 76 0'
const int anim_bam_pain = 77; //'77 82 0'
const int anim_bam_death = 83; //'83 93 0'

void bam_stand1(entity this);
void bam_stand17(entity this) { set_animofs(this, anim_bam_stand, 17, bam_stand1); ai_stand(this); }
void bam_stand16(entity this) { set_animofs(this, anim_bam_stand, 16, bam_stand17); ai_stand(this); }
void bam_stand15(entity this) { set_animofs(this, anim_bam_stand, 15, bam_stand16); ai_stand(this); }
void bam_stand14(entity this) { set_animofs(this, anim_bam_stand, 14, bam_stand15); ai_stand(this); }
void bam_stand13(entity this) { set_animofs(this, anim_bam_stand, 13, bam_stand14); ai_stand(this); }
void bam_stand12(entity this) { set_animofs(this, anim_bam_stand, 12, bam_stand13); ai_stand(this); }
void bam_stand11(entity this) { set_animofs(this, anim_bam_stand, 11, bam_stand12); ai_stand(this); }
void bam_stand10(entity this) { set_animofs(this, anim_bam_stand, 10, bam_stand11); ai_stand(this); }
void bam_stand9(entity this) { set_animofs(this, anim_bam_stand, 9, bam_stand10); ai_stand(this); }
void bam_stand8(entity this) { set_animofs(this, anim_bam_stand, 8, bam_stand9); ai_stand(this); }
void bam_stand7(entity this) { set_animofs(this, anim_bam_stand, 7, bam_stand8); ai_stand(this); }
void bam_stand6(entity this) { set_animofs(this, anim_bam_stand, 6, bam_stand7); ai_stand(this); }
void bam_stand5(entity this) { set_animofs(this, anim_bam_stand, 5, bam_stand6); ai_stand(this); }
void bam_stand4(entity this) { set_animofs(this, anim_bam_stand, 4, bam_stand5); ai_stand(this); }
void bam_stand3(entity this) { set_animofs(this, anim_bam_stand, 3, bam_stand4); ai_stand(this); }
void bam_stand2(entity this) { set_animofs(this, anim_bam_stand, 2, bam_stand3); ai_stand(this); }
void bam_stand1(entity this) { set_animofs(this, anim_bam_stand, 1, bam_stand2); ai_stand(this); }

void bam_walk1(entity this);
void bam_walk12(entity this)
{
	set_animofs(this, anim_bam_walk, 12, bam_walk1);
	ai_walk(this, 7);
	if(random() > 0.8)
		_sound(this, CH_VOICE, "bambler/sidle.wav", 1, ATTN_IDLE);
}
void bam_walk11(entity this) { set_animofs(this, anim_bam_walk, 11, bam_walk12); ai_walk(this, 7); }
void bam_walk10(entity this) { set_animofs(this, anim_bam_walk, 10, bam_walk11); ai_walk(this, 9); }
void bam_walk9(entity this) { set_animofs(this, anim_bam_walk, 9, bam_walk10); ai_walk(this, 13); }
void bam_walk8(entity this) { set_animofs(this, anim_bam_walk, 8, bam_walk9); ai_walk(this, 3); }
void bam_walk7(entity this) { set_animofs(this, anim_bam_walk, 7, bam_walk8); ai_walk(this, 8); }
void bam_walk6(entity this) { set_animofs(this, anim_bam_walk, 6, bam_walk7); ai_walk(this, 12); }
void bam_walk5(entity this) { set_animofs(this, anim_bam_walk, 5, bam_walk6); ai_walk(this, 6); }
void bam_walk4(entity this) { set_animofs(this, anim_bam_walk, 4, bam_walk5); ai_walk(this, 5); }
void bam_walk3(entity this) { set_animofs(this, anim_bam_walk, 3, bam_walk4); ai_walk(this, 9); }
void bam_walk2(entity this) { set_animofs(this, anim_bam_walk, 2, bam_walk3); ai_walk(this, 9); }
void bam_walk1(entity this) { set_animofs(this, anim_bam_walk, 1, bam_walk2); ai_walk(this, 10); }

void bam_run1(entity this);
void bam_run6(entity this)
{
	set_animofs(this, anim_bam_run, 6, bam_run1);
	ai_run(this, 20);
	if(random() > 0.8)
		_sound(this, CH_VOICE, "bambler/sidle.wav", 1, ATTN_IDLE);
}
void bam_run5(entity this) { set_animofs(this, anim_bam_run, 5, bam_run6); ai_run(this, 24); }
void bam_run4(entity this) { set_animofs(this, anim_bam_run, 4, bam_run5); ai_run(this, 20); }
void bam_run3(entity this) { set_animofs(this, anim_bam_run, 3, bam_run4); ai_run(this, 20); }
void bam_run2(entity this) { set_animofs(this, anim_bam_run, 2, bam_run3); ai_run(this, 24); }
void bam_run1(entity this) { set_animofs(this, anim_bam_run, 1, bam_run2); ai_run(this, 20); }

void bam_smash12(entity this) { set_animofs(this, anim_bam_smash, 12, bam_run1); ai_charge(this, 4); }
void bam_smash11(entity this) { set_animofs(this, anim_bam_smash, 11, bam_smash12); ai_charge(this, 5); }
void bam_smash10(entity this)
{
	set_animofs(this, anim_bam_smash, 10, bam_smash11);
	if(!this.enemy)
		return;
	ai_charge(this, 0);

	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;
		
	float ldmg = (random() + random() + random()) * 40;
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_BAMBLER.m_id);
	_sound(this, CH_VOICE, "bambler/smack.wav", 1, ATTN_NORM);

	SpawnMeatSpray(this, this.origin + v_forward*16, crandom() * 100 * v_right);
	SpawnMeatSpray(this, this.origin + v_forward*16, crandom() * 100 * v_right);
}
void bam_smash9(entity this) { set_animofs(this, anim_bam_smash, 9, bam_smash10); ai_charge(this, 0); }
void bam_smash8(entity this) { set_animofs(this, anim_bam_smash, 8, bam_smash9); ai_charge(this, 0); }
void bam_smash7(entity this) { set_animofs(this, anim_bam_smash, 7, bam_smash8); ai_charge(this, 0); }
void bam_smash6(entity this) { set_animofs(this, anim_bam_smash, 6, bam_smash7); ai_charge(this, 1); }
void bam_smash5(entity this) { set_animofs(this, anim_bam_smash, 5, bam_smash6); ai_charge(this, 4); }
void bam_smash4(entity this) { set_animofs(this, anim_bam_smash, 4, bam_smash5); ai_charge(this, 5); }
void bam_smash3(entity this) { set_animofs(this, anim_bam_smash, 3, bam_smash4); ai_charge(this, 6); }
void bam_smash2(entity this) { set_animofs(this, anim_bam_smash, 2, bam_smash3); ai_charge(this, 6); }
void bam_smash1(entity this)
{
	set_animofs(this, anim_bam_smash, 1, bam_smash2);
	_sound(this, CH_VOICE, "bambler/melee1.wav", 1, ATTN_NORM);
	ai_charge(this, 2);
}

void bam_swingr1(entity this);

void bamClaw(entity this, float side)
{
	if(!this.enemy)
		return;
	ai_charge(this, 10);

	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
		
	float ldmg =(random() + random() + random()) * 20;
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_BAMBLER.m_id);
	_sound(this, CH_VOICE, "bambler/smack.wav", 1, ATTN_NORM);

	if(side)
	{
		fixedmakevectors(this.angles);
		SpawnMeatSpray(this, this.origin + v_forward*16, side * v_right);
	}
}

void bam_swingl9(entity this)
{
	set_animofs(this, anim_bam_swingl, 9, bam_run1); 
	ai_charge(this, 8);
	if(random()<0.5)
		setthink(this, bam_swingr1);
}
void bam_swingl8(entity this) { set_animofs(this, anim_bam_swingl, 8, bam_swingl9); ai_charge(this, 4); }
void bam_swingl7(entity this)
{
	set_animofs(this, anim_bam_swingl, 7, bam_swingl8);
	ai_charge(this, 5);
	bamClaw(this, 250);
}
void bam_swingl6(entity this) { set_animofs(this, anim_bam_swingl, 6, bam_swingl7); ai_charge(this, 9); }
void bam_swingl5(entity this) { set_animofs(this, anim_bam_swingl, 5, bam_swingl6); ai_charge(this, 7); }
void bam_swingl4(entity this) { set_animofs(this, anim_bam_swingl, 4, bam_swingl5); ai_charge(this, 3); }
void bam_swingl3(entity this) { set_animofs(this, anim_bam_swingl, 3, bam_swingl4); ai_charge(this, 7); }
void bam_swingl2(entity this) { set_animofs(this, anim_bam_swingl, 2, bam_swingl3); ai_charge(this, 3); }
void bam_swingl1(entity this)
{
	set_animofs(this, anim_bam_swingl, 1, bam_swingl2); 
	_sound(this, CH_VOICE, "bambler/melee2.wav", 1, ATTN_NORM);
	ai_charge(this, 5);
}

void bam_swingr9(entity this)
{
	set_animofs(this, anim_bam_swingr, 9, bam_run1);
	//ai_charge(this, 1);
	ai_charge(this, 10);
	if(random() < 0.5)
		setthink(this, bam_swingl1);
}
void bam_swingr8(entity this) { set_animofs(this, anim_bam_swingr, 8, bam_swingr9); ai_charge(this, 3); }
void bam_swingr7(entity this)
{
	set_animofs(this, anim_bam_swingr, 7, bam_swingr8);
	ai_charge(this, 6);
	bamClaw(this, -250);
}
void bam_swingr6(entity this) { set_animofs(this, anim_bam_swingr, 6, bam_swingr7); ai_charge(this, 6); }
void bam_swingr5(entity this) { set_animofs(this, anim_bam_swingr, 5, bam_swingr6); ai_charge(this, 3); }
void bam_swingr4(entity this) { set_animofs(this, anim_bam_swingr, 4, bam_swingr5); ai_charge(this, 7); }
void bam_swingr3(entity this) { set_animofs(this, anim_bam_swingr, 3, bam_swingr4); ai_charge(this, 14); }
void bam_swingr2(entity this) { set_animofs(this, anim_bam_swingr, 2, bam_swingr3); ai_charge(this, 8); }
void bam_swingr1(entity this)
{
	set_animofs(this, anim_bam_swingr, 1, bam_swingr2); 
	_sound(this, CH_VOICE, "bambler/melee1.wav", 1, ATTN_NORM);
	ai_charge(this, 1);
}

void bam_melee(entity this)
{
	float chance = random();
	if(chance > 0.6 || this.health >= this.max_health)
		bam_smash1(this);
	else if(chance > 0.3)
		bam_swingr1(this);
	else
		bam_swingl1(this);
}


//============================================================================

void bam_pain6(entity this) { set_animofs(this, anim_bam_pain, 6, bam_run1); }
void bam_pain5(entity this) { set_animofs(this, anim_bam_pain, 5, bam_pain6); }
void bam_pain4(entity this) { set_animofs(this, anim_bam_pain, 4, bam_pain5); }
void bam_pain3(entity this) { set_animofs(this, anim_bam_pain, 3, bam_pain4); }
void bam_pain2(entity this) { set_animofs(this, anim_bam_pain, 2, bam_pain3); }
void bam_pain1(entity this) { set_animofs(this, anim_bam_pain, 1, bam_pain2); }

void bam_pain(entity this, entity attacker, float damage, int deathtype)
{
	_sound(this, CH_VOICE, "bambler/shurt2.wav", 1, ATTN_NORM);

	if(this.health <= 0)
		return;		// allready dying, don't go into pain frame

	if(random()*400 > damage)
		return;		// didn't flinch

	if(this.pain_finished > time)
		return;
	this.pain_finished = time + 2;
		
	bam_pain1(this);
}


//============================================================================


void bam_death11(entity this)
{
	set_animofs(this, anim_bam_death, 11, bam_death11);
	CorpseThink(this);
}
void bam_death10(entity this) { set_animofs(this, anim_bam_death, 10, bam_death11); }
void bam_death9(entity this) { set_animofs(this, anim_bam_death, 9, bam_death10); }
void bam_death8(entity this) { set_animofs(this, anim_bam_death, 8, bam_death9); }
void bam_death7(entity this) { set_animofs(this, anim_bam_death, 7, bam_death8); }
void bam_death6(entity this) { set_animofs(this, anim_bam_death, 6, bam_death7); }
void bam_death5(entity this) { set_animofs(this, anim_bam_death, 5, bam_death6); }
void bam_death4(entity this) { set_animofs(this, anim_bam_death, 4, bam_death5); }
void bam_death3(entity this) { set_animofs(this, anim_bam_death, 3, bam_death4); this.solid = SOLID_NOT; }
void bam_death2(entity this) { set_animofs(this, anim_bam_death, 2, bam_death3); }
void bam_death1(entity this) { set_animofs(this, anim_bam_death, 1, bam_death2); }

void bam_die(entity this, entity inflictor, entity attacker, int deathtype)
{
// check for gib
	if(this.health < -60)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, "progs/h_bams.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib2.mdl", this.health);
		ThrowGib(this, "progs/gib3.mdl", this.health);
		ThrowGib(this, "progs/gib3.mdl", this.health);
		ThrowGib(this, "progs/gib3.mdl", this.health);
		return;
	}

// regular death
	_sound(this, CH_VOICE, "bambler/sdeath.wav", 1, ATTN_NORM);
	bam_death1(this);
}

/*QUAKED monster_bambler (1 0 0) (-32 -32 -24) (32 32 64) Ambush
*/
spawnfunc(monster_bambler) { monster_start(this, MON_BAMBLER); }
#endif // SVQC

#ifdef SVQC
METHOD(Bambler, mr_setup, bool(Bambler this, entity actor))
{
    TC(Bambler, this);
	
	precache_sound("bambler/sdeath.wav");
	precache_sound("bambler/shurt2.wav");
	precache_sound("bambler/sidle.wav");
	precache_sound("bambler/ssight.wav");
	precache_sound("bambler/melee1.wav");
	precache_sound("bambler/melee2.wav");
	precache_sound("bambler/smack.wav");

    actor.health = 450;
    actor.th_stand = bam_stand1;
	actor.th_walk = bam_walk1;
	actor.th_run = bam_run1;
	actor.th_die = bam_die;
	actor.th_melee = bam_melee;
	actor.th_pain = bam_pain;

    return true;
}
#endif
