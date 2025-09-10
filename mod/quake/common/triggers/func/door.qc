#ifdef SVQC

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

	if((this.spawnflags & DOOR_CRUSHER) || (this.spawnflags & DOOR_CRUSHING))
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
	this.frame = this.skin;
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
	this.frame = !this.skin;

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

	if(!(this.spawnflags & DOOR_TOGGLE))
		this.message = ""; // no more message
	else
	{
		if(this.state == STATE_UP || this.state == STATE_TOP)
		{
			do {
				door_go_down(e);
				e = e.enemy;
			} while(e != this && e);
			return;
		}
	}
	
// trigger all paired doors
	if(!(this.spawnflags & DOOR_TOGGLE) || ((this.spawnflags & DOOR_TOGGLE) && this.state == STATE_BOTTOM))
	{
		do {
			door_go_up(e);
			e = e.enemy;
		} while(e != this && e);
	}
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
	this.takedamage = DAMAGE_NO;
	door_fire(this.owner);
}


void door_trigger_touch(entity this, entity toucher)
{
	if(toucher.draggedby)
		toucher = toucher.draggedby; // hehe
	if(toucher.health <= 0)
		return;
	if(toucher.move_movetype == MOVETYPE_NOCLIP)
		return;

	if(time < this.attack_finished)
		return;
	// silly fix for sleeping monsters standing behind doors inside their touch fields causing them to open
	if(IS_MONSTER(toucher) && !toucher.enemy && !toucher.goalentity)
		return;
	this.attack_finished = time + 1;

	door_use(this.owner, toucher, NULL);
}


void door_killed(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.owner.health = this.owner.max_health;
	this.owner.takedamage = DAMAGE_NO;	// will be reset upon return
	door_use(this.owner, attacker, NULL);
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
		/*if(d.owner.trigger_field == world && !d.owner.items && !(d.spawnflags & DOOR_TOGGLE))
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
		/*if(d.owner.trigger_field == world && !d.owner.items && !(d.spawnflags & DOOR_TOGGLE))
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
	if(toucher.draggedby)
		toucher = toucher.draggedby; // hehe
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
		else if(this.owner.items == IT_KEY3)
		{
			if(this.worldtype == WORLDTYPE_BASE)
			{
				centerprint(toucher, "You need the platinum keycard");
				_sound(this, CH_TRIGGER_SINGLE, this.noise3, 1, ATTN_NORM);
			}
			else if(this.worldtype == WORLDTYPE_METAL)
			{
				centerprint(toucher, "You need the platinum runekey");
				_sound(this, CH_TRIGGER_SINGLE, this.noise3, 1, ATTN_NORM);			
			}
			else if(this.worldtype == WORLDTYPE_MEDIEVAL || this.worldtype == WORLDTYPE_HUB)
			{
				centerprint(toucher, "You need the platinum key");
				_sound(this, CH_TRIGGER_SINGLE, this.noise3, 1, ATTN_NORM);
			}
		}
		return;
	}

	key_spend(toucher, this.owner.items);
	settouch(this.owner, func_null);
	entity t = this.owner.enemy;
	while(t != this.owner)// get paired doors
	{
		settouch(t, func_null);
		t = t.enemy;
	}
	door_use(this.owner, NULL, toucher);
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

entity door_spawn_field(entity this, vector fmins, vector fmaxs)
{
	//dprint("spawning door field\n");
	entity trigger = spawn();
	set_movetype(trigger, MOVETYPE_NONE);
	trigger.solid = SOLID_TRIGGER;
	trigger.owner = this;
	settouch(trigger, door_trigger_touch);

	vector t1 = fmins;
	vector t2 = fmaxs;
	setsize(trigger, t1 - '60 60 8', t2 + '60 60 8');
	return trigger;
}

void door_key_init(entity this)
{
	if(!this.message || this.message == "")
	{
		if(this.items & IT_KEY1)
		{
			if(world.worldtype == 2)
				this.message = "You need the Silver Keycard";
			else if(world.worldtype == 1)
				this.message = "You need the Silver Runekey";
			else if(world.worldtype == 0)
				this.message = "You need the Silver Key";
		}
		else if(this.items & IT_KEY2)
		{
			if(world.worldtype == 2)
				this.message = "You need the Gold Keycard";
			else if(world.worldtype == 1)
				this.message = "You need the Gold Runekey";			
			else if(world.worldtype == 0)
				this.message = "You need the Gold Key";
		}
	}
	if(this.items)
	{
		entity t = this;
		do {
			t.wait = -1;
			t = t.enemy;
		} while(t != this);
	}
}

// checks if a door ONLY has locks targeting it
bool door_getslocked(entity d)
{
	if(!d.targetname || d.targetname == "")
		return false;
	
	entity t;
	bool found = false;
	t = find(NULL, target, d.targetname);
	while(t)
	{
		found = true;
		if(t.classname != "target_lock")
			return false;
		t = find(t, target, d.targetname);
	}
	t = find(NULL, target2, d.targetname);
	while(t)
	{
		found = true;
		if(t.classname != "target_lock")
			return false;
		t = find(t, target2, d.targetname);
	}
	t = find(NULL, target3, d.targetname);
	while(t)
	{
		found = true;
		if(t.classname != "target_lock")
			return false;
		t = find(t, target3, d.targetname);
	}
	t = find(NULL, target4, d.targetname);
	while(t)
	{
		found = true;
		if(t.classname != "target_lock")
			return false;
		t = find(t, target4, d.targetname);
	}
	return found;	// no targeters has to be false
}

void door_finalize(entity this, vector cmins, vector cmaxs)
{
	// switch positions after linking so START_OPEN doors link properly
	entity t = this;
	do {
		// DOOR_START_OPEN is to allow an entity to be lighted in the closed position
		// but spawn in the open position
		if(t.spawnflags & DOOR_START_OPEN)
		{
			setorigin (t, t.pos2);
			t.pos2 = t.pos1;
			t.pos1 = t.origin;
		}
		t = t.enemy;
	} while (t != this);
			
	if(this.items)
	{
		door_key_init(this);
		return;
	}

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

	if(this.health)
		return;
	if(this.targetname && this.targetname != "")
		if(!door_getslocked(this) || (this.spawnflags & DOOR_TOGGLE))
			return;
	
	this.trigger_field = door_spawn_field(this, cmins, cmaxs);
	
	if(this.customflags & CFL_LOCKED)
		door_lock(this, false);
}

/*
=============
SUB_AddTarget
===============
*/
void SUB_AddTarget(entity to, string tname)
{
	if(!to)
		return;
	if(!to.target || to.target == "")
		to.target = tname;
	else if(!to.target2 || to.target2 == "")
		to.target2 = tname;
	else if(!to.target3 || to.target3 == "")
		to.target3 = tname;
	else if(!to.target4 || to.target4 == "")
		to.target4 = tname;
}

/*
=============
SUB_MergeTargets
===============
*/
void SUB_MergeTargets(entity this, entity to)
{
	// iw -- fixed copying target over all 4 targets and never copying killtarget
	if(!to)
		return;
	if(this.target && this.target != "")
		SUB_AddTarget(to, this.target);
	if(this.target2 && this.target2 != "")
		SUB_AddTarget(to, this.target2);
	if(this.target3 && this.target3 != "")
		SUB_AddTarget(to, this.target3);
	if(this.target4 && this.target4 != "")
		SUB_AddTarget(to, this.target4);
	if(this.killtarget && this.killtarget != "")
	{
		if(to.killtarget && to.killtarget != "")
			{ /* nope */ }
		else
			to.killtarget = this.killtarget;
	}		
}

bool door_can_link(entity door, entity master)
{
	if(door == master) return true;	// first door
	if(door.enemy) return false;	// already linked
	if(door.spawnflags & DOOR_DONT_LINK) return false;	// will finalize itself later

	if(door.targetname && door.targetname != "" && master.targetname && master.targetname != "" && master.targetname != door.targetname)
		return false;	// part of different systems, might only touch coincidentally
	
	if(door.items && master.items && !(master.items & door.items))
		return false;	// different items requirements
	
	return true;
}

void LinkDoors(entity this)
{
	if(this.enemy)
		return;		// already linked by another door
	qonquer_fixdoor(this);
	if(this.spawnflags & DOOR_DONT_LINK)
	{
		this.owner = this.enemy = this;
		door_finalize(this, this.mins, this.maxs);
		return;		// don't want to link this door
	}

	vector cmins = this.mins;
	vector cmaxs = this.maxs;
	
	entity masterdoor = this;
	entity t = this;
	
	do
	{
		this.owner = masterdoor;
		
		if(this != masterdoor)
		{
			if((this.targetname && this.targetname != "" && (!masterdoor.targetname || masterdoor.targetname == "")) ||
				this.targetname == masterdoor.targetname)
			{
				// all the doors in the chain having the same targetname will cause
				// the whole chain to be triggered once for every door in the chain
				masterdoor.targetname = this.targetname;
				this.targetname = string_null;
			}
			masterdoor.items |= this.items;
			if(this.health != 0 && masterdoor.health == 0)
				masterdoor.health = this.health;

			SUB_MergeTargets(this, masterdoor);
			this.target = string_null;
			this.target2 = string_null;
			this.target3 = string_null;
			this.target4 = string_null;
			this.killtarget = string_null;
			if(this.message && this.message != "" && (!masterdoor.message || masterdoor.message == ""))
				masterdoor.message = this.message;
		}

		// skip doors with other targetnames to not fold them into the loop
		do {
			t = find(t, classname, this.classname);	
		} while (t && (!door_can_link(t, masterdoor) || !boxesoverlap(this.absmin, this.absmax, t.absmin, t.absmax)));
		
		if(!t)
		{
			this.enemy = masterdoor;		// make the chain a loop
			this = this.owner;

			door_finalize(this, cmins, cmaxs);
			
			return;
		}

		this.enemy = t;
		this = t;

		cmins_x = min(t.mins_x, cmins_x);
		cmins_y = min(t.mins_y, cmins_y);
		cmins_z = min(t.mins_z, cmins_z);
		cmaxs_x = max(t.maxs_x, cmaxs_x);
		cmaxs_y = max(t.maxs_y, cmaxs_y);
		cmaxs_z = max(t.maxs_z, cmaxs_z);
	} while (t);
}

// for measuring how large an entity is along an arbitrary vector
// FIXME: this is trash and it returns trash
float BoundsAngleSize(vector v, vector s)
{
	v.x = fabs(v.x);
	v.y = fabs(v.y);
	v.z = fabs(v.z);
	
	// size is always + + + but this is in case I switch the parameters somewhere
	s.x = fabs(s.x);
	s.y = fabs(s.y);
	s.z = fabs(s.z);
	
	return v * s;
}

bool door_iscopper(entity this)
{
	return ((this.spawnflags & SPAWN_ALT_TARG) && (this.target2 != "" || this.target3 != "" || this.target4 != ""));
}

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
	if(this.movedir != '0 0 0')
		this.have_mg_movedir = true;
	SetMovedir(this);
	SUB_SetWorldtype(this);

	this.max_health = this.health;
	if(!InitMovingBrushTrigger(this))
		return;

	switch(this.sounds)
	{
		default:
		case 0: this.noise1 = "misc/null.wav"; this.noise2 = "misc/null.wav"; break;
		case 1: this.noise1 = "doors/drclos4.wav"; this.noise2 = "doors/doormv1.wav"; break;
		case 2: this.noise1 = "doors/hydro2.wav"; this.noise2 = "doors/hydro1.wav"; break;
		case 3: this.noise1 = "doors/stndr2.wav"; this.noise2 = "doors/stndr1.wav"; break;
		case 4: this.noise1 = "doors/ddoor2.wav"; this.noise2 = "doors/ddoor1.wav"; break;
		case 6: this.noise1 = "doors/q2door2.wav"; this.noise2 = "doors/q2door1.wav"; break;
		case 7: this.noise1 = "plats/plat2.wav"; this.noise2 = "plats/plat1.wav"; break;
		case 8: this.noise1 = "plats/medplat2.wav"; this.noise2 = "plats/medplat1.wav"; break;
	}

	switch(this.worldtype)
	{
		case WORLDTYPE_HUB:
		case WORLDTYPE_MEDIEVAL: this.noise3 = "doors/medtry.wav"; this.noise4 = "doors/meduse.wav"; break;
		case WORLDTYPE_METAL: this.noise3 = "doors/runetry.wav"; this.noise4 = "doors/runeuse.wav"; break;
		case WORLDTYPE_BASE: this.noise3 = "doors/basetry.wav"; this.noise4 = "doors/baseuse.wav"; break;
	}

	if(this.noise1 && this.noise1 != "") precache_sound(this.noise1);
	if(this.noise2 && this.noise2 != "") precache_sound(this.noise2);
	if(this.noise3 && this.noise3 != "") precache_sound(this.noise3);
	if(this.noise4 && this.noise4 != "") precache_sound(this.noise4);

	this.effects |= EF_LOWPRECISION;
	this.classname = "door";

	// NOTE: higher key level overrides previous key to avoid breaking aop2m2
	if(this.spawnflags & DOOR_SILVER_KEY)
		this.items = IT_KEY1;
	if(this.spawnflags & DOOR_GOLD_KEY)
		this.items = IT_KEY2;
	// still try to avoid overriding with platinum key where possible
	if((this.spawnflags & DOOR_PLAT_KEY) && !this.items && !door_iscopper(this))
		this.items = IT_KEY3;
	
	if(!this.speed)
		this.speed = 100;
	if(!this.wait)
		this.wait = 3;
	if(!this.lip)
		this.lip = 8;
	if(!this.dmg)
		this.dmg = 2;
	
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

	if(!this.distance)
		this.distance = (fabs(this.movedir * this.size) - this.lip);
	if(this.pos1 != '0 0 0' && this.pos2 != '0 0 0')
		setorigin(this, this.pos1);
	else
	{
		this.pos1 = this.origin;
		this.pos2 = this.pos1 + this.movedir * this.distance;
	}

	// mg hack
	if(this.have_mg_movedir)
	{
		this.pos1 = this.origin;
		this.pos2 = this.pos1 + this.movedir;
		this.angles = '0 0 0';
	}

	this.state = STATE_BOTTOM;

// LinkDoors can't be done until all of the doors have been spawned, so
// the sizes can be detected properly.
	setthink(this, LinkDoors);
	this.nextthink = this.ltime + 0.1;
}

#endif
