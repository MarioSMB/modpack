
void(float rollable) legacy_item =
{
	// old <1.4 item codes
	
	if (self.droprandom)
	{
		if (self.items)
		{
			self.slot1 = IV_NULL;
			self.slot1_x = self.items;
			if (self.slot1_x > IT_SPEARS)
				self.slot1_x = self.slot1_x + 32;
			self.items = 0;
		}
		self.slot1 = randitem(self.slot1_x, itemvalue, 3);
		self.droprandom = 0;
	}
	else if (self.items)
	{
		if (rollable)
		{
			self.slot1 = IV_NULL;
			self.slot1_x = self.items;
			if (self.slot1_x > IT_SPEARS)
				self.slot1_x = self.slot1_x + 32;
		}
		else
			self.slot1 = legacy_itemv1(self.items);
		self.items = 0;
	}
};