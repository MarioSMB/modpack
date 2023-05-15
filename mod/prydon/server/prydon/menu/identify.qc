float IDENTIFY_COST = 4;
void() m_identify;

float() m_identifycallback =
{
	if (!stat_id)
		return IDENTIFY_COST;
	return 0;
};

void() m_identify_confirm =
{
	local float slot, howm;
	local vector it;

	slot = root2(self.weapon);
	
	it = GetSlot(self, slot);
	it_simplestat(it);
	it_itemstat();
	
	if (self.menu < 1)
		self.menu = 2;
	else if (self.menu > 2)
		self.menu = 1;

	if (self.button1)
	{
		self.button1 = 0;
		if (self.menu == 1)
		{
			if(!getgold(IDENTIFY_COST))
				prompt(self, "You don't have enough gold for this", self, 2);
			else
			{
				it_simplestat(it);
				it_itemstat();
				stat_id = 1;
				SetSlot(self, slot, it_setstat());
				closemenu(self);
				openmenu(self, m_inven, self);
				return;
			}	
		}
		else if (self.menu == 2)
		{
			openmenu(self, m_identify, self.m_subject);
			return;
		}
	}
	if (self.m_refresh < time)
	{
		inven(it, fabs(self.equip & self.weapon) + 1);
		howm = pgold();
		pprice(howm, IDENTIFY_COST);
		
		newline();
		line();
	
		if (self.menu == 1)
			WriteString(msg_mode, "Identify this item?\n\{141}\[\1\] Yes\n \[\2\] No \n");
		else
			WriteString(msg_mode, "Identify this item?\n \[\1\] Yes\n\{141}\[\2\] No \n");
	
	}
}

void() m_identify =
{
	
	local float i;
	
	i = invenlst(self, 1, m_identifycallback, '4809829 7238761 6715648');
	if (i)
	{
		self.weapon = pow2(i);
		openmenu(self, m_identify_confirm, self.m_subject);	
	}
};