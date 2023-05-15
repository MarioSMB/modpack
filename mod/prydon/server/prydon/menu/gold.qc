
void() m_dropgold =
{
	float n;
	
	if (self.menu < 1)
		self.menu = 10;
	else if (self.menu > 10)
		self.menu = 1;
	if (self.menu == 10)
		n = 0;
	else
		n = self.menu;
		
	if (self.button1)
	{
		if (self.m_num < self.gp)
			self.m_num = self.m_num * 10 + n;
	}
	else if (self.button0 || self.button2)
	{
		if (self.m_num > self.gp)
		{
			prompt(self, "You don't have enough gold for this", self, 2);
			return;
		}
		dropgold(self.m_num);
		self.m_subject.gp = self.m_subject.gp - self.m_num;
		closemenu(self);
	}
	
	if (self.m_refresh < time)
	{
		if (!self.m_refresh)
			self.misc = self.misc - (self.misc & MISC_UPDATE_BLINK);
			
		pstart();
		p5('D', 'r', 'o', 'p', ' ');
		p4('G', 'o', 'l', 'd');
		newline();
		line();
		pgold();
		line();
		p8('Q', 'u', 'a', 'n', 't', 'i', 't', 'y');
		p2(':', ' ');
		if (self.m_num)
			pnum(self.m_num);
		red = RED_ON;
		if (self.misc & MISC_UPDATE_BLINK)
			p1(11);
		else
			pnum(n);
		red = 0;
		p1(0);
		self.m_refresh = time + 1;
	}
}
