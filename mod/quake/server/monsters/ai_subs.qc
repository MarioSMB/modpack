#include "ai_subs.qh"

/*======================================================================
 ai_foundbreakable
  Check if the monster is allowed to break the breakable!?!
======================================================================*/
bool ai_foundbreakable(entity source, entity targ, bool ignorenoshoot)
{
	// Found a breakable in the way?
	if(targ.classname == "misc_breakablemodel")
	{
		// Check if a monster and nomonster damage/trigger allowed?
		if(IS_MONSTER(source) && (targ.spawnflags & BREAK_NOMONSTER)) return false;
		// Ignoring noshoot spawnflag? (designed for jump/missile events)
		else if(ignorenoshoot) return true;
		// is breakable explosive damage only and attacker can use explosives?
		else if(targ.brktrigmissile && source.attack_explosive) return true;
		// Can the breakable be damaged?
		else if(targ.spawnflags & BREAK_NOSHOOT) return false;
		// Its a breakable that breaks!
		else return true;
	}
	return false;
}

/*======================================================================
 ai_immunebreakable
  Check if a breakable/pushable is immune to damage from monsters
======================================================================*/
bool ai_immunebreakable(entity source, entity targ)
{
	// Found a breakable? (BSP or model)
	if(targ.classname == "misc_breakablemodel")
	{
		// Check no damage spawnflag?
		if(IS_MONSTER(source) && (targ.spawnflags & BREAK_NOMONSTER))
			return true;
	}
	// Found a pushable?
	else if(targ.classname == "func_pushable")
	{
		// Check no damage spawnflag?
		if(IS_MONSTER(source) && (targ.spawnflags & PUSH_NOMONSTER))
			return true;
	}
	return false;
}
