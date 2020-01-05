/*
==============================================================================

KNIGHT

==============================================================================
*/

$cd id1/models/knight
$origin 0 0 24
$base base
$skin badass3
// rogue
$skin statue

const int anim_knight_stand1 = 0;
const int anim_knight_stand2 = 1;
const int anim_knight_stand3 = 2;
const int anim_knight_stand4 = 3;
const int anim_knight_stand5 = 4;
const int anim_knight_stand6 = 5;
const int anim_knight_stand7 = 6;
const int anim_knight_stand8 = 7;
const int anim_knight_stand9 = 8;

const int anim_knight_runb1 = 9;
const int anim_knight_runb2 = 10;
const int anim_knight_runb3 = 11;
const int anim_knight_runb4 = 12;
const int anim_knight_runb5 = 13;
const int anim_knight_runb6 = 14;
const int anim_knight_runb7 = 15;
const int anim_knight_runb8 = 16;

//frame runc1 runc2 runc3 runc4 runc5 runc6

const int anim_knight_runattack1 = 17;
const int anim_knight_runattack2 = 18;
const int anim_knight_runattack3 = 19;
const int anim_knight_runattack4 = 20;
const int anim_knight_runattack5 = 21;
const int anim_knight_runattack6 = 22;
const int anim_knight_runattack7 = 23;
const int anim_knight_runattack8 = 24;
const int anim_knight_runattack9 = 25;
const int anim_knight_runattack10 = 26;
const int anim_knight_runattack11 = 27;

const int anim_knight_pain1 = 28;
const int anim_knight_pain2 = 29;
const int anim_knight_pain3 = 30;

const int anim_knight_painb1 = 31;
const int anim_knight_painb2 = 32;
const int anim_knight_painb3 = 33;
const int anim_knight_painb4 = 34;
const int anim_knight_painb5 = 35;
const int anim_knight_painb6 = 36;
const int anim_knight_painb7 = 37;
const int anim_knight_painb8 = 38;
const int anim_knight_painb9 = 39;
const int anim_knight_painb10 = 40;
const int anim_knight_painb11 = 41;

//frame attack1 attack2 attack3 attack4 attack5 attack6 attack7
//frame attack8 attack9 attack10 attack11

const int anim_knight_attackb1 = 42;
const int anim_knight_attackb2 = 43;
const int anim_knight_attackb3 = 44;
const int anim_knight_attackb4 = 45;
const int anim_knight_attackb5 = 46;
const int anim_knight_attackb6 = 47;
const int anim_knight_attackb7 = 48;
const int anim_knight_attackb8 = 49;
const int anim_knight_attackb9 = 50;
const int anim_knight_attackb10 = 51;

const int anim_knight_walk1 = 52;
const int anim_knight_walk2 = 53;
const int anim_knight_walk3 = 54;
const int anim_knight_walk4 = 55;
const int anim_knight_walk5 = 56;
const int anim_knight_walk6 = 57;
const int anim_knight_walk7 = 58;
const int anim_knight_walk8 = 59;
const int anim_knight_walk9 = 60;
const int anim_knight_walk10 = 61;
const int anim_knight_walk11 = 62;
const int anim_knight_walk12 = 63;
const int anim_knight_walk13 = 64;
const int anim_knight_walk14 = 65;

const int anim_knight_kneel1 = 66;
const int anim_knight_kneel2 = 67;
const int anim_knight_kneel3 = 68;
const int anim_knight_kneel4 = 69;
const int anim_knight_kneel5 = 70;

const int anim_knight_standing2 = 71;
const int anim_knight_standing3 = 72;
const int anim_knight_standing4 = 73;
const int anim_knight_standing5 = 74;

const int anim_knight_death1 = 75;
const int anim_knight_death2 = 76;
const int anim_knight_death3 = 77;
const int anim_knight_death4 = 78;
const int anim_knight_death5 = 79;
const int anim_knight_death6 = 80;
const int anim_knight_death7 = 81;
const int anim_knight_death8 = 82;
const int anim_knight_death9 = 83;
const int anim_knight_death10 = 84;

const int anim_knight_deathb1 = 85;
const int anim_knight_deathb2 = 86;
const int anim_knight_deathb3 = 87;
const int anim_knight_deathb4 = 88;
const int anim_knight_deathb5 = 89;
const int anim_knight_deathb6 = 90;
const int anim_knight_deathb7 = 91;
const int anim_knight_deathb8 = 92;
const int anim_knight_deathb9 = 93;
const int anim_knight_deathb10 = 94;
const int anim_knight_deathb11 = 95;

void kn_idle_sound(entity this)
{
	if(random() < 0.2)
	{
		if(MP_ROGUE && (this.spawnflags & 2)) // statue)
			_sound(this, CH_VOICE, "statue/idle.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "knight/idle.wav", 1,  ATTN_IDLE);
	}
}

void knight_stand1(entity this);
void knight_stand9(entity this) { set_anim(this, anim_knight_stand9, knight_stand1); ai_stand(this); }
void knight_stand8(entity this) { set_anim(this, anim_knight_stand8, knight_stand9); ai_stand(this); }
void knight_stand7(entity this) { set_anim(this, anim_knight_stand7, knight_stand8); ai_stand(this); }
void knight_stand6(entity this) { set_anim(this, anim_knight_stand6, knight_stand7); ai_stand(this); }
void knight_stand5(entity this) { set_anim(this, anim_knight_stand5, knight_stand6); ai_stand(this); }
void knight_stand4(entity this) { set_anim(this, anim_knight_stand4, knight_stand5); ai_stand(this); }
void knight_stand3(entity this) { set_anim(this, anim_knight_stand3, knight_stand4); ai_stand(this); }
void knight_stand2(entity this) { set_anim(this, anim_knight_stand2, knight_stand3); ai_stand(this); }
void knight_stand1(entity this) { set_anim(this, anim_knight_stand1, knight_stand2); ai_stand(this); }

void knight_walk1(entity this);
void knight_walk14(entity this) { set_anim(this, anim_knight_walk14, knight_walk1); ai_walk(this, 3); }
void knight_walk13(entity this) { set_anim(this, anim_knight_walk13, knight_walk14); ai_walk(this, 4); }
void knight_walk12(entity this) { set_anim(this, anim_knight_walk12, knight_walk13); ai_walk(this, 3); }
void knight_walk11(entity this) { set_anim(this, anim_knight_walk11, knight_walk12); ai_walk(this, 2); }
void knight_walk10(entity this) { set_anim(this, anim_knight_walk10, knight_walk11); ai_walk(this, 3); }
void knight_walk9(entity this) { set_anim(this, anim_knight_walk9, knight_walk10); ai_walk(this, 3); }
void knight_walk8(entity this) { set_anim(this, anim_knight_walk8, knight_walk9); ai_walk(this, 4); }
void knight_walk7(entity this) { set_anim(this, anim_knight_walk7, knight_walk8); ai_walk(this, 3); }
void knight_walk6(entity this) { set_anim(this, anim_knight_walk6, knight_walk7); ai_walk(this, 3); }
void knight_walk5(entity this) { set_anim(this, anim_knight_walk5, knight_walk6); ai_walk(this, 3); }
void knight_walk4(entity this) { set_anim(this, anim_knight_walk4, knight_walk5); ai_walk(this, 4); }
void knight_walk3(entity this) { set_anim(this, anim_knight_walk3, knight_walk4); ai_walk(this, 3); }
void knight_walk2(entity this) { set_anim(this, anim_knight_walk2, knight_walk3); ai_walk(this, 2); }
void knight_walk1(entity this)
{
	set_anim(this, anim_knight_walk1, knight_walk2);
	kn_idle_sound(this);
	ai_walk(this, 3);
}

void knight_run1(entity this);
void knight_run8(entity this) { set_anim(this, anim_knight_runb8, knight_run1); ai_run(this, 6); }
void knight_run7(entity this) { set_anim(this, anim_knight_runb7, knight_run8); ai_run(this, 14); }
void knight_run6(entity this) { set_anim(this, anim_knight_runb6, knight_run7); ai_run(this, 20); }
void knight_run5(entity this) { set_anim(this, anim_knight_runb5, knight_run6); ai_run(this, 16); }
void knight_run4(entity this) { set_anim(this, anim_knight_runb4, knight_run5); ai_run(this, 7); }
void knight_run3(entity this) { set_anim(this, anim_knight_runb3, knight_run4); ai_run(this, 13); }
void knight_run2(entity this) { set_anim(this, anim_knight_runb2, knight_run3); ai_run(this, 20); }
void knight_run1(entity this)
{
	set_anim(this, anim_knight_runb1, knight_run2);
	kn_idle_sound(this);
	ai_run(this, 16);
}

void knight_runatk11(entity this) { set_anim(this, anim_knight_runattack11, knight_run1); ai_charge(this, 10); }
void knight_runatk10(entity this) { set_anim(this, anim_knight_runattack10, knight_runatk11); ai_charge_side(this); }
void knight_runatk9(entity this) { set_anim(this, anim_knight_runattack9, knight_runatk10); ai_melee_side(this); }
void knight_runatk8(entity this) { set_anim(this, anim_knight_runattack8, knight_runatk9); ai_melee_side(this); }
void knight_runatk7(entity this) { set_anim(this, anim_knight_runattack7, knight_runatk8); ai_melee_side(this); }
void knight_runatk6(entity this) { set_anim(this, anim_knight_runattack6, knight_runatk7); ai_melee_side(this); }
void knight_runatk5(entity this) { set_anim(this, anim_knight_runattack5, knight_runatk6); ai_melee_side(this); }
void knight_runatk4(entity this) { set_anim(this, anim_knight_runattack4, knight_runatk5); ai_charge_side(this); }
void knight_runatk3(entity this) { set_anim(this, anim_knight_runattack3, knight_runatk4); ai_charge_side(this); }
void knight_runatk2(entity this) { set_anim(this, anim_knight_runattack2, knight_runatk3); ai_charge_side(this); }
void knight_runatk1(entity this)
{
	set_anim(this, anim_knight_runattack1, knight_runatk2);
	if(random() > 0.5)
		_sound(this, CH_WEAPON_SINGLE, "knight/sword2.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "knight/sword1.wav", 1, ATTN_NORM);
	ai_charge(this, 20);
}

void knight_atk10(entity this) { set_anim(this, anim_knight_attackb10, knight_run1); ai_charge(this, 5); }
void knight_atk9(entity this) { set_anim(this, anim_knight_attackb9, knight_atk10); ai_charge(this, 1); }
void knight_atk8(entity this) { set_anim(this, anim_knight_attackb8, knight_atk9); ai_charge(this, 3); ai_melee(this); }
void knight_atk7(entity this) { set_anim(this, anim_knight_attackb7, knight_atk8); ai_charge(this, 1); ai_melee(this); }
void knight_atk6(entity this) { set_anim(this, anim_knight_attackb6, knight_atk7); ai_charge(this, 4); ai_melee(this); }
void knight_atk5(entity this) { set_anim(this, anim_knight_attackb5, knight_atk6); ai_charge(this, 3); }
void knight_atk4(entity this) { set_anim(this, anim_knight_attackb4, knight_atk5); ai_charge(this, 0); }
void knight_atk3(entity this) { set_anim(this, anim_knight_attackb3, knight_atk4); ai_charge(this, 4); }
void knight_atk2(entity this) { set_anim(this, anim_knight_attackb2, knight_atk3); ai_charge(this, 7); }
void knight_atk1(entity this) { set_anim(this, anim_knight_attackb1, knight_atk2);  _sound(this, CH_WEAPON_SINGLE, "knight/sword1.wav", 1, ATTN_NORM); ai_charge(this, 0); }

void knight_attack(entity this)
{
// decide if now is a good swing time
	if(vdist((this.enemy.origin + this.enemy.view_ofs) - (this.origin + this.view_ofs), <, 80))
		knight_atk1(this);
	else
		knight_runatk1(this);
}

//void knight_atk11(entity this)	=[	anim_knight_attack11,		knight_run1	 
//void knight_atk10(entity this)	=[	anim_knight_attack10,		knight_atk11	 
//void knight_atk9(entity this)	=[	anim_knight_attack9,		knight_atk10	 

//===========================================================================

void knight_pain3(entity this) { set_anim(this, anim_knight_pain3, knight_run1); }
void knight_pain2(entity this) { set_anim(this, anim_knight_pain2, knight_pain3); }
void knight_pain1(entity this) { set_anim(this, anim_knight_pain1, knight_pain2); }

void knight_painb11(entity this) { set_anim(this, anim_knight_painb11, knight_run1); }
void knight_painb10(entity this) { set_anim(this, anim_knight_painb10, knight_painb11); ai_painforward(this, 0); }
void knight_painb9(entity this) { set_anim(this, anim_knight_painb9, knight_painb10); ai_painforward(this, 5); }
void knight_painb8(entity this) { set_anim(this, anim_knight_painb8, knight_painb9); ai_painforward(this, 5); }
void knight_painb7(entity this) { set_anim(this, anim_knight_painb7, knight_painb8); ai_painforward(this, 2); }
void knight_painb6(entity this) { set_anim(this, anim_knight_painb6, knight_painb7); ai_painforward(this, 4); }
void knight_painb5(entity this) { set_anim(this, anim_knight_painb5, knight_painb6); ai_painforward(this, 2); }
void knight_painb4(entity this) { set_anim(this, anim_knight_painb4, knight_painb5); }
void knight_painb3(entity this) { set_anim(this, anim_knight_painb3, knight_painb4); }
void knight_painb2(entity this) { set_anim(this, anim_knight_painb2, knight_painb3); ai_painforward(this, 3); }
void knight_painb1(entity this) { set_anim(this, anim_knight_painb1, knight_painb2); ai_painforward(this, 0); }

void knight_pain(entity this, entity attacker, float damage)
{
	if(this.pain_finished > time)
		return;

	float r = random();
	
	if(this.spawnflags & 2) // statue)
		_sound(this, CH_VOICE, "statue/pain.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "knight/khurt.wav", 1, ATTN_NORM);
	if(r < 0.85)
	{
		knight_pain1(this);
		this.pain_finished = time + 1;
	}
	else
	{
		knight_painb1(this);
		this.pain_finished = time + 1;
	}
	
}

//===========================================================================

void knight_bow10(entity this) { set_anim(this, anim_knight_walk1, knight_walk1); ai_turn(this); }
void knight_bow9(entity this) { set_anim(this, anim_knight_kneel1, knight_bow10); ai_turn(this); }
void knight_bow8(entity this) { set_anim(this, anim_knight_kneel2, knight_bow9); ai_turn(this); }
void knight_bow7(entity this) { set_anim(this, anim_knight_kneel3, knight_bow8); ai_turn(this); }
void knight_bow6(entity this) { set_anim(this, anim_knight_kneel4, knight_bow7); ai_turn(this); }
void knight_bow5(entity this) { set_anim(this, anim_knight_kneel5, knight_bow5); ai_turn(this); }
void knight_bow4(entity this) { set_anim(this, anim_knight_kneel4, knight_bow5); ai_turn(this); }
void knight_bow3(entity this) { set_anim(this, anim_knight_kneel3, knight_bow4); ai_turn(this); }
void knight_bow2(entity this) { set_anim(this, anim_knight_kneel2, knight_bow3); ai_turn(this); }
void knight_bow1(entity this) { set_anim(this, anim_knight_kneel1, knight_bow2); ai_turn(this); }

void knight_die10(entity this) { set_anim(this, anim_knight_death10, knight_die10); CorpseThink(this); }
void knight_die9(entity this) { set_anim(this, anim_knight_death9, knight_die10); }
void knight_die8(entity this) { set_anim(this, anim_knight_death8, knight_die9); }
void knight_die7(entity this) { set_anim(this, anim_knight_death7, knight_die8); }
void knight_die6(entity this) { set_anim(this, anim_knight_death6, knight_die7); }
void knight_die5(entity this) { set_anim(this, anim_knight_death5, knight_die6); }
void knight_die4(entity this) { set_anim(this, anim_knight_death4, knight_die5); }
void knight_die3(entity this) { set_anim(this, anim_knight_death3, knight_die4); this.solid = SOLID_NOT; }
void knight_die2(entity this) { set_anim(this, anim_knight_death2, knight_die3); }
void knight_die1(entity this) { set_anim(this, anim_knight_death1, knight_die2); }

void knight_dieb11(entity this) { set_anim(this, anim_knight_deathb11, knight_dieb11); CorpseThink(this); }
void knight_dieb10(entity this) { set_anim(this, anim_knight_deathb10, knight_dieb11); }
void knight_dieb9(entity this) { set_anim(this, anim_knight_deathb9, knight_dieb10); }
void knight_dieb8(entity this) { set_anim(this, anim_knight_deathb8, knight_dieb9); }
void knight_dieb7(entity this) { set_anim(this, anim_knight_deathb7, knight_dieb8); }
void knight_dieb6(entity this) { set_anim(this, anim_knight_deathb6, knight_dieb7); }
void knight_dieb5(entity this) { set_anim(this, anim_knight_deathb5, knight_dieb6); }
void knight_dieb4(entity this) { set_anim(this, anim_knight_deathb4, knight_dieb5); }
void knight_dieb3(entity this) { set_anim(this, anim_knight_deathb3, knight_dieb4); this.solid = SOLID_NOT; }
void knight_dieb2(entity this) { set_anim(this, anim_knight_deathb2, knight_dieb3); }
void knight_dieb1(entity this) { set_anim(this, anim_knight_deathb1, knight_dieb2); }


void knight_die(entity this, entity inflictor, entity attacker)
{
// check for gib
	if(this.health < -40)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		if(MP_ROGUE && (this.spawnflags & 2)) // statue)
		{
			ThrowGib(this, "progs/statgib1.mdl", this.health);
			ThrowGib(this, "progs/statgib2.mdl", this.health);
			ThrowGib(this, "progs/statgib3.mdl", this.health);
		}
		else
		{
			ThrowHead(this, "progs/h_knight.mdl", this.health);
			ThrowGib(this, "progs/gib1.mdl", this.health);
			ThrowGib(this, "progs/gib2.mdl", this.health);
			ThrowGib(this, "progs/gib3.mdl", this.health);
		}
		return;
	}

// regular death
	if(MP_ROGUE && (this.spawnflags & 2)) // statue
		_sound(this, CH_VOICE, "statue/death.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "knight/kdeath.wav", 1, ATTN_NORM);
	if(random() < 0.5)
		knight_die1(this);
	else
		knight_dieb1(this);
}

void knight_pause(entity this, entity actor, entity trigger)
{
	_sound(this, CH_VOICE, "statue/see.wav", 1, ATTN_NORM);

	this.takedamage = DAMAGE_AIM;
	this.th_stand = knight_stand1;
	this.th_walk = knight_walk1;
	this.th_run = knight_run1;
	this.th_melee = knight_atk1;
	this.th_pain = knight_pain;
	this.th_die = knight_die;
	this.use = func_null;
	
	setthink(this, knight_run1);

	this.enemy = actor;
	this.nextthink = time + 0.1;
	setthink(this, FoundTarget);

	this.delay = 0;
}

void knight_pause1(entity this)
{
	this.takedamage = DAMAGE_NO;
	this.use = knight_pause;
	setthink(this, knight_pause1);
    this.nextthink = time + 0.1;
}

string knight_sight(entity this) { if(!MP_ROGUE || !this.skin) return "knight/ksight.wav"; else return string_null; }
string knight_deathmessage(entity this) { return "was slashed by a Knight"; }

/*QUAKED monster_knight(1 0 0)(-16 -16 -24)(16 16 40) Ambush Statue

Statue - (rogue only) select this to use the stone skin and have him frozen in place.

delay: time from sight to attack (default 5)
frame: frame to be frozen in. (default 44)
*/
spawnfunc(monster_knight)
{
	if(deathmatch) { delete(this); return; }
	precache_model("progs/knight.mdl");
	precache_model("progs/h_knight.mdl");

	if(MP_ROGUE && (this.spawnflags & 2)) // statue
	{
		precache_model("progs/statgib1.mdl");
		precache_model("progs/statgib2.mdl");
		precache_model("progs/statgib3.mdl");
		precache_sound("statue/see.wav");
		precache_sound("statue/idle.wav");
		precache_sound("statue/pain.wav");
		precache_sound("statue/death.wav");
	}
	else
	{
		precache_sound("knight/kdeath.wav");
		precache_sound("knight/khurt.wav");
		precache_sound("knight/ksight.wav");
		precache_sound("knight/idle.wav");
	}
	precache_sound("knight/sword1.wav");
	precache_sound("knight/sword2.wav");

	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);

	_setmodel(this, "progs/knight.mdl");

	setsize(this, '-16 -16 -24', '16 16 40');
	this.health = 75;

	this.sightsound = knight_sight;
	this.deathmessage = knight_deathmessage;

	if(MP_ROGUE && (this.spawnflags & 2)) // statue
	{
		if(this.frame == 0)
			this.frame = 44;
		this.skin = 1;

		if(!this.targetname || this.targetname == "")
		{
			LOG_DEBUGF("statue %s not targeted at %v\n", this.classname, this.origin);
			return;
		}

		this.th_stand = knight_pause1;
		this.th_walk = knight_pause1;
		this.th_run = knight_pause1;
	}
	else
	{
		this.th_stand = knight_stand1;
		this.th_walk = knight_walk1;
		this.th_run = knight_run1;
		this.th_melee = knight_attack;
		this.th_pain = knight_pain;
		this.th_die = knight_die;
	}
	
	monster_start(this, 0);

	if(MP_ROGUE && (this.spawnflags & 2))
		this.use = knight_pause; // do this AFTER monster_start, so .use isn't overridden!
}
