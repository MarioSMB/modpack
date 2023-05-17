#include "dialog.qh"

#include "../subs/trigger.qh"

void m_dialog(entity this)
{
	entity t = this.m_targ;
	this.m_subject.m_subject = this.player;
	this.weaponmodel = t.weaponmodel;
	this.weaponframe = t.weaponframe;
	
	int r = 0;
	int off = 0;
	if(t.target1)
		r = r + 1;
	else
		off = 1;
	if(t.target2)
		r = r + 1;
	else if(off)
		off = 2;
	if(t.target3)
		r = r + 1;
	else if(off == 2)
		off = 3;
	if(t.target4)
		r = r + 1;

	if(r)
	{
		if(this.menu < 1)
			this.menu = 1;
		else if(this.menu > r)
			this.menu = r;
		
		if(this.button1)
		{
			this.button1 = 0;
			Trigger(t, this.m_subject, this, this.menu + off);
		
		}
	}
	else
	{
		Trigger(t, this.m_subject, this, 0);
	}
	if(this.m_refresh > time)
		return;
	mstring_clear();
	if(t.message)
		mstring_add(this, t.message); 
		
	if(t.target1)
		mstring_addop(this);
	if(t.message1)
		mstring_add(this, t.message1);
		
	if(t.target2)
		mstring_addop(this);
	if(t.message2)
		mstring_add(this, t.message2);
		
	if(t.target3)
		mstring_addop(this);
	if(t.message3)
		mstring_add(this, t.message3); 

	if(t.target4)
		mstring_addop(this);
	if(t.message4)
		mstring_add(this, t.message4); 
	mstring_print(this);
}
