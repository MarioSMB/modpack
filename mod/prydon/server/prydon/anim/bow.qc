#include "bow.qh"

#include "../spells/spells.qh"
#include "../spells/sval.qh"
#include "../subs/combat.qh"
#include "../subs/subs.qh"

void arrow_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.takedamage)
		if(!friendly(this.enemy, toucher))
			if(this.fire)
				FireDamage(this.enemy, toucher, this.fire);
	if(Hit(this.enemy, toucher, SKILL_BOW))
	{
		_sound(this, CHAN_AUTO, "player/arrowhit.wav", 1, ATTN_NORM);
		delete(this);
	}
	else if(!toucher)
	{
		if(this.enemy.classname == "dummy")
		{
			this.velocity = '0 0 0';
			settouch(this, func_null);
			this.owner = NULL;
			setthink(this, death_fade);
			this.alpha = 1;
			this.nextthink = time + 8;
		}
		else
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

void firearrow(entity this)
{
	if(this.classname == "dummy")
	{
		if(!takeammo(this.owner, IT_ARROWS)) // arrows
		{
			sprint(this.owner, "Out of arrows\n");
			return;
		}
	}
	_sound(this, CHAN_BODY, "player/arrowuse.wav", 1, ATTN_NORM);
	entity e = launch_projectile(this, 0, 500, BIG_DISTANCE, "progs/arrow.mdl");
	settouch(e, arrow_touch);
}

void firefirearrow(entity this)
{
	if(this.classname == "dummy")
	{
		if(!takeammo(this.owner, IT_ARROWS)) // arrows
		{
			sprint(this.owner, "Out of arrows\n");
			return;
		}
	}
	_sound(this, CHAN_BODY, "player/arrowuse.wav", 1, ATTN_NORM);
	entity e = launch_projectile(this, 0, 500, BIG_DISTANCE, "progs/arrow.mdl");
	float lev = GetSpellLevel(this.owner, SP_FLAME_ARROW);
	float dam = lev * lev * 5;
	e.fire = e.fire + dam;
	e.effects = EF_DIMLIGHT;
	e.skin = 1;
	settouch(e, arrow_touch);
}

void bow_frames(entity this)
{
	set_anim(this, 0, bow_frames);
		
	this.frame = this.jumpframes + this.walkframe;

	if(this.frame >= this.bowframes)
	{
		this.walkframe = 0;
		setthink(this, AnimatePlayer);
		this.nextthink = time + 0.1;
	}
	else
		this.walkframe = this.walkframe + 1;
	face(this, 1);
	if(this.walkframe == 3)
	{
		if(this.gotstuff == SP_FLAME_ARROW)
			firefirearrow(this);
		else
			firearrow(this);
	}
}

void bowattack1(entity this)
{
	this.walkframe = 1;
	bow_frames(this);
}

void cbow_frames(entity this)
{
	set_anim(this, 0, cbow_frames);
	this.frame = this.doubleattack + this.walkframe;

	if(this.frame >= this.cbowframes)
	{
		this.walkframe = 0;
		setthink(this, AnimatePlayer);
		this.nextthink = time + 0.1;
	}
	else
		this.walkframe = this.walkframe + 1;
	face(this, 1);
	if(this.walkframe == 3)
	{
		if(this.gotstuff == SP_FLAME_ARROW)
			firefirearrow(this);
		else
			firearrow(this);
	}
}

void cbowattack1(entity this)
{
	this.walkframe = 1;
	cbow_frames(this);
}
