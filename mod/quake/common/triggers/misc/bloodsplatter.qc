#ifdef SVQC

void bubble_removetouch(entity this, entity toucher)
{
	delete(this);
}

void make_blood_fall(entity this)
{
	entity bubble = spawn();
	_setmodel(bubble, "progs/bldfall.mdl");
	if(this.classname == "impaler")
		setorigin(bubble, this.origin - v_forward * 16);
	else
		setorigin(bubble, this.origin);
	set_movetype(bubble, MOVETYPE_FLY);
	bubble.solid = SOLID_BBOX;
	bubble.velocity = '0 0 -900';
	settouch(bubble, bubble_removetouch);
	bubble.classname = "falling_blood";
	setsize(bubble, '0 0 0', '0 0 0');
	this.nextthink = time + random();
	setthink(this, make_blood_fall);
	if(this.classname == "impaler" && !this.enemy)
		delete(this);
}

void make_blood_fall_use(entity this, entity actor, entity trigger)
{
	make_blood_fall(this);
}

spawnfunc(misc_bloodspitter)
{
	precache_model("progs/bldfall.mdl");
	if(this.targetname && this.targetname != "")
		this.use = make_blood_fall_use;
	else
	{
		this.nextthink = time + 1;
		setthink(this, make_blood_fall);
	}
}


#endif
