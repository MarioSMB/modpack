#include "button.qh"

#ifdef SVQC

const int BUTTON_KEY_ALWAYS_REQUIRED = 32;

// button and multiple button

void button_return(entity this);

void button_wait(entity this)
{
	this.state = STATE_TOP;
	this.nextthink = this.ltime + this.wait;
	setthink(this, button_return);
	this.frame = 1;			// use alternate textures
	if(this.customflags & CFL_LOCKED)
		return;
	if(!SUB_UseTargets_CopperAlt(this, this.enemy, NULL, BIT(1) | BIT(3) | BIT(4)))
		SUB_UseTargets(this, this.enemy, NULL);
}

void button_done(entity this)
{
	this.frame = 0; // use normal textures
	this.state = STATE_BOTTOM;
	if(this.customflags & CFL_LOCKED)
		return;
	SUB_UseTargets_CopperAlt(this, this.enemy, NULL, BIT(1) | BIT(2) | BIT(3));
}

void button_return(entity this)
{
	if(this.customflags & CFL_LOCKED)
		return;
	this.state = STATE_DOWN;
	SUB_CalcMove(this, this.pos1, TSPEED_LINEAR, this.speed, button_done);
	this.frame = 0;			// use normal textures
	if(this.health)
		this.takedamage = DAMAGE_YES;	// can be shot again
	SUB_UseTargets_CopperAlt(this, this.enemy, NULL, BIT(1) | BIT(2) | BIT(4));
}

void button_blocked(entity this, entity blocker)
{
	// do nothing, just don't come all the way back out
}

void button_fire(entity this)
{
	if(this.customflags & CFL_LOCKED)
		return;
	if(this.state == STATE_UP || this.state == STATE_TOP)
		return;

	if(this.items)
	{
		_sound(this, CH_TRIGGER_SINGLE, this.noise4, 1, ATTN_NORM);
		if(!(this.spawnflags & BUTTON_KEY_ALWAYS_REQUIRED))
			this.items = 0;
	}

	if(this.noise && this.noise != "")
		_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);

	SUB_UseTargets_CopperAlt(this, this.enemy, NULL, BIT(2) | BIT(3) | BIT(4));

	this.state = STATE_UP;
	SUB_CalcMove(this, this.pos2, TSPEED_LINEAR, this.speed, button_wait);
}

void button_use(entity this, entity actor, entity trigger)
{
	if(this.customflags & CFL_LOCKED)
		return;
	if(this.state == STATE_UP || this.state == STATE_DOWN)
		return;
	this.enemy = actor;
	button_fire(this);
}

void button_touch(entity this, entity toucher)
{
	if(this.customflags & CFL_LOCKED)
		return;
	if(!IS_PLAYER(toucher) || toucher.health <= 0)
		return;
	if(this.items)
	{
		if(time < this.attack_finished)
			return;
		this.attack_finished = time + 2;

		if((this.items & toucher.items) != this.items)
		{
			_sound(this, CH_TRIGGER_SINGLE, this.noise3, 1, ATTN_NORM);
			if(this.items == IT_KEY1)
			{
				if(this.worldtype == WORLDTYPE_BASE)
					centerprint(toucher, "You need the silver keycard");
				else if(this.worldtype == WORLDTYPE_METAL)
					centerprint(toucher, "You need the silver runekey");
				else if(this.worldtype == WORLDTYPE_MEDIEVAL || this.worldtype == WORLDTYPE_HUB)
					centerprint(toucher, "You need the silver key");
			}
			else if(this.items == IT_KEY2)
			{
				if(this.worldtype == WORLDTYPE_BASE)
					centerprint(toucher, "You need the gold keycard");
				else if(this.worldtype == WORLDTYPE_METAL)
					centerprint(toucher, "You need the gold runekey");			
				else if(this.worldtype == WORLDTYPE_MEDIEVAL || this.worldtype == WORLDTYPE_HUB)
					centerprint(toucher, "You need the gold key");
			}
			else if(this.items == IT_KEY3)
			{
				if(this.worldtype == WORLDTYPE_BASE)
					centerprint(toucher, "You need the platinum keycard");
				else if(this.worldtype == WORLDTYPE_METAL)
					centerprint(toucher, "You need the platinum runekey");			
				else if(this.worldtype == WORLDTYPE_MEDIEVAL || this.worldtype == WORLDTYPE_HUB)
					centerprint(toucher, "You need the platinum key");
			}
			return;
		}
		else
		{
			// Yoder Sept24, 2021 Horde merge
			if(horde_ent || autocvar_sv_quake_globalkeys)
			{
				horde_key_spend(this.items);
				settouch(this, func_null);
			}
			else // standard behaviour
				toucher.items &= ~this.items;
		}
	}
	this.enemy = toucher;
	button_fire(this);
}

void button_killed(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(this.customflags & CFL_LOCKED)
		return;
	this.enemy = attacker;
	this.health = this.max_health;
	this.takedamage = DAMAGE_NO;	// wil be reset upon return
	button_fire(this);
}

void button_done_unlock(entity this)
{
	button_done(this);
	this.customflags &= ~CFL_LOCKED;
}

void button_lock(entity this, bool unlock)
{
	if(unlock)
	{
		if(this.max_health)
		{
			this.takedamage = DAMAGE_YES;
			this.health = this.max_health;
		}
		this.frame = 0; // use normal textures
		this.state = STATE_DOWN;
		SUB_CalcMove(this, this.pos1, TSPEED_LINEAR, this.speed, button_done_unlock);
	}
	else
	{
		this.customflags |= CFL_LOCKED;
		if(this.max_health)
			this.takedamage = DAMAGE_NO;
		this.state = STATE_UP;
		SUB_CalcMove(this, this.pos2, TSPEED_LINEAR, this.speed, button_wait);
	}
}

void button_sounds(entity this)
{
	if(this.sounds == 0)
		this.noise = "buttons/airbut1.wav";
	else if(this.sounds == 1)
		this.noise = "buttons/switch21.wav";
	else if(this.sounds == 2)
		this.noise = "buttons/switch02.wav";
	else if(this.sounds == 3)
		this.noise = "buttons/switch04.wav";
	else if(this.sounds == 4)
		this.noise = "misc/trigger1.wav";
	precache_sound(this.noise);
}


/*QUAKED func_button(0 .5 .8) ?
When a button is touched, it moves some distance in the direction of it's angle, triggers all of it's targets, waits some time, then returns to it's original position where it can be triggered again.

"angle"		determines the opening direction
"target"	all entities with a matching targetname will be used
"speed"		override the default 40 speed
"wait"		override the default 1 second wait(-1 = never return)
"lip"		override the default 4 pixel lip remaining at end of move
"health"	if set, the button must be killed instead of touched
"sounds"
0) steam metal
1) wooden clunk
2) metallic click
3) in-out
*/
void func_button_init(entity this, entity actor, entity trigger);
spawnfunc(func_button)
{
	if(this.movedir != '0 0 0')
		this.have_mg_movedir = true;
	SetMovedir(this);
	if(!InitMovingBrushTrigger(this))
		return;
	button_sounds(this);

	if(!this.speed)
		this.speed = 40;
	if(!this.wait)
		this.wait = 1;
	if(!this.lip)
		this.lip = 4;

	if(this.noise != "")
        precache_sound(this.noise);

	this.state = STATE_BOTTOM;

	SUB_SetWorldtype(this);

	if(this.worldtype ==  WORLDTYPE_MEDIEVAL || this.worldtype == WORLDTYPE_HUB)
	{
		precache_sound("doors/medtry.wav");
		precache_sound("doors/meduse.wav");
		this.noise3 = "doors/medtry.wav";
		this.noise4 = "doors/meduse.wav";
	}
	else if(this.worldtype == WORLDTYPE_METAL)
	{
		precache_sound("doors/runetry.wav");
		precache_sound("doors/runeuse.wav");
		this.noise3 = "doors/runetry.wav";
		this.noise4 = "doors/runeuse.wav";
	}
	else if(this.worldtype == WORLDTYPE_BASE)
	{
		precache_sound("doors/basetry.wav");
		precache_sound("doors/baseuse.wav");
		this.noise3 = "doors/basetry.wav";
		this.noise4 = "doors/baseuse.wav";
	}

	if(this.spawnflags & DOOR_SILVER_KEY)
		this.items = IT_KEY1;
	else if(this.spawnflags & DOOR_GOLD_KEY)
		this.items = IT_KEY2;
	else if(this.spawnflags & DOOR_PLAT_KEY)
		this.items = IT_KEY3;

	if(this.spawnflags & 128)
		this.use = func_button_init;
	else
		func_button_init(this, NULL, NULL);
}

void func_button_init(entity this, entity actor, entity trigger)
{
	setblocked(this, button_blocked);
	this.use = button_use;
	this.lock = button_lock;

	if(this.health)
	{
		this.max_health = this.health;
		this.th_die = button_killed;
		this.takedamage = DAMAGE_YES;
	}
	else
		settouch(this, button_touch);

	if(this.have_mg_movedir)
	{
		this.pos1 = this.origin;
		this.pos2 = this.pos1 + this.movedir;
		this.angles = '0 0 0';
	}
	else
	{
		if(!this.distance)
			this.distance = fabs(this.movedir * this.size) - this.lip;
		this.pos1 = this.origin;
		this.pos2 = this.pos1 + this.movedir * this.distance;
	}

	if(this.customflags & CFL_LOCKED)
		button_lock(this, false);
}

/*
===========================================
SKILL BUTTON

special button that has to react to other skill buttons being pressed, 
and the skill cvar changing at the console, and not be stupid about it

supports door fade lighting
hides like a locked button but doesn't count as locked status
registers itself with a global ent as a skill entity, chains itself
startframe checks for cvar change and walks the chain flipping status
===========================================
*/
entity skill_head;

void skillbutton_hit_top(entity this);
void skillbutton_hit_bottom(entity this);
void skillbutton_go_up(entity this)
{
	if(this.state == STATE_UP || this.state == STATE_TOP)
		return;
	
	float spd;
	this.state = STATE_UP;
	this.frame = 1;
	if(this.max_health)
		this.takedamage = DAMAGE_NO;
	
	if(time < 1.2)
		spd = 9999999;
	else
	{
		if(this.noise && this.noise != "")
			_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
		spd = this.speed;
	}

	SUB_CalcMoveLight(this, this.pos1, this.pos2, spd, skillbutton_hit_top, false);

	SUB_UseTargets_CopperAlt(this, NULL, NULL, BIT(2) | BIT(3) | BIT(4));
}

void skillbutton_hit_top(entity this)
{
	this.state = STATE_TOP;
	if(!SUB_UseTargets_CopperAlt(this, NULL, NULL, BIT(1) | BIT(3) | BIT(4)))
		SUB_UseTargetsSilent(this, NULL, NULL);
	bmodel_lightstyle(this, 0);
	
	// special message handling:
	// one button will always be set at map start, and we don't want a mystery message
	// printing when the start map loads announcing the skill you already have set at
	// the console
	if(this.enemy && IS_PLAYER(this.enemy))
	{
		centerprint_proximity(this.enemy, process_string(this.message), this);
		this.enemy = NULL;
	}
}

void skillbutton_go_down(entity this)
{
	if(this.state == STATE_DOWN || this.state == STATE_BOTTOM)
		return;
	
	float spd;
	this.state = STATE_DOWN;
	this.enemy = NULL;
	
	if(time < 1.2)
		spd = 9999999;
	else
		spd = this.speed2;
	
	SUB_CalcMoveLight(this, this.pos2, this.pos1, spd, skillbutton_hit_bottom, true);

	SUB_UseTargets_CopperAlt(this, NULL, NULL, BIT(1) | BIT(2) | BIT(4));
}

void skillbutton_hit_bottom(entity this)
{
	this.state = STATE_BOTTOM;
	this.frame = 0;	
	bmodel_lightstyle(this, 1);
	if(this.max_health)
	{
		this.takedamage = DAMAGE_YES;
		this.health = this.max_health;
	}
	SUB_UseTargets_CopperAlt(this, NULL, NULL, BIT(1) | BIT(2) | BIT(3));
}

.float strength;
void skillbutton_activate(entity this)
{
	bool match = ((autocvar_skill == this.strength) || (ftos(autocvar_skill) == this.netname));
	
	if(match)
		skillbutton_go_up(this);
	else
		skillbutton_go_down(this);
}

void skillbutton_touch(entity this, entity toucher)
{
	if(this.state != STATE_BOTTOM)
		return;
	this.enemy = toucher;
	cvar_set("skill", this.netname);
}
void skillbutton_use(entity this, entity actor, entity trigger)
{
	this.enemy = actor;
	cvar_set("skill", this.netname);
}
void skillbutton_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.enemy = attacker;
	cvar_set("skill", this.netname);
}

float skillbutton_skill;
void skillbutton_frame()
{
	float sk = autocvar_skill;
	if(sk != skillbutton_skill)
	{
		skillbutton_skill = sk;
		entity skbtn = skill_head;
		while(skbtn)
		{
			LOG_DEBUG("activating skillbutton from startframe");
			skillbutton_activate(skbtn);
			skbtn = skbtn.owner;
		}
	}
}


/*QUAKED func_button_skill (0 .5 .8) ? EASY NORMAL HARD NIGHTMARE SILENT
Special button for selecting skill level. Will always be pressed when the skill corresponding to the chosen spawnflag is set. Changes its state automatically when other skill buttons are pressed, when trigger_setskills are touched, or when skill is changed live at the console.

"message"	override message printed to clients when button is touched or used (or use SILENT spawnflag for no message)
"angle"		determines the opening direction
"target"	all entities with a matching targetname will be used
"speed"		override the default 40 speed
"wait"		override the default 1 second wait (-1 = never return)
"lip"		override the default 4 pixel lip remaining at end of move
"health"	if set, the button must be killed instead of touched
"sounds"
0) steam metal
1) wooden clunk
2) metallic click
3) in-out
4) trigger noise (big light switch)

Alt Target Pattern: 'target' when touched, 'target2' when fully depressed, 'target3' when returning, 'target4' when fully out.
*/
/*FGD
@SolidClass base(Appearflags, Angle, Target, Func, AltTarget) = func_button_skill : 
"Special button for selecting skill level. Will always be pressed when the skill corresponding to the chosen spawnflag is set. Changes its state automatically when other skill buttons are pressed, when trigger_setskills are touched, or when skill is changed live at the console.

Alt Target Pattern: 'target' when touched, 'target2' when fully depressed, 'target3' when returning, 'target4' when fully out." 
[
	spawnflags(Flags) = [
		1 : "Easy" : 0
		2 : "Normal" : 1
		4 : "Hard" : 0
		8 : "Nightmaaare" : 0
		16 : "No centerprint" : 0
	]
	speed(integer) : "Speed" : 40
	health(integer) : "Health (shootable if > 0)"
	lip(integer) : "Lip remaining at end of move" : 4
	distance(string) : "Distance to travel (overrides Lip)" : "0.0"
	sounds(choices) : "Sounds" = 
	[
		-1 : "None/Custom (set 'noise')"
		0 : "Steam metal"
		1 : "Wooden clunk"
		2 : "Metallic clink"
		3 : "In-out"
		4 : "Trigger noise (big light switch)"
	]
	message(string) : "Override skill selected message" 
	noise(string) : "Wav to play if sounds is -1" 
]
*/
spawnfunc(func_button_skill)
{
	button_sounds(this);
	SetMovedir(this);

	if(!this.speed)
		this.speed = 40;
	if(!this.speed2)
		this.speed2 = this.speed;
	if(!this.lip)
		this.lip = 4;

	if(skill_head)
		this.owner = skill_head;
	skill_head = this;

	if(this.style || this.switchshadstyle)
	{
		if(this.style < 0)
		{
			this.style *= -1;
			this.customflags |= CFL_INVLIGHT;
		}
		bmodel_lightstyle(this, 1);
	}
	
	this.state = STATE_BOTTOM;
	set_movetype(this, MOVETYPE_PUSH);
	this.solid = SOLID_BSP;
	_setmodel(this, this.model);
	if(!this.distance)
		this.distance = fabs(this.movedir*this.size) - this.lip;
	this.pos1 = this.origin;
	this.pos2 = this.pos1 + this.movedir * this.distance;

	setblocked(this, button_blocked);
	this.use = skillbutton_use;

	if(this.health)
	{
		this.max_health = this.health;
		this.th_die = skillbutton_die;
		this.takedamage = DAMAGE_YES;
	}
	else
		settouch(this, skillbutton_touch);

	if(this.spawnflags & 1)
	{
		this.strength = 0;
		this.netname = "0";
	}
	else if(this.spawnflags & 4)
	{
		this.strength = 2;
		this.netname = "2";
	}
	else if(this.spawnflags & 8)
	{
		this.strength = 3;
		this.netname = "3";
	}
	else	// 2 or default
	{
		this.strength = 1;
		this.netname = "1";
	}

	if(this.spawnflags & 16)	// silent
		this.message = string_null;
	else if(this.message == string_null)
	{
		if(this.spawnflags & 1)
			this.message = "EASY skill selected";
		else if(this.spawnflags & 4)
			this.message = "HARD skill selected";
		else if(this.spawnflags & 8)
			this.message = "\bNIGHTMARE\b skill selected";
		else	// 2 or default
			this.message = "NORMAL skill selected";
	}

	setthink(this, skillbutton_activate);	// assume correct position and set up any related target states
	this.nextthink = this.ltime + 0.2;
}

#endif
