#include "identify.qh"

#include "../subs/math.qh"

float m_identifycallback(entity this)
{
	if(!stat_id)
		return IDENTIFY_COST;
	return 0;
}

void m_identify_confirm(entity this)
{
	float slot = root2(this.weapon);
	
	vector itslot = GetSlot(this, slot);
	it_simplestat(this, itslot);
	it_itemstat(this);
	
	if(this.menu < 1)
		this.menu = 2;
	else if(this.menu > 2)
		this.menu = 1;

	if(this.button1)
	{
		this.button1 = 0;
		if(this.menu == 1)
		{
			if(!getgold(this, IDENTIFY_COST))
				prompt(this, "You don't have enough gold for this", this, 2);
			else
			{
				it_simplestat(this, itslot);
				it_itemstat(this);
				stat_id = 1;
				SetSlot(this, slot, it_setstat());
				closemenu(this);
				openmenu(this, m_inven, this);
				return;
			}	
		}
		else if(this.menu == 2)
		{
			openmenu(this, m_identify, this.m_subject);
			return;
		}
	}
	if(this.m_refresh < time)
	{
		inven(this, itslot, fabs(this.equip & this.weapon) + 1);
		float howm = pgold(this);
		pprice(this, howm, IDENTIFY_COST);
		
		newline();
		line();
	
		if(this.menu == 1)
			WriteString(msg_mode, "Identify this item?\n\{141}\[\1\] Yes\n \[\2\] No \n");
		else
			WriteString(msg_mode, "Identify this item?\n \[\1\] Yes\n\{141}\[\2\] No \n");
	
	}
}

void m_identify(entity this)
{
	int theslot = invenlst(this, this, 1, m_identifycallback, '4809829 7238761 6715648');
	if(theslot)
	{
		this.weapon = (2 ** theslot);
		openmenu(this, m_identify_confirm, this.m_subject);	
	}
}
