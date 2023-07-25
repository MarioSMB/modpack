#include "justice.qh"

#ifdef SVQC
const int anim_justice_smash = 1;
const int anim_justice_walk = 11;
const int anim_justice_taunt = 24;
const int anim_justice_summon = 33;
const int anim_justice_flame = 43;
const int anim_justice_run = 56;
const int anim_justice_painA = 63;
const int anim_justice_fist = 67;
const int anim_justice_stand = 79;
const int anim_justice_jump = 96;
const int anim_justice_deathB = 103;
const int anim_justice_deathA = 112;
const int anim_justice_drawA = 122;
const int anim_justice_drawB = 127;
const int anim_justice_swing = 132;
const int anim_justice_walkB = 145;
const int anim_justice_drawC = 158;
const int anim_justice_idleC = 163;
const int anim_justice_drawD = 176;
const int anim_justice_drawD5 = 180;
const int anim_justice_idleD = 181;
const int anim_justice_drawE = 195;
const int anim_justice_magicB = 200;
const int anim_justice_flameT = 214;
const int anim_justice_magicA = 226;
const int anim_justice_charge = 234;

/*==============================================================================
 The Judicator Knight (model/animation by Benoit Stordeur)

  Interesting QC traits
  * Has a floor damage attack to encourage players to jump
  * Uses the new flame (sprite) projectile system
  * Has logic to break attacks and switch based on enemy distance
 
==============================================================================*/

// Model state
const float JUSTICE_STAND = 1;
const float JUSTICE_TAUNT = 3;	// IdleB
const float JUSTICE_IDLEC = 5;	// IdleC
const float JUSTICE_IDLED = 7;	// IdleD
const float JUSTICE_WALK = 10;
const float JUSTICE_RUN = 15;
const float JUSTICE_MELEE = 20;
const float JUSTICE_JUMP = 25;
const float JUSTICE_MAGICA = 30;
const float JUSTICE_MAGICB = 32;
const float JUSTICE_FLAME = 34;
const float JUSTICE_LINE = 36;
const float JUSTICE_SUMMON = 38;
const float JUSTICE_PAIN = 40;
const float JUSTICE_DEAD = 42;

// Sword location (Back/Shoulder/Hand)
const float JUSTICE_SWBACK = 1;
const float JUSTICE_SWSHOULDER = 2;
const float JUSTICE_SWHAND = 3;
const float JUSTICE_SWFLOOR = 4;

// Sword changing sound fx
const float JUSTICE_SFXDEF = 0;
const float JUSTICE_SFXDRAW = 1;
const float JUSTICE_SFXSHEATH = 2;
const float JUSTICE_SFXSWOOSH = 3;
const float JUSTICE_SFXSILENT = 4;

const float JUSTICE_PHASE0 = -1;	// No boss wave/setup
const float JUSTICE_PHASE1 = 1;		// Intro
const float JUSTICE_PHASE2 = 2;		// Fighting
const float JUSTICE_PHASE3 = 3;		// Summon mode
const float JUSTICE_PHASE4 = 4;		// Death

// Different model animation speeds
const float JUSTICESPD_WALK = 5.8;
const float JUSTICESPD_SWING = 24.5;
const float JUSTICESPD_SMASH = 22.9;

.bool attack_switch;
.float attack_chance;
.bool attack_sidestep;
.int attack_count;
.float attack_timer;
.bool attack_active;
.int attack_summon;

.int proj_attarc;

.int weaponstate;

.bool move_altwalk;

.int blendsfx;
.int blenddir;
.int blendstart;

.entity jumptouch;

// Forward compiler refeence
void justice_checksword(entity this, float finalstate, float soundtype);
void justice_jump6(entity this);
void justice_jump(entity this);
void justice_run(entity this);

//============================================================================
void justice_sword_sound(entity this)
{
	float r = random();
	if(r < 0.25)
		_sound(this, CH_WEAPON_SINGLE, "weapons/sword1a.wav", 1, ATTN_NORM);
	else if(r < 0.5)
		_sound(this, CH_WEAPON_SINGLE, "weapons/sword2a.wav", 1, ATTN_NORM);
	else if(r < 0.75)
		_sound(this, CH_WEAPON_SINGLE, "weapons/sword1b.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "weapons/sword2b.wav", 1, ATTN_NORM);
}

//============================================================================
// Attachment management (create, finish and delete)
//============================================================================
void justice_create_attachment(entity this)
{
	if(!this.attachment)
	{
		this.attachment = spawn();
		this.attachment.owner = this;
		this.attachment.classname = "attachment";
	}
}

//----------------------------------------------------------------------
void justice_finish_attachment(entity this)
{
	if(this.attachment)
		_setmodel(this.attachment, "");
}

//----------------------------------------------------------------------
void justice_remove_attachment(entity this)
{
	if(this.attachment)
	{
		setthink(this.attachment, SUB_Remove);
		this.attachment.nextthink = time + 0.1;
	}
	this.attachment = NULL;
}

//----------------------------------------------------------------------
void justice_update_attachment(entity this, float att_frame)
{
	makevectors(this.angles);
	this.attachment.origin = this.origin + attack_vector('24 0 32');
	setorigin(this.attachment, this.attachment.origin);
	// Different frame count set to main model
	this.attachment.frame = att_frame;
}

//----------------------------------------------------------------------
void justice_setup_attachment(entity this)
{
	// Check if attachment has been setup yet
	if(!this.attachment)
		justice_create_attachment(this);
	_setmodel(this.attachment, "progs/s_judgemagic.spr");
	this.attachment.skin = 0;
	// Display/sync with main model
	justice_update_attachment(this, 0);
}

//======================================================================
// Standing around
//----------------------------------------------------------------------
void justice_standframe(entity this)
{
	// Justice Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUSTICE_DEAD)
		return;
	
	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, justice_standframe);
	// Hide any glowing/sprite attachments
	justice_finish_attachment(this);
	
	// Beginning of animation block
	if(this.walkframe == 0)
	{
		if(random() < 0.2)
			_sound(this, CH_VOICE, "justice/idle1.wav", 1, ATTN_IDLE);
	}
	
	// Update frame and move forward
	this.frame = anim_justice_stand + this.walkframe;
	this.walkframe += 1;
	
	// Finished animation set? (0-15 = 16 frames)
	if(this.walkframe > 15)
	{
		this.walkframe = 0;
		// Is there a walk timer active? Enough time for an idea?
		float r;
		if(this.goalentity && this.pausetime != -1 && time > (this.pausetime+0.5))
			r = 0;
		else
			r = random();
		// Any chance for an idle
		if(r < 0.2)
		{
			// Let blend animation happen before any walking
			if(this.pausetime > 0) 
				this.pausetime += 0.5;
			// Make sure the idle animations don't repeat
			r = this.lefty;
			while(this.lefty == r)
			{ 
				this.lefty = rint(random()*3);
			}
			if(this.lefty <= 1)
			{
				// IdleB = Point sword forward
				this.state = JUSTICE_TAUNT;
				justice_checksword(this, JUSTICE_SWSHOULDER, JUSTICE_SFXSWOOSH);
			}
			else if(this.lefty <= 2)
			{
				// IdleC = Inspect the sword (for+back)
				this.state = JUSTICE_IDLEC;
				justice_checksword(this, JUSTICE_SWSHOULDER, JUSTICE_SFXSWOOSH);
			}
			else {
				// Don't go into this idle animation if patrolling
				// This can last too long and be awkward to reset
				if(!this.attack_switch)
				{
					// IdleD = Place sword on floor
					this.state = JUSTICE_IDLED;
					this.cnt = 0;
					justice_checksword(this, JUSTICE_SWFLOOR, JUSTICE_SFXSWOOSH);
				}
			}
		}
	}
	// Check for combat
	else
		ai_stand(this);	
}

//----------------------------------------------------------------------
void justice_tauntframe(entity this)
{
	// Justice Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUSTICE_DEAD)
		return;
	
	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, justice_tauntframe);
	// Keep justice at path_corner idling
	if(this.pausetime > 0)
		this.pausetime += 0.1;

	// Sword swoosh/whoosh noises
	if(this.walkframe == 3 || this.walkframe == 12)
		justice_sword_sound(this);
	
	// Update frame and move forward
	// 00 01 02 03 04 05 06 07 -- (forward)
	//                      08    (pause)
	// 16 15 14 13 12 11 10 09    (backward)
	if(this.walkframe <= 7)
		this.frame = anim_justice_taunt + this.walkframe;
	else if(this.walkframe == 8)
		this.frame = anim_justice_taunt + 8 - 1;
	else
		this.frame = anim_justice_taunt + (16-this.walkframe);
	
	this.walkframe += 1;
	// Finished animation set?
	if(this.walkframe > 16 )
		this.th_stand(this);
	else
		ai_stand(this);	
}

//----------------------------------------------------------------------
void justice_idleCframe(entity this)
{
	// Justice Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUSTICE_DEAD)
		return;
	
	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, justice_idleCframe);
	// Keep justice at path_corner idling
	if(this.pausetime > 0)
		this.pausetime += 0.1;

	// Sword swoosh/whoosh noises
	if(this.walkframe == 1 || this.walkframe == 22)
		justice_sword_sound(this);
	
	// Update frame and move forward
	// 00 01 02 03 04 05 06 07 08 09 10 11 12 (forward)
	// 24 23 22 21 20 19 18 17 16 15 14 13    (backward)
	if(this.walkframe <= 12)
		this.frame = anim_justice_idleC + this.walkframe;
	else
		this.frame = anim_justice_idleC + (24-this.walkframe);
	
	this.walkframe += 1;
	// Finished animation set?
	if(this.walkframe > 24 )
		this.th_stand(this);
	else
		ai_stand(this);	
}

//----------------------------------------------------------------------
void justice_idleDframe(entity this)
{
	// Justice Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUSTICE_DEAD)
		return;
	
	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, justice_idleDframe);
	// Keep justice at path_corner idling
	if(this.pausetime > 0)
		this.pausetime += 0.1;

	// Update frame and move forward
	this.frame = anim_justice_idleD + this.walkframe;
	this.walkframe += 1;
	// Finished animation set?
	if(this.walkframe > 13 )
	{
		// Chance to keep this animation active?
		if(random() < this.attack_chance)
		{
			// Animation does not end with shoulder position
			this.state = JUSTICE_STAND;
			justice_checksword(this, JUSTICE_SWSHOULDER, JUSTICE_SFXSWOOSH);
		}
		// Keep looping
		else
			this.walkframe = 0;
		// Keep adding loop chance
		this.attack_chance += 0.2;
	}
	else
		ai_stand(this);	
}

//----------------------------------------------------------------------
void justice_walkframe(entity this)
{
	// Justice Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUSTICE_DEAD)
		return;
	
	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, justice_walkframe);
	// Avoid idleD (its too long for walk patrols)
	this.attack_switch = true;
	// Hide any glowing/sprite attachments
	justice_finish_attachment(this);

	// Beginning of animation block
	if(this.walkframe == 3)
	{
		if(random() < 0.2)
			_sound(this, CH_VOICE, "justice/idle1.wav", 1, ATTN_IDLE);
	}

	// Update frame and move forward
	if(this.move_altwalk > 0)
		this.frame = anim_justice_walkB + this.walkframe;
	else
		this.frame = anim_justice_walk + this.walkframe;

	this.walkframe += 1;
	// Finished animation set?
	if(this.walkframe > 11)
		this.walkframe = 0;
	// Jude/Justice different scales = different walks
	ai_walk(this, JUSTICESPD_WALK);
}

void justice_runframe(entity this)
{
	// Justice Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUSTICE_DEAD)
		return;

	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, justice_runframe);
	// Hide any glowing/sprite attachments
	justice_finish_attachment(this);

	// Beginning of animation block
	if(this.walkframe == 2)
	{
		if(random() < 0.2)
			_sound(this, CH_VOICE, "justice/idle1.wav", 1, ATTN_IDLE);
	}

	// Update frame and move forward
	this.frame = anim_justice_run + this.walkframe;
	this.walkframe += 1;
	// Finished animation set?
	if(this.walkframe > 5)
		this.walkframe = 0;

	// Check for less than half health for drole rampage speed
	if(this.health < (this.max_health*0.5))
		ai_run(this, 28);
	else
		ai_run(this, 24);
}

//----------------------------------------------------------------------
void justice_chargeframe(entity this)
{
	// Justice Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUSTICE_DEAD)
		return;
	
	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, justice_chargeframe);
	// Hide any glowing/sprite attachments
	justice_finish_attachment(this);

	// Beginning of animation block
	// Sword swoosh/whoosh noises
	if(this.walkframe == 2 || this.walkframe == 8)
		justice_sword_sound(this);
	// Check for charging damage
	if(this.walkframe == 1 || this.walkframe == 2)
		ai_melee(this, DEATH_MONSTER_JUSTICE.m_id, 100);
	else if(this.walkframe >= 5 && this.frame <= 9)
		ai_melee(this, DEATH_MONSTER_JUSTICE.m_id, 100);

	// Update frame and move forward
	this.frame = anim_justice_charge + this.walkframe;
	this.walkframe += 1;
	// Finished animation set?
	if(this.walkframe > 11)
		this.th_run(this);
	// Turn towards enemy and push forward (walkmove)
	else
	{
		// Check for less than half health for drole rampage speed
		if(this.health < (this.max_health*0.5))
		{
			ai_face(this);
			ai_forward(this, 28);
		}
		else
		{
			ai_face(this);
			ai_forward(this, 20);
		}
	}
}

void justice_ai_melee(entity this)
{
	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;
			
	float ldmg = (random() + random() + random()) * 30;
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_JUSTICE.m_id);
	_sound(this, CH_VOICE, "justice/smash_hitheavy.wav", 1, ATTN_NORM);

	SpawnMeatSpray(this, this.origin + v_forward*16, crandom() * 100 * v_right);
	SpawnMeatSpray(this, this.origin + v_forward*16, crandom() * 100 * v_right);
}

//----------------------------------------------------------------------
void justice_smashframe(entity this)
{
	// Justice Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUSTICE_DEAD)
		return;

	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, justice_smashframe);
	// Hide any glowing/sprite attachments
	justice_finish_attachment(this);

	// Face enemy
	ai_face(this);
	
	// Put left foot forward first!
	if(this.walkframe >= 1 && this.walkframe <= 5)
	{
		ai_forward(this, JUSTICESPD_SMASH/5);
	}

	// Sword swoosh/whoosh noises
	if(this.walkframe == 3)
		justice_sword_sound(this);
	// sword meets flesh! or ground ...
	else if(this.walkframe == 5)
		justice_ai_melee(this);
	
	// Update frame and move forward
	this.frame = anim_justice_smash + this.walkframe;
	this.walkframe = this.walkframe + 1;
	// Finished animation set? (1-10)
	if(this.walkframe > 9)
		this.th_run(this);
}

//======================================================================
// (JUSTICE only) MAGIC PATTERN A - Giant arrow heads in diamond
//======================================================================
void justice_firemagicA(entity this, float offset)
{
	if(!this.enemy)
		return;
	if(this.health < 1)
		return;
	
	this.effects |= EF_MUZZLEFLASH;
	_sound(this, CH_WEAPON_SINGLE, "justice/magic_fire.wav", 1, ATTN_NORM);	

	// check for enemy origin (based on sight test)
	// if cannot see enemy fire at last known location
	ai_face(this);
	makevectors (this.angles);
	vector org = this.origin + attack_vector('24 0 32');
	
	// Create perfect shot (no longer use offset)
	vector dir = normalize(this.enemy.origin - org);
	//Launch_Missile (org, dir, '0 0 0', CT_PROJ_JUSTICER, this.attack_speed);

	entity newmis = launch_spike(this, org, dir);
	_setmodel(newmis, "progs/proj_judger.mdl");
	newmis.dmg = 20;
	setsize(newmis, '0 0 0', '0 0 0');
	newmis.velocity = dir * 400;
	settouch(newmis, T_MissileTouch); // rocket explosion
	newmis.projectiledeathtype = DEATH_MONSTER_JUSTICE.m_id;
}

//----------------------------------------------------------------------
void justice_magicAframe(entity this)
{
	// Justice Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUSTICE_DEAD)
		return;

	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, justice_magicAframe);
	
	ai_face(this);
	// Do specific stuff on certain animation frames
	if(this.walkframe == 0)
	{
		// Warn the player of firing magic spikes
		_sound(this, CH_WEAPON_SINGLE, "justice/magic_attack.wav", 1, ATTN_NORM);
		this.frame = anim_justice_magicA;
		// Glow ball of magic infront of sword
		justice_setup_attachment(this);
		ai_face(this);
	}
	else if(this.walkframe >= 1 && this.walkframe <= 3)
	{
		this.frame = anim_justice_magicA + 2 - 1;
		justice_update_attachment(this, this.walkframe);
		particle(this.attachment.origin, '0 0 1' * (20 + random() * 20), 100, 100);
		//particle_implode(this.attachment.origin, 20+random()*20, 100, 100, PARTICLE_BURST_YELLOW);
		ai_face(this);
	}
	else if(this.walkframe >= 4 && this.walkframe <= 7) { 
		this.frame = (anim_justice_magicA + 3 - 1) + (this.walkframe-4);
		justice_update_attachment(this, this.walkframe);
		justice_firemagicA(this, this.walkframe - 4);
	}
	else if(this.walkframe == 8)
	{
		this.frame = anim_justice_magicA + 7 - 1;
		SpawnExplosion(EXPLODE_BURST_SMOKE, this.attachment.origin, "weapons/resist_rocket.wav");
		justice_finish_attachment(this);
	}
	else
		this.th_run(this);

	// Update frame and move forward
	this.walkframe += 1;
}

//======================================================================
// (JUSTICE only) FLAMES PATTERN 1 - wall arc infront (at players feet)
//======================================================================
void justice_animate_fireball(entity this)
{
	if(time > this.cnt)
	{
		delete(this);
		return;
	}

	if(this.noise && this.noise != "" && time > this.volume)
	{
		this.volume = time + 1;
		_sound(this, CH_VOICE, this.noise, 0.3, ATTN_IDLE);
	}

	if(random() < 0.05)
		SpawnProjectileSmoke(this.origin, 200, 50, 250);

	this.walkframe += 1;
	if(this.walkframe >= 14)
		this.walkframe = 0;
	this.frame = this.walkframe;

	setthink(this, justice_animate_fireball);
	this.nextthink = time + 0.1;
}

entity Launch_Fireball(entity this, vector org, vector dir, float pspeed);
void justice_fireflamewall(entity this, bool fire_explode)
{
	// Justice cannot find target!
	if(!this.enemy) return;

	// Facing angle
	ai_face(this);
	fixedmakevectors(this.angles);	
	vector org = this.origin + attack_vector('32 0 -16');
	
	// Setup explosion origin (infront)
	vector eorg = org + attack_vector('16 0 16');
	
	// BIG EXPLOSION - infront and above impact point
	if(fire_explode)
	{
		// Setup wall parameters
		this.proj_attarc = 1 + autocvar_skill;
		// Within range? Easy = 3(-1/1), Normal = 5(-2/2), Hard/NM = 7(-3/3)
		if(this.proj_attarc > 3)
			this.proj_attarc = 3;
		// Invert maximum arc to create beginning/current
		this.proj_attarc = -this.proj_attarc;

		int expl_type;
		if(random() < 0.5)
			expl_type = EXPLODE_MED;
		else
			expl_type = EXPLODE_BIG;

		SpawnExplosion(expl_type, eorg, "justice/flame_explode.wav");
	}
	// SMALL EFFECTS
	else
	{
		// Quiet sfx + dust/smoke
		_sound(this, CH_WEAPON_SINGLE, "justice/flame_fire.wav", 1, ATTN_NORM);	
		if(random() > 0.5)
			SpawnProjectileSmoke(eorg, 200, 50, 250);
	}

	// Start with facing angle
	fixedmakevectors(this.angles);	
	// Work out offset (24 unit) from left to right (- to +)
	vector torg = this.enemy.origin + (v_right * (this.proj_attarc * 24));
	float targetang = SUB_Elevation(this, 30, this.origin, torg, 600);
	// Work out angle
	vector ang = vectoangles(torg - org);
	ang.x = -targetang;	// Negative = upwards angle 
	makevectors(ang);
	// fire flames forward with slight Z wobble
	vector dir = (v_forward + (v_up * (random()*0.2)) ) * 600;

	// Fire that flame!
	float fire_life = (5 / 2) + random() + random();
	// target, origin, v_forward, colour, size, lifetime, speed
	//Launch_Flame(this, org, dir, FLAME_RED, -1, fire_life, 600);

	entity newmis = Launch_Fireball(this, org, dir, 600);
	newmis.projectiledeathtype = DEATH_MONSTER_JUSTICE.m_id;
	newmis.frame = floor(random() * 14);
	newmis.walkframe = newmis.frame;
	setthink(newmis, justice_animate_fireball);
	newmis.nextthink = time + 0.1;
	newmis.cnt = fire_life;

	float r = random();
	if(r < 0.2)
	{
		_setmodel(newmis, "progs/s_flamemed.spr");
		setsize(newmis, '-8 -8 0', '8 8 32');
	}
	else if(r < 0.5)
	{
		_setmodel(newmis, "progs/s_flamesml.spr");
		setsize(newmis, '-6 -6 0', '6 6 24');
	}
	else
	{
		_setmodel(newmis, "progs/s_flametiny.spr");
		setsize(newmis, '-4 -4 0', '4 4 16');
	}

	r = random();
	if(r < 0.25)
		newmis.noise = "ambience/flames1.wav";
	else if(r < 0.5)
		newmis.noise = "ambience/flames2.wav";
	else if(r < 0.75)
		newmis.noise = "ambience/flames3.wav";
	else
		newmis.noise = "ambience/flames4.wav";
	_sound(newmis, CH_VOICE, newmis.noise, 0.3, ATTN_IDLE);
	newmis.volume = time + 1;

	// Next arc position
	this.proj_attarc += 1;
}

//----------------------------------------------------------------------
void justice_flamewall(entity this)
{
	// Justice Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUSTICE_DEAD)
		return;

	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, justice_flamewall);
	
	this.frame = anim_justice_flame + this.walkframe;
	if(this.walkframe >= 0 && this.walkframe <= 6)
		ai_face(this);
	
	// Do specific stuff on certain animation frames
	if(this.walkframe == 0)
	{
		// Reset rage counter
		this.attack_rage = 1;
		_sound(this, CH_WEAPON_SINGLE, "justice/flame_attack.wav", 1, ATTN_NORM);
	}
	// BUILD up of attack ----------------------------------------
	// STRIKE into ground ----------------------------------------
	else if(this.walkframe == 6)
	{ 
		// Sprite Count = Base (X) * (Skill * Y) Maximum = Z
		this.attack_count = 3;
		justice_fireflamewall(this, true);
	}
	// EXIT from attack ------------------------------------------
	else if(this.walkframe >= 12)
	{
		ai_face(this);
		// Slow down flame attacks with attack timer/blocker
		this.attack_timer = time + 1 + random();
		// Back to regular movement
		this.attack_state = AS_STRAIGHT;
		setthink(this, this.th_run);
	}
	// LOOP with sword in ground ---------------------------------
	else if(this.walkframe >= 7 && this.walkframe <= 10)
	{ 
		// Check if the attack is blocked (extra wide for wall/monsters)
		if(visblocked_wide(this, this.enemy, '32 0 -16', '0 0 0'))
		{
			// Attack is blocked, just exit wasting time
			this.walkframe = 11;  
			this.frame = anim_justice_flame + this.walkframe;
		}
		else
		{
			// Keep counting down flame attacks (3/5/7 sets)
			this.attack_count -= 1;
			if(this.attack_count > 0)
			{
				// Keep looping around sword in ground cycle
				if(this.walkframe == 10)
					this.walkframe = 6;
				justice_fireflamewall(this, false);
				this.nextthink = time + 0.05;
			}
			else
			{ 
				// Sword out of ground, about to exit loop
				this.walkframe = 11;  
				this.frame = anim_justice_flame + this.walkframe;
				// Anymore rage left? (Burst mode)
				this.attack_rage += 1;
				if(this.attack_rage <= 3 - autocvar_skill)
				{
					// Sprite Count = Base (X) * (Skill * Y) Maximum = Z
					this.attack_count = 3;
					// Back around animation loop
					this.walkframe = 1;
				}
			}
		}
	}

	// Update frame and move forward
	this.walkframe = this.walkframe + 1;
}

//----------------------------------------------------------------------
void justice_magicBframe(entity this)
{
	// Justice Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUSTICE_DEAD)
		return;
}

//----------------------------------------------------------------------
void justice_flameline(entity this)
{
	// Justice Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUSTICE_DEAD)
		return;
}

//======================================================================
// Lunge forward (leaving ground) and do heavy damage on touch
//----------------------------------------------------------------------
void justice_JumpTouch(entity this, entity toucher)
{
	// Justice Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUSTICE_DEAD)
		return;

	// Hide any glowing/sprite attachments
	justice_finish_attachment(this);

	//ai_jumpbreakable(30);			// Damage any breakables
	settouch(this, func_null);			// No more touching
	this.count += 1;	// Total amount of touch jumps
	setthink(this, justice_jump6);	// Exit frame
	this.nextthink = time + 0.1;
		
	// Keep track of how many times touched the same object
	if(this.jumptouch == toucher)
		this.jump_flag = time + 2;
	this.jumptouch = toucher;			// Keep track of touch target

	// Do not damage other monsters of the same type with jump attacks
	if(toucher.monsterdef != this.monsterdef && toucher.takedamage)
	{
		if(vdist(this.velocity, >, 300))
		{
			float ldmg = 20 + 10*random();
			T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_JUSTICE.m_id);	
			SpawnMeatSpray(this, toucher.origin, toucher.velocity);
			SpawnMeatSpray(this, toucher.origin, toucher.velocity);
			SpawnMeatSpray(this, toucher.origin, toucher.velocity);
		}
	}

	// Is the Justice floating in the air?
	if(!t_checkbottom(this))
	{
		// Is the Justice standing on something?		
		if(IS_ONGROUND(this))
		{	
			// Do an extra jump if got the count
			if(this.count < 2)
				setthink(this, justice_jump);
		}
	}
	// Go straight into landing animation
	else
		justice_jump6(this);
}

//----------------------------------------------------------------------
// Landed with a thud
void justice_jump7(entity this)
{
	set_animofs(this, anim_justice_jump, 7, justice_run);
	// Make sure attack state is reset (can then decide melee or range)
	this.attack_state = AS_STRAIGHT;
	this.angles_x = this.angles_z = 0;
	ai_face(this);
}
void justice_jump6(entity this) { set_animofs(this, anim_justice_jump, 6, justice_jump7); }
void justice_jump5(entity this)
{
	set_animofs(this, anim_justice_jump, 5, justice_jump5);
	// Double check monster is still falling?
	if(this.velocity == '0 0 0' || this.oldorigin == this.origin)
	{
		this.ideal_yaw = random() * 360; 	//random jump angle
		setthink(this, justice_jump6);
	}
	this.oldorigin = this.origin;
}
void justice_jump4(entity this) { set_animofs(this, anim_justice_jump, 4, justice_jump5); }
void justice_jump3(entity this) { set_animofs(this, anim_justice_jump, 3, justice_jump4); }
void justice_jump2(entity this)
{
	set_animofs(this, anim_justice_jump, 2, justice_jump3);
	ai_face(this);
	settouch(this, justice_JumpTouch);

	this.jump_flag = time + 2;
	_sound(this, CH_WEAPON_SINGLE, "justice/leap1.wav", 1, ATTN_NORM);
	fixedmakevectors(this.angles);
	this.velocity = (v_forward * 450) + ('0 0 1' * 225);
	UNSET_ONGROUND(this);
	this.oldorigin = this.origin;
}
void justice_jump1(entity this) { set_animofs(this, anim_justice_jump, 1, justice_jump2); ai_face(this); }

//----------------------------------------------------------------------
void justice_jump(entity this)
{
	// Entered combat once
	this.attack_active = true;
	// Hide any glowing/sprite attachments
	justice_finish_attachment(this);

	this.state = JUSTICE_JUMP;
	// No pain + make sword in correct position
	this.pain_finished = time + 1;
	justice_checksword(this, JUSTICE_SWHAND, JUSTICE_SFXDEF);
}

//======================================================================
// Entry point for Stand, Walk and Run monster states
// All have to cope with sword out/on back blend animations
//----------------------------------------------------------------------
void justice_stand(entity this)
{ 
	// Hide any glowing/sprite attachments
	justice_finish_attachment(this);

	// Let blend animation happen before any walking
	if(this.pausetime > 0 && this.weaponstate != JUSTICE_SWSHOULDER) 
		this.pausetime += 0.5;
	// Standing around, check sword status first
	this.state = JUSTICE_STAND;
	justice_checksword(this, JUSTICE_SWSHOULDER, JUSTICE_SFXDEF);
}

//----------------------------------------------------------------------
void justice_walk(entity this)
{
	// Start walking
	this.state = JUSTICE_WALK;
	// Hide any glowing/sprite attachments
	justice_finish_attachment(this);

	// Which walk animation to use?
	if(this.move_altwalk > 0)
		justice_checksword(this, JUSTICE_SWHAND, JUSTICE_SFXDEF);
	else
		justice_checksword(this, JUSTICE_SWBACK, JUSTICE_SFXDEF);
}

//----------------------------------------------------------------------
void justice_run(entity this)
{
	// Don't start combat with a jump!
	if(!this.attack_active)
		this.jump_flag = time + 2;
	// Entered combat once
	this.attack_active = true;
	// Hide any glowing/sprite attachments
	justice_finish_attachment(this);

	this.state = JUSTICE_RUN; 
	justice_checksword(this, JUSTICE_SWHAND, JUSTICE_SFXDEF);
}

//----------------------------------------------------------------------
void justice_melee(entity this)
{
	// Entered combat once
	this.attack_active = true;
	// Reset jump attack decision branch
	this.attack_sidestep = false;
	// Hide any glowing/sprite attachments
	justice_finish_attachment(this);

	this.state = JUSTICE_MELEE; 
	// No pain + make sword in correct position
	this.pain_finished = time + 1;
	justice_checksword(this, JUSTICE_SWHAND, JUSTICE_SFXDEF);
}

//----------------------------------------------------------------------
void justice_range(entity this)
{
	// Entered combat once
	this.attack_active = true;
	// Hide any glowing/sprite attachments
	justice_finish_attachment(this);

	//------------------------------------------------------------------
	// Flame BURST and MagicA = JUSTICE only
	//------------------------------------------------------------------
	// Magic range will always reach a monster
	if(IS_MONSTER(this.enemy))
		this.state = JUSTICE_MAGICA;
	else
	{
		// Easy/Normal = get more spikes Hard/NM = get more flames
		// Easy=0.6, Normal=0.5, Hard=0.4, NM=0.3
		float achance = 0.6 - (autocvar_skill * 0.1);
		if(random() > achance)
			this.state = JUSTICE_FLAME;
		else
			this.state = JUSTICE_MAGICA;
		// Flame attack does not go up stairs or ledges very well
		if(this.enemy.origin_z > (this.origin_z + 32)) 
			this.state = JUSTICE_MAGICA;

		// Forced pause between FLAME attacks
		if(this.attack_timer < time)
		{
			// Sprite Count = Base (X) * (Skill * Y) Maximum = Z
			this.attack_count = 3;
			// Any sprite space left for hazard projectiles? (min = 1 wave)
			this.state = JUSTICE_MAGICA;
		}
		// Do magic attack instead
		else
			this.state = JUSTICE_MAGICA;
	}
	
	// No pain + make sure sword in correct position
	this.pain_finished = time + 1;
	justice_checksword(this, JUSTICE_SWHAND, JUSTICE_SFXDEF);
}

//======================================================================
// Sword position blending, checked by all functions
// Blend animations ( Back / Shoulder / Hand )
//----------------------------------------------------------------------
void justice_finishsword(entity this)
{
	this.walkframe = this.attack_chance = 0;
	// Where to go next?
	if(this.state == JUSTICE_STAND) justice_standframe(this);
	else if(this.state == JUSTICE_TAUNT) justice_tauntframe(this);
	else if(this.state == JUSTICE_IDLEC) justice_idleCframe(this);
	else if(this.state == JUSTICE_IDLED) justice_idleDframe(this);
	else if(this.state == JUSTICE_WALK) justice_walkframe(this);
	else if(this.state == JUSTICE_MELEE)
	{
		// Simple flat (2d) range check
		// Overhead smash or charging (swing + run)
		if(vdist(vec2(this.enemy.origin - this.origin), <, 100))
			justice_smashframe(this);
		else
			justice_chargeframe(this);
	}
	else if(this.state == JUSTICE_JUMP) justice_jump1(this);
	else if(this.state == JUSTICE_MAGICA) justice_magicAframe(this);
	else if(this.state == JUSTICE_MAGICB) justice_magicBframe(this);
	else if(this.state == JUSTICE_LINE) justice_flameline(this);
	else if(this.state == JUSTICE_FLAME) justice_flamewall(this);
	// Default = in combat and running
	else
		justice_runframe(this);
}

void justice_movesword(entity this)
{
	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, justice_movesword);
	// Sword sound (defined beforehand)
	if(this.walkframe == 2)
	{
		// Allow for sound override
		if(this.blendsfx == JUSTICE_SFXDRAW)
		{
			_sound(this, CH_WEAPON_SINGLE, "justice/sword_draw.wav", 1, ATTN_NORM);
		}
		else if(this.blendsfx == JUSTICE_SFXSHEATH)
		{
			_sound(this, CH_WEAPON_SINGLE, "justice/sword_sheath.wav", 1, ATTN_NORM);
		}
		else if(this.blendsfx == JUSTICE_SFXSWOOSH)
			justice_sword_sound(this);
	}
	// Step through animation (check direction)
	if(this.blenddir == 1)
		this.frame = this.blendstart + this.walkframe;
	else
		this.frame = this.blendstart + (4 - this.walkframe);
	this.walkframe += 1;
	
	// Check if finished animation
	if(this.walkframe > 4)
		justice_finishsword(this);
}

void justice_checksword(entity this, int finalstate, int soundtype)
{
	// Justice Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUSTICE_DEAD)
		return;

	// Hide any glowing/sprite attachments
	justice_finish_attachment(this);

	this.walkframe = 0;
	// Is sword in right position? - Move on to next animation
	if(finalstate == this.weaponstate)
		justice_finishsword(this);
	else
	{
		// Setup defaults
		this.blendstart = anim_justice_drawA;
		this.blenddir = 1;
		this.blendsfx = soundtype;

		// drawA1 = Move sword from BACK to hand
		// drawB1 = Move sword from HAND to shoulder
		// drawC1 = Move sword from SHOULDER to back
		// drawD1 = Move sword from SHOULDER to floor
		// drawE1 = Move sword from FLOOR to hand
		if(this.weaponstate == JUSTICE_SWBACK)
		{
			if(finalstate == JUSTICE_SWSHOULDER)
			{
				//dprint("BACK --> SHOULDER\n");
				if(soundtype == 0)
					this.blendsfx = JUSTICE_SFXDRAW;
				this.blendstart = anim_justice_drawC;
				this.blenddir = -1;
			}
			else if(finalstate == JUSTICE_SWHAND)
			{
				//dprint("BACK --> HAND\n");
				if(soundtype == 0)
					this.blendsfx = JUSTICE_SFXDRAW;
				this.blendstart = anim_justice_drawA;
				this.blenddir = 1;
			}
			else if(finalstate == JUSTICE_SWFLOOR)
			{
				//dprint("BACK --> FLOOR\n");
				// blend does not exist, use shoulder -> floor
				if(soundtype == 0)
					this.blendsfx = JUSTICE_SFXSHEATH;
				this.blendstart = anim_justice_drawD;
				this.blenddir = 1;
			}
		}
		else if(this.weaponstate == JUSTICE_SWSHOULDER)
		{
			if(finalstate == JUSTICE_SWBACK)
			{
				//dprint("SHOULDER --> BACK\n");
				if(soundtype == 0)
					this.blendsfx = JUSTICE_SFXSHEATH;
				this.blendstart = anim_justice_drawC;
				this.blenddir = 1;
			}
			else if(finalstate == JUSTICE_SWHAND)
			{
				//dprint("SHOULDER --> HAND\n");
				if(soundtype == 0)
					this.blendsfx = JUSTICE_SFXSHEATH;
				this.blendstart = anim_justice_drawB;
				this.blenddir = -1;
			}
			else if(finalstate == JUSTICE_SWFLOOR)
			{
				//dprint("SHOULDER --> FLOOR\n");
				if(soundtype == 0)
					this.blendsfx = JUSTICE_SFXSHEATH;
				this.blendstart = anim_justice_drawD;
				this.blenddir = 1;
			}
		}
		else if(this.weaponstate == JUSTICE_SWHAND)
		{
			if(finalstate == JUSTICE_SWBACK)
			{
				//dprint("HAND --> BACK\n");
				if(soundtype == 0)
					this.blendsfx = JUSTICE_SFXDRAW;
				this.blendstart = anim_justice_drawA;
				this.blenddir = -1;
			}
			else if(finalstate == JUSTICE_SWSHOULDER)
			{
				//dprint("HAND --> SHOULDER\n");
				if(soundtype == 0)
					this.blendsfx = JUSTICE_SFXSHEATH;
				this.blendstart = anim_justice_drawB;
				this.blenddir = 1;
			}
			else if(finalstate == JUSTICE_SWFLOOR)
			{
				//dprint("HAND --> FLOOR\n");
				if(soundtype == 0)
					this.blendsfx = JUSTICE_SFXSHEATH;
				this.blendstart = anim_justice_drawE;
				this.blenddir = -1;
			}
		}
		else if(this.weaponstate == JUSTICE_SWFLOOR)
		{
			if(finalstate == JUSTICE_SWBACK)
			{
				//dprint("FLOOR --> BACK\n");
				// blend does not exist, use floor -> shoulder
				if(soundtype == 0)
					this.blendsfx = JUSTICE_SFXDRAW;
				this.blendstart = anim_justice_drawD;
				this.blenddir = -1;
			}
			else if(finalstate == JUSTICE_SWSHOULDER)
			{
				//dprint("FLOOR --> SHOULDER\n");
				if(soundtype == 0)
					this.blendsfx = JUSTICE_SFXSHEATH;
				this.blendstart = anim_justice_drawD;
				this.blenddir = -1;
			}
			else if(finalstate == JUSTICE_SWHAND)
			{
				//dprint("FLOOR --> HAND\n");
				if(soundtype == 0)
					this.blendsfx = JUSTICE_SFXSHEATH;
				this.blendstart = anim_justice_drawE;
				this.blenddir = -1;
			}
		}
	
		// Setup counter and update state
		this.weaponstate = finalstate;
		// Start blend animation
		justice_movesword(this);
	}
}

void justice_painA4(entity this) { set_animofs(this, anim_justice_painA, 4, justice_run); }
void justice_painA3(entity this) { set_animofs(this, anim_justice_painA, 3, justice_painA4); }
void justice_painA2(entity this) { set_animofs(this, anim_justice_painA, 2, justice_painA3); }
void justice_painA1(entity this) { set_animofs(this, anim_justice_painA, 1, justice_painA2); }

void justice_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	if((random() * 200) > damage)
		return;
	if(this.state == JUSTICE_DEAD)
		return;

	justice_finish_attachment(this);

	this.pain_finished = time + 2;
	justice_painA1(this);
	_sound(this, CH_VOICE, "justice/pain1.wav", 1, ATTN_NORM);
}

void justice_dieA10(entity this) { set_animofs(this, anim_justice_deathA, 10, justice_dieA10); CorpseThink(this); }
void justice_dieA9(entity this) { set_animofs(this, anim_justice_deathA, 9, justice_dieA10); }
void justice_dieA8(entity this) { set_animofs(this, anim_justice_deathA, 8, justice_dieA9); }
void justice_dieA7(entity this) { set_animofs(this, anim_justice_deathA, 7, justice_dieA8); }
void justice_dieA6(entity this)
{
	set_animofs(this, anim_justice_deathA, 6, justice_dieA7);
	_sound(this, CH_WEAPON_SINGLE, "gibs/gibmetala.wav", 1, ATTN_NORM);
}
void justice_dieA5(entity this) { set_animofs(this, anim_justice_deathA, 5, justice_dieA6); }
void justice_dieA4(entity this) { set_animofs(this, anim_justice_deathA, 4, justice_dieA5); }
void justice_dieA3(entity this) { set_animofs(this, anim_justice_deathA, 3, justice_dieA4); }
void justice_dieA2(entity this) { set_animofs(this, anim_justice_deathA, 2, justice_dieA3); }
void justice_dieA1(entity this) { set_animofs(this, anim_justice_deathA, 1, justice_dieA2); this.solid = SOLID_NOT; }

void justice_dieB9(entity this) { set_animofs(this, anim_justice_deathB, 9, justice_dieB9); CorpseThink(this); }
void justice_dieB8(entity this) { set_animofs(this, anim_justice_deathB, 8, justice_dieB9); }
void justice_dieB7(entity this)
{
	set_animofs(this, anim_justice_deathB, 7, justice_dieB8);
	_sound(this, CH_WEAPON_SINGLE, "gibs/gibmetala.wav", 1, ATTN_NORM);
}
void justice_dieB6(entity this) { set_animofs(this, anim_justice_deathB, 6, justice_dieB7); }
void justice_dieB5(entity this) { set_animofs(this, anim_justice_deathB, 5, justice_dieB6); }
void justice_dieB4(entity this) { set_animofs(this, anim_justice_deathB, 4, justice_dieB5); }
void justice_dieB3(entity this) { set_animofs(this, anim_justice_deathB, 3, justice_dieB4); }
void justice_dieB2(entity this) { set_animofs(this, anim_justice_deathB, 2, justice_dieB3); }
void justice_dieB1(entity this) { set_animofs(this, anim_justice_deathB, 1, justice_dieB2); this.solid = SOLID_NOT; }

void justice_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	justice_finish_attachment(this);
	justice_remove_attachment(this);

// check for gib
	if(this.health < -60)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, "progs/h_justice.mdl", this.health);
		ThrowGib(this, "progs/w_justicesword.mdl", this.health);
		ThrowGib(this, "progs/gib_justiceboot.mdl", this.health);
		ThrowGib(this, "progs/gib_justiceshould.mdl", this.health);
		return;
	}

// regular death
	_sound(this, CH_VOICE, "justice/death1.wav", 1, ATTN_NORM);
	if(random() < 0.5)
		justice_dieA1(this);
	else
		justice_dieB1(this);
}

/*======================================================================
 JusticeCheckAttack
======================================================================*/
bool JusticeCheckAttack(entity this)
{
	if(IS_MONSTER(this.enemy))
	{
		if(vdist(this.enemy.origin - this.origin, >, 100))
			this.attack_state = AS_MISSILE;
		else
			this.attack_state = AS_MELEE;
		return true;
	}
		
	if(!this.enemy_visible)
		return false;

	entity targ = this.enemy;
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;
	traceline(spot1, spot2, false, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
		return false;	// don't have a clear shot

	if(this.movespeed < 0)
	{
		if(time < this.attack_finished)
			return false;
		this.attack_finished = time + 1 + 2 * random();
		this.attack_state = AS_MISSILE;
		return true;
	}

	if(ai_checkmelee(this, 200, 0))
	{
		if(vdist(this.enemy.origin - this.origin, >, 100) && random() < 0.5)
		{
			this.attack_state = AS_MISSILE;
			this.attack_finished = time + 2 + random();
			return true;
		}
		this.attack_state = AS_MELEE;
		return true;
	}

	if(this.jump_flag < time && infront(this, this.enemy))
	{
		if(this.enemy.origin_z <= this.origin_z)
		{
			float edist = vlen2(this.enemy.origin - this.origin);
			if(edist > 200 && edist < 350)
			{
				this.attack_finished = time + random();
				this.jumptouch = NULL;
				this.count = 0;
				justice_jump(this);
				return true;
			}
		}
	}

	if(time < this.attack_finished)
		return false;

	if(vdist(this.enemy.origin - this.origin, <, 250))
		return false;

	this.attack_state = AS_MISSILE;
	this.attack_finished = time + 2 + random();
	return true;
}

//======================================================================
/*QUAKED monster_justice (1 0 0) (-16 -16 -24) (16 16 56) Ambush
======================================================================*/
spawnfunc(monster_justice) { monster_start(this, true, MON_JUSTICE); }

// old spawnpoint for some maps
spawnfunc(monster_baron) { monster_start(this, true, MON_JUSTICE); }
#endif // SVQC

#ifdef SVQC
METHOD(Justice, mr_setup, bool(Justice this, entity actor))
{
    TC(Justice, this);

	precache_model("progs/w_justicesword.mdl");
	precache_model("progs/gib_justiceboot.mdl");
	precache_model("progs/gib_justiceshould.mdl");

	precache_sound("gibs/gibmetala.wav");

	precache_sound("justice/idle1.wav");
	precache_sound("justice/pain1.wav");
	precache_sound("justice/death1.wav");

	precache_model("progs/proj_judger.mdl");

	precache_model("progs/s_flamemed.spr");
	precache_model("progs/s_flamesml.spr");
	precache_model("progs/s_flametiny.spr");

	precache_model("progs/s_judgemagic.spr");

	precache_sound("justice/smash_hit.wav");
	precache_sound("justice/smash_hitheavy.wav");

	precache_sound("justice/magic_attack.wav");
	precache_sound("justice/magic_fire.wav");
	precache_sound("justice/magic_hit.wav");

	precache_sound("justice/flame_attack.wav");
	precache_sound("justice/flame_fire.wav");
	precache_sound("justice/flame_explode.wav");

	precache_sound("justice/sword_sheath.wav");
	precache_sound("justice/sword_draw.wav");

	precache_sound("weapons/sword1a.wav");
	precache_sound("weapons/sword1b.wav");
	precache_sound("weapons/sword2a.wav");
	precache_sound("weapons/sword2b.wav");

	precache_sound("justice/leap1.wav");

	precache_sound("ambience/flames1.wav");
	precache_sound("ambience/flames2.wav");
	precache_sound("ambience/flames3.wav");
	precache_sound("ambience/flames4.wav");

    actor.health = 600;
    actor.th_stand = justice_stand;
	actor.th_walk = justice_walk;
	actor.th_run = justice_run;
	actor.th_melee = justice_melee;
	actor.th_missile = justice_range;
	actor.th_pain = justice_pain;
	actor.th_die = justice_die;

	actor.checkattack = JusticeCheckAttack;

	actor.weaponstate = JUSTICE_SWSHOULDER;
	actor.state = JUSTICE_STAND;

    return true;
}
#endif
