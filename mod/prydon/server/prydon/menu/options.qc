void (float i) pcheckbox =
{
	pad(27);
	if (i)
		p3(16, 156, 17);
	else
		p3(16, 32, 17);
};

void () m_opitions =
{
	if (self.menu < 1)
		self.menu = 5;
	else if (self.menu > 5)
		self.menu = 1;
	if (self.button1)
	{
		if (self.menu == 5)
		{
			closemenu(self);
			return;
		}
		if (self.options & pow2(self.menu))
			self.options = self.options - pow2(self.menu);
		else
			self.options = self.options | pow2(self.menu);	
	
	}
	if (self.m_refresh >= time)
		return;
	// show the player his stats and allows ptd
	pstart();
	
	
	poption(1, TRUE);
	p8('A', 'l', 'w', 'a', 'y', 's', ' ', 'S');
	p8('h', 'o', 'w', ' ', 'S', 'p', 'e', 'l');
	p1('l');
	pcheckbox(!(self.options & 1));
	newline();
	
	poption(2, TRUE);
	p8('M', 'o', 'u', 's', 'e', ' ', 'R', 'o');
	p8('t', 'a', 't', 'e', '/', 'Z', 'o', 'o');
	p1('m');
	pcheckbox(!(self.options & 2));
	newline();
	
	poption(3, TRUE);
	p8('Q', 'u', 'e', 's', 't', ' ', 'N', 'o');
	p4('t', 'i', 'c', 'e');
	pcheckbox(!(self.options & 4));
	newline();
	
	poption(4, TRUE);
	p7('V', 'e', 'r', 'b', 'o', 's', 'e');
	pcheckbox(self.options & OPT_VERBOSE);
	newline();
	
	poption(5, TRUE);
	p4('E', 'x', 'i', 't');
	pad(30);
	p1(0);
/*
 \[\1\] Always Show Spell \[ \]\n
 \[\2\] Mouse Rotate/Zoom \[ \]\n
 \[\3\] Quest Notice      \[ \]\n
*/
};