float(float it) itemcount =
{
	float g, i;
	
	for(i=1; i<9; i = i + 1)
	{
		it_simplestat(GetSlot(self, i));
		if (stat_it == it)
			g = g + stat_dur;

	}
	return g;
};


float(float it, float pref, float suf, float howmuch) takeamount =
{
	float g, i;
	
	if (howmuch < 0)
		return FALSE;
	else if (howmuch == 0)
		return TRUE;
		
	g = itemcount(it);
	
	if (howmuch > g)
		return FALSE; // not enough
	
	for (i=8; i > 0; i = i - 1)
	{
		it_simplestat(GetSlot(self, i));
		if (stat_it == it && stat_pref == pref && stat_suf == suf)
		{
			g = stat_dur;
			stat_dur = stat_dur - howmuch;
			if (stat_dur <= 0)
			{
				ClearSlot(self, i);
				howmuch = howmuch - g;
			}
			else
			{
				SetSlot(self, i, it_setstat());
				return TRUE;
			}
			if (howmuch <= 0)
				return TRUE;
		}
	}
	return TRUE;
};

void() replenish_dur =
{
	float i;
	for( i = 1; i <= TOTAL_SLOTS; i = i + 1)
	{
		if (self.equip & pow2(i))
		{
			it_simplestat(GetSlot(self, i));
			it_itemstat();
			
			if (stat_spec & SPEC_REPLENISH)
			{
				stat_dur = stat_dur + 1;
				if (stat_dur > stat_max_dur)
					stat_dur = stat_max_dur;
				if (stat_loc & AMMO)
					self.armorvalue = stat_dur;
			}
		}
	}

}

float(float howmuch) getgold =
{

	if (self.skill & SKILL_DISCOUNT)
	{
		howmuch = ceil((0.8 - (self.title_x * 0.05)) * howmuch);
	}
	if (howmuch > self.gp)
		return FALSE;
	howmuch = ceil(howmuch);
	self.gp = self.gp - howmuch;
	if (self.options & OPT_VERBOSE)
	{
		sprint(self, "Lost ");
		sprint(self, ftos(howmuch));
		sprint(self, " gold\n");
	}
	return TRUE;
};

void(float howmuch) givegold =
{
	if (howmuch <= 0)
		return;
	howmuch = ceil(howmuch);
	self.gp = self.gp + howmuch;
	if (self.options & OPT_VERBOSE)
	{
		sprint(self, "Acquired ");
		sprint(self, ftos(howmuch));
		sprint(self, " gold\n");
	}
};

float(float it) takeammo =
{
	// first find the slot of the arrows / scroll
	local float i, succeeded;
	local entity e;
	e = self;
	self = self.owner;
	succeeded = 0;
	for(i=1; i<= TOTAL_SLOTS; i = i + 1)
	{
		if (self.equip & pow2(i))
		{
			
			it_simplestat(GetSlot(self, i));
			it_itemstat();
			if (stat_it == it)
			{
				
				if (stat_dur > 0)
				{
					stat_dur = stat_dur - 1;
					self.armorvalue = stat_dur;
					SetSlot(self, i, it_setstat());
					succeeded = 1;
				}
				if (stat_dur <= 0)
				{
					if (stat_spec & SPEC_REPLENISH)
					{
						stat_dur = 0;
						SetSlot(self, i, it_setstat());
						return succeeded;
					}
					else
					{
						if (self.flags & FL_CLIENT)
						{
							msg_entity = self;
							WriteByte(MSG_ONE, 8);
							PrintItemName();
							WriteString(MSG_ONE, " has run out\n");
						}
						Unequip(i, 1);
						ClearSlot(self, i);
						// TEST
						AutoEquip(inv_hasitem(it * '1 0 0', 1, 0));
						return succeeded;
					}
				}
				self = e;
				return succeeded;
			}
		}
	}
	self = e;
	return FALSE;		
};


float(float sp) TakeCharges =
{
	// first find the slot of the arrows / scroll
	local float i;
	local entity e;
	e = self;
	self = self.owner;
	
	for(i=1; i<=TOTAL_SLOTS; i = i + 1)
	{
		if (self.equip & pow2(i))
		{
			it_simplestat(GetSlot(self, i));
			it_itemstat();
			if ((stat_action & 63) == sp)
			{
				if (stat_loc & CHARGES) 
				{
					
					self.armorvalue = stat_dur;
					if (stat_dur == 1)
					{
						stat_dur = 0;
						if (self.flags & FL_CLIENT)
						{
							msg_entity = self;
							WriteByte(MSG_ONE, 8);
							PrintItemName();
							WriteString(MSG_ONE, " has run out\n");
						}
						SetSlot(self, i, it_setstat());
						//if (!(stat_spec & SPEC_REPLENISH))				
						//	Unequip(i, 1);
						self = e;
						return TRUE;
					}
					else if (stat_dur <= 0)
					{
						self = e;
						return FALSE;
					}
					stat_dur = stat_dur - 1;
					SetSlot(self, i, it_setstat());
					self = e;
					return TRUE;
				}
			}
		}
	}
	self = e;
	return TRUE;		
};
void(entity who, float weps) DamageEquipment =
{
	float i;
	local entity oself;
	
	if (random() < 0.8)
		return;
		
	for(i = 1; i <= TOTAL_SLOTS; i = i + 1)
	{
		if (who.equip & pow2(i))
		{
			it_simplestat(GetSlot(who, i));
			it_itemstat();
			if (stat_loc & DURABILITY)
			{
				if ((weps && stat_daml) || (!weps && stat_def))
				{
					if (random() < 0.1)
					{
						stat_dur = stat_dur - 1;
						if (stat_dur <= 0)
						{
							
							
							oself = self;
							self = who;
							Unequip(i, 1);
							it_simplestat(GetSlot(who, i));
							it_itemstat();
							stat_dur = 0;
							self = oself;
							
							SetSlot(who, i, it_setstat());
							if (who.flags & FL_CLIENT)
							{
								msg_entity = who;
								WriteByte(MSG_ONE, 8);
								PrintItemName();
								WriteString(MSG_ONE, " has broken\n");
							}
							sound(who.player, CHAN_BODY, "player/break.wav", 1, ATTN_NORM);
						}
						else
						{
							if (stat_dur == ceil(stat_max_dur  * 0.15))
							{
								if (who.flags & FL_CLIENT)
								{
									msg_entity = who;
									WriteByte(MSG_ONE, 8);
									PrintItemName();
									WriteString(MSG_ONE, " is about to break\n");
								}	
							}
							SetSlot(who, i, it_setstat());
						}
					}
				}
			}
		}
	}
};

float(vector it, entity e) takesomething =
{
	local entity oself;
	float i;
	it_simplestat(it);
	it_itemstat();
	
	oself = self;
	
	self = e;
		
	if (stat_it == IT_GOLD)
	{
		if (getgold(stat_dur))
		{
			self = oself;
			return TRUE;
	}
		else
		{
			self = oself;
			return FALSE;
		}
	}
	else if (stat_loc & STACKABLE)
	{
	
		if (takeamount(stat_it, stat_pref, stat_suf, stat_dur))
		{
			self = oself;
			return TRUE;
		}
		else
		{
			self = oself;
			return FALSE;
		}
	}
	else
	{
	
		i = inv_hasitem(it, TRUE, 0);
		if (i)
		{
			Unequip(i, 1);
			ClearSlot(self, i);
			self = oself;
			return TRUE;
		}
		else
			return FALSE;
	}


}

float (vector it, entity e) hassomething =
{
	local entity oself;
	local float i;

	it_simplestat(it);
	it_itemstat();
	i = stat_dur;
	oself = self;
	self = e;
	
		
	if (stat_it == IT_GOLD)
	{
		if (self.gp >= stat_dur)
		{
			self = oself;
			return TRUE;
		}
		else
		{
			self = oself;
			return FALSE;
		}

	}
	else if (stat_loc & STACKABLE)
	{
		if (itemcount(stat_it) >= i)
		{
			self = oself;
			return TRUE;
		}
		else
		{
			self = oself;
			return FALSE;
		}
	}
	else
	{
		i = inv_hasitem(it, 1, 0);
		if (i)
		{
			self = oself;
			return TRUE;
		}
		else
		{
			self = oself;
			return FALSE;
		}
	}

};