#ifdef SVQC

/*  Copyright (C) 1996-2022 id Software LLC

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

	See file, 'COPYING', for details.
*/

const int FUNC_BOB_NONSOLID = BIT(0);
const int FUNC_BOB_START_ON = BIT(1);

const float FUNC_BOB_THINKINTERVAL = 0.05;

.entity bobbing_controller;

vector func_bob_GetPositionForAngle(entity this, float an)
{
	this.count += (an);
	this.count = (this.count % 360);

	float dd = sin(this.count);
	vector offs = this.dest * dd;
	if(this.dest2 != '0 0 0')
	{   
		float ddc = cos(this.count);
		offs += (this.dest2 * ddc);
	}

	return offs;
}

void func_bob_blocked(entity this, entity blocker)
{
	if(this.attack_finished > time) return;
	T_Damage(blocker, this, this, this.dmg, DEATH_CRUSH.m_id);
	this.attack_finished = time + 0.5;
}

// Used by solid bobbers
void func_bob_controller_think(entity this)
{
	entity bob = this.owner;
	this.nextthink = time + FUNC_BOB_THINKINTERVAL;

	if(!bob.state)
	{
		bob.velocity = '0 0 0';
		CSQCMODEL_AUTOUPDATE(bob);
		return;
	}

	vector offs = func_bob_GetPositionForAngle(bob, bob.cnt * FUNC_BOB_THINKINTERVAL * PHYS_INPUT_FRAMETIME);

	vector diff = offs - bob.origin;
	if(bob.classname == "func_bob") // don't brake stuff if the func_bob was killtarget'ed
		// * 10 so it will arrive in 0.1 sec
		bob.velocity = diff * (1 / FUNC_BOB_THINKINTERVAL);
	CSQCMODEL_AUTOUPDATE(bob);
}

void func_bob_use(entity this, entity actor, entity trigger)
{
	if(this.state)
	{
		this.velocity = '0 0 0';
		this.bobbing_controller.nextthink = -1;
	}
	else
	{
		func_bob_controller_think(this.bobbing_controller);
	}

	this.state = 1 - this.state;
	CSQCMODEL_AUTOUPDATE(this);
}

spawnfunc(func_bob)
{
	if(!MP_MG) { delete(this); return; }

	_setmodel(this, this.model);
	setorigin(this, this.origin);

	if(!this.dest)
		this.dest = '0 0 64';
	if(!this.wait)
		this.wait = 10;
	if(!this.dmg)
		this.dmg = 1;
	this.cnt = 360 / this.wait;
	this.count = 360 * this.delay;
 
	this.use = func_bob_use;
	
	setblocked(this, func_bob_blocked);

	if(this.spawnflags & FUNC_BOB_NONSOLID)
	{
		set_movetype(this, MOVETYPE_FAKEPUSH);
		this.solid = SOLID_NOT;
	}
	else
	{
		set_movetype(this, MOVETYPE_PUSH);
		this.solid = SOLID_BSP;
	}

	// wait for targets to spawn
	entity controller = new_pure(func_bobbing_controller);
	set_movetype(controller, MOVETYPE_NONE); // link with qc
	controller.owner = this;
	setthink(controller, func_bob_controller_think);
	this.nextthink = this.ltime + 999999999;
	setthink(this, SUB_NullThink);
	this.bobbing_controller = controller;

	CSQCMODEL_AUTOINIT(this);

	if(this.spawnflags & FUNC_BOB_START_ON)
		func_bob_use(this, NULL, NULL);
}

// =======================================

/*
	FUNC_BOBBING

a lot has been done here to never ever rely on values that are repeatedly summed
over time, as floating point error will cause gradual drift.

usually, movers use this.ltime so that time doesn't advance for them while they're
blocked, preventing SUB_CalcMove from being shifted off the end of its motion and
screwing up doors. we don't do that here, because accumulated time error in .ltime  
will cause bobbings to slowly slide out of phase with each other and not keep good 
time. if the mapper sets an oscillation period of 5.0 seconds, the mover damn sure
better oscillate once every exactly 5 seconds, not '5-ish'.

engine structure requires that mover thinks be scheduled using .ltime because that's
what it compares a MOVETYPE_PUSH's nextthink against, but we can use global time for
actual positioning/velocity. it requires some particular gymnastics in the .blocked()
function, but the result is precise and seamless.

.wait: wavelength in seconds
.delay: current phase offset (0-1)
.search_time: origin point in time of the cosine wave. whenever we save it, we shift
	it backwards by the current .delay * .wait
.length: think rate, usually 0.1 but can be lower on hyperactive bobbers
*/

const int SFLAG_BOB_CRUSHER = 2;
const int SFLAG_BOB_STOPLOW = 4;
const int SFLAG_BOB_STOPMID = 8;
const int SFLAG_BOB_STOPHI = 16;
const int SFLAG_BOB_STOP = 4+8+16;

void func_bobbing_think(entity this);

void func_bobbing_blocked(entity this, entity blocker)
{
	T_Damage(blocker, this, this, this.dmg, DEATH_CRUSH.m_id);
	
	if(this.spawnflags & SFLAG_BOB_CRUSHER)	// don't reverse
		return;
	
	// reversing direction entails reversing the phase
	this.delay = (this.delay * -1) + 1 + (this.length / this.wait);
	// put it one think in the future too
	
	// set new starting conditions to reanchor the reverse movement at
	// the moment of contact
	this.search_time = time - this.delay * this.wait - this.length;
	// subtracting .length puts the reversed wave one more think in the past.
	// if we don't we'll get a frame of 0 movement
	
	// start new movement now or we'll be a CRUSHER anyway
	func_bobbing_think(this);
}

void func_bobbing_use(entity this, entity actor, entity trigger)
{
	setthink(this, func_bobbing_think);
	
	if(this.state == 2)	// a future stop was requested but we never reached it
		this.state = 1;		// go back to being plain old 'on'
	else
		this.state = !this.state;
	
	if(this.state)	// start immediately
	{
		this.search_time = time - this.delay * this.wait;
		_sound(this, CH_TRIGGER_SINGLE, this.noise1, 1, ATTN_NORM);	// move
		if(getthink(this))
			getthink(this)(this);
		return;
	}
	
	if(this.spawnflags & SFLAG_BOB_STOP)	// stop at an apex, not immediately
	{
		this.state = 2;
		return;
	}
	
	// stop immediately
	_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);	// cut off move sound with stop sound
	this.nextthink = 0;
}

vector func_bobbing_pos(entity this, float thephase)
{
	float cosD = (1 - cos(360 * thephase)) / 2;	// flip -1/1 and scale to 0-1
	vector newpos = this.pos1 + (cosD * (this.pos2 - this.pos1));
	return newpos;
}

void func_bobbing_think(entity this)
{
	if(!this.state)
	{
		this.velocity = '0 0 0';
		return;
	}
	
	// always derive current phase from a fixed starting time rather than
	// summing an offset every think, or we'll accumulate error and drift
	float curphase = ((time - this.search_time) / this.wait) % 1;
	if(curphase < this.delay)
		curphase += 1;	// don't wrap yet
	
	bool atLow = (this.delay < 0.5 && curphase >= 0.5);
	bool atHigh = (this.delay < 1 && curphase >= 1);
	bool stop = false;
	
	if(this.state == 2) // stop at our earliest convenience
	{
		if(atLow && (this.spawnflags & SFLAG_BOB_STOPLOW))
		{
			curphase = 0.5;
			stop = true;
		}
		else if(atHigh && (this.spawnflags & SFLAG_BOB_STOPHI))
		{
			curphase = 0;
			stop = true;
		}
		else if(this.spawnflags & SFLAG_BOB_STOPMID)
		{
			if(this.delay < 0.25 && curphase >= 0.25)
			{
				curphase = 0.25;
				stop = true;
			}
			else if(this.delay < 0.75 && curphase >= 0.75)
			{
				curphase = 0.75;
				stop = true;
			}		
		}
	}	
	else if(atLow || atHigh)
	{
		// when we pass either apex, repeat the noises
		_sound(this, CH_TRIGGER_SINGLE, this.noise1, 1, ATTN_NORM);	// move
		_sound(this, CHAN_BODY, this.noise, 1, ATTN_NORM);	// stop
	}
	
	if(stop)
	{
		this.state = 0;
		_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);	// cut off move sound with stop sound
	}
	
	this.delay = curphase;
	if(this.delay > 1)	// now we can wrap
		this.delay -= 1;
	
	// whither are we going
	vector dst = func_bobbing_pos(this, curphase);
	
	this.velocity = (dst - this.origin) / this.length;
	this.nextthink = this.ltime + this.length;
}

/*QUAKED func_bobbing (0 .5 .8) ? START_OFF CRUSHER STOP_LOW STOP_MID STOP_HIGH - - START_INVIS
Bobbing platform. Moves in a smooth sine wave. Build at the center of motion, specify 'wait' for the wavelength in seconds and 'distance' for the amplitude (distance from end to end) in units.
Trigger to freeze/reactivate.

"angle" set bob axis
"distance" total distance of bob, will move half this far in either direction
"pos1"/"pos2" ignore angle/distance and set apex offsets directly
"wait" wavelength of bob in seconds
"delay" phase offset to start at (0 = pos1, 0.5 = pos2, 1.0 = back at pos1 again)
"sounds"
0) none, or, set your own with 'noise' (stop sound) and 'noise1' (move sound)
1) ratchet metal
2) base plat

Spawnflags
START_OFF	start off
CRUSHER		don't reverse when blocked
STOP_*		when triggered off, keep oscillating until reaching the low/high/midpoint and stop there. checking more than one adds eligible stopping places, and the bobber will stop at the first one reached.
*/
/*FGD
@baseclass base(Appearflags, Targetname, TrainSounds, Angle, Func, FuncInvis) = Bob
[
	spawnflags(flags) = [
		1 : "Start off" : 0
		2 : "Crusher (no reverse)" : 0
		4 : "Don't stop until low pos" : 0
		8 : "Don't stop until mid pos" : 0
		16 : "Don't stop until high pos" : 0
	]
	wait(string) : "Period (Wavelength)" : "4"
	distance(integer) : "Length (Amplitude)" : 64
	delay(string) : "Starting offset (0-1) (Phase)" : "0.0"
	dmg(integer) : "Damage when blocked" : 2
	noise(string) : "Override stop sound"
	noise1(string) : "Override move sound"
	pos1(string) : "Override peak position (relative)"
	pos2(string) : "Override trough position (relative)"
]
@SolidClass base(Bob) = func_bobbing : "Bobbing platform.
Moves in a smooth sine wave. Build at the center of motion, specify 'wait' for the wavelength in seconds and 'distance' for the amplitude (distance from end to end) in units. Use 'delay' to set a phase offset (0-1).
Trigger to freeze in place or reactivate. If any 'don't stop until' spawnflags are checked, the bobber will keep oscillating until it reaches one of the designated positions and stop there.

Set both 'pos1' & 'pos2' to override the two apex positions (ends of the bob) to build and light your plat wherever."  []
*/
void func_bobbing_init(entity this, entity actor, entity trigger);
spawnfunc(func_bobbing)
{
	precache_model(this.model);
	if(this.sounds == 0)
	{
		if(!this.noise || this.noise == "")
			this.noise = ("misc/null.wav");
		if(!this.noise1 || this.noise1 == "")
			this.noise1 = ("misc/null.wav");
		precache_sound(this.noise);
		precache_sound(this.noise1);
	}

	if(this.sounds == 1)
	{
		this.noise = ("plats/train2.wav");
		precache_sound("plats/train2.wav");
		this.noise1 = ("plats/train1.wav");
		precache_sound("plats/train1.wav");
	}
	if(this.sounds == 2)
	{
		precache_sound("plats/plat1.wav");
		precache_sound("plats/plat2.wav");
		this.noise1 = "plats/plat1.wav";
		this.noise = "plats/plat2.wav";
	}

	SetMovedir(this);
	if(!this.distance)
		this.distance = 64;
	if(this.wait <= 0)
		this.wait = 4;
	
	this.dmg = zeroconvertdefault(this.dmg, 2);
	
	if(!this.pos1 && !this.pos2)
	{
		this.pos1 = this.origin + this.distance * 0.5 * this.movedir;
		this.pos2 = this.origin - this.distance * 0.5 * this.movedir;
	}
	this.length = min(0.1, this.wait / 6);

	if(this.spawnflags & 128)
		this.use = func_bobbing_init;
	else
		func_bobbing_init(this, NULL, NULL);
}

void func_bobbing_usethink(entity this)
{
	func_bobbing_use(this, NULL, NULL);
}

void func_bobbing_init(entity this, entity actor, entity trigger)
{
	if(!(this.spawnflags & START_OFF))
	{
		setthink(this, func_bobbing_usethink);
		this.nextthink = 0.3;	// wait for items and monsters to rest on it
	}
	
	this.use = func_bobbing_use;
	setblocked(this, func_bobbing_blocked);
	
	this.solid = zeroconvertdefault(this.solid, SOLID_BSP);
	if(!this.solid)
		set_movetype(this, MOVETYPE_FAKEPUSH);
	else
		set_movetype(this, MOVETYPE_PUSH);

	_setmodel(this, this.model);
	setsize(this, this.mins, this.maxs);
	setorigin(this, func_bobbing_pos(this, this.delay));
}


/*QUAKED func_bobbing_point (0 .5 .8) (-8 -8 -8) (8 8 8) START_OFF CRUSHER STOP_LOW STOP_MID STOP_HIGH - - START_INVIS
Bobbing platform. Moves in a smooth sine wave. Build at the center of motion, specify 'wait' for the wavelength in seconds and 'distance' for the amplitude (distance from end to end) in units.
Trigger to freeze/reactivate.

"angle" set bobaxis
"distance" total distance of bob, will move half this far in either direction
"pos1"/"pos2" ignore angle/distance and set apex offsets directly
"wait" wavelength of bob in seconds
"delay" phase offset to start at (0 = pos1, 0.5 = pos2, 1.0 = back at pos1 again)
"sounds"
0) none, or, set your own with 'noise' (stop sound) and 'noise1' (move sound)
1) ratchet metal
2) base plat

Spawnflags
START_OFF	start off
CRUSHER		don't reverse when blocked
STOP_*		when triggered off, keep oscillating until reaching the low/high/midpoint and stop there. checking more than one adds eligible stopping places, and the bobber will stop at the first one reached.
*/
/*FGD
@PointClass size(16 16 16) base(Bob) = func_bobbing_point : "Bobbing platform.
Moves in a smooth sine wave. Build at the center of motion, specify 'wait' for the wavelength in seconds and 'distance' for the amplitude (distance from end to end) in units. Use 'delay' to set a phase offset (0-1).
Trigger to freeze in place or reactivate. If any 'don't stop until' spawnflags are checked, the bobber will keep oscillating until it reaches one of the designated positions and stop there.

Set both 'pos1' & 'pos2' to override the two apex positions (ends of the bob) to build and light your plat wherever."  [
	model(string) : "Model to use"
]
*/
spawnfunc(func_bobbing_point)
{
	spawnfunc_func_bobbing(this);
}

#endif
