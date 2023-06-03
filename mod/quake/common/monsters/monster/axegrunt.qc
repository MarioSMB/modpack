#include "axegrunt.qh"

#ifdef SVQC
const int anim_axegrunt_axrun = 0; //'0 5 0'
const int anim_axegrunt_rockrun = 6; //'6 11 0'
const int anim_axegrunt_stand = 12; //'12 16 0'
const int anim_axegrunt_axstnd = 17; //'17 28 0'
const int anim_axegrunt_axpain = 29; //'29 34 0'
const int anim_axegrunt_pain = 35; //'35 40 0'
const int anim_axegrunt_axdeth = 41; //'41 49 0'
const int anim_axegrunt_deatha = 50; //'50 60 0'
const int anim_axegrunt_deathb = 61; //'61 69 0'
const int anim_axegrunt_deathc = 70; //'70 84 0'
const int anim_axegrunt_deathd = 85; //'85 93 0'
const int anim_axegrunt_deathe = 94; //'94 102 0'
const int anim_axegrunt_nailatt = 103; //'103 104 0'
const int anim_axegrunt_light = 105; //'105 106 0'
const int anim_axegrunt_rockatt = 107; //'107 112 0'
const int anim_axegrunt_shotatt = 113; //'113 118 0'
const int anim_axegrunt_axatt = 119; //'119 124 0'
const int anim_axegrunt_axattb = 125; //'125 130 0'
const int anim_axegrunt_axattc = 131; //'131 136 0'
const int anim_axegrunt_axattd = 137; //'137 142 0'

void axe_stand1(entity this);
void axe_stand12(entity this) { set_animofs(this, anim_axegrunt_axstnd, 12, axe_stand1); ai_stand(this); }
void axe_stand11(entity this) { set_animofs(this, anim_axegrunt_axstnd, 11, axe_stand12); ai_stand(this); }
void axe_stand10(entity this) { set_animofs(this, anim_axegrunt_axstnd, 10, axe_stand11); ai_stand(this); }
void axe_stand9(entity this) { set_animofs(this, anim_axegrunt_axstnd, 9, axe_stand10); ai_stand(this); }
void axe_stand8(entity this) { set_animofs(this, anim_axegrunt_axstnd, 8, axe_stand9); ai_stand(this); }
void axe_stand7(entity this) { set_animofs(this, anim_axegrunt_axstnd, 7, axe_stand8); ai_stand(this); }
void axe_stand6(entity this) { set_animofs(this, anim_axegrunt_axstnd, 6, axe_stand7); ai_stand(this); }
void axe_stand5(entity this) { set_animofs(this, anim_axegrunt_axstnd, 5, axe_stand6); ai_stand(this); }
void axe_stand4(entity this) { set_animofs(this, anim_axegrunt_axstnd, 4, axe_stand5); ai_stand(this); }
void axe_stand3(entity this) { set_animofs(this, anim_axegrunt_axstnd, 3, axe_stand4); ai_stand(this); }
void axe_stand2(entity this) { set_animofs(this, anim_axegrunt_axstnd, 2, axe_stand3); ai_stand(this); }
void axe_stand1(entity this) { set_animofs(this, anim_axegrunt_axstnd, 1, axe_stand2); ai_stand(this); }

void axe_run1(entity this);
void axe_run6(entity this) { set_animofs(this, anim_axegrunt_axrun, 6, axe_run1); ai_run(this, 12); }
void axe_run5(entity this) { set_animofs(this, anim_axegrunt_axrun, 5, axe_run6); ai_run(this, 18); }
void axe_run4(entity this) { set_animofs(this, anim_axegrunt_axrun, 4, axe_run5); ai_run(this, 25); }
void axe_run3(entity this) { set_animofs(this, anim_axegrunt_axrun, 3, axe_run4); ai_run(this, 12); }
void axe_run2(entity this) { set_animofs(this, anim_axegrunt_axrun, 2, axe_run3); ai_run(this, 18); }
void axe_run1(entity this)
{
	set_animofs(this, anim_axegrunt_axrun, 1, axe_run2);
	this.state = 1; // running
	if(random() < 0.2)
		_sound(this, CH_VOICE, "knight/idle.wav", 1,  ATTN_IDLE);
	ai_run(this, 25);
}

void axe_walk1(entity this);
void axe_walk6(entity this) { set_animofs(this, anim_axegrunt_rockrun, 6, axe_walk1); this.nextthink = time + 0.15; ai_walk(this, 4); }
void axe_walk5(entity this) { set_animofs(this, anim_axegrunt_rockrun, 5, axe_walk6); this.nextthink = time + 0.15; ai_walk(this, 9); }
void axe_walk4(entity this) { set_animofs(this, anim_axegrunt_rockrun, 4, axe_walk5); this.nextthink = time + 0.15; ai_walk(this, 12); }
void axe_walk3(entity this) { set_animofs(this, anim_axegrunt_rockrun, 3, axe_walk4); this.nextthink = time + 0.15; ai_walk(this, 4); }
void axe_walk2(entity this) { set_animofs(this, anim_axegrunt_rockrun, 2, axe_walk3); this.nextthink = time + 0.15; ai_walk(this, 9); }
void axe_walk1(entity this)
{
	set_animofs(this, anim_axegrunt_rockrun, 1, axe_walk2);
	this.nextthink = time + 0.15;
	if(random() < 0.2)
    	_sound(this, CH_VOICE, "soldier/idle.wav", 1,  ATTN_IDLE);
	ai_walk(this, 12);
}

//===========================================================================

void axe_chop(entity this, vector dir)
{
	if(!this.enemy)
		return;		// removed before stroke
		
	ai_charge_side(this);

	if(vdist(this.enemy.origin - this.origin, >, 60))
		return;
	if(!CanDamage(this.enemy, this))
		return;
	float ldmg = (random() + random() + random()) * 2;
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_AXEGRUNT.m_id);

	vector toss = v_forward * dir_x + v_right * dir_y + v_up * dir_z;
	this.enemy.velocity = this.enemy.velocity + toss;
}

void axe_runatka6(entity this) { set_animofs(this, anim_axegrunt_axatt, 6, axe_run1); ai_charge_side(this);}
void axe_runatka5(entity this) { set_animofs(this, anim_axegrunt_axatt, 5, axe_runatka6); axe_chop(this, '100 -40 10');}
void axe_runatka4(entity this) { set_animofs(this, anim_axegrunt_axatt, 4, axe_runatka5); axe_chop(this, '50 -20 10');}
void axe_runatka3(entity this) { set_animofs(this, anim_axegrunt_axatt, 3, axe_runatka4); ai_charge(this, 10); axe_chop(this, '0 0 0');}
void axe_runatka2(entity this) { set_animofs(this, anim_axegrunt_axatt, 2, axe_runatka3); ai_charge(this, 20); }
void axe_runatka1(entity this)
{
	set_animofs(this, anim_axegrunt_axatt, 1, axe_runatka2);
	if(random() > 0.5)
		_sound(this, CH_WEAPON_SINGLE, "knight/sword2.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "knight/sword1.wav", 1, ATTN_NORM);
	ai_charge(this, 30);
}

void axe_runatkb6(entity this) { set_animofs(this, anim_axegrunt_axattb, 6, axe_run1); ai_charge_side(this); }
void axe_runatkb5(entity this) { set_animofs(this, anim_axegrunt_axattb, 5, axe_runatkb6); axe_chop(this, '80 150 20'); }
void axe_runatkb4(entity this) { set_animofs(this, anim_axegrunt_axattb, 4, axe_runatkb5); axe_chop(this, '40 75 10'); }
void axe_runatkb3(entity this) { set_animofs(this, anim_axegrunt_axattb, 3, axe_runatkb4); ai_charge(this, 10); axe_chop(this, '0 0 0'); }
void axe_runatkb2(entity this) { set_animofs(this, anim_axegrunt_axattb, 2, axe_runatkb3); ai_charge(this, 20); }
void axe_runatkb1(entity this)
{
	set_animofs(this, anim_axegrunt_axattb, 1, axe_runatkb2);
	if(random() > 0.5)
		_sound(this, CH_WEAPON_SINGLE, "knight/sword2.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "knight/sword1.wav", 1, ATTN_NORM);
	ai_charge(this, 30);
}

void axe_runatkc6(entity this) { set_animofs(this, anim_axegrunt_axattc, 6, axe_run1); ai_charge_side(this); }
void axe_runatkc5(entity this) { set_animofs(this, anim_axegrunt_axattc, 5, axe_runatkc6); axe_chop(this, '120 0 20'); }
void axe_runatkc4(entity this) { set_animofs(this, anim_axegrunt_axattc, 4, axe_runatkc5); axe_chop(this, '60 0 10'); }
void axe_runatkc3(entity this) { set_animofs(this, anim_axegrunt_axattc, 3, axe_runatkc4); ai_charge(this, 10); axe_chop(this, '0 0 0'); }
void axe_runatkc2(entity this) { set_animofs(this, anim_axegrunt_axattc, 2, axe_runatkc3); ai_charge(this, 20); }
void axe_runatkc1(entity this)
{
	set_animofs(this, anim_axegrunt_axattc, 1, axe_runatkc2);
	if(random() > 0.5)
		_sound(this, CH_WEAPON_SINGLE, "knight/sword2.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "knight/sword1.wav", 1, ATTN_NORM);
	ai_charge(this, 30);
}

void axe_runatkd6(entity this) { set_animofs(this, anim_axegrunt_axattd, 6, axe_run1); ai_charge_side(this); }
void axe_runatkd5(entity this) { set_animofs(this, anim_axegrunt_axattd, 5, axe_runatkd6); axe_chop(this, '60 -150 200'); }
void axe_runatkd4(entity this) { set_animofs(this, anim_axegrunt_axattd, 4, axe_runatkd5); axe_chop(this, '30 -75 100'); }
void axe_runatkd3(entity this) { set_animofs(this, anim_axegrunt_axattd, 3, axe_runatkd4); ai_charge(this, 10); axe_chop(this, '0 0 0'); }
void axe_runatkd2(entity this) { set_animofs(this, anim_axegrunt_axattd, 2, axe_runatkd3); ai_charge(this, 20); }
void axe_runatkd1(entity this)
{
	set_animofs(this, anim_axegrunt_axattd, 1, axe_runatkd2);
	if(random() > 0.5)
		_sound(this, CH_WEAPON_SINGLE, "knight/sword2.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "knight/sword1.wav", 1, ATTN_NORM);
	ai_charge(this, 30);
}

void axe_atk(entity this)
{
	if(this.pain_finished > time)
		return;
	this.state = 2; //attacking
	float r = random();
	
	if(r < 0.25)
		axe_runatka1(this);
	else if(r < 0.5)
		axe_runatkb1(this);
	else if(r < 0.75)
		axe_runatkc1(this);
	else
		axe_runatkd1(this);
}


//===========================================================================


void axe_pain6(entity this) { set_animofs(this, anim_axegrunt_axpain, 6, axe_run1); }
void axe_pain5(entity this) { set_animofs(this, anim_axegrunt_axpain, 5, axe_pain6); }
void axe_pain4(entity this) { set_animofs(this, anim_axegrunt_axpain, 4, axe_pain5); }
void axe_pain3(entity this) { set_animofs(this, anim_axegrunt_axpain, 3, axe_pain4); ai_painforward(this, -2);}
void axe_pain2(entity this) { set_animofs(this, anim_axegrunt_axpain, 2, axe_pain3); ai_painforward(this, -1);}
void axe_pain1(entity this) { set_animofs(this, anim_axegrunt_axpain, 1, axe_pain2); }

void axe_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.health < this.max_health * 0.05)
		this.skin = 3;
	else if(this.health < this.max_health * 0.4)
		this.skin = 2;
	else if(this.health < this.max_health * 0.8)
		this.skin = 1;

	if(this.pain_finished > time)
		return;

	_sound(this, CH_VOICE, "axegrunt/axgpain.wav", 1, ATTN_NORM);
	this.state = 3; // pain state
	axe_pain1(this);
	this.pain_finished = time + 0.75;
}

//===========================================================================

void axe_die9(entity this) { set_animofs(this, anim_axegrunt_axdeth, 9, axe_die9); CorpseThink(this); }
void axe_die8(entity this) { set_animofs(this, anim_axegrunt_axdeth, 8, axe_die9); }
void axe_die7(entity this) { set_animofs(this, anim_axegrunt_axdeth, 7, axe_die8); }
void axe_die6(entity this) { set_animofs(this, anim_axegrunt_axdeth, 6, axe_die7); }
void axe_die5(entity this) { set_animofs(this, anim_axegrunt_axdeth, 5, axe_die6); }
void axe_die4(entity this) { set_animofs(this, anim_axegrunt_axdeth, 4, axe_die5); }
void axe_die3(entity this) { set_animofs(this, anim_axegrunt_axdeth, 3, axe_die4); }
void axe_die2(entity this) { set_animofs(this, anim_axegrunt_axdeth, 2, axe_die3); }
void axe_die1(entity this) { set_animofs(this, anim_axegrunt_axdeth, 1, axe_die2); this.solid = SOLID_NOT; }

void axe_diea11(entity this) { set_animofs(this, anim_axegrunt_deatha, 11, axe_diea11); CorpseThink(this); }
void axe_diea10(entity this) { set_animofs(this, anim_axegrunt_deatha, 10, axe_diea11); }
void axe_diea9(entity this) { set_animofs(this, anim_axegrunt_deatha, 9, axe_diea10); }
void axe_diea8(entity this) { set_animofs(this, anim_axegrunt_deatha, 8, axe_diea9); }
void axe_diea7(entity this) { set_animofs(this, anim_axegrunt_deatha, 7, axe_diea8); }
void axe_diea6(entity this) { set_animofs(this, anim_axegrunt_deatha, 6, axe_diea7); }
void axe_diea5(entity this) { set_animofs(this, anim_axegrunt_deatha, 5, axe_diea6); }
void axe_diea4(entity this) { set_animofs(this, anim_axegrunt_deatha, 4, axe_diea5); }
void axe_diea3(entity this) { set_animofs(this, anim_axegrunt_deatha, 3, axe_diea4); }
void axe_diea2(entity this) { set_animofs(this, anim_axegrunt_deatha, 2, axe_diea3); }
void axe_diea1(entity this) { set_animofs(this, anim_axegrunt_deatha, 1, axe_diea2); this.solid = SOLID_NOT; }

void axe_diec15(entity this) { set_animofs(this, anim_axegrunt_deathc, 15, axe_diec15); this.nextthink = time + 0.075; CorpseThink(this); }
void axe_diec14(entity this) { set_animofs(this, anim_axegrunt_deathc, 14, axe_diec15); this.nextthink = time + 0.075; }
void axe_diec13(entity this) { set_animofs(this, anim_axegrunt_deathc, 13, axe_diec14); this.nextthink = time + 0.075; }
void axe_diec12(entity this) { set_animofs(this, anim_axegrunt_deathc, 12, axe_diec13); this.nextthink = time + 0.075; }
void axe_diec11(entity this) { set_animofs(this, anim_axegrunt_deathc, 11, axe_diec12); this.nextthink = time + 0.075; }
void axe_diec10(entity this) { set_animofs(this, anim_axegrunt_deathc, 10, axe_diec11); this.nextthink = time + 0.075; }
void axe_diec9(entity this) { set_animofs(this, anim_axegrunt_deathc, 9, axe_diec10); this.nextthink = time + 0.1; ai_painforward(this, 5); }
void axe_diec8(entity this) { set_animofs(this, anim_axegrunt_deathc, 8, axe_diec9); this.nextthink = time + 0.1; ai_painforward(this, 6); }
void axe_diec7(entity this) { set_animofs(this, anim_axegrunt_deathc, 7, axe_diec8); this.nextthink = time + 0.1; ai_painforward(this, 6); }
void axe_diec6(entity this) { set_animofs(this, anim_axegrunt_deathc, 6, axe_diec7); this.nextthink = time + 0.1; ai_painforward(this, 8); }
void axe_diec5(entity this) { set_animofs(this, anim_axegrunt_deathc, 5, axe_diec6); this.nextthink = time + 0.075; ai_painforward(this, 8); }
void axe_diec4(entity this) { set_animofs(this, anim_axegrunt_deathc, 4, axe_diec5); this.nextthink = time + 0.075; ai_painforward(this, 9); }
void axe_diec3(entity this) { set_animofs(this, anim_axegrunt_deathc, 3, axe_diec4); this.nextthink = time + 0.075; ai_painforward(this, 9); }
void axe_diec2(entity this) { set_animofs(this, anim_axegrunt_deathc, 2, axe_diec3); this.nextthink = time + 0.075; ai_painforward(this, 12); }
void axe_diec1(entity this) { set_animofs(this, anim_axegrunt_deathc, 1, axe_diec2); this.nextthink = time + 0.075; ai_painforward(this, 12); this.solid = SOLID_NOT; }

void axe_died9(entity this) { set_animofs(this, anim_axegrunt_deathd, 9, axe_died9); CorpseThink(this); }
void axe_died8(entity this) { set_animofs(this, anim_axegrunt_deathd, 8, axe_died9); }
void axe_died7(entity this) { set_animofs(this, anim_axegrunt_deathd, 7, axe_died8); }
void axe_died6(entity this) { set_animofs(this, anim_axegrunt_deathd, 6, axe_died7); }
void axe_died5(entity this) { set_animofs(this, anim_axegrunt_deathd, 5, axe_died6); }
void axe_died4(entity this) { set_animofs(this, anim_axegrunt_deathd, 4, axe_died5); }
void axe_died3(entity this) { set_animofs(this, anim_axegrunt_deathd, 3, axe_died4); }
void axe_died2(entity this) { set_animofs(this, anim_axegrunt_deathd, 2, axe_died3); }
void axe_died1(entity this) { set_animofs(this, anim_axegrunt_deathd, 1, axe_died2); this.solid = SOLID_NOT; }

void axe_diee9(entity this) { set_animofs(this, anim_axegrunt_deathe, 9, axe_diee9); CorpseThink(this); }
void axe_diee8(entity this) { set_animofs(this, anim_axegrunt_deathe, 8, axe_diee9); }
void axe_diee7(entity this) { set_animofs(this, anim_axegrunt_deathe, 7, axe_diee8); }
void axe_diee6(entity this) { set_animofs(this, anim_axegrunt_deathe, 6, axe_diee7); }
void axe_diee5(entity this) { set_animofs(this, anim_axegrunt_deathe, 5, axe_diee6); }
void axe_diee4(entity this) { set_animofs(this, anim_axegrunt_deathe, 4, axe_diee5); }
void axe_diee3(entity this) { set_animofs(this, anim_axegrunt_deathe, 3, axe_diee4); }
void axe_diee2(entity this) { set_animofs(this, anim_axegrunt_deathe, 2, axe_diee3); }
void axe_diee1(entity this) { set_animofs(this, anim_axegrunt_deathe, 1, axe_diee2); this.solid = SOLID_NOT; }

void axe_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(this.health < -30)
	{
		this.skin = 0;
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, "progs/h_guard.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib2.mdl", this.health);
		ThrowGib(this, "progs/gib3.mdl", this.health);
		ThrowGib(this, "progs/gib3.mdl", this.health);
		return;
	}

	this.skin = 3;
	float rnd = random();

	_sound(this, CH_VOICE, "axegrunt/axgdeath.wav", 1, ATTN_NORM);
	
	if((this.state == 2) && this.health < -15)
		axe_diec1(this);
	else if(rnd < 0.25)
		axe_die1(this);
	else if(rnd < 0.50)
		axe_diea1(this);
	else if(rnd < 0.75)
		axe_died1(this);
	else
		axe_diee1(this);
}

/*QUAKED monster_axegrunt (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_axegrunt) { monster_start(this, true, MON_AXEGRUNT); }
#endif // SVQC

#ifdef SVQC
METHOD(AxeGrunt, mr_setup, bool(AxeGrunt this, entity actor))
{
    TC(AxeGrunt, this);

	precache_sound("axegrunt/axgdeath.wav");
	precache_sound("axegrunt/axgpain.wav");
	precache_sound("axegrunt/axgsight.wav");
	precache_sound("knight/sword1.wav");
	precache_sound("knight/sword2.wav");
	precache_sound("knight/idle.wav");
	precache_sound("soldier/idle.wav");

    actor.health = 75;
    actor.th_stand = axe_stand1;
	actor.th_walk = axe_walk1;
	actor.th_run = axe_run1;
	actor.th_melee = axe_atk;
	actor.th_pain = axe_pain;
	actor.th_die = axe_die;

    return true;
}
#endif
