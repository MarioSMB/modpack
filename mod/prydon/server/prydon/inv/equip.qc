#include "equip.qh"

#include "../stats/stats.qh"

// false runaway loop error avoidance
void EquipCheck(entity this, float loc, float skip)
{
	bool change = false;
	do
	{
		change = false;
		for(int i = 1; i <= TOTAL_SLOTS; i = i + 1)
		{
			if(i != skip)
			{
				
				vector itslot = GetSlot(this, i);
				if(!canuse(this, itslot))
				{
					if(Unequip(this, i, 0))
						change = true;
				}
				else if(LOC & stat_loc & loc)
				{
					if(Unequip(this, i, 0))
						change = true;
				}
			}
		}
		loc = 0;
	}
	while(change);
}

bool Equip(entity this, float slot)
{
	vector itslot = GetSlot(this, slot);
	
	if(canuse(this, itslot) && (stat_loc & EQUIPABLE))
	{
		EquipCheck(this, stat_loc, slot);
		if(canuse(this, itslot))
		{
			_sound(this, CHAN_AUTO, itemsound(stat_it), 1, ATTN_NORM);
			it_simplestat(this, itslot);
			it_itemstat(this);
			if(UseItem(this, 1))
			{
				this.equip |= (2 ** slot);
				boundstats(this);
				return true;
			}
		}
	}
	return false;
}

bool Unequip(entity this, float slot, float recheck)
{
	float f = (2 ** slot);
	
	if(this.equip & f)
	{
		it_simplestat(this, GetSlot(this, slot));
		it_itemstat(this);
		
		UseItem(this, -1);
		boundstats(this);
		this.equip = this.equip - f;
		if(recheck)
			EquipCheck(this, stat_loc, slot);
		return true;
	}
	return false;
}

void UnequipAll(entity this)
{
	int f = 1;
	
	for(int i = 0; i <= TOTAL_SLOTS; ++i)
	{
		if(this.equip & f)
		{
			it_simplestat(this, GetSlot(this, i));
			it_itemstat(this);
			UseItem(this, -1);
		}
		f *= 2;
	}
	
	boundstats(this);
	this.equip = 0;
}
