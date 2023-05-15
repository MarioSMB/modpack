.float min_fade, max_fade;

void() fadethink =
{
	local entity e;
	local float f;

	self.nextthink = time + 0.1;
	e = find(world, classname, "dummy");
	f = 0;
	while(e != world && !f)
	{
		if (e.origin_x > self.absmin_x)
			if (e.origin_x < self.absmax_x)
				if (e.origin_y > self.absmin_y)
					if (e.origin_y < self.absmax_y)
						if (e.origin_z < self.absmin_z)
							f = 1;
		e = find(e, classname, "dummy");
	}
	if (f)
	{
	
		if (self.min_fade && fadeinterval < 1)
		{
			if (self.alpha > self.min_fade)
			{
				self.alpha = self.alpha - fadeinterval;
				self.nextthink = time + 0.01;
			}
		}
		else
		{
			if (self.alpha > 0.2)
			{
				self.alpha = self.alpha - fadeinterval;
				self.nextthink = time + 0.01;
			}
			else
			{
				self.model = "";
				self.alpha = 0;
			}
		}
	}
	else
	{
		if (self.alpha < self.max_fade)
		{
			self.model = self.netname;
			self.modelindex = self.str;
			self.alpha = self.alpha + fadeinterval;
			self.nextthink = time + 0.01;
			if (self.alpha >= 1)
				self.alpha = 1;
		}
	}
};

void() func_fadewall =
{
	if (CheckStory(self))
	{
		remove(self);
		return;
	}
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel (self, self.model);
	self.netname = self.model;
	self.str = self.modelindex;
	self.think = fadethink;
	self.alpha = 1;
	if (!self.max_fade)
		self.max_fade = 1;
	self.nextthink = time + 0.1;
};


void() func_fadewalk =
{
	if (CheckStory(self))
	{
		remove(self);
		return;
	}
	self.angles = '0 0 0';
	setmodel (self, self.model);
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_BBOX;
	self.netname = self.model;
	self.str = self.modelindex;
	self.think = fadethink;
	self.alpha = 1;
	if (!self.max_fade)
		self.max_fade = 1;
	self.nextthink = time + 0.1;
};