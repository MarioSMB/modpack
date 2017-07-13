#ifdef SVQC

/*QUAKED trigger_relay(.5 .5 .5)(-8 -8 -8)(8 8 8)
This fixed size trigger cannot be touched, it can only be fired by other events.  It can contain killtargets, targets, delays, and messages.
*/
spawnfunc(trigger_relay)
{
	this.use = SUB_UseTargets;
}

#endif
