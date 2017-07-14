/*
==============================================================================

SHAMBLER

==============================================================================
*/

$cd id1/models/shams
$origin 0 0 24
$base base		
$skin base

const int anim_sham_stand1 = 0;
const int anim_sham_stand2 = 1;
const int anim_sham_stand3 = 2;
const int anim_sham_stand4 = 3;
const int anim_sham_stand5 = 4;
const int anim_sham_stand6 = 5;
const int anim_sham_stand7 = 6;
const int anim_sham_stand8 = 7;
const int anim_sham_stand9 = 8;
const int anim_sham_stand10 = 9;
const int anim_sham_stand11 = 10;
const int anim_sham_stand12 = 11;
const int anim_sham_stand13 = 12;
const int anim_sham_stand14 = 13;
const int anim_sham_stand15 = 14;
const int anim_sham_stand16 = 15;
const int anim_sham_stand17 = 16;

const int anim_sham_walk1 = 17;
const int anim_sham_walk2 = 18;
const int anim_sham_walk3 = 19;
const int anim_sham_walk4 = 20;
const int anim_sham_walk5 = 21;
const int anim_sham_walk6 = 22;
const int anim_sham_walk7 = 23;
const int anim_sham_walk8 = 24;
const int anim_sham_walk9 = 25;
const int anim_sham_walk10 = 26;
const int anim_sham_walk11 = 27;
const int anim_sham_walk12 = 28;

const int anim_sham_run1 = 29;
const int anim_sham_run2 = 30;
const int anim_sham_run3 = 31;
const int anim_sham_run4 = 32;
const int anim_sham_run5 = 33;
const int anim_sham_run6 = 34;

const int anim_sham_smash1 = 35;
const int anim_sham_smash2 = 36;
const int anim_sham_smash3 = 37;
const int anim_sham_smash4 = 38;
const int anim_sham_smash5 = 39;
const int anim_sham_smash6 = 40;
const int anim_sham_smash7 = 41;
const int anim_sham_smash8 = 42;
const int anim_sham_smash9 = 43;
const int anim_sham_smash10 = 44;
const int anim_sham_smash11 = 45;
const int anim_sham_smash12 = 46;

const int anim_sham_swingr1 = 47;
const int anim_sham_swingr2 = 48;
const int anim_sham_swingr3 = 49;
const int anim_sham_swingr4 = 50;
const int anim_sham_swingr5 = 51;
const int anim_sham_swingr6 = 52;
const int anim_sham_swingr7 = 53;
const int anim_sham_swingr8 = 54;
const int anim_sham_swingr9 = 55;
const int anim_sham_swingl1 = 56;
const int anim_sham_swingl2 = 57;
const int anim_sham_swingl3 = 58;
const int anim_sham_swingl4 = 59;
const int anim_sham_swingl5 = 60;
const int anim_sham_swingl6 = 61;
const int anim_sham_swingl7 = 62;
const int anim_sham_swingl8 = 63;
const int anim_sham_swingl9 = 64;

const int anim_sham_magic1 = 65;
const int anim_sham_magic2 = 66;
const int anim_sham_magic3 = 67;
const int anim_sham_magic4 = 68;
const int anim_sham_magic5 = 69;
const int anim_sham_magic6 = 70;
const int anim_sham_magic7 = 71;
const int anim_sham_magic8 = 72;
const int anim_sham_magic9 = 73;
const int anim_sham_magic10 = 74;
const int anim_sham_magic11 = 75;
const int anim_sham_magic12 = 76;

const int anim_sham_pain1 = 77;
const int anim_sham_pain2 = 78;
const int anim_sham_pain3 = 79;
const int anim_sham_pain4 = 80;
const int anim_sham_pain5 = 81;
const int anim_sham_pain6 = 82;

const int anim_sham_death1 = 83;
const int anim_sham_death2 = 84;
const int anim_sham_death3 = 85;
const int anim_sham_death4 = 86;
const int anim_sham_death5 = 87;
const int anim_sham_death6 = 88;
const int anim_sham_death7 = 89;
const int anim_sham_death8 = 90;
const int anim_sham_death9 = 91;
const int anim_sham_death10 = 92;
const int anim_sham_death11 = 93;

void sham_stand1(entity this);
void sham_stand17(entity this) { set_anim(this, anim_sham_stand17, sham_stand1); ai_stand(this); }
void sham_stand16(entity this) { set_anim(this, anim_sham_stand16, sham_stand17); ai_stand(this); }
void sham_stand15(entity this) { set_anim(this, anim_sham_stand15, sham_stand16); ai_stand(this); }
void sham_stand14(entity this) { set_anim(this, anim_sham_stand14, sham_stand15); ai_stand(this); }
void sham_stand13(entity this) { set_anim(this, anim_sham_stand13, sham_stand14); ai_stand(this); }
void sham_stand12(entity this) { set_anim(this, anim_sham_stand12, sham_stand13); ai_stand(this); }
void sham_stand11(entity this) { set_anim(this, anim_sham_stand11, sham_stand12); ai_stand(this); }
void sham_stand10(entity this) { set_anim(this, anim_sham_stand10, sham_stand11); ai_stand(this); }
void sham_stand9(entity this) { set_anim(this, anim_sham_stand9, sham_stand10); ai_stand(this); }
void sham_stand8(entity this) { set_anim(this, anim_sham_stand8, sham_stand9); ai_stand(this); }
void sham_stand7(entity this) { set_anim(this, anim_sham_stand7, sham_stand8); ai_stand(this); }
void sham_stand6(entity this) { set_anim(this, anim_sham_stand6, sham_stand7); ai_stand(this); }
void sham_stand5(entity this) { set_anim(this, anim_sham_stand5, sham_stand6); ai_stand(this); }
void sham_stand4(entity this) { set_anim(this, anim_sham_stand4, sham_stand5); ai_stand(this); }
void sham_stand3(entity this) { set_anim(this, anim_sham_stand3, sham_stand4); ai_stand(this); }
void sham_stand2(entity this) { set_anim(this, anim_sham_stand2, sham_stand3); ai_stand(this); }
void sham_stand1(entity this) { set_anim(this, anim_sham_stand1, sham_stand2); ai_stand(this); }

void sham_walk1(entity this);
void sham_walk12(entity this)
{
	set_anim(this, anim_sham_walk12, sham_walk1);
	ai_walk(this, 7);
	if(random() > 0.8)
		_sound(this, CH_VOICE, "shambler/sidle.wav", 1, ATTN_IDLE);
}
void sham_walk11(entity this) { set_anim(this, anim_sham_walk11, sham_walk12); ai_walk(this, 7); }
void sham_walk10(entity this) { set_anim(this, anim_sham_walk10, sham_walk11); ai_walk(this, 9); }
void sham_walk9(entity this) { set_anim(this, anim_sham_walk9, sham_walk10); ai_walk(this, 13); }
void sham_walk8(entity this) { set_anim(this, anim_sham_walk8, sham_walk9); ai_walk(this, 3); }
void sham_walk7(entity this) { set_anim(this, anim_sham_walk7, sham_walk8); ai_walk(this, 8); }
void sham_walk6(entity this) { set_anim(this, anim_sham_walk6, sham_walk7); ai_walk(this, 12); }
void sham_walk5(entity this) { set_anim(this, anim_sham_walk5, sham_walk6); ai_walk(this, 6); }
void sham_walk4(entity this) { set_anim(this, anim_sham_walk4, sham_walk5); ai_walk(this, 5); }
void sham_walk3(entity this) { set_anim(this, anim_sham_walk3, sham_walk4); ai_walk(this, 9); }
void sham_walk2(entity this) { set_anim(this, anim_sham_walk2, sham_walk3); ai_walk(this, 9); }
void sham_walk1(entity this) { set_anim(this, anim_sham_walk1, sham_walk2); ai_walk(this, 10); }

void sham_run1(entity this);
void sham_run6(entity this)
{
	set_anim(this, anim_sham_run6, sham_run1);
	ai_run(this, 20);
	if(random() > 0.8)
		_sound(this, CH_VOICE, "shambler/sidle.wav", 1, ATTN_IDLE);
}
void sham_run5(entity this) { set_anim(this, anim_sham_run5, sham_run6); ai_run(this, 24); }
void sham_run4(entity this) { set_anim(this, anim_sham_run4, sham_run5); ai_run(this, 20); }
void sham_run3(entity this) { set_anim(this, anim_sham_run3, sham_run4); ai_run(this, 20); }
void sham_run2(entity this) { set_anim(this, anim_sham_run2, sham_run3); ai_run(this, 24); }
void sham_run1(entity this) { set_anim(this, anim_sham_run1, sham_run2); ai_run(this, 20); }

void sham_smash12(entity this) { set_anim(this, anim_sham_smash12, sham_run1); ai_charge(this, 4); }
void sham_smash11(entity this) { set_anim(this, anim_sham_smash11, sham_smash12); ai_charge(this, 5); }
void sham_smash10(entity this)
{
	set_anim(this, anim_sham_smash10, sham_smash11);
	if(!this.enemy)
		return;
	ai_charge(this, 0);

	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;
		
	float ldmg =(random() + random() + random()) * 40;
	T_Damage(this.enemy, this, this, ldmg);
	_sound(this, CH_VOICE, "shambler/smack.wav", 1, ATTN_NORM);

	SpawnMeatSpray(this, this.origin + v_forward*16, crandom() * 100 * v_right);
	SpawnMeatSpray(this, this.origin + v_forward*16, crandom() * 100 * v_right);
}
void sham_smash9(entity this) { set_anim(this, anim_sham_smash9, sham_smash10); ai_charge(this, 0); }
void sham_smash8(entity this) { set_anim(this, anim_sham_smash8, sham_smash9); ai_charge(this, 0); }
void sham_smash7(entity this) { set_anim(this, anim_sham_smash7, sham_smash8); ai_charge(this, 0); }
void sham_smash6(entity this) { set_anim(this, anim_sham_smash6, sham_smash7); ai_charge(this, 1); }
void sham_smash5(entity this) { set_anim(this, anim_sham_smash5, sham_smash6); ai_charge(this, 4); }
void sham_smash4(entity this) { set_anim(this, anim_sham_smash4, sham_smash5); ai_charge(this, 5); }
void sham_smash3(entity this) { set_anim(this, anim_sham_smash3, sham_smash4); ai_charge(this, 6); }
void sham_smash2(entity this) { set_anim(this, anim_sham_smash2, sham_smash3); ai_charge(this, 6); }
void sham_smash1(entity this) { set_anim(this, anim_sham_smash1, sham_smash2); _sound(this, CH_VOICE, "shambler/melee1.wav", 1, ATTN_NORM); ai_charge(this, 2); }

void sham_swingr1(entity this);

void ShamClaw(entity this, float side)
{
	if(!this.enemy)
		return;
	ai_charge(this, 10);

	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
		
	float ldmg =(random() + random() + random()) * 20;
	T_Damage(this.enemy, this, this, ldmg);
	_sound(this, CH_VOICE, "shambler/smack.wav", 1, ATTN_NORM);

	if(side)
	{
		makevectors(this.angles);
		SpawnMeatSpray(this, this.origin + v_forward*16, side * v_right);
	}
}

void sham_swingl9(entity this)
{
	set_anim(this, anim_sham_swingl9, sham_run1); 
	ai_charge(this, 8);
	if(random()<0.5)
		setthink(this, sham_swingr1);
}
void sham_swingl8(entity this) { set_anim(this, anim_sham_swingl8, sham_swingl9); ai_charge(this, 4); }
void sham_swingl7(entity this) { set_anim(this, anim_sham_swingl7, sham_swingl8); ai_charge(this, 5); ShamClaw(this, 250); }
void sham_swingl6(entity this) { set_anim(this, anim_sham_swingl6, sham_swingl7); ai_charge(this, 9); }
void sham_swingl5(entity this) { set_anim(this, anim_sham_swingl5, sham_swingl6); ai_charge(this, 7); }
void sham_swingl4(entity this) { set_anim(this, anim_sham_swingl4, sham_swingl5); ai_charge(this, 3); }
void sham_swingl3(entity this) { set_anim(this, anim_sham_swingl3, sham_swingl4); ai_charge(this, 7); }
void sham_swingl2(entity this) { set_anim(this, anim_sham_swingl2, sham_swingl3); ai_charge(this, 3); }
void sham_swingl1(entity this)
{
	set_anim(this, anim_sham_swingl1, sham_swingl2); 
	_sound(this, CH_VOICE, "shambler/melee2.wav", 1, ATTN_NORM);
	ai_charge(this, 5);
}

void sham_swingr9(entity this)
{
	set_anim(this, anim_sham_swingr9, sham_run1);
	//ai_charge(this, 1);
	ai_charge(this, 10);
	if(random() < 0.5)
		setthink(this, sham_swingl1);
}
void sham_swingr8(entity this) { set_anim(this, anim_sham_swingr8, sham_swingr9); ai_charge(this, 3); }
void sham_swingr7(entity this) { set_anim(this, anim_sham_swingr7, sham_swingr8); ai_charge(this, 6); ShamClaw(this, -250); }
void sham_swingr6(entity this) { set_anim(this, anim_sham_swingr6, sham_swingr7); ai_charge(this, 6); }
void sham_swingr5(entity this) { set_anim(this, anim_sham_swingr5, sham_swingr6); ai_charge(this, 3); }
void sham_swingr4(entity this) { set_anim(this, anim_sham_swingr4, sham_swingr5); ai_charge(this, 7); }
void sham_swingr3(entity this) { set_anim(this, anim_sham_swingr3, sham_swingr4); ai_charge(this, 14); }
void sham_swingr2(entity this) { set_anim(this, anim_sham_swingr2, sham_swingr3); ai_charge(this, 8); }
void sham_swingr1(entity this)
{
	set_anim(this, anim_sham_swingr1, sham_swingr2); 
	_sound(this, CH_VOICE, "shambler/melee1.wav", 1, ATTN_NORM);
	ai_charge(this, 1);
}

void sham_melee(entity this)
{
	float chance = random();
	if(chance > 0.6 || this.health == 600)
		sham_smash1(this);
	else if(chance > 0.3)
		sham_swingr1(this);
	else
		sham_swingl1(this);
}


//============================================================================

void CastLightning(entity this)
{
	this.effects |= EF_MUZZLEFLASH;

	ai_face(this);

	vector org = this.origin + '0 0 40';

	vector dir = this.enemy.origin + '0 0 16' - org;
	dir = normalize(dir);

	traceline(org, this.origin + dir*600, true, this);

	te_lightning1(NULL, org, trace_endpos); // TODO: entity breaks

	LightningDamage(org, trace_endpos, this, 10);
}

void sham_magic12(entity this) { set_anim(this, anim_sham_magic12, sham_run1); }
void sham_magic11(entity this)
{
	set_anim(this, anim_sham_magic11, sham_magic12);
	if(skill == 3)
		CastLightning(this);
}
void sham_magic10(entity this) { set_anim(this, anim_sham_magic10, sham_magic11); CastLightning(this); }
void sham_magic9(entity this) { set_anim(this, anim_sham_magic9, sham_magic10); CastLightning(this); }
void sham_magic6(entity this)
{
	set_anim(this, anim_sham_magic6, sham_magic9);
	delete(this.owner);
	CastLightning(this);
	_sound(this, CH_WEAPON_SINGLE, "shambler/sboom.wav", 1, ATTN_NORM);
}
void sham_magic5(entity this)
{
	set_anim(this, anim_sham_magic5, sham_magic6);
	this.effects |= EF_MUZZLEFLASH;
	this.owner.frame = 2;
}
void sham_magic4(entity this)
{
	set_anim(this, anim_sham_magic4, sham_magic5);
	this.effects |= EF_MUZZLEFLASH;
	this.owner.frame = 1;
}
void sham_magic3(entity this)
{
	set_anim(this, anim_sham_magic3, sham_magic4);
	ai_face(this);
	this.nextthink = this.nextthink + 0.2;

	this.effects |= EF_MUZZLEFLASH;
	entity o = spawn();
	this.owner = o;
	_setmodel(o, "progs/s_light.mdl");
	setorigin(o, this.origin);
	o.angles = this.angles;
	o.nextthink = time + 0.7;
	setthink(o, SUB_Remove);
}
void sham_magic2(entity this) { set_anim(this, anim_sham_magic2, sham_magic3); ai_face(this); }
void sham_magic1(entity this)
{
	set_anim(this, anim_sham_magic1, sham_magic2);
	ai_face(this);
	_sound(this, CH_WEAPON_SINGLE, "shambler/sattck1.wav", 1, ATTN_NORM);
}

void sham_pain6(entity this) { set_anim(this, anim_sham_pain6, sham_run1); }
void sham_pain5(entity this) { set_anim(this, anim_sham_pain5, sham_pain6); }
void sham_pain4(entity this) { set_anim(this, anim_sham_pain4, sham_pain5); }
void sham_pain3(entity this) { set_anim(this, anim_sham_pain3, sham_pain4); }
void sham_pain2(entity this) { set_anim(this, anim_sham_pain2, sham_pain3); }
void sham_pain1(entity this) { set_anim(this, anim_sham_pain1, sham_pain2); }

void sham_pain(entity this, entity attacker, float damage)
{
	_sound(this, CH_VOICE, "shambler/shurt2.wav", 1, ATTN_NORM);

	if(this.health <= 0)
		return;		// allready dying, don't go into pain frame

	if(random()*400 > damage)
		return;		// didn't flinch

	if(this.pain_finished > time)
		return;
	this.pain_finished = time + 2;
		
	sham_pain1(this);
}


//============================================================================


void sham_death11(entity this) { set_anim(this, anim_sham_death11, sham_death11); }
void sham_death10(entity this) { set_anim(this, anim_sham_death10, sham_death11); }
void sham_death9(entity this) { set_anim(this, anim_sham_death9, sham_death10); }
void sham_death8(entity this) { set_anim(this, anim_sham_death8, sham_death9); }
void sham_death7(entity this) { set_anim(this, anim_sham_death7, sham_death8); }
void sham_death6(entity this) { set_anim(this, anim_sham_death6, sham_death7); }
void sham_death5(entity this) { set_anim(this, anim_sham_death5, sham_death6); }
void sham_death4(entity this) { set_anim(this, anim_sham_death4, sham_death5); }
void sham_death3(entity this) { set_anim(this, anim_sham_death3, sham_death4); this.solid = SOLID_NOT; }
void sham_death2(entity this) { set_anim(this, anim_sham_death2, sham_death3); }
void sham_death1(entity this) { set_anim(this, anim_sham_death1, sham_death2); }

void sham_die(entity this, entity attacker)
{
// check for gib
	if(this.health < -60)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, "progs/h_shams.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib2.mdl", this.health);
		ThrowGib(this, "progs/gib3.mdl", this.health);
		return;
	}

// regular death
	_sound(this, CH_VOICE, "shambler/sdeath.wav", 1, ATTN_NORM);
	sham_death1(this);
}

/*
===========
ShamCheckAttack

The player is in view, so decide to move or launch an attack
Returns false if movement should continue
============
*/
bool ShamCheckAttack(entity this)
{
	if(this.enemy_range == RANGE_MELEE)
	{
		if(CanDamage(this.enemy, this))
		{
			this.attack_state = AS_MELEE;
			return true;
		}
	}

	if(time < this.attack_finished)
		return false;
	
	if(!this.enemy_vis)
		return false;
		
	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	if(vlen(spot1 - spot2) > 600)
		return false;

	traceline(spot1, spot2, false, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
	{
		return false;	// don't have a clear shot
	}
			
// missile attack
	if(this.enemy_range == RANGE_FAR)
		return false;
		
	this.attack_state = AS_MISSILE;
	SUB_AttackFinished(this, 2 + 2*random());
	return true;
}

string shambler_sight(entity this) { return "shambler/ssight.wav"; }
string shambler_deathmessage(entity this) { return "was smashed by a Shambler"; }

//============================================================================


/*QUAKED monster_shambler(1 0 0)(-32 -32 -24)(32 32 64) Ambush
*/
spawnfunc(monster_shambler)
{
	if(deathmatch)
	{
		delete(this);
		return;
	}
	precache_model("progs/shambler.mdl");
	precache_model("progs/s_light.mdl");
	precache_model("progs/h_shams.mdl");
	precache_model("progs/bolt.mdl");
	
	precache_sound("shambler/sattck1.wav");
	precache_sound("shambler/sboom.wav");
	precache_sound("shambler/sdeath.wav");
	precache_sound("shambler/shurt2.wav");
	precache_sound("shambler/sidle.wav");
	precache_sound("shambler/ssight.wav");
	precache_sound("shambler/melee1.wav");
	precache_sound("shambler/melee2.wav");
	precache_sound("shambler/smack.wav");

	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);
	_setmodel(this, "progs/shambler.mdl");

	setsize(this, VEC_HULL2_MIN, VEC_HULL2_MAX);
	this.health = 600;

	this.th_stand = sham_stand1;
	this.th_walk = sham_walk1;
	this.th_run = sham_run1;
	this.th_die = sham_die;
	this.th_melee = sham_melee;
	this.th_missile = sham_magic1;
	this.th_pain = sham_pain;

	this.sightsound = shambler_sight;
	this.checkattack = ShamCheckAttack;
	this.deathmessage = shambler_deathmessage;
	
	monster_start(this, 0);
}
