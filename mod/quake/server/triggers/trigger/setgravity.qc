#ifdef SVQC

void trigger_gravity_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(this.gravity == -1)
		toucher.gravity = 1.0;
	else
		toucher.gravity = this.gravity;
}

/*QUAKED trigger_setgravity (.5 .5 .5) ?
set the gravity of a player
"gravity" what to set the players gravity to
 - 0 (default) normal gravity
 - 1 no gravity
 - 2 almost no gravity
 - ...
 - 101 normal gravity
 - 102 slightly higher gravity
 - ...
 - 1000 very high gravity
*/
spawnfunc(trigger_setgravity)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	InitTrigger(this);
	settouch(this, trigger_gravity_touch);
	if(!this.gravity)
		this.gravity = -1;
	else
		this.gravity = ((this.gravity - 1) / 100);
}

#endif
