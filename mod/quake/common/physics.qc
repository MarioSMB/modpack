#ifdef SVQC
void Physics_UpdateStats(entity this)
{
	if(intermission_running)
		STAT(PL_VIEW_OFS, this) = STAT(PL_CROUCH_VIEW_OFS, this) = '0 0 0';
	else
		STAT(PL_VIEW_OFS, this) = STAT(PL_CROUCH_VIEW_OFS, this) = '0 0 22';

	STAT(PL_MIN, this) = STAT(PL_CROUCH_MIN, this) = VEC_HULL_MIN;
	STAT(PL_MAX, this) = STAT(PL_CROUCH_MAX, this) = VEC_HULL_MAX;	
}
#endif

void PM_FixClient(entity this)
{
#ifdef CSQC
	this.movement = PHYS_INPUT_MOVEVALUES(this);
#elif defined(SVQC)
	Physics_UpdateStats(this);
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

void PlayerJump(entity this)
{
	if(this.flags & FL_WATERJUMP)
		return;
	
	if(this.waterlevel >= 2)
	{
		if(this.watertype == CONTENT_WATER)
			this.velocity_z = 100;
		else if(this.watertype == CONTENT_SLIME)
			this.velocity_z = 80;
		else
			this.velocity_z = 50;

// play swiming sound
#ifdef SVQC
		if(this.swim_flag < time)
		{
			this.swim_flag = time + 1;
			if(random() < 0.5)
				_sound(this, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
			else
				_sound(this, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
		}
#endif

		return;
	}

	if(!IS_ONGROUND(this))
		return;

	if(IS_JUMP_HELD(this))
		return;		// don't pogo stick

	SET_JUMP_HELD(this);

	UNSET_ONGROUND(this);
	
#ifdef SVQC
	//this.button2 = 0;
// player jumping sound
	_sound(this, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
#endif
	this.velocity_z = this.velocity_z + 270;
}

/*
===========
WaterMove

============
*/
#ifdef SVQC
void DeathBubbles(entity this, int num_bubbles);
#endif

void WaterMove(entity this, float dt)
{
	if(this.move_movetype == MOVETYPE_NOCLIP)
		return;
	if(PHYS_HEALTH(this) <= 0)
		return;
	
	if(!this.waterlevel)
		return;

	if(!(this.flags & FL_WATERJUMP))
		this.velocity = this.velocity - 0.8 * this.waterlevel * dt * this.velocity;

#ifdef SVQC
	if(MP_HIPNOTIC && STAT(WETSUIT_FINISHED, this) > time)
	{
		if(this.waterlevel >= 2)
		{
			// play scuba sound
			if(this.swim_flag < time)
			{
				this.swim_flag = time + 7;
				_sound(this, CHAN_BODY, "misc/wetsuit.wav", 1, ATTN_NORM);
			}
			//MED 01/17/97
			else
			{
				if(fabs(this.swim_flag - time - 6) < 0.04)
					DeathBubbles(this, 1);
				else if(fabs(this.swim_flag - time - 5.5) < 0.04)
					DeathBubbles(this, 1);
				else if(fabs(this.swim_flag - time - 5) < 0.04)
					DeathBubbles(this, 1);
			}
		}
	}
#endif
}

void CheckWaterJump(entity this)
{
	// check for a jump-out-of-water
	makevectors(this.angles);
	vector start = this.origin;
	start.z = start.z + 8; 
	v_forward_z = 0;
	normalize(v_forward);
	vector end = start + v_forward*24;
	traceline(start, end, true, this);
	if(trace_fraction < 1)
	{	// solid at waist
		start.z = start.z + this.maxs_z - 8;
		end = start + v_forward * 24;
		this.movedir = trace_plane_normal * -50;
		traceline(start, end, true, this);
		if(trace_fraction == 1)
		{	// open at eye level
			this.flags |= FL_WATERJUMP;
			this.velocity_z = 225;
			SET_JUMP_HELD(this);
			this.teleport_time = time + 2;	// safety net
			return;
		}
	}
}

void PM_WaterMove(entity this, float dt)
{
	makevectors(this.v_angle);

	vector wishvel;
	wishvel = v_forward * this.movement_x + v_right * this.movement_y + '0 0 1' * this.movement_z;
	if (wishvel == '0 0 0')
		wishvel = '0 0 -60'; // drift towards bottom

	vector wishdir = normalize(wishvel);
	float wishspeed = min(PHYS_MAXSPEED(this), vlen(wishvel));
	if(MP_HIPNOTIC && STAT(WETSUIT_FINISHED, this) > time)
	{
		if(this.waterlevel == 2)
			wishspeed *= 1.25;
		else if(this.waterlevel == 3)
			wishspeed *= 1.5;
	}
	wishspeed *= 0.7;

	// water friction
	float frict = ((PHYS_WATERFRICTION(this) < 0) ? PHYS_FRICTION(this) : PHYS_WATERFRICTION(this));
	float speed = vlen(this.velocity);
	float spd = (1 - dt * frict);
	float newspeed = max(0, speed - spd);
	this.velocity = this.velocity * spd;

	// water acceleration
	if (!wishspeed)
		return;

	float addspeed = wishspeed - newspeed;
	if (addspeed <= 0)
		return;

	float accel = ((PHYS_WATERACCELERATE(this)) < 0 ? PHYS_ACCELERATE(this) : PHYS_WATERACCELERATE(this));
	if(MP_HIPNOTIC && STAT(WETSUIT_FINISHED, this) > time)
	{
		if(this.waterlevel == 2)
			accel *= 0.8;
		else if(this.waterlevel == 3)
			accel *= 0.66;
	}
	float accelspeed = accel * wishspeed * dt;
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

void PM_UserFriction(entity this, float dt)
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
	float newspeed = speed - dt * control * friction;

	if(newspeed < 0)
		newspeed = 0;
	else
		newspeed /= speed;

	this.velocity = this.velocity * newspeed;
}

void PM_Accelerate(entity this, float dt, vector wishdir, float wishspeed)
{
	float currentspeed = (this.velocity * wishdir);
	float addspeed = wishspeed - currentspeed;
	if(addspeed <= 0)
		return;
	float accelspeed = PHYS_ACCELERATE(this) * dt * wishspeed;
	if(accelspeed > addspeed)
		accelspeed = addspeed;

	this.velocity += accelspeed * wishdir;
}

void PM_AirAccelerate(entity this, float dt, vector wishvel, float wishspeed)
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
			* (GAMEPLAYFIX_Q2AIRACCELERATE ? wishspd : wishspeed) * dt;
	if(accelspeed > addspeed)
		accelspeed = addspeed;

	this.velocity += accelspeed * wishdir;
}

void PM_AirMove(entity this, float dt)
{
	makevectors(this.angles_y * '0 1 0');
	vector wishvel = v_forward * this.movement_x + v_right * this.movement_y;

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
	else if(IS_ONGROUND(this))
	{
		PM_UserFriction(this, dt);
		PM_Accelerate(this, dt, wishdir, wishspeed);
	}
	else
	{
		// not on ground, so little effect on velocity
		PM_AirAccelerate(this, dt, wishvel, wishspeed);
	}
}

void PM_RollView(entity this)
{
#ifdef SVQC
	vector vang = this.v_angle + this.punchangle;

	this.angles_z = SV_CalcRoll(this) * 4;

	if(!this.fixangle) { this.angles = '0 1 0' * vang.y; }
#endif
}

void PM_Main(entity this, float dt)
{
	PM_FixClient(this);

	if(this.move_movetype == MOVETYPE_NONE)
		return;

	SV_check_punch(this, dt);

	if(PHYS_HEALTH(this) <= 0)
		return;

	PM_RollView(this);

	if(PHYS_INPUT_BUTTON_JUMP(this))
		PlayerJump(this);
	else
		UNSET_JUMP_HELD(this);

	WaterMove(this, dt);

	if(this.waterlevel == 2)
		CheckWaterJump(this);

	if(this.flags & FL_WATERJUMP)
	{
		PM_WaterJump(this);
		return;
	}

	if(this.waterlevel >= 2 && this.move_movetype != MOVETYPE_NOCLIP)
	{
		PM_WaterMove(this, dt);
		return;
	}

	PM_AirMove(this, dt);
}

#if defined(SVQC)
void SV_PlayerPhysics(entity this)
#elif defined(CSQC)
void CSQC_ClientMovement_PlayerMove_Frame(entity this)
#endif
{
	PM_Main(this, PHYS_INPUT_TIMELENGTH);

#ifdef SVQC
	this.pm_frametime = frametime;
#endif
}
