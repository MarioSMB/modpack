#ifdef SVQC

/*QUAKED ambient_suck_wind(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_suck_wind)
{
	precache_sound("ambience/suck1.wav");
	ambientsound(this.origin, "ambience/suck1.wav", 1, ATTN_STATIC);
}

/*QUAKED ambient_drone(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_drone)
{
	precache_sound("ambience/drone6.wav");
	ambientsound(this.origin, "ambience/drone6.wav", 0.5, ATTN_STATIC);
}

/*QUAKED ambient_flouro_buzz(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_flouro_buzz)
{
	precache_sound("ambience/buzz1.wav");
	ambientsound(this.origin, "ambience/buzz1.wav", 1, ATTN_STATIC);
}
/*QUAKED ambient_drip(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_drip)
{
	precache_sound("ambience/drip1.wav");
	ambientsound(this.origin, "ambience/drip1.wav", 0.5, ATTN_STATIC);
}
/*QUAKED ambient_comp_hum(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_comp_hum)
{
	precache_sound("ambience/comp1.wav");
	ambientsound(this.origin, "ambience/comp1.wav", 1, ATTN_STATIC);
}
/*QUAKED ambient_thunder(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_thunder)
{
	precache_sound("ambience/thunder1.wav");
	ambientsound(this.origin, "ambience/thunder1.wav", 0.5, ATTN_STATIC);
}
/*QUAKED ambient_light_buzz(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_light_buzz)
{
	precache_sound("ambience/fl_hum1.wav");
	ambientsound(this.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
}
/*QUAKED ambient_swamp1(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_swamp1)
{
	precache_sound("ambience/swamp1.wav");
	ambientsound(this.origin, "ambience/swamp1.wav", 0.5, ATTN_STATIC);
}
/*QUAKED ambient_swamp2(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_swamp2)
{
	precache_sound("ambience/swamp2.wav");
	ambientsound(this.origin, "ambience/swamp2.wav", 0.5, ATTN_STATIC);
}

/*QUAKED ambient_generic (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
spawnfunc(ambient_generic)
{
	if(!MP_MG) { delete(this); return; }
	if(!this.noise || this.noise == "")
	{
		LOG_DEBUG("ambient_generic with no noise. Removing.");
		delete(this);
	}
	if(!this.volume) this.volume = 0.5;
	if(!this.delay) this.delay = 3;
	
	precache_sound(this.noise);
	ambientsound(this.origin, this.noise, this.volume, this.delay);
}

void play_sound_use(entity this, entity actor, entity trigger)
{
	if(this.spawnflags & 1)
	{
		if(this.state == 0)
		{
			this.state = 1;
			_sound(this, this.impulse, this.noise, this.volume, this.speed);
		}
		else
		{
			this.state = 0;
			sound(this, this.impulse, SND_Null, this.volume, this.speed);
		}
	}
	else
		_sound(this, this.impulse, this.noise, this.volume, this.speed);
}

void PlaySoundThink(entity this)
{
	float t = max(this.delay, this.wait * random());
	this.nextthink = time + t;
	play_sound_use(this, NULL, NULL);
}

/*QUAKED play_sound_triggered (0.3 0.1 0.6) (-8 -8 -8) (8 8 8) toggle
play a sound when it is used
"toggle" determines whether sound should be stopped when triggered again
"volume" how loud (1 default full volume)
"noise" sound to play
"impulse" channel on which to play _sound(0-7) (0 automatic is default)
"speed" attenuation factor
	-1 - no attenuation
	 1 - normal
	 2 - idle
	 3 - static
*/
spawnfunc(play_sound_triggered)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	precache_sound(this.noise);
	if(this.volume == 0)
		this.volume = 1;
	if(this.speed == 0)
		this.speed = 1;
	if(this.speed == -1)
		this.speed = 0;
	if(this.spawnflags & 1)
		if(this.impulse == 0)
			this.impulse = 7;
	this.use = play_sound_use;
}

/*QUAKED play_sound(0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
play a sound on a periodic basis
"volume" how loud (1 default full volume)
"noise" sound to play
"wait" random time between sounds (default 20)
"delay" minimum delay between sounds (default 2)
"impulse" channel on which to play _sound(0-7) (0 automatic is default)
"speed" attenuation factor
	-1 - no attenuation
	 1 - normal
	 2 - idle
	 3 - static
*/
spawnfunc(play_sound)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	spawnfunc_play_sound_triggered(this);
	if(this.wait == 0)
		this.wait = 20;
	if(this.delay == 0)
		this.delay = 2;
	setthink(this, PlaySoundThink);
	float t = max(this.delay, this.wait * random());
	this.nextthink = time + t;
}

/*QUAKED random_thunder (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
"wait" random time between strikes (default 20)
"delay" minimum delay between strikes (default 2)
"volume" how loud (1 default full volume)
"speed" attenuation factor
	-1 - no attenuation
	 1 - normal
	 2 - idle
	 3 - static
*/
spawnfunc(random_thunder)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	this.noise = "ambience/thunder1.wav";
	spawnfunc_play_sound(this);
	this.impulse = 6;
}

/*QUAKED random_thunder_triggered (0.3 0.1 0.6) (-10 -10 -8) (10 10 8) toggle
"toggle" determines whether sound should be stopped when triggered again
"volume" how loud (1 default full volume)
"speed" attenuation factor
	-1 - no attenuation
	 1 - normal
	 2 - idle
	 3 - static
*/
spawnfunc(random_thunder_triggered)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	this.noise = "ambience/thunder1.wav";
	spawnfunc_play_sound_triggered(this);
	this.impulse = 6;
}

/*QUAKED ambient_humming (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
  "volume" how loud it should be (0.5 is default)
*/
spawnfunc(ambient_humming)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	if(this.volume == 0)
		this.volume = 0.5;
	precache_sound("ambient/humming.wav");
	ambientsound(this.origin, "ambient/humming.wav", this.volume, ATTN_STATIC);
}

/*QUAKED ambient_rushing (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
  "volume" how loud it should be (0.5 is default)
*/
spawnfunc(ambient_rushing)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	if(this.volume == 0)
		this.volume = 0.5;
	precache_sound("ambient/rushing.wav");
	ambientsound(this.origin, "ambient/rushing.wav", this.volume, ATTN_STATIC);
}

/*QUAKED ambient_running_water (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
  "volume" how loud it should be (0.5 is default)
*/
spawnfunc(ambient_running_water)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	if(this.volume == 0)
		this.volume = 0.5;
	precache_sound("ambient/runwater.wav");
	ambientsound(this.origin, "ambient/runwater.wav", this.volume, ATTN_STATIC);
}

/*QUAKED ambient_fan_blowing (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
  "volume" how loud it should be (0.5 is default)
*/
spawnfunc(ambient_fan_blowing)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	if(this.volume == 0)
		this.volume = 0.5;
	precache_sound("ambient/fanblow.wav");
	ambientsound(this.origin, "ambient/fanblow.wav", this.volume, ATTN_STATIC);
}

/*QUAKED ambient_waterfall (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
  "volume" how loud it should be (0.5 is default)
*/
spawnfunc(ambient_waterfall)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	if(this.volume == 0)
		this.volume = 0.5;
	precache_sound("ambient/waterfal.wav");
	ambientsound(this.origin, "ambient/waterfal.wav", this.volume, ATTN_STATIC);
}

/*QUAKED ambient_riftpower (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
  "volume" how loud it should be (0.5 is default)
*/
spawnfunc(ambient_riftpower)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	if(this.volume == 0)
		this.volume = 0.5;
	precache_sound("ambient/riftpowr.wav");
	ambientsound(this.origin, "ambient/riftpowr.wav", this.volume, ATTN_STATIC);
}

#endif
