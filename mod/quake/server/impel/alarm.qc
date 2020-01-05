void stop_alarm(entity this, entity actor, entity trigger)
{
	if(random() < 0.5)
		_sound(this, CHAN_BODY, "enviro/security/onalarm3.wav", 1, ATTN_NONE);
	else
		_sound(this, CHAN_BODY, "enviro/security/onalarm4.wav", 1, ATTN_NONE);
	setthink(this, func_null);
	this.nextthink = 0;
}

void play_alarm2(entity this)
{
	this.use = stop_alarm;
	_sound(this, CHAN_BODY, "enviro/security/onalarm2.wav", 1, ATTN_NONE);
	setthink(this, play_alarm2);
	this.nextthink = time + 4;
}

void play_alarm(entity this, entity actor, entity trigger)
{
	_sound(this, CHAN_BODY, "enviro/security/onalarm1.wav", 1, ATTN_NONE);
	setthink(this, play_alarm2);
	this.nextthink = time + 2;
}

spawnfunc(sound_alarm)
{
	if(!MP_IMPEL) { delete(this); return; }

	precache_sound2("enviro/security/onalarm1.wav");
	precache_sound2("enviro/security/onalarm2.wav");
	precache_sound2("enviro/security/onalarm3.wav");
	precache_sound2("enviro/security/onalarm4.wav");
	this.use = play_alarm;
}
