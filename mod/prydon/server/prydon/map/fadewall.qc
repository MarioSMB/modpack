#include "fadewall.qh"

#include "../subs/reqs.qh"

.float min_fade, max_fade;

void fadethink(entity this)
{
	this.nextthink = time + 0.1;
	entity e = find(NULL, classname, "dummy");
	float f = 0;
	while(e && !f)
	{
		if(e.origin_x > this.absmin_x)
			if(e.origin_x < this.absmax_x)
				if(e.origin_y > this.absmin_y)
					if(e.origin_y < this.absmax_y)
						if(e.origin_z < this.absmin_z)
							f = 1;
		e = find(e, classname, "dummy");
	}
	if(f)
	{
	
		if(this.min_fade && 0.02 < 1)
		{
			if(this.alpha > this.min_fade)
			{
				this.alpha = this.alpha - 0.02;
				this.nextthink = time + 0.01;
			}
		}
		else
		{
			if(this.alpha > 0.2)
			{
				this.alpha = this.alpha - 0.02;
				this.nextthink = time + 0.01;
			}
			else
			{
				this.model = "";
				this.alpha = 0;
			}
		}
	}
	else
	{
		if(this.alpha < this.max_fade)
		{
			this.model = this.netname;
			this.modelindex = this.str;
			this.alpha = this.alpha + 0.02;
			this.nextthink = time + 0.01;
			if(this.alpha >= 1)
				this.alpha = 1;
		}
	}
}

spawnfunc(func_fadewall)
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
	this.netname = this.model;
	this.str = this.modelindex;
	setthink(this, fadethink);
	this.alpha = 1;
	if(!this.max_fade)
		this.max_fade = 1;
	this.nextthink = time + 0.1;
}

spawnfunc(func_fadewalk)
{
	if(CheckStory(this))
	{
		delete(this);
		return;
	}
	this.angles = '0 0 0';
	_setmodel(this, this.model);
	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_BBOX;
	this.netname = this.model;
	this.str = this.modelindex;
	setthink(this, fadethink);
	this.alpha = 1;
	if(!this.max_fade)
		this.max_fade = 1;
	this.nextthink = time + 0.1;
}
