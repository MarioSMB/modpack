float(entity who, float stats, float() callback, vector ptitle) invenlst =
{
	float end, begin, c, i, total, mslot;
	vector f;

	if (self.menu < 1)
		self.menu = 10;
	else if (self.menu > 10)
		self.menu = 1;
	total = 0;
	mslot = 0;
	
	begin = TOTAL_SLOTS;
	for (i = 1; i <= TOTAL_SLOTS; i = i + 1)
	{
		f = GetSlot(who, i);
		it_simplestat(f);
		it_itemstat();
		
		if (callback())
		{
			total = total + 1;
			if (total > self.m_num)
				if (i < begin)
					begin = i;
			if (i > end)
				end = i;
			if ((self.menu + self.m_num) == total)
				mslot = i;
		}
	}
	if (self.menu < 9)
	{
		if (!mslot)
		{
			if (self.impulse == -1)
			{
				self.menu = self.menu - 1;
				self.m_refresh = 0;
				if (self.menu < 1)
					self.menu = 10;
			}
			else	
				self.menu = self.menu + 1;
		}
	}
	else if (self.menu == 9)
	{
		if (total <= 8)
		{
			if (self.impulse == -1)
			{
				self.menu = self.menu - 1;
				self.m_refresh = 0;
				if (self.menu < 1)
					self.menu = 10;
			}
			else	
				self.menu = self.menu + 1;
		}
	}
	
	if (self.button1)
	{
		self.button1 = 0;
		if (self.menu == 9)
		{
			if (total > 8)
			{
				self.m_num = self.m_num + 8;
				if (self.m_num >= TOTAL_SLOTS)
					self.m_num = 0;
			}
		}
		else if (self.menu == 10)
		{
			closemenu(self);
			return 0;
		}
		else
		{
			it_simplestat(GetSlot(who, mslot));
			it_itemstat();
			if (callback())
				return mslot;
		}
	}
	if (self.m_refresh >= time)
		return 0;
	pstart();
	if (ptitle != '0 0 0')
	{
		pvstr(ptitle);
		newline();
		if (stats & 1)
			pgold();
		line();
	}
	total = 0;
	for (i = begin; i <= end; i = i + 1)
	{
		f = GetSlot(who, i);
		it_simplestat(f);
		it_itemstat();
		c = callback();
		
		if (c)
		{
			total = total + 1;
			if (total > 8)
				break;
			newline();
			poption(total, TRUE);	
			
			if (who.equip & pow2(i))
				red = RED_ON;		
			PrintItemName();
			if (stats & 1)
			{
				pad(33);
				pnum(c);
				p2('G', 'P');
			}
			pad(40);

			if (stats & (DURABILITY | STACKABLE | CHARGES))
			{
				newline();
				pad(5);
				if (stats & STACKABLE)
				{
					p8('Q', 'u', 'a', 'n', 't', 'i', 't', 'y');
					p1(' ');
				}
				else if (stats & CHARGES)
					p8('C', 'h', 'a', 'r', 'g', 'e', 's', ' ');
				else
				{
					p8('D', 'u', 'r', 'a', 'b', 'i', 'l', 'i');
					p3('t', 'y', ' ');
				}
				pnum(stat_dur);
				p1('/');
				pnum(stat_max_dur);
				pad (40);
			}

		}

	}
	if (self.menu > total)
	{
		if (self.impulse == -1)
			self.menu = total;
		else if (self.m_num)
			self.menu = 9;
		else 
			self.menu = 10;
	}
	newline();
	if (ptitle)
		padlines(11);
	else
		padlines(10);
	line();
	
	if (total > 8)
	{
		poption(9, TRUE);
		p8('N', 'e', 'x', 't', ' ', 'P', 'a', 'g');
		p1('e');
		pad(40);
		newline();
	}
	else if (self.m_num)
	{
		poption(9, TRUE);
		p8('P', 'r', 'e', 'v', 'i', 'o', 'u', 's');
		p5(' ', 'P', 'a', 'g', 'e');
		pad(40);
		newline();
	}
	poption(10, TRUE);
	p4('E', 'x', 'i', 't');
	pad(40);
	p1(0);
	return 0;
	
};

float() m_invenlstcallback =
{
	if (stat_it)
		return 1;
	
};
void() m_invenlst =
{
	local float i;

	i = invenlst(self.m_subject, 0, m_invenlstcallback, '0 0 0');
	
	if (i)
	{
		self.weapon = pow2(i);
		openmenu(self, m_inven, self.m_subject);
	}
};