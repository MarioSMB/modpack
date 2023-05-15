void() legacy_inventory =
{
	local float i;
	
	for (i=1; i <= TOTAL_SLOTS; i = i + 1)
	{
		inv_autoplace(self, GetSlot(self, i), INV_PLAYERSIZE);
	}

};