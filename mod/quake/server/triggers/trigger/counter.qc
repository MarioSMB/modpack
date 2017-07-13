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
		multi_trigger(this);
	}
	else
	{
		if(IS_PLAYER(actor) && (this.spawnflags & SPAWNFLAG_NOMESSAGE))
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
	this.wait = -1;
	if(!this.count)
		this.count = 2;

	this.use = counter_use;
}

#endif
