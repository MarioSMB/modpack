#include "itemv1.qh"

vector legacy_itemv1(float itslot)
{
	if(itslot < 0)
	{
		stat_id = 0;
		itslot = 0 - itslot;
	}
	else
		stat_id = 1;
	stat_it = itslot & 31;
	stat_pref = floor(itslot / 32) & 31;
	stat_suf = floor (itslot / 1024) & 63;
	stat_dur = floor (itslot / 65536) & 255;
	if(!stat_it && itslot)
	{
		if(stat_pref)
		{
			stat_it = stat_pref + 63;
			stat_pref = 0;
			// this is still needed for compatability
			if(stat_it == IT_GOLD)
			{
				stat_dur = stat_dur + stat_suf * 256;
				stat_suf = 0;
			}
			else if(stat_it == IT_OIL2)
			{
				stat_pref = stat_suf;
				stat_suf = 0;
			}
			// UNIQUE1
			else if(stat_it == IT_UNIQUE1)
			{
				stat_it = 253 + stat_suf;
				stat_suf = 0;
			}
				
		}
		else
		{
			// quest items?
			stat_it = stat_suf + 190;
			stat_suf = 0;
		}
	}
	if(stat_suf > 47)
		stat_suf = stat_suf + 64;
	return it_setstat();
}
