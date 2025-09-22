#include "judicator.qh"

#include "gaunt.qh"

#ifdef SVQC
const int anim_judge_smash = 1;
const int anim_judge_walk = 11;
const int anim_judge_taunt = 24;
const int anim_judge_summon = 33;
const int anim_judge_flame = 43;
const int anim_judge_run = 56;
const int anim_judge_painA = 63;
const int anim_judge_fist = 67;
const int anim_judge_stand = 79;
const int anim_judge_jump = 96;
const int anim_judge_deathB = 103;
const int anim_judge_deathA = 112;
const int anim_judge_drawA = 122;
const int anim_judge_drawB = 127;
const int anim_judge_swing = 132;
const int anim_judge_walkB = 145;
const int anim_judge_drawC = 158;
const int anim_judge_idleC = 163;
const int anim_judge_drawD = 176;
const int anim_judge_drawD5 = 180;
const int anim_judge_idleD = 181;
const int anim_judge_drawE = 195;
const int anim_judge_magicB = 200;
const int anim_judge_flameT = 214;
const int anim_judge_magicA = 226;
const int anim_judge_charge = 234;

/*==============================================================================
 The Judicator Knight (model/animation by Benoit Stordeur)

  Interesting QC traits
  * Has a floor damage attack to encourage players to jump
  * Uses the new flame (sprite) projectile system
  * Has logic to break attacks and switch based on enemy distance
 
==============================================================================*/

const int MON_JUDGE_BLUE = 4;
const int JUDGE_SPAWN_NOGFX = 32;

// Model state
const float JUDGE_STAND = 1;
const float JUDGE_TAUNT = 3;	// IdleB
const float JUDGE_IDLEC = 5;	// IdleC
const float JUDGE_IDLED = 7;	// IdleD
const float JUDGE_WALK = 10;
const float JUDGE_RUN = 15;
const float JUDGE_MELEE = 20;
const float JUDGE_JUMP = 25;
const float JUDGE_MAGICA = 30;
const float JUDGE_MAGICB = 32;
const float JUDGE_FLAME = 34;
const float JUDGE_LINE = 36;
const float JUDGE_SUMMON = 38;
const float JUDGE_PAIN = 40;
const float JUDGE_DEAD = 42;

// Sword location (Back/Shoulder/Hand)
const float JUDGE_SWBACK = 1;
const float JUDGE_SWSHOULDER = 2;
const float JUDGE_SWHAND = 3;
const float JUDGE_SWFLOOR = 4;

// Sword changing sound fx
const float JUDGE_SFXDEF = 0;
const float JUDGE_SFXDRAW = 1;
const float JUDGE_SFXSHEATH = 2;
const float JUDGE_SFXSWOOSH = 3;
const float JUDGE_SFXSILENT = 4;

const float JUDGE_PHASE0 = -1;	// No boss wave/setup
const float JUDGE_PHASE1 = 1;		// Intro
const float JUDGE_PHASE2 = 2;		// Fighting
const float JUDGE_PHASE3 = 3;		// Summon mode
const float JUDGE_PHASE4 = 4;		// Death

// Different model animation speeds
const float JUDGESPD_WALK = 7.4;
const float JUDGESPD_SWING = 31.4;
const float JUDGESPD_SMASH = 29.3;

.bool judge_summonflag;
.entity entchain;

.string tethertarget;
.float tetherrange;
.bool attack_switch;
.float attack_chance;
.bool attack_sidestep;
.int attack_count;
.float attack_timer;
.bool attack_active;
.int attack_summon;

.bool nospawndamage;

.int proj_attarc;

.float bosswave;
.int bosswaveqty;
.int bosswavetotal;
.float bosswavetrig;
.entity bossminchain;
.float bossminrnd;
.float bossminbase;
.entity entchain;

.int weaponstate;

.bool move_altwalk;

.int blendsfx;
.int blenddir;
.int blendstart;

.entity jumptouch;

// Forward compiler refeence
void judge_checksword(entity this, float finalstate, float soundtype);
void judge_summon(entity this);
void judge_jump6(entity this);
void judge_jump(entity this);
void judge_run(entity this);

//============================================================================
void judge_sword_sound(entity this)
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

//----------------------------------------------------------------------
// Setup wave HP and trigger boundaries
//----------------------------------------------------------------------
void judge_WaveSetupHP(entity this)
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
// Check if HP has reached next boss wave trigger event
//----------------------------------------------------------------------
bool judge_WaveCheck(entity this)
{
	// Should be in summon code, double check
	if(this.style == JUDGE_PHASE3)
		return true;
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
			FOREACH_ENTITY_STRING(targetname, this.noise,
			{
				if(it.use)
					it.use(it, NULL, this);
			});
		}

		// Update Boss wave parameters (next wave!)
		this.bosswave += 1;
		judge_WaveSetupHP(this);
		this.style = JUDGE_PHASE3;	// Summon mode
		return true;
	}
	return false;
}

//----------------------------------------------------------------------
// Check the tether system
//----------------------------------------------------------------------
bool judge_CheckTether(entity this)
{
	// Check the most obvious first, inside tether range?
	if(vdist(this.origin - this.movelast.origin, <, this.tetherrange))
		return false;
	else
	{
		// If player or tether close to each other?
		if(infront(this, this.movelast) && infront(this, this.enemy))
			return false;
		// Stop moving around
		else
			return true;
	}
}

//======================================================================
// Standing around
//----------------------------------------------------------------------
void judge_standframe(entity this)
{
	// Judge Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUDGE_DEAD)
		return;
	
	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, judge_standframe);
	
	// Beginning of animation block
	if(this.walkframe == 0)
	{
		if(random() < 0.2)
			_sound(this, CH_VOICE, "judge/idle1.wav", 1, ATTN_IDLE);
	}
	
	// Update frame and move forward
	this.frame = anim_judge_stand + this.walkframe;
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
				this.state = JUDGE_TAUNT;
				judge_checksword(this, JUDGE_SWSHOULDER, JUDGE_SFXSWOOSH);
			}
			else if(this.lefty <= 2)
			{
				// IdleC = Inspect the sword (for+back)
				this.state = JUDGE_IDLEC;
				judge_checksword(this, JUDGE_SWSHOULDER, JUDGE_SFXSWOOSH);
			}
			else {
				// Don't go into this idle animation if patrolling
				// This can last too long and be awkward to reset
				if(!this.attack_switch)
				{
					// IdleD = Place sword on floor
					this.state = JUDGE_IDLED;
					this.cnt = 0;
					judge_checksword(this, JUDGE_SWFLOOR, JUDGE_SFXSWOOSH);
				}
			}
		}
	}
	// Check for combat
	else
		ai_stand(this);	
}

//----------------------------------------------------------------------
void judge_tauntframe(entity this)
{
	// Judge Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUDGE_DEAD)
		return;
	
	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, judge_tauntframe);
	// Keep judge at path_corner idling
	if(this.pausetime > 0)
		this.pausetime += 0.1;

	// Sword swoosh/whoosh noises
	if(this.walkframe == 3 || this.walkframe == 12)
		judge_sword_sound(this);
	
	// Update frame and move forward
	// 00 01 02 03 04 05 06 07 -- (forward)
	//                      08    (pause)
	// 16 15 14 13 12 11 10 09    (backward)
	if(this.walkframe <= 7)
		this.frame = anim_judge_taunt + this.walkframe;
	else if(this.walkframe == 8)
		this.frame = anim_judge_taunt + 8 - 1;
	else
		this.frame = anim_judge_taunt + (16-this.walkframe);
	
	this.walkframe += 1;
	// Finished animation set?
	if(this.walkframe > 16 )
		this.th_stand(this);
	else
		ai_stand(this);	
}

//----------------------------------------------------------------------
void judge_idleCframe(entity this)
{
	// Judge Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUDGE_DEAD)
		return;
	
	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, judge_idleCframe);
	// Keep judge at path_corner idling
	if(this.pausetime > 0)
		this.pausetime += 0.1;

	// Sword swoosh/whoosh noises
	if(this.walkframe == 1 || this.walkframe == 22)
		judge_sword_sound(this);
	
	// Update frame and move forward
	// 00 01 02 03 04 05 06 07 08 09 10 11 12 (forward)
	// 24 23 22 21 20 19 18 17 16 15 14 13    (backward)
	if(this.walkframe <= 12)
		this.frame = anim_judge_idleC + this.walkframe;
	else
		this.frame = anim_judge_idleC + (24-this.walkframe);
	
	this.walkframe += 1;
	// Finished animation set?
	if(this.walkframe > 24 )
		this.th_stand(this);
	else
		ai_stand(this);	
}

//----------------------------------------------------------------------
void judge_idleDframe(entity this)
{
	// Judge Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUDGE_DEAD)
		return;
	
	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, judge_idleDframe);
	// Keep judge at path_corner idling
	if(this.pausetime > 0)
		this.pausetime += 0.1;

	// Update frame and move forward
	this.frame = anim_judge_idleD + this.walkframe;
	this.walkframe += 1;
	// Finished animation set?
	if(this.walkframe > 13 )
	{
		// Chance to keep this animation active?
		if(random() < this.attack_chance)
		{
			// Animation does not end with shoulder position
			this.state = JUDGE_STAND;
			judge_checksword(this, JUDGE_SWSHOULDER, JUDGE_SFXSWOOSH);
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
void judge_walkframe(entity this)
{
	// Judge Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUDGE_DEAD)
		return;
	
	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, judge_walkframe);
	// Avoid idleD (its too long for walk patrols)
	this.attack_switch = true;

	// Beginning of animation block
	if(this.walkframe == 3)
	{
		if(random() < 0.2)
			_sound(this, CH_VOICE, "judge/idle1.wav", 1, ATTN_IDLE);
	}

	// Update frame and move forward
	if(this.move_altwalk > 0)
		this.frame = anim_judge_walkB + this.walkframe;
	else
		this.frame = anim_judge_walk + this.walkframe;

	this.walkframe += 1;
	// Finished animation set?
	if(this.walkframe > 11)
		this.walkframe = 0;
	ai_walk(this, JUDGESPD_WALK);
}

void judge_runframe(entity this)
{
	// Judge Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUDGE_DEAD)
		return;
	
	// Check for boss wave trigger events
	if(judge_WaveCheck(this))
	{
		judge_summon(this);
		return;
	}

	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, judge_runframe);

	// Beginning of animation block
	if(this.walkframe == 2)
	{
		if(random() < 0.2)
			_sound(this, CH_VOICE, "judge/idle1.wav", 1, ATTN_IDLE);
	}

	// Update frame and move forward
	this.frame = anim_judge_run + this.walkframe;
	this.walkframe += 1;
	// Finished animation set?
	if(this.walkframe > 5)
		this.walkframe = 0;

	// Check for less than half health for drole rampage speed
	// Check the BOSS tether system
	if(judge_CheckTether(this))
		ai_run(this, 0);
	else
		ai_run(this, 24);
}

//======================================================================
// MELEE ATTACKS
//======================================================================

void judge_fistframe(entity this)
{
	// Judge Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUDGE_DEAD)
		return;
	
	// Check for summoning condition?
	if(judge_WaveCheck(this))
	{
		judge_summon(this);
		return;
	}

	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, judge_fistframe);

	// Keep turning towards enemy
	if(this.walkframe >= 0  && this.walkframe <= 7)
		ai_face(this);
	// Update frame before so weapon glow can sync
	this.frame = anim_judge_fist + this.walkframe;

	// Do specific stuff on certain animation frames
	if(this.walkframe == 0)
	{
		// Warn the player of impact
		_sound(this, CH_WEAPON_SINGLE, "judge/smash_roar.wav", 1, ATTN_NORM);
	}
	// Sneaky distance check before floor smash (must have enemy as well)
	else if(this.walkframe == 6 && this.enemy)
	{
		if(vdist(this.enemy.origin - this.origin, >, 200))
			this.attack_sidestep = true;
	}
	// Time for fist meets ground?
	else if(this.walkframe == 7)
	{
		// Move toward enemy
		ai_chargenoturn(this, 4); 
		// Pre-defined variables in defscustom.qc
		ai_shockwave(this, '24 8 -22', 30, 512, 250, 500, DEATH_MONSTER_JUDICATOR.m_id, "judge/smash_ground.wav");
	}
	
	// Enemy has moved too far away for stomp attack to be useful
	// Switch to the jump attack to get closer to the enemy
	// Jump attack is instant so it can blend easily with exit point
	if(this.attack_sidestep)
	{
		this.walkframe = 0;
		if(random() < 0.7)
			judge_jump(this);
		else
			this.th_missile(this);
	}
	else {
		// Update frame and move forward
		this.walkframe += 1;
		// Finished animation set? (1-12)
		if(this.walkframe > 11)
			this.th_run(this);
	}
}

//----------------------------------------------------------------------
void judge_chargeframe(entity this)
{
	// Judge Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUDGE_DEAD)
		return;
}

void judge_ai_melee(entity this)
{
	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;
			
	float ldmg = (random() + random() + random()) * 30;
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_JUDICATOR.m_id);
	_sound(this, CH_VOICE, "judge/smash_hitheavy.wav", 1, ATTN_NORM);

	SpawnMeatSpray(this, this.origin + v_forward*16, crandom() * 100 * v_right);
	SpawnMeatSpray(this, this.origin + v_forward*16, crandom() * 100 * v_right);
}

void judge_swingframe(entity this)
{
	// Judge Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUDGE_DEAD)
		return;

	// Check for boss wave trigger events
	if(judge_WaveCheck(this))
	{
		judge_summon(this);
		return;
	}

	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, judge_swingframe);

	// Keep turning towards enemy
	ai_face(this);
	
	// Put left foot forward first!
	if(this.walkframe >= 1 && this.walkframe <= 4)
	{
		ai_forward(this, JUDGESPD_SWING/4);
	}

	// Sword swoosh/whoosh noises
	if(this.walkframe == 2 || this.walkframe == 7)
		judge_sword_sound(this);
	// sword meets flesh! or air ...
	else if(this.walkframe == 3 || this.walkframe == 8)
		judge_ai_melee(this);
	
	// Update frame and move forward
	this.frame = anim_judge_swing + this.walkframe;
	this.walkframe = this.walkframe + 1;
	// Finished animation set? (1-12)
	if(this.walkframe > 11)
		this.th_run(this);
}

//----------------------------------------------------------------------
void judge_smashframe(entity this)
{
	// Judge Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUDGE_DEAD)
		return;

	// Check for boss wave trigger events
	if(judge_WaveCheck(this))
	{
		judge_summon(this);
		return;
	}

	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, judge_smashframe);

	// Face enemy
	ai_face(this);
	
	// Put left foot forward first!
	if(this.walkframe >= 1 && this.walkframe <= 5)
	{
		ai_forward(this, JUDGESPD_SMASH/5);
	}

	// Sword swoosh/whoosh noises
	if(this.walkframe == 3)
		judge_sword_sound(this);
	// sword meets flesh! or ground ...
	else if(this.walkframe == 5)
		judge_ai_melee(this);
	
	// Update frame and move forward
	this.frame = anim_judge_smash + this.walkframe;
	this.walkframe = this.walkframe + 1;
	// Finished animation set? (1-10)
	if(this.walkframe > 9)
		this.th_run(this);
}

//======================================================================
// (JUSTICE only) FLAMES PATTERN 1 - wall arc infront (at players feet)
//======================================================================
void judge_animate_fireball(entity this)
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

	setthink(this, judge_animate_fireball);
	this.nextthink = time + 0.1;
}

//----------------------------------------------------------------------
void judge_flamewall(entity this)
{
	// Judge Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUDGE_DEAD)
		return;
}

void judge_magicAframe(entity this)
{
	// Judge Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUDGE_DEAD)
		return;
}

//======================================================================
// (JUDGE only) MAGIC PATTERN B - Giant arrow heads in sweeping arc
//======================================================================
void judge_firemagicB(entity this, float offset)
{
	if(!this.enemy)
		return;
	if(this.health < 1)
		return;
	
	this.effects |= EF_MUZZLEFLASH;
	_sound(this, CH_WEAPON_SINGLE, "judge/magic_fire.wav", 1, ATTN_NORM);	
	
	// check for enemy origin (based on sight test)
	// if cannot see enemy fire at last known location
	ai_face(this);

	fixedmakevectors(this.angles);
	vector org = this.origin + attack_vector('24 0 32');
	
	// Create an arc pattern based on skill level
	vector fire_pat = '0 0 0';
	fire_pat.y = -2 + offset;
	org += attack_vector(fire_pat * 16);
	
	// Initially travels outward using sweep/arc pattern
	vector dir = v_forward + (v_right * (fire_pat.y * 0.2));
	
	// Skill based projectile fire 0=easy, 1=normal, 2=hard, 3=nm
	if(offset <= autocvar_skill)
	{
		//Launch_Missile (org, dir, '0 0 0', projcol, this.attack_speed);
		entity proj = launch_spike(this, org, dir);
		proj.projectiledeathtype = DEATH_MONSTER_JUDICATOR.m_id;
		proj.classname = "judge_spike";
		proj.dmg = 25;
		proj.avelocity = '0 0 0';
		_setmodel(proj, "progs/proj_judger.mdl");
		setsize(proj, '0 0 0', '0 0 0');		
		proj.velocity = dir * 600;
	}
	
	// Chance of flame off first (offset=0) swing of sword
	if(offset == 0)
	{
		// Any sprite space left for flame burst attack?
		if(random() < 0.1)
		{
			// Fire that flame!
			dir = v_forward * (100 + (100 * random()));
			// target, origin, v_forward, colour, size, lifetime, speed
			//Launch_Flame (this, org, dir, fire_col, FLAME_TINY, -1, 600);		
			entity newmis = Launch_Fireball(this, org, dir, 600);
			newmis.projectiledeathtype = DEATH_MONSTER_JUDICATOR.m_id;
			newmis.frame = floor(random() * 14);
			newmis.walkframe = newmis.frame;
			setthink(newmis, judge_animate_fireball);
			newmis.nextthink = time + 0.1;
			newmis.cnt = time + 10;

			_setmodel(newmis, "progs/s_flametiny.spr");
			setsize(newmis, '-4 -4 0', '4 4 16');

			float r = random();
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
		}
		// Majority of the time, spawn projectile dust
		else
			SpawnVelocitySmoke(org, dir+v_up, 200, 50);
	}
	// Spawn some projectile dust instead
	else
		SpawnVelocitySmoke(org, dir+v_up, 200, 50);
}

//----------------------------------------------------------------------
void judge_magicBframe(entity this)
{
	// Judge Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUDGE_DEAD)
		return;

	if(judge_WaveCheck(this))
	{
		judge_summon(this);
		return;
	}

	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, judge_magicBframe);
	
	ai_face(this);
	this.frame = anim_judge_magicB + this.walkframe;

	// Do specific stuff on certain animation frames
	if(this.walkframe == 0)
	{
		// Warn the player of firing magic
		_sound(this, CH_WEAPON_SINGLE, "judge/magic_attack.wav", 1, ATTN_NORM);
	}
	// Swinging arm backward
	else if(this.walkframe >= 1 && this.walkframe <= 4)
	{
		ai_face(this);
	}
	// Fire projectiles 1-4 based on skill level
	else if(this.walkframe >= 5 && this.walkframe <= 8)
	{
		judge_firemagicB(this, this.walkframe-5);
	}
	
	// Update frame and move forward
	this.walkframe += 1;
	if(this.walkframe > 13)
		this.th_run(this);
}

//======================================================================
// (JUDGE only) FLAMES PATTERN 2 - straight line towards player
//======================================================================
// TODO: trail portion of this is not implemented!
void Launch_Trail(entity this, vector org, vector dir)
{
	entity newmis = Launch_Fireball(this, org, dir, 600);
	newmis.projectiledeathtype = DEATH_MONSTER_JUDICATOR.m_id;
	newmis.frame = floor(random() * 14);
	newmis.walkframe = newmis.frame;
	setthink(newmis, judge_animate_fireball);
	newmis.nextthink = time + 0.1;
	newmis.cnt = time + 10;

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
}

void judge_fireflameline(entity this)
{
	// Judge cannot find target!
	if(!this.enemy)
		return;

	// Turn toward enemy
	ai_face(this);
	fixedmakevectors(this.angles);	
	vector org = this.origin + attack_vector('48 0 0');
	vector dir = v_forward;

	// Fire that flame!
	// Origin, v_forward, colour, sfx
	Launch_Trail(this, org, dir);
}

//----------------------------------------------------------------------
void judge_flameline(entity this)
{
	// Judge Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUDGE_DEAD)
		return;

	// Check for boss wave trigger events
	if(judge_WaveCheck(this))
	{
		judge_summon(this);
		return;
	}

	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, judge_flameline);
	
	if(this.walkframe <= 6)
		ai_face(this);
	this.frame = anim_judge_flameT + this.walkframe;
	// Do specific stuff on certain animation frames
	// Check for last frame (exit) first!
	if(this.walkframe == 0)
		_sound(this, CH_WEAPON_SINGLE, "judge/flame_attack.wav", 1, ATTN_NORM);

	else if(this.walkframe == 6)
		judge_fireflameline(this);
	else if(this.walkframe > 11)
	{
		// Slow down flame attacks with attack timer/blocker
		this.attack_timer = time + 1 + random();
		// Back to regular movement
		this.attack_state = AS_STRAIGHT;
		setthink(this, this.th_run);
	}

	// Update frame and move forward
	this.walkframe += 1;
}

//======================================================================
// Lunge forward (leaving ground) and do heavy damage on touch
//----------------------------------------------------------------------
void judge_JumpTouch(entity this, entity toucher)
{
	// Judge Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUDGE_DEAD)
		return;

	ai_jumpbreakable(this, toucher, 30);			// Damage any breakables
	settouch(this, func_null);			// No more touching
	this.count += 1;	// Total amount of touch jumps
	setthink(this, judge_jump6);	// Exit frame
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
			T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_JUDICATOR.m_id);	
			SpawnMeatSpray(this, toucher.origin, toucher.velocity);
			SpawnMeatSpray(this, toucher.origin, toucher.velocity);
			SpawnMeatSpray(this, toucher.origin, toucher.velocity);
		}
	}

	// Is the Judge floating in the air?
	if(!t_checkbottom(this))
	{
		// Is the Judge standing on something?		
		if(IS_ONGROUND(this))
		{	
			// Do an extra jump if got the count
			if(this.count < 2)
				setthink(this, judge_jump);
		}
	}
	// Go straight into landing animation
	else
		judge_jump6(this);
}

//----------------------------------------------------------------------
// Landed with a thud
void judge_jump7(entity this)
{
	set_animofs(this, anim_judge_jump, 7, judge_run);
	// Make sure attack state is reset (can then decide melee or range)
	this.attack_state = AS_STRAIGHT;
	this.angles_x = this.angles_z = 0;
	ai_face(this);
}
void judge_jump6(entity this) { set_animofs(this, anim_judge_jump, 6, judge_jump7); }
void judge_jump5(entity this)
{
	set_animofs(this, anim_judge_jump, 5, judge_jump5);
	// Double check monster is still falling?
	if(this.velocity == '0 0 0' || this.oldorigin == this.origin)
	{
		this.ideal_yaw = random() * 360; 	//random jump angle
		setthink(this, judge_jump6);
	}
	this.oldorigin = this.origin;
}
void judge_jump4(entity this) { set_animofs(this, anim_judge_jump, 4, judge_jump5); }
void judge_jump3(entity this) { set_animofs(this, anim_judge_jump, 3, judge_jump4); }
void judge_jump2(entity this)
{
	set_animofs(this, anim_judge_jump, 2, judge_jump3);
	ai_face(this);
	// Same for Judge and Justice
	settouch(this, judge_JumpTouch);

	this.jump_flag = time + 2;
	_sound(this, CH_WEAPON_SINGLE, "judge/leap1.wav", 1, ATTN_NORM);
	fixedmakevectors(this.angles);
	this.velocity = (v_forward * 450) + ('0 0 1' * 225);
	UNSET_ONGROUND(this);
	this.oldorigin = this.origin;
}
void judge_jump1(entity this) { set_animofs(this, anim_judge_jump, 1, judge_jump2); ai_face(this); }

//----------------------------------------------------------------------
void judge_jump(entity this)
{
	// Entered combat once
	this.attack_active = true;
	
	// Check for boss wave trigger events
	if(judge_WaveCheck(this))
	{
		judge_summon(this);
		return;
	}

	this.state = JUDGE_JUMP;
	// No pain + make sword in correct position
	this.pain_finished = time + 1;
	judge_checksword(this, JUDGE_SWHAND, JUDGE_SFXDEF);
}

//======================================================================
// Entry point for Stand, Walk and Run monster states
// All have to cope with sword out/on back blend animations
//----------------------------------------------------------------------
void judge_stand(entity this)
{ 
	// Let blend animation happen before any walking
	if(this.pausetime > 0 && this.weaponstate != JUDGE_SWSHOULDER) 
		this.pausetime += 0.5;
	// Standing around, check sword status first
	this.state = JUDGE_STAND;
	judge_checksword(this, JUDGE_SWSHOULDER, JUDGE_SFXDEF);
}

//----------------------------------------------------------------------
void judge_walk(entity this)
{
	// Start walking
	this.state = JUDGE_WALK;
	// Which walk animation to use?
	if(this.move_altwalk > 0)
		judge_checksword(this, JUDGE_SWHAND, JUDGE_SFXDEF);
	else
		judge_checksword(this, JUDGE_SWBACK, JUDGE_SFXDEF);
}

//----------------------------------------------------------------------
void judge_run(entity this)
{
	// Don't start combat with a jump!
	if(!this.attack_active)
		this.jump_flag = time + 2;
	// Entered combat once
	this.attack_active = true;

	// Check for boss wave trigger events
	if(judge_WaveCheck(this))
	{
		judge_summon(this);
		return;
	}

	this.state = JUDGE_RUN; 
	judge_checksword(this, JUDGE_SWHAND, JUDGE_SFXDEF);
}

//----------------------------------------------------------------------
void judge_melee(entity this)
{
	// Entered combat once
	this.attack_active = true;
	// Reset jump attack decision branch
	this.attack_sidestep = false;

	// Check for boss wave trigger events
	if(judge_WaveCheck(this))
	{
		judge_summon(this);
		return;
	}

	this.state = JUDGE_MELEE; 
	// No pain + make sword in correct position
	this.pain_finished = time + 1;
	judge_checksword(this, JUDGE_SWHAND, JUDGE_SFXDEF);
}

//----------------------------------------------------------------------
void judge_range(entity this)
{
	// Entered combat once
	this.attack_active = true;
	// Check for boss wave trigger events
	if(judge_WaveCheck(this))
	{
		judge_summon(this);
		return;
	}

	//------------------------------------------------------------------
	// Flame LINE and MagicB = JUDGE (boss) only
	//------------------------------------------------------------------
	// Magic range will always reach a monster
	if(IS_MONSTER(this.enemy))
		this.state = JUDGE_MAGICB;
	else
	{
		// Flame line limited distance
		if(vdist(this.enemy.origin - this.origin, <, 400))
			this.state = JUDGE_LINE;
		else
			this.state = JUDGE_MAGICB;
	
		// Forced pause between FLAME attacks
		if(this.attack_timer < time)
		{
			// Any sprite space left for hazard projectiles?
			this.state = JUDGE_MAGICB;
		}
		// Do magic attack instead
		else
			this.state = JUDGE_MAGICB;
	}
	
	// No pain + make sure sword in correct position
	this.pain_finished = time + 1;
	judge_checksword(this, JUDGE_SWHAND, JUDGE_SFXDEF);
}

//======================================================================
// Sword position blending, checked by all functions
// Blend animations ( Back / Shoulder / Hand )
//----------------------------------------------------------------------
void judge_finishsword(entity this)
{
	this.walkframe = this.attack_chance = 0;
	// Where to go next?
	if(this.state == JUDGE_STAND) judge_standframe(this);
	else if(this.state == JUDGE_TAUNT) judge_tauntframe(this);
	else if(this.state == JUDGE_IDLEC) judge_idleCframe(this);
	else if(this.state == JUDGE_IDLED) judge_idleDframe(this);
	else if(this.state == JUDGE_WALK) judge_walkframe(this);
	else if(this.state == JUDGE_MELEE)
	{
		// Special setup for monster infighting
		if(IS_MONSTER(this.enemy))
			judge_smashframe(this);
		// Close enough for classic swing left/right
		else if(ai_checkmelee(this, 100, 64)) 
			judge_swingframe(this);
		// Fist smash ground (Boss ONLY)
		else
			judge_fistframe(this);
	}
	else if(this.state == JUDGE_JUMP) judge_jump1(this);
	else if(this.state == JUDGE_MAGICA) judge_magicAframe(this);
	else if(this.state == JUDGE_MAGICB) judge_magicBframe(this);
	else if(this.state == JUDGE_LINE) judge_flameline(this);
	else if(this.state == JUDGE_FLAME) judge_flamewall(this);
	// Default = in combat and running
	else
		judge_runframe(this);
}

void judge_movesword(entity this)
{
	// Check for boss wave trigger events
	if(judge_WaveCheck(this))
	{
		judge_summon(this);
		return;
	}

	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, judge_movesword);
	// Sword sound (defined beforehand)
	if(this.walkframe == 2)
	{
		// Allow for sound override
		if(this.blendsfx == JUDGE_SFXDRAW)
		{
			_sound(this, CH_WEAPON_SINGLE, "judge/sword_draw.wav", 1, ATTN_NORM);
		}
		else if(this.blendsfx == JUDGE_SFXSHEATH)
		{
			_sound(this, CH_WEAPON_SINGLE, "judge/sword_sheath.wav", 1, ATTN_NORM);
		}
		else if(this.blendsfx == JUDGE_SFXSWOOSH)
			judge_sword_sound(this);
	}
	// Step through animation (check direction)
	if(this.blenddir == 1)
		this.frame = this.blendstart + this.walkframe;
	else
		this.frame = this.blendstart + (4 - this.walkframe);
	this.walkframe += 1;
	
	// Check if finished animation
	if(this.walkframe > 4)
		judge_finishsword(this);
}

void judge_checksword(entity this, int finalstate, int soundtype)
{
	// Judge Dead stops here!
	if(this.health < 1)
		return;
	if(this.state == JUDGE_DEAD)
		return;

	this.walkframe = 0;
	// Is sword in right position? - Move on to next animation
	if(finalstate == this.weaponstate)
		judge_finishsword(this);
	else
	{
		// Setup defaults
		this.blendstart = anim_judge_drawA;
		this.blenddir = 1;
		this.blendsfx = soundtype;

		// drawA1 = Move sword from BACK to hand
		// drawB1 = Move sword from HAND to shoulder
		// drawC1 = Move sword from SHOULDER to back
		// drawD1 = Move sword from SHOULDER to floor
		// drawE1 = Move sword from FLOOR to hand
		if(this.weaponstate == JUDGE_SWBACK)
		{
			if(finalstate == JUDGE_SWSHOULDER)
			{
				//dprint("BACK --> SHOULDER\n");
				if(soundtype == 0)
					this.blendsfx = JUDGE_SFXDRAW;
				this.blendstart = anim_judge_drawC;
				this.blenddir = -1;
			}
			else if(finalstate == JUDGE_SWHAND)
			{
				//dprint("BACK --> HAND\n");
				if(soundtype == 0)
					this.blendsfx = JUDGE_SFXDRAW;
				this.blendstart = anim_judge_drawA;
				this.blenddir = 1;
			}
			else if(finalstate == JUDGE_SWFLOOR)
			{
				//dprint("BACK --> FLOOR\n");
				// blend does not exist, use shoulder -> floor
				if(soundtype == 0)
					this.blendsfx = JUDGE_SFXSHEATH;
				this.blendstart = anim_judge_drawD;
				this.blenddir = 1;
			}
		}
		else if(this.weaponstate == JUDGE_SWSHOULDER)
		{
			if(finalstate == JUDGE_SWBACK)
			{
				//dprint("SHOULDER --> BACK\n");
				if(soundtype == 0)
					this.blendsfx = JUDGE_SFXSHEATH;
				this.blendstart = anim_judge_drawC;
				this.blenddir = 1;
			}
			else if(finalstate == JUDGE_SWHAND)
			{
				//dprint("SHOULDER --> HAND\n");
				if(soundtype == 0)
					this.blendsfx = JUDGE_SFXSHEATH;
				this.blendstart = anim_judge_drawB;
				this.blenddir = -1;
			}
			else if(finalstate == JUDGE_SWFLOOR)
			{
				//dprint("SHOULDER --> FLOOR\n");
				if(soundtype == 0)
					this.blendsfx = JUDGE_SFXSHEATH;
				this.blendstart = anim_judge_drawD;
				this.blenddir = 1;
			}
		}
		else if(this.weaponstate == JUDGE_SWHAND)
		{
			if(finalstate == JUDGE_SWBACK)
			{
				//dprint("HAND --> BACK\n");
				if(soundtype == 0)
					this.blendsfx = JUDGE_SFXDRAW;
				this.blendstart = anim_judge_drawA;
				this.blenddir = -1;
			}
			else if(finalstate == JUDGE_SWSHOULDER)
			{
				//dprint("HAND --> SHOULDER\n");
				if(soundtype == 0)
					this.blendsfx = JUDGE_SFXSHEATH;
				this.blendstart = anim_judge_drawB;
				this.blenddir = 1;
			}
			else if(finalstate == JUDGE_SWFLOOR)
			{
				//dprint("HAND --> FLOOR\n");
				if(soundtype == 0)
					this.blendsfx = JUDGE_SFXSHEATH;
				this.blendstart = anim_judge_drawE;
				this.blenddir = -1;
			}
		}
		else if(this.weaponstate == JUDGE_SWFLOOR)
		{
			if(finalstate == JUDGE_SWBACK)
			{
				//dprint("FLOOR --> BACK\n");
				// blend does not exist, use floor -> shoulder
				if(soundtype == 0)
					this.blendsfx = JUDGE_SFXDRAW;
				this.blendstart = anim_judge_drawD;
				this.blenddir = -1;
			}
			else if(finalstate == JUDGE_SWSHOULDER)
			{
				//dprint("FLOOR --> SHOULDER\n");
				if(soundtype == 0)
					this.blendsfx = JUDGE_SFXSHEATH;
				this.blendstart = anim_judge_drawD;
				this.blenddir = -1;
			}
			else if(finalstate == JUDGE_SWHAND)
			{
				//dprint("FLOOR --> HAND\n");
				if(soundtype == 0)
					this.blendsfx = JUDGE_SFXSHEATH;
				this.blendstart = anim_judge_drawE;
				this.blenddir = -1;
			}
		}
	
		// Setup counter and update state
		this.weaponstate = finalstate;
		// Start blend animation
		judge_movesword(this);
	}
}

//======================================================================
// BOSS ONLY - summon a bunch of gaunts
//----------------------------------------------------------------------
void Spawn_judgeMinFX(entity this)
{
	// Randomly pick from teleport sounds
	float r = random() * 5;
	string snd;
	if(r < 1)
		snd = "misc/r_tele1.wav";
	else if(r < 2)
		snd = "misc/r_tele2.wav";
	else if(r < 3)
		snd = "misc/r_tele3.wav";
	else if(r < 4)
		snd = "misc/r_tele4.wav";
	else
		snd = "misc/r_tele5.wav";
	_sound(this, CH_VOICE, snd, 1, ATTN_NORM);
	
	// Show ID teleport particle effect
	te_teleport(this.origin);
}

//----------------------------------------------------------------------
// Fire random plasma spikes while summoning gaunt minions
//----------------------------------------------------------------------
void Fire_judgePlasma(entity this)
{
	makevectors(this.angles);
	vector ovec = '24 8 112' + (random() * '-16 -12 32');
	vector org = this.origin + attack_vector(ovec);
	vector rndvec = randomvec() * 50;
	vector destvec = normalize(rndvec);
	//launch_plasma(org, destvec, CT_SUMMONLIGHT, SPEED_REFLECTION);
	entity plasma = launch_plasma(this, org, destvec);
	_setmodel(plasma, "progs/proj_lightning2.mdl");
	setsize(plasma, '0 0 0', '0 0 0');
	plasma.projectiledeathtype = DEATH_MONSTER_JUDICATOR.m_id;
	plasma.velocity = v_forward + destvec * 600;
}

//----------------------------------------------------------------------
void Spawn_judgeMin(entity this)
{
	// Fire off some random plasma/lightning
	Fire_judgePlasma(this);
	
	// Cycle through spawn targets and spawn Tfog + Gaunt
	int scount = this.attack_summon;
	while(scount > 0)
	{
		setthink(this.bossminchain, Spawn_judgeMinFX);
		this.bossminchain.nextthink = time + 0.01 + random() * 0.3;

		// If the spawn locaiton all clear, spawn something!
		this.pos1 = this.bossminchain.origin;
		this.judge_summonflag = find_minionspace(this.pos1);			
		if(this.judge_summonflag) 
			minion_spawn(this, this.pos1, new(monster), MON_GAUNT);
		
		// Next spawn point
		this.bossminchain = this.bossminchain.entchain;
		scount -= 1;
	}
}

//----------------------------------------------------------------------
void Setup_judgeMin(entity this)
{
	// Work out random position along length of sword
	// Hilt = 20 0 112  Middle = 16 0 128  Top = 12 0 144
	fixedmakevectors(this.angles);
	vector ovec = '24 8 112' + (random() * '-16 -12 32');
	vector org = this.origin + attack_vector(ovec);

	// Slowly suck in particles to sword
	particle(org, '0 0 1' * (20 + random() * 20), 75, 75);
	//particle_implode(org, 20+random()*20, 75, 75, PARTICLE_BURST_BLUE);
	
	// Generate a random bolt of electricity
	Fire_judgePlasma(this);

	// Cycle through spawn targets and fire Lightning per frame
	int scount = this.attack_summon;
	while(scount > 0)
	{
		// Traceline from spawn point to random direction
		vector start = this.bossminchain.origin - org;
		vector offset = randomvec() * 50;
		vector targpos = normalize(start + offset);
		traceline(org, org + targpos * 600, false, this);
		
		// Create lightning bolt from source to target
		SendCSQCLightningBeam(org, trace_endpos);
		
		// Play some arching lightning sounds
		if(random() < 0.5)
		{
			if(random() < 0.5)
				_sound(this.bossminchain, CHAN_BODY, "judge/elec_arch1.wav", 1, ATTN_NORM);
			else
				_sound(this.bossminchain, CHAN_BODY, "judge/elec_arch2.wav", 1, ATTN_NORM);
		}

		// Next spawn point
		this.bossminchain = this.bossminchain.entchain;
		scount -= 1;
	}
}

//----------------------------------------------------------------------
void judge_summonframe(entity this)
{
	// Keep looping
	this.nextthink = time + 0.1;
	setthink(this, judge_summonframe);

	// Only turn towards player on intro/outro
	if(this.walkframe < 4 || this.walkframe > 9)
		ai_face(this);
	
	// Beginning of animation block
	// INTRO sequence --------------------------------------
	if(this.walkframe >= 0 && this.walkframe <= 3)
	{
		this.frame = anim_judge_summon + this.walkframe;
		// Setup animation sound/loop counter
		if(this.walkframe == 0)
			_sound(this, CH_WEAPON_SINGLE, "judge/summon.wav", 1, ATTN_NORM);
	}
	// MAIN loop -------------------------------------------
	else if(this.walkframe >= 4 && this.walkframe <= 9)
	{
		this.frame = anim_judge_summon + this.walkframe;
		if(this.walkframe == 9 && this.attack_count == 1)
			Spawn_judgeMin(this);
		else
			Setup_judgeMin(this);
	}
	// OUTRO sequence --------------------------------------
	if(this.walkframe > 8)
	{
		// Keep counting down loop (6 frames)
		this.attack_count -= 1;
		if(this.attack_count > 0)
			this.walkframe = 3;
		// Setup outro (0-3 backward)
		else
			this.frame = anim_judge_summon + (13-this.walkframe);		
	}
	
	// Next frame / loop
	this.walkframe += 1;
	
	// End of sequence? ------------------------------------
	if(this.walkframe > 13)
	{
		this.walkframe = 0;
		// Restore ammo resistance to default
		Resist_ChangeType(this, false);
		this.style = JUDGE_PHASE2;	// Fight mode
		this.th_run(this);
	}
}

//----------------------------------------------------------------------
void judge_summon(entity this)
{
	// Always reset the think
	this.nextthink = time + 0.1;
	setthink(this, judge_summonframe);
	
	// Block all damage while summoning stuff
	Resist_ChangeType(this, true);
	
	// Reset attack state so it does not keep spawning
	this.attack_state = AS_STRAIGHT;
	int scount = this.attack_summon;
	while(scount > 0)
	{
		int tries = 4;	// Try 4 times, no infinite loops
		while(tries > 0)
		{
			// Work out 2 empty spaces around Judicator for minions
			this.pos2 = randomvec() + '1 1 1' * (this.bossminbase * this.bossminrnd);
			// Always spawn higher than boss
			if(this.pos2_z < this.maxs_z)
				this.pos2_z = this.maxs_z;
			this.pos1 = this.origin + this.pos2;
			// Check for available space for mininon
			this.judge_summonflag = find_minionspace(this.pos1);
			tries -= 1;
			// Space is right, save origin
			if(this.judge_summonflag)
				tries = -10;
		}
		// Found space, store origin for later
		if(tries == -10)
			this.bossminchain.origin = this.pos1;
		else
			this.bossminchain.origin = this.origin;
		
		// Next spawn point
		this.bossminchain = this.bossminchain.entchain;
		scount -= 1;
	}
	
	// Start spawning stuff!
	this.pain_finished = time + 5;
	this.walkframe = 0;
	this.attack_count = 2;
	judge_summonframe(this);
}

void judge_painA4(entity this) { set_animofs(this, anim_judge_painA, 4, judge_run); }
void judge_painA3(entity this) { set_animofs(this, anim_judge_painA, 3, judge_painA4); }
void judge_painA2(entity this) { set_animofs(this, anim_judge_painA, 2, judge_painA3); }
void judge_painA1(entity this) { set_animofs(this, anim_judge_painA, 1, judge_painA2); }

void judge_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	if((random() * 200) > damage)
		return;
	if(this.state == JUDGE_DEAD)
		return;

	this.pain_finished = time + 2;
	if(judge_WaveCheck(this))
	{
		judge_summon(this);
		return;
	}
	judge_painA1(this);
	_sound(this, CH_VOICE, "judge/pain1.wav", 1, ATTN_NORM);
}

void judge_dieA10(entity this) { set_animofs(this, anim_judge_deathA, 10, judge_dieA10); CorpseThink(this); }
void judge_dieA9(entity this) { set_animofs(this, anim_judge_deathA, 9, judge_dieA10); }
void judge_dieA8(entity this) { set_animofs(this, anim_judge_deathA, 8, judge_dieA9); }
void judge_dieA7(entity this) { set_animofs(this, anim_judge_deathA, 7, judge_dieA8); }
void judge_dieA6(entity this)
{
	set_animofs(this, anim_judge_deathA, 6, judge_dieA7);
	_sound(this, CH_WEAPON_SINGLE, "gibs/gibmetala.wav", 1, ATTN_NORM);
}
void judge_dieA5(entity this) { set_animofs(this, anim_judge_deathA, 5, judge_dieA6); }
void judge_dieA4(entity this) { set_animofs(this, anim_judge_deathA, 4, judge_dieA5); }
void judge_dieA3(entity this) { set_animofs(this, anim_judge_deathA, 3, judge_dieA4); }
void judge_dieA2(entity this) { set_animofs(this, anim_judge_deathA, 2, judge_dieA3); }
void judge_dieA1(entity this) { set_animofs(this, anim_judge_deathA, 1, judge_dieA2); this.solid = SOLID_NOT; }

void judge_dieB9(entity this) { set_animofs(this, anim_judge_deathB, 9, judge_dieB9); CorpseThink(this); }
void judge_dieB8(entity this) { set_animofs(this, anim_judge_deathB, 8, judge_dieB9); }
void judge_dieB7(entity this)
{
	set_animofs(this, anim_judge_deathB, 7, judge_dieB8);
	_sound(this, CH_WEAPON_SINGLE, "gibs/gibmetala.wav", 1, ATTN_NORM);
}
void judge_dieB6(entity this) { set_animofs(this, anim_judge_deathB, 6, judge_dieB7); }
void judge_dieB5(entity this) { set_animofs(this, anim_judge_deathB, 5, judge_dieB6); }
void judge_dieB4(entity this) { set_animofs(this, anim_judge_deathB, 4, judge_dieB5); }
void judge_dieB3(entity this) { set_animofs(this, anim_judge_deathB, 3, judge_dieB4); }
void judge_dieB2(entity this) { set_animofs(this, anim_judge_deathB, 2, judge_dieB3); }
void judge_dieB1(entity this) { set_animofs(this, anim_judge_deathB, 1, judge_dieB2); this.solid = SOLID_NOT; }

void judge_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(this.message2 && this.message2 != "")
	{
		FOREACH_ENTITY_STRING(targetname, this.message2,
		{
			if(it.use)
				it.use(it, NULL, this);
		});
	}

// check for gib
	if(this.health < -60)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, inflictor, "progs/h_judge.mdl", this.health);
		ThrowGib(this, inflictor, "progs/w_judgesword.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib_judgeboot.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib_judgeshould.mdl", this.health);
		return;
	}

// regular death
	_sound(this, CH_VOICE, "judge/death1.wav", 1, ATTN_NORM);
	if(random() < 0.5)
		judge_dieA1(this);
	else
		judge_dieB1(this);
}

bool judge_minionsetup(entity this)
{
	entity min_prev = NULL, min_first = NULL;
	
	// Cycle through minion list
	int scount = this.attack_summon;
	entity newmis = NULL;
	while(scount > 0)
	{
		newmis = spawn();
		newmis.origin = this.origin;
		newmis.owner = this;
		// Is this the first pass through loop?
		if(!min_first)
			min_first = newmis;
		// Any previous entities created?
		if(!min_prev)
			min_prev = newmis;
		else
		{
			// Link previous to current entity
			// and move previous forward in chain
			min_prev.entchain = newmis;
			min_prev = newmis;
		}
		// Keep on looping
		scount -= 1;
	}
	// Close loop
	if(min_first)
	{
		newmis.entchain = min_first;
		this.bossminchain = min_first;
		return false;
	}
	return true;
}

void judge_spawntether(entity this)
{
	// temporary tether point
	this.movelast = spawn();
	this.movelast.owner = this;
	this.movelast.classname = "tether";
	set_movetype(this.movelast, MOVETYPE_NONE);
	this.movelast.solid = SOLID_NOT;
	this.movelast.origin = this.origin;
	setsize(this.movelast, '0 0 0', '0 0 0');
}

void judge_readyframe(entity this)
{
	this.takedamage = DAMAGE_AIM;	// Can take damage
	this.style = JUDGE_PHASE2;		// Time to fight!
	Resist_ChangeType(this,false);	// restore resistance
}

/*======================================================================
 JudgeCheckAttack
======================================================================*/
bool JudgeCheckAttack(entity this)
{
	//----------------------------------------------------------------------
	// Melee attack (Special fist ground smash)
	//----------------------------------------------------------------------
	if(random() < 0.5 && ai_checkmelee(this, 200, 64))
	{
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

	if(this.jump_flag < time && infront(this, this.enemy))
	{
		if(this.enemy.origin_z <= this.origin_z)
		{
			float edist = vlen2(this.enemy.origin - this.origin);
			if(edist > 200 && edist < 300)
			{
				this.attack_finished = time + random();
				this.jumptouch = NULL;
				this.count = 0;
				judge_jump(this);
				return true;
			}
		}
	}

	if(time < this.attack_finished)
		return false;

	this.attack_state = AS_MISSILE;
	this.attack_finished = time + 2 + random();
	return true;
}

void judge_awake(entity this, entity actor, entity trigger)
{
	this.use = func_null;
	this.style = JUDGE_PHASE1;
	this.frame = anim_judge_stand;

	this.takedamage = DAMAGE_NO;
	this.yaw_speed = 20; // average speed
	this.velocity = '0 0 0';
	this.walkframe = 0;
	this.attack_summon = autocvar_skill + 1;

	if(this.tetherrange < 32)
		this.tetherrange = 500;
	if(this.bossminbase <= 64)
		this.bossminbase = 128;
	if(this.bossminrnd <= 64)
		this.bossminrnd = 128;

	if(this.attack_summon > 3)
		this.attack_summon = 3;

	if(!this.tethertarget || this.tethertarget == "")
		judge_spawntether(this);
	else
		this.movelast = find(NULL, targetname, this.tethertarget);

	if(!this.movelast)
	{
		delete(this);
		return; // TODO? no path means no monster?!
	}

	if(judge_minionsetup(this))
	{
		delete(this);
		return; // TODO!
	}

	if(!this.nospawndamage)
		spawn_tdeath(this.origin, this);

	if(!(this.spawnflags & JUDGE_SPAWN_NOGFX))
		spawn_tfog(this.origin);

	Resist_Save(this);
	Resist_ChangeType(this, true); // resist everything

	this.deadflag = DEAD_NO;
	if(this.bosswave < 1)
		this.bosswavetotal = 4;
	else
		this.bosswavetotal = this.bosswave;

	// setup initial boss wave
	this.bosswave = 1;
	if(this.bosswaveqty < 1)
		this.bosswaveqty = 500;
	this.max_health = this.bosswavetotal * this.bosswaveqty;
	judge_WaveSetupHP(this);

	this.pain_finished = time + 3;
	this.attack_finished = time + 2;

	this.enemy = this.goalentity = this.movetarget = NULL;

	if(this.message && this.message != "")
	{
		FOREACH_ENTITY_STRING(targetname, this.message,
		{
			if(it.use)
				it.use(it, NULL, this);
		});
		this.message = "";
	}

	this.message2 = this.target;
	this.target = this.target2 = this.deathtarget = "";

	judge_readyframe(this);
}

//======================================================================
/*QUAKED monster_judicator (1 0 0) (-32 -32 -24) (32 32 80) Ambush
======================================================================*/
spawnfunc(monster_judicator) { monster_start(this, true, MON_JUDICATOR); }
#endif // SVQC

#ifdef SVQC
METHOD(Judicator, mr_setup, bool(Judicator this, entity actor))
{
    TC(Judicator, this);

	precache_model("progs/w_judgesword.mdl");
	precache_model("progs/gib_judgeboot.mdl");
	precache_model("progs/gib_judgeshould.mdl");

	precache_sound("gibs/gibmetala.wav");

	precache_model("progs/proj_judger.mdl");
	precache_model("progs/proj_ringshock.mdl");
	precache_model("progs/proj_lightning2.mdl");

	precache_model("progs/s_flamemed.spr");
	precache_model("progs/s_flamesml.spr");
	precache_model("progs/s_flametiny.spr");

	precache_model("progs/s_judgemagic.spr");

	precache_sound("judge/idle1.wav");
	precache_sound("judge/smash_roar.wav");
	precache_sound("judge/smash_ground.wav");
	precache_sound("judge/smash_hit.wav");
	precache_sound("judge/smash_hitheavy.wav");
	precache_sound("judge/magic_attack.wav");
	precache_sound("judge/magic_fire.wav");
	precache_sound("judge/magic_hit.wav");
	precache_sound("judge/flame_attack.wav");
	precache_sound("judge/pain1.wav");
	precache_sound("judge/death1.wav");
	precache_sound("judge/elec_arch1.wav");
	precache_sound("judge/elec_arch2.wav");
	precache_sound("judge/summon.wav");
	precache_sound("judge/sword_draw.wav");
	precache_sound("judge/sword_sheath.wav");
	precache_sound("weapons/sword1a.wav");
	precache_sound("weapons/sword1b.wav");
	precache_sound("weapons/sword2a.wav");
	precache_sound("weapons/sword2b.wav");

	precache_sound("judge/leap1.wav");

	precache_sound("ambience/flames1.wav");
	precache_sound("ambience/flames2.wav");
	precache_sound("ambience/flames3.wav");
	precache_sound("ambience/flames4.wav");

	if(random() < 0.5 || (actor.spawnflags & MON_JUDGE_BLUE))
		actor.skin = 1;
	else
		actor.skin = 0;

    actor.health = 50000; // health is actually in stages
    actor.th_stand = judge_stand;
	actor.th_walk = judge_walk;
	actor.th_run = judge_run;
	actor.th_melee = judge_melee;
	actor.th_missile = judge_range;
	actor.th_pain = judge_pain;
	actor.th_die = judge_die;

	actor.checkattack = JudgeCheckAttack;

	actor.weaponstate = JUDGE_SWSHOULDER;
	actor.state = JUDGE_STAND;
	actor.style = JUDGE_PHASE0;

	actor.resist_rockets = actor.resist_cells = 0.75;
	actor.reflectlightning = true;
	actor.reflectplasma = true;

	judge_awake(actor, NULL, NULL);

    return true;
}
#endif
