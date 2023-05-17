#include "pickup.qh"

#include "../quests/rq_subs.qh"
#include "../quests/rq_vars.qh"

bool AutoEquip(entity this, float slot)
{
	float d, i;
	it_simplestat(this, GetSlot(this, slot));
	it_itemstat(this);

	if(stat_loc & EQUIPABLE)
	{
		// don't let scrolls equip themselves if you're using a spell
		if(stat_loc & SPELL)
			if(this.spell)
				return false;
		// auto-equip
		d = stat_loc & LOC;
		for (i=1; i <= TOTAL_SLOTS; i = i + 1)
		{
			if(this.equip & (2 ** i))
			{
				it_simplestat(this, GetSlot(this, i));
				it_itemstat(this);
				if(stat_loc & d)
					return false;
			}
		}
		return Equip(this, slot);
	}
	return false;
}

void openitembuy(entity this, entity targ)
{
	openmenu(targ, m_itembuy, this);
}

void action_pickup(entity this, entity targ)
{
	this.action = donothing;
	if(this.slot1_x == 0)
		return;

	vector r = pickupitem(targ.owner, this.slot1);
	if(r)
	{
		dropitem(targ.owner, r);
		sprint(targ.owner, "Not enough room in your inventory\n");
	}
	
	if(this.movedir)
		rq_advance(RQ_ITEMS);
	delete(this);
}

vector pickupitem(entity this, vector itslot)
{
	if (!itslot)
		return IV_NULL;

	// find stackables?
	it_simplestat(this, itslot);
	it_itemstat(this);
	if(!stat_it)
		return IV_NULL;
		
	if(stat_it == IT_GOLD)
	{
		this.gp = this.gp + stat_dur;
		if(this.options & OPT_VERBOSE)
		{
			sprint(this, "Acquired ");
			sprint(this, ftos(stat_dur));
			sprint(this, " gold\n");
		}
		return IV_NULL;
	}
	if(this.skill & SKILL_POTION)
	{
		if(stat_it == IT_LESSER_HEAL || stat_it == IT_HEAL_POTION)
			stat_it = IT_GREATER_HEAL;
		else if(stat_it == IT_LESSER_MANA || stat_it == IT_MANA_POTION)
			stat_it = IT_GREATER_MANA;
		itslot = it_setstat();
	}
	if(stat_id)
	if(stat_loc & STACKABLE)
	{
		int d = stat_dur;
		
		int i = 1;
		while(i <= TOTAL_SLOTS)
		{
			i = inv_hasitem(this, itslot, i, 1);
			if(!i)
				break;
			it_simplestat(this, GetSlot(this, i));
			it_itemstat(this);
			stat_dur = stat_dur + d;
			d = stat_dur - stat_max_dur;
			if(d<0)
				d=0;
			stat_dur = stat_dur - d;

			SetSlot(this, i, it_setstat());
			if(stat_loc & AMMO)
				if(this.equip & (2 ** i))
					this.armorvalue = stat_dur;
			if(!d)
			{
				if(this.options & OPT_VERBOSE)
				{
					
					sprint(this, "Acquired Item: ");
					msg_entity = this;
					WriteByte(MSG_ONE, 8);
					PrintItemName();
					WriteString(MSG_ONE, "\n");
				}
				return IV_NULL;
			}
			it_simplestat(this, itslot);
			stat_dur = d;
		
			itslot = it_setstat();
			i = i + 1;
		}

	}
	int slot = inv_hasitem(this, IV_NULL, 1, 0);
	if(!slot)
		return itslot;
	SetSlot(this, slot, itslot);
	if(IS_PLAYER(this))
		AutoEquip(this, slot);
	if(this.options & OPT_VERBOSE)
	{
		it_simplestat(this, itslot);
		sprint(this, "Acquired Item: ");
		msg_entity = this;
		WriteByte(MSG_ONE, 8);
		PrintItemName();
		WriteString(MSG_ONE, "\n");
	}		
	return IV_NULL;
}

void pushitem(entity this, vector itslot)
{
	if(itslot != IV_NULL)
	{
		for(int i = 1; i < TOTAL_SLOTS; i = i + 1)
		{
			SetSlot(this, i, GetSlot(this, i + 1));
		}
		SetSlot(this, TOTAL_SLOTS, itslot);
	}
}