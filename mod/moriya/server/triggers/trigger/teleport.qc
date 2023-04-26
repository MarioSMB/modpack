#ifdef SVQC

spawnfunc(target_teleporter) {}
spawnfunc(misc_teleporter_dest) {}

void teleporter_teleport(entity this)
{
	entity tgt = find(NULL, targetname, this.target);
	setorigin(this.enemy, tgt.origin);
	this.enemy = NULL;
}

void teleporter_touch(entity this, entity toucher)
{
	if(this.enemy) return;
	if(!IS_PLAYER(toucher)) return;
	entity tgt = find(NULL, targetname, this.target);
	if(!tgt) return;
	this.enemy = toucher;
	this.nextthink = time + 0.5;
	setthink(this, teleporter_teleport);
}

spawnfunc(trigger_teleport)
{
	_setmodel(this, this.model);
	this.modelindex = 0;
	this.solid = SOLID_TRIGGER;
	settouch(this, teleporter_touch);
}


#endif
