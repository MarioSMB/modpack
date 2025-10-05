#include "minotaur.qh"

#include "gargoyle.qh"

/*==============================================================================
MINOTAUR (Hexen2 model by Raven Software) (The Shuffler from Marcher MOD)
also known as "The Nethergoat: Spawnmaster of the Elder World"
==============================================================================*/

#ifdef SVQC
const int anim_minotaur_bwalk = 0; //'0 23 0'
const int anim_minotaur_charge = 24; //'24 35 0'
const int anim_minotaur_death = 36; //'36 60 0'
const int anim_minotaur_gore = 61; //'61 72 0'
const int anim_minotaur_howl = 73; //'73 108 0'
const int anim_minotaur_jump = 109; //'109 132 0'
const int anim_minotaur_pain = 133; //'133 140 0'
const int anim_minotaur_shake = 141; //'141 160 0'
const int anim_minotaur_magic = 161; //'161 192 0'
//const int anim_minotaur_slideL = 193; //'193 197 0'
//const int anim_minotaur_slideR = 198; //'198 202 0'
const int anim_minotaur_stand = 203; //'203 226 0'
const int anim_minotaur_walk = 227; //'227 250 0'

// Spawning effect for projectiles has several skin colours
const int MINO_BLUE = 0;
const int MINO_GREEN = 1;
const int MINO_RED = 2;

const int MON_MINOTAUR_MINIONS = 4;

.bool minotaur_summonflag;

.entity attachment;
.entity attachment2;

void mino_stand1(entity this);
void mino_walk1(entity this);
void mino_run(entity this);
void mino_jump10(entity this);
void mino_jump1(entity this);
void mino_jump4(entity this);
void mino_charge1(entity this);

//============================================================================
void mino_stand12(entity this) { set_animofs(this, anim_minotaur_stand, 23, mino_stand1); ai_stand(this); }
void mino_stand11(entity this) { set_animofs(this, anim_minotaur_stand, 21, mino_stand12); ai_stand(this); }
void mino_stand10(entity this) { set_animofs(this, anim_minotaur_stand, 19, mino_stand11); ai_stand(this); }
void mino_stand9(entity this) { set_animofs(this, anim_minotaur_stand, 17, mino_stand10); ai_stand(this); }
void mino_stand8(entity this) { set_animofs(this, anim_minotaur_stand, 15, mino_stand9); ai_stand(this); }
void mino_stand7(entity this) { set_animofs(this, anim_minotaur_stand, 13, mino_stand8); ai_stand(this); }
void mino_stand6(entity this) { set_animofs(this, anim_minotaur_stand, 11, mino_stand7); ai_stand(this); }
void mino_stand5(entity this) { set_animofs(this, anim_minotaur_stand, 9, mino_stand6); ai_stand(this); }
void mino_stand4(entity this) { set_animofs(this, anim_minotaur_stand, 7, mino_stand5); ai_stand(this); }
void mino_stand3(entity this) { set_animofs(this, anim_minotaur_stand, 5, mino_stand4); ai_stand(this); }
void mino_stand2(entity this) { set_animofs(this, anim_minotaur_stand, 3, mino_stand3); ai_stand(this); }
void mino_stand1(entity this)
{
	set_animofs(this, anim_minotaur_stand, 1, mino_stand2);
	ai_stand(this);
	if(random() > 0.8)
		_sound(this, CH_VOICE, ((random() > 0.5) ? "minotaur/idle1.wav" : "minotaur/idle2.wav"), 1, ATTN_IDLE);
}

//============================================================================
void mino_walk12(entity this) { set_animofs(this, anim_minotaur_walk, 23, mino_walk1); ai_walk(this, 9);}
void mino_walk11(entity this) { set_animofs(this, anim_minotaur_walk, 21, mino_walk12); ai_walk(this, 4);}
void mino_walk10(entity this) { set_animofs(this, anim_minotaur_walk, 19, mino_walk11); ai_walk(this, 10); monster_footstep(this, false); }
void mino_walk9(entity this) { set_animofs(this, anim_minotaur_walk, 17, mino_walk10); ai_walk(this, 9);}
void mino_walk8(entity this) { set_animofs(this, anim_minotaur_walk, 15, mino_walk9); ai_walk(this, 12);}
void mino_walk7(entity this) { set_animofs(this, anim_minotaur_walk, 13, mino_walk8); ai_walk(this, 12);}
void mino_walk6(entity this) { set_animofs(this, anim_minotaur_walk, 11, mino_walk7); ai_walk(this, 9);}
void mino_walk5(entity this) { set_animofs(this, anim_minotaur_walk, 9, mino_walk6); ai_walk(this, 4);}
void mino_walk4(entity this) { set_animofs(this, anim_minotaur_walk, 7, mino_walk5); ai_walk(this, 10); monster_footstep(this, false); }
void mino_walk3(entity this) { set_animofs(this, anim_minotaur_walk, 5, mino_walk4); ai_walk(this, 9);}
void mino_walk2(entity this) { set_animofs(this, anim_minotaur_walk, 3, mino_walk3); ai_walk(this, 12);}
void mino_walk1(entity this)
{
	set_animofs(this, anim_minotaur_walk, 1, mino_walk2);
	ai_walk(this, 12);
	if(random() > 0.8)
		_sound(this, CH_VOICE, ((random() > 0.5) ? "minotaur/idle1.wav" : "minotaur/idle2.wav"), 1, ATTN_IDLE);
}

//============================================================================
// Charge/run/gore!
//============================================================================
void mino_rage6(entity this) { set_animofs(this, anim_minotaur_charge, 12, mino_run); ai_run(this, 26); }
void mino_rage5(entity this) { set_animofs(this, anim_minotaur_charge, 10, mino_rage6); ai_run(this, 28); monster_footstep(this, false); }
void mino_rage4(entity this) { set_animofs(this, anim_minotaur_charge, 8, mino_rage5); ai_run(this, 34); }
void mino_rage3(entity this) { set_animofs(this, anim_minotaur_charge, 6, mino_rage4); ai_run(this, 26); }
void mino_rage2(entity this) { set_animofs(this, anim_minotaur_charge, 4, mino_rage3); ai_run(this, 28); monster_footstep(this, false); }
void mino_rage1(entity this)
{
	set_animofs(this, anim_minotaur_charge, 2, mino_rage2);
	ai_run(this, 34);
	if(random() > 0.8)
		_sound(this, CH_VOICE, ((random() > 0.5) ? "minotaur/idle1.wav" : "minotaur/idle2.wav"), 1, ATTN_IDLE);
}

//----------------------------------------------------------------------
void mino_run12(entity this) { set_animofs(this, anim_minotaur_walk, 23, mino_run); ai_run(this, 9); }
void mino_run11(entity this) { set_animofs(this, anim_minotaur_walk, 21, mino_run12); ai_run(this, 4); }
void mino_run10(entity this) { set_animofs(this, anim_minotaur_walk, 19, mino_run11); ai_run(this, 10); monster_footstep(this, false); }
void mino_run9(entity this) { set_animofs(this, anim_minotaur_walk, 17, mino_run10); ai_run(this, 9); }
void mino_run8(entity this) { set_animofs(this, anim_minotaur_walk, 15, mino_run9); ai_run(this, 12); }
void mino_run7(entity this) { set_animofs(this, anim_minotaur_walk, 13, mino_run8); ai_run(this, 12); }
void mino_run6(entity this) { set_animofs(this, anim_minotaur_walk, 11, mino_run7); ai_run(this, 9); }
void mino_run5(entity this) { set_animofs(this, anim_minotaur_walk, 9, mino_run6); ai_run(this, 4); }
void mino_run4(entity this) { set_animofs(this, anim_minotaur_walk, 7, mino_run5); ai_run(this, 10); monster_footstep(this, false); }
void mino_run3(entity this) { set_animofs(this, anim_minotaur_walk, 5, mino_run4); ai_run(this, 9); }
void mino_run2(entity this) { set_animofs(this, anim_minotaur_walk, 3, mino_run3); ai_run(this, 12); }
void mino_run1(entity this)
{
	set_animofs(this, anim_minotaur_walk, 1, mino_run2);
	ai_run(this, 12);
	if(random() > 0.8)
		_sound(this, CH_VOICE, ((random() > 0.5) ? "minotaur/idle1.wav" : "minotaur/idle2.wav"), 1, ATTN_IDLE);
}

//----------------------------------------------------------------------
void mino_run(entity this)
{
	if(this.attack_rage)
		mino_rage1(this);
	else
		mino_run1(this);
}

//----------------------------------------------------------------------
// Short howl animation to switch to rage mode
//----------------------------------------------------------------------
void mino_howl12(entity this) { set_animofs(this, anim_minotaur_howl, 31, mino_run); }
void mino_howl11(entity this) { set_animofs(this, anim_minotaur_howl, 29, mino_howl12); }
void mino_howl10(entity this) { set_animofs(this, anim_minotaur_howl, 27, mino_howl11); }
void mino_howl9(entity this) { set_animofs(this, anim_minotaur_howl, 25, mino_howl10); }
void mino_howl8(entity this) { set_animofs(this, anim_minotaur_howl, 23, mino_howl9); }
void mino_howl7(entity this) { set_animofs(this, anim_minotaur_howl, 21, mino_howl8); }
void mino_howl6(entity this) { set_animofs(this, anim_minotaur_howl, 19, mino_howl7); }
void mino_howl5(entity this) { set_animofs(this, anim_minotaur_howl, 9, mino_howl6); }
void mino_howl4(entity this) { set_animofs(this, anim_minotaur_howl, 7, mino_howl5); }
void mino_howl3(entity this) { set_animofs(this, anim_minotaur_howl, 5, mino_howl4); }
void mino_howl2(entity this) { set_animofs(this, anim_minotaur_howl, 3, mino_howl3); }
void mino_howl1(entity this)
{
	set_animofs(this, anim_minotaur_howl, 1, mino_howl2);
	_sound(this, CH_WEAPON_SINGLE, "minotaur/attack1long.wav", 1, ATTN_NORM);
}

//============================================================================
// MELEE ATTACK (claws)
//============================================================================
void mino_claw(entity this, float side)
{
	if(!this.enemy) return;
	if(this.health < 1) return;
	ai_face(this);						// Turn towards enemy target
	ai_damagebreakable(this, 50);			// Damage any breakables

	if(!this.enemy.takedamage || !ai_checkmelee(this, 100, 64))
	{
		// Melee claw miss sound
		_sound(this, CH_WEAPON_SINGLE, "minotaur/swipe.wav", 1, ATTN_NORM);
	}
	else
	{
		// Melee claw hit sound
		if(this.lefty)
			_sound(this, CH_WEAPON_SINGLE, "minotaur/strike1.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_WEAPON_SINGLE, "minotaur/strike2.wav", 1, ATTN_NORM);
		this.lefty = 1 - this.lefty;
		float ldmg = 12 + 6*random();
		// Rage attack is once per animation frame, more deadly
		if(this.attack_rage)
			ldmg *= 2;
		T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_MINOTAUR.m_id);
		fixedmakevectors(this.angles);
		SpawnMeatSpray(this, this.origin + v_forward*16, side * v_right);
	}
}

//----------------------------------------------------------------------
// Slap LEFT  - 19, 21, 23, 1, 3, 5
// Slap RIGHT - 7, 9, 11, 13, 15, 17
void mino_slapR1(entity this);
void mino_slapL6(entity this) { set_animofs(this, anim_minotaur_bwalk, 5, mino_slapR1); ai_charge(this, 9); }
void mino_slapL5(entity this) { set_animofs(this, anim_minotaur_bwalk, 3, mino_slapL6); ai_charge(this, 12); }
void mino_slapL4(entity this) { set_animofs(this, anim_minotaur_bwalk, 1, mino_slapL5); ai_charge(this, 12); mino_claw(this, -250); }
void mino_slapL3(entity this) { set_animofs(this, anim_minotaur_bwalk, 23, mino_slapL4); ai_charge(this, 9); }
void mino_slapL2(entity this) { set_animofs(this, anim_minotaur_bwalk, 21, mino_slapL3); ai_charge(this, 4); }
void mino_slapL1(entity this) { set_animofs(this, anim_minotaur_bwalk, 19, mino_slapL2); ai_charge(this, 10); monster_footstep(this, false); }

void mino_slapR6(entity this)
{
	set_animofs(this, anim_minotaur_bwalk, 17, mino_run);
	ai_charge(this, 9);
	// Check if enemy is close, alive and visible before doing more melee
	if(random() < 0.5 && this.enemy.health > 0 && ai_checkmelee(this, 100, 64) && visible(this, this.enemy))
		setthink(this, mino_slapL1);
}
void mino_slapR5(entity this) { set_animofs(this, anim_minotaur_bwalk, 15, mino_slapR6); ai_charge(this, 12); }
void mino_slapR4(entity this) { set_animofs(this, anim_minotaur_bwalk, 13, mino_slapR5); ai_charge(this, 12); mino_claw(this, 250); }
void mino_slapR3(entity this) { set_animofs(this, anim_minotaur_bwalk, 11, mino_slapR4); ai_charge(this, 9); }
void mino_slapR2(entity this) { set_animofs(this, anim_minotaur_bwalk, 9, mino_slapR3); ai_charge(this, 4); }
void mino_slapR1(entity this) { set_animofs(this, anim_minotaur_bwalk, 7, mino_slapR2); ai_charge(this, 10); monster_footstep(this, false); }

//----------------------------------------------------------------------
// Rage melee attack
void mino_gore6(entity this) { set_animofs(this, anim_minotaur_gore, 12, mino_run); ai_charge(this, 26); }
void mino_gore5(entity this) { set_animofs(this, anim_minotaur_gore, 10, mino_gore6); ai_charge(this, 28); monster_footstep(this, false); }
void mino_gore4(entity this) { set_animofs(this, anim_minotaur_gore, 8, mino_gore5); ai_charge(this, 34); }
void mino_gore3(entity this) { set_animofs(this, anim_minotaur_gore, 6, mino_gore4); ai_charge(this, 26); mino_claw(this, -250); }
void mino_gore2(entity this) { set_animofs(this, anim_minotaur_gore, 4, mino_gore3); ai_charge(this, 28); monster_footstep(this, false); }
void mino_gore1(entity this) { set_animofs(this, anim_minotaur_gore, 2, mino_gore2); ai_charge(this, 34); }

//----------------------------------------------------------------------
void mino_melee(entity this)
{
	// Switch to a faster more deadly melee attack if in rage mode
	if(this.attack_rage)
		mino_gore1(this);
	else
	{
		// Randomly start left or right and then loop
		if(random() < 0.5)
			mino_slapR1(this);
		else
			mino_slapL1(this);
	}
}

//============================================================================
// JUMP ATTACK - pre-rage only
//============================================================================
void mino_JumpTouch(entity this, entity toucher)
{
	if(this.health < 1)
		return;
	ai_jumpbreakable(this, toucher, 30);			// Damage any breakables
	settouch(this, func_null);			// No more touching
	this.count += 1;	// Total amount of touch jumps
	setthink(this, mino_jump10);	// Exit frame

	if(CanDamage(toucher, this))
	{
		if(vdist(this.velocity, >, 300))
		{
			float ldmg = 20 + 10*random();
			T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_MINOTAUR.m_id);	
			spawn_touchblood(this, ldmg * 3, toucher);
		}
	}

	// Is the minotaur floating in the air?
	if(!t_checkbottom(this))
	{
		// Is the minotaur standing on something?		
		if(IS_ONGROUND(this))
		{	
			// Do an extra jump if got the count
			if(this.count < 2)
				setthink(this, mino_jump1);
		}
	}

	// Next timer
	this.nextthink = time + 0.1;
}

//----------------------------------------------------------------------
void mino_jump12(entity this)
{
	set_animofs(this, anim_minotaur_jump, 23, mino_run);
	ai_charge(this, 10);
	this.angles_x = this.angles_z = 0;
	// If close enough start melee ELSE return to run cycle
	if(this.enemy.health > 0 && ai_checkmelee(this, 100, 64)) 
		setthink(this, mino_melee);
}
void mino_jump10(entity this) { set_animofs(this, anim_minotaur_jump, 19, mino_jump12); ai_charge(this, 8); monster_footstep(this, false); }
void mino_jump8(entity this)
{
	set_animofs(this, anim_minotaur_jump, 15, mino_jump8);
	// Double check monster is still falling?
	if(this.velocity == '0 0 0' || this.oldorigin == this.origin)
	{
		this.ideal_yaw = random() * 360; 	//random jump angle
		setthink(this, mino_jump4);			// Keep jumping
	}
	this.oldorigin = this.origin;
}
void mino_jump7(entity this) { set_animofs(this, anim_minotaur_jump, 13, mino_jump8); ai_face(this);}
void mino_jump6(entity this) { set_animofs(this, anim_minotaur_jump, 11, mino_jump7); }
void mino_jump5(entity this) { set_animofs(this, anim_minotaur_jump, 9, mino_jump6); ai_face(this);}
void mino_jump4(entity this)
{
	set_animofs(this, anim_minotaur_jump, 7, mino_jump5);
	ai_face(this);
	settouch(this, mino_JumpTouch);
	makevectors(this.angles);
	this.velocity = (v_forward*450) + ('0 0 1'*250);
	UNSET_ONGROUND(this);
	this.oldorigin = this.origin;
}
void mino_jump3(entity this) { set_animofs(this, anim_minotaur_jump, 5, mino_jump4); ai_face(this); }
void mino_jump2(entity this) { set_animofs(this, anim_minotaur_jump, 3, mino_jump3); ai_face(this); }
void mino_jump1(entity this)
{
	set_animofs(this, anim_minotaur_jump, 1, mino_jump2);
	// Use combat idle grunt sounds (can get annoying otherwise)
	if(random() < 0.5)
		_sound(this, CH_VOICE, "minotaur/idle1com.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "minotaur/idle2com.wav", 1, ATTN_NORM);
}


//============================================================================
// RANGE ATTACK - Plasma Bolts (rocket)
//============================================================================
int minotaur_skin_type(entity targ)
{
	// Switch skin around for spawning effect
	if(targ.spawnflags & MON_MINOTAUR_MINIONS)
	{
		return (targ.poisonous) ? MINO_GREEN : MINO_RED;
	}
	// Default = blue version
	return MINO_BLUE;
}

//----------------------------------------------------------------------
void minotaur_create_attachment(entity this)
{
	// Are the attachments setup yet?
	if(!this.attachment)
	{
		this.attachment = spawn();
		this.attachment.owner = this;
		this.attachment.classname = "attachment";
		this.attachment.mdl = "progs/proj_minoball.mdl";
	}
	if(!this.attachment2)
	{
		this.attachment2 = spawn();
		this.attachment2.owner = this;
		this.attachment2.classname = "attachment";
		this.attachment2.mdl = "progs/proj_minoball.mdl";
	}
}

//----------------------------------------------------------------------
void minotaur_finish_attachment(entity this)
{
	if(this.attachment)
	{
		_setmodel(this.attachment, "");
	}
	if(this.attachment2)
	{
		_setmodel(this.attachment2, "");
	}
}

//----------------------------------------------------------------------
void minotaur_remove_attachment(entity this)
{
	if(this.attachment)
	{
		setthink(this.attachment, SUB_Remove);
		this.attachment.nextthink = time + 0.1;
	}
	this.attachment = NULL;
	if(this.attachment2)
	{
		setthink(this.attachment2, SUB_Remove);
		this.attachment2.nextthink = time + 0.1;
	}
	this.attachment2 = NULL;
}

//----------------------------------------------------------------------
void minotaur_handball(entity this, entity handent, vector orgofs, float dbframe)
{
	// Frame 0 is start of the sequence (move everything into place)
	if(dbframe == 0)
	{
		setorigin(handent, this.origin);
		_setmodel(handent, handent.mdl);
		setsize(handent, '0 0 0', '0 0 0');
		set_movetype(handent, MOVETYPE_NONE);
		handent.solid = SOLID_NOT;
		// Switch skin around for spawning effect
		handent.skin = minotaur_skin_type(this);
		handent.alpha = 0.85;
	}
	
	// Generate attachment in hand (left)
	// makevectors set in previous function (minotaur_hands)
	vector org = this.origin + attack_vector(orgofs);
	setorigin(handent, org);
	handent.angles_y = rint(random() * 359);
	handent.frame = dbframe;
}

//----------------------------------------------------------------------
// There is a ball for each hand with different origins
//----------------------------------------------------------------------
void minotaur_hands(entity this, vector leftofs, vector rightofs, float dbframe)
{
	if(this.health < 1)
		return;
	
	// Keep turning towards enemy
	ai_face(this);
	makevectors(this.angles);
	
	// Generate a ball in each hand
	minotaur_handball(this, this.attachment, leftofs, dbframe);
	minotaur_handball(this, this.attachment2, rightofs, dbframe);
}

//----------------------------------------------------------------------
// Fire a volley of plasma/poison bolts at the enemy
//----------------------------------------------------------------------
void minotaur_fire(entity this, vector orgofs, float angofs)
{
	if(!this.enemy) return;
	if(this.health < 1) return;

	this.effects |= EF_MUZZLEFLASH;
	
	makevectors(this.angles);
	vector org = this.origin + attack_vector(orgofs);
	vector dir = (this.enemy.origin - org) + (v_right*(angofs*30));
	dir = normalize(dir);

	// The DARK minotaur (spawner) has two types of spikes
	if(this.spawnflags & MON_MINOTAUR_MINIONS)
	{
		entity newmis = launch_spike(this, org, dir);
		newmis.projectiledeathtype = DEATH_MONSTER_MINOTAUR.m_id;
		newmis.poisonous = this.poisonous;
		if(newmis.poisonous)
			_setmodel(newmis, "progs/proj_minopoison.mdl");
		else
			_setmodel(newmis, "progs/proj_minoblood.mdl");
		setsize(newmis, '0 0 0', '0 0 0');
		newmis.velocity = dir * (500 + (autocvar_skill * 150));
	}
	else
	{
		// Projectile behaves like plasma (light/trail/impact effects)
		// The correct projectile model is switched in launch function
		entity plasma = launch_plasma(this, org, dir);
		plasma.projectiledeathtype = DEATH_MONSTER_MINOTAUR.m_id;
		plasma.velocity = dir * (300 + (autocvar_skill * 150));
	}
}

//----------------------------------------------------------------------
// Main projectile plasma/poison attack of both types of minotaur
//----------------------------------------------------------------------
void mino_magic16(entity this) { set_animofs(this, anim_minotaur_magic, 31, mino_run); ai_face(this);}
void mino_magic15(entity this) { set_animofs(this, anim_minotaur_magic, 29, mino_magic16); ai_face(this);}
void mino_magic14(entity this) { set_animofs(this, anim_minotaur_magic, 27, mino_magic15); }
void mino_magic13(entity this)
{
	set_animofs(this, anim_minotaur_magic, 25, mino_magic14);
	// Remove hand attachments and setup particle explosion
	// Create a cloud of particles which slowly raise upwards
	minotaur_finish_attachment(this);
	ai_face(this);
	makevectors(this.angles);
	// Spawn a mist of blue/green particles where projectiles came from
	__pointparticles(_particleeffectnum("shockwave_attack"), this.origin + (v_forward * 44) + (v_up * 32), '0 0 0', 1);
	// Random chance of final growl at player
	if(random() < 0.3)
		_sound(this, CHAN_BODY, "minotaur/attack1end.wav", 1, ATTN_NORM);
}
void mino_magic12(entity this)
{
	set_animofs(this, anim_minotaur_magic, 23, mino_magic13);
	ai_forward(this, 8);
	minotaur_hands(this, '44 0 46','44 2 44',2);
	minotaur_fire(this, '44 0 45',2);
}
void mino_magic11(entity this)
{
	set_animofs(this, anim_minotaur_magic, 21, mino_magic12);
	ai_forward(this, 4);
	monster_footstep(this, false);
	minotaur_hands(this, '28 0 50','28 2 48',3);
	minotaur_fire(this, '28 0 49',1);
}
void mino_magic10(entity this)
{
	set_animofs(this, anim_minotaur_magic, 19, mino_magic11);
	ai_back(this, 4);
	minotaur_hands(this, '20 0 48','20 2 46',4);
	minotaur_fire(this, '20 0 47',0);
}
void mino_magic9(entity this)
{
	set_animofs(this, anim_minotaur_magic, 17, mino_magic10);
	ai_back(this, 8);
	minotaur_hands(this, '32 -2 44','32 2 44',5);
	minotaur_fire(this, '32 0 44',-1);
}
void mino_magic8(entity this)
{
	set_animofs(this, anim_minotaur_magic, 15, mino_magic9); 
	_sound(this, CH_WEAPON_SINGLE, "minotaur/bolt_fire.wav", 1, ATTN_NORM);
	minotaur_hands(this, '40 -3 46','40 1 44',6);
	minotaur_fire(this, '40 0 45',-2);
}
void mino_magic7(entity this) { set_animofs(this, anim_minotaur_magic, 13, mino_magic8); minotaur_hands(this, '36 -20 56','24 32 68',5); }
void mino_magic6(entity this) { set_animofs(this, anim_minotaur_magic, 11, mino_magic7); minotaur_hands(this, '16 -36 72','-12 44 80',4); }
void mino_magic5(entity this) { set_animofs(this, anim_minotaur_magic, 9, mino_magic6); minotaur_hands(this, '0 -40 80','-10 48 76',3); }
void mino_magic4(entity this) { set_animofs(this, anim_minotaur_magic, 7, mino_magic5); minotaur_hands(this, '15 -16 88','-10 56 48',2); }
void mino_magic3(entity this) { set_animofs(this, anim_minotaur_magic, 5, mino_magic4); minotaur_hands(this, '30 -12 64','-20 44 28',1); }
void mino_magic2(entity this) { set_animofs(this, anim_minotaur_magic, 3, mino_magic3); minotaur_hands(this, '34 0 44','-20 30 20',0); }
void mino_magic1(entity this)
{
	set_animofs(this, anim_minotaur_magic, 1, mino_magic2);
	ai_face(this);
	if(random() < 3)
		_sound(this, CHAN_BODY, "minotaur/attack1start.wav", 1, ATTN_NORM);
}

//----------------------------------------------------------------------
// Spawn particles from body that float upwards during summons
//----------------------------------------------------------------------
void mino_sumeffect(entity this)
{
	__pointparticles(_particleeffectnum("TE_PLASMABURN"), this.origin + '0 0 64', '0 0 0', 1);
}

//----------------------------------------------------------------------
// Display a ball where the gargoyle is spawning
//----------------------------------------------------------------------
void mino_sumball(entity this, float dbframe)
{
	// Double check the space checks worked
	if(!this.minotaur_summonflag)
		return;
	
	// Frame 0 is start of the sequence (move everything into place)
	if(dbframe == 0)
	{
		setorigin(this.attachment, this.pos2);
		_setmodel(this.attachment, this.attachment.mdl);
		setsize(this.attachment, '0 0 0', '0 0 0');
		set_movetype(this.attachment, MOVETYPE_NONE);
		this.attachment.solid = SOLID_NOT;
		this.attachment.skin = minotaur_skin_type(this);
	}
	
	// rotate and fade the ball as it grows
	this.attachment.angles_y = rint(random()*359);
	this.attachment.frame = dbframe;
	this.attachment.lip = 0.3 + ((7-dbframe) * 0.1);
	this.attachment.alpha = this.attachment.lip;
	//particle_explode(this.pos2, 5+random()*10, 3, this.part_style, PARTICLE_BURST_MINOTAUR);
	if(this.poisonous)
		te_explosion2(this.pos2, 50, 20);
	else if(this.spawnflags & MON_MINOTAUR_MINIONS)
		te_explosion2(this.pos2, 225, 10);
	else
		te_explosion2(this.pos2, 200, 25);
}

//----------------------------------------------------------------------
// Raise up head and howl at the sky and spawn green particles from body
// Always check if there is space to spawn a gargoyle first
// Block monster pain function so that the summons is completed
//----------------------------------------------------------------------
void mino_summon18(entity this) { set_animofs(this, anim_minotaur_howl, 35, mino_run); ai_face(this); this.attack_finished = time + (1 + 2*random()); }
void mino_summon17(entity this) { set_animofs(this, anim_minotaur_howl, 33, mino_summon18); ai_face(this);}
void mino_summon16(entity this) { set_animofs(this, anim_minotaur_howl, 31, mino_summon17); }
void mino_summon15(entity this)
{
	set_animofs(this, anim_minotaur_howl, 29, mino_summon16);
	minotaur_finish_attachment(this);
	if(this.minotaur_summonflag)
	{
		if(this.poisonous)
			te_explosion2(this.pos2, 50, 20);
		else if(this.spawnflags & MON_MINOTAUR_MINIONS)
			te_explosion2(this.pos2, 225, 10);
		else
			te_explosion2(this.pos2, 200, 25);
	}
}
void mino_summon14(entity this) { set_animofs(this, anim_minotaur_howl, 27, mino_summon15); mino_sumeffect(this); mino_sumball(this, 7); }
void mino_summon13(entity this) { set_animofs(this, anim_minotaur_howl, 25, mino_summon14); mino_sumeffect(this); mino_sumball(this, 6); }
void mino_summon12(entity this) { set_animofs(this, anim_minotaur_howl, 23, mino_summon13); mino_sumeffect(this); mino_sumball(this, 5); }
void mino_summon11(entity this) { set_animofs(this, anim_minotaur_howl, 21, mino_summon12); mino_sumeffect(this); mino_sumball(this, 4); }
void mino_summon10(entity this) { set_animofs(this, anim_minotaur_howl, 19, mino_summon11); mino_sumeffect(this); mino_sumball(this, 3); }
void mino_summon9(entity this) { set_animofs(this, anim_minotaur_howl, 17, mino_summon10); mino_sumeffect(this); mino_sumball(this, 2); }
void mino_summon8(entity this) { set_animofs(this, anim_minotaur_howl, 15, mino_summon9); mino_sumeffect(this); mino_sumball(this, 1); }
void mino_summon7(entity this)
{
	set_animofs(this, anim_minotaur_howl, 13, mino_summon8);
	mino_sumeffect(this);
	// Find out if there is enough space to spawn a gargoyle
	// Findradius version
	makevectors(this.angles);
	this.pos1 = this.origin + this.view_ofs + v_forward*64 + v_up*32;
	this.minotaur_summonflag = find_minionspace(this.pos1);
	
	// If the spawn locaiton all clear, spawn something!
	if(this.minotaur_summonflag)
	{
		minion_spawn(this, this.pos1, new(monster), MON_GARGOYLE);
		this.pos2 = this.pos1 - '0 0 16';	// Origin of gargoyle
		mino_sumball(this, 0);
	}
}
void mino_summon6(entity this) { set_animofs(this, anim_minotaur_howl, 11, mino_summon7); mino_sumeffect(this); }
void mino_summon5(entity this) { set_animofs(this, anim_minotaur_howl, 9, mino_summon6); mino_sumeffect(this); }
void mino_summon4(entity this) { set_animofs(this, anim_minotaur_howl, 7, mino_summon5); mino_sumeffect(this); }
void mino_summon3(entity this)
{
	set_animofs(this, anim_minotaur_howl, 5, mino_summon4);
	ai_face(this);
	mino_sumeffect(this);
	_sound(this, CHAN_BODY, "minotaur/attack1long.wav", 1, ATTN_NORM);
}
void mino_summon2(entity this) { set_animofs(this, anim_minotaur_howl, 3, mino_summon3); ai_face(this); }
void mino_summon1(entity this) { set_animofs(this, anim_minotaur_howl, 1, mino_summon2); ai_face(this); this.pain_finished = time + 2; }

//----------------------------------------------------------------------
// Both type of minotaurs go through the same magic function
//----------------------------------------------------------------------
void mino_magic(entity this)
{
	// Make sure the attachments are setup ready
	minotaur_create_attachment(this);
	
	// Is the target the player or monster?
	if(IS_PLAYER(this.enemy))
	{
		if(this.spawnflags & MON_MINOTAUR_MINIONS)
		{
			// has the gargoyle limit been reached?
			if(query_minionactive(this) > 0)
				mino_summon1(this);
			else
				mino_magic1(this);
		}
		// White Minotaur attacks with plasma
		else
			mino_magic1(this);
		
	}
	// Always attack monsters with plasma/poison projectiles
	else
		mino_magic1(this);
}

//============================================================================
// CHARGE ATTACK - just been hit with a long pain animation (pre-rage only)
//============================================================================
void mino_chargecheck(entity this, float dist)
{
	// turn, face and pursue enemy
	ai_charge(this, dist);
	// Close enough for melee combat?
	if(this.th_melee && ai_checkmelee(this, 100, 64))
		this.th_melee(this);
	// Enemy dead? run out of stamina or enemy not infront?
	if(this.enemy.health < 1 ||  this.attack_finished < time || !infront(this, this.enemy))
		setthink(this, mino_run);
}

//----------------------------------------------------------------------
void mino_charge6(entity this) { set_animofs(this, anim_minotaur_charge, 11, mino_charge1); mino_chargecheck(this, 26); }
void mino_charge5(entity this) { set_animofs(this, anim_minotaur_charge, 9, mino_charge6); mino_chargecheck(this, 28); monster_footstep(this, false); }
void mino_charge4(entity this) { set_animofs(this, anim_minotaur_charge, 7, mino_charge5); mino_chargecheck(this, 34); }
void mino_charge3(entity this) { set_animofs(this, anim_minotaur_charge, 5, mino_charge4); mino_chargecheck(this, 26); }
void mino_charge2(entity this) { set_animofs(this, anim_minotaur_charge, 3, mino_charge3); mino_chargecheck(this, 28); monster_footstep(this, false); }
void mino_charge1(entity this) { set_animofs(this, anim_minotaur_charge, 1, mino_charge2); mino_chargecheck(this, 34); }

//----------------------------------------------------------------------
void mino_charge(entity this)
{
	this.ideal_yaw = vectoyaw(this.enemy.origin - this.origin);
	this.attack_finished = time + 2 + random();
	mino_charge1(this);
}

//============================================================================
// (133) Quick pain flinch backward
void mino_pain8(entity this) { set_animofs(this, anim_minotaur_pain, 8, mino_run); }
void mino_pain7(entity this) { set_animofs(this, anim_minotaur_pain, 7, mino_pain8); }
void mino_pain6(entity this) { set_animofs(this, anim_minotaur_pain, 6, mino_pain7); }
void mino_pain5(entity this) { set_animofs(this, anim_minotaur_pain, 5, mino_pain6); }
void mino_pain4(entity this) { set_animofs(this, anim_minotaur_pain, 4, mino_pain5); }
void mino_pain3(entity this) { set_animofs(this, anim_minotaur_pain, 3, mino_pain4); }
void mino_pain2(entity this) { set_animofs(this, anim_minotaur_pain, 2, mino_pain3); }
void mino_pain1(entity this) { set_animofs(this, anim_minotaur_pain, 1, mino_pain2); }

//----------------------------------------------------------------------
// (141) Stationary - shake head/arms
// Block the pain and then start charging like crazy
void mino_shake10(entity this)
{
	set_animofs(this, anim_minotaur_shake, 19, mino_run);
	// If pre-rage and can see enemy, start chasing
	if(!this.attack_rage && infront(this, this.enemy))
		setthink(this, mino_charge);
}
void mino_shake9(entity this) { set_animofs(this, anim_minotaur_shake, 17, mino_shake10); }
void mino_shake8(entity this) { set_animofs(this, anim_minotaur_shake, 15, mino_shake9); }
void mino_shake7(entity this) { set_animofs(this, anim_minotaur_shake, 13, mino_shake8); }
void mino_shake6(entity this) { set_animofs(this, anim_minotaur_shake, 11, mino_shake7); }
void mino_shake5(entity this) { set_animofs(this, anim_minotaur_shake, 9, mino_shake6); }
void mino_shake4(entity this) { set_animofs(this, anim_minotaur_shake, 7, mino_shake5); }
void mino_shake3(entity this) { set_animofs(this, anim_minotaur_shake, 5, mino_shake4); }
void mino_shake2(entity this) { set_animofs(this, anim_minotaur_shake, 3, mino_shake3); }
void mino_shake1(entity this) { set_animofs(this, anim_minotaur_shake, 1, mino_shake2); this.pain_finished = time + 2;}

//----------------------------------------------------------------------
void mino_pain(entity this, entity attacker, float damage, int deathtype)
{
	// Check all pain conditions and set up what to do next
	if(this.health <= 0)
		return;		// allready dying, don't go into pain frame

	if(random()*200 > damage)
		return;		// didn't flinch

	if(this.pain_finished > time)
		return;

	this.pain_finished = time + 2;
	minotaur_finish_attachment(this);

	// Any pain animation/sound required?
	float r = random();
	if(r < 0.5)
		_sound(this, CH_VOICE, "minotaur/pain1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "minotaur/pain2.wav", 1, ATTN_NORM);

	if(this.spawnflags & MON_MINOTAUR_MINIONS)
		mino_pain1(this);
	else
	{
		if(r < 0.4)
			mino_pain1(this);
		else
			mino_shake1(this);
	}
}

//============================================================================
void mino_death14(entity this) { set_animofs(this, anim_minotaur_death, 25, mino_death14); CorpseThink(this); }
void mino_death13(entity this) { set_animofs(this, anim_minotaur_death, 25, mino_death14); }
void mino_death12(entity this) { set_animofs(this, anim_minotaur_death, 23, mino_death13); ai_forward(this, 4); }
void mino_death11(entity this) { set_animofs(this, anim_minotaur_death, 21, mino_death12); ai_forward(this, 7); }
void mino_death10(entity this) { set_animofs(this, anim_minotaur_death, 19, mino_death11); ai_forward(this, 4); }
void mino_death9(entity this) { set_animofs(this, anim_minotaur_death, 17, mino_death10); ai_forward(this, 8); }
void mino_death8(entity this) { set_animofs(this, anim_minotaur_death, 15, mino_death9); ai_forward(this, 10); }
void mino_death7(entity this) { set_animofs(this, anim_minotaur_death, 13, mino_death8); ai_forward(this, 11); }
void mino_death6(entity this) { set_animofs(this, anim_minotaur_death, 11, mino_death7); ai_forward(this, 11); }
void mino_death5(entity this) { set_animofs(this, anim_minotaur_death, 9, mino_death6); ai_forward(this, 10); }
void mino_death4(entity this) { set_animofs(this, anim_minotaur_death, 7, mino_death5); ai_forward(this, 8); }
void mino_death3(entity this) { set_animofs(this, anim_minotaur_death, 5, mino_death4); ai_forward(this, 4); }
void mino_death2(entity this) { set_animofs(this, anim_minotaur_death, 3, mino_death3); ai_forward(this, 2); }
void mino_death1(entity this) { set_animofs(this, anim_minotaur_death, 1, mino_death2); this.solid = SOLID_NOT; }

//----------------------------------------------------------------------
void mino_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	minotaur_remove_attachment(this);
// check for gib
	if(this.health < -60)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, inflictor, "progs/h_minotaur.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib_minoclaw1.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib_minoclaw2.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib_minoleg1.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib_minoleg2.mdl", this.health);
		return;
	}

// regular death
	_sound(this, CH_VOICE, "minotaur/death.wav", 1, ATTN_NORM);
	mino_death1(this);
}

bool MinotaurCheckAttack(entity this)
{
	//----------------------------------------------------------------------
	// If health is low enough, switch to rage mode
	// This does not affect the minion spawning version
	if(!(this.spawnflags & MON_MINOTAUR_MINIONS) && this.movespeed >= 0)
	{
		if(this.health < this.max_health*0.5 && !this.attack_rage)
		{
			this.attack_rage = true;
			mino_howl1(this);	// Short howl at the sky
			return true;
		}
	}
	//----------------------------------------------------------------------
	// Melee attack (claws)
	//----------------------------------------------------------------------
	if(ai_checkmelee(this, 100, 64))
	{
		this.attack_state = AS_MELEE;
		return true;
	}

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
		// If enemy not infront or random chance, stop and range attack
		if(!infront(this, this.enemy) || random() < 0.1)
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
			//----------------------------------------------------------------------
			// Mid Range attack (JUMP) Not spawning dark version
			//----------------------------------------------------------------------
			if(!(this.spawnflags & MON_MINOTAUR_MINIONS) && random() < 0.35)
			{
				// Jumped recently, facing right direction and not blocked?
				if(this.jump_flag < time && infront(this, this.enemy))
				{
					//if(!visblocked_wide(this.enemy, this.view_ofs, this.enemy.view_ofs))
					{
						// Check for enemy above? (z axis)
						if(this.enemy.origin_z <= this.origin_z)
						{
							// Is the minotaur within the right range?
							// TODO: check horizontally to prevent awkward jumping angles
							if(vdist(this.enemy.origin - this.origin, <, 300))
							{
								// Block any range attacks for a while
								this.attack_finished = time + random();
								this.count = 0;			// Number of times jumped
								mino_jump1(this);
								return true;
							}
						}
					}
				}
			}
			//----------------------------------------------------------------------
			// Range / missile attack (plasma bolts)
			//----------------------------------------------------------------------
			// Any chance of a range attack?
			if(time < this.attack_finished)
			{
				// Calculate a flat vector to ignore Z axis difference
				// Don't always stay at absolute range, move closer
				if(random() < 0.15 && this.enemy_range == RANGE_FAR)
					this.attack_state = AS_STRAIGHT;
			}
			else
			{
				// Does the monster have a clear shot to the player?
				// sightline can be blocked by other monsters
				// Keep firing plasma when at range
				this.attack_finished = time + 2 + 2 * random();
				this.attack_state = AS_MISSILE;
			}
		}
	}
	return true;
}

/*======================================================================
QUAKED monster_minotaur (1 0 0) (-32 -32 -24) (32 32 64) Ambush
======================================================================*/
spawnfunc(monster_minotaur) { monster_start(this, true, MON_MINOTAUR); }

// drake
spawnfunc(monster_yakman) { monster_start(this, true, MON_MINOTAUR); }
spawnfunc(monster_shuffler) { monster_start(this, true, MON_MINOTAUR); }
#endif // SVQC

#ifdef SVQC
METHOD(Minotaur, mr_setup, bool(Minotaur this, entity actor))
{
    TC(Minotaur, this);

	precache_model("progs/gib_minoclaw1.mdl");
	precache_model("progs/gib_minoclaw2.mdl");
	precache_model("progs/gib_minoleg1.mdl");
	precache_model("progs/gib_minoleg2.mdl");
	precache_model("progs/proj_minopoison.mdl");
	precache_model("progs/proj_minoblood.mdl");
	precache_model("progs/proj_minoball.mdl");
	
	precache_sound("minotaur/swipe.wav");		// claw misses
	precache_sound("minotaur/strike1.wav");	// claw hit1
	precache_sound("minotaur/strike2.wav");	// claw hit2

	precache_sound("minotaur/attack1start.wav");	// Short roar
	precache_sound("minotaur/attack1end.wav");		// Short roar
	precache_sound("minotaur/attack1long.wav");	// Enter rage mode
	precache_sound("minotaur/bolt_fire.wav");		// fire projectile
	precache_sound("weapons/plasma_hit.wav");				// impact sounds
	precache_sound("minotaur/death.wav");
	precache_sound("minotaur/pain1.wav");
	precache_sound("minotaur/pain2.wav");
	precache_sound("minotaur/idle1.wav");
	precache_sound("minotaur/idle2.wav");
	precache_sound("minotaur/idle1com.wav");
	precache_sound("minotaur/idle2com.wav");

    actor.health = 500;
	actor.th_stand = mino_stand1;
	actor.th_walk = mino_walk1;
	actor.th_run = mino_run;
	actor.th_melee = mino_melee;
	actor.th_missile = mino_magic;
	actor.th_pain = mino_pain;
	actor.th_die = mino_die;

	if(actor.spawnflags & MON_MINOTAUR_MINIONS)
	{
		if(actor.poisonous < 0)
			actor.poisonous = false;
		else
			actor.poisonous = true;
		actor.skin = 1;
		if(!actor.minion_maxcount)
			actor.minion_maxcount = 3;
	}
	else
		actor.poisonous = false;

	actor.resist_cells = 0.5;
	actor.reflectlightning = true;
	actor.reflectplasma = true;

	actor.steptype = FS_TYPELARGE;

	actor.checkattack = MinotaurCheckAttack;

    return true;
}
#endif

