#include "ai_minions.qh"

/*======================================================================
 MINIONS FUNCTIONS

 Minion Support functions
  Setup and update minion counters centralized to reduce errors
  monster_death_precheck remove from the counter (dying event)
  minion_voreling, minion_spider add to the counter (spawn event)
  
======================================================================*/

PRECACHE(Minions)
{
	precache_model("progs/proj_wraithegg.mdl");
	precache_model("progs/proj_shalegg.mdl");
	precache_model("progs/proj_wraithshell.mdl");
	precache_model("progs/proj_shalshell.mdl");

	precache_sound("wraith/bounce.wav");
	precache_sound("shalrath/bounce.wav");
}

//----------------------------------------------------------------------
void setup_minionsupport(entity this)
{
	// Reset all counters
	this.minion_active = true;
	this.minion_count = 0;
	this.minion_trigger = 0;

	// Setup default max counters (check for existing values)
	if(!this.minion_maxcount) this.minion_maxcount = MIN_MAXACTIVE;
	if(!this.minion_maxtrigger) this.minion_maxtrigger = MIN_MAXTRIGGER;
}

//----------------------------------------------------------------------
void update_minioncount(entity msource, float countupd)
{
	if(!msource.minion_active) return;
	// Add to the active minion counters (check range limits)
	msource.minion_count += countupd;
	if(msource.minion_count < 0) msource.minion_count = 0;
	if(msource.minion_count > msource.minion_maxcount)
		msource.minion_count = msource.minion_maxcount;

	// Check for trigger events (ignore death triggers)
	if(countupd > 0)
	{
		msource.minion_trigger += countupd;
		if(msource.minion_trigger >= msource.minion_maxtrigger)
		{
			msource.minion_trigger = 0;
			// Check for trigger event string?
			if(msource.miniontarget != "")
			{
				FOREACH_ENTITY_STRING(targetname, msource.miniontarget,
				{
					if(it.use)
						it.use(it, ((IS_PLAYER(msource)) ? msource : NULL), msource);
				});
			}
		}
	}
}

//----------------------------------------------------------------------
// Check if anymore minions can be spawned at the moment
//----------------------------------------------------------------------
int query_minionactive(entity msource)
{
	if(!msource.minion_active) return -1;
	return (msource.minion_count < msource.minion_maxcount);
}

//======================================================================
// Check if there is space to spawn a minion
// 
// Version 1 - use a touch trigger to detect players
// Version 2 - use a findradius command to find players
//======================================================================
void touch_minionspace(entity this, entity toucher)
{
	if(IS_PLAYER(toucher))
		this.aflag = true;
}

//----------------------------------------------------------------------
// Touch trigger version for detecting client/players too close
//----------------------------------------------------------------------
void setup_minionspace(entity this, vector org, vector minspace, vector maxspace)
{
	// Create a touch trigger if one does not exist
	if(!this.minion_test) this.minion_test = spawn();
	// reset all parameters
	set_movetype(this.minion_test, MOVETYPE_NONE);
	this.minion_test.solid = SOLID_TRIGGER;
	_setmodel(this.minion_test, "");
	this.minion_test.skin = this.minion_test.frame = 0;
	this.minion_test.flags = 0;

	// Move touch trigger to correct location
	setorigin(this.minion_test, org);
	setsize(this.minion_test, minspace, maxspace);
	// Enable touch function and reset collision flag
	settouch(this.minion_test, touch_minionspace);
	this.minion_test.aflag = false;
}

bool test_minionspace(entity this)
{
	// Quick exit if no touch entity exists
	if(!this.minion_test)
		return false;

	// Basic world collision test for origin/min/max of spawn
	if(pointcontents(this.minion_test.origin) != CONTENT_EMPTY) return false;
	if(pointcontents(this.minion_test.origin+'-16 -16 -24') != CONTENT_EMPTY) return false;
	if(pointcontents(this.minion_test.origin+'16 16 40') != CONTENT_EMPTY) return false;
	
	// Switch off touch function and check for collision
	settouch(this.minion_test, func_null);
	return !(this.minion_test.aflag);
}

//----------------------------------------------------------------------
// Findradius version for detecting client/players too close
//----------------------------------------------------------------------
bool find_minionspace(vector org)
{
	// Basic world collision test for origin/min/max of spawn
	if(pointcontents(org) != CONTENT_EMPTY) return false;
	if(pointcontents(org+'-16 -16 -24') != CONTENT_EMPTY) return false;
	if(pointcontents(org+'16 16 40') != CONTENT_EMPTY) return false;
	
	bool foundclient = true;
	// The player can cover crazy amount of distance very fast
	// Extend radius out further to catch running players
	entity minstuff = findradius(org, 128);
	while(minstuff)
	{
		if(IS_PLAYER(minstuff))
		{
			foundclient = false;
			break;
		}
		minstuff = minstuff.chain;
	}
	return foundclient;
}

/*======================================================================
 MINION EGGS
 * Spawns a projecile (egg) at the player
 * Wait for egg to bounce and settle
 * Spawn (rotating) minion inside egg and then explode
======================================================================*/
//void minion_spider(vector minion_org, entity minion_targ);
//void minion_scorpion(vector minion_org, entity minion_targ);
//void minion_voreling(vector minion_org, entity minion_targ);

//----------------------------------------------------------------------------
void Explode_Egg(entity this)
{
	// Remove egg and throw gibs up as minion grows
	_setmodel(this, "");
	if(random() > 0.5) // classname == "monster_wraith"
	{
		entity gib = ThrowGib(this, "progs/proj_wraithshell.mdl", rint(2+random()*4));
		gib.frame = 9;
	}
	else // classname == "monster_shalrath"
	{
		entity gib = ThrowGib(this, "progs/proj_shalshell.mdl", rint(2+random()*4));
		gib.frame = 9;
	}

	// Safely remove egg
	setthink(this, SUB_Remove);
	this.nextthink = time + 0.1;
}

entity minion_spawn(entity own, vector org, Monster mon)
{
	entity targ = own.enemy;

	if(!mon || mon == MON_Null || (mon.spawnflags & MONSTER_TYPE_DECOY))
		return NULL;

	update_minioncount(own, 1);

	entity monster = new(monster);
	monster.monsterdef = mon;
	monster.spawnfunc_checked = true;
	//monster.angles = own.angles;
	monster.enemy = targ;
	monster.minion_active = true;
	monster.solid = SOLID_SLIDEBOX;
	monster.flags = FL_MONSTER | FL_CLONE | FL_MINION; // TODO: clone is temporary to prevent monster counts being affected!

	if(mon.spawnflags & MONSTER_TYPE_SWIM) { monster.flags |= FL_SWIM; }
	if(mon.spawnflags & MONSTER_TYPE_FLY) { monster.flags |= FL_FLY; }

	if(monster.flags & FL_FLY)
		set_movetype(monster, MOVETYPE_NONE);
	else
		set_movetype(monster, MOVETYPE_STEP);

	if(!(monster.flags & FL_SWIM))
	{
		IL_PUSH(g_damagedbycontents, monster);
		monster.damagedbycontents	= true;
	}
	//setup_minionsupport(monster);

	// perform enemy-type specific loading
	// TODO: copy model from existing monster?
	setmodel(monster, mon.m_model);
	setsize(monster, mon.m_mins, mon.m_maxs);

	// TODO: zombie logic too messy to work with mr_setup for now!
	if(mon == MON_ZOMBIE)
	{
		monster.classname = "monster_zombie";
		//org += '0 0 32';
		monster.health = 60;
		monster.th_stand = zombie_stand1;
		monster.th_walk = zombie_walk1;
		monster.th_run = zombie_run1;
		monster.th_pain = zombie_pain;
		monster.th_die = zombie_die;
		monster.th_missile = zombie_missile;
		monster.target = string_null; // don't target anything!
	}
	mon.mr_setup(mon, monster);

	setorigin(monster, org);

	setcefc(monster, monster_customize);

	//if(!(mon.spawnflags & MONSTER_TYPE_FLY))
		//droptofloor(monster);

	monster.takedamage = DAMAGE_AIM;
	if(!monster.yaw_speed)
		monster.yaw_speed = 20;
	monster.view_ofs = '0 0 25';
	monster.use = monster_use;
	monster.max_health = monster.health;

	monster.nextthink = time;
	setthink(monster, FoundTarget);
	monster.owner = own;

	return monster;
}

//----------------------------------------------------------------------
// Once the egg has landed via Grenade Touch function
// The minion is spawned and the egg is set to explode
//----------------------------------------------------------------------
void Hatch_Egg(entity this)
{
	// Turn off touch function and any movement
	settouch(this, func_null);
	set_movetype(this, MOVETYPE_NONE);
	this.takedamage = DAMAGE_NO;
	this.velocity = '0 0 0';
	
	// Check if the egg can hatch? turn on collision
	// setup new bounds and extend upwards for testing
	setsize(this, '-24 -24 0', '24 24 40');
	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_TOSS);
	this.oldorigin = this.origin;
	this.origin_z = this.origin_z + 8;
	droptofloor(this);
	
	// Can the egg hatch yet? Solid content?
	tracebox(this.origin, this.mins, this.maxs, this.origin, MOVE_NOMONSTERS, this);
	if(trace_startsolid || pointcontents(this.origin) == CONTENT_SOLID)
	{
		this.origin = this.oldorigin;
		setthink(this, Hatch_Egg);
		this.nextthink = time + 1 + random();
		this.solid = SOLID_NOT;		// turn off again
		return;
	}

	// Setup spawn location for minion
	traceline(this.origin+'0 0 128', this.origin-'0 0 256', true, NULL);
	this.oldorigin = trace_endpos + '0 0 32';
	
	// Spawn minion inside of egg model
	// this.owner is re-assigned to minion to avoid shell gibs interacting
#if 0
	// TODO: cleaner hatching system
	if(this.owner.classtype == CT_MONWRAITH)
	{
		if(this.owner.spawnflags & MON_WRAITH_SCORPIONS) minion_scorpion(this.oldorigin, this.enemy);
		else minion_spider(this.oldorigin, this.enemy);
	}
	else if(this.owner.classtype == CT_MONSHAL)
		minion_voreling(this.oldorigin, this.enemy);
#endif
	entity minion = minion_spawn(this.owner, this.oldorigin, this.owner.monsterdef);
	this.owner = minion; // TODO?

	// Skip a couple of frames
	setthink(this, Explode_Egg);
	this.nextthink = time + 0.4;
}

void Egg_Touch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.solid == SOLID_TRIGGER)
		return;

	if(toucher.takedamage == DAMAGE_AIM && this.velocity != '0 0 0')
	{
		this.angles = vectoangles(this.mangle);
		this.angles_y = anglemods(this.angles_y + 180);
		this.velocity = -this.mangle;
		this.mangle = this.velocity;
		_sound(this, CH_WEAPON_SINGLE, ((random() > 0.5) ? "wraith/bounce.wav" : "shalrath/bounce.wav"), 1, ATTN_NORM);
		if(vdist(this.velocity, >, 100))
			this.nextthink = time + 1.5;
	}
	else
	{
		_sound(this, CH_WEAPON_SINGLE, ((random() > 0.5) ? "wraith/bounce.wav" : "shalrath/bounce.wav"), 1, ATTN_NORM);
		if(this.velocity == '0 0 0')
			this.avelocity = '0 0 0';
	}
}

//----------------------------------------------------------------------
// Work out direction speed of egg and then launch it!
//----------------------------------------------------------------------
void Create_Egg(entity this, vector eggofs)
{
	if(this.health < 1) return;

	// Turn towards player and drop the egg!
	makevectors(this.angles);
	vector org = this.origin + attack_vector(eggofs);
	float egg_speed = 200 + (random() * 50);
	vector dir = (v_forward * egg_speed) + (v_right * (crandom()* 50));
	entity missile = new(egg);
	missile.owner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	setorigin(missile, org);
	missile.solid = SOLID_BBOX;
	missile.mangle = dir;
	missile.velocity = missile.mangle;
	missile.avelocity = '0 0 0';
	missile.angles = vectoangles(missile.velocity);
	missile.enemy = this.enemy;
	settouch(missile, Egg_Touch);
	setthink(missile, Hatch_Egg);
	missile.nextthink = time + 1.5;
	if(random() > 0.5)
		_setmodel(missile, "progs/proj_wraithegg.mdl");
	else
		_setmodel(missile, "progs/proj_shalegg.mdl");
	setsize(missile, '-2 -2 -2', '2 2 2');
	this.attack_finished = time + 2 + random();
}
