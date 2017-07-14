#ifdef SVQC

void train_next(entity this);
void func_train_find(entity this);

void train_blocked(entity this, entity blocker)
{
	if(time < this.attack_finished)
		return;
	this.attack_finished = time + 0.5;
	T_Damage(blocker, this, this, this.dmg);
}
void train_use(entity this, entity actor, entity trigger)
{
	if(getthink(this) != func_train_find)
		return;		// already activated
	train_next(this);
}

void train_wait(entity this)
{
	if(this.wait)
	{
		this.nextthink = this.ltime + this.wait;
		_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
	}
	else
		this.nextthink = this.ltime + 0.1;
	
	setthink(this, train_next);
}

void train_next(entity this)
{
	entity	targ;

	targ = find(NULL, targetname, this.target);
	this.target = targ.target;
	if(!this.target || this.target == "")
		objerror(this, "train_next: no next target");
	if(targ.wait)
		this.wait = targ.wait;
	else
		this.wait = 0;
	_sound(this, CH_TRIGGER_SINGLE, this.noise1, 1, ATTN_NORM);
	SUB_CalcMove(this, targ.origin - this.mins, this.speed, train_wait);
}

void func_train_find(entity this)
{
	entity	targ;

	targ = find(NULL, targetname, this.target);
	this.target = targ.target;
	setorigin(this, targ.origin - this.mins);
	if(!this.targetname || this.targetname == "")
	{	// not triggered, so start immediately
		this.nextthink = this.ltime + 0.1;
		setthink(this, train_next);
	}
}

/*QUAKED func_train(0 .5 .8) ?
Trains are moving platforms that players can ride.
The targets origin specifies the min point of the train at each corner.
The train spawns at the first target it is pointing at.
If the train is the target of a button or trigger, it will not begin moving until activated.
speed	default 100
dmg		default	2
sounds
1) ratchet metal

*/
spawnfunc(func_train)
{	
	if(!this.speed)
		this.speed = 100;
	if(!this.target || this.target == "")
		objerror(this, "func_train without a target");
	if(!this.dmg)
		this.dmg = 2;

	if (!InitMovingBrushTrigger(this))
		return;
	this.effects |= EF_LOWPRECISION;

	if(this.sounds == 0)
	{
		this.noise =("misc/null.wav");
		precache_sound("misc/null.wav");
		this.noise1 =("misc/null.wav");
		precache_sound("misc/null.wav");
	}

	if(this.sounds == 1)
	{
		this.noise =("plats/train2.wav");
		precache_sound("plats/train2.wav");
		this.noise1 =("plats/train1.wav");
		precache_sound("plats/train1.wav");
	}

	this.cnt = 1;
	setblocked(this, train_blocked);
	this.use = train_use;
	this.classname = "train";

// start trains on the second frame, to make sure their targets have had
// a chance to spawn
	this.nextthink = this.ltime + 0.1;
	setthink(this, func_train_find);
}

/*QUAKED misc_teleporttrain(0 .5 .8)(-8 -8 -8)(8 8 8)
This is used for the final bos
*/
spawnfunc(misc_teleporttrain)
{	
	if(!this.speed)
		this.speed = 100;
	if(!this.target || this.target == "")
		objerror(this, "func_train without a target");

	this.cnt = 1;
	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_PUSH);
	setblocked(this, train_blocked);
	this.use = train_use;
	this.avelocity = '100 200 300';

	this.noise =("misc/null.wav");
	precache_sound("misc/null.wav");
	this.noise1 =("misc/null.wav");
	precache_sound("misc/null.wav");

	precache_model2("progs/teleport.mdl");
	_setmodel(this, "progs/teleport.mdl");
	setsize(this, this.mins , this.maxs);
	setorigin(this, this.origin);

// start trains on the second frame, to make sure their targets have had
// a chance to spawn
	this.nextthink = this.ltime + 0.1;
	setthink(this, func_train_find);
}

// --------------------------------------------------------------------------------
// hipnotic train2

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
		_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
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

	_sound(this, CH_TRIGGER_SINGLE, this.noise1, 1, ATTN_NORM);

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

#endif
