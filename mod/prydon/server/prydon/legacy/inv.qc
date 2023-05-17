#include "inv.qh"

void legacy_inventory(entity this)
{
	for(int i = 1; i <= TOTAL_SLOTS; i = i + 1)
	{
		inv_autoplace(this, GetSlot(this, i), INV_PLAYERSIZE);
	}

}
