//#include <common/mapobjects/subs.qc>

void SUB_NullThink(entity this) { }

#ifdef SVQC
/*QUAKED info_null(0 0.5 0)(-4 -4 -4)(4 4 4)
Used as a positional target for spotlights, etc.
*/
spawnfunc(info_null)
{
	delete(this);
}
#endif

#ifdef SVQC
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

void InitTrigger(entity this)
{
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

#ifdef SVQC
// quake specific handlers

/*

in nightmare mode, all attack_finished times become 0
some monsters refire twice automatically

*/

void SUB_AttackFinished(entity this, float normal)
{
	this.cnt = 0;		// refire count for nightmare
	if(skill != 3)
		this.attack_finished = time + normal;
}

bool visible(entity this, entity targ);

void SUB_CheckRefire(entity this, void(entity) thinkst)
{
	if(skill != 3)
		return;
	if(this.cnt == 1)
		return;
	if(!visible(this, this.enemy))
		return;
	this.cnt = 1;
	setthink(this, thinkst);
}
#endif
