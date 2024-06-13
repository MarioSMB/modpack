#ifdef SVQC

const int REPEATER_ON = BIT(0);

void repeater_think(entity this)
{
	SUB_UseTargets(this, NULL, NULL);
	this.nextthink = time + this.wait + (this.pausetime * random());
}

void repeater_use(entity this, entity actor, entity trigger)
{
	if(this.spawnflags & REPEATER_ON)
	{
		// turn off
		this.spawnflags &= ~REPEATER_ON;
		this.nextthink = 0;
		setthink(this, func_null);
	}
	else
	{
		// turn on
		this.spawnflags |= REPEATER_ON;
		this.nextthink = time + this.wait + (this.pausetime * random());
		setthink(this, repeater_think);
	}
}

spawnfunc(trigger_repeater)
{
	if(Inhibit_Coop(this) || RemovedOutsideCoop(this))
	{
		delete(this);
		return;
	}

	if(!this.wait)
		this.wait = 1;
	this.use = repeater_use;
	if(this.spawnflags & REPEATER_ON)
	{
		this.nextthink = time + this.wait + (this.pausetime * random());
		setthink(this, repeater_think);
	}
	else
	{	
		this.nextthink = 0;
		setthink(this, func_null);
	}
}

#endif
