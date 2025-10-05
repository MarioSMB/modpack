#include "fury_knight.qh"

#ifdef SVQC

const int anim_dfury_standL = 0;
const int anim_dfury_standLR = 12;
const int anim_dfury_standR = 19;
const int anim_dfury_standRL = 31;
const int anim_dfury_standB = 38;
const int anim_dfury_standC = 50;
const int anim_dfury_walk = 70;
const int anim_dfury_run = 84;
const int anim_dfury_painA = 90;
const int anim_dfury_painD = 95;
const int anim_dfury_slice = 111;
const int anim_dfury_lunge = 125;
const int anim_dfury_w_attack = 140;
const int anim_dfury_rswing = 164;
const int anim_dfury_lswing = 172;
const int anim_dfury_smash = 180;
const int anim_dfury_magica = 195;
const int anim_dfury_magicb = 211;
const int anim_dfury_death = 224;
const int anim_dfury_deathb = 241;

/*==============================================================================
FURY KNIGHT (one more night)
==============================================================================*/

.int meleeattack;
.float weaponswitch;

void dfury_idle_sound(entity this);
void dfury_standL1(entity this);
void dfury_magic(entity this);
void dfury_sword_sound(entity this);					// Sword swipe sounds
void dfury_grunt_sound(entity this, int soundtype);	// Grunting while attacking

// Different types of grunting sounds
const int DFURY_SOUND_PULLAPART = 1;
const int DFURY_SOUND_OVERSMASH = 2;
const int DFURY_SOUND_JUMP = 3;
const int DFURY_SOUND_LRFURY = 4;
const int DFURY_SOUND_RUNSWING = 5;
const int DFURY_SOUND_OPTIONAL = 6;

//----------------------------------------------------------------------
void dfury_standB12(entity this) { set_animofs(this, anim_dfury_standB, 12, dfury_standL1); ai_stand(this); }
void dfury_standB11(entity this) { set_animofs(this, anim_dfury_standB, 11, dfury_standB12); ai_stand(this); }
void dfury_standB10(entity this)
{
	set_animofs(this, anim_dfury_standB, 10, dfury_standB11);
	ai_stand(this);
	this.nextthink = this.nextthink + random() * 0.2;
}
void dfury_standB9(entity this)
{
	set_animofs(this, anim_dfury_standB, 9, dfury_standB10);
	ai_stand(this);
	this.nextthink = this.nextthink + random() * 0.2;
}
void dfury_standB8(entity this)
{
	set_animofs(this, anim_dfury_standB, 8, dfury_standB9);
	ai_stand(this);
	this.nextthink = this.nextthink + random() * 0.2;
}
void dfury_standB7(entity this) { set_animofs(this, anim_dfury_standB, 7, dfury_standB8); ai_stand(this); }
void dfury_standB6(entity this) { set_animofs(this, anim_dfury_standB, 6, dfury_standB7); ai_stand(this); }
void dfury_standB5(entity this) { set_animofs(this, anim_dfury_standB, 5, dfury_standB6); ai_stand(this); }
void dfury_standB4(entity this) { set_animofs(this, anim_dfury_standB, 4, dfury_standB5); ai_stand(this); }
void dfury_standB3(entity this) { set_animofs(this, anim_dfury_standB, 3, dfury_standB4); ai_stand(this); }
void dfury_standB2(entity this) { set_animofs(this, anim_dfury_standB, 2, dfury_standB3); ai_stand(this); }
void dfury_standB1(entity this) { set_animofs(this, anim_dfury_standB, 1, dfury_standB2); ai_stand(this); }

//----------------------------------------------------------------------
void dfury_standC20(entity this) { set_animofs(this, anim_dfury_standC, 20, dfury_standL1); ai_stand(this); }
void dfury_standC19(entity this) { set_animofs(this, anim_dfury_standC, 19, dfury_standC20); ai_stand(this); }
void dfury_standC18(entity this) { set_animofs(this, anim_dfury_standC, 18, dfury_standC19); ai_stand(this); }
void dfury_standC17(entity this) { set_animofs(this, anim_dfury_standC, 17, dfury_standC18); ai_stand(this); }
void dfury_standC16(entity this) { set_animofs(this, anim_dfury_standC, 16, dfury_standC17); ai_stand(this); }
void dfury_standC15(entity this) { set_animofs(this, anim_dfury_standC, 15, dfury_standC16); ai_stand(this); }
void dfury_standC14(entity this) { set_animofs(this, anim_dfury_standC, 14, dfury_standC15); ai_stand(this); }
void dfury_standC13(entity this) { set_animofs(this, anim_dfury_standC, 13, dfury_standC14); ai_stand(this); }
void dfury_standC12(entity this) { set_animofs(this, anim_dfury_standC, 12, dfury_standC13); ai_stand(this); }
void dfury_standC11(entity this) { set_animofs(this, anim_dfury_standC, 11, dfury_standC12); ai_stand(this); }
void dfury_standC10(entity this) { set_animofs(this, anim_dfury_standC, 10, dfury_standC11); ai_stand(this); }
void dfury_standC9(entity this) { set_animofs(this, anim_dfury_standC, 9, dfury_standC10); ai_stand(this); }
void dfury_standC8(entity this) { set_animofs(this, anim_dfury_standC, 8, dfury_standC9); ai_stand(this); }
void dfury_standC7(entity this) { set_animofs(this, anim_dfury_standC, 7, dfury_standC8); ai_stand(this); }
void dfury_standC6(entity this) { set_animofs(this, anim_dfury_standC, 6, dfury_standC7); ai_stand(this); }
void dfury_standC5(entity this) { set_animofs(this, anim_dfury_standC, 5, dfury_standC6); ai_stand(this); }
void dfury_standC4(entity this) { set_animofs(this, anim_dfury_standC, 4, dfury_standC5); ai_stand(this); }
void dfury_standC3(entity this) { set_animofs(this, anim_dfury_standC, 3, dfury_standC4); ai_stand(this); }
void dfury_standC2(entity this) { set_animofs(this, anim_dfury_standC, 2, dfury_standC3); ai_stand(this); }
void dfury_standC1(entity this) { set_animofs(this, anim_dfury_standC, 1, dfury_standC2); ai_stand(this); }

//----------------------------------------------------------------------
void dfury_standRL7(entity this) { set_animofs(this, anim_dfury_standRL, 7, dfury_standL1); ai_stand(this); }
void dfury_standRL6(entity this) { set_animofs(this, anim_dfury_standRL, 6, dfury_standRL7); ai_stand(this); }
void dfury_standRL5(entity this) { set_animofs(this, anim_dfury_standRL, 5, dfury_standRL6); ai_stand(this); }
void dfury_standRL4(entity this) { set_animofs(this, anim_dfury_standRL, 4, dfury_standRL5); ai_stand(this); }
void dfury_standRL3(entity this) { set_animofs(this, anim_dfury_standRL, 3, dfury_standRL4); ai_stand(this); }
void dfury_standRL2(entity this) { set_animofs(this, anim_dfury_standRL, 2, dfury_standRL3); ai_stand(this); }
void dfury_standRL1(entity this) { set_animofs(this, anim_dfury_standRL, 1, dfury_standRL2); ai_stand(this); }

void dfury_standR1(entity this);
void dfury_standR12(entity this) { set_animofs(this, anim_dfury_standR, 12, dfury_standR1); ai_stand(this); }
void dfury_standR11(entity this) { set_animofs(this, anim_dfury_standR, 11, dfury_standR12); ai_stand(this); }
void dfury_standR10(entity this) { set_animofs(this, anim_dfury_standR, 10, dfury_standR11); ai_stand(this); }
void dfury_standR9(entity this) { set_animofs(this, anim_dfury_standR, 9, dfury_standR10); ai_stand(this); }
void dfury_standR8(entity this) { set_animofs(this, anim_dfury_standR, 8, dfury_standR9); ai_stand(this); }
void dfury_standR7(entity this) { set_animofs(this, anim_dfury_standR, 7, dfury_standR8); ai_stand(this); }
void dfury_standR6(entity this) { set_animofs(this, anim_dfury_standR, 6, dfury_standR7); dfury_idle_sound(this); ai_stand(this); }
void dfury_standR5(entity this) { set_animofs(this, anim_dfury_standR, 5, dfury_standR6); ai_stand(this); }
void dfury_standR4(entity this) { set_animofs(this, anim_dfury_standR, 4, dfury_standR5); ai_stand(this); }
void dfury_standR3(entity this) { set_animofs(this, anim_dfury_standR, 3, dfury_standR4); ai_stand(this); }
void dfury_standR2(entity this) { set_animofs(this, anim_dfury_standR, 2, dfury_standR3); ai_stand(this); }
void dfury_standR1(entity this)
{
	set_animofs(this, anim_dfury_standR, 1, dfury_standR2);
	dfury_idle_sound(this);
	if(random() < 0.2 && this.weaponswitch < time) 
		setthink(this, dfury_standRL1);	// Switch weapon stance
	ai_stand(this);
}

//----------------------------------------------------------------------
void dfury_standLR7(entity this) { set_animofs(this, anim_dfury_standLR, 7, dfury_standR1); ai_stand(this); }
void dfury_standLR6(entity this) { set_animofs(this, anim_dfury_standLR, 6, dfury_standLR7); ai_stand(this); }
void dfury_standLR5(entity this) { set_animofs(this, anim_dfury_standLR, 5, dfury_standLR6); ai_stand(this); }
void dfury_standLR4(entity this) { set_animofs(this, anim_dfury_standLR, 4, dfury_standLR5); ai_stand(this); }
void dfury_standLR3(entity this) { set_animofs(this, anim_dfury_standLR, 3, dfury_standLR4); ai_stand(this); }
void dfury_standLR2(entity this) { set_animofs(this, anim_dfury_standLR, 2, dfury_standLR3); ai_stand(this); }
void dfury_standLR1(entity this) { set_animofs(this, anim_dfury_standLR, 1, dfury_standLR2); ai_stand(this); }

//----------------------------------------------------------------------
void dfury_standL12(entity this) { set_animofs(this, anim_dfury_standL, 12, dfury_standL1); ai_stand(this); }
void dfury_standL11(entity this) { set_animofs(this, anim_dfury_standL, 11, dfury_standL12); ai_stand(this); }
void dfury_standL10(entity this) { set_animofs(this, anim_dfury_standL, 10, dfury_standL11); ai_stand(this); }
void dfury_standL9(entity this) { set_animofs(this, anim_dfury_standL, 9, dfury_standL10); ai_stand(this); }
void dfury_standL8(entity this) { set_animofs(this, anim_dfury_standL, 8, dfury_standL9); ai_stand(this); }
void dfury_standL7(entity this) { set_animofs(this, anim_dfury_standL, 7, dfury_standL8); ai_stand(this); }
void dfury_standL6(entity this) { set_animofs(this, anim_dfury_standL, 6, dfury_standL7); ai_stand(this); }
void dfury_standL5(entity this) { set_animofs(this, anim_dfury_standL, 5, dfury_standL6); ai_stand(this); }
void dfury_standL4(entity this) { set_animofs(this, anim_dfury_standL, 4, dfury_standL5); ai_stand(this); }
void dfury_standL3(entity this) { set_animofs(this, anim_dfury_standL, 3, dfury_standL4); ai_stand(this); }
void dfury_standL2(entity this) { set_animofs(this, anim_dfury_standL, 2, dfury_standL3); ai_stand(this); }
void dfury_standL1(entity this)
{
	set_animofs(this, anim_dfury_standL, 1, dfury_standL2);
	dfury_idle_sound(this);
	if(random() < 0.2 && this.weaponswitch < time)
	{
		// Slow down the repeating of idle animations
		this.weaponswitch = time + 1 + random()*3;

		// Make sure the idle animations don't repeat in a row
		this.lefty = this.lip;
		while(this.lefty == this.lip)
		{
			this.lefty = rint(random() * 4);
		}
		this.lip = this.lefty;

		if(this.lip < 2)
			setthink(this, dfury_standC1);		// Look at weapon
		else if(this.lip == 2)
			setthink(this, dfury_standB1);	// Look around
		else
			setthink(this, dfury_standLR1);					// Switch weapon stance
	}
	ai_stand(this);
}

void dfury_walk1(entity this);
void dfury_walk14(entity this) { set_animofs(this, anim_dfury_walk, 14, dfury_walk1); ai_walk(this, 2); }
void dfury_walk13(entity this) { set_animofs(this, anim_dfury_walk, 13, dfury_walk14); ai_walk(this, 6); }
void dfury_walk12(entity this) { set_animofs(this, anim_dfury_walk, 12, dfury_walk13); ai_walk(this, 4); }
void dfury_walk11(entity this) { set_animofs(this, anim_dfury_walk, 11, dfury_walk12); ai_walk(this, 3); }
void dfury_walk10(entity this) { set_animofs(this, anim_dfury_walk, 10, dfury_walk11); ai_walk(this, 4); }
void dfury_walk9(entity this) { set_animofs(this, anim_dfury_walk, 9, dfury_walk10); ai_walk(this, 3); }
void dfury_walk8(entity this) { set_animofs(this, anim_dfury_walk, 8, dfury_walk9); ai_walk(this, 3); monster_footstep(this, false); }
void dfury_walk7(entity this) { set_animofs(this, anim_dfury_walk, 7, dfury_walk8); ai_walk(this, 2); }
void dfury_walk6(entity this) { set_animofs(this, anim_dfury_walk, 6, dfury_walk7); ai_walk(this, 2); }
void dfury_walk5(entity this) { set_animofs(this, anim_dfury_walk, 5, dfury_walk6); ai_walk(this, 4); }
void dfury_walk4(entity this) { set_animofs(this, anim_dfury_walk, 4, dfury_walk5); ai_walk(this, 4); }
void dfury_walk3(entity this) { set_animofs(this, anim_dfury_walk, 3, dfury_walk4); ai_walk(this, 5); }
void dfury_walk2(entity this) { set_animofs(this, anim_dfury_walk, 2, dfury_walk3); ai_walk(this, 5); monster_footstep(this, false); }
void dfury_walk1(entity this) { set_animofs(this, anim_dfury_walk, 1, dfury_walk2); dfury_idle_sound(this); ai_walk(this, 2); }

//===========================================================================
// 6 frames instead of 8 frames (skipping 3rd/7th timing of original)
void dfury_run1(entity this);
void dfury_run6(entity this) { set_animofs(this, anim_dfury_run, 6, dfury_run1); ai_run(this, 15); }
void dfury_run5(entity this) { set_animofs(this, anim_dfury_run, 5, dfury_run6); ai_run(this, 27); monster_footstep(this, false); }
void dfury_run4(entity this) { set_animofs(this, anim_dfury_run, 4, dfury_run5); ai_run(this, 16); }
void dfury_run3(entity this) { set_animofs(this, anim_dfury_run, 3, dfury_run4); ai_run(this, 18); }
void dfury_run2(entity this) { set_animofs(this, anim_dfury_run, 2, dfury_run3); ai_run(this, 27); monster_footstep(this, false); }
void dfury_run1(entity this)
{
	set_animofs(this, anim_dfury_run, 1, dfury_run2);
	dfury_idle_sound(this);
	ai_run(this, 22);
}

void dfury_idle_sound(entity this)
{
	if(random() < 0.2)
		_sound(this, CH_VOICE, "hknight/idle.wav", 1, ATTN_NORM);
}

//===========================================================================
// Melee Attack 1 - Slice (bring swords together and pull apart)
void dfury_slice11(entity this) { set_animofs(this, anim_dfury_slice, 14, dfury_run1); ai_charge(this, 7); monster_footstep(this, false); }
void dfury_slice10(entity this) { set_animofs(this, anim_dfury_slice, 13, dfury_slice11); ai_charge(this, 0); }
void dfury_slice9(entity this) { set_animofs(this, anim_dfury_slice, 11, dfury_slice10); ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true); monster_footstep(this, false); }
void dfury_slice8(entity this)
{
	set_animofs(this, anim_dfury_slice, 9, dfury_slice9);
	ai_charge(this, 6);
	ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true);
}
void dfury_slice7(entity this)
{
	set_animofs(this, anim_dfury_slice, 8, dfury_slice8);
	ai_charge(this, 12);
	ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true);
}
void dfury_slice6(entity this)
{
	set_animofs(this, anim_dfury_slice, 7, dfury_slice7);
	ai_charge(this, 19);
	ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true);
}
void dfury_slice5(entity this)
{
	set_animofs(this, anim_dfury_slice, 6, dfury_slice6);
	ai_charge(this, 11);
	dfury_sword_sound(this);
	ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true);
}
void dfury_slice4(entity this) { set_animofs(this, anim_dfury_slice, 5, dfury_slice5); ai_charge(this, 4); W_Parry_Trigger(this, 0); monster_footstep(this, false); }
void dfury_slice3(entity this) { set_animofs(this, anim_dfury_slice, 4, dfury_slice4); ai_charge(this, 17); }
void dfury_slice2(entity this) { set_animofs(this, anim_dfury_slice, 3, dfury_slice3); ai_charge(this, 10); dfury_sword_sound(this); }
void dfury_slice1(entity this)
{
	set_animofs(this, anim_dfury_slice, 2, dfury_slice2);
	dfury_grunt_sound(this, DFURY_SOUND_PULLAPART);
	ai_charge(this, 9);
}

//----------------------------------------------------------------------
// Melee Attack 2 - Smash (both swords chop overhead to ground)
void dfury_smash11(entity this) { set_animofs(this, anim_dfury_smash, 13, dfury_run1); ai_charge(this, 0); }
void dfury_smash10(entity this) { set_animofs(this, anim_dfury_smash, 12, dfury_smash11); ai_charge(this, 0); }
void dfury_smash9(entity this)
{
	set_animofs(this, anim_dfury_smash, 10, dfury_smash10);
	ai_charge(this, 3);
	ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true);
}
void dfury_smash8(entity this)
{
	set_animofs(this, anim_dfury_smash, 9, dfury_smash9);
	ai_charge(this, 2);
	W_Parry_Trigger(this, 0);
	if(vdist(this.enemy.origin - this.origin, >, 40))
		return;
	if(!CanDamage(this.enemy, this))
		return;
		
	float ldmg = (random() + random() + random()) * 40;
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_FURY_KNIGHT.m_id);
	_sound(this, CH_VOICE, "gibs/gibheavy2.wav", 1, ATTN_NORM);

	SpawnMeatSpray(this, this.origin + v_forward*16, crandom() * 100 * v_right);
	SpawnMeatSpray(this, this.origin + v_forward*16, crandom() * 100 * v_right);
}
void dfury_smash7(entity this) { set_animofs(this, anim_dfury_smash, 8, dfury_smash8); ai_charge(this, 12); monster_footstep(this, false);  }
void dfury_smash6(entity this) { set_animofs(this, anim_dfury_smash, 7, dfury_smash7); ai_charge(this, 7); dfury_sword_sound(this); }
void dfury_smash5(entity this)
{
	set_animofs(this, anim_dfury_smash, 6, dfury_smash6);
	dfury_grunt_sound(this, DFURY_SOUND_OVERSMASH);
	ai_charge(this, 10);
}
void dfury_smash4(entity this) { set_animofs(this, anim_dfury_smash, 5, dfury_smash5); ai_charge(this, 11); }
void dfury_smash3(entity this) { set_animofs(this, anim_dfury_smash, 4, dfury_smash4); ai_charge(this, 9); monster_footstep(this, false); }
void dfury_smash2(entity this) { set_animofs(this, anim_dfury_smash, 3, dfury_smash3); ai_charge(this, 13); }
void dfury_smash1(entity this) { set_animofs(this, anim_dfury_smash, 2, dfury_smash2); ai_charge(this, 1); }

//----------------------------------------------------------------------
// Melee Attack 4a - Single Right Swing (fast attack)
void dfury_lswing3(entity this);
void dfury_rswing8(entity this) { set_animofs(this, anim_dfury_rswing, 8, dfury_run1); ai_charge(this, 1);
	if(ai_checkmelee(this, 70, false) && this.enemy.health > 0)
		setthink(this, dfury_lswing3);
}
void dfury_rswing7(entity this) { set_animofs(this, anim_dfury_rswing, 7, dfury_rswing8); ai_charge(this, 2); monster_footstep(this, false); }
void dfury_rswing6(entity this)
{
	set_animofs(this, anim_dfury_rswing, 6, dfury_rswing7);
	ai_charge(this, 5);
	ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true);
	dfury_sword_sound(this);
}
void dfury_rswing5(entity this)
{
	set_animofs(this, anim_dfury_rswing, 5, dfury_rswing6);
	ai_charge(this, 7);
	ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true);
}
void dfury_rswing4(entity this)
{
	set_animofs(this, anim_dfury_rswing, 4, dfury_rswing5);
	ai_charge(this, 8);
	ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true);
	monster_footstep(this, false);
}
void dfury_rswing3(entity this)
{
	set_animofs(this, anim_dfury_rswing, 3, dfury_rswing4);
	dfury_grunt_sound(this, DFURY_SOUND_LRFURY);
	ai_charge(this, 5);
}
void dfury_rswing1(entity this) { set_animofs(this, anim_dfury_rswing, 2, dfury_rswing3); ai_charge(this, 2); }

//----------------------------------------------------------------------
// Melee Attack 4a - Single Right Swing (fast attack)
void dfury_lswing8(entity this)
{
	set_animofs(this, anim_dfury_lswing, 8, dfury_run1);
	ai_charge(this, 1);
	if(ai_checkmelee(this, 70, false) && this.enemy.health > 0)
		setthink(this, dfury_rswing3);
}
void dfury_lswing7(entity this) { set_animofs(this, anim_dfury_lswing, 7, dfury_lswing8); ai_charge(this, 2); monster_footstep(this, false); }
void dfury_lswing6(entity this)
{
	set_animofs(this, anim_dfury_lswing, 6, dfury_lswing7);
	ai_charge(this, 5);
	ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true);
	dfury_sword_sound(this);
}
void dfury_lswing5(entity this)
{
	set_animofs(this, anim_dfury_lswing, 5, dfury_lswing6);
	ai_charge(this, 7);
	ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true);
}
void dfury_lswing4(entity this)
{
	set_animofs(this, anim_dfury_lswing, 4, dfury_lswing5);
	ai_charge(this, 8);
	ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true);
	monster_footstep(this, false);
}
void dfury_lswing3(entity this)
{
	set_animofs(this, anim_dfury_lswing, 3, dfury_lswing4);
	dfury_grunt_sound(this, DFURY_SOUND_OPTIONAL);
	ai_charge(this, 5);
}
void dfury_lswing1(entity this) { set_animofs(this, anim_dfury_lswing, 2, dfury_lswing3); ai_charge(this, 2); }

//----------------------------------------------------------------------
// Melee Attack 3 - Lunge forward (leaving ground) and do heavy damage
void dfury_lunge9(entity this);
void dfury_lunge1(entity this);
void dfury_JumpTouch(entity this, entity toucher)
{
	if(this.health < 1)
		return;
	ai_jumpbreakable(this, toucher, 30);			// Damage any breakables
	settouch(this, func_null);			// No more touching
	setthink(this, dfury_lunge9);	// Exit frame

	if(CanDamage(toucher, this) )
	{
		if(vdist(this.velocity, >, 300))
		{
			float ldmg = 20 + 10*random();
			T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_FURY_KNIGHT.m_id);	
			spawn_touchblood(this, ldmg * 3, toucher);
		}
	}

	// Is the fury knight floating in the air?
	if(!t_checkbottom(this))
	{
		// Is the fury knight standing on something?		
		if(IS_ONGROUND(this))
		{	
			// Do an extra jump if got the count
			if(this.count < 2)
				setthink(this, dfury_lunge1);
		}
	}

	// Next timer
	this.nextthink = time + 0.1;
}

//----------------------------------------------------------------------

void dfury_lunge4(entity this);
void dfury_lunge8(entity this)
{
	set_animofs(this, anim_dfury_lunge, 8, dfury_lunge8);
	// Double check monster is still falling?
	if(this.velocity == '0 0 0' || this.oldorigin == this.origin)
	{
		this.ideal_yaw = random() * 360; 	//random jump angle
		setthink(this, dfury_lunge4);			// Keep jumping
	}
	this.oldorigin = this.origin;
}

//----------------------------------------------------------------------
// Landed with thrush attack
void dfury_lunge15(entity this)
{
	set_animofs(this, anim_dfury_lunge, 15, dfury_run1);
	this.angles_x = this.angles_z = 0;
	// If close enough starting swinging left+right ELSE return to run cycle
	if(ai_checkmelee(this, 70, false) && this.enemy.health > 0)
		setthink(this, dfury_rswing3);
}
void dfury_lunge14(entity this)
{
	set_animofs(this, anim_dfury_lunge, 14, dfury_lunge15);
	ai_charge(this, 1);
}
void dfury_lunge13(entity this)
{
	set_animofs(this, anim_dfury_lunge, 13, dfury_lunge14);
	ai_charge(this, 1);
	ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true);
	monster_footstep(this, false);
}
void dfury_lunge12(entity this)
{
	set_animofs(this, anim_dfury_lunge, 12, dfury_lunge13);
	ai_charge(this, 1);
	ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true);
}
void dfury_lunge11(entity this)
{
	set_animofs(this, anim_dfury_lunge, 11, dfury_lunge12);
	ai_charge(this, 4);
	ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true);
	dfury_sword_sound(this);
}
void dfury_lunge10(entity this)
{
	set_animofs(this, anim_dfury_lunge, 10, dfury_lunge11);
	ai_charge(this, 5);
	ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true);
}
void dfury_lunge9(entity this) { set_animofs(this, anim_dfury_lunge, 9, dfury_lunge10); ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true); }
void dfury_lunge7(entity this) { set_animofs(this, anim_dfury_lunge, 7, dfury_lunge8); W_Parry_Trigger(this, 0); }
void dfury_lunge6(entity this) { set_animofs(this, anim_dfury_lunge, 6, dfury_lunge7); }
void dfury_lunge5(entity this) { set_animofs(this, anim_dfury_lunge, 5, dfury_lunge6); }
void dfury_lunge4(entity this)
{
	set_animofs(this, anim_dfury_lunge, 4, dfury_lunge5);
	ai_face(this);
	this.jump_flag = time + 2;
	settouch(this, dfury_JumpTouch);
	fixedmakevectors(this.angles);
	this.velocity = (v_forward * 500) + ('0 0 1' * 250);
	UNSET_ONGROUND(this);
	this.oldorigin = this.origin;
}
void dfury_lunge3(entity this) { set_animofs(this, anim_dfury_lunge, 3, dfury_lunge4); ai_face(this); }
void dfury_lunge2(entity this) { set_animofs(this, anim_dfury_lunge, 2, dfury_lunge3); ai_face(this); }
void dfury_lunge1(entity this)
{
	set_animofs(this, anim_dfury_lunge, 1, dfury_lunge2);
	ai_face(this);
	this.jump_flag = time + 2;
	dfury_grunt_sound(this, DFURY_SOUND_JUMP);
}

//----------------------------------------------------------------------
// Melee Attack 5 - W_Attack (two handed slashing attack)
// Identical frame set (Hell Knight / Death Knight)
// Speed boost (+16 charge) to all frames, fast charging attack!

void dfury_watk22(entity this)
{
	set_animofs(this, anim_dfury_w_attack, 22, dfury_run1);
	ai_charge(this, 21);
	// this is a long animations set for chasing the player
	// Quick check if within melee range, close melee range or random magic attack!
	if(this.enemy.health > 0)
	{
		if(ai_checkmelee(this, 70, false))
			setthink(this, dfury_rswing3);
		else if(ai_checkmelee(this, 150, false))
			setthink(this, dfury_slice1);
		else if(random() < 0.3)
			setthink(this, dfury_magic);
	}
}
void dfury_watk21(entity this) { set_animofs(this, anim_dfury_w_attack, 21, dfury_watk22); ai_charge(this, 25); }
void dfury_watk20(entity this) { set_animofs(this, anim_dfury_w_attack, 20, dfury_watk21); ai_charge(this, 24); }
void dfury_watk19(entity this) { set_animofs(this, anim_dfury_w_attack, 19, dfury_watk20); ai_charge(this, 22); }
void dfury_watk18(entity this)
{
	set_animofs(this, anim_dfury_w_attack, 18, dfury_watk19);
	ai_charge(this, 21);
	ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true);
}
void dfury_watk17(entity this)
{
	set_animofs(this, anim_dfury_w_attack, 17, dfury_watk18);
	ai_charge(this, 19);
	ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true);
	monster_footstep(this, false);
}
void dfury_watk16(entity this)
{
	set_animofs(this, anim_dfury_w_attack, 16, dfury_watk17);
	ai_charge(this, 19);
	dfury_sword_sound(this);
	ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true);
}
void dfury_watk15(entity this) { set_animofs(this, anim_dfury_w_attack, 15, dfury_watk16); ai_charge(this, 18); }
void dfury_watk14(entity this)
{
	set_animofs(this, anim_dfury_w_attack, 14, dfury_watk15);
	ai_charge(this, 18);
	dfury_grunt_sound(this, DFURY_SOUND_OPTIONAL);
}
void dfury_watk13(entity this) { set_animofs(this, anim_dfury_w_attack, 13, dfury_watk14); ai_charge(this, 18); }
void dfury_watk12(entity this) { set_animofs(this, anim_dfury_w_attack, 12, dfury_watk13); ai_charge(this, 19); }
void dfury_watk11(entity this) { set_animofs(this, anim_dfury_w_attack, 11, dfury_watk12); ai_charge(this, 19); }
void dfury_watk10(entity this)
{
	set_animofs(this, anim_dfury_w_attack, 10, dfury_watk11);
	ai_charge(this, 21);
	ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true);
}
void dfury_watk9(entity this)
{
	set_animofs(this, anim_dfury_w_attack, 9, dfury_watk10);
	ai_charge(this, 23);
	ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true);
}
void dfury_watk8(entity this)
{
	set_animofs(this, anim_dfury_w_attack, 8, dfury_watk9);
	ai_charge(this, 22);
	dfury_sword_sound(this);
	ai_melee(this, DEATH_MONSTER_FURY_KNIGHT.m_id, 70, true);
}
void dfury_watk7(entity this) { set_animofs(this, anim_dfury_w_attack, 7, dfury_watk8); ai_charge(this, 19); monster_footstep(this, false); }
void dfury_watk6(entity this) { set_animofs(this, anim_dfury_w_attack, 6, dfury_watk7); ai_charge(this, 18); }
void dfury_watk5(entity this)
{
	set_animofs(this, anim_dfury_w_attack, 5, dfury_watk6);
	ai_charge(this, 18);
	dfury_grunt_sound(this, DFURY_SOUND_RUNSWING);
}
void dfury_watk4(entity this) { set_animofs(this, anim_dfury_w_attack, 4, dfury_watk5); ai_charge(this, 18); }
void dfury_watk3(entity this) { set_animofs(this, anim_dfury_w_attack, 3, dfury_watk4); ai_charge(this, 18); }
void dfury_watk1(entity this) { set_animofs(this, anim_dfury_w_attack, 2, dfury_watk3); ai_charge(this, 18); monster_footstep(this, false); }

//----------------------------------------------------------------------
void dfury_melee(entity this)
{
	// Use heavy overhead smash for monsters
	if(IS_MONSTER(this.enemy))
		dfury_smash1(this);
	else
	{
		// Make sure next attack is different to previous (randomly while loop)
		this.lip = this.meleeattack;
		while(this.lip == this.meleeattack)
		{
			this.lip = rint(random() * 2);
		}
		this.meleeattack = this.lip;
		if(this.meleeattack == 0)
			dfury_lswing1(this);			// Quick left
		else if(this.meleeattack == 1)
			dfury_rswing1(this);	// Quick right
		else
			dfury_smash1(this);								// Overhead smash
	}
}

//===========================================================================
// Magic attacks (glowing swords)
//===========================================================================
// Magic Attack A - Spray of spikes from raised up swords
//----------------------------------------------------------------------
void dfury_magica_shot(entity this, float offset)
{
	if(!this.enemy)
		return;
	if(this.health < 1)
		return;

	// Single sound per volley of bullets
	_sound(this, CH_WEAPON_SINGLE, "hknight/attack1.wav", 1, ATTN_NORM);

	// Randomize quantity each time called
	int shotcount;
	if(random() < 0.5)
		shotcount = 2;
	else
		shotcount = 3;

	// based angle of projectiles on straight line between source and target
	vector offang = vectoangles(this.enemy.origin - this.origin);
	offang.y += offset * 6;		// Arc offset
	makevectors (offang);

	while(shotcount > 0)
	{
		// Randomly spawn projectiles up and down sword length
		vector soffset = v_forward * 20 + v_up * random() * 20;

		// Double check that missile is not blocked by any world geo
		traceline(this.origin, this.origin + soffset, MOVE_NOMONSTERS, this);
		if(!trace_startsolid)
			soffset.z += 24;
		soffset = this.origin + soffset;

		// Straight line velocity from source to target
		vector dir = normalize (v_forward);
		dir_z = 0 - dir_z + (random() - 0.5)*0.1;	// Slight wiggle up/down
		
		// Variable speed based on skill level with extra random spice
		entity newmis = launch_spike(this, soffset, dir);
		newmis.projectiledeathtype = DEATH_MONSTER_FURY_KNIGHT.m_id;
		newmis.classname = "dfury_spike";
		//newmis.dmg = 20;
		_setmodel(newmis, "progs/proj_fury2.mdl");
		setsize(newmis, '0 0 0', '0 0 0');		
		newmis.velocity = dir * 400;
		shotcount -= 1;
	}
}

//----------------------------------------------------------------------
// Magic Attack B - 3 x rockets launched in an arc
//----------------------------------------------------------------------
void dfury_magicb_shot(entity this)
{
	if(!this.enemy)
		return;
	if(this.health < 1)
		return;

	// Single sound for all rockets fired
	_sound(this, CH_WEAPON_SINGLE, "hknight/attack1.wav", 1, ATTN_NORM);

	// create an arc of rockets fanning outwards from source
	float offset = -4;
	int shotcount = 3;
	while(shotcount > 0)
	{
	// based angle of projectiles on straight line between source and target
		vector offang = vectoangles(this.enemy.origin - this.origin);
		offang.y += offset;
		makevectors(offang);
	
		// Randomly spawn projectiles around central point
		vector soffset = v_forward * 20 + v_up * (5 + random() * 10);
		
		// Double check that missile is not blocked by any world geo
		traceline(this.origin, this.origin + soffset, MOVE_NOMONSTERS, this);
		if(!trace_startsolid)
			soffset.z += 24;
		soffset = this.origin + soffset;
	
		// Straight line velocity from source to target
		vector dir = normalize(v_forward);
		dir.z = 0 - dir.z + (random() - 0.5)*0.1;	// Slight wiggle up/down
		vector avel = randomvec() * 200;
		
		// Variable speed based on skill level with extra random spice
		entity newmis = launch_spike(this, soffset, dir);
		newmis.projectiledeathtype = DEATH_MONSTER_FURY_KNIGHT.m_id;
		newmis.classname = "dfury_spike";
		newmis.dmg = 20;
		newmis.avelocity = avel;
		_setmodel(newmis, "progs/proj_fury1.mdl");
		setsize(newmis, '0 0 0', '0 0 0');		
		newmis.velocity = dir * 400;
		offset += 4;
		shotcount -= 1;
	}
}

void dfury_attachment_finish(entity this)
{
	if(this.state)
	{
		this.state = false;
		this.alpha = 0.1;
		setmodel(this, MDL_Null);
	}
}

void dfury_attachment_setup(entity this, int skincolor)
{
	if(this.attachment && !this.attachment.state)
	{
		this.attachment.state = true;
		_setmodel(this.attachment, "progs/mon_dfury_glow.mdl");
		this.attachment.alpha = 0.1;
		this.attachment.skin = skincolor;
		setorigin(this.attachment, this.origin);
		this.attachment.angles = this.angles;
		this.attachment.nextthink = time + 0.15;
		setthink(this.attachment, dfury_attachment_finish);
	}
}

//----------------------------------------------------------------------
void dfury_attachment_update(entity this)
{		
	if(this.attachment && this.attachment.state)
	{
		setorigin(this.attachment, this.origin);
		this.attachment.angles = this.angles;
		this.attachment.frame = this.frame;
		this.attachment.alpha = 0.3 + random()*0.7;
		this.attachment.nextthink = time + 0.15;
		setthink(this.attachment, dfury_attachment_finish);
	}
}

//----------------------------------------------------------------------
// Magic Attack A - Spray of spikes from raised up swords
// Block pain function from interrupting magic attack
void dfury_magica15(entity this) { set_animofs(this, anim_dfury_magica, 16, dfury_run1); }
void dfury_magica14(entity this)
{
	set_animofs(this, anim_dfury_magica, 15, dfury_magica15);
	dfury_attachment_update(this);
	dfury_magica_shot(this, 2);
}
void dfury_magica13(entity this)
{
	set_animofs(this, anim_dfury_magica, 14, dfury_magica14);
	dfury_attachment_update(this);
	dfury_magica_shot(this, 1);
}
void dfury_magica12(entity this)
{
	set_animofs(this, anim_dfury_magica, 13, dfury_magica13);
	dfury_attachment_update(this);
	dfury_magica_shot(this, 0);
}
void dfury_magica11(entity this)
{
	set_animofs(this, anim_dfury_magica, 12, dfury_magica12);
	dfury_attachment_update(this);
	dfury_magica_shot(this, -1);
}
void dfury_magica10(entity this)
{
	set_animofs(this, anim_dfury_magica, 11, dfury_magica11);
	dfury_attachment_update(this);
	dfury_magica_shot(this, -3);
}
void dfury_magica9(entity this) { set_animofs(this, anim_dfury_magica, 10, dfury_magica10); ai_charge(this, 2); dfury_attachment_update(this); }
void dfury_magica8(entity this) { set_animofs(this, anim_dfury_magica, 9, dfury_magica9); ai_charge(this, 2); dfury_attachment_update(this); }
void dfury_magica7(entity this) { set_animofs(this, anim_dfury_magica, 8, dfury_magica8); ai_charge(this, 2); dfury_attachment_update(this); }
void dfury_magica6(entity this) { set_animofs(this, anim_dfury_magica, 7, dfury_magica7); ai_charge(this, 2); dfury_attachment_update(this); }
void dfury_magica5(entity this) { set_animofs(this, anim_dfury_magica, 6, dfury_magica6); ai_charge(this, 2); dfury_attachment_setup(this, 0); }
void dfury_magica4(entity this) { set_animofs(this, anim_dfury_magica, 5, dfury_magica5); ai_face(this); }
void dfury_magica3(entity this) { set_animofs(this, anim_dfury_magica, 4, dfury_magica4); ai_face(this); }
void dfury_magica2(entity this) { set_animofs(this, anim_dfury_magica, 3, dfury_magica3); ai_face(this); }
void dfury_magica1(entity this) { set_animofs(this, anim_dfury_magica, 2, dfury_magica2); ai_face(this); }

//----------------------------------------------------------------------
// Magic Attack B - 3 x rockets launched in an arc
// Block pain function from interrupting magic attack
void dfury_magicb13(entity this) { set_animofs(this, anim_dfury_magica, 13, dfury_run1); }
void dfury_magicb12(entity this) { set_animofs(this, anim_dfury_magicb, 12, dfury_magicb13); }
void dfury_magicb11(entity this) { set_animofs(this, anim_dfury_magicb, 11, dfury_magicb12); }
void dfury_magicb10(entity this) { set_animofs(this, anim_dfury_magicb, 10, dfury_magicb11); dfury_attachment_update(this); }
void dfury_magicb9(entity this)
{
	set_animofs(this, anim_dfury_magicb, 9, dfury_magicb10);
	ai_face(this);
	dfury_attachment_update(this);
	dfury_magicb_shot(this);
}
void dfury_magicb8(entity this) { set_animofs(this, anim_dfury_magicb, 8, dfury_magicb9); ai_face(this); dfury_attachment_update(this); }
void dfury_magicb7(entity this) { set_animofs(this, anim_dfury_magicb, 7, dfury_magicb8); ai_face(this); dfury_attachment_update(this); }
void dfury_magicb6(entity this) { set_animofs(this, anim_dfury_magicb, 6, dfury_magicb7); ai_face(this); dfury_attachment_update(this); }
void dfury_magicb5(entity this) { set_animofs(this, anim_dfury_magicb, 5, dfury_magicb6); ai_face(this); dfury_attachment_update(this); }
void dfury_magicb4(entity this) { set_animofs(this, anim_dfury_magicb, 4, dfury_magicb5); ai_face(this); dfury_attachment_update(this); }
void dfury_magicb3(entity this) { set_animofs(this, anim_dfury_magicb, 3, dfury_magicb4); ai_face(this); dfury_attachment_update(this); }
void dfury_magicb2(entity this) { set_animofs(this, anim_dfury_magicb, 2, dfury_magicb3); ai_face(this); dfury_attachment_setup(this, 1); }
void dfury_magicb1(entity this) { set_animofs(this, anim_dfury_magicb, 1, dfury_magicb2); }

//----------------------------------------------------------------------
// MagicB is explosive so only use if there is range available
// Otherwise randomly pick between the two types (spikes/rockets)
//----------------------------------------------------------------------
void dfury_magic(entity this)
{
	this.attack_finished = time + 2 + random();

	if(vdist(this.enemy.origin - this.origin, <, 150))
		dfury_magica1(this);
	else
	{
		if(random() < 0.2)
			dfury_magica1(this);
		else
			dfury_magicb1(this);
	}
}

void dfury_painA5(entity this) { set_animofs(this, anim_dfury_painA, 5, dfury_run1); }
void dfury_painA4(entity this) { set_animofs(this, anim_dfury_painA, 4, dfury_painA5); }
void dfury_painA3(entity this) { set_animofs(this, anim_dfury_painA, 3, dfury_painA4); }
void dfury_painA2(entity this) { set_animofs(this, anim_dfury_painA, 2, dfury_painA3); }
void dfury_painA1(entity this) { set_animofs(this, anim_dfury_painA, 1, dfury_painA2); }

void dfury_painD11(entity this) { set_animofs(this, anim_dfury_painD, 11, dfury_run1); }
void dfury_painD10(entity this) { set_animofs(this, anim_dfury_painD, 10, dfury_painD11); }
void dfury_painD9(entity this) { set_animofs(this, anim_dfury_painD, 9, dfury_painD10); }
void dfury_painD8(entity this) { set_animofs(this, anim_dfury_painD, 8, dfury_painD9); monster_footstep(this, false); }
void dfury_painD7(entity this) { set_animofs(this, anim_dfury_painD, 7, dfury_painD8); }
void dfury_painD6(entity this) { set_animofs(this, anim_dfury_painD, 6, dfury_painD7); }
void dfury_painD5(entity this) { set_animofs(this, anim_dfury_painD, 5, dfury_painD6); }
void dfury_painD4(entity this) { set_animofs(this, anim_dfury_painD, 4, dfury_painD5); monster_footstep(this, false); }
void dfury_painD3(entity this) { set_animofs(this, anim_dfury_painD, 3, dfury_painD4); }
void dfury_painD2(entity this) { set_animofs(this, anim_dfury_painD, 2, dfury_painD3); }
void dfury_painD1(entity this) { set_animofs(this, anim_dfury_painD, 1, dfury_painD2); }

//----------------------------------------------------------------------
void dfury_pain(entity this, entity attacker, float damage, int deathtype)
{
	//if(deathtype != DEATH_GENERIC.m_id && (random() * 30) > damage)
		//return;

	if(this.pain_finished > time)
		return;

	_sound(this, CH_VOICE, "hknight/pain1.wav", 1, ATTN_NORM);

	if(random() < 0.9)
		dfury_painA1(this);
	else if(random() < 0.5)
	{
		this.pain_finished = time + 2;
		dfury_painD1(this);
	}
	else
	{
		this.pain_finished = time + 1.1;
		this.axhitme = false;
		dfury_painD1(this);
	}
}

void dfury_die16(entity this) { set_animofs(this, anim_dfury_death, 17, dfury_die16); CorpseThink(this); }
void dfury_die15(entity this) { set_animofs(this, anim_dfury_death, 16, dfury_die16); }
void dfury_die14(entity this)
{
	set_animofs(this, anim_dfury_death, 15, dfury_die15);
	_sound(this, CH_WEAPON_SINGLE, "gibs/gibmetala.wav", 1, ATTN_NORM);
}
void dfury_die13(entity this) { set_animofs(this, anim_dfury_death, 14, dfury_die14); }
void dfury_die12(entity this) { set_animofs(this, anim_dfury_death, 13, dfury_die13); }
void dfury_die11(entity this) { set_animofs(this, anim_dfury_death, 12, dfury_die12); }
void dfury_die10(entity this) { set_animofs(this, anim_dfury_death, 11, dfury_die11); }
void dfury_die9(entity this) { set_animofs(this, anim_dfury_death, 10, dfury_die10); ai_forward(this, 11); }
void dfury_die8(entity this) { set_animofs(this, anim_dfury_death, 9, dfury_die9); ai_forward(this, 10); }
void dfury_die7(entity this) { set_animofs(this, anim_dfury_death, 8, dfury_die8); }
void dfury_die6(entity this)
{
	set_animofs(this, anim_dfury_death, 7, dfury_die7);
	_sound(this, CH_WEAPON_SINGLE, "gibs/gibmetala.wav", 1, ATTN_NORM);
}
void dfury_die5(entity this) { set_animofs(this, anim_dfury_death, 6, dfury_die6); }
void dfury_die4(entity this) { set_animofs(this, anim_dfury_death, 5, dfury_die5); }
void dfury_die3(entity this) { set_animofs(this, anim_dfury_death, 4, dfury_die4); ai_forward(this, 7); }
void dfury_die2(entity this) { set_animofs(this, anim_dfury_death, 3, dfury_die3); ai_forward(this, 8); }
void dfury_die1(entity this) { set_animofs(this, anim_dfury_death, 2, dfury_die2); this.solid = SOLID_NOT; ai_forward(this, 10); }

void dfury_dieb14(entity this) { set_animofs(this, anim_dfury_deathb, 14, dfury_dieb14); CorpseThink(this); }
void dfury_dieb13(entity this) { set_animofs(this, anim_dfury_deathb, 13, dfury_dieb14); }
void dfury_dieb12(entity this) { set_animofs(this, anim_dfury_deathb, 12, dfury_dieb13); }
void dfury_dieb11(entity this) { set_animofs(this, anim_dfury_deathb, 11, dfury_dieb12); }
void dfury_dieb10(entity this) { set_animofs(this, anim_dfury_deathb, 10, dfury_dieb11); }
void dfury_dieb9(entity this) { set_animofs(this, anim_dfury_deathb, 9, dfury_dieb10); }
void dfury_dieb8(entity this) { set_animofs(this, anim_dfury_deathb, 8, dfury_dieb9); }
void dfury_dieb7(entity this) { set_animofs(this, anim_dfury_deathb, 7, dfury_dieb8); }
void dfury_dieb6(entity this)
{
	set_animofs(this, anim_dfury_deathb, 6, dfury_dieb7);
	_sound(this, CH_WEAPON_SINGLE, "gibs/gibmetalb.wav", 1, ATTN_NORM);
}
void dfury_dieb5(entity this) { set_animofs(this, anim_dfury_deathb, 5, dfury_dieb6); }
void dfury_dieb4(entity this) { set_animofs(this, anim_dfury_deathb, 4, dfury_dieb5); }
void dfury_dieb3(entity this) { set_animofs(this, anim_dfury_deathb, 3, dfury_dieb4); }
void dfury_dieb2(entity this) { set_animofs(this, anim_dfury_deathb, 2, dfury_dieb3); }
void dfury_dieb1(entity this) { set_animofs(this, anim_dfury_deathb, 1, dfury_dieb2); this.solid = SOLID_NOT; }

void dfury_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(this.attachment)
		delete(this.attachment);
	this.attachment = NULL;
// check for gib
	if(this.health < -40)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, inflictor, "progs/h_dfury.mdl", this.health);
		ThrowGib(this, inflictor, "progs/w_dfurysword1.mdl", this.health);
		ThrowGib(this, inflictor, "progs/w_dfurysword2.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib_knfoot_r.mdl", this.health);
		return;
	}

// regular death
	_sound(this, CH_VOICE, "hknight/death1.wav", 1, ATTN_NORM);
	if(random() > 0.5)
		dfury_die1(this);
	else
		dfury_dieb1(this);
}

void dfury_sword_sound(entity this)
{
	float r = random();
	if(r < 0.25)
		_sound(this, CH_WEAPON_SINGLE, "weapons/sword1a.wav", 1, ATTN_NORM);
	else if(r < 0.5)
		_sound(this, CH_WEAPON_SINGLE, "weapons/sword2a.wav", 1, ATTN_NORM);
	else if(r < 0.75)
		_sound(this, CH_WEAPON_SINGLE, "weapons/sword1b.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "weapons/sword2b.wav", 1, ATTN_NORM);
}

//============================================================================
void dfury_grunt_sound(entity this, int soundtype)
{
	if(soundtype == DFURY_SOUND_PULLAPART)
		_sound(this, CH_WEAPON_SINGLE, "dknight/dfury_grunt3.wav", 1, ATTN_NORM);
	else if(soundtype == DFURY_SOUND_OVERSMASH)
		_sound(this, CH_WEAPON_SINGLE, "dknight/dfury_grunt4.wav", 1, ATTN_NORM);
	else if(soundtype == DFURY_SOUND_JUMP)
		_sound(this, CH_WEAPON_SINGLE, "dknight/dfury_leap.wav", 1, ATTN_NORM);
	else
	{
		if(soundtype == DFURY_SOUND_OPTIONAL && random() < 0.8)
			return;
		float r = random();
		this.weaponswitch = 0.6 + random()*0.4;
		if(r < 0.25)
			_sound(this, CH_WEAPON_SINGLE, "dknight/dfury_grunt1.wav", this.weaponswitch, ATTN_NORM);
		else if(r < 0.5)
			_sound(this, CH_WEAPON_SINGLE, "dknight/dfury_grunt2.wav", this.weaponswitch, ATTN_NORM);
		else if(r < 0.75)
			_sound(this, CH_WEAPON_SINGLE, "dknight/dfury_grunt3.wav", this.weaponswitch, ATTN_NORM);
		else
			_sound(this, CH_WEAPON_SINGLE, "dknight/dfury_grunt4.wav", this.weaponswitch, ATTN_NORM);
	}
}

/*======================================================================
 DFuryCheckAttack
======================================================================*/
bool DFuryCheckAttack(entity this)
{
	if(time < this.attack_finished)
		return false;
	if(!this.enemy_visible)
		return false;

	entity targ = this.enemy;
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;
	traceline(spot1, spot2, false, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
		return false;	// don't have a clear shot

	if(ai_checkmelee(this, 70, 0))
	{
		this.attack_state = AS_MELEE;
		this.th_melee(this);
		return true;
	}

	//----------------------------------------------------------------------
	// If setup to be a turret, check range attack only
	//----------------------------------------------------------------------
	if(this.movespeed < 0)
	{
		this.attack_state = AS_MISSILE;
		return true;
	}

	//----------------------------------------------------------------------
	// is the enemy close enough for a double sword slice attack?
	//----------------------------------------------------------------------
	if(vdist(this.enemy.origin - this.origin, <, 150))
	{
		dfury_slice1(this);
		this.attack_state = AS_MELEE;
		return true;
	}

	//----------------------------------------------------------------------
	// Mid Range attack (JUMP)
	//----------------------------------------------------------------------
	// Jumped recently, facing right direction and not blocked?
	if(this.jump_flag < time && infront(this, this.enemy))
	{
		// Check for enemy above? (z axis)
		if(this.enemy.origin_z <= this.origin_z)
		{
			// Is the fury knight within the right range?
			float edist = vlen2(this.enemy.origin - this.origin);
			if(edist > 150 && edist < 350)
			{
				this.attack_finished = time + random();
				this.count = 0;
				if(random() < 0.65)
					dfury_lunge1(this);
				else
					dfury_watk1(this);
				return true;
			}
		}
	}

	float achance = 0;
	if(this.enemy_range == RANGE_MELEE)
		achance = 0.9;
	else if(this.enemy_range == RANGE_NEAR)
		achance = 0.4;
	else if(this.enemy_range > RANGE_NEAR && this.jump_flag == -1)
		achance = 0.4;
	else
		achance = 0;

	if(random() < achance)
	{
		this.attack_state = AS_MISSILE;
		return true;
	}

	return false;
}

/*======================================================================
QUAKED monster_dfury (1 0 0) (-16 -16 -24) (16 16 40) Ambush
======================================================================*/
spawnfunc(monster_dfury) { monster_start(this, true, MON_FURY_KNIGHT); }
#endif // SVQC

#ifdef SVQC
METHOD(FuryKnight, mr_setup, bool(FuryKnight this, entity actor))
{
    TC(FuryKnight, this);

	precache_model("progs/w_dfurysword1.mdl");
	precache_model("progs/w_dfurysword2.mdl");
	precache_model("progs/gib_knfoot_r.mdl");

	precache_model("progs/proj_fury1.mdl");
	precache_model("progs/proj_fury2.mdl");

	precache_model("progs/mon_dfury_glow.mdl");

	precache_sound("hknight/idle.wav");
	precache_sound("hknight/attack1.wav");
	precache_sound("hknight/death1.wav");
	precache_sound("hknight/pain1.wav");
	precache_sound("hknight/hit.wav");	

	precache_sound("player/udeath.wav");		// gib death

	precache_sound("gibs/gibmetala.wav");
	precache_sound("gibs/gibmetalb.wav");
	precache_sound("gibs/gibheavy2.wav");

	// New sword sweep/slash sounds
	precache_sound("weapons/sword1a.wav");
	precache_sound("weapons/sword1b.wav");
	precache_sound("weapons/sword2a.wav");
	precache_sound("weapons/sword2b.wav");

	// New grunt sounds during combat
	precache_sound("dknight/dfury_grunt1.wav");
	precache_sound("dknight/dfury_grunt2.wav");
	precache_sound("dknight/dfury_grunt3.wav");
	precache_sound("dknight/dfury_grunt4.wav");
	precache_sound("dknight/dfury_leap.wav");

	actor.meleeattack = rint(random() * 5);
	actor.weaponswitch = time + 5;

	if(!actor.attachment)
		actor.attachment = spawn();
	actor.attachment.owner = actor;
	actor.attachment.classname = "attachment";
	setsize(actor.attachment, '0 0 0', '0 0 0');
	set_movetype(actor.attachment, MOVETYPE_NONE);
	actor.attachment.solid = SOLID_NOT;
	setorigin(actor.attachment, actor.origin);

    actor.health = 400;
    actor.th_stand = dfury_standL1;
	actor.th_walk = dfury_walk1;
	actor.th_run = dfury_run1;
	actor.th_melee = dfury_melee;
	actor.th_missile = dfury_magic;
	actor.th_pain = dfury_pain;
	actor.th_die = dfury_die;

	actor.checkattack = DFuryCheckAttack;

	actor.steptype = FS_TYPEMEDIUM;

    return true;
}
#endif
