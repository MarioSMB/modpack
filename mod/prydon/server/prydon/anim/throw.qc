#include "throw.qh"

#include "common.qh"
#include "../subs/combat.qh"
#include "../subs/subs.qh"

void throw_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;
	if(Hit(this.enemy, toucher, SKILL_THROW))
	{
		_sound(this, CHAN_AUTO, "player/arrowhit.wav", 1, ATTN_NORM);
		delete(this);
	}
	else if(!toucher)
	{
		delete(this);
	}
	else
	{
		this.owner = toucher;
		this.velocity = this.dest1;
		setthink(this, fix_velocity);
		this.ltime = this.nextthink;
		this.nextthink = time;
	}
}

void return_to_owner(entity this)
{
	//set_movetype(this, MOVETYPE_NOCLIP);
	this.dest1 = this.velocity = normalize(this.enemy.origin - this.origin) * 400;
	this.flags = 0;
	//settouch(this, func_null);
	
	if(vdist(this.enemy.origin - this.origin, <, 50))
	{
		this.enemy.misc = this.enemy.misc - (this.enemy.misc & MISC_CHAKRAM);
		this.enemy.owner.rightarm = this.slot1;
		delete(this);
	}
	else
		this.nextthink = time + 0.1;
}

void fix_velocity_chakram(entity this)
{
	this.velocity = this.dest1;
	setthink(this, return_to_owner);
	this.nextthink = this.attack_finished;
}

void chakram_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;
	if(Hit(this.enemy, toucher, SKILL_THROW))
	{
		_sound(this, CHAN_AUTO, "player/arrowhit.wav", 1, ATTN_NORM);
		return_to_owner(this);
	}
	else if(!toucher)
	{
		return_to_owner(this);
	}
	else
	{
		this.owner = toucher;
		this.velocity = this.dest1;
		setthink(this, fix_velocity_chakram);

		this.nextthink = time;
	}
}

void throwchakram(entity this, vector itslot)
{
	if(this.classname == "dummy")
	{
		if(this.misc & MISC_CHAKRAM)
			return;
		this.misc |= MISC_CHAKRAM;
	}
	_sound(this, CHAN_BODY, this.noise, 1, ATTN_NORM);
	it_simplestat(this, itslot);
	// major hackery here.
	entity e = launch_projectile(this, 0, 400, BIG_DISTANCE, itemmodel(stat_it));
	itemapplyeffects(e);
	setsize(e, '0 0 0', '0 0 0');
	
	setthink(e, return_to_owner);
	e.attack_finished = e.nextthink = time + 0.5;
	settouch(e, chakram_touch);
	this.owner.rightarm = IV_NULL;
	e.slot1 = itslot;
}

void throwit(entity this, vector itslot)
{
	if(this.classname == "dummy")
	{
		if(!takeammo(this.owner, itslot.x))
		{
			sprint(this.owner, "Out of ammo\n");
			return;
		}
	}

	_sound(this, CHAN_BODY, this.noise, 1, ATTN_NORM);
	it_simplestat(this, itslot);
	entity e = launch_projectile(this, 0, 500, BIG_DISTANCE, itemmodel(stat_it));
	itemapplyeffects(e);
	setsize(e, '0 0 0', '0 0 0');
	settouch(e, throw_touch);
	if(stat_it == IT_THROW_AXE)
	{
		e.angles_z = 90;
		e.avelocity = '300 0 0';
	}
}

void throw_frames(entity this)
{
	set_anim(this, 0, throw_frames);
	this.frame = this.bowframes + this.walkframe;

	// HACK!
	if(this.walkframe == 2)
		throwit(this, this.owner.rightarm);
	if(this.frame >= this.throwframes)
	{
		this.walkframe = 0;
		setthink(this, AnimatePlayer);
		this.nextthink = time + 0.1;
	}
	else
		this.walkframe = this.walkframe + 1;
	face(this, 1);
}

void throw1(entity this) { this.walkframe = 1; throw_frames(this); }

void chakram_frames(entity this)
{
	set_anim(this, 0, chakram_frames);
	this.frame = this.bowframes + this.walkframe;

	// HACK!
	if(this.walkframe == 2)
		throwchakram(this, this.owner.rightarm);
	if(this.frame >= this.throwframes)
	{
		this.walkframe = 0;
		setthink(this, AnimatePlayer);
		this.nextthink = time + 0.1;
	}
	else
		this.walkframe = this.walkframe + 1;
	face(this, 1);
}

void chakram1(entity this) { this.walkframe = 1; chakram_frames(this); }
