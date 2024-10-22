#ifdef SVQC

.float rand;

void trigger_repeat_think(entity this)
{
	if(this.count > 0 && this.cnt <= 0) // has limited uses and has reached 0
		return;

	SUB_UseTargets(this, NULL, NULL);

	setthink(this, trigger_repeat_think);

	if(this.count > 0)
	{
		this.cnt -= 1;
		if(this.cnt <= 0)
		{
			this.state = STATE_INACTIVE;
			setthink(this, func_null);
			this.nextthink = 0;
			return;
		}
	}

	this.nextthink = time + this.wait + this.rand * random();
}

void trigger_repeat_use(entity this, entity actor, entity trigger)
{
	if(this.state == STATE_INACTIVE)
	{
		if(!(this.spawnflags & 1))
			this.cnt = this.count;
		
		if(this.delay)
		{
			setthink(this, trigger_repeat_think);
			this.nextthink = time + this.delay; 
		}
		else
			trigger_repeat_think(this);

		this.state = STATE_ACTIVE;
	}
	else
	{
		this.nextthink = 0;
		setthink(this, func_null);
		this.state = STATE_INACTIVE;
	}
}

spawnfunc(trigger_repeat)
{
	if(!this.wait)
		this.wait = 2;

	this.cnt = this.count; //.cnt is the internal counter
	this.state = STATE_INACTIVE;
	this.use = trigger_repeat_use;
}

#endif
