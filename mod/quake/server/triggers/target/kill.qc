#include "kill.qh"

#ifdef SVQC
void RemoveTarget(entity victim)
{
	// since the player won't get credit for the kill
	if(IS_MONSTER(victim) && victim.health > 0)	// iw -- don't change kill count when removing a dead monster
	{
		monsters_total -= 1;
	}
	else if(victim.customflags & CFL_SPAWNER)
	{
		if(victim.count > 0)
		{
			monsters_total -= 1 * victim.count;
		}
	}
	// clean up door triggers so they don't get lonely and crash
	else if(victim.trigger_field)
		delete(victim.trigger_field);

	// silence movers
	_sound(victim, CHAN_VOICE, "misc/null.wav", 1, 1);
	
	delete(victim);
}

void target_kill_remove(entity this, entity t, entity actor)
{
	if((this.spawnflags & 1) == 0)
	{
		RemoveTarget(t);
		return;
	}

	// 'murder' spawnflag: actually kill monsters instead of removing them
	if(IS_MONSTER(t) && t.health > 0)
	{
		T_Damage(t, actor, this, t.health + 20, DEATH_GENERIC.m_id);
	}
	else if(t.customflags & CFL_SPAWNER)
	{
		while(t.count > 0)
		{
			monsters_killed += 1;
			t.count -= 1;
		}
		delete(t);
	}
	else
		RemoveTarget(t);
}

void SUB_CountTargets(entity this)
{
	int i = 0;
	entity t = NULL;
	while(this.target != string_null) 
	{
		t = find(t, targetname, this.target);
		if(!t) break;
		i += 1;
	}
	t = NULL;
	while(this.target2 != string_null) 
	{
		t = find(t, targetname, this.target2);
		if(!t) break;
		i += 1;
	}
	t = NULL;
	while(this.target3 != string_null) 
	{
		t = find(t, targetname, this.target3);
		if(!t) break;
		i += 1;
	}
	t = NULL;
	while(this.target4 != string_null) 
	{
		t = find(t, targetname, this.target4);
		if(!t) break;
		i += 1;
	}

	this.cnt = i;

	this.frags = 0;	
	t = NULL;
	while(this.killtarget != string_null) 
	{
		t = find(t, targetname, this.killtarget);
		if(!t) break;
		this.frags += 1;
	}
}

void target_kill_rando(entity this, entity actor)
{
	SUB_CountTargets(this);
	this.cnt += this.frags;
	
	if(!this.cnt)
		return;

	entity t = NULL;
	int randy = ceil( random() * this.cnt );

	if(this.target && this.target != "") while ( randy > 0 )
	{
		t = find(t, targetname, this.target);
		if(!t)
			break;
		randy -= 1;
	}
	if(!t && this.target2 && this.target2 != "") while ( randy > 0 )
	{
		t = find(t, targetname, this.target2);
		if(!t)
			break;
		randy -= 1;
	}
	if(!t && this.target3 && this.target3 != "") while ( randy > 0 )
	{
		t = find(t, targetname, this.target3);
		if(!t)
			break;
		randy -= 1;
	}
	if(!t && this.target4 && this.target4 != "") while ( randy > 0 )
	{
		t = find(t, targetname, this.target4);
		if(!t)
			break;
		randy -= 1;
	}
	if(!t && this.killtarget && this.killtarget != "") while ( randy > 0 )
	{
		t = find(t, targetname, this.killtarget);
		if(!t)
			break;
		randy -= 1;
	}
	
	target_kill_remove(this, t, actor);
}

void target_kill_go(entity this)
{
	if(this.spawnflags & 2)
	{
		target_kill_rando(this, NULL);
		return;
	}
	entity t = NULL;

	// kill targets
	if(this.target && this.target != "")
	{
		t = NULL;
		do {
			t = find(t, targetname, this.target);
			if(!t) break;
			target_kill_remove(this, t, NULL);
		} while ( 1 );
	}
	if(this.target2 && this.target2 != "") {
		t = NULL;
		do {
			t = find(t, targetname, this.target2);
			if(!t) break;
			target_kill_remove(this, t, NULL);
		} while ( 1 );
	}
	if(this.target3 && this.target3 != "") {
		t = NULL;
		do {
			t = find(t, targetname, this.target3);
			if(!t) break;
			target_kill_remove(this, t, NULL);
		} while ( 1 );
	}
	if(this.target4 && this.target4 != "") {
		t = NULL;
		do {
			t = find(t, targetname, this.target4);
			if(!t) break;
			target_kill_remove(this, t, NULL);
		} while ( 1 );
	}
	if(this.killtarget && this.killtarget != "") {
		t = NULL;
		do {
			t = find(t, targetname, this.killtarget);
			if(!t) break;
			target_kill_remove(this, t, NULL);
		} while ( 1 );
	}
}

void target_kill_use(entity this, entity actor, entity trigger)
{
	if(!this.delay)
	{
		target_kill_go(this);
		return;
	}
	entity killer = spawn();
	killer.classname = "target_kill_killer";
	killer.target = this.target;
	killer.target2 = this.target2;
	killer.target3 = this.target3;
	killer.target4 = this.target4;
	setthink(killer, target_kill_go);
	killer.nextthink = time + this.delay;
}

/*QUAKED target_kill (0.75 0.5 0) (-8 -8 -8) (8 8 8) MURDER RANDOM
Kills ALL of its targets (1-4) as well as killtargets when triggered. for targets you really don't like.

"delay" wait before killing

MURDER	monsters are damaged to death, and spawners will credit unspawned kills
RANDOM	randomly kill only one target out of all of them
*/
/*FGD
@Pointclass base(Targetname, Appearflags) color(192 64 0) size(16 16 16) = target_kill : 
"Removes all targets when triggered. for targets you really don't like." [
	spawnflags(flags) =	[
		1 : "Murder monsters instead of removing" : 0
		2 : "Remove one target at random" : 0
	]	
	target(target_destination) : "Target: removes all with matching targetname" 
	target2(target_destination) : "Target 2: removes all with matching targetname" 
	target3(target_destination) : "Target 3: removes all with matching targetname" 
	target4(target_destination) : "Target 4: removes all with matching targetname" 
	killtarget(target_destination) : "Killtarget: removes all with matching targetname" 
	delay(string) : "Delay before removing" : "0"
]
*/
spawnfunc(target_kill)
{
	this.use = target_kill_use;
}
#endif
