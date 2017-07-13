#ifdef SVQC

void trigger_skill_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
		
	cvar_set("skill", this.message);
}

/*QUAKED trigger_setskill(.5 .5 .5) ?
sets skill level to the value of "message".
Only used on start map.
*/
spawnfunc(trigger_setskill)
{
	InitTrigger(this);
	settouch(this, trigger_skill_touch);
}

#endif
