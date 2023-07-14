#include "newplats.qh"

// ==================================
// down N and wait code
// ==================================

void dn_and_wait_go_up(entity this);
void dn_and_wait_go_down(entity this);
void dn_and_wait_crush(entity this, entity blocker);

void dn_and_wait_hit_top(entity this)
{
	_sound(this, CH_TRIGGER_SINGLE, this.noise1, 1, ATTN_NORM);
	this.state = STATE_TOP;
}

void dn_and_wait_hit_bottom(entity this)
{
	_sound(this, CH_TRIGGER_SINGLE, this.noise1, 1, ATTN_NORM);
	this.state = STATE_BOTTOM;
	setthink(this, dn_and_wait_go_up);
	this.nextthink = this.ltime + this.health;
}

void dn_and_wait_go_down(entity this)
{
	_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
	this.state = STATE_DOWN;
	SUB_CalcMove(this, this.pos2, TSPEED_LINEAR, this.speed, dn_and_wait_hit_bottom);
}

void dn_and_wait_go_up(entity this)
{
	_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
	this.state = STATE_UP;
	SUB_CalcMove(this, this.pos1, TSPEED_LINEAR, this.speed, dn_and_wait_hit_top);
}

void dn_and_wait_crush(entity this, entity blocker)
{
	T_Damage(blocker, this, this, 1, DEATH_CRUSH.m_id);
	
	if(this.state == STATE_UP)
		dn_and_wait_go_down(this);
	else if(this.state == STATE_DOWN)
		dn_and_wait_go_up(this);
	else
		objerror(this, "plat_new_crush: bad this.state\n");
}

void dn_and_wait_use(entity this, entity actor, entity trigger)
{
	if(this.state != STATE_TOP)
		return;
	
	dn_and_wait_go_down(this);
}

// ==================================
// toggle type code
// ==================================

void toggle_go_up(entity this);
void toggle_go_down(entity this);
void toggle_crush(entity this, entity blocker);

void toggle_hit_top(entity this)
{
	_sound(this, CH_TRIGGER_SINGLE, this.noise1, 1, ATTN_NORM);
	this.state = STATE_TOP;
}

void toggle_hit_bottom(entity this)
{
	_sound(this, CH_TRIGGER_SINGLE, this.noise1, 1, ATTN_NORM);
	this.state = STATE_BOTTOM;
}

void toggle_go_down(entity this)
{
	_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
	this.state = STATE_DOWN;
	SUB_CalcMove(this, this.pos2, TSPEED_LINEAR, this.speed, toggle_hit_bottom);
}

void toggle_go_up(entity this)
{
	_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
	this.state = STATE_UP;
	SUB_CalcMove(this, this.pos1, TSPEED_LINEAR, this.speed, toggle_hit_top);
}

void toggle_crush(entity this, entity blocker)
{
	T_Damage(blocker, this, this, 1, DEATH_CRUSH.m_id);
	
	if(this.state == STATE_UP)
		toggle_go_down(this);
	else if(this.state == STATE_DOWN)
		toggle_go_up(this);
	else
		objerror(this, "plat_new_crush: bad this.state\n");
}

void toggle_use(entity this, entity actor, entity trigger)
{
	if(this.state == STATE_TOP)
		toggle_go_down(this);
	else if(this.state == STATE_BOTTOM)
		toggle_go_up(this);
}

// ==================================
// elvtr type code
// ==================================

void elvtr_crush(entity this, entity blocker);

void elvtr_stop(entity this)
{
	this.elevatorOnFloor = this.elevatorToFloor;
	_sound(this, CH_TRIGGER_SINGLE, this.noise1, 1, ATTN_NORM);
	this.state = STATE_BOTTOM;
	this.elevatorLastUse = time;
}

void elvtr_go(entity this)
{
	this.elevatorDestination = this.pos2;
	this.elevatorDestination_z = this.pos2_z + 
								(this.height * this.elevatorToFloor);
	_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
	this.state = STATE_UP;
	SUB_CalcMove(this, this.elevatorDestination, TSPEED_LINEAR, this.speed, elvtr_stop);
	this.elevatorLastUse = time;
}

void elvtr_crush(entity this, entity blocker)
{
//	T_Damage (blocker, this, this, 1);
	this.elevatorToFloor = this.elevatorOnFloor;
	
	elvtr_go(this);
}

// ===============
// elevator use function
// 'this' = plat, 'toucher' = elevator button, toucher.enemy = player
// ===============
void elvtr_use(entity this, entity actor, entity trigger)
{
	if((this.elevatorLastUse + 2) > time)
		return;
	
	this.elevatorLastUse = time;

	if(ELV_BUTN_DIR == 0)
		return;

	float elvPos = (this.absmin_z + this.absmax_z) * 0.5;
	float btnPos = (trigger.absmin_z + trigger.absmax_z) * 0.5;

	float tempDist;
	if(elvPos > btnPos)
	{
		tempDist = (elvPos - btnPos) / this.height;
		tempDist = ceil ( tempDist);
		this.elevatorToFloor = this.elevatorOnFloor - tempDist;
		elvtr_go(this);
		return;
	}
	else
	{
		tempDist = btnPos - elvPos;
		if(tempDist > this.height)
		{
			tempDist = tempDist / this.height;
			tempDist = floor ( tempDist );
			this.elevatorToFloor = this.elevatorOnFloor + tempDist;
			elvtr_go(this);
			return;
		}
	}

	if(ELV_BUTN_DIR == -1)
	{	
		if(this.elevatorOnFloor > 0)
		{
			this.elevatorToFloor = this.elevatorOnFloor - 1;
			elvtr_go(this);
		}
	}
	else if(ELV_BUTN_DIR == 1)
	{
		if(this.elevatorOnFloor < (this.cnt - 1))
		{
			this.elevatorToFloor = this.elevatorOnFloor + 1;
			elvtr_go(this);
		}
	}
}

// ==================================
// PLAT2 type code
// ==================================

void plat2_center_touch(entity this, entity toucher);
void plat2_go_up(entity this);
void plat2_go_down(entity this);
void plat2_crush(entity this, entity blocker);

void plat2_spawn_inside_trigger(entity this)
{
//
// middle trigger
//	
	entity trigger = spawn();
	settouch(trigger, plat2_center_touch);
	set_movetype(trigger, MOVETYPE_NONE);
	trigger.solid = SOLID_TRIGGER;
	trigger.enemy = this;
	
	vector tmin = this.mins + '25 25 0';
	vector tmax = this.maxs - '25 25 -8';
	tmin.z = tmax.z - (this.pos1_z - this.pos2_z + 8);

	if(this.spawnflags & PLAT_LOW_TRIGGER)
		tmax.z = tmin.z + 8;
	
	if(this.size_x <= 50)
	{
		tmin.x = (this.mins_x + this.maxs_x) / 2;
		tmax.x = tmin.x + 1;
	}
	if(this.size_y <= 50)
	{
		tmin.y = (this.mins_y + this.maxs_y) / 2;
		tmax.y = tmin.y + 1;
	}
	
	setsize(trigger, tmin, tmax);
}

void plat2_hit_top(entity this)
{
	_sound(this, CH_TRIGGER_SINGLE, this.noise1, 1, ATTN_NORM);
	this.state = STATE_TOP;
	
	this.plat2LastMove = time;
	if(this.plat2Called == 1)
	{
		setthink(this, plat2_go_down);
		this.nextthink = this.ltime + 1.5;
		this.plat2Called = 0;
		this.plat2LastMove = 0; // allow immediate move
	}
	else if(!(this.spawnflags & START_AT_TOP))
	{
		setthink(this, plat2_go_down);
		this.nextthink = this.ltime + this.delay;
		this.plat2Called = 0;
	}
}

void plat2_hit_bottom(entity this)
{
	_sound(this, CH_TRIGGER_SINGLE, this.noise1, 1, ATTN_NORM);
	this.state = STATE_BOTTOM;

	this.plat2LastMove = time;
	if(this.plat2Called == 1)
	{
		setthink(this, plat2_go_up);
		this.nextthink = this.ltime + 1.5;
		this.plat2Called = 0;
		this.plat2LastMove = 0; // allow immediate move
	}
	else if(this.spawnflags & START_AT_TOP)
	{	
		setthink(this, plat2_go_up);
		this.nextthink = this.ltime + this.delay;
		this.plat2Called = 0;
	}
}

void plat2_go_down(entity this)
{
	_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
	this.state = STATE_DOWN;
	SUB_CalcMove(this, this.pos2, TSPEED_LINEAR, this.speed, plat2_hit_bottom);
}

void plat2_go_up(entity this)
{
	_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
	this.state = STATE_UP;
	SUB_CalcMove(this, this.pos1, TSPEED_LINEAR, this.speed, plat2_hit_top);
}

void plat2_use(entity this, entity actor, entity trigger) 
{
	if(this.state > 4)
		this.state = this.state - 10;	

	this.use = func_null;
}

void plat2_center_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
		
	if(toucher.health <= 0)
		return;

	// at this point, this is the trigger. this.enemy is the plat.
	// this changes this to be the plat, toucher is the player.

	entity trig = this.enemy;

	if((trig.plat2LastMove + 2) > time)
		return;

	if(trig.state > 4)		// disabled.
		return;
		
	if(trig.plat2GoTo > STATE_BOTTOM)
	{
		if(trig.plat2GoTime < time)
		{
			if(trig.plat2GoTo == STATE_UP)
				plat2_go_up(trig);		
			else
				plat2_go_down(trig);
				
			trig.plat2GoTo = 0;
		}
		return;
	}

	if(trig.state > STATE_BOTTOM)		// STATE_UP or STATE_DOWN
		return;

	vector platPosition = (trig.absmax + trig.absmin) * 0.5;

	int otherState;
	if(trig.state == STATE_TOP)
	{
		otherState = STATE_TOP;
		if( platPosition_z > toucher.origin_z )
			otherState = STATE_BOTTOM;
	}
	else
	{
		otherState = STATE_BOTTOM;
		if( (toucher.origin_z - platPosition_z) > trig.height)
			otherState = STATE_TOP;
	}	

	if(trig.state == otherState)
	{
		trig.plat2Called = 0;
		trig.plat2GoTime = time + 0.5;
	}
	else
	{
		trig.plat2GoTime = time + 0.1;
		trig.plat2Called = 1;
	}	

	if(trig.state == STATE_BOTTOM)
		trig.plat2GoTo = STATE_UP;
	else if(trig.state == STATE_TOP)
		trig.plat2GoTo = STATE_DOWN;
}

void plat2_crush(entity this, entity blocker)
{
	T_Damage(blocker, this, this, 1, DEATH_CRUSH.m_id);
	
	if(this.state == STATE_UP)
		plat2_go_down(this);
	else if(this.state == STATE_DOWN)
		plat2_go_up(this);
	else
		objerror(this, "plat2_crush: bad this.state\n");
}

// ==================================
// Common Plat Code
// ==================================

/*QUAKED func_new_plat (0 .5 .8) ? DN_N_WAIT PLT_TOGGLE ELEVATOR START_AT_TOP PLAT2 P2_BOTTOM

--------------
DN_N_WAIT is a plat that starts at the top and when triggered, goes down, waits, then comes back up.
health - number of seconds to wait (default 5)

--------------
PLT_TOGGLE is a plat that will change between the top and bottom each time it is triggered.

--------------
ELEVATOR is an elevator plat. You can have as many levels as you want but they must be all the same distance away. Use elevator button entity as the trigger. 
  cnt is the number of floors
  height is the distance between floors

START_AT_TOP is an optional flag for elevators. It just tells the elevator that it's position is the top floor. (Default is the bottom floor) USE THIS ONLY WITH ELEVATORS!

--------------
PLAT2 is a fixed version of the original plat. If you want the plat to start at the bottom and move to the top on demand, use a negative height. That will tell Quake to lower the plat at spawn time. Always place this plat type in the top position when making the map. This will ensure correct lighting, hopefully. If a plat2 is the target of a trigger, it will be disabled until it has been triggered. Delay is the wait before the plat returns to original position.

If you don't want to bother figuring out the height, don't put a 
value in the height 

delay		default 3
speed		default 150
cnt			default 2

P2_BOTTOM is an optional switch to have an auto-sized plat2 start at the bottom.
--------------
Plats are always drawn in the extended position, so they will light correctly.

If the plat is the target of another trigger or button, it will start out disabled in the extended position until it is trigger, when it will lower and become a normal plat.

If the "height" key is set, that will determine the amount the plat moves, instead of being implicitly determined by the model's height.
Set "sounds" to one of the following:
1) base fast
2) chain slow
*/

spawnfunc(func_new_plat)
{
	if(!MP_ROGUE) { delete(this); return; }
	
	bool negativeHeight = false;
	
	if(!this.t_length)
		this.t_length = 80;
	if(!this.t_width)
		this.t_width = 10;

	if(this.sounds == 0)
		this.sounds = 2;
// FIX THIS TO LOAD A GENERIC PLAT SOUND

	if(this.sounds == 1)
	{
		precache_sound ("plats/plat1.wav");
		precache_sound ("plats/plat2.wav");
		this.noise = "plats/plat1.wav";
		this.noise1 = "plats/plat2.wav";
	}

	if(this.sounds == 2)
	{
		precache_sound ("plats/quake_medplat1.wav");
		precache_sound ("plats/quake_medplat2.wav");
		this.noise = "plats/quake_medplat1.wav";
		this.noise1 = "plats/quake_medplat2.wav";
	}

	this.mangle = this.angles;
	this.angles = '0 0 0';

	this.classname = "func_new_plat";
	if (!InitMovingBrushTrigger(this))
		return;
	this.effects |= EF_LOWPRECISION;
	setsize(this, this.mins , this.maxs);

	if(!this.speed)
		this.speed = 150;
		
// pos1 is the top position, pos2 is the bottom
	this.pos1 = this.origin;
	this.pos2 = this.origin;

	if(this.height < 0)
	{
		negativeHeight = true;
		this.height = 0 - this.height;
	}
	
	if(this.height)
		this.pos2_z = this.origin_z - this.height;
	else
	{
		negativeHeight = true;
		this.height = this.size_z - 8;
		this.pos2_z = this.origin_z - this.height;
	}
		
	if(this.spawnflags & DN_N_WAIT)
	{
		this.use = dn_and_wait_use;
		setblocked(this, dn_and_wait_crush);

		if(negativeHeight)
		{
			this.state = STATE_BOTTOM;
			setorigin(this, this.pos2);	
		}
		else
			this.state = STATE_TOP;

		if(!this.health)
			this.health = 5;
	}
	else if(this.spawnflags & PLT_TOGGLE)
	{
		this.use = toggle_use;
		setblocked(this, toggle_crush);
		if(negativeHeight)
		{	
			setorigin(this, this.pos2);
			this.state = STATE_BOTTOM;
		}
		else
		{
			this.state = STATE_TOP;
		}
	}
	else if(this.spawnflags & ELEVATOR)
	{
		this.elevatorOnFloor = 0;
		this.elevatorToFloor = 0;
		this.elevatorLastUse = 0;
		this.pos1 = this.origin;
		this.pos2 = this.origin;
		
		if(this.spawnflags & START_AT_TOP)
		{
			this.pos2_z = this.origin_z - (this.height * (this.cnt - 1));
			this.elevatorOnFloor = this.cnt - 1;
		}
		else
		{
			this.pos1_z = this.origin_z + (this.height * (this.cnt - 1));
			this.elevatorOnFloor = 0;
		}
		
		this.use = elvtr_use;
		setblocked(this, elvtr_crush);
	}
	else if(this.spawnflags & PLAT2)
	{
		plat2_spawn_inside_trigger(this);	// the "start moving" trigger	
		this.plat2Called = 0;
		this.plat2LastMove = 0;
		this.plat2GoTo = 0;
		this.plat2GoTime = 0;
		setblocked(this, plat2_crush);
		
		if(!this.delay)
			this.delay = 3;
			
		if(negativeHeight)
		{
			this.state = STATE_BOTTOM;
			// make sure START_AT_TOP isn't set. We need that...
			this.spawnflags = PLAT2;
			setorigin(this, this.pos2);	
		}
		else
		{
			// default position is top.
			this.spawnflags = this.spawnflags | START_AT_TOP;
			this.state = STATE_TOP;
		}
				
		if(this.targetname && this.targetname != "")
		{
			this.use = plat2_use;
			this.state = this.state + 10;
		}
	}
}

