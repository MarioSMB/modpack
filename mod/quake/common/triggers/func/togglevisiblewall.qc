#ifdef SVQC

.string origmodel;

/*****************
func_togglevisiblewall

A bmodel which you can toggle its visibility. Behaves much like a traditional func_wall in any other way,
but you can target it to toggle visible/invisible.
If the entity has a switchable shadow it also toggles.

spawnflag 1: starts invisible
spawnflag 2: set brush as non-solid

******************/

const int TOGGLEVISWALL_STARTOFF = 1;
const int TOGGLEVISWALL_NOTSOLID = 2;

void func_togglevisiblewall_use(entity this, entity actor, entity trigger)
{
	if(!this.state)
	{
		if(!(this.spawnflags & TOGGLEVISWALL_NOTSOLID))
		{
			this.solid = SOLID_BSP;
			set_movetype(this, MOVETYPE_PUSH);
		}
		_setmodel(this, this.origmodel);
		if(this.switchshadstyle)
			lightstyle(this.switchshadstyle, "a");
		this.state = 1;
	}
	else
	{

		this.solid = SOLID_NOT;
		set_movetype(this, MOVETYPE_NONE);
		_setmodel(this, "");
		if(this.switchshadstyle)
			lightstyle(this.switchshadstyle, "m");
		this.state = 0;
	}
}


/*QUAKED func_togglevisiblewall (0 .5 .8) ? TOGGLEVISWALL_STARTOFF TOGGLEVISWALL_NOTSOLID X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY

A bmodel which you can toggle its visibility. Behaves much like a traditional func_wall in any other way,
but you can target it to toggle visible/invisible.
If the entity has a switchable shadow it also toggles.

TOGGLEVISWALL_STARTOFF spawns in disabled state.

TOGGLEVISWALL_NOTSOLID sets it to be non-solid.

*/
spawnfunc(func_togglevisiblewall)
{
	this.angles = '0 0 0';
	this.use = func_togglevisiblewall_use;

	this.origmodel = this.model;

	if(this.spawnflags & TOGGLEVISWALL_STARTOFF)
		this.state = 1;
	else
		this.state = 0;

	if(this.spawnflags & TOGGLEVISWALL_NOTSOLID)
	{
		this.solid = SOLID_NOT;
		set_movetype(this, MOVETYPE_NONE);
	}

	// trigger initially to activate the model
	func_togglevisiblewall_use(this, NULL, NULL);
}

#endif
