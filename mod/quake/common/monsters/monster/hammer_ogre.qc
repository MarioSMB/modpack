#include "hammer_ogre.qh"

#ifdef SVQC
const int anim_hogreham_stand = 0;
const int anim_hogreham_walk = 8;
const int anim_hogreham_run = 20;
const int anim_hogreham_swing = 28;
const int anim_hogreham_smash = 42;
const int anim_hogreham_slam = 56;
const int anim_hogreham_turidle = 73;
const int anim_hogreham_shoot = 81;
const int anim_hogreham_turpainA = 89;
const int anim_hogreham_painA = 94;
const int anim_hogreham_painB = 99;
const int anim_hogreham_painC = 112;
const int anim_hogreham_turwake = 129;
const int anim_hogreham_turrel = 133;
const int anim_hogreham_deathA = 137;
const int anim_hogreham_deathB = 147;

//=============================================================================

const int MON_HOGRE_METAL = 4; // Metal Skin version +HP

void hogreham_sound(entity this, int soundtype);

//============================================================================
void hogreham_stand1(entity this);
void hogreham_stand8(entity this) { set_animofs(this, anim_hogreham_stand, 8, hogreham_stand1); ai_stand(this); }
void hogreham_stand7(entity this) { set_animofs(this, anim_hogreham_stand, 7, hogreham_stand8); ai_stand(this); }
void hogreham_stand6(entity this) { set_animofs(this, anim_hogreham_stand, 6, hogreham_stand7); ai_stand(this); }
void hogreham_stand5(entity this) { set_animofs(this, anim_hogreham_stand, 5, hogreham_stand6); ai_stand(this); }
void hogreham_stand4(entity this) { set_animofs(this, anim_hogreham_stand, 4, hogreham_stand5); ai_stand(this); }
void hogreham_stand3(entity this) { set_animofs(this, anim_hogreham_stand, 3, hogreham_stand4); ai_stand(this); }
void hogreham_stand2(entity this) { set_animofs(this, anim_hogreham_stand, 2, hogreham_stand3); ai_stand(this); }
void hogreham_stand1(entity this)
{
	set_animofs(this, anim_hogreham_stand, 1, hogreham_stand2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "ogre/ogidle.wav", 1, ATTN_IDLE);
	ai_stand(this);
}

//============================================================================
void hogreham_walk1(entity this);
void hogreham_walk12(entity this) { set_animofs(this, anim_hogreham_walk, 12, hogreham_walk1); monster_footstep(this, false); ai_walk(this, 3); }
void hogreham_walk11(entity this) { set_animofs(this, anim_hogreham_walk, 11, hogreham_walk12); ai_walk(this, 4); }
void hogreham_walk10(entity this) { set_animofs(this, anim_hogreham_walk, 10, hogreham_walk11); ai_walk(this, 4); }
void hogreham_walk9(entity this) { set_animofs(this, anim_hogreham_walk, 9, hogreham_walk10); ai_walk(this, 4); }
void hogreham_walk8(entity this) { set_animofs(this, anim_hogreham_walk, 8, hogreham_walk9); ai_walk(this, 4); }
void hogreham_walk7(entity this) { set_animofs(this, anim_hogreham_walk, 7, hogreham_walk8); ai_walk(this, 4); }
void hogreham_walk6(entity this) { set_animofs(this, anim_hogreham_walk, 6, hogreham_walk7); monster_footstep(this, false); ai_walk(this, 4); }
void hogreham_walk5(entity this) { set_animofs(this, anim_hogreham_walk, 5, hogreham_walk6); ai_walk(this, 4); }
void hogreham_walk4(entity this) { set_animofs(this, anim_hogreham_walk, 4, hogreham_walk5); ai_walk(this, 4); }
void hogreham_walk3(entity this)
{
	set_animofs(this, anim_hogreham_walk, 3, hogreham_walk4);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "ogre/ogidle.wav", 1, ATTN_IDLE);
	ai_walk(this, 4);
}
void hogreham_walk2(entity this) { set_animofs(this, anim_hogreham_walk, 2, hogreham_walk3); ai_walk(this, 4); }
void hogreham_walk1(entity this) { set_animofs(this, anim_hogreham_walk, 1, hogreham_walk2); ai_walk(this, 4); }

//============================================================================
void hogreham_run1(entity this);
void hogreham_run8(entity this) { set_animofs(this, anim_hogreham_run, 8, hogreham_run1); ai_run(this, 13); }
void hogreham_run7(entity this) { set_animofs(this, anim_hogreham_run, 7, hogreham_run8); ai_run(this, 18); }
void hogreham_run6(entity this) { set_animofs(this, anim_hogreham_run, 6, hogreham_run7); monster_footstep(this, false); ai_run(this, 16); }
void hogreham_run5(entity this) { set_animofs(this, anim_hogreham_run, 5, hogreham_run6); ai_run(this, 8); }
void hogreham_run4(entity this) { set_animofs(this, anim_hogreham_run, 4, hogreham_run5); ai_run(this, 13); }
void hogreham_run3(entity this) { set_animofs(this, anim_hogreham_run, 3, hogreham_run4); ai_run(this, 13); }
void hogreham_run2(entity this) { set_animofs(this, anim_hogreham_run, 2, hogreham_run3); monster_footstep(this, false); ai_run(this, 13); }
void hogreham_run1(entity this)
{
	set_animofs(this, anim_hogreham_run, 1, hogreham_run2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "ogre/ogidle.wav", 1, ATTN_IDLE);
	ai_run(this, 8);
}

//============================================================================
// ogreham_melee(float melee_attack, float side) - defined in aisubs.qc
//----------------------------------------------------------------------
void hogreham_swing14(entity this) { set_animofs(this, anim_hogreham_swing, 14, hogreham_run1); ai_face(this); }
void hogreham_swing13(entity this) { set_animofs(this, anim_hogreham_swing, 13, hogreham_swing14); ai_face(this); }
void hogreham_swing12(entity this) { set_animofs(this, anim_hogreham_swing, 12, hogreham_swing13); ai_face(this); monster_footstep(this, false); }
void hogreham_swing11(entity this) { set_animofs(this, anim_hogreham_swing, 11, hogreham_swing12); ai_forward(this, 3); }
void hogreham_swing10(entity this) { set_animofs(this, anim_hogreham_swing, 10, hogreham_swing11); ai_forward(this, 3); }
void hogreham_swing9(entity this) { set_animofs(this, anim_hogreham_swing, 9, hogreham_swing10); ai_forward(this, 3); }
void hogreham_swing8(entity this) { set_animofs(this, anim_hogreham_swing, 8, hogreham_swing9); ai_forward(this, 3); }
void hogreham_swing7(entity this) { set_animofs(this, anim_hogreham_swing, 7, hogreham_swing8); ai_forward(this, 7); monster_footstep(this, false); }
void hogreham_swing6(entity this)
{
	set_animofs(this, anim_hogreham_swing, 6, hogreham_swing7);
	ai_forward(this, 14);
	if(ai_meleesmash(this, DEATH_MONSTER_HAMMER_OGRE.m_id, 120, 20))
		_sound(this, CH_WEAPON_SINGLE, "gibs/gibheavy1.wav", 1, ATTN_NORM);
}
void hogreham_swing5(entity this) { set_animofs(this, anim_hogreham_swing, 5, hogreham_swing6); ai_charge(this, 12); }
void hogreham_swing4(entity this) { set_animofs(this, anim_hogreham_swing, 4, hogreham_swing5); ai_charge(this, 8); }
void hogreham_swing3(entity this) { set_animofs(this, anim_hogreham_swing, 3, hogreham_swing4); ai_charge(this, 8); }
void hogreham_swing2(entity this) { set_animofs(this, anim_hogreham_swing, 2, hogreham_swing3); ai_charge(this, 8); hogreham_sound(this, 4); }
void hogreham_swing1(entity this) { set_animofs(this, anim_hogreham_swing, 1, hogreham_swing2); ai_charge(this, 4); }

//----------------------------------------------------------------------
void hogreham_smash14(entity this) { set_animofs(this, anim_hogreham_smash, 14, hogreham_run1); ai_face(this); }
void hogreham_smash13(entity this) { set_animofs(this, anim_hogreham_smash, 13, hogreham_smash14); ai_face(this); }
void hogreham_smash12(entity this) { set_animofs(this, anim_hogreham_smash, 12, hogreham_smash13); }
void hogreham_smash11(entity this) { set_animofs(this, anim_hogreham_smash, 11, hogreham_smash12); }
void hogreham_smash10(entity this)
{
	set_animofs(this, anim_hogreham_smash, 10, hogreham_smash11);
	ai_face(this) ;
	if(ai_meleesmash(this, DEATH_MONSTER_HAMMER_OGRE.m_id, 120, 30))
		_sound(this, CH_WEAPON_SINGLE, "gibs/gibheavy1.wav", 1, ATTN_NORM);
	makevectors(this.angles); // Put impact infront of ogre
	vector ang = this.origin + (v_forward * 56) + (-v_up * 22);
	particle_explode(ang, 24, 0.5, PARTICLE_BURST_FIRE, PARTICLE_BURST_SHOCKWAVE); 
	_sound(this, CH_WEAPON_SINGLE, "ogre/ham_hit.wav", 1, ATTN_IDLE);
}
void hogreham_smash9(entity this) { set_animofs(this, anim_hogreham_smash, 9, hogreham_smash10); ai_face(this); }
void hogreham_smash8(entity this) { set_animofs(this, anim_hogreham_smash, 8, hogreham_smash9); ai_face(this); monster_footstep(this, false); }
void hogreham_smash7(entity this) { set_animofs(this, anim_hogreham_smash, 7, hogreham_smash8); ai_face(this); }
void hogreham_smash6(entity this) { set_animofs(this, anim_hogreham_smash, 6, hogreham_smash7); ai_face(this); }
void hogreham_smash5(entity this) { set_animofs(this, anim_hogreham_smash, 5, hogreham_smash6); ai_charge(this, 6); }
void hogreham_smash4(entity this) { set_animofs(this, anim_hogreham_smash, 4, hogreham_smash5); ai_charge(this, 8); }
void hogreham_smash3(entity this) { set_animofs(this, anim_hogreham_smash, 3, hogreham_smash4); ai_charge(this, 10); }
void hogreham_smash2(entity this) { set_animofs(this, anim_hogreham_smash, 2, hogreham_smash3); ai_charge(this, 10); hogreham_sound(this, 4); }
void hogreham_smash1(entity this) { set_animofs(this, anim_hogreham_smash, 1, hogreham_smash2); ai_charge(this, 10); }

/*============================================================================
 Special new ground slam attack - knockback shockwave
============================================================================*/
//----------------------------------------------------------------------
// Slow wind up animation (impact frame - 13) so it is easier to spot
// Pain animations are suppressed so that the attack always happens
//----------------------------------------------------------------------
void hogreham_slam17(entity this)
{
	set_animofs(this, anim_hogreham_slam, 17, hogreham_run1);
	// Double check enemy is still alive?
	if(this.enemy && this.enemy.health > 1)
	{
		// If the enemy is visible, quickly fire a grenade at them
		if(this.th_missile)
		{
			entity targ = this.enemy;
			vector spot1 = this.origin + this.view_ofs;
			vector spot2 = targ.origin + targ.view_ofs;

			traceline(spot1, spot2, false, this);

			if(trace_inopen && trace_inwater)
				return;			// sight line crossed contents

			if(trace_ent != targ)
				return;	// don't have a clear shot

			this.attack_finished = time + 1 * random();
			this.attack_state = AS_MISSILE;
			setthink(this, this.th_missile);
		}
	}
}
void hogreham_slam16(entity this) { set_animofs(this, anim_hogreham_slam, 16, hogreham_slam17); }
void hogreham_slam15(entity this) { set_animofs(this, anim_hogreham_slam, 15, hogreham_slam16); }
void hogreham_slam14(entity this) { set_animofs(this, anim_hogreham_slam, 14, hogreham_slam15); ai_chargenoturn(this, 3); }
void hogreham_slam13(entity this)
{
	set_animofs(this, anim_hogreham_slam, 13, hogreham_slam14); 
	ai_chargenoturn(this, 4);
	ai_shockwave(this, '56 0 -22', 30, 512, 300, 500, DEATH_MONSTER_HAMMER_OGRE.m_id, "ogre/ham_wave.wav");
}
void hogreham_slam12(entity this) { set_animofs(this, anim_hogreham_slam, 12, hogreham_slam13); ai_charge(this, 4); }
void hogreham_slam11(entity this) { set_animofs(this, anim_hogreham_slam, 11, hogreham_slam12); ai_charge(this, 8); }
void hogreham_slam10(entity this) { set_animofs(this, anim_hogreham_slam, 10, hogreham_slam11); ai_charge(this, 8); }
void hogreham_slam9(entity this)
{
	set_animofs(this, anim_hogreham_slam, 9, hogreham_slam10);
	ai_charge(this, 6);
	// Chance of ogre roar (sightsight) instead of weapon swipe
	if(random() < 0.2)
		_sound(this, CH_VOICE, "ogre/ogwake.wav", 1, ATTN_IDLE);
	else
		hogreham_sound(this, 4);
}
void hogreham_slam8(entity this) { set_animofs(this, anim_hogreham_slam, 8, hogreham_slam9); ai_face(this); }
void hogreham_slam7(entity this) { set_animofs(this, anim_hogreham_slam, 7, hogreham_slam8); ai_face(this); }
void hogreham_slam6(entity this) { set_animofs(this, anim_hogreham_slam, 6, hogreham_slam7); ai_charge(this, 3); }
void hogreham_slam5(entity this) { set_animofs(this, anim_hogreham_slam, 5, hogreham_slam6); ai_charge(this, 3); }
void hogreham_slam4(entity this) { set_animofs(this, anim_hogreham_slam, 4, hogreham_slam5); ai_charge(this, 2); }
void hogreham_slam3(entity this) { set_animofs(this, anim_hogreham_slam, 3, hogreham_slam4); ai_charge(this, 2); }
void hogreham_slam2(entity this) { set_animofs(this, anim_hogreham_slam, 2, hogreham_slam3); ai_charge(this, 2); }
void hogreham_slam1(entity this) { set_animofs(this, anim_hogreham_slam, 1, hogreham_slam2); ai_charge(this, 2); }

void hogreham_melee(entity this)
{
	// Hammer ogres don't get interrupted with pain for melee
	this.pain_finished = time + 2;
	if(this.spawnflags & MON_HOGRE_METAL)
		hogreham_slam1(this);
	else
	{
		if(random() < 0.5)
			hogreham_smash1(this);
		else
			hogreham_swing1(this);
	}
}

void OgreFireGrenade(entity this);
void hogreham_shoot7(entity this) { set_animofs(this, anim_hogreham_shoot, 6, hogreham_run1); ai_face(this); }
void hogreham_shoot6(entity this) { set_animofs(this, anim_hogreham_shoot, 5, hogreham_shoot7); ai_face(this); }
void hogreham_shoot5(entity this) { set_animofs(this, anim_hogreham_shoot, 4, hogreham_shoot6); ai_face(this); }
void hogreham_shoot4(entity this) { set_animofs(this, anim_hogreham_shoot, 3, hogreham_shoot5); ai_face(this); OgreFireGrenade(this); }
void hogreham_shoot3(entity this) { set_animofs(this, anim_hogreham_shoot, 2, hogreham_shoot4); ai_face(this); }
void hogreham_shoot2(entity this) { set_animofs(this, anim_hogreham_shoot, 2, hogreham_shoot3); ai_face(this); }
void hogreham_shoot1(entity this) { set_animofs(this, anim_hogreham_shoot, 1, hogreham_shoot2); ai_face(this); }

//============================================================================
// painA - Quick backwards flex
//----------------------------------------------------------------------
void hogreham_painA5(entity this) { set_animofs(this, anim_hogreham_painA, 5, hogreham_run1); }
void hogreham_painA4(entity this) { set_animofs(this, anim_hogreham_painA, 4, hogreham_painA5); }
void hogreham_painA3(entity this) { set_animofs(this, anim_hogreham_painA, 3, hogreham_painA4); }
void hogreham_painA2(entity this) { set_animofs(this, anim_hogreham_painA, 2, hogreham_painA3); }
void hogreham_painA1(entity this) { set_animofs(this, anim_hogreham_painA, 1, hogreham_painA2); }

//----------------------------------------------------------------------
// painB - Stagger backwards
//----------------------------------------------------------------------
void hogreham_painB13(entity this) { set_animofs(this, anim_hogreham_painB, 13, hogreham_run1); monster_footstep(this, false); ai_forward(this, 2); }
void hogreham_painB12(entity this) { set_animofs(this, anim_hogreham_painB, 12, hogreham_painB13); ai_forward(this, 2); }
void hogreham_painB11(entity this) { set_animofs(this, anim_hogreham_painB, 11, hogreham_painB12); ai_forward(this, 2); }
void hogreham_painB10(entity this) { set_animofs(this, anim_hogreham_painB, 10, hogreham_painB11); ai_forward(this, 2); }
void hogreham_painB9(entity this) { set_animofs(this, anim_hogreham_painB, 9, hogreham_painB10); ai_forward(this, 2); }
void hogreham_painB8(entity this) { set_animofs(this, anim_hogreham_painB, 8, hogreham_painB9); ai_forward(this, 2); }
void hogreham_painB7(entity this) { set_animofs(this, anim_hogreham_painB, 7, hogreham_painB8); ai_forward(this, 2); }
void hogreham_painB6(entity this) { set_animofs(this, anim_hogreham_painB, 6, hogreham_painB7); ai_forward(this, 2); }
void hogreham_painB5(entity this) { set_animofs(this, anim_hogreham_painB, 5, hogreham_painB6); }
void hogreham_painB4(entity this) { set_animofs(this, anim_hogreham_painB, 4, hogreham_painB5); monster_footstep(this, false); }
void hogreham_painB3(entity this) { set_animofs(this, anim_hogreham_painB, 3, hogreham_painB4); }
void hogreham_painB2(entity this) { set_animofs(this, anim_hogreham_painB, 2, hogreham_painB3); ai_pain(this, 5); }
void hogreham_painB1(entity this) { set_animofs(this, anim_hogreham_painB, 1, hogreham_painB2); ai_pain(this, 7); }

//----------------------------------------------------------------------
// painC - Fall down
//----------------------------------------------------------------------
void hogreham_painC17(entity this) { set_animofs(this, anim_hogreham_painC, 17, hogreham_run1); ai_forward(this, 4); }
void hogreham_painC16(entity this) { set_animofs(this, anim_hogreham_painC, 16, hogreham_painC17); ai_forward(this, 5); }
void hogreham_painC15(entity this) { set_animofs(this, anim_hogreham_painC, 15, hogreham_painC16); ai_forward(this, 4); }
void hogreham_painC14(entity this) { set_animofs(this, anim_hogreham_painC, 14, hogreham_painC15); ai_forward(this, 4); }
void hogreham_painC13(entity this) { set_animofs(this, anim_hogreham_painC, 13, hogreham_painC14); monster_footstep(this, false); ai_forward(this, 3); }
void hogreham_painC12(entity this) { set_animofs(this, anim_hogreham_painC, 12, hogreham_painC13); }
void hogreham_painC11(entity this) { set_animofs(this, anim_hogreham_painC, 11, hogreham_painC12); }
void hogreham_painC10(entity this) { set_animofs(this, anim_hogreham_painC, 10, hogreham_painC11); monster_footstep(this, false); }
void hogreham_painC9(entity this) { set_animofs(this, anim_hogreham_painC, 9, hogreham_painC10); }
void hogreham_painC8(entity this) { set_animofs(this, anim_hogreham_painC, 8, hogreham_painC9); }
void hogreham_painC7(entity this) { set_animofs(this, anim_hogreham_painC, 7, hogreham_painC8); }
void hogreham_painC6(entity this) { set_animofs(this, anim_hogreham_painC, 6, hogreham_painC7); }
void hogreham_painC5(entity this) { set_animofs(this, anim_hogreham_painC, 5, hogreham_painC6); hogreham_sound(this, 3); }	// Ogre hits floor
void hogreham_painC4(entity this) { set_animofs(this, anim_hogreham_painC, 4, hogreham_painC5); }
void hogreham_painC3(entity this) { set_animofs(this, anim_hogreham_painC, 3, hogreham_painC4); }
void hogreham_painC2(entity this) { set_animofs(this, anim_hogreham_painC, 2, hogreham_painC3); ai_pain(this, 2); }
void hogreham_painC1(entity this) { set_animofs(this, anim_hogreham_painC, 1, hogreham_painC2); ai_pain(this, 5); }

void hogreham_pain(entity this, entity attacker, float damage, int deathtype)
{
// don't make multiple pain sounds right after each other
	if(this.pain_finished > time)
		return;

	_sound(this, CH_VOICE, "ogre/ogpain1.wav", 1, ATTN_NORM);		

	float r = random();
	
	if(r < 0.33)
	{
		this.pain_finished = time + 1;
		hogreham_painA1(this);
	}
	else if(r < 0.66)
	{
		this.pain_finished = time + 2;
		hogreham_painB1(this);
	}
	else
	{
		this.pain_finished = time + 1.7;
		hogreham_painC1(this);
	}
}


void hogreham_dieA10(entity this) { set_animofs(this, anim_hogreham_deathA, 10, hogreham_dieA10); CorpseThink(this); }
void hogreham_dieA9(entity this) { set_animofs(this, anim_hogreham_deathA, 9, hogreham_dieA10); }
void hogreham_dieA8(entity this) { set_animofs(this, anim_hogreham_deathA, 8, hogreham_dieA9); }
void hogreham_dieA7(entity this) { set_animofs(this, anim_hogreham_deathA, 7, hogreham_dieA8); hogreham_sound(this, 3); }	// Hammer hits floor
void hogreham_dieA6(entity this) { set_animofs(this, anim_hogreham_deathA, 6, hogreham_dieA7); ai_forward(this, 1); }
void hogreham_dieA5(entity this) { set_animofs(this, anim_hogreham_deathA, 5, hogreham_dieA6); ai_forward(this, 1); }
void hogreham_dieA4(entity this) { set_animofs(this, anim_hogreham_deathA, 4, hogreham_dieA5); ai_forward(this, 1); }
void hogreham_dieA3(entity this) { set_animofs(this, anim_hogreham_deathA, 3, hogreham_dieA4); ai_forward(this, 3); }
void hogreham_dieA2(entity this) { set_animofs(this, anim_hogreham_deathA, 2, hogreham_dieA3); ai_forward(this, 14); }
void hogreham_dieA1(entity this) { set_animofs(this, anim_hogreham_deathA, 1, hogreham_dieA2); this.solid = SOLID_NOT; ai_forward(this, 14); }

//----------------------------------------------------------------------
void hogreham_dieB14(entity this) { set_animofs(this, anim_hogreham_deathB, 14, hogreham_dieB14); CorpseThink(this); }
void hogreham_dieB13(entity this) { set_animofs(this, anim_hogreham_deathB, 13, hogreham_dieB14); }
void hogreham_dieB12(entity this) { set_animofs(this, anim_hogreham_deathB, 12, hogreham_dieB13); }
void hogreham_dieB11(entity this) { set_animofs(this, anim_hogreham_deathB, 11, hogreham_dieB12); }
void hogreham_dieB10(entity this) { set_animofs(this, anim_hogreham_deathB, 10, hogreham_dieB11); }
void hogreham_dieB9(entity this) { set_animofs(this, anim_hogreham_deathB, 9, hogreham_dieB10); hogreham_sound(this, 3); }	// Hammer hits floor
void hogreham_dieB8(entity this) { set_animofs(this, anim_hogreham_deathB, 8, hogreham_dieB9); ai_back(this, 1); }
void hogreham_dieB7(entity this) { set_animofs(this, anim_hogreham_deathB, 7, hogreham_dieB8); ai_back(this, 1); }
void hogreham_dieB6(entity this) { set_animofs(this, anim_hogreham_deathB, 6, hogreham_dieB7); }
void hogreham_dieB5(entity this) { set_animofs(this, anim_hogreham_deathB, 5, hogreham_dieB6); }
void hogreham_dieB4(entity this) { set_animofs(this, anim_hogreham_deathB, 4, hogreham_dieB5); ai_back(this, 1); }
void hogreham_dieB3(entity this) { set_animofs(this, anim_hogreham_deathB, 3, hogreham_dieB4); ai_back(this, 3); }
void hogreham_dieB2(entity this) { set_animofs(this, anim_hogreham_deathB, 2, hogreham_dieB3); ai_back(this, 10); }
void hogreham_dieB1(entity this) { set_animofs(this, anim_hogreham_deathB, 1, hogreham_dieB2); this.solid = SOLID_NOT; ai_back(this, 4); }

void hogreham_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(this.spawnflags & MON_HOGRE_METAL)
		STAT(WEAPONS, this) = WEP_HAMMER.m_wepset;
	DropBackpack(this);
	
// check for gib
	if(this.health < -80)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, inflictor, "progs/h_hogreham.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib_ogfoot1.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib_ogfoot2.mdl", this.health);
		if(random() < 0.5)
			ThrowGib(this, inflictor, "progs/w_ogregl.mdl", this.health);
		else
			ThrowGib(this, inflictor, "progs/w_ogreham.mdl", this.health);
		return;
	}

	_sound(this, CH_VOICE, "ogre/ogdth.wav", 1, ATTN_NORM);
	
	if(random() < 0.5)
		hogreham_dieA1(this);
	else
		hogreham_dieB1(this);
}

void hogreham_sound(entity this, int soundtype)
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

/*======================================================================
 OgreHamCheckAttack (Hammer only, much faster)
======================================================================*/
bool OgreHamCheckAttack(entity this)
{
	if(this.spawnflags & MON_HOGRE_METAL)
	{
		if(vdist(this.enemy.origin - this.origin, <=, 250) && CanDamage(this.enemy, this))
		{
			this.attack_state = AS_MELEE;
			return true;
		}

	}
	else if(vdist(this.enemy.origin - this.origin, <=, 120))
	{
		if(CanDamage(this.enemy, this))
		{
			this.attack_state = AS_MELEE;
			return true;
		}
	}

	if(this.enemy_range == RANGE_FAR)
		return false;
	if(time < this.attack_finished)
		return false;
	if(!this.enemy_visible)
		return false;

	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, false, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
	{
		return false;	// don't have a clear shot
	}

	this.attack_state = AS_MISSILE;
	this.attack_finished = time + 1 * random();
	return true;
}

//======================================================================
/*QUAKED monster_hogreham (0.5 0.75 0) (-32 -32 -24) (32 32 64) AMBUSH x METAL NOSIGHT NOIDLE NOGFX STARTOFF ANGRY Not_Easy Not_Normal Not_Hard Not_DM
{ model(":progs/mon_hogreham.mdl"); }
Ogre, 300 health points.
-------- KEYS --------
-------- SPAWNFLAGS --------
METAL : Full plate metal armour and +100HP
-------- NOTES --------

======================================================================*/
spawnfunc(monster_hogreham) { monster_start(this, true, MON_HAMMER_OGRE); }
#endif // SVQC

#ifdef SVQC
METHOD(HammerOgre, mr_setup, bool(HammerOgre this, entity actor))
{
	TC(HammerOgre, this);

	precache_model("progs/w_ogreham.mdl");
	precache_model("progs/gib_ogfoot1.mdl");
	precache_model("progs/gib_ogfoot2.mdl");
	precache_model("progs/w_ogregl.mdl");
	precache_model("progs/proj_ringshock.mdl");

	precache_sound("ogre/ogdrag.wav");
	precache_sound("ogre/ogdth.wav");
	precache_sound("ogre/ogidle.wav");
	precache_sound("ogre/ogidle2.wav");
	precache_sound("ogre/ogpain1.wav");
	precache_sound("ogre/ogsawatk.wav");
	precache_sound("ogre/ham_swipe.wav"); // hammer swipe
	precache_sound("ogre/ham_hit.wav"); // hammer hit ground
	precache_sound("ogre/ham_wave.wav"); // hammer shockwave

	precache_sound("gibs/gibheavy1.wav");
	precache_sound("gibs/gibwood.wav");

	precache_sound("weapons/r_exp3b.wav");

	if(random() < 0.2)
		actor.spawnflags |= MON_HOGRE_METAL;

	if(actor.health < 1)
		actor.health = 300;

	if(actor.spawnflags & MON_HOGRE_METAL)
	{
		actor.health += 50;
		actor.skin = 1;
	}

	actor.th_stand = hogreham_stand1;
	actor.th_walk = hogreham_walk1;
	actor.th_run = hogreham_run1;
	actor.th_die = hogreham_die;
	actor.th_melee = hogreham_melee;
	actor.th_missile = hogreham_shoot1;
	actor.th_pain = hogreham_pain;

	actor.checkattack = OgreHamCheckAttack;

	actor.steptype = FS_TYPEHEAVY;

	if(actor.ammo_rockets < 0)
		actor.ammo_rockets = 0;
	else if(actor.ammo_rockets == 0)
		actor.ammo_rockets = 4;

	return true;
}
#endif
