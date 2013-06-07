
/*

A monster is in fight mode if it thinks it can effectively attack its
enemy.

When it decides it can't attack, it goes into hunt mode.

*/

void SUB_AttackFinished (float normal)
{
	self.cnt = 0;           // refire count for nightmare
	if (skill < 3)
		ATTACK_FINISHED(self) = time + normal;
}

float CanDamage(entity targ, entity inflictor)
{
	if (targ.movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), TRUE, self);
		if (trace_fraction == 1)
			return TRUE;
		if (trace_ent == targ)
			return TRUE;
		return FALSE;
	}

	traceline(inflictor.origin, targ.origin, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;

	return FALSE;
}

float(float v) anglemod;

void(vector dest) ChooseTurn;

void() ai_face;


float enemy_range;


//=============================================================================

/*
===========
GenericCheckAttack

The player is in view, so decide to move or launch an attack
Returns FALSE if movement should continue
============
*/
float() GenericCheckAttack =
{
	vector spot1, spot2;
	entity targ;
	float chance;

	if (self.health < 1)
		return FALSE;
	targ = self.enemy;

	if (vlen(targ.origin - self.origin) > 5000) // long traces are slow
		return FALSE;

// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, self);

	if (trace_ent != targ)
		return FALSE; // don't have a clear shot

	if (trace_inopen && trace_inwater)
		return FALSE; // sight line crossed contents

	if (enemy_range == RANGE_MELEE)
	{	// melee attack
		if (self.th_melee)
		{
			self.th_melee ();
			return TRUE;
		}
	}

// missile attack
	if (time < ATTACK_FINISHED(self))
		return FALSE;

	if (!self.th_missile)
		return FALSE;

	if (enemy_range == RANGE_FAR)
		return FALSE;

	if (enemy_range == RANGE_MELEE)
	{
		chance = 0.9;
		ATTACK_FINISHED(self) = 0;
	}
	else if (enemy_range == RANGE_NEAR)
	{
		if (self.th_melee)
			chance = 0.2;
		else
			chance = 0.4;
	}
	else if (enemy_range == RANGE_MID)
	{
		if (self.th_melee)
			chance = 0.05;
		else
			chance = 0.1;
	}
	else
		chance = 0;

	if (random () < chance)
	if (self.th_missile ())
	{
		SUB_AttackFinished (2*random());
		return TRUE;
	}

	return FALSE;
}


/*
=============
ai_face

Stay facing the enemy
=============
*/
void() ai_face =
{
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	ChangeYaw ();
}

/*
=============
ai_charge

The monster is in a melee attack, so get as close as possible to .enemy
=============
*/
float (entity targ) visible;
float(entity targ) infront;
float(entity targ) range;

void(float d) ai_charge =
{
	if (self.health < 1)
		return;
	ai_face ();
	movetogoal (d);		// done in C code...
}

void() ai_charge_side =
{
	if (self.health < 1)
		return;
	vector dtemp;
	float heading;

// aim to the left of the enemy for a flyby

	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	ChangeYaw ();

	makevectors (self.angles);
	dtemp = self.enemy.origin - 30*v_right;
	heading = vectoyaw(dtemp - self.origin);

	walkmove(heading, 20);
}


/*
=============
ai_melee

=============
*/
void() ai_melee =
{
	vector delta;
	float ldmg;

	if (self.health < 1)
		return;
	if (!self.enemy)
		return;		// removed before stroke

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 60)
		return;

	ldmg = DMG_KNIGHT_MELEE_BASE + DMG_KNIGHT_MELEE_RANDOM1 * random();
	ldmg = ldmg + DMG_KNIGHT_MELEE_RANDOM2 * random();
	ldmg = ldmg + DMG_KNIGHT_MELEE_RANDOM3 * random();
	traceline(self.origin, self.enemy.origin, FALSE, self);

	Damage (self.enemy, self, self, ldmg, self.projectiledeathtype, trace_endpos, '0 0 0'); // TODO add force to monster melee attacks?
}


void() ai_melee_side =
{
	vector delta;
	float ldmg;

	if (self.health < 1)
		return;
	if (!self.enemy)
		return;		// removed before stroke

	ai_charge_side();

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 60)
		return;
	if (!CanDamage (self.enemy, self))
		return;
	ldmg = DMG_KNIGHT_MELEE_BASE + DMG_KNIGHT_MELEE_RANDOM1 * random();
	ldmg = ldmg + DMG_KNIGHT_MELEE_RANDOM2 * random();
	ldmg = ldmg + DMG_KNIGHT_MELEE_RANDOM3 * random();
	traceline(self.origin, self.enemy.origin, FALSE, self);
	Damage (self.enemy, self, self, ldmg, self.projectiledeathtype, trace_endpos, '0 0 0');
}

