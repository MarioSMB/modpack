void PM_ClientMovement_UpdateStatus(entity this)
{
#if 0
	if(!IS_PLAYER(this))
		return;

	if (IS_ONGROUND(this) || this.velocity.z <= 0 || this.teleport_time <= 0)
		this.teleport_time = 0;
#endif
}

void PM_FixClient(entity this)
{
#ifdef CSQC
	//this.team = myteam + 1; // is this correct?
	//PHYS_WATERJUMP_TIME(this) -= dt;
	//this.teleport_time -= dt; // TODO?
	this.movement = PHYS_INPUT_MOVEVALUES(this);
	//this.items = STAT(ITEMS, this);
	if (!(PHYS_INPUT_BUTTON_JUMP(this))) // !jump
		UNSET_JUMP_HELD(this);           // canjump = true
	PM_ClientMovement_UpdateStatus(this);
#endif
}

void SV_check_punch(entity this, float dt)
{
#ifdef SVQC
	if (this.punchangle != '0 0 0')
	{
		float f = vlen(this.punchangle) - 10 * dt;
		if (f > 0)
			this.punchangle = normalize(this.punchangle) * f;
		else
			this.punchangle = '0 0 0';
	}

	if (this.punchvector != '0 0 0')
	{
		float f = vlen(this.punchvector) - 30 * dt;
		if (f > 0)
			this.punchvector = normalize(this.punchvector) * f;
		else
			this.punchvector = '0 0 0';
	}
#endif
}

#ifdef SVQC
// yes, it is confusing seeing cl_ cvars on server side, don't ask
float SV_CalcRoll(entity this)
{
	makevectors(this.angles);

	float side = (this.velocity * v_right);
	float sign = (side < 0) ? -1 : 1;
	side = fabs(side);

	float value = cvar("cl_rollangle");

	if(side < cvar("cl_rollspeed"))
		side = side * value / cvar("cl_rollspeed");
	else
		side = value;

	return side * sign;
}
#endif

void PM_WaterMove(entity this)
{
	makevectors(this.v_angle);

	vector wishvel;
	wishvel = v_forward * self.movement_x + v_right * self.movement_y + '0 0 1' * self.movement_z;
	if (wishvel == '0 0 0')
		wishvel = '0 0 -60'; // drift towards bottom

	vector wishdir = normalize(wishvel);
	float wishspeed = vlen(wishvel);
	if (wishspeed > PHYS_MAXSPEED(this))
		wishspeed = PHYS_MAXSPEED(this);
	wishspeed *= 0.7;

	// water friction
	float frict = ((PHYS_WATERFRICTION(this) < 0) ? PHYS_FRICTION(this) : PHYS_WATERFRICTION(this));
	float speed = vlen(this.velocity);
	float spd = (1 - frametime * frict);
	float newspeed = max(0, speed - spd);
	self.velocity = self.velocity * spd;

	// water acceleration
	if (!wishspeed)
		return;

	float addspeed = wishspeed - newspeed;
	if (addspeed <= 0)
		return;

	float accel = ((PHYS_WATERACCELERATE(this)) < 0 ? PHYS_ACCELERATE(this) : PHYS_WATERACCELERATE(this));
	float accelspeed = accel * wishspeed * frametime;
	if (accelspeed > addspeed)
		accelspeed = addspeed;

	this.velocity += accelspeed * wishdir;
}

void PM_WaterJump(entity this)
{
	if(time > this.teleport_time || !this.waterlevel)
	{
		this.flags &= ~FL_WATERJUMP;
		this.teleport_time = 0;
	}

	this.velocity_x = this.movedir_x;
	this.velocity_y = this.movedir_y;
}

void PM_UserFriction(entity this)
{
	if(this.velocity == '0 0 0')
		return;

	float speed = vlen(this.velocity);
	vector start, stop;
	start.x = stop.x = this.origin_x + this.velocity_x / speed * 16;
	start.y = stop.y = this.origin_y + this.velocity_y / speed * 16;
	start.z = this.origin_z + this.mins_z;
	stop.z = start.z - 34;

	traceline(start, stop, MOVE_NOMONSTERS, this);

	float friction;
	if(trace_fraction == 1.0)
		friction = PHYS_FRICTION(this) * PHYS_EDGEFRICTION(this);
	else
		friction = PHYS_FRICTION(this);

	float control = (speed < PHYS_STOPSPEED(this)) ? PHYS_STOPSPEED(this) : speed;
	float newspeed = speed - frametime * control * friction;

	if(newspeed < 0)
		newspeed = 0;
	else
		newspeed /= speed;

	this.velocity = this.velocity * newspeed;
}

void PM_Accelerate(entity this, vector wishdir, float wishspeed)
{
	float currentspeed = (this.velocity * wishdir);
	float addspeed = wishspeed - currentspeed;
	if(addspeed <= 0)
		return;
	float accelspeed = PHYS_ACCELERATE(this) * frametime * wishspeed;
	if(accelspeed > addspeed)
		accelspeed = addspeed;

	this.velocity += accelspeed * wishdir;
}

void PM_AirAccelerate(entity this, vector wishvel, float wishspeed)
{
	vector wishdir = normalize(wishvel);
	float wishspd = vlen(wishvel);
	if(wishspd > PHYS_MAXAIRSPEED(this))
		wishspd = PHYS_MAXAIRSPEED(this);
	float currentspeed = (this.velocity * wishvel);
	float addspeed = wishspd - currentspeed;
	if(addspeed <= 0)
		return;
	float accelspeed = (PHYS_AIRACCELERATE(this) < 0 ? PHYS_ACCELERATE(this) : PHYS_AIRACCELERATE(this))
			* (GAMEPLAYFIX_Q2AIRACCELERATE ? wishspd : wishspeed) * frametime;
	if(accelspeed > addspeed)
		accelspeed = addspeed;

	this.velocity += accelspeed * wishdir;
}

void PM_AirMove(entity this)
{
	makevectors(self.angles_y * '0 1 0');
	vector wishvel = v_forward * self.movement_x + v_right * self.movement_y;

	if(this.move_movetype != MOVETYPE_WALK)
		wishvel.z += this.movement_z;

	vector wishdir = normalize(wishvel);
	float wishspeed = vlen(wishvel);
	if (wishspeed > PHYS_MAXSPEED(this))
	{
		wishvel *= PHYS_MAXSPEED(this) / wishspeed;
		wishspeed = PHYS_MAXSPEED(this);
	}

	if(time < this.teleport_time)
	{
		// do nothing
	}
	if(this.move_movetype == MOVETYPE_NOCLIP)
	{
		// noclip
		this.velocity = wishvel;
	}
	else if(this.flags & FL_ONGROUND)
	{
		PM_UserFriction(this);
		PM_Accelerate(this, wishdir, wishspeed);
	}
	else
	{
		// not on ground, so little effect on velocity
		PM_AirAccelerate(this, wishvel, wishspeed);
	}
}

bool PM_CheckDead(entity this)
{
#ifdef SVQC
	return (this.health <= 0);
#else
	return false;
#endif
}

void PM_RollView(entity this)
{
#ifdef SVQC
	vector vang = this.v_angle + this.punchangle;

	this.angles_z = SV_CalcRoll(this) * 4;

	if (!this.fixangle)
	{
		this.angles_x = vang.x / 3;
		this.angles_y = vang.y;
	}
#endif
}

void PM_Main(entity this, float dt)
{
	if(this.move_movetype == MOVETYPE_NONE)
		return;

	PM_FixClient(this);

	SV_check_punch(this, frametime);

	if(PM_CheckDead(this))
		return;

	PM_RollView(this);

	if(this.flags & FL_WATERJUMP)
	{
		PM_WaterJump(this);
		return;
	}

	if(this.waterlevel >= 2 && this.move_movetype != MOVETYPE_NOCLIP)
	{
		PM_WaterMove(this);
		return;
	}

	PM_AirMove(this);
}

void SV_PlayerPhysics(entity this)
{
	PM_Main(this, PHYS_INPUT_TIMELENGTH);

#ifdef SVQC
	this.pm_frametime = frametime;
#endif
}