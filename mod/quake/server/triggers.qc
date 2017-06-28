#include "combat.qh"

void trigger_reactivate(entity this)
{
	this.solid = SOLID_TRIGGER;
}

//=============================================================================

const int SPAWNFLAG_NOMESSAGE = BIT(0);
const int SPAWNFLAG_NOTOUCH = BIT(0);

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
		return;		// allready been triggered
	}

	if(this.classname == "trigger_secret")
	{
		if(!IS_PLAYER(this.enemy))
			return;
		found_secrets = found_secrets + 1;
		WriteByte(MSG_ALL, SVC_FOUNDSECRET);
	}

	if(this.noise)
		_sound(this, CHAN_VOICE, this.noise, 1, ATTN_NORM);

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
		// called wheil C code is looping through area links...
		settouch(this, func_null);
		this.nextthink = time + 0.1;
		setthink(this, SUB_Remove);
	}
}

void multi_killed(entity this, entity attacker)
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
If notouch is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by trigger_relay!
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
spawnfunc(trigger_multiple)
{
	if(this.sounds == 1)
	{
		precache_sound("misc/secret.wav");
		this.noise = "misc/secret.wav";
	}
	else if(this.sounds == 2)
	{
		precache_sound("misc/talk.wav");
		this.noise = "misc/talk.wav";
	}
	else if(this.sounds == 3)
	{
		precache_sound("misc/trigger1.wav");
		this.noise = "misc/trigger1.wav";
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
	else
	{
		if( !(this.spawnflags & SPAWNFLAG_NOTOUCH) )
		{
			settouch(this, multi_touch);
		}
	}
}


/*QUAKED trigger_once(.5 .5 .5) ? notouch
Variable sized trigger. Triggers once, then removes itthis.  You must set the key "target" to the name of another object in the level that has a matching
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

//=============================================================================

/*QUAKED trigger_relay(.5 .5 .5)(-8 -8 -8)(8 8 8)
This fixed size trigger cannot be touched, it can only be fired by other events.  It can contain killtargets, targets, delays, and messages.
*/
spawnfunc(trigger_relay)
{
	this.use = SUB_UseTargets;
}


//=============================================================================

/*QUAKED trigger_secret(.5 .5 .5) ?
secret counter trigger
sounds
1)	secret
2)	beep beep
3)
4)
set "message" to text string
*/
spawnfunc(trigger_secret)
{
	total_secrets = total_secrets + 1;
	this.wait = -1;
	if(!this.message)
		this.message = "You found a secret area!";
	if(!this.sounds)
		this.sounds = 1;
	
	if(this.sounds == 1)
	{
		precache_sound("misc/secret.wav");
		this.noise = "misc/secret.wav";
	}
	else if(this.sounds == 2)
	{
		precache_sound("misc/talk.wav");
		this.noise = "misc/talk.wav";
	}

	spawnfunc_trigger_multiple(this);
}

//=============================================================================


void counter_use(entity this, entity actor, entity trigger)
{
	this.count = this.count - 1;
	if(this.count < 0)
		return;
	
	if(this.count != 0)
	{
		if(IS_PLAYER(actor) && !(this.spawnflags & SPAWNFLAG_NOMESSAGE))
		{
			if(this.count >= 4)
				centerprint(actor, "There are more to go...");
			else if(this.count == 3)
				centerprint(actor, "Only 3 more to go...");
			else if(this.count == 2)
				centerprint(actor, "Only 2 more to go...");
			else
				centerprint(actor, "Only 1 more to go...");
		}
		return;
	}
	
	if(IS_PLAYER(actor) && !(this.spawnflags & SPAWNFLAG_NOMESSAGE))
		centerprint(actor, "Sequence completed!");
	this.enemy = actor;
	multi_trigger(this);
}

/*QUAKED trigger_counter(.5 .5 .5) ? nomessage
Acts as an intermediary for an action that takes multiple inputs.

If nomessage is not set, t will print "1 more.. " etc when triggered and "sequence complete" when finished.

After the counter has been triggered "count" times(default 2), it will fire all of it's targets and remove itthis.
*/
spawnfunc(trigger_counter)
{
	this.wait = -1;
	if(!this.count)
		this.count = 2;

	this.use = counter_use;
}


/*
==============================================================================

TELEPORT TRIGGERS

==============================================================================
*/

const int PLAYER_ONLY = BIT(0);
const int SILENT = BIT(1);

void play_teleport(entity this)
{
	string tmpstr;

	float v = random() * 5;
	if(v < 1)
		tmpstr = "misc/r_tele1.wav";
	else if(v < 2)
		tmpstr = "misc/r_tele2.wav";
	else if(v < 3)
		tmpstr = "misc/r_tele3.wav";
	else if(v < 4)
		tmpstr = "misc/r_tele4.wav";
	else
		tmpstr = "misc/r_tele5.wav";

	_sound(this, CHAN_VOICE, tmpstr, 1, ATTN_NORM);
	delete(this);
}

void spawn_tfog(vector org)
{
	entity s = spawn();
	s.origin = org;
	s.nextthink = time + 0.2;
	setthink(s, play_teleport);

	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_TELEPORT);
	WriteCoord(MSG_BROADCAST, org_x);
	WriteCoord(MSG_BROADCAST, org_y);
	WriteCoord(MSG_BROADCAST, org_z);
}


void tdeath_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

// frag anyone who teleports in on top of an invincible player
	if(IS_PLAYER(toucher))
	{
		if(toucher.invincible_finished > time)
			this.classname = "teledeath2";
		if(!IS_PLAYER(this.owner))
		{	// toucher monsters explode themselves
			T_Damage(this.owner, this, this, 50000);
			return;
		}
		
	}

	if(toucher.health)
	{
		T_Damage(toucher, this, this, 50000);
	}
}


void spawn_tdeath(vector org, entity death_owner)
{
	entity death = spawn();
	death.classname = "teledeath";
	set_movetype(death, MOVETYPE_NONE);
	death.solid = SOLID_TRIGGER;
	death.angles = '0 0 0';
	setsize(death, death_owner.mins - '1 1 1', death_owner.maxs + '1 1 1');
	setorigin(death, org);
	settouch(death, tdeath_touch);
	death.nextthink = time + 0.2;
	setthink(death, SUB_Remove);
	death.owner = death_owner;
	
	force_retouch = 2;		// make sure even still objects get hit
}

void teleport_touch(entity this, entity toucher)
{
	if(this.targetname && this.targetname != "" && this.nextthink < time)
		return;		// not fired yet

	if((this.spawnflags & PLAYER_ONLY) && !IS_PLAYER(toucher))
		return;

// only teleport living creatures
	if(toucher.health <= 0 || toucher.solid != SOLID_SLIDEBOX)
		return;

	SUB_UseTargets(this, NULL, toucher);

// put a tfog where the player was
	spawn_tfog(toucher.origin);

	entity t = find(NULL, targetname, this.target);
	if(!t)
		objerror(this, "couldn't find target");
		
// spawn a tfog flash in front of the destination
	makevectors(t.mangle);
	vector org = t.origin + 32 * v_forward;

	spawn_tfog(org);
	spawn_tdeath(t.origin, toucher);

// move the player and lock him down for a little while
	if(!toucher.health)
	{
		toucher.origin = t.origin;
		toucher.velocity =(v_forward * toucher.velocity_x) +(v_forward * toucher.velocity_y);
		return;
	}

	setorigin(toucher, t.origin);
	toucher.angles = t.mangle;
	if(IS_PLAYER(toucher))
	{
		toucher.fixangle = 1;		// turn this way immediately
		toucher.teleport_time = time + 0.7;
		toucher.velocity = v_forward * 300;
	}

	UNSET_ONGROUND(toucher);

	BITXOR_ASSIGN(toucher.effects, EF_TELEPORT_BIT);
}

/*QUAKED info_teleport_destination(.5 .5 .5)(-8 -8 -8)(8 8 32)
This is the destination marker for a teleporter.  It should have a "targetname" field with the same value as a teleporter's "target" field.
*/
spawnfunc(info_teleport_destination)
{
// this does nothing, just serves as a target spot
	this.mangle = this.angles;
	this.angles = '0 0 0';
	this.model = "";
	this.origin = this.origin + '0 0 27';
	if(!this.targetname)
		objerror(this, "no targetname");
}

void SUB_NullThink(entity this) { }

void teleport_use(entity this, entity actor, entity trigger)
{
	this.nextthink = time + 0.2;
	force_retouch = 2;		// make sure even still objects get hit
	setthink(this, SUB_NullThink);
}

/*QUAKED trigger_teleport(.5 .5 .5) ? PLAYER_ONLY SILENT
Any object touching this will be transported to the corresponding info_teleport_destination entity. You must set the "target" field, and create an object with a "targetname" field that matches.

If the trigger_teleport has a targetname, it will only teleport entities when it has been fired.
*/
spawnfunc(trigger_teleport)
{
	vector o;

	InitTrigger(this);
	settouch(this, teleport_touch);
	// find the destination 
	if(!this.target)
		objerror(this, "no target");
	this.use = teleport_use;

	if(!(this.spawnflags & SILENT))
	{
		precache_sound("ambience/hum1.wav");
		o =(this.mins + this.maxs)*0.5;
		ambientsound(o, "ambience/hum1.wav",0.5 , ATTN_STATIC);
	}
}

/*
==============================================================================

trigger_setskill

==============================================================================
*/

void trigger_skill_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
		
	cvar_set("skill", this.message);
}

/*QUAKED trigger_setskill(.5 .5 .5) ?
sets skill level to the value of "message".
Only used on start map.
*/
spawnfunc(trigger_setskill)
{
	InitTrigger(this);
	settouch(this, trigger_skill_touch);
}


/*
==============================================================================

ONLY REGISTERED TRIGGERS

==============================================================================
*/

void trigger_onlyregistered_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(this.attack_finished > time)
		return;

	this.attack_finished = time + 2;
	if(autocvar_registered)
	{
		this.message = "";
		SUB_UseTargets(this, NULL, toucher);
		delete(this);
	}
	else
	{
		if(this.message != "")
		{
			centerprint(toucher, this.message);
			_sound(toucher, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
		}
	}
}

/*QUAKED trigger_onlyregistered(.5 .5 .5) ?
Only fires if playing the registered version, otherwise prints the message
*/
spawnfunc(trigger_onlyregistered)
{
	precache_sound("misc/talk.wav");
	InitTrigger(this);
	settouch(this, trigger_onlyregistered_touch);
}

//============================================================================

void hurt_on(entity this)
{
	this.solid = SOLID_TRIGGER;
	this.nextthink = -1;
}

void hurt_touch(entity this, entity toucher)
{
	if(toucher.takedamage)
	{
		this.solid = SOLID_NOT;
		T_Damage(toucher, this, this, this.dmg);
		setthink(this, hurt_on);
		this.nextthink = time + 1;
	}

	return;
}

/*QUAKED trigger_hurt(.5 .5 .5) ?
Any object touching this will be hurt
set dmg to damage amount
defalt dmg = 5
*/
spawnfunc(trigger_hurt)
{
	InitTrigger(this);
	settouch(this, hurt_touch);
	if(!this.dmg)
		this.dmg = 5;
}

//============================================================================

const int PUSH_ONCE = BIT(0);

void trigger_push_touch(entity this, entity toucher)
{
	if(toucher.classname == "grenade")
		toucher.velocity = this.speed * this.movedir * 10;
	else if(toucher.health > 0)
	{
		toucher.velocity = this.speed * this.movedir * 10;
		if(IS_PLAYER(toucher))
		{
			if(toucher.fly_sound < time)
			{
				toucher.fly_sound = time + 1.5;
				_sound(toucher, CHAN_AUTO, "ambience/windfly.wav", 1, ATTN_NORM);
			}
		}
	}
	if(this.spawnflags & PUSH_ONCE)
		delete(this);
}


/*QUAKED trigger_push(.5 .5 .5) ? PUSH_ONCE
Pushes the player
*/
spawnfunc(trigger_push)
{
	InitTrigger(this);
	precache_sound("ambience/windfly.wav");
	settouch(this, trigger_push_touch);
	if(!this.speed)
		this.speed = 1000;
}

//============================================================================

void trigger_monsterjump_touch(entity this, entity toucher)
{
	if(!IS_MONSTER(toucher))
		return;
	if((toucher.flags & FL_FLY) || (toucher.flags & FL_SWIM))
		return;

// set XY even if not on ground, so the jump will clear lips
	toucher.velocity_x = this.movedir_x * this.speed;
	toucher.velocity_y = this.movedir_y * this.speed;
	
	if(!(toucher.flags & FL_ONGROUND))
		return;
	
	toucher.flags &= ~FL_ONGROUND;

	toucher.velocity_z = this.height;
}

/*QUAKED trigger_monsterjump(.5 .5 .5) ?
Walking monsters that touch this will jump in the direction of the trigger's angle
"speed" default to 200, the speed thrown forward
"height" default to 200, the speed thrown upwards
*/
spawnfunc(trigger_monsterjump)
{
	if(!this.speed)
		this.speed = 200;
	if(!this.height)
		this.height = 200;
	if(this.angles == '0 0 0')
		this.angles = '0 360 0';
	InitTrigger(this);
	settouch(this, trigger_monsterjump_touch);
}

