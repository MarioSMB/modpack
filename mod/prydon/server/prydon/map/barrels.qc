.void() altdie;

void(string gibmodel) spawngib =
{
	local entity e;
	e = spawn();
	setmodel(e, gibmodel);
	e.think = SUB_Remove;
	e.nextthink = time + 1 + random() * 5;
	
	setorigin(e, (self.absmin + self.absmax) * 0.5);
	setsize(e, '0 0 0', '0 0 0');
	e.movetype = MOVETYPE_BOUNCE;
	e.solid = SOLID_NOT;
	e.avelocity_x = random() * 600 - 300;
	e.avelocity_y = random() * 600 - 300;
	e.avelocity_z = random() * 600 - 300;
	e.velocity_x = random() * 300 - 150;
	e.velocity_y = random() * 300 - 150;
	e.velocity_z = random() * 80 + 100;
};

void() barrel_poison =
{
	local float n;
	for(n = 0; n < 3; n = n + 1)
		spawngib(self.bkup_model);
	generictrigger();
	sound(self, CHAN_AUTO, self.noise4, 1, ATTN_NORM);
	other = world;
	self.owner = self;
	self.poidam = 30;
	self.enemy = self;
	self.takedamage = DAMAGE_NO;
	poisonball_hit();
}

void() barrel_nova =
{
	local float n;
	for(n = 0; n < 3; n = n + 1)
		spawngib(self.bkup_model);
	generictrigger();
	sound(self, CHAN_AUTO, self.noise4, 1, ATTN_NORM);
	self.takedamage = DAMAGE_NO;
	nova_go(0);
	remove(self);
}
void() barrel_explode =
{
	local entity e, oself;
	local float n;
	oself = self;
	self.tohit = 100;
	for(n = 0; n < 3; n = n + 1)
		spawngib(self.bkup_model);
	generictrigger();
	sound(self, CHAN_AUTO, self.noise4, 1, ATTN_NORM);	
	e = findradius(self.origin, 110);
	while(e)
	{
		if (e.takedamage)
		{
			if (!friendly(e, oself))
			{
				oself.fire = 5;
				MagicHit(oself, e);
			}
		}
		e = e.chain;
	}
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, oself.origin_x);
	WriteCoord (MSG_BROADCAST, oself.origin_y);
	WriteCoord (MSG_BROADCAST, oself.origin_z);

	remove(oself);
}

void(float bodydeath) barrel_die =
{
	float i;
	if (self.altdie)
	{
		self.think = self.altdie;
		self.nextthink = time;
		return;
	}
	
	dropallitems();
	for(i = 0; i < 3; i = i + 1)
		spawngib(self.bkup_model);
	sound(self, CHAN_AUTO, self.noise4, 1, ATTN_NORM);
	generictrigger();
	remove(self);
};

void() barrel =
{
	float r;
	if (CheckStory(self))
	{
		remove(self);
		return;
	}
	if (!self.model)
		self.model = "progs/barrel.mdl";
	precache_model(self.model);
	if (!self.noise4)
		self.noise4 = "misc/barrel.wav";
	precache_sound(self.noise4);
	self.effects = EF_SELECTABLE;
	if (!self.bkup_model)
		self.bkup_model = "progs/shrap.mdl";
	precache_model(self.bkup_model);
	setmodel(self, self.model);
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
	
	self.classname	= "barrel";
	if (!self.netname)
		self.netname = "barrel";
	self.health = 1;
	self.max_health = 1;
	self.owner = self;
	self.player = self;
	self.movetype	= MOVETYPE_TOSS;
	self.solid	= SOLID_BBOX;
	if (!self.team)
		self.team = 2;
	self.takedamage = DAMAGE_YES;
	self.flags = 0;
	self.die = barrel_die;
	// first possible trap
	if (self.droprandom)
	{
		if (random() < 0.1)
		{
			r = random();
			if (r < 0.4)
				self.altdie = barrel_explode;
			else if (r < 0.7)
				self.altdie = barrel_poison;
			else
				self.altdie = barrel_nova;
		}
	}
	self.frags = 1;
	self.dodge = 1;

};


void() hitwall =
{
	if (CheckStory(self))
	{
		remove(self);
		return;
	}
	if (!self.bkup_model)
		self.bkup_model = "progs/shrap.mdl";
	legacy_fixinv();

	precache_model(self.bkup_model);
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	setmodel (self, self.model);
	if (!self.max_health)
		self.max_health = 1;
	if (!self.health)
		self.health = self.max_health;
	if (!self.team)
		self.team = 2;
	self.takedamage = DAMAGE_YES;
	if (self.spawnflags)
	{
		self.pain = generictrigger;
		self.flags = self.flags | FL_GODMODE;
	}
	self.effects = EF_SELECTABLE;
	self.die = barrel_die;	
	self.owner = self;
	self.player = self;
	self.frags = 1;
	self.dodge = 1;
};
