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
	if(earthquake > time && IS_ONGROUND(this))
		this.velocity = this.velocity + (random() * '0 0 150');
}

void earthquake_frame()
{
	if(earthquake > time)
	{
		if(!quakeactive)
		{
			soundat(NULL, '0 0 0', CH_TRIGGER_SINGLE, "misc/quake.wav", 1, ATTEN_NONE); // just do it at world origin?
			quakeactive = true;
		}
	}
	else
	{
		if(quakeactive)
		{
			stopsound(NULL, CH_TRIGGER_SINGLE);
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
	if(!MP_HIPNOTIC) { delete(this); return; }
	
	quakeactive = false;
	precache_sound("misc/quake.wav");
	precache_sound("misc/quakeend.wav");
	this.classname = "earthquake";
	this.use = earthquake_use;
	setthink(this, func_null);
	if(!this.dmg)
		this.dmg = 0.8;
}
