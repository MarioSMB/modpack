#include "subs.qh"

void Precache_Set(entity this, string modelname)
{
	precache_model(modelname);
	_setmodel(this, modelname);
}

bool friendly(entity e1, entity e2)
{
	if((e1.team & 256) & e2.team)
		return false;
	if((e1.team & 224) == (e2.team & 224))
		if((e1.team & 31) != (e2.team & 31))
			return false;
	return true;
}

void CycleFrames(entity this, float a, float z)
{
	this.frame = this.frame + 1;
	if(this.frame < a || this.frame > z)
		this.frame = a;
}

bool infront(entity this, entity targ)
{
	makevectors(this.angles);
	vector vec = normalize (targ.origin - this.origin);
	float dot = vec * v_forward;
	
	return (dot > 0.3);
}

bool visible(entity this, entity e)
{
	traceline(this.origin, (e.absmin + e.absmax) * 0.5, true, this);
	if(trace_fraction == 1)
		return true;
	else if(trace_ent == e)
		return true;

	return false;
}

void fix_velocity(entity this)
{
	this.velocity = this.dest1;
	setthink(this, SUB_Remove);
	this.nextthink = this.ltime;
}

entity launch_projectile(entity this, float ofs, float sped, float range, string mdel)
{
	makevectors(this.angles);
	entity e = spawn();
	e.owner = this;
	e.velocity = normalize(this.enemy.origin - this.origin) * sped;

	e.angles = vectoangles(e.velocity);
	if(ofs)
	{
		e.angles_y = e.angles_y + ofs;
		makevectors(e.angles_x * '-1 0 0' + e.angles_y * '0 1 0'); // LordHavoc: 20040420 fixed inverted pitch problem
		e.velocity = v_forward * sped;
	}
	e.dest1 = e.velocity;
	set_movetype(e, MOVETYPE_FLY);
	e.solid = SOLID_BBOX;
	_setmodel(e, mdel);
	setorigin(e, this.origin + v_up * 16 + v_forward * 8);
	e.enemy = this;
	setthink(e, SUB_Remove);
	e.nextthink = time + range / sped;
	setsize(e, '0 0 0', '0 0 0');
	return e;
}

entity find_spot(entity this)
{
	float dir = 0;
	int runaway = 0;
	vector org;
	entity e = NULL;
	entity spot = spawn();
	setsize(spot, VEC_HULL_MIN, VEC_HULL_MAX);
	set_movetype(spot, MOVETYPE_STEP);
	float dist = 34;
	makevectors(spot.angles);
	if(this.enemy)
		org = this.enemy.origin;
	else
		org = this.origin;
	org = org + '0 0 48';
	//spot.flags = FL_FLY;
	spot.solid = SOLID_BBOX;
	do 
	{
		if(dir == 0)
			setorigin(spot, org + v_forward * dist);
		else if(dir == 1)
			setorigin(spot, org + v_forward * -1 * dist);
		else if(dir == 2)
			setorigin(spot, org + v_right * dist);
		else if(dir == 3)
		{
			setorigin(spot, org + v_right * -1 * dist);
			dir = -1;
			dist = dist + 8;
		}
		droptofloor(spot);
		dir = dir + 1;
		if(spot != findradius(spot.origin, 32))
			continue;
		traceline(org, spot.origin, false, spot);
		if(trace_fraction != 1)
			continue;
		
		if(runaway > 80)
		{
			spot.flags = 0;
			e = spot;
			return e;
		}
		runaway += 1;			
	}
	while(!t_walkmove(spot, 0, 0));
	spot.flags = 0;
	e = spot;
	return e;
}

void sound2(entity e, string snd)
{
	if(e.owner)
		e = e.owner;
		
	e.voice = snd; // hold it off
}

void setdmusic(string msc)
{
	if(!music)
		return;
	if(music == msc)
		return;
		
	music = msc;
	_sound(NULL, CH_BGM_SINGLE, music, 1, ATTN_NONE);
}
