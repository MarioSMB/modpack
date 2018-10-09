$cd /qwork/xpack/models/sword
$origin 0 0 24
$base base
$skin badass3


const int anim_sword_stand1 = 0;
//$stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9

const int anim_sword_runb1 = 1;
const int anim_sword_runb2 = 2;
const int anim_sword_runb3 = 3;
const int anim_sword_runb4 = 4;
const int anim_sword_runb5 = 5;
const int anim_sword_runb6 = 6;
const int anim_sword_runb7 = 7;
const int anim_sword_runb8 = 8;

//frame runc1 runc2 runc3 runc4 runc5 runc6

//$frame runattack1 runattack2 runattack3 runattack4 runattack5
//$frame runattack6 runattack7 runattack8 runattack9 runattack10
//$frame runattack11

//$frame pain1 pain2 pain3

//$frame painb1 painb2 painb3 painb4 painb5 painb6 painb7 painb8 painb9
//$frame painb10 painb11

//frame attack1 attack2 attack3 attack4 attack5 attack6 attack7
//frame attack8 attack9 attack10 attack11

const int anim_sword_attackb1 = 9;
const int anim_sword_attackb2 = 10;
const int anim_sword_attackb3 = 11;
const int anim_sword_attackb4 = 12;
const int anim_sword_attackb5 = 13;
const int anim_sword_attackb6 = 14;
const int anim_sword_attackb7 = 15;
const int anim_sword_attackb8 = 16;
const int anim_sword_attackb9 = 17;
const int anim_sword_attackb10 = 18;

//$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9
//$frame walk10 walk11 walk12 walk13 walk14

//$frame kneel1 kneel2 kneel3 kneel4 kneel5

//$frame standing2 standing3 standing4 standing5

const int anim_sword_death1 = 19;
const int anim_sword_death2 = 20;
const int anim_sword_death3 = 21;
const int anim_sword_death4 = 22;
const int anim_sword_death5 = 23;
const int anim_sword_death6 = 24;
const int anim_sword_death7 = 25;
const int anim_sword_death8 = 26;
const int anim_sword_death9 = 27;
const int anim_sword_death10 = 28;

const int anim_sword_deathb1 = 29;
const int anim_sword_deathb2 = 30;
const int anim_sword_deathb3 = 31;
const int anim_sword_deathb4 = 32;
const int anim_sword_deathb5 = 33;
const int anim_sword_deathb6 = 34;
const int anim_sword_deathb7 = 35;
const int anim_sword_deathb8 = 36;
const int anim_sword_deathb9 = 37;
const int anim_sword_deathb10 = 38;
const int anim_sword_deathb11 = 39;

void sword_stand1(entity this) { set_anim(this, anim_sword_stand1, sword_stand1); ai_stand(this); }

void sword_run1(entity this);
void sword_run8(entity this) { set_anim(this, anim_sword_runb8, sword_run1); ai_run(this, 14); }
void sword_run7(entity this) { set_anim(this, anim_sword_runb7, sword_run8); ai_run(this, 14); }
void sword_run6(entity this) { set_anim(this, anim_sword_runb6, sword_run7); ai_run(this, 14); }
void sword_run5(entity this) { set_anim(this, anim_sword_runb5, sword_run6); ai_run(this, 14); }
void sword_run4(entity this) { set_anim(this, anim_sword_runb4, sword_run5); ai_run(this, 14); }
void sword_run3(entity this) { set_anim(this, anim_sword_runb3, sword_run4); ai_run(this, 14); }
void sword_run2(entity this) { set_anim(this, anim_sword_runb2, sword_run3); ai_run(this, 14); }
void sword_run1(entity this) { set_anim(this, anim_sword_runb1, sword_run2); this.effects = EF_DIMLIGHT; ai_run(this, 14); }

void sword_atk10(entity this) { set_anim(this, anim_sword_attackb10, sword_run1); ai_charge(this, 14); }
void sword_atk9(entity this) { set_anim(this, anim_sword_attackb9, sword_atk10); ai_charge(this, 14); }
void sword_atk8(entity this) { set_anim(this, anim_sword_attackb8, sword_atk9); ai_charge(this, 14); }
void sword_atk7(entity this) { set_anim(this, anim_sword_attackb7, sword_atk8); ai_melee(this); }
void sword_atk6(entity this) { set_anim(this, anim_sword_attackb6, sword_atk7); ai_melee(this); }
void sword_atk5(entity this) { set_anim(this, anim_sword_attackb5, sword_atk6); ai_melee(this); }
void sword_atk4(entity this) { set_anim(this, anim_sword_attackb4, sword_atk5); ai_charge(this, 14); }
void sword_atk3(entity this) { set_anim(this, anim_sword_attackb3, sword_atk4); ai_charge(this, 14); }
void sword_atk2(entity this) { set_anim(this, anim_sword_attackb2, sword_atk3); ai_charge(this, 14); }
void sword_atk1(entity this) { set_anim(this, anim_sword_attackb1, sword_atk2); _sound(this, 0, "knight/sword1.wav", 1, 1); ai_charge(this, 14); }

//===========================================================================

void sword_die10(entity this) { set_anim(this, anim_sword_death10, sword_die10); }
void sword_die9(entity this) { set_anim(this, anim_sword_death9, sword_die10); }
void sword_die8(entity this) { set_anim(this, anim_sword_death8, sword_die9); }
void sword_die7(entity this) { set_anim(this, anim_sword_death7, sword_die8); _sound(this, 1, "player/axhit2.wav", 0.5, ATTN_NORM); }
void sword_die6(entity this) { set_anim(this, anim_sword_death6, sword_die7); }
void sword_die5(entity this) { set_anim(this, anim_sword_death5, sword_die6); }
void sword_die4(entity this) { set_anim(this, anim_sword_death4, sword_die5); }
void sword_die3(entity this) { set_anim(this, anim_sword_death3, sword_die4); this.solid = SOLID_NOT; }
void sword_die2(entity this) { set_anim(this, anim_sword_death2, sword_die3); }
void sword_die1(entity this) { set_anim(this, anim_sword_death1, sword_die2); }

void sword_dieb11(entity this) { set_anim(this, anim_sword_deathb11, sword_dieb11); }
void sword_dieb10(entity this) { set_anim(this, anim_sword_deathb10, sword_dieb11); }
void sword_dieb9(entity this) { set_anim(this, anim_sword_deathb9, sword_dieb10); }
void sword_dieb8(entity this) { set_anim(this, anim_sword_deathb8, sword_dieb9); }
void sword_dieb7(entity this) { set_anim(this, anim_sword_deathb7, sword_dieb8); _sound(this, 1, "player/axhit2.wav", 0.5, ATTN_NORM); }
void sword_dieb6(entity this) { set_anim(this, anim_sword_deathb6, sword_dieb7); }
void sword_dieb5(entity this) { set_anim(this, anim_sword_deathb5, sword_dieb6); }
void sword_dieb4(entity this) { set_anim(this, anim_sword_deathb4, sword_dieb5); }
void sword_dieb3(entity this) { set_anim(this, anim_sword_deathb3, sword_dieb4); this.solid = SOLID_NOT; }
void sword_dieb2(entity this) { set_anim(this, anim_sword_deathb2, sword_dieb3); }
void sword_dieb1(entity this) { set_anim(this, anim_sword_deathb1, sword_dieb2); }

void sword_die(entity this, entity attacker)
{
// regular death
	this.effects = 0;
	if(random() < 0.5)
		sword_die1(this);
	else
		sword_dieb1(this);
}

void sword_pause(entity this)
{
	this.th_run = sword_run1; 
	setthink(this, sword_run1);
	this.nextthink = time + this.delay;
	this.delay = 0;
}

void sword_pain(entity this, entity attacker, float damage)
{
	this.th_run = sword_run1; 
	setthink(this, sword_run1);
	this.nextthink = time + 0.1;
	this.delay = 0;
	this.th_pain = func_null;
}

string sword_deathmessage(entity this) { return "was slit open by a Phantom Swordsman"; }


/*QUAKED monster_sword (1 0 0) (-16 -16 -24) (16 16 40) Ambush
The Invisible Swordsman

delay - seconds after first sighting before it attacks (default 10)
*/
spawnfunc(monster_sword)
{
	if(deathmatch) { delete(this); return; }
	
	precache_model("progs/sword.mdl");

	precache_sound("knight/sword1.wav");
	precache_sound("knight/ksight.wav");
	precache_sound("player/axhit2.wav");
	
	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);

	_setmodel(this, "progs/sword.mdl");

	setsize(this, '-16 -16 -24', '16 16 40');
	this.health = 150;  // 75;

	if(!this.delay)
		this.delay = 10;
		
	this.th_stand = sword_stand1;
//	this.th_walk = sword_walk1;
	this.th_walk = sword_stand1;
	this.th_run = sword_pause;
	this.th_melee = sword_atk1;
	this.th_die = sword_die;
	this.th_pain = sword_pain;
	this.deathmessage = sword_deathmessage;

	monster_start(this, 0);
}
