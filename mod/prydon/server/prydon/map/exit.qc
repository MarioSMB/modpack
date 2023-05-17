#include "exit.qh"

#include "../subs/math.qh"
#include "../subs/reqs.qh"

void gochangelevel(entity this, entity actor, entity trigger)
{
	if(!RequirementsMet(this, trigger))
	{
		if(this.attack_finished < time)
		{
			_sound(this, CHAN_AUTO, "misc/locked.wav", 1, ATTN_NORM);
			sprint(trigger.owner, "locked\n");
			this.attack_finished = time + 1;
		}
		return;
	}
	if(this.impulse)
		serverflags = recode(serverflags, 3, this.impulse);
	changelevel(this.message);
}

void gochangelevel_action(entity this, entity targ)
{
	gochangelevel(this, NULL, targ);
}

spawnfunc(exit)
{
	precache_sound("misc/locked.wav");
	if(!this.netname)
		this.netname = "Exit";
	this.effects = EF_SELECTABLE;
	_setmodel(this, this.model);
	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_BBOX;
	setorigin(this, this.origin);
	if(this.spawnflags & 1)
	{
		this.modelindex = 0;
		this.model = "";
	}
	this.use = gochangelevel;
	
	if(this.message)
		this.action = gochangelevel_action;
	else
		this.action = donothing;
}

void nospawncheck(entity this)
{
	//FIXME
	//if(cvar("noexit"))
	//	sound(this, CHAN_AUTO, "spells/slow.wav", 1, ATTN_NORM);
	//cvar_set("noexit", "0");
}

void gowarp(entity this, entity actor, entity trigger)
{
	if(this.attack_finished > time)
		return;
	this.attack_finished = time + 1;

	if(!RequirementsMet(this, trigger))
	{
		_sound(this, CHAN_AUTO, "misc/locked.wav", 1, ATTN_NORM);
		sprint(trigger.owner, "locked\n");
		return;
	}
	// TODO: dangerous
	localcmd(strcat(this.message, "\n"));
	setthink(this, nospawncheck);
	this.nextthink = time + 0.01;
}

void gowarp_action(entity this, entity targ)
{
	gowarp(this, NULL, targ);
}

spawnfunc(func_invisible)
{
	_setmodel(this, this.model);
	this.solid = SOLID_BBOX;
	this.model = "";
}

spawnfunc(warp)
{
	if(this.story_min || this.story_max)
		precache_sound("misc/locked.wav");
	if(!this.netname)
		this.netname = "Warp";
	this.effects = EF_SELECTABLE;
	_setmodel(this, this.model);
	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_BBOX;
	setorigin(this, this.origin);
	if(this.spawnflags & 1)
	{
		this.modelindex = 0;
		this.model = "";
	}
	this.use = gowarp;
	
	if(this.message)
		this.action = gowarp_action;
	else
		this.action = donothing;
}
