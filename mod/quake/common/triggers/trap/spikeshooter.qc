#ifdef SVQC

const int SPAWNFLAG_SUPERSPIKE = BIT(0);
const int SPAWNFLAG_LASER = BIT(1);
const int SPAWNFLAG_LAVASPIKE = BIT(2);
const int SPAWNFLAG_SUPERLAVA = BIT(3);
const int SPAWNFLAG_LAVASKILL = BIT(4);
const int SPAWNFLAG_FIREBALL = BIT(5);

const int SPAWNFLAG_LAVABALL = BIT(2);
const int SPAWNFLAG_ROCKET = BIT(3);

entity LaunchLaser(entity this, vector org, vector vec);
void superlavaspike_touch(entity this, entity toucher);
void superspike_touch(entity this, entity toucher);
entity W_FireRocket(entity this);
entity launch_fireball(entity this, vector org, vector dir);

void spikeshooter_use(entity this, entity actor, entity trigger)
{
	if((this.spawnflags & SPAWNFLAG_SUPERSPIKE) || !this.spawnflags)
	{
		if(!(this.spawnflags & SPAWNFLAG_SILENT))
			_sound(this, CH_WEAPON_SINGLE, "weapons/spike2.wav", 1, ATTN_NORM);
		entity newmis = launch_spike(this, this.origin, this.movedir);
		newmis.projectiledeathtype = DEATH_TRAP.m_id;
		newmis.velocity = this.movedir * 500;
		if(this.spawnflags & SPAWNFLAG_SUPERSPIKE)
			settouch(newmis, superspike_touch);
	}
	else if(((this.spawnflags & SPAWNFLAG_LAVASPIKE) || (this.spawnflags & SPAWNFLAG_SUPERLAVA)) && IsRogueMap())
	{
		entity newmis = launch_lava_spike(this, this.origin, this.movedir);
		_sound(this, CH_WEAPON_SINGLE, "weapons/spike2.wav", 1, ATTN_NORM);
		newmis.projectiledeathtype = DEATH_TRAP.m_id;
		newmis.velocity = this.movedir * 500;
		if((this.spawnflags & SPAWNFLAG_SUPERLAVA) || (this.spawnflags & SPAWNFLAG_LAVASKILL))
			settouch(newmis, superlavaspike_touch);
		else
			settouch(newmis, lavaspike_touch);
	}
	else if((this.spawnflags & SPAWNFLAG_FIREBALL) && IsRogueMap())
	{
		entity newmis = launch_fireball(this, this.origin, this.movedir);
		newmis.projectiledeathtype = DEATH_TRAP.m_id;
	}
	else if(this.spawnflags & SPAWNFLAG_LASER)
	{
		if(!(this.spawnflags & SPAWNFLAG_SILENT))
			_sound(this, CH_WEAPON_SINGLE, "enforcer/enfire.wav", 1, ATTN_NORM);
		entity las = LaunchLaser(this, this.origin, this.movedir);
		las.spawnflags = this.spawnflags;
	}
	else if(this.spawnflags & SPAWNFLAG_LAVABALL)
	{
		if(!(this.spawnflags & SPAWNFLAG_SILENT))
			_sound (this, CH_WEAPON_SINGLE, "misc/spike.wav", 1, ATTN_NORM);
		entity lavaball = new(lavaball);
		set_movetype(lavaball, MOVETYPE_FLYMISSILE);
		lavaball.solid = SOLID_BBOX;
		// set lavaball speed
		lavaball.velocity = this.movedir * 300;
		lavaball.angles = vectoangles(lavaball.velocity);
		lavaball.owner = this;
		lavaball.projectiledeathtype = DEATH_TRAP.m_id;
		settouch(lavaball, T_MissileTouch);
		_setmodel (lavaball, "progs/lavarock.mdl");
		setsize (lavaball, '-4 -4 -4', '4 4 4');
		setorigin (lavaball, this.origin);
		lavaball.avelocity = '0 0 400';
		lavaball.nextthink = time + 5;
		setthink(lavaball, SUB_Remove);
	}
	else if(this.spawnflags & SPAWNFLAG_ROCKET)
	{
		if(!(this.spawnflags & SPAWNFLAG_SILENT))
			_sound(this, CH_WEAPON_SINGLE, "weapons/sgun1.wav", 1, ATTN_NORM);
		entity rocket = W_FireRocket(this);
		rocket.velocity = this.movedir*1000;
		rocket.angles = vectoangles(rocket.velocity);
		setorigin(rocket, this.origin + this.movedir*8);
	}
	else
	{
		if(!(this.spawnflags & SPAWNFLAG_SILENT))
			_sound(this, CH_WEAPON_SINGLE, "weapons/spike2.wav", 1, ATTN_NORM);
		entity newmis = launch_spike(this, this.origin, this.movedir);
		newmis.projectiledeathtype = DEATH_TRAP.m_id;
		newmis.velocity = this.movedir * 500;
		if(this.spawnflags & SPAWNFLAG_SUPERLAVA)
			settouch(newmis, superlavaspike_touch);
		else if((this.spawnflags & SPAWNFLAG_LAVASKILL) && autocvar_skill > 1)
			settouch(newmis, superlavaspike_touch);
		else if(this.spawnflags & SPAWNFLAG_SUPERSPIKE)
			settouch(newmis, superspike_touch);
	}
}

void shooter_think(entity this)
{
	if(this.state)
		spikeshooter_use(this, NULL, NULL);
	this.nextthink = time + this.wait;
	FOREACH_ENTITY_ENT(owner, this,
	{
		it.velocity = this.movedir * 500;
	});
}


/*QUAKED trap_spikeshooter(0 .5 .8)(-8 -8 -8)(8 8 8) superspike laser lavaball rocket silent superlava skilllava fireball
When triggered, fires a spike in the direction set in QuakeEd.
Laser, Lava and SuperLava are is only for REGISTERED.
*/

spawnfunc(trap_spikeshooter)
{
	SetMovedir(this);
	this.use = spikeshooter_use;
	this.killstring = " was spiked";
	if(this.spawnflags & SPAWNFLAG_LASER)
	{
		precache_model("progs/laser.mdl");
		
		precache_sound("enforcer/enfire.wav");
		precache_sound("enforcer/enfstop.wav");
	}
	if(this.spawnflags & SPAWNFLAG_LAVABALL) // too early to bother checking for mission packs
	{
		precache_model("progs/lavarock.mdl");
//      this.classname = "fireball";
		precache_sound("misc/spike.wav");
	}
	if(this.spawnflags & SPAWNFLAG_ROCKET)
	{
		precache_model("progs/missile.mdl");
		precache_sound("weapons/sgun1.wav");
	}
	if(this.spawnflags & SPAWNFLAG_LAVASPIKE)
	{
		precache_model("progs/lspike.mdl");
		precache_sound("lavagun/snail.wav");		// lava nail gun cooldown
		precache_sound("weapons/rocket1i.wav");
	}
	if(this.spawnflags & SPAWNFLAG_SUPERLAVA)
	{
		precache_model("progs/lspike.mdl");
		precache_sound("lavagun/snail.wav");		// lava nail gun cooldown
		precache_sound("weapons/spike2.wav");
	}
	if(this.spawnflags & SPAWNFLAG_LAVASKILL)
	{
		precache_model("progs/lspike.mdl");
		precache_sound("lavagun/snail.wav");		// lava nail gun cooldown
		precache_sound("weapons/rocket1i.wav");
		precache_sound("weapons/spike2.wav");
	}
	if(this.spawnflags & SPAWNFLAG_FIREBALL)
		precache_model("progs/fireball.mdl");
	else
		precache_sound("weapons/spike2.wav");
}


/*QUAKED trap_shooter(0 .5 .8)(-8 -8 -8)(8 8 8) superspike laser lavaball rocket silent
Continuously fires spikes.
"wait" time between spike(1.0 default)
"nextthink" delay before firing first spike, so multiple shooters can be stagered.
*/
spawnfunc(trap_shooter)
{
	spawnfunc_trap_spikeshooter(this);
	
	if(this.wait == 0)
		this.wait = 1;
	this.state = 1;
	this.nextthink = this.save_nextthink + this.wait + this.ltime;
	setthink(this, shooter_think);
}

//MED 11/01/96 added new use function
void trap_shooter_use(entity this, entity actor, entity trigger)
{
	this.state = 1 - this.state;
}
//MED 11/01/96 added new function
/*QUAKED trap_switched_shooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser lavaball rocket silent
Continuously fires spikes.
"wait" time between spike (1.0 default)
"nextthink" delay before firing first spike, so multiple shooters can be stagered.
"state" 0 initially off, 1 initially on. (0 default)
*/
spawnfunc(trap_switched_shooter)
{
	if(this.wait == 0)
		this.wait = 1;
//MED 11/01/96 added state capability
	this.nextthink = this.save_nextthink + this.wait + this.ltime;
	setthink(this, shooter_think);
	this.use = trap_shooter_use;

	spawnfunc_trap_spikeshooter(this);
}

#endif
