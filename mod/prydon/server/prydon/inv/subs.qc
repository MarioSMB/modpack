#include "subs.qh"

vector GetSlot(entity e, float slot)
{
	if(slot == 1)
		return e.slot1;
	else if(slot == 2)
		return e.slot2;
	else if(slot == 3)
		return e.slot3;
	else if(slot == 4)
		return e.slot4;
	else if(slot == 5)
		return e.slot5;
	else if(slot == 6)
		return e.slot6;
	else if(slot == 7)
		return e.slot7;
	else if(slot == 8)
		return e.slot8;
	else if(slot == 9)
		return e.slot9;
	else if(slot == 10)
		return e.slot10;
	else if(slot == 11)
		return e.slot11;
	else if(slot == 12)
		return e.slot12;
	else if(slot == 13)
		return e.slot13;
	else if(slot == 14)
		return e.slot14;
	else if(slot == 15)
		return e.slot15;
	else if(slot == 16)
		return e.slot16;
	return IV_NULL;
}

void SetSlot(entity e, float slot, vector itslot)
{
	if(slot == 1)
		e.slot1 = itslot;
	else if(slot == 2)
		e.slot2 = itslot;
	else if(slot == 3)
		e.slot3 = itslot;
	else if(slot == 4)
		e.slot4 = itslot;
	else if(slot == 5)
		e.slot5 = itslot;
	else if(slot == 6)
		e.slot6 = itslot;
	else if(slot == 7)
		e.slot7 = itslot;
	else if(slot == 8)
		e.slot8 = itslot;
	else if(slot == 9)
		e.slot9 = itslot;
	else if(slot == 10)
		e.slot10 = itslot;
	else if(slot == 11)
		e.slot11 = itslot;
	else if(slot == 12)
		e.slot12 = itslot;
	else if(slot == 13)
		e.slot13 = itslot;
	else if(slot == 14)
		e.slot14 = itslot;
	else if(slot == 15)
		e.slot15 = itslot;
	else if(slot == 16)
		e.slot16 = itslot;
}

void ClearSlot(entity e, float slot)
{
	if(e.options & OPT_VERBOSE)
	{
		msg_entity = e;
		it_simplestat(e, GetSlot(e, slot));
		if(stat_it)
		{
			sprint(e, "Lost item: ");
			WriteByte(MSG_ONE, 8);
			PrintItemName();
			WriteString(MSG_ONE, "\n");
		}
	}
	SetSlot(e, slot, IV_NULL);
}

int inv_hasitem(entity this, vector itslot, float start, float check)
{
	for(int i=start; i <= TOTAL_SLOTS; i = i + 1)
	{
		vector n = GetSlot(this, i);

		if(itslot.x == n.x)
		{
			if(check)
			{
				if(itslot.y != n.y)
					continue;
			}
			return i;
		}
	}
	return false;
}

void randomize_inventory(entity e)
{
	for(int i = 1; i <= TOTAL_SLOTS; i = i + 1)
	{
		if(e.droprandom & (2 ** i))
		{
			vector itslot = GetSlot(e, i);
			SetSlot(e, i, randitem(e, itslot.x, itemvalue + e.value, false));
		}
	}
	e.droprandom = 0;
}
