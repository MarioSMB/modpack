/* Counter QuickC program
	By Jim Dose'  9/13/96
	Copyright (c)1996 Hipnotic Interactive, Inc.
	All rights reserved.
	Distributed (unsupported) on 3.12.97
*/

const int COUNTER_TOGGLE = BIT(0);
const int COUNTER_LOOP = BIT(1);
const int COUNTER_STEP = BIT(2);
const int COUNTER_RESET = BIT(3);
const int COUNTER_RANDOM = BIT(4);
const int COUNTER_FINISHCOUNT = BIT(5);
const int COUNTER_START_ON = BIT(6);

void counter_on_use(entity this, entity actor, entity trigger);
void counter_off_use(entity this, entity actor, entity trigger);

void counter_think(entity this)
{
	this.cnt = this.cnt + 1;
	if(this.spawnflags & COUNTER_RANDOM)
	{
		this.state = random() * this.count;
		this.state = floor(this.state) + 1;
	}
	else
		this.state = this.cnt;

	SUB_UseTargets(this, this.enemy, this.enemy);

	if(getthink(this))
		this.nextthink = time + this.wait;

	if(this.spawnflags & COUNTER_STEP)
		counter_on_use(this, this.enemy, this.enemy);

	if( this.cnt >= this.count )
	{
		this.cnt = 0;
		if((this.aflag) || !(this.spawnflags & COUNTER_LOOP))
		{
			if(this.spawnflags & COUNTER_TOGGLE)
				counter_on_use(this, this.enemy, this.enemy);
			else
				delete(this);
		}
	}
}

void counter_on_use(entity this, entity actor, entity trigger)
{
	if((this.cnt != 0) && (this.spawnflags & COUNTER_FINISHCOUNT))
	{
		this.aflag = true;
		return;
	}

	this.use = counter_off_use;
	setthink(this, func_null);
	this.nextthink = 0;
	this.aflag = false;
}

void counter_off_use(entity this, entity actor, entity trigger)
{
	this.aflag = false;
	if(this.spawnflags & COUNTER_TOGGLE)
		this.use = counter_on_use;
	else
		this.use = func_null;

	if(this.spawnflags & COUNTER_RESET)
	{
		this.cnt = 0;
		this.state = 0;
	}
	this.enemy = trigger;
	setthink(this, counter_think); // TODO: do we actually want this?
	if(this.delay)
		this.nextthink = time + this.delay;
	else
		counter_think(this);
}

void counter_off_use_think(entity this)
{
	counter_off_use(this, NULL, NULL);
}

int counter_GetCount(entity counter)
{
	if(counter.classname == "counter")
		return counter.state;

	return 0;
}

/*QUAKED func_counter (0 0 0.5) (0 0 0) (32 32 32) TOGGLE LOOP STEP RESET RANDOM FINISHCOUNT START_ON
TOGGLE causes the counter to switch between an on and off state
each time the counter is triggered.

LOOP causes the counter to repeat infinitly.  The count resets to zero
after reaching the value in "count".

STEP causes the counter to only increment when triggered.  Effectively,
this turns the counter into a relay with counting abilities.

RESET causes the counter to reset to 0 when restarted.

RANDOM causes the counter to generate random values in the range 1 to "count"
at the specified interval.

FINISHCOUNT causes the counter to continue counting until it reaches "count"
before shutting down even after being set to an off state.

START_ON causes the counter to be on when the level starts.

"count" specifies how many times to repeat the event.  If LOOP is set,
it specifies how high to count before reseting to zero.  Default is 10.

"wait"  the length of time between each trigger event. Default is 1 second.

"delay" how much time to wait before firing after being switched on.
*/

spawnfunc(func_counter)
{
	if(!MP_HIPNOTIC) { delete(this); return; }
	
	if(!this.wait)
		this.wait = 1;

	this.count = floor(this.count);
	if(this.count <= 0)
		this.count = 10;

	this.cnt = 0;
	this.state = 0;

	this.classname = "counter";
	this.use = counter_off_use;
	setthink(this, func_null);
	if(this.spawnflags & COUNTER_START_ON)
	{
		setthink(this, counter_off_use_think);
		this.nextthink = time + 0.1;
	}
}

void oncount_use(entity this, entity actor, entity trigger)
{
	if(counter_GetCount(trigger) == this.count)
		SUB_UseTargets(this, actor, actor);
}

/*QUAKED func_oncount (0 0 0.5) (0 0 0) (16 16 16)
Must be used as the target for func_counter.  When the counter
reaches the value set by count, func_oncount triggers its targets.

"count" specifies the value to trigger on.  Default is 1.

"delay" how much time to wait before firing after being triggered.
*/

spawnfunc(func_oncount)
{
	if(!MP_HIPNOTIC) { delete(this); return; }
	
	this.count = floor(this.count);
	if(this.count <= 0)
		this.count = 1;

	this.classname = "oncount";
	this.use = oncount_use;
	setthink(this, func_null);
}
