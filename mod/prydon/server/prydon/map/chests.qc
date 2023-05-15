void () chestopen =
{
	if (!RequirementsMet(self, other))
	{

		if (self.attack_finished < time)
		{
			sound(self, CHAN_AUTO, "misc/locked.wav", 1, ATTN_NORM);
			sprint(other.owner, "locked\n");
			self.attack_finished = time + 1;
		}
		return;
	}
	sound(self, CHAN_AUTO, self.noise, 1, ATTN_NORM);
	self.frame = 1;
	dropallitems();
	self.action = nullfunc;
	self.use = nullfunc;
	generictrigger();
};

void () chest =
{
	if (!self.model)
		self.model = "progs/chest.mdl";
	precache_model(self.model);
	if (!self.noise)
		self.noise = "misc/chest.wav";
	precache_sound(self.noise);
	precache_sound ("misc/locked.wav");
	setmodel(self, self.model);
	setsize(self, '-16 -16 0', '16 16 16');
	self.effects = EF_SELECTABLE;
	self.classname	= "chest";
	if (!self.netname)
		self.netname = "Chest";
	legacy_fixinv();

	datacheck();
	
	self.owner = self;
	self.movetype	= MOVETYPE_TOSS;
	self.solid	= SOLID_BBOX;
	if (CheckStory(self) == 1)
	{
		self.frame = 1;
		self.action = nullfunc;
		self.use = nullfunc;
	}
	else if (self.targetname)
		self.use = chestopen;
	else
		self.action = chestopen;
};
