// false runaway loop error avoidance
void(float loc, float skip) EquipCheck =
{
	local float i, change;
	local vector it;

	do
	{
		change = 0;
		for (i = 1; i <= TOTAL_SLOTS; i = i + 1)
		{
			if (i != skip)
			{
				
				it = GetSlot(self, i);
				if (!canuse(it))
				{
					if(Unequip(i, 0))
						change = 1;
				}
				else if (LOC & stat_loc & loc)
				{
					if(Unequip(i, 0))
						change = 1;
				}
			}
		}
		loc = 0;
	}
	while(change);
}



float(float slot) Equip =
{
	local vector it;
	it = GetSlot(self, slot);
	
	if (canuse(it) && (stat_loc & EQUIPABLE))
	{
		EquipCheck(stat_loc, slot);
		if (canuse(it))
		{
			sound(self, CHAN_AUTO, itemsound(stat_it), 1, ATTN_NORM);
			it_simplestat(it);
			it_itemstat();
			if (UseItem(1))
			{
				self.equip = self.equip | pow2(slot);
				boundstats(self);
				return TRUE;
			}
		}
	}
	return FALSE;
};


float(float slot, float recheck) Unequip =
{
	local float f;
	f = pow2(slot);
	
	if (self.equip & f)
	{
		it_simplestat(GetSlot(self, slot));
		it_itemstat();
		
		UseItem(-1);
		boundstats(self);
		self.equip = self.equip - f;
		if (recheck)
			EquipCheck(stat_loc, slot);
		return TRUE;
	}
	return FALSE;
	
};
void() UnequipAll =
{
	local float f, i;
	f = 1;
	
	for (i = i; i <= TOTAL_SLOTS; i = i + 1)
	{
		if (self.equip & f)
		{
			it_simplestat(GetSlot(self, i));
it_itemstat();
			UseItem(-1);
		}
		f = f * 2;
	}
	
	boundstats(self);
	self.equip = 0;

};
