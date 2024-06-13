#ifdef SVQC

const int FUNC_TRAIN_NONSOLID = 1;

const int TRAIN_INHERIT = 1;
const int TRAIN_TOGGLE = 2;
const int TRAIN_SMOOTHSPEED = 4;

.entity buddy;

.bool starton;

spawnfunc(func_train_point);
void train_wait(entity this);
void train_use(entity this, entity actor, entity trigger);
void train_next(entity this);

entity findunlocked(entity start, .string fld, string match)
{
	entity head = find(start, fld, match);
	while(head)
	{
		if(!(head.customflags & CFL_LOCKED))
			break;
		head = find(head, fld, match);
	}
	return head;
}

entity findunlockedtarget(entity e, entity start)
{
	entity head = NULL;
	if(e.target && e.target != "")
		head = findunlocked(start, targetname, e.target);
	if(head)
		return head;
	
	if(e.target2 && e.target2 != "")
		head = findunlocked(start, targetname, e.target2);
	if(head)
		return head;
	
	if(e.target3 && e.target3 != "")
		head = findunlocked(start, targetname, e.target3);
	if(head)
		return head;
	
	if(e.target4 && e.target4 != "")
		return findunlocked(start, targetname, e.target4);
	return NULL;
}

void train_sounds(entity this)
{
	if(this.sounds == 0)
	{
		if(!this.noise)
			this.noise = ("misc/null.wav");
		if(!this.noise1)
			this.noise1 = ("misc/null.wav");
		precache_sound(this.noise);
		precache_sound(this.noise1);
	}

	if(this.sounds == 1)
	{
		this.noise = ("plats/train2.wav");
		precache_sound("plats/train2.wav");
		this.noise1 = ("plats/train1.wav");
		precache_sound("plats/train1.wav");
	}
	if(this.sounds == 2)
	{
		precache_sound("plats/plat1.wav");
		precache_sound("plats/plat2.wav");
		this.noise1 = "plats/plat1.wav";
		this.noise = "plats/plat2.wav";
	}

}

/*FGD
@baseclass = TrainSounds [
	sounds(choices) : "Sound" : 1 =
	[
		0: "Silent/Override"
		1: "Ratchet Metal"
		2: "Base Lift"
	]
]
@baseclass base(Appearflags, Targetname, TrainSounds, Func, AltTarget) = Train [
	speed(integer) : "Speed (units per second)" : 64
	target(target_source) : "Target to start at"
	dmg(integer) : "Damage on block" : 2
	noise(string) : "Override stop sound"
	noise1(string) : "Override move sound"
	pausetime(string) : "Default wait time" : "0.1"
]
*/

void flytrain_ghost_die(entity this)
{
	if(this.owner.th_melee)
		this.owner.th_melee(this.owner);
	else
		delete(this.owner);
	delete(this);
}

void flytrain_ghost_resume(entity this)
{
	if(this.state == STATE_OFF)	// already deactivated
		return;	
	if(this.pos2)
		// we were stopped along a bezier curve, resume with saved values
		SUB_CalcMoveCurveSeg(this);
	else
		SUB_CalcMove(this, this.enemy.origin - this.movedir, TSPEED_LINEAR, this.speed, this.th_stand);
}

void flytrain_ghost_blocked(entity this, entity blocker)
{
	if(this.state == STATE_OFF)	// already deactivated
		return;	
	this.velocity = '0 0 0';
	setthink(this, flytrain_ghost_resume);
	this.nextthink = this.ltime + 0.05;
}

// if the flytrain is blocked, it has to halt its buddy's movement and schedule it to restart immediately
void flytrain_blocked(entity this, entity blocker)
{
	if(this.buddy.state == STATE_ON)
		flytrain_ghost_blocked(this.buddy, blocker);

	if(time < this.attack_finished)
		return;
	this.attack_finished = time + this.dmgtime;
	T_Damage(blocker, this, this, this.dmg, DEATH_CRUSH.m_id);
}

void flytrain_killed(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(this.customflags & CFL_LOCKED)
		return;
	this.health = this.max_health;
	train_use(this.buddy, attacker, this);
}

void flytrain_think(entity this)
{
	this.takedamage = this.buddy.takedamage;
	
	// if the ghost train hits a speed -1 teleport corner we have to teleport with it, not zoom to it
	if(this.buddy.teleport_time)
	{
		this.buddy.teleport_time = 0;
		setorigin(this, this.buddy.origin - this.movedir);
		this.velocity = this.buddy.velocity;
	}
	else
	{
		// rosette movement looks more orbital than the original bounce of random offsets
		float t = this.ltime + this.lip;
		vector ang = '0 0 0';
		ang_y = (sin(this.dest_x * t) + cos(this.dest_y * t)) * 90 + t;
		float d = cos(t * this.dest_z);
		ang_z = d * 180;
		makevectors(ang);
		
		this.pos1 = v_forward * this.width * d;
		this.pos1_z = v_right_z * this.height;
		
		vector delta = (this.buddy.origin + this.pos1) - this.origin - this.movedir;
		vector wishvel = this.buddy.velocity + delta;
		this.velocity = (this.velocity * 4 + wishvel) * 0.2;
	}
	
	this.nextthink = this.ltime + 0.05;
}

void flytrain_init(entity this)
{
	setorigin(this, this.buddy.origin - this.movedir);
	setthink(this, flytrain_think);
	flytrain_think(this);
}

void flytrain_setup(entity this)
{
	// spawn a nonsolid point ent to follow our path sensibly and 
	//	handle all train-like logic, bc it's a func_train
	// we shadow it at all times with floaty drifty movement to keep 
	//	that logic separate from train behavior and allow us to sludge
	//	the velocity over a few frames for rubber-bandy motion without
	//	colliding with state changes
	this.buddy = spawn();
	this.buddy.spawnflags = this.spawnflags;
	this.buddy.spawnflags |= TRAIN_INHERIT; // flytrains always inherit speed
	this.buddy.spawnflags |= TRAIN_SMOOTHSPEED; // make it smoothed as well for less jank
	this.buddy.speed = this.speed;
	this.buddy.starton = this.starton;
	if(!this.dmg)
		this.dmg = 2;
	if(!this.dmgtime)
		this.dmgtime = 0.5;
	this.buddy.pausetime = this.pausetime;
	this.buddy.health = this.health;
	this.buddy.sounds = this.sounds;
	this.buddy.solid = -1;
	if(!this.target || this.target == "")
	{
		this.buddy.enemy = new(path_corner);
		setorigin(this.buddy.enemy, this.origin + this.movedir);
		this.buddy.enemy.wait = -1;		
	}
	this.buddy.target = this.target;
	this.buddy.target2 = this.target2;
	this.buddy.target3 = this.target3;
	this.buddy.target4 = this.target4;
	this.buddy.killtarget = this.killtarget;

	this.buddy.targetname = this.targetname;
	this.buddy.owner = this;

	this.buddy.spawnfunc_checked = true;
	spawnfunc_func_train_point(this.buddy);
	this.buddy.classname = "func_flytrain_ghost";
	this.buddy.th_stand = train_wait;
	this.buddy.th_melee = flytrain_ghost_die;

	if(!this.width)
		this.width = 8;
	if(!this.height)
		this.height = 8;
	this.max_health = 0;

	setblocked(this, flytrain_blocked);
	this.solid = zeroconvertdefault(this.solid, SOLID_BSP);
	if(!this.solid)
		set_movetype(this, MOVETYPE_FAKEPUSH);
	else
	{
		set_movetype(this, MOVETYPE_PUSH);
		if(this.health)
		{
			this.max_health = this.health;
			this.th_die = flytrain_killed;
			this.takedamage = DAMAGE_YES;
		}
	}
	
	this.dest_x = 3 + random();
	this.dest_y = 1 + random();
	this.dest_z = 4 + random();
	if(this.speed2 <= 0)
		this.speed2 = 10;
	this.dest *= this.speed2;
	this.lip = random() * 20;
	
	setthink(this, flytrain_init);	// wait for buddy to call train_find
	this.nextthink = this.ltime + 0.25; // magic amount of time :|
}

/*QUAKED func_flytrain (0 .5 .8) ? - TOGGLE
Acts as a func_train with PATH_SPEED and SMOOTH_SPEED set, with additional random motion and and gentle smoothing at stops, starts, and hard corners.

"width"		Horizontal drift range, default 8 (-1 for 0)
"height"	Vertical drift range, default 8 (-1 for 0)
"lip"		Length of 'leash', default 64 (increase if train jumps around at high speeds)
"sounds"
0) none, or, set your own with 'noise' (stop sound) and 'noise1' (move sound)
1) ratchet metal
2) base plat

Alt Target Pattern: 'target' selects path start, 'target2' on each pathcorner arrival, 'target3' on each departure, 'target4' on termination
*/
/*FGD
@baseclass base(Train) = Flytrain [
	width(string) : "Horizontal drift range" : "8"
	height(string) : "Vertical drift range" : "8"
]
@SolidClass base(Flytrain) = func_flytrain : 
"Acts as a func_train with PATH_SPEED and SMOOTH_SPEED set, with additional random motion and and gentle smoothing at stops, starts, and hard corners. Will fire all targets of a pathcorner on arrival, but does not normally fire its own targets.

Alt Target Pattern: 'target' selects path start, 'target2' on each pathcorner arrival, 'target3' on each departure, 'target4' on termination"
[
	width(string) : "Horizontal drift range" : "8"
	height(string) : "Vertical drift range" : "8"
]
*/
spawnfunc(func_flytrain)
{
	precache_model(this.model);
	_setmodel(this, this.model);
	setsize(this, this.mins, this.maxs);
	this.movedir = (this.mins + this.maxs) * 0.5;
	
	flytrain_setup(this);
}

/*QUAKED func_flytrain_point (0 .5 .8) (-8 -8 -8) (8 8 8) - TOGGLE
Acts as a func_train with PATH_SPEED and SMOOTH_SPEED set, with additional random motion and and gentle smoothing at stops, starts, and hard corners.

"model"		model to use
"width"		Horizontal drift range, default 8 (-1 for 0)
"height"	Vertical drift range, default 8 (-1 for 0)
"lip"		Length of 'leash', default 64 (increase if train jumps around at high speeds)
"sounds"
0) none, or, set your own with 'noise' (stop sound) and 'noise1' (move sound)
1) ratchet metal
2) base plat

Alt Target Pattern: 'target' selects path start, 'target2' on each pathcorner arrival, 'target3' on each departure, 'target4' on termination
*/
/*FGD
@PointClass base(Flytrain) size(16 16 16) = func_flytrain_point : 
"Acts as a func_train with PATH_SPEED and SMOOTH_SPEED set, with additional random motion and and gentle smoothing at stops, starts, and hard corners. Will fire all targets of a pathcorner on arrival, but does not normally fire its own targets.

Alt Target Pattern: 'target' selects path start, 'target2' on each pathcorner arrival, 'target3' on each departure, 'target4' on termination"
[
	model(string) : "Model to use"
]
*/
spawnfunc(func_flytrain_point)
{
	precache_model(this.model);
	_setmodel(this, this.model);
	setsize(this, this.mins, this.maxs);
	this.classname = "func_flytrain";
	this.movedir = '0 0 0';
	
	flytrain_setup(this);
}

//============================================================================

void train_blocked(entity this, entity blocker)
{
	if(time < this.attack_finished)
		return;
	this.attack_finished = time + this.dmgtime;
	T_Damage(blocker, this, this, this.dmg, DEATH_CRUSH.m_id);
}

void train_killed(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(this.customflags & CFL_LOCKED)
		return;
	this.health = this.max_health;
	train_use(this, attacker, NULL);
}

void train_lock(entity this, bool unlock)
{
	if(unlock)
	{
		this.customflags &= ~CFL_LOCKED;
		if(this.max_health)
		{
			this.health = this.max_health;
			this.takedamage = DAMAGE_YES;
		}
	}
	else
	{
		this.customflags |= CFL_LOCKED;
		this.takedamage = DAMAGE_NO;
	}
}

void train_off(entity this)
{
	this.state = STATE_OFF;
	if(this.customflags & CFL_LOCKED)
		return;
	if(this.max_health)
	{
		this.health = this.max_health;
		this.takedamage = DAMAGE_YES;
	}
}
void train_on(entity this)
{
	this.state = STATE_ON;
	if(this.max_health && !(this.spawnflags & TRAIN_TOGGLE))
		this.takedamage = DAMAGE_NO;
}

void train_use(entity this, entity actor, entity trigger)
{
	if((this.spawnflags & TRAIN_TOGGLE) && (this.origin + this.movedir) != this.enemy.origin)
	{
		if(this.state == STATE_ON)
		{
			train_off(this);
			this.velocity = '0 0 0';
			this.nextthink = 0;
			_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
		}
		else
		{
			train_on(this);
			_sound(this, CH_TRIGGER_SINGLE, this.noise1, 1, ATTN_NORM);
			if(this.pos2 != '0 0 0')
				// we were stopped along a bezier curve, resume with saved values
				SUB_CalcMoveCurveSeg(this);
			else
				SUB_CalcMove(this, this.enemy.origin - this.movedir, TSPEED_LINEAR, this.speed, this.th_stand);
		}
		return;
	}

	if(this.state == STATE_ON)	// already activated
		return;	
	train_next(this);
}

entity get_closest_client(entity this)
{
	float chosen_dist = 0;
	entity chosen = NULL;
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		float mydist = vlen2(it.origin - this.origin);
		if(!chosen || mydist < chosen_dist)
		{
			chosen = it;
			chosen_dist = mydist;
		}
	});

	return chosen;
}

void train_wait(entity this)	// arrival at a pathcorner
{
	entity corner = this.enemy;
	if(corner.wait)
		this.wait = corner.wait;
	else
		this.wait = this.pausetime;

	SUB_UseTargets_CopperAlt(this, this.enemy, NULL, BIT(1) | BIT(3) | BIT(4));

	if(this.wait == -1)
	{
		train_off(this);
		this.use = train_use;
		_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
	}
	else if(this.wait > 0)
	{
		train_off(this);	// allow triggering while waiting
		setthink(this, train_next);
		this.nextthink = this.ltime + this.wait;
		if(this.wait > 0.1)
			_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
	}
	else 	// this.wait is 0 or a garbage value
	{
		train_next(this);
	}
	
	// trains now fire their pathcorners' targets on arrival
	// if a player is riding the train, treat them as activator
	// OR NOT, your silly function was changing activator to the train
	entity player = get_closest_client(this);
	SUB_UseTargets(corner, player, NULL);
	// fire them after sorting corner wait stuff, in case the corner triggers
	// the train itself (useful for wait-locking a pathcorner with a relay)
}

// quick bezier length approximation (2/3 chord len + 1/3 perimeter)
float bez_lenApprox(vector start, vector ctrl, vector end)
{
	float chord = vlen(start - end);
	float peri = vlen(start - ctrl) + vlen(ctrl - end) + chord;

	return 2 * chord / 3 + peri / 3;
}

void train_next(entity this) // departure for next pathcorner
{
	entity ctrl = NULL;
	float segs;
	entity corner = findunlockedtarget(this.enemy, NULL);
	if(!corner)
	{
		LOG_DEBUG("train_next: no next target");
		// .th_melee is a train's "expire at end of path" function, because .th_die
		// has to be reserved for shootable trains to work with T_Damage()/Killed()
		if(this.th_melee)
		{
			this.th_melee(this);
			SUB_UseTargets_CopperAlt(this, this.enemy, NULL, BIT(1) | BIT(2) | BIT(3));
		}
		else
			delete(this);
		return;
	}
	this.oldenemy = this.enemy;
	if(corner.spawnflags & 16)
	{
		ctrl = corner;
		corner = findunlockedtarget(ctrl, NULL);
		if(!corner)
		{
			LOG_DEBUG("train_next: no next target after curve point");
			if(this.th_melee)
			{
				this.th_melee(this);
				SUB_UseTargets_CopperAlt(this, this.enemy, NULL, BIT(1) | BIT(2) | BIT(3));
			}
			else
				delete(this);
			return;
		}
	}
	
	this.enemy = corner;
	SUB_UseTargets_CopperAlt(this, this.enemy, NULL, BIT(1) | BIT(2) | BIT(4));
	train_on(this);
	
	if(this.oldenemy.speed == -1)
	{
		setorigin(this, corner.origin - this.movedir);
		this.teleport_time = time;
		if(this.th_stand)
			this.th_stand(this);
		return;
	}
	else if(this.oldenemy.speed > 0 && (this.spawnflags & TRAIN_INHERIT))
		this.speed = this.oldenemy.speed;

	_sound(this, CH_TRIGGER_SINGLE, this.noise1, 1, ATTN_NORM);
	
	if(ctrl)
	{
		float dspeed;
		if((this.spawnflags & TRAIN_INHERIT) && (this.spawnflags & TRAIN_SMOOTHSPEED) && corner.speed > 0)
			dspeed = corner.speed;
		else
			dspeed = this.speed;
		
		if(ctrl.count)
			segs = ctrl.count;
		else
			// chop the curve into roughly 200ms segments
			segs = ceil(5 * bez_lenApprox(this.origin, ctrl.origin, corner.origin) / ((this.speed + dspeed) / 2));

		SUB_CalcMoveCurve(this, corner.origin - this.movedir, ctrl.origin - this.movedir, segs, this.speed, dspeed, this.th_stand);
		return;
	}
	
	if((this.spawnflags & TRAIN_INHERIT) && (this.spawnflags & TRAIN_SMOOTHSPEED) && this.enemy.speed > 0)
	{
		// 'curved' motion in a straight line, for the speed stepping
		vector travel = (corner.origin - this.movedir) - this.origin;
		segs = max( 2, floor( vlen(travel) / 64 ) );	// pick an intelligent segment count
		SUB_CalcMoveCurve(this, corner.origin - this.movedir, this.origin + travel * 0.5, segs, this.speed, this.enemy.speed, this.th_stand);
	}
	else
		SUB_CalcMove(this, corner.origin - this.movedir, TSPEED_LINEAR, this.speed, this.th_stand);
}

void func_train_find(entity this)
{
	if(!this.enemy)
		this.enemy = findunlockedtarget(this, NULL);

	//this.target = this.enemy.target;
	setorigin(this, this.enemy.origin - this.movedir);
	if((this.spawnflags & TRAIN_INHERIT) && this.enemy.speed > 0)
		this.speed = this.enemy.speed;
	if(!this.targetname || this.targetname == "" || this.starton)
	{	// not triggered, so start immediately
		train_wait(this);	// still go through wait in case we start at a wait -1 corner
	}
}

void func_train_setup(entity this)
{
	if(!this.speed)
		this.speed = 100;
	if((!this.target || this.target == "") && !this.enemy)
	{
		objerror(this, "train entity without a target");
		return;
	}

	if(!this.dmg)
		this.dmg = 2;
	if(!this.dmgtime)
		this.dmgtime = 0.5;
	this.pausetime = zeroconvertdefault(this.pausetime, 0.1);
	this.wait = 0;	// this is american mcgee's fault

	train_sounds(this);

//	this.cnt = 1;
	this.solid = zeroconvertdefault(this.solid, SOLID_BSP);
	if(!this.solid)
		set_movetype(this, MOVETYPE_FAKEPUSH);
	else
		set_movetype(this, MOVETYPE_PUSH);
	if((this.spawnflags & FUNC_TRAIN_NONSOLID) && substring(world.model, 0, 7) == "maps/mg") // hack needed because this flag is set on vanilla maps!
		this.solid = SOLID_NOT; // TODO: MOVETYPE_FAKEPUSH?
	else
		setblocked(this, train_blocked);
	this.use = train_use;
	this.lock = train_lock;
	this.classname = "train";
	
	this.max_health = 0;
	if(this.health)
	{
		this.max_health = this.health;
		this.th_die = train_killed;
		this.takedamage = DAMAGE_YES;
	}
	train_off(this);

	// start trains on the second frame, to make sure their targets have had
	// a chance to spawn
	setthink(this, func_train_find);
	this.nextthink = this.ltime + 0.1;
}

/*QUAKED func_train (0 .5 .8) ? PATH_SPEED TOGGLE SMOOTHSPEED
Trains are moving platforms that players can ride. Its origin is the min corner of the train. 
The train spawns at the first target it is pointing at. If the train is the target of a button or trigger, it will not begin moving until activated.
A train will fire all targets of a pathcorner on arrival.

Keys:
"speed"	default 100
"dmg"	default	2
"sounds"
	0) none, or, set your own with 'noise' (stop sound) and 'noise1' (move sound)
	1) ratchet metal
	2) base plat
"pausetime"	pausetime at a pathcorner that doesn't specify a wait, default 0.1, -1 for continuous motion
"health" allow the train to be shot to trigger it whenever it could normally be triggered (toggle spawnflag applies)

Spawnflags:
PATH_SPEED: train will inherit 'speed' value from path_corners as it reaches them
If a path_corner's speed is -1, the func_train's move when LEAVING that corner will be to snap instantly to the next corner.
TOGGLE: allow starting/stopping motion anywhere on its path (default is to ignore triggerings when in motion)
SMOOTH_SPEED: if PATH_SPEED, train will smoothly blend to its destination's 'speed' as it travels to it

Alt Target Pattern: 'target' selects path start, 'target2' on each pathcorner arrival, 'target3' on each departure, 'target4' on termination
*/
/*FGD
@SolidClass base(Train) = func_train : "Moving platform that players can ride. 
Its origin is the min corner of the train. 
The train spawns at the first target it is pointing at. If the train is the target of a button or trigger, it will not begin moving until activated.
Will fire all targets of a pathcorner on arrival, but does not normally fire its own targets.


If 'Speed from path' is set, the train will inherit the 'speed' value from path_corners as it reaches them. If 'blend speed smoothly' is also set, the train will instead smoothly blend to its destination's 'speed' as it travels to it.
If a path_corner's speed is -1, the func_train's move when LEAVING that corner will be to snap instantly to the next corner.
The 'Toggle' spawnflag allows starting and stopping the motion anywhere on the train's path (default is to ignore triggerings when in motion).
Setting 'health' will allow the train to be shot to trigger it whenever it could normally be triggered (toggle spawnflag applies). 

Alt Target Pattern: 'target' selects path start, 'target2' on each pathcorner arrival, 'target3' on each departure, 'target4' on termination"
[
	spawnflags(Flags) = [
		1 : "Speed from path" : 0
		2 : "Toggle" : 0
		4 : "Blend speed smoothly" : 0
	]
	health(integer) : "Health (shootable if > 0)"
]
*/
spawnfunc(func_train)
{	
	func_train_setup(this);
	
	this.th_stand = train_wait;
	
	precache_model(this.model);
	_setmodel(this, this.model);
	setsize(this, this.mins, this.maxs);
	setorigin(this, this.origin);
	this.movedir = this.mins;
}

/*QUAKED func_train_point (0 .5 .8) (-8 -8 -8) (8 8 8) PATH_SPEED
Trains are moving platforms that players can ride.
The targets origin specifies the min point of the train at each corner. The train spawns at the first target it is pointing at.
If the train is the target of a button or trigger, it will not begin moving until activated.
A train will fire all targets of a pathcorner on arrival.
Keys:
"model" model to use
"speed"	default 100
"dmg"	default	2
"sounds"
	0) none, or, set your own with 'noise' (stop sound) and 'noise1' (move sound)
	1) ratchet metal
	2) base plat
"pausetime"	pausetime at a pathcorner that doesn't specify a wait, default 0.1, -1 for continuous motion

Spawnflags:
PATH_SPEED: train will inherit 'speed' value from path_corners as it reaches them

Alt Target Pattern: 'target' selects path start, 'target2' on each pathcorner arrival, 'target3' on each departure, 'target4' on termination
*/
/*FGD
@PointClass base(Train) = func_train_point : "Moving platform that players can ride. 
The point entity is the origin, even if a model is specified.
The train spawns at the first target it is pointing at. If the train is the target of a button or trigger, it will not begin moving until activated.
Will fire all targets of a pathcorner on arrival, but does not normally fire its own targets.

If 'Speed from path' is set, the train will inherit the 'speed' value from path_corners as it reaches them. If 'blend speed smoothly' is also set, the train will instead smoothly blend to its destination's 'speed' as it travels to it.
If a path_corner's speed is -1, the func_train's move when LEAVING that corner will be to snap instantly to the next corner.
The 'Toggle' spawnflag allows starting and stopping the motion anywhere on the train's path (default is to ignore triggerings when in motion).

Alt Target Pattern: 'target' selects path start, 'target2' on each pathcorner arrival, 'target3' on each departure, 'target4' on termination"
[
	model(string) : "Model to use"
	spawnflags(Flags) = [
		1 : "Speed from path" : 0
		2 : "Toggle" : 0
		4 : "Blend speed smoothly" : 0
	]
]
*/
spawnfunc(func_train_point)
{	
	func_train_setup(this);
	
	this.th_stand = train_wait;

	if(!this.model || this.model == "")
		this.model = "null";
	precache_model(this.model);
	_setmodel(this, this.model);
	setsize(this, this.mins, this.maxs);
	setorigin(this, this.origin);
	this.movedir = '0 0 0';
}

void teleball_init(entity this, entity actor, entity trigger)
{
	if(this.spawnflags & 1)
	{
		this.spawnflags &= ~1;
		_setmodel(this, "progs/teleport.mdl");
		setsize(this, '0 0 0', '0 0 0');	
	}
	
	this.avelocity = 50 * vec3(crandom(), crandom(), crandom());
	this.use = func_null;
}

/*QUAKED misc_teleporttrain(0 .5 .8)(-8 -8 -8)(8 8 8)
This is used for the final bos
*/
spawnfunc(misc_teleporttrain)
{
	precache_model2("progs/teleport.mdl");
	
	// emulate old "spawn where you were placed and then move to the first pathcorner"
	// behavior so udob_end isn't broken by the first path_corner's targets not firing
	setorigin(this, this.origin);
	entity path = spawn();
	setorigin(path, this.origin);
	path.classname = "path_corner";
	path.targetname = strzone(vtos(this.origin));	// dumb, but unique!
	path.target = this.target;
	this.target = path.targetname;
	// do this first so train_find finds it
	
	if(!this.speed)
		this.speed = 100;
	if(this.speed2)
		this.speed2 /= 6;	// old teletrains have old dumb speed2 values from old dumb fly code
	this.pausetime = -1;
	this.solid = -1;
	
	flytrain_setup(this);
	set_movetype(this, MOVETYPE_FAKEPUSH);	// for avelocity
	
	if(!(this.spawnflags & 1))
	{
		teleball_init(this, NULL, NULL);
		_setmodel(this, "progs/teleport.mdl");
		setsize(this, '0 0 0', '0 0 0');	
	}
	else
		this.use = teleball_init;
}

// --------------------------------------------------------------------------------
// hipnotic train2

void hip_train_next(entity this);
void hip_func_train_find(entity this);

void hip_train_use(entity this, entity actor, entity trigger)
{
	if(getthink(this) != hip_func_train_find)
	{
		if(this.velocity != '0 0 0')
			return;		// already activated
	}
	hip_train_next(this);
}

void hip_train_wait(entity this)
{
	if(this.wait)
	{
		_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
		if(this.wait != -1)
		{
			this.nextthink = this.ltime + this.wait;
			this.wait = 0;
		}
	}
	else
		this.nextthink = this.ltime + 0.1;

	setthink(this, hip_train_next);
}


void hip_train_next(entity this)
{
	// Get the speed of the current path_corner.
	// (we must save this off at each path change since
	// we don't have a pointer to the current path_corner).
	float current = this.cnt;

	entity targ = find(NULL, targetname, this.target);

	// Save the speed in cnt for later use
	this.cnt = targ.speed;
	this.target = targ.target;
	if(!this.target || this.target == "")
	{
		objerror(this, "hip_train_next: no next target");
		return;
	}

	_sound(this, CH_TRIGGER_SINGLE, this.noise1, 1, ATTN_NORM);

	this.wait = targ.wait;
	if(targ.wait)
		setthink(this, hip_train_wait);
	else
		setthink(this, hip_train_next);

	if(this.goalentity.event)
	{
		// Trigger any events that should happen at the corner.
		string temp = this.target;
		this.target = this.goalentity.event;
		this.message = this.goalentity.message;
		SUB_UseTargets(this, NULL, NULL);
		this.target = temp;
		this.message = string_null;
	}

	// Save the current entity
	this.goalentity = targ;

	if(current == -1)
	{
		// Warp to the next path_corner
		setorigin(this, targ.origin - this.mins );
		this.nextthink = this.ltime + 0.01;
	}
	else
	{
		// check if there's a speed change
		if(current>0)
			this.speed = current;

		// travel to the next path change
		SUB_CalcMove(this, targ.origin - this.mins, TSPEED_LINEAR, this.speed, getthink(this));
	}
}

void hip_func_train_find(entity this)
{
	entity targ = find(NULL, targetname, this.target);

	// Save the current entity
	this.goalentity = targ;

	// Save the speed in cnt for later use
	this.cnt = targ.speed;

	this.target = targ.target;
	setorigin(this, targ.origin - this.mins);
	if(!this.targetname || this.targetname == "")
	{	// not triggered, so start immediately
		this.nextthink = this.ltime + 0.1;
		setthink(this, hip_train_next);
	}
}

/*QUAKED func_train2 (0 .5 .8) ?
This is a modification of the standard func_train entity.
It is functionally equivalent, except that it removes a slight delay that
would occur after each path entry, and it adds a speed variable to the
path_corner entity.

"noise" contains the name of the sound to play when train stops.
"noise1" contains the name of the sound to play when train moves.
Both "noise" and "noise1" defaults depend upon "sounds" variable.

In path_corner, set speed to be the new speed of the train after it reaches
the path change.  If speed is -1, the train will warp directly to the next
path change after the specified wait time.

Also in path_corner, if wait is set to -1, the train will wait until it is
retriggered before moving on to the next goal.

Here is a reiteration of the func_train docs:

Trains are moving platforms that players can ride.
The targets origin specifies the min point of the train at each corner.
The train spawns at the first target it is pointing at.
If the train is the target of a button or trigger, it will not begin moving until activated.
speed	default 100
dmg		default	2
sounds
1) ratchet metal

*/
spawnfunc(func_train2)
{
	if(!this.speed)
		this.speed = 100;
	if(!this.target || this.target == "")
	{
		objerror(this, "func_train2 without a target");
		return;
	}
	if(!this.dmg)
		this.dmg = 2;

	if(!InitMovingBrushTrigger(this))
		return;
	this.effects |= EF_LOWPRECISION;

	if(!this.noise)
	{
		if(this.sounds == 0)
			this.noise =("misc/null.wav");

		if(this.sounds == 1)
			this.noise =("plats/train2.wav");
	}
	if(!this.noise1)
	{
		if(this.sounds == 0)
			this.noise1 =("misc/null.wav");
		if(this.sounds == 1)
			this.noise1 =("plats/train1.wav");
	}

	precache_sound(this.noise);
	precache_sound(this.noise1);

	this.cnt = 1;
	setblocked(this, train_blocked);
	this.use = hip_train_use;
	this.classname = "train2";

// start trains on the second frame, to make sure their targets have had
// a chance to spawn
	this.nextthink = this.ltime + 0.1;
	setthink(this, hip_func_train_find);
}

#endif
