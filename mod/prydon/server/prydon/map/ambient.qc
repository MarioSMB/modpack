#include "ambient.qh"

#include "../subs/reqs.qh"

void doambient(entity this, string soundfile, float volume)
{
	if(CheckStory(this))
		return;
	precache_sound(soundfile);
	ambientsound(this.origin, soundfile, volume, ATTN_STATIC);
}

spawnfunc(ambient_suck_wind)        = { doambient(this, "ambience/suck1.wav",      1);	delete(this); }
spawnfunc(ambient_flouro_buzz)      = { doambient(this, "ambience/buzz1.wav",      1);	delete(this); }
spawnfunc(ambient_drip)             = { doambient(this, "ambience/drip1.wav",      1);	delete(this); }
spawnfunc(ambient_comp_hum)         = { doambient(this, "ambience/comp1.wav",      1);	delete(this); }
spawnfunc(ambient_drone)            = { doambient(this, "ambience/drone6.wav",   0.5);	delete(this); }
spawnfunc(ambient_thunder)          = { doambient(this, "ambience/thunder1.wav", 0.5);	delete(this); }
spawnfunc(ambient_light_buzz)       = { doambient(this, "ambience/fl_hum1.wav",  0.5);	delete(this); }
spawnfunc(ambient_swamp1)           = { doambient(this, "ambience/swamp1.wav",   0.5);	delete(this); }
spawnfunc(ambient_swamp2)           = { doambient(this, "ambience/swamp2.wav",   0.5);	delete(this); }
spawnfunc(ambient)					= { doambient(this, this.noise, 1);}
