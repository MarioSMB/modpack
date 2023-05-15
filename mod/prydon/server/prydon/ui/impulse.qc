void() menu_impulse =
{
	if (self.impulse == 14)
		self.button1 = 1;
	else if (self.impulse == 15)
		self.button3 = 1;
	else if (self.impulse == 16)
		self.button3 = 0;
	else if (self.impulse == 11)
	{
		if (self.menu && self.m_func != m_dead)
			closemenu(self);
	}
};

void h_impulse(entity this)
{
	float i;
	if ((self.impulse >= 99) && (self.impulse <= 115))
	{
		SelectSpell(self.impulse - 99);
	}
	else if ((self.impulse >= 21) && (self.impulse <= 28))
	{
		i = self.impulse - 20;
			
		it_simplestat(GetSlot(self, i));
		it_itemstat();
		
		if (stat_loc & EQUIPABLE)
		{
			if (self.equip & pow2(i))
				Unequip(i, 1);
			else if (!Equip(i))
				sprint(self, "Can't!\n");
		}
		if (stat_loc & USABLE)
			Use(i);
	}
	else if (self.impulse == 13)
	{
		if (!self.menu)
			openmenu(self, m_mainmenu, self);
	}
	else if (self.impulse == 17)
	{
		remove(self.camera);
		self.camera = world;
	}
	else if (self.impulse == 30)
	{
		i = inv_hasitem(IT_GREATER_HEAL * '1 0 0', 1, 0);
		if (i)
		{
			it_simplestat(GetSlot(self, i));
			it_itemstat();
			Use(i);
		}
		i = inv_hasitem(IT_HEAL_POTION * '1 0 0', 1, 0);
		if (i)
		{
			it_simplestat(GetSlot(self, i));
			it_itemstat();
			Use(i);
		}
		i = inv_hasitem(IT_LESSER_HEAL * '1 0 0', 1, 0);
		if (i)
		{
			it_simplestat(GetSlot(self, i));
			it_itemstat();
			Use(i);
		}

	}
	else if (self.impulse == 31)
	{
		i = inv_hasitem(IT_GREATER_MANA * '1 0 0', 1, 0);
		if (i)
		{
			it_simplestat(GetSlot(self, i));
			it_itemstat();
			Use(i);
		}
		i = inv_hasitem(IT_MANA_POTION * '1 0 0', 1, 0);
		if (i)
		{
			it_simplestat(GetSlot(self, i));
			it_itemstat();
			Use(i);
		}
		i = inv_hasitem(IT_LESSER_MANA * '1 0 0', 1, 0);
		if (i)
		{
			it_simplestat(GetSlot(self, i));
			it_itemstat();
			Use(i);
		}
	}
	else if (self.impulse == 32)
	{
		i = inv_hasitem(IT_CURE * '1 0 0', 1, 0);
		if (i)
		{
			it_simplestat(GetSlot(self, i));
			it_itemstat();
			Use(i);
		}
	}
/*
	else if (self.impulse == 33)
	{

		legacy_inventory();
		ui_showinventory();
	}

	else if (self.impulse == 34)
	{
		local float x,y;
		for (y = 0; y < INV_PLAYERSIZE_y; y = y + 1)
		{
			for (x = 0; x < INV_PLAYERSIZE_x; x = x + 1)
			{
				bprint(ftos(inv_get(self, x, y)), " ");
			}
			bprint("\n");
		}
	}

	else if (self.impulse == 42)
	{
		sprint(self, vtos(GetSlot(self, root2(self.weapon))));
		sprint(self, "\n");
	}
*/
	if (cvar("developer"))
	{
		if (self.impulse == 40 || self.impulse == 41)
		{
			float t;
			if (self.weapon)
			{
				i = root2(self.weapon);
				it_simplestat(GetSlot(self, i));
				if (self.impulse == 40)
					t = 1;
				else 
					t = -1;
				if (self.menu == 1)
					stat_it = stat_it + t;
				else if (self.menu == 2)
					stat_pref = stat_pref + t;
				else if (self.menu == 3)
					stat_suf = stat_suf + t;
				else if (self.menu == 4)
					stat_dur = stat_dur + t;
	
				SetSlot(self, i, it_setstat());
				self.m_refresh = 0;
			}
				
		}
		else if (self.impulse == 47)
		{
			self.ptd = 255;
		}
	

	}
};
