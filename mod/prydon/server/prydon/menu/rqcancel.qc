// ugly hack

void() m_rqcancel =
{
	if (self.button1)
	{
		if (self.menu == 1)
			rq_cancel();
		closemenu(self);
	}
	if (self.m_refresh > time)
		return;
	mstring_clear();
	mstring_add("Have you done the task that\nI requested yet?");
	mstring_addop();
	mstring_add("Cancel Quest");
	mstring_print();
	
};