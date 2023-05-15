void(string soundfile, float volume) doambient =
{
	if (CheckStory(self))
		return;
	precache_sound (soundfile);
	ambientsound (self.origin, soundfile, volume, ATTN_STATIC);
};


void() ambient_suck_wind        = {doambient("ambience/suck1.wav",      1);	remove(self);};
void() ambient_flouro_buzz      = {doambient("ambience/buzz1.wav",      1);	remove(self);};
void() ambient_drip             = {doambient("ambience/drip1.wav",      1);	remove(self);};
void() ambient_comp_hum         = {doambient("ambience/comp1.wav",      1);	remove(self);};
void() ambient_drone            = {doambient("ambience/drone6.wav",   0.5);	remove(self);};
void() ambient_thunder          = {doambient("ambience/thunder1.wav", 0.5);	remove(self);};
void() ambient_light_buzz       = {doambient("ambience/fl_hum1.wav",  0.5);	remove(self);};
void() ambient_swamp1           = {doambient("ambience/swamp1.wav",   0.5);	remove(self);};
void() ambient_swamp2           = {doambient("ambience/swamp2.wav",   0.5);	remove(self);};
void() ambient			= {doambient(self.noise, 1);};
