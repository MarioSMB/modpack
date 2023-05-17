#include "misc.qh"

#include "../subs/reqs.qh"

spawnfunc(invtest) {}

spawnfunc(func_illusionary)
{
	if(CheckStory(this))
	{
		delete(this);
		return;
	}
	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_NOT;
	_setmodel(this, this.model);
	if(!this.alpha)
        CSQCMODEL_AUTOINIT(this);
}

spawnfunc(func_wall)
{
	if(CheckStory(this))
	{
		delete(this);
		return;
	}
	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_PUSH);	// so it doesn't get pushed by anything
	this.solid = SOLID_BSP;
	_setmodel(this, this.model);
}

void dripland(entity this, entity toucher)
{
	float r = ceil(random() * 3);
	if(r == 1)
		_sound(this, CHAN_AUTO, "misc/drip1.wav", 1, ATTN_NORM);
	else if(r == 2)
		_sound(this, CHAN_AUTO, "misc/drip2.wav", 1, ATTN_NORM);
	else if(r == 2)
		_sound(this, CHAN_AUTO, "misc/drip3.wav", 1, ATTN_NORM);
	delete(this);
}

void makedrip(entity this)
{
	entity e = spawn();
	_setmodel(e, "progs/drop.mdl");
	setorigin(e, this.origin);
	e.solid = SOLID_TRIGGER;
	set_movetype(e, MOVETYPE_BOUNCE);
	settouch(e, dripland);
	e.flags = 0;
	setsize(e, '0 0 0', '0 0 0');
	
	this.nextthink = time + 10 * random();
}

spawnfunc(drip)
{
	if(netplay)
	{
		delete(this);
		return;
	}
	if(CheckStory(this))
	{
		delete(this);
		return;
	}
	precache_sound("misc/drip1.wav");
	precache_sound("misc/drip2.wav");
	precache_sound("misc/drip3.wav");
	precache_model("progs/drop.mdl");
	setthink(this, makedrip);
	this.nextthink = time + 10 * random();
}

spawnfunc(deadguy)
{
	if(CheckStory(this))
	{
		delete(this);
		return;
	}
	
	if(!this.model)
		this.model = "progs/human.mdl";
	precache_model(this.model);
	_setmodel(this, this.model);
	this.frame = 18;
	if(!this.misc & MISC_NO_SKINS)
		this.skin = this.skin + 2;
	
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	this.solid = SOLID_BBOX;
	droptofloor(this);
	this.angles_y = random() * 360;
	CSQCMODEL_AUTOINIT(this);
}