#include "dur.qh"

#include "../items/encode.qh"
#include "subs.qh"

int itemcount(entity this, float itslot)
{
	int g = 0;
	
	for(int i=1; i<9; i = i + 1)
	{
		it_simplestat(this, GetSlot(this, i));
		if(stat_it == itslot)
			g += stat_dur;

	}
	return g;
}

bool takeamount(entity this, float itslot, float pref, float suf, float howmuch)
{
	if(howmuch < 0)
		return false;
	else if(howmuch == 0)
		return true;
		
	int g = itemcount(this, itslot);
	
	if(howmuch > g)
		return false; // not enough
	
	for(int i=8; i > 0; i = i - 1)
	{
		it_simplestat(this, GetSlot(this, i));
		if(stat_it == itslot && stat_pref == pref && stat_suf == suf)
		{
			g = stat_dur;
			stat_dur = stat_dur - howmuch;
			if(stat_dur <= 0)
			{
				ClearSlot(this, i);
				howmuch -= g;
			}
			else
			{
				SetSlot(this, i, it_setstat());
				return true;
			}
			if(howmuch <= 0)
				return true;
		}
	}
	return true;
}

void replenish_dur(entity this)
{
	for(int i = 1; i <= TOTAL_SLOTS; i = i + 1)
	{
		if(this.equip & (2 ** i))
		{
			it_simplestat(this, GetSlot(this, i));
			it_itemstat(this);
			
			if(stat_spec & SPEC_REPLENISH)
			{
				stat_dur = stat_dur + 1;
				if(stat_dur > stat_max_dur)
					stat_dur = stat_max_dur;
				if(stat_loc & AMMO)
					this.armorvalue = stat_dur;
			}
		}
	}

}

bool getgold(entity this, int howmuch)
{
	if(this.skill & SKILL_DISCOUNT)
	{
		howmuch = ceil((0.8 - (this.title_x * 0.05)) * howmuch);
	}
	if(howmuch > this.gp)
		return false;
	howmuch = ceil(howmuch);
	this.gp = this.gp - howmuch;
	if(this.options & OPT_VERBOSE)
	{
		sprint(this, sprintf("Lost %d gold\n", howmuch));
	}
	return true;
}

void givegold(entity this, int howmuch)
{
	if(howmuch <= 0)
		return;
	howmuch = ceil(howmuch);
	this.gp = this.gp + howmuch;
	if(this.options & OPT_VERBOSE)
	{
		sprint(this, sprintf("Acquired %d gold\n", howmuch));
	}
}

bool takeammo(entity this, float itslot)
{
	// first find the slot of the arrows / scroll
	bool succeeded = false;
	for(int i=1; i<= TOTAL_SLOTS; i = i + 1)
	{
		if(this.equip & (2 ** i))
		{
			it_simplestat(this, GetSlot(this, i));
			it_itemstat(this);
			if(stat_it == itslot)
			{
				if(stat_dur > 0)
				{
					stat_dur = stat_dur - 1;
					this.armorvalue = stat_dur;
					SetSlot(this, i, it_setstat());
					succeeded = true;
				}
				if(stat_dur <= 0)
				{
					if(stat_spec & SPEC_REPLENISH)
					{
						stat_dur = 0;
						SetSlot(this, i, it_setstat());
						return succeeded;
					}
					else
					{
						if(IS_CLIENT(this))
						{
							msg_entity = this;
							WriteByte(MSG_ONE, 8);
							PrintItemName();
							WriteString(MSG_ONE, " has run out\n");
						}
						Unequip(this, i, 1);
						ClearSlot(this, i);
						// TEST
						AutoEquip(this, inv_hasitem(this, itslot * '1 0 0', 1, 0));
						return succeeded;
					}
				}
				return succeeded;
			}
		}
	}
	return false;		
}


bool TakeCharges(entity this, float sp)
{
	// first find the slot of the arrows / scroll
	for(int i=1; i<=TOTAL_SLOTS; i = i + 1)
	{
		if(this.equip & (2 ** i))
		{
			it_simplestat(this, GetSlot(this, i));
			it_itemstat(this);
			if((stat_action & 63) == sp)
			{
				if(stat_loc & CHARGES) 
				{
					
					this.armorvalue = stat_dur;
					if(stat_dur == 1)
					{
						stat_dur = 0;
						if(this.flags & FL_CLIENT)
						{
							msg_entity = this;
							WriteByte(MSG_ONE, 8);
							PrintItemName();
							WriteString(MSG_ONE, " has run out\n");
						}
						SetSlot(this, i, it_setstat());
						//if(!(stat_spec & SPEC_REPLENISH))				
						//	Unequip(i, 1);
						return true;
					}
					else if(stat_dur <= 0)
					{
						return false;
					}
					stat_dur = stat_dur - 1;
					SetSlot(this, i, it_setstat());
					return true;
				}
			}
		}
	}
	return true;		
}

void DamageEquipment(entity who, float weps)
{
	if(random() < 0.8)
		return;
		
	for(int i = 1; i <= TOTAL_SLOTS; i = i + 1)
	{
		if(who.equip & (2 ** i))
		{
			it_simplestat(who, GetSlot(who, i));
			it_itemstat(who);
			if(stat_loc & DURABILITY)
			{
				if((weps && stat_daml) || (!weps && stat_def))
				{
					if(random() < 0.1)
					{
						stat_dur = stat_dur - 1;
						if(stat_dur <= 0)
						{
							Unequip(who, i, 1);
							it_simplestat(who, GetSlot(who, i));
							it_itemstat(who);
							stat_dur = 0;
							
							SetSlot(who, i, it_setstat());
							if(IS_CLIENT(who))
							{
								msg_entity = who;
								WriteByte(MSG_ONE, 8);
								PrintItemName();
								WriteString(MSG_ONE, " has broken\n");
							}
							_sound(who.player, CHAN_BODY, "player/break.wav", 1, ATTN_NORM);
						}
						else
						{
							if(stat_dur == ceil(stat_max_dur  * 0.15))
							{
								if(IS_CLIENT(who))
								{
									msg_entity = who;
									WriteByte(MSG_ONE, 8);
									PrintItemName();
									WriteString(MSG_ONE, " is about to break\n");
								}	
							}
							SetSlot(who, i, it_setstat());
						}
					}
				}
			}
		}
	}
}

bool takesomething(vector itslot, entity e)
{
	it_simplestat(e, itslot);
	it_itemstat(e);
		
	if(stat_it == IT_GOLD)
	{
		if(getgold(e, stat_dur))
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	else if(stat_loc & STACKABLE)
	{
		if(takeamount(e, stat_it, stat_pref, stat_suf, stat_dur))
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	else
	{
		int i = inv_hasitem(e, itslot, true, 0);
		if(i)
		{
			Unequip(e, i, 1);
			ClearSlot(e, i);
			return true;
		}
		else
			return false;
	}
}

bool hassomething(vector itslot, entity e)
{
	it_simplestat(e, itslot);
	it_itemstat(e);
	int i = stat_dur;

	if(stat_it == IT_GOLD)
	{
		if(e.gp >= stat_dur)
		{
			return true;
		}
		else
		{
			return false;
		}

	}
	else if(stat_loc & STACKABLE)
	{
		if(itemcount(e, stat_it) >= i)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	else
	{
		i = inv_hasitem(e, itslot, 1, 0);
		if(i)
		{
			return true;
		}
		else
		{
			return false;
		}
	}

}