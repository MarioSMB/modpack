void SUB_DontUseTargets()
{
}


void() SUB_UseTargets;

void DelayThink()
{
	activator = self.enemy;
	SUB_UseTargets ();
	remove(self);
}

/*
==============================
SUB_UseTargets

the global "activator" should be set to the entity that initiated the firing.

If self.delay is set, a DelayedUse entity will be created that will actually
do the SUB_UseTargets after that many seconds have passed.

Centerprints any self.message to the activator.

Removes all entities with a targetname that match self.killtarget,
and removes them, so some events can remove other triggers.

Search for (string)targetname in all entities that
match (string)self.target and call their .use function

==============================
*/
void SUB_UseTargets()
{
	entity t, stemp, otemp, act;
	string s;
	float i;

//
// check for a delay
//
	if (self.delay)
	{
	// create a temp object to fire at a later time
		t = spawn();
		t.classname = "DelayedUse";
		t.nextthink = time + self.delay;
		t.think = DelayThink;
		t.enemy = activator;
		t.message = self.message;
		t.killtarget = self.killtarget;
		t.target = self.target;
		t.target2 = self.target2;
		t.target3 = self.target3;
		t.target4 = self.target4;
		return;
	}


//
// print the message
//
	if (IS_PLAYER(activator) && self.message != "")
	{
		if(IS_REAL_CLIENT(activator))
		{
			centerprint (activator, self.message);
			if (self.noise == "")
				play2(activator, "misc/talk.wav");
		}
	}

//
// kill the killtagets
//
	s = self.killtarget;
	if (s != "")
	{
		for(t = world; (t = find(t, targetname, s)); )
			remove(t);
	}

//
// fire targets
//
	act = activator;
	stemp = self;
	otemp = other;

	if(stemp.target_random)
		RandomSelection_Init();

	for(i = 0; i < 4; ++i)
	{
		switch(i)
		{
			default:
			case 0: s = stemp.target; break;
			case 1: s = stemp.target2; break;
			case 2: s = stemp.target3; break;
			case 3: s = stemp.target4; break;
		}
		if (s != "")
		{
			for(t = world; (t = find(t, targetname, s)); )
			if(t.use)
			{
				if(stemp.target_random)
				{
					RandomSelection_Add(t, 0, string_null, 1, 0);
				}
				else
				{
					self = t;
					other = stemp;
					activator = act;
					self.use();
				}
			}
		}
	}

	if(stemp.target_random && RandomSelection_chosen_ent)
	{
		self = RandomSelection_chosen_ent;
		other = stemp;
		activator = act;
		self.use();
	}

	activator = act;
	self = stemp;
	other = otemp;
}


//=============================================================================

float	SPAWNFLAG_NOMESSAGE = 1;
float	SPAWNFLAG_NOTOUCH = 1;

// the wait time has passed, so set back up for another activation
void multi_wait()
{
	if (self.max_health)
	{
		self.health = self.max_health;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
	}
}


// the trigger was just touched/killed/used
// self.enemy should be set to the activator so it can be held through a delay
// so wait for the delay time before firing
void multi_trigger()
{
	if (self.nextthink > time)
	{
		return;		// allready been triggered
	}

	if (self.classname == "trigger_secret")
	{
		if not(IS_PLAYER(self.enemy))
			return;
		found_secrets = found_secrets + 1;
		WriteByte (MSG_ALL, SVC_FOUNDSECRET);
	}

	if (self.noise)
		sound (self.enemy, CH_TRIGGER, self.noise, VOL_BASE, ATTN_NORM);

// don't trigger again until reset
	self.takedamage = DAMAGE_NO;

	activator = self.enemy;
	other = self.goalentity;
	SUB_UseTargets();

	if (self.wait > 0)
	{
		self.think = multi_wait;
		self.nextthink = time + self.wait;
	}
	else if (self.wait == 0)
	{
		multi_wait(); // waiting finished
	}
	else
	{	// we can't just remove (self) here, because this is a touch function
		// called wheil C code is looping through area links...
		self.touch = func_null;
	}
}

void multi_use()
{
	self.goalentity = other;
	self.enemy = activator;
	multi_trigger();
}

void multi_touch()
{
	if not(self.spawnflags & 2)
		if not(other.iscreature)
			return;

	if(self.team)
		if((self.spawnflags & 4 == 0) == (self.team != other.team))
			return;

// if the trigger has an angles field, check player's facing direction
	if (self.movedir != '0 0 0')
	{
		makevectors (other.angles);
		if (v_forward * self.movedir < 0)
			return;		// not facing the right way
	}

	EXACTTRIGGER_TOUCH;

	self.enemy = other;
	self.goalentity = other;
	multi_trigger ();
}

void multi_eventdamage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (!self.takedamage)
		return;
	if(self.spawnflags & DOOR_NOSPLASH)
		if(!(DEATH_ISSPECIAL(deathtype)) && (deathtype & HITTYPE_SPLASH))
			return;
	self.health = self.health - damage;
	if (self.health <= 0)
	{
		self.enemy = attacker;
		self.goalentity = inflictor;
		multi_trigger();
	}
}

void multi_reset()
{
	if ( !(self.spawnflags & SPAWNFLAG_NOTOUCH) )
		self.touch = multi_touch;
	if (self.max_health)
	{
		self.health = self.max_health;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
	}
	self.think = func_null;
	self.nextthink = 0;
	self.team = self.team_saved;
}

/*QUAKED spawnfunc_trigger_multiple (.5 .5 .5) ? notouch
Variable sized repeatable trigger.  Must be targeted at one or more entities.  If "health" is set, the trigger must be killed to activate each time.
If "delay" is set, the trigger waits some time after activating before firing.
"wait" : Seconds between triggerings. (.2 default)
If notouch is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by spawnfunc_trigger_relay!
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void spawnfunc_trigger_multiple()
{
	self.reset = multi_reset;
	if (self.sounds == 1)
	{
		precache_sound ("misc/secret.wav");
		self.noise = "misc/secret.wav";
	}
	else if (self.sounds == 2)
	{
		precache_sound ("misc/talk.wav");
		self.noise = "misc/talk.wav";
	}
	else if (self.sounds == 3)
	{
		precache_sound ("misc/trigger1.wav");
		self.noise = "misc/trigger1.wav";
	}

	if (!self.wait)
		self.wait = 0.2;
	else if(self.wait < -1)
		self.wait = 0;
	self.use = multi_use;

	EXACTTRIGGER_INIT;

	self.team_saved = self.team;

	if (self.health)
	{
		if (self.spawnflags & SPAWNFLAG_NOTOUCH)
			objerror ("health and notouch don't make sense\n");
		self.max_health = self.health;
		self.event_damage = multi_eventdamage;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
		setorigin (self, self.origin);	// make sure it links into the world
	}
	else
	{
		if ( !(self.spawnflags & SPAWNFLAG_NOTOUCH) )
		{
			self.touch = multi_touch;
			setorigin (self, self.origin);	// make sure it links into the world
		}
	}
}


/*QUAKED spawnfunc_trigger_once (.5 .5 .5) ? notouch
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
void spawnfunc_trigger_once()
{
	self.wait = -1;
	spawnfunc_trigger_multiple();
}

//=============================================================================

/*QUAKED spawnfunc_trigger_relay (.5 .5 .5) (-8 -8 -8) (8 8 8)
This fixed size trigger cannot be touched, it can only be fired by other events.  It can contain killtargets, targets, delays, and messages.
*/
void spawnfunc_trigger_relay()
{
	self.use = SUB_UseTargets;
	self.reset = spawnfunc_trigger_relay; // this spawnfunc resets fully
}

void delay_use()
{
    self.think = SUB_UseTargets;
    self.nextthink = self.wait;
}

void delay_reset()
{
	self.think = func_null;
	self.nextthink = 0;
}

void spawnfunc_trigger_delay()
{
    if(!self.wait)
        self.wait = 1;

    self.use = delay_use;
    self.reset = delay_reset;
}

//=============================================================================


void counter_use()
{
	self.count = self.count - 1;
	if (self.count < 0)
		return;

	if (self.count != 0)
	{
		if (IS_PLAYER(activator)
		&& (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0)
		{
			if (self.count >= 4)
				centerprint (activator, "There are more to go...");
			else if (self.count == 3)
				centerprint (activator, "Only 3 more to go...");
			else if (self.count == 2)
				centerprint (activator, "Only 2 more to go...");
			else
				centerprint (activator, "Only 1 more to go...");
		}
		return;
	}

	if (IS_PLAYER(activator)
	&& (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0)
		centerprint(activator, "Sequence completed!");
	self.enemy = activator;
	multi_trigger ();
}

void counter_reset()
{
	self.count = self.cnt;
	multi_reset();
}

/*QUAKED spawnfunc_trigger_counter (.5 .5 .5) ? nomessage
Acts as an intermediary for an action that takes multiple inputs.

If nomessage is not set, t will print "1 more.. " etc when triggered and "sequence complete" when finished.

After the counter has been triggered "count" times (default 2), it will fire all of it's targets and remove itself.
*/
void spawnfunc_trigger_counter()
{
	self.wait = -1;
	if (!self.count)
		self.count = 2;
	self.cnt = self.count;

	self.use = counter_use;
	self.reset = counter_reset;
}

void trigger_hurt_use()
{
	if(IS_PLAYER(activator))
		self.enemy = activator;
	else
		self.enemy = world; // let's just destroy it, if taking over is too much work
}

.float triggerhurttime;
void trigger_hurt_touch()
{
	if (self.active != ACTIVE_ACTIVE) 
		return;

	if(self.team)
		if((self.spawnflags & 4 == 0) == (self.team != other.team))
			return;

	// only do the EXACTTRIGGER_TOUCH checks when really needed (saves some cpu)
	if (other.iscreature)
	{
		if (other.takedamage)
		if (other.triggerhurttime < time)
		{
			EXACTTRIGGER_TOUCH;
			other.triggerhurttime = time + 1;

			entity own;
			own = self.enemy;
			if not(IS_PLAYER(own))
			{
				own = self;
				self.enemy = world; // I still hate you all
			}

			Damage (other, self, own, self.dmg, DEATH_HURTTRIGGER, other.origin, '0 0 0');
		}
	}
	else if(other.damagedbytriggers)
	{
		if(other.takedamage)
		{
			EXACTTRIGGER_TOUCH;
			Damage(other, self, self, self.dmg, DEATH_HURTTRIGGER, other.origin, '0 0 0');
		}
	}

	return;
}

/*QUAKED spawnfunc_trigger_hurt (.5 .5 .5) ?
Any object touching this will be hurt
set dmg to damage amount
defalt dmg = 5
*/
.entity trigger_hurt_next;
entity trigger_hurt_last;
entity trigger_hurt_first;
void spawnfunc_trigger_hurt()
{
	EXACTTRIGGER_INIT;
	self.active = ACTIVE_ACTIVE;
	self.touch = trigger_hurt_touch;
	self.use = trigger_hurt_use;
	self.enemy = world; // I hate you all
	if (!self.dmg)
		self.dmg = 1000;
	if (self.message == "")
		self.message = "was in the wrong place";
	if (self.message2 == "")
		self.message2 = "was thrown into a world of hurt by";
	// self.message = "someone like %s always gets wrongplaced";

	if(!trigger_hurt_first)
		trigger_hurt_first = self;
	if(trigger_hurt_last)
		trigger_hurt_last.trigger_hurt_next = self;
	trigger_hurt_last = self;
}

float tracebox_hits_trigger_hurt(vector start, vector mi, vector ma, vector end)
{
	entity th;

	for(th = trigger_hurt_first; th; th = th.trigger_hurt_next)
		if(tracebox_hits_box(start, mi, ma, end, th.absmin, th.absmax))
			return TRUE;

	return FALSE;
}

//////////////////////////////////////////////////////////////
//
//
//
//Trigger heal --a04191b92fbd93aa67214ef7e72d6d2e
//
//////////////////////////////////////////////////////////////

.float triggerhealtime;
void trigger_heal_touch()
{
	if (self.active != ACTIVE_ACTIVE) 
		return;
	
	// only do the EXACTTRIGGER_TOUCH checks when really needed (saves some cpu)
	if (other.iscreature)
	{
		if (other.takedamage)
		if (!other.deadflag)
		if (other.triggerhealtime < time)
		{
			EXACTTRIGGER_TOUCH;
			other.triggerhealtime = time + 1;
			
			if (other.health < self.max_health)
			{
				other.health = min(other.health + self.health, self.max_health);
				other.pauserothealth_finished = max(other.pauserothealth_finished, time + autocvar_g_balance_pause_health_rot);
				sound (other, CH_TRIGGER, self.noise, VOL_BASE, ATTN_NORM);
			}
		}
	}
}

void spawnfunc_trigger_heal()
{
	self.active = ACTIVE_ACTIVE;
	
	EXACTTRIGGER_INIT;
	self.touch = trigger_heal_touch;
	if (!self.health)
		self.health = 10;
	if (!self.max_health)
		self.max_health = 200; //Max health topoff for field
	if(self.noise == "")
		self.noise = "misc/mediumhealth.wav";
	precache_sound(self.noise);
}


//////////////////////////////////////////////////////////////
//
//
//
//End trigger_heal
//
//////////////////////////////////////////////////////////////

.entity trigger_gravity_check;
void trigger_gravity_remove(entity own)
{
	if(own.trigger_gravity_check.owner == own)
	{
		UpdateCSQCProjectile(own);
		own.gravity = own.trigger_gravity_check.gravity;
		remove(own.trigger_gravity_check);
	}
	else
		backtrace("Removing a trigger_gravity_check with no valid owner");
	own.trigger_gravity_check = world;
}
void trigger_gravity_check_think()
{
	// This spawns when a player enters the gravity zone and checks if he left.
	// Each frame, self.count is set to 2 by trigger_gravity_touch() and decreased by 1 here.
	// It the player has left the gravity trigger, this will be allowed to reach 0 and indicate that.
	if(self.count <= 0)
	{
		if(self.owner.trigger_gravity_check == self)
			trigger_gravity_remove(self.owner);
		else
			remove(self);
		return;
	}
	else
	{
		self.count -= 1;
		self.nextthink = time;
	}
}

void trigger_gravity_use()
{
	self.state = !self.state;
}

void trigger_gravity_touch()
{
	float g;

	if(self.state != TRUE)
		return;

	EXACTTRIGGER_TOUCH;

	g = self.gravity;

	if not(self.spawnflags & 1)
	{
		if(other.trigger_gravity_check)
		{
			if(self == other.trigger_gravity_check.enemy)
			{
				// same?
				other.trigger_gravity_check.count = 2; // gravity one more frame...
				return;
			}

			// compare prio
			if(self.cnt > other.trigger_gravity_check.enemy.cnt)
				trigger_gravity_remove(other);
			else
				return;
		}
		other.trigger_gravity_check = spawn();
		other.trigger_gravity_check.enemy = self;
		other.trigger_gravity_check.owner = other;
		other.trigger_gravity_check.gravity = other.gravity;
		other.trigger_gravity_check.think = trigger_gravity_check_think;
		other.trigger_gravity_check.nextthink = time;
		other.trigger_gravity_check.count = 2;
		if(other.gravity)
			g *= other.gravity;
	}

	if (other.gravity != g)
	{
		other.gravity = g;
		if(self.noise != "")
			sound (other, CH_TRIGGER, self.noise, VOL_BASE, ATTN_NORM);
		UpdateCSQCProjectile(self.owner);
	}
}

void spawnfunc_trigger_gravity()
{
	if(self.gravity == 1)
		return;

	EXACTTRIGGER_INIT;
	self.touch = trigger_gravity_touch;
	if(self.noise != "")
		precache_sound(self.noise);

	self.state = TRUE;
	IFTARGETED
	{
		self.use = trigger_gravity_use;
		if(self.spawnflags & 2)
			self.state = FALSE;
	}
}

//=============================================================================

// TODO add a way to do looped sounds with sound(); then complete this entity
.float volume, atten;
void target_speaker_use_off();
void target_speaker_use_activator()
{
	if not(IS_REAL_CLIENT(activator))
		return;
	string snd;
	if(substring(self.noise, 0, 1) == "*")
	{
		var .string sample;
		sample = GetVoiceMessageSampleField(substring(self.noise, 1, -1));
		if(GetPlayerSoundSampleField_notFound)
			snd = "misc/null.wav";
		else if(activator.sample == "")
			snd = "misc/null.wav";
		else
		{
			tokenize_console(activator.sample);
			float n;
			n = stof(argv(1));
			if(n > 0)
				snd = strcat(argv(0), ftos(floor(random() * n + 1)), ".wav"); // randomization
			else
				snd = strcat(argv(0), ".wav"); // randomization
		}
	}
	else
		snd = self.noise;
	msg_entity = activator;
	soundto(MSG_ONE, self, CH_TRIGGER, snd, VOL_BASE * self.volume, self.atten);
}
void target_speaker_use_on()
{
	string snd;
	if(substring(self.noise, 0, 1) == "*")
	{
		var .string sample;
		sample = GetVoiceMessageSampleField(substring(self.noise, 1, -1));
		if(GetPlayerSoundSampleField_notFound)
			snd = "misc/null.wav";
		else if(activator.sample == "")
			snd = "misc/null.wav";
		else
		{
			tokenize_console(activator.sample);
			float n;
			n = stof(argv(1));
			if(n > 0)
				snd = strcat(argv(0), ftos(floor(random() * n + 1)), ".wav"); // randomization
			else
				snd = strcat(argv(0), ".wav"); // randomization
		}
	}
	else
		snd = self.noise;
	sound(self, CH_TRIGGER_SINGLE, snd, VOL_BASE * self.volume, self.atten);
	if(self.spawnflags & 3)
		self.use = target_speaker_use_off;
}
void target_speaker_use_off()
{
	sound(self, CH_TRIGGER_SINGLE, "misc/null.wav", VOL_BASE * self.volume, self.atten);
	self.use = target_speaker_use_on;
}
void target_speaker_reset()
{
	if(self.spawnflags & 1) // LOOPED_ON
	{
		if(self.use == target_speaker_use_on)
			target_speaker_use_on();
	}
	else if(self.spawnflags & 2)
	{
		if(self.use == target_speaker_use_off)
			target_speaker_use_off();
	}
}

void spawnfunc_target_speaker()
{
	// TODO: "*" prefix to sound file name
	// TODO: wait and random (just, HOW? random is not a field)
	if(self.noise)
		precache_sound (self.noise);

	if(!self.atten && !(self.spawnflags & 4))
	{
		IFTARGETED
			self.atten = ATTN_NORM;
		else
			self.atten = ATTN_STATIC;
	}
	else if(self.atten < 0)
		self.atten = 0;

	if(!self.volume)
		self.volume = 1;

	IFTARGETED
	{
		if(self.spawnflags & 8) // ACTIVATOR
			self.use = target_speaker_use_activator;
		else if(self.spawnflags & 1) // LOOPED_ON
		{
			target_speaker_use_on();
			self.reset = target_speaker_reset;
		}
		else if(self.spawnflags & 2) // LOOPED_OFF
		{
			self.use = target_speaker_use_on;
			self.reset = target_speaker_reset;
		}
		else
			self.use = target_speaker_use_on;
	}
	else if(self.spawnflags & 1) // LOOPED_ON
	{
		ambientsound (self.origin, self.noise, VOL_BASE * self.volume, self.atten);
		remove(self);
	}
	else if(self.spawnflags & 2) // LOOPED_OFF
	{
		objerror("This sound entity can never be activated");
	}
	else
	{
		// Quake/Nexuiz fallback
		ambientsound (self.origin, self.noise, VOL_BASE * self.volume, self.atten);
		remove(self);
	}
}


void spawnfunc_func_stardust() {
	self.effects = EF_STARDUST;
}

.string bgmscript;
.float bgmscriptattack;
.float bgmscriptdecay;
.float bgmscriptsustain;
.float bgmscriptrelease;
float pointparticles_SendEntity(entity to, float fl)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_POINTPARTICLES);

	// optional features to save space
	fl = fl & 0x0F;
	if(self.spawnflags & 2)
		fl |= 0x10; // absolute count on toggle-on
	if(self.movedir != '0 0 0' || self.velocity != '0 0 0')
		fl |= 0x20; // 4 bytes - saves CPU
	if(self.waterlevel || self.count != 1)
		fl |= 0x40; // 4 bytes - obscure features almost never used
	if(self.mins != '0 0 0' || self.maxs != '0 0 0')
		fl |= 0x80; // 14 bytes - saves lots of space

	WriteByte(MSG_ENTITY, fl);
	if(fl & 2)
	{
		if(self.state)
			WriteCoord(MSG_ENTITY, self.impulse);
		else
			WriteCoord(MSG_ENTITY, 0); // off
	}
	if(fl & 4)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);
	}
	if(fl & 1)
	{
		if(self.model != "null")
		{
			WriteShort(MSG_ENTITY, self.modelindex);
			if(fl & 0x80)
			{
				WriteCoord(MSG_ENTITY, self.mins_x);
				WriteCoord(MSG_ENTITY, self.mins_y);
				WriteCoord(MSG_ENTITY, self.mins_z);
				WriteCoord(MSG_ENTITY, self.maxs_x);
				WriteCoord(MSG_ENTITY, self.maxs_y);
				WriteCoord(MSG_ENTITY, self.maxs_z);
			}
		}
		else
		{
			WriteShort(MSG_ENTITY, 0);
			if(fl & 0x80)
			{
				WriteCoord(MSG_ENTITY, self.maxs_x);
				WriteCoord(MSG_ENTITY, self.maxs_y);
				WriteCoord(MSG_ENTITY, self.maxs_z);
			}
		}
		WriteShort(MSG_ENTITY, self.cnt);
		if(fl & 0x20)
		{
			WriteShort(MSG_ENTITY, compressShortVector(self.velocity));
			WriteShort(MSG_ENTITY, compressShortVector(self.movedir));
		}
		if(fl & 0x40)
		{
			WriteShort(MSG_ENTITY, self.waterlevel * 16.0);
			WriteByte(MSG_ENTITY, self.count * 16.0);
		}
		WriteString(MSG_ENTITY, self.noise);
		if(self.noise != "")
		{
			WriteByte(MSG_ENTITY, floor(self.atten * 64));
			WriteByte(MSG_ENTITY, floor(self.volume * 255));
		}
		WriteString(MSG_ENTITY, self.bgmscript);
		if(self.bgmscript != "")
		{
			WriteByte(MSG_ENTITY, floor(self.bgmscriptattack * 64));
			WriteByte(MSG_ENTITY, floor(self.bgmscriptdecay * 64));
			WriteByte(MSG_ENTITY, floor(self.bgmscriptsustain * 255));
			WriteByte(MSG_ENTITY, floor(self.bgmscriptrelease * 64));
		}
	}
	return 1;
}

void pointparticles_use()
{
	self.state = !self.state;
	self.SendFlags |= 2;
}

void pointparticles_think()
{
	if(self.origin != self.oldorigin)
	{
		self.SendFlags |= 4;
		self.oldorigin = self.origin;
	}
	self.nextthink = time;
}

void pointparticles_reset()
{
	if(self.spawnflags & 1)
		self.state = 1;
	else
		self.state = 0;
}

void spawnfunc_func_pointparticles()
{
	if(self.model != "")
		setmodel(self, self.model);
	if(self.noise != "")
		precache_sound (self.noise);
	
	if(!self.bgmscriptsustain)
		self.bgmscriptsustain = 1;
	else if(self.bgmscriptsustain < 0)
		self.bgmscriptsustain = 0;

	if(!self.atten)
		self.atten = ATTN_NORM;
	else if(self.atten < 0)
		self.atten = 0;
	if(!self.volume)
		self.volume = 1;
	if(!self.count)
		self.count = 1;
	if(!self.impulse)
		self.impulse = 1;

	if(!self.modelindex)
	{
		setorigin(self, self.origin + self.mins);
		setsize(self, '0 0 0', self.maxs - self.mins);
	}
	if(!self.cnt)
		self.cnt = particleeffectnum(self.mdl);

	Net_LinkEntity(self, (self.spawnflags & 4), 0, pointparticles_SendEntity);

	IFTARGETED
	{
		self.use = pointparticles_use;
		self.reset = pointparticles_reset;
		self.reset();
	}
	else
		self.state = 1;
	self.think = pointparticles_think;
	self.nextthink = time;
}

void spawnfunc_func_sparks()
{
	// self.cnt is the amount of sparks that one burst will spawn
	if(self.cnt < 1) {
		self.cnt = 25.0; // nice default value
	}

	// self.wait is the probability that a sparkthink will spawn a spark shower
	// range: 0 - 1, but 0 makes little sense, so...
	if(self.wait < 0.05) {
		self.wait = 0.25; // nice default value
	}

	self.count = self.cnt;
	self.mins = '0 0 0';
	self.maxs = '0 0 0';
	self.velocity = '0 0 -1';
	self.mdl = "TE_SPARK";
	self.impulse = 10 * self.wait; // by default 2.5/sec
	self.wait = 0;
	self.cnt = 0; // use mdl

	spawnfunc_func_pointparticles();
}

float rainsnow_SendEntity(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_RAINSNOW);
	WriteByte(MSG_ENTITY, self.state);
	WriteCoord(MSG_ENTITY, self.origin_x + self.mins_x);
	WriteCoord(MSG_ENTITY, self.origin_y + self.mins_y);
	WriteCoord(MSG_ENTITY, self.origin_z + self.mins_z);
	WriteCoord(MSG_ENTITY, self.maxs_x - self.mins_x);
	WriteCoord(MSG_ENTITY, self.maxs_y - self.mins_y);
	WriteCoord(MSG_ENTITY, self.maxs_z - self.mins_z);
	WriteShort(MSG_ENTITY, compressShortVector(self.dest));
	WriteShort(MSG_ENTITY, self.count);
	WriteByte(MSG_ENTITY, self.cnt);
	return 1;
}

/*QUAKED spawnfunc_func_rain (0 .5 .8) ?
This is an invisible area like a trigger, which rain falls inside of.

Keys:
"velocity"
 falling direction (should be something like '0 0 -700', use the X and Y velocity for wind)
"cnt"
 sets color of rain (default 12 - white)
"count"
 adjusts density, this many particles fall every second for a 1024x1024 area, default is 2000
*/
void spawnfunc_func_rain()
{
	self.dest = self.velocity;
	self.velocity = '0 0 0';
	if (!self.dest)
		self.dest = '0 0 -700';
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	SetBrushEntityModel();
	if (!self.cnt)
		self.cnt = 12;
	if (!self.count)
		self.count = 2000;
	self.count = 0.01 * self.count * (self.size_x / 1024) * (self.size_y / 1024);
	if (self.count < 1)
		self.count = 1;
	if(self.count > 65535)
		self.count = 65535;

	self.state = 1; // 1 is rain, 0 is snow
	self.Version = 1;

	Net_LinkEntity(self, FALSE, 0, rainsnow_SendEntity);
}


/*QUAKED spawnfunc_func_snow (0 .5 .8) ?
This is an invisible area like a trigger, which snow falls inside of.

Keys:
"velocity"
 falling direction (should be something like '0 0 -300', use the X and Y velocity for wind)
"cnt"
 sets color of rain (default 12 - white)
"count"
 adjusts density, this many particles fall every second for a 1024x1024 area, default is 2000
*/
void spawnfunc_func_snow()
{
	self.dest = self.velocity;
	self.velocity = '0 0 0';
	if (!self.dest)
		self.dest = '0 0 -300';
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	SetBrushEntityModel();
	if (!self.cnt)
		self.cnt = 12;
	if (!self.count)
		self.count = 2000;
	self.count = 0.01 * self.count * (self.size_x / 1024) * (self.size_y / 1024);
	if (self.count < 1)
		self.count = 1;
	if(self.count > 65535)
		self.count = 65535;

	self.state = 0; // 1 is rain, 0 is snow
	self.Version = 1;

	Net_LinkEntity(self, FALSE, 0, rainsnow_SendEntity);
}


void FireRailgunBullet (vector start, vector end, float bdamage, float bforce, float mindist, float maxdist, float halflifedist, float forcehalflifedist, float deathtype);

.float modelscale;
void misc_laser_aim()
{
	vector a;
	if(self.enemy)
	{
		if(self.spawnflags & 2)
		{
			if(self.enemy.origin != self.mangle)
			{
				self.mangle = self.enemy.origin;
				self.SendFlags |= 2;
			}
		}
		else
		{
			a = vectoangles(self.enemy.origin - self.origin);
			a_x = -a_x;
			if(a != self.mangle)
			{
				self.mangle = a;
				self.SendFlags |= 2;
			}
		}
	}
	else
	{
		if(self.angles != self.mangle)
		{
			self.mangle = self.angles;
			self.SendFlags |= 2;
		}
	}
	if(self.origin != self.oldorigin)
	{
		self.SendFlags |= 1;
		self.oldorigin = self.origin;
	}
}

void misc_laser_init()
{
	if(self.target != "")
		self.enemy = find(world, targetname, self.target);
}

.entity pusher;
void misc_laser_think()
{
	vector o;
	entity oldself;
	entity hitent;
	vector hitloc;

	self.nextthink = time;

	if(!self.state)
		return;

	misc_laser_aim();

	if(self.enemy)
	{
		o = self.enemy.origin;
		if not(self.spawnflags & 2)
			o = self.origin + normalize(o - self.origin) * 32768;
	}
	else
	{
		makevectors(self.mangle);
		o = self.origin + v_forward * 32768;
	}

	if(self.dmg || self.enemy.target != "")
	{
		traceline(self.origin, o, MOVE_NORMAL, self);
	}
	hitent = trace_ent;
	hitloc = trace_endpos;

	if(self.enemy.target != "") // DETECTOR laser
	{
		if(trace_ent.iscreature)
		{
			self.pusher = hitent;
			if(!self.count)
			{
				self.count = 1;

				oldself = self;
				self = self.enemy;
				activator = self.pusher;
				SUB_UseTargets();
				self = oldself;
			}
		}
		else
		{
			if(self.count)
			{
				self.count = 0;

				oldself = self;
				self = self.enemy;
				activator = self.pusher;
				SUB_UseTargets();
				self = oldself;
			}
		}
	}

	if(self.dmg)
	{
		if(self.team)
			if((self.spawnflags & 8 == 0) == (self.team != hitent.team))
				return;
		if(hitent.takedamage)
			Damage(hitent, self, self, ((self.dmg < 0) ? 100000 : (self.dmg * frametime)), DEATH_HURTTRIGGER, hitloc, '0 0 0');
	}
}

float laser_SendEntity(entity to, float fl)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_LASER);
	fl = fl - (fl & 0xF0); // use that bit to indicate finite length laser
	if(self.spawnflags & 2)
		fl |= 0x80;
	if(self.alpha)
		fl |= 0x40;
	if(self.scale != 1 || self.modelscale != 1)
		fl |= 0x20;
	if(self.spawnflags & 4)
		fl |= 0x10;
	WriteByte(MSG_ENTITY, fl);
	if(fl & 1)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);
	}
	if(fl & 8)
	{
		WriteByte(MSG_ENTITY, self.colormod_x * 255.0);
		WriteByte(MSG_ENTITY, self.colormod_y * 255.0);
		WriteByte(MSG_ENTITY, self.colormod_z * 255.0);
		if(fl & 0x40)
			WriteByte(MSG_ENTITY, self.alpha * 255.0);
		if(fl & 0x20)
		{
			WriteByte(MSG_ENTITY, bound(0, self.scale * 16.0, 255));
			WriteByte(MSG_ENTITY, bound(0, self.modelscale * 16.0, 255));
		}
		if((fl & 0x80) || !(fl & 0x10)) // effect doesn't need sending if the laser is infinite and has collision testing turned off
			WriteShort(MSG_ENTITY, self.cnt + 1);
	}
	if(fl & 2)
	{
		if(fl & 0x80)
		{
			WriteCoord(MSG_ENTITY, self.enemy.origin_x);
			WriteCoord(MSG_ENTITY, self.enemy.origin_y);
			WriteCoord(MSG_ENTITY, self.enemy.origin_z);
		}
		else
		{
			WriteAngle(MSG_ENTITY, self.mangle_x);
			WriteAngle(MSG_ENTITY, self.mangle_y);
		}
	}
	if(fl & 4)
		WriteByte(MSG_ENTITY, self.state);
	return 1;
}

/*QUAKED spawnfunc_misc_laser (.5 .5 .5) ? START_ON DEST_IS_FIXED
Any object touching the beam will be hurt
Keys:
"target"
 spawnfunc_target_position where the laser ends
"mdl"
 name of beam end effect to use
"colormod"
 color of the beam (default: red)
"dmg"
 damage per second (-1 for a laser that kills immediately)
*/
void laser_use()
{
	self.state = !self.state;
	self.SendFlags |= 4;
	misc_laser_aim();
}

void laser_reset()
{
	if(self.spawnflags & 1)
		self.state = 1;
	else
		self.state = 0;
}

void spawnfunc_misc_laser()
{
	if(self.mdl)
	{
		if(self.mdl == "none")
			self.cnt = -1;
		else
		{
			self.cnt = particleeffectnum(self.mdl);
			if(self.cnt < 0)
				if(self.dmg)
					self.cnt = particleeffectnum("laser_deadly");
		}
	}
	else if(!self.cnt)
	{
		if(self.dmg)
			self.cnt = particleeffectnum("laser_deadly");
		else
			self.cnt = -1;
	}
	if(self.cnt < 0)
		self.cnt = -1;

	if(self.colormod == '0 0 0')
		if(!self.alpha)
			self.colormod = '1 0 0';
	if(self.message == "")
		self.message = "saw the light";
	if (self.message2 == "")
		self.message2 = "was pushed into a laser by";
	if(!self.scale)
		self.scale = 1;
	if(!self.modelscale)
		self.modelscale = 1;
	else if(self.modelscale < 0)
		self.modelscale = 0;
	self.think = misc_laser_think;
	self.nextthink = time;
	InitializeEntity(self, misc_laser_init, INITPRIO_FINDTARGET);

	self.mangle = self.angles;

	Net_LinkEntity(self, FALSE, 0, laser_SendEntity);

	IFTARGETED
	{
		self.reset = laser_reset;
		laser_reset();
		self.use = laser_use;
	}
	else
		self.state = 1;
}

// tZorks trigger impulse / gravity
.float radius;
.float falloff;
.float strength;
.float lastpushtime;

// targeted (directional) mode
void trigger_impulse_touch1()
{
	entity targ;
    float pushdeltatime;
    float str;

	if (self.active != ACTIVE_ACTIVE) 
		return;

	if (!isPushable(other))
		return;

	EXACTTRIGGER_TOUCH;

    targ = find(world, targetname, self.target);
    if(!targ)
    {
        objerror("trigger_force without a (valid) .target!\n");
        remove(self);
        return;
    }

    str = min(self.radius, vlen(self.origin - other.origin));

    if(self.falloff == 1)
        str = (str / self.radius) * self.strength;
    else if(self.falloff == 2)
        str = (1 - (str / self.radius)) * self.strength;
    else
        str = self.strength;

    pushdeltatime = time - other.lastpushtime;
    if (pushdeltatime > 0.15) pushdeltatime = 0;
    other.lastpushtime = time;
    if(!pushdeltatime) return;

    other.velocity = other.velocity + normalize(targ.origin - self.origin) * str * pushdeltatime;
    other.flags &~= FL_ONGROUND;
    UpdateCSQCProjectile(other);
}

// Directionless (accelerator/decelerator) mode
void trigger_impulse_touch2()
{
    float pushdeltatime;

	if (self.active != ACTIVE_ACTIVE) 
		return;

	if (!isPushable(other))
		return;

	EXACTTRIGGER_TOUCH;

    pushdeltatime = time - other.lastpushtime;
    if (pushdeltatime > 0.15) pushdeltatime = 0;
    other.lastpushtime = time;
    if(!pushdeltatime) return;

    // div0: ticrate independent, 1 = identity (not 20)
    other.velocity = other.velocity * pow(self.strength, pushdeltatime);
    UpdateCSQCProjectile(other);
}

// Spherical (gravity/repulsor) mode
void trigger_impulse_touch3()
{
    float pushdeltatime;
    float str;

	if (self.active != ACTIVE_ACTIVE) 
		return;

	if (!isPushable(other))
		return;

	EXACTTRIGGER_TOUCH;

    pushdeltatime = time - other.lastpushtime;
    if (pushdeltatime > 0.15) pushdeltatime = 0;
    other.lastpushtime = time;
    if(!pushdeltatime) return;

    setsize(self, '-1 -1 -1' * self.radius,'1 1 1' * self.radius);

	str = min(self.radius, vlen(self.origin - other.origin));

    if(self.falloff == 1)
        str = (1 - str / self.radius) * self.strength; // 1 in the inside
    else if(self.falloff == 2)
        str = (str / self.radius) * self.strength; // 0 in the inside
    else
        str = self.strength;

    other.velocity = other.velocity + normalize(other.origin - self.origin) * str * pushdeltatime;
    UpdateCSQCProjectile(other);
}

/*QUAKED spawnfunc_trigger_impulse (.5 .5 .5) ?
-------- KEYS --------
target : If this is set, this points to the spawnfunc_target_position to which the player will get pushed.
         If not, this trigger acts like a damper/accelerator field.

strength : This is how mutch force to add in the direction of .target each second
           when .target is set. If not, this is hoe mutch to slow down/accelerate
           someting cought inside this trigger. (1=no change, 0,5 half speed rougthly each tic, 2 = doubble)

radius   : If set, act as a spherical device rather then a liniar one.

falloff : 0 = none, 1 = liniar, 2 = inverted liniar

-------- NOTES --------
Use a brush textured with common/origin in the trigger entity to determine the origin of the force
in directional and sperical mode. For damper/accelerator mode this is not nessesary (and has no effect).
*/

void spawnfunc_trigger_impulse()
{
	self.active = ACTIVE_ACTIVE;

	EXACTTRIGGER_INIT;
    if(self.radius)
    {
        if(!self.strength) self.strength = 2000 * autocvar_g_triggerimpulse_radial_multiplier;
        setorigin(self, self.origin);
        setsize(self, '-1 -1 -1' * self.radius,'1 1 1' * self.radius);
        self.touch = trigger_impulse_touch3;
    }
    else
    {
        if(self.target)
        {
            if(!self.strength) self.strength = 950 * autocvar_g_triggerimpulse_directional_multiplier;
            self.touch = trigger_impulse_touch1;
        }
        else
        {
            if(!self.strength) self.strength = 0.9;
			self.strength = pow(self.strength, autocvar_g_triggerimpulse_accel_power) * autocvar_g_triggerimpulse_accel_multiplier;
            self.touch = trigger_impulse_touch2;
        }
    }
}

/*QUAKED spawnfunc_trigger_flipflop (.5 .5 .5) (-8 -8 -8) (8 8 8) START_ENABLED
"Flip-flop" trigger gate... lets only every second trigger event through
*/
void flipflop_use()
{
	self.state = !self.state;
	if(self.state)
		SUB_UseTargets();
}

void spawnfunc_trigger_flipflop()
{
	if(self.spawnflags & 1)
		self.state = 1;
	self.use = flipflop_use;
	self.reset = spawnfunc_trigger_flipflop; // perfect resetter
}

/*QUAKED spawnfunc_trigger_monoflop (.5 .5 .5) (-8 -8 -8) (8 8 8)
"Mono-flop" trigger gate... turns one trigger event into one "on" and one "off" event, separated by a delay of "wait"
*/
void monoflop_use()
{
	self.nextthink = time + self.wait;
	self.enemy = activator;
	if(self.state)
		return;
	self.state = 1;
	SUB_UseTargets();
}
void monoflop_fixed_use()
{
	if(self.state)
		return;
	self.nextthink = time + self.wait;
	self.state = 1;
	self.enemy = activator;
	SUB_UseTargets();
}

void monoflop_think()
{
	self.state = 0;
	activator = self.enemy;
	SUB_UseTargets();
}

void monoflop_reset()
{
	self.state = 0;
	self.nextthink = 0;
}

void spawnfunc_trigger_monoflop()
{
	if(!self.wait)
		self.wait = 1;
	if(self.spawnflags & 1)
		self.use = monoflop_fixed_use;
	else
		self.use = monoflop_use;
	self.think = monoflop_think;
	self.state = 0;
	self.reset = monoflop_reset;
}

void multivibrator_send()
{
	float newstate;
	float cyclestart;

	cyclestart = floor((time + self.phase) / (self.wait + self.respawntime)) * (self.wait + self.respawntime) - self.phase;

	newstate = (time < cyclestart + self.wait);

	activator = self;
	if(self.state != newstate)
		SUB_UseTargets();
	self.state = newstate;

	if(self.state)
		self.nextthink = cyclestart + self.wait + 0.01;
	else
		self.nextthink = cyclestart + self.wait + self.respawntime + 0.01;
}

void multivibrator_toggle()
{
	if(self.nextthink == 0)
	{
		multivibrator_send();
	}
	else
	{
		if(self.state)
		{
			SUB_UseTargets();
			self.state = 0;
		}
		self.nextthink = 0;
	}
}

void multivibrator_reset()
{
	if(!(self.spawnflags & 1))
		self.nextthink = 0; // wait for a trigger event
	else
		self.nextthink = max(1, time);
}

/*QUAKED trigger_multivibrator (.5 .5 .5) (-8 -8 -8) (8 8 8) START_ON
"Multivibrator" trigger gate... repeatedly sends trigger events. When triggered, turns on or off.
-------- KEYS --------
target: trigger all entities with this targetname when it goes off
targetname: name that identifies this entity so it can be triggered; when off, it always uses the OFF state
phase: offset of the timing
wait: "on" cycle time (default: 1)
respawntime: "off" cycle time (default: same as wait)
-------- SPAWNFLAGS --------
START_ON: assume it is already turned on (when targeted)
*/
void spawnfunc_trigger_multivibrator()
{
	if(!self.wait)
		self.wait = 1;
	if(!self.respawntime)
		self.respawntime = self.wait;

	self.state = 0;
	self.use = multivibrator_toggle;
	self.think = multivibrator_send;
	self.nextthink = max(1, time);

	IFTARGETED
		multivibrator_reset();
}


void follow_init()
{
	entity src, dst;
	src = world;
	dst = world;
	if(self.killtarget != "")
		src = find(world, targetname, self.killtarget);
	if(self.target != "")
		dst = find(world, targetname, self.target);

	if(!src && !dst)
	{
		objerror("follow: could not find target/killtarget");
		return;
	}

	if(self.jointtype)
	{
		// already done :P entity must stay
		self.aiment = src;
		self.enemy = dst;
	}
	else if(!src || !dst)
	{
		objerror("follow: could not find target/killtarget");
		return;
	}
	else if(self.spawnflags & 1)
	{
		// attach
		if(self.spawnflags & 2)
		{
			setattachment(dst, src, self.message);
		}
		else
		{
			attach_sameorigin(dst, src, self.message);
		}

		dst.solid = SOLID_NOT; // solid doesn't work with attachment
		remove(self);
	}
	else
	{
		if(self.spawnflags & 2)
		{
			dst.movetype = MOVETYPE_FOLLOW;
			dst.aiment = src;
			// dst.punchangle = '0 0 0'; // keep unchanged
			dst.view_ofs = dst.origin;
			dst.v_angle = dst.angles;
		}
		else
		{
			follow_sameorigin(dst, src);
		}

		remove(self);
	}
}

void spawnfunc_misc_follow()
{
	InitializeEntity(self, follow_init, INITPRIO_FINDTARGET);
}



void gamestart_use() {
	activator = self;
	SUB_UseTargets();
	remove(self);
}

void spawnfunc_trigger_gamestart() {
	self.use = gamestart_use;
	self.reset2 = spawnfunc_trigger_gamestart;

	if(self.wait)
	{
		self.think = self.use;
		self.nextthink = game_starttime + self.wait;
	}
	else
		InitializeEntity(self, gamestart_use, INITPRIO_FINDTARGET);
}




.entity voicescript; // attached voice script
.float voicescript_index; // index of next voice, or -1 to use the randomized ones
.float voicescript_nextthink; // time to play next voice
.float voicescript_voiceend; // time when this voice ends

void target_voicescript_clear(entity pl)
{
	pl.voicescript = world;
}

void target_voicescript_use()
{
	if(activator.voicescript != self)
	{
		activator.voicescript = self;
		activator.voicescript_index = 0;
		activator.voicescript_nextthink = time + self.delay;
	}
}

void target_voicescript_next(entity pl)
{
	entity vs;
	float i, n, dt;

	vs = pl.voicescript;
	if(!vs)
		return;
	if(vs.message == "")
		return;
	if not(IS_PLAYER(pl))
		return;
	if(gameover)
		return;

	if(time >= pl.voicescript_voiceend)
	{
		if(time >= pl.voicescript_nextthink)
		{
			// get the next voice...
			n = tokenize_console(vs.message);

			if(pl.voicescript_index < vs.cnt)
				i = pl.voicescript_index * 2;
			else if(n > vs.cnt * 2)
				i = mod(pl.voicescript_index - vs.cnt, (n - vs.cnt * 2 - 1) / 2) * 2 + vs.cnt * 2 + 1;
			else
				i = -1;

			if(i >= 0)
			{
				play2(pl, strcat(vs.netname, "/", argv(i), ".wav"));
				dt = stof(argv(i + 1));
				if(dt >= 0)
				{
					pl.voicescript_voiceend = time + dt;
					pl.voicescript_nextthink = pl.voicescript_voiceend + vs.wait * (0.5 + random());
				}
				else
				{
					pl.voicescript_voiceend = time - dt;
					pl.voicescript_nextthink = pl.voicescript_voiceend;
				}

				pl.voicescript_index += 1;
			}
			else
			{
				pl.voicescript = world; // stop trying then
			}
		}
	}
}

void spawnfunc_target_voicescript()
{
	// netname: directory of the sound files
	// message: list of "sound file" duration "sound file" duration, a *, and again a list
	//          foo1 4.1 foo2 4.0 foo3 -3.1 * fool1 1.1 fool2 7.1 fool3 9.1 fool4 3.7
	//          Here, a - in front of the duration means that no delay is to be
	//          added after this message
	// wait: average time between messages
	// delay: initial delay before the first message
	
	float i, n;
	self.use = target_voicescript_use;

	n = tokenize_console(self.message);
	self.cnt = n / 2;
	for(i = 0; i+1 < n; i += 2)
	{
		if(argv(i) == "*")
		{
			self.cnt = i / 2;
			++i;
		}
		precache_sound(strcat(self.netname, "/", argv(i), ".wav"));
	}
}



void trigger_relay_teamcheck_use()
{
	if(activator.team)
	{
		if(self.spawnflags & 2)
		{
			if(activator.team != self.team)
				SUB_UseTargets();
		}
		else
		{
			if(activator.team == self.team)
				SUB_UseTargets();
		}
	}
	else
	{
		if(self.spawnflags & 1)
			SUB_UseTargets();
	}
}

void trigger_relay_teamcheck_reset()
{
	self.team = self.team_saved;
}

void spawnfunc_trigger_relay_teamcheck()
{
	self.team_saved = self.team;
	self.use = trigger_relay_teamcheck_use;
	self.reset = trigger_relay_teamcheck_reset;
}



void trigger_disablerelay_use()
{
	entity e;

	float a, b;
	a = b = 0;

	for(e = world; (e = find(e, targetname, self.target)); )
	{
		if(e.use == SUB_UseTargets)
		{
			e.use = SUB_DontUseTargets;
			++a;
		}
		else if(e.use == SUB_DontUseTargets)
		{
			e.use = SUB_UseTargets;
			++b;
		}
	}

	if((!a) == (!b))
		print("Invalid use of trigger_disablerelay: ", ftos(a), " relays were on, ", ftos(b), " relays were off!\n");
}

void spawnfunc_trigger_disablerelay()
{
	self.use = trigger_disablerelay_use;
}

float magicear_matched;
float W_Tuba_HasPlayed(entity pl, string melody, float instrument, float ignorepitch, float mintempo, float maxtempo);
string trigger_magicear_processmessage(entity ear, entity source, float teamsay, entity privatesay, string msgin)
{
	float domatch, dotrigger, matchstart, l;
	string s, msg;
	entity oldself;
	string savemessage;

	magicear_matched = FALSE;

	dotrigger = ((IS_PLAYER(source)) && (source.deadflag == DEAD_NO) && ((ear.radius == 0) || (vlen(source.origin - ear.origin) <= ear.radius)));
	domatch = ((ear.spawnflags & 32) || dotrigger);

	if not(domatch)
		return msgin;

	if not(msgin)
	{
		// we are in TUBA mode!
		if not(ear.spawnflags & 256)
			return msgin;

		if(!W_Tuba_HasPlayed(source, ear.message, ear.movedir_x, !(ear.spawnflags & 512), ear.movedir_y, ear.movedir_z))
			return msgin;

		magicear_matched = TRUE;

		if(dotrigger)
		{
			oldself = self;
			activator = source;
			self = ear;
			savemessage = self.message;
			self.message = string_null;
			SUB_UseTargets();
			self.message = savemessage;
			self = oldself;
		}

		if(ear.netname != "")
			return ear.netname;

		return msgin;
	}

	if(ear.spawnflags & 256) // ENOTUBA
		return msgin;

	if(privatesay)
	{
		if(ear.spawnflags & 4)
			return msgin;
	}
	else
	{
		if(!teamsay)
			if(ear.spawnflags & 1)
				return msgin;
		if(teamsay > 0)
			if(ear.spawnflags & 2)
				return msgin;
		if(teamsay < 0)
			if(ear.spawnflags & 8)
				return msgin;
	}
	
	matchstart = -1;
	l = strlen(ear.message);

	if(ear.spawnflags & 128)
		msg = msgin;
	else
		msg = strdecolorize(msgin);

	if(substring(ear.message, 0, 1) == "*")
	{
		if(substring(ear.message, -1, 1) == "*")
		{
			// two wildcards
			// as we need multi-replacement here...
			s = substring(ear.message, 1, -2);
			l -= 2;
			if(strstrofs(msg, s, 0) >= 0)
				matchstart = -2; // we use strreplace on s
		}
		else
		{
			// match at start
			s = substring(ear.message, 1, -1);
			l -= 1;
			if(substring(msg, -l, l) == s)
				matchstart = strlen(msg) - l;
		}
	}
	else
	{
		if(substring(ear.message, -1, 1) == "*")
		{
			// match at end
			s = substring(ear.message, 0, -2);
			l -= 1;
			if(substring(msg, 0, l) == s)
				matchstart = 0;
		}
		else
		{
			// full match
			s = ear.message;
			if(msg == ear.message)
				matchstart = 0;
		}
	}

	if(matchstart == -1) // no match
		return msgin;

	magicear_matched = TRUE;

	if(dotrigger)
	{
		oldself = self;
		activator = source;
		self = ear;
		savemessage = self.message;
		self.message = string_null;
		SUB_UseTargets();
		self.message = savemessage;
		self = oldself;
	}

	if(ear.spawnflags & 16)
	{
		return ear.netname;
	}
	else if(ear.netname != "")
	{
		if(matchstart < 0)
			return strreplace(s, ear.netname, msg);
		else
			return strcat(
				substring(msg, 0, matchstart),
				ear.netname,
				substring(msg, matchstart + l, -1)
			);
	}
	else
		return msgin;
}

entity magicears;
string trigger_magicear_processmessage_forallears(entity source, float teamsay, entity privatesay, string msgin)
{
	entity ear;
	string msgout;
	for(ear = magicears; ear; ear = ear.enemy)
	{
		msgout = trigger_magicear_processmessage(ear, source, teamsay, privatesay, msgin);
		if not(ear.spawnflags & 64)
			if(magicear_matched)
				return msgout;
		msgin = msgout;
	}
	return msgin;
}

void spawnfunc_trigger_magicear()
{
	self.enemy = magicears;
	magicears = self;

	// actually handled in "say" processing
	// spawnflags:
	//    1 = ignore say
	//    2 = ignore teamsay
	//    4 = ignore tell
	//    8 = ignore tell to unknown player
	//   16 = let netname replace the whole message (otherwise, netname is a word replacement if set)
	//   32 = perform the replacement even if outside the radius or dead
	//   64 = continue replacing/triggering even if this one matched
	//  128 = don't decolorize message before matching
	//  256 = message is a tuba note sequence (pitch.duration pitch.duration ...)
	//  512 = tuba notes must be exact right pitch, no transposing
	// message: either
	//   *pattern*
	// or
	//   *pattern
	// or
	//   pattern*
	// or
	//   pattern
	// netname:
	//   if set, replacement for the matched text
	// radius:
	//   "hearing distance"
	// target:
	//   what to trigger
	// movedir:
	//   for spawnflags 256, defines 'instrument+1 mintempo maxtempo' (zero component doesn't matter)

	self.movedir_x -= 1; // map to tuba instrument numbers
}

void relay_activators_use()
{
	entity trg, os;
	
	os = self;
	
	for(trg = world; (trg = find(trg, targetname, os.target)); )
	{
		self = trg;
		if (trg.setactive)
			trg.setactive(os.cnt);
		else
		{
			//bprint("Not using setactive\n");
			if(os.cnt == ACTIVE_TOGGLE)
				if(trg.active == ACTIVE_ACTIVE)
					trg.active = ACTIVE_NOT;
				else	
					trg.active = ACTIVE_ACTIVE;
			else
				trg.active = os.cnt;
		}		
	}
	self = os;
}

void spawnfunc_relay_activate()
{
	self.cnt = ACTIVE_ACTIVE;
	self.use = relay_activators_use;
}

void spawnfunc_relay_deactivate()
{
	self.cnt = ACTIVE_NOT;
	self.use = relay_activators_use;	
}

void spawnfunc_relay_activatetoggle()
{
	self.cnt = ACTIVE_TOGGLE;
	self.use = relay_activators_use;	
}

.string chmap, gametype;
void spawnfunc_target_changelevel_use()
{
	if(self.gametype != "")
		MapInfo_SwitchGameType(MapInfo_Type_FromString(self.gametype));

	if (self.chmap == "")
		localcmd("endmatch\n");
	else
		localcmd(strcat("changelevel ", self.chmap, "\n"));
}

void spawnfunc_target_changelevel()
{
	self.use = spawnfunc_target_changelevel_use;
}
