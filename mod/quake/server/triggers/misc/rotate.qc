#ifdef SVQC

/*QUAKED info_rotate (0.4 1.0 0.6) (-8 -8 -8) (8 8 8) 
Used to indicate center of rotation.
*/
spawnfunc(info_rotate_axis) 
{
	delete(this);
}    

/*
===============================================================================
Continuous rotation
this.state     = state: either off, on, accel up, or deccel down.
this.avelocity = rotation degrees per second
this.speed     = current fraction of angluar velocity
this.distance  = change in this.speed per second, negative if decelerating
this.delay     = editor field for how long the acceleration should take
===============================================================================
*/

enum
{
	RotateStateOff,
	RotateStateAccelUp,
	RotateStateOn,
	RotateStateDecelDown
};

void rotate_object_continuously_tick(entity this, float dt)
{
	this.angles_x = anglemods(this.angles_x + this.avelocity_x * dt);
	this.angles_y = anglemods(this.angles_y + this.avelocity_y * dt);
	this.angles_z = anglemods(this.angles_z + this.avelocity_z * dt);
}

void rotate_object_tween_tick(entity this, float dt)
{
	this.speed += this.distance * dt;
	this.speed = bound(0, this.speed, 1);
	if(this.speed == 0)
	{
		this.state = RotateStateOff;
		RemoveFrameTickEntity(this);
		return;
	}
	if(this.speed == 1)
	{
		this.state = RotateStateOn;
		this.tick = rotate_object_continuously_tick;
		this.tick(this, dt);
		return;
	}
	this.angles_x = anglemods(this.angles_x + this.avelocity_x * dt * this.speed);
	this.angles_y = anglemods(this.angles_y + this.avelocity_y * dt * this.speed);
	this.angles_z = anglemods(this.angles_z + this.avelocity_z * dt * this.speed);
}

void rotate_object_continuously_use(entity this, entity actor, entity trigger)
{
	if(this.delay <= 0)
	{
		//No acceleration, just toggle on or off
		if(this.state == RotateStateOff)
		{
			this.state = RotateStateOn;
			RegisterFrameTickEntity(this);
		}
		else
		{
			this.state = RotateStateOff;
			RemoveFrameTickEntity(this);
		}
		return;
	}

	switch(this.state)
	{
		case RotateStateOff:
			this.state = RotateStateAccelUp;
			this.tick = rotate_object_tween_tick;
			this.distance = fabs(this.distance);
			RegisterFrameTickEntity(this);
			return;
			
		case RotateStateAccelUp:
			this.state = RotateStateDecelDown;
			this.tick = rotate_object_tween_tick;
			this.distance = -fabs(this.distance);
			return;
			
		case RotateStateOn:
			this.state = RotateStateDecelDown;
			this.tick = rotate_object_tween_tick;
			this.distance = -fabs(this.distance);
			return;
		
		case RotateStateDecelDown:
			this.state = RotateStateAccelUp;
			this.tick = rotate_object_tween_tick;
			this.distance = fabs(this.distance);
			return;
	}
}

/*QUAKED rotate_object_continuously (0.4 1.0 0.6) (? ? ?) (? ? ?) START_OFF 
Non-solid object that rotates continuously.
Trigger to turn on and off.
*/
spawnfunc(rotate_object_continuously)
{
	if(!MP_MG) { delete(this); return; }
	if(this.avelocity == '0 0 0')
		this.avelocity = '0 30 0';
	if(this.delay > 0)
		this.distance = 1 / this.delay;

	if(this.spawnflags & SOLID_BSP)
	{
		set_movetype(this, MOVETYPE_PUSH);
		this.solid = SOLID_BSP;
	}
	else
	{
		set_movetype(this, MOVETYPE_NONE);
		this.solid = SOLID_NOT;
	}
	this.angles = '0 0 0';
	if(this.pos2)
		setorigin(this, this.pos2);
	_setmodel(this, this.model);
	
	this.use = rotate_object_continuously_use;
	this.tick = rotate_object_continuously_tick;

	if(this.spawnflags & START_OFF)
		this.state = RotateStateOff;
	else
	{
		this.state = RotateStateOn;
		this.speed = 1;
		RegisterFrameTickEntity(this);
	}
}


#endif
