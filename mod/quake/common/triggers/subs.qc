//#include <common/mapobjects/subs.qc>

void SUB_NullThink(entity this) { }

#ifdef SVQC
#define getblocked(e) SELFWRAP_GET(blocked, e)

void SUB_CopyEntity(entity srcent, entity destent)
{
	destent.modelindex = srcent.modelindex;
	destent.absmin = srcent.absmin;
	destent.absmax = srcent.absmax;
	destent.ltime = srcent.ltime;
	set_movetype(destent, srcent.move_movetype);
	destent.solid = srcent.solid;
	destent.origin = srcent.origin;
	destent.oldorigin = srcent.oldorigin;
	destent.velocity = srcent.velocity;
	destent.angles = srcent.angles;
	destent.avelocity = srcent.avelocity;
	destent.punchangle = srcent.punchangle;
	destent.classname = srcent.classname;
	destent.model = srcent.model;
	destent.frame = srcent.frame;
	destent.skin = srcent.skin;
	destent.effects = srcent.effects;
	destent.mins = srcent.mins;
	destent.maxs = srcent.maxs;
	destent.size = srcent.size;
	settouch(destent, gettouch(srcent));
	destent.use = srcent.use;
	setthink(destent, getthink(srcent));
	setblocked(destent, getblocked(srcent));
	destent.nextthink = srcent.nextthink;
	destent.groundentity = srcent.groundentity;
	destent.health = srcent.health;
	destent.frags = srcent.frags;
	destent.weapon = srcent.weapon;
	destent.weaponmodel = srcent.weaponmodel;
	destent.weaponframe = srcent.weaponframe;
	destent.ammo_shells = srcent.ammo_shells;
	destent.ammo_nails = srcent.ammo_nails;
	destent.ammo_rockets = srcent.ammo_rockets;
	destent.ammo_cells = srcent.ammo_cells;
	destent.items = srcent.items;
	destent.powerups = srcent.powerups;
	STAT(WEAPONS, destent) = STAT(WEAPONS, srcent);
	destent.takedamage = srcent.takedamage;
	destent.chain = srcent.chain;
	destent.deadflag = srcent.deadflag;
	destent.view_ofs = srcent.view_ofs;
	destent.button0 = srcent.button0;
	destent.button1 = srcent.button1;
	destent.button2 = srcent.button2;
	destent.button3 = srcent.button3;
	destent.impulse = srcent.impulse;
	destent.fixangle = srcent.fixangle;
	destent.v_angle = srcent.v_angle;
	destent.idealpitch = srcent.idealpitch;
	destent.netname = srcent.netname;
	destent.enemy = srcent.enemy;
	destent.flags = srcent.flags;
	destent.colormap = srcent.colormap;
	destent.max_health = srcent.max_health;
	destent.teleport_time = srcent.teleport_time;
	destent.armortype = srcent.armortype;
	destent.armorvalue = srcent.armorvalue;
	destent.waterlevel = srcent.waterlevel;
	destent.watertype = srcent.watertype;
	destent.ideal_yaw = srcent.ideal_yaw;
	destent.yaw_speed = srcent.yaw_speed;
	destent.aiment = srcent.aiment;
	destent.goalentity = srcent.goalentity;
	destent.spawnflags = srcent.spawnflags;
	destent.target = srcent.target;
	destent.targetname = srcent.targetname;
	destent.dmg_take = srcent.dmg_take;
	destent.dmg_save = srcent.dmg_save;
	destent.dmg_inflictor = srcent.dmg_inflictor;
	destent.owner = srcent.owner;
	destent.movedir = srcent.movedir;
	destent.message = srcent.message;
	destent.sounds = srcent.sounds;
	destent.noise = srcent.noise;
	destent.noise1 = srcent.noise1;
	destent.noise2 = srcent.noise2;
	destent.noise3 = srcent.noise3;
	//destent.wad = srcent.wad;
	destent.map = srcent.map;
	destent.worldtype = srcent.worldtype;
	destent.killtarget = srcent.killtarget;
	destent.light_lev = srcent.light_lev;
	destent.style = srcent.style;
	destent.th_stand = srcent.th_stand;
	destent.th_walk = srcent.th_walk;
	destent.th_run = srcent.th_run;
	destent.th_missile = srcent.th_missile;
	destent.th_melee = srcent.th_melee;
	destent.th_pain = srcent.th_pain;
	destent.th_die = srcent.th_die;
	destent.oldenemy = srcent.oldenemy;
	destent.speed = srcent.speed;
	destent.lefty = srcent.lefty;
	destent.search_time = srcent.search_time;
	destent.attack_state = srcent.attack_state;
	destent.walkframe = srcent.walkframe;
	destent.attack_finished = srcent.attack_finished;
	destent.attack2_finished = srcent.attack2_finished;
	destent.pain_finished = srcent.pain_finished;
	destent.invincible_finished = srcent.invincible_finished;
	destent.invisible_finished = srcent.invisible_finished;
	destent.super_damage_finished = srcent.super_damage_finished;
	destent.radsuit_finished = srcent.radsuit_finished;
	destent.invincible_sound = srcent.invincible_sound;
	destent.invisible_sound = srcent.invisible_sound;
	destent.super_sound = srcent.super_sound;
	destent.fly_sound = srcent.fly_sound;
	destent.axhitme = srcent.axhitme;
	destent.show_hostile = srcent.show_hostile;
	destent.jump_flag = srcent.jump_flag;
	destent.swim_flag = srcent.swim_flag;
	destent.air_finished = srcent.air_finished;
	destent.bubble_count = srcent.bubble_count;
	destent.projectiledeathtype = srcent.projectiledeathtype;
	destent.mdl = srcent.mdl;
	destent.mangle = srcent.mangle;
	destent.oldorigin = srcent.oldorigin;
	destent.t_length = srcent.t_length;
	destent.t_width = srcent.t_width;
	destent.dest = srcent.dest;
	destent.dest1 = srcent.dest1;
	destent.dest2 = srcent.dest2;
	destent.wait = srcent.wait;
	destent.delay = srcent.delay;
	destent.trigger_field = srcent.trigger_field;
	destent.noise4 = srcent.noise4;
	destent.pausetime = srcent.pausetime;
	destent.movetarget = srcent.movetarget;
	destent.aflag = srcent.aflag;
	destent.dmg = srcent.dmg;
	destent.cnt = srcent.cnt;
	destent.think1 = srcent.think1;
	destent.finaldest = srcent.finaldest;
	destent.finalangle = srcent.finalangle;
	destent.count = srcent.count;
	destent.lip = srcent.lip;
	destent.state = srcent.state;
	destent.pos1 = srcent.pos1;
	destent.pos2 = srcent.pos2;
	destent.height = srcent.height;
	destent.waitmin = srcent.waitmin;
	destent.waitmax = srcent.waitmax;
	destent.distance = srcent.distance;
	destent.volume = srcent.volume;
	destent.gorging = srcent.gorging;
	destent.stoleweapon = srcent.stoleweapon;
	destent.spawnfunction = srcent.spawnfunction;
	destent.spawnthink = srcent.spawnthink;
	destent.spawnclassname = srcent.spawnclassname;
}

//=========================
//
// SUB_NormalizeAngles
//
//=========================

vector SUB_NormalizeAngles(vector ang)
{
	while(ang.x > 360)
		ang.x = ang.x - 360;

	while(ang.x < 0)
		ang.x = ang.x + 360;

	while(ang.y > 360)
		ang.y = ang.y - 360;

	while(ang.y < 0)
		ang.y = ang.y + 360;

	while(ang.z > 360)
		ang.z = ang.z - 360;

	while(ang.z < 0)
		ang.z = ang.z + 360;

	return ang;
}

/*QUAKED info_null(0 0.5 0)(-4 -4 -4)(4 4 4)
Used as a positional target for spotlights, etc.
*/
spawnfunc(info_null)
{
	delete(this);
}
#endif

#ifdef SVQC
bool Inhibit_Coop(entity this)
{
	return (coop && (this.spawnflags & NOT_IN_COOP) && IsMGMap());
}

/*
=============
SUB_CalcMove

calculate this.velocity and this.nextthink to reach dest from
this.origin traveling at speed
===============
*/
void SUB_CalcMoveDone(entity this);
void SUB_CalcMove(entity this, vector tdest, float tspeedtype, float tspeed, void(entity) func)
{
	if(!tspeed)
		objerror(this, "No speed is defined!");

	this.think1 = func;
	this.finaldest = tdest;
	setthink(this, SUB_CalcMoveDone);

	if(tdest == this.origin)
	{
		this.velocity = '0 0 0';
		this.nextthink = this.ltime + 0.1;
		return;
	}
		
// set destdelta to the vector needed to move
	vector vdestdelta = tdest - this.origin;
	
// calculate length of vector
	float len = vlen(vdestdelta);

// divide by speed to get time to reach dest
	float traveltime = len / tspeed;

	if(traveltime < 0.1)
	{
		this.velocity = '0 0 0';
		this.nextthink = this.ltime + 0.1;
		return;
	}
	
// set nextthink to trigger a think when dest is reached
	this.nextthink = this.ltime + traveltime;

// scale the destdelta vector by the time spent traveling to get velocity
	this.velocity = vdestdelta *(1/traveltime);	// qcc won't take vec/float	
}

void SUB_CalcMoveDone(entity this)
{
	// After moving, set origin to exact final destination

	setorigin(this, this.finaldest);
	this.velocity = '0 0 0';
	this.nextthink = -1;
	if(this.think1 && this.think1 != SUB_CalcMoveDone)
		this.think1(this);
}

.float lifetime_finished;
void shadowmonitor_think(entity this)
{
	entity o = this.owner;
	
	float frac = vlen(o.origin - this.pos2) / vlen(this.pos2 - this.pos1);
	if(this.customflags & CFL_INVLIGHT)
		frac = 1 - frac;
	bmodel_lightstyle(o, frac);
	
	this.nextthink = time + min(0.05, (o.nextthink - o.ltime));

	// remove last so we don't miss a final eval
	if(this.nextthink <= time || o.ltime > this.lifetime_finished || this.state != o.state)
		delete(this);
}

// to avoid damaging existing movement logic with extra thinks, we wrap
// it and create a helper entity to do this instead
void SUB_CalcMoveLight(entity this, vector tstart, vector tdest, float tspeed, void(entity) endfn, bool invert)
{
	if(this.style || this.switchshadstyle)
	{
		entity mon = spawn();
		mon.classname = "shadowmonitor";
		mon.owner = this;
		mon.state = this.state;	// removes this if these stop matching
		mon.lifetime_finished = this.ltime + vlen(tdest - this.origin) / tspeed;
		setthink(mon, shadowmonitor_think);
		mon.nextthink = time;
		mon.pos1 = tstart;
		mon.pos2 = tdest;
		if(invert)
			mon.customflags |= CFL_INVLIGHT;
	}	
	SUB_CalcMove(this, tdest, TSPEED_LINEAR, tspeed, endfn);
}

/*
CURVACEOUS MOVE

pathcorners can have a curve spawnflag that marks them as bezier control points
bezier path corners affect the curve but will never be visited
	this means they don't affect speed, don't fire targets, etc
*/

// bez is short for Bilinear EnterpolationZ
vector bez(vector start, vector ctrl, vector end, float t)
{
	vector b1 = t * ctrl + (1-t) * start;
	vector b2 = t * end + (1-t) * ctrl;
	return t * b2 + (1-t) * b1;
}

float lerp_copper(float a, float b, float mix)
{
	if(mix <= 0) return a;
	if(mix >= 1) return b;
	return (b * mix + a * ( 1 - mix ) );
}

void SUB_CalcMoveCurveSeg(entity this)
{
	float chron = this.ltime;
	// this.cnt is number of steps we've passed through
	// (when this.cnt == nodeCtrl.count we should be at nodeEnd)
	if(this.cnt == this.count)
	{
		this.pos2 = '0 0 0';
		SUB_CalcMoveDone(this);
		return;
	}
	this.cnt += 1;

	float t = this.cnt / this.count;
	vector destdelta = bez(this.pos1, this.pos2, this.finaldest, t) - this.origin;

	float wishspeed = lerp_copper(this.speed, this.speed2, t);
	float traveltime = vlen(destdelta) / wishspeed;
	if(traveltime < 0.05)
	{
		this.velocity = '0 0 0';
		this.nextthink = chron + 0.05;
		setthink(this, SUB_CalcMoveDone);
		return;
	}	
	this.velocity = destdelta * (1 / traveltime);
	setthink(this, SUB_CalcMoveCurveSeg);
	this.nextthink = chron + traveltime;
}

// init curved motion
void SUB_CalcMoveCurve(entity this, vector end, vector ctrl, float segs, float speedStart, float speedEnd, void(entity) fnDone)
{
	// this.oldenemy is current pathcorner already
	this.pos1 = this.origin;
	this.pos2 = ctrl;
	this.finaldest = end;
	this.speed = speedStart;
	this.speed2 = speedEnd;
	this.cnt = 0;
	this.count = segs;
	this.think1 = fnDone;
	
	SUB_CalcMoveCurveSeg(this);
}


/*
=============
SUB_CalcAngleMove

calculate this.avelocity and this.nextthink to reach destangle from
this.angles rotating 

The calling function should make sure this.think is valid
===============
*/
void SUB_CalcAngleMoveDone(entity this);
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
	this.avelocity = destdelta *(1 / traveltime);
	
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
#endif

/*
==================
SUB_VanishOrRemove

Makes client invisible or removes non-client
==================
*/
void SUB_VanishOrRemove (entity ent)
{
	if(IS_CLIENT(ent))
	{
		// vanish
		ent.alpha = -1;
		ent.effects = 0;
#ifdef SVQC
		ent.glow_size = 0;
		ent.pflags = 0;
#endif
	}
	else
	{
		// remove
		delete(ent);
	}
}

void SUB_SetFade_Think (entity this)
{
	if(this.alpha == 0)
		this.alpha = 1;
	setthink(this, SUB_SetFade_Think);
	this.nextthink = time;
	this.alpha -= frametime * this.fade_rate;
	if(this.alpha < 0.01)
		SUB_VanishOrRemove(this);
	else
		this.nextthink = time;
}

/*
==================
SUB_SetFade

Fade ent out when time >= vanish_time
==================
*/
void SUB_SetFade(entity ent, float vanish_time, float fading_time)
{
	if(fading_time <= 0)
		fading_time = 0.01;
	ent.fade_rate = 1/fading_time;
	setthink(ent, SUB_SetFade_Think);
	ent.nextthink = vanish_time;
}

#ifdef SVQC
void ApplyMinMaxScaleAngles(entity e)
{
	if(e.angles.x != 0 || e.angles.z != 0 || e.avelocity.x != 0 || e.avelocity.z != 0) // "weird" rotation
	{
		e.maxs = '1 1 1' * vlen(
			'1 0 0' * max(-e.mins.x, e.maxs.x) +
			'0 1 0' * max(-e.mins.y, e.maxs.y) +
			'0 0 1' * max(-e.mins.z, e.maxs.z)
		);
		e.mins = -e.maxs;
	}
	else if(e.angles.y != 0 || e.avelocity.y != 0) // yaw only is a bit better
	{
		e.maxs_x = vlen(
			'1 0 0' * max(-e.mins.x, e.maxs.x) +
			'0 1 0' * max(-e.mins.y, e.maxs.y)
		);
		e.maxs_y = e.maxs.x;
		e.mins_x = -e.maxs.x;
		e.mins_y = -e.maxs.x;
	}
	if(e.scale)
		setsize(e, e.mins * e.scale, e.maxs * e.scale);
	else
		setsize(e, e.mins, e.maxs);
}

void SetBrushEntityModelNoLOD(entity this)
{
 	if(this.model != "")
 	{
 		precache_model(this.model);
		if(this.mins != '0 0 0' || this.maxs != '0 0 0')
		{
			vector mi = this.mins;
			vector ma = this.maxs;
			_setmodel(this, this.model); // no precision needed
			setsize(this, mi, ma);
		}
		else
			_setmodel(this, this.model); // no precision needed
 	}
	setorigin(this, this.origin);
	ApplyMinMaxScaleAngles(this);
}

/*
================
InitTrigger
================
*/

/*
QuakeEd only writes a single float for angles(bad idea), so up and down are
just constant angles.
*/
void SetMovedir(entity this)
{
	if(this.movedir != '0 0 0')
	{
		this.angles = '0 0 0';
		return;
	}
	vector myangle = '0 0 0';
	if(this.mangle != '0 0 0')
	{
		myangle = this.angles;
		if(myangle == '0 -1 0')
			myangle = '0 -90 0';
		else if(myangle == '0 -2 0')
			myangle = '0 90 0';
		this.angles = vec3(this.mangle_y, this.mangle_x, this.mangle_z);
	}

	if(this.angles == '0 -1 0')
		this.movedir = '0 0 1';
	else if(this.angles == '0 -2 0')
		this.movedir = '0 0 -1';
	else
	{
		makevectors(this.angles);
		this.movedir = v_forward;
	}
	
	this.angles = myangle;
}

void SUB_CountTargets(entity this)
{
	int i = 0;
	entity t = NULL;
	while(this.target != string_null) 
	{
		t = find(t, targetname, this.target);
		if(!t) break;
		i += 1;
	}
	t = NULL;
	while(this.target2 != string_null) 
	{
		t = find(t, targetname, this.target2);
		if(!t) break;
		i += 1;
	}
	t = NULL;
	while(this.target3 != string_null) 
	{
		t = find(t, targetname, this.target3);
		if(!t) break;
		i += 1;
	}
	t = NULL;
	while(this.target4 != string_null) 
	{
		t = find(t, targetname, this.target4);
		if(!t) break;
		i += 1;
	}

	this.cnt = i;

	this.frags = 0;	
	t = NULL;
	while(this.killtarget != string_null) 
	{
		t = find(t, targetname, this.killtarget);
		if(!t) break;
		this.frags += 1;
	}
}

/*
================
RemovedOutsideCoop
Returns true if COOP_ONLY spawnflag is set and we're not in coop.
================
*/
bool RemovedOutsideCoop(entity this)
{
	return (!coop && (this.spawnflags & COOP_ONLY) && IsMGMap());
}

.void(entity, entity, entity) trigger_init_use;
void trigger_reactivate(entity this, entity actor, entity trigger)
{
	// TheSolipsist fix: when the trigger has health, make it solid so it can be shot
	this.active = ACTIVE_ACTIVE;
	if(this.max_health)
		this.solid = SOLID_BBOX;
	else
		this.solid = SOLID_TRIGGER;
	setorigin(this, this.origin); // relink
	this.use = this.trigger_init_use;
	force_retouch = 2;		// make sure even still objects get hit
}


void InitTrigger(entity this)
{
	if(RemovedOutsideCoop(this))
	{
		delete(this);
		return;
	}
// trigger angles are used for one-way touches.  An angle of 0 is assumed
// to mean no restrictions, so use a yaw of 360 instead.
	if(this.angles != '0 0 0')
		SetMovedir(this);
	if(!this.health)
		this.solid = SOLID_TRIGGER;
	//SetBrushEntityModelNoLOD(this);
	vector oldmin = this.mins, oldmax = this.maxs;
	_setmodel(this, this.model);
	if(oldmin != '0 0 0' && oldmax != '0 0 0')
		setsize(this, oldmin, oldmax);
	set_movetype(this, MOVETYPE_NONE);
	//this.modelindex = 0;
	this.model = string_null;

	if((this.spawnflags & SPAWNFLAG_TRIGGER_FIRST) && !IsMGMap())
	{
		this.solid = SOLID_NOT;
		setorigin(this, this.origin); // relink
		this.trigger_init_use = this.use;
		this.use = trigger_reactivate;
	}
}

/*
================
InitTriggerBounds
quoth2-style edict-saving bounding box triggers
================
*/
void InitTriggerBounds(entity this)
{
// trigger angles are used for one-way touches.  An angle of 0 is assumed
// to mean no restrictions, so use a yaw of 360 instead.

	// do this first so setsize links us correctly
	if(!this.health)
		this.solid = SOLID_TRIGGER;
	setorigin (this, this.origin);
	
	if(this.size != '0 0 0')
		setsize(this, this.size * -0.5, this.size * 0.5);
	else if(this.mangle != '0 0 0')
	{
		setsize(this, this.mangle * -0.5, this.mangle * 0.5);
		this.mangle = '0 0 0';	// so setMoveDir doesn't think our mangle is our angle
	}
	
	if(this.angles != '0 0 0')
		SetMovedir(this);
	
	if(this.distance > 1)
		this.distance = cos(this.distance / 2);

	if((this.spawnflags & SPAWNFLAG_TRIGGER_FIRST) && !IsMGMap())
	{
		this.solid = SOLID_NOT;
		this.trigger_init_use = this.use;
		this.use = trigger_reactivate;
	}
		
	set_movetype(this, MOVETYPE_NONE);
//	particle(this.origin - this.mangle, '0 0 0', 232, 4);
//	particle(this.origin + this.mangle, '0 0 0', 232, 4);
//	this.modelindex = 0;
//	this.model = string_null;
}

bool InitMovingBrushTrigger(entity this)
{
// trigger angles are used for one-way touches.  An angle of 0 is assumed
// to mean no restrictions, so use a yaw of 360 instead.
	this.solid = SOLID_BSP;
	SetBrushEntityModelNoLOD(this); // SetBrushEntityModel was here
	set_movetype(this, MOVETYPE_PUSH);
	if(this.modelindex == 0)
	{
		objerror(this, "InitMovingBrushTrigger: no brushes found!");
		return false;
	}
	return true;
}
#endif

/*
================
Bitshift emulation
================
*/
// TODO: we have actual bitshift, port to it!
float SUB_LeftShift(float num, float bits)
{
	bits = floor(bits);
	while(bits > 0)
	{
		num*= 2;
		bits--;
	}
	return num;
}

float SUB_RightShift(float num, float bits)
{
	bits = floor(bits);
	while(bits > 0)
	{
		num/= 2;
		bits--;
	}
	return num;
}

#ifdef SVQC
//======================================================================
// Most of the monsters have an attack_offset setup to spawn their
// proejctiles in the right location relative to their gun model
// This function expects the makevectors has been done already
// makevectors (this.angles); <--- if missing, vector will be rubbish!
//----------------------------------------------------------------------
vector attack_vector(vector attack_dir)
{
	vector retvec;
	retvec = v_forward * attack_dir.x;
	retvec = retvec + (v_right * attack_dir.y);
	retvec = retvec + (v_up * attack_dir.z);
	return retvec;
}

/*======================================================================
 SUB_Elevation
  Calculates the Elevation for Z Aware monsters
  * Original code by Preach (https://tomeofpreach.wordpress.com/)
  * Added support for variable origin locations and proj speeds
  * Added support for distance scaling linked to skill levels
======================================================================*/
float SUB_Elevation(entity this, float theta, vector sorg, vector mdest, float zspeed)
{
	Monster mon = this.monsterdef;
	vector ofs;

	// Place projectile destination at player head level
	//if(this.monsterdef == MON_SPIDER)
		//mdest += '0 0 -16';
	//else
		mdest += '0 0 12';

	// Work out vector distance between source and destination
	// Normalize the distance and create a percentage of that
	// This is a skill based calculation so the aiming gets better
	// The grenade is aimed infront of target so that it bounces
	// No check for vertical difference so it bad going up height!
	// Zombie, poison spiders zaware calculation is fine, exception!
	if(!(mon.spawnflags & MONSTER_TYPE_UNDEAD)) //&& mon != MON_SPIDER && mon != MON_BOGLORD)
	{
		vector vec = mdest - sorg;
		float dist = vlen(vec);
		vec = normalize(vec);
		float sperc = 0.45 + autocvar_skill * 0.15;
		vector eorg = sorg + (vec * (dist * sperc));
		ofs = eorg - sorg;
	}
	else
		ofs = mdest - sorg;
		
	//calculate how far we are firing
	//	ofs = mdest - sorg;
	float az = ofs.z;
	ofs.z = 0;
	float ay = vlen(ofs);
 
	// Map gravity is a global variable defined in world.qc
	//find the coefficients of the quadratic in tan(theta)
	float a = 0.5 * autocvar_sv_gravity * ay * ay / (zspeed * zspeed);
	float b = -ay;
	float c = a + az;
 
	//check if the destination is too far to reach
	if((b * b) < (4 * a * c))
		return 30;

	//calculate the tan value of the given theta
	float tan_theta = tan(theta);

	//reuse ang to create the improved firing direction
	theta = atan2(a * tan_theta * tan_theta - c, 2 * a * tan_theta + b);

	//constrain the values to stop anything too mad happening
	while(theta > 90)
		theta -= 180;
	return theta;
}

/*
=============
SUB_PrintMessage
===============
*/
void SUB_PrintMessage(entity this, entity actor)
{
	if(!this.message || this.message == "")
		return;

	// print the message
	if(IS_PLAYER(actor) && IS_REAL_CLIENT(actor))
	{
		centerprint_proximity(actor, process_string(this.message), this);
		
		// non-triggers might play the noise themselves (buttons, etc)
		if((!this.noise || this.noise == "") && (this.solid == SOLID_TRIGGER || this.solid == SOLID_NOT) && this.sounds != -1)
			_sound(actor, CH_INFO, QUAKE_TALKSOUND, 1, ATTN_NORM);
	}
	else
	{
		// sometimes activator can be an infighting monster that killed a monster 
		// with a targetname, so just print to all clients
		FOREACH_CLIENT(IS_PLAYER(it) && IS_REAL_CLIENT(it),
		{
			centerprint(it, this.message);
			if((!this.noise || this.noise == "") && (this.solid == SOLID_TRIGGER || this.solid == SOLID_NOT))
				_sound(it, CH_INFO, QUAKE_TALKSOUND, 1, ATTN_NORM);
		});
	}
}

/*
=============
SUB_VerifyTrigger

somewhat unreliable attempt to ensure items with targetnames that aren't actually
triggered by anything don't stay unspawned forever and break a stock map
examples: weapons in antediluvium targeted by spotlights, the silver key in e4m4
===============
*/
bool SUB_VerifyTrigger(entity this, entity tg)
{
	// things that could conceivably be targeted at an item but cannot fire targets
	if(tg.classname == "light" ||
		//tg.classname == "path_corner" ||	// trains do fire targets
		tg.classname == "trap_shooter" ||
		tg.classname == "target_drop" ||
		tg.classname == "target_fade" ||
		tg.classname == "trap_spikeshooter")
		return false;
		
	if(tg.killtarget == this.targetname)	// id1 'killtarget must target' protection
		return false;
	return true;
}

/*
=============
SUB_VerifyTriggerable
===============
*/
bool SUB_VerifyTriggerable(entity this)
{
	if(!this.targetname || this.targetname == "")
		return false;
	// some quake maps use SUB_regen as a hack to make items respawn, but
	// they expect those items to still spawn at map start, so catch those
	// cases and return false to force the item to spawn
	if(/*this.use == SUB_regen ||*/ this.classname == "info_notnull")
		return false;

	entity tg;

	bool validTriggerers = false;
	tg = NULL;
	while(1)
	{
		tg = find(tg, target, this.targetname);
		if(!tg)
			break;
		validTriggerers |= SUB_VerifyTrigger(this, tg);
	}
	tg = NULL;
	while(1)
	{
		tg = find(tg, target2, this.targetname);
		if(!tg)
			break;
		validTriggerers |= SUB_VerifyTrigger(this, tg);
	}
	tg = NULL;
	while(1)
	{
		tg = find(tg, target3, this.targetname);
		if(!tg)
			break;
		validTriggerers |= SUB_VerifyTrigger(this, tg);
	}
	tg = NULL;
	while(1)
	{
		tg = find(tg, target4, this.targetname);
		if(!tg)
			break;
		validTriggerers |= SUB_VerifyTrigger(this, tg);
	}
	
	return validTriggerers;
}
#endif
