#ifdef SVQC

/*QUAKED func_levelgate(0 .5 .8)
Inversed version of func_episodegate, prevents access until the required runes have been gathered.
"svflags" is the flag number for serverflags when checked.
"spawnflags" "1" will make it inversed working just like func_episodegate but with higher bits.
*/
spawnfunc(func_levelgate)
{
	if(this.spawnflags & 1)
	{
		if(!(serverflags & this.svflags))
			return;
	}
	else
	{
		if(serverflags & this.svflags)
			return;
	}

	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_PUSH);  // so it doesn't get pushed by anything
	this.solid = SOLID_BSP;
	this.use = func_wall_use;
	_setmodel(this, this.model);
}

#endif
