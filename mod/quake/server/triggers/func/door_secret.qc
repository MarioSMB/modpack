#ifdef SVQC

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
	
	_sound(this, CH_TRIGGER_SINGLE, this.noise1, 1, ATTN_NORM);
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
	SUB_CalcMove(this, this.dest1, TSPEED_LINEAR, this.speed, fd_secret_move1);
	_sound(this, CH_TRIGGER_SINGLE, this.noise2, 1, ATTN_NORM);
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
	_sound(this, CH_TRIGGER_SINGLE, this.noise3, 1, ATTN_NORM);
}

// Start moving sideways w/sound...
void fd_secret_move2(entity this)
{
	_sound(this, CH_TRIGGER_SINGLE, this.noise2, 1, ATTN_NORM);
	SUB_CalcMove(this, this.dest2, TSPEED_LINEAR, this.speed, fd_secret_move3);
}

// Wait here until time to go back...
void fd_secret_move3(entity this)
{
	_sound(this, CH_TRIGGER_SINGLE, this.noise3, 1, ATTN_NORM);
	if(!(this.spawnflags & SECRET_OPEN_ONCE))
	{
		this.nextthink = this.ltime + this.wait;
		setthink(this, fd_secret_move4);
	}
}

// Move backward...
void fd_secret_move4(entity this)
{
	_sound(this, CH_TRIGGER_SINGLE, this.noise2, 1, ATTN_NORM);
	SUB_CalcMove(this, this.dest1, TSPEED_LINEAR, this.speed, fd_secret_move5);		
}

// Wait 1 second...
void fd_secret_move5(entity this) 
{
	this.nextthink = this.ltime + 1.0;
	setthink(this, fd_secret_move6);
	_sound(this, CH_TRIGGER_SINGLE, this.noise3, 1, ATTN_NORM);
}

void fd_secret_move6(entity this)
{
	_sound(this, CH_TRIGGER_SINGLE, this.noise2, 1, ATTN_NORM);
	SUB_CalcMove(this, this.oldorigin, TSPEED_LINEAR, this.speed, fd_secret_done);
}

void fd_secret_done(entity this)
{
	if(!this.targetname || this.targetname == "" || (this.spawnflags & SECRET_YES_SHOOT))
	{
		this.health = 10000;
		this.takedamage = DAMAGE_YES;
		this.th_pain = fd_secret_pain;	
	}
	_sound(this, CH_TRIGGER_SINGLE, this.noise3, 1, ATTN_NORM);
}

void secret_blocked(entity this, entity blocker)
{
	if(time < this.attack_finished)
		return;
	this.attack_finished = time + 0.5;
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
		_sound(toucher, CH_PLAYER, QUAKE_TALKSOUND, 1, ATTN_NORM);
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
	else if(this.sounds == 2)
	{
		precache_sound("doors/airdoor1.wav");
		precache_sound("doors/airdoor2.wav");
		this.noise2 = "doors/airdoor1.wav";
		this.noise1 = "doors/airdoor2.wav";
		this.noise3 = "doors/airdoor2.wav";
	}
	else if(this.sounds == 3)
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
	this.classname = "door";
	if (!InitMovingBrushTrigger(this)) return;
	this.effects |= EF_LOWPRECISION;

	settouch(this, secret_touch);
	setblocked(this, secret_blocked);
	this.speed = 50;
	this.use = fd_secret_use;
	if(!this.targetname || this.targetname == "" || (this.spawnflags & SECRET_YES_SHOOT))
	{
		this.health = 10000;
		this.takedamage = DAMAGE_YES;
		this.th_pain = fd_secret_pain;
		this.th_die = fd_secret_die;
	}
	this.oldorigin = this.origin;
	if(!this.wait)
		this.wait = 5;		// 5 seconds before closing
}

#endif
