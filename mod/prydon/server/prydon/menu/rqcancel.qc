#include "rqcancel.qh"

#include "../quests/rq_dialog.qh"

// ugly hack

void m_rqcancel(entity this)
{
	if(this.button1)
	{
		if(this.menu == 1)
			rq_cancel(this);
		closemenu(this);
	}
	if(this.m_refresh > time)
		return;
	mstring_clear();
	mstring_add(this, "Have you done the task that\nI requested yet?");
	mstring_addop(this);
	mstring_add(this, "Cancel Quest");
	mstring_print(this);
}
