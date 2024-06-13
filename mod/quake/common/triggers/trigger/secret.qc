#ifdef SVQC

/*QUAKED trigger_secret(.5 .5 .5) ?
secret counter trigger
sounds
1)	secret
2)	beep beep
3)
4)
set "message" to text string
*/
spawnfunc(trigger_secret)
{
	if(Inhibit_Coop(this))
	{
		delete(this);
		return;
	}
	secrets_total += 1;
	this.wait = -1;
	if(!this.message)
		this.message = "You found a secret area!";
	if(!this.sounds)
		this.sounds = 1;
	
	if(this.sounds == 1)
	{
		precache_sound("misc/secret.wav");
		this.noise = "misc/secret.wav";
	}
	else if(this.sounds == 2)
	{
		precache_sound(QUAKE_TALKSOUND);
		this.noise = QUAKE_TALKSOUND;
	}

	spawnfunc_trigger_multiple(this);

	this.classname = "trigger_secret";
}

#endif
