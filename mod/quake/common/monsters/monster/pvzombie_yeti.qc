#include "pvzombie_yeti.qh"

#ifdef SVQC
const int anim_pvz_yeti_idle = 0;
const int anim_pvz_yeti_walk = 9;
const int anim_pvz_yeti_run = 26;
const int anim_pvz_yeti_pain = 35;
const int anim_pvz_yeti_attack = 42;
const int anim_pvz_yeti_deatha = 51;
const int anim_pvz_yeti_deathb = 64;
const int anim_pvz_yeti_deathc = 76;
const int anim_pvz_yeti_deathd = 88;

void pvz_yeti_leap1(entity this);
void pvz_yeti_run1(entity this);


/*
================
pvz_yeti_bite

================
*/
void pvz_yeti_bite(entity this)
{
	if(!this.enemy)
		return;

	ai_charge(this, 4);

	if(!CanDamage(this.enemy, this))
		return;

	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;

	if(random() > 0.5)
		_sound(this, CH_VOICE, "pvz/chomp.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "pvz/chomp2.wav", 1, ATTN_NORM);
		
	float ldmg =(random() + random() + random()) * 32;
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_PVZOMBIE_YETI.m_id);
}

void pvz_yeti_stand1(entity this);
void pvz_yeti_stand9(entity this) { set_animofs(this, anim_pvz_yeti_idle, 9, pvz_yeti_stand1); ai_stand(this); }
void pvz_yeti_stand8(entity this) { set_animofs(this, anim_pvz_yeti_idle, 8, pvz_yeti_stand9); ai_stand(this); }
void pvz_yeti_stand7(entity this) { set_animofs(this, anim_pvz_yeti_idle, 7, pvz_yeti_stand8); ai_stand(this); }
void pvz_yeti_stand6(entity this) { set_animofs(this, anim_pvz_yeti_idle, 6, pvz_yeti_stand7); ai_stand(this); }
void pvz_yeti_stand5(entity this) { set_animofs(this, anim_pvz_yeti_idle, 5, pvz_yeti_stand6); ai_stand(this); }
void pvz_yeti_stand4(entity this) { set_animofs(this, anim_pvz_yeti_idle, 4, pvz_yeti_stand5); ai_stand(this); }
void pvz_yeti_stand3(entity this) { set_animofs(this, anim_pvz_yeti_idle, 3, pvz_yeti_stand4); ai_stand(this); }
void pvz_yeti_stand2(entity this) { set_animofs(this, anim_pvz_yeti_idle, 2, pvz_yeti_stand3); ai_stand(this); }
void pvz_yeti_stand1(entity this) { set_animofs(this, anim_pvz_yeti_idle, 1, pvz_yeti_stand2); ai_stand(this); }

void pvz_yeti_walk1(entity this);
void pvz_yeti_walk17(entity this) { set_animofs(this, anim_pvz_yeti_walk, 17, pvz_yeti_walk1); ai_walk(this, 5); }
void pvz_yeti_walk16(entity this) { set_animofs(this, anim_pvz_yeti_walk, 16, pvz_yeti_walk17); ai_walk(this, 5); monster_footstep(this, false); }
void pvz_yeti_walk15(entity this) { set_animofs(this, anim_pvz_yeti_walk, 15, pvz_yeti_walk16); ai_walk(this, 5); }
void pvz_yeti_walk14(entity this) { set_animofs(this, anim_pvz_yeti_walk, 14, pvz_yeti_walk15); ai_walk(this, 5); monster_footstep(this, false); }
void pvz_yeti_walk13(entity this) { set_animofs(this, anim_pvz_yeti_walk, 13, pvz_yeti_walk14); ai_walk(this, 5); }
void pvz_yeti_walk12(entity this) { set_animofs(this, anim_pvz_yeti_walk, 12, pvz_yeti_walk13); ai_walk(this, 5); monster_footstep(this, false); }
void pvz_yeti_walk11(entity this) { set_animofs(this, anim_pvz_yeti_walk, 11, pvz_yeti_walk12); ai_walk(this, 5); }
void pvz_yeti_walk10(entity this) { set_animofs(this, anim_pvz_yeti_walk, 10, pvz_yeti_walk11); ai_walk(this, 5); monster_footstep(this, false); }
void pvz_yeti_walk9(entity this) { set_animofs(this, anim_pvz_yeti_walk, 9, pvz_yeti_walk10); ai_walk(this, 5); }
void pvz_yeti_walk8(entity this) { set_animofs(this, anim_pvz_yeti_walk, 8, pvz_yeti_walk9); ai_walk(this, 5); monster_footstep(this, false); }
void pvz_yeti_walk7(entity this) { set_animofs(this, anim_pvz_yeti_walk, 7, pvz_yeti_walk8); ai_walk(this, 5); }
void pvz_yeti_walk6(entity this) { set_animofs(this, anim_pvz_yeti_walk, 6, pvz_yeti_walk7); ai_walk(this, 5); monster_footstep(this, false); }
void pvz_yeti_walk5(entity this) { set_animofs(this, anim_pvz_yeti_walk, 5, pvz_yeti_walk6); ai_walk(this, 5); }
void pvz_yeti_walk4(entity this) { set_animofs(this, anim_pvz_yeti_walk, 4, pvz_yeti_walk5); ai_walk(this, 5); monster_footstep(this, false); }
void pvz_yeti_walk3(entity this) { set_animofs(this, anim_pvz_yeti_walk, 3, pvz_yeti_walk4); ai_walk(this, 5); }
void pvz_yeti_walk2(entity this) { set_animofs(this, anim_pvz_yeti_walk, 2, pvz_yeti_walk3); ai_walk(this, 5); monster_footstep(this, false); }
void pvz_yeti_walk1(entity this)
{
	set_animofs(this, anim_pvz_yeti_walk, 1, pvz_yeti_walk2);
	if(random() < 0.25)
	{
		if(random() > 0.5)
			_sound(this, CH_VOICE, "pvz/lowgroan.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "pvz/lowgroan2.wav", 1, ATTN_IDLE);
	}
	ai_walk(this, 5);
}

void pvz_yeti_run1(entity this);
void pvz_yeti_run8(entity this) { set_animofs(this, anim_pvz_yeti_run, 8, pvz_yeti_run1); ai_run(this, 10); }
void pvz_yeti_run7(entity this) { set_animofs(this, anim_pvz_yeti_run, 7, pvz_yeti_run8); ai_run(this, 14); monster_footstep(this, false); }
void pvz_yeti_run6(entity this) { set_animofs(this, anim_pvz_yeti_run, 6, pvz_yeti_run7); ai_run(this, 9); }
void pvz_yeti_run5(entity this) { set_animofs(this, anim_pvz_yeti_run, 5, pvz_yeti_run6); ai_run(this, 10); }
void pvz_yeti_run4(entity this) { set_animofs(this, anim_pvz_yeti_run, 4, pvz_yeti_run5); ai_run(this, 9); monster_footstep(this, false); }
void pvz_yeti_run3(entity this) { set_animofs(this, anim_pvz_yeti_run, 3, pvz_yeti_run4); ai_run(this, 10); }
void pvz_yeti_run2(entity this) { set_animofs(this, anim_pvz_yeti_run, 2, pvz_yeti_run3); ai_run(this, 10); monster_footstep(this, false); }
void pvz_yeti_run1(entity this)
{
	set_animofs(this, anim_pvz_yeti_run, 1, pvz_yeti_run2);
	if(random() < 0.2)
	{
		if(random() > 0.5)
			_sound(this, CH_VOICE, "pvz/lowgroan.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "pvz/lowgroan2.wav", 1, ATTN_IDLE);
	}
	ai_run(this, 9);
}

void pvz_yeti_atta9(entity this) { set_animofs(this, anim_pvz_yeti_attack, 9, pvz_yeti_run1); ai_charge(this, 0); }
void pvz_yeti_atta8(entity this) { set_animofs(this, anim_pvz_yeti_attack, 8, pvz_yeti_atta9); ai_charge(this, 0); }
void pvz_yeti_atta7(entity this) { set_animofs(this, anim_pvz_yeti_attack, 7, pvz_yeti_atta8); ai_charge(this, 0); monster_footstep(this, false); }
void pvz_yeti_atta6(entity this) { set_animofs(this, anim_pvz_yeti_attack, 6, pvz_yeti_atta7); ai_charge(this, 0); }
void pvz_yeti_atta5(entity this) { set_animofs(this, anim_pvz_yeti_attack, 5, pvz_yeti_atta6); ai_charge(this, 0); }
void pvz_yeti_atta4(entity this)
{
	set_animofs(this, anim_pvz_yeti_attack, 4, pvz_yeti_atta5);
	pvz_yeti_bite(this);
}
void pvz_yeti_atta3(entity this) { set_animofs(this, anim_pvz_yeti_attack, 3, pvz_yeti_atta4); ai_charge(this, 0); }
void pvz_yeti_atta2(entity this) { set_animofs(this, anim_pvz_yeti_attack, 2, pvz_yeti_atta3); ai_charge(this, 0); }
void pvz_yeti_atta1(entity this) { set_animofs(this, anim_pvz_yeti_attack, 1, pvz_yeti_atta2); ai_charge(this, 0); }

void pvz_yeti_leap1(entity this) { pvz_yeti_atta1(this); }

void pvz_yeti_pain7(entity this) { set_animofs(this, anim_pvz_yeti_pain, 7, pvz_yeti_run1); }
void pvz_yeti_pain6(entity this) { set_animofs(this, anim_pvz_yeti_pain, 6, pvz_yeti_pain7); }
void pvz_yeti_pain5(entity this) { set_animofs(this, anim_pvz_yeti_pain, 5, pvz_yeti_pain6); }
void pvz_yeti_pain4(entity this) { set_animofs(this, anim_pvz_yeti_pain, 4, pvz_yeti_pain5); }
void pvz_yeti_pain3(entity this) { set_animofs(this, anim_pvz_yeti_pain, 3, pvz_yeti_pain4); }
void pvz_yeti_pain2(entity this) { set_animofs(this, anim_pvz_yeti_pain, 2, pvz_yeti_pain3); }
void pvz_yeti_pain1(entity this) { set_animofs(this, anim_pvz_yeti_pain, 1, pvz_yeti_pain2); }

void pvz_yeti_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	_sound(this, CH_VOICE, "pvz/groan2.wav", 1, ATTN_NORM);

	this.pain_finished = time + 1;

	//pvz_yeti_pain1(this);
}

void pvz_yeti_diea13(entity this) { set_animofs(this, anim_pvz_yeti_deatha, 13, pvz_yeti_diea13); CorpseThink(this); }
void pvz_yeti_diea12(entity this) { set_animofs(this, anim_pvz_yeti_deatha, 12, pvz_yeti_diea13); }
void pvz_yeti_diea11(entity this) { set_animofs(this, anim_pvz_yeti_deatha, 11, pvz_yeti_diea12); }
void pvz_yeti_diea10(entity this) { set_animofs(this, anim_pvz_yeti_deatha, 10, pvz_yeti_diea11); }
void pvz_yeti_diea9(entity this) { set_animofs(this, anim_pvz_yeti_deatha, 9, pvz_yeti_diea10); }
void pvz_yeti_diea8(entity this) { set_animofs(this, anim_pvz_yeti_deatha, 8, pvz_yeti_diea9); }
void pvz_yeti_diea7(entity this) { set_animofs(this, anim_pvz_yeti_deatha, 7, pvz_yeti_diea8); }
void pvz_yeti_diea6(entity this) { set_animofs(this, anim_pvz_yeti_deatha, 6, pvz_yeti_diea7); }
void pvz_yeti_diea5(entity this) { set_animofs(this, anim_pvz_yeti_deatha, 5, pvz_yeti_diea6); }
void pvz_yeti_diea4(entity this) { set_animofs(this, anim_pvz_yeti_deatha, 4, pvz_yeti_diea5); }
void pvz_yeti_diea3(entity this) { set_animofs(this, anim_pvz_yeti_deatha, 3, pvz_yeti_diea4); }
void pvz_yeti_diea2(entity this) { set_animofs(this, anim_pvz_yeti_deatha, 2, pvz_yeti_diea3); }
void pvz_yeti_diea1(entity this) { set_animofs(this, anim_pvz_yeti_deatha, 1, pvz_yeti_diea2); }

void pvz_yeti_dieb12(entity this) { set_animofs(this, anim_pvz_yeti_deathb, 12, pvz_yeti_dieb12); CorpseThink(this); }
void pvz_yeti_dieb11(entity this) { set_animofs(this, anim_pvz_yeti_deathb, 11, pvz_yeti_dieb12); }
void pvz_yeti_dieb10(entity this) { set_animofs(this, anim_pvz_yeti_deathb, 10, pvz_yeti_dieb11); }
void pvz_yeti_dieb9(entity this) { set_animofs(this, anim_pvz_yeti_deathb, 9, pvz_yeti_dieb10); }
void pvz_yeti_dieb8(entity this) { set_animofs(this, anim_pvz_yeti_deathb, 8, pvz_yeti_dieb9); }
void pvz_yeti_dieb7(entity this) { set_animofs(this, anim_pvz_yeti_deathb, 7, pvz_yeti_dieb8); }
void pvz_yeti_dieb6(entity this) { set_animofs(this, anim_pvz_yeti_deathb, 6, pvz_yeti_dieb7); }
void pvz_yeti_dieb5(entity this) { set_animofs(this, anim_pvz_yeti_deathb, 5, pvz_yeti_dieb6); }
void pvz_yeti_dieb4(entity this) { set_animofs(this, anim_pvz_yeti_deathb, 4, pvz_yeti_dieb5); }
void pvz_yeti_dieb3(entity this) { set_animofs(this, anim_pvz_yeti_deathb, 3, pvz_yeti_dieb4); }
void pvz_yeti_dieb2(entity this) { set_animofs(this, anim_pvz_yeti_deathb, 2, pvz_yeti_dieb3); }
void pvz_yeti_dieb1(entity this) { set_animofs(this, anim_pvz_yeti_deathb, 1, pvz_yeti_dieb2); }

void pvz_yeti_diec12(entity this) { set_animofs(this, anim_pvz_yeti_deathc, 12, pvz_yeti_diec12); CorpseThink(this); }
void pvz_yeti_diec11(entity this) { set_animofs(this, anim_pvz_yeti_deathc, 11, pvz_yeti_diec12); }
void pvz_yeti_diec10(entity this) { set_animofs(this, anim_pvz_yeti_deathc, 10, pvz_yeti_diec11); }
void pvz_yeti_diec9(entity this) { set_animofs(this, anim_pvz_yeti_deathc, 9, pvz_yeti_diec10); }
void pvz_yeti_diec8(entity this) { set_animofs(this, anim_pvz_yeti_deathc, 8, pvz_yeti_diec9); }
void pvz_yeti_diec7(entity this) { set_animofs(this, anim_pvz_yeti_deathc, 7, pvz_yeti_diec8); }
void pvz_yeti_diec6(entity this) { set_animofs(this, anim_pvz_yeti_deathc, 6, pvz_yeti_diec7); }
void pvz_yeti_diec5(entity this) { set_animofs(this, anim_pvz_yeti_deathc, 5, pvz_yeti_diec6); }
void pvz_yeti_diec4(entity this) { set_animofs(this, anim_pvz_yeti_deathc, 4, pvz_yeti_diec5); }
void pvz_yeti_diec3(entity this) { set_animofs(this, anim_pvz_yeti_deathc, 3, pvz_yeti_diec4); }
void pvz_yeti_diec2(entity this) { set_animofs(this, anim_pvz_yeti_deathc, 2, pvz_yeti_diec3); }
void pvz_yeti_diec1(entity this) { set_animofs(this, anim_pvz_yeti_deathc, 1, pvz_yeti_diec2); }

void pvz_yeti_died8(entity this) { set_animofs(this, anim_pvz_yeti_deathd, 8, pvz_yeti_died8); CorpseThink(this); }
void pvz_yeti_died7(entity this) { set_animofs(this, anim_pvz_yeti_deathd, 7, pvz_yeti_died8); }
void pvz_yeti_died6(entity this) { set_animofs(this, anim_pvz_yeti_deathd, 6, pvz_yeti_died7); }
void pvz_yeti_died5(entity this) { set_animofs(this, anim_pvz_yeti_deathd, 5, pvz_yeti_died6); }
void pvz_yeti_died4(entity this) { set_animofs(this, anim_pvz_yeti_deathd, 4, pvz_yeti_died5); }
void pvz_yeti_died3(entity this) { set_animofs(this, anim_pvz_yeti_deathd, 3, pvz_yeti_died4); }
void pvz_yeti_died2(entity this) { set_animofs(this, anim_pvz_yeti_deathd, 2, pvz_yeti_died3); }
void pvz_yeti_died1(entity this) { set_animofs(this, anim_pvz_yeti_deathd, 1, pvz_yeti_died2); }

void pvz_yeti_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
			ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
			ThrowGib(this, inflictor, "progs/grenbone.mdl", this.health);
			ThrowGib(this, inflictor, "progs/grenbone.mdl", this.health);
			ThrowGib(this, inflictor, "progs/grenbone.mdl", this.health);
			ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
			ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
			ThrowGib(this, inflictor, "progs/h_pvz_worker.mdl", this.health);
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

// regular death
	_sound(this, CH_VOICE, "pvz/groan4.wav", 1, ATTN_NORM);
	this.solid = SOLID_NOT;

	float r = random();
	if(r < 0.25)
		pvz_yeti_diea1(this);
	else if(r < 0.50)
		pvz_yeti_dieb1(this);
	else if(r < 0.75)
		pvz_yeti_diec1(this);
	else
		pvz_yeti_died1(this);
}

//============================================================================

/*
==============
CheckPvZombieYetiMelee

Returns true if a melee attack would hit right now
==============
*/
bool CheckPvZombieYetiMelee(entity this)
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
CheckPvZombieYetiJump

==============
*/
bool CheckPvZombieYetiJump(entity this)
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

bool PvZombieYetiCheckAttack(entity this)
{
// if close enough for slashing, go for it
	if(CheckPvZombieYetiMelee(this))
	{
		this.attack_state = AS_MELEE;
		return true;
	}
	
	//if(CheckPvZombieYetiJump(this))
	//{
		//this.attack_state = AS_MISSILE;
		//return true;
	//}
	
	return false;
}

/*QUAKED monster_pvzombie_yeti(1 0 0)(-32 -32 -24)(32 32 40) Ambush
*/
spawnfunc(monster_pvzombie_yeti) { monster_start(this, true, MON_PVZOMBIE_YETI); }
#endif // SVQC

#ifdef SVQC
METHOD(PvZombieYeti, mr_setup, bool(PvZombieYeti this, entity actor))
{
	TC(PvZombieYeti, this);

	precache_model("progs/h_pvz_worker.mdl");
	precache_model("progs/grenbone.mdl");
	precache_sound("pvz/chomp.wav");
	precache_sound("pvz/chomp2.wav");
	precache_sound("pvz/lowgroan.wav");
	precache_sound("pvz/lowgroan2.wav");
	//precache_sound("pvz/groan.wav");
	precache_sound("pvz/groan2.wav");
	//precache_sound("pvz/groan3.wav");
	precache_sound("pvz/groan4.wav");
	precache_sound("pvz/groan5.wav");
	precache_sound("pvz/groan6.wav");

	if(!actor.health)
		actor.health = 600;
	actor.gibhealth = -85;
	actor.th_stand = pvz_yeti_stand1;
	actor.th_walk = pvz_yeti_walk1;
	actor.th_run = pvz_yeti_run1;
	actor.th_pain = pvz_yeti_pain;
	actor.th_die = pvz_yeti_die;
	actor.th_melee = pvz_yeti_atta1;
	//actor.th_missile = pvz_yeti_leap1;

	actor.checkattack = PvZombieYetiCheckAttack;

	actor.steptype = FS_TYPEHEAVY;

	return true;
}
METHOD(PvZombieYeti, mr_sight, bool(PvZombieYeti this, entity actor))
{
	TC(PvZombieYeti, this);

	if(random() > 0.5)
		_sound(actor, CH_VOICE, "pvz/groan5.wav", 1, ATTN_NORM);
	else
		_sound(actor, CH_VOICE, "pvz/groan6.wav", 1, ATTN_NORM);

	return true;
}
#endif
