#ifdef SVQC

.bool trigger_multiple_copperhack;

// the wait time has passed, so set back up for another activation
void multi_wait(entity this)
{
	if(this.max_health)
	{
		this.health = this.max_health;
		this.takedamage = DAMAGE_YES;
		this.solid = SOLID_BBOX;
	}
}


// the trigger was just touched/killed/used
// this.enemy should be set to the activator so it can be held through a delay
// so wait for the delay time before firing
void multi_trigger(entity this)
{
	if(this.nextthink > time)
	{
		return; // already been triggered
	}

	if(this.classname == "trigger_secret")
	{
		if(!IS_PLAYER(this.enemy))
			return;
		secrets_found += 1;
	}

	if(this.noise && this.noise != "")
		_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);

	// don't trigger again until reset
	this.takedamage = DAMAGE_NO;

	SUB_UseTargets(this, this.enemy, NULL);

	if(this.wait > 0)	
	{
		setthink(this, multi_wait);
		this.nextthink = time + this.wait;
	}
	else
	{	// we can't just delete(this) here, because this is a touch function
		// called while C code is looping through area links...
		settouch(this, func_null);
		this.nextthink = time + 0.1;
		setthink(this, SUB_Remove);
		return;
	}

	if(this.cnt > 0)
	{
		this.cnt = this.cnt - 1;
		if(this.cnt == 0)
		{
			settouch(this, func_null);
			this.nextthink = time + 0.1;
			setthink(this, SUB_Remove);
		}
	}
}

void multi_killed(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.enemy = attacker;
	multi_trigger(this);
}

void multi_use(entity this, entity actor, entity trigger)
{
	this.enemy = actor;
	multi_trigger(this);
}

void multi_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	
// if the trigger has an angles field, check player's facing direction
	if(this.movedir != '0 0 0')
	{
		makevectors(toucher.angles);
		if(v_forward * this.movedir < 0)
			return;		// not facing the right way
	}
	
	this.enemy = toucher;
	multi_trigger(this);
}

/*QUAKED trigger_multiple(.5 .5 .5) ? notouch
Variable sized repeatable trigger.  Must be targeted at one or more entities.  If "health" is set, the trigger must be killed to activate each time.
If "delay" is set, the trigger waits some time after activating before firing.
"wait" : Seconds between triggerings.(.2 default)
"cnt" how many times it can be triggered (infinite default in hipnotic)
If notouch is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by trigger_relay!
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
spawnfunc(trigger_multiple);
void trigger_multiple_use(entity this, entity actor, entity trigger)
{
	spawnfunc_trigger_multiple(this);
}
spawnfunc(trigger_multiple)
{
	if(MP_MG && Inhibit_Coop(this))
	{
		delete(this);
		return;
	}
	if(this.sounds == 1)
	{
		precache_sound("misc/secret.wav");
		this.noise = "misc/secret.wav";
	}
	else if(this.sounds == 2)
	{
		precache_sound(QUAKE_TALKSOUND);
		this.noise = QUAKE_TALKSOUND;
	}
	else if(this.sounds == 3)
	{
		precache_sound("misc/trigger1.wav");
		this.noise = "misc/trigger1.wav";
	}

	if(MP_MG)
	{
		this.sounds = 0;
		if(this.spawnflags & SPAWNFLAG_TRIGGER_FIRST)
		{
			this.use = trigger_multiple_use;
			this.spawnflags &= ~SPAWNFLAG_TRIGGER_FIRST;
			return;
		}
	}
	
	if(!this.wait)
		this.wait = 0.2;
	this.use = multi_use;

	if(this.trigger_multiple_copperhack)
		InitTriggerBounds(this);
	else
		InitTrigger(this);

	if(this.health)
	{
		if(this.spawnflags & SPAWNFLAG_NOTOUCH)
			objerror(this, "health and notouch don't make sense\n");
		this.max_health = this.health;
		this.th_die = multi_killed;
		this.takedamage = DAMAGE_YES;
		this.solid = SOLID_BBOX;
		setorigin(this, this.origin);	// make sure it links into the world
	}
	else if(!(this.spawnflags & SPAWNFLAG_NOTOUCH))
			settouch(this, multi_touch);

	if(!this.cnt)
		this.cnt = -1;
}

/*QUAKED trigger_once(.5 .5 .5) ? notouch
Variable sized trigger. Triggers once, then removes itself.  You must set the key "target" to the name of another object in the level that has a matching
"targetname".  If "health" is set, the trigger must be killed to activate.
If notouch is set, the trigger is only fired by other entities, not by touching.
if "killtarget" is set, any objects that have a matching "target" will be removed when the trigger is fired.
if "angle" is set, the trigger will only fire when someone is facing the direction of the angle.  Use "360" for an angle of 0.
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
spawnfunc(trigger_once)
{
	this.wait = -1;
	spawnfunc_trigger_multiple(this);
}

/*QUAKED trigger_multiple_box (.5 .5 0) (-8 -8 -8) (8 8 8) ? ? TRIGGER_FIRST MONSTERS ALL_CLIENTS
Trigger multiple. Variable sized repeatable trigger. Must be targeted at one or more entities.

Quoth2-style edict-saving bounding box trigger: define size with 'size', and the trigger volume will be that size centered on the trigger's origin.

Flags:
"all_clients" will trigger once per client touching it on the same frame before waiting (default behavior is to trigger only for the first touch event, ie the lowest-numbered client). use if you want to trigger a target_items or target_heal and have every client in the trigger affected by the result.
"trigger_first" won't be touchable until triggered once by something else
"monsters" monsters will fire this trigger (and count as activator, so be careful)

Keys:
"angle" the trigger will only fire when someone is facing the direction of the angle, use "360" for angle 0.
"distance" dot product result to compare "angle" against. 0 is 90 degrees off (default), 0.7 is 45 degrees.
"delay" delay before firing (after trigger)
"health" button must be killed to activate
"message" message to display when triggered
"sounds"
    1 = secret
    2 = beep beep
	3 = large switch
	4 = it is a mysteryyy
	-1 = silent
"noise"	choose your own .wav
"target"  entity to trigger (required)
"targetname"  entity name
"wait" delay between triggerings (default: 0.2) (NOTE: wait -1 with all_clients will not work like you think.)
*/
/*FGD
@PointClass base(TriggerMulti, Bounds) = trigger_multiple_box : "Trigger multiple. Variable sized repeatable trigger.
Must be targeted at one or more entities.

Quoth2-style edict-saving bounding box trigger: define size with 'size', and the trigger volume will be that size centered on the trigger's origin.

Spawnflags:
'No Touch': only triggered by other entities, not by touching (legacy; just use a trigger relay)
'All Clients': will trigger once per client touching it on the same frame before waiting (default behavior is to trigger only for the first touch event, ie the lowest-numbered client). use if you want to trigger a target_items or target_heal and have every client in the trigger affected by the result.
'Trigger First': won't be touchable until triggered once by something else
'Monsters Will Activate': monsters will fire this trigger (and count as activator, so be careful)"
[
	wait(string) : "Retriggering Interval" : "0.2"
]
*/
spawnfunc(trigger_multiple_box)
{
	this.trigger_multiple_copperhack = true; // workaround for not needing to overcomplicate trigger_multiple
	spawnfunc_trigger_multiple(this);
}

#endif
