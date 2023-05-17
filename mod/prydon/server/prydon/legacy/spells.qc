#include "spells.qh"

#include "../spells/spells.qh"

int decompress_spell_value(float espell, float sp1, float sp2)
{
	float f;

	if(espell <= 8)
	{
		f = (2 ** (espell - 1) * 3);
		return floor((sp1 / f) & 7);
	}
	else if(espell <= 16)
	{
		f = (2 ** (espell - 9) * 3);
		return floor((sp2 / f) & 7);
	}
	return 0;
}
void decompress_spells(entity e)
{
	int sp1 = e.spells1;
	int sp2 = e.spells2;
	
	for(int i = 1; i <= 16; i = i + 1)
	{
		int l = decompress_spell_value(i, sp1, sp2);
		SetSpellLevel(e, i, l);
	}
}
