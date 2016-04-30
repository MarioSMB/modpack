#ifdef SVQC

void light_use(entity this, entity actor, entity trigger)
{
	if(this.spawnflags & 1)
	{
		lightstyle(this.style, "m");
		this.spawnflags &= ~1;
	}
	else
	{
		lightstyle(this.style, "a");
		this.spawnflags |= 1;
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

SOUND(AMBIENT_FLURO_HUM1, "ambience/fl_hum1");

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

	ambientsound(this.origin, SND(AMBIENT_FLURO_HUM1), VOL_BASE * 0.5, ATTEN_STATIC);
}

MODEL(LIGHT_FLAME2, "progs/flame2.mdl");
SOUND(AMBIENT_FIRE1, "ambience/fire1");

spawnfunc(light_flame_large_yellow)
{
	setmodel(this, MDL_LIGHT_FLAME2);
	this.frame = 1;

	ambientsound(this.origin, SND(AMBIENT_FIRE1), VOL_BASE * 0.5, ATTEN_STATIC);
}

#endif
