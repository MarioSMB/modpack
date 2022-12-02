#ifdef SVQC
	#include "../server/combat.qh"
#endif

#ifdef SVQC
void Physics_UpdateStats(entity this)
{
	STAT(PL_VIEW_OFS, this) = STAT(PL_CROUCH_VIEW_OFS, this) = '0 0 48';

	STAT(PL_MIN, this) = STAT(PL_CROUCH_MIN, this) = '-16 -16 0';
	STAT(PL_MAX, this) = STAT(PL_CROUCH_MAX, this) = '16 16 64';
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

vector vector_bounce(vector v, vector n)
{
	// n = normalize(n);
	return v - (v * n) * n * 1;
}

void do_jump(entity this)
{
	if(STAT(JUMPS, this) <= 0)
		return;
	this.velocity.z = 420;
	SET_JUMP_HELD(this);
#ifdef SVQC
	STAT(JUMPS, this) -= 1;
	this.frame = 2;
	sound(this, CHAN_AUTO, SND_JUMP, 0.75, ATTEN_NORM);
	pointparticles(EFFECT_WEAPON_JUMP, this.origin + '0 0 16', '0 0 40', 1);
#endif
}

const float COYOTE_TIME = 0.15;
const float PRELAND_TIME = 0.15;
void PM_Main(entity this, float dt)
{
	PM_FixClient(this);

	if(PHYS_HEALTH(this) <= 0)
		return;

	if(this.move_movetype == MOVETYPE_NONE)
		return;

	vector forward, right, up;
	MAKE_VECTORS(vmul(PHYS_INPUT_ANGLES(this), '1 1 0'), forward, right, up);
	vector moveval;
#ifdef SVQC
	if(cvar_string("sv_worldbasename") == "map2")
#else
	if(cvar_string("cl_worldbasename") == "map2")
#endif
	{
		moveval = PHYS_INPUT_MOVEVALUES(this);
		moveval.y *= -1;
	}
	else
		moveval = vec2(forward * PHYS_INPUT_MOVEVALUES(this).x + right * PHYS_INPUT_MOVEVALUES(this).y);

	//if(vdist(moveval, >, 350))
		//moveval = normalize(moveval) * 350;
	//moveval.y *= (time > STAT(ATTACK_FINISHED, this)) ? -1 : -0.4;
	if(STAT(NO_CONTROL_TIME, this) <= time)
	{
		float vel_z = this.velocity_z;
		float wishspeed = 350;
		if(STAT(ATTACK_FINISHED, this) > time)
			wishspeed *= 0.4;
		vector vel_xy = normalize(moveval) * wishspeed;
		this.velocity = vel_xy + vel_z * '0 0 1';
	}
	//this.velocity = (STAT(NO_CONTROL_TIME, this) > time) ? this.velocity : moveval + vec3(0, 0, this.velocity.z);
#ifdef SVQC
	//this.fixangle = true;
#endif

	if(PHYS_INPUT_BUTTON_JUMP(this) && !IS_JUMP_HELD(this) && time > STAT(NO_CONTROL_TIME, this))
	{
#ifdef SVQC
		if(!IS_JUMP_HELD(this))
			STAT(JUMP_PRESSED_TIME, this) = time;
#endif
		SET_JUMP_HELD(this);
		if(time - STAT(ON_GROUND_TIME, this) < COYOTE_TIME && this.velocity.z <= 0)
			do_jump(this);
		else if(STAT(JUMPS, this) > 0 && STAT(JUMPS, this) < STAT(FEATHER, this))
			do_jump(this);
	}

	if(!PHYS_INPUT_BUTTON_JUMP(this))
	{
		UNSET_JUMP_HELD(this);
#ifdef SVQC
		STAT(JUMP_PRESSED_TIME, this) = 0;
#endif
	}

	float grav = PHYS_GRAVITY(this) * dt;

	// Check ground
	tracebox(this.origin, this.mins, this.maxs, this.origin - '0 0 1', MOVE_NORMAL, this);
	if(trace_fraction == 1)
	{
		// Player is not on a proper footing
#ifdef SVQC
		if(this.velocity_z <= 0 && time - STAT(ON_GROUND_TIME, this) > COYOTE_TIME) // walked from edge, take away first jump
			STAT(JUMPS, this) = min(STAT(JUMPS, this), STAT(FEATHER, this) - 1);
#endif
		UNSET_ONGROUND(this);
	}
	else if(this.velocity_z <= 0)
	{
		// Player is on ground
#ifdef SVQC
		STAT(ON_GROUND_TIME, this) = time;
#endif
		SET_ONGROUND(this);
#ifdef SVQC
		STAT(JUMPS, this) = STAT(FEATHER, this);
#endif
		
		if(time - STAT(JUMP_PRESSED_TIME, this) < PRELAND_TIME)
			do_jump(this);
	}
	
	if(!IS_ONGROUND(this))
		this.velocity_z -= grav;	

	vector startpos = this.origin;
	vector endpos = this.origin + this.velocity * dt;

	tracebox(this.origin, this.mins, this.maxs, endpos, MOVE_NORMAL, this);
	entity old_trace_ent = trace_ent;

	setorigin(this, trace_endpos);
	float move_left = 1 - trace_fraction;
	if(trace_fraction < 1)
	{
		float oldz = this.velocity.z;
		this.velocity = vector_bounce(this.velocity, trace_plane_normal);
		if(this.velocity.z > oldz)
		{
			// just to prevent launching players in the air on tight slopes, avoid slopes in levels
			this.velocity *= trace_plane_normal.z;
		}
		if(move_left > 0.1)
		{
			endpos = this.origin + this.velocity * move_left * dt;
			tracebox(this.origin, this.mins, this.maxs, endpos, 0, this);
			setorigin(this, trace_endpos);
			this.velocity = vector_bounce(this.velocity, trace_plane_normal);
			
			if(trace_ent && trace_ent != old_trace_ent) // Other touches
			{
				if(gettouch(this))
					gettouch(this)(this, trace_ent);
				if(gettouch(trace_ent))
					gettouch(trace_ent)(trace_ent, this);
			}
			
			// Hack to prevent corner stuck
			move_left = move_left - trace_fraction;
			if(move_left > 0.9)
			{
				endpos = this.origin + vec3(0, 0, this.velocity.z) * move_left * dt;
				tracebox(this.origin, this.mins, this.maxs, endpos, 0, this);
				setorigin(this, trace_endpos);
			}
		}
	}

	if(old_trace_ent) // Other touches
	{
		if(gettouch(this))
			gettouch(this)(this, old_trace_ent);
		if(gettouch(old_trace_ent))
			gettouch(old_trace_ent)(old_trace_ent, this);
	}

	// Go from initial start pos to final pos, check for triggers
	tracebox(startpos, this.mins, this.maxs, this.origin, MOVE_NOMONSTERS, this);
	if(trace_ent && trace_ent.solid == SOLID_TRIGGER) // TRIGGER touches
	{
		if(gettouch(this))
			gettouch(this)(this, trace_ent);
	}
}

#ifdef SVQC
float turn_angle(float a, float b, float amount)
{
	a = anglemods(a);
	b = anglemods(b);
	float diff = b - a;
	
	if (fabs(diff) < amount)
	{
		return b;
	}
	
	if (diff < -180)
	{
		b += 360;	
	}
	else if (diff > 180)
	{
		b -= 360;
	}
	
	if (fabs(b - a) < amount)
	{
		return b;
	}
	if (a < b)
		return a + amount;
	else
		return a - amount;	
}

.float playery;
void CSQCPlayer_SmoothAngle(entity this)
{
	if(time < STAT(NO_CONTROL_TIME, this))
		return;

	if(vdist(vec2(this.velocity), >, 0))
	{
		vector wanted_angles = vectoangles(vec2(this.velocity));
		float framescale = ((IS_ONGROUND(this)) ? 1200 : 500);

		this.playery = turn_angle(this.playery, wanted_angles_y, PHYS_INPUT_TIMELENGTH * framescale);
	}

	this.angles.y = this.playery;
}

void PM_UpdateButtons(entity this)
{
	if(this.health <= 0)
		return;
	if(cvar_string("sv_worldbasename") != "map2")
	{
		CSQCPlayer_SmoothAngle(this);
		return;
	}

	vector moveval = this.movement;
	moveval.y *= -1;
	vector real_angles = vec3(0, this.playery, 0);
	if(vdist(moveval, >, 0))
		real_angles = vectoangles(moveval);
	this.playery = real_angles.y;
	this.v_angle = vec3(0, real_angles.y, 0);
	this.angles_y = real_angles.y;
}
#endif

#if defined(SVQC)
void SV_PlayerPhysics(entity this)
#elif defined(CSQC)
void CSQC_ClientMovement_PlayerMove_Frame(entity this)
#endif
{
#ifdef SVQC
	// needs to be called before physics are run!
	if(IS_REAL_CLIENT(this))
		PM_UpdateButtons(this);
#endif
	PM_Main(this, PHYS_INPUT_TIMELENGTH);

#ifdef SVQC
	this.pm_frametime = frametime;
#endif
}
