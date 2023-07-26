#include "vis.qh"

void dovis()
{
	IL_EACH(g_moveables, !IS_PLAYER(it) && it.solid != SOLID_NOT && it.solid != SOLID_BSP,
	{
		it.effects |= EF_NODRAW;
	});

	FOREACH_CLIENT(IS_PLAYER(it),
	{
		entity f = findradius(it.origin, 512);
		while(f)
		{
			if(!IS_PLAYER(f) && f.solid != SOLID_NOT && f.solid != SOLID_BSP)
				f.effects &= ~EF_NODRAW;
			f = f.chain;
		}
	});
}
