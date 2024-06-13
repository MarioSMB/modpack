#ifdef SVQC

void particle_think(entity this)
{
	float thinktime, intensity;

	if(this.weapon >= 0)
		thinktime = this.weapon;
	else
		thinktime = random() * this.weapon * -1;
	if(this.owner.frags >= 0)
		intensity = this.owner.frags;
	else
		intensity = random() * this.owner.frags * -1;
	particle(this.origin, '0 0 0', this.owner.colormap, intensity);
	this.nextthink = time + thinktime;
	if(this.currentammo < time)
		delete(this);
}

void pixel_think(entity this)
{
	entity part = spawn();
	float r = random();
	setorigin(part, this.origin);
	if(r < 0.05)
		_sound(this, CHAN_AUTO, "ambience/pixels.wav", 1, ATTN_NORM);
	if(this.spawnflags)
		set_movetype(part, MOVETYPE_TOSS);
	else
		set_movetype(part, MOVETYPE_FLYMISSILE);
	if(this.speed >= 0)
		part.velocity = this.movedir * this.speed;
	else
		part.velocity = (((this.movedir * random()) * this.speed) * -1);
	part.weapon = this.weapon;
	part.nextthink = time;
	setthink(part, particle_think);
	part.owner = this;
	if(this.currentammo >= 0)
		part.currentammo = time + this.currentammo;
	else
		part.currentammo = (time + ((random() * this.currentammo) * -1));
	if(this.teleport_time >= 0)
		this.nextthink = time + this.teleport_time;
	else
		this.nextthink = (time + ((random() * this.teleport_time) * -1));
}

spawnfunc(misc_pixel)
{
	precache_model2("progs/null.mdl");
	precache_sound2("ambience/pixels.wav");
	setthink(this, pixel_think);
	this.nextthink = time;
	this.teleport_time = this.teleport_time / 100;
	this.currentammo = this.currentammo / 100;
	this.weapon = this.weapon / 100;
}

#endif
