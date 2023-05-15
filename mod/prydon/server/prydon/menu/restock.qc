void() m_restock;
float() restockcost =
{
	local float m;
	if (!(stat_loc & STACKABLE))
		return 0;
	if (stat_dur >= stat_max_dur)
		return 0;
	m = ceil((1 / stat_max_dur) * stat_price * 1.5);
	if (self.skill & SKILL_DISCOUNT)
		m = (0.8 - (self.title_x * 0.05) * m);
	
	if (m <= 1)
		m = 1;
	return m;
};
void() m_restock_confirm =
{
	local float slot, cost, howm;
	local vector it;
	slot = root2(self.weapon);
	
	it = GetSlot(self, slot);
	it_simplestat(it);
	it_itemstat();
	cost = restockcost();
	
	if (self.menu < 1)
		self.menu = 4;
	else if (self.menu > 4)
		self.menu = 1;

	if (self.button1)
	{
		self.button1 = 0;
		if (self.menu == 1)
		{
			howm = 1;
			if(!getgold(howm * cost))
				prompt(self, "You don't have enough gold for this", self, 2);
			else
			{
				it_simplestat(it);
it_itemstat();
				stat_dur = stat_dur + howm;
				SetSlot(self, slot, it_setstat());

			}	
		}
		else if (self.menu == 2)
		{
			if ((stat_max_dur - stat_dur) < 10)
				howm = (stat_max_dur - stat_dur);
			else
				howm = 10;
				
			if(!getgold(howm * cost))
				prompt(self, "You don't have enough gold for this", self, 2);
			else
			{
it_simplestat(it);
				it_itemstat();
				stat_dur = stat_dur + howm;
				SetSlot(self, slot, it_setstat());
			}	
		}
		else if (self.menu == 3)
		{
			howm = (stat_max_dur - stat_dur);
			if ((cost * howm) > self.gp)
			{
				howm = floor(self.gp / cost);
			}
			if(!getgold(howm * cost))
				prompt(self, "You don't have enough gold for this", self, 2);
			else
			{
				it_simplestat(it);
it_itemstat();
				stat_dur = stat_dur + howm;
				SetSlot(self, slot, it_setstat());
				openmenu(self, m_restock, self.m_subject);
				self.weapon = 0;
				return;
			}	
		}
		else
		{
			closemenu(self);
			return;
		}
	}
	if (self.m_refresh < time)
	{

		inven(it, fabs(self.equip & self.weapon) + 1);
		howm = pgold();
		pprice(howm, cost);
		
		p4 (' ', 'E', 'A', '.');
		newline();
		line();

/*
 \[\1\] Buy 1 \n \[\2\] Buy 10\n \[\3\] Fill  \n \[\4\] Cancel\n
*/
		if (self.menu == 1)
			WriteString(msg_mode, "\{141}\[\1\] Buy 1 \n \[\2\] Buy 10\n \[\3\] Fill  \n \[\4\] Cancel\n");
		else if (self.menu == 2)
			WriteString(msg_mode, " \[\1\] Buy 1 \n\{141}\[\2\] Buy 10\n \[\3\] Fill  \n \[\4\] Cancel\n");
		else if (self.menu == 3)
			WriteString(msg_mode, " \[\1\] Buy 1 \n \[\2\] Buy 10\n\{141}\[\3\] Fill  \n \[\4\] Cancel\n");
		else if (self.menu == 4)
			WriteString(msg_mode, " \[\1\] Buy 1 \n \[\2\] Buy 10\n \[\3\] Fill  \n\{141}\[\4\] Cancel\n");
	}
}

void() m_restock =
{
	
	local float i;

	i = invenlst(self, STACKABLE | 1, restockcost, '5399923 7630691 7012352');
	
	if (i)
	{
		self.weapon = pow2(i);
		openmenu(self, m_restock_confirm, self.m_subject);
	}
};