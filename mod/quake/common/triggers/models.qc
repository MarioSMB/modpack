//#include "models.qh"

#ifdef SVQC
const int SPAWN_WALL_NONSOLID = 1;
const int SPAWN_WALL_TOGGLEVIS = 2;
const int SPAWN_WALL_STARTINVIS = 4;

void bmodel_vanish_do(entity this);
void bmodel_vanish_think(entity this);
void bmodel_vanish(entity this)
{
	if(this.solid == SOLID_NOT)
	{
		bmodel_vanish_do(this);
		return;
	}

	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_NONE);
	this.nextthink = time + 0.2;
	setthink(this, bmodel_vanish_think);
}

void bmodel_appear(entity this)
{
	// ***
	// IN THIS ORDER
	// ***
	if(!(this.spawnflags & 1))
	{
		this.solid = SOLID_BSP;
		set_movetype(this, MOVETYPE_PUSH);
	}
	setorigin(this, this.origin);	
	_setmodel(this, this.model);
	//this.alpha = 1;
	// ***
	// NOT ANY OTHER ORDERS
	// ***
	
	bmodel_lightstyle(this, 1);
	this.state = STATE_BOTTOM;
	//force_retouch = 2;
}

void bmodel_vanish_think(entity this)
{
	bmodel_vanish_do(this);
}

void bmodel_vanish_do(entity this)
{
	this.state = STATE_TOP;
	this.modelindex = 0;
	bmodel_lightstyle(this, 0);
}

void func_wall_flip(entity this)
{	// change to alternate textures
	if(this.noise && this.noise != "")
		_sound(this, CH_TRIGGER_SINGLE, this.noise, 1.0, ATTN_NORM);
	
	if(this.spawnflags & SPAWN_WALL_TOGGLEVIS)
	{
		if(this.state == STATE_TOP)
		{
			bmodel_appear(this);
		}
		else
		{
			bmodel_vanish(this);
		}
		return;
	}
	
	this.frame = 1 - this.frame;
}

void func_wall_use(entity this, entity actor, entity trigger)
{
	if(this.wait == -1)
	{
		func_wall_flip(this);
		this.use = func_null;
		return;
	}
	
	if(this.wait > 0)
	{
		if(this.nextthink <= this.ltime)
			func_wall_flip(this);
		setthink(this, func_wall_flip);
		this.nextthink = this.ltime + this.wait;
		return;
	}
	
	func_wall_flip(this);
}

void wall_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(time < this.attack_finished)
		return;

	if(this.message && this.message != "")
	{
		centerprint_proximity(toucher, this.message);
		if(this.noise2 && this.noise2 != "")
			_sound(toucher, CH_TRIGGER_SINGLE, this.noise2, 1, ATTN_NORM);
		else
			_sound(toucher, CH_TRIGGER_SINGLE, QUAKE_TALKSOUND, 1, ATTN_NORM);
	}
	this.attack_finished = time + 2;
}

/*QUAKED func_wall(0 .5 .8) ?
This is just a solid wall if not inhibitted
*/
spawnfunc(func_wall)
{
	if(this.noise && this.noise != "")
		precache_sound(this.noise);
	if(this.noise2 && this.noise2 != "")
		precache_sound(this.noise2);
	precache_model(this.model);
	
	//if(this.mangle)
		this.angles = this.mangle;
	this.use = func_wall_use;
	//this.angles = '0 0 0';

	if(this.style < 0)
	{
		this.style *= -1;
		this.customflags |= CFL_INVLIGHT;
	}	

	set_movetype(this, MOVETYPE_PUSH);	// so it doesn't get pushed by anything
	if(this.spawnflags & SPAWN_WALL_NONSOLID)
		this.solid = SOLID_NOT;
	else
		this.solid = SOLID_BSP;

	_setmodel(this, this.model);
	//if(!this.touch)
		settouch(this, wall_touch);
	
	if(this.spawnflags & SPAWN_WALL_STARTINVIS)
	{
		this.spawnflags |= SPAWN_WALL_TOGGLEVIS;	// starting invis implies toggle
		bmodel_vanish(this);
	}
	else
	{
		bmodel_lightstyle(this, 1);
		this.state = STATE_BOTTOM;
	}
}


/*QUAKED func_illusionary(0 .5 .8) ?
A simple entity that looks solid but lets you walk through it.
*/
spawnfunc(func_illusionary)
{
	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_NOT;
	SetBrushEntityModelNoLOD(this);
	CSQCMODEL_AUTOINIT(this);
	//_makestatic_hidden(this);
}

/*QUAKED func_episodegate(0 .5 .8) ? E1 E2 E3 E4
This bmodel will appear if the episode has allready been completed, so players can't reenter it.
*/
spawnfunc(func_episodegate)
{
	if(!(serverflags & this.spawnflags))
		return;			// can still enter episode

	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_PUSH);	// so it doesn't get pushed by anything
	this.solid = SOLID_BSP;
	this.use = func_wall_use;
	_setmodel(this, this.model);
}

void func_bossgate_usetargets(entity this)
{
	SUB_UseTargets(this, NULL, NULL);
}

/*QUAKED func_bossgate(0 .5 .8) ?
This bmodel appears unless players have all of the episode sigils.
*/
const int BOSSGATE_INVERSE = 64;
spawnfunc(func_bossgate)
{
	bool inverse = (this.spawnflags & BOSSGATE_INVERSE);
	this.spawnflags &= ~BOSSGATE_INVERSE;
	if(!this.spawnflags)
		this.spawnflags = SIGIL_E1 | SIGIL_E2 | SIGIL_E3 | SIGIL_E4;
	this.spawnflags &= SIGIL_ALL;
	if((serverflags & this.spawnflags) == this.spawnflags) // ALL runes collected
	{
		if(!inverse)
		{
			delete(this);
			return;
		}
	}
	else
	{
		if(inverse)
		{
			delete(this);
			return;
		}
	}
	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_PUSH);	// so it doesn't get pushed by anything
	this.solid = SOLID_BSP;
	this.use = func_wall_use;
	_setmodel(this, this.model);

	if(this.target || this.target != "" || this.killtarget || this.killtarget != "")
	{
		setthink(this, func_bossgate_usetargets);
		this.nextthink = time + 0.2;
	}
}
#endif
