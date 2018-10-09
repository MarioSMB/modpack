/*
==============================================================================

DEMON

==============================================================================
*/

$cd id1/models/demon3
$scale	0.8
$origin 0 0 24
$base base
$skin base

#if 0
const int anim_demon_stand1 = 0;
const int anim_demon_stand2 = 1;
const int anim_demon_stand3 = 2;
const int anim_demon_stand4 = 3;
const int anim_demon_stand5 = 4;
const int anim_demon_stand6 = 5;
const int anim_demon_stand7 = 6;
const int anim_demon_stand8 = 7;
const int anim_demon_stand9 = 8;
const int anim_demon_stand10 = 9;
const int anim_demon_stand11 = 10;
const int anim_demon_stand12 = 11;
const int anim_demon_stand13 = 12;

const int anim_demon_walk1 = 13;
const int anim_demon_walk2 = 14;
const int anim_demon_walk3 = 15;
const int anim_demon_walk4 = 16;
const int anim_demon_walk5 = 17;
const int anim_demon_walk6 = 18;
const int anim_demon_walk7 = 19;
const int anim_demon_walk8 = 20;

const int anim_demon_run1 = 21;
const int anim_demon_run2 = 22;
const int anim_demon_run3 = 23;
const int anim_demon_run4 = 24;
const int anim_demon_run5 = 25;
const int anim_demon_run6 = 26;

const int anim_demon_leap1 = 27;
const int anim_demon_leap2 = 28;
const int anim_demon_leap3 = 29;
const int anim_demon_leap4 = 30;
const int anim_demon_leap5 = 31;
const int anim_demon_leap6 = 32;
const int anim_demon_leap7 = 33;
const int anim_demon_leap8 = 34;
const int anim_demon_leap9 = 35;
const int anim_demon_leap10 = 36;
const int anim_demon_leap11 = 37;
const int anim_demon_leap12 = 38;

const int anim_demon_pain1 = 39;
const int anim_demon_pain2 = 40;
const int anim_demon_pain3 = 41;
const int anim_demon_pain4 = 42;
const int anim_demon_pain5 = 43;
const int anim_demon_pain6 = 44;

const int anim_demon_death1 = 45;
const int anim_demon_death2 = 46;
const int anim_demon_death3 = 47;
const int anim_demon_death4 = 48;
const int anim_demon_death5 = 49;
const int anim_demon_death6 = 50;
const int anim_demon_death7 = 51;
const int anim_demon_death8 = 52;
const int anim_demon_death9 = 53;

const int anim_demon_attacka1 = 54;
const int anim_demon_attacka2 = 55;
const int anim_demon_attacka3 = 56;
const int anim_demon_attacka4 = 57;
const int anim_demon_attacka5 = 58;
const int anim_demon_attacka6 = 59;
const int anim_demon_attacka7 = 60;
const int anim_demon_attacka8 = 61;
const int anim_demon_attacka9 = 62;
const int anim_demon_attacka10 = 63;
const int anim_demon_attacka11 = 64;
const int anim_demon_attacka12 = 65;
const int anim_demon_attacka13 = 66;
const int anim_demon_attacka14 = 67;
const int anim_demon_attacka15 = 68;
#endif

const int anim_demon_stand = 0; //'0 12 0'
const int anim_demon_walk = 13; //'13 20 0'
const int anim_demon_run = 21; //'21 26 0'
const int anim_demon_leap = 27; //'27 38 0'
const int anim_demon_pain = 39; //'39 44 0'
const int anim_demon_death = 45; //'45 53 0'
const int anim_demon_attacka = 54; //'54 68 0'


//============================================================================

void Demon_JumpTouch(entity this, entity toucher);

void demon1_stand1(entity this);
void demon1_stand13(entity this) { set_animofs(this, anim_demon_stand, 1, demon1_stand1); ai_stand(this); }
void demon1_stand12(entity this) { set_animofs(this, anim_demon_stand, 12, demon1_stand13); ai_stand(this); }
void demon1_stand11(entity this) { set_animofs(this, anim_demon_stand, 11, demon1_stand12); ai_stand(this); }
void demon1_stand10(entity this) { set_animofs(this, anim_demon_stand, 10, demon1_stand11); ai_stand(this); }
void demon1_stand9(entity this) { set_animofs(this, anim_demon_stand, 9, demon1_stand10); ai_stand(this); }
void demon1_stand8(entity this) { set_animofs(this, anim_demon_stand, 8, demon1_stand9); ai_stand(this); }
void demon1_stand7(entity this) { set_animofs(this, anim_demon_stand, 7, demon1_stand8); ai_stand(this); }
void demon1_stand6(entity this) { set_animofs(this, anim_demon_stand, 6, demon1_stand7); ai_stand(this); }
void demon1_stand5(entity this) { set_animofs(this, anim_demon_stand, 5, demon1_stand6); ai_stand(this); }
void demon1_stand4(entity this) { set_animofs(this, anim_demon_stand, 4, demon1_stand5); ai_stand(this); }
void demon1_stand3(entity this) { set_animofs(this, anim_demon_stand, 3, demon1_stand4); ai_stand(this); }
void demon1_stand2(entity this) { set_animofs(this, anim_demon_stand, 2, demon1_stand3); ai_stand(this); }
void demon1_stand1(entity this) { set_animofs(this, anim_demon_stand, 1, demon1_stand2); ai_stand(this); }

void demon1_walk1(entity this);
void demon1_walk8(entity this) { set_animofs(this, anim_demon_walk, 8, demon1_walk1); ai_walk(this, 10); }
void demon1_walk7(entity this) { set_animofs(this, anim_demon_walk, 7, demon1_walk8); ai_walk(this, 10); }
void demon1_walk6(entity this) { set_animofs(this, anim_demon_walk, 6, demon1_walk7); ai_walk(this, 6); }
void demon1_walk5(entity this) { set_animofs(this, anim_demon_walk, 5, demon1_walk6); ai_walk(this, 4); }
void demon1_walk4(entity this) { set_animofs(this, anim_demon_walk, 4, demon1_walk5); ai_walk(this, 7); }
void demon1_walk3(entity this) { set_animofs(this, anim_demon_walk, 3, demon1_walk4); ai_walk(this, 6); }
void demon1_walk2(entity this) { set_animofs(this, anim_demon_walk, 2, demon1_walk3); ai_walk(this, 6); }
void demon1_walk1(entity this)
{
	set_animofs(this, anim_demon_walk, 1, demon1_walk2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "demon/idle1.wav", 1, ATTN_IDLE);
	ai_walk(this, 8);
}

void demon1_run1(entity this);
void demon1_run6(entity this) { set_animofs(this, anim_demon_run, 6, demon1_run1); ai_run(this, 36); }
void demon1_run5(entity this) { set_animofs(this, anim_demon_run, 5, demon1_run6); ai_run(this, 15); }
void demon1_run4(entity this) { set_animofs(this, anim_demon_run, 4, demon1_run5); ai_run(this, 20); }
void demon1_run3(entity this) { set_animofs(this, anim_demon_run, 3, demon1_run4); ai_run(this, 36); }
void demon1_run2(entity this) { set_animofs(this, anim_demon_run, 2, demon1_run3); ai_run(this, 15); }
void demon1_run1(entity this)
{
	set_animofs(this, anim_demon_run, 1, demon1_run2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "demon/idle1.wav", 1, ATTN_IDLE);
	ai_run(this, 20);
}

void demon1_jump1(entity this);
void demon1_jump12(entity this) { set_animofs(this, anim_demon_leap, 12, demon1_jump1); }
void demon1_jump11(entity this) { set_animofs(this, anim_demon_leap, 11, demon1_jump12); }
void demon1_jump10(entity this) { set_animofs(this, anim_demon_leap, 10, demon1_jump1); this.nextthink = time + 3; }
void demon1_jump9(entity this) { set_animofs(this, anim_demon_leap, 9, demon1_jump10); }
void demon1_jump8(entity this) { set_animofs(this, anim_demon_leap, 8, demon1_jump9); }
void demon1_jump7(entity this) { set_animofs(this, anim_demon_leap, 7, demon1_jump8); }
void demon1_jump6(entity this) { set_animofs(this, anim_demon_leap, 6, demon1_jump7); }
void demon1_jump5(entity this) { set_animofs(this, anim_demon_leap, 5, demon1_jump6); }
void demon1_jump4(entity this)
{
	set_animofs(this, anim_demon_leap, 4, demon1_jump5);
	ai_face(this);
	settouch(this, Demon_JumpTouch);
	this.origin_z += 1;
	makevectors(this.angles);
	this.velocity = v_forward * 600 + '0 0 250';
	UNSET_ONGROUND(this);
}
// if three seconds pass, assume demon is stuck and jump again
void demon1_jump3(entity this) { set_animofs(this, anim_demon_leap, 3, demon1_jump4); ai_face(this); }
void demon1_jump2(entity this) { set_animofs(this, anim_demon_leap, 2, demon1_jump3); ai_face(this); }
void demon1_jump1(entity this) { set_animofs(this, anim_demon_leap, 1, demon1_jump2); ai_face(this); }

void Demon_Melee(entity this, float side);
void demon1_atta15(entity this) { set_animofs(this, anim_demon_attacka, 15, demon1_run1); ai_charge(this, 4); }
void demon1_atta14(entity this) { set_animofs(this, anim_demon_attacka, 14, demon1_atta15); ai_charge(this, 4); }
void demon1_atta13(entity this) { set_animofs(this, anim_demon_attacka, 13, demon1_atta14); ai_charge(this, 8); }
void demon1_atta12(entity this) { set_animofs(this, anim_demon_attacka, 12, demon1_atta13); ai_charge(this, 5); }
void demon1_atta11(entity this) { set_animofs(this, anim_demon_attacka, 11, demon1_atta12); Demon_Melee(this, -200); }
void demon1_atta10(entity this) { set_animofs(this, anim_demon_attacka, 10, demon1_atta11); ai_charge(this, 2); }
void demon1_atta9(entity this) { set_animofs(this, anim_demon_attacka, 9, demon1_atta10); ai_charge(this, 4); }
void demon1_atta8(entity this) { set_animofs(this, anim_demon_attacka, 8, demon1_atta9); ai_charge(this, 8); }
void demon1_atta7(entity this) { set_animofs(this, anim_demon_attacka, 7, demon1_atta8); ai_charge(this, 6); }
void demon1_atta6(entity this) { set_animofs(this, anim_demon_attacka, 6, demon1_atta7); ai_charge(this, 1); }
void demon1_atta5(entity this) { set_animofs(this, anim_demon_attacka, 5, demon1_atta6); ai_charge(this, 2); Demon_Melee(this, 200); }
void demon1_atta4(entity this) { set_animofs(this, anim_demon_attacka, 4, demon1_atta5); ai_charge(this, 1); }
void demon1_atta3(entity this) { set_animofs(this, anim_demon_attacka, 3, demon1_atta4); ai_charge(this, 0); }
void demon1_atta2(entity this) { set_animofs(this, anim_demon_attacka, 2, demon1_atta3); ai_charge(this, 0); }
void demon1_atta1(entity this) { set_animofs(this, anim_demon_attacka, 1, demon1_atta2); ai_charge(this, 4); }

void demon1_pain6(entity this) { set_animofs(this, anim_demon_pain, 6, demon1_run1); }
void demon1_pain5(entity this) { set_animofs(this, anim_demon_pain, 5, demon1_pain6); }
void demon1_pain4(entity this) { set_animofs(this, anim_demon_pain, 4, demon1_pain5); }
void demon1_pain3(entity this) { set_animofs(this, anim_demon_pain, 3, demon1_pain4); }
void demon1_pain2(entity this) { set_animofs(this, anim_demon_pain, 2, demon1_pain3); }
void demon1_pain1(entity this) { set_animofs(this, anim_demon_pain, 1, demon1_pain2); }

void demon1_pain(entity this, entity attacker, float damage)
{
	if(gettouch(this) == Demon_JumpTouch)
		return;

	if(this.pain_finished > time)
		return;

	this.pain_finished = time + 1;
    _sound(this, CH_VOICE, "demon/dpain1.wav", 1, ATTN_NORM);

	if(random()*200 > damage)
		return;		// didn't flinch
		
	demon1_pain1(this);
}

void demon1_die9(entity this) { set_animofs(this, anim_demon_death, 9, demon1_die9); }
void demon1_die8(entity this) { set_animofs(this, anim_demon_death, 8, demon1_die9); }
void demon1_die7(entity this) { set_animofs(this, anim_demon_death, 7, demon1_die8); }
void demon1_die6(entity this) { set_animofs(this, anim_demon_death, 6, demon1_die7); }
void demon1_die5(entity this) { set_animofs(this, anim_demon_death, 5, demon1_die6); this.solid = SOLID_NOT; }
void demon1_die4(entity this) { set_animofs(this, anim_demon_death, 4, demon1_die5); }
void demon1_die3(entity this) { set_animofs(this, anim_demon_death, 3, demon1_die4); }
void demon1_die2(entity this) { set_animofs(this, anim_demon_death, 2, demon1_die3); }
void demon1_die1(entity this)
{
	set_animofs(this, anim_demon_death, 1, demon1_die2);
	_sound(this, CH_VOICE, "demon/ddeath.wav", 1, ATTN_NORM);
}

void demon_die(entity this, entity attacker)
{
// check for gib
	if(this.health < -80)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, "progs/h_demon.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		return;
	}

// regular death
	demon1_die1(this);
}


void Demon_MeleeAttack(entity this)
{
	demon1_atta1(this);
}

/*
==============
CheckDemonMelee

Returns true if a melee attack would hit right now
==============
*/
bool CheckDemonMelee(entity this)
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
CheckDemonJump

==============
*/
bool CheckDemonJump(entity this)
{
	if(this.origin_z + this.mins_z > this.enemy.origin_z + this.enemy.mins_z
		+ 0.75 * this.enemy.size_z)
		return false;
		
	if(this.origin_z + this.maxs_z < this.enemy.origin_z + this.enemy.mins_z
		+ 0.25 * this.enemy.size_z)
		return false;
		
	vector dist = vec2(this.enemy.origin - this.origin);
	
	if(vdist(dist, <, 100))
		return false;
		
	if(vdist(dist, >, 200))
	{
		if(random() < 0.9)
			return false;
	}
		
	return true;
}

bool DemonCheckAttack(entity this)
{
// if close enough for slashing, go for it
	if(CheckDemonMelee(this))
	{
		this.attack_state = AS_MELEE;
		return true;
	}

	if(CheckDemonJump(this))
	{
		this.attack_state = AS_MISSILE;
        _sound(this, CH_VOICE, "demon/djump.wav", 1, ATTN_NORM);
		return true;
	}

	return false;
}


//===========================================================================

void Demon_Melee(entity this, float side)
{
	ai_face(this);
	t_walkmove(this, this.ideal_yaw, 12);	// allow a little closing

	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;
		
    _sound(this, CH_WEAPON_SINGLE, "demon/dhit2.wav", 1, ATTN_NORM);
	float ldmg = 10 + 5*random();
	T_Damage(this.enemy, this, this, ldmg);	

	makevectors(this.angles);
	SpawnMeatSpray(this, this.origin + v_forward*16, side * v_right);
}


void Demon_JumpTouch(entity this, entity toucher)
{
	if(this.health <= 0)
		return;
		
	if(toucher.takedamage)
	{
		if(vdist(this.velocity, >, 400))
		{
			float ldmg = 40 + 10*random();
			T_Damage(toucher, this, this, ldmg);	
		}
	}

	if(!t_checkbottom(this))
	{
		if(IS_ONGROUND(this))
		{	// jump randomly to not get hung up
			//dprint("popjump\n");
			settouch(this, func_null);
			setthink(this, demon1_jump1);
			this.nextthink = time + 0.1;
		}
		return;	// not on ground yet
	}

	settouch(this, func_null);
	setthink(this, demon1_jump11);
	this.nextthink = time + 0.1;
}

string demon1_sight(entity this) { return "demon/sight2.wav"; }
string demon1_deathmessage(entity this) { return "was eviscerated by a Fiend"; }


/*QUAKED monster_demon1(1 0 0)(-32 -32 -24)(32 32 64) Ambush

*/
spawnfunc(monster_demon1)
{
	if(deathmatch)
	{
		delete(this);
		return;
	}
	precache_model("progs/demon.mdl");
	precache_model("progs/h_demon.mdl");

	precache_sound("demon/ddeath.wav");
	precache_sound("demon/dhit2.wav");
	precache_sound("demon/djump.wav");
	precache_sound("demon/dpain1.wav");
	precache_sound("demon/idle1.wav");
	precache_sound("demon/sight2.wav");

	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);

	_setmodel(this, "progs/demon.mdl");

	setsize(this, VEC_HULL2_MIN, VEC_HULL2_MAX);
	this.health = 300;

	this.th_stand = demon1_stand1;
	this.th_walk = demon1_walk1;
	this.th_run = demon1_run1;
	this.th_die = demon_die;
	this.th_melee = Demon_MeleeAttack;		// one of two attacks
	this.th_missile = demon1_jump1;			// jump attack
	this.th_pain = demon1_pain;

	this.sightsound = demon1_sight;
	this.checkattack = DemonCheckAttack;
	this.deathmessage = demon1_deathmessage;
		
	monster_start(this, 0);
}
