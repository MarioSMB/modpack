#include "combat.qh"

void plat_center_touch(entity this, entity toucher);
void plat_outside_touch(entity this, entity toucher);
void plat_trigger_use(entity this, entity actor, entity trigger);
void plat_go_up(entity this);
void plat_go_down(entity this);
void plat_crush(entity this, entity blocker);
const int PLAT_LOW_TRIGGER = BIT(0);

void plat_spawn_inside_trigger(entity this)
{
	vector	tmin, tmax;

//
// middle trigger
//	
	entity trigger = spawn();
	settouch(trigger, plat_center_touch);
	trigger.movetype = MOVETYPE_NONE;
	trigger.solid = SOLID_TRIGGER;
	trigger.enemy = this;
	
	tmin = this.mins + '25 25 0';
	tmax = this.maxs - '25 25 -8';
	tmin_z = tmax_z -(this.pos1_z - this.pos2_z + 8);
	if(this.spawnflags & PLAT_LOW_TRIGGER)
		tmax_z = tmin_z + 8;
	
	if(this.size_x <= 50)
	{
		tmin_x =(this.mins_x + this.maxs_x) / 2;
		tmax_x = tmin_x + 1;
	}
	if(this.size_y <= 50)
	{
		tmin_y =(this.mins_y + this.maxs_y) / 2;
		tmax_y = tmin_y + 1;
	}
	
	setsize(trigger, tmin, tmax);
}

void plat_hit_top(entity this)
{
	_sound(this, CHAN_VOICE, this.noise1, 1, ATTN_NORM);
	this.state = STATE_TOP;
	setthink(this, plat_go_down);
	this.nextthink = this.ltime + 3;
}

void plat_hit_bottom(entity this)
{
	_sound(this, CHAN_VOICE, this.noise1, 1, ATTN_NORM);
	this.state = STATE_BOTTOM;
}

void plat_go_down(entity this)
{
	_sound(this, CHAN_VOICE, this.noise, 1, ATTN_NORM);
	this.state = STATE_DOWN;
	SUB_CalcMove(this, this.pos2, this.speed, plat_hit_bottom);
}

void plat_go_up(entity this)
{
	_sound(this, CHAN_VOICE, this.noise, 1, ATTN_NORM);
	this.state = STATE_UP;
	SUB_CalcMove(this, this.pos1, this.speed, plat_hit_top);
}

void plat_center_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
		
	if(toucher.health <= 0)
		return;

	if(this.enemy.state == STATE_BOTTOM)
		plat_go_up(this.enemy);
	else if(this.enemy.state == STATE_TOP)
		this.enemy.nextthink = this.enemy.ltime + 1;	// delay going down
}

void plat_outside_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;

	if(toucher.health <= 0)
		return;
		
//dprint("plat_outside_touch\n");
	if(this.enemy.state == STATE_TOP)
		plat_go_down(this.enemy);
}

void plat_trigger_use(entity this, entity actor, entity trigger)
{
	if(getthink(this))
		return;		// allready activated
	plat_go_down(this);
}


void plat_crush(entity this, entity blocker)
{
//dprint("plat_crush\n");

	T_Damage(blocker, this, this, 1);
	
	if(this.state == STATE_UP)
		plat_go_down(this);
	else if(this.state == STATE_DOWN)
		plat_go_up(this);
	else
		objerror(this, "plat_crush: bad this.state\n");
}

void plat_use(entity this, entity actor, entity trigger)
{
	this.use = func_null;
	if(this.state != STATE_UP)
		objerror(this, "plat_use: not in up state");
	plat_go_down(this);
}


/*QUAKED func_plat(0 .5 .8) ? PLAT_LOW_TRIGGER
speed	default 150

Plats are always drawn in the extended position, so they will light correctly.

If the plat is the target of another trigger or button, it will start out disabled in the extended position until it is trigger, when it will lower and become a normal plat.

If the "height" key is set, that will determine the amount the plat moves, instead of being implicitly determined by the model's height.
Set "sounds" to one of the following:
1) base fast
2) chain slow
*/


spawnfunc(func_plat)
{
	if(!this.t_length)
		this.t_length = 80;
	if(!this.t_width)
		this.t_width = 10;

	if(this.sounds == 0)
		this.sounds = 2;
// FIX THIS TO LOAD A GENERIC PLAT SOUND

	if(this.sounds == 1)
	{
		precache_sound("plats/plat1.wav");
		precache_sound("plats/plat2.wav");
		this.noise = "plats/plat1.wav";
		this.noise1 = "plats/plat2.wav";
	}

	if(this.sounds == 2)
	{
		precache_sound("plats/medplat1.wav");
		precache_sound("plats/medplat2.wav");
		this.noise = "plats/medplat1.wav";
		this.noise1 = "plats/medplat2.wav";
	}


	this.mangle = this.angles;
	this.angles = '0 0 0';

	this.classname = "plat";
	this.solid = SOLID_BSP;
	this.movetype = MOVETYPE_PUSH;
	setorigin(this, this.origin);	
	_setmodel(this, this.model);
	setsize(this, this.mins , this.maxs);

	setblocked(this, plat_crush);
	if(!this.speed)
		this.speed = 150;

// pos1 is the top position, pos2 is the bottom
	this.pos1 = this.origin;
	this.pos2 = this.origin;
	if(this.height)
		this.pos2_z = this.origin_z - this.height;
	else
		this.pos2_z = this.origin_z - this.size_z + 8;

	this.use = plat_trigger_use;

	plat_spawn_inside_trigger(this);	// the "start moving" trigger	

	if(this.targetname)
	{
		this.state = STATE_UP;
		this.use = plat_use;
	}
	else
	{
		setorigin(this, this.pos2);
		this.state = STATE_BOTTOM;
	}
}

//============================================================================

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
		_sound(this, CHAN_VOICE, this.noise, 1, ATTN_NORM);
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
	if(!this.target)
		objerror(this, "train_next: no next target");
	if(targ.wait)
		this.wait = targ.wait;
	else
		this.wait = 0;
	_sound(this, CHAN_VOICE, this.noise1, 1, ATTN_NORM);
	SUB_CalcMove(this, targ.origin - this.mins, this.speed, train_wait);
}

void func_train_find(entity this)
{
	entity	targ;

	targ = find(NULL, targetname, this.target);
	this.target = targ.target;
	setorigin(this, targ.origin - this.mins);
	if(!this.targetname)
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
	if(!this.target)
		objerror(this, "func_train without a target");
	if(!this.dmg)
		this.dmg = 2;

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
	this.solid = SOLID_BSP;
	this.movetype = MOVETYPE_PUSH;
	setblocked(this, train_blocked);
	this.use = train_use;
	this.classname = "train";

	_setmodel(this, this.model);
	setsize(this, this.mins , this.maxs);
	setorigin(this, this.origin);

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
	if(!this.target)
		objerror(this, "func_train without a target");

	this.cnt = 1;
	this.solid = SOLID_NOT;
	this.movetype = MOVETYPE_PUSH;
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

