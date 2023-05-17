#include "chests.qh"

#include "../subs/_mod.qh"

void chest_open(entity this, entity targ)
{
	if(!RequirementsMet(this, targ))
	{
		if(this.attack_finished < time)
		{
			_sound(this, CHAN_AUTO, "misc/locked.wav", 1, ATTN_NORM);
			sprint(targ.owner, "locked\n");
			this.attack_finished = time + 1;
		}
		return;
	}
	_sound(this, CHAN_AUTO, this.noise, 1, ATTN_NORM);
	this.frame = 1;
	dropallitems(this);
	this.action = func_null;
	this.use = func_null;
	generictrigger(this, NULL, targ);
}

void chestopen(entity this, entity actor, entity trigger)
{
	chest_open(this, trigger); // TODO: actor?
}

spawnfunc(chest)
{
	if(!this.model)
		this.model = "progs/chest.mdl";
	precache_model(this.model);
	if(!this.noise)
		this.noise = "misc/chest.wav";
	precache_sound(this.noise);
	precache_sound("misc/locked.wav");
	_setmodel(this, this.model);
	setsize(this, '-16 -16 0', '16 16 16');
	this.effects = EF_SELECTABLE;
	this.classname	= "chest";
	if(!this.netname)
		this.netname = "Chest";
	legacy_fixinv(this);

	datacheck(this);
	
	this.owner = this;
	set_movetype(this, MOVETYPE_TOSS);
	this.solid	= SOLID_BBOX;
	if(CheckStory(this) == 1)
	{
		this.frame = 1;
		this.action = func_null;
		this.use = func_null;
	}
	else if(this.targetname)
		this.use = chestopen;
	else
		this.action = chest_open;
}
