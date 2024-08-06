#ifdef SVQC

void trigger_onlyregistered_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(this.attack_finished > time)
		return;

	bool isregistered = true;
#if 0
	if(!autocvar_g_registered)
		isregistered = false;
#endif

	if(isregistered)
	{
		this.message = "";
		SUB_UseTargets(this, NULL, toucher);
		delete(this);
		return;
	}

	// if we get here, game is unregistered

	this.attack_finished = time + 2;
	if(this.message != "")
	{
		centerprint(toucher, this.message);
		_sound(toucher, CH_PLAYER, QUAKE_TALKSOUND, 1, ATTN_NORM);
	}
}

/*QUAKED trigger_onlyregistered(.5 .5 .5) ?
Only fires if playing the registered version, otherwise prints the message
*/
spawnfunc(trigger_onlyregistered)
{
	precache_sound(QUAKE_TALKSOUND);
	InitTrigger(this);
	settouch(this, trigger_onlyregistered_touch);
}

#endif
