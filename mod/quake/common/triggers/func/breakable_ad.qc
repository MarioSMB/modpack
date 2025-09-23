#include "breakable_ad.qh"

#ifdef SVQC

/*
===============================================================================
func_breakable - ADHD (arcane dimensions) edition
===============================================================================
*/

//=============================================================================
/*QUAKED func_breakable (0 .5 .8) ? STARTOFF NODAMAGE EXPLOSION SILENT DAMAGE NOMOSTER NOSOUND NOROTATE Not_Easy Not_Normal Not_Hard Not_DM
Spawn breakable objects from a bmodel
-------- KEYS --------
target     : targets to fire when breakable is dead/used (only used once)
target2    : Additional trigger function (need target to be defined as well)
style      : pre-defined sound/model types - 1=rock, 2=wood, 3=glass, 4=metal, 5=brick, 6=flesh, 10=custom
brksound   : Initial breaking sound type (override style default)
brkimpsound : Impact sound type (override style default)
brkobjects : Breakable object model type (10-15=rocks, 20-22=woods, 30-32=glass, 40-42=metals, 50-54=brick, 60-62=flesh)
noise     : Initial breaking sound (unique sound file)
noise1    : Custom Rubble Impact sounds (unique sound files, must have 1 defined)
noise2    : Custom Rubble Impact sound 2
noise3    : Custom Rubble Impact sound 3
noise4    : Custom Rubble Impact sound 4
brkobj1   : Custom Rubble bmodel objects (unique models, must have 1 defined)
brkobj2   : Custom Rubble bmodel objects 2
brkobj3   : Custom Rubble bmodel objects 3
brkobj4   : Custom Rubble bmodel objects 4
health    : amount of damage to take before breaking (def 1)
count     : minimum quantity to spawn (def 4)
cnt       : random quantity to spawn (def 4) =-1 no random qty
dmg       : explosive radius damage (emits from center of func object)
pos1      : x=start particle colour, y=random range, z=quantity
brkvelbase : Base amount for velocity of broken parts (def "50 50 100")
brkveladd : Random additions for velocity of broken parts (def "100 100 150")
brkavel   : Amount of breaking object angle velocity (def 200)
brkfade   : Fade time before rubble fades away (def 4+random()x4)
brkmondmg : Damage multiplier for monster damage against breakable
angles    : direction to throw rubble (override default = impact direction)
brkgravity     : Change the gravity for rubble, useful for underwater (Value = 0-1)
brktrigjump    : Trigger if damaged by jumping monster attack (-1/1=active)
brktrigmissile : Trigger if damaged by rocket/grenade/shalball/radiusdmg (-1/1=active)
brktrignoplayer: No player/clients can damage this breakable
brkdelaydamage : Time pause before enabling damage on this breakable
_dirt       : -1 = will be excluded from dirtmapping
_minlight   : Minimum light level for any surface of the brush model
_mincolor   : Minimum light color for any surface (def='1 1 1' RGB)
_shadow     : Will cast shadows on other models and itself
_shadowself : Will cast shadows on itself
-------- SPAWNFLAGS --------
STARTOFF  : Will wait for trigger to spawn
NODAMAGE  : Cannot be damaged or shot, trigger only
EXPLOSION : trigger sprite/particle explosion
SILENT    : No initial breakage sound
DAMAGE    : Spawning rubble can damage (def = 2, use dmg key for touch damage)
NOMONSTER : Monsters cannot damage this breakable and/or spawning rubble will not damage monsters
NOSOUND   : Spawning rubble has no impact sounds
NOROTATE  : Spawning rubble has No Y rotation
-------- NOTES --------
Spawn breakable ojects from a bmodel
*/

//=============================================================================
/*QUAKED func_breakable_spawner (0.5 .5 .8) (-8 -8 -8) (8 8 8) x x EXPLOSION SILENT DAMAGE NOMOSTER NOSOUND NOROTATE Not_Easy Not_Normal Not_Hard Not_DM
Spawn breakable objects from a single point
-------- KEYS --------
target     : targets to fire when breakable is dead/used (only used once)
target2    : Additional trigger function (need target to be defined as well)
style      : pre-defined sound/model types - 1=rock, 2=wood, 3=glass, 4=metal, 5=brick, 6=flesh, 10=custom
brksound   : Initial breaking sound type (override style default)
brkimpsound: Impact sound type (override style default)
brkobjects : Breakable object model type (10-15=rocks, 20-22=woods, 30-32=glass, 40-42=metals, 50-54=brick, 60-62=flesh)
noise      : Initial breaking sound (unique sound file)
noise1    : Custom Rubble Impact sounds (unique sound files, must have 1 defined)
noise2    : Custom Rubble Impact sound 2
noise3    : Custom Rubble Impact sound 3
noise4    : Custom Rubble Impact sound 4
brkobj1   : Custom Rubble bmodel objects (unique models, must have 1 defined)
brkobj2   : Custom Rubble bmodel objects 2
brkobj3   : Custom Rubble bmodel objects 3
brkobj4   : Custom Rubble bmodel objects 4
health    : amount of damage to take before breaking (def 1)
count     : minimum quantity to spawn (def 4)
cnt       : random quantity to spawn (def 4) =-1 no random qty
dmg       : explosive radius damage (emits from center of func object)
pos1      : x=start particle colour, y=random range, z=quantity
brkvelbase: Base amount for velocity of broken parts (def "50 50 100")
brkveladd : Random additions for velocity of broken parts (def "100 100 150")
brkavel   : Amount of breaking object angle velocity (def 200)
brkfade   : Fade time before rubble fades away (def 4+random()x4)
angles    : direction to throw rubble (override default = impact direction)
brkgravity     : Change the gravity for rubble, useful for underwater (Value = 0-1)
brktrigjump    : Trigger if damaged by jumping monster attack (-1/1=active)
brktrigmissile : Trigger if damaged by rocket/grenade/shalball/radiusdmg (-1/1=active)
brktrignoplayer: No player/clients can damage this breakable
brkdelaydamage : Time pause before enabling damage on this breakable
brkvol      : Spawning volume vector for breakable point entity
_dirt       : -1 = will be excluded from dirtmapping
_minlight   : Minimum light level for any surface of the brush model
_mincolor   : Minimum light color for any surface (def='1 1 1' RGB)
_shadow     : Will cast shadows on other models and itself
_shadowself : Will cast shadows on itself
-------- SPAWNFLAGS --------
EXPLOSION : trigger sprite/particle explosion
SILENT    : No initial breakage sound
DAMAGE    : Spawning rubble can damage (def = 2, use dmg key for touch damage)
NOMONSTER : Spawning rubble will not damage monsters
NOSOUND   : Spawning rubble has no impact sounds
NOROTATE  : Spawning rubble has No Y rotation
-------- NOTES --------
Spawn breakable ojects from a single point
*/

//----------------------------------------------------------------------
//======================================================================
// model_fade : Gradually fade out a model over time 
// * Optionally entity removal if height = 0
//
//----------------------------------------------------------------------
void model_fade(entity this)
{
    this.alpha = 1 - ((time - this.ltime) / 1);

    if(this.alpha > 1)
    	this.alpha = 1;
    else if(this.alpha <= 0)
    {
        this.alpha = 0;
		this.modelindex = 0;	// Make sure no model
        this.model = "";
        this.solid = SOLID_NOT;
        // Remove model by default
        if(this.height == 0)
        {
			setthink(this, SUB_Remove);
			this.nextthink = time + 1;
 		}
        return;
    }

    this.nextthink = time + 0.01;
}

void breakable_remove(entity this)
{
	setthink(this, model_fade);
	this.nextthink = time + 0.1;
	this.ltime = this.nextthink;
}

//----------------------------------------------------------------------
void breakable_checkfloor(entity this)
{
	// Is it time for the breakable to fade away?
	if(this.pain_finished > time)
	{
		// NOTE: disabled as this is a waste of resources when the object is already bouncing
		// Check floor below breakable (global function)
		// Origin at base of model + 16 (typical step height)
		//ent_floorcheck(this, FLOOR_TRACE_BREAK);

		// Keep checking
		setthink(this, breakable_checkfloor);
		this.nextthink = time + 0.1;
	}
	else
		breakable_remove(this);
}

//----------------------------------------------------------------------
void breakable_particle(entity this)
{
	// Are particles disabled? has the model touched something?
	if(this.wait)
	{
		// Is there any time left to setup floor checks
		if(this.pain_finished > time + 0.1)
			setthink(this, breakable_checkfloor);
		else
			setthink(this, breakable_remove);
		this.nextthink = time + 0.1;
	}
	else
	{
		// Add a bit of randomness to the particles generated
		if(random() < 0.5)
			this.nextthink = time + 0.01;
		else
			this.nextthink = time + 0.02;
		particle(this.origin, this.oldorigin, rint(this.pos1_x + random() * this.pos1_y), this.pos1_z);
		// Check for removal timer
		if(this.pain_finished < time)
			setthink(this, breakable_remove);
	}
}

//----------------------------------------------------------------------
void breakable_touch(entity this, entity toucher)
{
	if(toucher.classname == "func_void" || pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	if(toucher.classname == "rubble")
		return;	// Ignore other breakables
	if(toucher.solid == SOLID_TRIGGER)
		return;		// Ignore trigger fields
	this.wait = true;	// No more particles

	if(this.count < 1)
	{
		settouch(this, func_null);				// no more touching
		this.solid = SOLID_NOT;				// Turn off world interaction
		this.avelocity = '0 0 0';			// Stop any velocity rotation
	}
	else
	{
		// Does the spawning rubble hurt?
		if(this.owner.spawnflags & BREAK_DAMAGE)
		{
			if(toucher.takedamage)
			{
				// Spawnflag BREAK_NOMONSTER = 32;  (No damage to monsters from rubble)
				// Was originally about monsters being immune to spawning rubble
				// This has changed over time to mean NO monster damage to breakable
				// The original intention is still active and really meant for
				// breakable spawners which don't have a bmodel component.
				// The ability for breakable rubble to injure monsters is not a major
				// feature and the no monster damage is more important.
				// 
				if(IS_MONSTER(toucher) && (this.owner.spawnflags & BREAK_NOMONSTER))
					{ /* do nothing */ }
				else
					T_Damage(toucher, this, this, this.owner.dmg, DEATH_TRAP.m_id);
			}
		}
		this.count -= 1;
		if(!(this.owner.spawnflags & BREAK_NOSOUND))
		{
			// Randomize impact sound
			this.lip = random() * this.owner.brkimpqty;
			if(this.lip < 1)
				_sound(this, CH_TRIGGER_SINGLE, this.owner.noise1, 1, 2);
			else if(this.lip < 2)
				_sound(this, CH_TRIGGER_SINGLE, this.owner.noise2, 1, 2);
			else if(this.lip < 3)
				_sound(this, CH_TRIGGER_SINGLE, this.owner.noise3, 1, 2);
			else
				_sound(this, CH_TRIGGER_SINGLE, this.owner.noise4, 1, 2);
		}
	}
}

//----------------------------------------------------------------------
// Can't have multiple radius explosion on same frame
// Always delay them to prevent endless loops
//----------------------------------------------------------------------
void funcbreakable_delayexplode(entity this)
{
	T_RadiusDamage(this.attachment, this.attachment, this.dmg, DEATH_TRAP.m_id, this.attachment);
}

//======================================================================
// Vector randomizer, used mostly for avelocity setups
// Used all over the place; monsters, weapons and gibs!
// 
//----------------------------------------------------------------------
vector vecrand(float base, float rndmix, float plusminus)
{
	vector vecmix;
	if(plusminus)
	{
		vecmix.x = base + crandom() * rndmix; 
		vecmix.y = base + crandom() * rndmix; 
		vecmix.z = base + crandom() * rndmix; 
	}
	else
	{
		vecmix.x = base + random() * rndmix; 
		vecmix.y = base + random() * rndmix; 
		vecmix.z = base + random() * rndmix; 
	}
	return vecmix;
}

vector mathlib_vectorotateZ(vector targvec, float targang)
{
	vector retvec;
	retvec.x = (targvec.x * cos(targang)) - (targvec.y * sin(targang));
	retvec.y = (targvec.x * sin(targang)) + (targvec.y * cos(targang));
	retvec.z = targvec.z;
	return(retvec);
}

//======================================================================
// Main function for generating rubble
//======================================================================
void funcbreakable_use(entity this, entity actor, entity trigger)
{
	vector dirvec, gvel;

	if(this.waitmin)
		return;	// Trigger once block
	if(this.waitmin2 > time)
		return;	// Spawn damage block

	//----------------------------------------------------------------------
	// Play initial breaking sound (exception - silent spawnflag)
	if(!(this.spawnflags & BREAK_SILENT)) 
		_sound(this.attachment, CHAN_BODY, this.noise, 1, ATTN_NORM);

	//----------------------------------------------------------------------
	// BMODEL breakable (brushwork)
	if(this.classname == "func_breakable")
	{
		this.waitmin = true;			// Only fire breakable ONCE
		this.use = func_null;			// No more triggers
		this.takedamage = DAMAGE_NO;	// No more pain/damage
		this.model = "";				// hide model
		this.modelindex = 0;			// Make sure no model
		this.solid = SOLID_NOT;			// no world interaction
		set_movetype(this, MOVETYPE_NONE);
		// Work out bottom corner of min/max bounding box
		this.oldorigin = this.attachment.origin - (this.size * 0.5);
	}
	// MODEL breakable (.mdl file)
	else if(this.classname == "misc_breakablemodel")
	{
		// Check for explosive puff + dust
		if(this.brkpuff)
		{
			SpawnExplosion(EXPLODE_BURST_SMOKE, this.origin, "");
			if(random() > 0.5)
				SpawnProjectileSmoke(this.origin, 200, 50, 250);
		}
		this.movetarget = find(NULL, targetname, this.target);
		if(IS_MONSTER(this.movetarget))
		{
			if(this.jumpsquash)
			{
				// Always force the spawning of the telefrag (death) triggers
				// When the player is jumping onto the breakable model.
				// The player will touch the death trigger and automatically
				// kill the owner of this trigger (the spawning monster)
				this.movetarget.nospawndamage = false;
			}
			else
			{
				bool bbox_over = false;
				// No Z comparision because brk/monster can start at diff heights
				// XY for all monsters are always the same because of rotation
				if(this.movetarget.bbmins_x < this.bbmins_x)
					bbox_over = true;
				else if(this.movetarget.bbmins_y < this.bbmins_y)
					bbox_over = true;
				else if(this.movetarget.bbmaxs_x > this.bbmaxs_x)
					bbox_over = true;
				else if(this.movetarget.bbmaxs_y > this.bbmaxs_y)
					bbox_over = true;
				// If bounding box same size as breakable, no telefrag dmg/check
				if(!bbox_over)
					this.movetarget.nospawndamage = true;
			}
		}
		
		this.waitmin = true;			// Only fire breakable ONCE
		this.use = func_null;			// No more triggers
		this.takedamage = DAMAGE_NO;	// No more pain/damage
		this.modelindex = 0;			// Make sure no model
		this.model = "";				// hide model
		this.frame = this.skin = 0;		// reset skin/frames
		this.solid = SOLID_NOT;			// no world interaction
		set_movetype(this, MOVETYPE_NONE);
	}
	// Breakable point entities just keep on spawning rubble
	else
		this.oldorigin = this.origin;
		
	//----------------------------------------------------------------------
	// Fire all targets (usually the target is the broken remains)
	// Only fire this target once and check based on target field only
	// Targets are fired before rubble so pointcontent check can
	// take into account any ruined sections and not spawn inside brushwork
	if(this.target != "")
	{
		// Check death entity (set in Killed in ai_combat.qc)
		SUB_UseTargets(this, actor, trigger);
	}
	// Only fire targets once, remove any further triggering
	this.target = this.target2 = this.target3 = this.target4 = string_null;
	this.killtarget = string_null;

	//----------------------------------------------------------------------
	// By default all breakables use direction force for rubble
	// If angles (movedir) set on breakable use that instead
	// Work out direction of impact (using activate passed from combat.qc or trigger.qc)
	// All bmodels are labelled with .bsporigin flag (origin = 0,0,0)
	// attachment points to self if funcbreakable_wall active
	if(this.spawnflags & BREAK_MOVEDIR)
		dirvec = this.movedir;
	// No activate condition? usually trigger events
	else if(!actor)
		dirvec = '0 0 1';
	else
	{
		// DEFAULT option
		vector dirorg = (actor.absmin + actor.absmax) * 0.5;
		dirvec = vectoangles(this.attachment.origin - dirorg);
	}
	
	//----------------------------------------------------------------------
	// Main rubble loop
	while(this.count > 0 && this.brkobjqty > 0)
	{
		//----------------------------------------------------------------------
		// Work out position inside bounding box of breakable bmodel
		// Just in case no space to spawn anywhere, dont do an infinite loop
		int content_loop = 4;
		vector rorg = '0 0 0';

		while(content_loop > 0)
		{
		// Setup broken object inside area (min/max) of parent breakable object
			if(this.classname == "func_breakable")
			{
				rorg.x = this.oldorigin_x + random() * this.size_x;
				rorg.y = this.oldorigin_y + random() * this.size_y;
				rorg.z = this.oldorigin_z + random() * this.size_z;
			}
			else
			{
				// trigger version is a single origin point with slight wobble
				rorg.x = this.origin_x + crandom() * this.brkvol_x;
				rorg.y = this.origin_y + crandom() * this.brkvol_y;
				rorg.z = this.origin_z + crandom() * this.brkvol_z;
			}
			// Check point content and keep checking (limited loop cycles)
			int content_flag = pointcontents(rorg);
			if(content_flag != CONTENT_SOLID && content_flag != CONTENT_SKY)
				content_loop = -1;
			else
				content_loop -= 1;
		}

		//----------------------------------------------------------------------
		// Was there any space to spawn rubble?
		if(content_loop < 0)
		{
			// Create new piece of rubble
			entity newmis = spawn();
			newmis.classname = "rubble";
			newmis.owner = this;
			
			// Setup broken model/bsp (random selection if possible)
			this.lip = random() * this.brkobjqty;
			if(this.lip < 1)
				_setmodel(newmis, this.brkobj1);
			else if(this.lip < 2)
				_setmodel(newmis, this.brkobj2);
			else if(this.lip < 3)
				_setmodel(newmis, this.brkobj3);
			else
				_setmodel(newmis, this.brkobj4);
	
			// Setup origin based on previous content checks
			newmis.solid = SOLID_BBOX; // before setorigin
			setorigin(newmis, rorg);	
			setsize(newmis, '0 0 0', '0 0 0');
	
			// Mirror the skin (exact) on the pot to the breakable chunks
			if(this.classname == "misc_breakablemodel")
				newmis.skin = this.exactskin;
	
			//----------------------------------------------------------------------
			// Setup movement and spin parameters
			set_movetype(newmis, MOVETYPE_BOUNCE);
			if(!(this.spawnflags & BREAK_NOROTATE))
				newmis.angles_y = random() * 360;
			newmis.avelocity = vecrand(0, this.brkavel, true);
			
			//----------------------------------------------------------------------
			if(this.spawnflags & BREAK_MOVEDIR && this.movedir_y < 0)
			{
				// Up/down direction with slight X/Y wobble
				newmis.velocity_x = crandom() * (this.brkveladd_x / 2);
				newmis.velocity_y = crandom() * (this.brkveladd_y / 2);
				if(this.movedir_y == -2)
					newmis.velocity_z = 0 - random() * 50;
				else
					newmis.velocity_z = this.brkvelbase_z + (random() * this.brkveladd_z);
			}
			else
			{
				// Directional velocity based on angle_y or activator entity
				makevectors(dirvec);
				gvel = v_forward * (this.brkvelbase_x + random() * this.brkveladd_x);
				gvel = gvel + v_right * (crandom() * this.brkveladd_y);
				gvel = gvel + v_up * (this.brkvelbase_z + random() * this.brkveladd_z);
				newmis.velocity = gvel;
			}
			//----------------------------------------------------------------------
			// How many bounce sounds - randomly pick 1-2
			if(random() < 0.2)
				newmis.count = 2;
			else
				newmis.count = 1;
		
			//----------------------------------------------------------------------
			// Touch and eventual fade functions		
			settouch(newmis, breakable_touch);
			newmis.pain_finished = time + this.brkfade + random() * this.brkfade;
			newmis.nextthink = time + 0.01;
			setthink(newmis, breakable_particle);
	
			//----------------------------------------------------------------------
			// Setup particle colour and particle dirction (forward)
			newmis.pos1 = this.pos1;
			gvel = vectoangles(newmis.velocity);
			makevectors(gvel);
			newmis.oldorigin = v_forward;
			if(this.brkgravity)
				newmis.gravity = this.brkgravity;			
		}
		
		//----------------------------------------------------------------------
		// Keep on spawning rubble!
		this.count -= 1;
	}
	
	//----------------------------------------------------------------------
	// breakable trigger entities can spawn debris multiple times
	if(this.wait != -1)
	{
		this.count = this.height;
	}
	else
	{
		// Don't need to be active in the world anymore
		setsize(this, '0 0 0', '0 0 0');
		// Produce explosion sprite/particle effect using attachment entity
		if(this.spawnflags & BREAK_EXPLOSION)
		{
			te_explosion(this.attachment.origin);
			
			SpawnExplosion(EXPLODE_SMALL, this.attachment.origin, "weapons/r_exp3b.wav");
			// Do no remove breakable, the rumble is still using
			// the noise keys for impact sounds
			setthink(this, SUB_Remove);
			this.nextthink = time;
			this.use = func_null;
			settouch(this, func_null);
			this.solid = SOLID_NOT;
		}
		//----------------------------------------------------------------------
		// create any explosive damage (do this last!)
		// setup the radius explosion as a delay to prevent endless loops
		if(this.dmg)
		{
			setthink(this, funcbreakable_delayexplode);
			this.nextthink = time + 0.05;
		}
	}
}

//----------------------------------------------------------------------
void funcbreakable_touch(entity this, entity toucher)
{
	// This only works for monster and special jumping break impacts
	if(!IS_MONSTER(toucher))
		return;
	if(IS_ONGROUND(toucher))
		return;
	if(!this.brktrigjump)
		return;
	settouch(this, func_null);
	if(this.use)
		this.use(this, toucher, toucher);
}

//----------------------------------------------------------------------
void funcbreakable_pain(entity this, entity attacker, float damage, int deathtype)
{
	// TODO: inflictor for th_pain
	// As always there are exceptions
	// Grenades bounce and don't impact breakables, cannot tell impact point
	// If inflictor the same as attacker then particle impact done already
	//if(inflictor.classtype == CT_PROJ_GL)
		//return;
	//if(inflictor == attacker)
		//return;
	// Check for player exception on damage to breakable
	if(IS_PLAYER(attacker) && this.brktrignoplayer != 0)
		return;
	
	// Something is trying to wear down the breakable with damage
	// work out facing angle and project particles upward
	makevectors(attacker.angles);
	vector vel = -v_up * 2;
	int loop_count = 0;
	while(loop_count < 4)
	{
		particle(attacker.origin, vel * 0.1, this.bleedcolour + rint(random() * 7), damage);
		loop_count += 1;
	}
}

//----------------------------------------------------------------------
void funcbreakable_death(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(this.spawnflags & BREAK_NOSHOOT)
		return;
	// Check for player exception on damage to breakable
	else if(IS_PLAYER(attacker) && this.brktrignoplayer != 0)
		return;
	else
		funcbreakable_use(this, attacker, attacker);
}

//======================================================================
// Setup all model/sound pre-cache
//----------------------------------------------------------------------
void breakable_cache(entity this)
{
	//----------------------------------------------------------------------
	// If a breakable style key setup, update all undefined sounds/model keys
	if(this.style > 0 && this.style < BTYPE_CUSTOM)
	{
		if(!this.brksound)
			this.brksound = this.style;
		if(!this.brkimpsound)
			this.brkimpsound = this.style;
		if(!this.brkobjects)
			this.brkobjects = this.style * 10;
	}
	else
		return;
	
	//----------------------------------------------------------------------
	// make sure initial break sound is within range types (def=rock)
	if(this.brksound < BTYPE_ROCK || this.brksound > BTYPE_CUSTOM) 
		this.brksound = BTYPE_ROCK;
		
	if(this.brksound == BTYPE_ROCK || this.brksound == BTYPE_BRICK)
	{
		this.noise = "break/rock_impact.wav";
		// Heavy rocks don't move around too much
		if(!this.brkvelbase) this.brkvelbase = '0 0 50';
		if(!this.brkveladd) this.brkveladd = '100 100 100';
	}
	else if(this.brksound == BTYPE_WOOD)
	{
		this.noise = "break/wood_impact.wav";
		if(!this.brkvelbase) this.brkvelbase = '50 50 50';
		if(!this.brkveladd) this.brkveladd = '100 100 50';
	}
	else if(this.brksound == BTYPE_GLASS)
	{
		this.noise = "break/glass_impact.wav";
		if(!this.brkvelbase) this.brkvelbase = '50 50 50';
		if(!this.brkveladd) this.brkveladd = '100 100 150';
	}
	else if(this.brksound == BTYPE_METAL)
	{
		this.noise = "break/metal_impact.wav";
		if(!this.brkvelbase) this.brkvelbase = '50 50 100';
		if(!this.brkveladd) this.brkveladd = '100 100 150';
	}
	else if(this.brksound == BTYPE_FLESH)
	{
		this.noise = "break/flesh_impact.wav";
		if(!this.brkvelbase) this.brkvelbase = '0 0 50';
		if(!this.brkveladd) this.brkveladd = '100 100 100';
	}
	else if(this.brksound == BTYPE_CERAMIC)
	{
		this.noise = "break/ceramic_impact.wav";
		if(!this.brkvelbase) this.brkvelbase = '50 50 50';
		if(!this.brkveladd) this.brkveladd = '100 100 150';
	}
	else if(this.noise == "")
	{
		this.noise = "misc/null.wav";
		if(!this.brkvelbase) this.brkvelbase = '50 50 50';
		if(!this.brkveladd) this.brkveladd = '100 100 150';
	}
	precache_sound(this.noise);	

	//----------------------------------------------------------------------
	// make sure impack sounds are within range types (def=rock)
	if(this.brkimpsound < BTYPE_ROCK || this.brkimpsound > BTYPE_CUSTOM) 
		this.brkimpsound = BTYPE_ROCK;
	// All the impact sounds come in sets of 4 for random variety
	this.brkimpqty = 4;
		
	if(this.brkimpsound == BTYPE_ROCK || this.brkimpsound == BTYPE_BRICK)
	{
		if(this.noise1 == "") this.noise1 = "break/rock_i1.wav";
		if(this.noise2 == "") this.noise2 = "break/rock_i2.wav";
		if(this.noise3 == "") this.noise3 = "break/rock_i3.wav";
		if(this.noise4 == "") this.noise4 = "break/rock_i4.wav";
	}
	else if(this.brkimpsound == BTYPE_WOOD)
	{
		if(this.noise1 == "") this.noise1 = "break/wood_i1.wav";
		if(this.noise2 == "") this.noise2 = "break/wood_i2.wav";
		if(this.noise3 == "") this.noise3 = "break/wood_i3.wav";
		if(this.noise4 == "") this.noise4 = "break/wood_i4.wav";
	}
	else if(this.brkimpsound == BTYPE_GLASS)
	{
		if(this.noise1 == "") this.noise1 = "break/glass_i1.wav";
		if(this.noise2 == "") this.noise2 = "break/glass_i2.wav";
		if(this.noise3 == "") this.noise3 = "break/glass_i3.wav";
		if(this.noise4 == "") this.noise4 = "break/glass_i4.wav";
	}
	else if(this.brkimpsound == BTYPE_METAL)
	{
		if(this.noise1 == "") this.noise1 = "break/metal_i1.wav";
		if(this.noise2 == "") this.noise2 = "break/metal_i2.wav";
		if(this.noise3 == "") this.noise3 = "break/metal_i3.wav";
		if(this.noise4 == "") this.noise4 = "break/metal_i4.wav";
	}
	else if(this.brkimpsound == BTYPE_FLESH)
	{
		if(this.noise1 == "") this.noise1 = "gibs/gibhit1.wav";
		if(this.noise2 == "") this.noise2 = "gibs/gibhit2.wav";
		if(this.noise3 == "") this.noise3 = "gibs/gibhit3.wav";
		if(this.noise4 == "") this.noise4 = "gibs/gibhit4.wav";
	}
	else if(this.brkimpsound == BTYPE_CERAMIC)
	{
		if(this.noise1 == "") this.noise1 = "break/ceramic_i1.wav";
		if(this.noise2 == "") this.noise2 = "break/ceramic_i2.wav";
		if(this.noise3 == "") this.noise3 = "break/ceramic_i3.wav";
		if(this.noise4 == "") this.noise4 = "break/ceramic_i4.wav";
	}
	else
	{
		// Workout total amount of active impact sounds (custom can have <4)
		// empty slots are filled up with empty sounds for precache reasons
		if(this.noise2 != "")
		{
			if(this.noise3 != "")
			{
				if(this.noise4 != "")
					this.brkimpqty = 4;
				else
					this.brkimpqty = 3;
			}
			else
				this.brkimpqty = 2;
		}
		else
			this.brkimpqty = 1;
		// Cannot have no impact sounds, always setup one sound by default
		if(this.pos1_x + this.pos1_y == 0)
			this.pos1 = '80 8 1';	// Green/Brown
		if(this.noise1 == "")
			this.noise1 = "break/rock_i1.wav";
		if(this.noise2 == "")
			this.noise2 = "misc/null.wav";
		if(this.noise3 == "")
			this.noise3 = "misc/null.wav";
		if(this.noise4 == "")
			this.noise4 = "misc/null.wav";
	}
	precache_sound(this.noise1);
	precache_sound(this.noise2);
	precache_sound(this.noise3);
	precache_sound(this.noise4);

	//----------------------------------------------------------------------
	// make sure breakable objects are within range types (def=rock)
	//----------------------------------------------------------------------
	if(this.brkobjects < BMODTYPE_SELF)
		this.brkobjects = BMODTYPE_ROCK1;

	// Two ways the models can be defined, using the default bmodel types
	// or specifying the models via the brkobjs strings
	// If the first string is empty, then the default = 4 (pre-defined)
	// If first string defined, then count the model strings

	// If the first string is not empty then the mapper has to specify
	// exactly what rubble models to choose from (randomly)
	// The auto fill option (style/brkobjects) only if brkobj1 = empty
	
	if(this.brkobj1 == "")
		this.brkobjqty = 4; // Default
	else
	{
		// Need to check for custom breakable quantity first
		if(this.brkobj2 != "")
		{
			if(this.brkobj3 != "")
			{
				if(this.brkobj4 != "")
					this.brkobjqty = 4;
				else
					this.brkobjqty = 3;
			}
			else
				this.brkobjqty = 2;
		}
		else
			this.brkobjqty = 1;
	}
	
	// All the broken models come in sets of 4 for random variety
	// if brkobjects is set to a custom value then model strings will be filled in
	// with a blank string and the brkobjqty will be adjusted to actual quanity
	switch(this.brkobjects)
	{
		case BMODTYPE_ROCK1:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '80 8 1';	// Green/Brown
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/rock01.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/rock02.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/rock03.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/rock04.bsp";
			break;
		}
		case BMODTYPE_ROCK2:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '48 8 1';	// Green
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/rock05.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/rock06.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/rock07.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/rock08.bsp";
			break;
		}
		case BMODTYPE_ROCK3:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '20 8 1';	// Light Brown
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/rock09.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/rock10.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/rock11.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/rock12.bsp";
			break;
		}
		case BMODTYPE_ROCK4:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '168 8 1';	// Whiteish
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/rock13.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/rock14.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/rock15.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/rock16.bsp";
			break;
		}
		case BMODTYPE_ROCK5:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '32 8 1';	// Blue
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/rock17.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/rock18.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/rock19.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/rock20.bsp";
			break;
		}
		case BMODTYPE_ROCK6:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '1 4 1';	// Black
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/rock21.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/rock22.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/rock23.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/rock24.bsp";
			break;
		}
		case BMODTYPE_ROCK7:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '1 4 1';	// Light Grey
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/rock25.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/rock26.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/rock27.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/rock28.bsp";
			break;
		}
		case BMODTYPE_ROCK8:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '0 2 1';	// Dark Grey
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/rock29.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/rock30.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/rock31.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/rock32.bsp";
			break;
		}
		case BMODTYPE_ROCK9:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '96 8 1';	// Red/Brown
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/rock33.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/rock34.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/rock35.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/rock36.bsp";
			break;
		}
		case BMODTYPE_WOOD1:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '16 8 1';	// Dark Brown
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/wood01.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/wood02.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/wood03.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/wood04.bsp";
			break;
		}
		case BMODTYPE_WOOD2:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '112 8 1';	// Light Brown
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/wood05.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/wood06.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/wood07.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/wood08.bsp";;
			break;
		}
		case BMODTYPE_WOOD3:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '80 8 1';	// Green/Brown
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/wood09.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/wood10.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/wood11.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/wood12.bsp";
			break;
		}
		case BMODTYPE_WOOD4:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '24 8 1';	// Green/Brown
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/wood13.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/wood14.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/wood15.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/wood16.bsp";
			break;
		}
		case BMODTYPE_GLASS1:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '32 8 1';	// Blue
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/glass01.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/glass02.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/glass03.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/glass04.bsp";
			break;
		}
		case BMODTYPE_GLASS2:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '64 8 1';	// Red
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/glass05.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/glass06.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/glass07.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/glass08.bsp";
			break;
		}
		case BMODTYPE_GLASS3:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '96 8 1';	// Pink/Yellow
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/glass09.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/glass10.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/glass11.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/glass12.bsp";
			break;
		}
		case BMODTYPE_GLASS4:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '128 4 1';	// Purple
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/glass13.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/glass14.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/glass15.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/glass16.bsp";
			break;
		}
		case BMODTYPE_METAL1:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '16 8 1';	// Brown
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/metal01.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/metal02.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/metal03.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/metal04.bsp";
			break;
		}
		case BMODTYPE_METAL2:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '80 8 1';	// Green/Brown
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/metal05.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/metal06.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/metal07.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/metal08.bsp";
			break;
		}
		case BMODTYPE_METAL3:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '48 8 1';	// Green
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/metal09.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/metal10.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/metal11.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/metal12.bsp";
			break;
		}
		case BMODTYPE_METAL4:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '48 8 1';	// Green
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/metal13.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/metal14.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/metal15.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/metal16.bsp";
			break;
		}
		case BMODTYPE_METAL5:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '32 8 1';	// Blue
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/metal17.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/metal18.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/metal19.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/metal20.bsp";
			break;
		}
		case BMODTYPE_BRICK1:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '16 8 1';	// Brown
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/brick01.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/brick02.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/brick03.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/brick04.bsp";
			break;
		}
		case BMODTYPE_BRICK2:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '80 8 1';	// Green/Brown
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/brick05.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/brick06.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/brick07.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/brick08.bsp";
			break;
		}
		case BMODTYPE_BRICK3:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '48 8 1';	// Green
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/brick09.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/brick10.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/brick11.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/brick12.bsp";
			break;
		}
		case BMODTYPE_BRICK4:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '0 8 1';	// Grey/White
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/brick13.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/brick14.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/brick15.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/brick16.bsp";
			break;
		}
		case BMODTYPE_BRICK5:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '16 8 1';	// Brown
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/brick17.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/brick18.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/brick19.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/brick20.bsp";
			break;
		}
		case BMODTYPE_BRICK6:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '16 8 1';	// Brown
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/brick21.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/brick22.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/brick23.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/brick24.bsp";
			break;
		}
		case BMODTYPE_BRICK7:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '32 8 1';	// Blue
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/brick25.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/brick26.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/brick27.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/brick28.bsp";
			break;
		}
		case BMODTYPE_BRICK8:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '16 8 1';	// Brown
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/brick29.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/brick30.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/brick31.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/brick32.bsp";
			break;
		}
		case BMODTYPE_FLESH1:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '64 8 1';	// Red
			if(this.brkobj1 == "") this.brkobj1 = "progs/gib_4.mdl";
			if(this.brkobj2 == "") this.brkobj2 = "progs/gib_5.mdl";
			if(this.brkobj3 == "") this.brkobj3 = "progs/gib_4.mdl";
			if(this.brkobj4 == "") this.brkobj4 = "progs/gib_3.mdl";
			break;
		}
		case BMODTYPE_FLESH2:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '48 8 1';	// Green
			if(this.brkobj1 == "") this.brkobj1 = "progs/gib_p4.mdl";
			if(this.brkobj2 == "") this.brkobj2 = "progs/gib_p5.mdl";
			if(this.brkobj3 == "") this.brkobj3 = "progs/gib_p4.mdl";
			if(this.brkobj4 == "") this.brkobj4 = "progs/gib_p3.mdl";
			break;
		}
		case BMODTYPE_FLESH3:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '168 8 1';	// Whiteish
			if(this.brkobj1 == "") this.brkobj1 = "progs/gib_s4.mdl";
			if(this.brkobj2 == "") this.brkobj2 = "progs/gib_s5.mdl";
			if(this.brkobj3 == "") this.brkobj3 = "progs/gib_s4.mdl";
			if(this.brkobj4 == "") this.brkobj4 = "progs/gib_s3.mdl";
			break;
		}
		case BMODTYPE_CERAMIC1:
		{
			if(this.pos1_x + this.pos1_y == 0) this.pos1 = '96 8 1';	// Pink/Yellow
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/glass09.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "maps/ad_brk/glass10.bsp";
			if(this.brkobj3 == "") this.brkobj3 = "maps/ad_brk/glass11.bsp";
			if(this.brkobj4 == "") this.brkobj4 = "maps/ad_brk/glass12.bsp";
			break;
		}
		default:
		{
			// Cannot have no breakable models, always setup one model by default
			if(this.brkobj1 == "") this.brkobj1 = "maps/ad_brk/rock01.bsp";
			if(this.brkobj2 == "") this.brkobj2 = "progs/null.mdl";
			if(this.brkobj3 == "") this.brkobj3 = "progs/null.mdl";
			if(this.brkobj4 == "") this.brkobj4 = "progs/null.mdl";
			break;
		}
	}

	precache_model(this.brkobj1);
	precache_model(this.brkobj2);
	precache_model(this.brkobj3);
	precache_model(this.brkobj4);
}
	
//----------------------------------------------------------------------
// Setup defaults
//----------------------------------------------------------------------
void breakable_defaults(entity this)
{
	// Setup breakable use blockers (trig once, delay damage)
	this.waitmin = this.waitmin2 = false;

	// Setup rubble counter = count + random*cnt
	if(this.count <= 0)
		this.count = BREAK_DEFCOUNT;
	if(this.cnt == 0)
		this.cnt = BREAK_DEFCNT;

	// If cnt = -1 then don't do any random factor, just exact amount
	if(this.cnt < 0)
		this.height = this.count;
	else
		this.height = this.count + rint(random() * this.cnt);
	
	// Backup rubble count for later (point entity)
	this.count = this.height;	
	
	// Special conditions - jump only, missile only, no health
	if(this.brktrigjump != 0 || this.brktrigmissile != 0 || this.health < 0) 
		this.spawnflags |= BREAK_NOSHOOT;

	// Setup default health
	if(this.health == 0)
		this.health = 1;
	
	// Rubble damage overrides any explosion damage
	if(this.spawnflags & BREAK_DAMAGE)
	{
		if(this.dmg <= 0)
			this.dmg = 2;
	}
	else if(this.spawnflags & BREAK_EXPLOSION)
	{
		if(this.dmg <= 0)
			this.dmg = 40;
	}
	
	// Setup default base + additional velocity and angle spin
	if(!this.brkvelbase)
		this.brkvelbase = '50 50 100';
	if(!this.brkveladd)
		this.brkveladd = '100 100 150';
	if(this.brkavel <= 0)
		this.brkavel = 200;
	if(this.brkfade <= 0)
		this.brkfade = 4;

	// angles has to be 0 0 0 otherwise brush model is twisted
	// Is there any angle direction defined for impact force direction
	// Exception: breakable models have random rotation on the model!
	if(this.angles_y && this.classname != "misc_breakablemodel")
	{
		this.movedir_y = this.angles_y;
		this.spawnflags |= BREAK_MOVEDIR;
	}
	this.mangle = this.angles = '0 0 0';
	
	// reset velocity / avelocity just in case of rogue key fields
	this.velocity = this.avelocity = '0 0 0';
	
	// Can fire other triggers, make sure no delay on breakable function
	this.delay = 0;
}

//----------------------------------------------------------------------
void funcbreakable_damageon(entity this)
{
	this.takedamage = DAMAGE_YES;
	this.th_pain = funcbreakable_pain;
	this.th_die = funcbreakable_death;
}

//----------------------------------------------------------------------
void breakable_trigger_touch(entity this, entity toucher)
{
	// dummy function?
}

//----------------------------------------------------------------------
void breakable_trigger_field(entity targ)
{
	targ.trigger_field = spawn();
	targ.trigger_field.classname = "breakable_trigger";
	set_movetype(targ.trigger_field, MOVETYPE_NONE);
	targ.trigger_field.solid = SOLID_TRIGGER;
	targ.trigger_field.owner = targ;
	settouch(targ.trigger_field, breakable_trigger_touch);
	setsize(targ.trigger_field, targ.bbmins, targ.bbmaxs);
	setorigin(targ.trigger_field, targ.origin);
}

//----------------------------------------------------------------------
void breakable_on(entity this, entity actor, entity trigger)
{
	// Make sure use function reset
	this.use = func_null;
	
	// Setup collision based on bmodel type
	if(this.bsporigin)
	{
		this.solid = SOLID_BSP;
		set_movetype(this, MOVETYPE_PUSH);
		_setmodel(this, this.model);
		setorigin(this, this.origin);	
		setsize(this, this.mins, this.maxs);

		// Used for sound, radius damage and explosion
		if(!this.attachment)
			this.attachment = spawn();
		this.attachment.classname = "breakable_attachment";
		this.attachment.origin = (this.absmin + this.absmax) * 0.5;
		setorigin(this.attachment, this.attachment.origin);
	}
	else
	{
		this.solid = SOLID_BBOX;
		set_movetype(this, MOVETYPE_NONE);
		_setmodel(this, this.mdl);
		setorigin(this, this.origin);	
		setsize(this, this.bbmins, this.bbmaxs);
		this.angles = this.pos2;
		this.skin = this.exactskin;
		// Vase 0-9 = combined models; Pot 10-29 = single models
		if(this.brkmdltype < 10)
			this.frame = this.brkmdltype;
		else
			this.frame = 0;
		
		// Used for sound, radius damage and explosion
		this.attachment = this;
	}
	
	if(this.spawnflags & BREAK_NOSHOOT)
	{
		this.takedamage = DAMAGE_NO;
		this.th_pain = func_null;
		this.th_die = func_null;
	}
	else
	{
		// Check for any damage pause before spawning new breakable
		// This is to prevent any breakables from spawning and
		// instantly being destroyed by radius damage from explosions
		// Really designed for multiple break stages
		if(this.brkdelaydamage > 0)
		{
			this.takedamage = DAMAGE_NO;
			this.th_pain = func_null;
			this.th_die = func_null;
			setthink(this, funcbreakable_damageon);
			this.nextthink = this.waitmin2 = time + this.brkdelaydamage;
		}
		else
		{
			this.takedamage = DAMAGE_YES;
			this.th_pain = funcbreakable_pain;
			this.th_die = funcbreakable_death;
		}
		
		this.bleedcolour = this.pos1_x;
		// Setup location (origin) to spawn particles
		vector targ_org = (this.absmin + this.absmax) * 0.5;
		if(this.bsporigin)
			this.oldorigin = targ_org;
		else
			this.oldorigin = this.origin;
	}
	
	// Originally had this as a targetname condition because
	// if the breakable is used then it needs a referenced name
	// Since adding brktrigjump, brktrigmissile ent keys there are
	// external trigger events which need breakable entities to react
	this.use = funcbreakable_use;
	// Jumping monsters don't often hit the breakable object easily
	// Easier to trap jump impact triggering with a touch function
	if(this.brktrigjump)
		settouch(this, funcbreakable_touch);
}

//======================================================================
// Basic workhorse of breakable system (bmodel)
//======================================================================
void func_breakable_ad(entity this)
{
	// reset out of range styles and setup default = BTYPE_ROCK (1)
	if(this.style < BTYPE_ROCK || this.style > BTYPE_MAX)
		this.style = BTYPE_ROCK;
	// precache all sound/model stuff
	breakable_cache(this);
	breakable_defaults(this);

	// No point setting up a breakable if it cannot be triggered or shoot
	if(this.targetname == "" && (this.spawnflags & BREAK_NOSHOOT))
	{
		// Check for external event triggers and warn on console
		if(this.brktrigjump != 0 || this.brktrigmissile != 0)
			{ /* do nothing */ }
		else
		{
			delete(this);
			return;
		}
	}

	this.classname = "func_breakable";
	this.bsporigin = true;		// bmodel origin 0,0,0
	this.wait = -1;				// Always work once, cannot unbreak

	if(this.spawnflags & BREAK_STARTOFF)
		this.use = breakable_on;
	else
		breakable_on(this, NULL, NULL);
}

//----------------------------------------------------------------------
// Point entity version of breakbles
// Good for producing rubble from areas unreachable players
// Earthquake and rubble and dust from ceilings
//----------------------------------------------------------------------
spawnfunc(func_breakable_spawner)
{
	// Check for targetname
	if(!this.targetname || this.targetname == "")
	{
		delete(this);
		return;
	}

	// reset out of range styles and setup default = BTYPE_ROCK (1)
	if(this.style < BTYPE_ROCK || this.style > BTYPE_MAX)
		this.style = BTYPE_ROCK;
	// precache all sound/model stuff
	breakable_cache(this);
	breakable_defaults(this);

	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_NONE);
	if(this.brkvol_x < 8)
		this.brkvol_x = 8;
	if(this.brkvol_y < 8)
		this.brkvol_y = 8;
	if(this.brkvol_z < 8)
		this.brkvol_z = 8;
	// Not used, but should be defined for later
	this.exactskin = this.brkmdltype = 0;
	
	// Already a point entity, don't need to generate anything else
	this.attachment = this;
	this.use = funcbreakable_use;
}

//======================================================================
// General purpose bmodel with toggle states and solid/fade functions
// Could be used for all sorts of situations not involving breakables
//======================================================================
/*QUAKED func_breakable_wall (0 .5 .8) ? START_ON SOLID FADEOUT
Switchable bmodel for breakable setups with optional collision
-------- KEYS --------
targetname : trigger entity (works with entity state system)
wait       : set to -1 for trigger once condition (def=0)
waitmin    : random time to wait before fading out
-------- SPAWNFLAGS --------
START_ON : Will spawn visible and wait for trigger
SOLID    : Will block player/monster movement
FADEOUT  : Will fade out after a certain amount of time if visible!
-------- NOTES --------
Switchable bmodel for breakable setups with optional collision

=============================================================================*/
void breakable_wall_state(entity this)
{
	// Show model and setup collision state
	if(this.state == STATE_ENABLED)
	{
		// Does the bmodel require any solid collision?
		if(this.spawnflags & BREAKWALL_SOLID)
		{
			this.solid = SOLID_BSP;
			set_movetype(this, MOVETYPE_PUSH);
		}
		else
		{
			// Bmodel visiable, no collision
			this.solid = SOLID_NOT;
			set_movetype(this, MOVETYPE_NONE);
		}
		// Add bmodel to the world
		_setmodel(this, this.mdl);
	}
	// hide model
	else
	{
		this.solid = SOLID_NOT;
		set_movetype(this, MOVETYPE_NONE);
		this.modelindex = 0;
		this.model = "";
	}
}

//----------------------------------------------------------------------
void breakable_wall_use(entity this, entity actor, entity trigger)
{
	//if(this.estate & ESTATE_BLOCK)
		//return;
	if(this.active != ACTIVE_ACTIVE)
		return;
	if(this.attack_finished > time)
		return;

	// Setup to trigger once?
	if(this.wait < 0)
		this.attack_finished = 999999;

	// Toggle bmodel visible state
	if(this.state == STATE_ENABLED)
		this.state = STATE_DISABLED;
	else
		this.state = STATE_ENABLED;
	
	// make sure model state is correct
	breakable_wall_state(this);

	// Is the breakable wall visible and designed to fade away?
	if((this.spawnflags & BREAKWALL_FADEOUT) && this.state == STATE_ENABLED)
	{
		// Setup random timer and fade away!
		this.nextthink = time + this.waitmin + random() * this.waitmin;
		setthink(this, breakable_remove);
		// Change the model type and state otherwise will not alpah fade
		set_movetype(this, MOVETYPE_NONE);
		this.solid = SOLID_BBOX;
	}	
}	

//----------------------------------------------------------------------
spawnfunc(func_breakable_wall)
{
	this.classname = "func_breakable";
	this.bsporigin = true;		// bmodel origin 0,0,0
	this.angles = '0 0 0';		// Stop model twisting
	this.mdl = this.model;		// Save for later

	// Make sure the bmodel is active in the world before changing state
	this.solid = SOLID_BSP;
	set_movetype(this, MOVETYPE_PUSH);
	_setmodel(this, this.mdl);

	// Something that fades away does it only once
	if(this.spawnflags & BREAKWALL_FADEOUT)
		this.wait = -1;
	// Default fade time = time+fade+random()*fade
	if(!this.waitmin)
		this.waitmin = 4;

	// Setup Entity State functionality
	//if(this.targetname != "")
		//this.use = entity_state_use;
	//this.estate_use = breakable_wall_use;
	//this.estate = ESTATE_ON;
	this.active = ACTIVE_ACTIVE;
	
	if(this.spawnflags & BREAKWALL_START_ON)
		this.state = STATE_ENABLED;
	else
		this.state = STATE_DISABLED;
	breakable_wall_state(this);
}

//======================================================================
// A point entity which triggers a breakable and monster together
//======================================================================
/*QUAKED trigger_monsterbreak (.8 .5 .8) (-8 -8 -8) (8 8 8) NODELAY WAKEANIM
Trigger (once) breakable and monster together
-------- KEYS --------
targetname : trigger entity (works with entity state system)
target     : points to func_breakable (single target)
target2    : points to a monster (single target)
wait       : time before breakable is triggered (def 0.2)
-------- SPAWNFLAGS --------
NODELAY  : No delay between monster and breakable trigger
WAKEANIM : Will do special wakeup animation when triggered
-------- NOTES --------
Trigger (once) breakable and monster together

======================================================================*/
void trig_monbreak_delay(entity this)
{
	// Check for breakable targetname first
	if(this.target != "")
	{
		// Find breakable (single target only)
		this.owner = find(NULL, targetname, this.target);
		if(this.owner.classname == "func_breakable" || this.owner.classname == "misc_breakablemodel")
		{
			if(this.owner.use)
				this.owner.use(this.owner, this, this);
		}
	}
}

//----------------------------------------------------------------------
void trig_monbreak_use(entity this, entity actor, entity trigger)
{
	if(this.active != ACTIVE_ACTIVE)
		return;
	if(this.attack_finished > time)
		return;
	
	// Trigger once
	this.attack_finished = 999999;

	// Any monster defined to wakeup?
	if(this.target2 != "")
	{
		// Find monster (single target only)
		this.enemy = find(NULL, targetname, this.target2);
		if(IS_MONSTER(this.enemy))
		{
			//if(this.spawnflags & MONTRIG_WAKEUPANIM)
				//this.enemy.wakeuptrigger = true;
			if(this.enemy.use)
				this.enemy.use(this.enemy, actor, this);
		}
	}

	// Time to explode breakable?
	if(this.spawnflags & MONTRIG_NODELAY)
		trig_monbreak_delay(this);
	else
	{
		// setup delay to trigger breakable wall
		this.nextthink = time + this.wait;
		setthink(this, trig_monbreak_delay);
	}
}

//----------------------------------------------------------------------
spawnfunc(trigger_monsterbreak)
{
	if(this.wait <= 0)
		this.wait = 0.2;

	// Setup Entity State functionality
	//if(this.targetname != "")
		//this.use = entity_state_use;
	//this.estate_use = trig_monbreak_use;
	//this.estate = ESTATE_ON;
	this.use = trig_monbreak_use;
	this.active = ACTIVE_ACTIVE;
}

//======================================================================
/*QUAKED func_breakable_vase (1 .5 .25) (-16 -16 -16) (16 16 24) STARTOFF NODAMAGE EXPLOSION SILENT DAMAGE NOMOSTER NOSOUND NOROTATE
{ model(":progs/brk_vase1.mdl"); }
Breakable ceramic vase (model)
-------- KEYS --------
mdl        : Name of model to display (def = 'progs/brk_vase1.mdl')
brkobj1    : Breakable rubble 1 (def = 'progs/brk_vase1part1.mdl')
brkobj2    : Breakable rubble 2 (def = 'progs/brk_vase1part2.mdl')
brkobj3    : Breakable rubble 3 (def = 'progs/brk_vase1part3.mdl')
brkobj4    : Breakable rubble 4 (def = 'progs/brk_vase1part4.mdl')
exactskin  : Skin override of model (def 0, cannot be negative)
target     : Additional triggers to fire when model breaks
angle      : Yaw rotation of model (-1/0 = random rotation)
health     : amount of damage to take before breaking (def 1)
count      : minimum quantity to spawn (def 4)
cnt        : random quantity to spawn (def 4) final qty = count + random(cnt)
dmg        : explosive radius damage (emits from center of func object)
pos1       : x=start particle colour, y=random range, z=quantity (def '168 8 1')
bbmins     : Model bounding box MINIMUM size (def '-8 -8 -16')
bbmaxs     : Model bounding box MAXIMUM size (def '8 8 16')
brkvol     : Volume size for spawning pieces inside of (def '16 16 32')
brkmdltype : Predefined sizes (0/1 = '16 16 32' and 2/3 = '24 24 40')
brkpuff    : Spawn explosive puff of smoke and extra particles (-1 = disable)
brkvelbase : Base amount for velocity of broken parts (def '50 50 100')
brkveladd  : Random additions for velocity of broken parts (def '100 100 150')
brkavel    : Amount of breaking object angle velocity (def 200)
brkfade    : Fade time before rubble fades away (def 4+random()x4)
brkgravity : will change the gravity for rubble, useful for underwater
-------- SPAWNFLAGS --------
STARTOFF   : Will wait for trigger to spawn
NODAMAGE   : Cannot be damaged or shot, trigger only
EXPLOSION  : trigger sprite/particle explosion
SILENT     : No initial breakage sound
DAMAGE     : Spawning rubble can damage (def = 2, use dmg key for touch damage)
NOMONSTER  : monsters cannot damage this breakable and/or spawning rubble will not damage monsters
NOSOUND    : Spawning rubble has no impact sounds
NOROTATE   : Spawning rubble has No Y rotation
-------- NOTES --------
Breakable ceramic vase (model)

======================================================================*/
spawnfunc(func_breakable_ceramic_model)
{
	// Setup object defaults
	this.classname = "misc_breakablemodel";
	this.style = BTYPE_CERAMIC;
	this.brkobjects = BMODTYPE_CUSTOM;

	// Setup particle dust colour
	if(this.pos1 == '0 0 0')
		this.pos1 = '168 8 1'; // Whiteish
	
	// Check for exactskin range errors, will be copied to rubble
	if(this.exactskin <= 0)
		this.exactskin = 0;
	this.skin = this.exactskin;

	// Setting the angle key in the editor to UP/DOWN = random rotation	
	if(this.angles_y <= 0)
		this.angles_y = rint(random()*359);
	this.pos2 = this.angles;	// Save for later
	this.wait = -1;				// Only break once
	// Setup default puff of smoke on break
	if(this.brkpuff < 1)
		this.brkpuff = 0;
	else
		this.brkpuff = 1;
	
	// precache all sound/model stuff
	breakable_cache(this);
	breakable_defaults(this);

	if(this.spawnflags & BREAK_STARTOFF)
		this.use = breakable_on;
	else
		breakable_on(this, NULL, NULL);
}

//----------------------------------------------------------------------
spawnfunc(misc_breakable_vase1)
{
	// Default model/skin
	if(this.mdl == "")
		this.mdl = "progs/brk_vase1.mdl";
	precache_model(this.mdl);

	if(this.brkobj1 == "") this.brkobj1 = "progs/brk_vase1part1.mdl";
	if(this.brkobj2 == "") this.brkobj2 = "progs/brk_vase1part2.mdl";
	if(this.brkobj3 == "") this.brkobj3 = "progs/brk_vase1part3.mdl";
	if(this.brkobj4 == "") this.brkobj4 = "progs/brk_vase1part4.mdl";

	// Make sure no out of range errors
	if(this.brkmdltype <= 0)
		this.brkmdltype = 0;
	// pre-defined large version (2/3)
	if(this.brkmdltype == 2 || this.brkmdltype == 3)
	{
		// 2 = large, 3 = large (animated)
		this.bbmins = '-16 -16 -16';
		this.bbmaxs = '16 16 24';
		this.brkvol = '32 32 40';
	}
	else
	{
		// Default bounding box and volume
		if(this.bbmins == '0 0 0')
			this.bbmins = '-8 -8 -16';
		if(this.bbmaxs == '0 0 0')
			this.bbmaxs = '8 8 16';
		if(this.brkvol == '0 0 0')
			this.brkvol = '16 16 32';
	}
	// Default setup
	spawnfunc_func_breakable_ceramic_model(this);
}

// Re-direct (old entity format)
spawnfunc(func_breakable_vase) { spawnfunc_misc_breakable_vase1(this); }

//----------------------------------------------------------------------
void misc_breakable_pot_setup(entity this)
{
	// Check for random model setup
	if(this.brkmdltype == -1)
		this.brkmdltype = rint(11 + (random() * 3.5));
	if(this.brkmdltype < -1)
		this.brkmdltype = rint(21 + (random() * 3.5));
	// Check for errors
	if(this.brkmdltype < 11)
		this.brkmdltype = 11;
	else if(this.brkmdltype > 25)
		this.brkmdltype = 25;
	else if(this.brkmdltype > 15 && this.brkmdltype < 21)
		this.brkmdltype = 15;

	// Pick model
	if(this.brkmdltype == 11) this.mdl = "progs/brk_pot1a.mdl";
	else if(this.brkmdltype == 12) this.mdl = "progs/brk_pot1b.mdl";
	else if(this.brkmdltype == 13) this.mdl = "progs/brk_pot1c.mdl";
	else if(this.brkmdltype == 14) this.mdl = "progs/brk_pot1d.mdl";
	else if(this.brkmdltype == 15) this.mdl = "progs/brk_pot1aflr.mdl";
	else if(this.brkmdltype == 21) this.mdl = "progs/brk_pot2a.mdl";
	else if(this.brkmdltype == 22) this.mdl = "progs/brk_pot2b.mdl";
	else if(this.brkmdltype == 23) this.mdl = "progs/brk_pot2c.mdl";
	else if(this.brkmdltype == 24) this.mdl = "progs/brk_pot2d.mdl";
	else if(this.brkmdltype == 25) this.mdl = "progs/brk_pot2aflr.mdl";
	precache_model(this.mdl);
	
	// Pot 1a and 2a
	if(this.brkmdltype == 11 || this.brkmdltype == 21)
	{
		if(this.bbmins == '0 0 0') this.bbmins = '-16 -16 -16';
		if(this.bbmaxs == '0 0 0') this.bbmaxs = '16 16 32';
		if(this.brkvol == '0 0 0') this.brkvol = '32 32 48';
	}
	// Pot 1b and 2b
	else if(this.brkmdltype == 12 || this.brkmdltype == 22)
	{
		if(this.bbmins == '0 0 0') this.bbmins = '-10 -10 -16';
		if(this.bbmaxs == '0 0 0') this.bbmaxs = '10 10 16';
		if(this.brkvol == '0 0 0') this.brkvol = '20 20 32';
	}
	// Pot 1c and 2c
	else if(this.brkmdltype == 13 || this.brkmdltype == 23)
	{
		if(this.bbmins == '0 0 0') this.bbmins = '-16 -16 -16';
		if(this.bbmaxs == '0 0 0') this.bbmaxs = '16 16 32';
		if(this.brkvol == '0 0 0') this.brkvol = '32 32 48';
	}
	// Pot 1d and 2d
	else if(this.brkmdltype == 14 || this.brkmdltype == 24)
	{
		if(this.bbmins == '0 0 0') this.bbmins = '-12 -12 -16';
		if(this.bbmaxs == '0 0 0') this.bbmaxs = '12 12 32';
		if(this.brkvol == '0 0 0') this.brkvol = '24 24 48';
	}
	else if(this.brkmdltype == 15 || this.brkmdltype == 25)
	{
		// Find out any random rotation of the pot early for this setup
		if(this.angles_y <= 0)
			this.angles_y = rint(random() * 359);
		// Calculate the true rotation of XY bounding box
		this.bbmins = mathlib_vectorotateZ('-20 -12 -16', this.angles_y);
		// The vector should have a minimum size, otherwise odd sizes
		if(this.bbmins_x > -16) this.bbmins_x = -16;
		if(this.bbmins_y > -16) this.bbmins_y = -16;
		// Calculate the true rotation of XY bounding box
		this.bbmaxs = mathlib_vectorotateZ('20 12 12', this.angles_y);
		// The vector should have a minimum size, otherwise odd sizes
		if(this.bbmaxs_x < 16)
			this.bbmaxs_x = 16;
		if(this.bbmaxs_y < 16)
			this.bbmaxs_y = 16;
		// Pot2a floor version is flatter on top (lower Z)
		if(this.brkmdltype == 25)
			this.bbmaxs_z = 8;
		// Volume is the same for breakable parts
		this.brkvol = '32 32 32';
	}
	
	
	// Setup breakable parts for each model type
	if(this.brkmdltype >= 11 && this.brkmdltype <= 15)
	{
		this.brkobj1 = "progs/brk_pot1part1.mdl";
		this.brkobj2 = "progs/brk_pot1part2.mdl";
		this.brkobj3 = "progs/brk_pot1part3.mdl";
		this.brkobj4 = "progs/brk_pot1part4.mdl";
	}
	else if(this.brkmdltype >= 21 && this.brkmdltype <= 25)
	{
		this.brkobj1 = "progs/brk_pot2part1.mdl";
		this.brkobj2 = "progs/brk_pot2part2.mdl";
		this.brkobj3 = "progs/brk_pot2part3.mdl";
		this.brkobj4 = "progs/brk_pot2part4.mdl";
	}
	spawnfunc_func_breakable_ceramic_model(this);
}

//----------------------------------------------------------------------
spawnfunc(misc_breakable_pot1a)
{
	if(this.brkmdltype < 0)
		this.brkmdltype = -1;
	else
		this.brkmdltype = 11;
	misc_breakable_pot_setup(this);
}
spawnfunc(misc_breakable_pot1b)
{
	if(this.brkmdltype < 0)
		this.brkmdltype = -1;
	else
		this.brkmdltype = 12;
	misc_breakable_pot_setup(this);
}
spawnfunc(misc_breakable_pot1c)
{
	if(this.brkmdltype < 0)
		this.brkmdltype = -1;
	else
		this.brkmdltype = 13;
	misc_breakable_pot_setup(this);
}
spawnfunc(misc_breakable_pot1d)
{
	if(this.brkmdltype < 0)
		this.brkmdltype = -1;
	else
		this.brkmdltype = 14;
	misc_breakable_pot_setup(this);
}
spawnfunc(misc_breakable_pot1aflr)
{
	this.brkmdltype = 15;
	misc_breakable_pot_setup(this);
}
//----------------------------------------------------------------------
spawnfunc(misc_breakable_pot2a)
{
	if(this.brkmdltype < 0)
		this.brkmdltype = -2;
	else
		this.brkmdltype = 21;
	misc_breakable_pot_setup(this);
}
spawnfunc(misc_breakable_pot2b)
{
	if(this.brkmdltype < 0)
		this.brkmdltype = -2;
	else
		this.brkmdltype = 22;
	misc_breakable_pot_setup(this);
}
spawnfunc(misc_breakable_pot2c)
{
	if(this.brkmdltype < 0)
		this.brkmdltype = -2;
	else
		this.brkmdltype = 23;
	misc_breakable_pot_setup(this);
}
spawnfunc(misc_breakable_pot2d)
{
	if(this.brkmdltype < 0)
		this.brkmdltype = -2;
	else
		this.brkmdltype = 24;
	misc_breakable_pot_setup(this);
}
spawnfunc(misc_breakable_pot2aflr)
{
	this.brkmdltype = 25;
	misc_breakable_pot_setup(this);
}

#endif
