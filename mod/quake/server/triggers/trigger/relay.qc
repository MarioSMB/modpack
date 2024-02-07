#ifdef SVQC

/*
================================================================

CONTROL FLOW

All the relays, counters, and other gates that manipulate the firing
of other entities' .use() functions

including entities that aren't real triggers but are named trigger_*

================================================================
*/

void trigger_relay_msg(entity this)
{
	SUB_PrintMessage(this, this.enemy);
	
	if(this.noise && this.noise != "")
		_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);

	if(this.spawnflags & 1)
		this.message = string_null;
}

void sound_delayed(entity on, float _chan, string _noise, float _volume, float _distance, float _delay);
void trigger_relay_use(entity this, entity actor, entity trigger)
{
	if(this.customflags & CFL_LOCKED)
		return;
	
	this.enemy = actor;
	
	if(this.spawnflags & 2)
	{
		//SUB_CountTargets(this);
		this.target_random = true;
		//SUB_UseRandomTarget();
		SUB_UseTargets(this, actor, trigger);
	}
	else
		SUB_UseTargets(this, actor, trigger);

	if(this.spawnflags & 1)
		this.message = string_null;
	
	if(!this.noise || this.noise == "")
	{
		if(this.delay > 0)
			sound_delayed(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM, this.delay);
		else
			_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
	}	
	
	playercount_convert(this, count);
	if(this.count > 0)
	{
		this.count -= 1;
		if(this.count == 0)
			delete(this);
	}
}

/*QUAKED trigger_relay(.5 .5 .5)(-8 -8 -8)(8 8 8)
This fixed size trigger cannot be touched, it can only be fired by other events.  It can contain killtargets, targets, delays, and messages.
*/
spawnfunc(trigger_relay)
{
	if(MP_MG && (Inhibit_Coop(this) || RemovedOutsideCoop(this)))
	{
		delete(this);
		return;
	}
	this.use = trigger_relay_use;

	if(!this.noise || this.noise == "")
	{
		if(this.sounds == 1)
			this.noise = "misc/secret.wav";
		else if(this.sounds == 2)
			this.noise = "misc/talk.wav";
		else if(this.sounds == 3)
			this.noise = "misc/trigger1.wav";
	}
	
	if(this.noise && this.noise != "")
		precache_sound(this.noise);
}

#endif
