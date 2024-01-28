#ifdef SVQC

//Yoder Sept24 Horde Merge
void horde_key_spend(int key_item);

/*

Doors are similar to buttons, but can spawn a fat trigger field around them
to open without a touch, and they link together to form simultanious
double/quad doors.
 
Door.owner is the master door.  If there is only one door, it points to itself.
If multiple doors, all will point to a single one.

Door.enemy chains from the master door through all doors linked in the chain.

*/

/*
=============================================================================

THINK FUNCTIONS

=============================================================================
*/

void door_blocked(entity this, entity blocker)
{
	T_Damage(blocker, this, this, ((IS_MONSTER(blocker)) ? 1000 : this.dmg), DEATH_CRUSH.m_id);

	if((!this.model || this.model == ""))
		return;

	if((this.spawnflags & DOOR_CRUSHER))
		return;
	
// if a door has a negative wait, it would never come back if blocked,
// so let it just squash the object to death real fast
	if(this.wait >= 0)
	{
		if(this.state == STATE_DOWN)
			door_go_up(this);
		else
			door_go_down(this);
	}
}


void door_hit_top(entity this)
{
	_sound(this, CH_TRIGGER_SINGLE, this.noise1, 1, ATTN_NORM);
	this.state = STATE_TOP;
	SUB_UseTargets_CopperAlt(this, NULL, NULL, BIT(1) | BIT(3) | BIT(4));
	if(this.spawnflags & DOOR_TOGGLE)
		return;		// don't come down automatically
	setthink(this, door_go_down);
	this.nextthink = this.ltime + this.wait;
}

void door_hit_bottom(entity this)
{
	_sound(this, CH_TRIGGER_SINGLE, this.noise1, 1, ATTN_NORM);
	this.state = STATE_BOTTOM;

	SUB_UseTargets_CopperAlt(this, NULL, NULL, BIT(1) | BIT(2) | BIT(3));
}

void door_go_down(entity this)
{
	_sound(this, CH_TRIGGER_SINGLE, this.noise2, 1, ATTN_NORM);
	if(this.max_health)
	{
		this.takedamage = DAMAGE_YES;
		this.health = this.max_health;
	}
	
	this.state = STATE_DOWN;
	if(this.speed2)
		SUB_CalcMoveLight(this, this.pos2, this.pos1, this.speed2, door_hit_bottom, true);
	else
		SUB_CalcMoveLight(this, this.pos2, this.pos1, this.speed, door_hit_bottom, true);

	SUB_UseTargets_CopperAlt(this, NULL, NULL, BIT(1) | BIT(2) | BIT(4));
}

void door_go_up(entity this)
{
	if(this.state == STATE_UP)
		return;		// allready going up

	if(this.state == STATE_TOP)
	{	// reset top wait time
		if(this.spawnflags & DOOR_TOGGLE)
			return; // don't come down automatically
		this.nextthink = this.ltime + this.wait;
		return;
	}
	
	_sound(this, CH_TRIGGER_SINGLE, this.noise2, 1, ATTN_NORM);
	this.state = STATE_UP;
	SUB_CalcMoveLight(this, this.pos1, this.pos2, this.speed, door_hit_top, false);

	if(!SUB_UseTargets_CopperAlt(this, NULL, NULL, BIT(2) | BIT(3) | BIT(4)))
		SUB_UseTargetsSilent(this, NULL, NULL);
}


/*
=============================================================================

ACTIVATION FUNCTIONS

=============================================================================
*/

void door_fire(entity this)
{
	entity e = this;
	if(this.owner != this)
		objerror(this, "door_fire: this.owner != this");

// play use key sound

	if(this.items)
		_sound(this, CH_TRIGGER_SINGLE, this.noise4, 1, ATTN_NORM);

	this.message = "";		// no more message

	if(this.spawnflags & DOOR_TOGGLE)
	{
		if (this.state == STATE_UP || this.state == STATE_TOP)
		{
			do {
				door_go_down(e);
				e = e.enemy;
			} while(e != this && e != NULL);
			return;
		}
	}
	
// trigger all paired doors
	do {
		door_go_up(e);
		e = e.enemy;
	} while(e != this && e != NULL);
}


void door_use(entity this, entity actor, entity trigger)
{
	if(this.customflags & CFL_LOCKED)
		return;
	if(!(this.spawnflags & DOOR_TOGGLE))
	{
		this.message = ""; // door message are for touch only
		this.owner.message = "";	
		this.enemy.message = "";
	}
	door_fire(this.owner);
}


void door_trigger_touch(entity this, entity toucher)
{
	if(toucher.health <= 0)
		return;

	if(time < this.attack_finished)
		return;
	this.attack_finished = time + 1;

	door_use(this.owner, toucher, NULL);
}


void door_killed(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.health = this.max_health;
	this.takedamage = DAMAGE_NO;	// will be reset upon return
	door_use(this, attacker, NULL);
}

void door_lock_do(entity d)
{
	//dprint("door_lock_do\n");
	if(d.customflags & CFL_LOCKED)
		return;
	d.customflags |= CFL_LOCKED;

	// close any open doors immediately
	if(d.state != STATE_BOTTOM && !((d.spawnflags & DOOR_TOGGLE) || d.wait == -1))
	{
		entity e = d;
		do
		{
			door_go_down(e);
			e = e.enemy;
		}
		while(e != d && e != world );
	}
	
	if(d.max_health)
	{
		d.takedamage = DAMAGE_NO;
	}
	else
	{
		/*if (d.owner.trigger_field == world && !d.owner.items && !(d.spawnflags & DOOR_TOGGLE))
			objerror("door being locked doesn't have a trigger");
		else*/ if(d.owner.trigger_field)
			settouch(d.owner.trigger_field, func_null);
	}
}

void door_unlock_do(entity d)
{
	//dprint("door_unlock_do\n");
	if(!(d.customflags & CFL_LOCKED))
		return;

	d.customflags &= ~CFL_LOCKED;
	
	if(d.max_health)
	{
		d.takedamage = DAMAGE_YES;
		d.health = d.max_health;
	}
	else
	{
		/*if (d.owner.trigger_field == world && !d.owner.items && !(d.spawnflags & DOOR_TOGGLE))
			objerror("door being unlocked doesn't have a trigger");
		else*/ if(d.owner.trigger_field)
			settouch(d.owner.trigger_field, door_trigger_touch);
	}
}

void door_lock(entity this, bool unlock)
{
	//dprint("door_lock\n");
	if(unlock)
		door_unlock_do(this);
	else
		door_lock_do(this);
	// inner loop checks for doors that are linked by touch and not targetname
	entity c = this.enemy;
	do
	{
		if(c.targetname != this.targetname)	// outer loop will find this one
		{
			if(unlock)
				door_unlock_do(c);
			else
				door_lock_do(c);
		}
		c = c.enemy;
	}
	while(c != this);
}


/*
================
door_touch

Prints messages and opens key doors
================
*/
void door_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(this.owner.attack_finished > time)
		return;

	this.owner.attack_finished = time + 2;

	if(this.owner.message && this.owner.message != "" && this.owner.state == STATE_BOTTOM && !(this.owner.items))
	{
		centerprint(toucher, this.owner.message);
		_sound(toucher, CH_TRIGGER_SINGLE, QUAKE_TALKSOUND, 1, ATTN_NORM);
	}
	
// key door stuff
	if(!this.owner.items)
		return;

// FIXME: blink key on player's status bar
	if(((this.owner.items & toucher.items) != this.items) || (this.owner.customflags & CFL_LOCKED))
	{
		if(this.owner.items == IT_KEY1)
		{
			if(this.worldtype == WORLDTYPE_BASE)
			{
				centerprint(toucher, "You need the silver keycard");
				_sound(this, CH_TRIGGER_SINGLE, this.noise3, 1, ATTN_NORM);
			}
			else if(this.worldtype == WORLDTYPE_METAL)
			{
				centerprint(toucher, "You need the silver runekey");
				_sound(this, CH_TRIGGER_SINGLE, this.noise3, 1, ATTN_NORM);
			}
			else if(this.worldtype == WORLDTYPE_MEDIEVAL || this.worldtype == WORLDTYPE_HUB)
			{
				centerprint(toucher, "You need the silver key");
				_sound(this, CH_TRIGGER_SINGLE, this.noise3, 1, ATTN_NORM);
			}
		}
		else if(this.owner.items == IT_KEY2)
		{
			if(this.worldtype == WORLDTYPE_BASE)
			{
				centerprint(toucher, "You need the gold keycard");
				_sound(this, CH_TRIGGER_SINGLE, this.noise3, 1, ATTN_NORM);
			}
			else if(this.worldtype == WORLDTYPE_METAL)
			{
				centerprint(toucher, "You need the gold runekey");
				_sound(this, CH_TRIGGER_SINGLE, this.noise3, 1, ATTN_NORM);			
			}
			else if(this.worldtype == WORLDTYPE_MEDIEVAL || this.worldtype == WORLDTYPE_HUB)
			{
				centerprint(toucher, "You need the gold key");
				_sound(this, CH_TRIGGER_SINGLE, this.noise3, 1, ATTN_NORM);
			}
		}
		return;
	}

	// Yoder sept24, 2021, horde merge
	if(horde_ent || autocvar_sv_quake_globalkeys)
		horde_key_spend(this.owner.items);
	else // standard behaviour
		toucher.items &= ~this.owner.items;
	settouch(this, func_null);
	if(this.enemy)
		settouch(this.enemy, func_null); // get paired door
	door_use(this, NULL, toucher);
}

/*
=============================================================================

SPAWNING FUNCTIONS

=============================================================================
*/


/*
=============
LinkDoors


=============
*/
#if 0
entity(vector fmins, vector fmaxs) door_spawn_field =
{
	local entity	trigger;
	local	vector	t1, t2;
	//dprint("spawning door field\n");
	trigger = spawn();
	trigger.movetype = MOVETYPE_NONE;
	trigger.solid = SOLID_TRIGGER;
	trigger.owner = self;
	trigger.touch = door_trigger_touch;

	t1 = fmins;
	t2 = fmaxs;
	setsize (trigger, t1 - '60 60 8', t2 + '60 60 8');
	return (trigger);
}

void(vector cmins, vector cmaxs) door_finalize =
{
	entity t;
	// switch positions after linking so START_OPEN doors link properly
	t = self;
	do {
		// DOOR_START_OPEN is to allow an entity to be lighted in the closed position
		// but spawn in the open position
		if (t.spawnflags & DOOR_START_OPEN)
		{
			setorigin (t, t.pos2);
			t.pos2 = t.pos1;
			t.pos1 = t.origin;
		}
		t = t.enemy;
	} while (t != self);
			
	if (self.items)
	{
		door_key_init();
		return;
	}

	if (self.style < 0)
	{
		self.style *= -1;
		self.customflags |= CFL_INVLIGHT;
	}
	if (self.spawnflags & DOOR_START_OPEN)
	{
		if (self.customflags & CFL_INVLIGHT)
			self.customflags -= CFL_INVLIGHT;
		else
			self.customflags |= CFL_INVLIGHT;
	}
	
	bmodel_lightstyle(self, 1);

	if (self.health)
		return;
	if (self.targetname != string_null)
		if (!door_getslocked(self) || self.spawnflags & DOOR_TOGGLE)
			return;
	
	self.trigger_field = door_spawn_field(cmins, cmaxs);
	
	if (self.customflags & CFL_LOCKED)
		door_lock(FALSE);
}

float(entity door, entity master) door_can_link =
{
	if (door == master) return TRUE;	// first door
	if (door.enemy) return FALSE;	// already linked
	if (door.spawnflags & DOOR_DONT_LINK) return FALSE;	// will finalize itself later

	if (door.targetname != string_null && master.targetname != string_null && master.targetname != door.targetname)
		return FALSE;	// part of different systems, might only touch coincidentally
	
	if (door.items && master.items && !(master.items & door.items))
		return FALSE;	// different items requirements
	
	return TRUE;
}

/*
=============
door_link
=============
*/
void door_link(entity this)
{
	entity	t, masterdoor;
	vector	cmins, cmaxs;

	if (self.enemy)
		return;		// already linked by another door
	if (self.spawnflags & DOOR_DONT_LINK)
	{
		self.owner = self.enemy = self;
		door_finalize(self.mins, self.maxs);
		return;		// don't want to link this door
	}

	cmins = self.mins;
	cmaxs = self.maxs;
	
	masterdoor = self;
	t = self;
	
	do
	{
		self.owner = masterdoor;
		
		if (self != masterdoor)
		{
			if ((self.targetname != string_null && masterdoor.targetname == string_null) ||
				self.targetname == masterdoor.targetname)
			{
				// all the doors in the chain having the same targetname will cause
				// the whole chain to be triggered once for every door in the chain
				masterdoor.targetname = self.targetname;
				self.targetname = string_null;
			}
			masterdoor.items |= self.items;
			if (self.health != 0 && masterdoor.health == 0)
				masterdoor.health = self.health;

			SUB_MergeTargets(masterdoor);
			self.target = string_null;
			self.target2 = string_null;
			self.target3 = string_null;
			self.target4 = string_null;
			self.killtarget = string_null;
			if (self.message != string_null && masterdoor.message == string_null)
				masterdoor.message = self.message;
		}

		// skip doors with other targetnames to not fold them into the loop
		do {
			t = find (t, classname, self.classname);	
		} while (t && (!door_can_link(t,masterdoor) || !EntitiesTouching(self,t)));
		
		if (!t)
		{
			self.enemy = masterdoor;		// make the chain a loop
			self = self.owner;

			door_finalize(cmins, cmaxs);
			
			return;
		}

		self.enemy = t;
		self = t;

		cmins_x = min(t.mins_x, cmins_x);
		cmins_y = min(t.mins_y, cmins_y);
		cmins_z = min(t.mins_z, cmins_z);
		cmaxs_x = max(t.maxs_x, cmaxs_x);
		cmaxs_y = max(t.maxs_y, cmaxs_y);
		cmaxs_z = max(t.maxs_z, cmaxs_z);
	} while (t);
}

void LinkDoors(entity this)
{
	door_link(this);
}
#else
#if 1
entity spawn_field(entity this, vector fmins, vector fmaxs)
{
	entity trigger = spawn();
	set_movetype(trigger, MOVETYPE_NONE);
	trigger.solid = SOLID_TRIGGER;
	trigger.owner = this;
	trigger.worldtype = this.worldtype;
	settouch(trigger, door_trigger_touch);

	vector t1 = fmins;
	vector t2 = fmaxs;
	setsize(trigger, t1 - '60 60 8', t2 + '60 60 8');
	return(trigger);
}

void door_finalize(entity this)
{
	if(this.style < 0)
	{
		this.style *= -1;
		this.customflags |= CFL_INVLIGHT;
	}
	if(this.spawnflags & DOOR_START_OPEN)
	{
		if(this.customflags & CFL_INVLIGHT)
			this.customflags &= ~CFL_INVLIGHT;
		else
			this.customflags |= CFL_INVLIGHT;
	}

	bmodel_lightstyle(this, 1);

	if(this.customflags & CFL_LOCKED)
		door_lock(this, false);
}

void LinkDoors(entity this)
{
	if(this.enemy)
		return;		// already linked by another door
	if(this.spawnflags & DOOR_DONT_LINK)
	{
		this.owner = this.enemy = this;
		door_finalize(this);
		return;		// don't want to link this door
	}

	vector cmins = this.mins;
	vector cmaxs = this.maxs;
	
	entity starte = this;
	entity t = this;

	entity e = this;
	
	do
	{
		e.owner = starte;			// master door

		if(e.health)
			starte.health = e.health;
		if(e.targetname && e.targetname != "")
			starte.targetname = e.targetname;
		if(e.message != "")
			starte.message = e.message;

		t = find(t, classname, e.classname);	
		if(!t)
		{
			e.enemy = starte;		// make the chain a loop
			door_finalize(e.owner); // TODO: unsure if this is the correct entity, cursed copper mess!
		// shootable, fired, or key doors just needed the owner/enemy links,
		// they don't spawn a field
	
			if(e.owner.health)
				return;
			if(e.owner.targetname && e.owner.targetname != "")
				return;
			if(e.owner.items)
				return;

			e.owner.owner.trigger_field = spawn_field(e.owner, cmins, cmaxs);

			return;
		}

		if(boxesoverlap(e.mins, e.maxs, t.mins, t.maxs))
		{
			if(t.enemy)
				objerror(this, "cross connected doors");
			
			e.enemy = t;
			e = t;

			if(t.mins_x < cmins.x)
				cmins.x = t.mins_x;
			if(t.mins_y < cmins.y)
				cmins.y = t.mins_y;
			if(t.mins_z < cmins.z)
				cmins.z = t.mins_z;
			if(t.maxs_x > cmaxs.x)
				cmaxs.x = t.maxs_x;
			if(t.maxs_y > cmaxs.y)
				cmaxs.y = t.maxs_y;
			if(t.maxs_z > cmaxs.z)
				cmaxs.z = t.maxs_z;
		}
	} while(1);

}
#else
void door_spawnfield(entity this, vector fmins, vector fmaxs)
{
	entity	trigger;
	vector	t1 = fmins, t2 = fmaxs;

	trigger = new(doortriggerfield);
	set_movetype(trigger, MOVETYPE_NONE);
	trigger.solid = SOLID_TRIGGER;
	trigger.owner = this;
	settouch(trigger, door_trigger_touch);

	setsize (trigger, t1 - '60 60 8', t2 + '60 60 8');
}

entity LinkDoors_nextent(entity cur, entity near, entity pass)
{
	while((cur = find(cur, classname, pass.classname)) && ((cur.spawnflags & 4) || cur.enemy))
	{
	}
	return cur;
}

bool LinkDoors_isconnected(entity e1, entity e2, entity pass)
{
	float DELTA = 4;
	if((e1.absmin_x > e2.absmax_x + DELTA)
	|| (e1.absmin_y > e2.absmax_y + DELTA)
	|| (e1.absmin_z > e2.absmax_z + DELTA)
	|| (e2.absmin_x > e1.absmax_x + DELTA)
	|| (e2.absmin_y > e1.absmax_y + DELTA)
	|| (e2.absmin_z > e1.absmax_z + DELTA)
	) { return false; }
	return true;
}

void LinkDoors(entity this)
{
	if (this.enemy)
		return;		// already linked by another door
	if (this.spawnflags & 4)
	{
		this.owner = this.enemy = this;

		if (this.health)
			return;
		if (this.targetname != "")
			return;
		if (this.items)
			return;

		door_spawnfield(this, this.absmin, this.absmax);

		return;		// don't want to link this door
	}

	FindConnectedComponent(this, enemy, LinkDoors_nextent, LinkDoors_isconnected, this);

	// set owner, and make a loop of the chain
	LOG_TRACE("LinkDoors: linking doors:");
	for(entity t = this; ; t = t.enemy)
	{
		LOG_TRACE(" ", etos(t));
		t.owner = this;
		if(t.enemy == NULL)
		{
			t.enemy = this;
			break;
		}
	}
	LOG_TRACE("");

	// collect health, targetname, message, size
	vector cmins = this.absmin;
	vector cmaxs = this.absmax;
	for(entity t = this; ; t = t.enemy)
	{
		if(t.health && !this.health)
			this.health = t.health;
		if((t.targetname != "") && (this.targetname == ""))
			this.targetname = t.targetname;
		if((t.message != "") && (this.message == ""))
			this.message = t.message;
		if (t.absmin_x < cmins_x)
			cmins_x = t.absmin_x;
		if (t.absmin_y < cmins_y)
			cmins_y = t.absmin_y;
		if (t.absmin_z < cmins_z)
			cmins_z = t.absmin_z;
		if (t.absmax_x > cmaxs_x)
			cmaxs_x = t.absmax_x;
		if (t.absmax_y > cmaxs_y)
			cmaxs_y = t.absmax_y;
		if (t.absmax_z > cmaxs_z)
			cmaxs_z = t.absmax_z;
		if(t.enemy == this)
			break;
	}

	// distribute health, targetname, message
	for(entity t = this; t; t = t.enemy)
	{
		t.health = this.health;
		t.targetname = this.targetname;
		t.message = this.message;
		if(t.enemy == this)
			break;
	}

	// shootable, or triggered doors just needed the owner/enemy links,
	// they don't spawn a field

	if (this.health)
		return;
	if (this.targetname != "")
		return;
	if (this.items)
		return;

	door_spawnfield(this, cmins, cmaxs);
}
#endif
#endif


/*QUAKED func_door(0 .5 .8) ? START_OPEN x DOOR_DONT_LINK GOLD_KEY SILVER_KEY TOGGLE
if two doors touch, they are assumed to be connected and operate as a unit.

TOGGLE causes the door to wait in both the start and end states for a trigger event.

START_OPEN causes the door to move to its destination when spawned, and operate in reverse.  It is used to temporarily or permanently close off an area when triggered(not usefull for touch or takedamage doors).

Key doors are allways wait -1.

"message"	is printed when the door is touched if it is a trigger door and it hasn't been fired yet
"angle"		determines the opening direction
"targetname" if set, no touch field will be spawned and a remote button or trigger field activates the door.
"health"	if set, door must be shot open
"speed"		movement speed(100 default)
"wait"		wait before returning(3 default, -1 = never return)
"lip"		lip remaining at end of move(8 default)
"dmg"		damage to inflict when blocked(2 default)
"sounds"
0)	no sound
1)	stone
2)	base
3)	stone chain
4)	screechy metal
*/

void func_door_init(entity this, entity actor, entity trigger);
spawnfunc(func_door)
{
	vector oldmovedir = this.movedir;
	SetMovedir(this);
	SUB_SetWorldtype(this);

	this.max_health = this.health;
	if (!InitMovingBrushTrigger(this))
		return;

	switch(this.sounds)
	{
		case 0: this.noise1 = "misc/null.wav"; this.noise2 = "misc/null.wav"; break;
		case 1: this.noise1 = "doors/drclos4.wav"; this.noise2 = "doors/doormv1.wav"; break;
		case 2: this.noise1 = "doors/hydro2.wav"; this.noise2 = "doors/hydro1.wav"; break;
		case 3: this.noise1 = "doors/stndr2.wav"; this.noise2 = "doors/stndr1.wav"; break;
		case 4: this.noise1 = "doors/ddoor2.wav"; this.noise2 = "doors/ddoor1.wav"; break;
	}

	switch(this.worldtype)
	{
		case WORLDTYPE_HUB:
		case WORLDTYPE_MEDIEVAL: this.noise3 = "doors/medtry.wav"; this.noise4 = "doors/meduse.wav"; break;
		case WORLDTYPE_METAL: this.noise3 = "doors/runetry.wav"; this.noise4 = "doors/runeuse.wav"; break;
		case WORLDTYPE_BASE: this.noise3 = "doors/basetry.wav"; this.noise4 = "doors/baseuse.wav"; break;
	}

	if(this.noise1 != "") precache_sound(this.noise1);
	if(this.noise2 != "") precache_sound(this.noise2);
	if(this.noise3 != "") precache_sound(this.noise3);
	if(this.noise4 != "") precache_sound(this.noise4);

	this.effects |= EF_LOWPRECISION;
	this.classname = "door";
	
	if(this.spawnflags & DOOR_SILVER_KEY)
		this.items = IT_KEY1;
	if(this.spawnflags & DOOR_GOLD_KEY)
		this.items = IT_KEY2;
	
	if(!this.speed)
		this.speed = 100;
	if(!this.wait)
		this.wait = 3;
	if(!this.lip)
		this.lip = 8;
	if(!this.dmg)
		this.dmg = 2;

	this.pos1 = this.origin;

	if(MP_ROGUE)
	{
		// fix cameron's door
		vector tmpvec = this.movedir;
		if(tmpvec.x < 0)
			tmpvec.x = 0 - tmpvec.x;
		if(tmpvec.y < 0)
			tmpvec.y = 0 - tmpvec.y;
		if(this.distance)
		{
			this.pos1 = this.origin;
			this.pos2 = this.pos1 + this.movedir * this.distance;
		}
		else
			this.pos2 = this.pos1 + this.movedir * (fabs(tmpvec * this.size) - this.lip);
	}
	else
	{
		if(this.distance)
		{
			this.pos1 = this.origin;
			this.pos2 = this.pos1 + this.movedir * this.distance;
		}
		else
			this.pos2 = this.pos1 + this.movedir*(fabs(this.movedir*this.size) - this.lip);
	}

	if(MP_MG && oldmovedir != '0 0 0')
	{
		this.pos2 = this.pos1 + oldmovedir;
		this.angles = '0 0 0';
	}

// DOOR_START_OPEN is to allow an entity to be lighted in the closed position
// but spawn in the open position
	if(this.spawnflags & DOOR_START_OPEN)
	{
		setorigin(this, this.pos2);
		this.pos2 = this.pos1;
		this.pos1 = this.origin;
	}

	this.state = STATE_BOTTOM;
	
	if(this.items)
		this.wait = -1;

	if(this.spawnflags & 128)
		this.use = func_door_init;
	else
		func_door_init(this, NULL, NULL);
}

void func_door_init(entity this, entity actor, entity trigger)
{
	settouch(this, door_touch);
	setblocked(this, door_blocked);
	this.use = door_use;
	this.lock = door_lock;

	if(this.health)
	{
		this.takedamage = DAMAGE_YES;
		this.th_die = door_killed;
	}

// LinkDoors can't be done until all of the doors have been spawned, so
// the sizes can be detected properly.
	setthink(this, LinkDoors);
	this.nextthink = time + 0.1;
}

#endif
