#ifdef SVQC

const int ENT_STARTOFF = 64;	// Global spawnflags setting

const int FUNC_SKILLSTARTOPEN = 1;	// Reverse setup for lighting issues
const int FUNC_SKILLCHAOSMODE = 2;	// Check for chaos setup instead of skill
const int FUNC_SKILLSTARTDIS = 32;	// Pillar starts in disabled state

.string message2;

//======================================================================
/*QUAKED func_skill (0 .5 .8) ? STARTOPEN CHAOS x x STARTDIS STARTOFF x
A bmodel that changes texture based on current skill/chaos level
Will keep checking until triggered (based on door QC code)
-------- KEYS --------
targetname  : trigger entity (works with entity state system)
style       : Skill Level - 0 = easy, 1 = normal, 2 = hard, 3 = nightmare
message2    : Override message to display when bmodel is touched/damaged
target      : Particle emitters to switch on/off
target2     : target(s) to fire when touched/damaged
wait        : =-1 cannot be touched or damaged (visual only)
health      : Can be damaged instead of touched (def=touch)
angle       : movement direction for trigger event
speed       : movement speed (100 default)
lip         : lip remaining at end of move (def=8)
waitmin     : Chaos mode touch slowdown timer (def=1s)
noise1      : Custom sound - Stop moving (doors/drclos4.wav)
noise2      : Custom sound - Start/Loop moving (doors/stndr1.wav)
noise3      : Custom sound - Touching (plats/medplat2.wav)
volume      : Volume for all custom sounds played (def=1, range=0-1)
_dirt       : -1 = will be excluded from dirtmapping
_minlight   : Minimum light level for any surface of the brush model
_mincolor   : Minimum light color for any surface (def='1 1 1' RGB)
_shadow     : Will cast shadows on other models and itself
_shadowself : Will cast shadows on itself
-------- SPAWNFLAGS --------
STARTOPEN : bmodel works in reverse state (moved to dest at spawn)
CHAOSMODE : special setup for the random chaos mode (waitmin=touch delay)
STARTDIS  : Starts disabled and waits for trigger
STARTOFF  : Starts off and waits for trigger
-------- NOTES --------
Visual skill/chaos selection/update function

======================================================================*/

//----------------------------------------------------------------------
void func_skill_check(entity this)
{
	// If blocked by entity state system do nothing
	if(this.active != ACTIVE_ACTIVE) return;
	if(this.spawnflags & FUNC_SKILLCHAOSMODE) return;

	// Has the skill level been changed?
	if(this.lefty != autocvar_skill)
	{
		// Stop this entity constantly changing
		this.lefty = autocvar_skill;
		// Is the current skill level active?
		if(this.style == autocvar_skill)
			this.frame = 0;	// +0 frame (on)
		else
			this.frame = 1;						// A frame (off)									// Blank texture (off)
	}
	// Keep thinking/checking
	this.nextthink = time + 0.1;
	setthink(this, func_skill_check);
}

//----------------------------------------------------------------------
void func_skill_touch(entity this, entity toucher)
{
	// If blocked by entity state system do nothing
	if(this.active != ACTIVE_ACTIVE) return;
	if(!IS_PLAYER(toucher)) return;
	if(toucher.health < 1) return;
	if(this.spawnflags & FUNC_SKILLCHAOSMODE) return;

	// If skill level is changing, say so on console
	if(autocvar_skill != this.style)
	{
		if(this.message2 != "")
			sprint(toucher, this.message2);
		else
		{
			sprint(toucher,"Skill level ");
			if(this.style == 0) sprint(toucher,"EASY");
			else if(this.style == 1) sprint(toucher,"NORMAL");
			else if(this.style == 2) sprint(toucher,"HARD");
			else if(this.style == 3) sprint(toucher,"NIGHTMARE");
			sprint(toucher," has been selected!");
		}
		sprint(toucher,"\n");
		
		// Change skill level
		cvar_set("skill", ftos(this.style));
		
		// Force quick update
		func_skill_check(this);
		
		// Any toucher targets to fire when touch/damaged
		if(this.target2 != "")
		{
			FOREACH_ENTITY_STRING(targetname, this.target2,
			{
				if(it.use)
					it.use(it, ((IS_PLAYER(toucher)) ? toucher : NULL), toucher);
			});
		}
	}		
	
	// Play touch sound regardless of skill change
	if(this.pausetime < time)
	{
		_sound(this, CH_VOICE, this.noise3, this.volume, ATTN_NORM);
		this.pausetime = time + 1;	// No constant sound
	}	
}

//----------------------------------------------------------------------
void func_skill_killed(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.health = this.max_health;	// Reset health to original value
	// All other exceptions are in the touch function
	if(gettouch(this))
		gettouch(this)(this, attacker);
}

void func_skill_on(entity this)
{
	// Remove any start off / disable spawnflags
	this.spawnflags &= ~ENT_STARTOFF;
	this.spawnflags &= ~FUNC_SKILLSTARTDIS;
	
	this.active = ACTIVE_ACTIVE;
	// Check/Update state
	func_skill_check(this);
}

void func_skill_on_use(entity this, entity actor, entity trigger)
{
	func_skill_on(this);
}

//----------------------------------------------------------------------
void func_skill_finishmove(entity this)
{
	// Stop sound, ON and particles!
	_sound(this, CH_TRIGGER_SINGLE, this.noise1, this.volume, ATTN_NORM);
	// Need to reset local entity time, otherwise timer is broken
	// it because of the SUB_CalcMove function changes it
	this.ltime = time;
	this.active = ACTIVE_ACTIVE;
}

//----------------------------------------------------------------------
void func_skill_startmove(entity this, entity actor, entity trigger)
{
	// Trigger once functionality
	this.active = ACTIVE_BUSY;
	// Remove any start off / disable spawnflags
	this.spawnflags &= ~ENT_STARTOFF;
	this.spawnflags &= ~FUNC_SKILLSTARTDIS;
	// Play movement sound and move pillar into place
	_sound(this, CH_TRIGGER_SINGLE, this.noise2, this.volume, ATTN_NORM);
	SUB_CalcMove(this, this.pos2, TSPEED_LINEAR, this.speed, func_skill_finishmove);
}

//----------------------------------------------------------------------
void func_skill_disable(entity this)
{
	this.active = ACTIVE_IDLE;
	// Off texture (+A)
	this.frame = 1;
}

//----------------------------------------------------------------------
void func_skill_off(entity this)
{
	this.active = ACTIVE_NOT;
	// Off texture (+A)
	this.frame = 1;
}

//----------------------------------------------------------------------
spawnfunc(func_skill)
{
	if(!InitMovingBrushTrigger(this))
		return;

	// Setup default sounds if no custom sounds exist
	if(this.noise1 == "") this.noise1 = "doors/drclos4.wav";
	if(this.noise2 == "") this.noise2 = "doors/stndr1.wav";
	if(this.noise3 == "") this.noise3 = "plats/medplat2.wav";

	//Pre-cache all sounds
	precache_sound(this.noise1);	// stop sound (big clunk sound)
	precache_sound(this.noise2);	// moving sound (door moving)
	precache_sound(this.noise3);	// Touch sound

	this.mdl = this.model;
	SetMovedir(this);
	
	if(this.speed <= 0) this.speed = 100;	// Default movement speed
	if(this.lip <= 0) this.lip = 8;		// End movement distance
	if(this.waitmin <= 0) this.waitmin = 1;// Touch timeout for chaos

	//----------------------------------------------------------------------
	// New random chaos mode
	settouch(this, func_skill_touch);
	// Check for negative skill values? skill 4+ = Evil Mode
	if(this.style < 0) this.style = 0;
	this.lefty = cvar("skill");			// Read current setting
	if(this.style != this.lefty) this.frame = 1;	// +A (off)
	else this.frame = 0;							// +0 (on)
	// Always check first time
	this.lefty = -1;
	
	//----------------------------------------------------------------------
	// Add bmodel to world and work out movement positions
	this.solid = SOLID_BSP;
	set_movetype(this, MOVETYPE_PUSH);
	_setmodel(this, this.mdl);
	setorigin(this, this.origin);	
	setsize(this, this.mins , this.maxs);
	this.pos1 = this.origin;
	this.pos2 = this.pos1 + this.movedir*(fabs(this.movedir*this.size) - this.lip);
	
	// Check for spawning conditions (coop, no NM check)
	// Needs to exist after entity has been added to work for BSPorigin
	//if(check_coop()) return;

	//----------------------------------------------------------------------
	// FUNC_SKILL_START_OPEN is design is hide a skill pillar
	// until it is triggered (nightmare skill)
	if(this.spawnflags & FUNC_SKILLSTARTOPEN)
	{
		setorigin (this, this.pos2);
		this.pos2 = this.pos1;
		this.pos1 = this.origin;
		// Start open always starts disabled
		this.spawnflags |= FUNC_SKILLSTARTDIS;
		this.active = ACTIVE_ACTIVE;
		// Wait for trigger to start moving into place
		this.use = func_skill_startmove;
	}
	// Default trigger/use (Turn on)
	else
	{
		this.use = func_skill_on_use;
		this.active = ACTIVE_IDLE;
	}

	// Check for notouch+damage, damage only or touch only
	// The visual only version has to be checked first
	if(this.wait < 0)
	{
		this.health = this.max_health = 0;
		this.th_die = func_null;
		this.takedamage = DAMAGE_NO;
		settouch(this, func_null);
	}
	else if(this.health != 0)
	{
		this.health = this.max_health = 1;
		this.th_die = func_skill_killed;
		this.takedamage = DAMAGE_YES;
		settouch(this, func_null);
	}
	else
	{
		this.health = this.max_health = 0;
		this.th_die = func_null;
		this.takedamage = DAMAGE_NO;
	}

	// Wait for particle emitter entities to spawn
	this.nextthink = time + 0.1 + random()*0.2;
	if(this.spawnflags & FUNC_SKILLSTARTDIS)
		setthink(this, func_skill_disable);
	else if(this.spawnflags & ENT_STARTOFF)
		setthink(this, func_skill_off);
	else
		setthink(this, func_skill_on);
}

#endif
