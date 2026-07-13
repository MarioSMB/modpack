#ifdef SVQC
#include "../../server/client.qh"
#include "../jumpsdonewell/_mod.qh"
#include "../tank/tank.qh"
#endif

#ifdef SVQC

void Physics_UpdateStats(entity this)
{
	if(intermission_running)
		STAT(PL_VIEW_OFS, this) = STAT(PL_CROUCH_VIEW_OFS, this) = '0 0 0';
	else
		STAT(PL_VIEW_OFS, this) = STAT(PL_CROUCH_VIEW_OFS, this) = '0 0 22';

	STAT(PL_MIN, this) = STAT(PL_CROUCH_MIN, this) = VEC_HULL_MIN;
	STAT(PL_MAX, this) = STAT(PL_CROUCH_MAX, this) = VEC_HULL_MAX;

	STAT(MOVEVARS_MAXSPEED, this) = autocvar_sv_maxspeed;

	STAT(MOVEVARS_AIRACCEL_QW, this) = autocvar_sv_airaccel_qw;
	STAT(MOVEVARS_AIRSTRAFEACCEL_QW, this) = autocvar_sv_airstrafeaccel_qw;
	STAT(MOVEVARS_AIRSPEEDLIMIT_NONQW, this) = autocvar_sv_airspeedlimit_nonqw;

	STAT(MOVEVARS_AIRACCEL_QW_STRETCHFACTOR, this) = autocvar_sv_airaccel_qw_stretchfactor;
	STAT(MOVEVARS_MAXAIRSTRAFESPEED, this) = autocvar_sv_maxairstrafespeed;
	STAT(MOVEVARS_MAXAIRSPEED, this) = autocvar_sv_maxairspeed;

	STAT(MOVEVARS_AIRSTRAFEACCELERATE, this) = autocvar_sv_airstrafeaccelerate;
	STAT(MOVEVARS_WARSOWBUNNY_TURNACCEL, this) = autocvar_sv_warsowbunny_turnaccel;
	STAT(MOVEVARS_AIRACCEL_SIDEWAYS_FRICTION, this) = autocvar_sv_airaccel_sideways_friction;
	STAT(MOVEVARS_AIRCONTROL, this) = autocvar_sv_aircontrol;
	STAT(MOVEVARS_AIRCONTROL_FLAGS, this) = autocvar_sv_aircontrol_flags;
	STAT(MOVEVARS_AIRCONTROL_POWER, this) = autocvar_sv_aircontrol_power;
	STAT(MOVEVARS_AIRCONTROL_PENALTY, this) = autocvar_sv_aircontrol_penalty;
	STAT(MOVEVARS_WARSOWBUNNY_AIRFORWARDACCEL, this) = autocvar_sv_warsowbunny_airforwardaccel;
	STAT(MOVEVARS_WARSOWBUNNY_TOPSPEED, this) = autocvar_sv_warsowbunny_topspeed;
	STAT(MOVEVARS_WARSOWBUNNY_ACCEL, this) = autocvar_sv_warsowbunny_accel;
	STAT(MOVEVARS_WARSOWBUNNY_BACKTOSIDERATIO, this) = autocvar_sv_warsowbunny_backtosideratio;
	STAT(MOVEVARS_FRICTION, this) = autocvar_sv_friction;
	STAT(MOVEVARS_STEPHEIGHT, this) = autocvar_sv_stepheight;
	STAT(MOVEVARS_ACCELERATE, this) = autocvar_sv_accelerate;
	STAT(MOVEVARS_STOPSPEED, this) = autocvar_sv_stopspeed;
	STAT(MOVEVARS_AIRACCELERATE, this) = autocvar_sv_airaccelerate;
	STAT(MOVEVARS_AIRSTOPACCELERATE, this) = autocvar_sv_airstopaccelerate;
	STAT(MOVEVARS_AIRSTOPACCELERATE_FULL, this) = autocvar_sv_airstopaccelerate_full;

	STAT(MOVEVARS_WALLCLIP, this) = autocvar_sv_wallclip;

	STAT(MOVEVARS_GRAVITY, this) = autocvar_sv_gravity;

	STAT(GAMEPLAYFIX_STEPDOWN, this) = autocvar_sv_gameplayfix_stepdown;

	STAT(MOVEVARS_WALLFRICTION, this) = autocvar_sv_wallfriction;

	Tank_UpdateStats(this);

	slide_UpdateStats(this);

	QCC_UpdateStats(this);

	if(this.sunbeam)
	{
		STAT(MOVEVARS_MAXSPEED, this) *= 0.33;
		STAT(MOVEVARS_MAXAIRSPEED, this) *= 0.33;
	}

	if(gametype == GAMETYPE_JUMPSDONEWELL)
		JDW_Physics_UpdateStats(this);

	if(this.clockwork && !intermission_running)
	{
		STAT(PL_MIN, this) = STAT(PL_CROUCH_MIN, this) = '-8 -8 -1';
		STAT(PL_MAX, this) = STAT(PL_CROUCH_MAX, this) = '8 8 8';
	}
}

.vector movement_old;
.vector v_angle_old;
.int buttons_old;
.bool button_chat_old;
void sys_phys_monitor(entity this, float dt)
{
	int buttons = PHYS_INPUT_BUTTON_MASK(this);
	if (autocvar_sv_maxidle > 0) {
		if (buttons != this.buttons_old
		    || this.movement != this.movement_old
		    || PHYS_INPUT_BUTTON_BUTTON_CHAT(this) != this.button_chat_old
		    || this.v_angle != this.v_angle_old) { this.parm_idlesince = time; }
	}
}
#endif

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

void PM_FixClient(entity this)
{
#ifdef CSQC
	this.movement = PHYS_INPUT_MOVEVALUES(this);
	this.items = STAT(ITEMS, this);
#elif defined(SVQC)
	Physics_UpdateStats(this);
#endif

	QCC_FixClient(this);
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
float autocvar_cl_rollangle;
float autocvar_cl_rollspeed;

// yes, it is confusing seeing cl_ cvars on server side, don't ask
float SV_CalcRoll(entity this)
{
	vector forward, right, up;
	MAKE_VECTORS(this.angles, forward, right, up);

	float side = (this.velocity * right);
	float sign = (side < 0) ? -1 : 1;
	side = fabs(side);

	float value = autocvar_cl_rollangle;

	if(side < autocvar_cl_rollspeed)
		side = side * value / autocvar_cl_rollspeed;
	else
		side = value;

	return side * sign;
}

.float speed;
void sys_phys_fixspeed(entity this, float maxspd_mod)
{
	float spd = max(PHYS_MAXSPEED(this), PHYS_MAXAIRSPEED(this)) * maxspd_mod;
	if (this.speed != spd) {
		this.speed = spd; // TODO: send this as a stat and set the below cvars on the client?
		string temps = ftos(spd);
		stuffcmd(this, strcat("cl_forwardspeed ", temps, "\n"));
		stuffcmd(this, strcat("cl_backspeed ", temps, "\n"));
		stuffcmd(this, strcat("cl_sidespeed ", temps, "\n"));
		stuffcmd(this, strcat("cl_upspeed ", temps, "\n"));
	}
}
#endif

void PlayerJump(entity this, float maxspd_mod, float dt)
{
	if(this.items & IT_TANK)
	{
		Tank_PlayerJump(this, dt);
		return;
	}

	if(this.flags & FL_WATERJUMP)
		return;

	if(PHYS_SLIDE(this))
		Slide_Jump(this);
	
	if(this.waterlevel >= 2)
	{
		float maxspeed = PHYS_MAXSPEED(this) * maxspd_mod;
		if(this.watertype == CONTENT_WATER)
			this.velocity_z = maxspeed * 0.7;
		else if(this.watertype == CONTENT_SLIME)
			this.velocity_z = 80 * maxspd_mod;
		else
			this.velocity_z = 50 * maxspd_mod;

	// play swimming sound
#ifdef SVQC
		if(this.swim_flag < time)
		{
			this.swim_flag = time + 1;
			if(random() < 0.5)
				_sound(this, CH_PLAYER, "misc/water1.wav", 1, ATTN_NORM);
			else
				_sound(this, CH_PLAYER, "misc/water2.wav", 1, ATTN_NORM);
		}
#endif

		return;
	}

	entity actor = this;
#ifdef CSQC
	actor = g_statuseffects;
#endif

	float mjumpheight = 270;

	bool pogo = false;
	bool doublejump = false;
	bool forcedheight = false;
	if(this.viewloc && this.waterlevel >= 2)
		doublejump = true;
	if(this.m_champion)
	{
		pogo = this.m_champion.qcc_pogo;
		if(this.m_champion.m_doublejump && this.m_champion.m_doublejump(this.m_champion, this))
			doublejump = true;
	}

	if(STAT(PASSIVES, this) & PASSIVE_BUNNYBOOTS)
		pogo = true;

	if(deathmatch && STAT(SKILL, this) == 3 && STAT(INSTAGIB_POGO, this))
		pogo = true;

	if(StatusEffects_active(STATUSEFFECT_DoubleJumpBoots, actor))
	{
		if(!IS_DOUBLEJUMPED(this) && !IS_JUMP_HELD(this) && !IS_ONGROUND(this))
		{
			doublejump = true;
			mjumpheight *= 1.5;
			forcedheight = true; // don't allow champions to override
			SET_DOUBLEJUMPED(this);
		}
	}

	if(!IS_ONGROUND(this) && !doublejump)
		return;

	if(IS_JUMP_HELD(this) && !StatusEffects_active(STATUSEFFECT_JumpBoots, actor) && !pogo)
		return;		// don't pogo stick

	SET_JUMP_HELD(this);

	if(STAT(CLOCKWORK, this))
		mjumpheight *= 0.75;
	if(this.m_champion && !forcedheight)
	{
		mjumpheight *= this.m_champion.qcc_jumpheight;
		if(this.m_champion.m_playerjump)
			mjumpheight *= this.m_champion.m_playerjump(this.m_champion, this);
	}
	if(StatusEffects_active(STATUSEFFECT_JumpBoots, actor))
		mjumpheight *= 1.5;
	if(this.viewloc && !forcedheight)
	{
		if(this.waterlevel >= 2)
			mjumpheight *= 0.7;
		else
			mjumpheight *= 1.5;
	}

	if(mjumpheight <= 0)
		return;

	UNSET_ONGROUND(this);

	if(PHYS_SKATING(this))
	{
		if(!PHYS_BOARD_FALLING(this))
		{
		#ifdef SVQC
			_sound(this, CH_PLAYER, "player/skatejmp.wav", 1, ATTN_NORM);
			this.walkframe = 13;
			this.buttonjump_held = true;
		#endif
			this.velocity_z += mjumpheight;
			this.jump_vel = this.velocity;
		}
		return;
	}
	
#ifdef SVQC
	//this.button2 = 0;
// player jumping sound
	if(this.clockwork)
		sound7(this, CH_PLAYER, "player_banjo/flight.wav", 1, ATTN_NORM, 175, 0);
	else
		playersound(this, CH_PLAYER, get_jumpsound(this), 1, ATTN_NORM);
#endif
	if(forcedheight)
		this.velocity_z = mjumpheight;
	else
		this.velocity_z += mjumpheight;
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
	if(StatusEffects_active(STATUSEFFECT_Wetsuit, this))
	{
		if(this.waterlevel >= 2)
		{
			// play scuba sound
			if(this.swim_flag < time)
			{
				this.swim_flag = time + 7;
				_sound(this, CH_PLAYER, "misc/wetsuit.wav", 1, ATTN_NORM);
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

void PM_LadderMove(entity this, float maxspd_mod, float dt)
{
	makevectors(this.v_angle);

	vector wishvel;
	wishvel = v_forward * this.movement_x + v_right * this.movement_y + '0 0 1' * this.movement_z;

	float maxspeed = PHYS_MAXSPEED(this) * maxspd_mod;

	vector wishdir = normalize(wishvel);
	float wishspeed = min(maxspeed, vlen(wishvel));
	wishspeed *= 4.0; // counteracts the friction penalty

	// friction
	float frict = PHYS_FRICTION(this);
	frict = 64;
	float speed = vlen(this.velocity);
	float spd = (1 - dt * frict);
	float newspeed = max(0, speed - spd);
	this.velocity *= spd;

	// acceleration
	if (!wishspeed)
		return;

	float addspeed = wishspeed - newspeed;
	if (addspeed <= 0)
		return;

	float accel = PHYS_ACCELERATE(this);
	float accelspeed = accel * wishspeed * dt;
	if (accelspeed > addspeed)
		accelspeed = addspeed;

	this.velocity += accelspeed * wishdir;
}

void CheckWaterJump(entity this)
{
	// check for a jump-out-of-water
	fixedmakevectors(this.angles);
	vector start = this.origin;
	start.z = start.z + 8; 
	v_forward_z = 0;
	normalize(v_forward);
	vector end = start + v_forward*24;
	traceline(start, end, MOVE_NOMONSTERS, this);
	if(trace_fraction < 1)
	{	// solid at waist
		start.z = start.z + this.maxs_z - 8;
		end = start + v_forward * 24;
		this.movedir = trace_plane_normal * -50;
		traceline(start, end, MOVE_NOMONSTERS, this);
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

void PM_WaterMove(entity this, float maxspd_mod, float dt)
{
	makevectors(this.v_angle);

	vector wishvel;
	wishvel = v_forward * this.movement_x + v_right * this.movement_y + '0 0 1' * this.movement_z;
	if (this.viewloc)
		wishvel.z = -160;    // drift anyway
	else if (wishvel == '0 0 0')
		wishvel = '0 0 -60'; // drift towards bottom

	float maxspeed = PHYS_MAXSPEED(this) * maxspd_mod;

	vector wishdir = normalize(wishvel);
	float wishspeed = min(maxspeed, vlen(wishvel));
	if(StatusEffects_active(STATUSEFFECT_Wetsuit, this))
	{
		if(this.waterlevel == 2)
			wishspeed *= 1.25;
		else if(this.waterlevel == 3)
			wishspeed *= 1.5;
	}
	wishspeed *= 0.7;

	// water friction
	float frict = PHYS_FRICTION(this);
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

	float accel = PHYS_ACCELERATE(this);
	if(StatusEffects_active(STATUSEFFECT_Wetsuit, this))
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
	if(time > this.teleport_time || this.waterlevel == 0)
	{
		this.flags &= ~FL_WATERJUMP;
		this.teleport_time = 0;
	}

	this.velocity_x = this.movedir_x;
	this.velocity_y = this.movedir_y;
}

float AdjustAirAccelQW(float accelqw, float factor)
{
	return copysign(bound(0.000001, 1 - (1 - fabs(accelqw)) * factor, 1), accelqw);
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
		float vel_xy_preclamp = vlen(vel_xy);
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

void PM_walk(entity this, float maxspd_mod, float dt)
{
	makevectors(this.angles_y * '0 1 0');
	vector wishvel = v_forward * this.movement_x + v_right * this.movement_y;

	float wishspeed = vlen(wishvel);
	vector wishdir = wishspeed ? wishvel * (1 / wishspeed) : '0 0 0';
	wishspeed = min(wishspeed, PHYS_MAXSPEED(this) * maxspd_mod);

	// apply edge friction
	float f2 = vlen2(vec2(this.velocity));
	int realfriction = PHYS_FRICTION(this);

	if(this.m_champion && this.m_champion.m_friction)
		realfriction *= this.m_champion.m_friction(this.m_champion, this);

	if (f2 > 0 && realfriction > 0)
	{
		// TODO: apply edge friction
		// apply ground friction

		float f = sqrt(f2);
		const float S = PHYS_STOPSPEED(this);
		//f = 1 - dt * realfriction * ((f < S) ? (S / f) : 1);
		// k9er: documentation here https://gitlab.com/otta8634/xonotic-physics
		const float dt_r = 0.00390625;
		// minor optimization, but it's only useful if friction > 1/dt_r
		//if (realfriction * dt_r >= 1)
		//	f = 0;
		//else
		{
			const float independent_geometric = (1 - realfriction * dt_r) ** (dt / dt_r);
			// NOTE: first condition ensures subframe accuracy in the geometric -> linear transition, may be not worth the hassle
			if (S < f && f < S / independent_geometric)
			{
				this.velocity = normalize(this.velocity);
				f = S - S * realfriction * (dt - (dt_r * log(S / f)) / log(1 - realfriction * dt_r));
			}
			else if (f >= S)
				f = independent_geometric;
			else
				f = 1 - realfriction * dt * S / f;
			f = max(0, f);
		}
		this.velocity *= f;
	}
	const float addspeed = wishspeed - this.velocity * wishdir;
	if (addspeed > 0)
	{
		const float accel = PHYS_ACCELERATE(this);
		const float accelspeed = min(accel * dt * wishspeed, addspeed);
		this.velocity += accelspeed * wishdir;
	}
}

void CPM_PM_Aircontrol(entity this, float dt, vector wishdir, float wishspeed)
{
	float movity = IsMoveInDirection(this.movement, 0);
	if(PHYS_AIRCONTROL_FLAGS(this) & BIT(0)) // backwards
		movity += IsMoveInDirection(this.movement, 180);
	if(PHYS_AIRCONTROL_FLAGS(this) & BIT(1)) // sidewards
	{
		movity += IsMoveInDirection(this.movement, 90);
		movity += IsMoveInDirection(this.movement, -90);
	}

	float k = 2 * movity - 1;
	if (k <= 0)
		return;
	if (!(PHYS_AIRCONTROL_FLAGS(this) & BIT(2))) // crouching has an impact
		k *= bound(0, wishspeed / PHYS_MAXAIRSPEED(this), 1);

	const float zspeed = this.velocity_z;
	this.velocity_z = 0;
	float xyspeed = vlen(this.velocity);
	this.velocity = normalize(this.velocity);

	float dot = this.velocity * wishdir;

	if (dot > 0) // we can't change direction while slowing down
	{
		k *= (dot ** PHYS_AIRCONTROL_POWER(this)) * dt;
		xyspeed = max(0, xyspeed - PHYS_AIRCONTROL_PENALTY(this) * sqrt(max(0, 1 - dot*dot)) * k);
		k *= 32 * fabs(PHYS_AIRCONTROL(this));
		this.velocity = normalize(this.velocity * xyspeed + wishdir * k);
	}

	this.velocity *= xyspeed;
	this.velocity_z = zspeed;
}

void PM_air(entity this, float maxspd_mod, float dt)
{
	makevectors(this.angles_y * '0 1 0');
	vector wishvel = v_forward * this.movement_x + v_right * this.movement_y;

	float wishspeed = vlen(wishvel);
	vector wishdir = wishspeed ? wishvel * (1 / wishspeed) : '0 0 0';
	wishspeed = min(wishspeed, PHYS_MAXAIRSPEED(this) * maxspd_mod);

	// apply air speed limit
	float airaccelqw = PHYS_AIRACCEL_QW(this);
	float wishspeed0 = wishspeed;
	const float maxairspd = PHYS_MAXAIRSPEED(this) * maxspd_mod;
	wishspeed = min(wishspeed, maxairspd);

	float airaccel = PHYS_AIRACCELERATE(this) * maxspd_mod;

	float accelerating = (this.velocity * wishdir > 0);
	float wishspeed2 = wishspeed;

	// CPM: air control
	if (PHYS_AIRSTOPACCELERATE(this))
	{
		const float dot = normalize(vec2(this.velocity)) * wishdir;
		if (dot < 0)
		{
			if (PHYS_AIRSTOPACCELERATE_FULL(this))
				airaccel = (PHYS_AIRSTOPACCELERATE(this) * maxspd_mod); // full slow-down
			else
				airaccel += (airaccel - (PHYS_AIRSTOPACCELERATE(this) * maxspd_mod)) * dot; // sinusoidal slow-down
		}
	}
	// note that for straight forward jumping:
	// step = accel * dt * wishspeed0;
	// accel  = bound(0, wishspeed - vel_xy_current, step) * accelqw + step * (1 - accelqw);
	// -->
	// dv/dt = accel * maxspeed (when slow)
	// dv/dt = accel * maxspeed * (1 - accelqw) (when fast)
	// log dv/dt = logaccel + logmaxspeed (when slow)
	// log dv/dt = logaccel + logmaxspeed + log(1 - accelqw) (when fast)
	float strafity = IsMoveInDirection(this.movement, -90) + IsMoveInDirection(this.movement, +90);  // if one is nonzero, other is always zero
	if (PHYS_MAXAIRSTRAFESPEED(this))
		wishspeed = min(wishspeed, GeomLerp(PHYS_MAXAIRSPEED(this) * maxspd_mod,
			                                strafity,
			                                PHYS_MAXAIRSTRAFESPEED(this) * maxspd_mod));

	if (PHYS_AIRSTRAFEACCELERATE(this))
		airaccel = GeomLerp(airaccel, strafity, PHYS_AIRSTRAFEACCELERATE(this) * maxspd_mod);

	if (PHYS_AIRSTRAFEACCEL_QW(this))
		airaccelqw =
			(((strafity > 0.5 ? PHYS_AIRSTRAFEACCEL_QW(this) : PHYS_AIRACCEL_QW(this)) >= 0) ? +1 : -1)
			*
			(1 - GeomLerp(1 - fabs(PHYS_AIRACCEL_QW(this)), strafity, 1 - fabs(PHYS_AIRSTRAFEACCEL_QW(this))));
	// !CPM

	if (PHYS_WARSOWBUNNY_TURNACCEL(this) && accelerating && this.movement.y == 0 && this.movement.x != 0)
		PM_AirAccelerate(this, dt, wishdir, wishspeed2);
	else
	{
		float sidefric = maxairspd ? (PHYS_AIRACCEL_SIDEWAYS_FRICTION(this) / maxairspd) : 0;
		PM_Accelerate(this, dt, wishdir, wishspeed, wishspeed0, airaccel, airaccelqw,
			PHYS_AIRACCEL_QW_STRETCHFACTOR(this), sidefric, PHYS_AIRSPEEDLIMIT_NONQW(this));
	}

	if (PHYS_AIRCONTROL(this))
		CPM_PM_Aircontrol(this, dt, wishdir, wishspeed2);
}

void PM_noclip(entity this, float maxspd_mod, float dt)
{
	makevectors(this.angles_y * '0 1 0');
	vector wishvel = v_forward * this.movement_x + v_right * this.movement_y;

	if(this.move_movetype != MOVETYPE_WALK)
		wishvel.z += this.movement_z;

	float maxspeed = PHYS_MAXSPEED(this) * maxspd_mod;
	//vector wishdir = normalize(wishvel);
	float wishspeed = vlen(wishvel);
	if (wishspeed > maxspeed)
	{
		if(maxspeed == 0)
			wishvel *= maxspeed;
		else
			wishvel *= maxspeed / wishspeed;
		wishspeed = maxspeed;
	}

	makevectors(this.v_angle);
	wishvel = v_forward * this.movement_x + v_right * this.movement_y + '0 0 1' * this.movement_z;
	this.velocity = wishvel;
}

void PM_RollView(entity this)
{
#ifdef SVQC
	vector vang = this.v_angle + this.punchangle;

	this.angles_z = SV_CalcRoll(this) * 4;

	if(!this.fixangle) { this.angles = '0 1 0' * vang.y; }
#endif
}

bool CheckLadder(entity this);
bool CheckWallClimb(entity this);

vector PlayerTouchWall(entity this);

bool CheckWallClimb(entity this)
{
	if(!this.m_champion || !this.m_champion.qcc_wallclimb)
		return false;
	if(IS_ONGROUND(this))
		return false;

	vector plane_normal = PlayerTouchWall(this);
	return (plane_normal != '0 0 0');
}

void PM_Main(entity this, float dt)
{
	PM_FixClient(this);

#ifdef SVQC
	sys_phys_monitor(this, dt);
	this.movement_old = this.movement;
	this.v_angle_old = this.v_angle;
	this.buttons_old = PHYS_INPUT_BUTTON_MASK(this);
	this.button_chat_old = PHYS_INPUT_BUTTON_BUTTON_CHAT(this);
#endif

	if(this.move_movetype == MOVETYPE_NONE)
		return;

	// TODO: less overrides?
	if(gametype == GAMETYPE_JUMPSDONEWELL)
	{
		JDW_PM_Main(this, dt);
		return;
	}

	if(StatusEffects_active(STATUSEFFECT_Confused, this))
	{
		this.movement_x *= -1;
		this.movement_y *= -1;
	}

	if(STAT(QCC_STUNNED, this) > time)
		this.movement = '0 0 0';

	viewloc_PlayerPhysics(this);

	SV_check_punch(this, dt);

	if(STAT(KIRBY_ZAPTIME, this) > time)
	{
		this.velocity_z = 0; // cancel out gravity?
		return;
	}

	if(PHYS_EXPTIME(this) != 0 || STAT(CANNON, this))
	{
		this.velocity = '0 0 0';
		return;
	}

	if(PHYS_HEALTH(this) <= 0)
		return;

	PM_RollView(this);

	entity actor = this;
#ifdef CSQC
	actor = g_statuseffects;
#endif

	float maxspeed_mod = 1;
	maxspeed_mod *= dodgeball_GetMoveSpeed(this);
	if(STAT(PASSIVES, this) & PASSIVE_HERMESBOOTS)
		maxspeed_mod *= 1.5;
	if(StatusEffects_active(STATUSEFFECT_Slowness, actor))
		maxspeed_mod *= 0.25;
	if(this.m_champion)
	{
		maxspeed_mod *= this.m_champion.qcc_movespeed;
		if(this.m_champion.m_getmovespeed)
			maxspeed_mod *= this.m_champion.m_getmovespeed(this.m_champion, this);

		if(this.waterlevel >= 2 && !(this.flags & FL_WATERJUMP) && !(this.items & IT_TANK) && this.move_movetype != MOVETYPE_NOCLIP)
			maxspeed_mod *= this.m_champion.qcc_swimspeed;
	}

#ifdef SVQC
	sys_phys_fixspeed(this, maxspeed_mod);
#endif

	// TODO clean up this mess of a setup
	if(this.m_champion == CHAMPION_Duke || this.m_champion == CHAMPION_FloydChamp)
		Duke_PreJump(this);
	if(this.m_champion == CHAMPION_BanjoKazooie)
		Banjo_PreJump(this);
	if(this.m_champion == CHAMPION_Kirby)
		Kirby_PreJump(this);

	if(IS_ONGROUND(this))
		UNSET_DOUBLEJUMPED(this);

	if(PHYS_INPUT_BUTTON_JUMP(this))
		PlayerJump(this, maxspeed_mod, dt);
	else if(!PHYS_SKATING(this) || IS_ONGROUND(this))
		UNSET_JUMP_HELD(this);

	if(PHYS_SKATING(this))
		skate_drive(this);
	else if(PHYS_SLIDE(this))
		slide_physics(this);
	else if(champions_PlayerPhysics(this, dt))
		return;
	else if(dodgeball_PlayerPhysics(this))
		return;

	WaterMove(this, dt);

	if(this.waterlevel == 2)
		CheckWaterJump(this);

	if(this.flags & FL_WATERJUMP)
	{
		PM_WaterJump(this);
		return;
	}

	if(this.move_movetype == MOVETYPE_NOCLIP || this.move_movetype == MOVETYPE_FLY)
		PM_noclip(this, maxspeed_mod, dt);
	else if(CheckLadder(this))
	{
		PM_LadderMove(this, maxspeed_mod, dt);
		return;
	}
	else if(this.waterlevel >= 2 || CheckWallClimb(this))
	{
		PM_WaterMove(this, maxspeed_mod, dt);
		return;
	}
	else if(IS_ONGROUND(this))
		PM_walk(this, maxspeed_mod, dt);
	else
		PM_air(this, maxspeed_mod, dt);
}

void player_touch(entity this, entity toucher) 
{
	entity actor = this;
#ifdef CSQC
	actor = g_statuseffects;
#endif
	if(StatusEffects_active(STATUSEFFECT_JumpBoots, actor))
	{
	#ifdef SVQC
		if(IS_PLAYER(toucher) || IS_MONSTER(toucher))
	#elif defined(CSQC)
		if(IS_PLAYER(toucher))
	#endif
		{
			if(tracebox_hits_box(this.origin, this.mins, this.maxs, this.origin - ('0 0 1' * (this.maxs_z + 5)), toucher.origin + toucher.mins, toucher.origin + toucher.maxs))
			{
				setorigin(this, this.origin + '0 0 2'); // make sure onground doesn't catch us later

				float mjumpheight = 300;
				if(PHYS_INPUT_BUTTON_JUMP(this))
				{
					mjumpheight *= 1.5;
					SET_JUMP_HELD(this);
				}

				UNSET_ONGROUND(this);
				this.velocity_z = mjumpheight;
		#ifdef SVQC
				this.oldvelocity_z = this.velocity_z;

				//animdecide_setaction(this, ANIMACTION_JUMP, true);

				float thedamage = 200;
				T_Damage(toucher, this, this, thedamage, DEATH_CRUSH.m_id);
				_sound(this, CH_TRIGGER_SINGLE, "items/goomba.wav", 1, ATTN_NORM);
		#endif
				return;
			}
		}
	}
#ifdef SVQC
	if(StatusEffects_active(STATUSEFFECT_PowerShield, this))
	{
		if(IS_MONSTER(toucher) && !(toucher.monsterdef.spawnflags & MONSTER_TYPE_BOSS) && !(toucher.monsterdef.spawnflags & MON_FLAG_STATIONARY) && !(toucher.monsterdef.spawnflags & MONSTER_TYPE_DECOY))
		{
			makevectors(this.angles);
			vector vec = normalize(toucher.origin - this.origin);
			float dot = vec * v_forward;
			if(dot < 0.3)
				return;

			float pushforce = 100 / vlen(toucher.maxs - toucher.mins);

			makevectors(this.angles);
			toucher.velocity = v_forward * (500 * pushforce);
			toucher.velocity_z = (250 * pushforce);

			// if shield has timed out, respawn it.
			// don't do particles more than twice a second. 
			if(this.shield_death_time < time)
			{
				_sound(this, CH_WEAPON_SINGLE, "enforcer/enfstop.wav", 1, ATTN_NORM);
	
				te_explosion2(toucher.origin, 230, 5);

				shield_spawn(this, v_forward);
			}

			T_Damage(toucher, this.shield_entity, this, 15, DEATH_SHIELD.m_id);

//			this.shield_death_time = time + 0.5;
		}
	}
#endif

	slide_PlayerTouch(this, toucher);
	champions_PlayerTouch(this, toucher);
#ifdef SVQC
	cannon_PlayerTouch(this, toucher);
#endif
}

#if defined(SVQC)
void SV_PlayerPhysics(entity this)
#elif defined(CSQC)
void CSQC_ClientMovement_PlayerMove_Frame(entity this)
#endif
{
#ifdef CSQC
	if(gettouch(this) != player_touch)
		settouch(this, player_touch);
#endif

	PM_Main(this, PHYS_INPUT_TIMELENGTH);

#ifdef SVQC
	this.pm_frametime = frametime;
#elif defined(CSQC)
	if(this.jetpack_status && !this.csqcmodel_isdead && !intermission && !STAT(CANNON, this) && (this.m_champion == CHAMPION_Duke || this.m_champion == CHAMPION_FloydChamp))
		this.csqcmodel_modelflags |= MF_ROCKET;
	else
		this.csqcmodel_modelflags &= ~MF_ROCKET;
#endif
}
