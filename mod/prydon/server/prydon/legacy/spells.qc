/*

LEGACY GARBAGE

*/


float(float espell, float sp1, float sp2) decompress_spell_value =
{
	local float f;

	if (espell <= 8)
	{
		f = pow(2, (espell - 1) * 3);
		return floor((sp1 / f) & 7);
	}
	else if (espell <= 16)
	{
		f = pow(2, (espell - 9) * 3);
		return floor((sp2 / f) & 7);
	}
}
void(entity e) decompress_spells =
{
	local float i, sp1, sp2, l;
	
	sp1 = e.spells1;
	sp2 = e.spells2;
	
	for(i = 1; i <= 16; i = i + 1)
	{
		l = decompress_spell_value(i, sp1, sp2);
		SetSpellLevel(e, i, l);
	}
};

