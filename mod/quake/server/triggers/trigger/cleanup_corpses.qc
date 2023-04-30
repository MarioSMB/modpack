#ifdef SVQC

void trigger_cleanup_corpses_use(entity this, entity actor, entity trigger)
{
	FOREACH_ENTITY_FLAGS(flags, FL_MONSTER,
	{
		if(it.health <= 0)
			delete(it);
	});
	delete(this);
}

spawnfunc(trigger_cleanup_corpses)
{
	if(!MP_MG) { delete(this); return; }
	if(coop == 0) { delete(this); return; }
	this.use = trigger_cleanup_corpses_use;
}

#endif
