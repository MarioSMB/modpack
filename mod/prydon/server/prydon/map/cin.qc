
void() goalpoint =
{
	self.use = goalpoint;
	self.action = generictrigger;
	
	if (activator == world)
		return;
	activator.enemy = self;
	activator.goalentity = self;
	activator.menu = self.spawnflags & 1;
};

void() setai =
{
	self.use = setai;
	if (activator == world)
		return;
	activator.team = self.team;
	activator.ai = self.ai;
};

void() setmusic =
{
	if (cache)
		precache_sound(self.theme);
		
	self.use = setmusic;
	if (activator == world)
		return;
	
	if (!RequirementsMet(self, activator))
		return;
	setdmusic(self.theme);
}

void() setaction =
{
	self.use = setaction;
	if (activator == world)
		return;
	if (!RequirementsMet(self, activator))
		return;
	if (self.altaction)
		activator.gotstuff = activator.altaction = self.altaction;
	if (self.spell)
		activator.spell = self.spell;
	if (self.target)
		activator.goalentity = find(world,targetname, self.target);
};

void() setcamera =
{
	self.use = setcamera;
	if (other == world)
		return;
	if (activator.owner.camera)
	{
		if (self.spawnflags)
		{
			activator.owner.camera.goalentity = world;
			if (activator.owner.camera.mangle != '0 0 0')
			{
				activator.owner.rotang = activator.owner.camera.mangle;
				activator.owner.camera.mangle = '0 0 0';
			}
		}
		else
		{
			if (activator.owner.camera.mangle == '0 0 0')
				activator.owner.camera.mangle = activator.owner.rotang;
			activator.owner.camera.goalentity = self;
			
		}
	}
};


void() setplayer =
{
	self.use = setplayer;
	if (activator == world)
		return;
	activator.owner.player = find(world, targetname, self.target);
	activator.owner.player.owner = activator;
	activator = activator.owner.player;
};



void() takestuff =
{
	float success;

	if (self.items)
	{
		self.slot1 = legacy_itemv1(self.items);
		self.items = 0;
	}
	self.use = takestuff;
	if (other == world)
		return;
	if (other.owner)
		other = other.owner;
		
	if (self.spawnflags)
	{
		success = hassomething(self.slot1, other);
		if (success)
			Trigger(self, activator, other, 1);
		else
			Trigger(self, activator, other, 2);
	}
	else
	{
		success = takesomething(self.slot1, other);
		if (success)
		{
			Trigger(self, activator, other, 1);
			self = activator;
			pickupitem(self.slot1);
		}
		else
			Trigger(self, activator, other, 2);
	}
	
};

void() dropstuff =
{
	entity o;

	o = self;
	self.use = dropstuff;
	if (!other)
		return;

	// hack
	call(dropallitems, activator);
};

void(entity src, entity dest, float sgn) statmod_apply =
{
	(dest.(src.mod_field)) = (dest.(src.mod_field)) + src.value * sgn;
	 
};

void() setstats =
{
	self.use = setstats;
	if (activator == world)
		return;
	if (!RequirementsMet(self, activator))
		return;
	statmod_apply (self, activator, 1);
};

void() script =
{
	// script
	// entry point (typically targetname, can be other stuff)
	// action
	// ...string var
	// ...inventory slots
	// ...number
	// action target
	// exit/next (.targets)

};