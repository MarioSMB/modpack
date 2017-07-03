/*
==============================================================================

SOLDIER / PLAYER

==============================================================================
*/

$cd id1/models/enforcer
$origin 0 -6 24
$base base		
$skin skin

const int anim_enf_stand1 = 0;
const int anim_enf_stand2 = 1;
const int anim_enf_stand3 = 2;
const int anim_enf_stand4 = 3;
const int anim_enf_stand5 = 4;
const int anim_enf_stand6 = 5;
const int anim_enf_stand7 = 6;

const int anim_enf_walk1 = 7;
const int anim_enf_walk2 = 8;
const int anim_enf_walk3 = 9;
const int anim_enf_walk4 = 10;
const int anim_enf_walk5 = 11;
const int anim_enf_walk6 = 12;
const int anim_enf_walk7 = 13;
const int anim_enf_walk8 = 14;
const int anim_enf_walk9 = 15;
const int anim_enf_walk10 = 16;
const int anim_enf_walk11 = 17;
const int anim_enf_walk12 = 18;
const int anim_enf_walk13 = 19;
const int anim_enf_walk14 = 20;
const int anim_enf_walk15 = 21;
const int anim_enf_walk16 = 22;

const int anim_enf_run1 = 23;
const int anim_enf_run2 = 24;
const int anim_enf_run3 = 25;
const int anim_enf_run4 = 26;
const int anim_enf_run5 = 27;
const int anim_enf_run6 = 28;
const int anim_enf_run7 = 29;
const int anim_enf_run8 = 30;

const int anim_enf_attack1 = 31;
const int anim_enf_attack2 = 32;
const int anim_enf_attack3 = 33;
const int anim_enf_attack4 = 34;
const int anim_enf_attack5 = 35;
const int anim_enf_attack6 = 36;
const int anim_enf_attack7 = 37;
const int anim_enf_attack8 = 38;
const int anim_enf_attack9 = 39;
const int anim_enf_attack10 = 40;

const int anim_enf_death1 = 41;
const int anim_enf_death2 = 42;
const int anim_enf_death3 = 43;
const int anim_enf_death4 = 44;
const int anim_enf_death5 = 45;
const int anim_enf_death6 = 46;
const int anim_enf_death7 = 47;
const int anim_enf_death8 = 48;
const int anim_enf_death9 = 49;
const int anim_enf_death10 = 50;
const int anim_enf_death11 = 51;
const int anim_enf_death12 = 52;
const int anim_enf_death13 = 53;
const int anim_enf_death14 = 54;

const int anim_enf_fdeath1 = 55;
const int anim_enf_fdeath2 = 56;
const int anim_enf_fdeath3 = 57;
const int anim_enf_fdeath4 = 58;
const int anim_enf_fdeath5 = 59;
const int anim_enf_fdeath6 = 60;
const int anim_enf_fdeath7 = 61;
const int anim_enf_fdeath8 = 62;
const int anim_enf_fdeath9 = 63;
const int anim_enf_fdeath10 = 64;
const int anim_enf_fdeath11 = 65;

const int anim_enf_paina1 = 66;
const int anim_enf_paina2 = 67;
const int anim_enf_paina3 = 68;
const int anim_enf_paina4 = 69;

const int anim_enf_painb1 = 70;
const int anim_enf_painb2 = 71;
const int anim_enf_painb3 = 72;
const int anim_enf_painb4 = 73;
const int anim_enf_painb5 = 74;

const int anim_enf_painc1 = 75;
const int anim_enf_painc2 = 76;
const int anim_enf_painc3 = 77;
const int anim_enf_painc4 = 78;
const int anim_enf_painc5 = 79;
const int anim_enf_painc6 = 80;
const int anim_enf_painc7 = 81;
const int anim_enf_painc8 = 82;

const int anim_enf_paind1 = 83;
const int anim_enf_paind2 = 84;
const int anim_enf_paind3 = 85;
const int anim_enf_paind4 = 86;
const int anim_enf_paind5 = 87;
const int anim_enf_paind6 = 88;
const int anim_enf_paind7 = 89;
const int anim_enf_paind8 = 90;
const int anim_enf_paind9 = 91;
const int anim_enf_paind10 = 92;
const int anim_enf_paind11 = 93;
const int anim_enf_paind12 = 94;
const int anim_enf_paind13 = 95;
const int anim_enf_paind14 = 96;
const int anim_enf_paind15 = 97;
const int anim_enf_paind16 = 98;
const int anim_enf_paind17 = 99;
const int anim_enf_paind18 = 100;
const int anim_enf_paind19 = 101;

void Laser_Touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
	_sound(this, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	vector org = this.origin - 8*normalize(this.velocity);

	if(toucher.health)
	{
		SpawnBlood(org, this.velocity*0.2, 15);
		T_Damage(toucher, this, this.owner, 15);
	}
	else
		te_gunshot(org);
	
	delete(this);	
}

void LaunchLaser(entity this, vector org, vector vec)
{
	if(this.classname == "monster_enforcer")
		_sound(this, CHAN_WEAPON, "enforcer/enfire.wav", 1, ATTN_NORM);

	vector vec2 = normalize(vec);
	
	entity newmis = spawn();
	newmis.owner = this;
	set_movetype(newmis, MOVETYPE_FLY);
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;

	_setmodel(newmis, "progs/laser.mdl");
	setsize(newmis, '0 0 0', '0 0 0');		

	setorigin(newmis, org);

	newmis.velocity = vec2 * 600;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 5;
	setthink(newmis, SUB_Remove);
	settouch(newmis, Laser_Touch);
}

void enforcer_fire(entity this)
{
	this.effects |= EF_MUZZLEFLASH;
	makevectors(this.angles);
	
	vector org = this.origin + v_forward * 30 + v_right * 8.5 + '0 0 16';

	LaunchLaser(this, org, this.enemy.origin - this.origin);
}

//============================================================================

void enf_stand1(entity this);
void enf_stand7(entity this) { set_anim(this, anim_enf_stand7, enf_stand1); ai_stand(this); }
void enf_stand6(entity this) { set_anim(this, anim_enf_stand6, enf_stand7); ai_stand(this); }
void enf_stand5(entity this) { set_anim(this, anim_enf_stand5, enf_stand6); ai_stand(this); }
void enf_stand4(entity this) { set_anim(this, anim_enf_stand4, enf_stand5); ai_stand(this); }
void enf_stand3(entity this) { set_anim(this, anim_enf_stand3, enf_stand4); ai_stand(this); }
void enf_stand2(entity this) { set_anim(this, anim_enf_stand2, enf_stand3); ai_stand(this); }
void enf_stand1(entity this) { set_anim(this, anim_enf_stand1, enf_stand2); ai_stand(this); }

void enf_walk1(entity this);
void enf_walk16(entity this) { set_anim(this, anim_enf_walk16, enf_walk1); ai_walk(this, 2); }
void enf_walk15(entity this) { set_anim(this, anim_enf_walk15, enf_walk16); ai_walk(this, 4); }
void enf_walk14(entity this) { set_anim(this, anim_enf_walk14, enf_walk15); ai_walk(this, 3); }
void enf_walk13(entity this) { set_anim(this, anim_enf_walk13, enf_walk14); ai_walk(this, 2); }
void enf_walk12(entity this) { set_anim(this, anim_enf_walk12, enf_walk13); ai_walk(this, 1); }
void enf_walk11(entity this) { set_anim(this, anim_enf_walk11, enf_walk12); ai_walk(this, 4); }
void enf_walk10(entity this) { set_anim(this, anim_enf_walk10, enf_walk11); ai_walk(this, 4); }
void enf_walk9(entity this) { set_anim(this, anim_enf_walk9, enf_walk10); ai_walk(this, 2); }
void enf_walk8(entity this) { set_anim(this, anim_enf_walk8, enf_walk9); ai_walk(this, 1); }
void enf_walk7(entity this) { set_anim(this, anim_enf_walk7, enf_walk8); ai_walk(this, 2); }
void enf_walk6(entity this) { set_anim(this, anim_enf_walk6, enf_walk7); ai_walk(this, 2); }
void enf_walk5(entity this) { set_anim(this, anim_enf_walk5, enf_walk6); ai_walk(this, 1); }
void enf_walk4(entity this) { set_anim(this, anim_enf_walk4, enf_walk5); ai_walk(this, 3); }
void enf_walk3(entity this) { set_anim(this, anim_enf_walk3, enf_walk4); ai_walk(this, 4); }
void enf_walk2(entity this) { set_anim(this, anim_enf_walk2, enf_walk3); ai_walk(this, 4); }
void enf_walk1(entity this)
{
	set_anim(this, anim_enf_walk1, enf_walk2);
	if(random() < 0.2)
		_sound(this, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);
	ai_walk(this, 2);
}

void enf_run1(entity this);
void enf_run8(entity this) { set_anim(this, anim_enf_run8, enf_run1); ai_run(this, 11); }
void enf_run7(entity this) { set_anim(this, anim_enf_run7, enf_run8); ai_run(this, 7); }
void enf_run6(entity this) { set_anim(this, anim_enf_run6, enf_run7); ai_run(this, 14); }
void enf_run5(entity this) { set_anim(this, anim_enf_run5, enf_run6); ai_run(this, 14); }
void enf_run4(entity this) { set_anim(this, anim_enf_run4, enf_run5); ai_run(this, 12); }
void enf_run3(entity this) { set_anim(this, anim_enf_run3, enf_run4); ai_run(this, 7); }
void enf_run2(entity this) { set_anim(this, anim_enf_run2, enf_run3); ai_run(this, 14); }
void enf_run1(entity this)
{
	set_anim(this, anim_enf_run1, enf_run2);
	if(random() < 0.2)
		_sound(this, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);
	ai_run(this, 18);
}

void enf_atk1(entity this);
void enf_atk14(entity this) { set_anim(this, anim_enf_attack10, enf_run1); ai_face(this); SUB_CheckRefire(this, enf_atk1); }
void enf_atk13(entity this) { set_anim(this, anim_enf_attack9, enf_atk14); ai_face(this); }
void enf_atk12(entity this) { set_anim(this, anim_enf_attack8, enf_atk13); ai_face(this); }
void enf_atk11(entity this) { set_anim(this, anim_enf_attack7, enf_atk12); ai_face(this); }
void enf_atk10(entity this) { set_anim(this, anim_enf_attack6, enf_atk11); enforcer_fire(this); }
void enf_atk9(entity this) { set_anim(this, anim_enf_attack5, enf_atk10); ai_face(this); }
void enf_atk8(entity this) { set_anim(this, anim_enf_attack8, enf_atk9); ai_face(this); }
void enf_atk7(entity this) { set_anim(this, anim_enf_attack7, enf_atk8); ai_face(this); }
void enf_atk6(entity this) { set_anim(this, anim_enf_attack6, enf_atk7); enforcer_fire(this); }
void enf_atk5(entity this) { set_anim(this, anim_enf_attack5, enf_atk6); ai_face(this); }
void enf_atk4(entity this) { set_anim(this, anim_enf_attack4, enf_atk5); ai_face(this); }
void enf_atk3(entity this) { set_anim(this, anim_enf_attack3, enf_atk4); ai_face(this); }
void enf_atk2(entity this) { set_anim(this, anim_enf_attack2, enf_atk3); ai_face(this); }
void enf_atk1(entity this) { set_anim(this, anim_enf_attack1, enf_atk2); ai_face(this); }

void enf_paina4(entity this) { set_anim(this, anim_enf_paina4, enf_run1); }
void enf_paina3(entity this) { set_anim(this, anim_enf_paina3, enf_paina4); }
void enf_paina2(entity this) { set_anim(this, anim_enf_paina2, enf_paina3); }
void enf_paina1(entity this) { set_anim(this, anim_enf_paina1, enf_paina2); }

void enf_painb5(entity this) { set_anim(this, anim_enf_painb5, enf_run1); }
void enf_painb4(entity this) { set_anim(this, anim_enf_painb4, enf_painb5); }
void enf_painb3(entity this) { set_anim(this, anim_enf_painb3, enf_painb4); }
void enf_painb2(entity this) { set_anim(this, anim_enf_painb2, enf_painb3); }
void enf_painb1(entity this) { set_anim(this, anim_enf_painb1, enf_painb2); }

void enf_painc8(entity this) { set_anim(this, anim_enf_painc8, enf_run1); }
void enf_painc7(entity this) { set_anim(this, anim_enf_painc7, enf_painc8); }
void enf_painc6(entity this) { set_anim(this, anim_enf_painc6, enf_painc7); }
void enf_painc5(entity this) { set_anim(this, anim_enf_painc5, enf_painc6); }
void enf_painc4(entity this) { set_anim(this, anim_enf_painc4, enf_painc5); }
void enf_painc3(entity this) { set_anim(this, anim_enf_painc3, enf_painc4); }
void enf_painc2(entity this) { set_anim(this, anim_enf_painc2, enf_painc3); }
void enf_painc1(entity this) { set_anim(this, anim_enf_painc1, enf_painc2); }

void enf_paind19(entity this) { set_anim(this, anim_enf_paind19, enf_run1); }
void enf_paind18(entity this) { set_anim(this, anim_enf_paind18, enf_paind19); }
void enf_paind17(entity this) { set_anim(this, anim_enf_paind17, enf_paind18); ai_pain(this, 1); }
void enf_paind16(entity this) { set_anim(this, anim_enf_paind16, enf_paind17); ai_pain(this, 1); }
void enf_paind15(entity this) { set_anim(this, anim_enf_paind15, enf_paind16); }
void enf_paind14(entity this) { set_anim(this, anim_enf_paind14, enf_paind15); }
void enf_paind13(entity this) { set_anim(this, anim_enf_paind13, enf_paind14); ai_painforward(this, 1); }
void enf_paind12(entity this) { set_anim(this, anim_enf_paind12, enf_paind13); ai_painforward(this, 1); }
void enf_paind11(entity this) { set_anim(this, anim_enf_paind11, enf_paind12); ai_painforward(this, 1); }
void enf_paind10(entity this) { set_anim(this, anim_enf_paind10, enf_paind11); }
void enf_paind9(entity this) { set_anim(this, anim_enf_paind9, enf_paind10); }
void enf_paind8(entity this) { set_anim(this, anim_enf_paind8, enf_paind9); }
void enf_paind7(entity this) { set_anim(this, anim_enf_paind7, enf_paind8); }
void enf_paind6(entity this) { set_anim(this, anim_enf_paind6, enf_paind7); }
void enf_paind5(entity this) { set_anim(this, anim_enf_paind5, enf_paind6); ai_painforward(this, 1); }
void enf_paind4(entity this) { set_anim(this, anim_enf_paind4, enf_paind5); ai_painforward(this, 2); }
void enf_paind3(entity this) { set_anim(this, anim_enf_paind3, enf_paind4); }
void enf_paind2(entity this) { set_anim(this, anim_enf_paind2, enf_paind3); }
void enf_paind1(entity this) { set_anim(this, anim_enf_paind1, enf_paind2); }

void enf_pain(entity this, entity attacker, float damage)
{
	float r = random();
	if(this.pain_finished > time)
		return;

	if(r < 0.5)
		_sound(this, CHAN_VOICE, "enforcer/pain1.wav", 1, ATTN_NORM);
	else
		_sound(this, CHAN_VOICE, "enforcer/pain2.wav", 1, ATTN_NORM);

	if(r < 0.2)
	{
		this.pain_finished = time + 1;
		enf_paina1(this);
	}
	else if(r < 0.4)
	{
		this.pain_finished = time + 1;
		enf_painb1(this);
	}
	else if(r < 0.7)
	{
		this.pain_finished = time + 1;
		enf_painc1(this);
	}
	else
	{
		this.pain_finished = time + 2;
		enf_paind1(this);
	}
}

//============================================================================


void enf_die14(entity this) { set_anim(this, anim_enf_death14, enf_die14); }
void enf_die13(entity this) { set_anim(this, anim_enf_death13, enf_die14); }
void enf_die12(entity this) { set_anim(this, anim_enf_death12, enf_die13); ai_forward(this, 5); }
void enf_die11(entity this) { set_anim(this, anim_enf_death11, enf_die12); ai_forward(this, 5); }
void enf_die10(entity this) { set_anim(this, anim_enf_death10, enf_die11); ai_forward(this, 5); }
void enf_die9(entity this) { set_anim(this, anim_enf_death9, enf_die10); ai_forward(this, 3); }
void enf_die8(entity this) { set_anim(this, anim_enf_death8, enf_die9); }
void enf_die7(entity this) { set_anim(this, anim_enf_death7, enf_die8); }
void enf_die6(entity this) { set_anim(this, anim_enf_death6, enf_die7); }
void enf_die5(entity this) { set_anim(this, anim_enf_death5, enf_die6); ai_forward(this, 2); }
void enf_die4(entity this) { set_anim(this, anim_enf_death4, enf_die5); ai_forward(this, 14); }
void enf_die3(entity this)
{
	set_anim(this, anim_enf_death3, enf_die4);
	this.solid = SOLID_NOT;
	this.ammo_cells = 5;
	DropBackpack(this);
}
void enf_die2(entity this) { set_anim(this, anim_enf_death2, enf_die3); }
void enf_die1(entity this) { set_anim(this, anim_enf_death1, enf_die2); }

void enf_fdie11(entity this) { set_anim(this, anim_enf_fdeath11, enf_fdie11); }
void enf_fdie10(entity this) { set_anim(this, anim_enf_fdeath10, enf_fdie11); }
void enf_fdie9(entity this) { set_anim(this, anim_enf_fdeath9, enf_fdie10); }
void enf_fdie8(entity this) { set_anim(this, anim_enf_fdeath8, enf_fdie9); }
void enf_fdie7(entity this) { set_anim(this, anim_enf_fdeath7, enf_fdie8); }
void enf_fdie6(entity this) { set_anim(this, anim_enf_fdeath6, enf_fdie7); }
void enf_fdie5(entity this) { set_anim(this, anim_enf_fdeath5, enf_fdie6); }
void enf_fdie4(entity this) { set_anim(this, anim_enf_fdeath4, enf_fdie5); }
void enf_fdie3(entity this)
{
	set_anim(this, anim_enf_fdeath3, enf_fdie4);
	this.solid = SOLID_NOT;
	this.ammo_cells = 5;
	DropBackpack(this);
}
void enf_fdie2(entity this) { set_anim(this, anim_enf_fdeath2, enf_fdie3); }
void enf_fdie1(entity this) { set_anim(this, anim_enf_fdeath1, enf_fdie2); }

void enf_die(entity this, entity attacker)
{
// check for gib
	if(this.health < -35)
	{
		_sound(this, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, "progs/h_mega.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib2.mdl", this.health);
		ThrowGib(this, "progs/gib3.mdl", this.health);
		return;
	}

// regular death
	_sound(this, CHAN_VOICE, "enforcer/death1.wav", 1, ATTN_NORM);
	if(random() > 0.5)
		enf_die1(this);
	else
		enf_fdie1(this);
}

string enf_sight(entity this)
{
	switch(rint(random() * 3))
	{
		case 1: return "enforcer/sight1.wav";
		case 2: return "enforcer/sight2.wav";
		case 0: return "enforcer/sight3.wav";
		default: return "enforcer/sight4.wav";
	}
}

string enf_deathmessage(entity this) { return "was blasted by an Enforcer"; }

/*QUAKED monster_enforcer(1 0 0)(-16 -16 -24)(16 16 40) Ambush

*/
spawnfunc(monster_enforcer)
{
	if(deathmatch)
	{
		delete(this);
		return;
	}
	precache_model2("progs/enforcer.mdl");
	precache_model2("progs/h_mega.mdl");
	precache_model2("progs/laser.mdl");

	precache_sound2("enforcer/death1.wav");
	precache_sound2("enforcer/enfire.wav");
	precache_sound2("enforcer/enfstop.wav");
	precache_sound2("enforcer/idle1.wav");
	precache_sound2("enforcer/pain1.wav");
	precache_sound2("enforcer/pain2.wav");
	precache_sound2("enforcer/sight1.wav");
	precache_sound2("enforcer/sight2.wav");
	precache_sound2("enforcer/sight3.wav");
	precache_sound2("enforcer/sight4.wav");
	
	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);

	_setmodel(this, "progs/enforcer.mdl");

	setsize(this, '-16 -16 -24', '16 16 40');
	this.health = 80;

	this.th_stand = enf_stand1;
	this.th_walk = enf_walk1;
	this.th_run = enf_run1;
	this.th_pain = enf_pain;
	this.th_die = enf_die;
	this.th_missile = enf_atk1;

	this.sightsound = enf_sight;
	this.deathmessage = enf_deathmessage;

	walkmonster_start(this);
}
