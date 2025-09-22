#ifdef SVQC

///////////////////////////
// Abyss of Pandemonium misc_model

const int MISC_MODEL_ANIMATED = BIT(0);
const int MISC_MODEL_ANIMATED_ONCE = BIT(1);
const int MISC_MODEL_ANIMATED_START_OFF = BIT(2);

///////////////////////////////
// Behaviour for a looping animation
///////////////////////////////

void misc_model_think_loop(entity this)
{
	this.frame += 1;
	if(this.frame == this.cnt)
		this.frame = this.count; // Back to start
	this.nextthink = time + 0.1;
}

void misc_model_use_loop(entity this, entity actor, entity trigger)
{
	if(this.spawnflags & MISC_MODEL_ANIMATED_START_OFF)
	{
		this.spawnflags &= ~MISC_MODEL_ANIMATED_START_OFF;
		setthink(this, misc_model_think_loop);
		misc_model_think_loop(this);
	}
	else
	{
		this.spawnflags |= MISC_MODEL_ANIMATED_START_OFF;
		setthink(this, func_null);
		this.nextthink = 0;
	}
	
}

///////////////////////////////
// Behaviour for a single animation
///////////////////////////////

void misc_model_think_once(entity this)
{
	this.frame += 1;
	if(this.frame < this.cnt)
		this.nextthink = time + 0.1;
}

void misc_model_use_once(entity this, entity actor, entity trigger)
{
	this.frame = this.count;
	setthink(this, misc_model_think_once);
	this.nextthink = time + 0.1;
}

void misc_model_aop(entity this)
{
	if(!this.model || this.model == "")
	{
		objerror(this, "misc_model with no model specified");
		return;
	}
	precache_model(this.model);
	_setmodel(this, this.model);
	setorigin(this, this.origin);
	this.solid = SOLID_NOT;

	if(this.spawnflags == 0)
		return;

	if((!this.targetname || this.targetname == "") && !this.impulse && this.pos1 == '0 0 0')
		return;

	if(this.cnt < this.frame)
	{
		objerror(this, "misc_model with invalid frame range (cnt < frame)");
		return;
	}
	if(this.targetname == "")
	{
		objerror(this, "misc_model with no targetname");
		return;
	}
	this.count = this.frame;
	
	if(this.spawnflags & MISC_MODEL_ANIMATED_ONCE)
	{
		this.use = misc_model_use_once;
	}
	else if(this.spawnflags & (MISC_MODEL_ANIMATED | MISC_MODEL_ANIMATED_START_OFF))
	{
		this.use = misc_model_use_loop;
		// Stupid way to do it but just flip the bit flag and pretend we just used it.
		this.spawnflags ^= MISC_MODEL_ANIMATED_START_OFF;
		misc_model_use_loop(this, NULL, NULL);
	}
}

///////////////////////////////

// alkaline version

const int MISC_MODEL_GRAVITY = 1;
const int MISC_MODEL_SOLID = 2;
const int MISC_MODEL_STARTOFF = 4;
const int MISC_MODEL_DONTMAKESTATIC = 8;

.vector centeroffset;
.vector mdlsz;
.float first_frame, last_frame;

/*
 * wrap
 *
 * Limits the given value to the given range and will wrap the value to the
 * the other end of the range if exceeded.
 *
 * value: A number
 *
 * minValue: The minimum value of the range
 *
 * maxValue: The maximum value of the range
 *
 * Returns: A number within the given range.
 */
float wrap(float value, float minValue, float maxValue)
{
	float range = maxValue - minValue;
	return ((value - minValue) % (range + 1)) + minValue;
}

void misc_model_use(entity this, entity actor, entity trigger)
{
	if(this.active == ACTIVE_ACTIVE)
	{
		if(this.spawnflags & MISC_MODEL_SOLID)
			this.solid = SOLID_NOT;
		this.model = "";

		this.active = ACTIVE_NOT;
		setsize(this, this.mins, this.maxs);
		setorigin(this, this.origin);
	}
	else
	{
		if(this.spawnflags & MISC_MODEL_SOLID)
			this.solid = SOLID_BBOX;
		this.model = this.mdl;

		this.active = ACTIVE_ACTIVE;
		setsize(this, this.mins, this.maxs);
		setorigin(this, this.origin);
	}
}

void misc_model_think(entity this)
{
	this.nextthink = time + fabs(this.speed);
	if(this.active != ACTIVE_ACTIVE)
		return;

	float myspeed = 0;
	if(this.speed > 0)
		myspeed = 1;
	else if(this.speed < 0)
		myspeed = -1;

	this.frame = this.frame + myspeed;
	this.frame = wrap(this.frame, this.first_frame, this.last_frame);
}

void misc_model_alkaline(entity this)
{
	if(!this.mdl || this.mdl == "")
	{
		objerror(this, "Model not defined");
		return;
	}

	if(this.mdlsz == '0 0 0')
		this.mdlsz = '32 32 32';
	
	vector vmin, vmax;
	
	vmin.x = this.centeroffset_x - (this.mdlsz_x * 0.5);
	vmin.y = this.centeroffset_y - (this.mdlsz_y * 0.5);
	vmin.z = this.centeroffset_z - (this.mdlsz_z * 0.5);
	
	vmax.x = this.centeroffset_x + (this.mdlsz_x * 0.5);
	vmax.y = this.centeroffset_y + (this.mdlsz_y * 0.5);
	vmax.z = this.centeroffset_z + (this.mdlsz_z * 0.5);

	if(this.spawnflags & MISC_MODEL_GRAVITY)
		set_movetype(this, MOVETYPE_TOSS);
	else
		set_movetype(this, MOVETYPE_NONE);

	if(this.spawnflags & MISC_MODEL_SOLID)
		this.solid = SOLID_BBOX;
	else
		this.solid = SOLID_NOT;

	precache_model(this.mdl);
	_setmodel(this, this.mdl);
	setsize(this, vmin, vmax);

	this.use = misc_model_use;
	
	if(!this.frame)
		this.frame = this.first_frame;
 
	if(this.last_frame)
	{
		// if it as a custom animation range
		// Default animation speed to 10 fps
		if(!this.speed)
			this.speed = 0.1;

		this.nextthink = time + this.speed;
		setthink(this, misc_model_think);
	}

	if(this.spawnflags & MISC_MODEL_STARTOFF)
		this.active = ACTIVE_ACTIVE;
	else
		this.active = ACTIVE_NOT;

	misc_model_use(this, NULL, NULL);
}

//////

/// copper
const int SPAWN_MODEL_TOGGLEVIS = 1;
const int SPAWN_MODEL_STARTINVIS = 2;
const int SPAWN_MODEL_ANIMONCE = 4;

.int oldstyle;

void misc_model_animate(entity this)
{
	vector anim;
	if(this.state)
		anim = this.pos2;
	else
		anim = this.pos1;
	
	this.frame += 1;
	if(this.frame > anim_z)
	{
		this.frame = anim_x;
		if((this.spawnflags & SPAWN_MODEL_ANIMONCE) && !this.state)
		{
			this.state = !this.state;
			this.frame = this.pos1_y;
			this.nextthink = time + this.speed;
			return;
		}
	}
	this.nextthink = time + this.speed;
}

void misc_model_use_copper(entity this, entity actor, entity trigger)
{
	this.state = !this.state;
	if(this.spawnflags & SPAWN_MODEL_TOGGLEVIS)
	{
		if(this.state)
		{
			this.modelindex = this.oldstyle;
			_setmodel(this, this.model);
			setsize(this, '-16 -16 -16', '16 16 16');
			if(this.pos1 == '0 0 0')
			{
				this.nextthink = time + this.speed;
				setthink(this, misc_model_animate);
			}
		}
		else
		{
			this.oldstyle = this.modelindex;
			this.modelindex = 0;
			this.nextthink = 0;
		}
	}
	else
	{
		if(this.state)
			this.frame = this.pos2_y;
		else
			this.frame = this.pos1_y;
		this.nextthink = time + this.speed;
		setthink(this, misc_model_animate);
	}
}

void misc_model_copper(entity this)
{ 
	precache_model(this.model);
	
	if(this.mangle != '0 0 0')
		this.angles = this.mangle;
	else if(this.angles != '0 0 0')
	{
		if(this.angles == '0 -1 0')
			this.angles = '-90 0 0';
		else if(this.angles == '0 -2 0')
			this.angles = '90 0 0';
	}
	if(this.ideal_yaw)
		this.angles_y = random() * 360;
	this.solid = SOLID_NOT;
	_setmodel(this, this.model);
	setsize(this, '-16 -16 -16', '16 16 16');
	
	set_movetype(this, MOVETYPE_NONE);
	
	if((!this.targetname || this.targetname == "") && !this.impulse && this.pos1 == '0 0 0')
		return;
	
	if(!this.speed)
		this.speed = 0.1;
		
	// toggle animation
	if(!this.targetname || this.targetname == "")
	{
		this.use = misc_model_use_copper;
		if(this.spawnflags & SPAWN_MODEL_STARTINVIS)
		{
			this.oldstyle = this.modelindex;
			this.modelindex = 0;
			this.state = 0;
		}
		else
			this.state = 1;
	}
	if(this.pos1 == '0 0 0')
	{
		this.frame = this.pos1_y;
		setthink(this, misc_model_animate);
		this.nextthink = time + 0.1;
	}		
}

spawnfunc(misc_model)
{
	// HACK: we use the AOP version of misc_model for the mumbo skull!
	if((world.model == "maps/quake.bsp" && this.model == "models/mumbo.mdl") || IsMGMap())
	{
		misc_model_aop(this);
		return;
	}

	if(this.model && this.model != "")
	{
		misc_model_copper(this);
		return;
	}

	misc_model_alkaline(this);
}

#endif
