

void() throw_touch =
{
	local entity oself;
	oself = self;
	
	if (other == self.owner)
		return;
	if (Hit(self.enemy, other, SKILL_THROW))
	{
		self = oself;
		sound(self, CHAN_AUTO, "player/arrowhit.wav", 1, ATTN_NORM);
		remove(self);
	}
	else if (other == world)
	{
		self = self;
		remove(self);
	}
	else
	{
		self = oself;
		self.owner = other;
		self.velocity = self.dest1;
		self.think = fix_velocity;
		self.ltime = self.nextthink;
		self.nextthink = time;
	}
};
void() return_to_owner;
void() fix_velocity_chakram = { self.velocity = self.dest1; self.think = return_to_owner; self.nextthink = self.attack_finished;};

void() return_to_owner =
{
	//self.movetype = MOVETYPE_NOCLIP;
	self.dest1 = self.velocity = normalize(self.enemy.origin - self.origin) * 400;
	self.flags = 0;
	//self.touch = SUB_Null;
	
	if (vlen(self.enemy.origin - self.origin) < 50)
	{

		self.enemy.misc = self.enemy.misc - (self.enemy.misc & MISC_CHAKRAM);
		self.enemy.owner.rightarm = self.slot1;
		remove(self);
	}
	else
		self.nextthink = time + 0.1;
};

void() chakram_touch =
{
	local entity oself;
	oself = self;
	
	if (other == self.owner)
		return;
	if (Hit(self.enemy, other, SKILL_THROW))
	{
		self = oself;
		sound(self, CHAN_AUTO, "player/arrowhit.wav", 1, ATTN_NORM);
		return_to_owner();
	}
	else if (other == world)
	{
		self = oself;
		return_to_owner();
	}
	else
	{
		self = oself;
		self.owner = other;
		self.velocity = self.dest1;
		self.think = fix_velocity_chakram;

		self.nextthink = time;
	}
};
void(vector it) throwchakram =
{
	local entity e;
	if (self.classname == "dummy")
	{
		if (self.misc & MISC_CHAKRAM)
			return;
		self.misc = self.misc | MISC_CHAKRAM;
	}
	sound(self, CHAN_BODY, self.noise, 1, ATTN_NORM);
	it_simplestat(it);
	// major hackery here.
	e = launch_projectile(0, 400, BIG_DISTANCE, itemmodel(stat_it));
	itemapplyeffects(e);
	setsize(e, '0 0 0', '0 0 0');
	
	e.think = return_to_owner;
	e.attack_finished = e.nextthink = time + 0.5;
	e.touch = chakram_touch;
	self.owner.rightarm = IV_NULL;
	e.slot1 = it;
	
};

void(vector it) throwit =
{
	local entity e;

	if (self.classname == "dummy")
	{
		if (!takeammo(it_x))
		{
			sprint(self.owner, "Out of ammo\n");
			return;
		}
	}

	sound(self, CHAN_BODY, self.noise, 1, ATTN_NORM);
	it_simplestat(it);
	e = launch_projectile(0, 500, BIG_DISTANCE, itemmodel(stat_it));
	itemapplyeffects(e);
	setsize(e, '0 0 0', '0 0 0');
	e.touch = throw_touch;
	if (stat_it == IT_THROW_AXE)
	{
		e.angles_z = 90;
		e.avelocity = '300 0 0';
	}
};




void() throw_frames = [0, throw_frames]
{
	self.frame = self.bowframes + self.walkframe;

	// HACK!
	if (self.walkframe == 2)
		throwit(self.owner.rightarm);
	if (self.frame >= self.throwframes)
	{
		self.walkframe = 0;
		self.think = AnimatePlayer;
		self.nextthink = time + 0.1;
	}
	else
		self.walkframe = self.walkframe + 1;
	face(1);
};
void() throw1 = {self.walkframe = 1; throw_frames();};


void() chakram_frames = [0, chakram_frames]
{
	self.frame = self.bowframes + self.walkframe;

	// HACK!
	if (self.walkframe == 2)
		throwchakram(self.owner.rightarm);
	if (self.frame >= self.throwframes)
	{
		self.walkframe = 0;
		self.think = AnimatePlayer;
		self.nextthink = time + 0.1;
	}
	else
		self.walkframe = self.walkframe + 1;
	face(1);
};
void() chakram1 = {self.walkframe = 1; chakram_frames();};