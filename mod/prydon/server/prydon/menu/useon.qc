#include "useon.qh"

#include "../subs/math.qh"

float source;

bool canuseon(entity this)
{
	if(source == IT_IDSCROLL)
	{
		if(!stat_id)
			return true;
	}
	else if(source == IT_OIL_OF_REPAIR)
	{
		if(stat_dur < stat_max_dur)
			if(stat_loc & DURABILITY)
				return true;
	}
	else if(source == IT_OIL)
	{
		if(stat_it < IT_GOLD)
		if(!stat_suf)
			if(stat_loc & EQUIPABLE)
				return true;
	}
	else if(source == IT_OIL2)
	{
		if(stat_it < IT_GOLD)
		if(!stat_pref)
			if(stat_loc & EQUIPABLE)
				return true;
	}
	return false;
	
}

void m_useon(entity this)
{
	float i;
	bool re_equip = false;

	int source_slot = root2(this.weapon);
	it_simplestat(this, GetSlot(this, source_slot));
	source = stat_it;
	float source_suf = stat_suf; // for OIL
	float source_pref = stat_pref;
	if(source == IT_OIL_OF_REPAIR)
		i = invenlst(this, this, DURABILITY, canuseon, '0 0 0');
	else
		i = invenlst(this, this, 0, canuseon, '0 0 0');
		
	if(i)
	{
		openmenu(this, m_inven, this);
		it_simplestat(this, GetSlot(this, i));
		it_itemstat(this);	
		if(!canuseon(this))
		{
			sprint(this, "Can't!\n");
			return;
		}
		if(source == IT_IDSCROLL)			
		{
			stat_id = 1;
			SetSlot(this, i, it_setstat());
		}
		else if(source == IT_OIL_OF_REPAIR)
		{
			stat_dur = stat_dur + 5;
			if(stat_dur >= stat_max_dur)
				stat_dur = stat_max_dur;
			SetSlot(this, i, it_setstat());
		}
		else if(source == IT_OIL)
		{
			if(this.equip & (2 ** i))
			{
				Unequip(this, i, 1);
				re_equip = 1;
			}
			it_simplestat(this, GetSlot(this, i));
			stat_suf = source_suf;
			
			SetSlot(this, i, it_setstat());
			if(re_equip)
				Equip(this, i);
		}
		else if(source == IT_OIL2)
		{
			if(this.equip & (2 ** i))
			{
				Unequip(this, i, 1);
				re_equip = 1;
			}
			it_simplestat(this, GetSlot(this, i));
			stat_pref = source_pref;
			SetSlot(this, i, it_setstat());
			if(re_equip)
				Equip(this, i);
		}
		_sound(this, CHAN_AUTO, itemsound(source), 1, ATTN_NORM);	
		this.weapon = (2 ** i);
		
		it_simplestat(this, GetSlot(this, source_slot));
		stat_dur = stat_dur - 1;
		if(stat_dur > 0)
			SetSlot(this, source_slot, it_setstat());
		else
			ClearSlot(this, source_slot);
		return;
	}
}
