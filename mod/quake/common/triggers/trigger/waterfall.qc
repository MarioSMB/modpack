#ifdef SVQC

void trigger_waterfall_touch(entity this, entity toucher)
{
	// only affect players
	if(!IS_CLIENT(toucher))
		return;

	toucher.velocity = toucher.velocity + this.movedir;
	toucher.velocity_x = toucher.velocity_x + this.count * ( random() - 0.5 );
	toucher.velocity_y = toucher.velocity_y + this.count * ( random() - 0.5 );
}

/*QUAKED trigger_waterfall (.2 .5 .2) ?
 Pushes the player in the direction specified by angles.

 "speed" is the strength of the push (default 50).
 "count" amount of random xy movement to add to velocity (default 100).
*/

spawnfunc(trigger_waterfall)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	InitTrigger(this);
	settouch(this, trigger_waterfall_touch);

	if(!this.count)
		this.count = 100;

	if(!this.speed)
		this.movedir = this.movedir * 50;
	else
		this.movedir = this.movedir * this.speed;
}

#endif
