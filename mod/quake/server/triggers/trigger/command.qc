#ifdef SVQC

// TODO: remove this, too much potential for breakage!

void trigger_command_use(entity this, entity actor, entity trigger)
{
	if(this.message)
		localcmd(strcat("\n", this.message, "\n"));
}

// the oncount_use part of this trigger makes it virtually useless beyond acting as a counter
// so just replicate it here as a disabled function to avoid the reference
void trigger_command_disabled_use(entity this, entity actor, entity trigger)
{
	int thecount = ((trigger.classname == "counter") ? trigger.state : 0);
	if(thecount == this.count)
		SUB_UseTargets(this, actor, actor);
}

/*QUAKED trigger_command (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
 When triggered, stuffs a command into the console to allow map
 designers to set server variables.

 "message" is the command to send to the console.
*/

spawnfunc(trigger_command)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	this.use = trigger_command_disabled_use;
	setthink(this, func_null);
}

#endif
