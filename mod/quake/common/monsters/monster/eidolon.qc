#include "eidolon.qh"

#ifdef SVQC
const int anim_eidolon_stand = 0; //'0 14 0'
const int anim_eidolon_walk = 14; //'14 37 0'
const int anim_eidolon_spell = 38; //'38 57 0'
const int anim_eidolon_howl = 58; //'58 85 0'
const int anim_eidolon_crouch = 86; //'86 115 0'
const int anim_eidolon_crWait = 116; //'116 130 0'
const int anim_eidolon_grow = 131; //'131 154 0'
const int anim_eidolon_breath = 155; //'155 197 0'
const int anim_eidolon_power = 198; //'198 217 0'
const int anim_eidolon_painA = 218; //'218 226 0'
const int anim_eidolon_painB = 227; //'227 246 0'

/*==============================================================================
Eidolon Demon from Hexen2 / Altar of Storms MOD
==============================================================================*/

const int EIDOLON_PHASE1 = 1;	// Trapped in cage
const int EIDOLON_PHASE2 = 2;	// Fighting

.float bosswavetotal;
.float bosswave;
.float bosswaveqty;
.float bosswavetrig;

.entity attachment;
.entity attachment2;

.entity movelast;

// Work out angle difference between player and boss
//----------------------------------------------------------------------
bool eidolon_angcheck(entity this, vector targorg, float angdiff)
{
	this.ideal_yaw = vectoyaw(targorg - this.origin);
	if((this.ideal_yaw - angdiff) > this.angles_y)
		return true;
	else if((this.ideal_yaw + angdiff) < this.angles_y)
		return true;
	return false;
}

//----------------------------------------------------------------------
// Need own find player function because of arena size
// Also setup all parameters ready to start combat quicker
//----------------------------------------------------------------------
bool eidolon_FindTarget(entity this)
{
	// Get the obvious exception(s) done first
	if(this.health < 1)
		return false;
	if(intermission_running > 0)
		return false;

	// Find a client in current PVS
	entity client;
	if(this.charmed)
	{
		RandomSelection_Init();
		FOREACH_ENTITY_FLAGS(flags, FL_MONSTER,
		{
			if(it != this && this.enemy != it && it.health > 0 && !(it.flags & FL_NOTARGET))
			{
				traceline(CENTER_OR_VIEWOFS(this), it.origin, true, this);
				if(trace_fraction != 1)
					continue;
				RandomSelection_AddEnt(it, 1, 1);
			}
		});
		client = RandomSelection_chosen_ent;
	}
	else
		client = t_checkclient(this);
	
	// Go through all the exception(s)
	if(!client) return false;
	if(!IS_PLAYER(client) && !this.charmed) return false;
	if(!IS_MONSTER(client) && this.charmed)
	if(client.flags & FL_NOTARGET) return false;
	if(client.powerups & POWERUP_INVISIBILITY) return false;
	
	// Check range and visibility of player
	this.enemy_visible = visible(this, client);
	if(!this.enemy_visible) return false;
	if(!infront(this, client)) return false;

	// Finally found something
	this.enemy = client;
	this.oldorigin = this.origin;		// Save origin
	this.goalentity = this.enemy;		// Focus on enemy
	// Setup turning angle towards new enemy
	this.ideal_yaw = vectoyaw(this.enemy.origin - this.origin);

	// Stage 1 is trapped, boss cannot attack or run
	if(this.style == EIDOLON_PHASE1)
		return false;

	// Move straight into run+attack
	this.nextthink = time + 0.1;
	setthink(this, this.th_run);		// Start running
	this.attack_finished = time + 1;

	// We have a winner!
	return true;	
}

//----------------------------------------------------------------------
// Setup wave HP and trigger boundaries
//----------------------------------------------------------------------
void eidolon_WaveSetupHP(entity this)
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
// Check if HP reached next wave, walk to center and fire targets
//----------------------------------------------------------------------
void eidolon_attackE1(entity this);
bool eidolon_WaveCheck(entity this)
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
			if(this.attachment2.classname == "monster_eidolon_wavetrig")
			{
				// Spawn any adds to keep player busy
				if(this.attachment2.target && this.attachment2.target != "") 
				{
					FOREACH_ENTITY_STRING(targetname, this.attachment2.target,
					{
						if(it.use)
							it.use(it, NULL, this);
					});
				}
				
				// Turn around and fire at crystal
				eidolon_attackE1(this);
			}
		}

		// Update Boss wave parameters (next wave!)
		this.bosswave += 1;
		eidolon_WaveSetupHP(this);		// Reset trigger/hp
		return true;
	}
	return false;
}

//======================================================================
// MONSTER STATES (stand, walk run, attack, pain and death!
//======================================================================
void eidolon_idle(entity this)
{
	// Do nothing if dead
	if(this.health < 1)
		return;
	if(this.walkframe == 1 && random() < 0.15)
	{
		if(random() < 0.5)
			_sound(this, CH_VOICE, "eidolon/idle1.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "eidolon/idle2.wav", 1, ATTN_IDLE);
	}
	this.nextthink = time + 0.05;

	// Keep moving the animation frame forward
	this.walkframe += 1;
	if(this.walkframe > 14)
		this.walkframe = 0;
	this.frame = anim_eidolon_stand + this.walkframe;
	
	// Keep looking for a player
	eidolon_FindTarget(this);
	
	if(this.style == EIDOLON_PHASE1)
	{
		// Slow animation speed, trapped inside cage
		this.nextthink = time + 0.1;
		// Found a player, now track them around the room
		if(IS_PLAYER(this.enemy) || IS_MONSTER(this.enemy))
		{
			if(eidolon_angcheck(this, this.enemy.origin, 60)) 
				setthink(this, this.th_walk);
		}
	}
}

void eidolon_stand1(entity this) { set_animofs(this, anim_eidolon_stand, 1, eidolon_idle); this.walkframe = 0; }

//======================================================================
// There is only one set of animations for walk and run and
// the only different is the final AI state (walk/run) 
// This is a hexen2 model so it should run at 20fps not 10fps
//----------------------------------------------------------------------
const int EIDOLON_WALK = 2;
const int EIDOLON_RUN = 4;

//----------------------------------------------------------------------
void eidolon_move(entity this, int fstate)
{
	// Do nothing if dead
	if(this.health < 1)
		return;
	this.nextthink = time + 0.05;
	
	// Keep moveing the animation frame forward
	this.walkframe += 1;
	if(this.walkframe > 23)
		this.walkframe = 0;
	this.frame = anim_eidolon_walk + this.walkframe;
	
	// Check for any special frame events
	if(this.frame == anim_eidolon_walk && random() < 0.15)
	{
		if(random() < 0.5)
			_sound(this, CH_VOICE, "eidolon/idle1.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "eidolon/idle2.wav", 1, ATTN_IDLE);
	}
	
	// Phase 1 (caged) uses walk to turn around
	if(this.style == EIDOLON_PHASE1)
	{
		// Wrong angle difference? keep turning
		if(eidolon_angcheck(this, this.enemy.origin, 10))
			changeyaw(this);
		else
		{
			// Close the beginning or the end of the animation?
			if(this.walkframe < 4 || this.walkframe > 20) 
				setthink(this, this.th_stand);
		}
	}
	// Phase 2 (free) walking back to center
	else if(this.style == EIDOLON_PHASE2 && fstate == EIDOLON_WALK)
	{
		// Check for player
		if(eidolon_FindTarget(this))
			return;

		// Reached origin point yet?
		if(vdist(this.movelast.origin - this.origin, <, 80))
		{
			// Still remember the old player?
			if(IS_PLAYER(this.oldenemy))
			{
				this.enemy = this.oldenemy;
				this.oldenemy = NULL;
			}
			// Keep turning towards old player
			if(eidolon_angcheck(this, this.enemy.origin, 10))
				changeyaw(this);
			else
				setthink(this, this.th_stand);
		}
		// Still not reached center
		else
			t_movetogoal(this, 6);
	}
	// Time to walk or run?
	else if(fstate == EIDOLON_RUN && this.enemy)
		ai_run(this, 6);
}

void eidolon_walk1(entity this) { set_animofs(this, anim_eidolon_walk, 1, eidolon_walk1); eidolon_move(this, EIDOLON_WALK); }
void eidolon_run1(entity this) { set_animofs(this, anim_eidolon_walk, 1, eidolon_run1); eidolon_move(this, EIDOLON_RUN); }

//============================================================================
// Attachment management (create, finish and delete)
//============================================================================
void eidolon_create_attachment(entity this)
{
	// Are the attachments setup yet?
	if(!this.attachment)
	{
		this.attachment = spawn();
		this.attachment.owner = this;
		this.attachment.classname = "attachment";
		this.attachment.mdl = "progs/proj_eidolonrock1.mdl";
	}
}

//----------------------------------------------------------------------
void eidolon_setup_attachment(entity this)
{
	// Is monster dead or dying?
	if(this.health < 1)
		return;

	// Check if attachment has been setup yet
	if(!this.attachment)
		eidolon_create_attachment(this);

	// Move attachment into place ready for use
	set_movetype(this.attachment, MOVETYPE_NONE);
	this.attachment.solid = SOLID_NOT;
	setmodel(this.attachment, MDL_Null);
	setsize(this.attachment, '0 0 0', '0 0 0');
	setorigin(this.attachment, this.origin);
	// Using empty model, so reset angle, frame and skin.
	this.attachment.angles = this.angles;
	this.attachment.frame = this.attachment.skin = 0;
}

//----------------------------------------------------------------------
void eidolon_finish_attachment(entity this)
{
	if(this.attachment)
	{
		_setmodel(this.attachment, "");
	}
}

//----------------------------------------------------------------------
void eidolon_remove_attachment(entity this)
{
	if(this.attachment)
	{
		setthink(this.attachment, SUB_Remove);
		this.attachment.nextthink = time + 0.1;
	}
	this.attachment = NULL;
}

//======================================================================
// ATTACK A  - Fire large explosive rock (grenade)
// Animation - Spell, put right hand up and infront
//======================================================================
void eidolon_launchmissile(entity this, vector org, vector dir)
{
	entity newmis = launch_spike(this, org, dir);
	_setmodel(newmis, "progs/proj_eidolonrock1.mdl");
	newmis.avelocity = randomvec() * 200;
	newmis.dmg = 25;
	newmis.frame = 7;
	setsize(newmis, '0 0 0', '0 0 0');
	if(random() < 0.5)
		newmis.noise = "eidolon/rock_hit1.wav";
	else
		newmis.noise = "eidolon/rock_hit2.wav";
	newmis.nextthink = time + 7;
	setthink(newmis, SUB_Remove);
	newmis.velocity = dir * (400 + (autocvar_skill * 150) + random()*10);
	settouch(newmis, T_MissileTouch); // rocket explosion
	newmis.projectiledeathtype = DEATH_MONSTER_EIDOLON.m_id;
}

void Fire_attackA(entity this, vector rockofs)
{
	// Finished with growing rock
	eidolon_finish_attachment(this);

	if(!this.enemy)
		return;
	if(this.health < 1)
		return;

	makevectors(this.angles);
	vector org = this.origin + attack_vector(rockofs);
	this.effects |= EF_MUZZLEFLASH;

	// create an arc of rockets fanning outwards from source
	float foffset = 8;
	float offset = -foffset;
	int shotcount = 3;
	while(shotcount > 0)
	{
	// based angle of projectiles on straight line between source and target
		vector offang = vectoangles((this.enemy.origin-'0 0 24') - org);
		offang.y += offset;
		fixedmakevectors(offang);
	
		// Randomly spawn projectiles around central point
		vector sorg = org + v_up * (5 + random() * 10);
		
		// Straight line velocity from source to target
		vector dir = normalize(v_forward);
		dir.z = 0 - dir.z + (random() - 0.5)*0.1;	// Slight wiggle up/down
		
		// Variable speed based on skill level with extra random spice
		eidolon_launchmissile(this, sorg, dir);
		offset += foffset;
		shotcount -= 1;
	}
}

//----------------------------------------------------------------------
void Setup_attackA(entity this, vector rockofs, float rockframe)
{
	// Check if attachment has been setup yet
	if(!this.attachment) 
		eidolon_create_attachment(this);
	
	// Frame 0 is start of the sequence (move everything into place)
	if(rockframe == 0)
	{
		set_movetype(this.attachment, MOVETYPE_NONE);
		this.attachment.solid = SOLID_NOT;

		_setmodel(this.attachment, this.attachment.mdl);
		setsize(this.attachment, '0 0 0', '0 0 0');

		// Start throwing rock sound
		_sound(this, CH_WEAPON_SINGLE, "eidolon/attacka.wav", 1, ATTN_NORM);
	}

	// Turn towards enemy and update model attachment
	// The offset is based on the Eidolon facing forward
	makevectors(this.angles);
	vector org = this.origin + attack_vector(rockofs);
	setorigin(this.attachment, org);
	this.attachment.angles = this.angles;
	this.attachment.angles_x = random()*360;
	this.attachment.frame = rockframe;
	// Random explosion like particles from ball as it grows
	//particle_explode(this.attachment.origin, 10+random()*10, 0.5+random(), PARTICLE_BURST_WHITE, 0);
	te_explosion2(this.attachment.origin, 10 + rint(random()*10), 0.5 + random());
}

//----------------------------------------------------------------------
void eidolon_attackA2(entity this)
{
	// Do nothing if dead
	if(this.health < 0)
		return;

	this.nextthink = time + 0.05;
	
	// Keep moveing the animation frame forward
	this.walkframe = this.walkframe + 1;
	if(this.walkframe > 19)
		setthink(this, this.th_run);
	this.frame = anim_eidolon_spell + this.walkframe;
	
	// Keep turning towards the player
	if(this.frame < anim_eidolon_spell + (4 - 1))
		ai_face(this);
	
	// Check the state of the projectile (grow/fire)
	if(this.frame == anim_eidolon_spell + (3 - 1)) eidolon_setup_attachment(this);
	else if(this.frame == anim_eidolon_spell + (4 - 1)) Setup_attackA(this, '60 18 64',0);
	else if(this.frame == anim_eidolon_spell + (5 - 1)) Setup_attackA(this, '62 18 68',1);
	else if(this.frame == anim_eidolon_spell + (6 - 1)) Setup_attackA(this, '64 18 72',2);
	else if(this.frame == anim_eidolon_spell + (7 - 1)) Setup_attackA(this, '68 18 78',3);
	else if(this.frame == anim_eidolon_spell + (8 - 1)) Setup_attackA(this, '72 18 86',4);
	else if(this.frame == anim_eidolon_spell + (9 - 1)) Setup_attackA(this, '74 18 96',5);
	else if(this.frame == anim_eidolon_spell + (10 - 1)) Setup_attackA(this, '70 18 104',6);
	else if(this.frame == anim_eidolon_spell + (11 - 1)) Setup_attackA(this, '72 18 112',7);
	else if(this.frame == anim_eidolon_spell + (12 - 1)) Setup_attackA(this, '73 18 112',7);
	else if(this.frame == anim_eidolon_spell + (13 - 1)) Fire_attackA(this, '73 18 112');
}

//----------------------------------------------------------------------
void eidolon_attackA1(entity this)
{
	set_animofs(this, anim_eidolon_spell, 1, eidolon_attackA2);
	ai_face(this);
	this.pain_finished = time + 1.5;
	this.walkframe = 0;
}

//======================================================================
// ATTACK B - Drops rocks randomly from above player
// Animation - Howl, raise arms up and then pull down
//======================================================================
void eidolon_attackB1(entity this)
{
}

//======================================================================
// ATTACK C - Projectile vomit rocks and dust at the player
// Animation - breathe, swings arms back and push head forward
//======================================================================
void rock_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float vol = 0.5 + random() * 0.5;
	float r = random();
	if(r < 0.25)
		_sound(this, CH_WEAPON_SINGLE, "break/rock_i1.wav", vol, 2);
	else if(r < 0.5)
		_sound(this, CH_WEAPON_SINGLE, "break/rock_i2.wav", vol, 2);
	else if(r < 0.75)
		_sound(this, CH_WEAPON_SINGLE, "break/rock_i3.wav", vol, 2);
	else
		_sound(this, CH_WEAPON_SINGLE, "break/rock_i4.wav", vol, 2);
	
// hit something that bleeds
	if(toucher.takedamage) // yoder mod, jan 05 2021
	{
		float damg = 9;
		spawn_touchblood(this, damg, toucher);
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}
	else
		te_gunshot(this.origin);

	delete(this);
}

void Fire_attackC(entity this, vector rockofs)
{
	if(!this.enemy)
		return;
	if(this.health < 1)
		return;

	makevectors(this.angles);
	// Spawn a mist of particles where projectiles came from
	vector org = this.origin + attack_vector(rockofs) + v_right*(crandom()*8) + v_up*(crandom()*16);

	vector dir = normalize(this.enemy.origin - org);
	te_explosion2(org, 5 + rint(random()*5), 2);
	//particle_explode(org, 5 + rint(random()*5), 2, PARTICLE_BURST_WHITE, PARTICLE_BURST_UPWARD);
	
	this.effects |= EF_MUZZLEFLASH;

	entity newmis = launch_spike(this, org, dir);
	newmis.projectiledeathtype = DEATH_MONSTER_EIDOLON.m_id;
	if(random() < 0.5)
		_setmodel(newmis, "progs/proj_golemrock1.mdl");
	else if(random() < 0.5)
		_setmodel(newmis, "progs/piano_musicnote_brown.mdl");
	else
		_setmodel(newmis, "progs/proj_golemrock2.mdl");
	newmis.avelocity = randomvec() * 200;
	setsize(newmis, '0 0 0', '0 0 0');
	newmis.frame = rint(random() * 9);
	newmis.velocity = dir * (400 + (autocvar_skill * 225));
	settouch(newmis, rock_touch);
}

//----------------------------------------------------------------------
void eidolon_attackC2(entity this)
{
	// Do nothing if dead
	if(this.health < 0)
		return;

	this.nextthink = time + 0.05;
	// Keep turning towards the player
	ai_face(this);
	
	// Keep moveing the animation frame forward
	this.walkframe = this.walkframe + 1;
	if(this.walkframe > 43)
		setthink(this, this.th_run);
	this.frame = anim_eidolon_breath + this.walkframe;
	
	// Start demon roar and then rocks!?!
	if(this.frame == anim_eidolon_breath + (4 - 1))
		_sound(this, CH_WEAPON_SINGLE, "eidolon/attackc.wav", 1, ATTN_NORM);
	
	// Rock breath!?!
	if(this.frame > anim_eidolon_breath + (17 - 1) && this.frame < anim_eidolon_breath + (35 - 1))
		Fire_attackC(this, '56 0 44');
}

//----------------------------------------------------------------------
void eidolon_attackC1(entity this)
{
	set_animofs(this, anim_eidolon_breath, 1, eidolon_attackC2);
	ai_face(this);
	this.pain_finished = time + 2;
	this.walkframe = 0;
}

//======================================================================
// ATTACK D - Throw a bunch of rocks upward towards the player
// Animation - death/grow, crouch down and swing arms upward
//======================================================================
void eidolon_attackD1(entity this)
{
}

//======================================================================
// ATTACK E - Summon monsters from blocks of stone
// Animation - power, lean head back, put hands up right infront
//======================================================================
void Setup_attackE(entity this, vector rockofs, int rockframe)
{
	// Check if attachment has been setup yet
	if(!this.attachment)
		eidolon_create_attachment(this);
	
	// Frame 0 is start of the sequence (move everything into place)
	if(rockframe == 0)
	{
		set_movetype(this.attachment, MOVETYPE_NONE);
		this.attachment.solid = SOLID_NOT;
		setorigin(this.attachment, this.origin);
		_setmodel(this.attachment, this.attachment.mdl);
		setsize(this.attachment, '0 0 0', '0 0 0');
		this.attachment.skin = 1;

		// Start long growl
		_sound(this, CH_VOICE, "eidolon/attacke.wav", 1, ATTN_NORM);
		_sound(this, CH_WEAPON_SINGLE, "weapons/lhit.wav", 1, ATTN_NORM);
	}
	
	if(rockframe == 7)
	{
		// Goodbye little rock!
		eidolon_finish_attachment(this);
		// Wakeup crystal and golems
		if(this.attachment2.target2 && this.attachment2.target2 != "")
		{
			FOREACH_ENTITY_STRING(targetname, this.attachment2.target2,
			{
				if(it.use)
					it.use(it, NULL, this);
			});
		}
	}
	else
	{
		// Turn towards enemy and update model attachment
		// The offset is based on the Eidolon facing forward
		makevectors(this.angles);
		vector org = this.origin + attack_vector(rockofs);
		setorigin(this.attachment, org);
		this.attachment.angles = this.angles;
		this.attachment.angles_x = random()*360;
		this.attachment.frame = rockframe;
		// Random explosion like particles from ball as it grows
		//particle_explode(this.attachment.origin, 10+random()*10, 0.5+random(), PARTICLE_BURST_BLUE, 0);
		te_explosion2(this.attachment.origin, 10 + rint(random()*10), 0.5+random());

		// Generate the lightning effect
		this.effects |= EF_MUZZLEFLASH;
		SendCSQCLightningBeam(this.attachment.origin, this.attachment2.origin);
	}
}

void eidolon_attackE_firing(entity this)
{
	this.nextthink = time + 0.1;
	
	// Keep moveing the animation frame forward
	this.walkframe += 1;
	// is the lightning spell finished?
	if(this.walkframe > 19)
	{
		setthink(this, this.th_run);
		this.walkframe = 0;
		Resist_ChangeType(this, false);
		this.takedamage = DAMAGE_YES;
		this.goalentity = this.enemy;
	}
	this.frame = anim_eidolon_power + this.walkframe;

	// Check the state of the projectile (grow/fire)
	if(this.frame == anim_eidolon_power + (7 - 1)) Setup_attackE(this, '68 16 84',0);
	else if(this.frame == anim_eidolon_power + (8 - 1)) Setup_attackE(this, '72 16 92',1);
	else if(this.frame == anim_eidolon_power + (9 - 1)) Setup_attackE(this, '74 16 94',2);
	else if(this.frame == anim_eidolon_power + (10 - 1)) Setup_attackE(this, '76 16 98',3);
	else if(this.frame == anim_eidolon_power + (11 - 1)) Setup_attackE(this, '76 16 102',4);
	else if(this.frame == anim_eidolon_power + (12 - 1)) Setup_attackE(this, '78 16 104',5);
	else if(this.frame == anim_eidolon_power + (13 - 1)) Setup_attackE(this, '80 16 104',7);
}

void eidolon_attackE2(entity this)
{
	set_animofs(this, anim_eidolon_power, 1, eidolon_attackE_firing);
	this.walkframe = 0;
}

void eidolon_attackE_turning(entity this)
{
	this.nextthink = time + 0.05;
	
	// Turn towards the power crystal
	if(eidolon_angcheck(this, this.attachment2.origin, 5))
		changeyaw(this);
	
	// Keep moveing the animation frame forward
	this.walkframe += 1;
	if(this.walkframe > 23)
	{
		setthink(this, eidolon_attackE2);
		this.walkframe = 0;
	}
	this.frame = anim_eidolon_walk + this.walkframe;
	
	// Move slowly closer to crystal or backward!
	if(vdist(this.attachment2.origin - this.origin, >, 192))
		t_movetogoal(this, 6);
	else
		t_walkmove(this, this.ideal_yaw - 180, 3);
}

void eidolon_attackE1(entity this)
{
	set_animofs(this, anim_eidolon_walk, 1, eidolon_attackE_turning);
	Resist_ChangeType(this, true);
	this.takedamage = DAMAGE_NO;
	this.goalentity = this.attachment2;
	this.yaw_speed = 6;		// Turning slowly
	this.walkframe = 0;		// Reset animation counter
	
	// Check angle difference betweem boss and crystal
	// If within 5 degree's tolerance, skip turning
	if(!eidolon_angcheck(this, this.attachment2.origin, 5)) 
		setthink(this, eidolon_attackE2);
}

//============================================================================
// PAIN and DEATH
//============================================================================
void eidolon_painA2(entity this)
{
	// Do nothing if dead
	if(this.health < 1)
		return;
	this.nextthink = time + 0.1;

	// Keep moveing the animation frame forward
	this.walkframe += 1;
	if(this.walkframe > 8)
	{
		this.frame = anim_eidolon_painA + (8 - 1);
		setthink(this, eidolon_run1);
	}
	else
		this.frame = anim_eidolon_painA + this.walkframe;
}
void eidolon_painA1(entity this) { set_animofs(this, anim_eidolon_painA, 1, eidolon_painA2); this.walkframe = 0; }

void eidolon_painB2(entity this)
{
	// Do nothing if dead
	if(this.health < 1)
		return;
	this.nextthink = time + 0.05;

	// Keep moveing the animation frame forward
	this.walkframe += 1;
	if(this.walkframe > 19)
	{
		this.frame = anim_eidolon_painB + (20 - 1);
		setthink(this, eidolon_run1);
	}
	else
		this.frame = anim_eidolon_painB + this.walkframe;
}
void eidolon_painB1(entity this) { set_animofs(this, anim_eidolon_painB, 1, eidolon_painB2); this.walkframe = 0; }

void eidolon_pain(entity this, entity attacker, float damage, int deathtype)
{
	// Finish with all attachments
	eidolon_finish_attachment(this);

	// Check for boss wave trigger events
	if(eidolon_WaveCheck(this))
		return;

	if(time < this.pain_finished)
		return;

	if(random()*400 > damage)
		return;		// didn't flinch

	_sound(this, CH_VOICE, "eidolon/pain.wav", 1, ATTN_NORM);

	if(random() < 0.7)
		eidolon_painA1(this);
	else
	{
		eidolon_painB1(this);
		this.pain_finished = time + 2;
	}
}

//============================================================================
// Oh no rocky has died!?!
//============================================================================
void eidolon_explode(entity this)
{
	// Check for any final trigger events
	if(this.message2 && this.message2 != "")
	{
		FOREACH_ENTITY_STRING(targetname, this.message2,
		{
			if(it.use)
				it.use(it, NULL, this);
		});
	}
	
	// Blue ID particle explosion
	te_explosion2(this.origin, 35, 8);
	
	// Classic sprite/DP explosion
	SpawnExplosion(EXPLODE_PLASMA_BIG, this.origin, "eidolon/explode_death.wav");

	// Gib explosive fountain!?!
	ThrowGib(this, "progs/proj_golemrock1.mdl", -500);	// Small Golem rock
	ThrowGib(this, "progs/proj_golemrock2.mdl", -500);	// Large Golem rock
	ThrowGib(this, "progs/gib1.mdl", -500);		// Some flesh bits
	ThrowGib(this, "progs/gib2.mdl", -500);

	if(this.movelast)
		delete(this.movelast);

	delete(this);
}

//----------------------------------------------------------------------
void eidolon_die2(entity this)
{
	this.nextthink = time + 0.1;
	
	// Keep moveing the animation frame forward
	if(this.walkframe < 30)
	{
		this.walkframe += 1;
		this.frame = anim_eidolon_crouch + this.walkframe;
	}
	else
	{
		// Make sure final frame is set
		this.frame = anim_eidolon_crouch + (30 - 1); // animations are off by one!

		// Spawn implosion effect
		if(random() < 0.5)
		{
			particle(this.origin, '0 0 1' * (20 + random() * 20), 100, 100);
			//particle_implode(this.origin, 20+random()*20, 100, 100, PARTICLE_BURST_WHITE);
		}
		// Spawn particle smoke and explosive smoke
		else
		{
			SpawnProjectileSmoke(this.origin, 150, 100, 300);
			particle(this.origin, '0 0 1' * (10 + random() * 10), 16, 16);
			//particle_dust(this.origin, 10+random()*10, 16, PARTICLE_BURST_WHITE);
		}
	
		// Check for any random lightning strikes outward
		if(random() < 0.5)
		{
			vector rpos1 = this.origin - '0 0 16';
			vector rpos2 = randomvec() * 50;
			rpos2.z = 25 + random() * 25;
			rpos2 = normalize(rpos2);
			traceline(rpos1, rpos1 + rpos2 * 600, false, this);
			
			// Create lightning bolt
			SendCSQCLightningBeam(this.origin, trace_endpos);

			// Play some arching lightning sounds
			if(random() < 0.5)
			{
				if(random() < 0.5)
					_sound(this, CHAN_BODY, "eidolon/elec_arch1.wav", 1, ATTN_NORM);
				else
					_sound(this, CHAN_BODY, "eidolon/elec_arch2.wav", 1, ATTN_NORM);
			}
		}
	
		// Cycle through end phase
		this.lip += 1;
		this.nextthink = time + 0.1;	// Slow down to regular time
		if(this.lip == 26)
			_sound(this, CH_VOICE, "eidolon/implode_death.wav", 1, ATTN_NONE);
		if(this.lip > 40)
			eidolon_explode(this);
	}
}

void eidolon_die1(entity this)
{
	set_animofs(this, anim_eidolon_crouch, 1, eidolon_die2);
	this.walkframe = this.lip = 0;
	this.solid = SOLID_NOT;
}

void eidolon_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.deadflag = DEAD_DEAD;		// the rock finally crashed
	this.effects = 0;				// Remove effects on death
	eidolon_finish_attachment(this);	// Remove any attachments
	eidolon_remove_attachment(this);

	_sound(this, CH_VOICE, "eidolon/death.wav", 1, ATTN_NORM);
	eidolon_die1(this);
}

//======================================================================
// Roar and break free from cage!
//======================================================================
void eidolon_free2(entity this)
{
	// Do nothing if dead
	if(this.health < 1)
		return;

	this.nextthink = time + 0.1;
	
	// Keep moveing the animation frame forward
	this.walkframe += 1;
	if(this.walkframe > 27)
	{
		this.th_stand = eidolon_stand1;
		this.th_walk = eidolon_walk1;
		this.th_run = eidolon_run1;
		this.yaw_speed = 20;			// Average Speed
		Resist_ChangeType(this, false);	// Default resistance
		if(this.enemy)
			setthink(this, this.th_run);
		else
			setthink(this, this.th_walk);
	}
	this.frame = anim_eidolon_howl + this.walkframe;
}

//----------------------------------------------------------------------
void eidolon_free1(entity this)
{
	set_animofs(this, anim_eidolon_howl, 1, eidolon_free2);
	this.takedamage = DAMAGE_AIM;		// Enable resistance effects
	this.th_stand = this.th_walk = this.th_run = eidolon_free2;
	Monster mon = this.monsterdef;
	if(mon && mon.m_sound != SND_Null)
		sound(this, CH_VOICE, mon.m_sound, 1, ATTN_NORM);
	this.walkframe = 0;
}

//----------------------------------------------------------------------
// Eidolon game play logic
//----------------------------------------------------------------------
bool EidolonCheckAttack(entity this)
{
	// Check for boss wave trigger events
	if(eidolon_WaveCheck(this))
		return false;

	if(this.enemy_range == RANGE_FAR)
		return false;
	if(time < this.attack_finished)
		return false;

	//----------------------------------------------------------------------
	// Check the tether system
	//----------------------------------------------------------------------
	//this.t_width = vlen(this.enemy.origin - this.movelast.origin);
	// Is the boss at maximum range?
	if(vdist(this.origin - this.movelast.origin, >, 448))
	{
		// Can the boss see the player?
		if(this.enemy_visible)
		{
			this.attack_state = AS_MELEE;
			return true;
		}
		else
		{
			// At max range + cannot see player, exit combat
			this.oldenemy = this.enemy;
			this.enemy = NULL;
			this.goalentity = this.movetarget = this.movelast;
			this.attack_state = AS_STRAIGHT;
			setthink(this, this.th_walk);
			return false;
		}
	}

	entity targ = this.enemy;

	// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, MOVE_NORMAL, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
		return false;	// don't have a clear shot
		
	//----------------------------------------------------------------------
	// Check Melee range and constantly fire
	//----------------------------------------------------------------------
	if(vdist(this.enemy.origin - this.origin, <, 192))
	{
		this.attack_state = AS_MELEE;
		return true;
	}

	if(time < this.attack_finished)
		return false;
			
	if(this.enemy_range == RANGE_FAR)
		return false;

	//----------------------------------------------------------------------
	// Range attacks (Boulder + Rock Storm)
	//----------------------------------------------------------------------
	// Only range attack if cooldown has finished
	// Intense rock storm attack
	if(vdist(this.enemy.origin - this.origin, <, 384) && random() < 0.75)
	{
		// Skill 0=3s, 1=2.25s, 2=1.5s, 3=0.75s
		float aspeed = (4 - autocvar_skill) * 0.75;
		this.attack_finished = time + aspeed + random();
		this.attack_state = AS_MELEE;
		return true;
	}
	// Large boulder attack
	else
	{
		// Skill 0=4s, 1=3s, 2=2s, 3=1s
		float aspeed = (4 - autocvar_skill) * 1;
		this.attack_finished = time + aspeed + random();
		this.attack_state = AS_MISSILE;
		return true;
	}
}

//======================================================================
// Setup Eidolon after trigger event
//======================================================================
void eidolon_wakeup(entity this, entity actor, entity trigger)
{
	this.use = func_null;			// No more triggers
	this.style = EIDOLON_PHASE2;	// Free to fight
	
	// Restore all think functions
	//this.th_stand = eidolon_stand1;
	//this.th_walk = eidolon_walk1;
	//this.th_run = eidolon_run1;
	this.th_melee = eidolon_attackC1;
	this.th_missile = eidolon_attackA1;
	this.th_pain = eidolon_pain;
	this.th_die = eidolon_die;

	this.pain_finished = time + 3;		// Make pain go away
	this.attack_finished = time + 2;	// Reset attack system

	// Time for Eidolon to break free!
	// temporarily override all the think functions as thinking directly can be overridden
	this.th_stand = this.th_walk = this.th_run = eidolon_free1;
	setthink(this, eidolon_free1);
	this.nextthink = time + 0.1;
}

void eidolon_tether_follow(entity this)
{
	if(!this.owner || this.owner.health < 1)
		return;
	setthink(this, eidolon_tether_follow);
	this.nextthink = time + 0.1;
	if(this.owner.charmed && this.owner.charmer)
		setorigin(this, this.owner.charmer.origin);
	else
		setorigin(this, this.owner.origin);
}

void eidolon_start(entity this)
{
	this.style = EIDOLON_PHASE1;
	this.yaw_speed = 6;
	this.takedamage = DAMAGE_NO;

	this.resist_shells = this.resist_cells = 0;
	this.resist_nails = this.resist_rockets = 0.75;
	// TODO: reflect nails and axe

	Resist_Save(this);
	Resist_ChangeType(this, true); // resist everything

	// Setup boss waves and overall health
	this.bosswave = 1;
	this.bosswavetotal = 5;
	this.bosswaveqty = ((horde_ent || this.charmed) ? 250 : 500);
	this.max_health = this.bosswavetotal * this.bosswaveqty;
	// Setup boss wave HP + trigger event
	eidolon_WaveSetupHP(this);

	this.checkattack = EidolonCheckAttack;
	// by default, no thinking happens
	this.th_stand = this.th_walk = this.th_run = func_null;
	this.th_missile = func_null;
	this.th_die = func_null;
	this.th_pain = func_null;

	// Tether point, save for later
	this.movelast = spawn();
	this.movelast.owner = this;
	this.movelast.classname = "tether";
	set_movetype(this.movelast, MOVETYPE_NONE);
	this.movelast.solid = SOLID_NOT;
	setorigin(this.movelast, this.origin);

	// if there's no original spawn location to worry about, just tether to current location, free roaming!
	if(!this.targetname || this.targetname == "")
	{
		setthink(this.movelast, eidolon_tether_follow);
		this.movelast.nextthink = time + 0.1;
	}

	// Make sure all death triggers are setup ready
	this.message2 = this.target;
	this.target = this.target2 = this.deathtarget = "";

	// Can only stand around and walk on the spot
	this.th_stand = eidolon_stand1;
	this.th_walk = this.th_run = eidolon_walk1;

	// wait for trigger event to be free from cage, or free immediately if none set
	if(this.targetname && this.targetname != "")
	{
		setthink(this, this.th_stand);
		this.nextthink = time + 0.1;
		this.use = eidolon_wakeup;
	}
	else
		eidolon_wakeup(this, NULL, NULL);
}

//======================================================================
/*QUAKED monster_eidolon (1 0 0) (-32 -32 -24) (32 32 128)
======================================================================*/
spawnfunc(monster_eidolon) { monster_start(this, true, MON_EIDOLON); }
#endif // SVQC

#ifdef SVQC
METHOD(Eidolon, mr_setup, bool(Eidolon this, entity actor))
{
    TC(Eidolon, this);

	precache_model("progs/proj_eidolonrock1.mdl");
	precache_model("progs/proj_golemrock1.mdl");
	precache_model("progs/proj_golemrock2.mdl");
	precache_model("progs/piano_musicnote_brown.mdl");

	precache_sound("eidolon/idle1.wav");
	precache_sound("eidolon/idle2.wav");
	precache_sound("eidolon/pain.wav");

	// Final death sequence
	precache_sound("eidolon/death.wav");
	precache_sound("eidolon/explode_death.wav");
	precache_sound("eidolon/implode_death.wav");
	precache_sound("eidolon/elec_arch1.wav");
	precache_sound("eidolon/elec_arch2.wav");
	
	// Attack A - Throw Boulder - range attack
	precache_sound("eidolon/attacka.wav");
	precache_sound("eidolon/rock_hit1.wav");
	precache_sound("eidolon/rock_hit2.wav");

	// Attack C - Rockstorm - range attack
	precache_sound("eidolon/attackc.wav");
	precache_sound("break/rock_i1.wav");
	precache_sound("break/rock_i2.wav");
	precache_sound("break/rock_i3.wav");
	precache_sound("break/rock_i4.wav");

	// Attack E - Lightning at summoning crystal - range attack
	precache_sound ("eidolon/attacke.wav");

	if(random() > 0.5)
		actor.skin = 1; // rocky skin
	//actor.takedamage = DAMAGE_NO;
	//actor.pain_finished = time + 999999;

    actor.health = 50000;

	eidolon_start(actor);

    return true;
}
#endif

#ifdef SVQC
//======================================================================
/*QUAKED monster_eidolon_wavetrig (0.75 0.25 1) (-32 -32 -4) (32 32 4) x
Target for boss lightning wave event
-------- KEYS --------
targetname : name of wave event (links to noise key on boss)
target     : trigger name of adds to spawn
target2    : trigger name of crystal event
noise      : targetname of collision entity
-------- SPAWNFLAGS --------
-------- NOTES --------
Target for boss lightning wave event

======================================================================*/
spawnfunc(monster_eidolon_wavetrig)
{
	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_NONE);
	this.takedamage = DAMAGE_NO;
	setsize(this, '0 0 0', '0 0 0');
}
#endif
