/*
==============================================================================

SOLDIER / PLAYER

==============================================================================
*/

$cd id1/models/soldier3
$origin 0 -6 24
$base base		
$skin skin

const int anim_army_stand1 = 0;
const int anim_army_stand2 = 1;
const int anim_army_stand3 = 2;
const int anim_army_stand4 = 3;
const int anim_army_stand5 = 4;
const int anim_army_stand6 = 5;
const int anim_army_stand7 = 6;
const int anim_army_stand8 = 7;

const int anim_army_death1 = 8;
const int anim_army_death2 = 9;
const int anim_army_death3 = 10;
const int anim_army_death4 = 11;
const int anim_army_death5 = 12;
const int anim_army_death6 = 13;
const int anim_army_death7 = 14;
const int anim_army_death8 = 15;
const int anim_army_death9 = 16;
const int anim_army_death10 = 17;

const int anim_army_deathc1 = 18;
const int anim_army_deathc2 = 19;
const int anim_army_deathc3 = 20;
const int anim_army_deathc4 = 21;
const int anim_army_deathc5 = 22;
const int anim_army_deathc6 = 23;
const int anim_army_deathc7 = 24;
const int anim_army_deathc8 = 25;
const int anim_army_deathc9 = 26;
const int anim_army_deathc10 = 27;
const int anim_army_deathc11 = 28;

const int anim_army_load1 = 29;
const int anim_army_load2 = 30;
const int anim_army_load3 = 31;
const int anim_army_load4 = 32;
const int anim_army_load5 = 33;
const int anim_army_load6 = 34;
const int anim_army_load7 = 35;
const int anim_army_load8 = 36;
const int anim_army_load9 = 37;
const int anim_army_load10 = 38;
const int anim_army_load11 = 39;

const int anim_army_pain1 = 40;
const int anim_army_pain2 = 41;
const int anim_army_pain3 = 42;
const int anim_army_pain4 = 43;
const int anim_army_pain5 = 44;
const int anim_army_pain6 = 45;

const int anim_army_painb1 = 46;
const int anim_army_painb2 = 47;
const int anim_army_painb3 = 48;
const int anim_army_painb4 = 49;
const int anim_army_painb5 = 50;
const int anim_army_painb6 = 51;
const int anim_army_painb7 = 52;
const int anim_army_painb8 = 53;
const int anim_army_painb9 = 54;
const int anim_army_painb10 = 55;
const int anim_army_painb11 = 56;
const int anim_army_painb12 = 57;
const int anim_army_painb13 = 58;
const int anim_army_painb14 = 59;

const int anim_army_painc1 = 60;
const int anim_army_painc2 = 61;
const int anim_army_painc3 = 62;
const int anim_army_painc4 = 63;
const int anim_army_painc5 = 64;
const int anim_army_painc6 = 65;
const int anim_army_painc7 = 66;
const int anim_army_painc8 = 67;
const int anim_army_painc9 = 68;
const int anim_army_painc10 = 69;
const int anim_army_painc11 = 70;
const int anim_army_painc12 = 71;
const int anim_army_painc13 = 72;

const int anim_army_run1 = 73;
const int anim_army_run2 = 74;
const int anim_army_run3 = 75;
const int anim_army_run4 = 76;
const int anim_army_run5 = 77;
const int anim_army_run6 = 78;
const int anim_army_run7 = 79;
const int anim_army_run8 = 80;

const int anim_army_shoot1 = 81;
const int anim_army_shoot2 = 82;
const int anim_army_shoot3 = 83;
const int anim_army_shoot4 = 84;
const int anim_army_shoot5 = 85;
const int anim_army_shoot6 = 86;
const int anim_army_shoot7 = 87;
const int anim_army_shoot8 = 88;
const int anim_army_shoot9 = 89;

const int anim_army_prowl_1 = 90;
const int anim_army_prowl_2 = 91;
const int anim_army_prowl_3 = 92;
const int anim_army_prowl_4 = 93;
const int anim_army_prowl_5 = 94;
const int anim_army_prowl_6 = 95;
const int anim_army_prowl_7 = 96;
const int anim_army_prowl_8 = 97;
const int anim_army_prowl_9 = 98;
const int anim_army_prowl_10 = 99;
const int anim_army_prowl_11 = 100;
const int anim_army_prowl_12 = 101;
const int anim_army_prowl_13 = 102;
const int anim_army_prowl_14 = 103;
const int anim_army_prowl_15 = 104;
const int anim_army_prowl_16 = 105;
const int anim_army_prowl_17 = 106;
const int anim_army_prowl_18 = 107;
const int anim_army_prowl_19 = 108;
const int anim_army_prowl_20 = 109;
const int anim_army_prowl_21 = 110;
const int anim_army_prowl_22 = 111;
const int anim_army_prowl_23 = 112;
const int anim_army_prowl_24 = 113;

/*
==============================================================================
SOLDIER CODE
==============================================================================
*/

void army_stand1(entity this);
void army_stand8(entity this) { set_anim(this, anim_army_stand8, army_stand1); ai_stand(this); }
void army_stand7(entity this) { set_anim(this, anim_army_stand7, army_stand8); ai_stand(this); }
void army_stand6(entity this) { set_anim(this, anim_army_stand6, army_stand7); ai_stand(this); }
void army_stand5(entity this) { set_anim(this, anim_army_stand5, army_stand6); ai_stand(this); }
void army_stand4(entity this) { set_anim(this, anim_army_stand4, army_stand5); ai_stand(this); }
void army_stand3(entity this) { set_anim(this, anim_army_stand3, army_stand4); ai_stand(this); }
void army_stand2(entity this) { set_anim(this, anim_army_stand2, army_stand3); ai_stand(this); }
void army_stand1(entity this) { set_anim(this, anim_army_stand1, army_stand2); ai_stand(this); }

void army_walk1(entity this);
void army_walk24(entity this) { set_anim(this, anim_army_prowl_24, army_walk1); ai_walk(this, 1); }
void army_walk23(entity this) { set_anim(this, anim_army_prowl_23, army_walk24); ai_walk(this, 1); }
void army_walk22(entity this) { set_anim(this, anim_army_prowl_22, army_walk23); ai_walk(this, 1); }
void army_walk21(entity this) { set_anim(this, anim_army_prowl_21, army_walk22); ai_walk(this, 2); }
void army_walk20(entity this) { set_anim(this, anim_army_prowl_20, army_walk21); ai_walk(this, 3); }
void army_walk19(entity this) { set_anim(this, anim_army_prowl_19, army_walk20); ai_walk(this, 3); }
void army_walk18(entity this) { set_anim(this, anim_army_prowl_18, army_walk19); ai_walk(this, 3); }
void army_walk17(entity this) { set_anim(this, anim_army_prowl_17, army_walk18); ai_walk(this, 3); }
void army_walk16(entity this) { set_anim(this, anim_army_prowl_16, army_walk17); ai_walk(this, 1); }
void army_walk15(entity this) { set_anim(this, anim_army_prowl_15, army_walk16); ai_walk(this, 1); }
void army_walk14(entity this) { set_anim(this, anim_army_prowl_14, army_walk15); ai_walk(this, 1); }
void army_walk13(entity this) { set_anim(this, anim_army_prowl_13, army_walk14); ai_walk(this, 0); }
void army_walk12(entity this) { set_anim(this, anim_army_prowl_12, army_walk13); ai_walk(this, 1); }
void army_walk11(entity this) { set_anim(this, anim_army_prowl_11, army_walk12); ai_walk(this, 2); }
void army_walk10(entity this) { set_anim(this, anim_army_prowl_10, army_walk11); ai_walk(this, 2); }
void army_walk9(entity this) { set_anim(this, anim_army_prowl_9, army_walk10); ai_walk(this, 2); }
void army_walk8(entity this) { set_anim(this, anim_army_prowl_8, army_walk9); ai_walk(this, 4); }
void army_walk7(entity this) { set_anim(this, anim_army_prowl_7, army_walk8); ai_walk(this, 4); }
void army_walk6(entity this) { set_anim(this, anim_army_prowl_6, army_walk7); ai_walk(this, 3); }
void army_walk5(entity this) { set_anim(this, anim_army_prowl_5, army_walk6); ai_walk(this, 2); }
void army_walk4(entity this) { set_anim(this, anim_army_prowl_4, army_walk5); ai_walk(this, 1); }
void army_walk3(entity this) { set_anim(this, anim_army_prowl_3, army_walk4); ai_walk(this, 1); }
void army_walk2(entity this) { set_anim(this, anim_army_prowl_2, army_walk3); ai_walk(this, 1); }
void army_walk1(entity this)
{
	set_anim(this, anim_army_prowl_1, army_walk2);
	if(random() < 0.2)
		_sound(this, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
	ai_walk(this, 1);
}

void army_run1(entity this);
void army_run8(entity this) { set_anim(this, anim_army_run8, army_run1); ai_run(this, 8); }
void army_run7(entity this) { set_anim(this, anim_army_run7, army_run8); ai_run(this, 10); }
void army_run6(entity this) { set_anim(this, anim_army_run6, army_run7); ai_run(this, 15); }
void army_run5(entity this) { set_anim(this, anim_army_run5, army_run6); ai_run(this, 8); }
void army_run4(entity this) { set_anim(this, anim_army_run4, army_run5); ai_run(this, 10); }
void army_run3(entity this) { set_anim(this, anim_army_run3, army_run4); ai_run(this, 10); }
void army_run2(entity this) { set_anim(this, anim_army_run2, army_run3); ai_run(this, 15); }
void army_run1(entity this)
{
	set_anim(this, anim_army_run1, army_run2);
	if(random() < 0.2)
		_sound(this, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
	ai_run(this, 11);
}

void army_fire(entity this);

void army_atk1(entity this);
void army_atk9(entity this) { set_anim(this, anim_army_shoot8, army_run1); ai_face(this); }
void army_atk8(entity this) { set_anim(this, anim_army_shoot8, army_atk9); ai_face(this); }
void army_atk7(entity this) { set_anim(this, anim_army_shoot7, army_atk8); ai_face(this); SUB_CheckRefire(this, army_atk1); }
void army_atk6(entity this) { set_anim(this, anim_army_shoot6, army_atk7); ai_face(this); }
void army_atk5(entity this)
{
	set_anim(this, anim_army_shoot5, army_atk6);
	ai_face(this);
	army_fire(this);
	this.effects |= EF_MUZZLEFLASH;
}
void army_atk4(entity this) { set_anim(this, anim_army_shoot4, army_atk5); ai_face(this); }
void army_atk3(entity this) { set_anim(this, anim_army_shoot3, army_atk4); ai_face(this); }
void army_atk2(entity this) { set_anim(this, anim_army_shoot2, army_atk3); ai_face(this); }
void army_atk1(entity this) { set_anim(this, anim_army_shoot1, army_atk2); ai_face(this); }

void army_pain6(entity this) { set_anim(this, anim_army_pain6, army_run1); ai_pain(this, 1); }
void army_pain5(entity this) { set_anim(this, anim_army_pain5, army_pain6); }
void army_pain4(entity this) { set_anim(this, anim_army_pain4, army_pain5); }
void army_pain3(entity this) { set_anim(this, anim_army_pain3, army_pain4); }
void army_pain2(entity this) { set_anim(this, anim_army_pain2, army_pain3); }
void army_pain1(entity this) { set_anim(this, anim_army_pain1, army_pain2); }

void army_painb14(entity this) { set_anim(this, anim_army_painb14, army_run1); }
void army_painb13(entity this) { set_anim(this, anim_army_painb13, army_painb14); }
void army_painb12(entity this) { set_anim(this, anim_army_painb12, army_painb13); ai_pain(this, 2); }
void army_painb11(entity this) { set_anim(this, anim_army_painb11, army_painb12); }
void army_painb10(entity this) { set_anim(this, anim_army_painb10, army_painb11); }
void army_painb9(entity this) { set_anim(this, anim_army_painb9, army_painb10); }
void army_painb8(entity this) { set_anim(this, anim_army_painb8, army_painb9); }
void army_painb7(entity this) { set_anim(this, anim_army_painb7, army_painb8); }
void army_painb6(entity this) { set_anim(this, anim_army_painb6, army_painb7); }
void army_painb5(entity this) { set_anim(this, anim_army_painb5, army_painb6); }
void army_painb4(entity this) { set_anim(this, anim_army_painb4, army_painb5); }
void army_painb3(entity this) { set_anim(this, anim_army_painb3, army_painb4); ai_painforward(this, 9); }
void army_painb2(entity this) { set_anim(this, anim_army_painb2, army_painb3); ai_painforward(this, 13); }
void army_painb1(entity this) { set_anim(this, anim_army_painb1, army_painb2); }

void army_painc13(entity this) { set_anim(this, anim_army_painc13, army_run1); }
void army_painc12(entity this) { set_anim(this, anim_army_painc12, army_painc13); ai_painforward(this, 8); }
void army_painc11(entity this) { set_anim(this, anim_army_painc11, army_painc12); ai_painforward(this, 6); }
void army_painc10(entity this) { set_anim(this, anim_army_painc10, army_painc11); ai_painforward(this, 3); }
void army_painc9(entity this) { set_anim(this, anim_army_painc9, army_painc10); ai_painforward(this, 4); }
void army_painc8(entity this) { set_anim(this, anim_army_painc8, army_painc9); ai_pain(this, 1); }
void army_painc7(entity this) { set_anim(this, anim_army_painc7, army_painc8); }
void army_painc6(entity this) { set_anim(this, anim_army_painc6, army_painc7); ai_painforward(this, 1); }
void army_painc5(entity this) { set_anim(this, anim_army_painc5, army_painc6); ai_painforward(this, 1); }
void army_painc4(entity this) { set_anim(this, anim_army_painc4, army_painc5); }
void army_painc3(entity this) { set_anim(this, anim_army_painc3, army_painc4); }
void army_painc2(entity this) { set_anim(this, anim_army_painc2, army_painc3); ai_pain(this, 1); }
void army_painc1(entity this) { set_anim(this, anim_army_painc1, army_painc2); }

void army_pain(entity this, entity attacker, float damage)
{
	if(this.pain_finished > time)
		return;

	float r = random();

	if(r < 0.2)
	{
		this.pain_finished = time + 0.6;
		army_pain1(this);
		_sound(this, CHAN_VOICE, "soldier/pain1.wav", 1, ATTN_NORM);
	}
	else if(r < 0.6)
	{
		this.pain_finished = time + 1.1;
		army_painb1(this);
		_sound(this, CHAN_VOICE, "soldier/pain2.wav", 1, ATTN_NORM);
	}
	else
	{
		this.pain_finished = time + 1.1;
		army_painc1(this);
		_sound(this, CHAN_VOICE, "soldier/pain2.wav", 1, ATTN_NORM);
	}
}


void army_fire(entity this)
{
	ai_face(this);
	
	_sound(this, CHAN_WEAPON, "soldier/sattck1.wav", 1, ATTN_NORM);	

// fire somewhat behind the player, so a dodging player is harder to hit
	entity en = this.enemy;
	
	vector dir = en.origin - en.velocity*0.2;
	dir = normalize(dir - this.origin);
	
	FireBullets(this, 4, dir, '0.1 0.1 0');
}


void army_die10(entity this) { set_anim(this, anim_army_death10, army_die10); }
void army_die9(entity this) { set_anim(this, anim_army_death9, army_die10); }
void army_die8(entity this) { set_anim(this, anim_army_death8, army_die9); }
void army_die7(entity this) { set_anim(this, anim_army_death7, army_die8); }
void army_die6(entity this) { set_anim(this, anim_army_death6, army_die7); }
void army_die5(entity this) { set_anim(this, anim_army_death5, army_die6); }
void army_die4(entity this) { set_anim(this, anim_army_death4, army_die5); }
void army_die3(entity this)
{
	set_anim(this, anim_army_death3, army_die4);
	this.solid = SOLID_NOT;
	this.ammo_shells = 5;
	DropBackpack(this);
}
void army_die2(entity this) { set_anim(this, anim_army_death2, army_die3); }
void army_die1(entity this) { set_anim(this, anim_army_death1, army_die2); }

void army_cdie11(entity this) { set_anim(this, anim_army_deathc11, army_cdie11); }
void army_cdie10(entity this) { set_anim(this, anim_army_deathc10, army_cdie11); }
void army_cdie9(entity this) { set_anim(this, anim_army_deathc9, army_cdie10); }
void army_cdie8(entity this) { set_anim(this, anim_army_deathc8, army_cdie9); }
void army_cdie7(entity this) { set_anim(this, anim_army_deathc7, army_cdie8); }
void army_cdie6(entity this) { set_anim(this, anim_army_deathc6, army_cdie7); ai_back(this, 4); }
void army_cdie5(entity this) { set_anim(this, anim_army_deathc5, army_cdie6); ai_back(this, 3); }
void army_cdie4(entity this) { set_anim(this, anim_army_deathc4, army_cdie5); ai_back(this, 13); }
void army_cdie3(entity this)
{
	set_anim(this, anim_army_deathc3, army_cdie4);
	this.solid = SOLID_NOT;
	this.ammo_shells = 5;
	DropBackpack(this);
	ai_back(this, 4);
}
void army_cdie2(entity this) { set_anim(this, anim_army_deathc2, army_cdie3); ai_back(this, 5); }
void army_cdie1(entity this) { set_anim(this, anim_army_deathc1, army_cdie2); }

void army_die(entity this, entity attacker)
{
// check for gib
	if(this.health < -35)
	{
		_sound(this, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, "progs/h_guard.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib2.mdl", this.health);
		ThrowGib(this, "progs/gib3.mdl", this.health);
		return;
	}

// regular death
	_sound(this, CHAN_VOICE, "soldier/death1.wav", 1, ATTN_NORM);
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
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, false, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
		return false;	// don't have a clear shot
			
	
// missile attack
	if(time < this.attack_finished)
		return false;
		
	if(this.enemy_range == RANGE_FAR)
		return false;

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
		SUB_AttackFinished(this, 1 + random());
		if(random() < 0.3)
			this.lefty = !this.lefty;

		return true;
	}

	return false;
}

string army_sight(entity this) { return "soldier/sight1.wav"; }
string army_deathmessage(entity this) { return "was shot by a Grunt"; }

/*QUAKED monster_army(1 0 0)(-16 -16 -24)(16 16 40) Ambush
*/
spawnfunc(monster_army)
{	
	if(deathmatch)
	{
		delete(this);
		return;
	}
	precache_model("progs/soldier.mdl");
	precache_model("progs/h_guard.mdl");
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


	this.solid = SOLID_SLIDEBOX;
	this.movetype = MOVETYPE_STEP;

	_setmodel(this, "progs/soldier.mdl");

	setsize(this, '-16 -16 -24', '16 16 40');
	this.health = 30;

	this.th_stand = army_stand1;
	this.th_walk = army_walk1;
	this.th_run = army_run1;
	this.th_missile = army_atk1;
	this.th_pain = army_pain;
	this.th_die = army_die;

	this.sightsound = army_sight;
	this.checkattack = SoldierCheckAttack;
	this.deathmessage = army_deathmessage;

	walkmonster_start(this);
}
