#ifdef SVQC

void counter_use(entity this, entity actor, entity trigger)
{
	this.count -= 1;
	if(this.count < 0)
		return;

	if(this.count == 0)
	{
		if(IS_PLAYER(actor) && !(this.spawnflags & SPAWNFLAG_NOMESSAGE))
			centerprint(actor, "Sequence completed!");

		this.enemy = actor;
		// yoder Sept24, 2021, Horde Merge
		if(MP_MG && (this.spawnflags & COUNTER_LOOPS))
			this.count = this.cnt;
		multi_trigger(this);
	}
	else
	{
		if(IS_PLAYER(actor) && !(this.spawnflags & SPAWNFLAG_NOMESSAGE))
		{
			if(this.count >= 4)
				centerprint(actor, "There are more to go...");
			else if(this.count == 3)
				centerprint(actor, "Only 3 more to go...");
			else if(this.count == 2)
				centerprint(actor, "Only 2 more to go...");
			else
				centerprint(actor, "Only 1 more to go...");
		}
	}
}

/*QUAKED trigger_counter(.5 .5 .5) ? nomessage
Acts as an intermediary for an action that takes multiple inputs.

If nomessage is not set, it will print "1 more.. " etc when triggered and "sequence complete" when finished.

After the counter has been triggered "count" times(default 2), it will fire all of its targets and remove itself.
*/
spawnfunc(trigger_counter)
{
	if(MP_MG && (Inhibit_Coop(this) || RemovedOutsideCoop(this)))
	{
		delete(this);
		return;
	}
	if(!MP_MG || !(this.spawnflags & COUNTER_LOOPS))
		this.wait = -1;
	// Yoder Sept24, 2021 Horde Merge
	// .count is decremented each use and fires its targets on 0
	// .cnt stores the original .count and restores to this if COUNTER_LOOPS
	if(!this.count)
		this.count = 2;
	if(MP_MG)
		this.cnt = this.count;

	this.use = counter_use;
}

void counter_timed_think(entity this)
{
	this.count = this.cnt;
}

void counter_timed_use(entity this, entity actor, entity trigger)
{
	this.count = this.count - 1;
	if(this.count < 0)
		return;
	
	this.nextthink = time + this.delay;

	if(this.count != 0)
	{
		if(IS_PLAYER(actor) && !(this.spawnflags & SPAWNFLAG_NOMESSAGE))
		{
			if(this.count >= 4)
				centerprint(actor, "There are more to go...");
			else if(this.count == 3)
				centerprint(actor, "Only 3 more to go...");
			else if(this.count == 2)
				centerprint(actor, "Only 2 more to go...");
			else
				centerprint(actor, "Only 1 more to go...");
		}
		return;
	}
	
	if(IS_PLAYER(actor) && !(this.spawnflags & SPAWNFLAG_NOMESSAGE))
		centerprint(actor, "Sequence completed!");

	this.enemy = actor;
	this.delay = 0;
	this.nextthink = -1;
	setthink(this, func_null);
	multi_trigger(this);
	delete(this);
}

/*QUAKED trigger_counter_timed (.5 .5 .5) ? nomessage message_all
Acts as an intermediary for an action that takes multiple inputs.

If nomessage is not set, t will print "1 more.. " etc when triggered and "sequence complete" when finished.

After the counter has been triggered "count" times (default 2), it will fire all of it's targets and remove itself.
*/
spawnfunc(trigger_counter_timed)
{
	if(!MP_MG) { delete(this); return; }
	if(MP_MG && (Inhibit_Coop(this) || RemovedOutsideCoop(this)))
	{
		delete(this);
		return;
	}

	this.wait = -1;
	if(!this.count)
		this.count = 2;

	if(!this.delay)
		this.delay = 2;
	
	this.cnt = this.count;

	this.use = counter_timed_use;
	setthink(this, counter_timed_think);
}

#endif
