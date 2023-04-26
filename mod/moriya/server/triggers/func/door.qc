#ifdef SVQC

spawnfunc(func_door)
{
	_setmodel(this, this.model);
	this.solid = SOLID_BSP;
}

#endif
