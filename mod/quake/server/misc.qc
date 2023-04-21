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

const float FRAME_TIME = 0.1;
void set_anim(entity this, int frm, void(entity) tnk)
{
	this.frame = frm;
	setthink(this, tnk);
	this.nextthink = time + FRAME_TIME;
}

void set_animofs(entity this, int frm, int offs, void(entity) tnk)
{
	int realoffset = offs - 1; // because frame1 should still look like frame1!
	set_anim(this, frm + realoffset, tnk);
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
	//_makestatic_hidden(this);
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
	bool allow_fire = true;
	if(MP_ROGUE && (this.spawnflags & 1))
		allow_fire = false;
	if(MP_IMPEL && (this.spawnflags & 2))
		allow_fire = false;
	if(allow_fire)
		FireAmbient(this);
	//_makestatic_hidden(this);
}

/*QUAKED light_flame_large_yellow(0 1 0)(-10 -10 -12)(12 12 18)
Large yellow flame ball
*/
spawnfunc(light_flame_large_yellow)
{
	precache_model("progs/flame2.mdl");
	_setmodel(this, "progs/flame2.mdl");
	this.frame = 1;
	bool allow_fire = true;
	if(MP_IMPEL && (this.spawnflags & 2))
		allow_fire = false;
	if(allow_fire)
		FireAmbient(this);
	//_makestatic_hidden(this);
}

/*QUAKED light_flame_small_yellow(0 1 0)(-8 -8 -8)(8 8 8) START_OFF
Small yellow flame ball
*/
spawnfunc(light_flame_small_yellow)
{
	precache_model("progs/flame2.mdl");
	_setmodel(this, "progs/flame2.mdl");
	bool allow_fire = true;
	if(MP_IMPEL && (this.spawnflags & 2))
		allow_fire = false;
	if(allow_fire)
		FireAmbient(this);
	//_makestatic_hidden(this);
}

/*QUAKED light_flame_small_white(0 1 0)(-10 -10 -40)(10 10 40) START_OFF
Small white flame ball
*/
spawnfunc(light_flame_small_white)
{
	precache_model("progs/flame2.mdl");
	_setmodel(this, "progs/flame2.mdl");
	bool allow_fire = true;
	if(MP_IMPEL && (this.spawnflags & 2))
		allow_fire = false;
	if(allow_fire)
		FireAmbient(this);
	//_makestatic_hidden(this);
}


void make_bubbles(entity this);
void bubble_remove(entity this, entity toucher);
void bubble_bob(entity this);

/*QUAKED air_bubbles(0 .5 .8)(-8 -8 -8)(8 8 8)

testing air bubbles
*/

spawnfunc(air_bubbles)
{
	if(deathmatch) { delete(this); return; }

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
	//_makestatic_hidden(this);
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
