#ifdef SVQC

.entity tesla_nextent;
.entity tesla_target;
int trap_tesla_scan(entity this)
{
	// look in our immediate vicinity
	int tesla_numtargets = 0;
	entity prev = NULL;
	FOREACH_ENTITY_RADIUS(this.origin, this.distance, !(it.flags & FL_NOTARGET) && (it.flags & this.cnt),
	{
		if(it.health > 0 && !it.struck_by_mjolnir && visible(this, it))
		{
			if(tesla_numtargets == 0)
				this.tesla_target = it;
			else
				prev.tesla_nextent = it;
			tesla_numtargets += 1;
			prev = it;
			if(tesla_numtargets >= this.count)
				break;
		}
	});

	return tesla_numtargets;
}

void TeslaLightningThink(entity this)
{
	this.owner.attack_state = 2;
	if(time > this.delay)
	{
		this.enemy.struck_by_mjolnir = false;
		delete(this);
		return;
	}
	traceline(this.origin, this.enemy.origin, true, this);

	if(trace_fraction != 1.0 || this.enemy.health <= 0 || vdist(this.origin - this.enemy.origin, >, (this.distance + 10)))
	{
		this.enemy.struck_by_mjolnir = false;
		delete(this);
		return;
	}
	//te_lightning2(NULL, this.origin, trace_endpos); // should be this
	SendCSQCLightningBeam(this.origin, trace_endpos);
	LightningDamage(this.origin, trace_endpos, this.lastvictim, this.dmg, this.projectiledeathtype);
	this.nextthink = time + 0.1;
}

void SpawnTeslaLightning(entity this, entity targ)
{
	// spawn actual lightning
	entity lgt = spawn();
	if(this.duration > 0)
		lgt.delay = time + this.duration;
	else
		lgt.delay = time + 9999;
	lgt.enemy = targ;
	targ.struck_by_mjolnir = true;
	lgt.distance = this.distance;
	lgt.owner = this;
	lgt.lastvictim = this.lastvictim;
	lgt.dmg = this.dmg;
	lgt.origin = this.origin;
	setthink(lgt, TeslaLightningThink);
	lgt.nextthink = time;
	lgt.projectiledeathtype = this.projectiledeathtype;
}

void trap_tesla_think(entity this)
{
	if(this.state == 0)
	{
		this.nextthink = time + 0.25;
		return;
	}
	switch(this.attack_state)
	{
		case 0:
		{
			setthink(this, trap_tesla_think);
			int numtargets = trap_tesla_scan(this);
			if(numtargets > 0)
			{
				if(this.wait > 0)
					_sound(this, CH_TRIGGER, "misc/tesla.wav", 1, ATTN_NORM);
				this.attack_state = 1;
				this.nextthink = time + this.wait;
				break;
			}
			this.nextthink = time + 0.25;
			if(this.delay > 0)
			{
				if(time > this.search_time)
					this.attack_state = 3;
			}
			break;
		}
		case 1:
		{
			int numtargets = trap_tesla_scan(this);
			while(numtargets > 0)
			{
				_sound(this, CHAN_AUTO, "hipweap/mjolhit.wav", 1, ATTN_NORM);
				SpawnTeslaLightning(this, this.tesla_target);
				this.tesla_target = this.tesla_target.tesla_nextent;
				numtargets = numtargets - 1;
			}
			this.attack_state = 2;
			this.nextthink = time + 1;
			break;
		}
		case 2:
		{
			this.attack_state = 3;
			this.nextthink = time + 0.2;
			break;
		}
		case 3:
		{
			this.attack_state = 0;
			this.nextthink = time + 0.1;
			if(this.classname == "trap_gods_wrath")
				this.nextthink = -1;
			break;
		}
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
	precache_sound("misc/tesla.wav");
	precache_sound("hipweap/mjolhit.wav");   // lightning sound
	if(this.wait == 0)
		this.wait = 2;
	if(this.dmg == 0)
		this.dmg = 2 + (5*autocvar_skill);
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
	this.attack_state = 0;
	this.projectiledeathtype = DEATH_TRAP.m_id; // TODO: is electrocuted
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
	if(this.delay == 0)
		this.delay = 5;
	spawnfunc_trap_tesla_coil(this);
	this.classname = "trap_gods_wrath"; // reset by spawnfunc
	this.wait = 0;
	this.state = 1;
	this.nextthink = -1;
	this.projectiledeathtype = DEATH_WRATH.m_id;
//   this.attack_state = 1;
	this.use = trap_gods_wrath_use;
}

#endif
