#include "restock.qh"

#include "../subs/math.qh"

float restockcost(entity this)
{
	if(!(stat_loc & STACKABLE))
		return 0;
	if(stat_dur >= stat_max_dur)
		return 0;
	float m = ceil((1 / stat_max_dur) * stat_price * 1.5);
	if(this.skill & SKILL_DISCOUNT)
		m = (0.8 - (this.title_x * 0.05) * m);
	
	if(m <= 1)
		m = 1;
	return m;
}

void m_restock_confirm(entity this)
{
	int howm;
	float slot = root2(this.weapon);
	vector itslot = GetSlot(this, slot);
	it_simplestat(this, itslot);
	it_itemstat(this);
	float cost = restockcost(this);
	
	if(this.menu < 1)
		this.menu = 4;
	else if(this.menu > 4)
		this.menu = 1;

	if(this.button1)
	{
		this.button1 = 0;
		if(this.menu == 1)
		{
			howm = 1;
			if(!getgold(this, howm * cost))
				prompt(this, "You don't have enough gold for this", this, 2);
			else
			{
				it_simplestat(this, itslot);
				it_itemstat(this);
				stat_dur = stat_dur + howm;
				SetSlot(this, slot, it_setstat());

			}	
		}
		else if(this.menu == 2)
		{
			if((stat_max_dur - stat_dur) < 10)
				howm = (stat_max_dur - stat_dur);
			else
				howm = 10;
				
			if(!getgold(this, howm * cost))
				prompt(this, "You don't have enough gold for this", this, 2);
			else
			{
				it_simplestat(this, itslot);
				it_itemstat(this);
				stat_dur = stat_dur + howm;
				SetSlot(this, slot, it_setstat());
			}	
		}
		else if(this.menu == 3)
		{
			howm = (stat_max_dur - stat_dur);
			if((cost * howm) > this.gp)
			{
				howm = floor(this.gp / cost);
			}
			if(!getgold(this, howm * cost))
				prompt(this, "You don't have enough gold for this", this, 2);
			else
			{
				it_simplestat(this, itslot);
				it_itemstat(this);
				stat_dur = stat_dur + howm;
				SetSlot(this, slot, it_setstat());
				openmenu(this, m_restock, this.m_subject);
				this.weapon = 0;
				return;
			}	
		}
		else
		{
			closemenu(this);
			return;
		}
	}
	if(this.m_refresh < time)
	{
		inven(this, itslot, fabs(this.equip & this.weapon) + 1);
		howm = pgold(this);
		pprice(this, howm, cost);
		
		p4 (' ', 'E', 'A', '.');
		newline();
		line();

/*
 \[\1\] Buy 1 \n \[\2\] Buy 10\n \[\3\] Fill  \n \[\4\] Cancel\n
*/
		if(this.menu == 1)
			WriteString(msg_mode, "\{141}\[\1\] Buy 1 \n \[\2\] Buy 10\n \[\3\] Fill  \n \[\4\] Cancel\n");
		else if(this.menu == 2)
			WriteString(msg_mode, " \[\1\] Buy 1 \n\{141}\[\2\] Buy 10\n \[\3\] Fill  \n \[\4\] Cancel\n");
		else if(this.menu == 3)
			WriteString(msg_mode, " \[\1\] Buy 1 \n \[\2\] Buy 10\n\{141}\[\3\] Fill  \n \[\4\] Cancel\n");
		else if(this.menu == 4)
			WriteString(msg_mode, " \[\1\] Buy 1 \n \[\2\] Buy 10\n \[\3\] Fill  \n\{141}\[\4\] Cancel\n");
	}
}

void m_restock(entity this)
{
	int i = invenlst(this, this, STACKABLE | 1, restockcost, '5399923 7630691 7012352');
	
	if(i)
	{
		this.weapon = (2 ** i);
		openmenu(this, m_restock_confirm, this.m_subject);
	}
}
