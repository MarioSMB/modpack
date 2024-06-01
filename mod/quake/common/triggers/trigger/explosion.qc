#ifdef SVQC

void trigEx_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	SUB_UseTargets(this, attacker, NULL);

	settouch(this, func_null);
	setthink(this, SUB_Remove);
	this.nextthink = time + 0.1;
}

//============================================================================
const int NO_DAMAGE = BIT(0);
void trigger_explosion_activate(entity this)
{
	this.delay = 0;
	SUB_UseTargets(this, NULL, NULL);
	
	if(!(this.spawnflags & NO_DAMAGE))
		T_RadiusDamage(this, this.owner, 120, DEATH_TRAP.m_id, this);

	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);

	BecomeExplosion(this);
}

void trigger_explosion_use(entity this, entity actor, entity trigger)
{
	if(this.delay > 0)
	{
		setthink(this, trigger_explosion_activate);
		this.nextthink = time + this.delay;
	}
	else
	{
		trigger_explosion_activate(this);
	}
}

/*QUAKED trigger_explosion (.5 .5 .5) ? 
Variable sized repeatable trigger.  Must be targeted at one or more entities. Only set off when killed, and is only damaged by T_RadiusDamage.

health: amount of damage needed to set off trigger.
*/
spawnfunc(trigger_explosion)
{
	if(!MP_ROGUE && !MP_MG) { delete(this); return; }
	if(MP_MG && (Inhibit_Coop(this) || RemovedOutsideCoop(this)))
	{
		delete(this);
		return;
	}

	// mg uses this as a target
	if(!this.modelindex)
		this.use = trigger_explosion_use;
	else // rogue uses a trigger
	{
		InitTrigger(this);

		if(!this.health)
			this.health = 20;

		this.max_health = this.health;
		this.th_die = trigEx_die;
		this.takedamage = DAMAGE_YES;
		this.solid = SOLID_BBOX;
		setorigin(this, this.origin);	// make sure it links into the world
	}
}

#endif
