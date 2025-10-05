#include "drole.qh"

#ifdef SVQC
const int anim_drole_standA = 0; //'0 29 0'
const int anim_drole_standB = 30; //'30 69 0'
const int anim_drole_standC = 70; //'70 99 0'
const int anim_drole_magic = 100; //'100 108 0'
const int anim_drole_walk = 109; //'109 116 0'
const int anim_drole_jump = 117; //'117 122 0'
const int anim_drole_run = 123; //'123 130 0'
const int anim_drole_pain = 131; //'131 136 0'
const int anim_drole_clawR = 132; //'132 147 0'
const int anim_drole_clawL = 148; //'148 163 0'
const int anim_drole_death = 164; //'164 189 0'
const int anim_drole_base = 190; //'190 192 0'

.float attack_sidedeny;

.bool idlebusy;

void drole_standC1(entity this);
void drole_standA30(entity this) { set_animofs(this, anim_drole_standA, 30, drole_standC1); ai_stand(this); }
void drole_standA29(entity this) { set_animofs(this, anim_drole_standA, 29, drole_standA30); ai_stand(this); }
void drole_standA28(entity this) { set_animofs(this, anim_drole_standA, 28, drole_standA29); ai_stand(this); }
void drole_standA27(entity this) { set_animofs(this, anim_drole_standA, 27, drole_standA28); ai_stand(this); }
void drole_standA26(entity this) { set_animofs(this, anim_drole_standA, 26, drole_standA27); ai_stand(this); }
void drole_standA25(entity this) { set_animofs(this, anim_drole_standA, 25, drole_standA26); ai_stand(this); }
void drole_standA24(entity this) { set_animofs(this, anim_drole_standA, 24, drole_standA25); ai_stand(this); }
void drole_standA23(entity this) { set_animofs(this, anim_drole_standA, 23, drole_standA24); ai_stand(this); }
void drole_standA22(entity this) { set_animofs(this, anim_drole_standA, 22, drole_standA23); ai_stand(this); }
void drole_standA21(entity this) { set_animofs(this, anim_drole_standA, 21, drole_standA22); ai_stand(this); }
void drole_standA20(entity this) { set_animofs(this, anim_drole_standA, 20, drole_standA21); ai_stand(this); }
void drole_standA19(entity this) { set_animofs(this, anim_drole_standA, 19, drole_standA20); ai_stand(this); }
void drole_standA18(entity this) { set_animofs(this, anim_drole_standA, 18, drole_standA19); ai_stand(this); }
void drole_standA17(entity this) { set_animofs(this, anim_drole_standA, 17, drole_standA18); ai_stand(this); }
void drole_standA16(entity this) { set_animofs(this, anim_drole_standA, 16, drole_standA17); ai_stand(this); }
void drole_standA15(entity this) { set_animofs(this, anim_drole_standA, 15, drole_standA16); ai_stand(this); }
void drole_standA14(entity this) { set_animofs(this, anim_drole_standA, 14, drole_standA15); ai_stand(this); }
void drole_standA13(entity this) { set_animofs(this, anim_drole_standA, 13, drole_standA14); ai_stand(this); }
void drole_standA12(entity this) { set_animofs(this, anim_drole_standA, 12, drole_standA13); ai_stand(this); }
void drole_standA11(entity this) { set_animofs(this, anim_drole_standA, 11, drole_standA12); ai_stand(this); }
void drole_standA10(entity this) { set_animofs(this, anim_drole_standA, 10, drole_standA11); ai_stand(this); }
void drole_standA9(entity this) { set_animofs(this, anim_drole_standA, 9, drole_standA10); ai_stand(this); }
void drole_standA8(entity this) { set_animofs(this, anim_drole_standA, 8, drole_standA9); ai_stand(this); }
void drole_standA7(entity this) { set_animofs(this, anim_drole_standA, 7, drole_standA8); ai_stand(this); }
void drole_standA6(entity this) { set_animofs(this, anim_drole_standA, 6, drole_standA7); ai_stand(this); }
void drole_standA5(entity this) { set_animofs(this, anim_drole_standA, 5, drole_standA6); ai_stand(this); }
void drole_standA4(entity this) { set_animofs(this, anim_drole_standA, 4, drole_standA5); ai_stand(this); }
void drole_standA3(entity this) { set_animofs(this, anim_drole_standA, 3, drole_standA4); ai_stand(this); }
void drole_standA2(entity this) { set_animofs(this, anim_drole_standA, 2, drole_standA3); ai_stand(this); }
void drole_standA1(entity this)
{
	set_animofs(this, anim_drole_standA, 1, drole_standA2);
	if(random() > 0.8)
		_sound(this, CH_VOICE, "drole/idle.wav", 1, ATTN_IDLE);
	ai_stand(this);
}

//============================================================================
void drole_standB40(entity this) { set_animofs(this, anim_drole_standB, 40, drole_standC1); ai_stand(this); }
void drole_standB39(entity this) { set_animofs(this, anim_drole_standB, 39, drole_standB40); ai_stand(this); }
void drole_standB38(entity this) { set_animofs(this, anim_drole_standB, 38, drole_standB39); ai_stand(this); }
void drole_standB37(entity this) { set_animofs(this, anim_drole_standB, 37, drole_standB38); ai_stand(this); }
void drole_standB36(entity this) { set_animofs(this, anim_drole_standB, 36, drole_standB37); ai_stand(this); }
void drole_standB35(entity this) { set_animofs(this, anim_drole_standB, 35, drole_standB36); ai_stand(this); }
void drole_standB34(entity this) { set_animofs(this, anim_drole_standB, 34, drole_standB35); ai_stand(this); }
void drole_standB33(entity this) { set_animofs(this, anim_drole_standB, 33, drole_standB34); ai_stand(this); }
void drole_standB32(entity this) { set_animofs(this, anim_drole_standB, 32, drole_standB33); ai_stand(this); }
void drole_standB31(entity this) { set_animofs(this, anim_drole_standB, 31, drole_standB32); ai_stand(this); }
void drole_standB30(entity this) { set_animofs(this, anim_drole_standB, 30, drole_standB31); ai_stand(this); }
void drole_standB29(entity this) { set_animofs(this, anim_drole_standB, 29, drole_standB30); ai_stand(this); }
void drole_standB28(entity this) { set_animofs(this, anim_drole_standB, 28, drole_standB29); ai_stand(this); }
void drole_standB27(entity this) { set_animofs(this, anim_drole_standB, 27, drole_standB28); ai_stand(this); }
void drole_standB26(entity this) { set_animofs(this, anim_drole_standB, 26, drole_standB27); ai_stand(this); }
void drole_standB25(entity this) { set_animofs(this, anim_drole_standB, 25, drole_standB26); ai_stand(this); }
void drole_standB24(entity this) { set_animofs(this, anim_drole_standB, 24, drole_standB25); ai_stand(this); }
void drole_standB23(entity this) { set_animofs(this, anim_drole_standB, 23, drole_standB24); ai_stand(this); }
void drole_standB22(entity this) { set_animofs(this, anim_drole_standB, 22, drole_standB23); ai_stand(this); }
void drole_standB21(entity this) { set_animofs(this, anim_drole_standB, 21, drole_standB22); ai_stand(this); }
void drole_standB20(entity this) { set_animofs(this, anim_drole_standB, 20, drole_standB21); ai_stand(this); }
void drole_standB19(entity this) { set_animofs(this, anim_drole_standB, 19, drole_standB20); ai_stand(this); }
void drole_standB18(entity this) { set_animofs(this, anim_drole_standB, 18, drole_standB19); ai_stand(this); }
void drole_standB17(entity this) { set_animofs(this, anim_drole_standB, 17, drole_standB18); ai_stand(this); }
void drole_standB16(entity this) { set_animofs(this, anim_drole_standB, 16, drole_standB17); ai_stand(this); }
void drole_standB15(entity this) { set_animofs(this, anim_drole_standB, 15, drole_standB16); ai_stand(this); }
void drole_standB14(entity this) { set_animofs(this, anim_drole_standB, 14, drole_standB15); ai_stand(this); }
void drole_standB13(entity this) { set_animofs(this, anim_drole_standB, 13, drole_standB14); ai_stand(this); }
void drole_standB12(entity this) { set_animofs(this, anim_drole_standB, 12, drole_standB13); ai_stand(this); }
void drole_standB11(entity this) { set_animofs(this, anim_drole_standB, 11, drole_standB12); ai_stand(this); }
void drole_standB10(entity this) { set_animofs(this, anim_drole_standB, 10, drole_standB11); ai_stand(this); }
void drole_standB9(entity this) { set_animofs(this, anim_drole_standB, 9, drole_standB10); ai_stand(this); }
void drole_standB8(entity this) { set_animofs(this, anim_drole_standB, 8, drole_standB9); ai_stand(this); }
void drole_standB7(entity this) { set_animofs(this, anim_drole_standB, 7, drole_standB8); ai_stand(this); }
void drole_standB6(entity this) { set_animofs(this, anim_drole_standB, 6, drole_standB7); ai_stand(this); }
void drole_standB5(entity this) { set_animofs(this, anim_drole_standB, 5, drole_standB6); ai_stand(this); }
void drole_standB4(entity this) { set_animofs(this, anim_drole_standB, 4, drole_standB5); ai_stand(this); }
void drole_standB3(entity this) { set_animofs(this, anim_drole_standB, 3, drole_standB4); ai_stand(this); }
void drole_standB2(entity this) { set_animofs(this, anim_drole_standB, 2, drole_standB3); ai_stand(this); }
void drole_standB1(entity this)
{
	set_animofs(this, anim_drole_standB, 1, drole_standB2);
	if(random() > 0.8)
		_sound(this, CH_VOICE, "drole/idle.wav", 1, ATTN_IDLE);
	ai_stand(this);
}

//============================================================================
void drole_standC30(entity this)
{
	set_animofs(this, anim_drole_standC, 30, drole_standC1);
	this.idlebusy = false; 
	if(random() < 0.2)
	{
		this.idlebusy = true;
		this.lefty = random();
		if(this.lefty < 0.3) setthink(this, drole_standA1);
		else if(this.lefty < 0.6) setthink(this, drole_standB1);
		else setthink(this, drole_standC1);
	}
	ai_stand(this);
}
void drole_standC29(entity this) { set_animofs(this, anim_drole_standC, 29, drole_standC30); ai_stand(this); }
void drole_standC28(entity this) { set_animofs(this, anim_drole_standC, 28, drole_standC29); ai_stand(this); }
void drole_standC27(entity this) { set_animofs(this, anim_drole_standC, 27, drole_standC28); ai_stand(this); }
void drole_standC26(entity this) { set_animofs(this, anim_drole_standC, 26, drole_standC27); ai_stand(this); }
void drole_standC25(entity this) { set_animofs(this, anim_drole_standC, 25, drole_standC26); ai_stand(this); }
void drole_standC24(entity this) { set_animofs(this, anim_drole_standC, 24, drole_standC25); ai_stand(this); }
void drole_standC23(entity this) { set_animofs(this, anim_drole_standC, 23, drole_standC24); ai_stand(this); }
void drole_standC22(entity this) { set_animofs(this, anim_drole_standC, 22, drole_standC23); ai_stand(this); }
void drole_standC21(entity this) { set_animofs(this, anim_drole_standC, 21, drole_standC22); ai_stand(this); }
void drole_standC20(entity this) { set_animofs(this, anim_drole_standC, 20, drole_standC21); ai_stand(this); }
void drole_standC19(entity this) { set_animofs(this, anim_drole_standC, 19, drole_standC20); ai_stand(this); }
void drole_standC18(entity this) { set_animofs(this, anim_drole_standC, 18, drole_standC19); ai_stand(this); }
void drole_standC17(entity this) { set_animofs(this, anim_drole_standC, 17, drole_standC18); ai_stand(this); }
void drole_standC16(entity this) { set_animofs(this, anim_drole_standC, 16, drole_standC17); ai_stand(this); }
void drole_standC15(entity this) { set_animofs(this, anim_drole_standC, 15, drole_standC16); ai_stand(this); }
void drole_standC14(entity this) { set_animofs(this, anim_drole_standC, 14, drole_standC15); ai_stand(this); }
void drole_standC13(entity this) { set_animofs(this, anim_drole_standC, 13, drole_standC14); ai_stand(this); }
void drole_standC12(entity this) { set_animofs(this, anim_drole_standC, 12, drole_standC13); ai_stand(this); }
void drole_standC11(entity this) { set_animofs(this, anim_drole_standC, 11, drole_standC12); ai_stand(this); }
void drole_standC10(entity this) { set_animofs(this, anim_drole_standC, 10, drole_standC11); ai_stand(this); }
void drole_standC9(entity this) { set_animofs(this, anim_drole_standC, 9, drole_standC10); ai_stand(this); }
void drole_standC8(entity this) { set_animofs(this, anim_drole_standC, 8, drole_standC9); ai_stand(this); }
void drole_standC7(entity this) { set_animofs(this, anim_drole_standC, 7, drole_standC8); ai_stand(this); }
void drole_standC6(entity this) { set_animofs(this, anim_drole_standC, 6, drole_standC7); ai_stand(this); }
void drole_standC5(entity this) { set_animofs(this, anim_drole_standC, 5, drole_standC6); ai_stand(this); }
void drole_standC4(entity this) { set_animofs(this, anim_drole_standC, 4, drole_standC5); ai_stand(this); }
void drole_standC3(entity this) { set_animofs(this, anim_drole_standC, 3, drole_standC4); ai_stand(this); }
void drole_standC2(entity this) { set_animofs(this, anim_drole_standC, 2, drole_standC3); ai_stand(this); }
void drole_standC1(entity this)
{
	set_animofs(this, anim_drole_standC, 1, drole_standC2);
	if(random() > 0.8)
		_sound(this, CH_VOICE, "drole/idle.wav", 1, ATTN_IDLE);
	ai_stand(this);
}

//============================================================================
void drole_walk1(entity this);
void drole_walk8(entity this) { set_animofs(this, anim_drole_walk, 8, drole_walk1); ai_walk(this, 3); }
void drole_walk7(entity this) { set_animofs(this, anim_drole_walk, 7, drole_walk8); ai_walk(this, 8); }
void drole_walk6(entity this) { set_animofs(this, anim_drole_walk, 6, drole_walk7); ai_walk(this, 12); }
void drole_walk5(entity this) { set_animofs(this, anim_drole_walk, 5, drole_walk6); ai_walk(this, 6); monster_footstep(this, false); }
void drole_walk4(entity this) { set_animofs(this, anim_drole_walk, 4, drole_walk5); ai_walk(this, 5); }
void drole_walk3(entity this) { set_animofs(this, anim_drole_walk, 3, drole_walk4); ai_walk(this, 9); }
void drole_walk2(entity this) { set_animofs(this, anim_drole_walk, 2, drole_walk3); ai_walk(this, 9); }
void drole_walk1(entity this)
{
	set_animofs(this, anim_drole_walk, 1, drole_walk2);
	if(random() > 0.8)
		_sound(this, CH_VOICE, "drole/idle.wav", 1, ATTN_IDLE);
	ai_walk(this, 10);
	monster_footstep(this, false);
}

//============================================================================
// Drole's have two run speeds, regular and rage
// * each run type uses different animation sets
// * once the drole is enraged there is no going back
// * moved the health trigger to a percentage (custom HP)
//============================================================================
void drole_run(entity this);

void drole_rage8(entity this) { set_animofs(this, anim_drole_run, 8, drole_run); ai_run(this, 28); monster_footstep(this, false); }
void drole_rage7(entity this) { set_animofs(this, anim_drole_run, 7, drole_rage8); ai_run(this, 30); }
void drole_rage6(entity this) { set_animofs(this, anim_drole_run, 6, drole_rage7); ai_run(this, 26); }
void drole_rage5(entity this) { set_animofs(this, anim_drole_run, 5, drole_rage6); ai_run(this, 27); }
void drole_rage4(entity this) { set_animofs(this, anim_drole_run, 4, drole_rage5); ai_run(this, 28); monster_footstep(this, false); }
void drole_rage3(entity this) { set_animofs(this, anim_drole_run, 3, drole_rage4); ai_run(this, 30); }
void drole_rage2(entity this) { set_animofs(this, anim_drole_run, 2, drole_rage3); ai_run(this, 26); }
void drole_rage1(entity this)
{
	set_animofs(this, anim_drole_run, 1, drole_rage2);
	if(random() > 0.8)
		_sound(this, CH_VOICE, "drole/idle.wav", 1, ATTN_IDLE);
	ai_run(this, 27);
	monster_footstep(this, false);
}

//----------------------------------------------------------------------
void drole_run1(entity this);
void drole_run8(entity this) { set_animofs(this, anim_drole_walk, 8, drole_run); ai_run(this, 8); }
void drole_run7(entity this) { set_animofs(this, anim_drole_walk, 7, drole_run8); ai_run(this, 13); }
void drole_run6(entity this) { set_animofs(this, anim_drole_walk, 6, drole_run7); ai_run(this, 17); }
void drole_run5(entity this) { set_animofs(this, anim_drole_walk, 5, drole_run6); ai_run(this, 11); monster_footstep(this, false); }
void drole_run4(entity this) { set_animofs(this, anim_drole_walk, 4, drole_run5); ai_run(this, 10); }
void drole_run3(entity this) { set_animofs(this, anim_drole_walk, 3, drole_run4); ai_run(this, 14); }
void drole_run2(entity this)
{
	set_animofs(this, anim_drole_walk, 2, drole_run3);
	if(random() > 0.8)
		_sound(this, CH_VOICE, "drole/idle.wav", 1, ATTN_IDLE);
	ai_run(this, 14);
}
void drole_run1(entity this) { set_animofs(this, anim_drole_walk, 1, drole_run2); ai_run(this, 15); monster_footstep(this, false); }

//----------------------------------------------------------------------
void drole_run(entity this)
{
	if(this.attack_rage)
		drole_rage1(this);
	else
		drole_run1(this);
}

//===========================================================================
// MELEE ATTACK - Double claws
//===========================================================================
void drole_claw(entity this, float side)
{
	if(!this.enemy) return;
	if(this.health < 1) return;
	ai_face(this);						// Turn towards enemy target
	ai_damagebreakable(this, 50);			// Damage any breakables

	if(!ai_checkmelee(this, 90, 64) || !this.enemy.takedamage)
	{
		// Melee claw miss sound
		_sound(this, CH_WEAPON_SINGLE, "drole/swipe.wav", 1, ATTN_NORM);
	}
	else
	{
		// Melee claw hit sound
		if(random() < 0.5)
			_sound(this, CH_WEAPON_SINGLE, "drole/strike1.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_WEAPON_SINGLE, "drole/strike2.wav", 1, ATTN_NORM);
		float ldmg = 12 + 6*random();
		T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_DROLE.m_id);		
		if(side)
		{
			fixedmakevectors(this.angles);
			SpawnMeatSpray(this, this.origin + v_forward*16, side * v_right);
		}
	}
}

//----------------------------------------------------------------------
void drole_charge(entity this, float ragespd)
{
	if(this.attack_rage)
		ai_charge(this, ragespd);
	else
		ai_charge(this, rint(ragespd*0.7));
}

//----------------------------------------------------------------------
void drole_clawL1(entity this);
//----------------------------------------------------------------------
void drole_clawR16(entity this)
{
	set_animofs(this, anim_drole_clawR, 16, drole_run);
	drole_charge(this, 28);
	if(random() < 0.5 && ai_checkmelee(this, 150, 64) && this.enemy.health > 0 && visible(this, this.enemy))
		drole_clawL1(this);
}
void drole_clawR15(entity this) { set_animofs(this, anim_drole_clawR, 15, drole_clawR16); drole_charge(this, 30); monster_footstep(this, false); }
void drole_clawR14(entity this)
{
	set_animofs(this, anim_drole_clawR, 14, drole_clawR15);
	drole_charge(this, 26);
	_sound(this, CH_WEAPON_SINGLE, "drole/swipe.wav", 1, ATTN_NORM);
}
void drole_clawR13(entity this) { set_animofs(this, anim_drole_clawR, 13, drole_clawR14); drole_charge(this, 27); }
void drole_clawR12(entity this) { set_animofs(this, anim_drole_clawR, 12, drole_clawR13); drole_charge(this, 28); }
void drole_clawR11(entity this) { set_animofs(this, anim_drole_clawR, 11, drole_clawR12); drole_charge(this, 30); drole_claw(this, -250); monster_footstep(this, false); }
void drole_clawR10(entity this) { set_animofs(this, anim_drole_clawR, 10, drole_clawR11); drole_charge(this, 26); }
void drole_clawR9(entity this) { set_animofs(this, anim_drole_clawR, 9, drole_clawR10); drole_charge(this, 27); }
void drole_clawR8(entity this) { set_animofs(this, anim_drole_clawR, 8, drole_clawR9); drole_charge(this, 28); }
void drole_clawR7(entity this) { set_animofs(this, anim_drole_clawR, 7, drole_clawR8); drole_charge(this, 30); monster_footstep(this, false); }
void drole_clawR6(entity this) { set_animofs(this, anim_drole_clawR, 6, drole_clawR7); drole_charge(this, 26); }
void drole_clawR5(entity this) { set_animofs(this, anim_drole_clawR, 5, drole_clawR6); drole_charge(this, 27); drole_claw(this, -250); }
void drole_clawR4(entity this) { set_animofs(this, anim_drole_clawR, 4, drole_clawR5); drole_charge(this, 28); }
void drole_clawR3(entity this) { set_animofs(this, anim_drole_clawR, 3, drole_clawR4); drole_charge(this, 30); monster_footstep(this, false); }
void drole_clawR2(entity this)
{
	set_animofs(this, anim_drole_clawR, 2, drole_clawR3);
	drole_charge(this, 26);
	_sound(this, CH_WEAPON_SINGLE, "drole/swipe.wav", 1, ATTN_NORM);
}
void drole_clawR1(entity this) { set_animofs(this, anim_drole_clawR, 1, drole_clawR2); drole_charge(this, 27); }

//----------------------------------------------------------------------
void drole_clawL16(entity this)
{
	set_animofs(this, anim_drole_clawL, 16, drole_run);
	drole_charge(this, 28);
	if(random() < 0.5 && ai_checkmelee(this, 150, 64) && this.enemy.health > 0 && visible(this, this.enemy))
		drole_clawR1(this);
}
void drole_clawL15(entity this) { set_animofs(this, anim_drole_clawL, 15, drole_clawL16); drole_charge(this, 30); monster_footstep(this, false); }
void drole_clawL14(entity this)
{
	set_animofs(this, anim_drole_clawL, 14, drole_clawL15);
	drole_charge(this, 26);
	_sound(this, CH_WEAPON_SINGLE, "drole/swipe.wav", 1, ATTN_NORM);
}
void drole_clawL13(entity this) { set_animofs(this, anim_drole_clawL, 13, drole_clawL14); drole_charge(this, 27); }
void drole_clawL12(entity this) { set_animofs(this, anim_drole_clawL, 12, drole_clawL13); drole_charge(this, 28); }
void drole_clawL11(entity this) { set_animofs(this, anim_drole_clawL, 11, drole_clawL12); drole_charge(this, 30); drole_claw(this, 250); monster_footstep(this, false); }
void drole_clawL10(entity this) { set_animofs(this, anim_drole_clawL, 10, drole_clawL11); drole_charge(this, 26); }
void drole_clawL9(entity this) { set_animofs(this, anim_drole_clawL, 9, drole_clawL10); drole_charge(this, 27); }
void drole_clawL8(entity this) { set_animofs(this, anim_drole_clawL, 8, drole_clawL9); drole_charge(this, 28); }
void drole_clawL7(entity this) { set_animofs(this, anim_drole_clawL, 7, drole_clawL8); drole_charge(this, 30); monster_footstep(this, false); }
void drole_clawL6(entity this) { set_animofs(this, anim_drole_clawL, 6, drole_clawL7); drole_charge(this, 26); }
void drole_clawL5(entity this) { set_animofs(this, anim_drole_clawL, 5, drole_clawL6); drole_charge(this, 27); drole_claw(this, 250); }
void drole_clawL4(entity this) { set_animofs(this, anim_drole_clawL, 4, drole_clawL5); drole_charge(this, 28); }
void drole_clawL3(entity this) { set_animofs(this, anim_drole_clawL, 3, drole_clawL4); drole_charge(this, 30); monster_footstep(this, false); }
void drole_clawL2(entity this)
{
	set_animofs(this, anim_drole_clawL, 2, drole_clawL3);
	drole_charge(this, 26);
	_sound(this, CH_WEAPON_SINGLE, "drole/swipe.wav", 1, ATTN_NORM);
}
void drole_clawL1(entity this) { set_animofs(this, anim_drole_clawL, 1, drole_clawL2); drole_charge(this, 27); }

//----------------------------------------------------------------------
void drole_melee(entity this)
{
	if(random() < 0.5)
		drole_clawR1(this);
	else
		drole_clawL1(this);
}

//============================================================================
// RANGE ATTACK - Fireball (rocket)
// * The trick to drole rockets is that they start really slow
// * Over time (4 frames) the rocket speeds up (linked to animation)
// * requires special projectile and new th_updmissile function
// * Has a different explosion sound (does not play rocket default)
//
//============================================================================
void drole_rocket4(entity this)
{
	set_anim(this, 3, SUB_Remove);
	this.nextthink = time + 5;
	if(autocvar_skill == 0)
		this.velocity = this.velocity * 3.5;
	else
		this.velocity = this.velocity * 4.5;
}
void drole_rocket3(entity this) { set_anim(this, 3, drole_rocket4); this.velocity = this.velocity * 1.5; }
void drole_rocket2(entity this) { set_anim(this, 2, drole_rocket3); this.velocity = this.velocity * 1.5; }
void drole_rocket1(entity this) { set_anim(this, 1, drole_rocket2); this.nextthink = time + 0.2; }

//----------------------------------------------------------------------
void drole_fire(entity this)
{
	if(!this.enemy) return;
	if(this.health < 1) return;

	makevectors(this.angles);
	vector org = this.origin + attack_vector('0 0 34');
	vector dir = normalize((this.enemy.origin + '0 0 -8') - org);
	vector avel = randomvec() * 100;

	entity newmis = launch_spike(this, org, dir);
	newmis.poisonous = this.poisonous;
	if(newmis.poisonous)
		_setmodel(newmis, "progs/proj_drolegrn.mdl");
	else
		_setmodel(newmis, "progs/proj_drole.mdl");
	newmis.avelocity = avel;
	newmis.dmg = 40;
	setsize(newmis, '0 0 0', '0 0 0');
	newmis.noise = "drole/r_explode.wav";
	newmis.nextthink = time + 0.025;
	setthink(newmis, drole_rocket1);
	newmis.velocity = dir * 80;
	settouch(newmis, T_MissileTouch); // rocket explosion
	newmis.projectiledeathtype = DEATH_MONSTER_DROLE.m_id;
}

void drole_magic9(entity this) { set_animofs(this, anim_drole_magic, 9, drole_run); ai_face(this); }
void drole_magic8(entity this) { set_animofs(this, anim_drole_magic, 8, drole_magic9); ai_face(this); }
void drole_magic7(entity this) { set_animofs(this, anim_drole_magic, 7, drole_magic8); ai_face(this); }
void drole_magic6(entity this) { set_animofs(this, anim_drole_magic, 6, drole_magic7); ai_face(this); }
void drole_magic5(entity this) { set_animofs(this, anim_drole_magic, 5, drole_magic6); ai_face(this); }
void drole_magic4(entity this)
{
	set_animofs(this, anim_drole_magic, 4, drole_magic5);
	if(visible(this, this.enemy))
		ai_face(this);
	drole_fire(this);
}
void drole_magic3(entity this)
{
	set_animofs(this, anim_drole_magic, 3, drole_magic4);
	if(visible(this, this.enemy))
		ai_face(this);
}
void drole_magic2(entity this)
{
	set_animofs(this, anim_drole_magic, 2, drole_magic3);
	if(visible(this, this.enemy))
		ai_face(this);
}
void drole_magic1(entity this)
{
	set_animofs(this, anim_drole_magic, 1, drole_magic2);
	_sound(this, CH_WEAPON_SINGLE, "drole/fire.wav", 1, ATTN_NORM);
}

//============================================================================
void drole_pain6(entity this) { set_animofs(this, anim_drole_pain, 6, drole_run); ai_back(this, 4); }
void drole_pain5(entity this) { set_animofs(this, anim_drole_pain, 5, drole_pain6); ai_back(this, 6); }
void drole_pain4(entity this) { set_animofs(this, anim_drole_pain, 4, drole_pain5); ai_back(this, 8); }
void drole_pain3(entity this) { set_animofs(this, anim_drole_pain, 3, drole_pain4); ai_back(this, 10); }
void drole_pain2(entity this) { set_animofs(this, anim_drole_pain, 2, drole_pain3); ai_back(this, 10); }
void drole_pain1(entity this) { set_animofs(this, anim_drole_pain, 1, drole_pain2); ai_back(this, 8); }

void drole_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.health <= 0)
		return;

	if(random() * 60 > damage)
		return;

	if(this.pain_finished > time)
		return;

	this.pain_finished = time + 0.6;

	if(this.attack_rage)
		_sound(this, CH_VOICE, "drole/enrage.wav", 0.5, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "drole/pain.wav", 1, ATTN_NORM);

	drole_pain1(this);
}

void drole_explode(entity this, entity inflictor, bool isgib)
{
	float myhealth = (isgib) ? this.health : -100;
	_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
	ThrowHead(this, inflictor, "progs/h_drole.mdl", myhealth);
	ThrowGib(this, inflictor, "progs/gib_drolearm1.mdl", myhealth);
	ThrowGib(this, inflictor, "progs/gib_drolearm2.mdl", myhealth);
	ThrowGib(this, inflictor, "progs/gib_droleleg1.mdl", myhealth);
}

void drole_death26(entity this) { set_animofs(this, anim_drole_death, 26, drole_death26); drole_explode(this, this, false); }
void drole_death25(entity this) { set_animofs(this, anim_drole_death, 25, drole_death26); }
void drole_death24(entity this) { set_animofs(this, anim_drole_death, 24, drole_death25); }
void drole_death23(entity this) { set_animofs(this, anim_drole_death, 23, drole_death24); }
void drole_death22(entity this) { set_animofs(this, anim_drole_death, 22, drole_death23); }
void drole_death21(entity this) { set_animofs(this, anim_drole_death, 21, drole_death22); }
void drole_death20(entity this) { set_animofs(this, anim_drole_death, 20, drole_death21); }
void drole_death19(entity this) { set_animofs(this, anim_drole_death, 19, drole_death20); }
void drole_death18(entity this) { set_animofs(this, anim_drole_death, 18, drole_death19); }
void drole_death17(entity this) { set_animofs(this, anim_drole_death, 17, drole_death18); }
void drole_death16(entity this) { set_animofs(this, anim_drole_death, 16, drole_death17); }
void drole_death15(entity this) { set_animofs(this, anim_drole_death, 15, drole_death16); }
void drole_death14(entity this) { set_animofs(this, anim_drole_death, 14, drole_death15); }
void drole_death13(entity this) { set_animofs(this, anim_drole_death, 13, drole_death14); }
void drole_death12(entity this) { set_animofs(this, anim_drole_death, 12, drole_death13); }
void drole_death11(entity this) { set_animofs(this, anim_drole_death, 11, drole_death12); }
void drole_death10(entity this) { set_animofs(this, anim_drole_death, 10, drole_death11); }
void drole_death9(entity this) { set_animofs(this, anim_drole_death, 9, drole_death10); }
void drole_death8(entity this) { set_animofs(this, anim_drole_death, 8, drole_death9); }
void drole_death7(entity this) { set_animofs(this, anim_drole_death, 7, drole_death8); }
void drole_death6(entity this) { set_animofs(this, anim_drole_death, 6, drole_death7); }
void drole_death5(entity this) { set_animofs(this, anim_drole_death, 5, drole_death6); }
void drole_death4(entity this) { set_animofs(this, anim_drole_death, 4, drole_death5); }
void drole_death3(entity this) { set_animofs(this, anim_drole_death, 3, drole_death4); }
void drole_death2(entity this) { set_animofs(this, anim_drole_death, 2, drole_death3); }
void drole_death1(entity this) { set_animofs(this, anim_drole_death, 1, drole_death2); this.solid = SOLID_NOT; }

void drole_die(entity this, entity inflictor, entity attacker, int deathtype)
{
// check for gib
	if(this.health < -50)
	{
		// custom gib function reused for death
		drole_explode(this, inflictor, true);
		return;
	}

// regular death
	_sound(this, CH_VOICE, "drole/death.wav", 1, ATTN_NORM);
	drole_death1(this);
}

/*======================================================================
 DroleCheckAttack
======================================================================*/
bool DroleCheckAttack(entity this)
{
	//----------------------------------------------------------------------
	// Quoth setup - 500HP, with rage at 350HP
	// Converted it to a % so mappers can change health
	//----------------------------------------------------------------------
	if(this.movespeed >= 0)
	{
		if(this.health < this.max_health*0.7 && !this.attack_rage)
		{
			this.attack_rage = true;
			return true;
		}
	}
	//----------------------------------------------------------------------
	// Melee attack (claws)
	//----------------------------------------------------------------------
	if(ai_checkmelee(this, 150, 64))
	{
		this.attack_state = AS_MELEE;
		return true;
	}
		
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

	//----------------------------------------------------------------------
	// If setup to be a turret, check range attack only
	//----------------------------------------------------------------------
	if(this.movespeed < 0)
	{
		// Keep firing rockets when at range
		this.attack_finished = time + 1 + 2 * random();
		this.attack_state = AS_MISSILE;
		return true;
	}
	//----------------------------------------------------------------------
	// RAGE mode (keep running at player)
	//----------------------------------------------------------------------
	if(this.attack_rage)
	{
		this.attack_state = AS_STRAIGHT;
		// Check range and sight for a low chance range attack
		if(vdist(this.enemy.origin, >, 300) && random() < 0.3)
		{
			// Does the monster have a clear shot to the player?
			// sightline can be blocked by other monsters
			// Plasma bolt attack
			this.attack_finished = time + 2 + 2 * random();
			this.attack_state = AS_MISSILE;
		}
	}	
	//----------------------------------------------------------------------
	// PASSIVE mode (keep at distance)
	//----------------------------------------------------------------------
	else
	{
		// Is the player NOT visible? Keep getting closer
		if(!this.enemy_visible)
			this.attack_state = AS_STRAIGHT;
		else
		{
			if(time < this.attack_finished)
			{
				if(vdist(this.enemy.origin, >, 300) && random() < 0.15)
				{
					this.attack_sidedeny = time + 1 + random();
					this.attack_state = AS_STRAIGHT;
				}
				else if(this.attack_sidedeny < time)
					this.attack_state = AS_DODGING;
				return true;
			}
			else
			{
				this.attack_finished = time + 1 + 2 * random();
				this.attack_state = AS_MISSILE;
			}	
		}
	}
	return true;
}

/*======================================================================
QUAKED monster_drole (1 0 0) (-32 -32 -24) (32 32 64) Ambush
======================================================================*/
spawnfunc(monster_drole) { monster_start(this, true, MON_DROLE); }
#endif // SVQC

#ifdef SVQC
METHOD(Drole, mr_setup, bool(Drole this, entity actor))
{
    TC(Drole, this);

	precache_model("progs/gib_drolearm1.mdl");
	precache_model("progs/gib_drolearm2.mdl");
	precache_model("progs/gib_droleleg1.mdl");
	precache_model("progs/proj_drole.mdl");
	precache_model("progs/proj_drolegrn.mdl");

	precache_sound("drole/idle.wav");
	precache_sound("drole/enrage.wav");
	precache_sound("drole/death.wav");
	precache_sound("drole/pain.wav");
	precache_sound("drole/fire.wav");
	precache_sound("drole/r_explode.wav");
	precache_sound("drole/strike1.wav");
	precache_sound("drole/strike2.wav");
	precache_sound("drole/swipe.wav");

    actor.health = 500;
    actor.th_stand = drole_standC1;
	actor.th_walk = drole_walk1;
	actor.th_run = drole_run;
	actor.th_melee = drole_melee;
	actor.th_missile = drole_magic1;
	actor.th_pain = drole_pain;
	actor.th_die = drole_die;

	actor.checkattack = DroleCheckAttack;

	actor.steptype = FS_TYPEHEAVY;

    return true;
}
#endif
