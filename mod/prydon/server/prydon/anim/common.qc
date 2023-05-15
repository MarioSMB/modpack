
void(float figure_aspeed) face = 
{
	float dspeed;
	
	if (self.player)
		self = self.player; // Quest's weird  bug?
	updatevwep();
	if (self.enemy && (self.enemy.owner.health > 0))
		self.angles_y = vectoyaw(self.enemy.origin - self.origin);
	if (figure_aspeed == 1)
	{
		dspeed = self.owner.aspeed;
		
		if (self.frenzy_time > time)
			dspeed = dspeed + self.frenzy_factor;
		else
			self.frenzy_factor = 0;
		if (self.misc & MISC_MAIMED)
			dspeed = dspeed - 50;
	
		self.nextthink = (self.nextthink - time) * (1 - (dspeed / 100)) + time;
	}
	
	
	if (self.cold_time > time)
	{
		self.nextthink = (self.nextthink - time) * (1/self.cold_factor) + time;
		if (self.nextthink >  self.cold_time)
			self.nextthink = self.cold_time;
	}
	else
	{
		if (self.cold_factor != 1)
		{
			self.cold_factor = 1;
			self.pausetime = time;
		}
	}
};

float (float sp, entity e) range_check =
{
	float len, rn;
	vector old, org;

	org = e.origin;
	if (org == '0 0 0')
	{
		org = (e.absmin + e.absmax) * 0.5;
		org_z = self.origin_z;
	}
	old = self.origin;
	org_z = (old_z + org_z * 3) * 0.25;
	
	len = vlen(org - old) - (e.size_x/2 + self.size_x/2);
	rn =  spell_range(sp) - 32;
	if (rn == BIG_DISTANCE)
		return 1;
	if ((visible(e) || len < 60))
	{
		if (len < rn)
			return 1;
	}
	else
		return 0;
};