#ifdef SVQC

entity tesla_target;
float tesla_numtargets;
void trap_tesla_scan(entity this)
{
	entity prev = NULL;

// look in our immediate vicinity

	tesla_numtargets = 0;
	entity head = findradius(this.origin, this.distance);
	while(head)
	{
		if(!(head.flags & FL_NOTARGET) && (head.flags & this.cnt))
		{
			if(visible(this, head) && (head.health > 0) && (head.struck_by_mjolnir == 0))
			{
				if(tesla_numtargets == 0)
					tesla_target = head;
				else
					prev.next_ent = head;
				tesla_numtargets = tesla_numtargets + 1;
				prev = head;
				if(tesla_numtargets == this.count)
					return;
			}
		}
		head = head.chain;
	}
}

void TeslaLightningThink(entity this)
{
	this.owner.attack_state = 2;
	if(time > this.delay)
	{
		this.enemy.struck_by_mjolnir = 0;
		delete(this);
		return;
	}
	traceline(this.origin, this.enemy.origin, true, this);

	if(trace_fraction != 1.0 || this.enemy.health <= 0 || vdist(this.origin - this.enemy.origin, >, (this.distance + 10)))
	{
		this.enemy.struck_by_mjolnir = 0;
		delete(this);
		return;
	}
	te_lightning2(NULL, this.origin, trace_endpos); // should be this
	LightningDamage(this.origin, trace_endpos, this.lastvictim, this.dmg);
	this.nextthink = time + 0.1;
}

void SpawnTeslaLightning(entity this, entity targ)
{
	// spawn actual lightning
	entity lgt = spawn();
	if(this.duration>0)
		lgt.delay = time + this.duration;
	else
		lgt.delay = time + 9999;
	lgt.enemy = targ;
	targ.struck_by_mjolnir = 1;
	lgt.distance = this.distance;
	lgt.owner = this;
	lgt.lastvictim = this.lastvictim;
	lgt.dmg = this.dmg;
	lgt.origin = this.origin;
	setthink(lgt, TeslaLightningThink);
	lgt.nextthink = time;
	lgt.deathtype = this.deathtype;
}

void trap_tesla_think(entity this)
{
	if(this.state == 0)
	{
		this.nextthink = time + 0.25;
		return;
	}
	if(this.attack_state == 0)
	{
		setthink(this, trap_tesla_think);
		trap_tesla_scan(this);
		if(tesla_numtargets > 0)
		{
			if(this.wait > 0)
				_sound(this, CHAN_AUTO, "misc/tesla.wav", 1, ATTN_NORM);
			this.attack_state = 1;
			this.nextthink = time + this.wait;
			return;
		}
		this.nextthink = time + 0.25;
		if(this.delay > 0)
		{
			if(time > this.search_time)
				this.attack_state = 3;
		}
	}
	else if(this.attack_state == 1)
	{
		trap_tesla_scan(this);
		while(tesla_numtargets > 0)
		{
			_sound(this, CHAN_AUTO, "hipweap/mjolhit.wav", 1, ATTN_NORM);
			SpawnTeslaLightning (this, tesla_target);
			tesla_target = tesla_target.next_ent;
			tesla_numtargets = tesla_numtargets - 1;
		}
		this.attack_state = 2;
		this.nextthink = time + 1;
	}
	else if(this.attack_state == 2)
	{
		this.attack_state = 3;
		this.nextthink = time + 0.2;
	}
	else if(this.attack_state == 3)
	{
		this.attack_state = 0;
		this.nextthink = time + 0.1;
		if(this.classname == "trap_gods_wrath")
			this.nextthink = -1;
	}
}

/*QUAKED trap_tesla_coil (0 .5 .8) (-8 -8 -8) (8 8 8) targetenemies
targets enemies in vicinity and fires at them
"wait" how long build up should be (2 second default)
"dmg" how much damage lightning should inflict (2 + 5*skill default)
"duration" how long each lightning attack should last (continuous default)
"distance" how far the tesla coil should reach (600 default)
"state" on/off for the coil (0 default is off)
"count" number of people to target (2 default)
*/
spawnfunc(trap_tesla_coil)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	precache_sound("misc/tesla.wav");
	precache_sound("hipweap/mjolhit.wav");   // lightning sound
	if(this.wait == 0)
		this.wait = 2;
	if(this.dmg == 0)
		this.dmg = 2 + (5*cvar("skill"));
	if(this.duration == 0)
		this.duration = -1;
	if(this.distance == 0)
		this.distance = 600;
	if(this.spawnflags & 1)
		this.cnt = FL_CLIENT | FL_MONSTER;
	else
		this.cnt = FL_CLIENT;
	this.use = trap_lightning_switched_use;
	if(this.delay == 0)
		this.delay = -1;
	this.nextthink = time + random();
	setthink(this, trap_tesla_think);
	this.lastvictim = NULL;
	tesla_numtargets = 0;
	this.attack_state = 0;
	this.deathtype = "is electrocuted";
}

void trap_gods_wrath_use(entity this, entity actor, entity trigger)
{
	if(this.attack_state == 0)
	{
		this.search_time = time + this.delay;
		this.lastvictim = actor;
		trap_tesla_think(this);
	}
}

/*QUAKED trap_gods_wrath (0 .5 .8) (-8 -8 -8) (8 8 8) targetenemies
targets enemies in vicinity and fires at them
"dmg" how much damage lightning should inflict (5 default)
"duration" how long each lightning attack should last (continuous default)
"distance" how far god's wrath should reach (600 default)
"delay" how long to wait until god calms down
	this is only needed if no one is targetted (5 seconds default)
"count" number of people to target (2 default)
*/
spawnfunc(trap_gods_wrath)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	if(this.delay == 0)
		this.delay = 5;
	spawnfunc_trap_tesla_coil(this);
	this.wait = 0;
	this.state = 1;
	this.nextthink = -1;
	this.deathtype = "suffers the wrath of God";
//   this.attack_state = 1;
	this.use = trap_gods_wrath_use;
}

#endif
