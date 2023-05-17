#include "door2.qh"

void SUB_CalcAngleMove(entity this, vector destangle, float tspeed, void(entity) func)
{
	if(!tspeed)
		objerror(this, "No speed is defined!");
		
// set destdelta to the vector needed to move
	vector destdelta = destangle - this.angles;
	
// calculate length of vector
	float len = vlen(destdelta);
	
// divide by speed to get time to reach dest
	float traveltime = len / tspeed;

// set nextthink to trigger a think when dest is reached
	this.nextthink = this.ltime + traveltime;

// scale the destdelta vector by the time spent traveling to get velocity
	this.avelocity = destdelta * (1 / traveltime);
	
	this.think1 = func;
	this.finalangle = destangle;
	setthink(this, SUB_CalcAngleMoveDone);
}

/*
============
After rotating, set angle to exact final angle
============
*/
void SUB_CalcAngleMoveDone(entity this)
{
	this.angles = this.finalangle;
	this.avelocity = '0 0 0';
	this.nextthink = -1;
	if(this.think1)
		this.think1(this);
}

void door2_closed(entity this)
{
	_sound(this, CHAN_BODY, this.noise2, 1, ATTN_NORM);
	setorigin(this.enemy, this.enemy.origin);
}

void door2_close(entity this)
{
	if(this.pausetime > time)
	{
		setthink(this, door2_closing);
		this.nextthink = time + 0.1;
		return;
	}	
	this.enemy.solid = SOLID_BBOX;
	setorigin(this.enemy, this.enemy.origin);
	this.style = STATE_UP;
	this.owner.ltime = time;
	_sound(this.owner, CHAN_BODY, this.owner.noise1, 1, ATTN_NORM);
	SUB_CalcAngleMove(this.owner, this.owner.dest1, this.owner.speed, door2_closed);
}

void door2_closing(entity this)
{
	force_retouch = 2;
	setorigin(this, this.origin);
	setthink(this, door2_close);
	this.nextthink = time + 0.1;
}

void door2_opened(entity this)
{
	this.enemy.style = STATE_BOTTOM;

	setthink(this.enemy, door2_closing);
	_sound(this, CHAN_BODY, this.noise2, 1, ATTN_NORM);
	this.enemy.nextthink = time + this.wait;
}

void door2_open(entity this, entity actor, entity trigger)
{
	if(!RequirementsMet(this.enemy, trigger))
	{
		if(this.enemy.attack_finished < time)
		{
			_sound(this.enemy, CHAN_AUTO, "misc/locked.wav", 1, ATTN_NORM);
			sprint(trigger.owner, "locked\n");
			this.enemy.attack_finished = time + 1;
		}
		return;
	}
	if(this.enemy.style == STATE_TOP)
		_sound(this.enemy.owner, CHAN_BODY, this.enemy.owner.noise1, 1, ATTN_NORM);
	this.enemy.style = STATE_DOWN;
	this.enemy.solid = SOLID_TRIGGER;
	setorigin(this.enemy, this.enemy.origin);
	
	entity e = find(NULL, targetname, this.target);
	while(e)
	{
		e.ltime = time;
		SUB_CalcAngleMove(e, e.mangle, e.speed, door2_opened);
		e = find(e, targetname, e.target);
	}
}

void door2_open_action(entity this, entity targ)
{
	door2_open(this, NULL, targ);
}

void door2_touch(entity this, entity toucher)
{
// hmmm?
	if(toucher.solid == SOLID_SLIDEBOX)
		this.pausetime = time + 0.2;
}

void door2_init(entity this)
{
	entity t = find(NULL, target, this.targetname);
	this.enemy = t;
	t.owner = this;
}

void default_rotate(entity this)
{
	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_NOCLIP);
	_setmodel(this,this.model);
	setsize(this, this.mins, this.maxs);
	this.angles = '0 0 0'; // test?
}

spawnfunc(func_door2)
{
	if(!this.noise1)
		this.noise1 = "doors/door1.wav";
	if(!this.noise2)
		this.noise2 = "doors/close1.wav";
	precache_sound(this.noise1);
	precache_sound(this.noise2);
	this.classname = "func_door2";
	this.effects = EF_SELECTABLE;
	default_rotate(this);

	if(!this.speed)
		this.speed = 200;
	if(this.mangle == '0 0 0')
		this.mangle_y = 90;
	if(!this.wait)
		this.wait = 5;
	this.use = door2_open;
	this.dest1 = this.angles;
	setthink(this, door2_init);
	this.nextthink = time;
}

spawnfunc(rotate_object)
{
	if(!this.m_func)
		this.m_func = spawnfunc_func_door2;
	
	this.m_func(this);
}

spawnfunc(func_blockwall)
{
	precache_sound("misc/locked.wav");
	this.enemy = this;
	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_NONE);	// so it doesn't get pushed by anything
	this.solid = SOLID_BBOX;
	_setmodel(this, this.model);
	this.modelindex = 0;
	if(this.targetname)
		this.use = door2_open;
	else
	{
		this.action = door2_open_action;
		settouch(this, door2_touch);
	}
	
	if(!this.netname)
		this.netname = "door";
}
