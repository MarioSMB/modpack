#ifdef SVQC

.float waitmin, waitmax;

void misc_drip_bouncetouch(entity this, entity toucher)
{
	if(toucher.solid == SOLID_TRIGGER)
		return;
	delete(this);
}

void misc_drip_touch(entity this, entity toucher)
{
	this.solid = SOLID_NOT;

	// mute
	if(!(this.spawnflags & 2))
	{
		float r = random();
		string dripsnd;

		if(r < 0.25) dripsnd = "misc/singledrip1.wav";
		else if(r < 0.5) dripsnd = "misc/singledrip2.wav";
		else if(r < 0.75) dripsnd = "misc/singledrip3.wav";
		else dripsnd = "misc/singledrip4.wav";

		_sound(this, CH_TRIGGER_SINGLE, dripsnd, 0.1, ATTN_STATIC);
	}
	
	// if no bounce is off
	if(!(this.spawnflags & 4))
	{
		traceline(this.origin + '0 0 2', this.origin - '0 0 2', false, this);
		vector angle_normal = vectoangles(trace_plane_normal);

		for(float i = 0; i < 3; i++)
		{
			entity e = spawn();
			e.classname = "misc_drip_bounce";
			set_movetype(e, MOVETYPE_BOUNCE);
			e.solid = SOLID_TRIGGER;
			setorigin(e, this.origin);
			_setmodel(e, this.model);
			setsize(e, '0 0 0', '0 0 0');
			settouch(e, misc_drip_bouncetouch);
			setthink(e, SUB_Remove);
			e.nextthink = time + 1;

			// create the initial drip vector
			makevectors(vec3(-50 - random()*15, 360/3*i + crandom()*30, 0));

			// rotate the vector 90deg so it's facing front
			vector v_drip = vec3(v_forward.z, v_forward.y, -v_forward.x);

			// negate X axis to account for makevectors
			makevectors(vec3(-angle_normal_x, angle_normal_y, angle_normal_z));

			// reorient the drip vector around the surface normal
			e.velocity = (v_forward * v_drip.x - v_right*v_drip.y + v_up*v_drip.z) * (130 + random() * 40);//vlen(this.velocity)/4;
		}
	}
	delete(this);
}

void misc_drip_use(entity this, entity actor, entity trigger)
{
	if(this.active != ACTIVE_ACTIVE)
		this.active = ACTIVE_ACTIVE;
	else
		this.active = ACTIVE_NOT;
}

void misc_drip_spawn(entity this)
{
	entity e = spawn();

	set_movetype(e, MOVETYPE_TOSS);
	e.solid = SOLID_BBOX;
	setorigin(e, this.origin);
	_setmodel(e, this.mdl);
	setsize(e, '0 0 0', '0 0 0');
	e.owner = this;
	settouch(e, misc_drip_touch);
	setthink(e, SUB_Remove);
	e.nextthink = time + 5;
}

void misc_drip_think(entity this)
{
	this.nextthink = time + this.waitmin + random()*(this.waitmax - this.waitmin);
	if(this.active != ACTIVE_ACTIVE)
		return;

	misc_drip_spawn(this);
}

spawnfunc(misc_drip)
{
	if(!this.mdl || this.mdl == "")
		this.mdl = "progs/drip.spr";
	precache_model(this.mdl);

	// mute
	if(!(this.spawnflags & 2))
	{
		precache_sound("misc/singledrip1.wav");
		precache_sound("misc/singledrip2.wav");
		precache_sound("misc/singledrip3.wav");
		precache_sound("misc/singledrip4.wav");
	}

	setthink(this, misc_drip_think);
	this.use = misc_drip_use;

	if(!this.waitmin)
		this.waitmin = 2;
	if(!this.waitmax)
		this.waitmax = 3;
	float tmin = min(this.waitmin, this.waitmax);
	float tmax = max(this.waitmin, this.waitmax);
	this.waitmin = tmin;
	this.waitmax = tmax;
	// start off
	if(this.spawnflags & 1)
		this.active = ACTIVE_NOT;
	else
		this.active = ACTIVE_ACTIVE;

	this.nextthink = time + this.waitmin + random()*(this.waitmax - this.waitmin);
}

#endif
