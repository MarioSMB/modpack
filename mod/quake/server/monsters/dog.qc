/*
==============================================================================

DOG

==============================================================================
*/

$cd id1/models/dog
$origin 0 0 24
$base base
$skin skin

const int anim_dog_attack1 = 0;
const int anim_dog_attack2 = 1;
const int anim_dog_attack3 = 2;
const int anim_dog_attack4 = 3;
const int anim_dog_attack5 = 4;
const int anim_dog_attack6 = 5;
const int anim_dog_attack7 = 6;
const int anim_dog_attack8 = 7;

const int anim_dog_death1 = 8;
const int anim_dog_death2 = 9;
const int anim_dog_death3 = 10;
const int anim_dog_death4 = 11;
const int anim_dog_death5 = 12;
const int anim_dog_death6 = 13;
const int anim_dog_death7 = 14;
const int anim_dog_death8 = 15;
const int anim_dog_death9 = 16;

const int anim_dog_deathb1 = 17;
const int anim_dog_deathb2 = 18;
const int anim_dog_deathb3 = 19;
const int anim_dog_deathb4 = 20;
const int anim_dog_deathb5 = 21;
const int anim_dog_deathb6 = 22;
const int anim_dog_deathb7 = 23;
const int anim_dog_deathb8 = 24;
const int anim_dog_deathb9 = 25;

const int anim_dog_pain1 = 26;
const int anim_dog_pain2 = 27;
const int anim_dog_pain3 = 28;
const int anim_dog_pain4 = 29;
const int anim_dog_pain5 = 30;
const int anim_dog_pain6 = 31;

const int anim_dog_painb1 = 32;
const int anim_dog_painb2 = 33;
const int anim_dog_painb3 = 34;
const int anim_dog_painb4 = 35;
const int anim_dog_painb5 = 36;
const int anim_dog_painb6 = 37;
const int anim_dog_painb7 = 38;
const int anim_dog_painb8 = 39;
const int anim_dog_painb9 = 40;
const int anim_dog_painb10 = 41;

const int anim_dog_painb11 = 42;
const int anim_dog_painb12 = 43;
const int anim_dog_painb13 = 44;
const int anim_dog_painb14 = 45;
const int anim_dog_painb15 = 46;
const int anim_dog_painb16 = 47;

const int anim_dog_run1 = 48;
const int anim_dog_run2 = 49;
const int anim_dog_run3 = 50;
const int anim_dog_run4 = 51;
const int anim_dog_run5 = 52;
const int anim_dog_run6 = 53;
const int anim_dog_run7 = 54;
const int anim_dog_run8 = 55;
const int anim_dog_run9 = 56;
const int anim_dog_run10 = 57;
const int anim_dog_run11 = 58;
const int anim_dog_run12 = 59;

const int anim_dog_leap1 = 60;
const int anim_dog_leap2 = 61;
const int anim_dog_leap3 = 62;
const int anim_dog_leap4 = 63;
const int anim_dog_leap5 = 64;
const int anim_dog_leap6 = 65;
const int anim_dog_leap7 = 66;
const int anim_dog_leap8 = 67;
const int anim_dog_leap9 = 68;

const int anim_dog_stand1 = 69;
const int anim_dog_stand2 = 70;
const int anim_dog_stand3 = 71;
const int anim_dog_stand4 = 72;
const int anim_dog_stand5 = 73;
const int anim_dog_stand6 = 74;
const int anim_dog_stand7 = 75;
const int anim_dog_stand8 = 76;
const int anim_dog_stand9 = 77;

const int anim_dog_walk1 = 78;
const int anim_dog_walk2 = 79;
const int anim_dog_walk3 = 80;
const int anim_dog_walk4 = 81;
const int anim_dog_walk5 = 82;
const int anim_dog_walk6 = 83;
const int anim_dog_walk7 = 84;
const int anim_dog_walk8 = 85;


void dog_leap1(entity this);
void dog_run1(entity this);

/*
================
dog_bite

================
*/
void dog_bite(entity this)
{
	if(!this.enemy)
		return;

	ai_charge(this, 10);

	if(!CanDamage(this.enemy, this))
		return;

	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
		
	float ldmg =(random() + random() + random()) * 8;
	T_Damage(this.enemy, this, this, ldmg);
}

void Dog_JumpTouch(entity this, entity toucher)
{
	if(this.health <= 0)
		return;
		
	if(toucher.takedamage)
	{
		if(vdist(this.velocity, >, 300))
		{
			float ldmg = 10 + 10*random();
			T_Damage(toucher, this, this, ldmg);	
		}
	}

	if(!checkbottom(this))
	{
		if(this.flags & FL_ONGROUND)
		{	// jump randomly to not get hung up
			//dprint("popjump\n");
			settouch(this, func_null);
			setthink(this, dog_leap1);
			this.nextthink = time + 0.1;

//			this.velocity_x =(random() - 0.5) * 600;
//			this.velocity_y =(random() - 0.5) * 600;
//			this.velocity_z = 200;
//			this.flags = this.flags - FL_ONGROUND;
		}
		return;	// not on ground yet
	}

	settouch(this, func_null);
	setthink(this, dog_run1);
	this.nextthink = time + 0.1;
}

void dog_stand1(entity this);
void dog_stand9(entity this) { set_anim(this, anim_dog_stand9, dog_stand1); ai_stand(this); }
void dog_stand8(entity this) { set_anim(this, anim_dog_stand8, dog_stand9); ai_stand(this); }
void dog_stand7(entity this) { set_anim(this, anim_dog_stand7, dog_stand8); ai_stand(this); }
void dog_stand6(entity this) { set_anim(this, anim_dog_stand6, dog_stand7); ai_stand(this); }
void dog_stand5(entity this) { set_anim(this, anim_dog_stand5, dog_stand6); ai_stand(this); }
void dog_stand4(entity this) { set_anim(this, anim_dog_stand4, dog_stand5); ai_stand(this); }
void dog_stand3(entity this) { set_anim(this, anim_dog_stand3, dog_stand4); ai_stand(this); }
void dog_stand2(entity this) { set_anim(this, anim_dog_stand2, dog_stand3); ai_stand(this); }
void dog_stand1(entity this) { set_anim(this, anim_dog_stand1, dog_stand2); ai_stand(this); }

void dog_walk1(entity this);
void dog_walk8(entity this) { set_anim(this, anim_dog_walk8, dog_walk1); ai_walk(this, 8); }
void dog_walk7(entity this) { set_anim(this, anim_dog_walk7, dog_walk8); ai_walk(this, 8); }
void dog_walk6(entity this) { set_anim(this, anim_dog_walk6, dog_walk7); ai_walk(this, 8); }
void dog_walk5(entity this) { set_anim(this, anim_dog_walk5, dog_walk6); ai_walk(this, 8); }
void dog_walk4(entity this) { set_anim(this, anim_dog_walk4, dog_walk5); ai_walk(this, 8); }
void dog_walk3(entity this) { set_anim(this, anim_dog_walk3, dog_walk4); ai_walk(this, 8); }
void dog_walk2(entity this) { set_anim(this, anim_dog_walk2, dog_walk3); ai_walk(this, 8); }
void dog_walk1(entity this)
{
	set_anim(this, anim_dog_walk1, dog_walk2);
	if(random() < 0.2)
		_sound(this, CHAN_VOICE, "dog/idle.wav", 1, ATTN_IDLE);
	ai_walk(this, 8);
}

void dog_run1(entity this);
void dog_run12(entity this) { set_anim(this, anim_dog_run12, dog_run1); ai_run(this, 32); }
void dog_run11(entity this) { set_anim(this, anim_dog_run11, dog_run12); ai_run(this, 64); }
void dog_run10(entity this) { set_anim(this, anim_dog_run10, dog_run11); ai_run(this, 20); }
void dog_run9(entity this) { set_anim(this, anim_dog_run9, dog_run10); ai_run(this, 32); }
void dog_run8(entity this) { set_anim(this, anim_dog_run8, dog_run9); ai_run(this, 32); }
void dog_run7(entity this) { set_anim(this, anim_dog_run7, dog_run8); ai_run(this, 16); }
void dog_run6(entity this) { set_anim(this, anim_dog_run6, dog_run7); ai_run(this, 32); }
void dog_run5(entity this) { set_anim(this, anim_dog_run5, dog_run6); ai_run(this, 64); }
void dog_run4(entity this) { set_anim(this, anim_dog_run4, dog_run5); ai_run(this, 20); }
void dog_run3(entity this) { set_anim(this, anim_dog_run3, dog_run4); ai_run(this, 32); }
void dog_run2(entity this) { set_anim(this, anim_dog_run2, dog_run3); ai_run(this, 32); }
void dog_run1(entity this)
{
	set_anim(this, anim_dog_run1, dog_run2);
	if(random() < 0.2)
		_sound(this, CHAN_VOICE, "dog/idle.wav", 1, ATTN_IDLE);
	ai_run(this, 16);
}

void dog_atta8(entity this) { set_anim(this, anim_dog_attack8, dog_run1); ai_charge(this, 10); }
void dog_atta7(entity this) { set_anim(this, anim_dog_attack7, dog_atta8); ai_charge(this, 10); }
void dog_atta6(entity this) { set_anim(this, anim_dog_attack6, dog_atta7); ai_charge(this, 10); }
void dog_atta5(entity this) { set_anim(this, anim_dog_attack5, dog_atta6); ai_charge(this, 10); }
void dog_atta4(entity this)
{
	set_anim(this, anim_dog_attack4, dog_atta5);
	dog_bite(this);
}
void dog_atta3(entity this) { set_anim(this, anim_dog_attack3, dog_atta4); ai_charge(this, 10); }
void dog_atta2(entity this) { set_anim(this, anim_dog_attack2, dog_atta3); ai_charge(this, 10); }
void dog_atta1(entity this) { set_anim(this, anim_dog_attack1, dog_atta2); ai_charge(this, 10); }


void dog_leap9(entity this) { set_anim(this, anim_dog_leap9, dog_leap9); }
void dog_leap8(entity this) { set_anim(this, anim_dog_leap8, dog_leap9); }
void dog_leap7(entity this) { set_anim(this, anim_dog_leap7, dog_leap8); }
void dog_leap6(entity this) { set_anim(this, anim_dog_leap6, dog_leap7); }
void dog_leap5(entity this) { set_anim(this, anim_dog_leap5, dog_leap6); }
void dog_leap4(entity this) { set_anim(this, anim_dog_leap4, dog_leap5); }
void dog_leap3(entity this) { set_anim(this, anim_dog_leap3, dog_leap4); }
void dog_leap2(entity this) { set_anim(this, anim_dog_leap2, dog_leap3); ai_face(this); }
void dog_leap1(entity this)
{
	set_anim(this, anim_dog_leap1, dog_leap2);
	ai_face(this);

	settouch(this, Dog_JumpTouch);
	makevectors(this.angles);
	this.origin_z = this.origin_z + 1;
	this.velocity = v_forward * 300 + '0 0 200';
	this.flags &= ~FL_ONGROUND;
}

void dog_pain6(entity this) { set_anim(this, anim_dog_pain6, dog_run1); }
void dog_pain5(entity this) { set_anim(this, anim_dog_pain5, dog_pain6); }
void dog_pain4(entity this) { set_anim(this, anim_dog_pain4, dog_pain5); }
void dog_pain3(entity this) { set_anim(this, anim_dog_pain3, dog_pain4); }
void dog_pain2(entity this) { set_anim(this, anim_dog_pain2, dog_pain3); }
void dog_pain1(entity this) { set_anim(this, anim_dog_pain1, dog_pain2); }

void dog_painb16(entity this) { set_anim(this, anim_dog_painb16, dog_run1); }
void dog_painb15(entity this) { set_anim(this, anim_dog_painb15, dog_painb16); }
void dog_painb14(entity this) { set_anim(this, anim_dog_painb14, dog_painb15); }
void dog_painb13(entity this) { set_anim(this, anim_dog_painb13, dog_painb14); }
void dog_painb12(entity this) { set_anim(this, anim_dog_painb12, dog_painb13); }
void dog_painb11(entity this) { set_anim(this, anim_dog_painb11, dog_painb12); }
void dog_painb10(entity this) { set_anim(this, anim_dog_painb10, dog_painb11); ai_pain(this, 10); }
void dog_painb9(entity this) { set_anim(this, anim_dog_painb9, dog_painb10); }
void dog_painb8(entity this) { set_anim(this, anim_dog_painb8, dog_painb9); ai_pain(this, 4); }
void dog_painb7(entity this) { set_anim(this, anim_dog_painb7, dog_painb8); }
void dog_painb6(entity this) { set_anim(this, anim_dog_painb6, dog_painb7); ai_pain(this, 2); }
void dog_painb5(entity this) { set_anim(this, anim_dog_painb5, dog_painb6); ai_pain(this, 12); }
void dog_painb4(entity this) { set_anim(this, anim_dog_painb4, dog_painb5); ai_pain(this, 12); }
void dog_painb3(entity this) { set_anim(this, anim_dog_painb3, dog_painb4); ai_pain(this, 4); }
void dog_painb2(entity this) { set_anim(this, anim_dog_painb2, dog_painb3); }
void dog_painb1(entity this) { set_anim(this, anim_dog_painb1, dog_painb2); }

void dog_pain(entity this, entity attacker, float damage)
{
	_sound(this, CHAN_VOICE, "dog/dpain1.wav", 1, ATTN_NORM);

	if(random() > 0.5)
		dog_pain1(this);
	else
		dog_painb1(this);
}

void dog_die9(entity this) { set_anim(this, anim_dog_death9, dog_die9); }
void dog_die8(entity this) { set_anim(this, anim_dog_death8, dog_die9); }
void dog_die7(entity this) { set_anim(this, anim_dog_death7, dog_die8); }
void dog_die6(entity this) { set_anim(this, anim_dog_death6, dog_die7); }
void dog_die5(entity this) { set_anim(this, anim_dog_death5, dog_die6); }
void dog_die4(entity this) { set_anim(this, anim_dog_death4, dog_die5); }
void dog_die3(entity this) { set_anim(this, anim_dog_death3, dog_die4); }
void dog_die2(entity this) { set_anim(this, anim_dog_death2, dog_die3); }
void dog_die1(entity this) { set_anim(this, anim_dog_death1, dog_die2); }

void dog_dieb9(entity this) { set_anim(this, anim_dog_deathb9, dog_dieb9); }
void dog_dieb8(entity this) { set_anim(this, anim_dog_deathb8, dog_dieb9); }
void dog_dieb7(entity this) { set_anim(this, anim_dog_deathb7, dog_dieb8); }
void dog_dieb6(entity this) { set_anim(this, anim_dog_deathb6, dog_dieb7); }
void dog_dieb5(entity this) { set_anim(this, anim_dog_deathb5, dog_dieb6); }
void dog_dieb4(entity this) { set_anim(this, anim_dog_deathb4, dog_dieb5); }
void dog_dieb3(entity this) { set_anim(this, anim_dog_deathb3, dog_dieb4); }
void dog_dieb2(entity this) { set_anim(this, anim_dog_deathb2, dog_dieb3); }
void dog_dieb1(entity this) { set_anim(this, anim_dog_deathb1, dog_dieb2); }

void dog_die(entity this, entity attacker)
{
// check for gib
	if(this.health < -35)
	{
		_sound(this, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowGib(this, "progs/gib3.mdl", this.health);
		ThrowGib(this, "progs/gib3.mdl", this.health);
		ThrowGib(this, "progs/gib3.mdl", this.health);
		ThrowHead(this, "progs/h_dog.mdl", this.health);
		return;
	}

// regular death
	_sound(this, CHAN_VOICE, "dog/ddeath.wav", 1, ATTN_NORM);
	this.solid = SOLID_NOT;

	if(random() > 0.5)
		dog_die1(this);
	else
		dog_dieb1(this);
}

//============================================================================

/*
==============
CheckDogMelee

Returns true if a melee attack would hit right now
==============
*/
bool CheckDogMelee(entity this)
{
	if(this.enemy_range == RANGE_MELEE)
	{	// FIXME: check canreach
		this.attack_state = AS_MELEE;
		return true;
	}
	return false;
}

/*
==============
CheckDogJump

==============
*/
bool CheckDogJump(entity this)
{
	if(this.origin_z + this.mins_z > this.enemy.origin_z + this.enemy.mins_z
	+ 0.75 * this.enemy.size_z)
		return false;
		
	if(this.origin_z + this.maxs_z < this.enemy.origin_z + this.enemy.mins_z
	+ 0.25 * this.enemy.size_z)
		return false;
		
	vector dist = vec2(this.enemy.origin - this.origin);
	
	if(vdist(dist, <, 80))
		return false;
		
	if(vdist(dist, >, 150))
		return false;
		
	return true;
}

bool DogCheckAttack(entity this)
{
// if close enough for slashing, go for it
	if(CheckDogMelee(this))
	{
		this.attack_state = AS_MELEE;
		return true;
	}
	
	if(CheckDogJump(this))
	{
		this.attack_state = AS_MISSILE;
		return true;
	}
	
	return false;
}

string dog_sight(entity this) { return "dog/dsight.wav"; }
string dog_deathmessage(entity this) { return "was mauled by a Rottweiler"; }

//===========================================================================

/*QUAKED monster_dog(1 0 0)(-32 -32 -24)(32 32 40) Ambush

*/
spawnfunc(monster_dog)
{
	if(deathmatch)
	{
		delete(this);
		return;
	}
	precache_model("progs/h_dog.mdl");
	precache_model("progs/dog.mdl");

	precache_sound("dog/dattack1.wav");
	precache_sound("dog/ddeath.wav");
	precache_sound("dog/dpain1.wav");
	precache_sound("dog/dsight.wav");
	precache_sound("dog/idle.wav");

	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);

	_setmodel(this, "progs/dog.mdl");

	setsize(this, '-32 -32 -24', '32 32 40');
	this.health = 25;

	this.th_stand = dog_stand1;
	this.th_walk = dog_walk1;
	this.th_run = dog_run1;
	this.th_pain = dog_pain;
	this.th_die = dog_die;
	this.th_melee = dog_atta1;
	this.th_missile = dog_leap1;

	this.sightsound = dog_sight;
	this.checkattack = DogCheckAttack;
	this.deathmessage = dog_deathmessage;

	walkmonster_start(this);
}
