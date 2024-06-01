#include "exploder.qh"

#ifdef SVQC

const int USE_PARTICLES = BIT(0);

void BecomeExplosion(entity this);

void exploder_fire(entity this)
{
	SUB_UseTargets(this, this.enemy, this.enemy);

	if(this.dmg < 120)
		_sound(this, CH_TRIGGER, "misc/shortexp.wav", this.volume, this.speed);
	else
		_sound(this, CH_TRIGGER, "misc/longexpl.wav", this.volume, this.speed);

	T_RadiusDamage(this, this.owner, this.dmg, DEATH_TRAP.m_id, this.enemy);
	if(this.spawnflags & USE_PARTICLES)
		Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);
	BecomeExplosion(this);
}

void exploder_use(entity this, entity actor, entity trigger)
{
	if(this.delay)
	{
		this.nextthink = time + this.delay;
		this.delay = 0;
		this.enemy = trigger;
		setthink(this, exploder_fire);
	}
	else
	{
		this.enemy = trigger;
		exploder_fire(this);
	}
}

/*QUAKED func_exploder (0.4 0 0) (0 0 0) (8 8 8) particles
	Spawns an explosion when triggered.  Triggers any targets.

	"dmg" specifies how much damage to cause.  Negative values
	indicate no damage.  Default or 0 indicates 120.
	"volume" volume at which to play explosions (default 1.0)
	"speed" attenuation for explosions (default normal)
*/
spawnfunc(func_exploder)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	precache_sound("misc/shortexp.wav");
	precache_sound("misc/longexpl.wav");
	this.classname = "exploder";
	this.use = exploder_use;
	if(this.dmg == 0)
		this.dmg = 120;
	if(this.dmg < 0)
		this.dmg = 0;
	if(this.speed == 0)
		this.speed = 1;
	if(this.volume == 0)
		this.volume = 1.0;
}

void multi_exploder_fire(entity this)
{
	this.nextthink = time + this.wait;
	if(this.state == 0)
	{
		this.state = 1;
		this.duration = time + this.duration;
		SUB_UseTargets(this, this.enemy, this.enemy);
	}
	if(time > this.duration)
	{
		delete(this);
		return;
	}
	entity expl = spawn();
	expl.owner = this.owner;
	expl.dmg = this.dmg;
	expl.origin_x = this.absmin_x + (random() * (this.absmax_x - this.absmin_x));
	expl.origin_y = this.absmin_y + (random() * (this.absmax_y - this.absmin_y));
	expl.origin_z = this.absmin_z + (random() * (this.absmax_z - this.absmin_z));
	_sound(expl , CH_TRIGGER_SINGLE, "misc/shortexp.wav", this.volume, this.speed);
	T_RadiusDamage(expl, this.owner, this.dmg, DEATH_TRAP.m_id, other);
	if(this.spawnflags & USE_PARTICLES)
		Send_Effect(EFFECT_EXPLOSION, expl.origin, '0 0 0', 1);
	BecomeExplosion(expl);
}

void multi_explosion(vector loc, float rad, float damage, float dur, float pause, float vol)
{
	entity temp = spawn();
	temp.origin = loc;
	temp.dmg = damage;
	temp.duration = dur;
	temp.wait = pause;
	temp.owner = NULL;
	temp.absmin = temp.origin - (rad * '1 1 1');
	temp.absmax = temp.origin + (rad * '1 1 1');
	setthink(temp, multi_exploder_fire);
	temp.volume = vol;
	multi_exploder_fire(temp);
}

void multi_exploder_use(entity this, entity actor, entity trigger)
{
	if(this.delay)
	{
		this.nextthink = time + this.delay;
		this.delay = 0;
		this.enemy = trigger;
		setthink(this, multi_exploder_fire);
	}
	else
	{
		setthink(this, multi_exploder_fire);
		this.enemy = trigger;
		multi_exploder_fire(this);
	}
}

/*QUAKED func_multi_exploder (0.4 0 0) ?
	Spawns an explosion when triggered.  Triggers any targets.
	size of brush determines where explosions will occur.

	"dmg" specifies how much damage to cause from each explosion
	Negative values indicate no damage.  Default or 0 indicates 120.
	"delay" delay before exploding (Default 0 seconds)
	"duration" how long to explode for (Default 1 second)
	"wait" time between each explosion (default 0.25 seconds)
	"volume" volume to play explosion sound at (default 0.5)
	"speed" attenuation for explosions (default normal)
*/
spawnfunc(func_multi_exploder)
{
	if(!MP_HIPNOTIC) { delete(this); return; }
	
	precache_sound("misc/shortexp.wav");
	precache_sound("misc/longexpl.wav");
	this.classname = "exploder";
	this.use = multi_exploder_use;
	_setmodel(this, this.model);
	set_movetype(this, MOVETYPE_NONE);
	this.modelindex = 0;
	this.model = "";
	if(this.dmg == 0)
		this.dmg = 120;
	if(this.dmg < 0)
		this.dmg = 0;
	if(this.duration == 0)
		this.duration = 1.0;
	if(this.speed == 0)
		this.speed = 1.0;
	if(this.volume == 0)
		this.volume = 0.5;
	if(this.wait == 0)
		this.wait = 0.25;
	this.state = 0;
}

#endif
