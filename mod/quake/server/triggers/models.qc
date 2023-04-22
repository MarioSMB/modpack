void func_wall_use(entity this, entity actor, entity trigger)
{	// change to alternate textures
	this.frame = 1 - this.frame;
}

/*QUAKED func_wall(0 .5 .8) ?
This is just a solid wall if not inhibitted
*/
spawnfunc(func_wall)
{
	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_PUSH);	// so it doesn't get pushed by anything
	this.solid = SOLID_BSP;
	this.use = func_wall_use;
	_setmodel(this, this.model);
}


/*QUAKED func_illusionary(0 .5 .8) ?
A simple entity that looks solid but lets you walk through it.
*/
spawnfunc(func_illusionary)
{
	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_NOT;
	_setmodel(this, this.model);
	//_makestatic_hidden(this);
}

/*QUAKED func_episodegate(0 .5 .8) ? E1 E2 E3 E4
This bmodel will appear if the episode has allready been completed, so players can't reenter it.
*/
spawnfunc(func_episodegate)
{
	if(!(serverflags & this.spawnflags))
		return;			// can still enter episode

	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_PUSH);	// so it doesn't get pushed by anything
	this.solid = SOLID_BSP;
	this.use = func_wall_use;
	_setmodel(this, this.model);
}

/*QUAKED func_bossgate(0 .5 .8) ?
This bmodel appears unless players have all of the episode sigils.
*/
spawnfunc(func_bossgate)
{
	if((serverflags & 15) == 15)
		return;		// all episodes completed
	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_PUSH);	// so it doesn't get pushed by anything
	this.solid = SOLID_BSP;
	this.use = func_wall_use;
	_setmodel(this, this.model);
}
