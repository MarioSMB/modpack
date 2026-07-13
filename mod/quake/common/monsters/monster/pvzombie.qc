#include "pvzombie.qh"

#ifdef SVQC
const int anim_pvz_idle = 0;
const int anim_pvz_walk = 9;
const int anim_pvz_run = 26;
const int anim_pvz_pain = 35;
const int anim_pvz_attack = 42;
const int anim_pvz_deatha = 51;
const int anim_pvz_deathb = 64;
const int anim_pvz_deathc = 76;
const int anim_pvz_deathd = 88;

// progs_dump compat
.string mdl_body;
.string mdl_head;
.int skin_head;
.int variant;

void pvz_leap1(entity this);
void pvz_run1(entity this);


/*
================
pvz_bite

================
*/
void pvz_bite(entity this)
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
		
	float ldmg =(random() + random() + random()) * 8;
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_PVZOMBIE.m_id);
}

void PvZombie_JumpTouch(entity this, entity toucher)
{
	if(this.health <= 0 || !this.takedamage)
		return;

	ai_jumpbreakable(this, toucher, 20);			// Damage any breakables
		
	if(toucher.takedamage && this.attack_finished < time)
	{
		if(vdist(this.velocity, >, 300))
		{
			float ldmg = 10 + 10*random();
			T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_PVZOMBIE.m_id);
			this.attack_finished = time + 0.5;
		}
	}

	if(!t_checkbottom(this))
	{
		if(IS_ONGROUND(this) && this.exptime == 0)
		{	// jump randomly to not get hung up
			//dprint("popjump\n");
			settouch(this, func_null);
			setthink(this, pvz_leap1);
			this.nextthink = time + 0.1;

//			this.velocity_x =(random() - 0.5) * 600;
//			this.velocity_y =(random() - 0.5) * 600;
//			this.velocity_z = 200;
//			this.flags = this.flags - FL_ONGROUND;
		}
		return;	// not on ground yet
	}

	settouch(this, func_null);
	if(this.exptime != 0)
		return;

	setthink(this, pvz_run1);
	this.nextthink = time + 0.1;
}

void pvz_stand1(entity this);
void pvz_stand9(entity this) { set_animofs(this, anim_pvz_idle, 9, pvz_stand1); ai_stand(this); }
void pvz_stand8(entity this) { set_animofs(this, anim_pvz_idle, 8, pvz_stand9); ai_stand(this); }
void pvz_stand7(entity this) { set_animofs(this, anim_pvz_idle, 7, pvz_stand8); ai_stand(this); }
void pvz_stand6(entity this) { set_animofs(this, anim_pvz_idle, 6, pvz_stand7); ai_stand(this); }
void pvz_stand5(entity this) { set_animofs(this, anim_pvz_idle, 5, pvz_stand6); ai_stand(this); }
void pvz_stand4(entity this) { set_animofs(this, anim_pvz_idle, 4, pvz_stand5); ai_stand(this); }
void pvz_stand3(entity this) { set_animofs(this, anim_pvz_idle, 3, pvz_stand4); ai_stand(this); }
void pvz_stand2(entity this) { set_animofs(this, anim_pvz_idle, 2, pvz_stand3); ai_stand(this); }
void pvz_stand1(entity this) { set_animofs(this, anim_pvz_idle, 1, pvz_stand2); ai_stand(this); }

void pvz_walk1(entity this);
void pvz_walk17(entity this) { set_animofs(this, anim_pvz_walk, 17, pvz_walk1); ai_walk(this, 3); }
void pvz_walk16(entity this) { set_animofs(this, anim_pvz_walk, 16, pvz_walk17); ai_walk(this, 3); monster_footstep(this, false); }
void pvz_walk15(entity this) { set_animofs(this, anim_pvz_walk, 15, pvz_walk16); ai_walk(this, 3); }
void pvz_walk14(entity this) { set_animofs(this, anim_pvz_walk, 14, pvz_walk15); ai_walk(this, 3); monster_footstep(this, false); }
void pvz_walk13(entity this) { set_animofs(this, anim_pvz_walk, 13, pvz_walk14); ai_walk(this, 3); }
void pvz_walk12(entity this) { set_animofs(this, anim_pvz_walk, 12, pvz_walk13); ai_walk(this, 3); monster_footstep(this, false); }
void pvz_walk11(entity this) { set_animofs(this, anim_pvz_walk, 11, pvz_walk12); ai_walk(this, 3); }
void pvz_walk10(entity this) { set_animofs(this, anim_pvz_walk, 10, pvz_walk11); ai_walk(this, 3); monster_footstep(this, false); }
void pvz_walk9(entity this) { set_animofs(this, anim_pvz_walk, 9, pvz_walk10); ai_walk(this, 3); }
void pvz_walk8(entity this) { set_animofs(this, anim_pvz_walk, 8, pvz_walk9); ai_walk(this, 3); monster_footstep(this, false); }
void pvz_walk7(entity this) { set_animofs(this, anim_pvz_walk, 7, pvz_walk8); ai_walk(this, 3); }
void pvz_walk6(entity this) { set_animofs(this, anim_pvz_walk, 6, pvz_walk7); ai_walk(this, 3); monster_footstep(this, false); }
void pvz_walk5(entity this) { set_animofs(this, anim_pvz_walk, 5, pvz_walk6); ai_walk(this, 3); }
void pvz_walk4(entity this) { set_animofs(this, anim_pvz_walk, 4, pvz_walk5); ai_walk(this, 3); monster_footstep(this, false); }
void pvz_walk3(entity this) { set_animofs(this, anim_pvz_walk, 3, pvz_walk4); ai_walk(this, 3); }
void pvz_walk2(entity this) { set_animofs(this, anim_pvz_walk, 2, pvz_walk3); ai_walk(this, 3); monster_footstep(this, false); }
void pvz_walk1(entity this)
{
	set_animofs(this, anim_pvz_walk, 1, pvz_walk2);
	if(random() < 0.25)
	{
		if(random() > 0.5)
			_sound(this, CH_VOICE, "pvz/groan.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "pvz/groan3.wav", 1, ATTN_IDLE);
	}
	ai_walk(this, 3);
}

void pvz_run1(entity this);
void pvz_run8(entity this) { set_animofs(this, anim_pvz_run, 8, pvz_run1); ai_run(this, 6); }
void pvz_run7(entity this) { set_animofs(this, anim_pvz_run, 7, pvz_run8); ai_run(this, 8); monster_footstep(this, false); }
void pvz_run6(entity this) { set_animofs(this, anim_pvz_run, 6, pvz_run7); ai_run(this, 5); }
void pvz_run5(entity this) { set_animofs(this, anim_pvz_run, 5, pvz_run6); ai_run(this, 6); }
void pvz_run4(entity this) { set_animofs(this, anim_pvz_run, 4, pvz_run5); ai_run(this, 5); monster_footstep(this, false); }
void pvz_run3(entity this) { set_animofs(this, anim_pvz_run, 3, pvz_run4); ai_run(this, 6); }
void pvz_run2(entity this) { set_animofs(this, anim_pvz_run, 2, pvz_run3); ai_run(this, 6); monster_footstep(this, false); }
void pvz_run1(entity this)
{
	set_animofs(this, anim_pvz_run, 1, pvz_run2);
	if(random() < 0.2)
	{
		if(random() > 0.5)
			_sound(this, CH_VOICE, "pvz/groan.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "pvz/groan3.wav", 1, ATTN_IDLE);
	}
	ai_run(this, 5);
}

void pvz_atta9(entity this) { set_animofs(this, anim_pvz_attack, 9, pvz_run1); ai_charge(this, 0); }
void pvz_atta8(entity this) { set_animofs(this, anim_pvz_attack, 8, pvz_atta9); ai_charge(this, 0); }
void pvz_atta7(entity this) { set_animofs(this, anim_pvz_attack, 7, pvz_atta8); ai_charge(this, 0); monster_footstep(this, false); }
void pvz_atta6(entity this) { set_animofs(this, anim_pvz_attack, 6, pvz_atta7); ai_charge(this, 0); }
void pvz_atta5(entity this) { set_animofs(this, anim_pvz_attack, 5, pvz_atta6); ai_charge(this, 0); }
void pvz_atta4(entity this)
{
	set_animofs(this, anim_pvz_attack, 4, pvz_atta5);
	pvz_bite(this);
}
void pvz_atta3(entity this) { set_animofs(this, anim_pvz_attack, 3, pvz_atta4); ai_charge(this, 0); }
void pvz_atta2(entity this) { set_animofs(this, anim_pvz_attack, 2, pvz_atta3); ai_charge(this, 0); }
void pvz_atta1(entity this) { set_animofs(this, anim_pvz_attack, 1, pvz_atta2); ai_charge(this, 0); }

void pvz_leap1(entity this) { pvz_atta1(this); }

void pvz_pain7(entity this) { set_animofs(this, anim_pvz_pain, 7, pvz_run1); }
void pvz_pain6(entity this) { set_animofs(this, anim_pvz_pain, 6, pvz_pain7); }
void pvz_pain5(entity this) { set_animofs(this, anim_pvz_pain, 5, pvz_pain6); }
void pvz_pain4(entity this) { set_animofs(this, anim_pvz_pain, 4, pvz_pain5); }
void pvz_pain3(entity this) { set_animofs(this, anim_pvz_pain, 3, pvz_pain4); }
void pvz_pain2(entity this) { set_animofs(this, anim_pvz_pain, 2, pvz_pain3); }
void pvz_pain1(entity this) { set_animofs(this, anim_pvz_pain, 1, pvz_pain2); }

void pvz_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	_sound(this, CH_VOICE, "pvz/groan2.wav", 1, ATTN_NORM);

	this.pain_finished = time + 1;

	pvz_pain1(this);
}

void pvz_diea13(entity this) { set_animofs(this, anim_pvz_deatha, 13, pvz_diea13); CorpseThink(this); }
void pvz_diea12(entity this) { set_animofs(this, anim_pvz_deatha, 12, pvz_diea13); }
void pvz_diea11(entity this) { set_animofs(this, anim_pvz_deatha, 11, pvz_diea12); }
void pvz_diea10(entity this) { set_animofs(this, anim_pvz_deatha, 10, pvz_diea11); }
void pvz_diea9(entity this) { set_animofs(this, anim_pvz_deatha, 9, pvz_diea10); }
void pvz_diea8(entity this) { set_animofs(this, anim_pvz_deatha, 8, pvz_diea9); }
void pvz_diea7(entity this) { set_animofs(this, anim_pvz_deatha, 7, pvz_diea8); }
void pvz_diea6(entity this) { set_animofs(this, anim_pvz_deatha, 6, pvz_diea7); }
void pvz_diea5(entity this) { set_animofs(this, anim_pvz_deatha, 5, pvz_diea6); }
void pvz_diea4(entity this) { set_animofs(this, anim_pvz_deatha, 4, pvz_diea5); }
void pvz_diea3(entity this) { set_animofs(this, anim_pvz_deatha, 3, pvz_diea4); }
void pvz_diea2(entity this) { set_animofs(this, anim_pvz_deatha, 2, pvz_diea3); }
void pvz_diea1(entity this) { set_animofs(this, anim_pvz_deatha, 1, pvz_diea2); }

void pvz_dieb12(entity this) { set_animofs(this, anim_pvz_deathb, 12, pvz_dieb12); CorpseThink(this); }
void pvz_dieb11(entity this) { set_animofs(this, anim_pvz_deathb, 11, pvz_dieb12); }
void pvz_dieb10(entity this) { set_animofs(this, anim_pvz_deathb, 10, pvz_dieb11); }
void pvz_dieb9(entity this) { set_animofs(this, anim_pvz_deathb, 9, pvz_dieb10); }
void pvz_dieb8(entity this) { set_animofs(this, anim_pvz_deathb, 8, pvz_dieb9); }
void pvz_dieb7(entity this) { set_animofs(this, anim_pvz_deathb, 7, pvz_dieb8); }
void pvz_dieb6(entity this) { set_animofs(this, anim_pvz_deathb, 6, pvz_dieb7); }
void pvz_dieb5(entity this) { set_animofs(this, anim_pvz_deathb, 5, pvz_dieb6); }
void pvz_dieb4(entity this) { set_animofs(this, anim_pvz_deathb, 4, pvz_dieb5); }
void pvz_dieb3(entity this) { set_animofs(this, anim_pvz_deathb, 3, pvz_dieb4); }
void pvz_dieb2(entity this) { set_animofs(this, anim_pvz_deathb, 2, pvz_dieb3); }
void pvz_dieb1(entity this) { set_animofs(this, anim_pvz_deathb, 1, pvz_dieb2); }

void pvz_diec12(entity this) { set_animofs(this, anim_pvz_deathc, 12, pvz_diec12); CorpseThink(this); }
void pvz_diec11(entity this) { set_animofs(this, anim_pvz_deathc, 11, pvz_diec12); }
void pvz_diec10(entity this) { set_animofs(this, anim_pvz_deathc, 10, pvz_diec11); }
void pvz_diec9(entity this) { set_animofs(this, anim_pvz_deathc, 9, pvz_diec10); }
void pvz_diec8(entity this) { set_animofs(this, anim_pvz_deathc, 8, pvz_diec9); }
void pvz_diec7(entity this) { set_animofs(this, anim_pvz_deathc, 7, pvz_diec8); }
void pvz_diec6(entity this) { set_animofs(this, anim_pvz_deathc, 6, pvz_diec7); }
void pvz_diec5(entity this) { set_animofs(this, anim_pvz_deathc, 5, pvz_diec6); }
void pvz_diec4(entity this) { set_animofs(this, anim_pvz_deathc, 4, pvz_diec5); }
void pvz_diec3(entity this) { set_animofs(this, anim_pvz_deathc, 3, pvz_diec4); }
void pvz_diec2(entity this) { set_animofs(this, anim_pvz_deathc, 2, pvz_diec3); }
void pvz_diec1(entity this) { set_animofs(this, anim_pvz_deathc, 1, pvz_diec2); }

void pvz_died8(entity this) { set_animofs(this, anim_pvz_deathd, 8, pvz_died8); CorpseThink(this); }
void pvz_died7(entity this) { set_animofs(this, anim_pvz_deathd, 7, pvz_died8); }
void pvz_died6(entity this) { set_animofs(this, anim_pvz_deathd, 6, pvz_died7); }
void pvz_died5(entity this) { set_animofs(this, anim_pvz_deathd, 5, pvz_died6); }
void pvz_died4(entity this) { set_animofs(this, anim_pvz_deathd, 4, pvz_died5); }
void pvz_died3(entity this) { set_animofs(this, anim_pvz_deathd, 3, pvz_died4); }
void pvz_died2(entity this) { set_animofs(this, anim_pvz_deathd, 2, pvz_died3); }
void pvz_died1(entity this) { set_animofs(this, anim_pvz_deathd, 1, pvz_died2); }

string pvz_headmodel(int num)
{
	return "progs/h_pvz_worker.mdl";
}

string pvz_getmodel(int num)
{
	switch(num)
	{
		case PVZ_DUCKIE: return "progs/pvz_duckie.mdl";
		case PVZ_BUCKETHEAD: return "progs/pvz_buckethead.mdl";
		case PVZ_NEWSPAPER: return "progs/pvz_newspaper.mdl";
		case PVZ_CONEHEAD: return "progs/pvz_conehead.mdl";
	}

	return "progs/pvz_worker.mdl";
}

void pvz_die(entity this, entity inflictor, entity attacker, int deathtype)
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
			if(this.mdl_head != "")
			{
				ThrowGib(this, inflictor, this.mdl_head, this.health);
				this.skin = this.skin_head;
			}
			else
				ThrowGib(this, inflictor, pvz_headmodel(this.variant), this.health);
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

// regular death
	_sound(this, CH_VOICE, "pvz/groan4.wav", 1, ATTN_NORM);
	this.solid = SOLID_NOT;

	float r = random();
	if(r < 0.25)
		pvz_diea1(this);
	else if(r < 0.50)
		pvz_dieb1(this);
	else if(r < 0.75)
		pvz_diec1(this);
	else
		pvz_died1(this);
}

//============================================================================

/*
==============
CheckPvZombieMelee

Returns true if a melee attack would hit right now
==============
*/
bool CheckPvZombieMelee(entity this)
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
CheckPvZombieJump

==============
*/
bool CheckPvZombieJump(entity this)
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

bool PvZombieCheckAttack(entity this)
{
// if close enough for slashing, go for it
	if(CheckPvZombieMelee(this))
	{
		this.attack_state = AS_MELEE;
		return true;
	}
	
	//if(CheckPvZombieJump(this))
	//{
		//this.attack_state = AS_MISSILE;
		//return true;
	//}
	
	return false;
}

/*QUAKED monster_pvzombie(1 0 0)(-32 -32 -24)(32 32 40) Ambush
*/
spawnfunc(monster_pvzombie) { monster_start(this, true, MON_PVZOMBIE); }
#endif // SVQC

#ifdef SVQC
METHOD(PvZombie, mr_setup, bool(PvZombie this, entity actor))
{
	TC(PvZombie, this);

	precache_model("progs/h_pvz_worker.mdl");
	precache_model("progs/grenbone.mdl");
	precache_sound("pvz/chomp.wav");
	precache_sound("pvz/chomp2.wav");
	precache_sound("pvz/groan.wav");
	precache_sound("pvz/groan2.wav");
	precache_sound("pvz/groan3.wav");
	precache_sound("pvz/groan4.wav");
	precache_sound("pvz/groan5.wav");
	precache_sound("pvz/groan6.wav");

	if(!actor.variant && random() < 0.2)
	{
		RandomSelection_Init();
		RandomSelection_AddFloat(PVZ_WORKER, 1, 1);
		// balloon not handled this way
		RandomSelection_AddFloat(PVZ_DUCKIE, 0.1, 1);
		RandomSelection_AddFloat(PVZ_BUCKETHEAD, 0.25, 1);
		RandomSelection_AddFloat(PVZ_NEWSPAPER, 0.25, 1);
		RandomSelection_AddFloat(PVZ_CONEHEAD, 0.25, 1);
		actor.variant = RandomSelection_chosen_float;
	}

	if(actor.variant && (!actor.mdl_body || actor.mdl_body == ""))
	{
		string mymdl = pvz_getmodel(actor.variant);
		string headmdl = pvz_headmodel(actor.variant);

		vector oldmin = actor.mins;
		vector oldmax = actor.maxs;
		precache_model(mymdl);
		_setmodel(actor, mymdl);
		setsize(actor, oldmin, oldmax);

		precache_model(headmdl);
	}
	else if(actor.mdl_head != "")
		precache_model(actor.mdl_head);

	if(actor.mdl_body != "")
	{
		vector oldmin = actor.mins;
		vector oldmax = actor.maxs;
		precache_model(actor.mdl_body);
		_setmodel(actor, actor.mdl_body);
		setsize(actor, oldmin, oldmax);
	}

	if(actor.variant == PVZ_BALLOON)
		actor.skin = 1;
	else if(actor.variant == PVZ_BUCKETHEAD)
	{
		actor.health = 100;
		actor.resist_shells = actor.resist_cells = 0.5;
		actor.resist_nails = actor.resist_rockets = 0.5;
	}
	else if(actor.variant)
		actor.health = 120;

	if(!actor.health)
		actor.health = 75;
	actor.gibhealth = -35;
	actor.th_stand = pvz_stand1;
	actor.th_walk = pvz_walk1;
	actor.th_run = pvz_run1;
	actor.th_pain = pvz_pain;
	actor.th_die = pvz_die;
	actor.th_melee = pvz_atta1;
	//actor.th_missile = pvz_leap1;

	actor.checkattack = PvZombieCheckAttack;

	actor.steptype = FS_TYPESLOW;

	return true;
}
METHOD(PvZombie, mr_sight, bool(PvZombie this, entity actor))
{
	TC(PvZombie, this);

	if(random() > 0.5)
		_sound(actor, CH_VOICE, "pvz/groan5.wav", 1, ATTN_NORM);
	else
		_sound(actor, CH_VOICE, "pvz/groan6.wav", 1, ATTN_NORM);

	return true;
}
#endif
