#ifdef SVQC
	#include "../server/combat.qh"
	#include "../server/player.qh"
#endif

#ifdef SVQC
void Physics_UpdateStats(entity this)
{
	STAT(PL_VIEW_OFS, this) = STAT(PL_CROUCH_VIEW_OFS, this) = '0 0 32';

	STAT(PL_MIN, this) = STAT(PL_CROUCH_MIN, this) = '-10 -10 0';
	STAT(PL_MAX, this) = STAT(PL_CROUCH_MAX, this) = '10 10 32';
}
#endif

void PM_FixClient(entity this)
{
#ifdef CSQC
	this.hitting_ground = STAT(HITTING_GROUND);
	this.groundtime = STAT(GROUNDTIME);
	this.watertime = STAT(WATERTIME);
	this.jumpcombo = STAT(JUMPCOMBO);
	this.movement = PHYS_INPUT_MOVEVALUES(this);
#elif defined(SVQC)
	Physics_UpdateStats(this);
#endif
}

#if 0
vector vector_bounce(vector v, vector n)
{
	// n = normalize(n);
	return v - (v * n) * n * 1;
}
#endif

void PlayerJump(entity this)
{
	if(!IS_ONGROUND(this))
		return;

	if(PHYS_TRACK_CANJUMP(this) && IS_JUMP_HELD(this))
		return;

#ifdef SVQC
	this.weaponframe = 0;
#endif

	// jump if on ground with jump button pressed but only if it has been
	// released at least once since the last jump
	this.velocity_z += PHYS_JUMPVELOCITY(this);
	UNSET_ONGROUND(this);
	SET_JUMP_HELD(this);
}

void PM_ClientMovement_UpdateStatus(entity this)
{
	// set crouched
	bool do_crouch = PHYS_INPUT_BUTTON_CROUCH(this);
	if (PHYS_HEALTH(this) <= 0) {
		do_crouch = false;
	}

	if (do_crouch) {
		if (!IS_DUCKED(this)) {
			SET_DUCKED(this);
			//this.view_ofs = STAT(PL_CROUCH_VIEW_OFS, this);
			setsize(this, STAT(PL_CROUCH_MIN, this), STAT(PL_CROUCH_MAX, this));
			// setanim(this, this.anim_duck, false, true, true); // this anim is BROKEN anyway
		}
	} else if (IS_DUCKED(this)) {
		tracebox(this.origin, STAT(PL_MIN, this), STAT(PL_MAX, this), this.origin, MOVE_NORMAL, this);
		if (!trace_startsolid) {
			UNSET_DUCKED(this);
			//this.view_ofs = STAT(PL_VIEW_OFS, this);
			setsize(this, STAT(PL_MIN, this), STAT(PL_MAX, this));
		}
	}

#ifdef SVQC
	if(IS_ONGROUND(this) && this.velocity == '0 0 0' && !IS_DASHING(this) && this.waterlevel == 0)
		this.frame = 0;
#endif

	_Movetype_CheckWater(this);
}

void PM_ClientMovement_Physics_Swim(entity this, float  dt)
{
	// water jump only in certain situations
	// this mimics quakeworld code
	if(PHYS_INPUT_BUTTON_JUMP(this) && this.waterlevel == 2 && this.velocity.z >= -180)
	{
		vector yawangles = '0 1 0' * this.v_angle.y;
		vector forward, right, up;
		MAKE_VECTORS(yawangles, forward, right, up);
		vector spot = this.origin + 24 * forward;
		spot_z += 8;
		traceline(spot, spot, MOVE_NOMONSTERS, this);
		if(trace_startsolid)
		{
			spot.z += 24;
			traceline(spot, spot, MOVE_NOMONSTERS, this);
			if(trace_startsolid)
			{
				this.velocity = v_forward * 50;
				this.velocity.z = 310;
				UNSET_ONGROUND(this);
				this.flags |= FL_WATERJUMP;
				SET_JUMP_HELD(this);
			}
		}
	}

	vector forward, right, up;
	MAKE_VECTORS(vmul(this.v_angle, '1 1 1'), forward, right, up);
	vector wishvel = forward * this.movement.x
	    + right * this.movement.y
	    + '0 0 1' * this.movement.z;

	if(wishvel == '0 0 0')
	{
		// drift towards bottom
		wishvel = '0 0 -60';
	}

	// split wishvel into wishspeed and wishdir
	const vector wishdir = normalize(wishvel);
	float wishspeed = min(vlen(wishvel), PHYS_MAXSPEED(this)) * 0.7;

	if(PHYS_INPUT_BUTTON_CROUCH(this))
		wishspeed *= 0.5;

	if(!(this.flags & FL_WATERJUMP))
	{
		// water friction
		float f = 1 - dt * PHYS_WATERFRICTION(this) * 1;
		f = bound(0, f, 1);
		this.velocity *= f;

		// water acceleration
		f = wishspeed - (this.velocity * wishdir);
		if(f > 0)
		{
			f = min(PHYS_WATERACCELERATE(this) * dt * wishspeed, f);
			this.velocity = this.velocity + f * wishdir;
		}

		// holding jump button swims upward slowly
		if(PHYS_INPUT_BUTTON_JUMP(this))
		{
			if(this.watertype == CONTENT_LAVA)
				this.velocity.z =  50;
			else if(this.watertype == CONTENT_SLIME)
				this.velocity.z =  80;
			else
				this.velocity.z = 100;
		}
	}

	PM_ClientMovement_UpdateStatus(this);
}

float IsMoveInDirection(vector mv, float ang) // key mix factor
{
	if (mv_x == 0 && mv_y == 0)
		return 0; // avoid division by zero
	ang -= RAD2DEG * atan2(mv_y, mv_x);
	ang = remainder(ang, 360) / 45;
	return ang > 1 ? 0 : ang < -1 ? 0 : 1 - fabs(ang);
}

float GeomLerp(float a, float _lerp, float b)
{
	return a == 0 ? (_lerp < 1 ? 0 : b)
		: b == 0 ? (_lerp > 0 ? 0 : a)
		: a * (fabs(b / a) ** _lerp);
}

void CPM_PM_Aircontrol(entity this, float dt, vector wishdir, float wishspeed)
{
	float movity = IsMoveInDirection(this.movement, 0);
	if(PHYS_AIRCONTROL_BACKWARDS(this))
		movity += IsMoveInDirection(this.movement, 180);
	if(PHYS_AIRCONTROL_SIDEWARDS(this))
	{
		movity += IsMoveInDirection(this.movement, 90);
		movity += IsMoveInDirection(this.movement, -90);
	}

	float k = 32 * (2 * movity - 1);
	if (k <= 0)
		return;

	k *= bound(0, wishspeed / PHYS_MAXAIRSPEED(this), 1);

	float zspeed = this.velocity_z;
	this.velocity_z = 0;
	float xyspeed = vlen(this.velocity);
	this.velocity = normalize(this.velocity);

	float dot = this.velocity * wishdir;

	if (dot > 0) // we can't change direction while slowing down
	{
		k *= (dot ** PHYS_AIRCONTROL_POWER(this)) * dt;
		xyspeed = max(0, xyspeed - PHYS_AIRCONTROL_PENALTY(this) * sqrt(max(0, 1 - dot*dot)) * k/32);
		k *= PHYS_AIRCONTROL(this);
		this.velocity = normalize(this.velocity * xyspeed + wishdir * k);
	}

	this.velocity = this.velocity * xyspeed;
	this.velocity_z = zspeed;
}

float AdjustAirAccelQW(float accelqw, float factor)
{
	return
		(accelqw < 0 ? -1 : +1)
		*
		bound(0.000001, 1 - (1 - fabs(accelqw)) * factor, 1);
}

void PM_Accelerate(entity this, float dt, vector wishdir, float wishspeed, float wishspeed0, float accel, float accelqw, float stretchfactor, float sidefric, float speedlimit)
{
	float speedclamp = stretchfactor > 0 ? stretchfactor
	: accelqw < 0 ? 1 // full clamping, no stretch
	: -1; // no clamping

	accelqw = fabs(accelqw);

	if (GAMEPLAYFIX_Q2AIRACCELERATE)
		wishspeed0 = wishspeed; // don't need to emulate this Q1 bug

	float vel_straight = this.velocity * wishdir;
	float vel_z = this.velocity_z;
	vector vel_xy = vec2(this.velocity);
	vector vel_perpend = vel_xy - vel_straight * wishdir;

	float step = accel * dt * wishspeed0;

	float vel_xy_current  = vlen(vel_xy);
	if (speedlimit)
		accelqw = AdjustAirAccelQW(accelqw, (speedlimit - bound(wishspeed, vel_xy_current, speedlimit)) / max(1, speedlimit - wishspeed));
	float vel_xy_forward =  vel_xy_current  + bound(0, wishspeed - vel_xy_current, step) * accelqw + step * (1 - accelqw);
	float vel_xy_backward = vel_xy_current  - bound(0, wishspeed + vel_xy_current, step) * accelqw - step * (1 - accelqw);
	vel_xy_backward = max(0, vel_xy_backward); // not that it REALLY occurs that this would cause wrong behaviour afterwards
	vel_straight =          vel_straight    + bound(0, wishspeed - vel_straight,   step) * accelqw + step * (1 - accelqw);

	if (sidefric < 0 && (vel_perpend*vel_perpend))
		// negative: only apply so much sideways friction to stay below the speed you could get by "braking"
	{
		float f = max(0, 1 + dt * wishspeed * sidefric);
		float themin = (vel_xy_backward * vel_xy_backward - vel_straight * vel_straight) / (vel_perpend * vel_perpend);
		// assume: themin > 1
		// vel_xy_backward*vel_xy_backward - vel_straight*vel_straight > vel_perpend*vel_perpend
		// vel_xy_backward*vel_xy_backward > vel_straight*vel_straight + vel_perpend*vel_perpend
		// vel_xy_backward*vel_xy_backward > vel_xy * vel_xy
		// obviously, this cannot be
		if (themin <= 0)
			vel_perpend *= f;
		else
		{
			themin = sqrt(themin);
			vel_perpend *= max(themin, f);
		}
	}
	else
		vel_perpend *= max(0, 1 - dt * wishspeed * sidefric);

	vel_xy = vel_straight * wishdir + vel_perpend;

	if (speedclamp >= 0)
	{
		float vel_xy_preclamp;
		vel_xy_preclamp = vlen(vel_xy);
		if (vel_xy_preclamp > 0) // prevent division by zero
		{
			vel_xy_current += (vel_xy_forward - vel_xy_current) * speedclamp;
			if (vel_xy_current < vel_xy_preclamp)
				vel_xy *= (vel_xy_current / vel_xy_preclamp);
		}
	}

	this.velocity = vel_xy + vel_z * '0 0 1';
}

void PM_AirAccelerate(entity this, float dt, vector wishdir, float wishspeed)
{
	if (wishspeed == 0)
		return;

	vector curvel = this.velocity;
	curvel_z = 0;
	float curspeed = vlen(curvel);

	if (wishspeed > curspeed * 1.01)
		wishspeed = min(wishspeed, curspeed + PHYS_WARSOWBUNNY_AIRFORWARDACCEL(this) * PHYS_MAXSPEED(this) * dt);
	else
	{
		float f = max(0, (PHYS_WARSOWBUNNY_TOPSPEED(this) - curspeed) / (PHYS_WARSOWBUNNY_TOPSPEED(this) - PHYS_MAXSPEED(this)));
		wishspeed = max(curspeed, PHYS_MAXSPEED(this)) + PHYS_WARSOWBUNNY_ACCEL(this) * f * PHYS_MAXSPEED(this) * dt;
	}
	vector wishvel = wishdir * wishspeed;
	vector acceldir = wishvel - curvel;
	float addspeed = vlen(acceldir);
	acceldir = normalize(acceldir);

	float accelspeed = min(addspeed, PHYS_WARSOWBUNNY_TURNACCEL(this) * PHYS_MAXSPEED(this) * dt);

	if (PHYS_WARSOWBUNNY_BACKTOSIDERATIO(this) < 1)
	{
		vector curdir = normalize(curvel);
		float dot = acceldir * curdir;
		if (dot < 0)
			acceldir -= (1 - PHYS_WARSOWBUNNY_BACKTOSIDERATIO(this)) * dot * curdir;
	}

	this.velocity += accelspeed * acceldir;
}

void PM_ClientMovement_Physics_Walk(entity this, float dt)
{
	// calculate movement vector
	vector forward, right, up;
	MAKE_VECTORS(vmul(this.v_angle, '1 1 1'), forward, right, up);
	// wishvel = forward * this.movement.x + right * this.movement.y + up * this.movement.z;
	vector wishvel = forward * this.movement.x
	    + right * this.movement.y
	    + '0 0 1' * this.movement.z * 1;

	// split wishvel into wishspeed and wishdir
	const vector wishdir = normalize(wishvel);
	float wishspeed = vlen(wishvel);

	// check if onground
	if(IS_ONGROUND(this))
	{
		wishspeed = min(wishspeed, PHYS_MAXSPEED(this));
		if(IS_DUCKED(this))
			wishspeed *= 0.5;

		// apply edge friction
		float f = sqrt(vlen2(vec2(this.velocity)));
		if(f > 0)
		{
			float friction = PHYS_FRICTION(this);
			if(PHYS_EDGEFRICTION(this) != 1)
			{
				// note: QW uses the full player box for the trace, and yet still
				// uses this.origin.z + s->mins.z, which is clearly an bug, but
				// this mimics it for compatibility
				vector neworigin2;
				neworigin2.x = this.origin.x + this.velocity.x * (16 / f);
				neworigin2.y = this.origin.y + this.velocity.y * (16 / f);
				neworigin2.z = this.origin.z + this.mins.z;
				vector neworigin3;
				neworigin3 = neworigin2 - '0 0 34';
				traceline(neworigin2, neworigin3, MOVE_NORMAL, this);
				if(trace_fraction == 1 && !trace_startsolid)
					friction *= PHYS_EDGEFRICTION(this);
			}
			// apply ground friction
			f = 1 - dt * friction * ((f < PHYS_STOPSPEED(this)) ? (PHYS_STOPSPEED(this) / f) : 1);
			f = max(f, 0);
			this.velocity = this.velocity * f;
		}
		float addspeed = wishspeed - (this.velocity * wishdir);
		if(addspeed > 0)
		{
			float accelspeed = min(PHYS_ACCELERATE(this) * dt * wishspeed, addspeed);
			this.velocity += accelspeed * wishdir;
		}
		if(vlen2(this.velocity))
			PM_ClientMovement_UpdateStatus(this);
	}
	else
	{
		if(!(this.flags & FL_WATERJUMP))
		{
			// apply air speed limit
			float airaccelqw = PHYS_AIRACCEL_QW(this);
			float accel, wishspeed0, wishspeed2, accelqw, strafity;
			bool accelerating;

			accelqw = PHYS_AIRACCEL_QW(this);;
			wishspeed0 = wishspeed;
			const float maxairspd = PHYS_MAXAIRSPEED(this);
			wishspeed = min(wishspeed, maxairspd);
			if(IS_DUCKED(this))
				wishspeed *= 0.5;
			accel = PHYS_AIRACCELERATE(this);

			float airaccel = PHYS_AIRACCELERATE(this);

			accelerating = ((this.velocity * wishdir) > 0);
			wishspeed2 = wishspeed;

			// CPM: air control
			if(PHYS_AIRSTOPACCELERATE(this) != 0)
			{
				vector curdir = vec2(this.velocity);
				curdir = normalize(curdir);
				accel = accel + (PHYS_AIRSTOPACCELERATE(this) - accel) * max(0, -(curdir * wishdir));
			}
			strafity = IsMoveInDirection(this.movement, -90) + IsMoveInDirection(this.movement, +90); // if one is nonzero, other is always zero
			if(PHYS_MAXAIRSTRAFESPEED(this))
				wishspeed = min(wishspeed, GeomLerp(PHYS_MAXAIRSPEED(this), strafity, PHYS_MAXAIRSTRAFESPEED(this)));
			if(PHYS_AIRSTRAFEACCELERATE(this))
				accel = GeomLerp(PHYS_AIRACCELERATE(this), strafity, PHYS_AIRSTRAFEACCELERATE(this));
			if(PHYS_AIRSTRAFEACCEL_QW(this))
				accelqw =
					(((strafity > 0.5 ? PHYS_AIRSTRAFEACCEL_QW(this) : PHYS_AIRACCEL_QW(this)) >= 0) ? +1 : -1)
					*
					(1 - GeomLerp(1 - fabs(PHYS_AIRACCEL_QW(this)), strafity, 1 - fabs(PHYS_AIRSTRAFEACCEL_QW(this))));
			// !CPM

			if(PHYS_WARSOWBUNNY_TURNACCEL(this) && accelerating && this.movement.y == 0 && this.movement.x != 0)
				PM_AirAccelerate(this, dt, wishdir, wishspeed2);
			else
			{
				float sidefric = maxairspd ? (PHYS_AIRACCEL_SIDEWAYS_FRICTION(this) / maxairspd) : 0;
				PM_Accelerate(this, dt, wishdir, wishspeed, wishspeed0, airaccel, airaccelqw,
					PHYS_AIRACCEL_QW_STRETCHFACTOR(this), sidefric, PHYS_AIRSPEEDLIMIT_NONQW(this));
			}

			if(PHYS_AIRCONTROL(this))
				CPM_PM_Aircontrol(this, dt, wishdir, wishspeed2);
		}
		PM_ClientMovement_UpdateStatus(this);
	}
}

void PM_ClientMovement_PlayerMove(entity this, float dt)
{
	//Con_Printf(" %f", frametime);
	if(!PHYS_INPUT_BUTTON_JUMP(this))
		UNSET_JUMP_HELD(this);
	this.movement = PHYS_INPUT_MOVEVALUES(this);
	PM_ClientMovement_UpdateStatus(this);
	if(this.waterlevel >= WATERLEVEL_SWIMMING)
		PM_ClientMovement_Physics_Swim(this, dt);
	else
		PM_ClientMovement_Physics_Walk(this, dt);
}

#ifdef SVQC
float footstepcount;
float waterpartcount;
#endif
void PM_Main(entity this, float dt)
{
	PM_FixClient(this);

	if(PHYS_HEALTH(this) <= 0)
		return;

	if(STAT(GAME_OVER))
	{
		this.velocity = '0 0 0';
		this.frame = 0;
		return;
	}

	if(this.move_movetype == MOVETYPE_NONE)
		return;

	float was_onground = IS_ONGROUND(this);

	// FIXME: logic can't be client predicted while making use of timers!
	// to the smartasses out there: yes, it can, but the logic for that needs implementing here
	if(was_onground)
	{
		if(time < this.hitting_ground)
		{
			this.movement = '0 0 0';
#ifdef CSQC
			input_buttons = 0;
#elif defined(SVQC)
			PHYS_INPUT_BUTTON_JUMP(this) = PHYS_INPUT_BUTTON_ATCK(this) = PHYS_INPUT_BUTTON_CROUCH(this) = false;
#endif
		}
		this.groundtime += dt;
		if(this.groundtime > 0.1)
			this.jumpcombo = 0;

		if(this.groundtime > 0.2)
			UNSET_DASHING(this);

#ifdef SVQC
		if(time > this.hitting_ground)
			this.frame = 1;
#endif
	}
	else
	{
		this.groundtime = 0;
	}

	// Jump
	if(PHYS_INPUT_BUTTON_JUMP(this))
		PlayerJump(this);
	else
		UNSET_JUMP_HELD(this);

	vector oldpos = this.origin;
#ifdef SVQC
	float oldz = this.velocity.z;
#endif

	PM_ClientMovement_PlayerMove(this, dt);
	vector hvel = vec2(this.velocity);
	
	// Do the dash
	if(!was_onground && PHYS_INPUT_BUTTON_ATCK(this) && this.jumpcombo >= 1 && !IS_DASHING(this) && vdist(hvel, >, 80))
	{
		if((this.jumpcombo != 3) || (this.velocity.z < 50))
		{
			this.velocity = normalize(hvel) * 380 + '0 0 65';
			SET_DASHING(this);
			this.jumpcombo = 0;
#ifdef SVQC
			this.frame = 5;
			
			increase_combo_time(this, 0.1);
			
			sound7(this, CHAN_VOICE, SND(EH1), 0.7 + random() * 0.3, 0.5, 94 + random() * 12, 0);
#endif
		}
	}

	// elaborate check to see if we just jumped
	if(PHYS_INPUT_BUTTON_JUMP(this) && was_onground && !IS_ONGROUND(this) && this.velocity.z > 0)
	{
		++this.jumpcombo;
		if(this.jumpcombo == 1)
		{
			if(IS_DASHING(this))
			{
#ifdef SVQC
				this.frame = 6;
				increase_combo_time(this, 0.2);
#endif
			}
			else
			{
				this.velocity.z += 48;
#ifdef SVQC
				this.frame = 2;
				increase_combo_time(this, 0.3);
#endif
				
			}
#ifdef SVQC
			sound7(this, CHAN_VOICE, SND(WAH_RANDOM()), 0.3 + random() * 0.2, 0.5, 95 + random() * 10, 0);
#endif
		}
		else if(this.jumpcombo == 2)
		{
			UNSET_DASHING(this);
			this.velocity.z += 120;
#ifdef SVQC
			this.frame = 3;
			increase_combo_time(this, 0.3);
			sound7(this, CHAN_VOICE, SND(WOW_RANDOM()), 0.3 + random() * 0.2, 0.5, 95 + random() * 10, 0);
#endif
		}
		else if(this.jumpcombo == 3 && vdist(hvel, >, 0))
		{
			this.velocity.z += 220;
#ifdef SVQC
			this.frame = 4;
			increase_combo_time(this, 0.7);
			if(random() < 0.5)
				sound7(this, CHAN_VOICE, SND(YAHOO), 0.6 + random() * 0.3, 0.5, 95 + random() * 10, 0);
			else
				sound7(this, CHAN_VOICE, SND(YEHEY), 0.7 + random() * 0.3, 0.5, 95 + random() * 10, 0);
#endif
		}
		else
		{
			this.jumpcombo = 1;
			this.velocity.z += 40;
#ifdef SVQC
			this.frame = 2;
			increase_combo_time(this, 0.3);
			sound7(this, CHAN_VOICE, SND(WAH_RANDOM()), 0.3 + random() * 0.3, 0.5, 95 + random() * 10, 0);
#endif
		}
#ifdef SVQC
		spawn_jump_ring(this.origin);
		pointparticles(EFFECT_JUMP_PUFF, this.origin, '0 0 1', 1);
#endif
	}
	
	// hitting ground in dash (not follow up jump)
	if(was_onground && IS_ONGROUND(this) && IS_DASHING(this))
	{
		if(this.jumpcombo == 0)
		{
			UNSET_DASHING(this);
			this.hitting_ground = time + 0.75;
#ifdef SVQC
			this.frame = 7;
			sound7(this, CHAN_VOICE, SND(UWEH), 0.8, 0.5, 94 + random() * 12, 0);
			pointparticles(EFFECT_HIT_DIRT, this.origin, hvel * 0.1, 1);
#endif
		}
		else
		{
			UNSET_DASHING(this);
#ifdef SVQC
			this.frame = 1;
#endif
		}
	}

#ifdef SVQC
	// footstep stuff
	if(was_onground && IS_ONGROUND(this) && vdist(hvel, >, 80) && time > this.hitting_ground)
	{
		vector diff = this.origin - oldpos;
		footstepcount += vlen(diff);
		float footstepdist = 48;
		if(footstepcount > footstepdist)
		{
			pointparticles(EFFECT_FOOTSTEP, this.origin - normalize(hvel) * 8, '0 0 1', 1);
			sound7(this, CHAN_AUTO, SND(STEP), vlen(hvel) / 700, 0.8, 95 + random() * 10, 0);
			footstepcount -= footstepdist;
		}	
	}
	else
	{
		footstepcount = 0;
	}
	
	if(!was_onground && IS_ONGROUND(this) && !IS_DASHING(this) && oldz < -50)
		pointparticles(EFFECT_LAND, this.origin, '0 0 1', floor(-oldz / 200));
#endif

	makevectors('0 1 0' * this.angles.y);
	
	// water stuff
	if(PHYS_WATERLEVEL(this) && this.origin.z < PHYS_WATERLEVEL(this))
	{
		if(oldpos.z >= PHYS_WATERLEVEL(this))
		{
			sound7(this, CHAN_AUTO, SND(SPLASH), 0.6 + random() * 0.3, 0.5, 95 + random() * 15, 0);
			pointparticles(EFFECT_WATER_SPLASH, this.origin - '0 0 8', '0 0 1', 1);
			UNSET_DASHING(this);
			this.jumpcombo = 0;
		}
		
		UNSET_ONGROUND(this);

#ifdef SVQC
		waterpartcount += dt;
		if(waterpartcount > 0.2)
		{
			pointparticles(EFFECT_WATER_SWIM, vec3(this.origin.x, this.origin.y, PHYS_WATERLEVEL(this) - 4), '0 0 1', 1);
			waterpartcount -= 0.2;
		}
#endif
		this.velocity -= this.velocity * dt * 2;
		if(PHYS_WATERLEVEL(this) && this.origin.z < (PHYS_WATERLEVEL(this) - 20))
		{
#ifdef SVQC
			this.frame = 8;
#endif
			this.velocity.z += PHYS_GRAVITY(this) * dt * 1.6;
		}
		
		if(PHYS_WATERLEVEL(this) && this.origin.z < (PHYS_WATERLEVEL(this) - 40))
			this.origin.z = PHYS_WATERLEVEL(this) - 40;
		
		this.watertime += dt;
		if(this.watertime > 1 && PHYS_INPUT_BUTTON_JUMP(this) && this.velocity.z < 200)
		{
			this.velocity.z = 275;
#ifdef SVQC
			sound7(this, CHAN_VOICE, SND(WAH_RANDOM()), 0.3 + random() * 0.2, 0.5, 95 + random() * 15, 0);
			this.frame = 2;
			sound7(this, CHAN_AUTO, SND(SPLASH2), 0.3 + random() * 0.3, 0.5, 95 + random() * 15, 0);
#endif
			this.jumpcombo = 1;
			this.watertime = 0;
		}
	}
	else
		this.watertime = 0;

	if(IS_DASHING(this))
		return;

	// Aircontrol

	vector proposed_velocity = this.velocity + (PHYS_INPUT_MOVEVALUES(this).x * v_forward + PHYS_INPUT_MOVEVALUES(this).y * v_right) * dt * 1.3;

	if(vdist(vec2(proposed_velocity), <, 240))
		this.velocity = proposed_velocity;
	else
	{
		vector newvel = normalize(vec2(proposed_velocity)) * vlen(vec2(this.velocity));
		this.velocity.x = newvel.x;
		this.velocity.y = newvel.y;
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
	if(this.health <= 0 || IS_DASHING(this))
		return;
	CSQCPlayer_SmoothAngle(this);
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
