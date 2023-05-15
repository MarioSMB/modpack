
vector(entity e, float slot) GetSlot =
{
	if (slot == 1)
		return e.slot1;
	else if (slot == 2)
		return e.slot2;
	else if (slot == 3)
		return e.slot3;
	else if (slot == 4)
		return e.slot4;
	else if (slot == 5)
		return e.slot5;
	else if (slot == 6)
		return e.slot6;
	else if (slot == 7)
		return e.slot7;
	else if (slot == 8)
		return e.slot8;
	else if (slot == 9)
		return e.slot9;
	else if (slot == 10)
		return e.slot10;
	else if (slot == 11)
		return e.slot11;
	else if (slot == 12)
		return e.slot12;
	else if (slot == 13)
		return e.slot13;
	else if (slot == 14)
		return e.slot14;
	else if (slot == 15)
		return e.slot15;
	else if (slot == 16)
		return e.slot16;
	return IV_NULL;
};


void(entity e, float slot, vector it) SetSlot =
{
	if (slot == 1)
		e.slot1 = it;
	else if (slot == 2)
		e.slot2 = it;
	else if (slot == 3)
		e.slot3 = it;
	else if (slot == 4)
		e.slot4 = it;
	else if (slot == 5)
		e.slot5 = it;
	else if (slot == 6)
		e.slot6 = it;
	else if (slot == 7)
		e.slot7 = it;
	else if (slot == 8)
		e.slot8 = it;
	else if (slot == 9)
		e.slot9 = it;
	else if (slot == 10)
		e.slot10 = it;
	else if (slot == 11)
		e.slot11 = it;
	else if (slot == 12)
		e.slot12 = it;
	else if (slot == 13)
		e.slot13 = it;
	else if (slot == 14)
		e.slot14 = it;
	else if (slot == 15)
		e.slot15 = it;
	else if (slot == 16)
		e.slot16 = it;
};

void(entity e, float slot) ClearSlot =
{
	if (e.options & OPT_VERBOSE)
	{

		msg_entity = e;
		it_simplestat(GetSlot(e, slot));
		if (stat_it)
		{
			sprint(self, "Lost item: ");
			WriteByte(MSG_ONE, 8);
			PrintItemName();
			WriteString(MSG_ONE, "\n");
		}
	}
	SetSlot(e, slot, IV_NULL);
	
};
float(vector it, float start, float check) inv_hasitem =
{
	local float i;
	local vector n;
	
	for (i=start; i <= TOTAL_SLOTS; i = i + 1)
	{
		n = GetSlot(self, i);

		if (it_x == n_x)
		{
			if (check)
			{
				if (it_y != n_y)
					continue;
			}
			return i;
		}
	}
	return FALSE;

};void(entity e) randomize_inventory =
{
	float i;
	local vector it;
	
	for (i = 1; i <= TOTAL_SLOTS; i = i + 1)
	{
		if (e.droprandom & pow2(i))
		{
			it = GetSlot(e, i);
			SetSlot(e, i, randitem(it_x, itemvalue + self.value, FALSE));
		}
	}
	e.droprandom = 0;
};
