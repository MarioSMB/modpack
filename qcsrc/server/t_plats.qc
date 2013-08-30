.float dmgtime2;
void generic_plat_blocked()
{
    if(self.dmg && other.takedamage != DAMAGE_NO) {
        if(self.dmgtime2 < time) {
            Damage (other, self, self, self.dmg, DEATH_HURTTRIGGER, other.origin, '0 0 0');
            self.dmgtime2 = time + self.dmgtime;
        }

        // Gib dead/dying stuff
        if(other.deadflag != DEAD_NO)
            Damage (other, self, self, 10000, DEATH_HURTTRIGGER, other.origin, '0 0 0');
    }
}


.entity trigger_field;

void() plat_center_touch;
void() plat_outside_touch;
void() plat_trigger_use;
void() plat_go_up;
void() plat_go_down;
void() plat_crush;
const float PLAT_LOW_TRIGGER = 1;

void plat_spawn_inside_trigger()
{
	entity trigger;
	vector tmin, tmax;

	trigger = spawn();
	trigger.touch = plat_center_touch;
	trigger.movetype = MOVETYPE_NONE;
	trigger.solid = SOLID_TRIGGER;
	trigger.enemy = self;

	tmin = self.absmin + '25 25 0';
	tmax = self.absmax - '25 25 -8';
	tmin_z = tmax_z - (self.pos1_z - self.pos2_z + 8);
	if (self.spawnflags & PLAT_LOW_TRIGGER)
		tmax_z = tmin_z + 8;

	if (self.size_x <= 50)
	{
		tmin_x = (self.mins_x + self.maxs_x) / 2;
		tmax_x = tmin_x + 1;
	}
	if (self.size_y <= 50)
	{
		tmin_y = (self.mins_y + self.maxs_y) / 2;
		tmax_y = tmin_y + 1;
	}

	if(tmin_x < tmax_x)
		if(tmin_y < tmax_y)
			if(tmin_z < tmax_z)
			{
				setsize (trigger, tmin, tmax);
				return;
			}

	// otherwise, something is fishy...
	remove(trigger);
	objerror("plat_spawn_inside_trigger: platform has odd size or lip, can't spawn");
}

void plat_hit_top()
{
	sound (self, CH_TRIGGER_SINGLE, self.noise1, VOL_BASE, ATTEN_NORM);
	self.state = 1;
	self.think = plat_go_down;
	self.nextthink = self.ltime + 3;
}

void plat_hit_bottom()
{
	sound (self, CH_TRIGGER_SINGLE, self.noise1, VOL_BASE, ATTEN_NORM);
	self.state = 2;
}

void plat_go_down()
{
	sound (self, CH_TRIGGER_SINGLE, self.noise, VOL_BASE, ATTEN_NORM);
	self.state = 3;
	SUB_CalcMove (self.pos2, self.speed, plat_hit_bottom);
}

void plat_go_up()
{
	sound (self, CH_TRIGGER_SINGLE, self.noise, VOL_BASE, ATTEN_NORM);
	self.state = 4;
	SUB_CalcMove (self.pos1, self.speed, plat_hit_top);
}

void plat_center_touch()
{
	if not(other.iscreature)
		return;

	if (other.health <= 0)
		return;

	self = self.enemy;
	if (self.state == 2)
		plat_go_up ();
	else if (self.state == 1)
		self.nextthink = self.ltime + 1;	// delay going down
}

void plat_outside_touch()
{
	if not(other.iscreature)
		return;

	if (other.health <= 0)
		return;

	self = self.enemy;
	if (self.state == 1)
		plat_go_down ();
}

void plat_trigger_use()
{
	if (self.think)
		return;		// already activated
	plat_go_down();
}


void plat_crush()
{
    if((self.spawnflags & 4) && (other.takedamage != DAMAGE_NO)) { // KIll Kill Kill!!
        Damage (other, self, self, 10000, DEATH_HURTTRIGGER, other.origin, '0 0 0');
    } else {
        if((self.dmg) && (other.takedamage != DAMAGE_NO)) {   // Shall we bite?
            Damage (other, self, self, self.dmg, DEATH_HURTTRIGGER, other.origin, '0 0 0');
            // Gib dead/dying stuff
            if(other.deadflag != DEAD_NO)
                Damage (other, self, self, 10000, DEATH_HURTTRIGGER, other.origin, '0 0 0');
        }

        if (self.state == 4)
            plat_go_down ();
        else if (self.state == 3)
            plat_go_up ();
	// when in other states, then the plat_crush event came delayed after
	// plat state already had changed
	// this isn't a bug per se!
    }
}

void plat_use()
{
	self.use = func_null;
	if (self.state != 4)
		objerror ("plat_use: not in up state");
	plat_go_down();
}

.string sound1, sound2;

void plat_reset()
{
	IFTARGETED
	{
		setorigin (self, self.pos1);
		self.state = 4;
		self.use = plat_use;
	}
	else
	{
		setorigin (self, self.pos2);
		self.state = 2;
		self.use = plat_trigger_use;
	}
}

void spawnfunc_path_corner() { }
void spawnfunc_func_plat()
{
	if (self.sounds == 0)
		self.sounds = 2;

    if(self.spawnflags & 4)
        self.dmg = 10000;

    if(self.dmg && (self.message == ""))
		self.message = "was squished";
    if(self.dmg && (self.message2 == ""))
		self.message2 = "was squished by";

	if (self.sounds == 1)
	{
		precache_sound ("plats/plat1.wav");
		precache_sound ("plats/plat2.wav");
		self.noise = "plats/plat1.wav";
		self.noise1 = "plats/plat2.wav";
	}

	if (self.sounds == 2)
	{
		precache_sound ("plats/medplat1.wav");
		precache_sound ("plats/medplat2.wav");
		self.noise = "plats/medplat1.wav";
		self.noise1 = "plats/medplat2.wav";
	}

	if (self.sound1)
	{
		precache_sound (self.sound1);
		self.noise = self.sound1;
	}
	if (self.sound2)
	{
		precache_sound (self.sound2);
		self.noise1 = self.sound2;
	}

	self.mangle = self.angles;
	self.angles = '0 0 0';

	self.classname = "plat";
	if not(InitMovingBrushTrigger())
		return;
	self.effects |= EF_LOWPRECISION;
	setsize (self, self.mins , self.maxs);

	self.blocked = plat_crush;

	if (!self.speed)
		self.speed = 150;
	if (!self.lip)
		self.lip = 16;
	if (!self.height)
		self.height = self.size_z - self.lip;

	self.pos1 = self.origin;
	self.pos2 = self.origin;
	self.pos2_z = self.origin_z - self.height;

	self.reset = plat_reset;
	plat_reset();

	plat_spawn_inside_trigger ();	// the "start moving" trigger
}


void() train_next;
void train_wait()
{
	if(self.noise != "")
		stopsoundto(MSG_BROADCAST, self, CH_TRIGGER_SINGLE); // send this as unreliable only, as the train will resume operation shortly anyway

	if(self.wait < 0)
	{
		train_next();
	}
	else
	{
		self.think = train_next;
		self.nextthink = self.ltime + self.wait;
	}

	entity oldself;
	oldself = self;
	self = self.enemy;
	SUB_UseTargets();
	self = oldself;
	self.enemy = world;
}

void train_next()
{
	entity targ;
	targ = find(world, targetname, self.target);
	self.enemy = targ;
	self.target = targ.target;
	if (self.target == "")
		objerror("train_next: no next target");
	self.wait = targ.wait;
	if (!self.wait)
		self.wait = 0.1;

	if (targ.speed)
		SUB_CalcMove(targ.origin - self.mins, targ.speed, train_wait);
	else
		SUB_CalcMove(targ.origin - self.mins, self.speed, train_wait);

	if(self.noise != "")
		sound(self, CH_TRIGGER_SINGLE, self.noise, VOL_BASE, ATTEN_IDLE);
}

void func_train_find()
{
	entity targ;
	targ = find(world, targetname, self.target);
	self.target = targ.target;
	if (self.target == "")
		objerror("func_train_find: no next target");
	setorigin(self, targ.origin - self.mins);
	self.nextthink = self.ltime + 1;
	self.think = train_next;
}

/*QUAKED spawnfunc_func_train (0 .5 .8) ?
Ridable platform, targets spawnfunc_path_corner path to follow.
speed : speed the train moves (can be overridden by each spawnfunc_path_corner)
target : targetname of first spawnfunc_path_corner (starts here)
*/
void spawnfunc_func_train()
{
	if (self.noise != "")
		precache_sound(self.noise);

	if (self.target == "")
		objerror("func_train without a target");
	if (!self.speed)
		self.speed = 100;

	if not(InitMovingBrushTrigger())
		return;
	self.effects |= EF_LOWPRECISION;

	// wait for targets to spawn
	InitializeEntity(self, func_train_find, INITPRIO_SETLOCATION);

	self.blocked = generic_plat_blocked;
	if(self.dmg && (self.message == ""))
		self.message = " was squished";
    if(self.dmg && (self.message2 == ""))
		self.message2 = "was squished by";
	if(self.dmg && (!self.dmgtime))
		self.dmgtime = 0.25;
	self.dmgtime2 = time;

	// TODO make a reset function for this one
}

void func_rotating_setactive(float astate)
{
	
	if (astate == ACTIVE_TOGGLE)
	{		
		if(self.active == ACTIVE_ACTIVE)
			self.active = ACTIVE_NOT;
		else
			self.active = ACTIVE_ACTIVE;
	}
	else
		self.active = astate;
		
	if(self.active  == ACTIVE_NOT)		
		self.avelocity = '0 0 0';
	else
		self.avelocity = self.pos1;
}

/*QUAKED spawnfunc_func_rotating (0 .5 .8) ? - - X_AXIS Y_AXIS
Brush model that spins in place on one axis (default Z).
speed   : speed to rotate (in degrees per second)
noise   : path/name of looping .wav file to play.
dmg     : Do this mutch dmg every .dmgtime intervall when blocked
dmgtime : See above.
*/

void spawnfunc_func_rotating()
{
	if (self.noise != "")
	{
		precache_sound(self.noise);
		ambientsound(self.origin, self.noise, VOL_BASE, ATTEN_IDLE);
	}
	
	self.active = ACTIVE_ACTIVE;
	self.setactive = func_rotating_setactive;
	
	if (!self.speed)
		self.speed = 100;
	// FIXME: test if this turns the right way, then remove this comment (negate as needed)
	if (self.spawnflags & 4) // X (untested)
		self.avelocity = '0 0 1' * self.speed;
	// FIXME: test if this turns the right way, then remove this comment (negate as needed)
	else if (self.spawnflags & 8) // Y (untested)
		self.avelocity = '1 0 0' * self.speed;
	// FIXME: test if this turns the right way, then remove this comment (negate as needed)
	else // Z
		self.avelocity = '0 1 0' * self.speed;
	
	self.pos1 = self.avelocity;
    
    if(self.dmg && (self.message == ""))
        self.message = " was squished";
    if(self.dmg && (self.message2 == ""))
		self.message2 = "was squished by";


    if(self.dmg && (!self.dmgtime))
        self.dmgtime = 0.25;

    self.dmgtime2 = time;

	if not(InitMovingBrushTrigger())
		return;
	// no EF_LOWPRECISION here, as rounding angles is bad

    self.blocked = generic_plat_blocked;

	// wait for targets to spawn
	self.nextthink = self.ltime + 999999999;
	self.think = SUB_NullThink; // for PushMove

	// TODO make a reset function for this one
}

.float height;
void func_bobbing_controller_think()
{
	vector v;
	self.nextthink = time + 0.1;
	
	if not (self.owner.active == ACTIVE_ACTIVE)
	{
		self.owner.velocity = '0 0 0';		
		return;
	}
		
	// calculate sinewave using makevectors
	makevectors((self.nextthink * self.owner.cnt + self.owner.phase * 360) * '0 1 0');
	v = self.owner.destvec + self.owner.movedir * v_forward_y;
	if(self.owner.classname == "func_bobbing") // don't brake stuff if the func_bobbing was killtarget'ed
		// * 10 so it will arrive in 0.1 sec
		self.owner.velocity = (v - self.owner.origin) * 10;
}

/*QUAKED spawnfunc_func_bobbing (0 .5 .8) ? X_AXIS Y_AXIS
Brush model that moves back and forth on one axis (default Z).
speed : how long one cycle takes in seconds (default 4)
height : how far the cycle moves (default 32)
phase : cycle timing adjustment (0-1 as a fraction of the cycle, default 0)
noise : path/name of looping .wav file to play.
dmg : Do this mutch dmg every .dmgtime intervall when blocked
dmgtime : See above.
*/
void spawnfunc_func_bobbing()
{
	entity controller;
	if (self.noise != "")
	{
		precache_sound(self.noise);
		soundto(MSG_INIT, self, CH_TRIGGER_SINGLE, self.noise, VOL_BASE, ATTEN_IDLE);
	}
	if (!self.speed)
		self.speed = 4;
	if (!self.height)
		self.height = 32;
	// center of bobbing motion
	self.destvec = self.origin;
	// time scale to get degrees
	self.cnt = 360 / self.speed;

	self.active = ACTIVE_ACTIVE;

	// damage when blocked
	self.blocked = generic_plat_blocked;
	if(self.dmg && (self.message == ""))
		self.message = " was squished";
    if(self.dmg && (self.message2 == ""))
		self.message2 = "was squished by";
	if(self.dmg && (!self.dmgtime))
		self.dmgtime = 0.25;
	self.dmgtime2 = time;

	// how far to bob
	if (self.spawnflags & 1) // X
		self.movedir = '1 0 0' * self.height;
	else if (self.spawnflags & 2) // Y
		self.movedir = '0 1 0' * self.height;
	else // Z
		self.movedir = '0 0 1' * self.height;

	if not(InitMovingBrushTrigger())
		return;

	// wait for targets to spawn
	controller = spawn();
	controller.classname = "func_bobbing_controller";
	controller.owner = self;
	controller.nextthink = time + 1;
	controller.think = func_bobbing_controller_think;
	self.nextthink = self.ltime + 999999999;
	self.think = SUB_NullThink; // for PushMove

	// Savage: Reduce bandwith, critical on e.g. nexdm02
	self.effects |= EF_LOWPRECISION;

	// TODO make a reset function for this one
}

.float freq;
void func_pendulum_controller_think()
{
	float v;
	self.nextthink = time + 0.1;

	if not (self.owner.active == ACTIVE_ACTIVE)
	{
		self.owner.avelocity_x = 0;
		return;
	}

	// calculate sinewave using makevectors
	makevectors((self.nextthink * self.owner.freq + self.owner.phase) * '0 360 0');
	v = self.owner.speed * v_forward_y + self.cnt;
	if(self.owner.classname == "func_pendulum") // don't brake stuff if the func_bobbing was killtarget'ed
	{
		// * 10 so it will arrive in 0.1 sec
		self.owner.avelocity_z = (remainder(v - self.owner.angles_z, 360)) * 10;
	}
}

void spawnfunc_func_pendulum()
{
	entity controller;
	if (self.noise != "")
	{
		precache_sound(self.noise);
		soundto(MSG_INIT, self, CH_TRIGGER_SINGLE, self.noise, VOL_BASE, ATTEN_IDLE);
	}

	self.active = ACTIVE_ACTIVE;

	// keys: angle, speed, phase, noise, freq

	if(!self.speed)
		self.speed = 30;
	// not initializing self.dmg to 2, to allow damageless pendulum

	if(self.dmg && (self.message == ""))
		self.message = " was squished";
	if(self.dmg && (self.message2 == ""))
		self.message2 = "was squished by";
	if(self.dmg && (!self.dmgtime))
		self.dmgtime = 0.25;
	self.dmgtime2 = time;

	self.blocked = generic_plat_blocked;

	self.avelocity_z = 0.0000001;
	if not(InitMovingBrushTrigger())
		return;

	if(!self.freq)
	{
		// find pendulum length (same formula as Q3A)
		self.freq = 1 / (M_PI * 2) * sqrt(autocvar_sv_gravity / (3 * max(8, fabs(self.mins_z))));
	}

	// copy initial angle
	self.cnt = self.angles_z;

	// wait for targets to spawn
	controller = spawn();
	controller.classname = "func_pendulum_controller";
	controller.owner = self;
	controller.nextthink = time + 1;
	controller.think = func_pendulum_controller_think;
	self.nextthink = self.ltime + 999999999;
	self.think = SUB_NullThink; // for PushMove

	//self.effects |= EF_LOWPRECISION;

	// TODO make a reset function for this one
}

// button and multiple button

void() button_wait;
void() button_return;

void button_wait()
{
	self.state = STATE_TOP;
	self.nextthink = self.ltime + self.wait;
	self.think = button_return;
	activator = self.enemy;
	SUB_UseTargets();
	self.frame = 1;			// use alternate textures
}

void button_done()
{
	self.state = STATE_BOTTOM;
}

void button_return()
{
	self.state = STATE_DOWN;
	SUB_CalcMove (self.pos1, self.speed, button_done);
	self.frame = 0;			// use normal textures
	if (self.health)
		self.takedamage = DAMAGE_YES;	// can be shot again
}


void button_blocked()
{
	// do nothing, just don't come all the way back out
}


void button_fire()
{
	self.health = self.max_health;
	self.takedamage = DAMAGE_NO;    // will be reset upon return

	if (self.state == STATE_UP || self.state == STATE_TOP)
		return;

	if (self.noise != "")
		sound (self, CH_TRIGGER, self.noise, VOL_BASE, ATTEN_NORM);

	self.state = STATE_UP;
	SUB_CalcMove (self.pos2, self.speed, button_wait);
}

void button_reset()
{
	self.health = self.max_health;
	setorigin(self, self.pos1);
	self.frame = 0;			// use normal textures
	self.state = STATE_BOTTOM;
	if (self.health)
		self.takedamage = DAMAGE_YES;	// can be shot again
}

void button_use()
{
	if not (self.active == ACTIVE_ACTIVE)
		return;

	self.enemy = activator;
	button_fire ();
}

void button_touch()
{
	if (!other)
		return;
	if not(other.iscreature)
		return;
	if(other.velocity * self.movedir < 0)
		return;
	self.enemy = other;
	if (other.owner)
		self.enemy = other.owner;
	button_fire ();
}

void button_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(self.spawnflags & DOOR_NOSPLASH)
		if(!(DEATH_ISSPECIAL(deathtype)) && (deathtype & HITTYPE_SPLASH))
			return;
	self.health = self.health - damage;
	if (self.health <= 0)
	{
		self.enemy = damage_attacker;
		button_fire ();
	}
}


/*QUAKED spawnfunc_func_button (0 .5 .8) ?
When a button is touched, it moves some distance in the direction of it's angle, triggers all of it's targets, waits some time, then returns to it's original position where it can be triggered again.

"angle"		determines the opening direction
"target"	all entities with a matching targetname will be used
"speed"		override the default 40 speed
"wait"		override the default 1 second wait (-1 = never return)
"lip"		override the default 4 pixel lip remaining at end of move
"health"	if set, the button must be killed instead of touched. If set to -1, the button will fire on ANY attack, even damageless ones like the MinstaGib laser
"sounds"
0) steam metal
1) wooden clunk
2) metallic click
3) in-out
*/
void spawnfunc_func_button()
{
	SetMovedir ();

	if not(InitMovingBrushTrigger())
		return;
	self.effects |= EF_LOWPRECISION;

	self.blocked = button_blocked;
	self.use = button_use;

//	if (self.health == 0) // all buttons are now shootable
//		self.health = 10;
	if (self.health)
	{
		self.max_health = self.health;
		self.event_damage = button_damage;
		self.takedamage = DAMAGE_YES;
	}
	else
		self.touch = button_touch;

	if (!self.speed)
		self.speed = 40;
	if (!self.wait)
		self.wait = 1;
	if (!self.lip)
		self.lip = 4;

    if(self.noise != "")
        precache_sound(self.noise);

	self.active = ACTIVE_ACTIVE;

	self.pos1 = self.origin;
	self.pos2 = self.pos1 + self.movedir*(fabs(self.movedir*self.size) - self.lip);
    self.flags |= FL_NOTARGET;

	button_reset();
}


const float DOOR_START_OPEN = 1;
const float DOOR_DONT_LINK = 4;
const float DOOR_TOGGLE = 32;

/*

Doors are similar to buttons, but can spawn a fat trigger field around them
to open without a touch, and they link together to form simultanious
double/quad doors.

Door.owner is the master door.  If there is only one door, it points to itself.
If multiple doors, all will point to a single one.

Door.enemy chains from the master door through all doors linked in the chain.

*/

/*
=============================================================================

THINK FUNCTIONS

=============================================================================
*/

void() door_go_down;
void() door_go_up;
void() door_rotating_go_down;
void() door_rotating_go_up;

void door_blocked()
{

    if((self.spawnflags & 8) && (other.takedamage != DAMAGE_NO)) { // KIll Kill Kill!!
        Damage (other, self, self, 10000, DEATH_HURTTRIGGER, other.origin, '0 0 0');
    } else {

        if((self.dmg) && (other.takedamage == DAMAGE_YES))    // Shall we bite?
            Damage (other, self, self, self.dmg, DEATH_HURTTRIGGER, other.origin, '0 0 0');

         //Dont chamge direction for dead or dying stuff
        if(other.deadflag != DEAD_NO && (other.takedamage == DAMAGE_NO)) {
            if (self.wait >= 0)
            {
                if (self.state == STATE_DOWN)
			if (self.classname == "door")
			{
				door_go_up ();
			} else
			{
				door_rotating_go_up ();
			}
                else
			if (self.classname == "door")
			{
				door_go_down ();
			} else
			{
				door_rotating_go_down ();
			}
            }
        } else {
            //gib dying stuff just to make sure
            if((self.dmg) && (other.takedamage != DAMAGE_NO))    // Shall we bite?
                Damage (other, self, self, 10000, DEATH_HURTTRIGGER, other.origin, '0 0 0');
        }
    }

	//T_Damage (other, self, self, self.dmg, self.dmg, self.deathtype, DT_IMPACT, (self.absmin + self.absmax) * 0.5, '0 0 0', Obituary_Generic);
// if a door has a negative wait, it would never come back if blocked,
// so let it just squash the object to death real fast
/*	if (self.wait >= 0)
	{
		if (self.state == STATE_DOWN)
			door_go_up ();
		else
			door_go_down ();
	}
*/
}


void door_hit_top()
{
	if (self.noise1 != "")
		sound (self, CH_TRIGGER_SINGLE, self.noise1, VOL_BASE, ATTEN_NORM);
	self.state = STATE_TOP;
	if (self.spawnflags & DOOR_TOGGLE)
		return;		// don't come down automatically
	if (self.classname == "door")
	{
		self.think = door_go_down;
	} else
	{
		self.think = door_rotating_go_down;
	}
	self.nextthink = self.ltime + self.wait;
}

void door_hit_bottom()
{
	if (self.noise1 != "")
		sound (self, CH_TRIGGER_SINGLE, self.noise1, VOL_BASE, ATTEN_NORM);
	self.state = STATE_BOTTOM;
}

void door_go_down()
{
	if (self.noise2 != "")
		sound (self, CH_TRIGGER_SINGLE, self.noise2, VOL_BASE, ATTEN_NORM);
	if (self.max_health)
	{
		self.takedamage = DAMAGE_YES;
		self.health = self.max_health;
	}

	self.state = STATE_DOWN;
	SUB_CalcMove (self.pos1, self.speed, door_hit_bottom);
}

void door_go_up()
{
	if (self.state == STATE_UP)
		return;		// already going up

	if (self.state == STATE_TOP)
	{	// reset top wait time
		self.nextthink = self.ltime + self.wait;
		return;
	}

	if (self.noise2 != "")
		sound (self, CH_TRIGGER_SINGLE, self.noise2, VOL_BASE, ATTEN_NORM);
	self.state = STATE_UP;
	SUB_CalcMove (self.pos2, self.speed, door_hit_top);

	string oldmessage;
	oldmessage = self.message;
	self.message = "";
	SUB_UseTargets();
	self.message = oldmessage;
}



/*
=============================================================================

ACTIVATION FUNCTIONS

=============================================================================
*/

float door_check_keys(void) {
	local entity door;
	
	
	if (self.owner)
		door = self.owner;
	else
		door = self;
	
	// no key needed
	if not(door.itemkeys)
		return TRUE;

	// this door require a key
	// only a player can have a key
	if not(IS_PLAYER(other))
		return FALSE;
	
	if (item_keys_usekey(door, other)) {
		// some keys were used
		if (other.key_door_messagetime <= time) {
			play2(other, "misc/talk.wav");
			centerprint(other, strcat("You also need ", item_keys_keylist(door.itemkeys), "!"));
			other.key_door_messagetime = time + 2;
		}
	} else {
		// no keys were used
		if (other.key_door_messagetime <= time) {
			play2(other, "misc/talk.wav");
			centerprint(other, strcat("You need ", item_keys_keylist(door.itemkeys), "!"));
			other.key_door_messagetime = time + 2;
		}
	}

	if (door.itemkeys) {
		// door is now unlocked
		play2(other, "misc/talk.wav");
		centerprint(other, "Door unlocked!");
		return TRUE;
	} else
		return FALSE;
}


void door_fire()
{
	entity 	oself;
	entity	starte;

	if (self.owner != self)
		objerror ("door_fire: self.owner != self");

	oself = self;

	if (self.spawnflags & DOOR_TOGGLE)
	{
		if (self.state == STATE_UP || self.state == STATE_TOP)
		{
			starte = self;
			do
			{
				if (self.classname == "door")
				{
					door_go_down ();
				}
				else
				{
					door_rotating_go_down ();
				}
				self = self.enemy;
			} while ( (self != starte) && (self != world) );
			self = oself;
			return;
		}
	}

// trigger all paired doors
	starte = self;
	do
	{
		if (self.classname == "door")
		{
			door_go_up ();
		} else
		{
			// if the BIDIR spawnflag (==2) is set and the trigger has set trigger_reverse, reverse the opening direction
			if ((self.spawnflags & 2) && other.trigger_reverse!=0 && self.lip!=666 && self.state == STATE_BOTTOM)
			{
				self.lip = 666; // self.lip is used to remember reverse opening direction for door_rotating
			  	self.pos2 = '0 0 0' - self.pos2;
			}
			// if BIDIR_IN_DOWN (==8) is set, prevent the door from reoping during closing if it is triggered from the wrong side
			if (!((self.spawnflags & 2) &&  (self.spawnflags & 8) && self.state == STATE_DOWN
			    && (((self.lip==666) && (other.trigger_reverse==0)) || ((self.lip!=666) && (other.trigger_reverse!=0)))))
			{
				door_rotating_go_up ();
			}
		}
		self = self.enemy;
	} while ( (self != starte) && (self != world) );
	self = oself;
}


void door_use()
{
	entity oself;

	//dprint("door_use (model: ");dprint(self.model);dprint(")\n");
	
	if (self.owner)
	{
		oself = self;
		self = self.owner;
		door_fire ();
		self = oself;
	}
}


void door_trigger_touch()
{
	if (other.health < 1)
		if not(other.iscreature && other.deadflag == DEAD_NO)
			return;

	if (time < self.attack_finished_single)
		return;
	
	// check if door is locked
	if (!door_check_keys())
		return;
	
	self.attack_finished_single = time + 1;

	activator = other;

	self = self.owner;
	door_use ();
}


void door_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	entity oself;
	if(self.spawnflags & DOOR_NOSPLASH)
		if(!(DEATH_ISSPECIAL(deathtype)) && (deathtype & HITTYPE_SPLASH))
			return;
	self.health = self.health - damage;
	
	if (self.itemkeys) {
		// don't allow opening doors through damage if keys are required
		return;
	}
	
	if (self.health <= 0)
	{
		oself = self;
		self = self.owner;
		self.health = self.max_health;
		self.takedamage = DAMAGE_NO;	// wil be reset upon return
		door_use ();
		self = oself;
	}
}


/*
================
door_touch

Prints messages
================
*/
void door_touch()
{
	if not(IS_PLAYER(other))
		return;
	if (self.owner.attack_finished_single > time)
		return;

	self.owner.attack_finished_single = time + 2;

	if (!(self.owner.dmg) && (self.owner.message != ""))
	{
		if (IS_CLIENT(other))
			centerprint (other, self.owner.message);
		play2(other, "misc/talk.wav");
	}
}


void door_generic_plat_blocked()
{

    if((self.spawnflags & 8) && (other.takedamage != DAMAGE_NO)) { // KIll Kill Kill!!
        Damage (other, self, self, 10000, DEATH_HURTTRIGGER, other.origin, '0 0 0');
    } else {

        if((self.dmg) && (other.takedamage == DAMAGE_YES))    // Shall we bite?
            Damage (other, self, self, self.dmg, DEATH_HURTTRIGGER, other.origin, '0 0 0');

         //Dont chamge direction for dead or dying stuff
        if(other.deadflag != DEAD_NO && (other.takedamage == DAMAGE_NO)) {
            if (self.wait >= 0)
            {
                if (self.state == STATE_DOWN)
                    door_rotating_go_up ();
                else
                    door_rotating_go_down ();
            }
        } else {
            //gib dying stuff just to make sure
            if((self.dmg) && (other.takedamage != DAMAGE_NO))    // Shall we bite?
                Damage (other, self, self, 10000, DEATH_HURTTRIGGER, other.origin, '0 0 0');
        }
    }

	//T_Damage (other, self, self, self.dmg, self.dmg, self.deathtype, DT_IMPACT, (self.absmin + self.absmax) * 0.5, '0 0 0', Obituary_Generic);
// if a door has a negative wait, it would never come back if blocked,
// so let it just squash the object to death real fast
/*	if (self.wait >= 0)
	{
		if (self.state == STATE_DOWN)
			door_rotating_go_up ();
		else
			door_rotating_go_down ();
	}
*/
}


void door_rotating_hit_top()
{
	if (self.noise1 != "")
		sound (self, CH_TRIGGER_SINGLE, self.noise1, VOL_BASE, ATTEN_NORM);
	self.state = STATE_TOP;
	if (self.spawnflags & DOOR_TOGGLE)
		return;		// don't come down automatically
	self.think = door_rotating_go_down;
	self.nextthink = self.ltime + self.wait;
}

void door_rotating_hit_bottom()
{
	if (self.noise1 != "")
		sound (self, CH_TRIGGER_SINGLE, self.noise1, VOL_BASE, ATTEN_NORM);
	if (self.lip==666) // self.lip is used to remember reverse opening direction for door_rotating
	{
		self.pos2 = '0 0 0' - self.pos2;
		self.lip = 0;
	}
	self.state = STATE_BOTTOM;
}

void door_rotating_go_down()
{
	if (self.noise2 != "")
		sound (self, CH_TRIGGER_SINGLE, self.noise2, VOL_BASE, ATTEN_NORM);
	if (self.max_health)
	{
		self.takedamage = DAMAGE_YES;
		self.health = self.max_health;
	}

	self.state = STATE_DOWN;
	SUB_CalcAngleMove (self.pos1, self.speed, door_rotating_hit_bottom);
}

void door_rotating_go_up()
{
	if (self.state == STATE_UP)
		return;		// already going up

	if (self.state == STATE_TOP)
	{	// reset top wait time
		self.nextthink = self.ltime + self.wait;
		return;
	}
	if (self.noise2 != "")
		sound (self, CH_TRIGGER_SINGLE, self.noise2, VOL_BASE, ATTEN_NORM);
	self.state = STATE_UP;
	SUB_CalcAngleMove (self.pos2, self.speed, door_rotating_hit_top);

	string oldmessage;
	oldmessage = self.message;
	self.message = "";
	SUB_UseTargets();
	self.message = oldmessage;
}




/*
=============================================================================

SPAWNING FUNCTIONS

=============================================================================
*/


entity spawn_field(vector fmins, vector fmaxs)
{
	entity	trigger;
	vector	t1, t2;

	trigger = spawn();
	trigger.classname = "doortriggerfield";
	trigger.movetype = MOVETYPE_NONE;
	trigger.solid = SOLID_TRIGGER;
	trigger.owner = self;
	trigger.touch = door_trigger_touch;

	t1 = fmins;
	t2 = fmaxs;
	setsize (trigger, t1 - '60 60 8', t2 + '60 60 8');
	return (trigger);
}


entity LinkDoors_nextent(entity cur, entity near, entity pass)
{
	while((cur = find(cur, classname, self.classname)) && ((cur.spawnflags & 4) || cur.enemy))
	{
	}
	return cur;
}

float LinkDoors_isconnected(entity e1, entity e2, entity pass)
{
	float DELTA = 4;
	if (e1.absmin_x > e2.absmax_x + DELTA)
		return FALSE;
	if (e1.absmin_y > e2.absmax_y + DELTA)
		return FALSE;
	if (e1.absmin_z > e2.absmax_z + DELTA)
		return FALSE;
	if (e2.absmin_x > e1.absmax_x + DELTA)
		return FALSE;
	if (e2.absmin_y > e1.absmax_y + DELTA)
		return FALSE;
	if (e2.absmin_z > e1.absmax_z + DELTA)
		return FALSE;
	return TRUE;
}

/*
=============
LinkDoors


=============
*/
void LinkDoors()
{
	entity	t;
	vector	cmins, cmaxs;

	if (self.enemy)
		return;		// already linked by another door
	if (self.spawnflags & 4)
	{
		self.owner = self.enemy = self;

		if (self.health)
			return;
		IFTARGETED
			return;
		if (self.items)
			return;
		self.trigger_field = spawn_field(self.absmin, self.absmax);

		return;		// don't want to link this door
	}

	FindConnectedComponent(self, enemy, LinkDoors_nextent, LinkDoors_isconnected, world);

	// set owner, and make a loop of the chain
	dprint("LinkDoors: linking doors:");
	for(t = self; ; t = t.enemy)
	{
		dprint(" ", etos(t));
		t.owner = self;
		if(t.enemy == world)
		{
			t.enemy = self;
			break;
		}
	}
	dprint("\n");

	// collect health, targetname, message, size
	cmins = self.absmin;
	cmaxs = self.absmax;
	for(t = self; ; t = t.enemy)
	{
		if(t.health && !self.health)
			self.health = t.health;
		if((t.targetname != "") && (self.targetname == ""))
			self.targetname = t.targetname;
		if((t.message != "") && (self.message == ""))
			self.message = t.message;
		if (t.absmin_x < cmins_x)
			cmins_x = t.absmin_x;
		if (t.absmin_y < cmins_y)
			cmins_y = t.absmin_y;
		if (t.absmin_z < cmins_z)
			cmins_z = t.absmin_z;
		if (t.absmax_x > cmaxs_x)
			cmaxs_x = t.absmax_x;
		if (t.absmax_y > cmaxs_y)
			cmaxs_y = t.absmax_y;
		if (t.absmax_z > cmaxs_z)
			cmaxs_z = t.absmax_z;
		if(t.enemy == self)
			break;
	}

	// distribute health, targetname, message
	for(t = self; t; t = t.enemy)
	{
		t.health = self.health;
		t.targetname = self.targetname;
		t.message = self.message;
		if(t.enemy == self)
			break;
	}

	// shootable, or triggered doors just needed the owner/enemy links,
	// they don't spawn a field

	if (self.health)
		return;
	IFTARGETED
		return;
	if (self.items)
		return;

	self.trigger_field = spawn_field(cmins, cmaxs);
}


/*QUAKED spawnfunc_func_door (0 .5 .8) ? START_OPEN x DOOR_DONT_LINK GOLD_KEY SILVER_KEY TOGGLE
if two doors touch, they are assumed to be connected and operate as a unit.

TOGGLE causes the door to wait in both the start and end states for a trigger event.

START_OPEN causes the door to move to its destination when spawned, and operate in reverse.  It is used to temporarily or permanently close off an area when triggered (not useful for touch or takedamage doors).

GOLD_KEY causes the door to open only if the activator holds a gold key.

SILVER_KEY causes the door to open only if the activator holds a silver key.

"message"	is printed when the door is touched if it is a trigger door and it hasn't been fired yet
"angle"		determines the opening direction
"targetname" if set, no touch field will be spawned and a remote button or trigger field activates the door.
"health"	if set, door must be shot open
"speed"		movement speed (100 default)
"wait"		wait before returning (3 default, -1 = never return)
"lip"		lip remaining at end of move (8 default)
"dmg"		damage to inflict when blocked (2 default)
"sounds"
0)	no sound
1)	stone
2)	base
3)	stone chain
4)	screechy metal
FIXME: only one sound set available at the time being

*/

void door_init_startopen()
{
	setorigin (self, self.pos2);
	self.pos2 = self.pos1;
	self.pos1 = self.origin;
}

void door_reset()
{
	setorigin(self, self.pos1);
	self.velocity = '0 0 0';
	self.state = STATE_BOTTOM;
	self.think = func_null;
	self.nextthink = 0;
}

// spawnflags require key (for now only func_door)
#define SPAWNFLAGS_GOLD_KEY 8
#define SPAWNFLAGS_SILVER_KEY 16
void spawnfunc_func_door()
{
	// Quake 1 keys compatibility
	if (self.spawnflags & SPAWNFLAGS_GOLD_KEY)
		self.itemkeys |= ITEM_KEY_BIT(0);
	if (self.spawnflags & SPAWNFLAGS_SILVER_KEY)
		self.itemkeys |= ITEM_KEY_BIT(1);
		
	//if (!self.deathtype) // map makers can override this
	//	self.deathtype = " got in the way";
	SetMovedir ();

	self.max_health = self.health;
	if not(InitMovingBrushTrigger())
		return;
	self.effects |= EF_LOWPRECISION;
	self.classname = "door";

	self.blocked = door_blocked;
	self.use = door_use;

	// FIXME: undocumented flag 8, originally (Q1) GOLD_KEY
	// if(self.spawnflags & 8)
	// 	self.dmg = 10000;

    if(self.dmg && (self.message == ""))
		self.message = "was squished";
    if(self.dmg && (self.message2 == ""))
		self.message2 = "was squished by";

	if (self.sounds > 0)
	{
		precache_sound ("plats/medplat1.wav");
		precache_sound ("plats/medplat2.wav");
		self.noise2 = "plats/medplat1.wav";
		self.noise1 = "plats/medplat2.wav";
	}

	if (!self.speed)
		self.speed = 100;
	if (!self.wait)
		self.wait = 3;
	if (!self.lip)
		self.lip = 8;

	self.pos1 = self.origin;
	self.pos2 = self.pos1 + self.movedir*(fabs(self.movedir*self.size) - self.lip);

// DOOR_START_OPEN is to allow an entity to be lighted in the closed position
// but spawn in the open position
	if (self.spawnflags & DOOR_START_OPEN)
		InitializeEntity(self, door_init_startopen, INITPRIO_SETLOCATION);

	self.state = STATE_BOTTOM;

	if (self.health)
	{
		self.takedamage = DAMAGE_YES;
		self.event_damage = door_damage;
	}

	if (self.items)
		self.wait = -1;

	self.touch = door_touch;

// LinkDoors can't be done until all of the doors have been spawned, so
// the sizes can be detected properly.
	InitializeEntity(self, LinkDoors, INITPRIO_LINKDOORS);

	self.reset = door_reset;
}

/*QUAKED spawnfunc_func_door_rotating (0 .5 .8) ? START_OPEN BIDIR DOOR_DONT_LINK BIDIR_IN_DOWN x TOGGLE X_AXIS Y_AXIS
if two doors touch, they are assumed to be connected and operate as a unit.

TOGGLE causes the door to wait in both the start and end states for a trigger event.

BIDIR makes the door work bidirectional, so that the opening direction is always away from the requestor.
The usage of bidirectional doors requires two manually instantiated triggers (trigger_multiple), the one to open it in the other direction
must have set trigger_reverse to 1.
BIDIR_IN_DOWN will the door prevent from reopening while closing if it is triggered from the other side.

START_OPEN causes the door to move to its destination when spawned, and operate in reverse.  It is used to temporarily or permanently close off an area when triggered (not usefull for touch or takedamage doors).

"message"	is printed when the door is touched if it is a trigger door and it hasn't been fired yet
"angle"		determines the destination angle for opening. negative values reverse the direction.
"targetname"    if set, no touch field will be spawned and a remote button or trigger field activates the door.
"health"	if set, door must be shot open
"speed"		movement speed (100 default)
"wait"		wait before returning (3 default, -1 = never return)
"dmg"		damage to inflict when blocked (2 default)
"sounds"
0)	no sound
1)	stone
2)	base
3)	stone chain
4)	screechy metal
FIXME: only one sound set available at the time being
*/

void door_rotating_reset()
{
	self.angles = self.pos1;
	self.avelocity = '0 0 0';
	self.state = STATE_BOTTOM;
	self.think = func_null;
	self.nextthink = 0;
}

void door_rotating_init_startopen()
{
	self.angles = self.movedir;
	self.pos2 = '0 0 0';
	self.pos1 = self.movedir;
}


void spawnfunc_func_door_rotating()
{

	//if (!self.deathtype) // map makers can override this
	//	self.deathtype = " got in the way";

	// I abuse "movedir" for denoting the axis for now
	if (self.spawnflags & 64) // X (untested)
		self.movedir = '0 0 1';
	else if (self.spawnflags & 128) // Y (untested)
		self.movedir = '1 0 0';
	else // Z
		self.movedir = '0 1 0';

	if (self.angles_y==0) self.angles_y = 90;

	self.movedir = self.movedir * self.angles_y;
	self.angles = '0 0 0';

	self.max_health = self.health;
	self.avelocity = self.movedir;
	if not(InitMovingBrushTrigger())
		return;
	self.velocity = '0 0 0';
	//self.effects |= EF_LOWPRECISION;
	self.classname = "door_rotating";

	self.blocked = door_blocked;
	self.use = door_use;

    if(self.spawnflags & 8)
        self.dmg = 10000;

    if(self.dmg && (self.message == ""))
		self.message = "was squished";
    if(self.dmg && (self.message2 == ""))
		self.message2 = "was squished by";

    if (self.sounds > 0)
	{
		precache_sound ("plats/medplat1.wav");
		precache_sound ("plats/medplat2.wav");
		self.noise2 = "plats/medplat1.wav";
		self.noise1 = "plats/medplat2.wav";
	}

	if (!self.speed)
		self.speed = 50;
	if (!self.wait)
		self.wait = 1;
	self.lip = 0; // self.lip is used to remember reverse opening direction for door_rotating

	self.pos1 = '0 0 0';
	self.pos2 = self.movedir;

// DOOR_START_OPEN is to allow an entity to be lighted in the closed position
// but spawn in the open position
	if (self.spawnflags & DOOR_START_OPEN)
		InitializeEntity(self, door_rotating_init_startopen, INITPRIO_SETLOCATION);

	self.state = STATE_BOTTOM;

	if (self.health)
	{
		self.takedamage = DAMAGE_YES;
		self.event_damage = door_damage;
	}

	if (self.items)
		self.wait = -1;

	self.touch = door_touch;

// LinkDoors can't be done until all of the doors have been spawned, so
// the sizes can be detected properly.
	InitializeEntity(self, LinkDoors, INITPRIO_LINKDOORS);

	self.reset = door_rotating_reset;
}

/*
=============================================================================

SECRET DOORS

=============================================================================
*/

void() fd_secret_move1;
void() fd_secret_move2;
void() fd_secret_move3;
void() fd_secret_move4;
void() fd_secret_move5;
void() fd_secret_move6;
void() fd_secret_done;

const float SECRET_OPEN_ONCE = 1;		// stays open
const float SECRET_1ST_LEFT = 2;		// 1st move is left of arrow
const float SECRET_1ST_DOWN = 4;		// 1st move is down from arrow
const float SECRET_NO_SHOOT = 8;		// only opened by trigger
const float SECRET_YES_SHOOT = 16;	// shootable even if targeted

void fd_secret_use()
{
	float temp;
	string message_save;

	self.health = 10000;
	self.bot_attack = TRUE;

	// exit if still moving around...
	if (self.origin != self.oldorigin)
		return;

	message_save = self.message;
	self.message = ""; // no more message
	SUB_UseTargets();				// fire all targets / killtargets
	self.message = message_save;

	self.velocity = '0 0 0';

	// Make a sound, wait a little...

	if (self.noise1 != "")
		sound(self, CH_TRIGGER_SINGLE, self.noise1, VOL_BASE, ATTEN_NORM);
	self.nextthink = self.ltime + 0.1;

	temp = 1 - (self.spawnflags & SECRET_1ST_LEFT);	// 1 or -1
	makevectors(self.mangle);

	if (!self.t_width)
	{
		if (self.spawnflags & SECRET_1ST_DOWN)
			self.t_width = fabs(v_up * self.size);
		else
			self.t_width = fabs(v_right * self.size);
	}

	if (!self.t_length)
		self.t_length = fabs(v_forward * self.size);

	if (self.spawnflags & SECRET_1ST_DOWN)
		self.dest1 = self.origin - v_up * self.t_width;
	else
		self.dest1 = self.origin + v_right * (self.t_width * temp);

	self.dest2 = self.dest1 + v_forward * self.t_length;
	SUB_CalcMove(self.dest1, self.speed, fd_secret_move1);
	if (self.noise2 != "")
		sound(self, CH_TRIGGER_SINGLE, self.noise2, VOL_BASE, ATTEN_NORM);
}

void fd_secret_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	fd_secret_use();
}

// Wait after first movement...
void fd_secret_move1()
{
	self.nextthink = self.ltime + 1.0;
	self.think = fd_secret_move2;
	if (self.noise3 != "")
		sound(self, CH_TRIGGER_SINGLE, self.noise3, VOL_BASE, ATTEN_NORM);
}

// Start moving sideways w/sound...
void fd_secret_move2()
{
	if (self.noise2 != "")
		sound(self, CH_TRIGGER_SINGLE, self.noise2, VOL_BASE, ATTEN_NORM);
	SUB_CalcMove(self.dest2, self.speed, fd_secret_move3);
}

// Wait here until time to go back...
void fd_secret_move3()
{
	if (self.noise3 != "")
		sound(self, CH_TRIGGER_SINGLE, self.noise3, VOL_BASE, ATTEN_NORM);
	if (!(self.spawnflags & SECRET_OPEN_ONCE))
	{
		self.nextthink = self.ltime + self.wait;
		self.think = fd_secret_move4;
	}
}

// Move backward...
void fd_secret_move4()
{
	if (self.noise2 != "")
		sound(self, CH_TRIGGER_SINGLE, self.noise2, VOL_BASE, ATTEN_NORM);
	SUB_CalcMove(self.dest1, self.speed, fd_secret_move5);
}

// Wait 1 second...
void fd_secret_move5()
{
	self.nextthink = self.ltime + 1.0;
	self.think = fd_secret_move6;
	if (self.noise3 != "")
		sound(self, CH_TRIGGER_SINGLE, self.noise3, VOL_BASE, ATTEN_NORM);
}

void fd_secret_move6()
{
	if (self.noise2 != "")
		sound(self, CH_TRIGGER_SINGLE, self.noise2, VOL_BASE, ATTEN_NORM);
	SUB_CalcMove(self.oldorigin, self.speed, fd_secret_done);
}

void fd_secret_done()
{
	if (self.spawnflags&SECRET_YES_SHOOT)
	{
		self.health = 10000;
		self.takedamage = DAMAGE_YES;
		//self.th_pain = fd_secret_use;
	}
	if (self.noise3 != "")
		sound(self, CH_TRIGGER_SINGLE, self.noise3, VOL_BASE, ATTEN_NORM);
}

void secret_blocked()
{
	if (time < self.attack_finished_single)
		return;
	self.attack_finished_single = time + 0.5;
	//T_Damage (other, self, self, self.dmg, self.dmg, self.deathtype, DT_IMPACT, (self.absmin + self.absmax) * 0.5, '0 0 0', Obituary_Generic);
}

/*
==============
secret_touch

Prints messages
================
*/
void secret_touch()
{
	if not(other.iscreature)
		return;
	if (self.attack_finished_single > time)
		return;

	self.attack_finished_single = time + 2;

	if (self.message)
	{
		if (IS_CLIENT(other))
			centerprint (other, self.message);
		play2(other, "misc/talk.wav");
	}
}

void secret_reset()
{
	if (self.spawnflags&SECRET_YES_SHOOT)
	{
		self.health = 10000;
		self.takedamage = DAMAGE_YES;
	}
	setorigin(self, self.oldorigin);
	self.think = func_null;
	self.nextthink = 0;
}

/*QUAKED spawnfunc_func_door_secret (0 .5 .8) ? open_once 1st_left 1st_down no_shoot always_shoot
Basic secret door. Slides back, then to the side. Angle determines direction.
wait  = # of seconds before coming back
1st_left = 1st move is left of arrow
1st_down = 1st move is down from arrow
always_shoot = even if targeted, keep shootable
t_width = override WIDTH to move back (or height if going down)
t_length = override LENGTH to move sideways
"dmg"		damage to inflict when blocked (2 default)

If a secret door has a targetname, it will only be opened by it's botton or trigger, not by damage.
"sounds"
1) medieval
2) metal
3) base
*/

void spawnfunc_func_door_secret()
{
	/*if (!self.deathtype) // map makers can override this
		self.deathtype = " got in the way";*/

	if (!self.dmg)
		self.dmg = 2;

	// Magic formula...
	self.mangle = self.angles;
	self.angles = '0 0 0';
	self.classname = "door";
	if not(InitMovingBrushTrigger())
		return;
	self.effects |= EF_LOWPRECISION;

	self.touch = secret_touch;
	self.blocked = secret_blocked;
	self.speed = 50;
	self.use = fd_secret_use;
	IFTARGETED
	{
	}
	else
		self.spawnflags |= SECRET_YES_SHOOT;

	if(self.spawnflags&SECRET_YES_SHOOT)
	{
		self.health = 10000;
		self.takedamage = DAMAGE_YES;
		self.event_damage = fd_secret_damage;
	}
	self.oldorigin = self.origin;
	if (!self.wait)
		self.wait = 5;		// 5 seconds before closing

	self.reset = secret_reset;
	secret_reset();
}

/*QUAKED spawnfunc_func_fourier (0 .5 .8) ?
Brush model that moves in a pattern of added up sine waves, can be used e.g. for circular motions.
netname: list of <frequencymultiplier> <phase> <x> <y> <z> quadruples, separated by spaces; note that phase 0 represents a sine wave, and phase 0.25 a cosine wave (by default, it uses 1 0 0 0 1, to match func_bobbing's defaults
speed: how long one cycle of frequency multiplier 1 in seconds (default 4)
height: amplitude modifier (default 32)
phase: cycle timing adjustment (0-1 as a fraction of the cycle, default 0)
noise: path/name of looping .wav file to play.
dmg: Do this mutch dmg every .dmgtime intervall when blocked
dmgtime: See above.
*/

void func_fourier_controller_think()
{
	vector v;
	float n, i, t;

	self.nextthink = time + 0.1;
	if not (self.owner.active == ACTIVE_ACTIVE)
	{
		self.owner.velocity = '0 0 0';		
		return;
	}


	n = floor((tokenize_console(self.owner.netname)) / 5);
	t = self.nextthink * self.owner.cnt + self.owner.phase * 360;

	v = self.owner.destvec;

	for(i = 0; i < n; ++i)
	{
		makevectors((t * stof(argv(i*5)) + stof(argv(i*5+1)) * 360) * '0 1 0');
		v = v + ('1 0 0' * stof(argv(i*5+2)) + '0 1 0' * stof(argv(i*5+3)) + '0 0 1' * stof(argv(i*5+4))) * self.owner.height * v_forward_y;
	}

	if(self.owner.classname == "func_fourier") // don't brake stuff if the func_fourier was killtarget'ed
		// * 10 so it will arrive in 0.1 sec
		self.owner.velocity = (v - self.owner.origin) * 10;
}

void spawnfunc_func_fourier()
{
	entity controller;
	if (self.noise != "")
	{
		precache_sound(self.noise);
		soundto(MSG_INIT, self, CH_TRIGGER_SINGLE, self.noise, VOL_BASE, ATTEN_IDLE);
	}

	if (!self.speed)
		self.speed = 4;
	if (!self.height)
		self.height = 32;
	self.destvec = self.origin;
	self.cnt = 360 / self.speed;

	self.blocked = generic_plat_blocked;
	if(self.dmg && (self.message == ""))
		self.message = " was squished";
    if(self.dmg && (self.message2 == ""))
		self.message2 = "was squished by";
	if(self.dmg && (!self.dmgtime))
		self.dmgtime = 0.25;
	self.dmgtime2 = time;

	if(self.netname == "")
		self.netname = "1 0 0 0 1";

	if not(InitMovingBrushTrigger())
		return;

	self.active = ACTIVE_ACTIVE;

	// wait for targets to spawn
	controller = spawn();
	controller.classname = "func_fourier_controller";
	controller.owner = self;
	controller.nextthink = time + 1;
	controller.think = func_fourier_controller_think;
	self.nextthink = self.ltime + 999999999;
	self.think = SUB_NullThink; // for PushMove

	// Savage: Reduce bandwith, critical on e.g. nexdm02
	self.effects |= EF_LOWPRECISION;

	// TODO make a reset function for this one
}

// reusing some fields havocbots declared
.entity wp00, wp01, wp02, wp03;

.float targetfactor, target2factor, target3factor, target4factor;
.vector targetnormal, target2normal, target3normal, target4normal;

vector func_vectormamamam_origin(entity o, float t)
{
	vector v, p;
	float f;
	entity e;

	f = o.spawnflags;
	v = '0 0 0';

	e = o.wp00;
	if(e)
	{
		p = e.origin + t * e.velocity;
		if(f & 1)
			v = v + (p * o.targetnormal) * o.targetnormal * o.targetfactor;
		else
			v = v + (p - (p * o.targetnormal) * o.targetnormal) * o.targetfactor;
	}

	e = o.wp01;
	if(e)
	{
		p = e.origin + t * e.velocity;
		if(f & 2)
			v = v + (p * o.target2normal) * o.target2normal * o.target2factor;
		else
			v = v + (p - (p * o.target2normal) * o.target2normal) * o.target2factor;
	}

	e = o.wp02;
	if(e)
	{
		p = e.origin + t * e.velocity;
		if(f & 4)
			v = v + (p * o.target3normal) * o.target3normal * o.target3factor;
		else
			v = v + (p - (p * o.target3normal) * o.target3normal) * o.target3factor;
	}

	e = o.wp03;
	if(e)
	{
		p = e.origin + t * e.velocity;
		if(f & 8)
			v = v + (p * o.target4normal) * o.target4normal * o.target4factor;
		else
			v = v + (p - (p * o.target4normal) * o.target4normal) * o.target4factor;
	}

	return v;
}

void func_vectormamamam_controller_think()
{
	self.nextthink = time + 0.1;

	if not (self.owner.active == ACTIVE_ACTIVE)
	{
		self.owner.velocity = '0 0 0';		
		return;
	}

	if(self.owner.classname == "func_vectormamamam") // don't brake stuff if the func_vectormamamam was killtarget'ed
		self.owner.velocity = (self.owner.destvec + func_vectormamamam_origin(self.owner, 0.1) - self.owner.origin) * 10;
}

void func_vectormamamam_findtarget()
{
	if(self.target != "")
		self.wp00 = find(world, targetname, self.target);

	if(self.target2 != "")
		self.wp01 = find(world, targetname, self.target2);

	if(self.target3 != "")
		self.wp02 = find(world, targetname, self.target3);

	if(self.target4 != "")
		self.wp03 = find(world, targetname, self.target4);

	if(!self.wp00 && !self.wp01 && !self.wp02 && !self.wp03)
		objerror("No reference entity found, so there is nothing to move. Aborting.");

	self.destvec = self.origin - func_vectormamamam_origin(self, 0);

	entity controller;
	controller = spawn();
	controller.classname = "func_vectormamamam_controller";
	controller.owner = self;
	controller.nextthink = time + 1;
	controller.think = func_vectormamamam_controller_think;
}

void spawnfunc_func_vectormamamam()
{
	if (self.noise != "")
	{
		precache_sound(self.noise);
		soundto(MSG_INIT, self, CH_TRIGGER_SINGLE, self.noise, VOL_BASE, ATTEN_IDLE);
	}

	if(!self.targetfactor)
		self.targetfactor = 1;

	if(!self.target2factor)
		self.target2factor = 1;

	if(!self.target3factor)
		self.target3factor = 1;

	if(!self.target4factor)
		self.target4factor = 1;

	if(vlen(self.targetnormal))
		self.targetnormal = normalize(self.targetnormal);

	if(vlen(self.target2normal))
		self.target2normal = normalize(self.target2normal);

	if(vlen(self.target3normal))
		self.target3normal = normalize(self.target3normal);

	if(vlen(self.target4normal))
		self.target4normal = normalize(self.target4normal);

	self.blocked = generic_plat_blocked;
	if(self.dmg && (self.message == ""))
		self.message = " was squished";
    if(self.dmg && (self.message == ""))
		self.message2 = "was squished by";
	if(self.dmg && (!self.dmgtime))
		self.dmgtime = 0.25;
	self.dmgtime2 = time;

	if(self.netname == "")
		self.netname = "1 0 0 0 1";

	if not(InitMovingBrushTrigger())
		return;

	// wait for targets to spawn
	self.nextthink = self.ltime + 999999999;
	self.think = SUB_NullThink; // for PushMove

	// Savage: Reduce bandwith, critical on e.g. nexdm02
	self.effects |= EF_LOWPRECISION;

	self.active = ACTIVE_ACTIVE;

	InitializeEntity(self, func_vectormamamam_findtarget, INITPRIO_FINDTARGET);
}

void conveyor_think()
{
	entity e;

	// set myself as current conveyor where possible
	for(e = world; (e = findentity(e, conveyor, self)); )
		e.conveyor = world;

	if(self.state)
	{
		for(e = findradius((self.absmin + self.absmax) * 0.5, vlen(self.absmax - self.absmin) * 0.5 + 1); e; e = e.chain)
			if(!e.conveyor.state)
				if(isPushable(e))
				{
					vector emin = e.absmin;
					vector emax = e.absmax;
					if(self.solid == SOLID_BSP)
					{
						emin -= '1 1 1';
						emax += '1 1 1';
					}
					if(boxesoverlap(emin, emax, self.absmin, self.absmax)) // quick
						if(WarpZoneLib_BoxTouchesBrush(emin, emax, self, e)) // accurate
							e.conveyor = self;
				}

		for(e = world; (e = findentity(e, conveyor, self)); )
		{
			if(IS_CLIENT(e)) // doing it via velocity has quite some advantages
				continue; // done in SV_PlayerPhysics

			setorigin(e, e.origin + self.movedir * sys_frametime);
			move_out_of_solid(e);
			UpdateCSQCProjectile(e);
			/*
			// stupid conveyor code
			tracebox(e.origin, e.mins, e.maxs, e.origin + self.movedir * sys_frametime, MOVE_NORMAL, e);
			if(trace_fraction > 0)
				setorigin(e, trace_endpos);
			*/
		}
	}

	self.nextthink = time;
}

void conveyor_use()
{
	self.state = !self.state;
}

void conveyor_reset()
{
	self.state = (self.spawnflags & 1);
}

void conveyor_init()
{
	if (!self.speed)
		self.speed = 200;
	self.movedir = self.movedir * self.speed;
	self.think = conveyor_think;
	self.nextthink = time;
	IFTARGETED
	{
		self.use = conveyor_use;
		self.reset = conveyor_reset;
		conveyor_reset();
	}
	else
		self.state = 1;
}

void spawnfunc_trigger_conveyor()
{
	SetMovedir();
	EXACTTRIGGER_INIT;
	conveyor_init();
}

void spawnfunc_func_conveyor()
{
	SetMovedir();
	InitMovingBrushTrigger();
	self.movetype = MOVETYPE_NONE;
	conveyor_init();
}
