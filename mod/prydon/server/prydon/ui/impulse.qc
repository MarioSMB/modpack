#include "impulse.qh"

#include "../spells/spells.qh"
#include "../subs/math.qh"

#if 0
#include "ui.qh"
#endif

void menu_impulse(entity this)
{
	if(this.impulse == 14)
		this.button1 = 1;
	else if(this.impulse == 15)
		this.button3 = 1;
	else if(this.impulse == 16)
		this.button3 = 0;
	else if(this.impulse == 11)
	{
		if(this.menu && this.m_func != m_dead)
			closemenu(this);
	}
}

void h_impulse(entity this)
{
	int i;
	if((this.impulse >= 99) && (this.impulse <= 115))
	{
		SelectSpell(this, this.impulse - 99);
	}
	else if((this.impulse >= 21) && (this.impulse <= 28))
	{
		i = this.impulse - 20;
			
		it_simplestat(this, GetSlot(this, i));
		it_itemstat(this);
		
		if(stat_loc & EQUIPABLE)
		{
			if(this.equip & (2 ** i))
				Unequip(this, i, 1);
			else if(!Equip(this, i))
				sprint(this, "Can't!\n");
		}
		if(stat_loc & USABLE)
			Use(this, i);
	}
	else if(this.impulse == 13)
	{
		if(!this.menu)
			openmenu(this, m_mainmenu, this);
	}
	else if(this.impulse == 17)
	{
		delete(this.camera);
		this.camera = NULL;
	}
	else if(this.impulse == 30)
	{
		i = inv_hasitem(this, IT_GREATER_HEAL * '1 0 0', 1, 0);
		if(i)
		{
			it_simplestat(this, GetSlot(this, i));
			it_itemstat(this);
			Use(this, i);
		}
		i = inv_hasitem(this, IT_HEAL_POTION * '1 0 0', 1, 0);
		if(i)
		{
			it_simplestat(this, GetSlot(this, i));
			it_itemstat(this);
			Use(this, i);
		}
		i = inv_hasitem(this, IT_LESSER_HEAL * '1 0 0', 1, 0);
		if(i)
		{
			it_simplestat(this, GetSlot(this, i));
			it_itemstat(this);
			Use(this, i);
		}

	}
	else if(this.impulse == 31)
	{
		i = inv_hasitem(this, IT_GREATER_MANA * '1 0 0', 1, 0);
		if(i)
		{
			it_simplestat(this, GetSlot(this, i));
			it_itemstat(this);
			Use(this, i);
		}
		i = inv_hasitem(this, IT_MANA_POTION * '1 0 0', 1, 0);
		if(i)
		{
			it_simplestat(this, GetSlot(this, i));
			it_itemstat(this);
			Use(this, i);
		}
		i = inv_hasitem(this, IT_LESSER_MANA * '1 0 0', 1, 0);
		if(i)
		{
			it_simplestat(this, GetSlot(this, i));
			it_itemstat(this);
			Use(this, i);
		}
	}
	else if(this.impulse == 32)
	{
		i = inv_hasitem(this, IT_CURE * '1 0 0', 1, 0);
		if(i)
		{
			it_simplestat(this, GetSlot(this, i));
			it_itemstat(this);
			Use(this, i);
		}
	}
#if 0
	else if(this.impulse == 33)
	{

		legacy_inventory();
		ui_showinventory();
	}

	else if(this.impulse == 34)
	{
		local float x,y;
		for (y = 0; y < INV_PLAYERSIZE_y; y = y + 1)
		{
			for (x = 0; x < INV_PLAYERSIZE_x; x = x + 1)
			{
				bprint(ftos(inv_get(this, x, y)), " ");
			}
			bprint("\n");
		}
	}

	else if(this.impulse == 42)
	{
		sprint(this, vtos(GetSlot(this, root2(this.weapon))));
		sprint(this, "\n");
	}
#endif
	if(cvar("developer"))
	{
		if(this.impulse == 40 || this.impulse == 41)
		{
			float t;
			if(this.weapon)
			{
				i = root2(this.weapon);
				it_simplestat(this, GetSlot(this, i));
				if(this.impulse == 40)
					t = 1;
				else 
					t = -1;
				if(this.menu == 1)
					stat_it = stat_it + t;
				else if(this.menu == 2)
					stat_pref = stat_pref + t;
				else if(this.menu == 3)
					stat_suf = stat_suf + t;
				else if(this.menu == 4)
					stat_dur = stat_dur + t;
	
				SetSlot(this, i, it_setstat());
				this.m_refresh = 0;
			}
				
		}
		else if(this.impulse == 47)
		{
			this.ptd = 255;
		}
	}
}
