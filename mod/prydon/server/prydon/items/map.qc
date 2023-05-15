
void() item_touch =
{
	if (other == world)
	{
		it_simplestat(self.slot1);
		sound(self, CHAN_BODY, itemsound(stat_it), 1, ATTN_NORM);
		self.avelocity = '0 0 0';
		self.angles_z = self.angles_x = 0;
		self.frame = 0;
		self.touch = SUB_Null;
		if (self.gp)
			self.action = openitembuy;
		else
			self.action = action_pickup;
	}
	else if (self.flags & FL_ONGROUND)
	{
		if (self.gp)
			self.action = openitembuy;
		else
			self.action = action_pickup;
	}
};



void() item =
{
	self.classname = "item";
	if (CheckStory(self))
	{
		remove(self);
		return;
	}
	legacy_item(0);
	it_simplestat(self.slot1);
	
	if (!stat_it && !self.fallz)
	{
		remove(self);
		return;
	}
	itemapplyeffects(self);
	
	setsize (self, '-16 -16 0', '16 16 5');
	self.flags = FL_ITEM;		// make extra wide
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;
	self.effects = self.effects | EF_SELECTABLE;
	self.touch = item_touch;
	if (self.menu)
		self.gp = self.menu;
};

void() shopitem =
{
	if (!self.angles_y)
		self.angles_y = random() * 360;
		
	if (self.fallz)
	{
		legacy_item(1);
		self.slot1 = randitem(self.slot1_x, itemvalue, self.fallz);
		if (self.fallz & 1)
		{
			if (!self.netname)
				self.netname = "wepshop";
		}
		else if (self.fallz & 2)
		{
			if (!self.netname)
				self.netname = "magshop";
		}
	}
	else
		legacy_item(0);
	it_simplestat(self.slot1);
	it_itemstat();
	if (!self.gp)
		self.gp = stat_price; // fixme
	item();
};
void() armoryitem =
{
	self.fallz = self.fallz | 1;
	shopitem();
};
void() magicitem =
{
	self.fallz = self.fallz | 2;
	shopitem();
};

