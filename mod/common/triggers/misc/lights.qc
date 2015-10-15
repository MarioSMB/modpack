#ifdef SVQC

void light_use()
{
	if(self.spawnflags & 1)
	{
		lightstyle(self.style, "m");
		self.spawnflags &= ~1;
	}
	else
	{
		lightstyle(self.style, "a");
		self.spawnflags |= 1;
	}
}

spawnfunc(qlight)
{
	if(this.style >= 32)
	{
		this.use = light_use;
		if(this.spawnflags & 1)
			lightstyle(this.style, "a");
		else
			lightstyle(this.style, "m");
	}
}

spawnfunc(light_fluoro)
{
	if(this.style >= 32)
	{
		this.use = light_use;
		if(this.spawnflags & 1)
			lightstyle(this.style, "a");
		else
			lightstyle(this.style, "m");
	}

	precache_sound("ambience/f1_hum1.wav");
	ambientsound(this.origin, "ambience/fl_hum1.wav", VOL_BASE * 0.5, ATTEN_STATIC);
}

#endif
