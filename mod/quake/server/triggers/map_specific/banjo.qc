/*QUAKED func_levelgate(0 .5 .8)
Inversed version of func_episodegate, prevents access until the required runes have been gathered.
*/
spawnfunc(func_levelgate)
{
	if(serverflags & this.spawnflags)
		return;

	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_PUSH);  // so it doesn't get pushed by anything
	this.solid = SOLID_BSP;
	this.use = func_wall_use;
	_setmodel(this, this.model);
}
