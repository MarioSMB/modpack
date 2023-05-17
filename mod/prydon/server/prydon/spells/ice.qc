#include "ice.qh"

void ice_go(entity this)
{
	_setmodel(this, "progs/icicle.mdl");
	setsize(this, '0 0 0', '0 0 0');
	this.velocity = this.dest1;
	this.angles = vectoangles(this.dest1);
	_sound(this, CH_WEAPON_SINGLE, "spells/launch.wav", 1, ATTN_NORM);
	setthink(this, SUB_Remove);
	this.nextthink = time + 5;
	set_movetype(this, MOVETYPE_FLY);
	this.solid = SOLID_BBOX;
	settouch(this, ball_hit);
	this.enemy = this.owner;
}

void iceblast_go(entity this, float lev)
{
	float dm, b, ofs, dly;
	
	if(lev <= 1)
	{
		b = 1;
		ofs = 0;
		dly = 0;
	}
	else
	{
		b = lev * 3;	
		ofs = 50 - (2 * lev);
		dly = 5  / lev;
		if(dly < 1)
			dly = 1;
	}
	makevectors(this.enemy.origin - this.origin);
	vector traj = normalize('0 0 -1' + (v_forward * 0.5));
	
	traceline(this.enemy.origin, this.enemy.origin + traj * -400, true, this);
	if(lev == 0)
		dm = 5;
	else
		dm = ceil((lev * lev * 1.4 + 4) / b);
	while(b > 0)
	{
		entity e = spawn();
		vector org;
		org.z = trace_endpos.z;
		org.y = (random() * ofs * 2) - ofs + trace_endpos.y;
		org.x = (random() * ofs * 2) - ofs + trace_endpos.x;
		setorigin(e, org);
		e.cold  = dm;
		setthink(e, ice_go);
		e.nextthink = time + dly * random();
		e.enemy = this;
		e.owner = this;
		e.dest1 = traj * 400;
		b = b - 1;
	}
}
