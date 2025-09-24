#include "galena.qh"

#if 0
#ifdef CSQC
	#define PHYS_DODGING_FRAMETIME				(1 / (frametime <= 0 ? 60 : frametime))
#elif defined(SVQC)
	#define PHYS_DODGING_FRAMETIME				sys_frametime
#endif

// set to 1 to indicate dodging has started.. reset by physics hook after dodge has been done..
.float dodging_action;

// the jump part of the dodge cannot be ramped
.float dodging_single_action;

// these store the movement direction at the time of the dodge action happening.
.vector dodging_direction;

// this indicates the last time a dodge was executed. used to check if another one is allowed
// and to ramp up the dodge acceleration in the physics hook.
.float last_dodging_time;

// the total speed that will be added over the ramp time
.float dodging_force_total;
// the part of total yet to be added
.float dodging_force_remaining;

.int pressedkeys;

#define X(dir) \
	tracebox(this.origin, this.mins, this.maxs, this.origin + threshold * dir, true, this); \
	if (trace_fraction < 1 && !(trace_dphitq3surfaceflags & Q3SURFACEFLAG_SKY)) \
		return true;

// returns true if the player is close to a wall
bool is_close_to_wall(entity this, float threshold, vector forward, vector right)
{
	X(right);
	X(-right);
	X(forward);
	X(-forward);

	return false;
}

bool is_close_to_ground(entity this, float threshold, vector up)
{
	if (IS_ONGROUND(this)) return true;
	X(-up); // necessary for dodging down a slope using doubletap (using `+dodge` works anyway)

	return false;
}

#undef X

float determine_force(entity player) {
	float horiz_vel = vlen(vec2(player.velocity));
	return map_bound_ranges(horiz_vel,
	                        200, 1000,
	                        400, 400);
}

bool PM_dodging_checkpressedkeys(entity this)
{
	float tap_direction_x = 0;
	float tap_direction_y = 0;
	bool dodge_detected = false;
	vector mymovement = this.movement;

	#define X(COND,BTN,RESULT)																			\
	if (mymovement_##COND) {																			\
		tap_direction_##RESULT;																			\
		if(PHYS_INPUT_BUTTON_CROUCH(this)) {															\
			dodge_detected = true;																		\
		}																								\
	}
	X(x < 0, BACKWARD,	x--);
	X(x > 0, FORWARD,	x++);
	X(y < 0, LEFT,		y--);
	X(y > 0, RIGHT,		y++);
	#undef X

	if (!dodge_detected) return false;

	// this check has to be after checking keys:
	// the first key press of the double tap is allowed to be before dodging delay,
	// only the second has to be after, otherwise +dodge gives an advantage because typical repress time is 0.1 s
	// or higher which means players using +dodge would be able to do it more often
	if ((time - this.last_dodging_time) < 1.2)
		return false;

	vector forward, right, up;
	MAKE_VECTORS(this.angles, forward, right, up);

	bool can_dodge = (is_close_to_ground(this, 10, up) && vdist(this.velocity, <, 450));
	if (!can_dodge) return false;

	this.last_dodging_time = time;

	this.dodging_action = 1;
	this.dodging_single_action = 1;

	this.dodging_force_total = determine_force(this);
	this.dodging_force_remaining = this.dodging_force_total;

	this.dodging_direction.x = tap_direction_x;
	this.dodging_direction.y = tap_direction_y;

	// normalize the dodging_direction vector.. (unlike UT99) XD
	float length = sqrt(this.dodging_direction.x ** 2 + this.dodging_direction.y ** 2);

	this.dodging_direction.x = this.dodging_direction.x / length;
	this.dodging_direction.y = this.dodging_direction.y / length;

	return true;
}

void PM_dodging(entity this)
{
	// can't use return value from PM_dodging_checkpressedkeys because they're called from different hooks
	if (!this.dodging_action) return;

	// when swimming or dead, no dodging allowed..
	if (this.waterlevel >= WATERLEVEL_SWIMMING || STAT(HEALTH, this) <= 0)
	{
		this.dodging_action = 0;
		this.dodging_direction.x = 0;
		this.dodging_direction.y = 0;
		return;
	}

	vector forward, right, up;
	MAKE_VECTORS(this.angles, forward, right, up);

	// fraction of the force to apply each frame
	// if we have e.g. 0.5 sec ramptime and a frametime of 0.25, then the ramp code
	// will be called ramp_time/frametime times = 2 times. so, we need to
	// add 0.5 * the total speed each frame until the dodge action is done..
	float common_factor = PHYS_DODGING_FRAMETIME / 0.1;
	// NOTE: depending on cl_netfps the client may (and probably will) send more input frames during each server frame
	// but common_factor uses server frame rate so players with higher cl_netfps will ramp slightly faster

	float velocity_increase = min(common_factor * this.dodging_force_total, this.dodging_force_remaining);
	this.dodging_force_remaining -= velocity_increase;
	this.velocity += this.dodging_direction.x * velocity_increase * forward
	               + this.dodging_direction.y * velocity_increase * right;

	// the up part of the dodge is a single shot action
	if (this.dodging_single_action == 1)
	{
		UNSET_ONGROUND(this);

		this.velocity += 200 * up;

#ifdef SVQC
		player_sound(this, CH_PLAYER, "plyrjmp8.wav", ATTN_NORM);
#endif

		this.dodging_single_action = 0;
	}

	if(this.dodging_force_remaining <= 0)
	{
		// reset state so next dodge can be done correctly
		this.dodging_action = 0;
		this.dodging_direction.x = 0;
		this.dodging_direction.y = 0;
	}
}

void PM_dodging_GetPressedKeys(entity this)
{
	PM_dodging_checkpressedkeys(this);

	// NOTE: GetPressedKeys and PM_dodging_GetPressedKeys use similar code
	int keys = this.pressedkeys;
	keys = BITSET(keys, KEY_FORWARD, 	this.movement.x > 0);
	keys = BITSET(keys, KEY_BACKWARD, 	this.movement.x < 0);
	keys = BITSET(keys, KEY_RIGHT, 		this.movement.y > 0);
	keys = BITSET(keys, KEY_LEFT, 		this.movement.y < 0);

	keys = BITSET(keys, KEY_JUMP, 		PHYS_INPUT_BUTTON_JUMP(this));
	//keys = BITSET(keys, KEY_CROUCH, 	IS_DUCKED(this)); // workaround: player can't un-crouch until their path is clear, so we keep the button held here
	keys = BITSET(keys, KEY_ATCK, 		PHYS_INPUT_BUTTON_ATCK(this));
	keys = BITSET(keys, KEY_ATCK2, 		PHYS_INPUT_BUTTON_ATCK2(this));
	this.pressedkeys = keys;
}

#ifdef SVQC
void dodging_ResetPlayer(entity this)
{
	this.last_dodging_time = 0;

	this.dodging_action = 0;
	this.dodging_single_action = 0;

	this.dodging_force_total = 0;
	this.dodging_force_remaining = 0;

	this.dodging_direction = '0 0 0';
}
#endif
#endif

#if 0
METHOD(Galena, m_physics, bool(Champions this, entity actor, float dt))
{
	PM_dodging_GetPressedKeys(actor);
	PM_dodging(actor);
	return false;
}
#else
METHOD(Galena, m_physics, bool(Champions this, entity actor, float dt))
{
	if(vdist(actor.velocity, <=, PHYS_MAXSPEED(actor)) && vdist(actor.velocity, >, PHYS_MAXSPEED(actor) * 0.5) && PHYS_INPUT_BUTTON_CROUCH(actor) && IS_ONGROUND(actor) && !QCC_HasSpellbook(actor))
	{
		float tap_direction_x = 0;
		float tap_direction_y = 0;
		bool dodge_detected = false;
		vector mymovement = actor.movement;

		#define X(COND,RESULT)																			\
		if (mymovement_##COND) {																			\
			tap_direction_##RESULT;																			\
			dodge_detected = true;																			\
		}
		X(x < 0,	x--);
		X(x > 0,	x++);
		X(y < 0,	y--);
		X(y > 0,	y++);
		#undef X

		if(!dodge_detected)
			return false;

		// normalize the dodging_direction vector.. (unlike UT99) XD
		float length = sqrt(tap_direction_x ** 2 + tap_direction_y ** 2);

		tap_direction_x = tap_direction_x / length;
		tap_direction_y = tap_direction_y / length;

	#ifdef SVQC
		player_sound(actor, CH_PLAYER, "plyrjmp8.wav", ATTN_NORM);
		STAT(QCC_ABILITYTIME, actor) = time + 1;
		actor.galena_dodge_time = time + 0.33;
	#endif
		vector vang = PHYS_INPUT_ANGLES(actor);
		makevectors('0 1 0' * vang.y);
		actor.velocity += tap_direction_x * 300 * v_forward + tap_direction_y * 300 * v_right;
		actor.velocity_z += 200;
		UNSET_ONGROUND(actor);
	}
	return false;
}
#endif

bool galena_canblock(entity actor)
{
#ifdef SVQC
	.entity weaponentity = weaponentities[0];
	if(actor.(weaponentity).m_weapon.spawnflags & WEP_FLAG_TWOHANDED)
		return false;
#endif
#ifdef CSQC
	if(viewmodels[0].activeweapon.spawnflags & WEP_FLAG_TWOHANDED)
		return false;
#endif
	return true;
}

METHOD(Galena, m_getmovespeed, float(Champions this, entity actor))
{
	if(PHYS_INPUT_BUTTON_ATCK2(actor) && galena_canblock(actor))
		return 0.25;
	return 0.9;
}

#ifdef SVQC
// TODO: generic list of deathtypes that should never be blocked
bool Galena_forcedamage(int deathtype)
{
	switch(deathtype)
	{
		case DEATH_VOID.m_id:
		case DEATH_HURTTRIGGER.m_id:
		case DEATH_KILL.m_id:
		case DEATH_GENERIC.m_id:
		case DEATH_LAVA.m_id:
		case DEATH_CHECKPOINT.m_id:
			return true;
	}
	return false;
}

METHOD(Galena, m_takedamage, float(Champions this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	if(targ.m_champion == this && targ.galena_dodge_time > time && !Galena_forcedamage(deathtype))
		return 0;
	if(targ.m_champion == this && PHYS_INPUT_BUTTON_ATCK2(targ) && galena_canblock(targ))
	{
		if(deathmatch)
			return 0.6;
		return 0.25;
	}
	return 1;
}

METHOD(Galena, m_activate, void(Champions this, entity actor))
{
	float r = random();
	if(r < 0.33)
		player_sound(actor, CH_VOICE, "abl1.wav", ATTN_NORM);
	else if(r < 0.66)
		player_sound(actor, CH_VOICE, "abl2.wav", ATTN_NORM);
	else
		player_sound(actor, CH_VOICE, "abl3.wav", ATTN_NORM);

	actor.skin = bound(0, (etof(actor) % 5) - 1, 4);

	STAT(WEAPONS, actor) |= WEP_SWORD.m_wepset;

#if 0
	dodging_ResetPlayer(actor);
#endif
}

METHOD(Galena, m_playerspawn, void(Champions this, entity actor))
{
	STAT(WEAPONS, actor) |= WEP_SWORD.m_wepset;
}
#endif
