#ifndef MENUQC

#ifndef IMPLEMENTATION
#if 0
	#include "effectinfo.qh"
#endif
	#include "waypoints.qh"
	#include "credits.qh"
	#include "dotc.qh"
	#include "guardian.qh"
	#include "death.qc"
#else
	#include "credits.qc"
	#include "death.qc"
	#include "guardian.qc"
#endif

#include "drones/all.inc"

#if defined(SVQC)
	#include "dotc.qc"
	#ifndef IMPLEMENTATION
		#include "ai.qh"
		#include "core.qh"
		#include "factory.qh"
		#include "fighting.qh"
		#include "formation.qh"
		#include "spawnitems.qh"
	#else
		#include "ai.qc"
		#include "core.qc"
		#include "factory.qc"
		#include "fighting.qc"
		#include "formation.qc"
		#include "movement.qc"
		#include "spawnitems.qc"
		#include "spawnpoint.qc"
	#endif
#endif

#endif
