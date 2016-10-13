#ifdef SVQC
void monsterjump_touch(entity this, entity toucher)
{
	if(toucher.flags & (FL_MONSTER | FL_FLY | FL_SWIM) != FL_MONSTER)
		return;

	trigger_push_touch(this, toucher);
}

spawnfunc(trigger_monsterjump)
{
	this.noise = SND(Null);

	spawnfunc_trigger_push(this);

	settouch(this, monsterjump_touch);
}
#endif
