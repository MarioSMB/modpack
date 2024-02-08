#include "sound.qh"

#ifdef SVQC
.entity buddy;
.float rand;

void sound_setup(entity this, float vol)
{
	if(!this.volume)
		this.volume = vol;
	if(!this.distance)
		this.distance = ATTN_STATIC;
	else if(this.distance == 1)
		this.distance = ATTN_IDLE;
	else if(this.distance == 2)
		this.distance = ATTN_NORM;
	else if(this.distance == 3)
		this.distance = ATTN_NONE;
	
	this.width = 0;
	if(this.noise && this.noise != "")
	{
		// why the HELL copper allows this is beyond me
		this.noise = strzone(strreplace("//", "/", this.noise));
		precache_sound(this.noise);
	}
	
	if(!this.noise1 || this.noise1 == "")
		return;
	this.noise1 = strzone(strreplace("//", "/", this.noise1));
	precache_sound(this.noise1);
	this.width++;

	if(!this.noise2 || this.noise2 == "")
		return;
	this.noise2 = strzone(strreplace("//", "/", this.noise2));
	precache_sound(this.noise2);
	this.width++;

	if(!this.noise3 || this.noise3 == "")
		return;
	this.noise3 = strzone(strreplace("//", "/", this.noise3));
	precache_sound(this.noise3);
	this.width++;

	if(!this.noise4 || this.noise4 == "")
		return;
	this.noise4 = strzone(strreplace("//", "/", this.noise4));
	precache_sound(this.noise4);
	this.width++;
}

void target_sound_use(entity this, entity actor, entity trigger);
void target_sound_use_think(entity this)
{
	target_sound_use(this, NULL, NULL);
}

void sound_delayed(entity on, float _chan, string _noise, float _volume, float _distance, float _delay)
{
	if(!_delay)
	{
		_sound(on, _chan, _noise, _volume, _distance);
		return;
	}
	entity snd = new(sound);
	setorigin(snd, on.origin + 0.5 * (on.mins + on.maxs));
	snd.noise = _noise;
	snd.volume = _volume;
	snd.distance = _distance;
	snd.style = _chan;
	setthink(snd, target_sound_use_think);
	snd.nextthink = time + _delay;
}

string target_sound_next(entity this)
{
	if(this.width == 0)
		return this.noise;
	
	if(this.spawnflags & 1)
	{
		float r = this.lip;
		while (r == this.lip)	// don't play the same sound twice
		{
			this.lip = floor(random() * (this.width + 0.98));
		}
	}
	else
		this.lip = (this.lip + 1) % (this.width + 1);
	
	switch(this.lip)
	{
		case 0:
			return this.noise;
		case 1:
			return this.noise1;
		case 2:
			return this.noise2;
		case 3:
			return this.noise3;
		case 4:
			return this.noise4;
	}
	return this.noise;
}

void target_sound_find(entity this, entity actor)
{
	if(this.buddy)
		return;
	
	if((this.spawnflags & 2) && IS_PLAYER(actor))
	{
		this.buddy = actor;
		return;
	}
	if(this.target && this.target != "")
	{
		this.buddy = find(NULL, targetname, this.target);
		if(!this.buddy)
			this.buddy = this;
		return;
	}
	this.buddy = this;
}

void target_sound_go(entity this)
{
	string snd = target_sound_next(this);
	
	if(this.delay > 0)
	{
		sound_delayed(this.buddy, this.style, snd, this.volume, this.distance, this.delay);
		return;
	}
	_sound(this.buddy, this.style, snd, this.volume, this.distance);
}

void target_sound_think(entity this)
{
	target_sound_go(this);
	if(this.count > 0)
	{
		this.cnt += 1;
		if(this.cnt == this.count)
		{
			this.cnt = 0;
			this.state = 0;
			return;
		}
	}
	this.nextthink = time + this.wait + random() * this.rand;
}

void target_sound_use(entity this, entity actor, entity trigger)
{
	playercount_convert(this, count);
	if(this.spawnflags & 4)	// toggle
	{
		this.state = !this.state;
		if(this.state)
		{
			target_sound_find(this, actor);
			setthink(this, target_sound_think);
			this.nextthink = time;
		}
		else
		{
			this.nextthink = 0;
			this.buddy = NULL;
		}
		return;
	}
	
	if(this.count > 0)
	{
		this.cnt += 1;
		if(this.cnt == this.count)
		{
			this.use = func_null;
			setthink(this, SUB_Remove);
			this.nextthink = time;
			//return;
		}
	}
	target_sound_find(this, actor);
	target_sound_go(this);
	this.buddy = NULL;
}

/*QUAKED target_sound (0.3 0.1 0.6) (-8 -8 -8) (8 8 8) SHUFFLE ON_PLAYER TOGGLE
play a sound when triggered.

"distance" attenuation (integer) - defaults to 0, which is the same as other ambient sounds.
  1 = 'idle' - monster idle sound range
  2 = 'normal' - monster bark sound range
  3 = 'none' - loops everywhere forever (don't use this)
"volume" volume, defaults to 1.0 (full volume)
"noise"  wav to play - don't leave off the ".wav"!
"noise1-4"  add additional wavs to cycle through
"delay"	delay sound after trigger
"count" limit number of uses before self destruction
"wait" time between plays, if TOGGLE
"rand" random extra time between plays, if TOGGLE
"style" force single sound channel (0 = any)

Spawnflags:
"SHUFFLE"	select next sound randomly if more than one noise is specified
"ON_PLAYER"	use activating player as source of sound
"TOGGLE"	trigger to turn on/off instead of firing once ('count' will limit use per activation if set)
*/
/*FGD
@PointClass base(Ambient, Targetname) color(150 0 150) = target_sound : "Custom triggered sound. Will play one sound every time it is triggered.
You can set up to five sounds on this entity to cycle through in order (or shuffle, with the 'random' spawnflag). They will not cut each other off, so triggering this entity more frequently than the length of the sounds will overlap them."
[
	noise(string) : "path to .wav"
	noise1(string) : "optional additional .wav to cycle"
	noise2(string) : "optional additional .wav to cycle"
	noise3(string) : "optional additional .wav to cycle"
	noise4(string) : "optional additional .wav to cycle"
	volume(string) : "Volume" : "1"
	delay(string) : "Delay" : "1"
	count(integer) : "Limit Uses" : 0
	wait(string) : "Time between sounds, if toggle" : 0
	rand(string) : "Random extra time between sounds, if toggle" : 0
	style(integer) : "Force sound channel" : 0
	spawnflags(flags) = 
	[
		1 : "Random next sound" : 0
		2 : "Play on player" : 0
		4 : "Toggle" : 0
	]
	target(target_source) : "Optional target to play sound on"
]
*/
spawnfunc(target_sound)
{
	sound_setup(this, 1);
	this.use = target_sound_use;
	if((this.style < 0) || (this.style > 7))
		this.style = 0;
}
#endif
