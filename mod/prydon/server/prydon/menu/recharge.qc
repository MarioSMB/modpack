float() rechargecost =
{
	local float m;
	if (!(stat_loc & CHARGES))
		return 0;
	if (stat_dur >= stat_max_dur)
		return 0;
		
	m = ceil(((stat_max_dur - stat_dur) / stat_max_dur) * stat_price * stat_spell * 1.2);
	if (self.skill & SKILL_DISCOUNT)
		m = ceil((0.8 - (self.title_x * 0.05)) * m);
	if (m <= 1)
		m = 1;

	return m;
};
void() m_recharge_confirm =
{
	local float slot, cost, howm;
	local vector it;
	slot = root2(self.weapon);
	
	it = GetSlot(self, slot);
it_simplestat(it);
	it_itemstat();
	cost = repaircost();
	
	if (self.menu < 1)
		self.menu = 2;
	else if (self.menu > 2)
		self.menu = 1;

	if (self.button1)
	{
		self.button1 = 0;
		if (self.menu == 1)
		{
			if(!getgold(cost))
				prompt(self, "You don't have enough gold for this", self, 2);
			else
			{
it_simplestat(it);
				it_itemstat();
				stat_dur = stat_max_dur;
				SetSlot(self, slot, it_setstat());
				openmenu(self, m_repair, self.m_subject);
				self.weapon = 0;
				return;
			}	
		}
		else if (self.menu == 2)
		{
			closemenu(self);
			return;
		}
	}
	if (self.m_refresh < time)
	{
		inven(it, fabs(self.equip & self.weapon) + 1);
		howm = pgold();
		pprice (howm, cost);
		newline();
		line();
	
		if (self.menu == 1)
			WriteString(msg_mode, "Recharge this item?\n\{141}\[\1\] Yes\n \[\2\] No \n");
		else
			WriteString(msg_mode, "Recharge this item?\n \[\1\] Yes\n\{141}\[\2\] No \n");
	}
}

void() m_recharge =
{
	
	local float i;

	i = invenlst(self, CHARGES | 1, rechargecost, '5399907 6840690 6776064');
	
	if (i)
	{
		self.weapon = pow2(i);
		openmenu(self, m_recharge_confirm, self.m_subject);
	}
};