void() gochangelevel =
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
	if (self.impulse)
		serverflags = recode(serverflags, 3, self.impulse);
	changelevel(self.message);
};


void() exit =
{
	precache_sound ("misc/locked.wav");
	if (!self.netname)
		self.netname = "Exit";
	self.effects = EF_SELECTABLE;
	setmodel(self, self.model);
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_BBOX;
	setorigin(self, self.origin);
	if (self.spawnflags & 1)
	{
		self.modelindex = 0;
		self.model = "";
	}
	self.use = gochangelevel;
	
	if (self.message)
		self.action = gochangelevel;
	else
		self.action = donothing;

};

void() nospawncheck =
{
	//FIXME
	//if (cvar("noexit"))
	//	sound(self, CHAN_AUTO, "spells/slow.wav", 1, ATTN_NORM);
	//cvar_set("noexit", "0");
}
void() gowarp =
{
	if (self.attack_finished > time)
		return;
	self.attack_finished = time + 1;

	if (!RequirementsMet(self, other))
	{
		sound(self, CHAN_AUTO, "misc/locked.wav", 1, ATTN_NORM);
		sprint(other.owner, "locked\n");
		return;
	}
	localcmd(self.message);
	localcmd("\n");
	self.think = nospawncheck;
	self.nextthink = time + 0.01;
};

void() func_invisible =
{
	setmodel(self, self.model);
	self.solid = SOLID_BBOX;
	self.model = "";
};
void() warp =
{
	if(self.story_min || self.story_max)
		precache_sound ("misc/locked.wav");
	if (!self.netname)
		self.netname = "Warp";
	self.effects = EF_SELECTABLE;
	setmodel(self, self.model);
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_BBOX;
	setorigin(self, self.origin);
	if (self.spawnflags & 1)
	{
		self.modelindex = 0;
		self.model = "";
	}
	self.use = gowarp;
	
	if (self.message)
		self.action = gowarp;
	else
		self.action = donothing;
};


