#include "combat.qh"

const int DOOR_START_OPEN = BIT(0);
const int DOOR_DONT_LINK = BIT(2);
const int DOOR_GOLD_KEY = BIT(3);
const int DOOR_SILVER_KEY = BIT(4);
const int DOOR_TOGGLE = BIT(5);

/*

Doors are similar to buttons, but can spawn a fat trigger field around them
to open without a touch, and they link together to form simultanious
double/quad doors.
 
Door.owner is the master door.  If there is only one door, it points to itthis.
If multiple doors, all will point to a single one.

Door.enemy chains from the master door through all doors linked in the chain.

*/

/*
=============================================================================

THINK FUNCTIONS

=============================================================================
*/

void door_go_down(entity this);
void door_go_up(entity this);

void door_blocked(entity this, entity blocker)
{
	blocker.deathtype = "squish";
	T_Damage(blocker, this, this.goalentity, this.dmg);
	
// if a door has a negative wait, it would never come back if blocked,
// so let it just squash the object to death real fast
	if(this.wait >= 0)
	{
		if(this.state == STATE_DOWN)
			door_go_up(this);
		else
			door_go_down(this);
	}
}


void door_hit_top(entity this)
{
	_sound(this, CHAN_VOICE, this.noise1, 1, ATTN_NORM);
	this.state = STATE_TOP;
	if(this.spawnflags & DOOR_TOGGLE)
		return;		// don't come down automatically
	setthink(this, door_go_down);
	this.nextthink = this.ltime + this.wait;
}

void door_hit_bottom(entity this)
{
	_sound(this, CHAN_VOICE, this.noise1, 1, ATTN_NORM);
	this.state = STATE_BOTTOM;
}

void door_go_down(entity this)
{
	_sound(this, CHAN_VOICE, this.noise2, 1, ATTN_NORM);
	if(this.max_health)
	{
		this.takedamage = DAMAGE_YES;
		this.health = this.max_health;
	}
	
	this.state = STATE_DOWN;
	SUB_CalcMove(this, this.pos1, this.speed, door_hit_bottom);
}

void door_go_up(entity this)
{
	if(this.state == STATE_UP)
		return;		// allready going up

	if(this.state == STATE_TOP)
	{	// reset top wait time
		this.nextthink = this.ltime + this.wait;
		return;
	}
	
	_sound(this, CHAN_VOICE, this.noise2, 1, ATTN_NORM);
	this.state = STATE_UP;
	SUB_CalcMove(this, this.pos2, this.speed, door_hit_top);

	SUB_UseTargets(this, NULL, NULL);
}


/*
=============================================================================

ACTIVATION FUNCTIONS

=============================================================================
*/

void door_fire(entity this, entity actor)
{
	if(this.owner != this)
		objerror(this, "door_fire: this.owner != this");

// play use key sound

	if(this.items)
		_sound(this, CHAN_VOICE, this.noise4, 1, ATTN_NORM);

	this.message = string_null;		// no more message

	if (this.spawnflags & DOOR_TOGGLE)
	{
		if (this.state == STATE_UP || this.state == STATE_TOP)
		{
			entity e = this;
			do {
				door_go_down(e);
				e = e.enemy;
			} while ((e != this) && (e != NULL));
			return;
		}
	}
	
// trigger all paired doors
	entity e = this;
	do {
		e.goalentity = actor; // who fired us
		door_go_up(e);
		e = e.enemy;
	} while ((e != this) && (e != NULL));
}


void door_use(entity this, entity actor, entity trigger)
{
	this.message = "";			// door message are for touch only
	this.owner.message = "";	
	this.enemy.message = "";
	door_fire(this.owner, actor);
}


void door_trigger_touch(entity this, entity toucher)
{
	if(toucher.health <= 0)
		return;

	if(time < this.attack_finished)
		return;
	this.attack_finished = time + 1;

	door_use(this.owner, toucher, NULL);
}


void door_killed(entity this, entity attacker)
{
	this.owner.health = this.owner.max_health;
	this.owner.takedamage = DAMAGE_NO;	// wil be reset upon return
	door_use(this.owner, attacker, NULL);
}


/*
================
door_touch

Prints messages and opens key doors
================
*/
void door_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(this.owner.attack_finished > time)
		return;

	this.owner.attack_finished = time + 2;

	if(this.owner.message != "")
	{
		centerprint(toucher, this.owner.message);
		_sound(toucher, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
	}
	
// key door stuff
	if(!this.items)
		return;

// FIXME: blink key on player's status bar
	if((this.items & toucher.items) != this.items )
	{
		if(this.owner.items == IT_KEY1)
		{
			if(world.worldtype == 2)
			{
				centerprint(toucher, "You need the silver keycard");
				_sound(this, CHAN_VOICE, this.noise3, 1, ATTN_NORM);
			}
			else if(world.worldtype == 1)
			{
				centerprint(toucher, "You need the silver runekey");
				_sound(this, CHAN_VOICE, this.noise3, 1, ATTN_NORM);
			}
			else if(world.worldtype == 0)
			{
				centerprint(toucher, "You need the silver key");
				_sound(this, CHAN_VOICE, this.noise3, 1, ATTN_NORM);
			}
		}
		else
		{
			if(world.worldtype == 2)
			{
				centerprint(toucher, "You need the gold keycard");
				_sound(this, CHAN_VOICE, this.noise3, 1, ATTN_NORM);
			}
			else if(world.worldtype == 1)
			{
				centerprint(toucher, "You need the gold runekey");
				_sound(this, CHAN_VOICE, this.noise3, 1, ATTN_NORM);			
			}
			else if(world.worldtype == 0)
			{
				centerprint(toucher, "You need the gold key");
				_sound(this, CHAN_VOICE, this.noise3, 1, ATTN_NORM);
			}
		}
		return;
	}

	toucher.items &= ~this.items;
	settouch(this, func_null);
	if(this.enemy)
		settouch(this.enemy, func_null); // get paired door
	door_use(this, NULL, toucher);
}

/*
=============================================================================

SPAWNING FUNCTIONS

=============================================================================
*/


entity spawn_field(entity this, vector fmins, vector fmaxs)
{
	entity trigger = spawn();
	set_movetype(trigger, MOVETYPE_NONE);
	trigger.solid = SOLID_TRIGGER;
	trigger.owner = this;
	settouch(trigger, door_trigger_touch);

	vector t1 = fmins;
	vector t2 = fmaxs;
	setsize(trigger, t1 - '60 60 8', t2 + '60 60 8');
	return(trigger);
}


/*
=============
LinkDoors


=============
*/
void LinkDoors(entity this)
{
	if(this.enemy)
		return;		// already linked by another door
	if(this.spawnflags & BIT(2))
	{
		this.owner = this.enemy = this;
		return;		// don't want to link this door
	}

	vector cmins = this.mins;
	vector cmaxs = this.maxs;
	
	entity starte = this;
	entity t = this;

	entity e = this;
	
	do
	{
		e.owner = starte;			// master door

		if(e.health)
			starte.health = e.health;
		if(e.targetname)
			starte.targetname = e.targetname;
		if(e.message != "")
			starte.message = e.message;

		t = find(t, classname, e.classname);	
		if(!t)
		{
			e.enemy = starte;		// make the chain a loop

		// shootable, fired, or key doors just needed the owner/enemy links,
		// they don't spawn a field
	
			if(e.owner.health)
				return;
			if(e.owner.targetname)
				return;
			if(e.owner.items)
				return;

			e.owner.owner.trigger_field = spawn_field(e.owner, cmins, cmaxs);

			return;
		}

		if(EntitiesTouching(e,t))
		{
			if(t.enemy)
				objerror(this, "cross connected doors");
			
			e.enemy = t;
			e = t;

			if(t.mins_x < cmins_x)
				cmins_x = t.mins_x;
			if(t.mins_y < cmins_y)
				cmins_y = t.mins_y;
			if(t.mins_z < cmins_z)
				cmins_z = t.mins_z;
			if(t.maxs_x > cmaxs_x)
				cmaxs_x = t.maxs_x;
			if(t.maxs_y > cmaxs_y)
				cmaxs_y = t.maxs_y;
			if(t.maxs_z > cmaxs_z)
				cmaxs_z = t.maxs_z;
		}
	} while(1);

}


/*QUAKED func_door(0 .5 .8) ? START_OPEN x DOOR_DONT_LINK GOLD_KEY SILVER_KEY TOGGLE
if two doors touch, they are assumed to be connected and operate as a unit.

TOGGLE causes the door to wait in both the start and end states for a trigger event.

START_OPEN causes the door to move to its destination when spawned, and operate in reverse.  It is used to temporarily or permanently close off an area when triggered(not usefull for touch or takedamage doors).

Key doors are allways wait -1.

"message"	is printed when the door is touched if it is a trigger door and it hasn't been fired yet
"angle"		determines the opening direction
"targetname" if set, no touch field will be spawned and a remote button or trigger field activates the door.
"health"	if set, door must be shot open
"speed"		movement speed(100 default)
"wait"		wait before returning(3 default, -1 = never return)
"lip"		lip remaining at end of move(8 default)
"dmg"		damage to inflict when blocked(2 default)
"sounds"
0)	no sound
1)	stone
2)	base
3)	stone chain
4)	screechy metal
*/

spawnfunc(func_door)
{

	if(world.worldtype == 0)
	{
		precache_sound("doors/medtry.wav");
		precache_sound("doors/meduse.wav");
		this.noise3 = "doors/medtry.wav";
		this.noise4 = "doors/meduse.wav";
	}
	else if(world.worldtype == 1)
	{
		precache_sound("doors/runetry.wav");
		precache_sound("doors/runeuse.wav");
		this.noise3 = "doors/runetry.wav";
		this.noise4 = "doors/runeuse.wav";
	}
	else if(world.worldtype == 2)
	{
		precache_sound("doors/basetry.wav");
		precache_sound("doors/baseuse.wav");
		this.noise3 = "doors/basetry.wav";
		this.noise4 = "doors/baseuse.wav";
	}
	else
	{
		dprint("no worldtype set!\n");
	}
	if(this.sounds == 0)
	{
		precache_sound("misc/null.wav");
		precache_sound("misc/null.wav");
		this.noise1 = "misc/null.wav";
		this.noise2 = "misc/null.wav";
	}
	if(this.sounds == 1)
	{
		precache_sound("doors/drclos4.wav");
		precache_sound("doors/doormv1.wav");
		this.noise1 = "doors/drclos4.wav";
		this.noise2 = "doors/doormv1.wav";
	}
	if(this.sounds == 2)
	{
		precache_sound("doors/hydro1.wav");
		precache_sound("doors/hydro2.wav");
		this.noise2 = "doors/hydro1.wav";
		this.noise1 = "doors/hydro2.wav";
	}
	if(this.sounds == 3)
	{
		precache_sound("doors/stndr1.wav");
		precache_sound("doors/stndr2.wav");
		this.noise2 = "doors/stndr1.wav";
		this.noise1 = "doors/stndr2.wav";
	}
	if(this.sounds == 4)
	{
		precache_sound("doors/ddoor1.wav");
		precache_sound("doors/ddoor2.wav");
		this.noise1 = "doors/ddoor2.wav";
		this.noise2 = "doors/ddoor1.wav";
	}

	SetMovedir(this);

	this.max_health = this.health;
	this.solid = SOLID_BSP;
	set_movetype(this, MOVETYPE_PUSH);
	setorigin(this, this.origin);	
	_setmodel(this, this.model);
	this.classname = "door";

	setblocked(this, door_blocked);
	this.use = door_use;
	
	if(this.spawnflags & DOOR_SILVER_KEY)
		this.items = IT_KEY1;
	if(this.spawnflags & DOOR_GOLD_KEY)
		this.items = IT_KEY2;
	
	if(!this.speed)
		this.speed = 100;
	if(!this.wait)
		this.wait = 3;
	if(!this.lip)
		this.lip = 8;
	if(!this.dmg)
		this.dmg = 2;

	this.pos1 = this.origin;
	this.pos2 = this.pos1 + this.movedir*(fabs(this.movedir*this.size) - this.lip);

// DOOR_START_OPEN is to allow an entity to be lighted in the closed position
// but spawn in the open position
	if(this.spawnflags & DOOR_START_OPEN)
	{
		setorigin(this, this.pos2);
		this.pos2 = this.pos1;
		this.pos1 = this.origin;
	}

	this.state = STATE_BOTTOM;

	if(this.health)
	{
		this.takedamage = DAMAGE_YES;
		this.th_die = door_killed;
	}
	
	if(this.items)
		this.wait = -1;
		
	settouch(this, door_touch);

// LinkDoors can't be done until all of the doors have been spawned, so
// the sizes can be detected properly.
	setthink(this, LinkDoors);
	this.nextthink = this.ltime + 0.1;
}

/*
=============================================================================

SECRET DOORS

=============================================================================
*/

void fd_secret_move1(entity this);
void fd_secret_move2(entity this);
void fd_secret_move3(entity this);
void fd_secret_move4(entity this);
void fd_secret_move5(entity this);
void fd_secret_move6(entity this);
void fd_secret_done(entity this);

const int SECRET_OPEN_ONCE = BIT(0);		// stays open
const int SECRET_1ST_LEFT = BIT(1);		// 1st move is left of arrow
const int SECRET_1ST_DOWN = BIT(2);		// 1st move is down from arrow
const int SECRET_NO_SHOOT = BIT(3);		// only opened by trigger
const int SECRET_YES_SHOOT = BIT(4);	// shootable even if targeted


void fd_secret_use(entity this, entity actor, entity trigger)
{
	this.health = 10000;

	// exit if still moving around...
	if(this.origin != this.oldorigin)
		return;
	
	this.message = string_null;		// no more message

	SUB_UseTargets(this, actor, trigger);				// fire all targets / killtargets
	
	if(!(this.spawnflags & SECRET_NO_SHOOT))
	{
		this.th_pain = func_null;
		this.takedamage = DAMAGE_NO;
	}
	this.velocity = '0 0 0';

	// Make a sound, wait a little...
	
	_sound(this, CHAN_VOICE, this.noise1, 1, ATTN_NORM);
	this.nextthink = this.ltime + 0.1;

	int temp = 1 - (this.spawnflags & SECRET_1ST_LEFT);	// 1 or -1
	makevectors(this.mangle);
	
	if(!this.t_width)
	{
		if(this.spawnflags & SECRET_1ST_DOWN)
			this.t_width = fabs(v_up * this.size);
		else
			this.t_width = fabs(v_right * this.size);
	}
		
	if(!this.t_length)
		this.t_length = fabs(v_forward * this.size);

	if(this.spawnflags & SECRET_1ST_DOWN)
		this.dest1 = this.origin - v_up * this.t_width;
	else
		this.dest1 = this.origin + v_right *(this.t_width * temp);
		
	this.dest2 = this.dest1 + v_forward * this.t_length;
	SUB_CalcMove(this, this.dest1, this.speed, fd_secret_move1);
	_sound(this, CHAN_VOICE, this.noise2, 1, ATTN_NORM);
}

void fd_secret_pain(entity this, entity attacker, float damage)
{
	fd_secret_use(this, attacker, NULL);
}

void fd_secret_die(entity this, entity attacker)
{
	fd_secret_use(this, attacker, NULL);
}

// Wait after first movement...
void fd_secret_move1(entity this) 
{
	this.nextthink = this.ltime + 1.0;
	setthink(this, fd_secret_move2);
	_sound(this, CHAN_VOICE, this.noise3, 1, ATTN_NORM);
}

// Start moving sideways w/sound...
void fd_secret_move2(entity this)
{
	_sound(this, CHAN_VOICE, this.noise2, 1, ATTN_NORM);
	SUB_CalcMove(this, this.dest2, this.speed, fd_secret_move3);
}

// Wait here until time to go back...
void fd_secret_move3(entity this)
{
	_sound(this, CHAN_VOICE, this.noise3, 1, ATTN_NORM);
	if(!(this.spawnflags & SECRET_OPEN_ONCE))
	{
		this.nextthink = this.ltime + this.wait;
		setthink(this, fd_secret_move4);
	}
}

// Move backward...
void fd_secret_move4(entity this)
{
	_sound(this, CHAN_VOICE, this.noise2, 1, ATTN_NORM);
	SUB_CalcMove(this, this.dest1, this.speed, fd_secret_move5);		
}

// Wait 1 second...
void fd_secret_move5(entity this) 
{
	this.nextthink = this.ltime + 1.0;
	setthink(this, fd_secret_move6);
	_sound(this, CHAN_VOICE, this.noise3, 1, ATTN_NORM);
}

void fd_secret_move6(entity this)
{
	_sound(this, CHAN_VOICE, this.noise2, 1, ATTN_NORM);
	SUB_CalcMove(this, this.oldorigin, this.speed, fd_secret_done);
}

void fd_secret_done(entity this)
{
	if(!this.targetname || this.spawnflags&SECRET_YES_SHOOT)
	{
		this.health = 10000;
		this.takedamage = DAMAGE_YES;
		this.th_pain = fd_secret_pain;
		this.th_die = fd_secret_die;
	}
	_sound(this, CHAN_VOICE, this.noise3, 1, ATTN_NORM);
}

void secret_blocked(entity this, entity blocker)
{
	if(time < this.attack_finished)
		return;
	this.attack_finished = time + 0.5;
	blocker.deathtype = "squish";
	T_Damage(blocker, this, this, this.dmg);
}

/*
================
secret_touch

Prints messages
================
*/
void secret_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(this.attack_finished > time)
		return;

	this.attack_finished = time + 2;
	
	if(this.message)
	{
		centerprint(toucher, this.message);
		_sound(toucher, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
	}
}


/*QUAKED func_door_secret(0 .5 .8) ? open_once 1st_left 1st_down no_shoot always_shoot
Basic secret door. Slides back, then to the side. Angle determines direction.
wait  = # of seconds before coming back
1st_left = 1st move is left of arrow
1st_down = 1st move is down from arrow
always_shoot = even if targeted, keep shootable
t_width = override WIDTH to move back(or height if going down)
t_length = override LENGTH to move sideways
"dmg"		damage to inflict when blocked(2 default)

If a secret door has a targetname, it will only be opened by it's botton or trigger, not by damage.
"sounds"
1) medieval
2) metal
3) base
*/

spawnfunc(func_door_secret)
{
	if(this.sounds == 0)
		this.sounds = 3;
	if(this.sounds == 1)
	{
		precache_sound("doors/latch2.wav");
		precache_sound("doors/winch2.wav");
		precache_sound("doors/drclos4.wav");
		this.noise1 = "doors/latch2.wav";
		this.noise2 = "doors/winch2.wav";
		this.noise3 = "doors/drclos4.wav";
	}
	if(this.sounds == 2)
	{
		precache_sound("doors/airdoor1.wav");
		precache_sound("doors/airdoor2.wav");
		this.noise2 = "doors/airdoor1.wav";
		this.noise1 = "doors/airdoor2.wav";
		this.noise3 = "doors/airdoor2.wav";
	}
	if(this.sounds == 3)
	{
		precache_sound("doors/basesec1.wav");
		precache_sound("doors/basesec2.wav");
		this.noise2 = "doors/basesec1.wav";
		this.noise1 = "doors/basesec2.wav";
		this.noise3 = "doors/basesec2.wav";
	}

	if(!this.dmg)
		this.dmg = 2;
		
	// Magic formula...
	this.mangle = this.angles;
	this.angles = '0 0 0';
	this.solid = SOLID_BSP;
	set_movetype(this, MOVETYPE_PUSH);
	this.classname = "door";
	_setmodel(this, this.model);
	setorigin(this, this.origin);	
	
	settouch(this, secret_touch);
	setblocked(this, secret_blocked);
	this.speed = 50;
	this.use = fd_secret_use;
	if( !this.targetname || this.spawnflags&SECRET_YES_SHOOT)
	{
		this.health = 10000;
		this.takedamage = DAMAGE_YES;
		this.th_pain = fd_secret_pain;
	}
	this.oldorigin = this.origin;
	if(!this.wait)
		this.wait = 5;		// 5 seconds before closing
}
