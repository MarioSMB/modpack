#include "lost_soul.qh"

#ifdef SVQC
const int anim_lost_idle = 0; //'0 5 0'
const int anim_lost_idleB = 6; //'6 11 0'
const int anim_lost_idleF = 12; //'12 17 0'
const int anim_lost_idleleft = 18; //'18 23 0'
const int anim_lost_idleright = 24; //'24 29 0'
const int anim_lost_idleturnl = 30; //'30 35 0'
const int anim_lost_idleturnr = 36; //'36 41 0'
const int anim_lost_charge = 42; //'42 47 0'
const int anim_lost_chew = 48; //'48 53 0'
const int anim_lost_pain = 54; //'54 65 0'
const int anim_lost_grow = 66; //'66 75 0'

const int LOST_IDLE = 0;		// Default state
const int LOST_IDLEB = 1;		// Looking UP
const int LOST_IDLEF = 2;		// Looking DOWN
const int LOST_IDLELEFT = 3;	// Looking left
const int LOST_IDLERIGHT = 4;	// Looking right
const int LOST_TURNLEFT = 5;	// Turning left (not looped)
const int LOST_TURNRIGHT = 6;	// Turning right (not looped)
const int LOST_CHARGE = 7;		// Mouth wide open and charging
const int LOST_MELEE = 8;		// Mouth chomping open/close
const int LOST_PAINB = 9;		// Roll backwards
const int LOST_PAINF = 10;		// Roll forward

// Size of each animation block
const int LOST_ANIMBLOCK = 6;

// Different states and fire particle quantity
const int LOST_STATE_STAND = 2;
const int LOST_STATE_WALK = 4;
const int LOST_STATE_GUARD = 3;
const int LOST_STATE_RUN = 5;
const int LOST_STATE_PAIN = 6;

.int inpain;
.float velocityfriction;
.float lostsoul_bob;
.int exactskin;
.float attack_timer;
.float attack_sidestep;
.float attack_sidedeny;
.bool idlereverse;
.int idlebusy;
.entity lostenemy;			// Lost soul enemy before losing sight
.float losttimer;			// Lost soul idle timer after losing sight
.float lostsearch;			// Lost soul searching for previous enemy

//======================================================================
// Update Lost Souls every frame with velocity movements and glow eyes!
// fstate (see above for animation block details)
//======================================================================
void lost_update(entity this, float fstate)
{
	// If Lost is dead, no more updates
	if(this.health < 1) return;

	// Time for an idle sound? (run only)
	if(this.state == LOST_STATE_RUN && random() > 0.8)
		_sound(this, CH_VOICE, ((random() > 0.5) ? "lostsoul/idle1.wav" : "lostsoul/idle2.wav"), 1, ATTN_IDLE);

	// Update glowing eyes! (skin types = 0,1,2,3,2,1)
	if(this.t_length < time)
	{
		// fire particle quantity linked to AI state
		//particle_explode(this.origin+'0 0 12', this.state, 1, PARTICLE_BURST_YELLOW, PARTICLE_BURST_LOSTUP);
		te_explosion2(this.origin + '0 0 12', this.state, 1);
		this.t_length = time + 0.2;
		this.exactskin += 1;
		if(this.exactskin > 5)
			this.exactskin = 0;
		this.skin = this.exactskin;
	}

	// While standing still or guarding, gently float up and down
	if(this.state == LOST_STATE_STAND || this.state == LOST_STATE_GUARD)
	{
		// While standing around idle, gently move up and down
		// using velocity, forced origin movement is really jerky!
		if(this.velocity_x == 0 && this.velocity_y == 0)
		{
			if(this.attack_timer < time)
			{
				this.attack_timer = time + 1;
				if(this.lostsoul_bob < 1)
					this.lostsoul_bob = 1;
				else
					this.lostsoul_bob = -1;
				this.velocity_z = 2 * this.lostsoul_bob;
			}
		}
		else
		{
			// Slowdown the velocity (movement = no friction)
			this.velocity = this.velocity * this.velocityfriction;
			if(this.velocity_x > -5 && this.velocity_x < 5) this.velocity_x = 0;
			if(this.velocity_y > -5 && this.velocity_y < 5) this.velocity_y = 0;
			if(this.velocity_z > -5 && this.velocity_z < 5) this.velocity_z = 0;
		}
	}

	// Lost sight of enemy during combat, wait and look around
	if(this.state == LOST_STATE_GUARD)
	{
		if(this.meleeattack < time)
		{
			this.meleeattack = time + 4 + (random() + random() + random() * 4);
			if(random() < 0.5)
				this.lefty = 1;
			else
				this.lefty = -1;
			this.avelocity = '0 0 0';
			this.avelocity_y = this.lefty*50;
			this.attack_sidestep = 0;
			this.attack_sidedeny = rint(4 + random()*4);
		}
		
		// Keep increasing rotation angle velocity
		this.attack_sidestep += 1;
		if(this.attack_sidestep > this.attack_sidedeny)
			this.avelocity = '0 0 0';
		else
			this.avelocity_y = this.avelocity_y * 1.25;
		
		// Check lost idle timer after combat
		if(this.lostenemy && this.losttimer < time && this.losttimer != -1)
		{
			this.losttimer = -1;
			if(this.lostenemy.health < 0)
				this.lostenemy = NULL;
			else
			{
				// Restore previous enemy and start hunting
				this.enemy = this.lostenemy;
				this.state = LOST_STATE_RUN;
				// Setup goals and DO NOT warn other monsters
				HuntTarget(this);
			}
		}
	}
		
	// Work through all the different AI states
	if(this.state == LOST_STATE_STAND || this.state == LOST_STATE_WALK)
	{
		// At beginning of frame block and reversing?
		if(this.count == 0 && this.idlereverse)
		{
			if(this.idlebusy == LOST_TURNLEFT || this.idlebusy == LOST_TURNRIGHT)
			{
				this.idlebusy = LOST_IDLE;
				this.idlereverse = false;
				this.waitmin = time + 2 + random() * 4;
			}
		}
		// At end of frame block and going forward?
		else if(this.count == LOST_ANIMBLOCK-1 && !this.idlereverse)
		{
			// Always reset turn left/right animation while walking
			if(this.state == LOST_STATE_WALK)
			{
				if(this.idlebusy == LOST_IDLELEFT)
				{
					this.idlebusy = LOST_TURNLEFT;
					this.idlereverse = true;
				}
				else if(this.idlebusy == LOST_IDLERIGHT)
				{
					this.idlebusy = LOST_TURNRIGHT;
					this.idlereverse = true;
				}
				// Return from all other idle animations
				else
				{
					this.idlebusy = LOST_IDLE;
					this.waitmin = time + 2 + random() * 4;
				}
			}
			// Idle animation designed for standing around
			else
			{
				if(this.idlebusy == LOST_IDLE && this.waitmin < time)
				{
					// Randonly pick an idle animation (difference stand/walk)
					float busyanim = random();
					if(busyanim < 0.4) this.idlebusy = LOST_TURNLEFT;
					else if(busyanim < 0.6) this.idlebusy = LOST_TURNRIGHT;
					else if(busyanim < 0.8) this.idlebusy = LOST_IDLEB;
					else this.idlebusy = LOST_IDLEF;
				}
				// Return from opening/closing mouth idle animations
				else if(this.idlebusy == LOST_IDLEB || this.idlebusy == LOST_IDLEF)
				{
					this.idlebusy = LOST_IDLE;
					this.waitmin = time + 2 + random() * 4;
				}
				// Turning head left direction
				else if(this.idlebusy == LOST_TURNLEFT)
				{
					this.idlebusy = LOST_IDLELEFT;
					this.waitmin = time + 2 + random() * 4;
				}
				// Turning head right direction
				else if(this.idlebusy == LOST_TURNRIGHT)
				{
					this.idlebusy = LOST_IDLERIGHT;
					this.waitmin = time + 2 + random() * 4;
				}
				// Looking left and randomly think about returning
				else if(this.idlebusy == LOST_IDLELEFT)
				{
					if(this.waitmin < time && random() < 0.5)
					{
						this.idlebusy = LOST_TURNLEFT;
						this.idlereverse = true;
					}
				}
				// Looking right and randomly think about returning
				else if(this.idlebusy == LOST_IDLERIGHT)
				{
					if(this.waitmin < time && random() < 0.5)
					{
						this.idlebusy = LOST_TURNRIGHT;
						this.idlereverse = true;
					}
				}
			}
		}
	}
	else
	{
		// All other states (RUN, PAIN, GUARD)
		// Reset any previous idle animations
		this.idlereverse = false;
		this.idlebusy = false;
	}
	
	// Check frame direction and update counter
	if(this.idlereverse)
		this.count -= 1;
	else
		this.count += 1;
	if(this.count >= LOST_ANIMBLOCK)
		this.count = 0;
	if(this.count < 0)
		this.count = LOST_ANIMBLOCK - 1;
	
	// Busy with an idle animation?
	if(this.idlebusy > 0)
		fstate = this.idlebusy;
	// Update frame animation block with frame counter
	this.frame = fstate * LOST_ANIMBLOCK + this.count;
	// Store current origin position
	this.oldorigin = this.origin;
}	

//----------------------------------------------------------------------------
void lost_flymode(entity this)
{
	this.solid = SOLID_SLIDEBOX;	// Reset just in case
	set_movetype(this, MOVETYPE_FLY);	// Turn body into projectile
	// make sure onground is not set, cannot use velocity otherwise
	UNSET_ONGROUND(this);
}

//----------------------------------------------------------------------------
void lost_stepmode(entity this)
{
	this.velocity = '0 0 0';			// Back to regular movement
	this.avelocity = '0 0 0';			// Cancel any rotation velocity
	this.angles_x = this.angles_z = 0;	// Reset any X/Y angles
	this.solid = SOLID_SLIDEBOX;		// Always reset
	set_movetype(this, MOVETYPE_STEP);		// Back to discreet movement
}

//======================================================================
// All stand, walk and run functions are condensed down to one entry
// so that the lost souls can move dynamic and have skin updates
//
void lost_stand1(entity this)
{
	set_animofs(this, anim_lost_idle, 1, lost_stand1);
	if(this.state != LOST_STATE_GUARD)
		this.state = LOST_STATE_STAND;	
	lost_flymode(this);				// allow velocity updates
	lost_update(this, LOST_IDLE);		// Update skin + velocity
	ai_stand(this);
}
void lost_guard1(entity this) { this.state = LOST_STATE_GUARD; lost_stand1(this); }

void lost_walk1(entity this)
{
	set_animofs(this, anim_lost_idle, 1, lost_walk1);
	this.state = LOST_STATE_WALK;
	lost_stepmode(this);			// back to discreet step mode
	lost_update(this, LOST_IDLE); 	// Update skin
	ai_walk(this, 8);
}
void lost_run1(entity this)
{
	set_animofs(this, anim_lost_idle, 1, lost_run1);
	this.state = LOST_STATE_RUN;
	lost_stepmode(this);			// back to discreet step mode
	lost_update(this, LOST_IDLE);		// Update skin
	ai_run(this, 8);
}

//============================================================================
// Range Charge attack
//============================================================================
void lost_charge_touch(entity this, entity toucher)
{
	// Stop anymore touching
	settouch(this, func_null);
	setthink(this, this.th_run);
	this.nextthink = time + 0.1;
	
	// Do not damage other souls with charge attacks
	// Prevents packs from killing themselves
	if(toucher.monsterdef != this.monsterdef && toucher.takedamage)
	{
		T_Damage(toucher, this, this, 10, DEATH_MONSTER_LOSTSOUL.m_id);
		spawn_touchblood(this, 10 * 3, toucher);

		// If touched a player, nudge them backwards
		if(IS_PLAYER(toucher)) 
		{
			this.lostsearch = false;
			makevectors(this.angles);
			toucher.velocity = toucher.velocity + (v_forward * 200 + '0 0 50');
		}
	}
}

void lost_charge2(entity this);
void lost_charge1(entity this)
{
	// Play hiss sound, sighted enemy, charging
	_sound(this, CH_WEAPON_SINGLE, "lostsoul/charge.wav", 1, ATTN_NORM);	
	
	this.count = 0;				// reset start of animation block
	lost_flymode(this);				// allow velocity updates
	lost_update(this, LOST_CHARGE);	// Update skin
	// Stop tracking if easy/normal skill 
	if(autocvar_skill < 2)
		this.lostsearch = false;

	this.cnt = 0;									// reset speed updates
	this.pos1 = this.enemy.origin + '0 0 12';	// Aim towards head
	this.pos2 = normalize(this.pos1 - this.origin);	// Vector direction
	settouch(this, lost_charge_touch);					// Damage/end function
	this.velocity = this.pos2 * 400;	// Launch body missile!
	this.angles = vectoangles(this.velocity);		// Turn straight away
	
	setthink(this, lost_charge2);
	this.nextthink = time + 0.1;
}

void lost_charge2(entity this)
{
	if(this.health < 1) return;
	lost_update(this, LOST_CHARGE);
	this.nextthink = time + 0.1;
	
	this.cnt = this.cnt + 1;						// speed updates
	if(this.cnt > 12)
		setthink(this, this.th_run);	// End of charge attack
	// Keep travelling forward regardless of enemy
	else
	{
		// Keep increasing speed every 0.1s (check for max speed)
		float myspeed = vlen(this.velocity);
		if(myspeed < 800)
			myspeed += 50;
		this.velocity = this.pos2 * myspeed;
		setthink(this, lost_charge2);
	}
}

//======================================================================
// MELEE ATTACK - Biting
//======================================================================
void lost_bite(entity this)
{
	if(!this.enemy) return;
	if(this.health < 1) return;
		
	ai_charge(this, 10);							// Get closer for extra bite
	//ai_damagebreakable(this, 10);					// Damage any breakables
	if(!ai_checkmelee(this, 60, 0))
		return;	// Too far away

	// Can the target bleed?
	if(!this.enemy.takedamage)
		return;

	_sound(this, CH_WEAPON_SINGLE, "lostsoul/bite.wav", 1, ATTN_NORM);

	// Lost Soul bite is very weak
	float ldmg = (random() + random() + random()) * 3;
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_LOSTSOUL.m_id);

	// Spawn blood at mouth of Lost Soul
	spawn_touchblood(this, ldmg * 3, this.enemy);
}

//----------------------------------------------------------------------------
void lost_melee2(entity this)
{
	if(this.health < 1) return;
	lost_update(this, LOST_MELEE);	// Update skin
	this.cnt += 1;	// Next frame
	
	// Check for bite attack
	if(this.cnt == 3)
		lost_bite(this);

	// End of melee attack?
	if(this.cnt >= 5)
	{
		// One chop of the jaws and then fly away time
		setthink(this, this.th_run);
		
		// Check if enemy is still within range for another chop!
//		if(ai_checkmelee(MONAI_MELEELOSTSOUL,false) && SUB_healthEnemyTarget() > 0)
//			this.think = this.th_melee;
//		else this.think = this.th_run;
	}
	else
		setthink(this, lost_melee2);
	this.nextthink = time + 0.1;
}

//----------------------------------------------------------------------------
void lost_melee1(entity this)
{
	this.count = 0;				// reset start of animation block
	this.cnt = 0;				// Reset bite frame counter
	lost_flymode(this);				// stay in flymode just in case collison probs
	lost_update(this, LOST_MELEE);	// Update skin

	setthink(this, lost_melee2);
	this.nextthink = time + 0.1;
}

//======================================================================
// MINION - Grow and spin up from nothing
//======================================================================
void lost_growangle(entity this)
{
	this.angles_y += this.lefty;
}

void lost_pain(entity this, entity attacker, float damage, int deathtype);
void lost_grow10(entity this)
{
	set_animofs(this, anim_lost_grow, 10, lost_run1);
	// Is the lost stuck? cannot move?
	if(pointcontents(this.origin) == CONTENT_SOLID)
	{
		// Time to die!
		this.health = -30;
		Killed(this, this, this, DEATH_CRUSH.m_id);
	}
	else
	{
		this.state = LOST_STATE_RUN;
		this.count = 0;
		lost_update(this, LOST_IDLE);		// Update skin

		// Finally spin back to original position
		this.angles_y = this.angles_y + this.lefty;
		// Setup goals and warn other monsters
		if(this.enemy)
			FoundTarget(this);

		// Restore all think state functions
		this.th_stand = lost_stand1;
		this.th_walk = lost_walk1;
		this.th_run = lost_run1;
		this.th_melee = lost_melee1;
		this.th_missile = lost_charge1;
		this.th_pain = lost_pain;
		
		// Start charging at player if not dead and got an enemy
		if(this.health > 0 && this.enemy)
		{
			ai_face(this);
			setthink(this, this.th_missile);
		}
	}
}
void lost_grow9(entity this) { set_animofs(this, anim_lost_grow, 9, lost_grow10); lost_growangle(this); }
void lost_grow8(entity this) { set_animofs(this, anim_lost_grow, 8, lost_grow9); lost_growangle(this); }
void lost_grow7(entity this) { set_animofs(this, anim_lost_grow, 7, lost_grow8); lost_growangle(this); }
void lost_grow6(entity this) { set_animofs(this, anim_lost_grow, 6, lost_grow7); lost_growangle(this); }
void lost_grow5(entity this) { set_animofs(this, anim_lost_grow, 5, lost_grow6); lost_growangle(this); }
void lost_grow4(entity this) { set_animofs(this, anim_lost_grow, 4, lost_grow5); lost_growangle(this); }
void lost_grow3(entity this) { set_animofs(this, anim_lost_grow, 3, lost_grow4); lost_growangle(this); }
void lost_grow2(entity this) { set_animofs(this, anim_lost_grow, 2, lost_grow3); lost_growangle(this); }
void lost_grow1(entity this) { set_animofs(this, anim_lost_grow, 1, lost_grow2); }

//----------------------------------------------------------------------------
void lost_grow(entity this)
{
	// Only call wakeup function once
	this.th_stand = this.th_walk = this.th_run = func_null;
	this.th_pain = func_null;
	if(random() < 0.5)
		this.lefty = 36;
	else
		this.lefty = -36;
	lost_stepmode(this);
	lost_grow1(this);
}

//============================================================================
// PAIN in the head!
//============================================================================
void lost_inpain(entity this)
{
	// Update pain frame
	lost_update(this, this.attack_rage);
	
	// Next pain animation
	this.inpain += 1;
	if(this.inpain >= 5)
		setthink(this, this.th_run);
	else
		setthink(this, lost_inpain);
	this.nextthink = time + 0.1;
}

//----------------------------------------------------------------------
void lost_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.state != LOST_STATE_PAIN)
	{
		// Stop all velocity and reset movetype
		lost_stepmode(this);
		_sound(this, CH_VOICE, "lostsoul/pain1.wav", 1, ATTN_NORM);
	}

	// Work out which direction the damage came from (enemy)
	if(infront(this, attacker))
		this.attack_rage = LOST_PAINB;	// Hit from infront
	else
		this.attack_rage = LOST_PAINF;						// Hit from behind
	
	this.state = LOST_STATE_PAIN;
	// Reset pain and current frame counter
	this.inpain = this.count = 0;
	// Always do pain, no flinch
	lost_inpain(this);
}

void lost_die2(entity this)
{
	set_animofs(this, anim_lost_pain, 2, lost_die2);
	// Lost souls explode when they die
	T_RadiusDamage(this, this, 40, DEATH_MONSTER_LOSTSOUL.m_id, NULL);
	int expl = EXPLODE_BIG;
	if(random() < 0.5)
		expl = EXPLODE_SMALL;
	else if(random() < 0.9)
		expl = EXPLODE_MED;
	SpawnExplosion(expl, this.origin, "lostsoul/death.wav");
	// Goto final resting place
	delete(this);
}
void lost_die1(entity this) { set_animofs(this, anim_lost_pain, 1, lost_die2); }

void lost_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	// Make sure body does not drop to the ground
	this.flags |= FL_FLY;
	this.takedamage = DAMAGE_NO;
	lost_die1(this);
}

/*======================================================================
 LostCheckAttack
======================================================================*/
bool LostCheckAttack(entity this)
{
	if(ai_checkmelee(this, 60, 0))
	{
		this.attack_state = AS_MELEE;
		return true;
	}

	if(time < this.attack_finished)
		return false;

	if(!this.enemy_visible)
	{
		if(!this.lostsearch && !(this.flags & FL_CLONE))
		{
			this.lostsearch = true;
			this.lostenemy = this.enemy;
			this.losttimer = time + 15 + random() * 5;
			this.enemy = this.goalentity = this.movetarget = NULL;
			lost_guard1(this);
		}
		return false;
	}

	entity targ = this.enemy;
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;
	traceline(spot1, spot2, false, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
		return false;	// don't have a clear shot

	//----------------------------------------------------------------------
	// Range attack (Ramming Speed)
	//----------------------------------------------------------------------
	// Only range attack if cooldown has finished
	if(time > this.attack_finished)
	{
		if(this.enemy_range != RANGE_MELEE)
			this.attack_finished = time + (2 + random());
		this.attack_state = AS_MISSILE;
		return true;
	}

	if(this.enemy_range >= RANGE_MID)
		this.attack_state = AS_STRAIGHT;
	else
		this.attack_state = AS_SLIDING;

	return true;
}

/*======================================================================
QUAKED monster_lostsoul (1 0.2 0) (-16 -16 -24) (16 16 24)
======================================================================*/
spawnfunc(monster_lostsoul) { monster_start(this, true, MON_LOSTSOUL); }
#endif // SVQC

#ifdef SVQC
METHOD(LostSoul, mr_setup, bool(LostSoul this, entity actor))
{
    TC(LostSoul, this);

	precache_sound("lostsoul/pain1.wav");
	precache_sound("lostsoul/idle1.wav");
	precache_sound("lostsoul/idle2.wav");
	precache_sound("lostsoul/charge.wav");		// charge hiss/scream
	precache_sound("lostsoul/bite.wav");		// chomp with teeth
	precache_sound("lostsoul/death.wav");

    actor.health = 30;
	actor.th_pain = lost_pain;
	actor.th_die = lost_die;
	if(actor.velocityfriction <= 0)
		actor.velocityfriction = 0.8 + (random() * 0.1);

	if(actor.flags & FL_CLONE) // TODO: custom flag
	{
		actor.th_stand = actor.th_walk = actor.th_run = lost_grow;
		actor.th_missile = func_null;
	}
	else
	{
		this.th_stand = lost_stand1;
		this.th_walk = lost_walk1;
		this.th_run = lost_run1;
		this.th_melee = lost_melee1;
		this.th_missile = lost_charge1;
	}

	actor.checkattack = LostCheckAttack;

    return true;
}
#endif
