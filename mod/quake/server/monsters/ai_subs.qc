#include "ai_subs.qh"

/*======================================================================
 ai_foundbreakable
  Check if the monster is allowed to break the breakable!?!
======================================================================*/
bool ai_foundbreakable(entity source, entity targ, bool ignorenoshoot)
{
	// Found a breakable in the way?
	if((targ.classname == "func_breakable" && targ.bsporigin) || targ.classname == "misc_breakablemodel")
	{
		// Check if a monster and nomonster damage/trigger allowed?
		if(IS_MONSTER(source) && (targ.spawnflags & BREAK_NOMONSTER))
			return false;
		// Ignoring noshoot spawnflag? (designed for jump/missile events)
		else if(ignorenoshoot)
			return true;
		// is breakable explosive damage only and attacker can use explosives?
		else if(targ.brktrigmissile && source.attack_explosive)
			return true;
		// Can the breakable be damaged?
		else if(targ.spawnflags & BREAK_NOSHOOT)
			return false;
		// Its a breakable that breaks!
		else
			return true;
	}
	return false;
}

/*======================================================================
 ai_tracebreakable
  Check if the monster (self) can see any breakables infront (target)
  Triple trace infront (self.angles) origin, +upward and +downward
======================================================================*/
bool ai_tracebreakable(entity this, float tracedist, float traceang)
{
	// Take current facing angle of monster
	makevectors(this.angles);
	vector spot1 = this.origin;
	vector spot2 = '0 0 0';

	// Work out look up/down height for additional tracelines
	float mon_height = (this.maxs_z - this.mins_z) * traceang;
	
	// Trace directly infront of entity using angles
	spot2 = spot1 + (v_forward * tracedist);
	traceline(spot1, spot2, false, this);
	if(ai_foundbreakable(this, trace_ent, false))
		return true;

	// Trace from origin and look UP!
	spot2 = spot1 + (v_forward * tracedist) + (v_up * mon_height);
	traceline(spot1, spot2, false, this);
	if(ai_foundbreakable(this, trace_ent, false))
		return true;

	// Trace from origin and look DOWN!
	spot2 = spot1 + (v_forward * tracedist) - (v_up * mon_height);
	traceline(spot1, spot2, false, this);
	if(ai_foundbreakable(this, trace_ent, false))
		return true;

	// No breakable found
	return false;
};

/*======================================================================
 ai_immunebreakable
  Check if a breakable/pushable is immune to damage from monsters
======================================================================*/
bool ai_immunebreakable(entity source, entity targ)
{
	// Found a breakable? (BSP or model)
	if((targ.classname == "func_breakable" && targ.bsporigin) || targ.classname == "misc_breakablemodel")
	{
		// Check no damage spawnflag?
		if(IS_MONSTER(source) && (targ.spawnflags & BREAK_NOMONSTER))
			return true;
	}
	// Found a pushable?
	else if(targ.classname == "func_pushable")
	{
		// Check no damage spawnflag?
		if(IS_MONSTER(source) && (targ.spawnflags & PUSH_NOMONSTER))
			return true;
	}
	return false;
}

/*======================================================================
 ai_damagebreakable
  If any breakables found, damage them to see if they will break
  Use the triple trace forward, upward and dowward to find breakables
======================================================================*/
void ai_damagebreakable(entity this, float brkdmg)
{
	// Setup damage modifier
	float ldmg = (random() + random() + random()) * brkdmg;

	// Triple trace directly infront of monster using angles
	if(ai_tracebreakable(this, 128, 0.35))
	{
		// Check for any monster damage modifier on breakable
		if(IS_MONSTER(this) && trace_ent.brkmondmg > 0)
			ldmg *= trace_ent.brkmondmg;
		// Apply damage to breakable
		T_Damage(trace_ent, this, this, ldmg, DEATH_GENERIC.m_id);
	}
}

/*======================================================================
 ai_jumpbreakable
  Check if the monster can trigger a breakable from jump attack
======================================================================*/
void ai_jumpbreakable(entity this, entity toucher, float brkdmg)
{
	if(ai_foundbreakable(this, toucher, true) && toucher.brktrigjump != 0)
	{
		// Found a breakable which is prone to jump damage
		if(toucher.use)
			toucher.use(toucher, this, this);
	}
	else
		ai_damagebreakable(this, brkdmg);	// Damage any breakables
}

/*======================================================================
 ai_shockwave
 - produce a large ground slam/shockwave effect
 - Used by hammer ogres, golems and barons
======================================================================*/
void ai_shockwave_think(entity this)
{
	this.wait = rint((time - this.ltime) * 10);
	if(this.wait > 6)
	{
		delete(this);
		return;
	}

	this.frame = this.wait;
	if(this.wait > 4)
	{
		if(!this.delay)
			this.delay = time;
		this.alpha = 1 - ((time - this.delay) * 5);
	}
	this.angles_y = anglemod(this.angles_y + rint(random() * 20));
    this.nextthink = time + 0.01; // TODO: just not add the .01? they're using it as a "min tick"
}

//----------------------------------------------------------------------
void ai_shockwave(entity this, vector imp_vec, float imp_damage, float imp_radius, float imp_forward, float imp_up, int deathtype, string meleehitsound)
{
	// Big impact, flash effect
	this.effects |= EF_MUZZLEFLASH;

	// Play impact sound and work out where the impact is going to happen
	_sound(this, CH_WEAPON_SINGLE, meleehitsound, 1, ATTN_IDLE);
	makevectors(this.angles);
	// Replaced this crazy mess with function attack_vector
	//impact = this.origin + v_forward*imp_vec_x + v_right*imp_vec_y + v_up*imp_vec_z;
	vector impact = this.origin + attack_vector(imp_vec);

	// Push all entities within a certain radius outwards
	// Do this find search before spawning ring and particles
	// findradius will find ALL entities regardless of type
	entity sjump = findradius(impact, imp_radius);
	while(sjump)
	{
		// Ignore monster (this)
		if(sjump != this)
		{
			// Check for player + blast belt? - play active sound
			/*if (IS_PLAYER(sjump) && sjump.moditems & IT_ARTBLASTBELT)
				PlayBlastBeltSound(sjump);
			// Only affect players and other monsters AND breakables (BSP+model)
			else*/ if(IS_PLAYER(sjump) || IS_MONSTER(sjump) || sjump.classname == "misc_breakablemodel")
			{
				// Exclude breakable/pushable immune to monster damage
				// This does not catch breakables excluded from player damage
				if(ai_immunebreakable(this, sjump))
				{
					// unbreakable thing, do nothing
				}
				// Exclude statues, stone/heavy monsters and bosses!
				else if(!(sjump.monsterdef.spawnflags & MONSTER_TYPE_BOSS)) // TODO: CG_STONE check was here
				{
					// Is the entity on the ground or a breakable?
					// The test for breakables exceptions is done earlier
					// Breakable bmodel/model don't have onground flag set
					// The onground test is really to catch player/monsters
					if(IS_ONGROUND(sjump) || sjump.classname == "misc_breakablemodel")
					{
						// Is the entity too far above or below the impact?
						float impzdiff = fabs(sjump.origin_z - impact_z);
						if(impzdiff < 128)
						{
							// Distance between impact and enemy/entity
							float sdist = vlen(sjump.origin - impact);
							// Percentage of impact force
							float vpercent = 1 - (sdist / imp_radius);
							float vdamage = rint(imp_damage * vpercent);
							// Impact damage radius is half for breakables
							// Otherwise whole rooms would be destroyed!
							if(sjump.classname == "misc_breakablemodel")
							{
								if(sdist > (imp_radius * 0.5))
									vdamage = 0;
							}
							// Only apply impact damage to players (not monsters)
							// The damage was previously a meleerange with +/- 48 zaxis
							// Been changed to a radius damage as its radius impact!
							// Percentage (distance) of the impact damaged specified
							// This will STILL not apply if blast belt or jumping :P
							// Breakable's need source (this) for impact direction
							// to spawn breakable pieces away from impact location
							if(vdamage > 0)
								T_Damage(sjump, this, this, imp_damage*vpercent, deathtype);
							
							// Monsters have less impact
							if(IS_MONSTER(sjump))
								vpercent *= 0.75;
							// Attacker facing angle
							makevectors(this.angles);									
							// Combine forward/up force with existing velocity
							vector fvel = (v_forward * (imp_forward * vpercent)) + (v_up * (imp_up * vpercent));
							sjump.velocity = sjump.velocity + fvel;
							UNSET_ONGROUND(sjump);
						}
					}
				}
			}
		}
		sjump = sjump.chain;
	}

	// Spawn impact model ring on the ground
	entity swave = spawn();
	swave.mdl = "progs/proj_ringshock.mdl";	
	_setmodel(swave,swave.mdl);
	setsize(swave, '0 0 0', '0 0 0');
	setorigin(swave, impact);		// on floor, slight up (2 pixels)
	swave.solid = SOLID_NOT;		// No interaction with world
	set_movetype(swave, MOVETYPE_NONE);
	setthink(swave, ai_shockwave_think);
	swave.nextthink = time + 0.01;	// High time loop
	swave.ltime = swave.nextthink;
	
	// Spawn particle explosion where impact is located
	int vpart = 64 + rint(random()*64);
	particle_explode(impact, vpart, 0.5, PARTICLE_BURST_FIRE, PARTICLE_BURST_SHOCKWAVE); 
}
