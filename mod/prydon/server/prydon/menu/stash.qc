#include "stash.qh"

void m_withdraw(entity this)
{
	int i = invenlst(this, this.m_subject, 0, m_invenlstcallback, '5728628 6841458 6387456');
	
	if(i)
	{
		vector r = GetSlot(this.m_subject, i);
		if(r)
		{
			r = pickupitem(this, r);
			if(!r)
			{
				ClearSlot(this.m_subject, i);
				this.m_refresh = 0;
			}
			else
			{
				prompt(this, "You don't have enough room\nin your inventory", this.m_subject, 2);
			}
		}
	}
}

void m_deposit(entity this)
{
	int i = invenlst(this, this, 0, m_invenlstcallback, '4482416 7304041 7602176');
	
	if(i)
	{
		vector r = GetSlot(this, i);
		if(r)
		{
			r = pickupitem(this.m_subject, r);
			
			if(!r)
			{
				Unequip(this, i, 0);
				ClearSlot(this, i);
				this.m_refresh = 0;
			}
			else
			{
				prompt(this, "This object can't carry anymore", this.m_subject, 2);
			}
		}
	}
}
