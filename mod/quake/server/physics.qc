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

void SVQC_WaterMove(entity this)
{
	makevectors(this.v_angle);

	vector wishvel;
	wishvel = v_forward * self.movement_x + v_right * self.movement_y + '0 0 1' * self.movement_z;
	if (wishvel == '0 0 0')
		wishvel = '0 0 -60'; // drift towards bottom

	vector wishdir = normalize(wishvel);
	float wishspeed = vlen(wishvel);
	if (wishspeed > cvar("sv_maxspeed"))
		wishspeed = cvar("sv_maxspeed");
	wishspeed *= 0.7;

	// water friction
	float speed = vlen(this.velocity);
	float spd = (1 - frametime * ((cvar("sv_waterfriction") < 0) ? cvar("sv_friction") : cvar("sv_waterfriction")));
	float newspeed = max(0, speed - spd);
	self.velocity = self.velocity * spd;

	// water acceleration
	if (!wishspeed)
		return;

	float addspeed = wishspeed - newspeed;
	if (addspeed <= 0)
		return;

	float accelspeed = (cvar("sv_wateraccelerate") < 0 ? cvar("sv_accelerate") : cvar("sv_wateraccelerate")) * wishspeed * frametime;
	if (accelspeed > addspeed)
		accelspeed = addspeed;

	this.velocity += accelspeed * wishdir;
}

void SVQC_WaterJump(entity this)
{
	if(time > this.teleport_time || !this.waterlevel)
	{
		this.flags &= ~FL_WATERJUMP;
		this.teleport_time = 0;
	}

	this.velocity_x = this.movedir_x;
	this.velocity_y = this.movedir_y;
}

void SVQC_UserFriction(entity this)
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
		friction = cvar("sv_friction") * cvar("sv_edgefriction");
	else
		friction = cvar("sv_friction");

	float control = (speed < cvar("sv_stopspeed")) ? cvar("sv_stopspeed") : speed;
	float newspeed = speed - frametime * control * friction;

	if(newspeed < 0)
		newspeed = 0;
	else
		newspeed /= speed;

	this.velocity = this.velocity * newspeed;
}

void SVQC_Accelerate(entity this, vector wishdir, float wishspeed)
{
	float currentspeed = (this.velocity * wishdir);
	float addspeed = wishspeed - currentspeed;
	if(addspeed <= 0)
		return;
	float accelspeed = cvar("sv_accelerate") * frametime * wishspeed;
	if(accelspeed > addspeed)
		accelspeed = addspeed;

	this.velocity += accelspeed * wishdir;
}

void SVQC_AirAccelerate(entity this, vector wishvel, float wishspeed)
{
	vector wishdir = normalize(wishvel);
	float wishspd = vlen(wishvel);
	if(wishspd > cvar("sv_maxairspeed"))
		wishspd = cvar("sv_maxairspeed");
	float currentspeed = (this.velocity * wishvel);
	float addspeed = wishspd - currentspeed;
	if(addspeed <= 0)
		return;
	float accelspeed = (cvar("sv_airaccelerate") < 0 ? cvar("sv_accelerate") : cvar("sv_airaccelerate"))
			* (cvar("sv_gameplayfix_q2airaccelerate") ? wishspd : wishspeed) * frametime;
	if(accelspeed > addspeed)
		accelspeed = addspeed;

	this.velocity += accelspeed * wishdir;
}

void SVQC_AirMove(entity this)
{
	makevectors(self.angles_y * '0 1 0');
	vector wishvel = v_forward * self.movement_x + v_right * self.movement_y;

	if(this.move_movetype != MOVETYPE_WALK)
		wishvel.z += this.movement_z;

	vector wishdir = normalize(wishvel);
	float wishspeed = vlen(wishvel);
	if (wishspeed > cvar("sv_maxspeed"))
	{
		wishvel *= cvar("sv_maxspeed") / wishspeed;
		wishspeed = cvar("sv_maxspeed");
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
		SVQC_UserFriction(this);
		SVQC_Accelerate(this, wishdir, wishspeed);
	}
	else
	{
		// not on ground, so little effect on velocity
		SVQC_AirAccelerate(this, wishvel, wishspeed);
	}
}

void SV_PlayerPhysics(entity this)
{
	if(this.move_movetype == MOVETYPE_NONE)
		return;

	SV_check_punch(this, frametime);

	if(this.health <= 0)
		return; // dead

	vector vang = this.v_angle + this.punchangle;

	this.angles_z = SV_CalcRoll(this) * 4;

	if (!self.fixangle)
	{
		self.angles_x = vang.x / 3;
		self.angles_y = vang.y;
	}

	if(this.flags & FL_WATERJUMP)
	{
		SVQC_WaterJump(this);
		return;
	}

	if(this.waterlevel >= 2 && this.move_movetype != MOVETYPE_NOCLIP)
	{
		SVQC_WaterMove(this);
		return;
	}

	SVQC_AirMove(this);
}