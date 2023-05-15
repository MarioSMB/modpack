
void() quest = 
{
	local entity z;

	//load stored values
	self.classname = "quest";

	if (!self.story_name)
	{
		// try to auto detect old story ents
		if (self.impulse > 15)
			self.story_name = "opt1";
		else if (self.story_min > 15)
			self.story_name = "opt1";
		else if (self.story_max > 15)
			self.story_name = "opt1";
		else
			self.story_name = "main";
		self.targetname = self.story_name;
	}
	
	self.lip = GetOldStory(self.targetname, self.lip);

	// remove redundant ents
	z = find(world, classname, "quest");
	while(z)
	{
		if (z != self)
		{
			if (self.targetname)
			{
				if (z.targetname == self.targetname)
				{
					if (self.impulse == z.impulse)
					{
						self.lip = z.lip;
						remove(z);
					}
				}
			}
			if (z.story_name == self.story_name)
			{
				if (self.impulse == z.impulse)
				{
					self.lip = z.lip;
					remove(z);
				}
			}
		}
		z = find(z, classname, "quest");
	}
	if (!fileaccess)
	{
		if (self.spawnflags & 1)
			self.lip = 0;
	}
};


void(float lv, string name, string storage) spawnstory =
{
	local entity e;
	
	e = spawn();
	e.lip = lv;
	e.story_name = name;
	e.targetname = storage;
	SetOldStory(storage, lv);
	call (quest, e);
};