#ifdef SVQC

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
	}

	if(MP_HIPNOTIC && this.cnt > 0)
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

void multi_killed(entity this, entity inflictor, entity attacker)
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

	if(MP_HIPNOTIC && !this.cnt)
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

#endif
