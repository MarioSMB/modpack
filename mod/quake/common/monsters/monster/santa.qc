#include "santa.qh"

#ifdef SVQC
const int anim_santa_stand = 0;
const int anim_santa_run = 6;
const int anim_santa_lounge = 12;
const int anim_santa_victory = 18;
const int anim_santa_attack = 28;
const int anim_santa_sack = 32;
const int anim_santa_painA = 42;
const int anim_santa_painB = 47;
const int anim_santa_death = 52;
const int anim_santa_bdeath = 62;
const int anim_santa_sitA = 71;
const int anim_santa_sitB = 78;

const int MON_SANTA_GOOD = 2;

/*==============================================================================
XMAS Santa - From Twisted Christmas Mod by Twisted Matrix
==============================================================================*/

void santa_seatA1(entity this);
void santa_seatA7(entity this) { set_animofs(this, anim_santa_sitA, 7, santa_seatA1); if(this.th_stand) this.th_stand(this); }
void santa_seatA6(entity this) { set_animofs(this, anim_santa_sitA, 6, santa_seatA7); }
void santa_seatA5(entity this) { set_animofs(this, anim_santa_sitA, 5, santa_seatA6); }
void santa_seatA4(entity this) { set_animofs(this, anim_santa_sitA, 4, santa_seatA5); }
void santa_seatA3(entity this) { set_animofs(this, anim_santa_sitA, 3, santa_seatA4); }
void santa_seatA2(entity this) { set_animofs(this, anim_santa_sitA, 2, santa_seatA3); }
void santa_seatA1(entity this) { set_animofs(this, anim_santa_sitA, 1, santa_seatA2); }

//----------------------------------------------------------------------
void santa_seatB1(entity this);
void santa_seatB6(entity this) { set_animofs(this, anim_santa_sitB, 6, santa_seatB1); if(this.th_stand) this.th_stand(this);}
void santa_seatB5(entity this) { set_animofs(this, anim_santa_sitB, 5, santa_seatB6); }
void santa_seatB4(entity this) { set_animofs(this, anim_santa_sitB, 4, santa_seatB5); }
void santa_seatB3(entity this) { set_animofs(this, anim_santa_sitB, 3, santa_seatB4); }
void santa_seatB2(entity this) { set_animofs(this, anim_santa_sitB, 2, santa_seatB3); }
void santa_seatB1(entity this) { set_animofs(this, anim_santa_sitB, 1, santa_seatB2); }

//----------------------------------------------------------------------
.float waitmin;
void santa_trigger(entity this, entity actor, entity trigger)
{
	// Trigger Once
	if(this.waitmin < 0 || this.waitmin > time)
		return;
	this.waitmin = -1;
	this.use = func_null;
	
	// "My dear boy, you saved me!"
	_sound(this, CH_WEAPON_SINGLE, "xmas/santa/good_saved.wav", 1, ATTN_NORM);
	
	// Fire all triggers/sounds/messages
	SUB_UseTargets(this, actor, trigger);
	
	// Fade out santa (+delete model)
	if(!this.alpha)
		this.alpha = 1;
	setthink(this, MonsterFade2);
	this.nextthink = time + 2 + random();
	settouch(this, func_null);
	this.th_pain = func_null;

	if(!(this.flags & FL_CLONE))
		monsters_killed += 1;
}

void santa_freetouch(entity this, entity toucher)
{
	settouch(this, func_null);
	this.use = func_null;
	this.th_pain = func_null;
	
	// "My dear boy, you saved me!"
	_sound(this, CH_WEAPON_SINGLE, "xmas/santa/good_saved.wav", 1, ATTN_NORM);
	
	// Fire all triggers/sounds/messages
	SUB_UseTargets(this, toucher, NULL);
	
	// Fade out santa (+delete model)
	if(!this.alpha)
		this.alpha = 1;
	setthink(this, MonsterFade2);
	this.nextthink = time + 2 + random();

	if(!(this.flags & FL_CLONE))
		monsters_killed += 1;
}

//----------------------------------------------------------------------
void santa_seated(entity this)
{
	// Keep resetting health/touch function
	this.health = this.max_health;
	this.use = santa_trigger;
	if(random() < 0.5)
		santa_seatA1(this);
	else
		santa_seatB1(this);
}

void santa_idlesound(entity this)
{
	if(random() < 0.2)
	{
		if(this.spawnflags & MON_SANTA_GOOD)
			_sound(this, CH_VOICE, "xmas/santa/good_hohoho.wav", 1,  ATTN_IDLE);
		else
		{
			float r = random();
			if(r < 0.333)
				_sound(this, CH_VOICE, "xmas/santa/hohoho.wav", 1,  ATTN_IDLE);
			else if(r < 0.666)
				_sound(this, CH_VOICE, "xmas/santa/laugh1.wav", 1,  ATTN_IDLE);
			else
				_sound(this, CH_VOICE, "xmas/santa/laugh3_com.wav", 1,  ATTN_IDLE);
		}
	}
}

void santa_stand1(entity this);
void santa_stand6(entity this) { set_animofs(this, anim_santa_stand, 6, santa_stand1); ai_stand(this); }
void santa_stand5(entity this) { set_animofs(this, anim_santa_stand, 5, santa_stand6); ai_stand(this); }
void santa_stand4(entity this) { set_animofs(this, anim_santa_stand, 4, santa_stand5); ai_stand(this); }
void santa_stand3(entity this) { set_animofs(this, anim_santa_stand, 3, santa_stand4); ai_stand(this); }
void santa_stand2(entity this) { set_animofs(this, anim_santa_stand, 2, santa_stand3); ai_stand(this); }
void santa_stand1(entity this) { set_animofs(this, anim_santa_stand, 1, santa_stand2); santa_idlesound(this); ai_stand(this); }

//======================================================================
void santa_walk1(entity this);
void santa_walk6(entity this) { set_animofs(this, anim_santa_run, 6, santa_walk1); ai_walk(this, 15); monster_footstep(this, false); }
void santa_walk5(entity this) { set_animofs(this, anim_santa_run, 5, santa_walk6); ai_walk(this, 17); }
void santa_walk4(entity this) { set_animofs(this, anim_santa_run, 4, santa_walk5); ai_walk(this, 15); }
void santa_walk3(entity this) { set_animofs(this, anim_santa_run, 3, santa_walk4); ai_walk(this, 15); monster_footstep(this, false); }
void santa_walk2(entity this) { set_animofs(this, anim_santa_run, 2, santa_walk3); ai_walk(this, 17); }
void santa_walk1(entity this) { set_animofs(this, anim_santa_run, 1, santa_walk2); santa_idlesound(this); ai_walk(this, 15); }

//======================================================================
void santa_run1(entity this);
void santa_run6(entity this) { set_animofs(this, anim_santa_run, 6, santa_run1); ai_run(this, 20); monster_footstep(this, false); }
void santa_run5(entity this) { set_animofs(this, anim_santa_run, 5, santa_run6); ai_run(this, 24); }
void santa_run4(entity this) { set_animofs(this, anim_santa_run, 4, santa_run5); ai_run(this, 20); }
void santa_run3(entity this) { set_animofs(this, anim_santa_run, 3, santa_run4); ai_run(this, 20); monster_footstep(this, false); }
void santa_run2(entity this) { set_animofs(this, anim_santa_run, 2, santa_run3); ai_run(this, 24); }
void santa_run1(entity this)
{
	set_animofs(this, anim_santa_run, 1, santa_run2);
	santa_idlesound(this);
	ai_run(this, 20);
}

void SantaMelee(entity this)
{
	if(!this.enemy)
		return;
	if(this.health < 1)
		return;
	if(!this.enemy.takedamage)
		return;
		
	ai_charge(this, 10);	// + ai_face()
	ai_damagebreakable(this, 50);
	if(!ai_checkmelee(this, 100, 0))
		return;

	_sound(this, CH_WEAPON_SINGLE, "xmas/santa/sack_hit.wav", 1, ATTN_NORM);

	// Sack attack is strong (1-60)
	float ldmg = max(1, (random() + random() + random()) * 20);
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_SANTA.m_id);

	// Spawn blood at sack
	spawn_touchblood(this, ldmg*3, this.enemy);
	// Lots of blood and gore
	SpawnMeatSpray(this, this.enemy.origin, '1 1 1' * (crandom() * 100));
	SpawnMeatSpray(this, this.enemy.origin, '1 1 1' * (crandom() * 100));
}

//----------------------------------------------------------------------
void santa_sack3(entity this);
void santa_sack10(entity this)
{
	set_animofs(this, anim_santa_sack, 10, santa_run1);
	// Check if snowman is within range to attack again
	if(ai_checkmelee(this, 100, 0) && this.enemy.health > 0)
	{
		if(this.health > 0)
			setthink(this, santa_sack3);
	}
}
void santa_sack9(entity this) { set_animofs(this, anim_santa_sack, 9, santa_sack10); }
void santa_sack8(entity this) { set_animofs(this, anim_santa_sack, 8, santa_sack9); SantaMelee(this); }
void santa_sack7(entity this) { set_animofs(this, anim_santa_sack, 7, santa_sack8); ai_charge(this, 10); }
void santa_sack6(entity this) { set_animofs(this, anim_santa_sack, 6, santa_sack7); ai_charge(this, 10); }
void santa_sack5(entity this) { set_animofs(this, anim_santa_sack, 5, santa_sack6); ai_charge(this, 10); }
void santa_sack4(entity this)
{
	set_animofs(this, anim_santa_sack, 4, santa_sack5);
	ai_face(this);
	// This sound is exactly 0.4s long, with hit to complete
	_sound(this, CH_WEAPON_SINGLE, "xmas/santa/sack_swing.wav", 1, ATTN_NORM);
}
void santa_sack3(entity this) { set_animofs(this, anim_santa_sack, 3, santa_sack4); ai_face(this); }
void santa_sack2(entity this) { set_animofs(this, anim_santa_sack, 2, santa_sack3); }
void santa_sack1(entity this) { set_animofs(this, anim_santa_sack, 1, santa_sack2); ai_face(this); }

.float attack_chance;
.float attack_timer;
void santa_launch_projectile(entity this, vector org, vector dir)
{
	entity newmis = launch_spike(this, org, dir);
	_setmodel(newmis, "progs/xmas/proj_snowball.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	newmis.dmg = 15;
	newmis.velocity = dir * 600;
	newmis.projectiledeathtype = DEATH_MONSTER_SANTA.m_id;
}

void Santa_FireSnow(entity this)
{
	vector spot1, spot2;
	
	// Keep adding up projectile counter
	this.attack_chance += 1;
	
	// Lit up that barrel
	this.effects |= EF_MUZZLEFLASH;
	_sound(this, CH_WEAPON_SINGLE, "xmas/santa/fire.wav", 1, ATTN_NORM);	

	// Keep tracking enemy origin (similar to wizards)
	ai_face(this);

	// Calculate the center of the gun
	fixedmakevectors(this.angles);
	vector org = this.origin + attack_vector('28 22 26');
	
	// Barrel 1
	spot1 = org + v_right*6;
	spot2 = normalize((this.enemy.origin + +v_right*6) - spot1);
	santa_launch_projectile(this, spot1, spot2);
	
	// Barrel 2
	spot1 = org - v_right*6;
	spot2 = normalize((this.enemy.origin + -v_right*6) - spot1);
	santa_launch_projectile(this, spot1, spot2);
}

//----------------------------------------------------------------------
void santa_snow1(entity this);
void santa_snow4(entity this)
{
	set_animofs(this, anim_santa_attack, 4, santa_run1); ai_face(this);
	// Anymore projectiles to fire?
	if(this.attack_chance < 30)
	{
		// Is the player still visible?
		if(this.enemy && this.enemy.health > 0 && visible(this, this.enemy))
			this.attack_timer = time + 0.8;
		// Is the enemy in view timer still active?
		if(this.attack_timer > time)
			setthink(this, santa_snow1);
	}	
}
void santa_snow3(entity this) { set_animofs(this, anim_santa_attack, 3, santa_snow4); Santa_FireSnow(this); }
void santa_snow2(entity this) { set_animofs(this, anim_santa_attack, 2, santa_snow3); ai_face(this); }
void santa_snow1(entity this)
{
	set_animofs(this, anim_santa_attack, 1, santa_snow2);
	ai_face(this);
	// First 0.2s is repeatable to get machine gun sound
	_sound(this, CH_WEAPON_SINGLE, "xmas/santa/fire.wav", 1, ATTN_NORM);
}

void santa_snowstart(entity this)
{
	santa_snow1(this);
}

void santa_painA5(entity this) { set_animofs(this, anim_santa_painA, 5, santa_run1); }
void santa_painA4(entity this) { set_animofs(this, anim_santa_painA, 4, santa_painA5); }
void santa_painA3(entity this) { set_animofs(this, anim_santa_painA, 3, santa_painA4); }
void santa_painA2(entity this) { set_animofs(this, anim_santa_painA, 2, santa_painA3); }
void santa_painA1(entity this) { set_animofs(this, anim_santa_painA, 1, santa_painA2); }

//----------------------------------------------------------------------
void santa_painB5(entity this) { set_animofs(this, anim_santa_painB, 5, santa_run1); }
void santa_painB4(entity this) { set_animofs(this, anim_santa_painB, 4, santa_painB5); }
void santa_painB3(entity this) { set_animofs(this, anim_santa_painB, 3, santa_painB4); }
void santa_painB2(entity this) { set_animofs(this, anim_santa_painB, 2, santa_painB3); }
void santa_painB1(entity this) { set_animofs(this, anim_santa_painB, 1, santa_painB2); }

void santa_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.spawnflags & MON_SANTA_GOOD)
		return;
	if(this.pain_finished > time)
		return;
	if(random()*200 > damage)
		return;		// didn't flinch

	if(random() < 0.5)
		_sound(this, CH_VOICE, "xmas/santa/pain1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "xmas/santa/pain2.wav", 1, ATTN_NORM);

	if(random() < 0.5)
	{
		this.pain_finished = time + 1;
		santa_painA1(this);
	}
	else
	{
		this.pain_finished = time + 2;
		santa_painB1(this);
	}
}


void santa_die10(entity this) { set_animofs(this, anim_santa_death, 10, santa_die10); CorpseThink(this); }
void santa_die9(entity this) { set_animofs(this, anim_santa_death, 9, santa_die10); }
void santa_die8(entity this) { set_animofs(this, anim_santa_death, 8, santa_die9); }
void santa_die7(entity this) { set_animofs(this, anim_santa_death, 7, santa_die8); }
void santa_die6(entity this) { set_animofs(this, anim_santa_death, 6, santa_die7); }
void santa_die5(entity this) { set_animofs(this, anim_santa_death, 5, santa_die6); }
void santa_die4(entity this) { set_animofs(this, anim_santa_death, 4, santa_die5); }
void santa_die3(entity this) { set_animofs(this, anim_santa_death, 3, santa_die4); }
void santa_die2(entity this) { set_animofs(this, anim_santa_death, 2, santa_die3); }
void santa_die1(entity this) { set_animofs(this, anim_santa_death, 1, santa_die2); this.solid = SOLID_NOT; }

//----------------------------------------------------------------------
void santa_dieb9(entity this) { set_animofs(this, anim_santa_bdeath, 9, santa_dieb9); CorpseThink(this); }
void santa_dieb8(entity this) { set_animofs(this, anim_santa_bdeath, 8, santa_dieb9); ai_back(this, 4); }
void santa_dieb7(entity this) { set_animofs(this, anim_santa_bdeath, 7, santa_dieb8); }
void santa_dieb6(entity this) { set_animofs(this, anim_santa_bdeath, 6, santa_dieb7); }
void santa_dieb5(entity this) { set_animofs(this, anim_santa_bdeath, 5, santa_dieb6); }
void santa_dieb4(entity this) { set_animofs(this, anim_santa_bdeath, 4, santa_dieb5); }
void santa_dieb3(entity this) { set_animofs(this, anim_santa_bdeath, 3, santa_dieb4); }
void santa_dieb2(entity this) { set_animofs(this, anim_santa_bdeath, 2, santa_dieb3); }
void santa_dieb1(entity this) { set_animofs(this, anim_santa_bdeath, 1, santa_dieb2); this.solid = SOLID_NOT; }

void santa_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(this.spawnflags & MON_SANTA_GOOD)
		return; // TODO: maybe we do need a CorpseThink here to keep stuff from breaking?
// check for gib
	if(this.health < -60)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, inflictor, "progs/xmas/h_santa.mdl", this.health);
		ThrowGib(this, inflictor, "progs/xmas/gib_santagun.mdl", this.health);
		ThrowGib(this, inflictor, "progs/xmas/gib_santasack.mdl", this.health);
		ThrowGib(this, inflictor, "progs/xmas/gib_snowball.mdl", this.health);
		return;
	}

// regular death
	_sound(this, CH_VOICE, "xmas/santa/death2.wav", 1, ATTN_NORM);
	if(random() < 0.5)
		santa_die1(this);
	else
		santa_dieb1(this);
}

/*
===========
SantaCheckAttack

The player is in view, so decide to move or launch an attack
Returns false if movement should continue
============
*/
bool SantaCheckAttack(entity this)
{
	entity targ = this.enemy;

	if(this.enemy_range == RANGE_FAR)
		return false;
	if(time < this.attack_finished)
		return false;

	if(ai_checkmelee(this, 100, 0))
	{
		this.attack_state = AS_MELEE;
		return true;
	}
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, MOVE_NORMAL, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
		return false;	// don't have a clear shot
			
	
// missile attack

	if(this.movespeed < 0)
	{
		// Keep firing rockets when at range
		this.attack_finished = time + 1 + 2 * random();
		this.attack_state = AS_MISSILE;
		return true;
	}

	float chance = 0;
	if(this.enemy_range == RANGE_MELEE)
		chance = 0.9;
	else if(this.enemy_range == RANGE_NEAR)
		chance = 0.4;
	else if(this.enemy_range == RANGE_MID)
		chance = 0.05;

	if(random() < chance && this.th_missile)
	{
		this.th_missile(this);
		this.attack_finished = time + (2 + 2*random());
		return true;
	}

	return false;
}

/*======================================================================
QUAKED monster_santa (1 0 0) (-16 -16 -24) (16 16 40) Ambush
======================================================================*/
spawnfunc(monster_xmas_santa) { monster_start(this, true, MON_SANTA); }
#endif // SVQC

#ifdef SVQC
METHOD(Santa, mr_setup, bool(Santa this, entity actor))
{
    TC(Santa, this);

	precache_model("progs/xmas/gib_santagun.mdl");
	precache_model("progs/xmas/gib_santasack.mdl");
	precache_model("progs/xmas/gib_snowball.mdl");

	precache_model("progs/xmas/proj_snowball.mdl");

	precache_sound("xmas/santa/sack_swing.wav");
	precache_sound("xmas/santa/sack_hit.wav");
	precache_sound("xmas/santa/fire.wav");

	precache_sound("xmas/santa/pain1.wav");
	precache_sound("xmas/santa/pain2.wav");
	precache_sound("xmas/santa/death2.wav");

	if(actor.charmed)
		actor.spawnflags &= ~MON_SANTA_GOOD;

	actor.resist_rockets = actor.resist_cells = 0.5;
	actor.reflectlightning = true;
	actor.reflectplasma = true;

    actor.health = 600;
	actor.th_pain = santa_pain;
	actor.th_die = santa_die;

	actor.steptype = FS_TYPEHEAVY;

	if(actor.spawnflags & MON_SANTA_GOOD)
	{
		precache_sound("xmas/santa/good_hohoho.wav");
		precache_sound("xmas/santa/good_saved.wav");
		if(!actor.message || actor.message == "")
			 actor.message = "You have rescued Santa!\nfrom the claws of hell!\n";
		if(!actor.targetname || actor.targetname == "")
			settouch(actor, santa_freetouch);
		else
			actor.health = 2000;
		actor.resist_shells = actor.resist_nails = 1;
		actor.resist_rockets = actor.resist_cells = 1;
		actor.skin = 1;
		actor.th_stand = santa_seated;
		actor.th_walk = santa_seated;
		actor.th_run = santa_seated;
		actor.waitmin = 0;
	}
	else
	{
		precache_sound("xmas/santa/hohoho.wav");
		precache_sound("xmas/santa/laugh1.wav");
		precache_sound("xmas/santa/laugh3_com.wav");
		actor.checkattack = SantaCheckAttack;
		actor.th_stand = santa_stand1;
		actor.th_walk = santa_walk1;
		actor.th_run = santa_run1;
		actor.th_melee = santa_sack1;
		actor.th_missile = santa_snowstart;
	}

    return true;
}
METHOD(Santa, mr_sight, bool(Santa this, entity actor))
{
    TC(Santa, this);

	if(actor.spawnflags & MON_SANTA_GOOD)
		_sound(actor, CH_VOICE, "xmas/santa/hohoho.wav", 1, ATTN_NORM);
	else
		sound(actor, CH_VOICE, this.m_sound, 1, ATTN_NORM);

    return true;
}
#endif
