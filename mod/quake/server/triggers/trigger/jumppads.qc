#ifdef SVQC

const int PUSH_ONCE = BIT(0);
const int PUSH_TOGL = BIT(1); // rogue, deprecated
const int PUSH_ACTIVE = BIT(2); // rogue
const int ADDITIVE_PUSH = BIT(1); // mg
const int PUSH_START_OFF = BIT(2); // mg

void trigger_push_touch(entity this, entity toucher)
{
	if(this.active != ACTIVE_ACTIVE)
		return;

	// yoder Sept 24 2021 horde merge
	
	if(horde_ent)
	{
		if(toucher.spawnflags & PUSH_START_OFF) // ignore this spawnflag in horde mode
			toucher.spawnflags &= ~PUSH_START_OFF;
		
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
		if((toucher.flags & FL_INSHELTER))
			return;
		if((this.spawnflags & ADDITIVE_PUSH)) // yoder add, Jan 28 2021
			toucher.velocity = toucher.velocity + this.speed * this.movedir * 10 * frametime;
		else
			toucher.velocity = this.speed * this.movedir * 10;
		if(IS_PLAYER(toucher))
		{
			if(toucher.fly_sound < time)
			{
				toucher.fly_sound = time + 1.5;
				_sound(toucher, CH_TRIGGER, "ambience/windfly.wav", 1, ATTN_NORM);
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


/*QUAKED trigger_push(.5 .5 .5) ? PUSH_ONCE PUSH_TOGL PUSH_ACTIVE ADDITIVE_PUSH START_OFF
Pushes the player.

speed: velocity of push. (default 1000)
*/
spawnfunc(trigger_push)
{
	this.use = trigger_push_use;

	InitTrigger(this);
	precache_sound("ambience/windfly.wav");
	settouch(this, trigger_push_touch);
	if(!this.speed)
		this.speed = 1000;

	this.active = ACTIVE_ACTIVE;

	// we're on a rogue campaign map, disable toggle flag which overlaps with additive, toggling handled automatically
	if(substring(world.model, 0, 6) == "maps/r")
	{
		// jumppads with the toggle flag aren't active by default unless specified
		if(!(this.spawnflags & PUSH_ACTIVE) && (this.spawnflags & PUSH_TOGL))
			this.active = ACTIVE_NOT;
		this.spawnflags &= ~PUSH_TOGL;
		return; // avoid mg's handling in this case
	}

	if((this.spawnflags & PUSH_START_OFF))
		this.active = ACTIVE_NOT;
}

//============================================================================

void trigger_monsterjump_touch(entity this, entity toucher)
{
	if(!IS_MONSTER(toucher))
		return;
	if((toucher.flags & FL_FLY) || (toucher.flags & FL_SWIM))
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

// set XY even if not on ground, so the jump will clear lips
	toucher.velocity_x = this.movedir_x * this.speed;
	toucher.velocity_y = this.movedir_y * this.speed;

	if(!IS_ONGROUND(toucher))
		return;
	
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
	if(this.angles == '0 0 0')
		this.angles = '0 360 0';
	InitTrigger(this);
	settouch(this, trigger_monsterjump_touch);

	if(!this.cnt)
		this.cnt = -1;
}

/*QUAKED info_notnull(0 0.5 0)(-4 -4 -4)(4 4 4)
Used as a positional target for lightning.
*/
spawnfunc(info_notnull)
{
}

#endif
