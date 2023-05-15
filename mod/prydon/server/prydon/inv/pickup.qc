
float(float slot) AutoEquip =
{
	local float d, i;
	it_simplestat(GetSlot(self, slot));
	it_itemstat();

	if (stat_loc & EQUIPABLE)
	{
		// don't let scrolls equip themselves if you're using a spell
		if (stat_loc & SPELL)
			if (self.spell)
				return FALSE;
		// auto-equip
		d = stat_loc & LOC;
		for (i=1; i <= TOTAL_SLOTS; i = i + 1)
		{
			if (self.equip & pow2(i))
			{
				it_simplestat(GetSlot(self, i));
				it_itemstat();
				if (stat_loc & d)
					return FALSE;
			}
		}
		return Equip(slot);
	}
};

void() openitembuy =
{
	openmenu(other, m_itembuy, self);
};

void() action_pickup =
{
	local vector r;
	local entity oself;
	oself = self;
	self.action = donothing;
	self = other.owner;
	if (oself.slot1_x == 0)
		return;

	r = pickupitem(oself.slot1);
	if (r)
	{
		dropitem(r);
		sprint(self, "Not enough room in your inventory\n");
	}
	
	if (oself.movedir)
		rq_advance(RQ_ITEMS);
	remove(oself);
	self = oself;
};



vector(vector it) pickupitem =
{
	local float i,d, slot;
	if  (!it)
		return IV_NULL;

	// find stackables?
	it_simplestat(it);
	it_itemstat();
	if (!stat_it)
		return IV_NULL;
		
	if (stat_it == IT_GOLD)
	{
		self.gp = self.gp + stat_dur;
		if (self.options & OPT_VERBOSE)
		{
			sprint(self, "Acquired ");
			sprint(self, ftos(stat_dur));
			sprint(self, " gold\n");
		}
		return IV_NULL;
	}
	if (self.skill & SKILL_POTION)
	{
		if (stat_it == IT_LESSER_HEAL || stat_it == IT_HEAL_POTION)
			stat_it = IT_GREATER_HEAL;
		else if (stat_it == IT_LESSER_MANA || stat_it == IT_MANA_POTION)
			stat_it = IT_GREATER_MANA;
		it = it_setstat();
	}
	if (stat_id)
	if (stat_loc & STACKABLE)
	{
		d = stat_dur;
		
		i = 1;
		while(i <= TOTAL_SLOTS)
		{
			i = inv_hasitem(it, i, 1);
			if (!i)
				break;
			it_simplestat(GetSlot(self, i));
			it_itemstat();
			stat_dur = stat_dur + d;
			d = stat_dur - stat_max_dur;
			if (d<0)
				d=0;
			stat_dur = stat_dur - d;

			SetSlot(self, i, it_setstat());
			if (stat_loc & AMMO)
				if (self.equip & pow2(i))
					self.armorvalue = stat_dur;
			if (!d)
			{
				if (self.options & OPT_VERBOSE)
				{
					
					sprint(self, "Acquired Item: ");
					msg_entity = self;
					WriteByte(MSG_ONE, 8);
					PrintItemName();
					WriteString(MSG_ONE, "\n");
				}
				return IV_NULL;
			}
			it_simplestat(it);
			stat_dur = d;
		
			it = it_setstat();
			i = i + 1;
		}

	}
	slot = inv_hasitem(IV_NULL, 1, 0);
	if (!slot)
		return it;
	SetSlot(self, slot, it);
	if (self.classname == "player")
		AutoEquip(slot);
	if (self.options & OPT_VERBOSE)
	{
		it_simplestat(it);
		sprint(self, "Acquired Item: ");
		msg_entity = self;
		WriteByte(MSG_ONE, 8);
		PrintItemName();
		WriteString(MSG_ONE, "\n");
	}		
	return IV_NULL;
};

void(vector it) pushitem =
{
	float i;
	if (it != IV_NULL)
	{
		for (i = 1; i < TOTAL_SLOTS; i = i + 1)
		{
			SetSlot(self, i, GetSlot(self, i + 1));
		}
		SetSlot(self, TOTAL_SLOTS, it);
	}

};