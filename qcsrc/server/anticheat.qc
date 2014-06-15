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

.float anticheat_fixangle_endtime;

float anticheat_div0_evade_evasion_delta;
.float anticheat_div0_evade_offset;
.vector anticheat_div0_evade_v_angle;
.vector anticheat_div0_evade_forward_initial;
MEAN_DECLARE(anticheat_div0_evade, 5);

.vector anticheat_div0_strafebot_movement_prev;
MEAN_DECLARE(anticheat_div0_strafebot_old, 5);

.vector anticheat_div0_strafebot_forward_prev;
MEAN_DECLARE(anticheat_div0_strafebot_new, 5);

// Snap-aim detection: we track the average angular speed of aiming over time, in "radians per second".
// Signal: a high-power mean. Cheaters will have high "signal" here.
// Noise: a low-power mean. Active/shivery players will have high "noise" here.
// Note one can always artificially add noise - so very high values of both signal and noise need to be checked too.
MEAN_DECLARE(anticheat_idle_snapaim_signal, 5);
MEAN_DECLARE(anticheat_idle_snapaim_noise, 1);

// TEMP DEBUG STUFF.
MEAN_DECLARE(anticheat_idle_snapaim_m2, 2);
MEAN_DECLARE(anticheat_idle_snapaim_m3, 3);
MEAN_DECLARE(anticheat_idle_snapaim_m4, 4);
MEAN_DECLARE(anticheat_idle_snapaim_m7, 7);
MEAN_DECLARE(anticheat_idle_snapaim_m10, 10);

.float anticheat_speedhack_offset;
.float anticheat_speedhack_movetime, anticheat_speedhack_movetime_count, anticheat_speedhack_movetime_frac;
MEAN_DECLARE(anticheat_speedhack, 5);

.float anticheat_speedhack_accu;
.float anticheat_speedhack_lasttime;
MEAN_DECLARE(anticheat_speedhack_m1, 1);
MEAN_DECLARE(anticheat_speedhack_m2, 2);
MEAN_DECLARE(anticheat_speedhack_m3, 3);
MEAN_DECLARE(anticheat_speedhack_m4, 4);
MEAN_DECLARE(anticheat_speedhack_m5, 5);

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
	float f;

	// div0_evade -> SPECTATORS
	makevectors(self.v_angle);
	if(self.anticheat_div0_evade_offset == 0)
	{
		f = fabs(anticheat_div0_evade_evasion_delta - floor(anticheat_div0_evade_evasion_delta) - 0.5) * 2; // triangle function
		self.anticheat_div0_evade_offset = servertime + sys_frametime * (3 * f - 1);
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

	// Note: this actually tries to detect snap-aim.
	if(vlen(self.anticheat_div0_strafebot_forward_prev) && time > self.anticheat_fixangle_endtime) {
		float cosangle = self.anticheat_div0_strafebot_forward_prev * v_forward;
		float angle = cosangle < -1 ? M_PI : cosangle > 1 ? 0 : acos(cosangle);
		/*
		if (angle >= 10 * M_PI / 180)
			printf("SNAP %s: %f for %f, %f since fixangle\n", self.netname, angle * 180 / M_PI, cosangle, time - self.anticheat_fixangle_endtime);
		*/
		MEAN_ACCUMULATE(anticheat_div0_strafebot_new, angle / M_PI, 1);

		if (autocvar_slowmo > 0) {
			// Technically this is a NOP, as the engine should be ensuring
			// this in the first place. Let's guard against dividing by
			// zero anyway.
			float dt = max(0.001, frametime) / autocvar_slowmo;

			float anglespeed = angle / dt;
			MEAN_ACCUMULATE(anticheat_idle_snapaim_signal, anglespeed, dt);
			MEAN_ACCUMULATE(anticheat_idle_snapaim_noise, anglespeed, dt);
			MEAN_ACCUMULATE(anticheat_idle_snapaim_m2, anglespeed, dt);
			MEAN_ACCUMULATE(anticheat_idle_snapaim_m3, anglespeed, dt);
			MEAN_ACCUMULATE(anticheat_idle_snapaim_m4, anglespeed, dt);
			MEAN_ACCUMULATE(anticheat_idle_snapaim_m7, anglespeed, dt);
			MEAN_ACCUMULATE(anticheat_idle_snapaim_m10, anglespeed, dt);
		}
	}
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

	// new generic speedhack detection
	if (self.anticheat_speedhack_lasttime > 0) {
		float dt = servertime - self.anticheat_speedhack_lasttime;
		const float falloff = 0.2;
		self.anticheat_speedhack_accu *= exp(-dt * falloff);
		self.anticheat_speedhack_accu += frametime * falloff;
		// NOTE: at cl_netfps x, this actually averages not to 1, but to 1/x * falloff / (1 - exp(-1/x * falloff))
		// For 15 netfps (absolute minimum bearable), and 0.2 falloff, this is: 1.0067
		self.anticheat_speedhack_lasttime = servertime;
		MEAN_ACCUMULATE(anticheat_speedhack_m1, self.anticheat_speedhack_accu, frametime);
		MEAN_ACCUMULATE(anticheat_speedhack_m2, self.anticheat_speedhack_accu, frametime);
		MEAN_ACCUMULATE(anticheat_speedhack_m3, self.anticheat_speedhack_accu, frametime);
		MEAN_ACCUMULATE(anticheat_speedhack_m4, self.anticheat_speedhack_accu, frametime);
		MEAN_ACCUMULATE(anticheat_speedhack_m5, self.anticheat_speedhack_accu, frametime);
	} else {
		self.anticheat_speedhack_accu = 1;
		self.anticheat_speedhack_lasttime = servertime;
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
	// TODO(divVerent): Use xonstat to acquire good thresholds.
	GameLogEcho(strcat(":anticheat:_time:", ftos(self.playerid), ":", ftos(servertime - self.anticheat_jointime)));
	GameLogEcho(strcat(":anticheat:speedhack:", ftos(self.playerid), ":", anticheat_display(MEAN_EVALUATE(anticheat_speedhack), 240, 0, 9999))); // Actually this one seems broken.
	GameLogEcho(strcat(":anticheat:speedhack_m1:", ftos(self.playerid), ":", anticheat_display(MEAN_EVALUATE(anticheat_speedhack_m1), 240, 1.01, 1.25)));
	GameLogEcho(strcat(":anticheat:speedhack_m2:", ftos(self.playerid), ":", anticheat_display(MEAN_EVALUATE(anticheat_speedhack_m2), 240, 1.01, 1.25)));
	GameLogEcho(strcat(":anticheat:speedhack_m3:", ftos(self.playerid), ":", anticheat_display(MEAN_EVALUATE(anticheat_speedhack_m3), 240, 1.01, 1.25)));
	GameLogEcho(strcat(":anticheat:speedhack_m4:", ftos(self.playerid), ":", anticheat_display(MEAN_EVALUATE(anticheat_speedhack_m4), 240, 1.01, 1.25)));
	GameLogEcho(strcat(":anticheat:speedhack_m5:", ftos(self.playerid), ":", anticheat_display(MEAN_EVALUATE(anticheat_speedhack_m5), 240, 1.01, 1.25)));
	GameLogEcho(strcat(":anticheat:div0_strafebot_old:", ftos(self.playerid), ":", anticheat_display(MEAN_EVALUATE(anticheat_div0_strafebot_old), 120, 0.15, 0.4)));
	GameLogEcho(strcat(":anticheat:div0_strafebot_new:", ftos(self.playerid), ":", anticheat_display(MEAN_EVALUATE(anticheat_div0_strafebot_new), 120, 0.25, 0.8)));
	GameLogEcho(strcat(":anticheat:div0_evade:", ftos(self.playerid), ":", anticheat_display(MEAN_EVALUATE(anticheat_div0_evade), 120, 0.2, 0.5)));
	GameLogEcho(strcat(":anticheat:idle_snapaim:", ftos(self.playerid), ":", anticheat_display(MEAN_EVALUATE(anticheat_idle_snapaim_signal) - MEAN_EVALUATE(anticheat_idle_snapaim_noise), 120, 0, 9999)));
	GameLogEcho(strcat(":anticheat:idle_snapaim_signal:", ftos(self.playerid), ":", anticheat_display(MEAN_EVALUATE(anticheat_idle_snapaim_signal), 120, 0, 9999)));
	GameLogEcho(strcat(":anticheat:idle_snapaim_noise:", ftos(self.playerid), ":", anticheat_display(MEAN_EVALUATE(anticheat_idle_snapaim_noise), 120, 0, 9999)));
	GameLogEcho(strcat(":anticheat:idle_snapaim_m2:", ftos(self.playerid), ":", anticheat_display(MEAN_EVALUATE(anticheat_idle_snapaim_m2), 120, 0, 9999)));
	GameLogEcho(strcat(":anticheat:idle_snapaim_m3:", ftos(self.playerid), ":", anticheat_display(MEAN_EVALUATE(anticheat_idle_snapaim_m3), 120, 0, 9999)));
	GameLogEcho(strcat(":anticheat:idle_snapaim_m4:", ftos(self.playerid), ":", anticheat_display(MEAN_EVALUATE(anticheat_idle_snapaim_m4), 120, 0, 9999)));
	GameLogEcho(strcat(":anticheat:idle_snapaim_m7:", ftos(self.playerid), ":", anticheat_display(MEAN_EVALUATE(anticheat_idle_snapaim_m7), 120, 0, 9999)));
	GameLogEcho(strcat(":anticheat:idle_snapaim_m10:", ftos(self.playerid), ":", anticheat_display(MEAN_EVALUATE(anticheat_idle_snapaim_m10), 120, 0, 9999)));
}

float anticheat_getvalue(string id)
{
	switch(id) {
		case "_time": return servertime - self.anticheat_jointime;
		case "speedhack": return MEAN_EVALUATE(anticheat_speedhack);
		case "speedhack_m1": return MEAN_EVALUATE(anticheat_speedhack_m1);
		case "speedhack_m2": return MEAN_EVALUATE(anticheat_speedhack_m2);
		case "speedhack_m3": return MEAN_EVALUATE(anticheat_speedhack_m3);
		case "speedhack_m4": return MEAN_EVALUATE(anticheat_speedhack_m4);
		case "speedhack_m5": return MEAN_EVALUATE(anticheat_speedhack_m5);
		case "div0_strafebot_old": return MEAN_EVALUATE(anticheat_div0_strafebot_old);
		case "div0_strafebot_new": return MEAN_EVALUATE(anticheat_div0_strafebot_new);
		case "div0_evade": return MEAN_EVALUATE(anticheat_div0_evade);
		case "idle_snapaim": return MEAN_EVALUATE(anticheat_idle_snapaim_signal) - MEAN_EVALUATE(anticheat_idle_snapaim_noise);
		case "idle_snapaim_signal": return MEAN_EVALUATE(anticheat_idle_snapaim_signal);
		case "idle_snapaim_noise": return MEAN_EVALUATE(anticheat_idle_snapaim_noise);
		case "idle_snapaim_m2": return MEAN_EVALUATE(anticheat_idle_snapaim_m2);
		case "idle_snapaim_m3": return MEAN_EVALUATE(anticheat_idle_snapaim_m3);
		case "idle_snapaim_m4": return MEAN_EVALUATE(anticheat_idle_snapaim_m4);
		case "idle_snapaim_m7": return MEAN_EVALUATE(anticheat_idle_snapaim_m7);
		case "idle_snapaim_m10": return MEAN_EVALUATE(anticheat_idle_snapaim_m10);
	}
	return -1;
}

void anticheat_startframe()
{
	anticheat_div0_evade_evasion_delta += frametime * (0.5 + random());
}

void anticheat_fixangle()
{
	self.anticheat_fixangle_endtime = servertime + ANTILAG_LATENCY(self) + 0.2;
}

void anticheat_endframe()
{
	entity oldself = self;
	FOR_EACH_CLIENT(self)
		if (self.fixangle)
			anticheat_fixangle();
	self = oldself;
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
