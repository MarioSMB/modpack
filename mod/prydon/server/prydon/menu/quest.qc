#include "quest.qh"

#include "../quests/_mod.qh"

// maximum quests per page
const int MAX_QUESTS = 3;

void m_quest(entity this)
{
	int i = 0;
	entity e;
	if(this.menu > 3)
		this.menu = 1;
	else if(this.menu < 1)
		this.menu = 3;
		
	this.questlog = 0;
	mstring_clear();
	mstring_add(this, "Quest Log\n\<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\>\n");

	if(i >= this.m_num && i - this.m_num < MAX_QUESTS)
	{
		mstring_add(this, mainstorystring(mainstory));
		i += 1;
	}
	if(i >= this.m_num && i - this.m_num < MAX_QUESTS)
	{
		if(rndquest)
		{
			rq_questlog(this);
			i += 1;
		}
	}	
	e = find(NULL, classname, "quest");
	while(e)
	{
		string n = getqueststring(e);
		if(n)
		{
			if(i >= this.m_num && i - this.m_num < MAX_QUESTS)
				mstring_add(this, n);
			i += 1;
		}
		e = find(e, classname, "quest");
	}
	
	if(this.button1)
	{
		this.button1 = 0;
		if(this.menu == 1)
		{
			this.m_num = this.m_num + MAX_QUESTS;
			if(this.m_num > i)
				this.m_num = 0;
		}
		else if(this.menu == 2)
		{
			this.m_num = this.m_num - MAX_QUESTS;
			if(this.m_num < 0)
				this.m_num = i - (i - (floor(i/MAX_QUESTS) * MAX_QUESTS));
		}
		else
		{
			closemenu(this);
			return;
		}
	}
	if(this.m_refresh > time)
		return;

	// next page?
	if(this.menu == 1)
		mstring_add(this, "\n\<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\>\n\n\{141}\[\1\] Next Page    \n \[\2\] Previous Page\n \[\3\] Exit         \n");
	else if(this.menu == 2)
		mstring_add(this, "\n\<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\>\n\n \[\1\] Next Page    \n\{141}\[\2\] Previous Page\n \[\3\] Exit         \n");
	else if(this.menu == 3)
		mstring_add(this, "\n\<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\>\n\n \[\1\] Next Page    \n \[\2\] Previous Page\n\{141}\[\3\] Exit         \n");

	mstring_print(this);
}
