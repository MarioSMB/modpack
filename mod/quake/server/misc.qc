#include "combat.qh"

bool autocvar_sv_eventlog_console;

/** print(), but only print if the server is not local */
void dedicated_print(string input)
{
	if(server_is_dedicated) print(input);
}

void GameLogEcho(string s)
{
    if(autocvar_sv_eventlog_console)
        dedicated_print(strcat(s, "\n"));
}

void set_anim(entity this, int frm, void(entity) tnk)
{
	this.frame = frm;
	setthink(this, tnk);
	this.nextthink = time + FRAME_TIME;
}

/*QUAKED info_null(0 0.5 0)(-4 -4 -4)(4 4 4)
Used as a positional target for spotlights, etc.
*/
spawnfunc(info_null)
{
	delete(this);
}

/*QUAKED info_notnull(0 0.5 0)(-4 -4 -4)(4 4 4)
Used as a positional target for lightning.
*/
spawnfunc(info_notnull)
{
}

//============================================================================

const int START_OFF = BIT(0);

void light_use(entity this, entity actor, entity trigger)
{
	if(this.spawnflags & START_OFF)
	{
		lightstyle(this.style, "m");
		this.spawnflags &= ~START_OFF;
	}
	else
	{
		lightstyle(this.style, "a");
		this.spawnflags |= START_OFF;
	}
}

/*QUAKED light(0 1 0)(-8 -8 -8)(8 8 8) START_OFF
Non-displayed light.
Default light value is 300
Default style is 0
If targeted, it will toggle between on or off.
*/
spawnfunc(light)
{
	if(!this.targetname || this.targetname == "")
	{	// inert light
		delete(this);
		return;
	}
	
	if(this.style >= 32)
	{
		this.use = light_use;
		if(this.spawnflags & START_OFF)
			lightstyle(this.style, "a");
		else
			lightstyle(this.style, "m");
	}
}

/*QUAKED light_fluoro(0 1 0)(-8 -8 -8)(8 8 8) START_OFF
Non-displayed light.
Default light value is 300
Default style is 0
If targeted, it will toggle between on or off.
Makes steady fluorescent humming sound
*/
spawnfunc(light_fluoro)
{
	if(this.style >= 32)
	{
		this.use = light_use;
		if(this.spawnflags & START_OFF)
			lightstyle(this.style, "a");
		else
			lightstyle(this.style, "m");
	}
	
	precache_sound("ambience/fl_hum1.wav");
	ambientsound(this.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
}

/*QUAKED light_fluorospark(0 1 0)(-8 -8 -8)(8 8 8)
Non-displayed light.
Default light value is 300
Default style is 10
Makes sparking, broken fluorescent sound
*/
spawnfunc(light_fluorospark)
{
	if(!this.style)
		this.style = 10;

	precache_sound("ambience/buzz1.wav");
	ambientsound(this.origin, "ambience/buzz1.wav", 0.5, ATTN_STATIC);
}

/*QUAKED light_globe(0 1 0)(-8 -8 -8)(8 8 8)
Sphere globe light.
Default light value is 300
Default style is 0
*/
spawnfunc(light_globe)
{
	precache_model("progs/s_light.spr");
	_setmodel(this, "progs/s_light.spr");
	makestatic(this);
}

void FireAmbient(entity this)
{
	precache_sound("ambience/fire1.wav");
// attenuate fast
	ambientsound(this.origin, "ambience/fire1.wav", 0.5, ATTN_STATIC);
}

/*QUAKED light_torch_small_walltorch(0 .5 0)(-10 -10 -20)(10 10 20) Quiet
Short wall torch
Default light value is 200 (300 in rogue)
Default style is 0
*/
spawnfunc(light_torch_small_walltorch)
{
	precache_model("progs/flame.mdl");
	_setmodel(this, "progs/flame.mdl");
	if(!MP_ROGUE || !(this.spawnflags & 1))
		FireAmbient(this);
	makestatic(this);
}

/*QUAKED light_flame_large_yellow(0 1 0)(-10 -10 -12)(12 12 18)
Large yellow flame ball
*/
spawnfunc(light_flame_large_yellow)
{
	precache_model("progs/flame2.mdl");
	_setmodel(this, "progs/flame2.mdl");
	this.frame = 1;
	FireAmbient(this);
	makestatic(this);
}

/*QUAKED light_flame_small_yellow(0 1 0)(-8 -8 -8)(8 8 8) START_OFF
Small yellow flame ball
*/
spawnfunc(light_flame_small_yellow)
{
	precache_model("progs/flame2.mdl");
	_setmodel(this, "progs/flame2.mdl");
	FireAmbient(this);
	makestatic(this);
}

/*QUAKED light_flame_small_white(0 1 0)(-10 -10 -40)(10 10 40) START_OFF
Small white flame ball
*/
spawnfunc(light_flame_small_white)
{
	precache_model("progs/flame2.mdl");
	_setmodel(this, "progs/flame2.mdl");
	FireAmbient(this);
	makestatic(this);
}

//============================================================================

void fire_touch(entity this, entity toucher)
{
	T_Damage(toucher, this, this, 20);
	delete(this);
}

void fire_fly(entity this)
{
	entity fireball = spawn();
	fireball.solid = SOLID_TRIGGER;
	set_movetype(fireball, MOVETYPE_TOSS);
	fireball.velocity = '0 0 1000';
	fireball.velocity_x =(random() * 100) - 50;
	fireball.velocity_y =(random() * 100) - 50;
	fireball.velocity_z = this.speed +(random() * 200);
	fireball.classname = "fireball";
	_setmodel(fireball, "progs/lavaball.mdl");
	setsize(fireball, '0 0 0', '0 0 0');
	setorigin(fireball, this.origin);
	fireball.nextthink = time + 5;
	setthink(fireball, SUB_Remove);
	settouch(fireball, fire_touch);
	
	this.nextthink = time +(random() * 5) + 3;
	setthink(this, fire_fly);
}


/*QUAKED misc_fireball(0 .5 .8)(-8 -8 -8)(8 8 8)
Lava Balls
*/

spawnfunc(misc_fireball)
{
	
	precache_model("progs/lavaball.mdl");
	this.classname = "fireball";
	this.nextthink = time +(random() * 5);
	setthink(this, fire_fly);
	if(!this.speed)
		this.speed = 1000;
}

//============================================================================


void barrel_explode(entity this, entity attacker)
{
	this.takedamage = DAMAGE_NO;
	this.classname = "explo_box";
	// did say this.owner
	T_RadiusDamage(this, this, 160, NULL);
	_sound(this, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);
	particle(this.origin, '0 0 0', 75, 255);

	setSendEntity(this, func_null); // some things are gonna happen to this barrel that the ChildrenS of QuakeC shouldn't see

	this.origin_z = this.origin_z + 32;
	BecomeExplosion(this);
}

void barrel_spawn(entity this)
{
	this.solid = SOLID_BBOX;
	precache_model(this.model);
	_setmodel(this, this.model);
	precache_sound("weapons/r_exp3.wav");
	if(!this.health)
		this.health = 20;
	this.th_die = barrel_explode;
	this.takedamage = DAMAGE_AIM;

	this.origin_z = this.origin_z + 2;
	float oldz = this.origin_z;
	WITHSELF(this, builtin_droptofloor());
	if(oldz - this.origin_z > 250)
	{
		LOG_DEBUG("Exploding box fell out of the level at ", vtos(this.origin), "\n");
		delete(this);
		return;
	}

	CSQCMODEL_AUTOINIT(this);
}



/*QUAKED misc_explobox(0 .5 .8)(0 0 0)(32 32 64)
TESTING THING
*/

spawnfunc(misc_explobox)
{
	this.model = "maps/b_explob.bsp";
	barrel_spawn(this);
}



/*QUAKED misc_explobox2(0 .5 .8)(0 0 0)(32 32 64)
Smaller exploding box, REGISTERED ONLY
*/

spawnfunc(misc_explobox2)
{
	this.model = "maps/b_exbox2.bsp";
	barrel_spawn(this);
}

//============================================================================

const int SPAWNFLAG_LAVASPIKE = BIT(2);
const int SPAWNFLAG_SUPERLAVA = BIT(3);
const int SPAWNFLAG_LAVASKILL = BIT(4);
const int SPAWNFLAG_FIREBALL = BIT(5);

entity LaunchLaser(entity this, vector org, vector vec);

void spikeshooter_use(entity this, entity actor, entity trigger)
{
	if(MP_ROGUE && ((this.spawnflags & SPAWNFLAG_SUPERSPIKE) || !this.spawnflags))
	{
		if(!MP_HIPNOTIC || !(this.spawnflags & SPAWNFLAG_SILENT))
			_sound(this, CHAN_VOICE, "weapons/spike2.wav", 1, ATTN_NORM);
		entity newmis = launch_spike(this, this.origin, this.movedir);
		newmis.velocity = this.movedir * 500;
		if(this.spawnflags & SPAWNFLAG_SUPERSPIKE)
			settouch(newmis, superspike_touch);
	}
	else if(this.spawnflags & SPAWNFLAG_LASER)
	{
		if(!MP_HIPNOTIC || !(this.spawnflags & SPAWNFLAG_SILENT))
			_sound(this, CHAN_VOICE, "enforcer/enfire.wav", 1, ATTN_NORM);
		entity las = LaunchLaser(this, this.origin, this.movedir);
		if(MP_HIPNOTIC)
			las.spawnflags = this.spawnflags;
	}
	else if(MP_HIPNOTIC && (this.spawnflags & SPAWNFLAG_LAVABALL))
	{
		if(!this.spawnflags & SPAWNFLAG_SILENT)
			_sound (this, CHAN_VOICE, "misc/spike.wav", 1, ATTN_NORM);
		entity lavaball = new(lavaball);
		set_movetype(lavaball, MOVETYPE_FLYMISSILE);
		lavaball.solid = SOLID_BBOX;
		// set lavaball speed
		lavaball.velocity = this.movedir * 300;
		lavaball.angles = vectoangles(lavaball.velocity);
		lavaball.owner = this;
		settouch(lavaball, T_MissileTouch);
		_setmodel (lavaball, "progs/lavarock.mdl");
		setsize (lavaball, '-4 -4 -4', '4 4 4');
		setorigin (lavaball, this.origin);
		lavaball.avelocity = '0 0 400';
		lavaball.nextthink = time + 5;
		setthink(lavaball, SUB_Remove);
	}
	else if(MP_HIPNOTIC && (this.spawnflags & SPAWNFLAG_ROCKET))
	{
		if(!this.spawnflags & SPAWNFLAG_SILENT)
			_sound(this, CHAN_VOICE, "weapons/sgun1.wav", 1, ATTN_NORM);
		entity rocket = W_FireRocket(this);
		rocket.velocity = this.movedir*1000;
		rocket.angles = vectoangles(rocket.velocity);
		setorigin(rocket, this.origin + this.movedir*8);
	}
	else
	{
		if(!MP_HIPNOTIC || !(this.spawnflags & SPAWNFLAG_SILENT))
			_sound(this, CHAN_VOICE, "weapons/spike2.wav", 1, ATTN_NORM);
		entity newmis = launch_spike(this, this.origin, this.movedir);
		newmis.velocity = this.movedir * 500;
		if(MP_ROGUE)
		{
			if(this.spawnflags & SPAWNFLAG_SUPERLAVA)
				settouch(newmis, superlavaspike_touch);
			else if((this.spawnflags & SPAWNFLAG_LAVASKILL) && skill > 1)
				settouch(newmis, superlavaspike_touch);
		}
		else if(this.spawnflags & SPAWNFLAG_SUPERSPIKE)
			settouch(newmis, superspike_touch);
	}
}

void shooter_think(entity this)
{
	if(!MP_HIPNOTIC || this.state)
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
	if(this.spawnflags & SPAWNFLAG_LASER)
	{
		precache_model2("progs/laser.mdl");
		
		precache_sound2("enforcer/enfire.wav");
		precache_sound2("enforcer/enfstop.wav");
	}
	else if(this.spawnflags & SPAWNFLAG_LAVABALL) // too early to bother checking for mission packs
	{
		precache_model("progs/lavarock.mdl");
//      this.classname = "fireball";
		precache_sound2("misc/spike.wav");
	}
	else if(this.spawnflags & SPAWNFLAG_ROCKET)
	{
		precache_model("progs/missile.mdl");
		precache_sound("weapons/sgun1.wav");
	}
	else if(this.spawnflags & SPAWNFLAG_LAVASPIKE)
	{
		precache_model2("progs/lspike.mdl");
		precache_sound2("lavagun/snail.wav");		// lava nail gun cooldown
		precache_sound2("weapons/rocket1i.wav");
	}
	else if(this.spawnflags & SPAWNFLAG_SUPERLAVA)
	{
		precache_model2("progs/lspike.mdl");
		precache_sound2("lavagun/snail.wav");		// lava nail gun cooldown
		precache_sound2("weapons/spike2.wav");
	}
	else if(this.spawnflags & SPAWNFLAG_LAVASKILL)
	{
		precache_model2("progs/lspike.mdl");
		precache_sound2("lavagun/snail.wav");		// lava nail gun cooldown
		precache_sound2("weapons/rocket1i.wav");
		precache_sound2("weapons/spike2.wav");
	}
	else if(this.spawnflags & SPAWNFLAG_FIREBALL)
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
	if(MP_HIPNOTIC)
		this.state = 1;
	this.nextthink = this.nextthink + this.wait + this.ltime;
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
	if(!MP_HIPNOTIC) { delete(this); return; }

	if(this.wait == 0)
		this.wait = 1;
//MED 11/01/96 added state capability
	this.nextthink = this.nextthink + this.wait + this.ltime;
	setthink(this, shooter_think);
	this.use = trap_shooter_use;

	spawnfunc_trap_spikeshooter(this);
}


/*
===============================================================================


===============================================================================
*/


void make_bubbles(entity this);
void bubble_remove(entity this, entity toucher);
void bubble_bob(entity this);

/*QUAKED air_bubbles(0 .5 .8)(-8 -8 -8)(8 8 8)

testing air bubbles
*/

spawnfunc(air_bubbles)
{
	if(deathmatch)
	{
		delete(this);
		return;
	}
	precache_model("progs/s_bubble.spr");
	this.nextthink = time + 1;
	setthink(this, make_bubbles);
}

void make_bubbles(entity this)
{
	entity bubble = spawn();
	_setmodel(bubble, "progs/s_bubble.spr");
	setorigin(bubble, this.origin);
	set_movetype(bubble, MOVETYPE_NOCLIP);
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 15';
	bubble.nextthink = time + 0.5;
	setthink(bubble, bubble_bob);
	settouch(bubble, bubble_remove);
	bubble.classname = "bubble";
	bubble.frame = 0;
	bubble.cnt = 0;
	setsize(bubble, '-8 -8 -8', '8 8 8');
	this.nextthink = time + random() + 0.5;
	setthink(this, make_bubbles);
}

void bubble_split(entity this)
{
	entity bubble = spawn();
	_setmodel(bubble, "progs/s_bubble.spr");
	setorigin(bubble, this.origin);
	set_movetype(bubble, MOVETYPE_NOCLIP);
	bubble.solid = SOLID_NOT;
	bubble.velocity = this.velocity;
	bubble.nextthink = time + 0.5;
	setthink(bubble, bubble_bob);
	settouch(bubble, bubble_remove);
	bubble.classname = "bubble";
	bubble.frame = 1;
	bubble.cnt = 10;
	setsize(bubble, '-8 -8 -8', '8 8 8');
	this.frame = 1;
	this.cnt = 10;
	if(this.waterlevel != 3)
		delete(this);
}

void bubble_remove(entity this, entity toucher)
{
	if(toucher.classname == this.classname)
	{
//		dprint("bump");
		return;
	}
	delete(this);
}

void bubble_bob(entity this)
{
	if(MP_ROGUE)
	{
		// PGM fix - 02/25/97 so bubbles won't go through walls
		float bubcont = pointcontents(this.origin);
		if(bubcont == CONTENT_SOLID)
		{
			delete(this);
			return;
		}
		// PGM fix - 02/25/97 so bubbles pop 2 seconds after leaving water
		else if(bubcont == CONTENT_EMPTY)
		{
			if(this.cnt < 16)
				this.cnt = 16;
		}
	}

	this.cnt = this.cnt + 1;
	if(this.cnt == 4)
		bubble_split(this);
	if(this.cnt == 20)
		delete(this);

	float rnd1 = this.velocity_x +(-10 +(random() * 20));
	float rnd2 = this.velocity_y +(-10 +(random() * 20));
	float rnd3 = this.velocity_z + 10 + random() * 10;

	if(rnd1 > 10)
		rnd1 = 5;
	if(rnd1 < -10)
		rnd1 = -5;
		
	if(rnd2 > 10)
		rnd2 = 5;
	if(rnd2 < -10)
		rnd2 = -5;
		
	if(rnd3 < 10)
		rnd3 = 15;
	if(rnd3 > 30)
		rnd3 = 25;
	
	this.velocity_x = rnd1;
	this.velocity_y = rnd2;
	this.velocity_z = rnd3;
		
	this.nextthink = time + 0.5;
	setthink(this, bubble_bob);
}

/*~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>
~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~*/

/*QUAKED viewthing(0 .5 .8)(-8 -8 -8)(8 8 8)

Just for the debugging level.  Don't use
*/

spawnfunc(viewthing)
{
	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_NOT;
	precache_model("progs/player.mdl");
	_setmodel(this, "progs/player.mdl");
}


/*
==============================================================================

SIMPLE BMODELS

==============================================================================
*/

void func_wall_use(entity this, entity actor, entity trigger)
{	// change to alternate textures
	this.frame = 1 - this.frame;
}

/*QUAKED func_wall(0 .5 .8) ?
This is just a solid wall if not inhibitted
*/
spawnfunc(func_wall)
{
	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_PUSH);	// so it doesn't get pushed by anything
	this.solid = SOLID_BSP;
	this.use = func_wall_use;
	_setmodel(this, this.model);
}


/*QUAKED func_illusionary(0 .5 .8) ?
A simple entity that looks solid but lets you walk through it.
*/
spawnfunc(func_illusionary)
{
	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_NOT;
	_setmodel(this, this.model);
	makestatic(this);
}

/*QUAKED func_episodegate(0 .5 .8) ? E1 E2 E3 E4
This bmodel will appear if the episode has allready been completed, so players can't reenter it.
*/
spawnfunc(func_episodegate)
{
	if(!(serverflags & this.spawnflags))
		return;			// can still enter episode

	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_PUSH);	// so it doesn't get pushed by anything
	this.solid = SOLID_BSP;
	this.use = func_wall_use;
	_setmodel(this, this.model);
}

/*QUAKED func_bossgate(0 .5 .8) ?
This bmodel appears unless players have all of the episode sigils.
*/
spawnfunc(func_bossgate)
{
	if((serverflags & 15) == 15)
		return;		// all episodes completed
	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_PUSH);	// so it doesn't get pushed by anything
	this.solid = SOLID_BSP;
	this.use = func_wall_use;
	_setmodel(this, this.model);
}

//============================================================================
/*QUAKED ambient_suck_wind(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_suck_wind)
{
	precache_sound("ambience/suck1.wav");
	ambientsound(this.origin, "ambience/suck1.wav", 1, ATTN_STATIC);
}

/*QUAKED ambient_drone(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_drone)
{
	precache_sound("ambience/drone6.wav");
	ambientsound(this.origin, "ambience/drone6.wav", 0.5, ATTN_STATIC);
}

/*QUAKED ambient_flouro_buzz(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_flouro_buzz)
{
	precache_sound("ambience/buzz1.wav");
	ambientsound(this.origin, "ambience/buzz1.wav", 1, ATTN_STATIC);
}
/*QUAKED ambient_drip(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_drip)
{
	precache_sound("ambience/drip1.wav");
	ambientsound(this.origin, "ambience/drip1.wav", 0.5, ATTN_STATIC);
}
/*QUAKED ambient_comp_hum(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_comp_hum)
{
	precache_sound("ambience/comp1.wav");
	ambientsound(this.origin, "ambience/comp1.wav", 1, ATTN_STATIC);
}
/*QUAKED ambient_thunder(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_thunder)
{
	precache_sound("ambience/thunder1.wav");
	ambientsound(this.origin, "ambience/thunder1.wav", 0.5, ATTN_STATIC);
}
/*QUAKED ambient_light_buzz(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_light_buzz)
{
	precache_sound("ambience/fl_hum1.wav");
	ambientsound(this.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
}
/*QUAKED ambient_swamp1(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_swamp1)
{
	precache_sound("ambience/swamp1.wav");
	ambientsound(this.origin, "ambience/swamp1.wav", 0.5, ATTN_STATIC);
}
/*QUAKED ambient_swamp2(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_swamp2)
{
	precache_sound("ambience/swamp2.wav");
	ambientsound(this.origin, "ambience/swamp2.wav", 0.5, ATTN_STATIC);
}

//============================================================================

void noise_think(entity this)
{
	this.nextthink = time + 0.5;
	_sound(this, 1, "enforcer/enfire.wav", 1, ATTN_NORM);
	_sound(this, 2, "enforcer/enfstop.wav", 1, ATTN_NORM);
	_sound(this, 3, "enforcer/sight1.wav", 1, ATTN_NORM);
	_sound(this, 4, "enforcer/sight2.wav", 1, ATTN_NORM);
	_sound(this, 5, "enforcer/sight3.wav", 1, ATTN_NORM);
	_sound(this, 6, "enforcer/sight4.wav", 1, ATTN_NORM);
	_sound(this, 7, "enforcer/pain1.wav", 1, ATTN_NORM);
}

/*QUAKED misc_noisemaker(1 0.5 0)(-10 -10 -10)(10 10 10)

For optimzation testing, starts a lot of sounds.
*/

spawnfunc(misc_noisemaker)
{
	precache_sound2("enforcer/enfire.wav");
	precache_sound2("enforcer/enfstop.wav");
	precache_sound2("enforcer/sight1.wav");
	precache_sound2("enforcer/sight2.wav");
	precache_sound2("enforcer/sight3.wav");
	precache_sound2("enforcer/sight4.wav");
	precache_sound2("enforcer/pain1.wav");
	precache_sound2("enforcer/pain2.wav");
	precache_sound2("enforcer/death1.wav");
	precache_sound2("enforcer/idle1.wav");

	this.nextthink = time + 0.1 + random();
	setthink(this, noise_think);
}
