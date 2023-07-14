#ifdef SVQC

#include "../../rogue/newplats.qh"

const int ELVTR_DOWN = BIT(0);

void elvtr_button_wait(entity this);
void elvtr_button_return(entity this);

void elvtr_button_wait(entity this)
{
	ELV_BUTN_DIR = 0;
	if(this.spawnflags & ELVTR_DOWN)
		ELV_BUTN_DIR = -1;
	else
		ELV_BUTN_DIR = 1;
		
	this.state = STATE_TOP;
	this.nextthink = this.ltime + this.wait;
	setthink(this, elvtr_button_return);
	SUB_UseTargets(this, this.enemy, NULL);;
	this.frame = 1;			// use alternate textures
}

void elvtr_button_done(entity this)
{
	this.state = STATE_BOTTOM;
}

void elvtr_button_return(entity this)
{
	this.state = STATE_DOWN;
	SUB_CalcMove(this, this.pos1, TSPEED_LINEAR, this.speed, elvtr_button_done);
	this.frame = 0;			// use normal textures
	if(this.health)
		this.takedamage = DAMAGE_YES;	// can be shot again
}

void elvtr_button_blocked(entity this, entity blocker)
{
	// do nothing, just don't come all the way back out
}

void elvtr_button_fire(entity this)
{
	if(this.state == STATE_UP || this.state == STATE_TOP)
		return;

	_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);

	this.state = STATE_UP;
	SUB_CalcMove(this, this.pos2, TSPEED_LINEAR, this.speed, elvtr_button_wait);
}

void elvtr_button_use(entity this, entity actor, entity trigger)
{
	this.enemy = actor;
	elvtr_button_fire(this);
}

void elvtr_button_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	this.enemy = toucher;
	elvtr_button_fire(this);
}

void elvtr_button_killed(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.enemy = attacker;
	this.health = this.max_health;
	this.takedamage = DAMAGE_NO;	// wil be reset upon return
	elvtr_button_fire(this);
}


/*QUAKED func_elvtr_button (0 .5 .8) ? ELVTR_DOWN
ELEVATOR BUTTON ONLY!

ELVTR_DOWN causes this to be a DOWN button.
Default is UP.

When a button is touched, it moves some distance in the direction of it's angle, triggers all of it's targets, waits some time, then returns to it's original position where it can be triggered again.

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
*/
spawnfunc(func_elvtr_button)
{
	if(!MP_ROGUE) { delete(this); return; }

	SetMovedir(this);
	if (!InitMovingBrushTrigger(this))
		return;

	switch(this.sounds)
	{
		case 0: this.noise = "buttons/airbut1.wav"; break;
		case 1: this.noise = "buttons/switch21.wav"; break;
		case 2: this.noise = "buttons/switch02.wav"; break;
		case 3: this.noise = "buttons/switch04.wav"; break;
	}

	if(this.noise != "")
        precache_sound(this.noise);

	setblocked(this, elvtr_button_blocked);
	this.use = elvtr_button_use;

	if(this.health)
	{
		this.max_health = this.health;
		this.th_die = elvtr_button_killed;
		this.takedamage = DAMAGE_YES;
	}
	else
		settouch(this, elvtr_button_touch);

	if(!this.speed)
		this.speed = 40;
	if(!this.wait)
		this.wait = 1;
	if(!this.lip)
		this.lip = 4;

	this.state = STATE_BOTTOM;

	this.pos1 = this.origin;
	this.pos2 = this.pos1 + this.movedir*(fabs(this.movedir*this.size) - this.lip);
}

#endif
