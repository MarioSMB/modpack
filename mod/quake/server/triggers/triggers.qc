#ifdef SVQC


//=============================================================================

void DelayThink(entity this)
{
	SUB_UseTargets(this, this.enemy, NULL);
	delete(this);
}

/*
==============================
SUB_UseTargets

the global "activator" should be set to the entity that initiated the firing.

If this.delay is set, a DelayedUse entity will be created that will actually
do the SUB_UseTargets after that many seconds have passed.

Centerprints any this.message to the activator.

Removes all entities with a targetname that match this.killtarget,
and removes them, so some events can remove other triggers.

Search for(string)targetname in all entities that
match(string)this.target and call their .use function

==============================
*/
void SUB_UseTargets_Ex(entity this, entity actor, entity trigger, int skiptargets, bool nomessage)
{
//
// check for a delay
//
	if(this.delay)
	{
	// create a temp object to fire at a later time
		entity t = new_pure(DelayedUse);
		t.nextthink = time + this.delay;
		setthink(t, DelayThink);
		t.enemy = actor;
		if(!nomessage)
			t.message = this.message;
		t.killtarget = this.killtarget;
		t.target = this.target;
		t.targetname = this.targetname;
		t.use = func_null;
		return;
	}
	
	
//
// print the message
//
	if(!nomessage && IS_PLAYER(actor) && this.message != "")
	if(IS_REAL_CLIENT(actor))
	{
		centerprint(actor, this.message);
		if(!this.noise || this.noise == "")
			_sound(actor, CH_INFO, QUAKE_TALKSOUND, 1, ATTN_NORM);
	}

//
// kill the killtagets
//

	string s;
	s = this.killtarget;
	if (s && s != "")
	{
		for(entity t = NULL; (t = find(t, targetname, s)); )
			delete(t);
	}
	
//
// fire targets
//

	for(int i = 0; i < 4; ++i)
	{
		if(skiptargets & BIT(i + 1))
			continue;
		switch(i)
		{
			default:
			case 0: s = this.target; break;
			case 1: s = this.target2; break;
			case 2: s = this.target3; break;
			case 3: s = this.target4; break;
		}
		if (s != "")
		{
			for(entity t = NULL; (t = find(t, targetname, s)); )
			{
				if(t.use)
					t.use(t, actor, this);
			}
		}
	}
}

void SUB_UseTargets(entity this, entity actor, entity trigger) { SUB_UseTargets_Ex(this, actor, trigger, 0, false); }
void SUB_UseTargetsSilent(entity this, entity actor, entity trigger) { SUB_UseTargets_Ex(this, actor, trigger, 0, true); }

bool SUB_UseTargets_CopperAlt(entity this, entity actor, entity trigger, int skiptargets)
{
	if(!(this.spawnflags & SPAWN_ALT_TARG))
		return false;
	SUB_UseTargets_Ex(this, actor, trigger, skiptargets, false);
	return true;
}

/*
================
SUB_SwitchTargets
================
*/

void SUB_SwitchTargets(.string field, string oldtarget, string newtarget)
{
	FOREACH_ENTITY_STRING(targetname, oldtarget,
	{
		it.(field) = newtarget;
	});
}

/*
================
SUB_SetWorldType
================
*/

void SUB_SetWorldtype(entity this)
{
	if(this.worldtype)
		this.worldtype--;
	else
		this.worldtype = world.worldtype;
}

#endif
