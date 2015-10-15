#ifdef SVQC

.string map;

void changelevel_inittarget()
{
	spawnfunc_target_changelevel(self);
}

spawnfunc(trigger_changelevel)
{
	entity e = spawn();
	e.chmap = this.map;
	e.think = changelevel_inittarget;
	e.nextthink = time;
	e.target = this.map;

	this.map = "";
	this.target = e.targetname;
	spawnfunc_trigger_multiple(this);
}

#endif
