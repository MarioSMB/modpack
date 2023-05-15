
entity(float n) get_questitem =
{
	local entity e;
	
	e = find(world, classname, "questitem");
	while (e)
	{
		if (e.slot1_x == n)
			return e;
		e = find(e, classname, "questitem");
	}

	return world;

};

void() questitem =
{
	local entity e;

	if (self.items)
	{
		self.slot1 = legacy_itemv1(self.items);
		self.items = self.slot1_x;
		if (self.spell > 16)
			self.spell = self.spell + 8;
		if (self.gotstuff > 16)
			self.gotstuff = self.gotstuff + 8;
			
	}
	e = get_questitem(self.slot1_x);
	if (e != world && e != self)
		remove(e);
	if (cache)
	{
		precache_model(self.model);
		precache_sound(self.noise);
	}

};