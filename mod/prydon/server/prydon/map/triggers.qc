void trigger_touch(entity this, entity toucher)
{
	if(toucher.classname == "npc" && (this.spawnflags & 1))
		generictrigger(this, toucher);
	if(toucher.classname == "dummy" && (this.spawnflags & 2))
		generictrigger(this, toucher);
}

spawnfunc(trigger_other)
{
	if(CheckStory(this))
	{
		delete(this);
		return;
	}
	if (!(this.spawnflags))
		this.spawnflags = 3;

	InitTrigger(this);
	this.use = generictrigger;
	settouch(this, trigger_touch);
}
