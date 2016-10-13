// included here is everything specific to the Quake mode, monsters are used as part of the general mod and are so kept outside

#ifdef QUAKE
	#include "../weapons/cvars.qh"
	#include "weapons/all.inc"

	#include "changelevel.qc"
	#include "gates.qc"
	#include "inventory.qc"
	#include "lights.qc"
	#include "monsterjump.qc"
	#include "spikeshooter.qc"

	#define IMPLEMENTATION
		#include "weapons/all.inc"
	#undef IMPLEMENTATION
#endif
