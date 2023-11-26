#include "common.qh"

bool W_DualWielding(entity player)
{
	int held_weapons = 0;
	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		if(player.(weaponentity) && player.(weaponentity).m_weapon != WEP_Null)
			++held_weapons;
	}

	return held_weapons > 1;
}
