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

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8

$frame run1 run2 run3 run4 run5 run6

$frame leap1 leap2 leap3 leap4 leap5 leap6 leap7 leap8 leap9 leap10
$frame leap11 leap12

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9

$frame attacka1 attacka2 attacka3 attacka4 attacka5 attacka6 attacka7 attacka8
$frame attacka9 attacka10 attacka11 attacka12 attacka13 attacka14 attacka15

//============================================================================

void Demon_JumpTouch(entity this, entity toucher);

void demon1_stand1(entity this) { set_anim(this, $stand1, demon1_stand2); ai_stand(this); }
void demon1_stand2(entity this) { set_anim(this, $stand2, demon1_stand3); ai_stand(this); }
void demon1_stand3(entity this) { set_anim(this, $stand3, demon1_stand4); ai_stand(this); }
void demon1_stand4(entity this) { set_anim(this, $stand4, demon1_stand5); ai_stand(this); }
void demon1_stand5(entity this) { set_anim(this, $stand5, demon1_stand6); ai_stand(this); }
void demon1_stand6(entity this) { set_anim(this, $stand6, demon1_stand7); ai_stand(this); }
void demon1_stand7(entity this) { set_anim(this, $stand7, demon1_stand8); ai_stand(this); }
void demon1_stand8(entity this) { set_anim(this, $stand8, demon1_stand9); ai_stand(this); }
void demon1_stand9(entity this) { set_anim(this, $stand9, demon1_stand10); ai_stand(this); }
void demon1_stand10(entity this) { set_anim(this, $stand10, demon1_stand11); ai_stand(this); }
void demon1_stand11(entity this) { set_anim(this, $stand11, demon1_stand12); ai_stand(this); }
void demon1_stand12(entity this) { set_anim(this, $stand12, demon1_stand13); ai_stand(this); }
void demon1_stand13(entity this) { set_anim(this, $stand1, demon1_stand1); ai_stand(this); }

void demon1_walk1(entity this)
{
	set_anim(this, $walk1, demon1_walk2);
	if(random() < 0.2)
		_sound(this, CHAN_VOICE, "demon/idle1.wav", 1, ATTN_IDLE);
	ai_walk(this, 8);
}
void demon1_walk2(entity this) { set_anim(this, $walk2, demon1_walk3); ai_walk(this, 6); }
void demon1_walk3(entity this) { set_anim(this, $walk3, demon1_walk4); ai_walk(this, 6); }
void demon1_walk4(entity this) { set_anim(this, $walk4, demon1_walk5); ai_walk(this, 7); }
void demon1_walk5(entity this) { set_anim(this, $walk5, demon1_walk6); ai_walk(this, 4); }
void demon1_walk6(entity this) { set_anim(this, $walk6, demon1_walk7); ai_walk(this, 6); }
void demon1_walk7(entity this) { set_anim(this, $walk7, demon1_walk8); ai_walk(this, 10); }
void demon1_walk8(entity this) { set_anim(this, $walk8, demon1_walk1); ai_walk(this, 10); }

void demon1_run1(entity this)
{
	set_anim(this, $run1, demon1_run2);
	if(random() < 0.2)
		_sound(this, CHAN_VOICE, "demon/idle1.wav", 1, ATTN_IDLE);
	ai_run(this, 20);
}
void demon1_run2(entity this) { set_anim(this, $run2, demon1_run3); ai_run(this, 15); }
void demon1_run3(entity this) { set_anim(this, $run3, demon1_run4); ai_run(this, 36); }
void demon1_run4(entity this) { set_anim(this, $run4, demon1_run5); ai_run(this, 20); }
void demon1_run5(entity this) { set_anim(this, $run5, demon1_run6); ai_run(this, 15); }
void demon1_run6(entity this) { set_anim(this, $run6, demon1_run1); ai_run(this, 36); }

void demon1_jump1(entity this) { set_anim(this, $leap1, demon1_jump2); ai_face(this); }
void demon1_jump2(entity this) { set_anim(this, $leap2, demon1_jump3); ai_face(this); }
void demon1_jump3(entity this) { set_anim(this, $leap3, demon1_jump4); ai_face(this); }
void demon1_jump4(entity this)
{
	set_anim(this, $leap4, demon1_jump5);
	ai_face(this);
	settouch(this, Demon_JumpTouch);
	this.origin_z += 1;
	this.velocity = v_forward * 600 + '0 0 250';
	this.flags &= ~FL_ONGROUND;
}
void demon1_jump5(entity this) { set_anim(this, $leap5, demon1_jump6); }
void demon1_jump6(entity this) { set_anim(this, $leap6, demon1_jump7); }
void demon1_jump7(entity this) { set_anim(this, $leap7, demon1_jump8); }
void demon1_jump8(entity this) { set_anim(this, $leap8, demon1_jump9); }
void demon1_jump9(entity this) { set_anim(this, $leap9, demon1_jump10); }
void demon1_jump10(entity this) { set_anim(this, $leap10, demon1_jump1); this.nextthink = time + 3; }
void demon1_jump11(entity this) { set_anim(this, $leap11, demon1_jump12); }
void demon1_jump12(entity this) { set_anim(this, $leap12, demon1_jump1); }
// if three seconds pass, assume demon is stuck and jump again


void()	demon1_atta1	=[	$attacka1,		demon1_atta2	] {ai_charge(4);}
void()	demon1_atta2	=[	$attacka2,		demon1_atta3	] {ai_charge(0);}
void()	demon1_atta3	=[	$attacka3,		demon1_atta4	] {ai_charge(0);}
void()	demon1_atta4	=[	$attacka4,		demon1_atta5	] {ai_charge(1);}
void()	demon1_atta5	=[	$attacka5,		demon1_atta6	] {ai_charge(2); Demon_Melee(200);}
void()	demon1_atta6	=[	$attacka6,		demon1_atta7	] {ai_charge(1);}
void()	demon1_atta7	=[	$attacka7,		demon1_atta8	] {ai_charge(6);}
void()	demon1_atta8	=[	$attacka8,		demon1_atta9	] {ai_charge(8);}
void()	demon1_atta9	=[	$attacka9,		demon1_atta10] {ai_charge(4);}
void()	demon1_atta10	=[	$attacka10,		demon1_atta11] {ai_charge(2);}
void()	demon1_atta11	=[	$attacka11,		demon1_atta12] {Demon_Melee(-200);}
void()	demon1_atta12	=[	$attacka12,		demon1_atta13] {ai_charge(5);}
void()	demon1_atta13	=[	$attacka13,		demon1_atta14] {ai_charge(8);}
void()	demon1_atta14	=[	$attacka14,		demon1_atta15] {ai_charge(4);}
void()	demon1_atta15	=[	$attacka15,		demon1_run1] {ai_charge(4);}

void()	demon1_pain1	=[	$pain1,		demon1_pain2	] {}
void()	demon1_pain2	=[	$pain2,		demon1_pain3	] {}
void()	demon1_pain3	=[	$pain3,		demon1_pain4	] {}
void()	demon1_pain4	=[	$pain4,		demon1_pain5	] {}
void()	demon1_pain5	=[	$pain5,		demon1_pain6	] {}
void()	demon1_pain6	=[	$pain6,		demon1_run1	] {}

void demon1_pain(entity this, entity attacker, float damage)
{
	if(gettouch(this) == Demon_JumpTouch)
		return;

	if(this.pain_finished > time)
		return;

	this.pain_finished = time + 1;
    _sound(this, CHAN_VOICE, "demon/dpain1.wav", 1, ATTN_NORM);

	if(random()*200 > damage)
		return;		// didn't flinch
		
	demon1_pain1(this);
}

void()	demon1_die1		=[	$death1,		demon1_die2	] {
_sound(this, CHAN_VOICE, "demon/ddeath.wav", 1, ATTN_NORM);}
void()	demon1_die2		=[	$death2,		demon1_die3	] {}
void()	demon1_die3		=[	$death3,		demon1_die4	] {}
void()	demon1_die4		=[	$death4,		demon1_die5	] {}
void()	demon1_die5		=[	$death5,		demon1_die6	] {}
void()	demon1_die6		=[	$death6,		demon1_die7	]
{this.solid = SOLID_NOT;}
void()	demon1_die7		=[	$death7,		demon1_die8	] {}
void()	demon1_die8		=[	$death8,		demon1_die9	] {}
void()	demon1_die9		=[	$death9,		demon1_die9 ] {}

void demon_die(entity this, entity attacker)
{
// check for gib
	if(this.health < -80)
	{
		_sound(this, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead("progs/h_demon.mdl", this.health);
		ThrowGib("progs/gib1.mdl", this.health);
		ThrowGib("progs/gib1.mdl", this.health);
		ThrowGib("progs/gib1.mdl", this.health);
		return;
	}

// regular death
	monster_playanim(this, demon1_die1);
}


void Demon_MeleeAttack(entity this)
{
	monster_playanim(this, demon1_atta1);
}

string demon1_sight() { return "demon/sight2.wav"; }
string demon1_deathmessage() { return "was eviscerated by a Fiend"; }


/*QUAKED monster_demon1(1 0 0)(-32 -32 -24)(32 32 64) Ambush

*/
bool DemonCheckAttack(entity this);
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
	this.movetype = MOVETYPE_STEP;

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
		
	walkmonster_start(this);
}


/*
==============================================================================

DEMON

==============================================================================
*/

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
        _sound(this, CHAN_VOICE, "demon/djump.wav", 1, ATTN_NORM);
		return true;
	}

	return false;
}


//===========================================================================

void Demon_Melee(entity this, float side)
{
	ai_face(this);
	walkmove(this.ideal_yaw, 12);	// allow a little closing

	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;
		
    _sound(this, CHAN_WEAPON, "demon/dhit2.wav", 1, ATTN_NORM);
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

	if(!checkbottom(this))
	{
		if(this.flags & FL_ONGROUND)
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

