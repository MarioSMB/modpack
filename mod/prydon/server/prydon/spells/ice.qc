
void() ice_go =
{
	setmodel(self, "progs/icicle.mdl");
	setsize(self, '0 0 0', '0 0 0');
	self.velocity = self.dest1;
	self.angles = vectoangles(self.dest1);
	sound(self, CHAN_WEAPON, "spells/launch.wav", 1, ATTN_NORM);
	self.think = SUB_Remove; self.nextthink = time + 5;
	self.movetype = MOVETYPE_FLY;
	self.solid = SOLID_BBOX;
	self.touch = ball_hit;
	self.enemy = self.owner;
}

void(float lev) iceblast_go =
{
	local entity e;
	local float dm, b, ofs, dly;
	local vector org, traj;
	
	if (lev <= 1)
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
		if (dly < 1)
			dly = 1;
	}
	makevectors(self.enemy.origin - self.origin);
	traj = normalize('0 0 -1' + (v_forward * 0.5));
	
	traceline(self.enemy.origin, self.enemy.origin + traj * -400, TRUE, self);
	if (lev == 0)
		dm = 5;
	else
		dm = ceil((lev * lev * 1.4 + 4) / b);
	while(b > 0)
	{
		e = spawn();
		org_z = trace_endpos_z;
		org_y = (random() * ofs * 2) - ofs + trace_endpos_y;
		org_x = (random() * ofs * 2) - ofs + trace_endpos_x;
		setorigin(e, org);
		e.cold  = dm;
		e.think = ice_go;
		e.nextthink = time + dly * random();
		e.enemy = self;
		e.owner = self;
		e.dest1 = traj * 400;
		b = b - 1;
	}
};