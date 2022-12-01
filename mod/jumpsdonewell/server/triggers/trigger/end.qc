#ifdef SVQC

.float end1_touch_time;
.float end2_touch_time;

void end2_touch(entity this, entity toucher)
{
	if(time < toucher.end1_touch_time)
		return;
	toucher.end1_touch_time = time + 20;
	msg_entity = toucher;
	WriteHeader(MSG_ONE, TE_CSQC_END2);
}

spawnfunc(trigger_end2)
{
	_setmodel(this, this.model);
	this.modelindex = 0;
	this.solid = SOLID_TRIGGER;
	settouch(this, end2_touch);
}

void end1_touch(entity this, entity toucher)
{
	if(time < toucher.end2_touch_time)
		return;
	toucher.end2_touch_time = time + 20;

	if (toucher.max_health < 8)
	{
		msg_entity = toucher;
		WriteHeader(MSG_ONE, TE_CSQC_END1);
	}
	else
	{
		entity door = find(NULL, classname, "func_door");
		if (!door) return;
		pointparticles(EFFECT_ENEMY_DIE, (door.absmin + door.absmax) * 0.5, '0 0 1', 1);
		sound(door, CHAN_AUTO, SND_SWORD2, 1, ATTEN_NORM);
		delete(door);
	}
}

spawnfunc(trigger_end1)
{
	_setmodel(this, this.model);
	this.modelindex = 0;
	this.solid = SOLID_TRIGGER;
	settouch(this, end1_touch);
}

#endif
