#ifdef SVQC

void trigger_decoy_touch(entity this, entity toucher)
{
	if(!(toucher.flags & FL_DECOY))
		return;
	settouch(this, func_null);
	this.nextthink = time + 0.1;
	setthink(this, SUB_Remove);
	SUB_UseTargets(this, toucher.realowner, toucher);
}

/*QUAKED trigger_decoy_use (.5 .5 .5) ?
 only the decoy player can trigger this
 once triggers, all targets are used
*/

spawnfunc(trigger_decoy_use)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	if(deathmatch) { delete(this); return; }

	InitTrigger(this);
	settouch(this, trigger_decoy_touch);
}

#endif
