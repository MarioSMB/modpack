// player animation data for this model
// each vector is as follows:
// _x = startframe
// _y = numframes
// _z = framerate
.vector anim_die1; // player dies
.vector anim_die2; // player dies differently
.vector anim_draw; // player pulls out a weapon
.vector anim_duckwalk; // player walking while crouching
.vector anim_duckjump; // player jumping from a crouch
.vector anim_duckidle; // player idling while crouching
.vector anim_idle; // player standing
.vector anim_jump; // player jump
.vector anim_pain1; // player flinches from pain
.vector anim_pain2; // player flinches from pain, differently
.vector anim_shoot; // player shoots
.vector anim_taunt; // player taunts others (FIXME: no code references this)
.vector anim_run; // player running forward
.vector anim_runbackwards; // player running backward
.vector anim_strafeleft; // player shuffling left quickly
.vector anim_straferight; // player shuffling right quickly
.vector anim_forwardright; // player running forward and right
.vector anim_forwardleft; // player running forward and left
.vector anim_backright; // player running backward and right
.vector anim_backleft; // player running back and left
.vector anim_melee; // player doing the melee action
.vector anim_duck; // player doing the melee action
.vector anim_duckwalkbackwards;
.vector anim_duckwalkstrafeleft;
.vector anim_duckwalkstraferight;
.vector anim_duckwalkforwardright;
.vector anim_duckwalkforwardleft;
.vector anim_duckwalkbackright;
.vector anim_duckwalkbackleft;
.float animdecide_modelindex;

void animdecide_init(entity e)
{
	if(e.modelindex == e.animdecide_modelindex)
		return;
	e.animdecide_modelindex = e.modelindex;

	vector none = '0 0 0';
	e.anim_die1 = animfixfps(e, '0 1 0.5', none); // 2 seconds
	e.anim_die2 = animfixfps(e, '1 1 0.5', none); // 2 seconds
	e.anim_draw = animfixfps(e, '2 1 3', none);
	e.anim_duckwalk = animfixfps(e, '4 1 1', none);
	e.anim_duckjump = animfixfps(e, '5 1 10', none);
	e.anim_duckidle = animfixfps(e, '6 1 1', none);
	e.anim_idle = animfixfps(e, '7 1 1', none);
	e.anim_jump = animfixfps(e, '8 1 10', none);
	e.anim_pain1 = animfixfps(e, '9 1 2', none); // 0.5 seconds
	e.anim_pain2 = animfixfps(e, '10 1 2', none); // 0.5 seconds
	e.anim_shoot = animfixfps(e, '11 1 5', none); // analyze models and set framerate
	e.anim_taunt = animfixfps(e, '12 1 0.33', none);
	e.anim_run = animfixfps(e, '13 1 1', none);
	e.anim_runbackwards = animfixfps(e, '14 1 1', none);
	e.anim_strafeleft = animfixfps(e, '15 1 1', none);
	e.anim_straferight = animfixfps(e, '16 1 1', none);
	e.anim_forwardright = animfixfps(e, '19 1 1', '16 1 1');
	e.anim_forwardleft = animfixfps(e, '20 1 1', '15 1 1');
	e.anim_backright = animfixfps(e, '21 1 1', '16 1 1');
	e.anim_backleft  = animfixfps(e, '22 1 1', '15 1 1');
	e.anim_melee = animfixfps(e, '23 1 1', '11 1 1');
	e.anim_duckwalkbackwards = animfixfps(e, '24 1 1', '4 1 1');
	e.anim_duckwalkstrafeleft = animfixfps(e, '25 1 1', '4 1 1');
	e.anim_duckwalkstraferight = animfixfps(e, '26 1 1', '4 1 1');
	e.anim_duckwalkforwardright = animfixfps(e, '27 1 1', '4 1 1');
	e.anim_duckwalkforwardleft = animfixfps(e, '28 1 1', '4 1 1');
	e.anim_duckwalkbackright = animfixfps(e, '29 1 1', '4 1 1');
	e.anim_duckwalkbackleft  = animfixfps(e, '30 1 1', '4 1 1');

	// these anims ought to stay until stopped explicitly by weaponsystem
	e.anim_shoot_z = 0.001;
	e.anim_melee_z = 0.001;
}

#define ANIMPRIO_IDLE 0
#define ANIMPRIO_ACTIVE 1
#define ANIMPRIO_CROUCH 2
#define ANIMPRIO_DEAD 3

vector animdecide_getupperanim(entity e)
{
	// death etc.
	if(e.anim_state & ANIMSTATE_FROZEN)
		return vec3(e.anim_idle_x, e.anim_time, ANIMPRIO_DEAD);
	if(e.anim_state & ANIMSTATE_DEAD1)
		return vec3(e.anim_die1_x, e.anim_time, ANIMPRIO_DEAD);
	if(e.anim_state & ANIMSTATE_DEAD2)
		return vec3(e.anim_die2_x, e.anim_time, ANIMPRIO_DEAD);

	// is there an action?
	vector outframe = '-1 0 0';
	float t, a;
	if(e.anim_upper_time >= e.anim_upper_implicit_time)
	{
		a = e.anim_upper_action;
		t = e.anim_upper_time;
	}
	else
	{
		a = e.anim_upper_implicit_action;
		t = e.anim_upper_implicit_time;
	}
	switch(a)
	{
		case ANIMACTION_DRAW: outframe = e.anim_draw; break;
		case ANIMACTION_PAIN1: outframe = e.anim_pain1; break;
		case ANIMACTION_PAIN2: outframe = e.anim_pain2; break;
		case ANIMACTION_SHOOT: outframe = e.anim_shoot; break;
		case ANIMACTION_TAUNT: outframe = e.anim_taunt; break;
		case ANIMACTION_MELEE: outframe = e.anim_melee; break;
	}
	if(outframe_x >= 0)
	{
		if(time <= t + outframe_y / outframe_z)
		{
			// animation is running!
			return vec3(outframe_x, t, ANIMPRIO_ACTIVE);
		}
	}
	// or, decide the anim by state
	t = max(e.anim_time, e.anim_implicit_time);
	// but all states are for lower body!
	return vec3(e.anim_idle_x, t, ANIMPRIO_IDLE);
}

vector animdecide_getloweranim(entity e)
{
	// death etc.
	if(e.anim_state & ANIMSTATE_FOLLOW)
		return vec3(((e.anim_state & ANIMSTATE_DUCK) ? e.anim_duckidle_x : e.anim_idle_x), e.anim_time, ANIMPRIO_DEAD); // dead priority so it's above all
	if(e.anim_state & ANIMSTATE_FROZEN)
		return vec3(e.anim_idle_x, e.anim_time, ANIMPRIO_DEAD);
	if(e.anim_state & ANIMSTATE_DEAD1)
		return vec3(e.anim_die1_x, e.anim_time, ANIMPRIO_DEAD);
	if(e.anim_state & ANIMSTATE_DEAD2)
		return vec3(e.anim_die2_x, e.anim_time, ANIMPRIO_DEAD);

	// is there an action?
	vector outframe = '-1 0 0';
	float t, a;
	if(e.anim_lower_time >= e.anim_lower_implicit_time)
	{
		a = e.anim_lower_action;
		t = e.anim_lower_time;
	}
	else
	{
		a = e.anim_lower_implicit_action;
		t = e.anim_lower_implicit_time;
	}
	switch(a)
	{
		case ANIMACTION_JUMP: if(e.anim_implicit_state & ANIMIMPLICITSTATE_INAIR) { if(e.anim_state & ANIMSTATE_DUCK) outframe = e.anim_duckjump; else outframe = e.anim_jump; } break;
	}
	if(outframe_x >= 0)
	{
		if(time <= t + outframe_y / outframe_z)
		{
			// animation is running!
			return vec3(outframe_x, t, ANIMPRIO_ACTIVE);
		}
	}
	// or, decide the anim by state
	t = max(e.anim_time, e.anim_implicit_time);
	if(e.anim_state & ANIMSTATE_DUCK)
	{
		if(e.anim_implicit_state & ANIMIMPLICITSTATE_INAIR)
			return vec3(e.anim_duckjump_x, 0, ANIMPRIO_CROUCH); // play the END of the jump anim
		else switch(e.anim_implicit_state & (ANIMIMPLICITSTATE_FORWARD | ANIMIMPLICITSTATE_BACKWARDS | ANIMIMPLICITSTATE_LEFT | ANIMIMPLICITSTATE_RIGHT))
		{
			case ANIMIMPLICITSTATE_FORWARD:
				return vec3(e.anim_duckwalk_x, t, ANIMPRIO_CROUCH);
			case ANIMIMPLICITSTATE_BACKWARDS:
				return vec3(e.anim_duckwalkbackwards_x, t, ANIMPRIO_CROUCH);
			case ANIMIMPLICITSTATE_RIGHT:
				return vec3(e.anim_duckwalkstraferight_x, t, ANIMPRIO_CROUCH);
			case ANIMIMPLICITSTATE_LEFT:
				return vec3(e.anim_duckwalkstrafeleft_x, t, ANIMPRIO_CROUCH);
			case ANIMIMPLICITSTATE_FORWARD | ANIMIMPLICITSTATE_RIGHT:
				return vec3(e.anim_duckwalkforwardright_x, t, ANIMPRIO_CROUCH);
			case ANIMIMPLICITSTATE_FORWARD | ANIMIMPLICITSTATE_LEFT:
				return vec3(e.anim_duckwalkforwardleft_x, t, ANIMPRIO_CROUCH);
			case ANIMIMPLICITSTATE_BACKWARDS | ANIMIMPLICITSTATE_RIGHT:
				return vec3(e.anim_duckwalkbackright_x, t, ANIMPRIO_CROUCH);
			case ANIMIMPLICITSTATE_BACKWARDS | ANIMIMPLICITSTATE_LEFT:
				return vec3(e.anim_duckwalkbackleft_x, t, ANIMPRIO_CROUCH);
			default:
				return vec3(e.anim_duckidle_x, t, ANIMPRIO_CROUCH);
		}
	}
	else
	{
		if(e.anim_implicit_state & ANIMIMPLICITSTATE_INAIR)
			return vec3(e.anim_jump_x, 0, ANIMPRIO_ACTIVE); // play the END of the jump anim
		else switch(e.anim_implicit_state & (ANIMIMPLICITSTATE_FORWARD | ANIMIMPLICITSTATE_BACKWARDS | ANIMIMPLICITSTATE_LEFT | ANIMIMPLICITSTATE_RIGHT))
		{
			case ANIMIMPLICITSTATE_FORWARD:
				return vec3(e.anim_run_x, t, ANIMPRIO_ACTIVE);
			case ANIMIMPLICITSTATE_BACKWARDS:
				return vec3(e.anim_runbackwards_x, t, ANIMPRIO_ACTIVE);
			case ANIMIMPLICITSTATE_RIGHT:
				return vec3(e.anim_straferight_x, t, ANIMPRIO_ACTIVE);
			case ANIMIMPLICITSTATE_LEFT:
				return vec3(e.anim_strafeleft_x, t, ANIMPRIO_ACTIVE);
			case ANIMIMPLICITSTATE_FORWARD | ANIMIMPLICITSTATE_RIGHT:
				return vec3(e.anim_forwardright_x, t, ANIMPRIO_ACTIVE);
			case ANIMIMPLICITSTATE_FORWARD | ANIMIMPLICITSTATE_LEFT:
				return vec3(e.anim_forwardleft_x, t, ANIMPRIO_ACTIVE);
			case ANIMIMPLICITSTATE_BACKWARDS | ANIMIMPLICITSTATE_RIGHT:
				return vec3(e.anim_backright_x, t, ANIMPRIO_ACTIVE);
			case ANIMIMPLICITSTATE_BACKWARDS | ANIMIMPLICITSTATE_LEFT:
				return vec3(e.anim_backleft_x, t, ANIMPRIO_ACTIVE);
			default:
				return vec3(e.anim_idle_x, t, ANIMPRIO_IDLE);
		}
	}
	// can't get here
#ifdef GMQCC
	return vec3(e.anim_idle_x, t, ANIMPRIO_IDLE);
#endif
}

void animdecide_setimplicitstate(entity e, float onground)
{
	float s;
	s = 0;

	makevectors(e.angles);
	vector v;
	v_x = e.velocity * v_forward;
	v_y = e.velocity * v_right;
	v_z = 0;

	// we want to match like this:
	// the 8 directions shall be "evenly spaced"
	// that means, the forward key includes anything from -67.5 to +67.5 degrees
	// which then means x > |y| * cot(3pi/8)
	//
	// BUT, the engine's clip-movement-to-keyboard function uses 0.5 here,
	// which would be an angle range from -63.43 to +63.43 degrees, making
	// it slightly less likely to "hit two keys at once", so let's do this
	// here too

	if(vlen(v) > 10)
	{
		if(v_x >  fabs(v_y) * 0.5)
			s |= ANIMIMPLICITSTATE_FORWARD;
		if(v_x < -fabs(v_y) * 0.5)
			s |= ANIMIMPLICITSTATE_BACKWARDS;
		if(v_y >  fabs(v_x) * 0.5)
			s |= ANIMIMPLICITSTATE_RIGHT;
		if(v_y < -fabs(v_x) * 0.5)
			s |= ANIMIMPLICITSTATE_LEFT;
	}
	if(!onground)
		s |= ANIMIMPLICITSTATE_INAIR;

	// detect some kinds of otherwise misdetected jumps (ground to air transition)
	// NOTE: currently, in CSQC this is the only jump detection, as the explicit jump action is never called!
	if(!(e.anim_implicit_state & ANIMIMPLICITSTATE_INAIR) && (s & ANIMIMPLICITSTATE_INAIR))
	{
		e.anim_lower_implicit_action = ANIMACTION_JUMP;
		e.anim_lower_implicit_time = time;
	}

	if(s != e.anim_implicit_state)
	{
		e.anim_implicit_state = s;
		e.anim_implicit_time = time;
	}
}
void animdecide_setframes(entity e, float support_blending, .float fld_frame, .float fld_frame1time, .float fld_frame2, .float fld_frame2time)
{
	// _x: frame
	// _y: start time
	// _z: priority
	vector upper = animdecide_getupperanim(e);
	vector lower = animdecide_getloweranim(e);
	//print("UPPER: ", vtos(upper), ", LOWER: ", vtos(lower), "\n");
	if(support_blending)
	{
		if(upper_z && !lower_z)
			lower = upper;
		else if(lower_z && !upper_z)
			upper = lower;
		if(e.frame1time != upper_y || e.frame2time != lower_y)
			BITXOR_ASSIGN(e.effects, EF_RESTARTANIM_BIT);
		e.fld_frame = upper_x;
		e.fld_frame1time = upper_y;
		e.fld_frame2 = lower_x;
		e.fld_frame2time = lower_y;
	}
	else
	{
		if(upper_z > lower_z)
			lower = upper;
		else if(lower_z > upper_z)
			upper = lower;
		if(e.frame1time != upper_y)
			BITXOR_ASSIGN(e.effects, EF_RESTARTANIM_BIT);
		e.fld_frame = upper_x;
		e.fld_frame1time = upper_y;
	}
}

void animdecide_setstate(entity e, float newstate, float restart)
{
	if(!restart)
		if(newstate == e.anim_state)
			return;
	e.anim_state = newstate;
	e.anim_time = time;
}
void animdecide_setaction(entity e, float action, float restart)
{
	if(action < 0)
	{
		if(!restart)
			if(action == e.anim_lower_action)
				return;
		e.anim_lower_action = action;
		e.anim_lower_time = time;
	}
	else
	{
		if(!restart)
			if(action == e.anim_upper_action)
				return;
		e.anim_upper_action = action;
		e.anim_upper_time = time;
	}
}
