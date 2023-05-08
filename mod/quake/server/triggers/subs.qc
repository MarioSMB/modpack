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
	destent.team = srcent.team;
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
	destent.invincible_time = srcent.invincible_time;
	destent.invincible_sound = srcent.invincible_sound;
	destent.invisible_time = srcent.invisible_time;
	destent.invisible_sound = srcent.invisible_sound;
	destent.super_time = srcent.super_time;
	destent.super_sound = srcent.super_sound;
	destent.rad_time = srcent.rad_time;
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
	destent.spawnmodel = srcent.spawnmodel;
	destent.spawnsolidtype = srcent.spawnsolidtype;
	destent.spawnmins = srcent.spawnmins;
	destent.spawnmaxs = srcent.spawnmaxs;
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
	return (coop && (this.spawnflags & NOT_IN_COOP));
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
	if(MP_MG && this.movedir)
	{
		this.angles = '0 0 0';
		return;
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
	
	this.angles = '0 0 0';
}

/*
================
RemovedOutsideCoop
Returns true if COOP_ONLY spawnflag is set and we're not in coop.
================
*/
bool RemovedOutsideCoop(entity this)
{
	return (!coop && (this.spawnflags & COOP_ONLY));
}

void InitTrigger(entity this)
{
	if(MP_MG && RemovedOutsideCoop(this))
	{
		delete(this);
		return;
	}
// trigger angles are used for one-way touches.  An angle of 0 is assumed
// to mean no restrictions, so use a yaw of 360 instead.
	if(this.angles != '0 0 0')
		SetMovedir(this);
	this.solid = SOLID_TRIGGER;
	SetBrushEntityModelNoLOD(this);
	set_movetype(this, MOVETYPE_NONE);
	this.modelindex = 0;
	this.model = "";
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
