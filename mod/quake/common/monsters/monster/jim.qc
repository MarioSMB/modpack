#include "scrag.qh"

#ifdef SVQC
const int anim_jim_idle = 0;
const int anim_jim_idleleft = 18;
const int anim_jim_idleright = 24;
const int anim_jim_idleturnl = 30;
const int anim_jim_idleturnr = 36;
const int anim_jim_movedn = 42;
const int anim_jim_moveup = 48;
const int anim_jim_pain = 54;
const int anim_jim_zdeath = 60;

/*==============================================================================
Jim (Heavily inspired by bob from Quoth - Kell/Necros/Preach)
New models, skins and animations, code
==============================================================================*/

const int JS_IDLE = 0;		// Default state
const int JS_IDLE2 = 1;		// Special idle (stationary)
const int JS_IDLE3 = 2;		// Special idle (stationary)
const int JS_IDLELEFT = 3;	// Looking left
const int JS_IDLERIGHT = 4;	// Looking right
const int JS_TURNLEFT = 5;	// Turning left (not looped)
const int JS_TURNRIGHT = 6;	// Turning right (not looped)
const int JS_DOWN = 7;		// Combat move
const int JS_UP = 8;		// Combat move
const int JS_PAIN = 9;		// Resets current animation
const int JS_DYING = 10;	// Final animation

// Size of each animation block
const int JS_ANIMBLOCK = 6;

const int MON_JIM_ROCKET = 4;

.int inpain;

.float idletimer;
.float attack_timer;

.vector attack_track;
.vector pos3;

.float idlebusy;
.float idlereverse;

.float velocityfriction;

/*
=================
jimCheckAttack
=================
*/
bool JimCheckAttack(entity this)
{
	if(time < this.attack_finished)
		return false;
	if(!this.enemy_visible)
		return false;

	if(this.enemy_range == RANGE_FAR)
	{
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
		}
		return false;
	}
		
	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, false, this);

	if(trace_ent != targ)
	{	// don't have a clear shot, so move to a side
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
		}
		return false;
	}

	float chance;	
	if(this.enemy_range == RANGE_MELEE)
		chance = 0.9;
	else if(this.enemy_range == RANGE_NEAR)
		chance = 0.6;
	else if(this.enemy_range == RANGE_MID)
		chance = 0.2;
	else
		chance = 0;

	if(random() < chance)
	{
		this.attack_state = AS_MISSILE;
		return true;
	}

	if(this.enemy_range == RANGE_MID)
	{
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
		}
	}
	else
	{
		if(this.attack_state != AS_SLIDING)
		{
			this.attack_state = AS_SLIDING;
		}
	}
	
	return false;
}

//======================================================================
// Update Jim every frame with skin/sound updates
// fstate (see above for animation block details)
//======================================================================
void jim_update(entity this, float fstate)
{
	// If jim is dead, no more updates
	if(this.health < 1)
		return;

	// Update ther gun idle (buzzing) sound
	if(this.t_width < time)
	{
		this.t_width = time + 0.9;
		_sound(this, CHAN_BODY, "jim/gunidle2.wav", 0.3, 2.3);
	}

	// Time for an idle sound?
	if(this.idletimer < time && random() < 0.2)
	{
		if(random() > 0.5)
			_sound(this, CH_VOICE, "jim/idle1.wav", 1, ATTN_NORM);
		else
		{
			if(this.spawnflags & MON_JIM_ROCKET)
				_sound(this, CH_VOICE, "jim/idle3.wav", 1, ATTN_NORM);
			else
				_sound(this, CH_VOICE, "jim/idle2.wav", 1, ATTN_NORM);
		}
		this.idletimer = time + 5 + (random() * 3);
	}

	// Jim has a glowing gun and eye skin feature!
	if(this.t_length < time)
	{
		this.t_length = time + 0.2;
		this.skin += 1;
		if(this.skin > 2)
			this.skin = 0;
	}

	// In combat?
	if(this.enemy)
	{
		this.idlebusy = false;
		if(fstate == JS_IDLE)
		{
			if(this.origin_z > this.oldorigin_z)
				fstate = JS_UP;
			else if(this.origin_z < this.oldorigin_z)
				fstate = JS_DOWN;
		}
	}
	else
	{
		// At beginning of frame block and reversing?
		if(this.count == 0 && this.idlereverse)
		{
			if(this.idlebusy == JS_TURNLEFT || this.idlebusy == JS_TURNRIGHT)
			{
				this.idlebusy = JS_IDLE;
				this.idlereverse = false;
				this.waitmin = time + 2 + random() * 4;
			}
		}
		// At end of frame block and going forward?
		else if(this.count == JS_ANIMBLOCK - 1 && !this.idlereverse)
		{
			// Staring forward, doing nothing
			if(this.idlebusy == JS_IDLE && this.waitmin < time)
			{
				// Only start idle animations if stationary
				if(this.velocity_x == 0 && this.velocity_y == 0)
				{
					if(this.idletimer < time)
					{
						if(random() > 0.5)
							_sound(this, CH_VOICE, "jim/idle1.wav", 1, ATTN_NORM);
						else
						{
							if(this.spawnflags & MON_JIM_ROCKET)
								_sound(this, CH_VOICE, "jim/idle3.wav", 1, ATTN_NORM);
							else
								_sound(this, CH_VOICE, "jim/idle2.wav", 1, ATTN_NORM);
						}
						this.idletimer = time + 5 + (random() * 3);
					}
					this.lip = random();
					if(this.lip < 0.3) this.idlebusy = JS_TURNLEFT;
					else if(this.lip < 0.6) this.idlebusy = JS_TURNRIGHT;
					else if(this.lip < 0.8) this.idlebusy = JS_IDLE2;
					else this.idlebusy = JS_IDLE3;
				}
			}
			// Return from wing flex, gun swing idle animations
			else if(this.idlebusy == JS_IDLE2 || this.idlebusy == JS_IDLE3)
			{
				this.idlebusy = JS_IDLE;
				this.waitmin = time + 2 + random() * 4;
			}
			// Turning eyes/gun in left direction
			else if(this.idlebusy == JS_TURNLEFT)
			{
				this.idlebusy = JS_IDLELEFT;
				this.waitmin = time + 2 + random() * 4;
			}
			// Turning eyes/gun to right direction
			else if(this.idlebusy == JS_TURNRIGHT)
			{
				this.idlebusy = JS_IDLERIGHT;
				this.waitmin = time + 2 + random() * 4;
			}
			// Looking left and randomly think about returning
			else if(this.idlebusy == JS_IDLELEFT)
			{
				if(this.waitmin < time && random() < 0.5)
				{
					this.idlebusy = JS_TURNLEFT;
					this.idlereverse = true;
				}
			}
			// Looking right and randomly think about returning
			else if(this.idlebusy == JS_IDLERIGHT)
			{
				if(this.waitmin < time && random() < 0.5)
				{
					this.idlebusy = JS_TURNRIGHT;
					this.idlereverse = true;
				}
			}
		}
		
		// Change the movement type so that jim can easily move up/down
		// using velocity, forced origin movement is really jerky!
		if(this.velocity_x == 0 && this.velocity_y == 0)
		{
			if(this.attack_timer < time)
			{
				this.attack_timer = time + 1;
				if(this.lip < 1)
					this.lip = 1;
				else
					this.lip = -1;
				this.velocity_z = 2 * this.lip;
			}
		}
		else
		{
			// Slowdown the velocity (movement = no friction)
			this.velocity = this.velocity * this.velocityfriction;
			if(this.velocity_x > -5 && this.velocity_x < 5) this.velocity_x = 0;
			if(this.velocity_y > -5 && this.velocity_y < 5) this.velocity_y = 0;
			if(this.velocity_z > -5 && this.velocity_z < 5) this.velocity_z = 0;
			// Don't go into attack straight away when velocity is active
			this.attack_finished = time + 0.5;
		}
	}

	// Check frame direction and update counter
	if(this.idlereverse)
		this.count -= 1;
	else
		this.count += 1;
	if(this.count >= JS_ANIMBLOCK)
		this.count = 0;
	if(this.count < 0)
		this.count = JS_ANIMBLOCK - 1;
	
	// Busy with an idle animation?
	if(this.idlebusy > 0)
		fstate = this.idlebusy;
	// Update frame animation block with frame counter
	this.frame = fstate * JS_ANIMBLOCK + this.count;
	// Store current origin position
	this.oldorigin = this.origin;
}

//======================================================================
// All stand, walk and run functions are condensed down to one entry
// because the robot has a constant skin/sound update that has to
// happen at specific intervals
//
void jim_stand1(entity this)
{
	set_animofs(this, anim_jim_idle, 1, jim_stand1);
	// Standing idle has gentle bobbing up and down
	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_FLY);
	jim_update(this, JS_IDLE);
	ai_stand(this);
}
void jim_walk1(entity this)
{
	set_animofs(this, anim_jim_idle, 1, jim_walk1);
	// Movement is steps, not velocity
	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);
	this.velocity = '0 0 0';
	jim_update(this, JS_IDLE);
	ai_walk(this, 8);
}
void jim_run1(entity this)
{
	set_animofs(this, anim_jim_idle, 1, jim_run1);
	// Movement is steps, only velocity when firing weapon
	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);
	this.velocity = '0 0 0';
	jim_update(this, JS_IDLE);
	ai_run(this, 16);
	if(this.movespeed != 0)
		ai_face(this);
}

//======================================================================
// Range (LASERS or ROCKETS)
//======================================================================
void JLaser_Touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
	_sound(this, CH_WEAPON_SINGLE, "weapons/laser_hit.wav", 1, ATTN_STATIC);
	vector org = this.origin - 10 * normalize(this.velocity);

	if(toucher.health)
	{
		SpawnBlood(org, this.velocity * 0.2, 15, trace_ent);
		T_Damage(toucher, this, this.owner, 15, this.projectiledeathtype);
	}
	else
	{
		te_knightspike(org);
	}
	
	delete(this);	
}

void JLaunchLaser(entity this, vector org, vector vec)
{
	entity newmis = spawn();
	newmis.owner = this;
	set_movetype(newmis, MOVETYPE_FLY);
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;
	newmis.flags = FL_PROJECTILE;
	newmis.projectiledeathtype = DEATH_MONSTER_JIM.m_id;

	_setmodel(newmis, "progs/proj_laz.mdl");
	setsize(newmis, '0 0 0', '0 0 0');		

	setorigin(newmis, org);

	vec = normalize(vec);
	newmis.velocity = vec * 575;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 5;
	setthink(newmis, SUB_Remove);
	settouch(newmis, JLaser_Touch);
}

void jim_laser(entity this)
{
	if(!this.enemy)
		return;
	if(this.health < 1)
		return;
	
	// Always make sure there is no monster or obstacle in the way
	// Cannot use enemy entity direct, enemytarget will be active
	if(!visible(this, this.enemy))
		return;

	this.effects |= EF_MUZZLEFLASH;
	_sound(this, CH_WEAPON_SINGLE, "weapons/laser_fire.wav", 1, ATTN_NORM);

	fixedmakevectors(this.angles);
	vector org = this.origin + attack_vector('20 0 -10');

	// Aim high to catch jumping players
	vector dir = this.enemy.origin + '0 0 12';
	vector vec = normalize(dir - org);
	JLaunchLaser(this, org, vec);
}

//----------------------------------------------------------------------
// Straight aim rocket, no pre-calculation or steering (skill based speed)
//----------------------------------------------------------------------
void jim_rocket(entity this)
{
	if(!this.enemy)
		return;
	if(this.health < 1)
		return;
	
	// Always make sure there is no monster or obstacle in the way
	// Cannot use enemy entity direct, enemytarget will be active
	if(!visible(this, this.enemy))
		return;
	
	this.effects |= EF_MUZZLEFLASH;
	_sound(this, CH_WEAPON_SINGLE, "jim/rocket_fire.wav", 1, ATTN_NORM);	

	fixedmakevectors(this.angles);
	vector org = this.origin + attack_vector('20 0 -10');

	// Aim low to catch players with splash damage
	vector dir = this.enemy.origin - '0 0 12';
	vector vec = normalize(dir - org);
	
	// Variable rocket speed, matching laser (very nasty)
	entity newmis = launch_spike(this, org, vec);
	_setmodel(newmis, "progs/proj_rocket.mdl");
	newmis.noise = "jim/rocket_hit.wav";
	newmis.dmg = 25;
	setsize(newmis, '0 0 0', '0 0 0');
	newmis.velocity = vec * 575;
	settouch(newmis, T_MissileTouch); // rocket explosion
	newmis.projectiledeathtype = DEATH_MONSTER_JIM.m_id;
}

//----------------------------------------------------------------------------
void jim_vel(entity this, float vspeed)
{ 
	// Turn and face enemy and update attack velocity
	ai_face(this); 
	if(this.movespeed == 0) 
		this.velocity = this.attack_track * vspeed;
}

//----------------------------------------------------------------------------
// Calculate new attack vector for firing lasers at the player
//----------------------------------------------------------------------------
void jim_attack(entity this)
{
	this.solid = SOLID_SLIDEBOX;
	if(this.movespeed == 0)
		set_movetype(this, MOVETYPE_FLY);
	fixedmakevectors(this.angles);
	// Always fly upwards away from the player
	this.pos1 = v_up * (50 + random() * 100);
	// Randomly pick a left or right strafe direction
	this.pos2 = v_right * (crandom() * 200);
	// Always try to back away from the player
	this.pos3 = v_forward * (random() * 100);
	
	// Merge all the randomness together
	this.attack_track = this.pos1 + this.pos2 + this.pos3;
	// Check nothing is in the way, estimate vector of attack
	traceline(this.origin, this.origin + this.attack_track, false, this);
}

//----------------------------------------------------------------------------
void jim_fire11(entity this)
{
	set_animofs(this, anim_jim_idle, 1, jim_run1);
	jim_update(this, JS_IDLE);
	// Chance of bob instantly firing again
	if(random() < 0.8)
		this.attack_finished = time + 1 + random();
	else
		this.attack_finished = time + 1 + random() * 0.5;
}
void jim_fire10(entity this) { set_animofs(this, anim_jim_idle, 1, jim_fire11); jim_update(this, JS_IDLE); jim_vel(this, 0.5); }
void jim_fire9(entity this)
{
	set_animofs(this, anim_jim_idle, 1, jim_fire10);
	jim_update(this, JS_IDLE);
	if(autocvar_skill < 2)
		jim_vel(this, 1.1);
	if(!(this.spawnflags & MON_JIM_ROCKET) && autocvar_skill >= 2)
		jim_laser(this);
}
void jim_fire8(entity this)
{
	set_animofs(this, anim_jim_idle, 1, jim_fire9);
	jim_update(this, JS_IDLE);
	if(autocvar_skill < 2)
		jim_vel(this, 1.3);
	if(!(this.spawnflags & MON_JIM_ROCKET) && autocvar_skill >= 1)
		jim_laser(this);
}
void jim_fire7(entity this)
{
	set_animofs(this, anim_jim_idle, 1, jim_fire8);
	jim_update(this, JS_IDLE);
	if(autocvar_skill < 2)
		jim_vel(this, 1.4);
	if(!(this.spawnflags & MON_JIM_ROCKET))
		jim_laser(this);
}
void jim_fire6(entity this)
{
	set_animofs(this, anim_jim_idle, 1, jim_fire7); 
	jim_update(this, JS_IDLE);
	if(autocvar_skill < 2)
		jim_vel(this, 1.2);
	if(!(this.spawnflags & MON_JIM_ROCKET))
		jim_laser(this);
	else
		jim_rocket(this);
}
void jim_fire5(entity this) { set_animofs(this, anim_jim_idle, 1, jim_fire6); jim_update(this, JS_IDLE); jim_vel(this, 1.0);}
void jim_fire4(entity this)
{
	set_animofs(this, anim_jim_idle, 1, jim_fire5);
	jim_update(this, JS_IDLE); 
	if(autocvar_skill < 2)
		jim_vel(this, 0.8);
}
void jim_fire3(entity this)
{
	set_animofs(this, anim_jim_idle, 1, jim_fire4); 
	jim_update(this, JS_IDLE);
	if(autocvar_skill < 2)
		jim_vel(this, 0.6);
}
void jim_fire2(entity this)
{
	set_animofs(this, anim_jim_idle, 1, jim_fire3);
	jim_update(this, JS_IDLE);
	jim_attack(this);
	if(autocvar_skill < 2)
		jim_vel(this, 0.4);
	else
		jim_vel(this, 1.5);
}
void jim_fire1(entity this)
{
	set_animofs(this, anim_jim_idle, 1, jim_fire2);
	jim_update(this, JS_IDLE);
	if(!(this.spawnflags & MON_JIM_ROCKET)) 
		_sound(this, CH_WEAPON_SINGLE, "jim/laser_load.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "jim/rocket_load.wav", 1, ATTN_NORM);
}

void jim_inpain(entity this)
{
	// Keep cycling the pain animation
	setthink(this, jim_inpain);
	this.nextthink = time + 0.1;
	
	// Start of pain cycle
	if(this.inpain == 0)
	{
		// Spawn a pile of sparks and dust falling down
		//particle_dust(this.origin, 10+random()*10, 16, PARTICLE_BURST_YELLOW);
		particle(this.origin, '0 0 1' * (10 + random() * 10), 16, 16);
		this.pos1 = '0 0 0';
		this.pos1_x = random() * this.lefty;	// Pitch away from dmg
		this.pos1_z = crandom() * -10;			// Roll left / right
	}
	// Finished, back to combat
	else if(this.inpain >= 5)
	{
		// reset pitch/roll
		this.angles_x = this.angles_z = 0;
		setthink(this, this.th_run);
	}
	else
	{
		// Keep moving in the pitch/roll direction
		this.pos1 = this.pos1 * 1.2;
		this.angles = this.angles + this.pos1;
	}
	
	// Update pain frame
	jim_update(this, JS_PAIN);
	// Next pain animation
	this.inpain += 1;
}

void jim_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(time < this.pain_finished)
		return;
	if((random() * 30) > damage)
		return;
	
	// Stop any ai_run velocity and reset movetype
	this.velocity = '0 0 0';
	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);
	if(random() < 0.5)
		_sound(this, CH_VOICE, "jim/pain1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "jim/pain2.wav", 1, ATTN_NORM);
	this.inpain = 0;
	
	// Work out which direction the damage came from (enemy)
	if(infront(this, attacker))
		this.lefty = 10;	// Hit from infront
	else
		this.lefty = -10;					// Hit from behind
	
	// Always do pain, no flinch
	jim_inpain(this);
}

void jim_dying2(entity this);
void jim_is_dead(entity this);

//----------------------------------------------------------------------------
void jim_dying1(entity this)
{
	// Setup correct death frame
	this.frame = JS_DYING + this.cnt;
	this.cnt = this.cnt + 1;
	
	// Start spinning the robot out of control
	// This update works with avelocity to create spiral effect
	makevectors(this.angles);
	this.velocity = (v_forward * 300) + (v_up * -30);
	// Keep spinning out of control (constant direction)
	if(this.lefty == 1)
		this.angles_y = (this.angles_y + 10);
	else
		this.angles_y = (this.angles_y - 10);

	// Spawn some extra smoke trails
	if(random() < 0.3) SpawnProjectileSmoke(this.origin, 150, 50, 150);

	// Keep looping round
	setthink(this, jim_dying1);
	this.nextthink = time + 0.1;

	// Next frame/function?
	if(this.cnt > 3)
	{ 
		setthink(this, jim_dying2);	// Next function
		this.waitmin = time + 1;	// Setup timer for next part
		this.cnt = 0; 				// Reset death animation
	}
}

//----------------------------------------------------------------------------
void jim_dying2(entity this)
{
	// Setup correct death frame
	this.frame = JS_DYING + this.cnt;
	this.cnt += 1;
	if(this.cnt > 5)
		this.cnt = 0;

	// Medium explosion + sound OR smoke projectile trail
	if(random() > 0.7)
		SpawnExplosion(EXPLODE_MED, this.origin, "jim/explode_minor.wav");
	else if(random() < 0.3)
		SpawnProjectileSmoke(this.origin, 150, 50, 150);

	// Turn down towards the ground
	makevectors(this.angles);
	this.solid = SOLID_BBOX;	// Collision + touch
	// Slow down the velocity to accent the spinning
	this.velocity = (this.velocity * 0.2) + ((v_forward * 100) * 0.8);
	this.velocity = normalize(this.velocity) * 300;
	this.velocity_z = this.velocity_z - 200;
	// Keep spinning out of control (constant direction)
	if(this.lefty == 1)
		this.angles_y = (this.angles_y + 10);
	else
		this.angles_y = (this.angles_y - 10);

	// Keep looping round
	this.nextthink = time + 0.1;
	if(this.waitmin < time)
		setthink(this, jim_is_dead);
	else
		setthink(this, jim_dying2);
}

void jim_is_dead(entity this)
{
	setthink(this, func_null);
	this.nextthink = 0;
	settouch(this, func_null);
	
	// Final fireworks!
	//particle_dust(this.origin, 10+random()*10, 16, PARTICLE_BURST_YELLOW);
	particle(this.origin, '0 0 1' * (10 + random() * 10), 16, 16);
	SpawnProjectileSmoke(this.origin, 150, 50, 150);
	SpawnProjectileSmoke(this.origin, 150, 50, 150);
	SpawnExplosion(EXPLODE_BIG, this.origin, "jim/explode_major.wav");

	delete(this);
}

void jim_is_dead_touch(entity this, entity toucher)
{
	jim_is_dead(this);
}

void jim_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CHAN_BODY, "", 1, ATTN_NORM);

	// Special explosive death event 
	// First function creates the upward spiral (negative avelocity)
	// Second function accents the spiral (1s forward movement)
	// Third final impact (touch function goes here as well)
	//
	_sound(this, CH_VOICE, "jim/death1.wav", 1, ATTN_NORM);
	this.solid = SOLID_NOT;			// No world colision
	set_movetype(this, MOVETYPE_FLY);	// Free velocity movement
	settouch(this, jim_is_dead_touch);		// still can touch stuff
	this.cnt = 0;					// Death frame 0
	this.movespeed = 0;				// Make sure turret mode off
	// The avelocity works better when negative (twisting upward)
	this.avelocity_x = (random() * 50) - 100;
	this.avelocity_y = (random() * 50) - 100;
	this.avelocity_z = (random() * 50) - 100;

	if(random() < 0.5)
		this.lefty = 1;
	else
		this.lefty = 0;

	particle(this.origin, '0 0 1' * (10 + random() * 10), 16, 16);
	SpawnExplosion(EXPLODE_BIG, this.origin, "jim/explode_minor.wav");
	SpawnProjectileSmoke(this.origin, 150, 50, 150);

	jim_dying1(this);
}

//======================================================================
/*QUAKED monster_jim (1 0 0) (-16 -16 -24) (16 16 24) Ambush
======================================================================*/
spawnfunc(monster_jim) { monster_start(this, true, MON_JIM); }

spawnfunc(monster_bob) { monster_start(this, true, MON_JIM); }

// alkaline
spawnfunc(monster_drone) { monster_start(this, true, MON_JIM); }
#endif // SVQC

#ifdef SVQC
METHOD(Jim, mr_setup, bool(Jim this, entity actor))
{
    TC(Jim, this);

   	// low chance to be a rocket jim anyway!
    if(random() < 0.2)
    	actor.spawnflags |= MON_JIM_ROCKET;

    if(actor.mdl && actor.mdl != "")
    {
    	precache_model(actor.mdl);
    	_setmodel(actor, actor.mdl);
    }
    else if(actor.spawnflags & MON_JIM_ROCKET)
    	_setmodel(actor, "progs/mon_jimrock.mdl");
    setsize(actor, this.m_mins, this.m_maxs);

    precache_sound("jim/death1.wav");
    precache_sound("jim/pain1.wav");
    precache_sound("jim/pain2.wav");

	precache_sound("jim/explode_minor.wav");
	precache_sound("jim/explode_major.wav");
	precache_sound("jim/gunidle2.wav");

	precache_sound("jim/idle1.wav");
	precache_sound("jim/idle2.wav");
	precache_sound("jim/idle3.wav");

	if(actor.spawnflags & MON_JIM_ROCKET)
	{
		precache_sound("jim/rocket_load.wav");
		precache_sound("jim/rocket_fire.wav");
		precache_sound("jim/rocket_hit.wav");
		precache_model("progs/proj_rocket.mdl");

		actor.health = 50;
	}
	else
	{
		precache_sound("jim/laser_load.wav");
		precache_sound("weapons/laser_fire.wav");
		precache_sound("weapons/laser_hit.wav");
		precache_model("progs/proj_laz.mdl");

		actor.health = 100;
	}

	if(actor.velocityfriction <= 0)
		actor.velocityfriction = 0.8 + (random() * 0.1);

    actor.th_stand = jim_stand1;
	actor.th_walk = jim_walk1;
	actor.th_run = jim_run1;
	actor.th_missile = jim_fire1;
	actor.th_pain = jim_pain;
	actor.th_die = jim_die;

	actor.checkattack = JimCheckAttack;

    return true;
}
#endif
