/*
TODO:
- add an unlock sound (here to trigger_keylock and to func_door)
- display available keys on the HUD
- make more tests
- think about adding NOT_EASY/NOT_NORMAL/NOT_HARD for Q1 compatibility
- should keys have a trigger?
*/

float item_keys_usekey(entity l, entity p) {
	float valid = l.itemkeys & p.itemkeys;
	
	if not(valid) {
		// other has none of the needed keys
		return FALSE;
	} else if (l.itemkeys == valid) {
		// ALL needed keys were given
		l.itemkeys = 0;
		return TRUE;
	} else {
		// only some of the needed keys were given
		l.itemkeys &= ~valid;
		return TRUE;
	}
}

string item_keys_keylist(float keylist) {
	float base, l;
	string n;
	
	// no keys
	if not(keylist)
		return "";
	
	// one key
	if ((keylist & (keylist-1)) != 0)
		return strcat("the ", item_keys_names[lowestbit(keylist)]);
	
	n = "";
	base = 0;
	while (keylist) {
		l = lowestbit(keylist);
		if (n)
			n = strcat(n, ", the ", item_keys_names[base + l]);
		else
			n = strcat("the ", item_keys_names[base + l]);
		
		keylist = bitshift(keylist,  -(l + 1));
		base+= l + 1;
	}
	
	return n;
}


/*
================================
item_key
================================
*/

/**
 * Key touch handler.
 */
void item_key_touch(void) {
	if not(IS_PLAYER(other))
		return;
		
	// player already picked up this key
	if (other.itemkeys & self.itemkeys)
		return;
	
	other.itemkeys |= self.itemkeys;
	play2(other, self.noise);
	
	centerprint(other, self.message);
};

/**
 * Spawn a key with given model, key code and color.
 */
void spawn_item_key() {
	precache_model(self.model);
	
	if (self.spawnflags & 1) // FLOATING
		self.noalign = 1;
	
	if (self.noalign)
		self.movetype = MOVETYPE_NONE;
	else
		self.movetype = MOVETYPE_TOSS;
		
	precache_sound(self.noise);
		
	self.mdl = self.model;
	self.effects = EF_LOWPRECISION;
	setmodel(self, self.model);
	//setsize(self, '-16 -16 -24', '16 16 32');
	setorigin(self, self.origin + '0 0 32');
	setsize(self, '-16 -16 -56', '16 16 0');
	self.modelflags |= MF_ROTATE;
	self.solid = SOLID_TRIGGER;
	
	if (!self.noalign)
	{
		// first nudge it off the floor a little bit to avoid math errors
		setorigin(self, self.origin + '0 0 1');
		// note droptofloor returns FALSE if stuck/or would fall too far
		droptofloor();
	}

	self.touch = item_key_touch;
};


/*QUAKED item_key (0 .5 .8) (-16 -16 -24) (16 16 32) FLOATING
A key entity.
The itemkeys should contain one of the following key IDs:
1 - GOLD key - 
2 - SILVER key
4 - BRONZE key
8 - RED keycard
16 - BLUE keycard
32 - GREEN keycard
Custom keys:
... - last key is 1<<23
Keys with bigger Id than 32 don't have a default netname and model, if you use one of them, you MUST provide those.
-----------KEYS------------
colormod: color of the key (default: '.9 .9 .9').
itemkeys: a key Id.
message: message to print when player picks up this key.
model: custom key model to use.
netname: the display name of the key.
noise: custom sound to play when player picks up the key.
-------- SPAWNFLAGS --------
FLOATING: the item will float in air, instead of aligning to the floor by falling
---------NOTES----------
This is the only correct way to put keys on the map!

itemkeys MUST always have exactly one bit set.
*/
void spawnfunc_item_key() {
	local string _model, _netname;
	local vector _colormod;
	
	// reject this entity if more than one key was set!
	if (self.itemkeys>0 && (self.itemkeys & (self.itemkeys-1)) != 0) {
		objerror("item_key.itemkeys must contain only 1 bit set specifying the key it represents!");
		remove(self);
		return;
	}

	// find default netname and colormod
	switch(self.itemkeys) {
	case 1:
		_netname = "GOLD key";
		_colormod = '1 .9 0';
		break;
		
	case 2:
		_netname = "SILVER key";
		_colormod = '.9 .9 .9';
		break;
		
	case 4:
		_netname = "BRONZE key";
		_colormod = '.6 .25 0';
		break;
		
	case 8:
		_netname = "RED keycard";
		_colormod = '.9 0 0';
		break;
		
	case 16:
		_netname = "BLUE keycard";
		_colormod = '0 0 .9';
		break;
		
	case 32:
		_netname = "GREEN keycard";
		_colormod = '0 .9 0';
		break;
	
	default:
		_netname = "FLUFFY PINK keycard";
		_colormod = '1 1 1';

		if (self.netname == "") {
			objerror("item_key doesn't have a default name for this key and a custom one was not specified!");
			remove(self);
			return;
		}
		break;
		
	}
	
	// find default model
#ifdef GMQCC
	_model = string_null;
#endif
	if (self.itemkeys <= ITEM_KEY_BIT(2)) {
		_model = "models/keys/key.md3";
	} else if (self.itemkeys >= ITEM_KEY_BIT(3) && self.itemkeys <= ITEM_KEY_BIT(5)) {
		_model = "models/keys/key.md3"; // FIXME: replace it by a keycard model!
	} else if (self.model == "") {
		objerror("item_key doesn't have a default model for this key and a custom one was not specified!");
		remove(self);
		return;
	}
	
	// set defailt netname
	if (self.netname == "")
		self.netname = _netname;
	
	// set default colormod
	if (!self.colormod)
		self.colormod = _colormod;
	
	// set default model
	if (self.model == "")
		self.model = _model;
	
	// set default pickup message
	if (self.message == "")
		self.message = strzone(strcat("You've picked up the ", self.netname, "!"));

	if (self.noise == "")
		self.noise = "misc/itempickup.wav";
	
	// save the name for later
	item_keys_names[lowestbit(self.itemkeys)] = self.netname;

	// put the key on the map	
	spawn_item_key();
}

/*QUAKED item_key1 (0 .5 .8) (-16 -16 -24) (16 16 32) FLOATING
SILVER key.
-----------KEYS------------
colormod: color of the key (default: '.9 .9 .9').
message: message to print when player picks up this key.
model: custom model to use.
noise: custom sound to play when player picks up the key.
-------- SPAWNFLAGS --------
FLOATING: the item will float in air, instead of aligning to the floor by falling
---------NOTES----------
Don't use this entity on new maps! Use item_key instead.
*/
void spawnfunc_item_key1(void) {
	self.classname = "item_key";
	self.itemkeys = ITEM_KEY_BIT(1);
	spawnfunc_item_key();
};

/*QUAKED item_key2 (0 .5 .8) (-16 -16 -24) (16 16 32) FLOATING
GOLD key.
-----------KEYS------------
colormod: color of the key (default: '1 .9 0').
message: message to print when player picks up this key.
model: custom model to use.
noise: custom sound to play when player picks up the key.
-------- SPAWNFLAGS --------
FLOATING: the item will float in air, instead of aligning to the floor by falling
---------NOTES----------
Don't use this entity on new maps! Use item_key instead.
*/
void spawnfunc_item_key2(void) {
	self.classname = "item_key";
	self.itemkeys = ITEM_KEY_BIT(0);
	spawnfunc_item_key();
};


/*
================================
trigger_keylock
================================
*/

/**
 * trigger givent targets
 */
void trigger_keylock_trigger(string s) {
	local entity t, stemp, otemp, atemp;
	
	stemp = self;
	otemp = other;
	atemp = activator;
	
	
	for(t = world; (t = find(t, targetname, s)); )
		if (t.use) {
			self = t;
			other = stemp;
			activator = atemp;
			self.use();
		}
	
	self = stemp;
	other = otemp;
	activator = atemp;
};

/**
 * kill killtarget of trigger keylock.
 */
void trigger_keylock_kill(string s) {
	local entity t;
	for(t = world; (t = find(t, targetname, s)); )
		remove(t);
};

void trigger_keylock_touch(void) {
	local float key_used, started_delay;
	
	key_used = FALSE;
	started_delay = FALSE;
	
	// only player may trigger the lock
	if not(IS_PLAYER(other))
		return;
	
	
	// check silver key
	if (self.itemkeys)
		key_used = item_keys_usekey(self, other);
	
	activator = other;
	
	if (self.itemkeys) {
		// at least one of the keys is missing
		if (key_used) {
			// one or more keys were given, but others are still missing!
			play2(other, self.noise1);
			centerprint(other, strcat("You also need ", item_keys_keylist(self.itemkeys), "!"));
			other.key_door_messagetime = time + 2;
		} else if (other.key_door_messagetime <= time) {
			// no keys were given
			play2(other, self.noise2);
			centerprint(other, strcat("You need ", item_keys_keylist(self.itemkeys), "!"));
			other.key_door_messagetime = time + 2;
		}
		
		// trigger target2
		if (self.delay <= time || started_delay == TRUE)
		if (self.target2) {
			trigger_keylock_trigger(self.target2);
			started_delay = TRUE;
			self.delay = time + self.wait;
		}
	} else {
		// all keys were given!
		play2(other, self.noise);
		centerprint(other, self.message);
		
		if (self.target)
			trigger_keylock_trigger(self.target);
			
		if (self.killtarget)
			trigger_keylock_kill(self.killtarget);
		
		remove(self);
	}
	
};

/*QUAKED trigger_keylock (.0 .5 .8) ?
Keylock trigger.  Must target other entities.
This trigger will trigger target entities when all required keys are provided.
-------- KEYS --------
itemkeys: A bit field with key IDs that are needed to open this lock.
sounds: 1 to play misc/secret.wav, 2 to play misc/talk.wav, 3 to play misc/trigger1.wav (3 is default)
target: trigger all entities with this targetname when triggered and all keys have been given to it, then remove this trigger
target2: trigger all entities with this targetname when triggered without giving it all the required keys.
killtarget: remove all entities with this targetname when triggered with all the needed keys.
message: print this message to the player who activated the trigger when all needed keys have been given.
message2: print this message to the player who activated the trigger when not all of the needed keys have been given.
noise: sound to play when lock gets unlocked (default: see sounds)
noise1: sound to play when only some of the needed key were used but not all (default: misc/decreasevalue.wav)
noise2: sound to play when a key is missing (default: misc/talk.wav)
wait: prevent triggering again for this amount of time (default: 5) - applies to target2, target3, target4.
---------NOTES----------
If spawned without any key specified in itemkeys, this trigger will display an error and remove itself.
message2 and noise2 will be resent to the player every 2 seconds while he is in the trigger zone.
*/
void spawnfunc_trigger_keylock(void) {
	if (!self.itemkeys) {
		remove(self);
		return;
	}

	// set unlocked message	
	if (self.message == "")
		self.message = "Unlocked!";
	
	// set default unlock noise
	if (self.noise == "") {
		if (self.sounds == 1)
			self.noise = "misc/secret.wav";
		else if (self.sounds == 2)
			self.noise = "misc/talk.wav";
		else //if (self.sounds == 3) {
			self.noise = "misc/trigger1.wav";
	}
	
	// set default use key sound
	if (self.noise1 == "")
		self.noise1 = "misc/decreasevalue.wav";
	
	// set closed sourd
	if (self.noise2 == "")
		self.noise2 = "misc/talk.wav";
	
	// delay between triggering message2 and trigger2
	if (!self.wait)
		self.wait = 5;
	
	// precache sounds
	precache_sound(self.noise);
	precache_sound(self.noise1);
	precache_sound(self.noise2);
	
	EXACTTRIGGER_INIT;
	
	self.touch = trigger_keylock_touch;
};


