void bubble_removetouch(entity this, entity toucher)
{
	delete(this);
}

void make_gib_fall(entity this)
{
	entity bubble = spawn();
	if(random() < 0.2)
		_setmodel(bubble, "progs/rawbone.mdl");
	else if(random() < 0.4)
		_setmodel(bubble, "progs/bone2.mdl");
	if(random() < 0.6)
		_setmodel(bubble, "progs/gib1.mdl");
	else if (random() < 0.8)
		_setmodel(bubble, "progs/rawbone2.mdl");
	else
		_setmodel(bubble, "progs/bone.mdl");

	setorigin(bubble, this.origin);
	set_movetype(bubble, MOVETYPE_FLY);
	bubble.solid = SOLID_BBOX;
	bubble.velocity = '0 0 -250';
	bubble.avelocity = '300 300 300';
	settouch(bubble, bubble_removetouch);
	bubble.classname = "falling gib";
	setsize (bubble, '0 0 0', '0 0 0');
	this.nextthink = time + random() * 1;
	setthink(this, make_gib_fall);
}

void make_gib_fall_use(entity this, entity actor, entity trigger)
{
	make_gib_fall(this);
}

void gibs_fall(entity this)
{
	if(this.targetname && this.targetname != "")
		this.use = make_gib_fall_use;
	else
	{
		this.nextthink = time + 1;
		setthink(this, make_gib_fall);
	}
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
	if(!MP_IMPEL) { delete(this); return; }

	precache_model("progs/bldfall.mdl");
	if(this.targetname && this.targetname != "")
		this.use = make_blood_fall_use;
	else
	{
		this.nextthink = time + 1;
		setthink(this, make_blood_fall);
	}
}
