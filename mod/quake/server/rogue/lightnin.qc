// lightning trail
// pmack
// sept 96

.float ltrailLastUsed;

const int LT_TOGGLE = BIT(0);
const int LT_ACTIVE = BIT(1);

void ltrail_chain(entity this) 
{
	SUB_UseTargets(this, NULL, NULL);

	setthink(this, func_null);
	this.nextthink = 0;
}

void ltrail_fire(entity this)
{
	if (this.classname != "ltrail_end")
	{
		_sound(this, CH_VOICE, "weapons/lhit.wav", 1, ATTN_NORM);
		entity myTarget = find(world, targetname, this.target);	
		te_lightning2(NULL, this.origin, myTarget.origin); // should be this
		LightningDamage(this.origin, myTarget.origin, this, this.currentammo);
	}

	if(this.items < time)
	{
		setthink(this, ltrail_chain);
		this.nextthink = time + this.frags;
	}
	else
	{
		setthink(this, ltrail_fire);
		this.nextthink = time + 0.05;
	}
}

void ltrail_start_fire(entity this, entity actor, entity trigger)
{
	// if it's a toggle ltrail, we ignore triggers from ltrail_end's
	// when toggled off.
	if (this.spawnflags & LT_TOGGLE)
	{
		// user is not a lightning trail - change activity state.
		if(trigger.classname != "ltrail_end")
		{
			if(this.spawnflags & LT_ACTIVE)
			// currently active
			{
				this.spawnflags &= ~LT_ACTIVE;
				return;
			}
			else 
			// not active
			{
				this.spawnflags |= LT_ACTIVE;
			}
		}
		// user is lightning trail, but trail has been turned off.
		// ignore the message.
		else if(!(this.spawnflags & LT_ACTIVE))
			return;
	}
		
	if(this.classname ==  "ltrail_start")
	{
		this.items = time + this.weapon;
		ltrail_fire(this);
		this.ltrailLastUsed = time;
	}
	else if(this.classname == "ltrail_relay")
	{
		this.items = time + this.weapon;
		ltrail_fire(this);
	}
	else 
	{
		setthink(this, ltrail_chain);
		this.nextthink = time + this.frags;
	}
}

/*QUAKED ltrail_start (0 1 0) (-8 -8 -8) (8 8 8) LT_TOGGLE
Starting point of a lightning trail.
Set currentammo to amount of damage you want the lightning to do.
Default is 25.

Set frags to amount of time before next item is triggered.
Default is 0.3 seconds.

Set weapon to amount of time to be firing the lightning.
Default is 0.3 seconds.

Set the LT_TOGGLE checkbox if you want the lightning shooter to continuously fire until triggered again.
*/
spawnfunc(ltrail_start)
{
	this.ltrailLastUsed = time;
	
	precache_sound("weapons/lhit.wav");
	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_BBOX;
	this.use = ltrail_start_fire;
	
	if(this.currentammo == 0)
		this.currentammo = 25;
		
	if(this.weapon == 0)
		this.weapon = 0.3;
		
	if(this.frags == 0)
		this.frags = 0.3;
		
	if(this.spawnflags & LT_ACTIVE)
	{	
		this.items = time + 99999999;
		setthink(this, ltrail_fire);
		this.nextthink = time + 0.1;
	}
}

/*QUAKED ltrail_relay (0 1 0) (-8 -8 -8) (8 8 8)
Relay point of a lightning trail.
Set currentammo to amount of damage you want the lightning to do.
Default is 25.

Set frags to amount of time before next item is triggered.
Default is 0.3 seconds.

Set weapon to amount of time to be firing the lightning.
Default is 0.3 seconds.
*/
spawnfunc(ltrail_relay)
{
	precache_sound("weapons/lhit.wav");
	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_BBOX;
	this.use = ltrail_start_fire;
	
	if(this.currentammo == 0)
		this.currentammo = 25;
		
	if(this.weapon == 0)
		this.weapon = 0.3;
		
	if(this.frags == 0)
		this.frags = 0.3;
}

/*QUAKED ltrail_end (0 1 0) (-8 -8 -8) (8 8 8) 
Ending point of a lightning trail.
Does not fire any lightning.

Set frags to amount of time before next item is triggered.
Default is 0.3 seconds.
*/
spawnfunc(ltrail_end)
{
	precache_sound ("weapons/lhit.wav");
	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_BBOX;
	this.use = ltrail_start_fire;

	if (this.currentammo == 0)
		this.currentammo = 25;

	if (this.weapon == 0)
		this.weapon = 0.3;

	if (this.frags == 0)
		this.frags = 0.3;
}
