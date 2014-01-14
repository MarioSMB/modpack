.float anticheat_jointime;

void mean_accumulate(entity e, .float a, .float c, float mean, float value, float weight)
{
	if(weight == 0)
		return;
	if(mean == 0)
		e.a *= pow(value, weight);
	else
		e.a += pow(value, mean) * weight;
	e.c += weight;
}

float mean_evaluate(entity e, .float a, .float c, float mean)
{
	if(e.c == 0)
		return 0;
	if(mean == 0)
		return pow(e.a, 1.0 / e.c);
	else
		return pow(e.a / e.c, 1.0 / mean);
}

#define MEAN_ACCUMULATE(prefix,v,w) mean_accumulate(self,prefix##_accumulator,prefix##_count,prefix##_mean,v,w)
#define MEAN_EVALUATE(prefix) mean_evaluate(self,prefix##_accumulator,prefix##_count,prefix##_mean)
#define MEAN_DECLARE(prefix,m) float prefix##_mean = m; .float prefix##_count, prefix##_accumulator

float anticheat_div0_evade_evasion_delta;
.float anticheat_div0_evade_offset;
.vector anticheat_div0_evade_v_angle;
.vector anticheat_div0_evade_forward_initial;
MEAN_DECLARE(anticheat_div0_evade, 5);

.vector anticheat_div0_strafebot_movement_prev;
MEAN_DECLARE(anticheat_div0_strafebot_old, 5);

.vector anticheat_div0_strafebot_forward_prev;
MEAN_DECLARE(anticheat_div0_strafebot_new, 5);

.float anticheat_speedhack_offset;
.float anticheat_speedhack_movetime, anticheat_speedhack_movetime_count, anticheat_speedhack_movetime_frac;
MEAN_DECLARE(anticheat_speedhack, 5);

float movement_oddity(vector m0, vector m1)
{
	float cosangle = normalize(m0) * normalize(m1);
	if(cosangle >= 0)
		return 0;
	return 0.5 - 0.5 * cos(cosangle * cosangle * 4 * M_PI);
		// returns 0 for: -1, -sqrt(0.5), 0 (angles that commonly happen with kbd)
}

void anticheat_physics()
{
	float f, wishspeed;
	vector wishvel;

	// div0_evade -> SPECTATORS
	makevectors(self.v_angle);
	if(self.anticheat_div0_evade_offset == 0)
	{
		f = fabs(anticheat_div0_evade_evasion_delta - floor(anticheat_div0_evade_evasion_delta) - 0.5) * 2; // triangle function
		self.anticheat_div0_evade_offset = time + sys_frametime * (3 * f - 1);
		self.anticheat_div0_evade_v_angle = self.v_angle;
		self.anticheat_div0_evade_forward_initial = v_forward;
		MEAN_ACCUMULATE(anticheat_div0_evade, 0, 1);
	}
	else
	{
		if(time < self.anticheat_div0_evade_offset)
			self.anticheat_div0_evade_v_angle = self.v_angle;
		MEAN_ACCUMULATE(anticheat_div0_evade, 0.5 - 0.5 * (self.anticheat_div0_evade_forward_initial * v_forward), 1);
	}

	MEAN_ACCUMULATE(anticheat_div0_strafebot_old, movement_oddity(self.movement, self.anticheat_div0_strafebot_movement_prev), 1);
	self.anticheat_div0_strafebot_movement_prev = self.movement;

	if(vlen(self.anticheat_div0_strafebot_forward_prev))
		MEAN_ACCUMULATE(anticheat_div0_strafebot_new, 0.5 - 0.5 * (self.anticheat_div0_strafebot_forward_prev * v_forward), 1);
	self.anticheat_div0_strafebot_forward_prev = v_forward;

	// generic speedhack detection: correlate anticheat_speedhack_movetime (UPDATED BEFORE THIS) and server time
	self.anticheat_speedhack_movetime_frac += frametime;
	f = floor(self.anticheat_speedhack_movetime_frac);
	self.anticheat_speedhack_movetime_frac -= f;
	self.anticheat_speedhack_movetime_count += f;
	self.anticheat_speedhack_movetime = self.anticheat_speedhack_movetime_frac + self.anticheat_speedhack_movetime_count;
	f = self.anticheat_speedhack_movetime - servertime;
	if(self.anticheat_speedhack_offset == 0)
		self.anticheat_speedhack_offset = f;
	else
	{
		MEAN_ACCUMULATE(anticheat_speedhack, max(0, f - self.anticheat_speedhack_offset), 1);
		self.anticheat_speedhack_offset += (f - self.anticheat_speedhack_offset) * frametime * 0.1;
	}

	// race/CTS: force kbd movement for fairness
	if(g_race || g_cts)
	{
		// if record times matter
		// ensure nothing EVIL is being done (i.e. div0_evade)
		// this hinders joystick users though
		// but it still gives SOME analog control
		wishvel_x = fabs(self.movement_x);
		wishvel_y = fabs(self.movement_y);
		if(wishvel_x != 0 && wishvel_y != 0 && wishvel_x != wishvel_y)
		{
			wishvel_z = 0;
			wishspeed = vlen(wishvel);
			if(wishvel_x >= 2 * wishvel_y)
			{
				// pure X motion
				if(self.movement_x > 0)
					self.movement_x = wishspeed;
				else
					self.movement_x = -wishspeed;
				self.movement_y = 0;
			}
			else if(wishvel_y >= 2 * wishvel_x)
			{
				// pure Y motion
				self.movement_x = 0;
				if(self.movement_y > 0)
					self.movement_y = wishspeed;
				else
					self.movement_y = -wishspeed;
			}
			else
			{
				// diagonal
				if(self.movement_x > 0)
					self.movement_x = M_SQRT1_2 * wishspeed;
				else
					self.movement_x = -M_SQRT1_2 * wishspeed;
				if(self.movement_y > 0)
					self.movement_y = M_SQRT1_2 * wishspeed;
				else
					self.movement_y = -M_SQRT1_2 * wishspeed;
			}
		}
	}
}

void anticheat_spectatecopy(entity spectatee)
{
	// div0_evade -> SPECTATORS
	self.angles = spectatee.anticheat_div0_evade_v_angle;
}

void anticheat_prethink()
{
	// div0_evade -> SPECTATORS
	self.anticheat_div0_evade_offset = 0;
}

string anticheat_display(float f, float tmin, float mi, float ma)
{
	string s;
	s = ftos(f);
	if(f <= mi)
		return strcat(s, ":N");
	if(f >= ma)
		return strcat(s, ":Y");
	return strcat(s, ":-");
}

void anticheat_report()
{
	if(!autocvar_sv_eventlog)
		return;
	GameLogEcho(strcat(":anticheat:_time:", ftos(self.playerid), ":", ftos(servertime - self.anticheat_jointime)));
	GameLogEcho(strcat(":anticheat:speedhack:", ftos(self.playerid), ":", anticheat_display(MEAN_EVALUATE(anticheat_speedhack), 240, 0.1, 0.15)));
	GameLogEcho(strcat(":anticheat:div0_strafebot_old:", ftos(self.playerid), ":", anticheat_display(MEAN_EVALUATE(anticheat_div0_strafebot_old), 120, 0.3, 0.4)));
	GameLogEcho(strcat(":anticheat:div0_strafebot_new:", ftos(self.playerid), ":", anticheat_display(MEAN_EVALUATE(anticheat_div0_strafebot_new), 120, 0.3, 0.4)));
	GameLogEcho(strcat(":anticheat:div0_evade:", ftos(self.playerid), ":", anticheat_display(MEAN_EVALUATE(anticheat_div0_evade), 120, 0.1, 0.2)));
}

void anticheat_serverframe()
{
	anticheat_div0_evade_evasion_delta += frametime * (0.5 + random());
}

void anticheat_init()
{
	self.anticheat_speedhack_offset = 0;
	self.anticheat_jointime = servertime;
}

void anticheat_shutdown()
{
}
