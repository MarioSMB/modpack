
/*

A monster is in fight mode if it thinks it can effectively attack its
enemy.

When it decides it can't attack, it goes into hunt mode.

*/

float(float v) anglemod;

void knight_atk1();
void knight_runatk1();
void ogre_smash1();
void ogre_swing1();

void sham_smash1();
void sham_swingr1();
void sham_swingl1();

float()	DemonCheckAttack;
void(float side)	Demon_Melee;

void(vector dest) ChooseTurn;


float	enemy_vis, enemy_infront;
int enemy_range;
float	enemy_yaw;


void knight_attack()
{
	float		len;
	
// decide if now is a good swing time
	len = vlen(this.enemy.origin+this.enemy.view_ofs -(this.origin+this.view_ofs));
	
	if(len<80)
		knight_atk1();
	else
		knight_runatk1();
}

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
	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, false, this);

	if(trace_ent != targ)
		return false;		// don't have a clear shot
			
	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(enemy_range == RANGE_MELEE)
	{	// melee attack
		if(this.th_melee)
		{
			if(this.classname == "monster_knight")
				knight_attack();
			else
				this.th_melee();
			return true;
		}
	}
	
// missile attack
	if(!this.th_missile)
		return false;
		
	if(time < this.attack_finished)
		return false;
		
	if(enemy_range == RANGE_FAR)
		return false;

	float chance;
	if(enemy_range == RANGE_MELEE)
	{
		chance = 0.9;
		this.attack_finished = 0;
	}
	else if(enemy_range == RANGE_NEAR)
	{
		if(this.th_melee)
			chance = 0.2;
		else
			chance = 0.4;
	}
	else if(enemy_range == RANGE_MID)
	{
		if(this.th_melee)
			chance = 0.05;
		else
			chance = 0.1;
	}
	else
		chance = 0;

	if(random() < chance)
	{
		this.th_missile();
		SUB_AttackFinished(this, 2*random());
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
	this.ideal_yaw = vectoyaw(this.enemy.origin - this.origin);
	ChangeYaw(this);
}

/*
=============
ai_charge

The monster is in a melee attack, so get as close as possible to .enemy
=============
*/
bool visible(entity targ);
bool infront(entity targ);
int range(entity targ);

void ai_charge(entity this, float d)
{
	ai_face(this);	
	movetogoal(this, d);		// done in C code...
}

void ai_charge_side(entity this)
{
// aim to the left of the enemy for a flyby

	this.ideal_yaw = vectoyaw(this.enemy.origin - this.origin);
	ChangeYaw(this);

	makevectors(this.angles);
	vector dtemp = this.enemy.origin - 30*v_right;
	float heading = vectoyaw(dtemp - this.origin);
	
	walkmove(heading, 20);
}


/*
=============
ai_melee

=============
*/
void ai_melee(entity this)
{
	if(!this.enemy)
		return;		// removed before stroke

	if(vdist(this.enemy.origin - this.origin, >, 60))
		return;
		
	float ldmg =(random() + random() + random()) * 3;
	T_Damage(this.enemy, this, this, ldmg);
}


void ai_melee_side(entity this)
{
	if(!this.enemy)
		return;		// removed before stroke

	ai_charge_side();

	if(vdist(this.enemy.origin - this.origin, >, 60))
		return;
	if(!CanDamage(this.enemy, this))
		return;
	float ldmg =(random() + random() + random()) * 3;
	T_Damage(this.enemy, this, this, ldmg);
}


//=============================================================================

/*
===========
SoldierCheckAttack

The player is in view, so decide to move or launch an attack
Returns false if movement should continue
============
*/
bool SoldierCheckAttack(entity this)
{
	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, false, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
		return false;	// don't have a clear shot
			
	
// missile attack
	if(time < this.attack_finished)
		return false;
		
	if(enemy_range == RANGE_FAR)
		return false;

	float chance;
	if(enemy_range == RANGE_MELEE)
		chance = 0.9;
	else if(enemy_range == RANGE_NEAR)
		chance = 0.4;
	else if(enemy_range == RANGE_MID)
		chance = 0.05;
	else
		chance = 0;

	if(random() < chance)
	{
		this.th_missile();
		SUB_AttackFinished(this, 1 + random());
		if(random() < 0.3)
			this.lefty = !this.lefty;

		return true;
	}

	return false;
}
//=============================================================================

/*
===========
ShamCheckAttack

The player is in view, so decide to move or launch an attack
Returns false if movement should continue
============
*/
bool ShamCheckAttack(entity this)
{
	if(enemy_range == RANGE_MELEE)
	{
		if(CanDamage(this.enemy, this))
		{
			this.attack_state = AS_MELEE;
			return true;
		}
	}

	if(time < this.attack_finished)
		return false;
	
	if(!enemy_vis)
		return false;
		
	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	if(vlen(spot1 - spot2) > 600)
		return false;

	traceline(spot1, spot2, false, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
	{
		return false;	// don't have a clear shot
	}
			
// missile attack
	if(enemy_range == RANGE_FAR)
		return false;
		
	this.attack_state = AS_MISSILE;
	SUB_AttackFinished(this, 2 + 2*random());
	return true;
}

//============================================================================

/*
===========
OgreCheckAttack

The player is in view, so decide to move or launch an attack
Returns false if movement should continue
============
*/
bool OgreCheckAttack(entity this)
{
	if(enemy_range == RANGE_MELEE)
	{
		if(CanDamage(this.enemy, this))
		{
			this.attack_state = AS_MELEE;
			return true;
		}
	}

	if(time < this.attack_finished)
		return false;
	
	if(!enemy_vis)
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
			
// missile attack
	float chance;
	if(time < this.attack_finished)
		return false;
		
	if(enemy_range == RANGE_FAR)
		return false;
	
	else if(enemy_range == RANGE_NEAR)
		chance = 0.10;
	else if(enemy_range == RANGE_MID)
		chance = 0.05;
	else
		chance = 0;

	this.attack_state = AS_MISSILE;
	SUB_AttackFinished(this, 1 + 2*random());
	return true;
}

