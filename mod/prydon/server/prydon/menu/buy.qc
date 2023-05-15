float() m_buy_callback =
{
	if (self.skill & SKILL_DISCOUNT)
		return ceil((0.8 - (self.title_x * 0.05)) * stat_price);
	return stat_price;

};

void() m_buy_confirm =
{
	local float slot, howm;
	local vector r;
	
	slot = root2(self.weapon);
	r = GetSlot(self.m_subject, slot);
	if (self.menu < 1)
		self.menu = 2;
	else if (self.menu > 2)
		self.menu = 1;
		
	if (self.button1)
	{
		self.button1 = 0;
		if (self.menu == 1)
		{
			it_simplestat(r);
			it_itemstat();
			if (r != IV_NULL)
			{
				if (!getgold(stat_price))
				{
					prompt(self, "You don't have enough gold for this", self, 2);
					return;
				}
				r = pickupitem(r);
				if (!r)
				{
					sound(self.m_subject, CHAN_BODY, itemsound(stat_it), 1, ATTN_NORM);
					ClearSlot(self.m_subject, slot);
					closemenu(self);
					return;
				}
				else
				{
					prompt(self, "You don't have enough room\nin your inventory", self.m_subject, 2);
				}
			}
			return;
		}
		else if (self.menu == 2)
		{
			closemenu(self);
			return;
		}
	}
	if (self.m_refresh < time)
	{
		inven(r, 0);
		howm = pgold();
		pprice(howm, stat_price);
		newline();
		line();
		if (self.menu == 1)
			WriteString(msg_mode, "Buy this item?\n\{141}\[\1\] Yes\n \[\2\] No \n");
		else
			WriteString(msg_mode, "Buy this item?\n \[\1\] Yes\n\{141}\[\2\] No \n");
	}

};



void() m_buy =
{
	local float i;

	i = invenlst(self.m_subject, 1, m_buy_callback, '4355449 0 0');
	
	if (i)
	{
		self.weapon = pow2(i);
		openmenu(self, m_buy_confirm, self.m_subject);
	}
};



void() m_itembuy =
{
	local float howm;
	local vector r;
	
	if (self.menu != 1)
		self.menu = 1;
	if (self.button1)
	{

		self.button1 = 0;
		
		if(!getgold(self.m_subject.gp))
		{
			prompt(self, "You don't have enough gold for this", self, 2);
			return;
		}
		r = pickupitem(self.m_subject.slot1);
		it_simplestat(self.m_subject.slot1);
		if (!r)
		{
			sound(self.m_subject, CHAN_BODY, itemsound(stat_it), 1, ATTN_NORM);
			if (self.m_subject.spawnflags & 1)
			{
				// infinite
				closemenu(self);
				return;
			}
			else if (self.m_subject.netname)
			{
				// shopitem
				setmodel(self.m_subject, "");
				self.m_subject.items = 0;
				self.m_subject.slot1 = IV_NULL;
				self.m_subject.gp = 0;
			}
			else
				remove(self.m_subject);
			closemenu(self);
			return;
		}
		else
		{
			it_simplestat(r);
it_itemstat();
			if (self.skill & SKILL_DISCOUNT)
				givegold(0.8 - (self.title_x * 0.05) * self.m_subject.gp);
			else
				givegold(self.m_subject.gp);
			
			prompt(self, "You don't have enough room\nin your inventory", self, 2);
		}
		return;
	}
	if (self.m_refresh < time)
	{
		inven(self.m_subject.slot1, 0);

		howm = pgold();
		pprice(howm, self.m_subject.gp);
		newline();
		line();
		WriteString(msg_mode, "\n\{141}\[\1\] Buy    ");

	}
};
