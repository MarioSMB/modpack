#ifdef SVQC

const int LIGHTNING_RANDOM = BIT(0);
const int LIGHTNING_BOOM = BIT(1);

void SpawnLightningThink(entity this)
{
	if(time > this.delay)
	{
		delete(this);
		return;
	}
	setthink(this, SpawnLightningThink);
	if(checkclient(this))
	{
		te_lightning2(NULL, this.origin, this.oldorigin); // should be this
	}
	LightningDamage(this.origin, this.oldorigin, this.lastvictim, this.dmg);
	this.nextthink = time + 0.1;
}

void trap_lightning_use(entity this, entity actor, entity trigger)
{
	vector p1, p2;

	if(this.pausetime != -1 && time >= this.pausetime)
	{
		if(this.spawnflags & LIGHTNING_BOOM)
			_sound(this, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
		else
			_sound(this, CHAN_AUTO, "weapons/lhit.wav", 1, ATTN_NORM);
		if(this.classname == "trap_lightning_triggered")
			this.pausetime = time + 0.1;
	}
	if(this.target && this.target != "")
	{
		p1 = this.origin;
		p2 = this.enemy.origin;
	}
	else
	{
		makevectors (this.angles);
		this.movedir = v_forward;
		traceline (this.origin, this.origin + this.movedir*600, true, this);
		p1 = this.origin;
		p2 = trace_endpos;
	}
	// fix up both ends of the lightning
	// lightning bolts are 30 units long each
	vector dir = normalize( p2-p1 );
	float dst = vlen(p2-p1);
	dst = dst / 30.0;
	float remainder = dst - floor(dst);
	if(remainder > 0)
	{
		remainder = remainder - 1;
		// split half the remainder with the front and back
		remainder = remainder * 15;
		p1 = p1 + (remainder*dir);
		p2 = p2 - (remainder*dir);
	}
	if(this.duration > 0.1)
	{
		entity ltning = spawn();
		ltning.origin = p1;
		ltning.oldorigin = p2;
		ltning.lastvictim = this;
		ltning.dmg = this.dmg;
		ltning.delay = time + this.duration;
		SpawnLightningThink(ltning);
	}
	else if(checkclient(this))
	{
		te_lightning2(NULL, p1, p2); // should be this
		LightningDamage(p1, p2, this, this.dmg);
	}
	else
		LightningDamage(p1, p2, this, this.dmg);
}

void lightning_think(entity this)
{
	float timedelay;

	if(this.state)
		trap_lightning_use(this, NULL, NULL);

	if(this.cnt == 0)
	{
		if(this.spawnflags & LIGHTNING_RANDOM)
			timedelay = this.wait * random();
		else
			timedelay = this.wait;

		this.cnt = 1;
		this.t_length = time + this.duration - 0.1;
		this.pausetime = time + this.duration - 0.1;
		if(this.pausetime < time + 0.3)
			this.pausetime = time + 0.3;
		if(timedelay < this.duration)
			timedelay = this.duration;
		this.t_width = time + timedelay;
	}
	setthink(this, lightning_think);
	if(time >= this.t_length)
	{
		this.cnt = 0;
		this.nextthink = this.t_width;
	}
	else
		this.nextthink = time + 0.2;
}

void lightning_firstthink(entity this)
{
	if(this.target && this.target != "")
	{
		entity targ = find(NULL,targetname,this.target);
		this.dest = targ.origin;
		this.enemy = targ;
	}
	setthink(this, func_null);
	this.nextthink = 0;
	if(this.classname != "trap_lightning_triggered")
	{
		this.nextthink = this.huntingcharmer + this.wait + this.ltime;
		setthink(this, lightning_think);
	}
}

void lightning_init(entity this)
{
	if(!this.wait)
		this.wait = 1.0;
	if(!this.dmg)
		this.dmg = 30;
	if(!this.duration)
		this.duration = 0.1;
	this.cnt = 0;
	this.use = trap_lightning_use;
	precache_sound("weapons/lhit.wav");
	precache_sound("weapons/lstart.wav");
	this.huntingcharmer = this.save_nextthink;
	setthink(this, lightning_firstthink);
	this.nextthink = time + 0.25;
	this.deathtype = "is electrocuted";
}

/*QUAKED trap_lightning_triggered (0 .5 .8) (-8 -8 -8) (8 8 8) random boom
When triggered, fires lightning in the direction set in QuakeEd.
"wait" how long to wait between blasts (1.0 default)
		 if in random mode wait is multiplied by random
"dmg" how much damage lightning should inflict (30 default)
"duration" how long each lightning attack should last (0.1 default)
*/

spawnfunc(trap_lightning_triggered)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	this.classname = "trap_lightning_triggered";

	lightning_init(this);
}


/*QUAKED trap_lightning (0 .5 .8) (-8 -8 -8) (8 8 8) random boom
Continuously fire lightning.
"wait" how long to wait between blasts (1.0 default)
		 if in random mode wait is multiplied by random
"nextthink" delay before firing first lightning, so multiple traps can be stagered.
"dmg" how much damage lightning should inflict (30 default)
"duration" how long each lightning attack should last (0.1 default)
*/
spawnfunc(trap_lightning)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	this.classname = "trap_lightning";

	lightning_init(this);
	this.state = 1;
}

void trap_lightning_switched_use(entity this, entity actor, entity trigger)
{
	this.state = 1 - this.state;
	if(this.state == 1)
	{
		this.nextthink = this.huntingcharmer;
		setthink(this, lightning_think);
	}
}
/*QUAKED trap_lightning_switched (0 .5 .8) (-8 -8 -8) (8 8 8) random boom
Continuously fires lightning.
"wait" how long to wait between blasts (1.0 default)
		 if in random mode wait is multiplied by random
"nextthink" delay before firing first lightning, so multiple traps can be stagered.
"dmg" how much damage lightning should inflict (30 default)
"duration" how long each lightning attack should last (0.1 default)
"state" 0 (default) initially off, 1 initially on.
*/
spawnfunc(trap_lightning_switched)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	this.classname = "trap_lightning_switched";

	lightning_init(this);
	this.use = trap_lightning_switched_use;
}

#endif
