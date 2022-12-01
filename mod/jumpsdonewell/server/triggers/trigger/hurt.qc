#ifdef SVQC

void hurt_touch(entity this, entity toucher)
{
	if(toucher.takes_damage)
		damage(this, toucher, 10000);
}

spawnfunc(trigger_hurt)
{
	_setmodel(this, this.model);
	this.modelindex = 0;
	this.solid = SOLID_TRIGGER;
	settouch(this, hurt_touch);
}

#endif
