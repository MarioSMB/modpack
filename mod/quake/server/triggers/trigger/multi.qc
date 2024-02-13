#ifdef SVQC

const int MULTI_NOMESSAGE = 1;
const int MULTI_NOTOUCH = 1;
const int MULTI_SUPERSECRET = 2;
const int MULTI_TRIGGER_FIRST = 4;
const int MULTI_TRIGGER_TOGGLE = 4;
const int MULTI_TRIGGER_MONSTERS = 8;
const int MULTI_ALL_CLIENTS = 16;

void InitTriggerSounds(entity this)
{
	if(!this.noise || this.noise == "")
	{
		if(this.sounds == 1)
			this.noise = "misc/secret.wav";
		else if(this.sounds == 2)
			this.noise = QUAKE_TALKSOUND;
		else if(this.sounds == 3)
			this.noise = "misc/trigger1.wav";
	}
	
	if(this.noise && this.noise != "")
		precache_sound(this.noise);
}

// the wait time has passed, so set back up for another activation
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
bool multi_trigger(entity this)
{
	if(this.nextthink > time)
		return false;		// already been triggered

	if(this.customflags & CFL_LOCKED)
		return false;
	
	if(this.classname == "trigger_secret")
	{
		SUB_UseTargetsSilent(this, this.enemy, NULL);
		if(!IS_PLAYER(this.enemy))
			return false;
		if(this.noise && this.noise != "")
			_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
		secrets_found += 1;
		if(IS_REAL_CLIENT(this.enemy))
			centerprint(this.enemy, process_string(this.message));
		settouch(this, func_null);
		setthink(this, SUB_Remove);
		this.nextthink = time;
		return false;
	}

	playercount_convert(this, count);
	if(this.count > 0)
	{
		this.count -= 1;
		if(this.count == 0)
			delete(this);
	}
	SUB_UseTargets(this, this.enemy, NULL);
	
	// sub_usetargets plays the sound if there's a message, doesn't if not
	if(this.noise && this.noise != "")
		sound_delayed(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM, this.delay);

// don't trigger again until reset
	this.takedamage = DAMAGE_NO;
	
	if(this.wait > 0)	
	{
		setthink(this, multi_wait);
		this.nextthink = time + this.wait;
	}
	else
	{	// we can't just remove (this) here, because this is a touch function
		// called while C code is looping through area links...
		settouch(this, func_null);
		setthink(this, SUB_Remove);
		this.nextthink = time;
	}
	
	return true;
}

// simplified multi_trigger with repeat-per-client guard included
// and dumb shootable/secret overloads removed
bool multi_trigger_coop(entity this)
{
	if(this.customflags & CFL_LOCKED)
		return false;
	
	// respond to multiple coop clients touching this at once before disabling
	if(time != this.dmgtime)
		if(time < this.attack_finished)
			return false;
	
	playercount_convert(this, count);
	if(this.count > 0)
	{
		this.count -= 1;
		if(this.count == 0)
			delete(this);
	}
	SUB_UseTargets(this, this.enemy, NULL);
	
	if(this.noise && this.noise != "")
		_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
	
	if(this.spawnflags & MULTI_ALL_CLIENTS)
		this.dmgtime = time;
	this.attack_finished = time + this.wait;

	return true;
}


// trigger_multiples are sometimes used as shootable buttons :(
// most notably the 'well of wishes' secret message in start.bsp
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
	if(this.spawnflags & MULTI_TRIGGER_MONSTERS)
	{
		if(!IS_MONSTER(toucher))
			return;
		if(!(toucher.enemy || toucher.goalentity))
			return;
	}
	else if(!IS_PLAYER(toucher) || toucher.health <= 0)
		return;
	
	// if the trigger has an angles field, check player's facing direction
	if(this.movedir != '0 0 0')
	{
		makevectors(toucher.v_angle);
		if(v_forward * this.movedir < this.distance)
			return;		// not facing the right way
	}
	
	this.enemy = toucher;
	
	// would use think1 but the prototype has to be float(); hooray for saving an efield
	if(!this.checkattack)
		this.checkattack = multi_trigger;
	this.checkattack(this);
}


void init_trigger_multiple(entity this)
{
	if(!this.wait)
		this.wait = 0.2;
	this.use = multi_use;

	if(this.health)
	{
		if(this.spawnflags & MULTI_NOTOUCH)
			objerror(this, "init_trigger: health and notouch don't make sense together\n");
		if(this.spawnflags & MULTI_ALL_CLIENTS)
			objerror(this, "init_trigger: allclients and health don't make sense together\n");
		this.max_health = this.health;
		this.th_die = multi_killed;
		this.takedamage = DAMAGE_YES;
		this.solid = SOLID_BBOX;
		setorigin(this, this.origin);	// make sure it links into the world
	}
	else
	{
		this.solid = SOLID_TRIGGER;
		if(this.spawnflags & MULTI_ALL_CLIENTS)
		{
			if(this.spawnflags & MULTI_NOTOUCH)
				objerror(this, "init_trigger: allclients and notouch don't make sense together\n");
			this.checkattack = multi_trigger_coop;
		}
		if(!(this.spawnflags & MULTI_NOTOUCH))
			settouch(this, multi_touch);
	}
}

/*QUAKED trigger_multiple (.5 .0 .5) ? NOTOUCH ? TRIGGER_FIRST MONSTERS ALL_CLIENTS
Variable sized repeatable trigger.
Must be targeted at one or more entities.

Flags:
"notouch" only triggered by other entities, not by touching
"all_clients" will trigger once per client touching it on the same frame before waiting (default behavior is to trigger only for the first touch event, ie the lowest-numbered client). use if you want to trigger a target_items or target_heal and have every client in the trigger affected by the result.
"trigger_first" won't be touchable until triggered once by something else
"monsters" monsters will fire this trigger (and count as activator, so be careful)

Keys:
"angle" the trigger will only fire when someone is facing the direction of the angle, use 360 for angle 0.
"distance" degrees of tolerance on facing angle if 'angle' is set
"delay" delay before firing (after trigger)
"health" solid, must be killed to activate
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
@SolidClass base(TriggerMulti) = trigger_multiple : "Trigger multiple. Variable sized repeatable trigger.
Must be targeted at one or more entities.

Spawnflags:
'No Touch': only triggered by other entities, not by touching (legacy; just use a trigger relay)
'All Clients': will trigger once per client touching it on the same frame before waiting (default behavior is to trigger only for the first touch event, ie the lowest-numbered client). use if you want to trigger a target_items or target_heal and have every client in the trigger affected by the result.
'Trigger First': won't be touchable until triggered once by something else
'Monsters Will Activate': monsters will fire this trigger (and count as activator, so be careful)" 
[
	wait(string) : "Retriggering Interval" : "0.2"
]
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

	InitTriggerSounds(this);

	if(this.spawnflags & MULTI_TRIGGER_FIRST)
	{
		this.use = trigger_multiple_use;
		this.spawnflags &= ~MULTI_TRIGGER_FIRST;
		return;
	}
	
	init_trigger_multiple(this);
	InitTrigger(this);
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
	InitTriggerSounds(this);
	
	init_trigger_multiple(this);
	setorigin(this, this.origin);	// make sure it links into the world
	InitTriggerBounds(this);
}


/*QUAKED trigger_once (.5 .0 .5) ? NOTOUCH ? TRIGGER_FIRST MONSTERS
Variable sized trigger. Triggers once, then removes itself. You must set the key "target" to the name of another object in the level that has a matching "targetname". If notouch is set, the trigger is only fired by other entities, not by touching.

Wait is always -1.

Flags:
"notouch" only triggered by other entities, not by touching
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
*/
/*FGD
@SolidClass base(TriggerMulti) = trigger_once : "Trigger multiple. Variable sized trigger.
Must be targeted at one or more entities. Wait is always -1: removes itself after one use.

Spawnflags:
'No Touch': only triggered by other entities, not by touching (legacy; just use a trigger relay)
'All Clients': will trigger once per client touching it on the same frame before waiting (default behavior is to trigger only for the first touch event, ie the lowest-numbered client). use if you want to trigger a target_items or target_heal and have every client in the trigger affected by the result.
'Trigger First': won't be touchable until triggered once by something else
'Monsters Will Activate': monsters will fire this trigger (and count as activator, so be careful)"
[]
*/
spawnfunc(trigger_once)
{
	this.wait = -1;
	spawnfunc_trigger_multiple(this);
}


/*QUAKED trigger_once_box (.5 .0 .5) ? ? ? TRIGGER_FIRST MONSTERS
Quoth2-style cache-saving bounding box triggers: define size with "mangle", as total dimensions in xyz - trigger volume will be that size centered on the trigger_multiple_box's origin.  otherwise acts like a normal trigger.

Wait is always -1.

Quoth2-style edict-saving bounding box trigger: define size with 'size', and the trigger volume will be that size centered on the trigger's origin.

Flags:
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
*/
/*FGD
@PointClass base(TriggerMulti, Bounds) = trigger_once_box : "Trigger multiple. Variable sized trigger.
Must be targeted at one or more entities. Wait is always -1: removes itself after one use.

Quoth2-style edict-saving bounding box trigger: define size with 'size', and the trigger volume will be that size centered on the trigger's origin.

Spawnflags:
'No Touch': only triggered by other entities, not by touching (legacy; just use a trigger relay)
'All Clients': will trigger once per client touching it on the same frame before waiting (default behavior is to trigger only for the first touch event, ie the lowest-numbered client). use if you want to trigger a target_items or target_heal and have every client in the trigger affected by the result.
'Trigger First': won't be touchable until triggered once by something else
'Monsters Will Activate': monsters will fire this trigger (and count as activator, so be careful)"
[]
*/
spawnfunc(trigger_once_box)
{
	this.wait = -1;
	spawnfunc_trigger_multiple_box(this);
}

#endif
