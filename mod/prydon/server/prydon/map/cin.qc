#include "cin.qh"

#include "../subs/_mod.qh"

void goalpoint_use(entity this, entity actor, entity trigger)
{
	if(!actor)
		return;
	actor.enemy = this;
	actor.goalentity = this;
	actor.menu = this.spawnflags & 1;
}

void goalpoint_action(entity this, entity targ)
{
	generictrigger(this, NULL, targ);
}

spawnfunc(goalpoint)
{
	this.use = goalpoint_use;
	this.action = goalpoint_action;
}

void setai_use(entity this, entity actor, entity trigger)
{
	if(!actor)
		return;
	actor.team = this.team;
	actor.ai = this.ai;
}

spawnfunc(setai)
{
	this.use = setai_use;
}

void setmusic_use(entity this, entity actor, entity trigger)
{
	if(!actor)
		return;
	if(!RequirementsMet(this, actor))
		return;
	setdmusic(this.theme);
}

spawnfunc(setmusic)
{
	if(cache)
		precache_sound(this.theme);
		
	this.use = setmusic_use;
}

void setaction_use(entity this, entity actor, entity trigger)
{
	if(!actor)
		return;
	if(!RequirementsMet(this, actor))
		return;
	if(this.altaction)
		actor.gotstuff = actor.altaction = this.altaction;
	if(this.spell)
		actor.spell = this.spell;
	if(this.target)
		actor.goalentity = find(NULL,targetname, this.target);
}

spawnfunc(setaction)
{
	this.use = setaction_use;
}

void setcamera_use(entity this, entity actor, entity trigger)
{
	if(!trigger)
		return;
	if(actor.owner.camera)
	{
		if(this.spawnflags)
		{
			actor.owner.camera.goalentity = NULL;
			if(actor.owner.camera.mangle != '0 0 0')
			{
				actor.owner.rotang = actor.owner.camera.mangle;
				actor.owner.camera.mangle = '0 0 0';
			}
		}
		else
		{
			if(actor.owner.camera.mangle == '0 0 0')
				actor.owner.camera.mangle = actor.owner.rotang;
			actor.owner.camera.goalentity = this;
			
		}
	}
}

spawnfunc(setcamera)
{
	this.use = setcamera_use;
}

void setplayer_use(entity this, entity actor, entity trigger)
{
	if(!actor)
		return;
	actor.owner.player = find(NULL, targetname, this.target);
	actor.owner.player.owner = actor;
	actor = actor.owner.player;
}

spawnfunc(setplayer)
{
	this.use = setplayer_use;
}

void takestuff_use(entity this, entity actor, entity trigger)
{
	float success;

	if(!trigger)
		return;
	if(trigger.owner)
		trigger = trigger.owner;
		
	if(this.spawnflags)
	{
		success = hassomething(this.slot1, trigger);
		if(success)
			Trigger(this, actor, trigger, 1);
		else
			Trigger(this, actor, trigger, 2);
	}
	else
	{
		success = takesomething(this.slot1, trigger);
		if(success)
		{
			Trigger(this, actor, trigger, 1);
			pickupitem(this, actor.slot1);
		}
		else
			Trigger(this, actor, trigger, 2);
	}
	
}

spawnfunc(takestuff)
{
	if(this.items)
	{
		this.slot1 = legacy_itemv1(this.items);
		this.items = 0;
	}
	this.use = takestuff_use;
}

void dropstuff_use(entity this, entity actor, entity trigger)
{
	if(!trigger)
		return;

	// hack
	dropallitems(actor);
}

spawnfunc(dropstuff)
{
	this.use = dropstuff_use;
}

void statmod_apply(entity src, entity dest, float sgn)
{
	(dest.(src.mod_field)) = (dest.(src.mod_field)) + src.value * sgn;
}

void setstats_use(entity this, entity actor, entity trigger)
{
	if(!actor)
		return;
	if(!RequirementsMet(this, actor))
		return;
	statmod_apply(this, actor, 1);
}

spawnfunc(setstats)
{
	this.use = setstats_use;
}

spawnfunc(script)
{
	// script
	// entry point (typically targetname, can be other stuff)
	// action
	// ...string var
	// ...inventory slots
	// ...number
	// action target
	// exit/next (.targets)
}
