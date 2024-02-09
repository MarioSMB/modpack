#ifdef SVQC

/*
================================================================

CONTROL FLOW

All the relays, counters, and other gates that manipulate the firing
of other entities' .use() functions

including entities that aren't real triggers but are named trigger_*

================================================================
*/

void sound_delayed(entity on, float _chan, string _noise, float _volume, float _distance, float _delay);
void trigger_relay_use(entity this, entity actor, entity trigger)
{
	if(this.customflags & CFL_LOCKED)
		return;
	
	this.enemy = actor;
	
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

/*QUAKED trigger_relay (.5 .0 .5) (-8 -8 -8) (8 8 8) MSG_ONCE RANDOM
This fixed size trigger cannot be touched, it can only be fired by other events.  Target this with a target_lock to selectively disable/reenable it for logic fun.

Keys:
"delay" delay before firing (after trigger)
"killtarget" removes target
"message" displayed when fired
"target/2/3/4" fires target when triggered
"targetname"  entity name (required)
"sounds" same as other triggers, plays after 'delay'
"noise" or, pick any wav
"count" only fire this many times, then auto self-destruct

Spawnflags:
"MSG_ONCE"	only print its message on the first firing, otherwise it prints every time
"RANDOM"	randomly fire one of its targets (and/or kill one of its killtargets) instead of them all
*/
/*FGD
@PointClass size(16 16 16) color(160 0 160) base(Appearflags, TriggerSounds, Target, Targetname) = trigger_relay : "Trigger: Relay.
This fixed size trigger cannot be touched, it can only be fired by other events. Target this with a target_lock to selectively disable/reenable it for logic fun."
[
	spawnflags(flags) =	[
		1 : "Only print message once" : 0
		2 : "Choose one target at random" : 0
	]
	message(string) : "Print when triggered"
	count(integer) : "Limit uses (then self destruct)" : 0
]
*/
spawnfunc(trigger_relay)
{
	if(MP_MG && (Inhibit_Coop(this) || RemovedOutsideCoop(this)))
	{
		delete(this);
		return;
	}
	this.use = trigger_relay_use;

	if(this.spawnflags & 2)
		this.target_random = true;

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
