
void() arrow_touch =
{
	local entity oself;
	oself = self;
	
	if (other == self.owner)
		return;

	if (other.takedamage)
		if (!friendly(self.enemy, other))
			if (self.fire)
				FireDamage(self.enemy, other, self.fire);
	if (Hit(self.enemy, other, SKILL_BOW))
	{

		self = oself;
		sound(self, CHAN_AUTO, "player/arrowhit.wav", 1, ATTN_NORM);
		remove(self);
	}
	else if (other == world)
	{
		if (self.enemy.classname == "dummy")
		{
			self.velocity = '0 0 0';
			self.touch = SUB_Null;
			self.owner = world;
			self.think = death_fade;
			self.alpha = 1;
			self.nextthink = time + 8;
		}
		else
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

void() firearrow =
{
	local entity e;
	if (self.classname == "dummy")
	{
		if (!takeammo(IT_ARROWS)) // arrows
		{
			sprint(self.owner, "Out of arrows\n");
			return;
		}
	}
	sound(self, CHAN_BODY, "player/arrowuse.wav", 1, ATTN_NORM);
	e = launch_projectile(0, 500, BIG_DISTANCE, "progs/arrow.mdl");
	e.touch = arrow_touch;
};

void() firefirearrow =
{
	local entity e;
	float lev, dam;
	if (self.classname == "dummy")
	{
		if (!takeammo(IT_ARROWS)) // arrows
		{
			sprint(self.owner, "Out of arrows\n");
			return;
		}
	}
	sound(self, CHAN_BODY, "player/arrowuse.wav", 1, ATTN_NORM);
	e = launch_projectile(0, 500, BIG_DISTANCE, "progs/arrow.mdl");
	lev = GetSpellLevel(self.owner, SP_FLAME_ARROW);
	dam = lev * lev * 5;
	e.fire = e.fire + dam;
	e.effects = EF_DIMLIGHT;
	e.skin = 1;
	e.touch = arrow_touch;
};


void () bow_frames = [0, bow_frames]
{
	
		
	self.frame = self.jumpframes + self.walkframe;

	if (self.frame >= self.bowframes)
	{
		self.walkframe = 0;
		self.think = AnimatePlayer;
		self.nextthink = time + 0.1;
	}
	else
		self.walkframe = self.walkframe + 1;
	face(1);
	if (self.walkframe == 3)
	{
		if (self.gotstuff == SP_FLAME_ARROW)
			firefirearrow();
		else
			firearrow();
	}
};

void() bowattack1 =
{
	self.walkframe = 1;
	bow_frames();
};

void () cbow_frames = [0, cbow_frames]
{
	self.frame = self.doubleattack + self.walkframe;

	if (self.frame >= self.cbowframes)
	{
		self.walkframe = 0;
		self.think = AnimatePlayer;
		self.nextthink = time + 0.1;
	}
	else
		self.walkframe = self.walkframe + 1;
	face(1);
	if (self.walkframe == 3)
	{
		if (self.gotstuff == SP_FLAME_ARROW)
			firefirearrow();
		else
			firearrow();
	}
};
void() cbowattack1 = 
{
	self.walkframe = 1;
	cbow_frames();
};
