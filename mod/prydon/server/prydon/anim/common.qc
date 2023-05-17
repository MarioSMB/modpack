#include "common.qh"

#include "../spells/sstats.qh"
#include "../subs/subs.qh"

void face(entity this, float figure_aspeed)
{
	if(this.player)
		this = this.player; // Quest's weird  bug?
	updatevwep(this);
	if(this.enemy && (this.enemy.owner.health > 0))
		this.angles_y = vectoyaw(this.enemy.origin - this.origin);
	if(figure_aspeed == 1)
	{
		float dspeed = this.owner.aspeed;
		
		if(this.frenzy_time > time)
			dspeed = dspeed + this.frenzy_factor;
		else
			this.frenzy_factor = 0;
		if(this.misc & MISC_MAIMED)
			dspeed = dspeed - 50;
	
		this.nextthink = (this.nextthink - time) * (1 - (dspeed / 100)) + time;
	}

	if(this.cold_time > time)
	{
		this.nextthink = (this.nextthink - time) * (1/this.cold_factor) + time;
		if(this.nextthink >  this.cold_time)
			this.nextthink = this.cold_time;
	}
	else
	{
		if(this.cold_factor != 1)
		{
			this.cold_factor = 1;
			this.pausetime = time;
		}
	}
}

bool range_check(entity this, float sp, entity e)
{
	vector org = e.origin;
	if(org == '0 0 0')
	{
		org = (e.absmin + e.absmax) * 0.5;
		org_z = this.origin_z;
	}
	vector old = this.origin;
	org_z = (old_z + org_z * 3) * 0.25;
	
	float len = vlen(org - old) - (e.size_x/2 + this.size_x/2);
	float rn =  spell_range(this, sp) - 32;
	if(rn == BIG_DISTANCE)
		return true;
	if((visible(this, e) || len < 60))
	{
		if(len < rn)
			return true;
	}
	return false;
}