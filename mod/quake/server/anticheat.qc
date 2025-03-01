#include "anticheat.qh"

#include "gamelog.qh"

.float anticheat_jointime;

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

.vector anticheat_div0_snapback_prev;
MEAN_DECLARE(anticheat_div0_snapback, 5);

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
	return 0.5 - 0.5 * cos(cosangle * cosangle * (4 * M_PI));
		// returns 0 for: -1, -sqrt(0.5), 0 (angles that commonly happen with kbd)
}

void anticheat_physics(entity this)
{
	float f;

	// div0_evade -> SPECTATORS
	makevectors(this.v_angle);
	if(this.anticheat_div0_evade_offset == 0)
	{
		f = fabs(anticheat_div0_evade_evasion_delta - floor(anticheat_div0_evade_evasion_delta) - 0.5) * 2; // triangle function
		this.anticheat_div0_evade_offset = servertime + sys_frametime * (3 * f - 1);
		this.anticheat_div0_evade_v_angle = this.v_angle;
		this.anticheat_div0_evade_forward_initial = v_forward;
		MEAN_ACCUMULATE(this, anticheat_div0_evade, 0, 1);
	}
	else
	{
		if(time < this.anticheat_div0_evade_offset)
			this.anticheat_div0_evade_v_angle = this.v_angle;
		MEAN_ACCUMULATE(this, anticheat_div0_evade, 0.5 - 0.5 * (this.anticheat_div0_evade_forward_initial * v_forward), 1);
	}

	MEAN_ACCUMULATE(this, anticheat_div0_strafebot_old, movement_oddity(this.movement, this.anticheat_div0_strafebot_movement_prev), 1);
	this.anticheat_div0_strafebot_movement_prev = this.movement;

	// Note: this actually tries to detect snap-aim.
	if(this.anticheat_div0_strafebot_forward_prev && time > this.anticheat_fixangle_endtime) {
		float cosangle = this.anticheat_div0_strafebot_forward_prev * v_forward;
		float angle = cosangle < -1 ? M_PI : cosangle > 1 ? 0 : acos(cosangle);
		/*
		if (angle >= 10 * M_PI / 180)
			printf("SNAP %s: %f for %f, %f since fixangle\n", this.netname, angle * 180 / M_PI, cosangle, time - this.anticheat_fixangle_endtime);
		*/
		MEAN_ACCUMULATE(this, anticheat_div0_strafebot_new, angle / M_PI, 1);

		if (autocvar_slowmo > 0) {
			// Technically this is a NOP, as the engine should be ensuring
			// this in the first place. Let's guard against dividing by
			// zero anyway.
			float dt = max(0.001, frametime) / autocvar_slowmo;

			float anglespeed = angle / dt;
			MEAN_ACCUMULATE(this, anticheat_idle_snapaim_signal, anglespeed, dt);
			MEAN_ACCUMULATE(this, anticheat_idle_snapaim_noise, anglespeed, dt);
			MEAN_ACCUMULATE(this, anticheat_idle_snapaim_m2, anglespeed, dt);
			MEAN_ACCUMULATE(this, anticheat_idle_snapaim_m3, anglespeed, dt);
			MEAN_ACCUMULATE(this, anticheat_idle_snapaim_m4, anglespeed, dt);
			MEAN_ACCUMULATE(this, anticheat_idle_snapaim_m7, anglespeed, dt);
			MEAN_ACCUMULATE(this, anticheat_idle_snapaim_m10, anglespeed, dt);

			// Detect snapping _back_.
			float f = bound(0, dt * 4, 1);  // About 0.25 seconds horizon for snapping back.
			vector aim_move = v_forward - this.anticheat_div0_strafebot_forward_prev;
			vector snapback_prev = this.anticheat_div0_snapback_prev;
			float snapback_len = vlen(snapback_prev);
			if (snapback_len != 0) {
				float aim_snap = max(0, (aim_move * snapback_prev) / -snapback_len);
				// Scales with aim_move, but is positive only when snapping back, otherwise zero.
				MEAN_ACCUMULATE(this, anticheat_div0_snapback, aim_snap, dt);
			}
			this.anticheat_div0_snapback_prev = snapback_prev * (1 - f) + aim_move * f;
		}
	}
	this.anticheat_div0_strafebot_forward_prev = v_forward;

	// generic speedhack detection: correlate anticheat_speedhack_movetime (UPDATED BEFORE THIS) and server time
	this.anticheat_speedhack_movetime_frac += frametime;
	f = floor(this.anticheat_speedhack_movetime_frac);
	this.anticheat_speedhack_movetime_frac -= f;
	this.anticheat_speedhack_movetime_count += f;
	this.anticheat_speedhack_movetime = this.anticheat_speedhack_movetime_frac + this.anticheat_speedhack_movetime_count;
	f = this.anticheat_speedhack_movetime - servertime;
	if(this.anticheat_speedhack_offset == 0)
		this.anticheat_speedhack_offset = f;
	else
	{
		MEAN_ACCUMULATE(this, anticheat_speedhack, max(0, f - this.anticheat_speedhack_offset), 1);
		this.anticheat_speedhack_offset += (f - this.anticheat_speedhack_offset) * frametime * 0.1;
	}

	// new generic speedhack detection
	if (this.anticheat_speedhack_lasttime > 0) {
		float dt = servertime - this.anticheat_speedhack_lasttime;
		const float falloff = 0.2;
		this.anticheat_speedhack_accu *= exp(-dt * falloff);
		this.anticheat_speedhack_accu += frametime * falloff;
		// NOTE: at cl_netfps x, this actually averages not to 1, but to 1/x * falloff / (1 - exp(-1/x * falloff))
		// For 15 netfps (absolute minimum bearable), and 0.2 falloff, this is: 1.0067
		this.anticheat_speedhack_lasttime = servertime;
		MEAN_ACCUMULATE(this, anticheat_speedhack_m1, this.anticheat_speedhack_accu, frametime);
		MEAN_ACCUMULATE(this, anticheat_speedhack_m2, this.anticheat_speedhack_accu, frametime);
		MEAN_ACCUMULATE(this, anticheat_speedhack_m3, this.anticheat_speedhack_accu, frametime);
		MEAN_ACCUMULATE(this, anticheat_speedhack_m4, this.anticheat_speedhack_accu, frametime);
		MEAN_ACCUMULATE(this, anticheat_speedhack_m5, this.anticheat_speedhack_accu, frametime);
	} else {
		this.anticheat_speedhack_accu = 1;
		this.anticheat_speedhack_lasttime = servertime;
	}
}

void anticheat_spectatecopy(entity this, entity spectatee)
{
	// div0_evade -> SPECTATORS
	this.angles = spectatee.anticheat_div0_evade_v_angle;
}

void anticheat_prethink(entity this)
{
	// div0_evade -> SPECTATORS
	this.anticheat_div0_evade_offset = 0;
}

string anticheat_display(float f, float t, float tmin, float mi, float ma)
{
	string s;
	s = ftos(f);
	if (t >= tmin) {
		if(f <= mi)
			return strcat(s, ":N");
		if(f >= ma)
			return strcat(s, ":Y");
	}
	return strcat(s, ":-");
}

#define ANTICHEATS(ANTICHEAT) \
	ANTICHEAT("speedhack", MEAN_EVALUATE(this, anticheat_speedhack), 240, 0, 9999); /* Actually this one seems broken. */ \
	ANTICHEAT("speedhack_m1", MEAN_EVALUATE(this, anticheat_speedhack_m1), 240, 1.01, 1.25); \
	ANTICHEAT("speedhack_m2", MEAN_EVALUATE(this, anticheat_speedhack_m2), 240, 1.01, 1.25); \
	ANTICHEAT("speedhack_m3", MEAN_EVALUATE(this, anticheat_speedhack_m3), 240, 1.01, 1.25); \
	ANTICHEAT("speedhack_m4", MEAN_EVALUATE(this, anticheat_speedhack_m4), 240, 1.01, 1.25); \
	ANTICHEAT("speedhack_m5", MEAN_EVALUATE(this, anticheat_speedhack_m5), 240, 1.01, 1.25); \
	ANTICHEAT("div0_strafebot_old", MEAN_EVALUATE(this, anticheat_div0_strafebot_old), 120, 0.15, 0.4); \
	ANTICHEAT("div0_strafebot_new", MEAN_EVALUATE(this, anticheat_div0_strafebot_new), 120, 0.25, 0.8); \
	ANTICHEAT("div0_evade", MEAN_EVALUATE(this, anticheat_div0_evade), 120, 0.2, 0.5); \
	ANTICHEAT("idle_snapaim", MEAN_EVALUATE(this, anticheat_idle_snapaim_signal) - MEAN_EVALUATE(this, anticheat_idle_snapaim_noise), 120, 0, 9999); \
	ANTICHEAT("idle_snapaim_signal", MEAN_EVALUATE(this, anticheat_idle_snapaim_signal), 120, 0, 9999); \
	ANTICHEAT("idle_snapaim_noise", MEAN_EVALUATE(this, anticheat_idle_snapaim_noise), 120, 0, 9999); \
	ANTICHEAT("idle_snapaim_m2", MEAN_EVALUATE(this, anticheat_idle_snapaim_m2), 120, 0, 9999); \
	ANTICHEAT("idle_snapaim_m3", MEAN_EVALUATE(this, anticheat_idle_snapaim_m3), 120, 0, 9999); \
	ANTICHEAT("idle_snapaim_m4", MEAN_EVALUATE(this, anticheat_idle_snapaim_m4), 120, 0, 9999); \
	ANTICHEAT("idle_snapaim_m7", MEAN_EVALUATE(this, anticheat_idle_snapaim_m7), 120, 0, 9999); \
	ANTICHEAT("idle_snapaim_m10", MEAN_EVALUATE(this, anticheat_idle_snapaim_m10), 120, 0, 9999); \
	ANTICHEAT("div0_snapback", MEAN_EVALUATE(this, anticheat_div0_snapback), 120, 0, 9999)

void anticheat_report_to_eventlog(entity this) {
	if(!autocvar_sv_eventlog)
		return;
	GameLogEcho(strcat(":anticheat:_time:", ftos(this.playerid), ":", ftos(servertime - this.anticheat_jointime)));
#define ANTICHEAT_REPORT_ONE(name, f, tmin, mi, ma) \
	GameLogEcho(strcat(":anticheat:", name, ":", anticheat_display(f, servertime - this.anticheat_jointime, tmin, mi, ma)))
	ANTICHEATS(ANTICHEAT_REPORT_ONE);
#undef ANTICHEAT_REPORT_ONE
}

void anticheat_report_to_playerstats(entity this) {
	PlayerStats_GameReport_Event_Player(this,
		strcat(PLAYERSTATS_ANTICHEAT, "_time"), servertime - this.anticheat_jointime);
#define ANTICHEAT_REPORT_ONE(name, f, tmin, mi, ma) \
	PlayerStats_GameReport_Event_Player(this, strcat(PLAYERSTATS_ANTICHEAT, name), f)
	ANTICHEATS(ANTICHEAT_REPORT_ONE);
#undef ANTICHEAT_REPORT_ONE
}

void anticheat_register_to_playerstats() {
	PlayerStats_GameReport_AddEvent(strcat(PLAYERSTATS_ANTICHEAT, "_time"));
#define ANTICHEAT_REGISTER_ONE(name, unused_f, unused_tmin, unused_mi, unused_ma) \
	PlayerStats_GameReport_AddEvent(strcat(PLAYERSTATS_ANTICHEAT, name))
	ANTICHEATS(ANTICHEAT_REGISTER_ONE);
#undef ANTICHEAT_REGISTER_ONE
}

#undef ANTICHEATS

void anticheat_startframe()
{
	anticheat_div0_evade_evasion_delta += frametime * (0.5 + random());
}

void anticheat_fixangle(entity this)
{
	this.anticheat_fixangle_endtime = servertime + ANTILAG_LATENCY(this) + 0.2;
}

void anticheat_endframe()
{
	FOREACH_CLIENT(it.fixangle, anticheat_fixangle(it));
	anticheat_div0_evade_evasion_delta += frametime * (0.5 + random());
}

void anticheat_init(entity this)
{
	this.anticheat_speedhack_offset = 0;
	this.anticheat_jointime = servertime;
}
