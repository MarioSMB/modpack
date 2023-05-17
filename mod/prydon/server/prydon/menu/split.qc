#include "split.qh"

#include "../subs/math.qh"

void m_split(entity this)
{
	float n;

	if(this.menu < 1)
		this.menu = 10;
	else if(this.menu > 10)
		this.menu = 1;
	if(this.menu == 10)
		n = 0;
	else
		n = this.menu;
	vector itslot = GetSlot(this.m_subject, root2(this.weapon));
	
	if(this.button1)
	{
		if(this.m_num < this.gp)
			this.m_num = this.m_num * 10 + n;
	}
	else if(this.button0 || this.button2)
	{
		it_simplestat(this, itslot);
		it_itemstat(this);
		if(stat_loc & STACKABLE)
		{
			if(this.m_num >= stat_dur)
			{
				prompt(this, "Too big", this, 2);
				return;
			}
			else if(this.m_num <= 0)
			{
				prompt(this, "Too small", this, 2);
				return;
			}
			stat_dur = stat_dur - this.m_num;
			SetSlot(this.m_subject, root2(this.weapon), it_setstat());
			stat_dur = this.m_num;
			int slot = inv_hasitem(this, IV_NULL, 1, 0);
			if(!slot)
				dropitem(this.m_subject, it_setstat());
			else
				SetSlot(this, slot, it_setstat());
		}
		closemenu(this);
	}
	
	if(this.m_refresh < time)
	{
		if(!this.m_refresh)
			this.misc = this.misc - (this.misc & MISC_UPDATE_BLINK);
			
		inven(this, itslot, fabs(this.m_subject.equip & this.weapon) + 1);
		padlines(9);
		
		p8('Q', 'u', 'a', 'n', 't', 'i', 't', 'y');
		p2(':', ' ');
		if(this.m_num)
			pnum(this.m_num);
		red = RED_ON;
		if(this.misc & MISC_UPDATE_BLINK)
			p1(11);
		else
			pnum(n);
		red = 0;
		p1(0);
		this.m_refresh = time + 1;
	}
}
