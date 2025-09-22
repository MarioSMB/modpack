#include "screenshake.qh"

#ifdef SVQC
void screenshake_go(entity targ, float mag)
{
	// punchangle doesn't work when we're in an intermission camera, so do
	// this with actual angle offsets when intermission > 0
	if(intermission_running)
	{
		vector kick = randomvec();
		kick *= bound(1, mag, 4);	// don't let vp wander too far, it might clip
		setorigin(targ, targ.goalentity.origin + kick);	// goalentity = current info_intermission
		
		// angle kicks look a lot harder in intermission for some reason, don't 
		// do them unless we mean it
		if(mag >= 1)
		{
			kick_z = crandom() * mag;
			mag *= 0.5;
			kick_x = crandom() * mag;
			kick_y = crandom() * mag;
			targ.angles = targ.mangle + kick;
			targ.fixangle = 1;
		}
		return;
	}	
	
	mag += 0.4;
	
	if(mag > 0.2)
	{
		targ.punchangle_x = crandom() * mag;
		targ.punchangle_y = crandom() * mag;
	}
	// the rolls feel a lot less violent, so bump them up a little
	if(mag > 0.1)
		targ.punchangle_z = crandom() * mag * 2;	
	
	// punchangle is integerized, so jitter viewpoint itself also for the feel of a faint 
	// rumble when the magnitude is low instead of just a dying fish kicking occasionally
	if(targ.health > 0) // view_ofs_z == 0 is a byword for 'dead' elsewhere :/
	{
		// quake only sends the z component of view_ofs over the network
		targ.view_ofs_z = crandom() * bound(0, mag * 2, 4) + 22;
	}	
}

void screenshake_think(entity this)
{
	float mag = 0;
	
	if(time > this.pain_finished)
	{
		// TODO: why change player height?!
		FOREACH_CLIENT(IS_PLAYER(it),
		{
			it.v_angle_z = 0; // unroll
			if(intermission_running || it.health <= 0)
				it.view_ofs_z = 0;
			else
				it.view_ofs_z = 22;
		});
		this.state = 0;
		return;
	}
	
	if(time < this.super_time + this.delay)
	{
		this.state = 1;
		mag = 1 - ((this.super_time + this.delay) - time) / this.delay;
	}
	else if(time < this.super_time + this.delay + this.length)
	{
		this.state = 2;
		mag = 1;
	}
	else if(time < this.pain_finished)
	{
		mag = (this.pain_finished - time) / this.wait;
		this.state = 3;
	}
	
	mag *= mag;	// power of 2 falloff seems smoother than linear

	FOREACH_CLIENT(IS_PLAYER(it),
	{
		float dmag = 1;
		if(this.distance)
			dmag = max(0, 1 - (vlen(this.origin - it.origin) / this.distance));
		if(dmag > 0)
			screenshake_go(it, this.strength * mag * dmag * dmag);
	});

	this.nextthink = time + 0.05;
}

void target_screenshake_use(entity this, entity actor, entity trigger)
{
	this.pain_finished = time + this.wait + this.delay + this.length;
	this.super_time = time;
	this.nextthink = time + 0.05;
	setthink(this, screenshake_think);
}

void screenshake_setup(entity this)
{
	this.wait = max(0, this.wait);
	this.delay = max(0, this.delay);
	this.length = max(0, this.length);
	this.distance = max(0, this.distance);
	
	if(!this.delay && !this.length && !this.wait)
		LOG_DEBUG("misc_screenshake will last 0 seconds");

	if(!this.strength)
	{
		if(this.volume)
			LOG_DEBUG("\bwarning:\b convert target_screenshake to .strength please");
		
		this.strength = 1;
	}
	this.use = target_screenshake_use;
}


/*QUAKED target_screenshake (0 .5 .8) (-8 -8 -8) (8 8 8)
Shakes the screen. Jostles the view of all clients, but doesn't physically move their bounding boxes or apply velocities.
Keys
"length" Duration of full intensity quake. -1 will last literally forever.
"delay" Time to ramp up quake intensity from 0
"wait" Time to ramp down quake intensity to 0. Total quake duration is length + delay + wait.
"strength" Intensity of quake. 1 is a hearty rumble, 10 is spasmodic bordering on hilarious.
"distance" Fade the intensity to 0 at this distance from the entity. Default is 0 (global).
*/
/*FGD
@Pointclass base(Targetname, Appearflags) color(0 128 224) size(16 16 16) = target_screenshake : 
"Shakes the screen. Jostles the view of all clients, but doesn't physically move their bounding boxes or apply velocities.
Total shake duration is length + delay + wait." 
[
	length(string) : "Duration of full intensity (sustain)"
	delay(string) : "Time to ramp up from 0 (attack)"
	wait(string) : "Time to ramp down quake intensity to 0."
	strength(string) : "Intensity of quake. 1 is a hearty rumble, 10 is spasmodic bordering on hilarious." : "1.0"
	distance(integer) : "Attenuation distance; 0 is global" : 0
]
*/
spawnfunc(target_screenshake)
{
	screenshake_setup(this);
}

void screenshake_oneshot(entity source, float attack, float sustain, float release, float str)
{
	entity shake = spawn();

	set_movetype(shake, MOVETYPE_NONE);
	shake.delay = attack;
	shake.length = sustain;
	shake.wait = release;
	shake.strength = str;

	if(source)
		setorigin(shake, source.origin);

	screenshake_setup(shake);
	target_screenshake_use(shake, NULL, NULL);
}
#endif
