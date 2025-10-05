#include "mace_ogre.qh"

#ifdef SVQC
const int anim_hogremac_stand = 0;
const int anim_hogremac_walk = 8;
const int anim_hogremac_walkB = 20;
const int anim_hogremac_run = 32;
const int anim_hogremac_swing = 40;
const int anim_hogremac_smash = 54;
const int anim_hogremac_turidle = 68;
const int anim_hogremac_shoot = 76;
const int anim_hogremac_turpainA = 84;
const int anim_hogremac_painA = 89;
const int anim_hogremac_painB = 94;
const int anim_hogremac_painC = 107;
const int anim_hogremac_turwake = 124;
const int anim_hogremac_turrel = 128;
const int anim_hogremac_deathA = 132;
const int anim_hogremac_deathB = 142;

//=============================================================================

const int MON_HOGREMAC_METAL = 4; // Metal Skin version +HP

void hogremac_sound(entity this, int soundtype);

//============================================================================
void hogremac_stand1(entity this);
void hogremac_stand8(entity this) { set_animofs(this, anim_hogremac_stand, 8, hogremac_stand1); ai_stand(this); }
void hogremac_stand7(entity this) { set_animofs(this, anim_hogremac_stand, 7, hogremac_stand8); ai_stand(this); }
void hogremac_stand6(entity this) { set_animofs(this, anim_hogremac_stand, 6, hogremac_stand7); ai_stand(this); }
void hogremac_stand5(entity this) { set_animofs(this, anim_hogremac_stand, 5, hogremac_stand6); ai_stand(this); }
void hogremac_stand4(entity this) { set_animofs(this, anim_hogremac_stand, 4, hogremac_stand5); ai_stand(this); }
void hogremac_stand3(entity this) { set_animofs(this, anim_hogremac_stand, 3, hogremac_stand4); ai_stand(this); }
void hogremac_stand2(entity this) { set_animofs(this, anim_hogremac_stand, 2, hogremac_stand3); ai_stand(this); }
void hogremac_stand1(entity this)
{
	set_animofs(this, anim_hogremac_stand, 1, hogremac_stand2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "ogre/ogidle.wav", 1, ATTN_IDLE);
	ai_stand(this);
}

//============================================================================
void hogremac_walk1(entity this);
void hogremac_walkB12(entity this) { set_animofs(this, anim_hogremac_walkB, 12, hogremac_walk1); ai_walk(this, 0); }
void hogremac_walkB11(entity this) { set_animofs(this, anim_hogremac_walkB, 11, hogremac_walkB12); monster_footstep(this, false); ai_walk(this, 0); }
void hogremac_walkB10(entity this) { set_animofs(this, anim_hogremac_walkB, 10, hogremac_walkB11); ai_walk(this, 2); }
void hogremac_walkB9(entity this) { set_animofs(this, anim_hogremac_walkB, 9, hogremac_walkB10); ai_walk(this, 6); }
void hogremac_walkB8(entity this)
{
	set_animofs(this, anim_hogremac_walkB, 8, hogremac_walkB9);
	ai_walk(this, 7);
	if(random() < 0.1)
		hogremac_sound(this, 1);
}
void hogremac_walkB7(entity this) { set_animofs(this, anim_hogremac_walkB, 7, hogremac_walkB8); ai_walk(this, 6); }
void hogremac_walkB6(entity this) { set_animofs(this, anim_hogremac_walkB, 6, hogremac_walkB7); ai_walk(this, 0); }
void hogremac_walkB5(entity this) { set_animofs(this, anim_hogremac_walkB, 5, hogremac_walkB6); monster_footstep(this, false); ai_walk(this, 0); }
void hogremac_walkB4(entity this) { set_animofs(this, anim_hogremac_walkB, 4, hogremac_walkB5); ai_walk(this, 4); }
void hogremac_walkB3(entity this)
{
	set_animofs(this, anim_hogremac_walkB, 3, hogremac_walkB4);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "ogre/ogidle.wav", 1, ATTN_IDLE);
	ai_walk(this, 6);
}
void hogremac_walkB2(entity this) { set_animofs(this, anim_hogremac_walkB, 2, hogremac_walkB3); ai_walk(this, 6); }
void hogremac_walkB1(entity this) { set_animofs(this, anim_hogremac_walkB, 1, hogremac_walkB2); ai_walk(this, 4); }

//======================================================================
void hogremac_walk12(entity this)
{
	set_animofs(this, anim_hogremac_walk, 12, hogremac_walk1);
	monster_footstep(this, false);
	if(random() < 0.05)
		setthink(this, hogremac_walkB1);
	ai_walk(this, 4);
}
void hogremac_walk11(entity this) { set_animofs(this, anim_hogremac_walk, 11, hogremac_walk12); ai_walk(this, 3); }
void hogremac_walk10(entity this) { set_animofs(this, anim_hogremac_walk, 10, hogremac_walk11); ai_walk(this, 4); }
void hogremac_walk9(entity this)
{
	set_animofs(this, anim_hogremac_walk, 9, hogremac_walk10);
	ai_walk(this, 4);
	if(random() < 0.1)
		hogremac_sound(this, 1);
}
void hogremac_walk8(entity this) { set_animofs(this, anim_hogremac_walk, 8, hogremac_walk9); ai_walk(this, 4); }
void hogremac_walk7(entity this) { set_animofs(this, anim_hogremac_walk, 7, hogremac_walk8); ai_walk(this, 4); }
void hogremac_walk6(entity this) { set_animofs(this, anim_hogremac_walk, 6, hogremac_walk7); monster_footstep(this, false); ai_walk(this, 4); }
void hogremac_walk5(entity this) { set_animofs(this, anim_hogremac_walk, 5, hogremac_walk6); ai_walk(this, 4); }
void hogremac_walk4(entity this) { set_animofs(this, anim_hogremac_walk, 4, hogremac_walk5); ai_walk(this, 4); }
void hogremac_walk3(entity this)
{
	set_animofs(this, anim_hogremac_walk, 3, hogremac_walk4);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "ogre/ogidle.wav", 1, ATTN_IDLE);
	ai_walk(this, 4);
}
void hogremac_walk2(entity this) { set_animofs(this, anim_hogremac_walk, 2, hogremac_walk3); ai_walk(this, 4); }
void hogremac_walk1(entity this) { set_animofs(this, anim_hogremac_walk, 1, hogremac_walk2); ai_walk(this, 4); }

//============================================================================
void hogremac_run1(entity this);
void hogremac_run8(entity this) { set_animofs(this, anim_hogremac_run, 8, hogremac_run1); ai_run(this, 13); }
void hogremac_run7(entity this) { set_animofs(this, anim_hogremac_run, 7, hogremac_run8); ai_run(this, 18); }
void hogremac_run6(entity this) { set_animofs(this, anim_hogremac_run, 6, hogremac_run7); monster_footstep(this, false); ai_run(this, 16); }
void hogremac_run5(entity this) { set_animofs(this, anim_hogremac_run, 5, hogremac_run6); ai_run(this, 8); }
void hogremac_run4(entity this) { set_animofs(this, anim_hogremac_run, 4, hogremac_run5); ai_run(this, 13); }
void hogremac_run3(entity this) { set_animofs(this, anim_hogremac_run, 3, hogremac_run4); ai_run(this, 13); }
void hogremac_run2(entity this) { set_animofs(this, anim_hogremac_run, 2, hogremac_run3); monster_footstep(this, false); ai_run(this, 13); }
void hogremac_run1(entity this)
{
	set_animofs(this, anim_hogremac_run, 1, hogremac_run2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "ogre/ogidle.wav", 1, ATTN_IDLE);
	ai_run(this, 8);
}

//============================================================================
// ogremac_melee(float melee_attack, float side) - defined in aisubs.qc
//----------------------------------------------------------------------
void hogremac_swing14(entity this) { set_animofs(this, anim_hogremac_swing, 14, hogremac_run1); ai_face(this); }
void hogremac_swing13(entity this) { set_animofs(this, anim_hogremac_swing, 13, hogremac_swing14); ai_face(this); }
void hogremac_swing12(entity this) { set_animofs(this, anim_hogremac_swing, 12, hogremac_swing13); ai_face(this); monster_footstep(this, false); }
void hogremac_swing11(entity this) { set_animofs(this, anim_hogremac_swing, 11, hogremac_swing12); ai_forward(this, 4); }
void hogremac_swing10(entity this) { set_animofs(this, anim_hogremac_swing, 10, hogremac_swing11); ai_forward(this, 4); }
void hogremac_swing9(entity this) { set_animofs(this, anim_hogremac_swing, 9, hogremac_swing10); ai_forward(this, 4); }
void hogremac_swing8(entity this) { set_animofs(this, anim_hogremac_swing, 8, hogremac_swing9); ai_forward(this, 4); }
void hogremac_swing7(entity this) { set_animofs(this, anim_hogremac_swing, 7, hogremac_swing8); ai_forward(this, 4); monster_footstep(this, false); }
void hogremac_swing6(entity this)
{
	set_animofs(this, anim_hogremac_swing, 6, hogremac_swing7);
	ai_forward(this, 7);
	if(ai_meleesmash(this, DEATH_MONSTER_MACE_OGRE.m_id, 120, 20))
		_sound(this, CH_WEAPON_SINGLE, "gibs/gibheavy1.wav", 1, ATTN_NORM);
}
void hogremac_swing5(entity this) { set_animofs(this, anim_hogremac_swing, 5, hogremac_swing6); ai_charge(this, 7); }
void hogremac_swing4(entity this) { set_animofs(this, anim_hogremac_swing, 4, hogremac_swing5); ai_charge(this, 6); }
void hogremac_swing3(entity this) { set_animofs(this, anim_hogremac_swing, 3, hogremac_swing4); ai_charge(this, 6); }
void hogremac_swing2(entity this) { set_animofs(this, anim_hogremac_swing, 2, hogremac_swing3); ai_charge(this, 10); hogremac_sound(this, 4); }
void hogremac_swing1(entity this) { set_animofs(this, anim_hogremac_swing, 1, hogremac_swing2); ai_charge(this, 10); }

//----------------------------------------------------------------------
void hogremac_smash14(entity this) { set_animofs(this, anim_hogremac_smash, 14, hogremac_run1); ai_face(this); }
void hogremac_smash13(entity this) { set_animofs(this, anim_hogremac_smash, 13, hogremac_smash14); ai_face(this); }
void hogremac_smash12(entity this) { set_animofs(this, anim_hogremac_smash, 12, hogremac_smash13); }
void hogremac_smash11(entity this) { set_animofs(this, anim_hogremac_smash, 11, hogremac_smash12); }
void hogremac_smash10(entity this)
{
	set_animofs(this, anim_hogremac_smash, 10, hogremac_smash11);
	ai_face(this) ;
	if(ai_meleesmash(this, DEATH_MONSTER_MACE_OGRE.m_id, 120, 30))
		_sound(this, CH_WEAPON_SINGLE, "gibs/gibheavy1.wav", 1, ATTN_NORM);
	makevectors(this.angles); // Put impact infront of ogre
	vector ang = this.origin + (v_forward * 56) + (-v_up * 22);
	particle_explode(ang, 24, 0.5, PARTICLE_BURST_FIRE, PARTICLE_BURST_SHOCKWAVE); 
	_sound(this, CH_WEAPON_SINGLE, "ogre/ham_hit.wav", 1, ATTN_IDLE);
}
void hogremac_smash9(entity this) { set_animofs(this, anim_hogremac_smash, 9, hogremac_smash10); ai_face(this); }
void hogremac_smash8(entity this) { set_animofs(this, anim_hogremac_smash, 8, hogremac_smash9); ai_face(this); monster_footstep(this, false); }
void hogremac_smash7(entity this) { set_animofs(this, anim_hogremac_smash, 7, hogremac_smash8); ai_charge(this, 5); }
void hogremac_smash6(entity this) { set_animofs(this, anim_hogremac_smash, 6, hogremac_smash7); ai_charge(this, 5); }
void hogremac_smash5(entity this) { set_animofs(this, anim_hogremac_smash, 5, hogremac_smash6); ai_charge(this, 12); }
void hogremac_smash4(entity this) { set_animofs(this, anim_hogremac_smash, 4, hogremac_smash5); ai_charge(this, 12); }
void hogremac_smash3(entity this) { set_animofs(this, anim_hogremac_smash, 3, hogremac_smash4); ai_charge(this, 9); }
void hogremac_smash2(entity this) { set_animofs(this, anim_hogremac_smash, 2, hogremac_smash3); ai_charge(this, 9); hogremac_sound(this, 1); }
void hogremac_smash1(entity this) { set_animofs(this, anim_hogremac_smash, 1, hogremac_smash2); ai_charge(this, 9); }

void hogremac_melee(entity this)
{
	// Mace ogres don't get interrupted with pain for melee
	this.pain_finished = time + 2;
	if(random() < 0.5)
		hogremac_smash1(this);
	else
		hogremac_swing1(this);
}

void OgreFireGrenade(entity this);
void hogremac_shoot7(entity this) { set_animofs(this, anim_hogremac_shoot, 6, hogremac_run1); ai_face(this); }
void hogremac_shoot6(entity this) { set_animofs(this, anim_hogremac_shoot, 5, hogremac_shoot7); ai_face(this); }
void hogremac_shoot5(entity this) { set_animofs(this, anim_hogremac_shoot, 4, hogremac_shoot6); ai_face(this); }
void hogremac_shoot4(entity this) { set_animofs(this, anim_hogremac_shoot, 3, hogremac_shoot5); ai_face(this); OgreFireGrenade(this); }
void hogremac_shoot3(entity this) { set_animofs(this, anim_hogremac_shoot, 2, hogremac_shoot4); ai_face(this); }
void hogremac_shoot2(entity this) { set_animofs(this, anim_hogremac_shoot, 2, hogremac_shoot3); ai_face(this); }
void hogremac_shoot1(entity this) { set_animofs(this, anim_hogremac_shoot, 1, hogremac_shoot2); ai_face(this); }

//============================================================================
// painA - Quick backwards flex
//----------------------------------------------------------------------
void hogremac_painA5(entity this) { set_animofs(this, anim_hogremac_painA, 5, hogremac_run1); }
void hogremac_painA4(entity this) { set_animofs(this, anim_hogremac_painA, 4, hogremac_painA5); }
void hogremac_painA3(entity this) { set_animofs(this, anim_hogremac_painA, 3, hogremac_painA4); }
void hogremac_painA2(entity this) { set_animofs(this, anim_hogremac_painA, 2, hogremac_painA3); }
void hogremac_painA1(entity this) { set_animofs(this, anim_hogremac_painA, 1, hogremac_painA2); }

//----------------------------------------------------------------------
// painB - Stagger backwards
//----------------------------------------------------------------------
void hogremac_painB13(entity this) { set_animofs(this, anim_hogremac_painB, 13, hogremac_run1); monster_footstep(this, false); ai_forward(this, 2); }
void hogremac_painB12(entity this) { set_animofs(this, anim_hogremac_painB, 12, hogremac_painB13); ai_forward(this, 2); }
void hogremac_painB11(entity this) { set_animofs(this, anim_hogremac_painB, 11, hogremac_painB12); ai_forward(this, 2); }
void hogremac_painB10(entity this) { set_animofs(this, anim_hogremac_painB, 10, hogremac_painB11); ai_forward(this, 2); }
void hogremac_painB9(entity this) { set_animofs(this, anim_hogremac_painB, 9, hogremac_painB10); ai_forward(this, 2); }
void hogremac_painB8(entity this) { set_animofs(this, anim_hogremac_painB, 8, hogremac_painB9); ai_forward(this, 2); }
void hogremac_painB7(entity this) { set_animofs(this, anim_hogremac_painB, 7, hogremac_painB8); ai_forward(this, 2); }
void hogremac_painB6(entity this) { set_animofs(this, anim_hogremac_painB, 6, hogremac_painB7); ai_forward(this, 2); }
void hogremac_painB5(entity this) { set_animofs(this, anim_hogremac_painB, 5, hogremac_painB6); }
void hogremac_painB4(entity this) { set_animofs(this, anim_hogremac_painB, 4, hogremac_painB5); monster_footstep(this, false); }
void hogremac_painB3(entity this) { set_animofs(this, anim_hogremac_painB, 3, hogremac_painB4); }
void hogremac_painB2(entity this) { set_animofs(this, anim_hogremac_painB, 2, hogremac_painB3); ai_pain(this, 5); }
void hogremac_painB1(entity this) { set_animofs(this, anim_hogremac_painB, 1, hogremac_painB2); ai_pain(this, 7); }

//----------------------------------------------------------------------
// painC - Fall down
//----------------------------------------------------------------------
void hogremac_painC17(entity this) { set_animofs(this, anim_hogremac_painC, 17, hogremac_run1); ai_forward(this, 4); }
void hogremac_painC16(entity this) { set_animofs(this, anim_hogremac_painC, 16, hogremac_painC17); ai_forward(this, 5); }
void hogremac_painC15(entity this) { set_animofs(this, anim_hogremac_painC, 15, hogremac_painC16); ai_forward(this, 4); }
void hogremac_painC14(entity this) { set_animofs(this, anim_hogremac_painC, 14, hogremac_painC15); ai_forward(this, 4); }
void hogremac_painC13(entity this) { set_animofs(this, anim_hogremac_painC, 13, hogremac_painC14); monster_footstep(this, false); ai_forward(this, 3); }
void hogremac_painC12(entity this) { set_animofs(this, anim_hogremac_painC, 12, hogremac_painC13); }
void hogremac_painC11(entity this) { set_animofs(this, anim_hogremac_painC, 11, hogremac_painC12); }
void hogremac_painC10(entity this) { set_animofs(this, anim_hogremac_painC, 10, hogremac_painC11); monster_footstep(this, false); }
void hogremac_painC9(entity this) { set_animofs(this, anim_hogremac_painC, 9, hogremac_painC10); }
void hogremac_painC8(entity this) { set_animofs(this, anim_hogremac_painC, 8, hogremac_painC9); }
void hogremac_painC7(entity this) { set_animofs(this, anim_hogremac_painC, 7, hogremac_painC8); }
void hogremac_painC6(entity this) { set_animofs(this, anim_hogremac_painC, 6, hogremac_painC7); }
void hogremac_painC5(entity this) { set_animofs(this, anim_hogremac_painC, 5, hogremac_painC6); hogremac_sound(this, 3); }	// Ogre hits floor
void hogremac_painC4(entity this) { set_animofs(this, anim_hogremac_painC, 4, hogremac_painC5); }
void hogremac_painC3(entity this) { set_animofs(this, anim_hogremac_painC, 3, hogremac_painC4); }
void hogremac_painC2(entity this) { set_animofs(this, anim_hogremac_painC, 2, hogremac_painC3); ai_pain(this, 2); }
void hogremac_painC1(entity this) { set_animofs(this, anim_hogremac_painC, 1, hogremac_painC2); ai_pain(this, 5); }

void hogremac_pain(entity this, entity attacker, float damage, int deathtype)
{
// don't make multiple pain sounds right after each other
	if(this.pain_finished > time)
		return;

	_sound(this, CH_VOICE, "ogre/ogpain1.wav", 1, ATTN_NORM);		

	float r = random();
	
	if(r < 0.33)
	{
		this.pain_finished = time + 1;
		hogremac_painA1(this);
	}
	else if(r < 0.66)
	{
		this.pain_finished = time + 2;
		hogremac_painB1(this);
	}
	else
	{
		this.pain_finished = time + 1.7;
		hogremac_painC1(this);
	}
}


void hogremac_dieA10(entity this) { set_animofs(this, anim_hogremac_deathA, 10, hogremac_dieA10); CorpseThink(this); }
void hogremac_dieA9(entity this) { set_animofs(this, anim_hogremac_deathA, 9, hogremac_dieA10); }
void hogremac_dieA8(entity this) { set_animofs(this, anim_hogremac_deathA, 8, hogremac_dieA9); hogremac_sound(this, 3); }
void hogremac_dieA7(entity this) { set_animofs(this, anim_hogremac_deathA, 7, hogremac_dieA8); }
void hogremac_dieA6(entity this) { set_animofs(this, anim_hogremac_deathA, 6, hogremac_dieA7); ai_forward(this, 1); }
void hogremac_dieA5(entity this) { set_animofs(this, anim_hogremac_deathA, 5, hogremac_dieA6); ai_forward(this, 1); }
void hogremac_dieA4(entity this) { set_animofs(this, anim_hogremac_deathA, 4, hogremac_dieA5); ai_forward(this, 1); }
void hogremac_dieA3(entity this) { set_animofs(this, anim_hogremac_deathA, 3, hogremac_dieA4); ai_forward(this, 3); }
void hogremac_dieA2(entity this) { set_animofs(this, anim_hogremac_deathA, 2, hogremac_dieA3); ai_forward(this, 14); }
void hogremac_dieA1(entity this) { set_animofs(this, anim_hogremac_deathA, 1, hogremac_dieA2); this.solid = SOLID_NOT; ai_forward(this, 14); }

//----------------------------------------------------------------------
void hogremac_dieB14(entity this) { set_animofs(this, anim_hogremac_deathB, 14, hogremac_dieB14); CorpseThink(this); }
void hogremac_dieB13(entity this) { set_animofs(this, anim_hogremac_deathB, 13, hogremac_dieB14); }
void hogremac_dieB12(entity this) { set_animofs(this, anim_hogremac_deathB, 12, hogremac_dieB13); }
void hogremac_dieB11(entity this) { set_animofs(this, anim_hogremac_deathB, 11, hogremac_dieB12); }
void hogremac_dieB10(entity this) { set_animofs(this, anim_hogremac_deathB, 10, hogremac_dieB11); }
void hogremac_dieB9(entity this) { set_animofs(this, anim_hogremac_deathB, 9, hogremac_dieB10); hogremac_sound(this, 3); }
void hogremac_dieB8(entity this) { set_animofs(this, anim_hogremac_deathB, 8, hogremac_dieB9); ai_back(this, 1); }
void hogremac_dieB7(entity this) { set_animofs(this, anim_hogremac_deathB, 7, hogremac_dieB8); ai_back(this, 1); }
void hogremac_dieB6(entity this) { set_animofs(this, anim_hogremac_deathB, 6, hogremac_dieB7); }
void hogremac_dieB5(entity this) { set_animofs(this, anim_hogremac_deathB, 5, hogremac_dieB6); }
void hogremac_dieB4(entity this) { set_animofs(this, anim_hogremac_deathB, 4, hogremac_dieB5); ai_back(this, 1); }
void hogremac_dieB3(entity this) { set_animofs(this, anim_hogremac_deathB, 3, hogremac_dieB4); ai_back(this, 3); }
void hogremac_dieB2(entity this) { set_animofs(this, anim_hogremac_deathB, 2, hogremac_dieB3); ai_back(this, 10); }
void hogremac_dieB1(entity this) { set_animofs(this, anim_hogremac_deathB, 1, hogremac_dieB2); this.solid = SOLID_NOT; ai_back(this, 4); }

void hogremac_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	DropBackpack(this);
	
// check for gib
	if(this.health < -80)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, inflictor, "progs/h_hogre.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib_ogfoot1.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib_ogfoot2.mdl", this.health);
		if(random() < 0.5)
			ThrowGib(this, inflictor, "progs/w_ogregl.mdl", this.health);
		else
			ThrowGib(this, inflictor, "progs/w_ogremac.mdl", this.health);
		return;
	}

	_sound(this, CH_VOICE, "ogre/ogdth.wav", 1, ATTN_NORM);
	
	if(random() < 0.5)
		hogremac_dieA1(this);
	else
		hogremac_dieB1(this);
}

void hogremac_sound(entity this, int soundtype)
{
	switch(soundtype)
	{
		default:
		case 1: _sound(this, CH_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE); break;
		case 2: _sound(this, CH_WEAPON_SINGLE, "ogre/ogsawatk.wav", 1, ATTN_NORM); break;
		case 3: _sound(this, CH_WEAPON_SINGLE, "gibs/gibwood.wav", 1, ATTN_NORM); break;
		case 4: _sound(this, CH_VOICE, "ogre/ham_swipe.wav", 1, ATTN_IDLE); break;
	}
}

// shares ogre's attack
bool OgreCheckAttack(entity this);

//======================================================================
/*QUAKED monster_hogremac (0.5 0.75 0) (-32 -32 -24) (32 32 64) AMBUSH x METAL NOSIGHT NOIDLE NOGFX STARTOFF ANGRY Not_Easy Not_Normal Not_Hard Not_DM
{ model(":progs/mon_hogremac.mdl"); }
Ogre, 200 health points.
-------- KEYS --------
-------- SPAWNFLAGS --------
METAL : Chain mail metal armour and +100HP
-------- NOTES --------

======================================================================*/
spawnfunc(monster_hogremac) { monster_start(this, true, MON_MACE_OGRE); }
#endif // SVQC

#ifdef SVQC
METHOD(MaceOgre, mr_setup, bool(MaceOgre this, entity actor))
{
	TC(MaceOgre, this);

	precache_model("progs/w_ogremac.mdl");
	precache_model("progs/gib_ogfoot1.mdl");
	precache_model("progs/gib_ogfoot2.mdl");
	precache_model("progs/w_ogregl.mdl");

	precache_sound("ogre/ogdrag.wav");
	precache_sound("ogre/ogdth.wav");
	precache_sound("ogre/ogidle.wav");
	precache_sound("ogre/ogidle2.wav");
	precache_sound("ogre/ogpain1.wav");
	precache_sound("ogre/ogsawatk.wav");
	precache_sound("ogre/ham_swipe.wav"); // mace swipe
	precache_sound("ogre/ham_hit.wav"); // mace hit ground

	precache_sound("gibs/gibheavy1.wav");
	precache_sound("gibs/gibwood.wav");

	precache_sound("weapons/r_exp3b.wav");

	if(random() < 0.2)
		actor.spawnflags |= MON_HOGREMAC_METAL;

	if(actor.health < 1)
		actor.health = 200;

	if(actor.spawnflags & MON_HOGREMAC_METAL)
	{
		actor.health += 50;
		actor.skin = 1;
	}

	actor.th_stand = hogremac_stand1;
	actor.th_walk = hogremac_walk1;
	actor.th_run = hogremac_run1;
	actor.th_die = hogremac_die;
	actor.th_melee = hogremac_melee;
	actor.th_missile = hogremac_shoot1;
	actor.th_pain = hogremac_pain;

	actor.checkattack = OgreCheckAttack;

	actor.steptype = FS_TYPEMEDIUM;

	if(actor.ammo_rockets < 0)
		actor.ammo_rockets = 0;
	else if(actor.ammo_rockets == 0)
		actor.ammo_rockets = 2;

	return true;
}
#endif
