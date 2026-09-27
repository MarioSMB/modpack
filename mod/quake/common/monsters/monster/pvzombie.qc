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
void pvz_run(entity this);


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

	setthink(this, pvz_run);
	this.nextthink = time + 0.1;
}

void pvz_stand(entity this)
{
	this.nextthink = time + 0.1;
	setthink(this, pvz_stand);

	this.frame = anim_pvz_idle + this.walkframe;
	this.walkframe += 1;
	if(this.walkframe >= 9)
		this.walkframe = 0;

	ai_stand(this);
}

void pvz_walk(entity this)
{
	this.nextthink = time + 0.1;
	setthink(this, pvz_walk);

	if(this.walkframe == 0 && random() < 0.25)
	{
		if(random() > 0.5)
			_sound(this, CH_VOICE, "pvz/groan.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "pvz/groan3.wav", 1, ATTN_IDLE);
	}

	if(this.walkframe % 2)
		monster_footstep(this, false);

	this.frame = anim_pvz_walk + this.walkframe;
	this.walkframe += 1;
	if(this.walkframe >= 17)
		this.walkframe = 0;

	ai_walk(this, 3);
}

void pvz_run(entity this)
{
	this.nextthink = time + 0.1;
	setthink(this, pvz_run);

	if(this.walkframe == 0 && random() < 0.25)
	{
		if(random() > 0.5)
			_sound(this, CH_VOICE, "pvz/groan.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "pvz/groan3.wav", 1, ATTN_IDLE);
	}

	this.frame = anim_pvz_run + this.walkframe;
	this.walkframe += 1;
	if(this.walkframe >= 8)
		this.walkframe = 0;

	switch(this.walkframe + 1)
	{
		case 1: ai_run(this, 5); break;
		case 2: ai_run(this, 6); monster_footstep(this, false); break;
		case 3: ai_run(this, 6); break;
		case 4: ai_run(this, 5); monster_footstep(this, false); break;
		case 5: ai_run(this, 6); break;
		case 6: ai_run(this, 5); break;
		case 7: ai_run(this, 8); monster_footstep(this, false); break;
		case 8: ai_run(this, 6); break;
		default: ai_run(this, 5); break;
	}
}

void pvz_atta9(entity this) { set_animofs(this, anim_pvz_attack, 9, pvz_run); ai_charge(this, 0); }
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

void pvz_pain7(entity this) { set_animofs(this, anim_pvz_pain, 7, pvz_run); }
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

void pvz_diea(entity this)
{
	this.nextthink = time + 0.1;
	setthink(this, pvz_diea);

	this.frame = anim_pvz_deatha + this.walkframe;
	this.walkframe += 1;
	if(this.walkframe >= 13)
		CorpseThink(this);
}

void pvz_dieb(entity this)
{
	this.nextthink = time + 0.1;
	setthink(this, pvz_dieb);

	this.frame = anim_pvz_deathb + this.walkframe;
	this.walkframe += 1;
	if(this.walkframe >= 12)
		CorpseThink(this);
}

void pvz_diec(entity this)
{
	this.nextthink = time + 0.1;
	setthink(this, pvz_diec);

	this.frame = anim_pvz_deathc + this.walkframe;
	this.walkframe += 1;
	if(this.walkframe >= 12)
		CorpseThink(this);
}

void pvz_died(entity this)
{
	this.nextthink = time + 0.1;
	setthink(this, pvz_died);

	this.frame = anim_pvz_deathd + this.walkframe;
	this.walkframe += 1;
	if(this.walkframe >= 8)
		CorpseThink(this);
}

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

	this.walkframe = 0;

	float r = random();
	if(r < 0.25)
		pvz_diea(this);
	else if(r < 0.50)
		pvz_dieb(this);
	else if(r < 0.75)
		pvz_diec(this);
	else
		pvz_died(this);
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
	actor.th_stand = pvz_stand;
	actor.th_walk = pvz_walk;
	actor.th_run = pvz_run;
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
