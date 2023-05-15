


void() twister_start = 
{
	local entity e;
	local float i;
	local vector v, r;
	
	if (self.frame < 23)
	{
		self.frame = self.frame + 1;
		self.nextthink = time + 0.05;
	}
	else if (time > self.ac)
	{
		if (self.frame < 48)
		{
			self.frame = self.frame + 1;
			self.nextthink = time + 0.05;
		}
		else
		{
			sound(self, CHAN_WEAPON, "misc/null.wav", 1, ATTN_NORM);
			remove(self);
		}
	}
	else
	{
		e = findradius(self.origin, 80);
		while (e)
		{
			if (e.takedamage)
			{
				if (!friendly(e, self))
				{
					e.flags = e.flags - (e.flags & FL_ONGROUND);
					v = normalize(e.origin - self.origin);
					v_z = 0;
					r_x = v_y;
					r_y = v_x * -1;
					r = r - v * 0.15;
					r = r * vlen(e.origin - self.origin) * 8;
					e.velocity = r + '0 0 31';
					if (self.attack_finished < time)
					{
						if (random() < 0.4)
							T_Damage(self.owner, e, 1, 4);
						self.attack_finished = time + 0.1;
					}
				}
			}
			e = e.chain;
		}
		makevectors(self.mangle);
		if (random() < 0.1)
			self.mangle_y = self.mangle_y + random() * 180 - 90;
		self.velocity = v_forward * 100;
		self.flags = self.flags - (self.flags & FL_ONGROUND); // LordHavoc 20040417: this was - FL_ONGROUND, which really messed up flags if it wasn't set
		if (!netplay)
		{
			for (i = 0; i < 9; i = i + 1)
			{
				self.finalangle_y = self.finalangle_y + 10;
				makevectors(self.finalangle);
				particle(self.origin + v_up * (i * 6) + v_forward * (i * 5), v_right * (i * 10) + v_up * 5, 12, 3);
			}
		}		
		self.nextthink = time + 0.01;
	}
	
};
void(float lev) twister_go =
{
	local entity e;
	
	e = spawn();
	setorigin(e, self.enemy.origin - '0 0 20');
	e.frags = lev;
	setmodel(e, "progs/twister.mdl");
	sound(e, CHAN_WEAPON, "spells/twist.wav", 1, ATTN_NORM);
	e.mangle = self.angles;
	e.think = twister_start;
	e.owner = self;
	e.solid = SOLID_TRIGGER;
	e.movetype = MOVETYPE_FLY;
	setsize(e, '-32 -32 0', '32 32 78');
	e.team = self.team;
	e.nextthink = time;
	e.ac = time + 1 + lev * 3;
	e.effects = EF_ADDITIVE;
	e.alpha = 0.75;
}
