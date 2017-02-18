#if XONOTIC
	#include "main.qc"

	#include "../common/all.inc"

	#include "bots.qc"
	#include "chat.qc"
	#include "commands.qc"
	#include "compat.qc"
	#include "damage.qc"
	#include "demo.qc"
	#include "ignore.qc"
	#include "itemplacer.qc"
	#include "items.qc"
	#include "headshots.qc"
	#include "monsters.qc"
	#include "mute.qc"
	#include "prediction.qc"
	#include "radio.qc"
	#include "spawnreplace.qc"
	#include "stats.qc"
	#include "tp.qc"

	#include "mutators/all.qh"
#endif

#define QUAKE_ONE
#ifdef QUAKE_ONE
	#include "../quake/server/progs.inc"
#endif
