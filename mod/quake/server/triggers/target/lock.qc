#include "lock.qh"

#ifdef SVQC
.float rand;

// state 1 = targets are currently locked
// state 0 = targets are currently unlocked

void target_lock_do(string tname, bool locking)
{
	if(!tname || tname == "")
		return;

	entity t = NULL;
	
	do {
		t = find (t, targetname, tname);
		if(!t)
			break;
		
		if(t.lock)
		{
			t.lock(t, !locking);
		}
		else
		{
			if(locking)
				t.customflags |= CFL_LOCKED;
			else
				t.customflags &= ~CFL_LOCKED;
		}
	} while(t);
}

void lock_targets(entity this)
{
	target_lock_do(this.target,  true);
	target_lock_do(this.target2, true);
	target_lock_do(this.target3, true);
	target_lock_do(this.target4, true);
	this.state = true;
}
void unlock_targets(entity this)
{
	target_lock_do(this.target,  false);
	target_lock_do(this.target2, false);
	target_lock_do(this.target3, false);
	target_lock_do(this.target4, false);
	this.state = false;
}

void target_lock_use(entity this, entity actor, entity trigger)
{
	bool locking = false, undoing = false;
	if(this.wait || this.rand)
	{
		undoing = true;
		this.nextthink = time + this.wait + random() * this.rand;
	}
	
	if(!(this.spawnflags & SPAWN_LOCK_NOTOGGLE))
	{
		this.state = !this.state;
		locking = this.state;
	}
	else if(this.spawnflags & SPAWN_LOCK_LOCK_ONLY)
		locking = true;
	else
		locking = false;

	if(locking)
	{
		lock_targets(this);
		if(undoing)
			setthink(this, unlock_targets);
		return;
	}
	unlock_targets(this);
	if(undoing)
		setthink(this, lock_targets);
}

/*QUAKED target_lock (0 .5 .8) (-8 -8 -8) (8 8 8) START_LOCKED LOCK_ONLY UNLOCK_ONLY
Locks and unlocks targeted entities independent of their toggle/start_open/etc states.  Works on various entities:
  - A locked func_door won't respond to touches or triggers. Use this for doors behind temporary bars.
  - A locked func_plat behaves as an unreleased LOW_TRIGGER plat
  - A locked trigger_relay will not fire or evaluate at all
  - Locked path_corners are not considered valid patrol/train destinations
  - Locked trigger volumes (once/multi/teleport/secret/changelevel/push/monsterjump) will not activate when touched or triggered

If 'wait' or 'rand' are set, will automatically undo itself after 'wait' seconds plus up to 'rand' additional seconds.

Spawnflags:
"start_locked"	Targeted entities start out locked. 
"lock_only"		Will only lock its targets rather than toggling
"unlock_only"	Will only unlock its targets rather than toggling
*/
/*FGD
@Pointclass base(Targetname, Appearflags) color(192 64 0) size(16 16 16) = target_lock : 
"Locks and unlocks targeted entities independent of their toggle/start_open/etc states.  Works on various entities:
  - A locked func_door won't respond to touches or triggers. Use this for doors behind temporary bars.
  - A locked func_plat behaves as an unreleased LOW_TRIGGER plat
  - A locked trigger_relay will not fire or evaluate at all
  - Locked path_corners are not considered valid patrol/train destinations
  - Locked trigger volumes (once/multi/teleport/secret/changelevel/push/monsterjump) will not activate when touched or triggered
If 'wait' is set, will automatically undo itself after 'wait' seconds."
[
	spawnflags(flags) = [
		1: "Targeted entities start locked" : 0
		2: "Lock only" : 0
		4: "Unlock only" : 0
	]
	target(target_destination) : "Target: acts on all with matching targetname" 
	target2(target_destination) : "Target 2: acts on all with matching targetname" 
	target3(target_destination) : "Target 3: acts on all with matching targetname" 
	target4(target_destination) : "Target 4: acts on all with matching targetname" 
	wait(string) : "Wait before undoing" : 0
	rand(string) : "Additional random wait" : 0
]
*/
spawnfunc(target_lock)
{
	this.use = target_lock_use;
	this.state = 0;
	
	if(this.spawnflags & SPAWN_LOCK_START)
	{
		setthink(this, lock_targets);
		this.nextthink = time + 0.25;
	}
}
#endif
