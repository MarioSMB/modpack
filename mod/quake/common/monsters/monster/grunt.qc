#include "grunt.qh"

#ifdef SVQC
const int anim_army_stand = 0; //'0 14 0'
const int anim_army_death = 8; //'8 17 0'
const int anim_army_deathc = 18; //'18 28 0'
const int anim_army_load = 29; //'29 39 0'
const int anim_army_pain = 40; //'40 45 0'
const int anim_army_painb = 46; //'46 59 0'
const int anim_army_painc = 60; //'60 72 0'
const int anim_army_run = 73; //'73 80 0'
const int anim_army_shoot = 81; //'81 191 0'
const int anim_army_prowl = 90; //'90 113 0'

/*
==============================================================================
SOLDIER CODE
==============================================================================
*/

void army_stand1(entity this);
void army_stand8(entity this) { set_animofs(this, anim_army_stand, 8, army_stand1); ai_stand(this); }
void army_stand7(entity this) { set_animofs(this, anim_army_stand, 7, army_stand8); ai_stand(this); }
void army_stand6(entity this) { set_animofs(this, anim_army_stand, 6, army_stand7); ai_stand(this); }
void army_stand5(entity this) { set_animofs(this, anim_army_stand, 5, army_stand6); ai_stand(this); }
void army_stand4(entity this) { set_animofs(this, anim_army_stand, 4, army_stand5); ai_stand(this); }
void army_stand3(entity this) { set_animofs(this, anim_army_stand, 3, army_stand4); ai_stand(this); }
void army_stand2(entity this) { set_animofs(this, anim_army_stand, 2, army_stand3); ai_stand(this); }
void army_stand1(entity this) { set_animofs(this, anim_army_stand, 1, army_stand2); ai_stand(this); }

void army_walk1(entity this);
void army_walk24(entity this) { set_animofs(this, anim_army_prowl, 24, army_walk1); ai_walk(this, 1); }
void army_walk23(entity this) { set_animofs(this, anim_army_prowl, 23, army_walk24); ai_walk(this, 1); }
void army_walk22(entity this) { set_animofs(this, anim_army_prowl, 22, army_walk23); ai_walk(this, 1); }
void army_walk21(entity this) { set_animofs(this, anim_army_prowl, 21, army_walk22); ai_walk(this, 2); }
void army_walk20(entity this) { set_animofs(this, anim_army_prowl, 20, army_walk21); ai_walk(this, 3); }
void army_walk19(entity this) { set_animofs(this, anim_army_prowl, 19, army_walk20); ai_walk(this, 3); }
void army_walk18(entity this) { set_animofs(this, anim_army_prowl, 18, army_walk19); ai_walk(this, 3); }
void army_walk17(entity this) { set_animofs(this, anim_army_prowl, 17, army_walk18); ai_walk(this, 3); }
void army_walk16(entity this) { set_animofs(this, anim_army_prowl, 16, army_walk17); ai_walk(this, 1); }
void army_walk15(entity this) { set_animofs(this, anim_army_prowl, 15, army_walk16); ai_walk(this, 1); }
void army_walk14(entity this) { set_animofs(this, anim_army_prowl, 14, army_walk15); ai_walk(this, 1); }
void army_walk13(entity this) { set_animofs(this, anim_army_prowl, 13, army_walk14); ai_walk(this, 0); }
void army_walk12(entity this) { set_animofs(this, anim_army_prowl, 12, army_walk13); ai_walk(this, 1); }
void army_walk11(entity this) { set_animofs(this, anim_army_prowl, 11, army_walk12); ai_walk(this, 2); }
void army_walk10(entity this) { set_animofs(this, anim_army_prowl, 10, army_walk11); ai_walk(this, 2); }
void army_walk9(entity this) { set_animofs(this, anim_army_prowl, 9, army_walk10); ai_walk(this, 2); }
void army_walk8(entity this) { set_animofs(this, anim_army_prowl, 8, army_walk9); ai_walk(this, 4); }
void army_walk7(entity this) { set_animofs(this, anim_army_prowl, 7, army_walk8); ai_walk(this, 4); }
void army_walk6(entity this) { set_animofs(this, anim_army_prowl, 6, army_walk7); ai_walk(this, 3); }
void army_walk5(entity this) { set_animofs(this, anim_army_prowl, 5, army_walk6); ai_walk(this, 2); }
void army_walk4(entity this) { set_animofs(this, anim_army_prowl, 4, army_walk5); ai_walk(this, 1); }
void army_walk3(entity this) { set_animofs(this, anim_army_prowl, 3, army_walk4); ai_walk(this, 1); }
void army_walk2(entity this) { set_animofs(this, anim_army_prowl, 2, army_walk3); ai_walk(this, 1); }
void army_walk1(entity this)
{
	set_animofs(this, anim_army_prowl, 1, army_walk2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
	ai_walk(this, 1);
}

void army_run1(entity this);
void army_run8(entity this) { set_animofs(this, anim_army_run, 8, army_run1); ai_run(this, 8); }
void army_run7(entity this) { set_animofs(this, anim_army_run, 7, army_run8); ai_run(this, 10); }
void army_run6(entity this) { set_animofs(this, anim_army_run, 6, army_run7); ai_run(this, 15); }
void army_run5(entity this) { set_animofs(this, anim_army_run, 5, army_run6); ai_run(this, 8); }
void army_run4(entity this) { set_animofs(this, anim_army_run, 4, army_run5); ai_run(this, 10); }
void army_run3(entity this) { set_animofs(this, anim_army_run, 3, army_run4); ai_run(this, 10); }
void army_run2(entity this) { set_animofs(this, anim_army_run, 2, army_run3); ai_run(this, 15); }
void army_run1(entity this)
{
	set_animofs(this, anim_army_run, 1, army_run2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
	ai_run(this, 11);
}

void army_fire(entity this);

void army_atk1(entity this);
void army_atk9(entity this) { set_animofs(this, anim_army_shoot, 8, army_run1); ai_face(this); }
void army_atk8(entity this) { set_animofs(this, anim_army_shoot, 8, army_atk9); ai_face(this); }
void army_atk7(entity this)
{
	set_animofs(this, anim_army_shoot, 7, army_atk8);
	ai_face(this);
}
void army_atk6(entity this) { set_animofs(this, anim_army_shoot, 6, army_atk7); ai_face(this); }
void army_atk5(entity this)
{
	set_animofs(this, anim_army_shoot, 5, army_atk6);
	ai_face(this);
	army_fire(this);
	this.effects |= EF_MUZZLEFLASH;
}
void army_atk4(entity this) { set_animofs(this, anim_army_shoot, 4, army_atk5); ai_face(this); }
void army_atk3(entity this) { set_animofs(this, anim_army_shoot, 3, army_atk4); ai_face(this); }
void army_atk2(entity this) { set_animofs(this, anim_army_shoot, 2, army_atk3); ai_face(this); }
void army_atk1(entity this) { set_animofs(this, anim_army_shoot, 1, army_atk2); ai_face(this); }

void army_pain6(entity this) { set_animofs(this, anim_army_pain, 6, army_run1); ai_pain(this, 1); }
void army_pain5(entity this) { set_animofs(this, anim_army_pain, 5, army_pain6); }
void army_pain4(entity this) { set_animofs(this, anim_army_pain, 4, army_pain5); }
void army_pain3(entity this) { set_animofs(this, anim_army_pain, 3, army_pain4); }
void army_pain2(entity this) { set_animofs(this, anim_army_pain, 2, army_pain3); }
void army_pain1(entity this) { set_animofs(this, anim_army_pain, 1, army_pain2); }

void army_painb14(entity this) { set_animofs(this, anim_army_painb, 14, army_run1); }
void army_painb13(entity this) { set_animofs(this, anim_army_painb, 13, army_painb14); }
void army_painb12(entity this) { set_animofs(this, anim_army_painb, 12, army_painb13); ai_pain(this, 2); }
void army_painb11(entity this) { set_animofs(this, anim_army_painb, 11, army_painb12); }
void army_painb10(entity this) { set_animofs(this, anim_army_painb, 10, army_painb11); }
void army_painb9(entity this) { set_animofs(this, anim_army_painb, 9, army_painb10); }
void army_painb8(entity this) { set_animofs(this, anim_army_painb, 8, army_painb9); }
void army_painb7(entity this) { set_animofs(this, anim_army_painb, 7, army_painb8); }
void army_painb6(entity this) { set_animofs(this, anim_army_painb, 6, army_painb7); }
void army_painb5(entity this) { set_animofs(this, anim_army_painb, 5, army_painb6); }
void army_painb4(entity this) { set_animofs(this, anim_army_painb, 4, army_painb5); }
void army_painb3(entity this) { set_animofs(this, anim_army_painb, 3, army_painb4); ai_painforward(this, 9); }
void army_painb2(entity this) { set_animofs(this, anim_army_painb, 2, army_painb3); ai_painforward(this, 13); }
void army_painb1(entity this) { set_animofs(this, anim_army_painb, 1, army_painb2); }

void army_painc13(entity this) { set_animofs(this, anim_army_painc, 13, army_run1); }
void army_painc12(entity this) { set_animofs(this, anim_army_painc, 12, army_painc13); ai_painforward(this, 8); }
void army_painc11(entity this) { set_animofs(this, anim_army_painc, 11, army_painc12); ai_painforward(this, 6); }
void army_painc10(entity this) { set_animofs(this, anim_army_painc, 10, army_painc11); ai_painforward(this, 3); }
void army_painc9(entity this) { set_animofs(this, anim_army_painc, 9, army_painc10); ai_painforward(this, 4); }
void army_painc8(entity this) { set_animofs(this, anim_army_painc, 8, army_painc9); ai_pain(this, 1); }
void army_painc7(entity this) { set_animofs(this, anim_army_painc, 7, army_painc8); }
void army_painc6(entity this) { set_animofs(this, anim_army_painc, 6, army_painc7); ai_painforward(this, 1); }
void army_painc5(entity this) { set_animofs(this, anim_army_painc, 5, army_painc6); ai_painforward(this, 1); }
void army_painc4(entity this) { set_animofs(this, anim_army_painc, 4, army_painc5); }
void army_painc3(entity this) { set_animofs(this, anim_army_painc, 3, army_painc4); }
void army_painc2(entity this) { set_animofs(this, anim_army_painc, 2, army_painc3); ai_pain(this, 1); }
void army_painc1(entity this) { set_animofs(this, anim_army_painc, 1, army_painc2); }

void army_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	float r = random();

	if(r < 0.2)
	{
		this.pain_finished = time + 0.6;
		army_pain1(this);
		_sound(this, CH_VOICE, "soldier/pain1.wav", 1, ATTN_NORM);
	}
	else if(r < 0.6)
	{
		this.pain_finished = time + 1.1;
		army_painb1(this);
		_sound(this, CH_VOICE, "soldier/pain2.wav", 1, ATTN_NORM);
	}
	else
	{
		this.pain_finished = time + 1.1;
		army_painc1(this);
		_sound(this, CH_VOICE, "soldier/pain2.wav", 1, ATTN_NORM);
	}
}


void army_fire(entity this)
{
	ai_face(this);
	
	_sound(this, CH_WEAPON_SINGLE, "soldier/sattck1.wav", 1, ATTN_NORM);	

// fire somewhat behind the player, so a dodging player is harder to hit
	entity en = this.enemy;
	
	vector dir = en.origin - en.velocity*0.2;
	dir = normalize(dir - this.origin);
	
	FireBullets(this, 4, dir, '0.1 0.1 0', DEATH_MONSTER_GRUNT.m_id);
}


void army_die10(entity this)
{
	set_animofs(this, anim_army_death, 10, army_die10);
	CorpseThink(this);
}
void army_die9(entity this) { set_animofs(this, anim_army_death, 9, army_die10); }
void army_die8(entity this) { set_animofs(this, anim_army_death, 8, army_die9); }
void army_die7(entity this) { set_animofs(this, anim_army_death, 7, army_die8); }
void army_die6(entity this) { set_animofs(this, anim_army_death, 6, army_die7); }
void army_die5(entity this) { set_animofs(this, anim_army_death, 5, army_die6); }
void army_die4(entity this) { set_animofs(this, anim_army_death, 4, army_die5); }
void army_die3(entity this)
{
	set_animofs(this, anim_army_death, 3, army_die4);
	this.solid = SOLID_NOT;
	this.ammo_shells = 5;
	DropBackpack(this);
}
void army_die2(entity this) { set_animofs(this, anim_army_death, 2, army_die3); }
void army_die1(entity this) { set_animofs(this, anim_army_death, 1, army_die2); }

void army_cdie11(entity this)
{
	set_animofs(this, anim_army_deathc, 11, army_cdie11);
	CorpseThink(this);
}
void army_cdie10(entity this) { set_animofs(this, anim_army_deathc, 10, army_cdie11); }
void army_cdie9(entity this) { set_animofs(this, anim_army_deathc, 9, army_cdie10); }
void army_cdie8(entity this) { set_animofs(this, anim_army_deathc, 8, army_cdie9); }
void army_cdie7(entity this) { set_animofs(this, anim_army_deathc, 7, army_cdie8); }
void army_cdie6(entity this) { set_animofs(this, anim_army_deathc, 6, army_cdie7); ai_back(this, 4); }
void army_cdie5(entity this) { set_animofs(this, anim_army_deathc, 5, army_cdie6); ai_back(this, 3); }
void army_cdie4(entity this) { set_animofs(this, anim_army_deathc, 4, army_cdie5); ai_back(this, 13); }
void army_cdie3(entity this)
{
	set_animofs(this, anim_army_deathc, 3, army_cdie4);
	this.solid = SOLID_NOT;
	this.ammo_shells = 5;
	DropBackpack(this);
	ai_back(this, 4);
}
void army_cdie2(entity this) { set_animofs(this, anim_army_deathc, 2, army_cdie3); ai_back(this, 5); }
void army_cdie1(entity this) { set_animofs(this, anim_army_deathc, 1, army_cdie2); }

void army_die(entity this, entity inflictor, entity attacker, int deathtype)
{
// check for gib
	if(this.health < -35)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, "progs/h_guard.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib2.mdl", this.health);
		ThrowGib(this, "progs/gib3.mdl", this.health);
		return;
	}

// regular death
	_sound(this, CH_VOICE, "soldier/death1.wav", 1, ATTN_NORM);
	if(random() < 0.5)
		army_die1(this);
	else
		army_cdie1(this);
}

/*
===========
SoldierCheckAttack

The player is in view, so decide to move or launch an attack
Returns false if movement should continue
============
*/
bool SoldierCheckAttack(entity this)
{
	entity targ = this.enemy;

	if(MP_IMPEL)
	{
		if(this.enemy_range == RANGE_FAR)
			return false;
		if(time < this.attack_finished)
			return false;
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
	if(!MP_IMPEL)
	{
		if(time < this.attack_finished)
			return false;
			
		if(this.enemy_range == RANGE_FAR)
			return false;
	}

	float chance = 0;
	if(this.enemy_range == RANGE_MELEE)
		chance = 0.9;
	else if(this.enemy_range == RANGE_NEAR)
		chance = 0.4;
	else if(this.enemy_range == RANGE_MID)
		chance = 0.05;

	if(random() < chance)
	{
		this.th_missile(this);
		this.attack_finished = time + (1 * random());
		if(random() < 0.3)
			this.lefty = !this.lefty;

		return true;
	}

	return false;
}

string army_sight(entity this) { return "soldier/sight1.wav"; }

/*QUAKED monster_army(1 0 0)(-16 -16 -24)(16 16 40) Ambush
*/
spawnfunc(monster_army) { monster_start(this, MON_GRUNT); }
#endif // SVQC

#ifdef SVQC
METHOD(Grunt, mr_setup, bool(Grunt this, entity actor))
{
    TC(Grunt, this);

	precache_model("progs/gib1.mdl");
	precache_model("progs/gib2.mdl");
	precache_model("progs/gib3.mdl");

	precache_sound("soldier/death1.wav");
	precache_sound("soldier/idle.wav");
	precache_sound("soldier/pain1.wav");
	precache_sound("soldier/pain2.wav");
	precache_sound("soldier/sattck1.wav");
	precache_sound("soldier/sight1.wav");

	precache_sound("player/udeath.wav");		// gib death

    actor.health = 30;
    actor.th_stand = army_stand1;
	actor.th_walk = army_walk1;
	actor.th_run = army_run1;
	actor.th_missile = army_atk1;
	actor.th_pain = army_pain;
	actor.th_die = army_die;

	actor.sightsound = army_sight;
	actor.checkattack = SoldierCheckAttack;

    return true;
}
#endif
