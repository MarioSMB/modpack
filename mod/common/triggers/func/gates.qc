int qserverflags;

void qgate_use()
{
	self.frame = 1 - self.frame;
}

spawnfunc(func_episodegate)
{
	if(!(qserverflags & this.spawnflags)) { remove(this); return; }

	this.angles = '0 0 0';
	this.movetype = MOVETYPE_PUSH;
	this.solid = SOLID_BSP;
	this.use = qgate_use;
	setmodel(this, this.model);
}

spawnfunc(func_bossgate)
{
	if((qserverflags & 15) == 15) { remove(this); return; }

	this.angles = '0 0 0';
	this.movetype = MOVETYPE_PUSH;
	this.solid = SOLID_BSP;
	this.use = qgate_use;
	setmodel(this, this.model);
}

spawnfunc(trigger_onlyregistered)
{
	spawnfunc_trigger_multiple(this);
}
