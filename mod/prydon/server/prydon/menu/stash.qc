void() m_withdraw =
{
	local float i;
	local vector r;

	i = invenlst(self.m_subject, 0, m_invenlstcallback, '5728628 6841458 6387456');
	
	if (i)
	{
		r = GetSlot(self.m_subject, i);
		if (r)
		{
			r = pickupitem(r);
			if (!r)
			{
				ClearSlot(self.m_subject, i);
				self.m_refresh = 0;
			}
			else
			{
				prompt(self, "You don't have enough room\nin your inventory", self.m_subject, 2);
			}
		}
	}
};




void() m_deposit =
{
	local float i;
	local vector r;
	local entity e;


	i = invenlst(self, 0, m_invenlstcallback, '4482416 7304041 7602176');
	
	if (i)
	{
		r = GetSlot(self, i);
		if (r)
		{
			e = self;
			self = self.m_subject;
			r = pickupitem(r);
			self = e;
			
			if (!r)
			{
				Unequip(i, 0);
				ClearSlot(self, i);
				self.m_refresh = 0;
			}
			else
			{
				prompt(self, "This object can't carry anymore", self.m_subject, 2);
			}
		}
	}
};