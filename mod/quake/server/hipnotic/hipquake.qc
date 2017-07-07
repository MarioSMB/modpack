/* Earthquake QuickC program
	 By Jim Dose'  9/13/96
	 Copyright (c)1996 Hipnotic Interactive, Inc.
	 All rights reserved.
	 Distributed (unsupported) on 3.12.97
*/
//JIM
float earthquake;
bool quakeactive;

void StopEarthQuake()
{
	earthquake = 0;
}

PRECACHE(EarthQuake)
{
	if(!MP_HIPNOTIC)
		return;

	StopEarthQuake(); // reset it on init
}

void EarthQuakeTime(float value)
{
	earthquake = max(earthquake, value + time);
}

void earthquake_postthink(entity this)
{
	if(earthquake > time)
	{
		if(!quakeactive)
		{
			_sound(this, CHAN_VOICE, "misc/quake.wav", 1, ATTN_NONE);
			quakeactive = true;
		}
//      lastearthquake = 1;
//      this.savedz = this.view_ofs_z;
		if(this.flags & FL_ONGROUND)
		{
//         	this.view_ofs_z = this.view_ofs_z - 5 + random() * 10;
			this.velocity = this.velocity + (random() * '0 0 150');
		}
	}
	else
	{
		if(quakeactive)
		{
			_sound(this, CHAN_VOICE, "misc/quakeend.wav", 1, ATTN_NONE);
			quakeactive = false;
		}
	}
}

void earthquake_use(entity this, entity actor, entity trigger)
{
	EarthQuakeTime(this.dmg);
}

/*QUAKED func_earthquake (0 0 0.5) (0 0 0) (32 32 32)
Causes an earthquake.  Triggers targets.

"dmg" is the duration of the earthquake.  Default is 0.8 seconds.
*/

spawnfunc(func_earthquake)
{
	quakeactive = false;
	precache_sound("misc/quake.wav");
	precache_sound("misc/quakeend.wav");
	this.classname = "earthquake";
	this.use = earthquake_use;
	setthink(this, func_null);
	if(!this.dmg)
		this.dmg = 0.8;
}
