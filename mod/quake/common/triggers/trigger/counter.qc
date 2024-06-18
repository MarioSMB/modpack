#ifdef SVQC

void counter_reset(entity this)
{
	this.state = 0;
	
	if(this.spawnflags & SPAWNFLAG_NOMESSAGE)
		return;
	centerprint(this.enemy, "Counter has reset!");
	_sound(this.enemy, CH_INFO, QUAKE_TALKSOUND, 1, ATTN_NORM);
}

void counter_use(entity this, entity actor, entity trigger)
{
	if(time < this.attack_finished)
		return;
	playercount_convert(this, count);
	this.enemy = actor;
	
	// eager reset spawnflag: reset 'wait' seconds after any trigger, not just upon
	//	completion - for requiring a number of impulses within a window of time
	if(this.spawnflags & 4)
	{
		setthink(this, counter_reset);
		this.nextthink = time + this.wait;
	}
	
	this.state += 1;
	if(this.state > this.count)
		return;
	
	if(this.state != this.count)
	{
		float rem = this.count - this.state;
		if(IS_PLAYER(actor) && !(this.spawnflags & SPAWNFLAG_NOMESSAGE))
		{
			if(rem >= 6)
				Send_Notification(NOTIF_ONE, actor, MSG_CENTER, CENTER_SEQUENCE_COUNTER);
			else
				Send_Notification(NOTIF_ONE, actor, MSG_CENTER, CENTER_SEQUENCE_COUNTER_FEWMORE, rem);
		}
		return;
	}
	
	this.nextthink = 0;
	
	if(IS_PLAYER(actor) && this.message && this.message != "")
		SUB_PrintMessage(this, actor);
//		centerprint(actor, this.message);
	
	if(this.wait >= 0) 
		this.state = 0;	// repeatable
	//multi_trigger ();
	SUB_UseTargetsSilent(this, actor, trigger);
	if(this.wait > 0)
		this.attack_finished = time + this.wait;
}


/*QUAKED trigger_counter(.5 .5 .5) ? nomessage
Acts as an intermediary for an action that takes multiple inputs.

If nomessage is not set, it will print "1 more.. " etc when triggered and "sequence complete" when finished.

After the counter has been triggered "count" times(default 2), it will fire all of its targets and remove itself.
*/
spawnfunc(trigger_counter)
{
	if(Inhibit_Coop(this) || RemovedOutsideCoop(this))
	{
		delete(this);
		return;
	}
	if(!this.wait)
	{
		if(this.spawnflags & 6) // 2 or 4
			this.wait = 1;
		else
			this.wait = -1;
	}
	// Yoder Sept24, 2021 Horde Merge
	// .count is decremented each use and fires its targets on 0
	// .cnt stores the original .count and restores to this if COUNTER_LOOPS
	if(!this.count)
		this.count = 2;
	if(!(this.spawnflags & SPAWNFLAG_NOMESSAGE) && (!this.message || this.message == ""))
		this.message = "Sequence completed!";

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
				Send_Notification(NOTIF_ONE, actor, MSG_CENTER, CENTER_SEQUENCE_COUNTER);
			else
				Send_Notification(NOTIF_ONE, actor, MSG_CENTER, CENTER_SEQUENCE_COUNTER_FEWMORE, this.count);
		}
		return;
	}
	
	if(IS_PLAYER(actor) && !(this.spawnflags & SPAWNFLAG_NOMESSAGE))
		Send_Notification(NOTIF_ONE, actor, MSG_CENTER, CENTER_SEQUENCE_COMPLETED);

	this.enemy = actor;
	this.delay = 0;
	this.nextthink = 0;
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
	if(Inhibit_Coop(this) || RemovedOutsideCoop(this))
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
