#include "sell.qh"

#include "../items/map.qh"
#include "../subs/math.qh"

float saleprice(entity this)
{
	return ceil(stat_price * 0.5);
}

float dropshopitem(entity this, vector itslot)
{
	FOREACH_ENTITY_STRING(netname, this.m_subject.wad,
	{
		if(it.classname == "item" && it.slot1 == IV_NULL)
		{
			it.slot1 = itslot;
			it.items = 0;
			it.droprandom = 0;
			spawnfunc_shopitem(it);
			return true;
		}
	});
	return false;
}

void m_sell_confirm(entity this)
{
	vector itslot = GetSlot(this, root2(this.weapon));
	
	if(this.menu < 1)
		this.menu = 2;
	else if(this.menu > 2)
		this.menu = 1;

	if(this.button1)
	{
		this.button1 = 0;
		if(this.menu == 1)
		{
			it_simplestat(this, itslot);
			it_itemstat(this);
			if(!dropshopitem(this, itslot))
				pushitem(this.m_subject, pickupitem(this, itslot));
			float g = saleprice(this);
			Unequip(this, root2(this.weapon), 1);
			ClearSlot(this, root2(this.weapon));
			givegold(this, g);				
			openmenu(this, m_sell, this.m_subject);
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
		inven(this, itslot, fabs(this.equip & this.weapon) + 1);

		p8('S', 'e', 'l', 'l', 's', ' ', 'f', 'o');
		p2('r', ' ');
		pnum(saleprice(this));
		p5(' ', 'G', 'o', 'l', 'd');
		newline();

		line();
	
		if(this.menu == 1)
			WriteString(msg_mode, "Sell this item?\n\{141}\[\1\] Yes\n \[\2\] No \n");
		else
			WriteString(msg_mode, "Sell this item?\n \[\1\] Yes\n\{141}\[\2\] No \n");
	}
}

void m_sell(entity this)
{
	int i = invenlst(this, this, 1, saleprice, '5465452 7077888 0');
	if(i)
	{
		this.weapon = (2 ** i);
		openmenu(this, m_sell_confirm, this.m_subject);
	}
}
