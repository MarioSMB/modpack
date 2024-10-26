#ifdef SVQC

.float rand;

void timer_think(entity this)
{
	playercount_convert(this, count);
	
	if(this.state == this.count)
	{
		//SUB_Remove();
		return;
	}

	if(this.nextthink > time)	// turn off again
	{
		this.nextthink = 0;
		return;
	}		

	this.nextthink = time + this.wait + random() * this.rand;
	this.state += 1;
	SUB_UseTargets(this, this.owner, this.enemy);
}

void timer_use(entity this, entity actor, entity trigger)
{
	this.owner = actor;
	this.enemy = trigger;
	this.state = 0;
	timer_think(this);
}

/*QUAKED trigger_timer (.5 .5 .5) (-16 -16 -16) (16 16 16) START_ON
Fires its targets once every "wait" seconds. If "count" is set, it will only fire that many times and then stop. Set "rand" to add a random extra delay to the wait interval.

SPAWNFLAGS
START_ON: do not wait until triggered to begin firing
*/
/*FGD
@PointClass size(32 32 32) color(160 0 160) base(Appearflags, Target, Targetname) = trigger_timer : "Trigger: Timer
Fires its targets once every 'wait' seconds once activated. If 'count' is set, it will only fire that many times and then stop. Set 'rand' to add a random extra delay to the wait interval." 
[
	spawnflags(flags) = [ 
		1: "Start On" : 0
	]
	count(integer) : "Limit" : 0
	wait(string) : "Interval"
	rand(string) : "Random Extra Interval"
]
*/
spawnfunc(trigger_timer)
{
	if(!this.wait)
		this.wait = 1;
	if(this.rand < 0)
		this.rand = 0;
		
	setthink(this, timer_think);
	this.use = timer_use;

	if(this.spawnflags & 1)	// start on
	{
		this.nextthink = time + this.wait;
		this.owner = nextent(NULL);	// use first player as activator since we're never triggered by an activator
	}
	
	if(!this.count)
		this.count = -1;
}

#endif
