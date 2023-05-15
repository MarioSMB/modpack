
nosave float source;

float() canuseon =
{
	if (source == IT_IDSCROLL)
	{
		if (!stat_id)
			return TRUE;
	}
	else if (source == IT_OIL_OF_REPAIR)
	{
		if (stat_dur < stat_max_dur)
			if (stat_loc & DURABILITY)
				return TRUE;
	}
	else if (source == IT_OIL)
	{
		if (stat_it < IT_GOLD)
		if (!stat_suf)
			if (stat_loc & EQUIPABLE)
				return TRUE;
	}
	else if (source == IT_OIL2)
	{
		if (stat_it < IT_GOLD)
		if (!stat_pref)
			if (stat_loc & EQUIPABLE)
				return TRUE;
	}
	return FALSE;
	
};

void() m_useon =
{
	local float source_slot, i, source_suf, source_pref, re_equip;

	source_slot = root2(self.weapon);
	it_simplestat(GetSlot(self, source_slot));
	source = stat_it;
	source_suf = stat_suf; // for OIL
	source_pref = stat_pref;
	if (source == IT_OIL_OF_REPAIR)
		i = invenlst(self, DURABILITY, canuseon, '0 0 0');
	else
		i = invenlst(self, 0, canuseon, '0 0 0');
		
	if (i)
	{
		openmenu(self, m_inven, self);
		it_simplestat(GetSlot(self, i));
		it_itemstat();	
		if (!canuseon())
		{
			sprint(self, "Can't!\n");
			return;
		}
		if (source == IT_IDSCROLL)			
		{
			stat_id = 1;
			SetSlot(self, i, it_setstat());
		}
		else if (source == IT_OIL_OF_REPAIR)
		{
			stat_dur = stat_dur + 5;
			if (stat_dur >= stat_max_dur)
				stat_dur = stat_max_dur;
			SetSlot(self, i, it_setstat());
		}
		else if (source == IT_OIL)
		{
			if (self.equip & pow2(i))
			{
				Unequip(i, 1);
				re_equip = 1;
			}
			it_simplestat(GetSlot(self, i));
			stat_suf = source_suf;
			
			SetSlot(self, i, it_setstat());
			if (re_equip)
				Equip(i);
		}
		else if (source == IT_OIL2)
		{
			if (self.equip & pow2(i))
			{
				Unequip(i, 1);
				re_equip = 1;
			}
			it_simplestat(GetSlot(self, i));
			stat_pref = source_pref;
			SetSlot(self, i, it_setstat());
			if (re_equip)
				Equip(i);
		}
		sound(self, CHAN_AUTO, itemsound(source), 1, ATTN_NORM);	
		self.weapon = pow2(i);
		
		it_simplestat(GetSlot(self, source_slot));
		stat_dur = stat_dur - 1;
		if (stat_dur > 0)
			SetSlot(self, source_slot, it_setstat());
		else
			ClearSlot(self, source_slot);
		return;
	}
};