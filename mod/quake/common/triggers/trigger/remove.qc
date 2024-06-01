#ifdef SVQC

void remove_touch(entity this, entity toucher)
{
	if(toucher.flags & this.cnt)
		return;
	settouch(toucher, func_null);
	toucher.model = "";
	delete(this); // TODO: shouldn't this be toucher?
//   toucher.nextthink = time + 0.1;
//   toucher.think = SUB_Remove;
}

/*QUAKED trigger_remove (.5 .5 .5) ? ignoremonsters ignoreplayers
Variable sized trigger that removes the thing
that touches it.  Does not affect monsters or
players.
*/
spawnfunc(trigger_remove)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	this.cnt = FL_CLIENT | FL_MONSTER;
	if(this.spawnflags & 1)
		this.cnt &= ~FL_MONSTER;
	if(this.spawnflags & 2)
		this.cnt &= ~FL_CLIENT;

	InitTrigger(this);
	settouch(this, remove_touch);
}

#endif
