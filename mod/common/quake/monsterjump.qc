#ifdef SVQC
void monsterjump_touch(entity this, entity toucher)
{
	if(!IS_MONSTER(toucher))
		return;
	if((toucher.flags & FL_FLY) || (toucher.flags & FL_SWIM))
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
