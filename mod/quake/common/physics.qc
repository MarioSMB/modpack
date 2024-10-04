#ifdef SVQC
#include "../server/client.qh"
#include "tank/tank.qh"
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

	STAT(MOVEVARS_WALLFRICTION, this) = autocvar_sv_wallfriction;

	STAT(MOVEVARS_FRICTION_WATER, this) = autocvar_sv_waterfriction;
	STAT(MOVEVARS_WATERACCELERATE, this) = autocvar_sv_wateraccelerate;
	STAT(MOVEVARS_FRICTION_EDGE, this) = autocvar_edgefriction;

	STAT(MOVEVARS_FRICTION, this) = autocvar_sv_friction;
	STAT(MOVEVARS_ACCELERATE, this) = autocvar_sv_accelerate;
	STAT(MOVEVARS_MAXSPEED, this) = autocvar_sv_maxspeed;
	STAT(MOVEVARS_STOPSPEED, this) = autocvar_sv_stopspeed;
	STAT(MOVEVARS_MAXAIRSPEED, this) = autocvar_sv_maxairspeed;
	STAT(MOVEVARS_AIRACCELERATE, this) = autocvar_sv_airaccelerate;

	STAT(MOVEVARS_WALLCLIP, this) = autocvar_sv_wallclip;

	Tank_UpdateStats(this);

	slide_UpdateStats(this);

	QCC_UpdateStats(this);

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

	bool pogo = false;
	bool doublejump = false;
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

	if(STAT(PASSIVES, this) & PASSIVE_DOUBLEJUMP)
	{
		if(!IS_DOUBLEJUMPED(this) && !IS_JUMP_HELD(this) && !IS_ONGROUND(this))
		{
			doublejump = true;
			SET_DOUBLEJUMPED(this);
		}
	}

	if(!IS_ONGROUND(this) && !doublejump)
		return;

	entity actor = this;
#ifdef CSQC
	actor = g_statuseffects;
#endif

	if(IS_JUMP_HELD(this) && !StatusEffects_active(STATUSEFFECT_JumpBoots, actor) && !pogo)
		return;		// don't pogo stick

	SET_JUMP_HELD(this);

	UNSET_ONGROUND(this);

	float mjumpheight = 270;
	if(STAT(CLOCKWORK, this))
		mjumpheight *= 0.75;
	if(this.m_champion)
	{
		mjumpheight *= this.m_champion.qcc_jumpheight;
		if(this.m_champion.m_playerjump)
			mjumpheight *= this.m_champion.m_playerjump(this.m_champion, this);
	}
	if(StatusEffects_active(STATUSEFFECT_JumpBoots, actor))
		mjumpheight *= 1.5;
	if(this.viewloc)
	{
		if(this.waterlevel >= 2)
			mjumpheight *= 0.7;
		else
			mjumpheight *= 1.5;
	}

	if(mjumpheight <= 0)
		return;

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
		player_sound(this, CH_PLAYER, "plyrjmp8.wav", ATTN_NORM);
#endif
	this.velocity_z = this.velocity_z + mjumpheight;
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
	entity actor = this;
#ifdef CSQC
	actor = g_statuseffects;
#endif
	if(StatusEffects_active(STATUSEFFECT_Wetsuit, actor))
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
	if(StatusEffects_active(STATUSEFFECT_Wetsuit, actor))
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

	if(this.m_champion && this.m_champion.m_friction)
		friction *= this.m_champion.m_friction(this.m_champion, this);

	float control = (speed < PHYS_STOPSPEED(this)) ? PHYS_STOPSPEED(this) : speed;
	float newspeed = speed - dt * control * friction;

	if(newspeed <= 0)
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
	float airaccel = (this.viewloc) ? 20 : PHYS_AIRACCELERATE(this);
	float accelspeed = (airaccel < 0 ? PHYS_ACCELERATE(this) : airaccel)
			* (GAMEPLAYFIX_Q2AIRACCELERATE ? wishspd : wishspeed) * dt;
	if(accelspeed > addspeed)
		accelspeed = addspeed;

	this.velocity += accelspeed * wishdir;
}

void PM_AirMove(entity this, float maxspd_mod, float dt)
{
	makevectors(this.angles_y * '0 1 0');
	vector wishvel = v_forward * this.movement_x + v_right * this.movement_y;

	if(this.move_movetype != MOVETYPE_WALK)
		wishvel.z += this.movement_z;

	float maxspeed = PHYS_MAXSPEED(this) * maxspd_mod;
	vector wishdir = normalize(wishvel);
	float wishspeed = vlen(wishvel);
	if (wishspeed > maxspeed)
	{
		if(maxspeed == 0)
			wishvel *= maxspeed;
		else
			wishvel *= maxspeed / wishspeed;
		wishspeed = maxspeed;
	}

	if(time < this.teleport_time)
	{
		// do nothing
	}
	// NOTE: not using else if here as it causes the player to lose control for a second after teleporting (annoying)
	if(this.move_movetype == MOVETYPE_NOCLIP)
	{
		// noclip
		makevectors(this.v_angle);
		wishvel = v_forward * this.movement_x + v_right * this.movement_y + '0 0 1' * this.movement_z;
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

void cannon_PlayerPhysics(entity this, float dt)
{
	this.velocity = '0 0 0';
}

bool CheckLadder(entity this);

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

	viewloc_PlayerPhysics(this);

	SV_check_punch(this, dt);

	if(STAT(QCC_STUNNED, this) > time || PHYS_EXPTIME(this) != 0 || STAT(CANNON, this))
	{
		this.velocity = '0 0 0';
		return;
	}

	if(PHYS_HEALTH(this) <= 0)
		return;

	PM_RollView(this);

	float maxspeed_mod = 1;
	maxspeed_mod *= dodgeball_GetMoveSpeed(this);
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
	if(this.m_champion == CHAMPION_Duke)
		Duke_PreJump(this);
	if(this.m_champion == CHAMPION_BanjoKazooie)
		Banjo_PreJump(this);

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

	if((this.waterlevel >= 2 || CheckLadder(this)) && this.move_movetype != MOVETYPE_NOCLIP)
	{
		PM_WaterMove(this, maxspeed_mod, dt);
		return;
	}

	PM_AirMove(this, maxspeed_mod, dt);
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
	if(StatusEffects_active(STATUSEFFECT_Shield, this))
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
	if(this.jetpack_status && !this.csqcmodel_isdead && !intermission && !STAT(CANNON, this) && this.m_champion == CHAMPION_Duke)
		this.csqcmodel_modelflags |= MF_ROCKET;
	else
		this.csqcmodel_modelflags &= ~MF_ROCKET;
#endif
}
