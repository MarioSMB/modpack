// maximum quests per page
float MAX_QUESTS = 3;

void() m_quest =
{
	local string n;
	local float i;
	
	local entity e;

	if (self.menu > 3)
		self.menu = 1;
	else if (self.menu < 1)
		self.menu = 3;
		
	self.questlog = 0;
	mstring_clear();
	mstring_add("Quest Log\n\<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\>\n");
	

	
	if (i >= self.m_num && i - self.m_num < MAX_QUESTS)
	{
		mstring_add(mainstorystring(mainstory));
		i = i + 1;
	}
	if (i >= self.m_num && i - self.m_num < MAX_QUESTS)
	{
		if (rndquest)
		{
			rq_questlog();
			i = i + 1;
		}
	}	
	e = find(world, classname, "quest");
	while(e)
	{
		n = getqueststring(e);
		if (n)
		{
			if (i >= self.m_num && i - self.m_num < MAX_QUESTS)
				mstring_add(n);
			i = i + 1;
		}
		e = find(e, classname, "quest");
	}
	
	if (self.button1)
	{
		self.button1 = 0;
		if (self.menu == 1)
		{
			self.m_num = self.m_num + MAX_QUESTS;
			if (self.m_num > i)
				self.m_num = 0;
		}
		else if (self.menu == 2)
		{
			self.m_num = self.m_num - MAX_QUESTS;
			if (self.m_num < 0)
				self.m_num = i - (i - (floor(i/MAX_QUESTS) * MAX_QUESTS));
		}
		else
		{
			closemenu(self);
			return;
		}
	}
	if (self.m_refresh > time)
		return;


	// next page?
	if (self.menu == 1)
		mstring_add("\n\<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\>\n\n\{141}\[\1\] Next Page    \n \[\2\] Previous Page\n \[\3\] Exit         \n");
	else if (self.menu == 2)
		mstring_add("\n\<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\>\n\n \[\1\] Next Page    \n\{141}\[\2\] Previous Page\n \[\3\] Exit         \n");
	else if (self.menu == 3)
		mstring_add("\n\<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\>\n\n \[\1\] Next Page    \n \[\2\] Previous Page\n\{141}\[\3\] Exit         \n");

	mstring_print();
};
