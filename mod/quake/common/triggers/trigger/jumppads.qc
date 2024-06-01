#ifdef SVQC

const int PUSH_ONCE = BIT(0);
const int PUSH_TOGL = BIT(1); // rogue, deprecated
const int PUSH_ACTIVE = BIT(2); // rogue
const int ADDITIVE_PUSH = BIT(1); // mg
const int PUSH_START_OFF = BIT(2); // mg

// copper
const int PUSH_ADD_VEL = 2; // copy of mg flag, see ADDITIVE_PUSH
const int PUSH_TUNNEL = 8;

void trigger_push_touch(entity this, entity toucher)
{
	if(toucher.move_movetype == MOVETYPE_NOCLIP)
		return;
	if(this.customflags & CFL_LOCKED)
		return;
	if(this.active != ACTIVE_ACTIVE)
		return;

	// yoder Sept 24 2021 horde merge
	
	if(horde_ent)
	{
		if(this.spawnflags & PUSH_START_OFF) // ignore this spawnflag in horde mode
			this.spawnflags &= ~PUSH_START_OFF;
		
		if(!IS_PLAYER(toucher))
		{
			if((toucher.classname == "item_artifact_invulnerability") || (toucher.classname == "item_artifact_super_damage"))
			{
				if((this.spawnflags & ADDITIVE_PUSH))
					toucher.velocity = toucher.velocity + (this.speed * this.movedir * 10 * frametime); 
				else
					toucher.velocity = this.speed * this.movedir * 10;
			}
			return;
		}
	}

	if(toucher.health > 0 || toucher.classname == "grenade" || toucher.classname == "ogre_grenade" || toucher.classname == "MiniGrenade" || toucher.classname == "MultiGrenade")
	{
		if(toucher.flags & FL_INSHELTER)
			return;
		if(this.spawnflags & ADDITIVE_PUSH) // yoder add, Jan 28 2021
		{
			if(time != this.dmgtime && time < this.attack_finished)
				return;
			if(this.speed2 > 0)
			{
				float overspeed = (toucher.velocity * this.movedir) - this.speed2;
				if(overspeed < 0)
					toucher.velocity += min(overspeed * -1, this.speed) * this.movedir;
			}
			else
				toucher.velocity += this.speed * this.movedir;

			this.dmgtime = time;
			this.attack_finished = time + 0.05;
		}
		else
			toucher.velocity = this.speed * this.movedir * 10;
		if(IS_PLAYER(toucher))
		{
			if(toucher.fly_sound < time)
			{
				toucher.fly_sound = time + 1.5;
				_sound(toucher, CH_TRIGGER, this.noise, 1, ATTN_NORM);
			}

			if(this.spawnflags & PUSH_TUNNEL)
			{
				vector suck = (this.origin + 0.5 * (this.mins + this.maxs)) - toucher.origin;
				suck -= this.movedir * (suck * this.movedir);
				toucher.velocity += suck * this.speed * 0.1;
			}
		}
		UNSET_ONGROUND(toucher);
	}
	if(this.spawnflags & PUSH_ONCE)
		delete(this);
}

void trigger_push_use(entity this, entity actor, entity trigger)
{
	if(this.active == ACTIVE_ACTIVE)
		this.active = ACTIVE_NOT;
	else
		this.active = ACTIVE_ACTIVE;
}

void trigger_push_find(entity this)
{
	entity n = find(NULL, targetname, this.target);
	if(!n)
		return;
	
	this.movedir = normalize(n.origin - (this.origin + 0.5 * (this.mins + this.maxs)));
}


/*QUAKED trigger_push(.5 .5 .5) ? PUSH_ONCE PUSH_TOGL PUSH_ACTIVE ADDITIVE_PUSH START_OFF
Pushes the player.

speed: velocity of push. (default 1000)
*/
spawnfunc(trigger_push)
{
	if(this.angles == '0 0 0')
		this.angles = '0 360 0';

	this.use = trigger_push_use;

	InitTrigger(this);
	if(!this.noise || this.noise == "")
		this.noise = "ambience/windfly.wav";
	precache_sound(this.noise);
	settouch(this, trigger_push_touch);
	if(!this.speed)
		this.speed = 1000;

	this.active = ACTIVE_ACTIVE;

	// we're on a rogue campaign map, disable toggle flag which overlaps with additive, toggling handled automatically
	if(IsRogueMap())
	{
		// jumppads with the toggle flag aren't active by default unless specified
		if(!(this.spawnflags & PUSH_ACTIVE) && (this.spawnflags & PUSH_TOGL))
			this.active = ACTIVE_NOT;
		this.spawnflags &= ~PUSH_TOGL;
		return; // avoid mg's handling in this case
	}

	if((this.spawnflags & PUSH_START_OFF))
		this.active = ACTIVE_NOT;

	if(this.target && this.target != "")
	{
		setthink(this, trigger_push_find);
		this.nextthink = time + 0.1;
	}
}

//============================================================================

const int SPAWN_MJUMP_NOLARGE = 1;
const int SPAWN_MJUMP_NOSMALL = 2;
const int SPAWN_MJUMP_MELEES = 8;
const int SPAWN_MJUMP_ONLYFRONT = 16;
const int SPAWN_MJUMP_ONLYBELOW = 32;
const int SPAWN_MJUMP_ADDVEL = 64;

.string include, exclude;

void trigger_monsterjump_touch(entity this, entity toucher)
{
	if(this.customflags & CFL_LOCKED)
		return;
	if(!IS_MONSTER(toucher))
		return;
	if((toucher.flags & FL_FLY) || (toucher.flags & FL_SWIM))
		return;
	if(toucher.health <= 0)
		return;

	if(time != this.dmgtime && time < this.attack_finished)
		return;

	// yoder add, July 10th 2020
	// making it so trigger_monsterjump's with spawnflag 8 only affect monsters with spawnflag 8
	if((this.spawnflags & 64))
	{
		if(!(toucher.spawnflags & 64))
		{
			LOG_DEBUG("monster didn't have spawnflag 8!");
			return;
		}
	}

	// filtration
	// always allow this class/tname
	if((!this.include || this.include == "") || (toucher.classname != this.include && toucher.targetname != this.include))
	{
		if((this.spawnflags & SPAWN_MJUMP_NOLARGE) && toucher.maxs_x >= 24)
			return;
		if((this.spawnflags & SPAWN_MJUMP_NOSMALL) && toucher.maxs_x < 24)
			return;
		//if((this.spawnflags & SPAWN_MJUMP_MELEES) && !(toucher.customflags & CFL_MELEEONLY))
			//return;
		
		if(this.exclude && this.exclude != "")
		{
			if(this.exclude == toucher.classname || this.exclude == toucher.targetname)
				return; // always exclude this class/tname
		}
	}
	if(this.spawnflags & SPAWN_MJUMP_ONLYBELOW)
	{
		if(!toucher.enemy)
			return;
		if(toucher.enemy.absmin_z > (toucher.absmin_z - 16))
			return;
	}
	if(this.spawnflags & SPAWN_MJUMP_ONLYFRONT)
	{
		if(!toucher.enemy)
			return;
		vector dir = toucher.enemy.origin - toucher.origin;
		dir_z = 0;
		dir = normalize(dir);
		if(dir * this.movedir < this.distance)
			return;
	}

	if(this.wait == -1)
	{
		settouch(this, func_null);
		setthink(this, SUB_Remove);
		this.nextthink = time;
	}
	else
	{
		this.dmgtime = time;
		this.attack_finished = time + this.wait;
	}

	// set XY even if not on ground, so the jump will clear lips
	if(this.spawnflags & SPAWN_MJUMP_ADDVEL)
	{
		toucher.velocity_x += this.movedir_x * this.speed;
		toucher.velocity_y += this.movedir_y * this.speed;
	}
	else
	{
		toucher.velocity_x = this.movedir_x * this.speed;
		toucher.velocity_y = this.movedir_y * this.speed;
	}

	if(!IS_ONGROUND(toucher))
	{
		if(this.spawnflags & SPAWN_MJUMP_ADDVEL)
			toucher.velocity_z += this.height;
		else
			return;
	}
	
	UNSET_ONGROUND(toucher);

	toucher.velocity_z = this.height;

	if(this.cnt > 0)
	{
		this.cnt -= 1;
		if(this.cnt == 0)
		{
			settouch(this, func_null);
			this.nextthink = time + 0.1;
			setthink(this, SUB_Remove);
		}
	}
}

/*QUAKED trigger_monsterjump(.5 .5 .5) ?
Walking monsters that touch this will jump in the direction of the trigger's angle
"speed" default to 200, the speed thrown forward
"height" default to 200, the speed thrown upwards
"cnt" default infinite, how many times to trigger
*/
spawnfunc(trigger_monsterjump)
{
	if(!this.speed)
		this.speed = 200;
	if(!this.height)
		this.height = 200;
	if(!this.distance)
		this.distance = 0.5;
	if(this.angles == '0 0 0')
		this.angles = '0 360 0';
	InitTrigger(this);
	settouch(this, trigger_monsterjump_touch);

	if(!this.cnt)
		this.cnt = -1;
}

/*QUAKED trigger_monsterjump_box (.5 .0 .5) (-8 -8 -8) (8 8 8) NO_LARGE NO_SMALL TRIGGER_FIRST ONLY_MELEES ONLY_FRONT ONLY_BELOW ADD_VEL
Monsters that touch this will 'jump' in the direction of the trigger's angle, if they meet its conditions.

Quoth2-style edict-saving bounding box trigger: define bounds size with 'size' - trigger volume will be centered on the trigger's origin.

Flags:
NO_LARGE only monsters with 32x32 bounds
NO_SMALL only monsters with 64x64 bounds
TRIGGER_FIRST won't be touchable until triggered once by something else
ONLY_MELEES only monsters with no ranged attack (dogs/fiends/spawns)
ONLY_FRONT will only trigger if monster's enemy is in front of the monster relative to jump angle
ONLY_BELOW will only trigger if monster's enemy is below the monster
ADD_VEL add velocity to monster rather than setting it

Keys:
"angle" angle towards the monster jumps
"height" the speed thrown upwards (default: 200)
"speed" the speed thrown forward (default: 200)
"target"  entity to trigger
"targetname"  entity name
"include" allow this classname of monster, or monsters with this targetname, no matter what
"exclude" exclude this classname of monster, or monsters with this targetname, no matter what
*/
/*FGD
@PointClass base(Monsterjump, Bounds) = trigger_monsterjump_box : "Trigger: Monster jump. Monsters that touch this will 'jump' in the direction of the trigger's angle, if they meet its conditions.

Use the 'Only if target in front'/'below' spawnflags to prevent monsters from being thrown off of ledges away from the player after the player has climbed up there. 

Use the 'no large monsters', 'no small monsters', and 'only melee monsters' spawnflags to fine-tune which monsters jump and which don't if necessary. If this isn't fine-grained enough, the 'include' and 'exclude' keys can be set to specific monster classnames, or targetnames, to exempt matching monsters from those rules. If that isn't fine-grained enough, consider two overlapping monsterjumps with different, more specific rules.

Quoth2-style edict-saving bounding box trigger: define bounds size with 'size' - trigger volume will be centered on the trigger's origin." []
*/
spawnfunc(trigger_monsterjump_box)
{
	this.speed = zeroconvertdefault(this.speed, 200);
	this.height = zeroconvertdefault(this.height, 200);
	if(!this.distance)
		this.distance = 0.5;
	if(this.angles == '0 0 0')
		this.angles = '0 360 0';
	settouch(this, trigger_monsterjump_touch);
	InitTriggerBounds(this);
	this.classname = "trigger_monsterjump";
}

/*QUAKED info_notnull(0 0.5 0)(-4 -4 -4)(4 4 4)
Used as a positional target for lightning.
*/
spawnfunc(info_notnull)
{
}

#endif
