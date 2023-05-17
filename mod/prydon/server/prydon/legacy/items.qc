#include "items.qh"

void legacy_item(entity this, bool rollable)
{
	// old <1.4 item codes
	
	if(this.droprandom)
	{
		if(this.items)
		{
			this.slot1 = IV_NULL;
			this.slot1_x = this.items;
			if(this.slot1_x > IT_SPEARS)
				this.slot1_x = this.slot1_x + 32;
			this.items = 0;
		}
		this.slot1 = randitem(this, this.slot1_x, itemvalue, 3);
		this.droprandom = 0;
	}
	else if(this.items)
	{
		if(rollable)
		{
			this.slot1 = IV_NULL;
			this.slot1_x = this.items;
			if(this.slot1_x > IT_SPEARS)
				this.slot1_x = this.slot1_x + 32;
		}
		else
			this.slot1 = legacy_itemv1(this.items);
		this.items = 0;
	}
}
