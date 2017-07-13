#ifdef SVQC

void trigger_onlyregistered_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(this.attack_finished > time)
		return;

	this.attack_finished = time + 2;
	if(autocvar_registered)
	{
		this.message = "";
		SUB_UseTargets(this, NULL, toucher);
		delete(this);
	}
	else
	{
		if(this.message != "")
		{
			centerprint(toucher, this.message);
			_sound(toucher, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
		}
	}
}

/*QUAKED trigger_onlyregistered(.5 .5 .5) ?
Only fires if playing the registered version, otherwise prints the message
*/
spawnfunc(trigger_onlyregistered)
{
	precache_sound("misc/talk.wav");
	InitTrigger(this);
	settouch(this, trigger_onlyregistered_touch);
}

#endif
