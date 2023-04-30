#ifdef SVQC

void trigger_changetarget_use(entity this, entity actor, entity trigger)
{
	SUB_SwitchTargets(target, this.target, this.killtarget);
}

spawnfunc(trigger_changetarget)
{
	if(!MP_MG) { delete(this); return; }
	if(!this.target || this.target == "")
		objerror(this, "Missing target.");
	if(!this.killtarget || this.killtarget == "")
		objerror(this, "Missing target to change to.");
	this.use = trigger_changetarget_use;
}

#endif
