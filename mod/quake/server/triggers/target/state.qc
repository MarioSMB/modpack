#include "state.qh"

#ifdef SVQC
bool target_state_compare(entity this, entity inc)
{
	bool out = false;
	if(this.style & 1)
		out |= (inc.state == this.state);
	if(this.style & 2)
		out |= (inc.state > this.state);
	else if(this.style & 4)
		out |= (inc.state < this.state);
	
	if(this.spawnflags & 2)
		return !out;
	return out;
}

//count -4 = numclients in coop
void playercount_convert(entity this, .float fld)
{
	if(this.(fld) != -4)
		return;
	if(!coop)
		this.(fld) = 1;
	else
	{
		int clients = 0;
		// let's not count bots
		FOREACH_CLIENT(IS_REAL_CLIENT(it) && IS_PLAYER(it),
		{
			++clients;
		});
		// limit this because we can't assume a max of 8 coop players (... thanks decino)
		if(clients <= 4)
			this.(fld) = clients;
		else if(clients >= 20)
			this.(fld) = 10;	// hard cap of 10 @ 20 players
		else if(clients >= 16)
			this.(fld) = 9;
		else if(clients >= 12)
			this.(fld) = 8;
		else if(clients >= 10)
			this.(fld) = 7;
		else if(clients >= 8)
			this.(fld) = 6;
		else if(clients >= 6)
			this.(fld) = 5;		
		/*
			this.(fld) =	// magic formula ...
				min(4, clients)	+							// first four clients count full
				floor(max(0, min(12, clients) - 4) / 2) +	// clients above 4th count half
				floor(max(0, clients - 12) / 4);			// clients above 12th count quarter
		*/
	}
}

void target_state_use(entity this, entity actor, entity trigger)
{
	if(this.customflags & CFL_LOCKED)
		return;

	if(this.spawnflags & 1)
	{
		entity inc = find(NULL, targetname, this.include);
		if(inc)
		{
			if(target_state_compare(this, inc))
				SUB_UseTargets(this, actor, trigger);
		}			
		return;
	}
	
	playercount_convert(this, count);
	
	float mx = max(1, this.count);
	if(this.spawnflags & 2)
	{
		this.state = this.state - 1;
		if(this.state < 0)
			this.state = mx;
	}
	else
	{
		this.state = this.state + 1;
		if(this.state > mx)
			this.state = 0;
	}
	//bprint3("state is now ",ftos(this.state),"\n");
}

/*QUAKED target_state (.5 .0 .5) (-8 -8 -8) (8 8 8) RELAY INVERSE 
Holds a numeric variable, or tests other entities for theirs before firing targets. Set 'state' to initial value. triggering this will cycle the value (swapping 0 and 1).

If "RELAY" is checked, it acts as a relay instead of holding state. It fires its targets based on the value of the 'state' member of another entity, specified by setting 'state' to the value it has to match and 'include' to that entity's targetname. This can be another target_state, or any other entity which has a 'state', such as doors or plats.
	0: off (lights/etc)/top (plats)/open (doors)/pushed (buttons)
	1: on (lights/etc)/bottom (plats)/closed (doors)/unpushed (buttons)
	2: going up (plats)/opening (doors)/pushing (buttons)
	3: going down (plats)/closing (doors)/unpushing (buttons)
A trigger_counter's 'state' is its current trigger count.

Keys:
"style" comparison to make if RELAY
	1: this = include (default)
	2: this < include
	3: this <= include
	4: this > include
	5: this >= include
"count" if > 1, state will be incremented on each trigger to a maximum of 'count' before cycling to 0
"delay" delay before firing (after trigger)
"target2/3/4/kill" targets to fire if RELAY

Spawnflags:
"INVERSE"	if RELAY, will fire if state is anything other than a match. otherwise, will decrement when triggered instead of increment
*/
/*FGD
@PointClass size(16 16 16) color(255 0 255) base(Appearflags, Target, Targetname) = target_state : "Target : State. 
Holds a numeric variable, or tests other entities for theirs before firing targets. 
Set 'state' to initial value. triggering this will cycle the value (swapping 0 and 1).

If 'Relay' spawnflag is checked, it acts as a relay instead of holding state. It fires its targets based on the value of the 'state' member of another entity, specified by setting 'state' to the value it has to match and 'include' to that entity's targetname. This can be another target_state, or any other entity which has a 'state', such as doors or plats.
  0: off (lights/etc)/top (plats)/open (doors)/pushed (buttons)
  1: on (lights/etc)/bottom (plats)/closed (doors)/unpushed (buttons)
  2: going up (plats)/opening (doors)/pushing (buttons)
  3: going down (plats)/closing (doors)/unpushing (buttons)
A trigger_counter's 'state' is its current trigger count.
If 'Inverse' spawnflag is set, will decrement when triggered instead of increment. If both 'Relay' and 'Inverse', will fire targets if the state of 'include' is anything other than a match."
[
	spawnflags(flags) =	[
		1 : "Relay" : 0
		2 : "Inverse" : 0
	]
	style(choices) : "Comparison operator for relay" = [
		1 : "this = include"
		2 : "this < include"
		3 : "this <= include"
		4 : "this > include"
		5 : "this >= include"
	]
	include(target_destination) : "Targetname of entity to monitor"
	count(integer) : "Max state value to cycle to. if > 1, state will be incremented on each trigger to a maximum of 'count' before cycling to 0." : 1
	state(integer) : "Value"
]
*/
spawnfunc(target_state)
{
	if((!this.targetname || this.targetname == "") && !this.impulse)
		objerror(this,"target_state not targeted by anything");
	if((this.spawnflags & 1) && !(this.include || this.include == ""))
		objerror(this,"target_state relay has no include");

	if(this.style < 1 || this.style > 5)
		this.style = 1;
		
	this.use = target_state_use;
}
#endif
