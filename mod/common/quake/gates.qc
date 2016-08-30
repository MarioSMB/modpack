#ifdef SVQC
void qgate_use(entity this, entity actor, entity trigger)
{
	this.frame = 1 - this.frame;
}

spawnfunc(func_episodegate)
{
	if(!(serverflags & this.spawnflags)) { delete(this); return; }

	spawnfunc_func_wall(this);

	this.use = qgate_use;
}

spawnfunc(func_bossgate)
{
	if((serverflags & 15) == 15) { delete(this); return; }

	spawnfunc_func_wall(this);

	this.use = qgate_use;
}

spawnfunc(trigger_onlyregistered)
{
	spawnfunc_trigger_multiple(this);
}
#endif
