#include "pvzombie_balloon.qh"

#ifdef SVQC
const int anim_pvz_balloon_fly = 0;
const int anim_pvz_balloon_drop = 16;
const int anim_pvz_balloon_pain = 31;
const int anim_pvz_balloon_death = 41;

void pvz_balloon_stand(entity this)
{
	this.walkframe += 1;
	if(this.walkframe > 15)
		this.walkframe = 0;
	set_animofs(this, anim_pvz_balloon_fly, this.walkframe + 1, pvz_balloon_stand);
	ai_stand(this);
}

void pvz_balloon_walk(entity this)
{
	this.walkframe += 1;
	if(this.walkframe > 15)
		this.walkframe = 0;
	set_animofs(this, anim_pvz_balloon_fly, this.walkframe + 1, pvz_balloon_walk);
	ai_walk(this, 4);

	if(random() < 0.075)
	{
		if(random() > 0.5)
			_sound(this, CH_VOICE, "pvz/groan.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "pvz/groan3.wav", 1, ATTN_IDLE);
	}
}

void pvz_balloon_run(entity this)
{
	this.walkframe += 1;
	if(this.walkframe > 15)
		this.walkframe = 0;
	set_animofs(this, anim_pvz_balloon_fly, this.walkframe + 1, pvz_balloon_run);
	ai_run(this, 4);

	if(random() < 0.075)
	{
		if(random() > 0.5)
			_sound(this, CH_VOICE, "pvz/groan.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "pvz/groan3.wav", 1, ATTN_IDLE);
	}
}

void pvz_balloon_pain10(entity this) { set_animofs(this, anim_pvz_balloon_pain, 10, pvz_balloon_run); ai_painforward(this, 4); }
void pvz_balloon_pain9(entity this) { set_animofs(this, anim_pvz_balloon_pain, 9, pvz_balloon_pain10); ai_painforward(this, 4); }
void pvz_balloon_pain8(entity this) { set_animofs(this, anim_pvz_balloon_pain, 8, pvz_balloon_pain9); ai_painforward(this, 4); }
void pvz_balloon_pain7(entity this) { set_animofs(this, anim_pvz_balloon_pain, 7, pvz_balloon_pain8); ai_painforward(this, 4); }
void pvz_balloon_pain6(entity this) { set_animofs(this, anim_pvz_balloon_pain, 6, pvz_balloon_pain7); ai_painforward(this, 4); }
void pvz_balloon_pain5(entity this) { set_animofs(this, anim_pvz_balloon_pain, 5, pvz_balloon_pain6); ai_painforward(this, 4); }
void pvz_balloon_pain4(entity this) { set_animofs(this, anim_pvz_balloon_pain, 4, pvz_balloon_pain5); ai_painforward(this, 4); }
void pvz_balloon_pain3(entity this) { set_animofs(this, anim_pvz_balloon_pain, 3, pvz_balloon_pain4); ai_painforward(this, 4); }
void pvz_balloon_pain2(entity this) { set_animofs(this, anim_pvz_balloon_pain, 2, pvz_balloon_pain3); ai_painforward(this, 4); }
void pvz_balloon_pain1(entity this) { set_animofs(this, anim_pvz_balloon_pain, 1, pvz_balloon_pain2); ai_painforward(this, 4); }

void pvz_balloon_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	_sound(this, CH_VOICE, "pvz/groan2.wav", 1, ATTN_NORM);

	this.pain_finished = time + 1;

	//setthink(this, pvz_balloon_pain1);
	//this.nextthink = time;
}

void pvz_balloon_death(entity this)
{
	set_animofs(this, anim_pvz_balloon_death, this.walkframe + 1, pvz_balloon_death);

	this.walkframe += 1;
	if((this.walkframe + 1) == 34)
	{
		set_movetype(this, MOVETYPE_TOSS);
		this.velocity = '0 0 -12';
		UNSET_ONGROUND(this);
	}

	if(this.walkframe >= 45)
	{
		this.walkframe = 45;
		this.nextthink = 0;
		setthink(this, func_null);
		CorpseThink(this);
	}
}

void pvz_balloon_die(entity this, entity inflictor, entity attacker, int deathtype)
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
	this.flags |= FL_FLY; // removed by death, but we wanna keep it!

	this.walkframe = 0;
	pvz_balloon_death(this);
}

//============================================================================

void pvz_balloon_drop15(entity this)
{
	set_animofs(this, anim_pvz_balloon_drop, 15, pvz_balloon_drop15);

	if(!IS_ONGROUND(this))
		return;

	entity body = new(monster);
	body.skin = 1;
	body.variant = PVZ_BALLOON;
	minion_spawn(this, this.origin, body, MON_PVZOMBIE);
	body.flags &= ~FL_CLONE;
	body.flags &= ~FL_MINION;

	delete(this);
}
void pvz_balloon_drop14(entity this) { set_animofs(this, anim_pvz_balloon_drop, 14, pvz_balloon_drop15); UNSET_ONGROUND(this); set_movetype(this, MOVETYPE_TOSS); }
void pvz_balloon_drop13(entity this) { set_animofs(this, anim_pvz_balloon_drop, 13, pvz_balloon_drop14); }
void pvz_balloon_drop12(entity this) { set_animofs(this, anim_pvz_balloon_drop, 12, pvz_balloon_drop13); }
void pvz_balloon_drop11(entity this) { set_animofs(this, anim_pvz_balloon_drop, 11, pvz_balloon_drop12); }
void pvz_balloon_drop10(entity this) { set_animofs(this, anim_pvz_balloon_drop, 10, pvz_balloon_drop11); }
void pvz_balloon_drop9(entity this) { set_animofs(this, anim_pvz_balloon_drop, 9, pvz_balloon_drop10); }
void pvz_balloon_drop8(entity this) { set_animofs(this, anim_pvz_balloon_drop, 8, pvz_balloon_drop9); }
void pvz_balloon_drop7(entity this) { set_animofs(this, anim_pvz_balloon_drop, 7, pvz_balloon_drop8); }
void pvz_balloon_drop6(entity this) { set_animofs(this, anim_pvz_balloon_drop, 6, pvz_balloon_drop7); }
void pvz_balloon_drop5(entity this) { set_animofs(this, anim_pvz_balloon_drop, 5, pvz_balloon_drop6); }
void pvz_balloon_drop4(entity this) { set_animofs(this, anim_pvz_balloon_drop, 4, pvz_balloon_drop5); }
void pvz_balloon_drop3(entity this) { set_animofs(this, anim_pvz_balloon_drop, 3, pvz_balloon_drop4); }
void pvz_balloon_drop2(entity this) { set_animofs(this, anim_pvz_balloon_drop, 2, pvz_balloon_drop3); }
void pvz_balloon_drop1(entity this) { set_animofs(this, anim_pvz_balloon_drop, 1, pvz_balloon_drop2); }

bool PvZombieBalloonCheckAttack(entity this)
{
	vector dist = vec2(this.enemy.origin - this.origin);

	if(vdist(dist, <=, 200))
	{
		setthink(this, pvz_balloon_drop1);
		this.nextthink = time;
		return true;
	}
	
	return false;
}

/*QUAKED monster_pvzombie_balloon(1 0 0)(-32 -32 -24)(32 32 40) Ambush
*/
spawnfunc(monster_pvzombie_balloon) { monster_start(this, true, MON_PVZOMBIE); }
#endif // SVQC

#ifdef SVQC
METHOD(PvZombieBalloon, mr_setup, bool(PvZombieBalloon this, entity actor))
{
	TC(PvZombieBalloon, this);

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

	if(!actor.health)
		actor.health = 110;
	actor.gibhealth = -40;
	actor.th_stand = pvz_balloon_stand;
	actor.th_walk = pvz_balloon_walk;
	actor.th_run = pvz_balloon_run;
	actor.th_pain = pvz_balloon_pain;
	actor.th_die = pvz_balloon_die;

	actor.checkattack = PvZombieBalloonCheckAttack;

	return true;
}
#endif
