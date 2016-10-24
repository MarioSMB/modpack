/*
QuakeEd only writes a single float for angles(bad idea), so up and down are
just constant angles.
*/
vector SetMovedir(entity this)
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

/*
================
InitTrigger
================
*/
void InitTrigger(entity this)
{
// trigger angles are used for one-way touches.  An angle of 0 is assumed
// to mean no restrictions, so use a yaw of 360 instead.
	if(this.angles != '0 0 0')
		SetMovedir(this);
	this.solid = SOLID_TRIGGER;
	_setmodel(this, this.model);	// set size and link into world
	this.movetype = MOVETYPE_NONE;
	this.modelindex = 0;
	this.model = "";
}

/*
=============
SUB_CalcMove

calculate this.velocity and this.nextthink to reach dest from
this.origin traveling at speed
===============
*/
void SUB_CalcMove(entity this, vector tdest, float tspeed, void(entity) func)
{
	if(!tspeed)
		objerror("No speed is defined!");

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

/*
============
After moving, set origin to exact final destination
============
*/
void  SUB_CalcMoveDone(entity this)
{
	setorigin(this, this.finaldest);
	this.velocity = '0 0 0';
	this.nextthink = -1;
	if(this.think1)
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
void SUB_CalcAngleMove(entity this, vector destangle, float tspeed, void(entity) func)
{
	if(!tspeed)
		objerror("No speed is defined!");
		
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


//=============================================================================

void DelayThink(entity this)
{
	SUB_UseTargets(this, this.enemy, NULL);
	delete(this);
}

/*
==============================
SUB_UseTargets

the global "activator" should be set to the entity that initiated the firing.

If this.delay is set, a DelayedUse entity will be created that will actually
do the SUB_UseTargets after that many seconds have passed.

Centerprints any this.message to the activator.

Removes all entities with a targetname that match this.killtarget,
and removes them, so some events can remove other triggers.

Search for(string)targetname in all entities that
match(string)this.target and call their .use function

==============================
*/
void SUB_UseTargets(entity this, entity actor, entity trigger)
{
//
// check for a delay
//
	if(this.delay)
	{
	// create a temp object to fire at a later time
		entity t = new(DelayedUse);
		t.nextthink = time + this.delay;
		setthink(t, DelayThink);
		t.enemy = actor;
		t.message = this.message;
		t.killtarget = this.killtarget;
		t.target = this.target;
		return;
	}
	
	
//
// print the message
//
	if(IS_PLAYER(actor) && this.message != "")
	{
		centerprint(actor, this.message);
		if(!this.noise)
			_sound(actor, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
	}

//
// kill the killtagets
//
	if(this.killtarget)
	{
		t = NULL;
		do
		{
			t = find(t, targetname, this.killtarget);
			if(!t)
				return;
			delete(t);
		} while( 1 );
	}
	
//
// fire targets
//
	if(this.target)
	{
		entity t = NULL;
		do
		{
			t = find(t, targetname, this.target);
			if(!t)
				return;
			if(t.use)
				t.use(t, actor, this);
		} while( 1 );
	}
	

}


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
