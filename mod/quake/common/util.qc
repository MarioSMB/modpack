#include "util.qh"

#ifdef GAMEQC
int Mod_Q1BSP_SuperContentsFromNativeContents(int nativecontents)
{
	switch(nativecontents)
	{
		case CONTENT_EMPTY:
			return 0;
		case CONTENT_SOLID:
			return DPCONTENTS_SOLID | DPCONTENTS_OPAQUE;
		case CONTENT_WATER:
			return DPCONTENTS_WATER;
		case CONTENT_SLIME:
			return DPCONTENTS_SLIME;
		case CONTENT_LAVA:
			return DPCONTENTS_LAVA | DPCONTENTS_NODROP;
		case CONTENT_SKY:
			return DPCONTENTS_SKY | DPCONTENTS_NODROP | DPCONTENTS_OPAQUE; // to match behaviour of Q3 maps, let sky count as opaque
	}
	return 0;
}

int Mod_Q1BSP_NativeContentsFromSuperContents(int supercontents)
{
	if(supercontents & (DPCONTENTS_SOLID | DPCONTENTS_BODY))
		return CONTENT_SOLID;
	if(supercontents & DPCONTENTS_SKY)
		return CONTENT_SKY;
	if(supercontents & DPCONTENTS_LAVA)
		return CONTENT_LAVA;
	if(supercontents & DPCONTENTS_SLIME)
		return CONTENT_SLIME;
	if(supercontents & DPCONTENTS_WATER)
		return CONTENT_WATER;
	return CONTENT_EMPTY;
}
#endif
