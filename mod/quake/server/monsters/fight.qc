#include "fight.qh"

#include "ai.qh"
#include "../combat.qh"

/*

A monster is in fight mode if it thinks it can effectively attack its
enemy.

When it decides it can't attack, it goes into hunt mode.

*/


//=============================================================================

/*
===========
CheckAttack

The player is in view, so decide to move or launch an attack
Returns false if movement should continue
============
*/
bool CheckAttack(entity this)
{
	if(this.enemy_range == RANGE_FAR)
		return false;
	if(this.enemy_range != RANGE_MELEE)
	{
		if(!this.th_missile)
			return false;
		if(time < this.attack_finished)
			return false;
	}

	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, MOVE_NORMAL, this);

	if(trace_ent != targ && !this.charmed) // hipnotic
		return false;		// don't have a clear shot
			
	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(this.enemy_range == RANGE_MELEE && z_overlap(this, this.enemy))
	{	// melee attack
		if(this.th_melee)
		{
			this.th_melee(this);
			return true;
		}
	}

	float chance;
	if(this.enemy_range == RANGE_MELEE)
	{
		chance = 0.9;
		this.attack_finished = 0;
	}
	else if(this.enemy_range == RANGE_NEAR)
	{
		if(this.th_melee)
			chance = 0.2;
		else
			chance = 0.4;
	}
	else if(this.enemy_range == RANGE_MID)
	{
		if(this.th_melee)
			chance = 0.05;
		else
			chance = 0.1;
	}
	else
		chance = 0;

	if(this.th_missile && random() < chance)
	{
		this.th_missile(this);
		this.attack_finished = time + (2 * random());
		return true;
	}

	return false;
}

/*
=============
ai_face

Stay facing the enemy
=============
*/
void ai_face(entity this)
{
	if(!this.enemy)
		return;
	this.ideal_yaw = vectoyaw(this.enemy.origin - this.origin);
	changeyaw(this);
}

/*
=============
ai_charge

The monster is in a melee attack, so get as close as possible to .enemy
=============
*/

void ai_charge(entity this, float d)
{
	ai_face(this);	
	t_movetogoal(this, d);		// done in C code...
}

void ai_charge_side(entity this)
{
// aim to the left of the enemy for a flyby

	this.ideal_yaw = vectoyaw(this.enemy.origin - this.origin);
	changeyaw(this);

	fixedmakevectors(this.angles);
	vector dtemp = this.enemy.origin - 30 * v_right;
	float heading = vectoyaw(dtemp - this.origin);
	
	t_walkmove(this, heading, 20);
}

/*======================================================================
 ai_checkmelee
  Check if the monster (this) can attack enemy (target)
  and returns TRUE if the monster is within XYZ range
======================================================================*/
bool ai_checkmelee(entity this, float attackdist, float attackzaxis)
{
	// Setup default
	if(attackzaxis <= 0)
		attackzaxis = 48;
	
	// Calculate distance and z axis difference seperate
	vector spot1 = this.enemy.origin; //SUB_orgEnemyTarget();
	vector spot2 = this.origin;
	float zdiff = fabs(spot1.z - spot2.z);
	spot1.z = spot2.z = 0;				// Flatten Z axis before vector length

	// Is the enemy too far away and the zaxis is wrong (too low/high)
	return (vdist(spot1 - spot2, <=, attackdist) && zdiff <= 48);
}

/*
=============
ai_melee

=============
*/
void ai_melee(entity this, int deathtype, int melee_range)
{
	if(!this.enemy)
		return;		// removed before stroke

	if(!ai_checkmelee(this, melee_range, false))
		return; // Too far away

	float ldmg = (random() + random() + random()) * 3;
	T_Damage(this.enemy, this, this, ldmg, deathtype);
}

void ai_melee_side(entity this, int deathtype, int melee_range)
{
	if(!this.enemy)
		return;		// removed before stroke

	ai_charge_side(this);

	if(!ai_checkmelee(this, melee_range, false))
		return; // Too far away
	if(!CanDamage(this.enemy, this))
		return;
	float ldmg = (random() + random() + random()) * 3;
	T_Damage(this.enemy, this, this, ldmg, deathtype);
}
