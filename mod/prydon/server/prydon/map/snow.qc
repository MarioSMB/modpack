#include "snow.qh"

#include "../subs/reqs.qh"

void snow_drift(entity this)
{
	this.velocity_x = random() * 20 - 10;
	this.velocity_y = random() * 20 - 10;
	this.nextthink = time + 0.1 + random();
}

void snow_removetouch(entity this, entity toucher)
{
	delete(this);
}

void snow_think(entity this)
{
	entity e;
	float f;

   	this.nextthink = time + 0.1;
	if(!snowtype)
	{
		e = find(NULL, classname, "dummy");
		f = 0;
		while(e && !f)
		{
			if(e.origin_x > this.absmin_x)
				if(e.origin_x < this.absmax_x)
					if(e.origin_y > this.absmin_y)
						if(e.origin_y < this.absmax_y)
							f = 1;
			e = find(e, classname, "dummy");
		}
		if(!f)
			return;
	}

	if(snowtype == 2) // DP
	{
		te_particlesnow(this.absmin, this.absmax, '0 0 -80', this.fade * 10, 12);
	}
	else
	{
		f = this.fade;
		while(f)
		{
			e = spawn();
			_setmodel(e, "progs/s_snow.spr");
			e.solid = SOLID_TRIGGER;
			settouch(e, snow_removetouch);
			setthink(e, snow_drift);
			e.nextthink = time + 0.1;
			set_movetype(e, MOVETYPE_FLY);
			e.velocity = '0 0 -50';
			e.velocity_x = random() * 20 - 10;
			e.velocity_y = random() * 20 - 10;
			setsize(e, '0 0 0', '0 0 0');
			vector v;
			v_x = this.absmin_x + ((this.absmax_x - this.absmin_x) * random());
			v_y = this.absmin_y + ((this.absmax_y - this.absmin_y) * random());
			v_z = this.absmax_z - 10;
			setorigin(e, v);
			f = f - 1;
		}
		this.nextthink = time + 0.2;
	}
}

spawnfunc(snow)
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
	if(!snowtype)
		precache_model("progs/s_snow.spr");
	
	this.angles = '0 0 0';
	this.solid = SOLID_NOT;
	_setmodel(this, this.model);	// set size and link into world
	setorigin(this, this.origin);

	set_movetype(this, MOVETYPE_NONE);
	this.modelindex = 0;
	this.model = "";
	setthink(this, snow_think);
	this.nextthink = time + 0.1;

	if(!this.fade)
		this.fade = 1;
}
