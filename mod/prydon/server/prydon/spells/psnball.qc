void() homing =
{
	local vector v;
	v = normalize(self.goalentity.origin - self.origin);
	self.velocity = normalize(v * 5 + self.velocity) * 120;
	self.angles = vectoangles(self.velocity);
	self.nextthink = time + 0.01;
	if (self.attack_finished < time)
		remove(self);
};



void() poison_1 = [0, poison_2] {};
void() poison_2 = [1, poison_3] {};
void() poison_3 = [2, SUB_Remove] {};

void() poisonball_hit =
{
	local entity e;
	
	if (other == self.owner)
		return;
	setmodel(self, "progs/poison.spr");
	self.velocity = '0 0 0';
	self.solid = SOLID_NOT;
	poison_1();
	
	e = findradius(self.origin, 220);
	while (e)
	{
		MagicHit(self.enemy, e);
		e = e.chain;
	}
};

void (float lev) poisonball_go =
{
	local entity e;

	e = launch_projectile(0, 120, spell_range(SP_POISONBALL), "progs/w_spike.mdl");
	if (lev > 4)
		e.touch = poisonball_hit;
	else
		e.touch = ball_hit;
	e.poidam = ceil(lev * lev * 1.2) + 20;
	e.think = homing;
	e.goalentity = self.enemy;
	e.enemy = self;
	e.owner = self;
	e.nextthink = time;
	e.attack_finished = time + 10;
	sound(self, CHAN_WEAPON, "spells/pfire.wav", 1, ATTN_NORM);
}
