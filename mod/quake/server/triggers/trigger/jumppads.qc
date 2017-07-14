#ifdef SVQC

const int PUSH_ONCE = BIT(0);
const int PUSH_TOGL = BIT(1);
const int PUSH_ACTIVE = BIT(2);

void trigger_push_touch(entity this, entity toucher)
{
	if(MP_ROGUE && !(this.spawnflags & PUSH_ACTIVE))
		return;

	if(toucher.classname == "grenade" || toucher.classname == "MiniGrenade" || toucher.classname == "MultiGrenade")
		toucher.velocity = this.speed * this.movedir * 10;
	else if(toucher.health > 0)
	{
		toucher.velocity = this.speed * this.movedir * 10;
		if(IS_PLAYER(toucher))
		{
			if(toucher.fly_sound < time)
			{
				toucher.fly_sound = time + 1.5;
				_sound(toucher, CH_TRIGGER, "ambience/windfly.wav", 1, ATTN_NORM);
			}
		}
	}
	if(this.spawnflags & PUSH_ONCE)
		delete(this);
}

void trigger_push_use(entity this, entity actor, entity trigger)
{
	if(this.spawnflags & PUSH_ACTIVE)
		this.spawnflags &= ~PUSH_ACTIVE;
	else
		this.spawnflags |= PUSH_ACTIVE;
}


/*QUAKED trigger_push(.5 .5 .5) ? PUSH_ONCE PUSH_TOGL PUSH_ACTIVE
Pushes the player.

speed: velocity of push. (default 1000)
*/
spawnfunc(trigger_push)
{
	if(MP_ROGUE)
	if(this.spawnflags & PUSH_TOGL)
		this.use = trigger_push_use;
	else
		this.spawnflags |= PUSH_ACTIVE;

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

	if(!IS_ONGROUND(toucher))
		return;
	
	UNSET_ONGROUND(toucher);

	toucher.velocity_z = this.height;

	if(MP_HIPNOTIC && this.cnt > 0)
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

	if(MP_HIPNOTIC && !this.cnt)
		this.cnt = -1;
}

#endif
