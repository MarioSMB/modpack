/* Rotate QuickC program
	 By Jim Dose'  10/17/96
	 Copyright (c)1996 Hipnotic Interactive, Inc.
	 All rights reserved.
	 Distributed (unsupported) on 3.12.97
*/

const int STATE_ACTIVE      = 0;
const int STATE_INACTIVE    = 1;
const int STATE_SPEEDINGUP  = 2;
const int STATE_SLOWINGDOWN = 3;

const int STATE_CLOSED   = 4;
const int STATE_OPEN     = 5;
const int STATE_OPENING  = 6;
const int STATE_CLOSING  = 7;

const int STATE_WAIT = 0;
const int STATE_MOVE = 1;
const int STATE_STOP = 2;
const int STATE_FIND = 3;
const int STATE_NEXT = 4;

const int OBJECT_ROTATE 	= 0;
const int OBJECT_MOVEWALL 	= 1;
const int OBJECT_SETORIGIN 	= 2;

const int TOGGLE   = BIT(0);
const int START_ON = BIT(1);

const int ROTATION 		= BIT(0);
const int ANGLES 		= BIT(1);
const int STOP 			= BIT(2);
const int NO_ROTATE 	= BIT(3);
const int DAMAGE   		= BIT(4);
const int MOVETIME 		= BIT(5);
const int SET_DAMAGE 	= BIT(6);

const int VISIBLE 		= BIT(0);
const int TOUCH 		= BIT(1);
const int NONBLOCKING 	= BIT(2);

const int STAYOPEN = BIT(0);

/*QUAKED info_rotate (0 0.5 0) (-4 -4 -4) (4 4 4)
Used as the point of rotation for rotatable objects.
*/
spawnfunc(info_rotate)
{
// remove self after a little while, to make sure that entities that
// have targeted it have had a chance to spawn
	this.nextthink = time + 2;
	setthink(this, SUB_Remove);
}

void RotateTargets(entity this)
{
	vector vx, vy, vz;
	vector org;

	makevectors(this.angles);

	FOREACH_ENTITY_STRING(targetname, this.target,
	{
		if(it.rotate_type == OBJECT_SETORIGIN)
		{
			org = it.oldorigin;
			vx = (v_forward * org.x);
			vy = (v_right * org.y);
			vy = vy * -1;
			vz = (v_up * org.z);
			it.neworigin = vx + vy + vz;
			setorigin(it, it.neworigin + this.origin);
		}
		else if(it.rotate_type == OBJECT_ROTATE)
		{
			it.angles = this.angles;
			org = it.oldorigin;
			vx = (v_forward * org.x);
			vy = (v_right * org.y);
			vy = vy * -1;
			vz = (v_up * org.z);
			it.neworigin = vx + vy + vz;
			setorigin(it, it.neworigin + this.origin);
		}
		else
		{
			org = it.oldorigin;
			vx = (v_forward * org.x);
			vy = (v_right * org.y);
			vy = vy * -1;
			vz = (v_up * org.z);
			it.neworigin = vx + vy + vz;
			it.neworigin = this.origin - this.oldorigin + (it.neworigin - it.oldorigin);
			it.velocity = (it.neworigin - it.origin) * 25;
		}
	});
}

void RotateTargetsFinal(entity this)
{
	FOREACH_ENTITY_STRING(targetname, this.target,
	{
		it.velocity = '0 0 0';
		if(it.rotate_type == OBJECT_ROTATE)
			it.angles = this.angles;
	});
}

void SetTargetOrigin(entity this)
{
	FOREACH_ENTITY_STRING(targetname, this.target,
	{
		if(it.rotate_type == OBJECT_MOVEWALL)
			setorigin(it, this.origin - this.oldorigin + (it.neworigin - it.oldorigin));
		else
			setorigin(it, it.neworigin + this.origin);
	});
}

void LinkRotateTargets(entity this)
{
	this.oldorigin = this.origin;
	FOREACH_ENTITY_STRING(targetname, this.target,
	{
		if(it.classname == "rotate_object")
		{
			it.rotate_type = OBJECT_ROTATE;
			it.oldorigin = it.origin - this.oldorigin;
			it.neworigin = it.origin - this.oldorigin;
			it.owner = this;
		}
		else if(it.classname == "func_movewall")
		{
			it.rotate_type = OBJECT_MOVEWALL;
			vector tempvec = ( it.absmin + it.absmax ) * 0.5;
			it.oldorigin = tempvec - this.oldorigin;
			it.neworigin = it.oldorigin;
			it.owner = this;
		}
		else
		{
			it.rotate_type = OBJECT_SETORIGIN;
			it.oldorigin = it.origin - this.oldorigin;
			it.neworigin = it.origin - this.oldorigin;
		}
	});
}

void SetDamageOnTargets(entity this, float amount)
{
	FOREACH_ENTITY_STRING(targetname, this.target,
	{
		if(it.classname == "trigger_hurt")
			hurt_setdamage(it, amount);
		else if(it.classname == "func_movewall")
			it.dmg = amount;
	});
}


//************************************************
//
// Simple continual rotatation
//
//************************************************

void rotate_entity_think(entity this)
{
	float t = time - this.ltime;
	this.ltime = time;

	if(this.state == STATE_SPEEDINGUP)
	{
		this.count = this.count + this.cnt * t;
		if( this.count > 1 )
			this.count = 1;

		// get rate of rotation
		t = t * this.count;
	}
	else if( this.state == STATE_SLOWINGDOWN )
	{
		this.count = this.count - this.cnt * t;
		if( this.count < 0 )
		{
			RotateTargetsFinal(this);
			this.state = STATE_INACTIVE;
			setthink(this, func_null);
			this.nextthink = 0;
			return;
		}

		// get rate of rotation
		t = t * this.count;
	}

	this.angles = this.angles + (this.rotate * t);
	this.angles = SUB_NormalizeAngles(this.angles);
	RotateTargets(this);
	this.nextthink = time + 0.02;
}

void rotate_entity_use(entity this, entity actor, entity trigger)
{
	// change to alternate textures
	this.frame = 1 - this.frame;

	if(this.state == STATE_ACTIVE)
	{
		if(this.spawnflags & TOGGLE)
		{
			if(this.speed)
			{
				this.count = 1;
				this.state = STATE_SLOWINGDOWN;
			}
			else
			{
				this.state = STATE_INACTIVE;
				setthink(this, func_null);
				this.nextthink = 0;
			}
		}
	}
	else if(this.state == STATE_INACTIVE)
	{
		setthink(this, rotate_entity_think);
		this.nextthink = time + 0.02;
		this.ltime = time;
		if(this.speed)
		{
			this.count = 0;
			this.state = STATE_SPEEDINGUP;
		}
		else
			this.state = STATE_ACTIVE;
	}
	else if(this.state == STATE_SPEEDINGUP)
	{
		if(this.spawnflags & TOGGLE)
			this.state = STATE_SLOWINGDOWN;
	}
	else
		this.state = STATE_SPEEDINGUP;
}

void rotate_entity_firstthink(entity this)
{
	LinkRotateTargets(this);
	if(this.spawnflags & START_ON)
	{
		this.state = STATE_ACTIVE;
		setthink(this, rotate_entity_think);
		this.nextthink = time + 0.02;
		this.ltime = time;
	}
	else
	{
		this.state = STATE_INACTIVE;
		setthink(this, func_null);
		this.nextthink = 0;
	}
	this.use = rotate_entity_use;
}

/*QUAKED func_rotate_entity (0 .5 .8) (-8 -8 -8) (8 8 8) TOGGLE START_ON
Creates an entity that continually rotates.  Can be toggled on and
off if targeted.

TOGGLE = allows the rotation to be toggled on/off

START_ON = wether the entity is spinning when spawned.  If TOGGLE is 0, entity can be turned on, but not off.

If "deathtype" is set with a string, this is the message that will appear when a player is killed by the train.

"rotate" is the rate to rotate.
"target" is the center of rotation.
"speed"  is how long the entity takes to go from standing still to full speed and vice-versa.
*/

spawnfunc(func_rotate_entity)
{
	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_NONE);

	_setmodel(this, this.model);
	setsize(this, this.mins, this.maxs);

	if(this.speed != 0)
		this.cnt = 1 / this.speed;

	setthink(this, rotate_entity_firstthink);
	this.nextthink = time + 0.1;
	this.ltime = time;
}

//************************************************
//
// Train with rotation functionality
//
//************************************************

/*QUAKED path_rotate (0.5 0.3 0) (-8 -8 -8) (8 8 8) ROTATION ANGLES STOP NO_ROTATE DAMAGE MOVETIME SET_DAMAGE
 Path for rotate_train.

 ROTATION tells train to rotate at rate specified by "rotate".  Use '0 0 0' to stop rotation.

 ANGLES tells train to rotate to the angles specified by "angles" while traveling to this path_rotate.  Use values < 0 or > 360 to guarantee that it turns in a certain direction.  Having this flag set automatically clears any rotation.

 STOP tells the train to stop and wait to be retriggered.

 NO_ROTATE tells the train to stop rotating when waiting to be triggered.

 DAMAGE tells the train to cause damage based on "dmg".

 MOVETIME tells the train to interpret "speed" as the length of time to take moving from one corner to another.

 SET_DAMAGE tells the train to set all targets damage to "dmg"

 "noise" contains the name of the sound to play when train stops.
 "noise1" contains the name of the sound to play when train moves.
 "event" is a target to trigger when train arrives at path_rotate.
*/
spawnfunc(path_rotate)
{
	if(this.noise)
		precache_sound(this.noise);
	if(this.noise1)
		precache_sound(this.noise1);
}


void rotate_train_next(entity this);
void rotate_train_find(entity this);

void rotate_train_think(entity this)
{
	float t = time - this.ltime;
	this.ltime = time;

	if(this.endtime && time >= this.endtime)
	{
		this.endtime = 0;
		if(this.state == STATE_MOVE)
		{
			setorigin(this, this.finaldest);
			this.velocity = '0 0 0';
		}

		if(this.think1)
			this.think1(this);
	}
	else
	{
		float timeelapsed = (time - this.cnt) * this.duration;
		if(timeelapsed > 1)
			timeelapsed = 1;
		setorigin( this, this.dest1 + ( this.dest2 * timeelapsed ) );
	}

	this.angles = this.angles + (this.rotate * t);
	this.angles = SUB_NormalizeAngles(this.angles);
	RotateTargets(this);

	this.nextthink = time + 0.02;
}

void rotate_train_use(entity this, entity actor, entity trigger)
{
	if(this.think1 != rotate_train_find)
	{
		if(this.velocity != '0 0 0')
			return;		// already activated
		if(this.think1)
			this.think1(this);
	}
}

void rotate_train_wait(entity this)
{
	this.state = STATE_WAIT;

	if(this.goalentity.noise)
		_sound(this, CHAN_VOICE, this.goalentity.noise, 1, ATTN_NORM);
	else
		_sound(this, CHAN_VOICE, this.noise, 1, ATTN_NORM);
	if(this.goalentity.spawnflags & ANGLES)
	{
		this.rotate = '0 0 0';
		this.angles = this.finalangle;
	}
	if(this.goalentity.spawnflags & NO_ROTATE)
		this.rotate = '0 0 0';
	this.endtime = this.ltime + this.goalentity.wait;
	this.think1 = rotate_train_next;
}

void rotate_train_stop(entity this)
{
	this.state = STATE_STOP;

	if(this.goalentity.noise)
		_sound(this, CHAN_VOICE, this.goalentity.noise, 1, ATTN_NORM);
	else
		_sound(this, CHAN_VOICE, this.noise, 1, ATTN_NORM);
	if( this.goalentity.spawnflags & ANGLES )
	{
		this.rotate = '0 0 0';
		this.angles = this.finalangle;
	}
	if( this.goalentity.spawnflags & NO_ROTATE )
		this.rotate = '0 0 0';

	this.dmg = 0;
	this.think1 = rotate_train_next;
}

void rotate_train_next(entity this)
{
	this.state = STATE_NEXT;

	entity current = this.goalentity;
	entity targ = NULL;
	FOREACH_ENTITY_STRING(targetname, this.path,
	{
		if(it.classname == "path_rotate")
		{
			targ = it;
			break;
		}
	});

	if(!targ)
		objerror(this, "Next target is not path_rotate");

	if(this.goalentity.noise1)
		this.noise1 = this.goalentity.noise1;

	_sound(this, CHAN_VOICE, this.noise1, 1, ATTN_NORM);

	this.goalentity = targ;
	this.path = targ.target;
	if(!this.path )
		objerror(this, "rotate_train_next: no next target");

	if(targ.spawnflags & STOP)
		this.think1 = rotate_train_stop;
	else if(targ.wait)
		this.think1 = rotate_train_wait;
	else
		this.think1 = rotate_train_next;

	if(current.event)
	{
		// Trigger any events that should happen at the corner.
		string temp = this.target;
		this.target = current.event;
		this.message = current.message;
		SUB_UseTargets(this, NULL, NULL);
		this.target = temp;
		this.message = string_null;
	}

	if(current.spawnflags & ANGLES)
	{
		this.rotate = '0 0 0';
		this.angles = this.finalangle;
	}

	if(current.spawnflags & ROTATION)
		this.rotate = current.rotate;

	if(current.spawnflags & DAMAGE)
		this.dmg = current.dmg;

	if(current.spawnflags & SET_DAMAGE)
		SetDamageOnTargets(this, current.dmg);

	if(current.speed == -1)
	{
		// Warp to the next path_corner
		setorigin(this, targ.origin);
		this.endtime = this.ltime + 0.01;
		SetTargetOrigin(this);

		if(targ.spawnflags & ANGLES)
			this.angles = targ.angles;

		this.duration = 1;         // 1 / duration
		this.cnt = time;           // start time
		this.dest2 = '0 0 0';      // delta
		this.dest1 = this.origin;  // original position
		this.finaldest = this.origin;
	}
	else
	{
		this.state = STATE_MOVE;

		this.finaldest = targ.origin;
		if(this.finaldest == this.origin)
		{
			this.velocity = '0 0 0';
			this.endtime = this.ltime + 0.1;

			this.duration = 1;        // 1 / duration
			this.cnt = time;          // start time
			this.dest2 = '0 0 0';     // delta
			this.dest1 = this.origin; // original position
			this.finaldest = this.origin;
			return;
		}
		// set destdelta to the vector needed to move
		vector vdestdelta = this.finaldest - this.origin;

		// calculate length of vector
		float len = vlen (vdestdelta);
		float traveltime;

		if(current.spawnflags & MOVETIME)
			traveltime = current.speed;
		else
		{
			// check if there's a speed change
			if(current.speed > 0)
				this.speed = current.speed;

			if(!this.speed)
				objerror(this, "No speed is defined!");

			// divide by speed to get time to reach dest
			traveltime = len / this.speed;
		}

		if(traveltime < 0.1)
		{
			this.velocity = '0 0 0';
			this.endtime = this.ltime + 0.1;
			if( targ.spawnflags & ANGLES )
				this.angles = targ.angles;

			return;
		}

		// qcc won't take vec/float
		float div = 1 / traveltime;

		if( targ.spawnflags & ANGLES )
		{
			this.finalangle = SUB_NormalizeAngles( targ.angles );
			this.rotate = ( targ.angles - this.angles ) * div;
		}

		// set endtime to trigger a think when dest is reached
		this.endtime = this.ltime + traveltime;

		// scale the destdelta vector by the time spent traveling to get velocity
		this.velocity = vdestdelta * div;

		this.duration = div;      // 1 / duration
		this.cnt = time;          // start time
		this.dest2 = vdestdelta;  // delta
		this.dest1 = this.origin; // original position
	}
}

void rotate_train_find(entity this)
{
	this.state = STATE_FIND;

	LinkRotateTargets(this);

	// the first target is the point of rotation.
	// the second target is the path.
	entity targ = NULL;
	FOREACH_ENTITY_STRING(targetname, this.path,
	{
		if(it.classname == "path_rotate")
		{
			targ = it;
			break;
		}
	});

	if(!targ)
		objerror(this, "Next target is not path_rotate");

	// Save the current entity
	this.goalentity = targ;

	if(targ.spawnflags & ANGLES)
	{
		this.angles = targ.angles;
		this.finalangle = SUB_NormalizeAngles(targ.angles);
	}

	this.path = targ.target;
	setorigin(this, targ.origin);
	SetTargetOrigin(this);
	RotateTargetsFinal(this);
	this.think1 = rotate_train_next;
	if(!this.targetname)
	{
		// not triggered, so start immediately
		this.endtime = this.ltime + 0.1;
	}
	else
		this.endtime = 0;

	this.duration = 1;        // 1 / duration
	this.cnt = time;          // start time
	this.dest2 = '0 0 0';     // delta
	this.dest1 = this.origin; // original position
}

/*QUAKED func_rotate_train (0 .5 .8) (-8 -8 -8) (8 8 8)
In path_rotate, set speed to be the new speed of the train after it reaches
the path change.  If speed is -1, the train will warp directly to the next
path change after the specified wait time.  If MOVETIME is set on the
path_rotate, the train to interprets "speed" as the length of time to
take moving from one corner to another.

"noise" contains the name of the sound to play when train stops.
"noise1" contains the name of the sound to play when train moves.
Both "noise" and "noise1" defaults depend upon "sounds" variable and
can be overridden by the "noise" and "noise1" variable in path_rotate.

Also in path_rotate, if STOP is set, the train will wait until it is
retriggered before moving on to the next goal.

Trains are moving platforms that players can ride.
"path" specifies the first path_rotate and is the starting position.
If the train is the target of a button or trigger, it will not begin moving until activated.
The func_rotate_train entity is the center of rotation of all objects targeted by it.

If "deathtype" is set with a string, this is the message that will appear when a player is killed by the train.

speed	default 100
dmg      default  0
sounds
1) ratchet metal
*/

spawnfunc(rotate_train)
{
	objerror (this, "rotate_train entities should be changed to rotate_object with\nfunc_rotate_train controllers\n");
}

spawnfunc(func_rotate_train)
{
	if(!this.speed)
		this.speed = 100;
	if(!this.target)
		objerror(this, "rotate_train without a target");

	if(!this.noise)
	{
		if(this.sounds == 0)
			this.noise = ("misc/null.wav");

		if(this.sounds == 1)
				this.noise = ("plats/train2.wav");
	}
	if(!this.noise1)
	{
		if(this.sounds == 0)
			this.noise1 = ("misc/null.wav");
		if(this.sounds == 1)
			this.noise1 = ("plats/train1.wav");
	}

	precache_sound( this.noise );
	precache_sound( this.noise1 );

	this.cnt = 1;
	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_STEP);
	this.use = rotate_train_use;

	_setmodel(this, this.model);
	setsize(this, this.mins, this.maxs);
	setorigin(this, this.origin);

// start trains on the second frame, to make sure their targets have had
// a chance to spawn
	this.ltime = time;
	this.nextthink = this.ltime + 0.1;
	this.endtime = this.ltime + 0.1;
	setthink(this, rotate_train_think);
	this.think1 = rotate_train_find;
	this.state = STATE_FIND;

	this.duration = 1;        // 1 / duration
	this.cnt = 0.1;           // start time
	this.dest2 = '0 0 0';     // delta
	this.dest1 = this.origin; // original position


	this.flags |= FL_ONGROUND;
}

//************************************************
//
// Moving clip walls
//
//************************************************

void rotate_door_reversedirection(entity this);
void rotate_door_group_reversedirection(entity this);

void movewall_touch(entity this, entity toucher)
{
	if(time < this.owner.attack_finished)
		return;

	if( this.dmg )
	{
		T_Damage(toucher, this, this.owner, this.dmg);
		this.owner.attack_finished = time + 0.5;
	}
	else if( this.owner.dmg )
	{
		T_Damage(toucher, this, this.owner, this.owner.dmg);
		this.owner.attack_finished = time + 0.5;
	}
}

void movewall_blocked(entity this, entity blocker)
{
	if(time < this.owner.attack_finished)
		return;

	this.owner.attack_finished = time + 0.5;

	if(this.owner.classname == "func_rotate_door")
		rotate_door_group_reversedirection(this.owner);

	if(this.dmg)
	{
		T_Damage(blocker, this, this.owner, this.dmg);
		this.owner.attack_finished = time + 0.5;
	}
	else if(this.owner.dmg)
	{
		T_Damage(blocker, this, this.owner, this.owner.dmg);
		this.owner.attack_finished = time + 0.5;
	}
}

void movewall_think(entity this)
{
	this.ltime = time;
	this.nextthink = time + 0.02;
}

/*QUAKED func_movewall (0 .5 .8) ? VISIBLE TOUCH NONBLOCKING
Used to emulate collision on rotating objects.

VISIBLE causes brush to be displayed.

TOUCH specifies whether to cause damage when touched by player.

NONBLOCKING makes the brush non-solid.  This is useless if VISIBLE is set.

"dmg" specifies the damage to cause when touched or blocked.
*/
spawnfunc(func_movewall)
{
	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_PUSH);
	if(this.spawnflags & NONBLOCKING)
		this.solid = SOLID_NOT;
	else
	{
		this.solid = SOLID_BSP;
		setblocked(this, movewall_blocked);
	}
	if(this.spawnflags & TOUCH)
		settouch(this, movewall_touch);

	_setmodel(this,this.model);
	if(!(this.spawnflags & VISIBLE))
		this.model = string_null;
	setthink(this, movewall_think);
	this.nextthink = time + 0.02;
	this.ltime = time;
}

/*QUAKED rotate_object (0 .5 .8) ?
This defines an object to be rotated.  Used as the target of func_rotate_door.
*/
spawnfunc(rotate_object)
{
	this.classname = "rotate_object";
	this.solid = SOLID_BSP; // TODO: this was SOLID_NOT, why did it work in Quake?
	set_movetype(this, MOVETYPE_NONE);
	_setmodel (this,this.model);
	setsize( this, this.mins, this.maxs );
	setthink(this, func_null);
	this.nextthink = 0;
}

//************************************************
//
// Rotating doors
//
//************************************************

void rotate_door_think2(entity this)
{
	//float t = time - this.ltime;
	this.ltime = time;

	// change to alternate textures
	this.frame = 1 - this.frame;

	this.angles = this.dest;

	if(this.state == STATE_OPENING)
		this.state = STATE_OPEN;
	else
	{
		if( this.spawnflags & STAYOPEN )
		{
			rotate_door_group_reversedirection(this);
			return;
		}
		this.state = STATE_CLOSED;
	}

	_sound(this, CHAN_VOICE, this.noise3, 1, ATTN_NORM);
	setthink(this, func_null);
	this.nextthink = 0;

	RotateTargetsFinal(this);
}

void rotate_door_think(entity this)
{
	float t = time - this.ltime;
	this.ltime = time;

	if(time < this.endtime)
	{
		this.angles = this.angles + (this.rotate * t);
		RotateTargets(this);
	}
	else
	{
		this.angles = this.dest;
		RotateTargets(this);
		setthink(this, rotate_door_think2);
	}

	this.nextthink = time + 0.01;
}

void rotate_door_reversedirection(entity this)
{
	vector start;

	// change to alternate textures
	this.frame = 1 - this.frame;

	if(this.state == STATE_CLOSING)
	{
		start = this.dest1;
		this.dest = this.dest2;
		this.state = STATE_OPENING;
	}
	else
	{
		start = this.dest2;
		this.dest = this.dest1;
		this.state = STATE_CLOSING;
	}

	_sound(this, CHAN_VOICE, this.noise2, 1, ATTN_NORM);

	this.rotate = (this.dest - start) * (1 / this.speed);
	setthink(this, rotate_door_think);
	this.nextthink = time + 0.02;
	this.endtime = time + this.speed - ( this.endtime - time );
	this.ltime = time;
}

void rotate_door_group_reversedirection(entity this)
{
	// tell all associated rotaters to reverse direction
	if(this.group)
	{
		string name = this.group;
		entity ent = find(NULL, group, name);
		while(ent)
		{
			rotate_door_reversedirection(ent);
			ent = find(ent, group, name);
		}
	}
	else
		rotate_door_reversedirection(this);
}

void rotate_door_use(entity this, entity actor, entity trigger)
{
	if((this.state != STATE_OPEN) && (this.state != STATE_CLOSED))
		return;

	if(!this.cnt)
	{
		this.cnt = 1;
		LinkRotateTargets(this);
	}

	// change to alternate textures
	this.frame = 1 - this.frame;

	vector start;
	if(this.state == STATE_CLOSED)
	{
		start = this.dest1;
		this.dest = this.dest2;
		this.state = STATE_OPENING;
	}
	else
	{
		start = this.dest2;
		this.dest = this.dest1;
		this.state = STATE_CLOSING;
	}

	_sound(this, CHAN_VOICE, this.noise2, 1, ATTN_NORM);

	this.rotate = (this.dest - start) * (1 / this.speed);
	setthink(this, rotate_door_think);
	this.nextthink = time + 0.01;
	this.endtime = time + this.speed;
	this.ltime = time;
}


/*QUAKED func_rotate_door (0 .5 .8) (-8 -8 -8) (8 8 8) STAYOPEN
Creates a door that rotates between two positions around a point of
rotation each time it's triggered.

STAYOPEN tells the door to reopen after closing.  This prevents a trigger-
once door from closing again when it's blocked.

"dmg" specifies the damage to cause when blocked.  Defaults to 2.  Negative numbers indicate no damage.
"speed" specifies how the time it takes to rotate

"sounds"
1) medieval (default)
2) metal
3) base
*/

spawnfunc(func_rotate_door)
{
	if(!this.target)
		objerror(this, "rotate_door without target.");

	this.dest1 = '0 0 0';
	this.dest2 = this.angles;
	this.angles = this.dest1;

	// default to 2 seconds
	if(!this.speed)
		this.speed = 2;

	this.cnt = 0;

	if(!this.dmg)
		this.dmg = 2;
	else if(this.dmg < 0)
		this.dmg = 0;

	if(this.sounds == 0)
		this.sounds = 1;
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

	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_NONE);
	_setmodel (this, this.model);
	setorigin( this, this.origin );
	setsize( this, this.mins, this.maxs );
	this.state = STATE_CLOSED;
	this.use = rotate_door_use;
	setthink(this, func_null);
	this.nextthink = 0;
}
