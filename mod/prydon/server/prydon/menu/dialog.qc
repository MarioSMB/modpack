

void() m_dialog =
{
	local float r, off;
	local entity t, o;
	
	t = self.m_targ;
	o = self;
	self.m_subject.m_subject = self.player;
	self.weaponmodel = t.weaponmodel;
	self.weaponframe = t.weaponframe;
	
	r = 0;
	if (t.target1)
		r = r + 1;
	else
		off = 1;
	if (t.target2)
		r = r + 1;
	else if (off)
		off = 2;
	if (t.target3)
		r = r + 1;
	else if (off == 2)
		off = 3;
	if (t.target4)
		r = r + 1;

	if (r)
	{
		if (self.menu < 1)
			self.menu = 1;
		else if (self.menu > r)
			self.menu = r;
		
		if (self.button1)
		{
			self.button1 = 0;
			self = self.m_subject;
			Trigger(t, self, o, o.menu + off);
			self = o;
		
		}
	}
	else
	{
		self = self.m_subject;
		Trigger(t, self, o, 0);
		self = o;
	}
	if (self.m_refresh > time)
		return;
	mstring_clear();
	if (t.message)
		mstring_add(t.message); 
		
	if (t.target1)
		mstring_addop();
	if (t.message1)
		mstring_add(t.message1);
		
	if (t.target2)
		mstring_addop();
	if (t.message2)
		mstring_add(t.message2);
		
	if (t.target3)
		mstring_addop();
	if (t.message3)
		mstring_add(t.message3); 

	if (t.target4)
		mstring_addop();
	if (t.message4)
		mstring_add(t.message4); 
	mstring_print();
	

};
