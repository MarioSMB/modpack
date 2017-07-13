/* Breakaway walls QuickC program
	 By Jim Dose'  9/11/96
	 Copyright (c)1996 Hipnotic Interactive, Inc.
	 All rights reserved.
	 Distributed (unsupported) on 3.12.97
*/

const int MULTI_USE = 1;
const int INVISIBLE = 2;

void damagethreshold_killed(entity this, entity attacker)
{
	this.health = this.max_health;

//  this.solid = SOLID_NOT;
	this.takedamage = DAMAGE_NO;
	SUB_UseTargets(this, attacker, NULL);
	this.takedamage = DAMAGE_YES;

	if(!(this.spawnflags & MULTI_USE))
		delete(this);
}

void damagethreshold_pain(entity this, entity attacker, float damage)
{
	this.health = this.max_health;
}

/*QUAKED trigger_damagethreshold (0 .5 .8) ? MULTI_USE INVISIBLE
Triggers only when a threshold of damage is exceeded.
When used in conjunction with func_breakawaywall, allows
walls that may be destroyed with a rocket blast.

MULTI_USE tells the trigger to not to remove itself after
being fired.  Allows the trigger to be used multiple times.

INVISIBLE tells the trigger to not be visible.

"health" specifies how much damage must occur before trigger fires.
Default is 60.

*/

spawnfunc(trigger_damagethreshold)
{
	if(!MP_HIPNOTIC) { delete(this); return; }
	
	this.mangle = this.angles;
	this.angles = '0 0 0';

	this.classname = "damagethreshold";
	this.solid = SOLID_BSP;
	set_movetype(this, MOVETYPE_PUSH);
	setorigin(this, this.origin);
	_setmodel(this, this.model);
	setsize(this, this.mins , this.maxs);
	if(this.spawnflags & INVISIBLE)
		this.model = string_null;

	if(!this.health)
		this.health = 60;

	this.max_health = this.health;
	this.takedamage = DAMAGE_YES;

	setblocked(this, func_null);
	this.th_pain = damagethreshold_pain;
	this.th_die = damagethreshold_killed;
}


void breakawaywall_remove(entity this, entity actor, entity trigger)
{
	delete(this);
}

/*QUAKED func_breakawaywall (0 .5 .8) ?
Special walltype that removes itself when triggered.
*/

spawnfunc(func_breakawaywall)
{
	if(!MP_HIPNOTIC) { delete(this); return; }
	
	this.mangle = this.angles;
	this.angles = '0 0 0';

	this.classname = "breakaway";
	this.solid = SOLID_BSP;
	set_movetype(this, MOVETYPE_PUSH);
	setorigin (this, this.origin);
	_setmodel (this, this.model);
	setsize (this, this.mins , this.maxs);
	this.use = breakawaywall_remove;
}
