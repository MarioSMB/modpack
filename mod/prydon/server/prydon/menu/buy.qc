#include "buy.qh"

#include "../subs/math.qh"

float m_buy_callback(entity this)
{
	if(this.skill & SKILL_DISCOUNT)
		return ceil((0.8 - (this.title_x * 0.05)) * stat_price);
	return stat_price;
}

void m_buy_confirm(entity this)
{
	float slot = root2(this.weapon);
	vector r = GetSlot(this.m_subject, slot);
	if(this.menu < 1)
		this.menu = 2;
	else if(this.menu > 2)
		this.menu = 1;
		
	if(this.button1)
	{
		this.button1 = 0;
		if(this.menu == 1)
		{
			it_simplestat(this, r);
			it_itemstat(this);
			if(r != IV_NULL)
			{
				if(!getgold(this, stat_price))
				{
					prompt(this, "You don't have enough gold for this", this, 2);
					return;
				}
				r = pickupitem(this, r);
				if(!r)
				{
					_sound(this.m_subject, CHAN_BODY, itemsound(stat_it), 1, ATTN_NORM);
					ClearSlot(this.m_subject, slot);
					closemenu(this);
					return;
				}
				else
				{
					prompt(this, "You don't have enough room\nin your inventory", this.m_subject, 2);
				}
			}
			return;
		}
		else if(this.menu == 2)
		{
			closemenu(this);
			return;
		}
	}
	if(this.m_refresh < time)
	{
		inven(this, r, 0);
		float howm = pgold(this);
		pprice(this, howm, stat_price);
		newline();
		line();
		if(this.menu == 1)
			WriteString(msg_mode, "Buy this item?\n\{141}\[\1\] Yes\n \[\2\] No \n");
		else
			WriteString(msg_mode, "Buy this item?\n \[\1\] Yes\n\{141}\[\2\] No \n");
	}

}

void m_buy(entity this)
{
	int i = invenlst(this, this.m_subject, 1, m_buy_callback, '4355449 0 0');
	
	if(i)
	{
		this.weapon = (2 ** i);
		openmenu(this, m_buy_confirm, this.m_subject);
	}
}

void m_itembuy(entity this)
{
	if(this.menu != 1)
		this.menu = 1;
	if(this.button1)
	{
		this.button1 = 0;
		
		if(!getgold(this, this.m_subject.gp))
		{
			prompt(this, "You don't have enough gold for this", this, 2);
			return;
		}
		vector r = pickupitem(this, this.m_subject.slot1);
		it_simplestat(this, this.m_subject.slot1);
		if(r == '0 0 0')
		{
			_sound(this.m_subject, CHAN_BODY, itemsound(stat_it), 1, ATTN_NORM);
			if(this.m_subject.spawnflags & 1)
			{
				// infinite
				closemenu(this);
				return;
			}
			else if(this.m_subject.netname)
			{
				// shopitem
				_setmodel(this.m_subject, "");
				this.m_subject.items = 0;
				this.m_subject.slot1 = IV_NULL;
				this.m_subject.gp = 0;
			}
			else
				delete(this.m_subject);
			closemenu(this);
			return;
		}
		else
		{
			it_simplestat(this, r);
			it_itemstat(this);
			if(this.skill & SKILL_DISCOUNT)
				givegold(this, 0.8 - (this.title_x * 0.05) * this.m_subject.gp);
			else
				givegold(this, this.m_subject.gp);
			
			prompt(this, "You don't have enough room\nin your inventory", this, 2);
		}
		return;
	}
	if(this.m_refresh < time)
	{
		inven(this, this.m_subject.slot1, 0);

		float howm = pgold(this);
		pprice(this, howm, this.m_subject.gp);
		newline();
		line();
		WriteString(msg_mode, "\n\{141}\[\1\] Buy    ");
	}
}
