#include "dark_knight.qh"

#ifdef SVQC
void dknight_stand1(entity this);
void dknight_stand9(entity this) { set_anim(this, 8, dknight_stand1); ai_stand(this); }
void dknight_stand8(entity this) { set_anim(this, 7, dknight_stand9); ai_stand(this); }
void dknight_stand7(entity this) { set_anim(this, 6, dknight_stand8); ai_stand(this); }
void dknight_stand6(entity this) { set_anim(this, 5, dknight_stand7); ai_stand(this); }
void dknight_stand5(entity this) { set_anim(this, 4, dknight_stand6); ai_stand(this); }
void dknight_stand4(entity this) { set_anim(this, 3, dknight_stand5); ai_stand(this); }
void dknight_stand3(entity this) { set_anim(this, 2, dknight_stand4); ai_stand(this); }
void dknight_stand2(entity this) { set_anim(this, 1, dknight_stand3); ai_stand(this); }
void dknight_stand1(entity this) { set_anim(this, 0, dknight_stand2); ai_stand(this); }

void dknight_walk1(entity this);
void dknight_walk14(entity this)
{
	set_anim(this, 66, dknight_walk1);
	ai_walk(this, 3);
	this.oldorigin = this.origin;
}
void dknight_walk13(entity this) { set_anim(this, 65, dknight_walk14); ai_walk(this, 4); }
void dknight_walk12(entity this) { set_anim(this, 64, dknight_walk13); ai_walk(this, 3); }
void dknight_walk11(entity this) { set_anim(this, 63, dknight_walk12); ai_walk(this, 2); }
void dknight_walk10(entity this) { set_anim(this, 62, dknight_walk11); ai_walk(this, 3); }
void dknight_walk9(entity this) { set_anim(this, 61, dknight_walk10); ai_walk(this, 3); }
void dknight_walk8(entity this) { set_anim(this, 60, dknight_walk9); ai_walk(this, 4); }
void dknight_walk7(entity this) { set_anim(this, 59, dknight_walk8); ai_walk(this, 3); }
void dknight_walk6(entity this) { set_anim(this, 58, dknight_walk7); ai_walk(this, 3); }
void dknight_walk5(entity this) { set_anim(this, 57, dknight_walk6); ai_walk(this, 3); }
void dknight_walk4(entity this) { set_anim(this, 56, dknight_walk5); ai_walk(this, 4); }
void dknight_walk3(entity this) { set_anim(this, 55, dknight_walk4); ai_walk(this, 3); }
void dknight_walk2(entity this) { set_anim(this, 54, dknight_walk3); ai_walk(this, 2); }
void dknight_walk1(entity this)
{
	set_anim(this, 53, dknight_walk2);
	float r = random();
	if(r <= 0.2)
		_sound(this, CH_VOICE, "monsters/dknight/dkidle1.wav", 1, ATTN_IDLE);
	else if(r <= 0.4)
		_sound(this, CH_VOICE, "monsters/dknight/dkidle2.wav", 1, ATTN_IDLE);
	else
		_sound(this, CH_VOICE, "monsters/dknight/dkidle3.wav", 1, ATTN_IDLE);
	ai_walk(this, 8);
}

void dknight_run1(entity this);
void dknight_run8(entity this) { set_anim(this, 16, dknight_run1); ai_run(this, 30); }
void dknight_run7(entity this) { set_anim(this, 15, dknight_run8); ai_run(this, 30); }
void dknight_run6(entity this) { set_anim(this, 14, dknight_run7); ai_run(this, 30); }
void dknight_run5(entity this) { set_anim(this, 13, dknight_run6); ai_run(this, 30); }
void dknight_run4(entity this) { set_anim(this, 12, dknight_run5); ai_run(this, 30); }
void dknight_run3(entity this) { set_anim(this, 11, dknight_run4); ai_run(this, 30); }
void dknight_run2(entity this) { set_anim(this, 10, dknight_run3); ai_run(this, 30); }
void dknight_run1(entity this)
{
	set_anim(this, 9, dknight_run2);
	float r = random();
	if(r <= 0.2)
		_sound(this, CH_VOICE, "monsters/dknight/dkidle1.wav", 1, ATTN_IDLE);
	else if(r <= 0.4)
		_sound(this, CH_VOICE, "monsters/dknight/dkidle2.wav", 1, ATTN_IDLE);
	else
		_sound(this, CH_VOICE, "monsters/dknight/dkidle3.wav", 1, ATTN_IDLE);
	ai_run(this, 30);
}

void dknight_bow11(entity this) { set_anim(this, 53, dknight_run1); ai_face(this); }
void dknight_bow10(entity this) { set_anim(this, 26, dknight_bow11); ai_turn(this); }
void dknight_bow9(entity this) { set_anim(this, 25, dknight_bow10); ai_turn(this); }
void dknight_bow8(entity this) { set_anim(this, 50, dknight_bow9); ai_turn(this); }
void dknight_bow7(entity this) { set_anim(this, 49, dknight_bow8); ai_turn(this); }
void dknight_bow6(entity this) { set_anim(this, 48, dknight_bow7); ai_turn(this); }
void dknight_bow5(entity this) { set_anim(this, 47, dknight_bow6); ai_face(this); }
void dknight_bow4(entity this) { set_anim(this, 46, dknight_bow5); ai_turn(this); }
void dknight_bow3(entity this) { set_anim(this, 45, dknight_bow4); ai_turn(this); }
void dknight_bow2(entity this) { set_anim(this, 44, dknight_bow3); ai_turn(this); }
void dknight_bow1(entity this)
{
	set_anim(this, 17, dknight_bow2);
	ai_face(this);
	makevectors(this.angles);
	this.origin_z = this.origin_z + 1;
	setorigin(this, this.origin);
	this.velocity = '0 0 200' + (v_forward * 500);
	UNSET_ONGROUND(this);
}

void dknight_startfire(entity this)
{
	float rand = random();
	float r = random();
	vector org = this.origin;
	vector emy;
	if(r >= 0.5)
		emy = this.enemy.origin + (v_right * (rand * 48));
	else
		emy = this.enemy.origin - (v_right * (rand * 48));
	traceline(org, emy, true, this);
	_sound(this, CHAN_WEAPON, "monsters/dknight/dklight.wav", 1, ATTN_NORM);
	//te_lightning2(NULL, org, trace_endpos); // should be this
	SendCSQCLightningBeam(org, trace_endpos);
	LightningDamage(org, trace_endpos, this, 3);
	this.oldorigin = this.origin;
}

void dknight_shoot12(entity this) { set_anim(this, 53, dknight_run1); ai_face(this); }
void dknight_shoot11(entity this) { set_anim(this, 52, dknight_shoot12); ai_face(this); dknight_startfire(this); }
void dknight_shoot10(entity this) { set_anim(this, 51, dknight_shoot11); ai_face(this); dknight_startfire(this); }
void dknight_shoot9(entity this) { set_anim(this, 52, dknight_shoot10); ai_face(this); dknight_startfire(this); }
void dknight_shoot8(entity this) { set_anim(this, 51, dknight_shoot9); ai_face(this); dknight_startfire(this); }
void dknight_shoot7(entity this) { set_anim(this, 50, dknight_shoot8); ai_face(this); dknight_startfire(this); }
void dknight_shoot6(entity this) { set_anim(this, 49, dknight_shoot7); ai_face(this); dknight_startfire(this); }
void dknight_shoot5(entity this) { set_anim(this, 48, dknight_shoot6); ai_face(this); }
void dknight_shoot4(entity this) { set_anim(this, 47, dknight_shoot5); ai_face(this); }
void dknight_shoot3(entity this) { set_anim(this, 46, dknight_shoot4); ai_face(this); }
void dknight_shoot2(entity this) { set_anim(this, 45, dknight_shoot3); ai_face(this); }
void dknight_shoot1(entity this) { set_anim(this, 44, dknight_shoot2); ai_face(this); }

void dknight_runatk11(entity this) { set_anim(this, 27, dknight_run1); ai_charge(this, 10); }
void dknight_runatk10(entity this) { set_anim(this, 26, dknight_runatk11); ai_charge_side(this); }
void dknight_runatk9(entity this) { set_anim(this, 25, dknight_runatk10); ai_melee_side(this); }
void dknight_runatk8(entity this) { set_anim(this, 24, dknight_runatk9); ai_melee_side(this); }
void dknight_runatk7(entity this) { set_anim(this, 23, dknight_runatk8); ai_melee_side(this); }
void dknight_runatk6(entity this) { set_anim(this, 22, dknight_runatk7); ai_melee_side(this); }
void dknight_runatk5(entity this)
{
	set_anim(this, 21, dknight_runatk6);
	float r = random();
	if(r < 0.5)
		_sound(this, CHAN_BODY, "monsters/dknight/dkswzap1.wav", 1, ATTN_IDLE);
	else
		_sound(this, CHAN_BODY, "monsters/dknight/dkswzap2.wav", 1, ATTN_IDLE);
	ai_melee_side(this);
}
void dknight_runatk4(entity this) { set_anim(this, 20, dknight_runatk5); ai_charge_side(this); }
void dknight_runatk3(entity this) { set_anim(this, 19, dknight_runatk4); ai_charge_side(this); }
void dknight_runatk2(entity this) { set_anim(this, 18, dknight_runatk3); ai_charge_side(this); }
void dknight_runatk1(entity this) { set_anim(this, 17, dknight_runatk2); ai_charge(this, 20); }

void dknight_atk10(entity this) { set_anim(this, 52, dknight_run1); ai_charge(this, 5); }
void dknight_atk9(entity this) { set_anim(this, 51, dknight_atk10); ai_charge(this, 1); }
void dknight_atk8(entity this) { set_anim(this, 50, dknight_atk9); ai_charge(this, 3); ai_melee(this); }
void dknight_atk7(entity this) { set_anim(this, 49, dknight_atk8); ai_charge(this, 1); ai_melee(this); }
void dknight_atk6(entity this) { set_anim(this, 48, dknight_atk7); ai_charge(this, 4); ai_melee(this); }
void dknight_atk5(entity this)
{
	set_anim(this, 47, dknight_atk6);
	float r = random();
	if(r < 0.5)
		_sound(this, CHAN_BODY, "monsters/dknight/dkswzap1.wav", 1, ATTN_IDLE);
	else
		_sound(this, CHAN_BODY, "monsters/dknight/dkswzap2.wav", 1, ATTN_IDLE);
	ai_charge(this, 3);
}
void dknight_atk4(entity this) { set_anim(this, 46, dknight_atk5); ai_charge(this, 0); }
void dknight_atk3(entity this) { set_anim(this, 45, dknight_atk4); ai_charge(this, 4); }
void dknight_atk2(entity this) { set_anim(this, 44, dknight_atk3); ai_charge(this, 7); }
void dknight_atk1(entity this) { set_anim(this, 42, dknight_atk2); ai_charge(this, 0); }

void dknight_attack(entity this)
{
// decide if now is a good swing time
	if(vdist((this.enemy.origin + this.enemy.view_ofs) - (this.origin + this.view_ofs), <, 80))
		dknight_atk1(this);
	else
		dknight_runatk1(this);
}

void dknight_pain3(entity this) { set_anim(this, 30, dknight_run1); }
void dknight_pain2(entity this) { set_anim(this, 29, dknight_pain3); }
void dknight_pain1(entity this) { set_anim(this, 28, dknight_pain2); }

void dknight_painb11(entity this) { set_anim(this, 41, dknight_run1); }
void dknight_painb10(entity this) { set_anim(this, 40, dknight_painb11); ai_painforward(this, 0); }
void dknight_painb9(entity this) { set_anim(this, 39, dknight_painb10); ai_painforward(this, 5); }
void dknight_painb8(entity this) { set_anim(this, 38, dknight_painb9); ai_painforward(this, 5); }
void dknight_painb7(entity this) { set_anim(this, 37, dknight_painb8); ai_painforward(this, 2); }
void dknight_painb6(entity this) { set_anim(this, 36, dknight_painb7); ai_painforward(this, 4); }
void dknight_painb5(entity this) { set_anim(this, 35, dknight_painb6); ai_painforward(this, 2); }
void dknight_painb4(entity this) { set_anim(this, 34, dknight_painb5); }
void dknight_painb3(entity this) { set_anim(this, 33, dknight_painb4); }
void dknight_painb2(entity this) { set_anim(this, 32, dknight_painb3); ai_painforward(this, 3); }
void dknight_painb1(entity this) { set_anim(this, 31, dknight_painb2); ai_painforward(this, 0); }

void dknight_pain(entity this, entity attacker, float damage)
{
	this.oldorigin = this.origin;
	if(this.pain_finished > time)
		return;
	float r = random();
	if(r <= 0.5)
		_sound(this, CH_VOICE, "monsters/dknight/dkhurt1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "monsters/dknight/dkhurt2.wav", 1, ATTN_NORM);
	if(r < 0.85)
	{
		dknight_pain1(this);
		this.pain_finished = time + 1;
	}
	else
	{
		dknight_painb1(this);
		this.pain_finished = time + 1;
	}
}

void dknight_die10(entity this) { set_anim(this, 85, dknight_die10); CorpseThink(this); }
void dknight_die9(entity this) { set_anim(this, 84, dknight_die10); }
void dknight_die8(entity this) { set_anim(this, 83, dknight_die9); }
void dknight_die7(entity this) { set_anim(this, 82, dknight_die8); }
void dknight_die6(entity this) { set_anim(this, 81, dknight_die7); }
void dknight_die5(entity this) { set_anim(this, 80, dknight_die6); }
void dknight_die4(entity this) { set_anim(this, 79, dknight_die5); }
void dknight_die3(entity this) { set_anim(this, 78, dknight_die4); this.solid = SOLID_NOT; }
void dknight_die2(entity this) { set_anim(this, 77, dknight_die3); }
void dknight_die1(entity this) { set_anim(this, 76, dknight_die2); }

void dknight_dieb11(entity this) { set_anim(this, 96, dknight_dieb11); CorpseThink(this); }
void dknight_dieb10(entity this) { set_anim(this, 95, dknight_dieb11); }
void dknight_dieb9(entity this) { set_anim(this, 94, dknight_dieb10); }
void dknight_dieb8(entity this) { set_anim(this, 93, dknight_dieb9); }
void dknight_dieb7(entity this) { set_anim(this, 92, dknight_dieb8); }
void dknight_dieb6(entity this) { set_anim(this, 91, dknight_dieb7); }
void dknight_dieb5(entity this) { set_anim(this, 90, dknight_dieb6); }
void dknight_dieb4(entity this) { set_anim(this, 89, dknight_dieb5); }
void dknight_dieb3(entity this) { set_anim(this, 88, dknight_dieb4); this.solid = SOLID_NOT; }
void dknight_dieb2(entity this) { set_anim(this, 87, dknight_dieb3); }
void dknight_dieb1(entity this) { set_anim(this, 86, dknight_dieb2); }

void dknight_die(entity this, entity inflictor, entity attacker)
{
	if(this.health < -40)
	{
		_sound(this, CHAN_ITEM, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, "progs/h_dkni.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib2.mdl", this.health);
		ThrowGib(this, "progs/gib3.mdl", this.health);
		return;
	}
	float r = random();
	if(r <= 0.5)
		_sound(this, CHAN_ITEM, "monsters/dknight/dkdeath1.wav", 1, ATTN_NORM);
	else
		_sound(this, CHAN_ITEM, "monsters/dknight/dkdeath2.wav", 1, ATTN_NORM);
	if(random() < 0.5)
		dknight_die1(this);
	else
		dknight_dieb1(this);
}

void dknightattack(entity this)
{
	if(random() < 0.25)
	{
		_sound(this, CHAN_WEAPON, "shalrath/attack2.wav", 1, ATTN_NORM);
		dknight_bow1(this);
	}
	else
	{
		_sound(this, CHAN_WEAPON, "monsters/dknight/dkzap.wav", 1, ATTN_NORM);
		dknight_shoot1(this);
	}
}

string dknight_sight(entity this)
{
	switch(floor(random() * 3))
	{
		case 0: return "monsters/dknight/dksight1.wav";
		case 1: return "monsters/dknight/dksight2.wav";
		default: case 2: return "monsters/dknight/dksight3.wav";
	}
}
string dknight_deathmessage(entity this) { return "was fried by a Dark Knight"; }

spawnfunc(monster_dknight)
{
	if(!MP_IMPEL) { delete(this); return; }
	monster_start(this, MON_DARK_KNIGHT);
}
#endif // SVQC

#ifdef SVQC
METHOD(DarkKnight, mr_setup, bool(DarkKnight this, entity actor))
{
    TC(DarkKnight, this);

	precache_sound2("monsters/dknight/dksight1.wav");
	precache_sound2("monsters/dknight/dksight2.wav");
	precache_sound2("monsters/dknight/dksight3.wav");
	precache_sound2("monsters/dknight/dklight.wav");
	precache_sound2("monsters/dknight/dkidle1.wav");
	precache_sound2("monsters/dknight/dkidle2.wav");
	precache_sound2("monsters/dknight/dkidle3.wav");
	precache_sound2("monsters/dknight/dkhurt1.wav");
	precache_sound2("monsters/dknight/dkhurt2.wav");
	precache_sound2("monsters/dknight/dkdeath1.wav");
	precache_sound2("monsters/dknight/dkdeath2.wav");
	precache_sound2("monsters/dknight/dkzap.wav");
	precache_sound2("monsters/dknight/dkswzap1.wav");
	precache_sound2("monsters/dknight/dkswzap2.wav");
	precache_sound2("shalrath/attack2.wav");

    actor.health = 200;
	actor.th_stand = dknight_stand1;
	actor.th_walk = dknight_walk1;
	actor.th_run = dknight_run1;
	actor.th_melee = dknight_atk1;
	actor.th_pain = dknight_pain;
	actor.th_melee = dknight_attack;
	actor.th_die = dknight_die;
	actor.th_missile = dknightattack;

	actor.sightsound = dknight_sight;
	actor.deathmessage = dknight_deathmessage;

    return true;
}
#endif
