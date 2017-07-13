/* Train QuickC program
	By Jim Dose'  9/11/96
	Copyright (c)1996 Hipnotic Interactive, Inc.
	All rights reserved.
	Distributed (unsupported) on 3.12.97
*/

void train_blocked(entity this, entity blocker);
void hip_train_next(entity this);
void hip_func_train_find(entity this);

void hip_train_use(entity this, entity actor, entity trigger)
{
	if(getthink(this) != hip_func_train_find)
	{
		if(this.velocity != '0 0 0')
			return;		// already activated
	}
	hip_train_next(this);
}

void hip_train_wait(entity this)
{
	if(this.wait)
	{
		_sound(this, CHAN_VOICE, this.noise, 1, ATTN_NORM);
		if(this.wait != -1)
		{
			this.nextthink = this.ltime + this.wait;
			this.wait = 0;
		}
	}
	else
		this.nextthink = this.ltime + 0.1;

	setthink(this, hip_train_next);
}


void hip_train_next(entity this)
{
	// Get the speed of the current path_corner.
	// (we must save this off at each path change since
	// we don't have a pointer to the current path_corner).
	float current = this.cnt;

	entity targ = find(NULL, targetname, this.target);

	// Save the speed in cnt for later use
	this.cnt = targ.speed;
	this.target = targ.target;
	if(!this.target)
		objerror(this, "hip_train_next: no next target");

	_sound(this, CHAN_VOICE, this.noise1, 1, ATTN_NORM);

	this.wait = targ.wait;
	if(targ.wait)
		setthink(this, hip_train_wait);
	else
		setthink(this, hip_train_next);

	if(this.goalentity.event)
	{
		// Trigger any events that should happen at the corner.
		string temp = this.target;
		this.target = this.goalentity.event;
		this.message = this.goalentity.message;
		SUB_UseTargets(this, NULL, NULL);
		this.target = temp;
		this.message = string_null;
	}

	// Save the current entity
	this.goalentity = targ;

	if(current == -1)
	{
		// Warp to the next path_corner
		setorigin(this, targ.origin - this.mins );
		this.nextthink = this.ltime + 0.01;
	}
	else
	{
		// check if there's a speed change
		if(current>0)
			this.speed = current;

		// travel to the next path change
		SUB_CalcMove(this, targ.origin - this.mins, this.speed, getthink(this));
	}
}

void hip_func_train_find(entity this)
{
	entity targ = find(NULL, targetname, this.target);

	// Save the current entity
	this.goalentity = targ;

	// Save the speed in cnt for later use
	this.cnt = targ.speed;

	this.target = targ.target;
	setorigin(this, targ.origin - this.mins);
	if(!this.targetname)
	{	// not triggered, so start immediately
		this.nextthink = this.ltime + 0.1;
		setthink(this, hip_train_next);
	}
}

/*QUAKED func_train2 (0 .5 .8) ?
This is a modification of the standard func_train entity.
It is functionally equivalent, except that it removes a slight delay that
would occur after each path entry, and it adds a speed variable to the
path_corner entity.

"noise" contains the name of the sound to play when train stops.
"noise1" contains the name of the sound to play when train moves.
Both "noise" and "noise1" defaults depend upon "sounds" variable.

In path_corner, set speed to be the new speed of the train after it reaches
the path change.  If speed is -1, the train will warp directly to the next
path change after the specified wait time.

Also in path_corner, if wait is set to -1, the train will wait until it is
retriggered before moving on to the next goal.

Here is a reiteration of the func_train docs:

Trains are moving platforms that players can ride.
The targets origin specifies the min point of the train at each corner.
The train spawns at the first target it is pointing at.
If the train is the target of a button or trigger, it will not begin moving until activated.
speed	default 100
dmg		default	2
sounds
1) ratchet metal

*/
spawnfunc(func_train2)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	if(!this.speed)
		this.speed = 100;
	if(!this.target || this.target == "")
		objerror(this, "func_train without a target");
	if(!this.dmg)
		this.dmg = 2;

	if (!InitMovingBrushTrigger(this))
		return;
	this.effects |= EF_LOWPRECISION;

	if(!this.noise)
	{
		if(this.sounds == 0)
			this.noise =("misc/null.wav");

		if(this.sounds == 1)
			this.noise =("plats/train2.wav");
	}
	if(!this.noise1)
	{
		if(this.sounds == 0)
			this.noise1 =("misc/null.wav");
		if(this.sounds == 1)
			this.noise1 =("plats/train1.wav");
	}

	precache_sound(this.noise);
	precache_sound(this.noise1);

	this.cnt = 1;
	setblocked(this, train_blocked);
	this.use = hip_train_use;
	this.classname = "train2";

// start trains on the second frame, to make sure their targets have had
// a chance to spawn
	this.nextthink = this.ltime + 0.1;
	setthink(this, hip_func_train_find);
}
