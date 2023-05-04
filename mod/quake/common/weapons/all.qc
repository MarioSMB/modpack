#include "all.qh"

// WEAPON PLUGIN SYSTEM

WepSet _WepSet_FromWeapon(int a)
{
	a -= WEP_FIRST;
	if (REGISTRY_MAX(Weapons) > 24)
		if (a >= 24)
		{
			a -= 24;
			if (REGISTRY_MAX(Weapons) > 48)
				if (a >= 24)
				{
					a -= 24;
					return '0 0 1' * BIT(a);
				}
			return '0 1 0' * BIT(a);
		}
	return '1 0 0' * BIT(a);
}
#ifdef SVQC
	void WriteWepSet(float dst, WepSet w)
	{
		if (REGISTRY_MAX(Weapons) > 48) WriteInt72_t(dst, w);
		else if (REGISTRY_MAX(Weapons) > 24) WriteInt48_t(dst, w);
		else WriteInt24_t(dst, w.x);
	}
#endif
#ifdef CSQC
	WepSet WepSet_GetFromStat()
	{
		return STAT(WEAPONS);
	}
	WepSet ReadWepSet()
	{
		if (REGISTRY_MAX(Weapons) > 48) return ReadInt72_t();
		if (REGISTRY_MAX(Weapons) > 24) return ReadInt48_t();
		return ReadInt24_t() * '1 0 0';
	}
#endif
