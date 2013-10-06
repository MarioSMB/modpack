
.float cvar_cl_dodging;
.float cvar_cl_dodging_timeout;


// these are used to store the last key press time for each of the keys..
.float last_FORWARD_KEY_time;
.float last_BACKWARD_KEY_time;
.float last_LEFT_KEY_time;
.float last_RIGHT_KEY_time;

// these store the movement direction at the time of the dodge action happening.
.float dodging_direction_x;
.float dodging_direction_y;

// this indicates the last time a dodge was executed. used to check if another one is allowed
// and to ramp up the dodge acceleration in the physics hook.
.float last_dodging_time;

// This is the velocity gain to be added over the ramp time.
// It will decrease from frame to frame during dodging_action = 1
// until it's 0.
.float dodging_velocity_gain;

MUTATOR_HOOKFUNCTION(dodging_GetCvars) {
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, cvar_cl_dodging, "cl_dodging");
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, cvar_cl_dodging_timeout, "cl_dodging_timeout");
	return 0;
}

MUTATOR_HOOKFUNCTION(dodging_PlayerPhysics) {
	// print("dodging_PlayerPhysics\n");

	float common_factor;
	float new_velocity_gain;
	float velocity_difference;
	float clean_up_and_do_nothing;
	float horiz_speed = autocvar_sv_dodging_horiz_speed;
	
	if(self.frozen)
		horiz_speed = autocvar_sv_dodging_horiz_speed_frozen;

    if (self.deadflag != DEAD_NO)
        return 0;

	new_velocity_gain = 0;
	clean_up_and_do_nothing = 0;

	if (g_dodging == 0)
		clean_up_and_do_nothing = 1;
		
	if(!self.cvar_cl_dodging)
		clean_up_and_do_nothing = 1;

	if(cvar("g_overkill"))
		clean_up_and_do_nothing = 0; // always enabled in overkill
		
	if(g_dodging == 2)
		clean_up_and_do_nothing = 0; // forced enabled
		
	if(self.frozen == 1)
		clean_up_and_do_nothing = 0; // also enabled in freezetag

	// when swimming, no dodging allowed..
	if (self.waterlevel >= WATERLEVEL_SWIMMING)
		clean_up_and_do_nothing = 1;

	if (clean_up_and_do_nothing != 0) {
		self.dodging_action = 0;
		self.dodging_direction_x = 0;
		self.dodging_direction_y = 0;
		return 0;
	}

	// make sure v_up, v_right and v_forward are sane
	makevectors(self.angles);

	// if we have e.g. 0.5 sec ramptime and a frametime of 0.25, then the ramp code 
	// will be called ramp_time/frametime times = 2 times. so, we need to 
	// add 0.5 * the total speed each frame until the dodge action is done..
	common_factor = sys_frametime / autocvar_sv_dodging_ramp_time;

	// if ramp time is smaller than frametime we get problems ;D
	if (common_factor > 1) 
		common_factor = 1;

	new_velocity_gain = self.dodging_velocity_gain - (common_factor * horiz_speed);
	if (new_velocity_gain < 0)
		new_velocity_gain = 0;

	velocity_difference = self.dodging_velocity_gain - new_velocity_gain;

	// ramp up dodging speed by adding some velocity each frame.. TODO: do it! :D
	if (self.dodging_action == 1) {
		//disable jump key during dodge accel phase
		if (self.movement_z > 0) self.movement_z = 0;
		self.BUTTON_JUMP = TRUE;

		self.velocity +=
			+ ((self.dodging_direction_y * velocity_difference) * v_right)
			+ ((self.dodging_direction_x * velocity_difference) * v_forward);

		self.dodging_velocity_gain = self.dodging_velocity_gain - velocity_difference;
	}

	// the up part of the dodge is a single shot action
	if (self.dodging_single_action == 1) {
		self.flags &= ~FL_ONGROUND;
		self.BUTTON_JUMP = TRUE;

		self.velocity += (autocvar_sv_dodging_up_speed * v_up);

		if (autocvar_sv_dodging_sound == 1)
			PlayerSound(playersound_jump, CH_PLAYER, VOICETYPE_PLAYERSOUND);

		animdecide_setaction(self, ANIMACTION_JUMP, TRUE);

		self.dodging_single_action = 0;
	}

	// are we done with the dodging ramp yet?
	if((self.dodging_action == 1) && ((time - self.last_dodging_time) > autocvar_sv_dodging_ramp_time))
	{
		// reset state so next dodge can be done correctly
		self.dodging_action = 0;
		self.dodging_direction_x = 0;
		self.dodging_direction_y = 0;
	}

	return 0;
}


// returns 1 if the player is close to a wall
float check_close_to_wall(float threshold) {
	if (autocvar_sv_dodging_wall_dodging == 0)
		return 0;

	vector trace_start;
	vector trace_end;

	trace_start = self.origin;

	trace_end = self.origin + (1000*v_right);
	tracebox(trace_start, self.mins, self.maxs, trace_end, TRUE, self);
	if (trace_fraction < 1 && vlen (self.origin - trace_endpos) < threshold)
		return 1;

	trace_end = self.origin - (1000*v_right);
	tracebox(trace_start, self.mins, self.maxs, trace_end, TRUE, self);
	if (trace_fraction < 1 && vlen (self.origin - trace_endpos) < threshold)
		return 1;

	trace_end = self.origin + (1000*v_forward);
	tracebox(trace_start, self.mins, self.maxs, trace_end, TRUE, self);
	if (trace_fraction < 1 && vlen (self.origin - trace_endpos) < threshold)
		return 1;

	trace_end = self.origin - (1000*v_forward);
	tracebox(trace_start, self.mins, self.maxs, trace_end, TRUE, self);
	if (trace_fraction < 1 && vlen (self.origin - trace_endpos) < threshold)
		return 1;

	return 0;
}

float check_close_to_ground(float threshold) {
	if (self.flags & FL_ONGROUND)
		return 1;

	return 0;
}


MUTATOR_HOOKFUNCTION(dodging_GetPressedKeys) {
	// print("dodging_PlayerPhysics\n");

	float length;
	float tap_direction_x;
	float tap_direction_y;

	tap_direction_x = 0;
	tap_direction_y = 0;
	
	float frozen_dodging, frozen_no_doubletap;
	float do_nothing = 0;
	frozen_dodging = (self.frozen == 1 && autocvar_sv_dodging_frozen);
	frozen_no_doubletap = (frozen_dodging && !autocvar_sv_dodging_frozen_doubletap);

	float dodge_detected = 0;
	if (g_dodging == 0)
		do_nothing = 1;

	if not(self.cvar_cl_dodging)
		do_nothing = 1;
	
	if(cvar("g_overkill"))
		do_nothing = 0;
		
	if(frozen_dodging)
		do_nothing = 0;
		
	if(g_dodging == 2)
		do_nothing = 0;
	
	if(do_nothing != 0)
		return 0;

	// first check if the last dodge is far enough back in time so we can dodge again
	if ((time - self.last_dodging_time) < autocvar_sv_dodging_delay)
		return 0;

	if (check_close_to_ground(autocvar_sv_dodging_height_threshold) != 1 
		&& check_close_to_wall(autocvar_sv_dodging_wall_distance_threshold) != 1)
		return 0;

	if (self.movement_x > 0) {
		// is this a state change?
		if (!(self.pressedkeys & KEY_FORWARD) || frozen_no_doubletap) {
			if ((time - self.last_FORWARD_KEY_time) < self.cvar_cl_dodging_timeout)	{ 
				tap_direction_x = 1.0;
				dodge_detected = 1;
			}
 			self.last_FORWARD_KEY_time = time;
 		}
	}

	if (self.movement_x < 0) {
		// is this a state change?
 		if (!(self.pressedkeys & KEY_BACKWARD) || frozen_no_doubletap) {
			tap_direction_x = -1.0;
			if ((time - self.last_BACKWARD_KEY_time) < self.cvar_cl_dodging_timeout)	{ 
				dodge_detected = 1;
			}
 			self.last_BACKWARD_KEY_time = time;
 		}
	}

	if (self.movement_y > 0) {
		// is this a state change?
		if (!(self.pressedkeys & KEY_RIGHT) || frozen_no_doubletap) {
			tap_direction_y = 1.0;
			if ((time - self.last_RIGHT_KEY_time) < self.cvar_cl_dodging_timeout)	{ 
				dodge_detected = 1;
			}
 			self.last_RIGHT_KEY_time = time;
 		}
	}

	if (self.movement_y < 0) {
		// is this a state change?
		if (!(self.pressedkeys & KEY_LEFT) || frozen_no_doubletap) {
			tap_direction_y = -1.0;
			if ((time - self.last_LEFT_KEY_time) < self.cvar_cl_dodging_timeout)	{ 
				dodge_detected = 1;
			}
 			self.last_LEFT_KEY_time = time;
 		}
	}

	if (dodge_detected == 1) {
		self.last_dodging_time = time;

		self.dodging_action = 1;
		self.dodging_single_action = 1;

		self.dodging_velocity_gain = autocvar_sv_dodging_horiz_speed;

		self.dodging_direction_x = tap_direction_x;
		self.dodging_direction_y = tap_direction_y;

		// normalize the dodging_direction vector.. (unlike UT99) XD
		length =          self.dodging_direction_x * self.dodging_direction_x;
		length = length + self.dodging_direction_y * self.dodging_direction_y;
		length = sqrt(length);

		self.dodging_direction_x = self.dodging_direction_x * 1.0/length;
		self.dodging_direction_y = self.dodging_direction_y * 1.0/length;
	}

	return 0;
}

MUTATOR_DEFINITION(mutator_dodging)
{
	// we need to be called before GetPressedKey does its thing so we can
	// detect state changes and therefore dodging actions..
	MUTATOR_HOOK(GetPressedKeys, dodging_GetPressedKeys, CBC_ORDER_ANY);

	// in the physics hook we actually implement the dodge..
	MUTATOR_HOOK(PlayerPhysics, dodging_PlayerPhysics, CBC_ORDER_ANY);

	// get timeout information from the client, so the client can configure it..
	MUTATOR_HOOK(GetCvars, dodging_GetCvars, CBC_ORDER_ANY);
	
	MUTATOR_ONADD
	{
		g_dodging = cvar("g_dodging");
	}

	// this just turns off the cvar.
	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		g_dodging = 0;
	}

	MUTATOR_ONREMOVE
	{
	}

	return 0;
}
