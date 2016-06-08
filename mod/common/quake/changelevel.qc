#ifdef SVQC

.string map;

void changelevel_inittarget(entity this)
{
	spawnfunc_target_changelevel(this);
}

spawnfunc(trigger_changelevel)
{
	entity e = spawn();
	e.chmap = this.map;
	setthink(e, changelevel_inittarget);
	e.nextthink = time;
	e.targetname = this.map;

	this.map = "";
	this.target = e.targetname;
	spawnfunc_trigger_multiple(this);
}

#endif
