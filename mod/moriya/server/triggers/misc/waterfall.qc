#ifdef SVQC
spawnfunc(misc_waterfall)
{
	setmodel(this, MDL_WATERFALL);
	this.effects = EF_NOSHADOW;
}

spawnfunc(ambient_waterfall)
{
	ambientsound(this.origin, SND(WATERFALL_AMBIENT), 0.6, 0.95);
}
#endif
