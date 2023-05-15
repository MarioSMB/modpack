#if XONOTIC
	#include "main.qc"

	#include "../common/all.inc"

	#include "chat.qc"
	#include "commands.qc"
	#include "compat.qc"
	#include "damage.qc"
	#include "demo.qc"
	#include "ignore.qc"
	//#include "itemplacer.qc"
	#include "items.qc"
	#include "monsters.qc"
	#include "mute.qc"
	#include "player_size.qc"
	#include "settemp.qc"
	#include "spawnreplace.qc"
	#include "stats.qc"
	#include "team_collisions.qc"
	#include "tp.qc"
	#include "voteban.qc"
	#include "weapons.qc"

	#include "mutators/all.inc"
#endif

#define PRYDON
#ifdef PRYDON
	#include "../prydon/server/progs.inc"
#endif
