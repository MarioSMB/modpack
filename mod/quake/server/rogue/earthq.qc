// ============================================================
// Level-Wide Earthquakes
// ============================================================
const int EQ_RANDOM = BIT(0);

void stop_earthquake(entity this);

void earthquake_rumble(entity this)
{
	if (this.attack_finished < time)
		stop_earthquake(this);
	else
	{
		_sound(this, CH_TRIGGER_SINGLE, "equake/rumble.wav", 1, ATTN_NONE );
		setthink(this, earthquake_rumble);
		this.nextthink = time + 1;
	}
} 

void start_earthquake(entity this)
{
	earthquake_active = true;
	if(this.spawnflags & EQ_RANDOM)
		this.attack_finished = time + random() * this.delay;
	else
		this.attack_finished = time + this.delay;
	earthquake_rumble(this);
}

void stop_earthquake(entity this)
{
	earthquake_active = false;
	setthink(this, start_earthquake);
	if(this.spawnflags & EQ_RANDOM)
		this.nextthink = time + random() * this.wait;
	else
		this.nextthink = time + this.wait;
}

/*QUAKED earthquake (0 1 0) (-8 -8 -8) (8 8 8) Random
The Earthquake generator.

delay - duration of the tremor (default 20)
wait - time between tremors (default 60)
weapon - richter scale of movement (default 40)

RANDOM affects the times only. It will change the randomly between
0-n where n is the duration or time between.

weapon - if you give a weapon value of 40, the X and Y displacement 
can vary between -20 and +20, a range of 40.
*/
spawnfunc(earthquake)
{
	if(!MP_ROGUE) { delete(this); return; }
	
	if(!this.delay)
		this.delay = 20;
	if(!this.wait)
		this.wait = 60;
	if(!this.weapon)
		this.weapon = 40;	
	
	precache_sound("equake/rumble.wav");
	earthquake_active = false;
	earthquake_intensity = this.weapon * 0.5;
	
	setsize(this, '0 0 0', '0 0 0');
	setthink(this, stop_earthquake);
	this.nextthink = time + 1;
}

// ============================================================
// Earthquake trigger
// ============================================================
void earthquake_touch(entity this, entity toucher)
{
	if(this.delay)
	{
		if(this.attack_finished < time)
		{
			_sound(this, CH_TRIGGER_SINGLE, "equake/rumble.wav", 1, ATTN_NORM );
			this.attack_finished = time + 1;
		}

		if(IS_PLAYER(toucher))
		{
			if(toucher.flags & FL_ONGROUND)
			{
				toucher.velocity_x = toucher.velocity_x + 
									(random() * this.weapon * 2) -
									this.weapon;
				toucher.velocity_y = toucher.velocity_y + 
									(random() * this.weapon * 2) -
									this.weapon;
				toucher.velocity_z = toucher.velocity_z + 
									(random() * this.weapon * 2) -
									this.weapon;
			}
		}
	}
}

void rogue_earthquake_use(entity this, entity actor, entity trigger)
{
	this.delay = !this.delay;
}

/*QUAKED trigger_earthquake (.5 .5 .5) ?
The Earthquake generator.

Anytime a person is in an active field, they shake. If the trigger is a target, it will be OFF until triggered. It will then toggle between ON and OFF.

weapon - richter scale of movement (default 40)

weapon - if you give a weapon value of 40, the X and Y displacement 
can vary between -20 and +20, a range of 40.
*/
spawnfunc(trigger_earthquake)
{
	if(!MP_ROGUE) { delete(this); return; }
	
	precache_sound ("equake/rumble.wav");
	
	if(!this.weapon)
		this.weapon = 40;	
	
	this.weapon = this.weapon * 0.5;
	this.delay = 1;
	settouch(this, earthquake_touch);

	if(this.targetname && this.targetname != "")
	{
		this.use = rogue_earthquake_use;
		this.delay = 0;
	}

	InitTrigger(this);
}

void kill_earthquake(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;

	// TODO: targeting?
	earthquake_active = false;
	FOREACH_ENTITY_CLASS("earthquake", true,
	{
		delete(it);
	});
}

/*QUAKED trigger_earthquake_kill (.5 .5 .5) ?
Trigger to kill the level-wide earthquake.
*/
spawnfunc(trigger_earthquake_kill)
{
	if(!MP_ROGUE) { delete(this); return; }
	
	settouch(this, kill_earthquake);

	InitTrigger(this);
}
