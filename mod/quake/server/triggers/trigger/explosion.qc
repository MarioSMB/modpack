#ifdef SVQC

void trigEx_die(entity this, entity attacker)
{
	SUB_UseTargets(this, attacker, NULL);

	settouch(this, func_null);
	setthink(this, SUB_Remove);
	this.nextthink = time + 0.1;
}

/*QUAKED trigger_explosion (.5 .5 .5) ? 
Variable sized repeatable trigger.  Must be targeted at one or more entities. Only set off when killed, and is only damaged by T_RadiusDamage.

health: amount of damage needed to set off trigger.
*/
spawnfunc(trigger_explosion)
{
	if(!MP_ROGUE) { delete(this); return; }

	InitTrigger(this);

	if(!this.health)
		this.health = 20;
	
	this.max_health = this.health;
	this.th_die = trigEx_die;
	this.takedamage = DAMAGE_YES;
	this.solid = SOLID_BBOX;
	setorigin(this, this.origin);	// make sure it links into the world
}

#endif
