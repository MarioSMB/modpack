#include "recharge.qh"

#include "../subs/math.qh"

float rechargecost(entity this)
{
	if(!(stat_loc & CHARGES))
		return 0;
	if(stat_dur >= stat_max_dur)
		return 0;
		
	float m = ceil(((stat_max_dur - stat_dur) / stat_max_dur) * stat_price * stat_spell * 1.2);
	if(this.skill & SKILL_DISCOUNT)
		m = ceil((0.8 - (this.title_x * 0.05)) * m);
	if(m <= 1)
		m = 1;

	return m;
}

void m_recharge_confirm(entity this)
{
	float slot = root2(this.weapon);
	
	vector itslot = GetSlot(this, slot);
	it_simplestat(this, itslot);
	it_itemstat(this);
	float cost = repaircost(this);
	
	if(this.menu < 1)
		this.menu = 2;
	else if(this.menu > 2)
		this.menu = 1;

	if(this.button1)
	{
		this.button1 = 0;
		if(this.menu == 1)
		{
			if(!getgold(this, cost))
				prompt(this, "You don't have enough gold for this", this, 2);
			else
			{
				it_simplestat(this, itslot);
				it_itemstat(this);
				stat_dur = stat_max_dur;
				SetSlot(this, slot, it_setstat());
				openmenu(this, m_repair, this.m_subject);
				this.weapon = 0;
				return;
			}	
		}
		else if(this.menu == 2)
		{
			closemenu(this);
			return;
		}
	}
	if(this.m_refresh < time)
	{
		inven(this, itslot, fabs(this.equip & this.weapon) + 1);
		float howm = pgold(this);
		pprice(this, howm, cost);
		newline();
		line();
	
		if(this.menu == 1)
			WriteString(msg_mode, "Recharge this item?\n\{141}\[\1\] Yes\n \[\2\] No \n");
		else
			WriteString(msg_mode, "Recharge this item?\n \[\1\] Yes\n\{141}\[\2\] No \n");
	}
}

void m_recharge(entity this)
{
	int i = invenlst(this, this, CHARGES | 1, rechargecost, '5399907 6840690 6776064');
	
	if(i)
	{
		this.weapon = (2 ** i);
		openmenu(this, m_recharge_confirm, this.m_subject);
	}
}
