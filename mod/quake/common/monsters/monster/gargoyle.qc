#include "gargoyle.qh"

/*==============================================================================
GARGOYLE / IMP (Hexen2 Model)
==============================================================================*/

#ifdef SVQC
const int anim_gargoyle_death = 0; //'0 13 0'
const int anim_gargoyle_attack = 14; //'14 35 0'
const int anim_gargoyle_fly = 36; //'36 55 0'
const int anim_gargoyle_grow = 56; //'56 65 0'
const int anim_gargoyle_flyup = 66; //'66 88 0'
const int anim_gargoyle_perch = 89; //'89 112 0'
const int anim_gargoyle_swoop = 113; //'113 132 0'
const int anim_gargoyle_swooploop = 133; //'133 136 0'
const int anim_gargoyle_swoopend = 137; //'137 151 0'
const int anim_gargoyle_swoopout = 152; //'152 166 0'

const int MON_GARGOYLE_STATUE = 2;				// Will start frozen with stone skin
const int MON_GARGOYLE_PERCH = 4;		// Start in perched position

.float meleeattack;
.entity attachment;

void gargoylewings(entity this)
{
	_sound(this, CHAN_ITEM, "gargoyle/wings1.wav", 1, ATTN_IDLE);
}
void garg_fbfinish(entity this);
void garg_run1(entity this);
void garg_walk1(entity this);
void garg_idle1(entity this);
void garg_fire1(entity this);

//======================================================================
void garg_idle10(entity this) { set_animofs(this, anim_gargoyle_fly, 20, garg_idle1); ai_stand(this); }
void garg_idle9(entity this) { set_animofs(this, anim_gargoyle_fly, 18, garg_idle10); ai_stand(this); }
void garg_idle8(entity this) { set_animofs(this, anim_gargoyle_fly, 16, garg_idle9); ai_stand(this); }
void garg_idle7(entity this) { set_animofs(this, anim_gargoyle_fly, 14, garg_idle8); ai_stand(this); }
void garg_idle6(entity this) { set_animofs(this, anim_gargoyle_fly, 12, garg_idle7); ai_stand(this); }
void garg_idle5(entity this) { set_animofs(this, anim_gargoyle_fly, 10, garg_idle6); ai_stand(this); }
void garg_idle4(entity this) { set_animofs(this, anim_gargoyle_fly, 8, garg_idle5); ai_stand(this); }
void garg_idle3(entity this) { set_animofs(this, anim_gargoyle_fly, 6, garg_idle4); gargoylewings(this); ai_stand(this); }
void garg_idle2(entity this) { set_animofs(this, anim_gargoyle_fly, 4, garg_idle3); ai_stand(this); }
void garg_idle1(entity this)
{
	set_animofs(this, anim_gargoyle_fly, 2, garg_idle2);
	if(random() > 0.8)
		_sound(this, CH_VOICE, "gargoyle/idle1.wav", 1, ATTN_IDLE);
	ai_stand(this);
}

//======================================================================
void garg_walk10(entity this) { set_animofs(this, anim_gargoyle_fly, 19, garg_walk1); ai_walk(this, 8); }
void garg_walk9(entity this) { set_animofs(this, anim_gargoyle_fly, 17, garg_walk10); ai_walk(this, 8); }
void garg_walk8(entity this) { set_animofs(this, anim_gargoyle_fly, 15, garg_walk9); ai_walk(this, 8); }
void garg_walk7(entity this) { set_animofs(this, anim_gargoyle_fly, 13, garg_walk8); ai_walk(this, 8); }
void garg_walk6(entity this) { set_animofs(this, anim_gargoyle_fly, 11, garg_walk7); ai_walk(this, 8); }
void garg_walk5(entity this) { set_animofs(this, anim_gargoyle_fly, 9, garg_walk6); ai_walk(this, 8); }
void garg_walk4(entity this) { set_animofs(this, anim_gargoyle_fly, 7, garg_walk5); ai_walk(this, 8); }
void garg_walk3(entity this) { set_animofs(this, anim_gargoyle_fly, 5, garg_walk4); gargoylewings(this); ai_walk(this, 8); }
void garg_walk2(entity this) { set_animofs(this, anim_gargoyle_fly, 3, garg_walk3); ai_walk(this, 8); }
void garg_walk1(entity this)
{
	set_animofs(this, anim_gargoyle_fly, 1, garg_walk2);
	if(random() > 0.8)
		_sound(this, CH_VOICE, "gargoyle/idle1.wav", 1, ATTN_IDLE);
	ai_walk(this, 8);
}

//======================================================================
void garg_run10(entity this) { set_animofs(this, anim_gargoyle_fly, 19, garg_run1); ai_run(this, 8); }
void garg_run9(entity this) { set_animofs(this, anim_gargoyle_fly, 17, garg_run10); ai_run(this, 7); }
void garg_run8(entity this) { set_animofs(this, anim_gargoyle_fly, 15, garg_run9); ai_run(this, 6); }
void garg_run7(entity this) { set_animofs(this, anim_gargoyle_fly, 13, garg_run8); ai_run(this, 5); }
void garg_run6(entity this) { set_animofs(this, anim_gargoyle_fly, 11, garg_run7); ai_run(this, 4); }
void garg_run5(entity this) { set_animofs(this, anim_gargoyle_fly, 9, garg_run6); ai_run(this, 8); }
void garg_run4(entity this) { set_animofs(this, anim_gargoyle_fly, 7, garg_run5); ai_run(this, 7); }
void garg_run3(entity this) { set_animofs(this, anim_gargoyle_fly, 5, garg_run4); gargoylewings(this); ai_run(this, 6); }
void garg_run2(entity this) { set_animofs(this, anim_gargoyle_fly, 3, garg_run3); ai_run(this, 5); }
void garg_run1(entity this)
{
	set_animofs(this, anim_gargoyle_fly, 1, garg_run2);
	if(random() > 0.8)
		_sound(this, CH_VOICE, "gargoyle/idle1.wav", 1, ATTN_IDLE);
	if(this.attachment && this.attachment.state)
		garg_fbfinish(this);
	// Switch direction of strafing (random duration)
	if(this.meleeattack < time)
	{
		this.meleeattack = time + 4 + (random() + random() + random() * 4);
		this.lefty = rint(1 - this.lefty);
	}
	ai_run(this, 4);
}

//============================================================================
// Range attack
//============================================================================
void garg_fbthrow(entity this)
{
	makevectors(this.angles);

	vector org = this.origin + attack_vector('16 28 22');
	vector dir = normalize(this.enemy.origin - org);

	entity newmis = launch_spike(this, org, dir);
	newmis.poisonous = this.poisonous;
	if(newmis.poisonous)
		_setmodel(newmis, "progs/proj_gargoylegrn.mdl");
	else
		_setmodel(newmis, "progs/proj_gargoyle.mdl");
	newmis.avelocity = '0 0 0';
	newmis.dmg = 20;
	setsize(newmis, '0 0 0', '0 0 0');		
	newmis.velocity = dir * (500 + (autocvar_skill * 150));
	settouch(newmis, T_MissileTouch); // rocket explosion
	newmis.effects = EF_DIMLIGHT;
	newmis.projectiledeathtype = DEATH_MONSTER_GARGOYLE.m_id;
}

//----------------------------------------------------------------------
void garg_fbfinish(entity this)
{
	_setmodel(this.attachment, "");
	setsize(this.attachment, '0 0 0', '0 0 0');
	this.attachment.state = false;
}

//----------------------------------------------------------------------
void garg_fbupdate(entity this, float fbframe, vector fbofs)
{
	if(this.health < 1)
		return;
	if(!this.attachment)
	{
		this.attachment = spawn();
		this.attachment.owner = this;
		this.attachment.classname = "attachment";
		if(this.poisonous)
			this.attachment.mdl = "progs/proj_gargballgrn.mdl";
		else
			this.attachment.mdl = "progs/proj_gargball.mdl";
		this.attachment.alpha = 0.85;
	}
	
	if(fbframe == 0)
	{
		this.attachment.state = true;
		this.pain_finished = time + 1.5;		//don't go into pain whilst firing
		setorigin(this.attachment, this.origin);
		_setmodel(this.attachment, this.attachment.mdl);
		setsize(this.attachment, '0 0 0', '0 0 0');
		set_movetype(this.attachment, MOVETYPE_NONE);
		this.attachment.solid = SOLID_NOT;
		_sound(this, CH_WEAPON_SINGLE, "gargoyle/attack1.wav", 1, ATTN_NORM);
	}

	ai_face(this);					// Turn towards enemy
	makevectors(this.angles);
	this.attachment.origin = this.origin + v_forward*fbofs_x + v_right*fbofs_y;
	this.attachment.origin_z = this.attachment.origin_z + fbofs_z;
	setorigin(this.attachment, this.attachment.origin);
	this.attachment.angles = this.angles;
	this.attachment.frame = fbframe;
}

//----------------------------------------------------------------------
// Original offset position for gargoyle fireball (designed for a sprite)
// 10 16 0, 4 24 2, -7 28 15, -25 26 28, -38 12 45, -38 9 45, -17 36 30, 24 16 10
// Changed the offset to match the new model instead
// Positioned the fireball to match the hand orientation
//----------------------------------------------------------------------
void garg_fire10(entity this)
{
	set_animofs(this, anim_gargoyle_attack, 20, garg_run1);
	ai_face(this);
	// If enemy really close, goto into a frenzy of fireball attacks
	if(this.enemy.health > 0 && range(this, this.enemy) <= RANGE_MELEE)
		setthink(this, garg_fire1);
	else
		this.attack_state = AS_STRAIGHT;
}
void garg_fire9(entity this) { set_animofs(this, anim_gargoyle_attack, 18, garg_fire10); ai_face(this); }
void garg_fire8(entity this) { set_animofs(this, anim_gargoyle_attack, 16, garg_fire9); garg_fbfinish(this); garg_fbthrow(this); }
void garg_fire7(entity this) { set_animofs(this, anim_gargoyle_attack, 14, garg_fire8); garg_fbupdate(this, 3,'-32 22 38'); }
void garg_fire6(entity this) { set_animofs(this, anim_gargoyle_attack, 12, garg_fire7); garg_fbupdate(this, 4,'-34 9 45'); }
void garg_fire5(entity this) { set_animofs(this, anim_gargoyle_attack, 10, garg_fire6); garg_fbupdate(this, 5,'-29 18 38'); }
void garg_fire4(entity this) { set_animofs(this, anim_gargoyle_attack, 8, garg_fire5); garg_fbupdate(this, 4,'-16 26 18'); }
void garg_fire3(entity this) { set_animofs(this, anim_gargoyle_attack, 6, garg_fire4); garg_fbupdate(this, 3,'-6 23 6'); gargoylewings(this); }
void garg_fire2(entity this) { set_animofs(this, anim_gargoyle_attack, 4, garg_fire3); garg_fbupdate(this, 2,'0 20 -2'); }
void garg_fire1(entity this) { set_animofs(this, anim_gargoyle_attack, 2, garg_fire2); garg_fbupdate(this, 0,'10 16 -2'); }

//============================================================================
// PERCH + WAKEUP
//============================================================================
void garg_perch1(entity this);
void garg_perch12(entity this) { set_animofs(this, anim_gargoyle_perch, 24, garg_perch1); ai_stand(this); }
void garg_perch11(entity this) { set_animofs(this, anim_gargoyle_perch, 22, garg_perch12); ai_stand(this); }
void garg_perch10(entity this) { set_animofs(this, anim_gargoyle_perch, 20, garg_perch11); ai_stand(this); }
void garg_perch9(entity this) { set_animofs(this, anim_gargoyle_perch, 18, garg_perch10); ai_stand(this); }
void garg_perch8(entity this) { set_animofs(this, anim_gargoyle_perch, 16, garg_perch9); ai_stand(this); }
void garg_perch7(entity this) { set_animofs(this, anim_gargoyle_perch, 14, garg_perch8); ai_stand(this); }
void garg_perch6(entity this) { set_animofs(this, anim_gargoyle_perch, 12, garg_perch7); ai_stand(this); }
void garg_perch5(entity this) { set_animofs(this, anim_gargoyle_perch, 10, garg_perch6); ai_stand(this); }
void garg_perch4(entity this) { set_animofs(this, anim_gargoyle_perch, 8, garg_perch5); ai_stand(this); }
void garg_perch3(entity this) { set_animofs(this, anim_gargoyle_perch, 6, garg_perch4); ai_stand(this); }
void garg_perch2(entity this) { set_animofs(this, anim_gargoyle_perch, 4, garg_perch3); ai_stand(this); }
void garg_perch1(entity this)
{
	set_animofs(this, anim_gargoyle_perch, 2, garg_perch2);
	ai_stand(this);
	if(random() > 0.8)
		_sound(this, CH_VOICE, "gargoyle/idle1.wav", 1, ATTN_IDLE);
}

//----------------------------------------------------------------------
// Sightsound and very quick animation while moving forward
void garg_wakeup6(entity this)
{
	set_animofs(this, anim_gargoyle_flyup, 20, garg_run1);
	FindTarget(this);			// Find target (angry/path_corner)
	this.nextthink = time + 0.1;// Next frame
}
void garg_wakeup5(entity this) { set_animofs(this, anim_gargoyle_flyup, 16, garg_wakeup6); ai_forward(this, 4); }
void garg_wakeup4(entity this) { set_animofs(this, anim_gargoyle_flyup, 14, garg_wakeup5); ai_forward(this, 8); gargoylewings(this); }
void garg_wakeup3(entity this) { set_animofs(this, anim_gargoyle_flyup, 6, garg_wakeup4); ai_forward(this, 8); }
void garg_wakeup2(entity this) { set_animofs(this, anim_gargoyle_flyup, 4, garg_wakeup3); ai_forward(this, 4); }
void garg_wakeup1(entity this) { set_animofs(this, anim_gargoyle_flyup, 2, garg_wakeup2); ai_forward(this, 1); }

//----------------------------------------------------------------------
void gargoyle_wakeup(entity this)
{
	// Dead already?
	if(this.health < 1)
		return;

	// No longer perched on the ground
	this.spawnflags &= ~MON_GARGOYLE_PERCH;
	this.spawnflags &= ~MON_GARGOYLE_STATUE;
	
	this.takedamage = DAMAGE_AIM;		// Can receive damage
	this.use = func_null;				// no re-trigger
	
	// Restore all think state functions
	this.th_stand = garg_idle1;
	this.th_walk = garg_walk1;
	this.th_run = garg_run1;
	this.th_missile = garg_fire1;

	// Allow gargoyle to fly up, no more ground checks
	this.flags |= FL_FLY;
	set_movetype(this, MOVETYPE_STEP);
	this.pain_finished = time + 1.5;		// No pain
	this.attack_finished = 1.5 + random();	// No skill adjustment
	garg_wakeup1(this);
}

//----------------------------------------------------------------------
void gargoyle_statue(entity this)
{
	if(random() < 0.2)
		_sound(this, CH_VOICE, "statue/idle1.wav", 1, ATTN_NORM);
	
 	setthink(this, gargoyle_statue);
 	this.nextthink = time + 5 + random()*5;
}

//======================================================================
// MINION - Grow and spin up from nothing
//======================================================================
void gargoyle_growangle(entity this)
{
	this.angles_y = this.angles_y + this.lefty;
}

void garg_pain(entity this, entity attacker, float damage, int deathtype);
void gargoyle_grow10(entity this)
{
	set_animofs(this, anim_gargoyle_grow, 10, garg_run1);
	// Is the gargoyle stuck? cannot move?
	if(pointcontents(this.origin) == CONTENT_SOLID)
	{
		// Time to die!
		this.health = -70;
		Killed(this, this, this, DEATH_CRUSH.m_id);
	}
	else
	{
		// Finally spin back to original position
		this.angles_y = this.angles_y + this.lefty;
		// Setup goals and warn other monsters
		FoundTarget(this);

		// Restore all think state functions
		this.th_stand = garg_idle1;
		this.th_walk = garg_walk1;
		this.th_run = garg_run1;
		this.th_missile = garg_fire1;
		this.th_pain = garg_pain;
	}
}
void gargoyle_grow9(entity this) { set_animofs(this, anim_gargoyle_grow, 9, gargoyle_grow10); gargoyle_growangle(this); }
void gargoyle_grow8(entity this) { set_animofs(this, anim_gargoyle_grow, 8, gargoyle_grow9); gargoyle_growangle(this); }
void gargoyle_grow7(entity this) { set_animofs(this, anim_gargoyle_grow, 7, gargoyle_grow8); gargoyle_growangle(this); }
void gargoyle_grow6(entity this) { set_animofs(this, anim_gargoyle_grow, 6, gargoyle_grow7); gargoyle_growangle(this); }
void gargoyle_grow5(entity this) { set_animofs(this, anim_gargoyle_grow, 5, gargoyle_grow6); gargoyle_growangle(this); }
void gargoyle_grow4(entity this) { set_animofs(this, anim_gargoyle_grow, 4, gargoyle_grow5); gargoyle_growangle(this); }
void gargoyle_grow3(entity this) { set_animofs(this, anim_gargoyle_grow, 3, gargoyle_grow4); gargoyle_growangle(this); }
void gargoyle_grow2(entity this) { set_animofs(this, anim_gargoyle_grow, 2, gargoyle_grow3); gargoyle_growangle(this); }
void gargoyle_grow1(entity this) { set_animofs(this, anim_gargoyle_grow, 1, gargoyle_grow2); }
//----------------------------------------------------------------------------
void gargoyle_grow(entity this)
{
	// Only call wakeup function once
	this.th_stand = this.th_walk = this.th_run = func_null;
	this.th_pain = func_null;
	if(random() < 0.5)
		this.lefty = 36;
	else
		this.lefty = -36;
	_sound(this, CH_VOICE, "gargoyle/sight1.wav", 1, ATTN_NORM);
	gargoyle_grow1(this);
}

//============================================================================
// The gargoyle does not have a specific pain animation
// - Kinn created one from the death animation (Marcher progs)
void garg_pain5(entity this) { set_animofs(this, anim_gargoyle_death, 1, garg_run1); }
void garg_pain4(entity this) { set_animofs(this, anim_gargoyle_death, 2, garg_pain5); }
void garg_pain3(entity this) { set_animofs(this, anim_gargoyle_death, 3, garg_pain4); }
void garg_pain2(entity this) { set_animofs(this, anim_gargoyle_death, 4, garg_pain3); }
void garg_pain1(entity this) { set_animofs(this, anim_gargoyle_death, 3, garg_pain2); }

//----------------------------------------------------------------------
void garg_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.health <= 0)
		return;
	if(random() * 200 > damage)
		return; // ddin't flinch
	if(this.pain_finished > time)
		return;

	// Check for perching gargoyles, need special wakeup
	if(this.spawnflags & MON_GARGOYLE_PERCH)
		gargoyle_wakeup(this);
	// Statues don't feel pain!
	else if(this.spawnflags & MON_GARGOYLE_STATUE)
		return;
	else
	{
		this.pain_finished = time + 2;

		// make sure any fireball is hidden
		if(this.attachment)
			garg_fbfinish(this);

		// Any pain animation/sound required?
		if(random() < 0.5)
			_sound(this, CH_VOICE, "gargoyle/pain75.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "gargoyle/pain100.wav", 1, ATTN_NORM);
		garg_pain1(this);
	}
}

//============================================================================
void garg_death8(entity this) { set_animofs(this, anim_gargoyle_death, 14, garg_death8); CorpseThink(this); }
void garg_death7(entity this) { set_animofs(this, anim_gargoyle_death, 13, garg_death8); }
void garg_death6(entity this) { set_animofs(this, anim_gargoyle_death, 11, garg_death7); }
void garg_death5(entity this) { set_animofs(this, anim_gargoyle_death, 9, garg_death6); }
void garg_death4(entity this) { set_animofs(this, anim_gargoyle_death, 7, garg_death5); }
void garg_death3(entity this) { set_animofs(this, anim_gargoyle_death, 5, garg_death4); }
void garg_death2(entity this) { set_animofs(this, anim_gargoyle_death, 3, garg_death3); }
void garg_death1(entity this) { set_animofs(this, anim_gargoyle_death, 1, garg_death2); this.solid = SOLID_NOT; }

//----------------------------------------------------------------------
void garg_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	// Make sure any wings sound is silenced
	_sound(this, CHAN_ITEM, "", 1, ATTN_NORM);

	// Statues don't die!
	if(this.spawnflags & MON_GARGOYLE_STATUE)
		return;

	bool dogib = (this.spawnflags & MON_GARGOYLE_PERCH);

	// If creating a Fireball, make it explode!
	if(this.attachment)
	{
		if(this.attachment.state)
		{
			dogib = true;
			SpawnProjectileSmoke(this.origin, 200, 50, 150);
			SpawnProjectileSmoke(this.origin, 200, 50, 150);
			//particle_explode(this.origin-'0 0 16', 50+random()*50, 2, this.lip, PARTICLE_BURST_UPWARD);
			vector partpos = this.origin + '0 0 16';
			if(this.poisonous)
				te_explosion2(partpos, 50, 20);
			else
				te_explosion2(partpos, 225, 10);
			makevectors(this.angles);
			float explef = EXPLODE_BIG;
			if(this.poisonous)
				explef = EXPLODE_POISON_BIG;
			SpawnExplosion(explef, this.origin + v_forward*8, "weapons/r_exp3b.wav");
		}
		// make sure any fireball is hidden
		garg_fbfinish(this);
	}

	if(this.health < -70 || dogib)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, "progs/h_gargoyle.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib2.mdl", this.health);
		ThrowGib(this, "progs/gib3.mdl", this.health);
		if(random() < 0.5)
			ThrowGib(this, "progs/gib_gargwing1.mdl", this.health);
		if(random() < 0.5)
			ThrowGib(this, "progs/gib_gargwing2.mdl", this.health);
		return;
	}
	
	// If not gibbed, then drop to ground
	_sound(this, CH_VOICE, "gargoyle/death1.wav", 1, ATTN_NORM);
	//this.flags = FL_MONSTER;				// reset all flag conditions
	set_movetype(this, MOVETYPE_TOSS);			// Affected by gravity
	this.velocity_x = -200 + 400*random();
	this.velocity_y = -200 + 400*random();
	this.velocity_z = 100 + 100*random();
	garg_death1(this);
}

bool GargoyleCheckAttack(entity this)
{
	if(time < this.attack_finished)
		return false;
		
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

	//----------------------------------------------------------------------
	// If setup to be a turret, check range attack only
	//----------------------------------------------------------------------
	if(this.movespeed < 0)
	{
		// Keep firing rockets when at range
		this.attack_finished = time + 1 + 2 * random();
		this.attack_state = AS_MISSILE;
		return true;
	}
	//----------------------------------------------------------------------
	// Range attack (Fireball)
	//----------------------------------------------------------------------
	// Only range attack if cooldown has finished
	if(time > this.attack_finished)
	{
		float attack_chance = 0;
		if(this.enemy_range == RANGE_MELEE) attack_chance = 0.9;		// range < 120 map units
		else if(this.enemy_range == RANGE_NEAR) attack_chance = 0.6;	// range < 500 map units
		else if(this.enemy_range == RANGE_MID) attack_chance = 0.2;	// range < 1000 map units
		if(random () < attack_chance)
		{
			if(this.enemy_range != RANGE_MELEE)
				this.attack_finished = time + (2 + random());
			this.attack_state = AS_MISSILE;
			return true;
		}
	}

	if(this.enemy_range >= RANGE_MID)
		this.attack_state = AS_STRAIGHT;
	else
		this.attack_state = AS_SLIDING;

	return true;
}

/*======================================================================
QUAKED monster_gargoyle (0.8 0 0.2) (-16 -16 -24) (16 16 40) AMBUSH STATUE PERCH NOSIGHT NOIDLE NOGFX STARTOFF ANGRY Not_Easy Not_Normal Not_Hard Not_DM
{ model(":progs/mon_gargoyle.mdl"); }
Gargoyle, 120 health points.
-------- KEYS --------
-------- SPAWNFLAGS --------
STATUE : Stone statue until triggered (always starts in a perched position)
PERCH : Start in a sitting down, place 44 units out from perching edge, 4 units higher

======================================================================*/
spawnfunc(monster_gargoyle) { monster_start(this, true, MON_GARGOYLE); }
#endif // SVQC

#ifdef SVQC
METHOD(Gargoyle, mr_setup, bool(Gargoyle this, entity actor))
{
    TC(Gargoyle, this);

	precache_model("progs/gib_gargwing1.mdl");
	precache_model("progs/gib_gargwing2.mdl");
	precache_model("progs/proj_gargball.mdl");
	precache_model("progs/proj_gargoyle.mdl");
	precache_model("progs/proj_gargoylegrn.mdl");
	precache_model("progs/proj_gargoyle.mdl");

	precache_sound("gargoyle/idle1.wav");
	precache_sound("gargoyle/perch1.wav");
	precache_sound("gargoyle/perch2.wav");
	precache_sound("gargoyle/attack1.wav");
	precache_sound("gargoyle/swoop1.wav");
	precache_sound("gargoyle/swoop2.wav");
	precache_sound("gargoyle/swoop1hit.wav");
	precache_sound("gargoyle/wings1.wav");
	precache_sound("gargoyle/pain75.wav");
	precache_sound("gargoyle/pain100.wav");
	precache_sound("gargoyle/death1.wav");
	precache_sound("weapons/r_exp3b.wav");

	// Fix double spawnflags problem - default to statue
	if((actor.spawnflags & MON_GARGOYLE_STATUE) && (actor.spawnflags & MON_GARGOYLE_PERCH))
		actor.spawnflags &= ~MON_GARGOYLE_PERCH;

    actor.health = 120;
	actor.th_pain = garg_pain; 
	actor.th_die = garg_die;

	//----------------------------------------------------------------------
	// Perched Gargoyles have special idle animation + idle sounds
	// The AI needs to be setup 40 units forward and 24 units up
	// to be positioned feet flat on perch surface
	if(actor.spawnflags & MON_GARGOYLE_PERCH)
	{
		actor.th_stand = actor.th_walk = garg_perch1;
		actor.th_run = actor.th_missile = gargoyle_wakeup;
		actor.flags &= ~FL_FLY; // unset flying type for now!
	}
	//----------------------------------------------------------------------
	// Statue Gargoyles setup in perch position with statue idle sounds
	// Randomly picks a frame position from perch animation set
	else if(actor.spawnflags & MON_GARGOYLE_STATUE)
	{
		// Setup stone idle sounds
		precache_sound("statue/idle1.wav");
		precache_sound("statue/idle2.wav");
		
		actor.poisonous = false;				// Cannot be status + poison
		actor.th_stand = gargoyle_statue;	// Stone idle pose
		actor.skin = 1;						// Stone like skin
		//actor.resist_nails = 0.5;			// Stone resistance
		// Work out random starting pose
		float f1 = anim_gargoyle_perch;
		float f2 = (anim_gargoyle_perch + 24) - 1; // - 1 because we start at 1
		float f3 = fabs(f2 - f1);
		actor.frame = rint(f1 + random() * f3);
	}
	//----------------------------------------------------------------------
	// Special spawning minion need to start spinning
	else if(actor.flags & FL_CLONE) // TODO: custom flag
	{
		actor.th_stand = actor.th_walk = actor.th_run = gargoyle_grow;
		actor.th_missile = func_null;
	}
	//----------------------------------------------------------------------
	// Default gargoyle setup
	else
	{
		actor.th_stand = garg_idle1;
		actor.th_walk = garg_walk1;
		actor.th_run = garg_run1;
		actor.th_missile = garg_fire1;
	}

	actor.checkattack = GargoyleCheckAttack;

    return true;
}
#endif
