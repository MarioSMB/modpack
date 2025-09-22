#include "ice_golem.qh"

#include "../../../common/triggers/triggers.qh"
#include "../../../common/triggers/func/door.qh"

#ifdef SVQC
const int anim_icegolem_wait = 0;
const int anim_icegolem_tranB = 22;
const int anim_icegolem_birth = 35;
const int anim_icegolem_walk = 51;
const int anim_icegolem_run = 85;
const int anim_icegolem_punch = 109;
const int anim_icegolem_pound = 133;
const int anim_icegolem_death = 157;
const int anim_icegolem_magic = 179;
const int anim_icegolem_stomp = 203;
const int anim_icegolem_knock = 227;

const int ICEG_PHASE1 = 1;	// Frozen in Ice
const int ICEG_PHASE2 = 2;	// Fighting
const int ICEG_PHASE3 = 3;	// Busting Columns
const int ICEG_PHASE4 = 4;	// Death

.bool attack_elev;

void icegolem_idle_sound(entity this)
{
	if(random() < 0.2)
	{
		if(this.enemy)
		{
			if(random() < 0.5)
				_sound(this, CH_VOICE, "golem/idle1a.wav", 1, ATTN_NORM);
			else
				_sound(this, CH_VOICE, "golem/idle1b.wav", 1, ATTN_NORM);
		}
		else
		{
			if(random() < 0.5)
				_sound(this, CH_VOICE, "golem/idle2a.wav", 1, ATTN_NORM);
			else
				_sound(this, CH_VOICE, "golem/idle2b.wav", 1, ATTN_NORM);
		}
	}
}

void iceg_waveboundary(entity this);

//======================================================================
// Global functions
//======================================================================
// Special streamlined player find function
//----------------------------------------------------------------------
#if 0
bool iceg_FindTarget(entity this)
{
	local entity client;
	
	// Get the obvious exception(s) done first
	if(this.health < 1) return false;
	if(intermission_running > 0) return false;
	if(cinematic_running > 0) return false;

	// Find a client in current PVS
	client = checkclient ();
	
	// Go through all the exception(s)
	if(!client) return false;
	if(!(client.flags & FL_CLIENT)) return false;
	if(client.flags & FL_NOTARGET) return false;
	if(client.items & IT_INVISIBILITY) return false;
	
	// Check range and visibility of player
	enemy_vis = visible(client);
	if(!enemy_vis) return false;
	if(!infront(client)) return false;

	// Finally found something
	this.enemy = client;
	this.oldorigin = this.origin;		// Save origin
	this.goalentity = this.enemy;		// Focus on enemy
	// Setup turning angle towards new enemy
	this.ideal_yaw = vectoyaw(this.enemy.origin - this.origin);

	// We have a winner!
	return true;	
}
#endif

//----------------------------------------------------------------------
// Setup wave HP and trigger boundaries
//----------------------------------------------------------------------
void iceg_WaveSetupHP(entity this)
{
	// Is there anymore boss waves left?
	if(this.bosswave >= this.bosswavetotal)
	{
		// Only one wave left (death is final trigger)
		this.health = this.bosswaveqty;
		this.bosswavetrig = -1000;
	}
	else
	{
		// Multiple waves are still left (reset hp+trigger)
		// Always reset HP to stop high DPS weapons trashing waves boundaries
		this.health = ((this.bosswavetotal - this.bosswave) + 1) * this.bosswaveqty;
		// The wave trigger is always one wave lower
		this.bosswavetrig = this.health - this.bosswaveqty;
	}
}

//----------------------------------------------------------------------
// Check if HP reached next wave, turn and fire at targets
//----------------------------------------------------------------------
bool iceg_WaveCheck(entity this)
{
	// Check for boss wave boundary event
	if(this.health > 1 && this.health < this.bosswavetrig)
	{
		// Check for wave boundary triggers
		this.noise = "";
		if(this.bosswave == 1) this.noise = this.noise1;
		else if(this.bosswave == 2) this.noise = this.noise2;
		else if(this.bosswave == 3) this.noise = this.noise3;
		else if(this.bosswave == 4) this.noise = this.noise4;
		
		// Is there any trigger for the wave boundary?
		if(this.noise != "")
		{
			this.attachment2 = find(NULL, targetname, this.noise);
			if(this.attachment2.classname == "monster_icegolem_wavetrig")
			{
				// Spawn any adds to keep player busy
				if(this.attachment2.target != "") 
				{
					FOREACH_ENTITY_STRING(targetname, this.attachment2.target,
					{
						if(it.use)
							it.use(it, this, this);
					});
				}
				
				// Turn around and blow up breakables
				iceg_waveboundary(this);
			}
		}

		// Update Boss wave parameters (next wave!)
		this.bosswave += 1;
		iceg_WaveSetupHP(this);		// Reset trigger/hp
		return true;
	}
	return false;
}

//----------------------------------------------------------------------
// Check the tether system
//----------------------------------------------------------------------
#if 0
bool iceg_CheckTether(entity this)
{
	this.t_length = vlen(this.origin - this.movelast.origin);
	// Check the most obvious first, inside tether range?
	if(this.t_length < this.tetherrange) return false;
	else {
		// If player or tether close to each other?
		if(infront(this.movelast) && infront(this.enemy) )
			return false;
		// Stop moving around
		else return true;
	}
}
#endif
	
//----------------------------------------------------------------------
// Quick check for stomp/melee + fast range attack
//----------------------------------------------------------------------
/*======================================================================
 visxray (variable options)
  Returns TRUE if there is no blocking, FALSE if something in the way
  Custom options for variable source/target offsets and monster blocking
  (nomonsters) TRUE = no block, FALSE = blocked
  self is excluded from any trace starting points
======================================================================*/
bool visxray(entity this, entity targ, vector s_offset, vector t_offset, bool nomonsters)
{
	// Bmodels don't have proper origins
	vector spot1 = (this.absmin + this.absmax) * 0.5;
	spot1 += s_offset;

	vector spot2 = (targ.absmin + targ.absmax) * 0.5;
	spot2 += t_offset;
	traceline(spot1, spot2, nomonsters, this);	// custom options
	
	// Check for liquid surface block condition
	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	// monster blocking changes which test to use
	if(nomonsters)
	{
		// Has the traceline gone from source>target without anything blocking?
		return (trace_fraction == 1);
	}
	else
	{
		// Is the entity hit by the traceline the targ destination?
		return (trace_ent == targ);
	}
}

void iceg_magic7(entity this);
void iceg_CheckCombo(entity this)
{
	if(this.health < 1)
		return;
	if(this.enemy.health < 1)
		return;
	if(autocvar_skill < 2) // hard only?
		return;
	
	// If the enemy is visible, quickly go for range attack
	if(visxray(this, this.enemy, '10 0 112', this.enemy.view_ofs, true))
	{
		this.attack_finished = time + (2 * 0.5) + random();
		// Skip forward in magic attack
		setthink(this, iceg_magic7);
	}
}

//----------------------------------------------------------------------
// Ice Golem game play logic
//----------------------------------------------------------------------
void iceg_stomp1(entity this);
bool IcegCheckAttack(entity this)
{
	//----------------------------------------------------------------------
	// Check Melee range and constantly fire
	//----------------------------------------------------------------------
	vector targ_org = (this.enemy.absmin + this.enemy.absmax) * 0.5;

	if(vdist(targ_org - this.origin, <=, 128))
	{
		this.attack_finished = time + 1;
		this.attack_state = AS_MELEE;
		return true;
	}

	//if(this.enemy_range == RANGE_FAR)
		//return false;
	if(time < this.attack_finished)
		return false;

	//----------------------------------------------------------------------
	// Floor stomp attack
	//----------------------------------------------------------------------
	if(vdist(targ_org - this.origin, <=, 400) && random() < 0.5)
	{
		this.attack_finished = time + (2 * 0.5) + random() + random();
		iceg_stomp1(this);
		return true;
	}
	
	//----------------------------------------------------------------------
	// Range attacks (O Rings + Ceiling Rubble)
	//----------------------------------------------------------------------
	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ_org + targ.view_ofs;

	if(vdist(spot1 - spot2, >, 600))
		return false;

	traceline(spot1, spot2, false, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
	{
		return false;	// don't have a clear shot
	}
	
	// Does the monster have a clear shot to the player?
	// sightline can be blocked by other monsters
	this.attack_finished = time + (2 * 0.6) + random() + random();
	this.attack_state = AS_MISSILE;

	return true;
}

//======================================================================
// MONSTER STATES (stand, walk run, attack, pain and death!
//======================================================================
void iceg_idleframe(entity this)
{
	// Do nothing if dead
	if(this.health < 1)
		return;
	if(this.walkframe == 0)
		icegolem_idle_sound(this);

	// Keep moving the animation frame forward
	this.walkframe = this.walkframe + 1;
	if(this.walkframe > 20)
		this.walkframe = 0;
	this.frame = anim_icegolem_wait + this.walkframe;
	setthink(this, iceg_idleframe);
	// Tick slower (10fps) for idle
	this.nextthink = time + 0.1;

	// Keep looking for a player
	FindTarget(this);
}

//----------------------------------------------------------------------
void iceg_stand1(entity this)
{
	this.walkframe = 0;
	iceg_idleframe(this);
}

//============================================================================
void iceg_walkframe(entity this)
{
	// Do nothing if dead
	if(this.health < 1)
		return;
	
	// Default walk speed (very slow)
	float walkspeed = 5;
	// Check for any special frame events
	if(this.walkframe == 0 || this.walkframe == 16)
	{
		walkspeed = 0;
		//monster_footstep(this, false);
	}		
	else if(this.walkframe == 1 || this.walkframe == 17)
		walkspeed = 4;
	else if(this.walkframe == 7 || this.walkframe == 24) 
		icegolem_idle_sound(this);

	// Keep moving the animation frame forward
	this.walkframe = this.walkframe + 1;
	if(this.walkframe > 33)
		this.walkframe = 0;
	this.frame = anim_icegolem_walk + this.walkframe;
	setthink(this, iceg_walkframe);
	// Hexen 2 models were designed for 20fps
	this.nextthink = time + 0.05;
	
	// Keep looking for a player
	FindTarget(this);
	
	// Any feet movement?
	if(walkspeed > 0)
	{
		// TODO: weird tether system
		t_movetogoal(this, walkspeed);		
	}
}

//----------------------------------------------------------------------
void iceg_walk1(entity this)
{
	this.walkframe = 0;
	iceg_walkframe(this);
}

//============================================================================
void iceg_runframe(entity this)
{
	if(this.style != ICEG_PHASE2)
		return;
	if(this.health < 1)
		return;
	
	// Check for boss wave trigger events
	if(iceg_WaveCheck(this))
	{
		iceg_waveboundary(this);
		return;
	}
	
	// Default run speed (very slow)
	float runspeed = 8;
	// Check for any special frame events
	if(this.walkframe == 0 || this.walkframe == 12)
	{
		runspeed = 0;
		//monster_footstep(this, false);
	}		
	else if(this.walkframe == 1 || this.walkframe == 13)
		runspeed = 6;
	else if(this.walkframe == 6 || this.walkframe == 17) 
		icegolem_idle_sound(this);

	// Keep moving the animation frame forward
	this.walkframe += 1;
	if(this.walkframe > 23)
		this.walkframe = 0;
	this.frame = anim_icegolem_run + this.walkframe;
	setthink(this, iceg_runframe);
	// Hexen 2 models were designed for 20fps
	this.nextthink = time + 0.05;

	// TODO? weird tether system may be needed
	ai_run(this, runspeed);
}

//----------------------------------------------------------------------
void iceg_run1(entity this)
{
	this.walkframe = 0;
	iceg_runframe(this);
}

//============================================================================
// MELEE - knockback the player with swipe
//============================================================================
void iceg_mcharge(entity this, float dist)
{ 
	ai_charge(this, dist);
	// Hexen 2 models were designed for 20fps
	this.nextthink = time + 0.05;
}

//----------------------------------------------------------------------
void iceg_knock24(entity this)
{
	set_animofs(this, anim_icegolem_knock, 24, iceg_run1);
	iceg_mcharge(this, 5); 
	// Check for combo Melee+quick range
	iceg_CheckCombo(this);
}
void iceg_knock23(entity this) { set_animofs(this, anim_icegolem_knock, 23, iceg_knock24); iceg_mcharge(this, 5); }
void iceg_knock22(entity this) { set_animofs(this, anim_icegolem_knock, 22, iceg_knock23); iceg_mcharge(this, 5); }
void iceg_knock21(entity this) { set_animofs(this, anim_icegolem_knock, 21, iceg_knock22); iceg_mcharge(this, 5); }
void iceg_knock20(entity this) { set_animofs(this, anim_icegolem_knock, 20, iceg_knock21); iceg_mcharge(this, 4); }
void iceg_knock19(entity this) { set_animofs(this, anim_icegolem_knock, 19, iceg_knock20); iceg_mcharge(this, 3); }
void iceg_knock18(entity this) { set_animofs(this, anim_icegolem_knock, 18, iceg_knock19); iceg_mcharge(this, 2); }
void iceg_knock17(entity this) { set_animofs(this, anim_icegolem_knock, 17, iceg_knock18); iceg_mcharge(this, 1); }
void iceg_knock16(entity this)
{
	set_animofs(this, anim_icegolem_knock, 16, iceg_knock17);
	iceg_mcharge(this, 1);
	if(ai_meleesmash(this, DEATH_MONSTER_ICE_GOLEM.m_id, 100, 30))
	{
		_sound(this, CH_WEAPON_SINGLE, "golem/melee_punch.wav", 1, ATTN_NORM);
	// If punch made contact, lift the enemy off ground
		vector dir = this.enemy.origin - this.origin;
		dir.z = 0;
		dir = normalize(dir);
		this.enemy.velocity = this.enemy.velocity + dir * 400;
		this.enemy.velocity_z = this.enemy.velocity_z + 250;
		UNSET_ONGROUND(this.enemy);
	}
}
void iceg_knock15(entity this) { set_animofs(this, anim_icegolem_knock, 15, iceg_knock16); iceg_mcharge(this, 2); }
void iceg_knock14(entity this) { set_animofs(this, anim_icegolem_knock, 14, iceg_knock15); iceg_mcharge(this, 3); }
void iceg_knock13(entity this) { set_animofs(this, anim_icegolem_knock, 13, iceg_knock14); iceg_mcharge(this, 4); }
void iceg_knock12(entity this)
{
	set_animofs(this, anim_icegolem_knock, 12, iceg_knock13);
	iceg_mcharge(this, 5);
	_sound(this, CH_VOICE, "golem/melee_swipe.wav", 1, ATTN_IDLE);
}
void iceg_knock11(entity this) { set_animofs(this, anim_icegolem_knock, 11, iceg_knock12); iceg_mcharge(this, 5); /*monster_footstep(this, false);*/ }
void iceg_knock10(entity this) { set_animofs(this, anim_icegolem_knock, 10, iceg_knock11); iceg_mcharge(this, 6); }
void iceg_knock9(entity this) { set_animofs(this, anim_icegolem_knock, 9, iceg_knock10); iceg_mcharge(this, 7); }
void iceg_knock8(entity this) { set_animofs(this, anim_icegolem_knock, 8, iceg_knock9); iceg_mcharge(this, 8); }
void iceg_knock7(entity this) { set_animofs(this, anim_icegolem_knock, 6, iceg_knock8); iceg_mcharge(this, 9); }
void iceg_knock6(entity this) { set_animofs(this, anim_icegolem_knock, 7, iceg_knock7); iceg_mcharge(this, 10); }
void iceg_knock5(entity this) { set_animofs(this, anim_icegolem_knock, 5, iceg_knock6); iceg_mcharge(this, 9); }
void iceg_knock4(entity this) { set_animofs(this, anim_icegolem_knock, 4, iceg_knock5); iceg_mcharge(this, 8); }
void iceg_knock3(entity this) { set_animofs(this, anim_icegolem_knock, 3, iceg_knock4); iceg_mcharge(this, 7); }
void iceg_knock2(entity this) { set_animofs(this, anim_icegolem_knock, 2, iceg_knock3); iceg_mcharge(this, 6); }
void iceg_knock1(entity this) { set_animofs(this, anim_icegolem_knock, 1, iceg_knock2); iceg_mcharge(this, 5); }

//============================================================================
// RANGE ATTACK (ICE SHARDS == rockets)
// Total shards to fire is based on skill level
// easy=3, normal=3, hard=4, nm=5
//============================================================================
void iceg_shardanimate(entity this)
{
	// manually animate
	this.frame = this.frame + 1;
	this.lip = 1 - (this.frame / 11);
	this.lip = this.lip * 0.5;
	// Gradualy fade out
	this.alpha = this.lip;
	// Hit animaton frame boundary?
	if(this.frame > 10)
	{
		delete(this);
		return;
	}

	this.nextthink = time + 0.1;
}

//----------------------------------------------------------------------
void iceg_shardtrail(entity this)
{
	if(time >= this.wait)
	{
		delete(this);
		return;
	}

	// Spawn a temporary entity
	entity oring = spawn();
	oring.owner = this;
	oring.solid = SOLID_NOT;			// No interaction with world
	set_movetype(oring, MOVETYPE_NONE);		// Static item, no movement
	
	// move to current projectile location
	_setmodel(oring, "progs/proj_ringblast.mdl");
	setsize(oring, '0 0 0', '0 0 0');
	setorigin(oring, this.origin);
	oring.alpha = 0.5;
	oring.skin = 3;
	
	// Match orientiation and start Oring animation
	this.pos2 = normalize(this.velocity);
	oring.angles = vectoangles(this.pos2);
	setthink(oring, iceg_shardanimate);
	oring.nextthink = time + 0.1;

	// Has the DP particle trail been setup yet?
	if(!this.pain_finished)
	{
		// only run this once
		this.pain_finished = true;
		// Re-use plasma trail
		this.traileffectnum = _particleeffectnum("TR_NEXUIZPLASMA");
		this.effects = 0;
	}
	
	// Keep looping for O rings trails
	setthink(this, iceg_shardtrail);
	this.nextthink = time + 0.05 + random() * 0.05;
}

//----------------------------------------------------------------------
void IceGolemMissileTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(toucher.takedamage)
	{
		T_Damage(toucher, this, this, 20, this.projectiledeathtype);	
	}

	if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD))
		T_Damage(toucher, this, this, 110, this.projectiledeathtype);	
	T_RadiusDamage(this, this.owner, 20, this.projectiledeathtype, toucher);

	//te_explosion(this.origin);
	SpawnExplosion(EXPLODE_ICE_BIG, self.origin, self.noise);

	delete(this);
}

entity iceg_Launch_Missile(entity this, vector org, vector dir, vector avel, float pspeed)
{
	entity newmis = launch_spike(this, org, dir);
	newmis.classname = "ice_shard";
	settouch(newmis, IceGolemMissileTouch);
	newmis.projectiledeathtype = DEATH_MONSTER_ICE_GOLEM.m_id;
	newmis.poisonous = this.poisonous;
	newmis.noise = "golem/iceshard_impact.wav";
	_setmodel(newmis, "progs/proj_golemshard.mdl");
	setthink(newmis, iceg_shardtrail);
	newmis.nextthink = time + 0.1;
	newmis.wait = time + 5;

	return newmis;
}

void iceg_icestorm(entity this, entity targ)
{
	// No enemy or dead? stop firing
	if(!targ)
		return;
	if(this.health < 1)
		return;

	// Play random firing sound
	float r = random();
	if(r < 0.3) 
		_sound(this, CH_WEAPON_SINGLE, "golem/iceshard1.wav", 1, ATTN_IDLE);
	else if(r  < 0.6)
		_sound(this, CH_WEAPON_SINGLE, "golem/iceshard2.wav", 1, ATTN_IDLE);
	else
		_sound(this, CH_WEAPON_SINGLE, "golem/iceshard3.wav", 1, ATTN_IDLE);
	
	// Make sure facing the right direction
	ai_face(this);
	makevectors(this.angles);

	// Check if enemy is bmodel or point entity
	vector targ_org = (this.enemy.absmin + this.enemy.absmax) * 0.5;

	// Spawn a mist of particles where projectiles came from
	vector org = this.origin + attack_vector('20 0 64');
	float zpart = 20 + rint(random() * 20);
	particle_explode(org, zpart, 1 + random(), PARTICLE_BURST_BLUE, PARTICLE_BURST_UPWARD);

	// Randomly spawn projectiles from golems chest
	vector yrand = (crandom() * 10) * v_right;
	vector zrand = (crandom() * 10) * v_up;
	org = this.origin + attack_vector('10 0 112') + yrand + zrand;

	// Add some right/left bias to the final destination
	vector dir = (targ_org - org) + (v_right * (crandom() * 50));
	dir = normalize (dir);

	// Variable speed based on skill level
	iceg_Launch_Missile(this, org, dir, '0 0 0', 700);
}

//----------------------------------------------------------------------
void iceg_magtime(entity this)
{
	this.nextthink = time + 0.05;
}

void iceg_magic24(entity this) { set_animofs(this, anim_icegolem_magic, 24, iceg_run1); iceg_magtime(this); }
void iceg_magic23(entity this) { set_animofs(this, anim_icegolem_magic, 23, iceg_magic24); iceg_magtime(this); }
void iceg_magic22(entity this) { set_animofs(this, anim_icegolem_magic, 22, iceg_magic23); iceg_magtime(this); }
void iceg_magic21(entity this)
{
	set_animofs(this, anim_icegolem_magic, 21, iceg_magic22);
	iceg_magtime(this);
	ai_face(this);
	if(autocvar_skill >= 2)
		iceg_icestorm(this, this.enemy);
}
void iceg_magic20(entity this) { set_animofs(this, anim_icegolem_magic, 20, iceg_magic21); iceg_magtime(this); ai_face(this); }
void iceg_magic19(entity this)
{
	set_animofs(this, anim_icegolem_magic, 19, iceg_magic20);
	iceg_magtime(this);
	ai_face(this);
	if(autocvar_skill >= 1)
		iceg_icestorm(this, this.enemy);
}
void iceg_magic18(entity this) { set_animofs(this, anim_icegolem_magic, 18, iceg_magic19); iceg_magtime(this); ai_face(this); }
void iceg_magic17(entity this) { set_animofs(this, anim_icegolem_magic, 17, iceg_magic18); iceg_magtime(this); iceg_icestorm(this, this.enemy); }
void iceg_magic16(entity this) { set_animofs(this, anim_icegolem_magic, 16, iceg_magic17); iceg_magtime(this); ai_face(this); }
void iceg_magic15(entity this) { set_animofs(this, anim_icegolem_magic, 15, iceg_magic16); iceg_magtime(this); iceg_icestorm(this, this.enemy); }
void iceg_magic14(entity this) { set_animofs(this, anim_icegolem_magic, 14, iceg_magic15); iceg_magtime(this); ai_face(this); }
void iceg_magic13(entity this) { set_animofs(this, anim_icegolem_magic, 13, iceg_magic14); iceg_magtime(this); iceg_icestorm(this, this.enemy); }
void iceg_magic12(entity this) { set_animofs(this, anim_icegolem_magic, 12, iceg_magic13); iceg_magtime(this); ai_face(this); }
void iceg_magic11(entity this) { set_animofs(this, anim_icegolem_magic, 11, iceg_magic12); iceg_magtime(this); ai_face(this); }
void iceg_magic10(entity this) { set_animofs(this, anim_icegolem_magic, 10, iceg_magic11); iceg_magtime(this); ai_face(this); }
void iceg_magic9(entity this) { set_animofs(this, anim_icegolem_magic, 9, iceg_magic10); iceg_magtime(this); ai_face(this); }
void iceg_magic8(entity this) { set_animofs(this, anim_icegolem_magic, 8, iceg_magic9); iceg_magtime(this); }
void iceg_magic7(entity this) { set_animofs(this, anim_icegolem_magic, 7, iceg_magic8); iceg_magtime(this); ai_face(this); }
void iceg_magic6(entity this) { set_animofs(this, anim_icegolem_magic, 6, iceg_magic7); iceg_magtime(this); ai_face(this); }
void iceg_magic5(entity this) { set_animofs(this, anim_icegolem_magic, 5, iceg_magic6); iceg_magtime(this); ai_face(this); }
void iceg_magic4(entity this) { set_animofs(this, anim_icegolem_magic, 4, iceg_magic5); iceg_magtime(this); }
void iceg_magic3(entity this) { set_animofs(this, anim_icegolem_magic, 3, iceg_magic4); iceg_magtime(this); ai_face(this); }
void iceg_magic2(entity this) { set_animofs(this, anim_icegolem_magic, 2, iceg_magic3); iceg_magtime(this); }
void iceg_magic1(entity this)
{
	set_animofs(this, anim_icegolem_magic, 1, iceg_magic2);
	iceg_magtime(this);
	ai_face(this);
	this.pain_finished = time + 1.5;
	_sound(this, CH_WEAPON_SINGLE, "golem/icestorm.wav", 1, ATTN_NORM);
}

//============================================================================
// RANGE ATTACK (Stomp ground and drop debris from ceiling)
//============================================================================
void funcbreakable_use(entity this, entity actor, entity trigger);
void funcbreakable_usethink(entity this)
{
	funcbreakable_use(this, NULL, NULL);
}
void iceg_ceilingrubble(entity this)
{
	// No enemy or dead?
	if(!this.enemy)
		return;
	if(this.health < 1)
		return;
	
	// Trace a line up from the enemy/player
	traceline(this.enemy.origin, this.enemy.origin + '0 0 1024', true, this.enemy);
	// is there any space for rubble?
	if(vdist(this.enemy.origin - trace_endpos, <, 64))
		return;

	// Spawn a func_breakable_spawner entity
	// Manually setup all parameters
	// All sounds/models pre-cached with ice golem
	this.attachment = spawn();
	this.attachment.classname = "ceiling_rubble";
	// Move the emitter slightly down from ceiling
	this.attachment.origin = trace_endpos - this.dest2;
	
	this.attachment.owner = this;
	this.attachment.style = BTYPE_ROCK;
	this.attachment.brkimpsound = BTYPE_ROCK;
	this.attachment.brkobjects = BTYPE_ROCK;
	this.attachment.brkvelbase = this.brkvelbase;
	this.attachment.brkveladd = this.brkveladd;
	this.attachment.brkavel = 200;
	this.attachment.brkfade = this.brkfade;
	this.attachment.noise = "break/rock_impact.wav";
	this.attachment.noise1 = "break/rock_i1.wav";
	this.attachment.noise2 = "break/rock_i2.wav";
	this.attachment.brkimpqty = 2;
	
	// Allow for custom rubble bmodels
	this.attachment.brkobj1 = this.brkobj1;
	this.attachment.brkobj2 = this.brkobj2;
	this.attachment.brkobjqty = 2;
	this.attachment.pos1 = this.dest1;
	this.attachment.cnt = 5 + random() * 5;
	this.attachment.count = 5 + random() * 5;
	this.attachment.movedir = '0 -2 0';
	this.attachment.angles = '0 0 0';
	
	// Check if the boss has dmg key set for rubble damage
	if(this.dmg > 0)
		this.attachment.spawnflags |= BREAK_DAMAGE;
	else
		this.attachment.spawnflags = BREAK_MOVEDIR;
	if(this.dmg > 0)
		this.attachment.dmg = this.dmg;
	else
		this.attachment.dmg = 2;
	
	// Default entity stuff (type/movement etc)
	this.attachment.solid = SOLID_NOT;
	set_movetype(this.attachment, MOVETYPE_NONE);
	this.attachment.brkvol = this.brkvol;
	setthink(this.attachment, funcbreakable_usethink);
	this.attachment.nextthink = time + 0.05;
}

//----------------------------------------------------------------------
void iceg_footstomp(entity this)
{
	this.nextthink = time + 0.05;
}

//----------------------------------------------------------------------
void iceg_stomp24(entity this)
{
	set_animofs(this, anim_icegolem_stomp, 24, iceg_run1);
	iceg_footstomp(this);
	//monster_footstep(this, false);
	// Check for combo Stomp+quick range
	iceg_CheckCombo(this);
}
void iceg_stomp23(entity this) { set_animofs(this, anim_icegolem_stomp, 23, iceg_stomp24); iceg_footstomp(this); }
void iceg_stomp22(entity this) { set_animofs(this, anim_icegolem_stomp, 22, iceg_stomp23); iceg_footstomp(this); }
void iceg_stomp21(entity this) { set_animofs(this, anim_icegolem_stomp, 21, iceg_stomp22); iceg_footstomp(this); }
void iceg_stomp20(entity this) { set_animofs(this, anim_icegolem_stomp, 20, iceg_stomp21); iceg_footstomp(this); }
void iceg_stomp19(entity this) { set_animofs(this, anim_icegolem_stomp, 19, iceg_stomp20); iceg_footstomp(this); }
void iceg_stomp18(entity this) { set_animofs(this, anim_icegolem_stomp, 18, iceg_stomp19); iceg_footstomp(this); }
void iceg_stomp17(entity this) { set_animofs(this, anim_icegolem_stomp, 17, iceg_stomp18); iceg_footstomp(this); }
void iceg_stomp16(entity this) { set_animofs(this, anim_icegolem_stomp, 16, iceg_stomp17); iceg_footstomp(this); icegolem_idle_sound(this); }
void iceg_stomp15(entity this) { set_animofs(this, anim_icegolem_stomp, 15, iceg_stomp16); iceg_footstomp(this); }
void iceg_stomp14(entity this) { set_animofs(this, anim_icegolem_stomp, 14, iceg_stomp15); iceg_footstomp(this); }
void iceg_stomp13(entity this)
{
	set_animofs(this, anim_icegolem_stomp, 13, iceg_stomp14); 
	iceg_footstomp(this);
	ai_shockwave(this, '12 8 -22', 30, 640, 300, 600, DEATH_MONSTER_ICE_GOLEM.m_id, "golem/groundslam.wav");
	// spawn ceiling rubble above player/enemy
	iceg_ceilingrubble(this);
}
void iceg_stomp12(entity this) { set_animofs(this, anim_icegolem_stomp, 12, iceg_stomp13); iceg_footstomp(this); }
void iceg_stomp11(entity this) { set_animofs(this, anim_icegolem_stomp, 11, iceg_stomp12); iceg_footstomp(this); }
void iceg_stomp10(entity this) { set_animofs(this, anim_icegolem_stomp, 10, iceg_stomp11); iceg_footstomp(this); }
void iceg_stomp9(entity this) { set_animofs(this, anim_icegolem_stomp, 9, iceg_stomp10); iceg_footstomp(this); }
void iceg_stomp8(entity this) { set_animofs(this, anim_icegolem_stomp, 8, iceg_stomp9); iceg_footstomp(this); }
void iceg_stomp7(entity this) { set_animofs(this, anim_icegolem_stomp, 7, iceg_stomp8); iceg_footstomp(this); }
void iceg_stomp6(entity this) { set_animofs(this, anim_icegolem_stomp, 6, iceg_stomp7); iceg_footstomp(this); }
void iceg_stomp5(entity this) { set_animofs(this, anim_icegolem_stomp, 5, iceg_stomp6); iceg_footstomp(this); icegolem_idle_sound(this); }
void iceg_stomp4(entity this) { set_animofs(this, anim_icegolem_stomp, 4, iceg_stomp5); iceg_footstomp(this); }
void iceg_stomp3(entity this) { set_animofs(this, anim_icegolem_stomp, 3, iceg_stomp4); iceg_footstomp(this); }
void iceg_stomp2(entity this) { set_animofs(this, anim_icegolem_stomp, 2, iceg_stomp3); iceg_footstomp(this); _sound(this, CH_VOICE, "golem/sight.wav", 1, ATTN_IDLE); }
void iceg_stomp1(entity this) { set_animofs(this, anim_icegolem_stomp, 1, iceg_stomp2); iceg_footstomp(this); this.pain_finished = time + 1; }

//============================================================================
// WAVE BOUNDARY - destroy some objects and spawn adds
//============================================================================
void iceg_aiturn(entity this)
{
	// turn towards a target if one exists
	if(this.enemy)
	{
		// Check if enemy target is bmodel or point entity
		vector org = (this.enemy.absmin + this.enemy.absmax) * 0.5;
		// Force turn towards new target
		this.ideal_yaw = vectoyaw(org - this.origin);
		changeyaw(this);

		// Check angle difference
		if((this.ideal_yaw - 10) > this.angles_y)
			this.attack_elev = true;
		else if((this.ideal_yaw + 10) < this.angles_y)
			this.attack_elev = true;
		else
			this.attack_elev = false;
	}
}

//----------------------------------------------------------------------
void iceg_waveface(entity this)
{
	// Hexen 2 quicktime!
	this.nextthink = time + 0.05;
	iceg_aiturn(this);
}

//----------------------------------------------------------------------
void iceg_waveb24(entity this)
{
	set_animofs(this, anim_icegolem_magic, 24, iceg_run1);
	this.style = ICEG_PHASE2;
	Resist_ChangeType(this, false);
	iceg_waveface(this);
	// Pause before next attack
	this.pain_finished = this.attack_finished = time + 2;
}
void iceg_waveb23(entity this) { set_animofs(this, anim_icegolem_magic, 23, iceg_waveb24); iceg_waveface(this); }
void iceg_waveb22(entity this) { set_animofs(this, anim_icegolem_magic, 22, iceg_waveb23); iceg_waveface(this); }
void iceg_waveb21(entity this) { set_animofs(this, anim_icegolem_magic, 21, iceg_waveb22); iceg_waveface(this); }
void iceg_waveb20(entity this)
{
	set_animofs(this, anim_icegolem_magic, 20, iceg_waveb21);
	iceg_waveface(this);
	if(this.enemy)
	{
		iceg_icestorm(this, this.enemy);
		// Trigger the target entity
		if(this.enemy.use && this.enemy.classname == "monster_icegolem_wavetrig")
			this.enemy.use(this.enemy, this, this);
	}	
}
void iceg_waveb19(entity this) { set_animofs(this, anim_icegolem_magic, 19, iceg_waveb20); iceg_waveface(this); iceg_icestorm(this, this.enemy); }
void iceg_waveb18(entity this) { set_animofs(this, anim_icegolem_magic, 18, iceg_waveb19); iceg_waveface(this); iceg_icestorm(this, this.enemy); }
void iceg_waveb17(entity this) { set_animofs(this, anim_icegolem_magic, 17, iceg_waveb18); iceg_waveface(this); iceg_icestorm(this, this.enemy); }
void iceg_waveb16(entity this) { set_animofs(this, anim_icegolem_magic, 16, iceg_waveb17); iceg_waveface(this); }
void iceg_waveb15(entity this) { set_animofs(this, anim_icegolem_magic, 15, iceg_waveb16); iceg_waveface(this); }
void iceg_waveb14(entity this) { set_animofs(this, anim_icegolem_magic, 14, iceg_waveb15); iceg_waveface(this); }
void iceg_waveb13(entity this)
{
	set_animofs(this, anim_icegolem_magic, 13, iceg_waveb14);
	iceg_waveface(this);
	if(this.enemy)
	{
		iceg_icestorm(this, this.enemy);
		if(this.enemy.classname == "monster_icegolem_wavetrig")
		{
			if(this.enemy.use)
				this.enemy.use(this.enemy, this, this);
			// point at next trigger if valid
			this.enemy = find(NULL, targetname, this.attachment2.noise2);
		}
	}
}
void iceg_waveb12(entity this) { set_animofs(this, anim_icegolem_magic, 12, iceg_waveb13); iceg_waveface(this); iceg_icestorm(this, this.enemy); }
void iceg_waveb11(entity this) { set_animofs(this, anim_icegolem_magic, 11, iceg_waveb12); iceg_waveface(this); iceg_icestorm(this, this.enemy); }
void iceg_waveb10(entity this) { set_animofs(this, anim_icegolem_magic, 10, iceg_waveb11); iceg_waveface(this); iceg_icestorm(this, this.enemy); }
void iceg_waveb9(entity this) { set_animofs(this, anim_icegolem_magic, 9, iceg_waveb10); iceg_waveface(this); }
void iceg_waveb8(entity this) { set_animofs(this, anim_icegolem_magic, 8, iceg_waveb9); iceg_waveface(this); }
void iceg_waveb7(entity this) { set_animofs(this, anim_icegolem_magic, 7, iceg_waveb8); iceg_waveface(this); }
void iceg_waveb6(entity this) { set_animofs(this, anim_icegolem_magic, 6, iceg_waveb7); iceg_waveface(this); }
void iceg_waveb5(entity this) { set_animofs(this, anim_icegolem_magic, 5, iceg_waveb6); iceg_waveface(this); }
void iceg_waveb4(entity this) { set_animofs(this, anim_icegolem_magic, 4, iceg_waveb5); iceg_waveface(this); }
void iceg_waveb3(entity this) { set_animofs(this, anim_icegolem_magic, 3, iceg_waveb4); iceg_waveface(this); }
void iceg_waveb2(entity this) { set_animofs(this, anim_icegolem_magic, 2, iceg_waveb3); iceg_waveface(this); }
void iceg_waveb1(entity this) { set_animofs(this, anim_icegolem_magic, 1, iceg_waveb2); iceg_waveface(this); }

//----------------------------------------------------------------------
void iceg_turnframe(entity this)
{
	// Do nothing if dead
	if(this.health < 1)
		return;
	
	// Check for any special frame events
	//if(this.walkframe == 0 || this.walkframe == 16)
		//monster_footstep(this, false);

	// Keep moving the animation frame forward
	this.walkframe = this.walkframe + 1;
	if(this.walkframe > 33)
		this.walkframe = 0;
	this.frame = anim_icegolem_walk + this.walkframe;
	// Hexen 2 models were designed for 20fps
	this.nextthink = time + 0.05;

	iceg_aiturn(this);
	
	// Facing the first target?
	if(!this.attack_elev)
		setthink(this, iceg_waveb1);
	else
		setthink(this, iceg_turnframe);
}

//----------------------------------------------------------------------
void iceg_waveboundary(entity this)
{
	entity targ = find(NULL, targetname, this.attachment2.noise1);
	if(!targ)
		targ = find(NULL, targetname, this.attachment2.noise2);
	if(!targ)
		targ = this.enemy;
	this.enemy = targ;
	
	// If nothing to shoot at, back to running!
	if(!this.enemy)
	{
		// Back to running!
		setthink(this, iceg_run1);
		this.nextthink = time + 0.05;
	}
	else
	{
		// Time to blow stuff up, switch on resistance and roar!
		this.style = ICEG_PHASE3;
		Resist_ChangeType(this, true);
		_sound(this, CH_WEAPON_SINGLE, "golem/icestorm.wav", 1, ATTN_NORM);
		// Start turning towards target (using walk animation)
		this.walkframe = 0;
		iceg_turnframe(this);
	}
}

//============================================================================
// PAIN (no pain animations)
//============================================================================
void iceg_pain(entity this, entity attacker, float damage, int deathtype)
{
	// Check for boss wave trigger events
	if(iceg_WaveCheck(this))
	{
		iceg_waveboundary(this);
		return;
	}

	// Any pain animation/sound required?
	if(random() < 0.5)
		_sound(this, CH_VOICE, "golem/pain1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "golem/pain2.wav", 1, ATTN_NORM);
}

//============================================================================
// DEATH : Time to melt the heavy water GOLEM!
//============================================================================
void iceg_fadeout(entity this)
{
	this.origin_z = this.origin_z - 0.2;	// Slowly sink into the ground (melting)
	this.alpha = 1 - ((time - this.ltime) / 1);
	if(random() < 0.1)
		SpawnProjectileSmoke(this.origin, 200, 100, 100);
	if(this.alpha <= 0)
	{
		delete(this);
		return;
	}

	this.nextthink = time + 0.01;
}

//----------------------------------------------------------------------
void iceg_startfade(entity this)
{
	// Check for any final trigger events
	if(this.message2 != "")
	{
		FOREACH_ENTITY_STRING(targetname, this.message2,
		{
			if(it.use)
				it.use(it, NULL, this); // TODO: is the null activator even needed?
		});
	}

	// Setup ready for fade away ice->water
	this.frame = anim_icegolem_death + 21; // $death22
	this.alpha = 0.99; 
	this.ltime = time + 2;
	setthink(this, iceg_fadeout);
	iceg_fadeout(this);
}

//----------------------------------------------------------------------
void iceg_brk(entity this, float fdist)
{
	if(fdist > 0)
		ai_forward(this, fdist);
	if(random() < 0.2)
		SpawnProjectileSmoke(this.origin, 200, 50, 150);
	if(random() < 0.4)
		SpawnProjectileSmoke(this.origin, 300, 50, 150);
	if(random() < 0.6)
		SpawnProjectileSmoke(this.origin, 200, 50, 250);
	if(random() < 0.3)
	{
		entity gib = ThrowGib(this, this, "progs/proj_golemrock1.mdl", 50);	// Small Golem rock
		gib.frame = rint(random() * 9);
	}

	//this.nextthink = time + 0.05;
}

//----------------------------------------------------------------------
void iceg_death22(entity this)
{
	set_animofs(this, anim_icegolem_death, 22, iceg_startfade); 
	this.nextthink = time + 4 + random() * 4;
	this.velocity = '0 0 0';
	set_movetype(this, MOVETYPE_NONE);
}
void iceg_death21(entity this) { set_animofs(this, anim_icegolem_death, 21, iceg_death22); iceg_brk(this, 4); }
void iceg_death20(entity this) { set_animofs(this, anim_icegolem_death, 20, iceg_death21); iceg_brk(this, 4); }
void iceg_death19(entity this) { set_animofs(this, anim_icegolem_death, 19, iceg_death20); iceg_brk(this, 4); }
void iceg_death18(entity this) { set_animofs(this, anim_icegolem_death, 18, iceg_death19); iceg_brk(this, 4); }
void iceg_death17(entity this) { set_animofs(this, anim_icegolem_death, 17, iceg_death18); iceg_brk(this, 4); }
void iceg_death16(entity this) { set_animofs(this, anim_icegolem_death, 16, iceg_death17); iceg_brk(this, 4); }
void iceg_death15(entity this) { set_animofs(this, anim_icegolem_death, 15, iceg_death16); iceg_brk(this, 4); }
void iceg_death14(entity this) { set_animofs(this, anim_icegolem_death, 14, iceg_death15); iceg_brk(this, 0); }
void iceg_death13(entity this) { set_animofs(this, anim_icegolem_death, 13, iceg_death14); iceg_brk(this, 0); }
void iceg_death12(entity this) { set_animofs(this, anim_icegolem_death, 12, iceg_death13); iceg_brk(this, 0); }
void iceg_death11(entity this) { set_animofs(this, anim_icegolem_death, 11, iceg_death12); iceg_brk(this, 0); }
void iceg_death10(entity this) { set_animofs(this, anim_icegolem_death, 10, iceg_death11); iceg_brk(this, 0); }
void iceg_death9(entity this) { set_animofs(this, anim_icegolem_death, 9, iceg_death10); iceg_brk(this, 0); }
void iceg_death8(entity this) { set_animofs(this, anim_icegolem_death, 8, iceg_death9); iceg_brk(this, 10); }
void iceg_death7(entity this) { set_animofs(this, anim_icegolem_death, 7, iceg_death8); iceg_brk(this, 12); /*monster_footstep(this, false);*/ }
void iceg_death6(entity this) { set_animofs(this, anim_icegolem_death, 6, iceg_death7); iceg_brk(this, 10); }
void iceg_death5(entity this) { set_animofs(this, anim_icegolem_death, 5, iceg_death6); iceg_brk(this, 5); }
void iceg_death4(entity this) { set_animofs(this, anim_icegolem_death, 4, iceg_death5); iceg_brk(this, 5); }
void iceg_death3(entity this) { set_animofs(this, anim_icegolem_death, 3, iceg_death4); iceg_brk(this, 2); }
void iceg_death2(entity this) { set_animofs(this, anim_icegolem_death, 2, iceg_death3); iceg_brk(this, 0); }
void iceg_death1(entity this) { set_animofs(this, anim_icegolem_death, 1, iceg_death2); iceg_brk(this, 0); }

void iceg_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.effects = 0;			// Remove effects on death
	this.style = ICEG_PHASE4;	// Heavy Water

	_sound(this, CHAN_BODY, "golem/death.wav", 1, ATTN_NORM);
	this.solid = SOLID_NOT;
	iceg_death1(this);
}

//============================================================================
// Wakeup From Statue form
//============================================================================
void iceg_birth(entity this)
{
	if(random() < 0.4) SpawnProjectileSmoke(this.origin, 200, 100, 100);
	if(random() < 0.8) SpawnProjectileSmoke(this.origin, 200, 50, 250);
	if(random() < 0.1)
	{
		entity gib = ThrowGib(this, this, "progs/proj_golemrock1.mdl", 50);	// Small Golem rock
		gib.frame = rint(random() * 9);
	}
	// Hexen 2 models were designed for 20fps
	this.nextthink = time + 0.05;
}

//----------------------------------------------------------------------
void iceg_tranB1(entity this);
void iceg_wake16(entity this) { set_animofs(this, anim_icegolem_birth, 16, iceg_tranB1); iceg_birth(this); }
void iceg_wake15(entity this) { set_animofs(this, anim_icegolem_birth, 15, iceg_wake16); iceg_birth(this); }
void iceg_wake14(entity this) { set_animofs(this, anim_icegolem_birth, 14, iceg_wake15); iceg_birth(this); }
void iceg_wake13(entity this) { set_animofs(this, anim_icegolem_birth, 13, iceg_wake14); iceg_birth(this); }
void iceg_wake12(entity this) { set_animofs(this, anim_icegolem_birth, 12, iceg_wake13); iceg_birth(this); }
void iceg_wake11(entity this) { set_animofs(this, anim_icegolem_birth, 11, iceg_wake12); iceg_birth(this); icegolem_idle_sound(this); }
void iceg_wake10(entity this) { set_animofs(this, anim_icegolem_birth, 10, iceg_wake11); iceg_birth(this); }
void iceg_wake9(entity this) { set_animofs(this, anim_icegolem_birth, 9, iceg_wake10); iceg_birth(this); }
void iceg_wake8(entity this) { set_animofs(this, anim_icegolem_birth, 8, iceg_wake9); iceg_birth(this); /*monster_footstep(this, false);*/ }
void iceg_wake7(entity this) { set_animofs(this, anim_icegolem_birth, 7, iceg_wake8); iceg_birth(this); ai_forward(this, 1); }
void iceg_wake6(entity this) { set_animofs(this, anim_icegolem_birth, 6, iceg_wake7); iceg_birth(this); ai_forward(this, 3); }
void iceg_wake5(entity this) { set_animofs(this, anim_icegolem_birth, 5, iceg_wake6); iceg_birth(this); ai_forward(this, 3); }
void iceg_wake4(entity this) { set_animofs(this, anim_icegolem_birth, 4, iceg_wake5); iceg_birth(this); ai_forward(this, 4); }
void iceg_wake3(entity this) { set_animofs(this, anim_icegolem_birth, 3, iceg_wake4); iceg_birth(this); ai_forward(this, 3); }
void iceg_wake2(entity this) { set_animofs(this, anim_icegolem_birth, 2, iceg_wake3); iceg_birth(this); ai_forward(this, 2); }
void iceg_wake1(entity this)
{
	set_animofs(this, anim_icegolem_birth, 1, iceg_wake2);
	this.use = func_null;				// No more triggers
	this.style = ICEG_PHASE2;			// Free to fight
	this.yaw_speed = 20;	// Really Fast Speed
	
	// Restore all think functions
	this.th_stand = iceg_stand1;
	this.th_walk = iceg_walk1;
	this.th_run = iceg_run1;
	this.th_melee = iceg_knock1;
	this.th_missile = iceg_magic1;
	//this.th_charge = iceg_magic7;
	//this.th_slide = iceg_stomp1;
	//this.th_jump = iceg_waveboundary;
	this.th_pain = iceg_pain;
	this.th_die = iceg_die;
	
	this.pain_finished = time + 3;		// Make pain go away
	this.attack_finished = time + 2;	// Reset attack system

	iceg_birth(this);
	_sound(this, CHAN_BODY, "golem/wakestatue.wav", 1, ATTN_NORM);
}

void iceg_wake(entity this, entity actor, entity trigger)
{
	// Setup player focus
	if(IS_PLAYER(actor))
		this.goalentity = this.enemy = actor;
	else
		this.enemy = NULL;

	iceg_wake1(this);
}

void iceg_tranB13(entity this)
{
	set_animofs(this, anim_icegolem_tranB, 13, iceg_run1);
	//monster_footstep(this, false);
	this.takedamage = DAMAGE_YES;	// Can take damage
	this.style = ICEG_PHASE2;		// Time to fight!
	Resist_ChangeType(this, false);	// restore resistance
	this.walkframe = 13;			// Mid way through set
	iceg_runframe(this);
}
void iceg_tranB12(entity this) { set_animofs(this, anim_icegolem_tranB, 12, iceg_tranB13); iceg_birth(this); ai_forward(this, 5); }
void iceg_tranB11(entity this) { set_animofs(this, anim_icegolem_tranB, 11, iceg_tranB12); iceg_birth(this); ai_forward(this, 5); }
void iceg_tranB10(entity this) { set_animofs(this, anim_icegolem_tranB, 10, iceg_tranB11); iceg_birth(this); ai_forward(this, 5); }
void iceg_tranB9(entity this) { set_animofs(this, anim_icegolem_tranB, 9, iceg_tranB10); iceg_birth(this); ai_forward(this, 5); }
void iceg_tranB8(entity this) { set_animofs(this, anim_icegolem_tranB, 8, iceg_tranB9); iceg_birth(this); ai_forward(this, 5); }
void iceg_tranB7(entity this) { set_animofs(this, anim_icegolem_tranB, 7, iceg_tranB8); iceg_birth(this); ai_forward(this, 5); icegolem_idle_sound(this); }
void iceg_tranB6(entity this) { set_animofs(this, anim_icegolem_tranB, 6, iceg_tranB7); iceg_birth(this); ai_forward(this, 5); }
void iceg_tranB5(entity this) { set_animofs(this, anim_icegolem_tranB, 5, iceg_tranB6); iceg_birth(this); ai_forward(this, 5); }
void iceg_tranB4(entity this) { set_animofs(this, anim_icegolem_tranB, 4, iceg_tranB5); iceg_birth(this); ai_forward(this, 5); }
void iceg_tranB3(entity this) { set_animofs(this, anim_icegolem_tranB, 3, iceg_tranB4); iceg_birth(this); ai_forward(this, 5); icegolem_idle_sound(this); }
void iceg_tranB2(entity this) { set_animofs(this, anim_icegolem_tranB, 2, iceg_tranB3); iceg_birth(this); ai_forward(this, 5); }
void iceg_tranB1(entity this)
{
	set_animofs(this, anim_icegolem_tranB, 1, iceg_tranB2);
	_sound(this, CH_VOICE, "golem/sight.wav", 1, ATTN_NORM);
	iceg_birth(this);
	ai_forward(this, 8);
}

void iceg_setup(entity this)
{
	this.style = ICEG_PHASE1;
	this.takedamage = DAMAGE_NO;
	this.skin = 1; // frozen skin
	this.pain_finished = this.attack_finished = 999999;

	// Setup Ammo Resistance
	this.resist_shells = this.resist_cells = 0;
	this.resist_nails = this.resist_rockets = 0.75;
	//this.reflectnails = true;		// Reflect nail projectiles
	//this.reflectaxe = true;			// Prevent axe damage

	Resist_Save(this);				// Save for Later
	Resist_ChangeType(this, true);	// resist everything

	// Setup boss waves and overall health
	this.bosswave = 1;
	this.bosswavetotal = 5;
	this.bosswaveqty = 500;
	this.max_health = this.bosswavetotal * this.bosswaveqty;
	// Setup boss wave HP + trigger event
	iceg_WaveSetupHP(this);

	// default = No think functions
	this.checkattack = IcegCheckAttack;
	this.th_stand = this.th_walk = this.th_run = func_null;
	this.th_missile = func_null;
	this.th_die = func_null;
	this.th_pain = func_null;

	// Make sure all death triggers are setup ready
	this.message2 = this.target;
	this.target = this.target2 = this.deathtarget = "";

	this.yaw_speed = 20;
	
	// Wait for trigger event to be wakeup
	if(this.targetname && this.targetname != "")
		this.use = iceg_wake;
	else
		iceg_wake1(this);
}

//======================================================================
/*QUAKED monster_icegolem (1 0.2 0) (-32 -32 -24) (32 32 128)
======================================================================*/
spawnfunc(monster_icegolem) { monster_start(this, true, MON_ICE_GOLEM); }
#endif // SVQC

#ifdef SVQC
METHOD(IceGolem, mr_setup, bool(IceGolem this, entity actor))
{
	TC(IceGolem, this);

	precache_model("progs/proj_ringshock.mdl");
	precache_model("progs/proj_ringblast.mdl");
	precache_model("progs/proj_golemrock1.mdl");
	precache_model("progs/proj_golemrock2.mdl");
	precache_model("progs/proj_golemshard.mdl");

	precache_sound("golem/idle1a.wav");
	precache_sound("golem/idle1b.wav");
	precache_sound("golem/idle2a.wav");
	precache_sound("golem/idle2b.wav");

	// Break free of statue pose
	precache_sound("golem/wakestatue.wav");

	// Several melee smack sounds and giant ground slam
	precache_sound("golem/melee_swipe.wav");
	precache_sound("golem/melee_punch.wav");
	precache_sound("golem/melee_pound.wav");
	precache_sound("golem/groundslam.wav");

	precache_sound("break/rock_impact.wav");
	precache_sound("break/rock_i1.wav");
	precache_sound("break/rock_i2.wav");

	if(actor.brkobj1 == "")
		actor.brkobj1 = "maps/ad_brk/rock01.bsp";
	precache_model(actor.brkobj1);

	if(actor.brkobj2 == "")
		actor.brkobj2 = "maps/ad_brk/rock02.bsp";
	precache_model(actor.brkobj2);

	// Ice Storm - range attack
	precache_sound("golem/icestorm.wav");
	precache_sound("golem/iceshard1.wav");
	precache_sound("golem/iceshard2.wav");
	precache_sound("golem/iceshard3.wav");
	precache_sound("golem/iceshard_impact.wav");
	precache_model("progs/s_exp_ice_big.spr"); // Shard impact (ne_ruin)

	precache_sound("golem/pain1.wav");
	precache_sound("golem/pain2.wav");
	precache_sound("golem/death.wav");

	iceg_setup(actor);

	return true;
}
#endif

#ifdef SVQC
//======================================================================
/*QUAKED monster_icegolem_wavetrig (0.75 0.25 1) (-32 -32 -8) (32 32 8) x
Target for boss column smash wave event
-------- KEYS --------
targetname : name of wave event (links to noise key on boss)
target     : trigger name of adds to spawn
noise1     : trigger name of column 1
noise2     : trigger name of column 2
-------- SPAWNFLAGS --------
-------- NOTES --------
Target for boss column smash wave event

======================================================================*/
spawnfunc(monster_icegolem_wavetrig) 
{
	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_NONE);
	this.takedamage = DAMAGE_NO;
	setsize(this, '0 0 0', '0 0 0');
}
#endif
