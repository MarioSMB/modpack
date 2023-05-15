
void() death_fade =
{
	if (self.alpha <= 0.06)
	{
		self.model = "";
		remove(self);
	}
	else
	{
		self.alpha = self.alpha - 0.03;
		self.nextthink = time + 0.02;
	}
};
void() death_frames = 
{
	local float f, b;
	
	self.think = death_frames;
	self.nextthink = time + 0.1;
	
	self.frame = self.frame + 1;
	b = (self.deathframes - self.runframes) / self.deathscenes;
	f = (self.frame - self.runframes) - 1;
	f = (f - (floor(f / b) * b)) + 1;

	if (f >= b)
	{
		if (self.classname == "body")
		{
			self.think = SUB_Null;
			return;
		}
		self.think = death_fade;
		self.alpha = 1;
		self.nextthink = time + 8;
	}
};
void() death_selectscene =
{
	local float b;
	b = (self.deathframes - self.runframes) / self.deathscenes;
	self.frame = self.deathframes - ((ceil(random() * self.deathscenes) * b));
};


void() death1 = 
{
	death_selectscene();
	death_frames();
};

void(float bodydeath) PlayerDie =
{
	float i;
	if (self.player)
		self = self.player;
		
	if (self.camera)
	{
		remove(self.camera);
		self.camera = world;
	}
	if (self.wayp)
	{
		remove(self.wayp);
		self.wayp = world;
	}
	if (self.spellprop)
	{
		remove(self.spellprop);
		self.spellprop = world;
	}
	if (self.owner.classname == "player")
		openmenu(self.owner, m_dead, self.owner);
	if (self.classname == "helper")
		if (self.sbarsub)
			self.sbarsub.summon_count = self.sbarsub.summon_count - 1;
	if (self.ai & AI_FOLLOW)
		if (self.sbarsub)
			self.sbarsub.follow_npcs = self.sbarsub.follow_npcs - 1;
	self.owner.health = 0;
	self.health = 0;
	self.takedamage = DAMAGE_NO;
	self.owner.takedamage = DAMAGE_NO;
	self.effects = 0;
	
	if (self.theme)
		setdmusic(world.noise2);
	if (self.killtarget)
		self.target = self.killtarget;
		
	if (self.target)
	{
		other = self.enemy;
		generictrigger();
	}
	if (bodydeath)
	{
		if (!drop_body())
		{
			dropallitems();
			if (self.cold_time > time)
			{
				for(i = 0; i < 3; i = i + 1)
					spawngib("progs/frozen.mdl");
				for(i = 0; i < 3; i = i + 1)
					spawngib("progs/frozen2.mdl");
				for(i = 0; i < 3; i = i + 1)
					spawngib("progs/frozen3.mdl");
				sound(self, CHAN_VOICE, "spells/shatter.wav", 1, ATTN_NORM);
				remove(self);
				return;
			}
			self.deadflag = 1;
	
			self.flags = 0;
			self.solid = SOLID_NOT;
			self.movetype = MOVETYPE_TOSS;
		}
		self = self.owner;
		Unstat();
		self.equip = 0;
		self.gp = 0;
		for (i = 1; i <= TOTAL_SLOTS; i = i +1)
			ClearSlot(self, i);
		Restat();
		self = self.player;
	}
	death1();
	self.owner.player = world;
	self.player = self;

	if (self.noise4)
		sound(self, CHAN_VOICE, self.noise4, 1, ATTN_NORM);

	self.owner = self;	
};