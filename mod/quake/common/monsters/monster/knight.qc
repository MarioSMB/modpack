#include "knight.qh"

#ifdef SVQC
const int anim_knight_stand = 0; //'0 8 0'
const int anim_knight_runb = 9; //'9 16 0'
const int anim_knight_runattack = 17; //'17 27 0'
const int anim_knight_pain = 28; //'28 30 0'
const int anim_knight_painb = 31; //'31 41 0'
const int anim_knight_attackb = 42; //'42 51 0'
const int anim_knight_walk = 52; //'52 65 0'
const int anim_knight_kneel = 66; //'66 70 0'
const int anim_knight_standing = 71; //'71 74 0'
const int anim_knight_death = 75; //'75 84 0'
const int anim_knight_deathb = 85; //'85 95 0'

void kn_idle_sound(entity this)
{
	if(random() < 0.2)
	{
		if((this.spawnflags & 2)) // statue)
			_sound(this, CH_VOICE, "statue/idle.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "knight/idle.wav", 1,  ATTN_IDLE);
	}
}

void knight_stand1(entity this);
void knight_stand9(entity this) { set_animofs(this, anim_knight_stand, 9, knight_stand1); ai_stand(this); }
void knight_stand8(entity this) { set_animofs(this, anim_knight_stand, 8, knight_stand9); ai_stand(this); }
void knight_stand7(entity this) { set_animofs(this, anim_knight_stand, 7, knight_stand8); ai_stand(this); }
void knight_stand6(entity this) { set_animofs(this, anim_knight_stand, 6, knight_stand7); ai_stand(this); }
void knight_stand5(entity this) { set_animofs(this, anim_knight_stand, 5, knight_stand6); ai_stand(this); }
void knight_stand4(entity this) { set_animofs(this, anim_knight_stand, 4, knight_stand5); ai_stand(this); }
void knight_stand3(entity this) { set_animofs(this, anim_knight_stand, 3, knight_stand4); ai_stand(this); }
void knight_stand2(entity this) { set_animofs(this, anim_knight_stand, 2, knight_stand3); ai_stand(this); }
void knight_stand1(entity this) { set_animofs(this, anim_knight_stand, 1, knight_stand2); ai_stand(this); }

void knight_walk1(entity this);
void knight_walk14(entity this) { set_animofs(this, anim_knight_walk, 14, knight_walk1); ai_walk(this, 3); }
void knight_walk13(entity this) { set_animofs(this, anim_knight_walk, 13, knight_walk14); ai_walk(this, 4); }
void knight_walk12(entity this) { set_animofs(this, anim_knight_walk, 12, knight_walk13); ai_walk(this, 3); }
void knight_walk11(entity this) { set_animofs(this, anim_knight_walk, 11, knight_walk12); ai_walk(this, 2); }
void knight_walk10(entity this) { set_animofs(this, anim_knight_walk, 10, knight_walk11); ai_walk(this, 3); }
void knight_walk9(entity this) { set_animofs(this, anim_knight_walk, 9, knight_walk10); ai_walk(this, 3); }
void knight_walk8(entity this) { set_animofs(this, anim_knight_walk, 8, knight_walk9); ai_walk(this, 4); }
void knight_walk7(entity this) { set_animofs(this, anim_knight_walk, 7, knight_walk8); ai_walk(this, 3); }
void knight_walk6(entity this) { set_animofs(this, anim_knight_walk, 6, knight_walk7); ai_walk(this, 3); }
void knight_walk5(entity this) { set_animofs(this, anim_knight_walk, 5, knight_walk6); ai_walk(this, 3); }
void knight_walk4(entity this) { set_animofs(this, anim_knight_walk, 4, knight_walk5); ai_walk(this, 4); }
void knight_walk3(entity this) { set_animofs(this, anim_knight_walk, 3, knight_walk4); ai_walk(this, 3); }
void knight_walk1(entity this) { set_animofs(this, anim_knight_walk, 2, knight_walk3); kn_idle_sound(this); ai_walk(this, 2); }
#if 0
void knight_walk1(entity this)
{
	set_animofs(this, anim_knight_walk, 1, knight_walk2);
	kn_idle_sound(this);
	ai_walk(this, 3);
}
#endif

void knight_run1(entity this);
void knight_run8(entity this) { set_animofs(this, anim_knight_runb, 8, knight_run1); ai_run(this, 6); }
void knight_run7(entity this) { set_animofs(this, anim_knight_runb, 7, knight_run8); ai_run(this, 14); }
void knight_run6(entity this) { set_animofs(this, anim_knight_runb, 6, knight_run7); ai_run(this, 20); }
void knight_run5(entity this) { set_animofs(this, anim_knight_runb, 5, knight_run6); ai_run(this, 16); }
void knight_run4(entity this) { set_animofs(this, anim_knight_runb, 4, knight_run5); ai_run(this, 7); }
void knight_run3(entity this) { set_animofs(this, anim_knight_runb, 3, knight_run4); ai_run(this, 13); }
void knight_run2(entity this) { set_animofs(this, anim_knight_runb, 2, knight_run3); ai_run(this, 20); }
void knight_run1(entity this)
{
	set_animofs(this, anim_knight_runb, 1, knight_run2);
	kn_idle_sound(this);
	ai_run(this, 16);
}

void knight_runatk11(entity this) { set_animofs(this, anim_knight_runattack, 11, knight_run1); ai_charge(this, 10); }
void knight_runatk10(entity this) { set_animofs(this, anim_knight_runattack, 10, knight_runatk11); ai_charge_side(this); }
void knight_runatk9(entity this) { set_animofs(this, anim_knight_runattack, 9, knight_runatk10); ai_melee_side(this, DEATH_MONSTER_KNIGHT.m_id); }
void knight_runatk8(entity this) { set_animofs(this, anim_knight_runattack, 8, knight_runatk9); ai_melee_side(this, DEATH_MONSTER_KNIGHT.m_id); }
void knight_runatk7(entity this) { set_animofs(this, anim_knight_runattack, 7, knight_runatk8); ai_melee_side(this, DEATH_MONSTER_KNIGHT.m_id); }
void knight_runatk6(entity this) { set_animofs(this, anim_knight_runattack, 6, knight_runatk7); ai_melee_side(this, DEATH_MONSTER_KNIGHT.m_id); }
void knight_runatk5(entity this) { set_animofs(this, anim_knight_runattack, 5, knight_runatk6); ai_melee_side(this, DEATH_MONSTER_KNIGHT.m_id); }
void knight_runatk4(entity this) { set_animofs(this, anim_knight_runattack, 4, knight_runatk5); ai_charge_side(this); }
void knight_runatk3(entity this) { set_animofs(this, anim_knight_runattack, 3, knight_runatk4); ai_charge_side(this); }
void knight_runatk2(entity this) { set_animofs(this, anim_knight_runattack, 2, knight_runatk3); ai_charge_side(this); }
void knight_runatk1(entity this)
{
	set_animofs(this, anim_knight_runattack, 1, knight_runatk2);
	if(random() > 0.5)
		_sound(this, CH_WEAPON_SINGLE, "knight/sword2.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "knight/sword1.wav", 1, ATTN_NORM);
	ai_charge(this, 20);
}

void knight_atk10(entity this) { set_animofs(this, anim_knight_attackb, 10, knight_run1); ai_charge(this, 5); }
void knight_atk9(entity this) { set_animofs(this, anim_knight_attackb, 9, knight_atk10); ai_charge(this, 1); }
void knight_atk8(entity this) { set_animofs(this, anim_knight_attackb, 8, knight_atk9); ai_charge(this, 3); ai_melee(this, DEATH_MONSTER_KNIGHT.m_id); }
void knight_atk7(entity this) { set_animofs(this, anim_knight_attackb, 7, knight_atk8); ai_charge(this, 1); ai_melee(this, DEATH_MONSTER_KNIGHT.m_id); }
void knight_atk6(entity this) { set_animofs(this, anim_knight_attackb, 6, knight_atk7); ai_charge(this, 4); ai_melee(this, DEATH_MONSTER_KNIGHT.m_id); }
void knight_atk5(entity this) { set_animofs(this, anim_knight_attackb, 5, knight_atk6); ai_charge(this, 3); }
void knight_atk4(entity this) { set_animofs(this, anim_knight_attackb, 4, knight_atk5); ai_charge(this, 0); }
void knight_atk3(entity this) { set_animofs(this, anim_knight_attackb, 3, knight_atk4); ai_charge(this, 4); }
void knight_atk2(entity this) { set_animofs(this, anim_knight_attackb, 2, knight_atk3); ai_charge(this, 7); }
void knight_atk1(entity this) { set_animofs(this, anim_knight_attackb, 1, knight_atk2);  _sound(this, CH_WEAPON_SINGLE, "knight/sword1.wav", 1, ATTN_NORM); ai_charge(this, 0); }

void knight_attack(entity this)
{
// decide if now is a good swing time
	if(vdist((this.enemy.origin + this.enemy.view_ofs) - (this.origin + this.view_ofs), <, 80))
		knight_atk1(this);
	else
		knight_runatk1(this);
}

//void knight_atk11(entity this)	=[	anim_knight_attack11,		knight_run1	 
//void knight_atk10(entity this)	=[	anim_knight_attack10,		knight_atk11	 
//void knight_atk9(entity this)	=[	anim_knight_attack9,		knight_atk10	 

//===========================================================================

void knight_pain3(entity this) { set_animofs(this, anim_knight_pain, 3, knight_run1); }
void knight_pain2(entity this) { set_animofs(this, anim_knight_pain, 2, knight_pain3); }
void knight_pain1(entity this) { set_animofs(this, anim_knight_pain, 1, knight_pain2); }

void knight_painb11(entity this) { set_animofs(this, anim_knight_painb, 11, knight_run1); }
void knight_painb10(entity this) { set_animofs(this, anim_knight_painb, 10, knight_painb11); ai_painforward(this, 0); }
void knight_painb9(entity this) { set_animofs(this, anim_knight_painb, 9, knight_painb10); ai_painforward(this, 5); }
void knight_painb8(entity this) { set_animofs(this, anim_knight_painb, 8, knight_painb9); ai_painforward(this, 5); }
void knight_painb7(entity this) { set_animofs(this, anim_knight_painb, 7, knight_painb8); ai_painforward(this, 2); }
void knight_painb6(entity this) { set_animofs(this, anim_knight_painb, 6, knight_painb7); ai_painforward(this, 4); }
void knight_painb5(entity this) { set_animofs(this, anim_knight_painb, 5, knight_painb6); ai_painforward(this, 2); }
void knight_painb4(entity this) { set_animofs(this, anim_knight_painb, 4, knight_painb5); }
void knight_painb3(entity this) { set_animofs(this, anim_knight_painb, 3, knight_painb4); }
void knight_painb2(entity this) { set_animofs(this, anim_knight_painb, 2, knight_painb3); ai_painforward(this, 3); }
void knight_painb1(entity this) { set_animofs(this, anim_knight_painb, 1, knight_painb2); ai_painforward(this, 0); }

void knight_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	float r = random();
	
	if((this.spawnflags & 2)) // statue)
		_sound(this, CH_VOICE, "statue/pain.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "knight/khurt.wav", 1, ATTN_NORM);
	if(r < 0.85)
	{
		knight_pain1(this);
		this.pain_finished = time + 1;
	}
	else
	{
		knight_painb1(this);
		this.pain_finished = time + 1;
	}
	
}

//===========================================================================

void knight_bow10(entity this) { set_animofs(this, anim_knight_walk, 1, knight_walk1); ai_turn(this); }
void knight_bow9(entity this) { set_animofs(this, anim_knight_kneel, 1, knight_bow10); ai_turn(this); }
void knight_bow8(entity this) { set_animofs(this, anim_knight_kneel, 2, knight_bow9); ai_turn(this); }
void knight_bow7(entity this) { set_animofs(this, anim_knight_kneel, 3, knight_bow8); ai_turn(this); }
void knight_bow6(entity this) { set_animofs(this, anim_knight_kneel, 4, knight_bow7); ai_turn(this); }
void knight_bow5(entity this) { set_animofs(this, anim_knight_kneel, 5, knight_bow5); ai_turn(this); }
void knight_bow4(entity this) { set_animofs(this, anim_knight_kneel, 4, knight_bow5); ai_turn(this); }
void knight_bow3(entity this) { set_animofs(this, anim_knight_kneel, 3, knight_bow4); ai_turn(this); }
void knight_bow2(entity this) { set_animofs(this, anim_knight_kneel, 2, knight_bow3); ai_turn(this); }
void knight_bow1(entity this) { set_animofs(this, anim_knight_kneel, 1, knight_bow2); ai_turn(this); }

void knight_die10(entity this)
{
	set_animofs(this, anim_knight_death, 10, knight_die10);
	CorpseThink(this);
}
void knight_die9(entity this) { set_animofs(this, anim_knight_death, 9, knight_die10); }
void knight_die8(entity this) { set_animofs(this, anim_knight_death, 8, knight_die9); }
void knight_die7(entity this) { set_animofs(this, anim_knight_death, 7, knight_die8); }
void knight_die6(entity this) { set_animofs(this, anim_knight_death, 6, knight_die7); }
void knight_die5(entity this) { set_animofs(this, anim_knight_death, 5, knight_die6); }
void knight_die4(entity this) { set_animofs(this, anim_knight_death, 4, knight_die5); }
void knight_die3(entity this) { set_animofs(this, anim_knight_death, 3, knight_die4); this.solid = SOLID_NOT; }
void knight_die2(entity this) { set_animofs(this, anim_knight_death, 2, knight_die3); }
void knight_die1(entity this) { set_animofs(this, anim_knight_death, 1, knight_die2); }

void knight_dieb11(entity this)
{
	set_animofs(this, anim_knight_deathb, 11, knight_dieb11);
	CorpseThink(this);
}
void knight_dieb10(entity this) { set_animofs(this, anim_knight_deathb, 10, knight_dieb11); }
void knight_dieb9(entity this) { set_animofs(this, anim_knight_deathb, 9, knight_dieb10); }
void knight_dieb8(entity this) { set_animofs(this, anim_knight_deathb, 8, knight_dieb9); }
void knight_dieb7(entity this) { set_animofs(this, anim_knight_deathb, 7, knight_dieb8); }
void knight_dieb6(entity this) { set_animofs(this, anim_knight_deathb, 6, knight_dieb7); }
void knight_dieb5(entity this) { set_animofs(this, anim_knight_deathb, 5, knight_dieb6); }
void knight_dieb4(entity this) { set_animofs(this, anim_knight_deathb, 4, knight_dieb5); }
void knight_dieb3(entity this) { set_animofs(this, anim_knight_deathb, 3, knight_dieb4); this.solid = SOLID_NOT; }
void knight_dieb2(entity this) { set_animofs(this, anim_knight_deathb, 2, knight_dieb3); }
void knight_dieb1(entity this) { set_animofs(this, anim_knight_deathb, 1, knight_dieb2); }


void knight_die(entity this, entity inflictor, entity attacker, int deathtype)
{
// check for gib
	if(this.health < -40)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, "progs/h_knight.mdl", this.health);
		if((this.spawnflags & 2)) // statue)
		{
			ThrowGib(this, "progs/statgib1.mdl", this.health);
			ThrowGib(this, "progs/statgib2.mdl", this.health);
			ThrowGib(this, "progs/statgib3.mdl", this.health);
		}
		else
		{
			ThrowGib(this, "progs/gib1.mdl", this.health);
			ThrowGib(this, "progs/gib2.mdl", this.health);
			ThrowGib(this, "progs/gib3.mdl", this.health);
		}
		return;
	}

// regular death
	if((this.spawnflags & 2)) // statue
		_sound(this, CH_VOICE, "statue/death.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "knight/kdeath.wav", 1, ATTN_NORM);
	if(random() < 0.5)
		knight_die1(this);
	else
		knight_dieb1(this);
}

void knight_pause(entity this, entity actor, entity trigger)
{
	_sound(this, CH_VOICE, "statue/see.wav", 1, ATTN_NORM);

	this.takedamage = DAMAGE_AIM;
	this.th_stand = knight_stand1;
	this.th_walk = knight_walk1;
	this.th_run = knight_run1;
	this.th_melee = knight_atk1;
	this.th_pain = knight_pain;
	this.th_die = knight_die;
	this.use = monster_use;
	
	setthink(this, knight_run1);

	this.enemy = actor;
	this.nextthink = time + 0.1;
	setthink(this, FoundTarget);

	this.delay = 0;
}

void knight_pause1(entity this)
{
	this.takedamage = DAMAGE_NO;
	this.use = knight_pause;
	setthink(this, knight_pause1);
    this.nextthink = time + 0.1;
}

/*QUAKED monster_knight(1 0 0)(-16 -16 -24)(16 16 40) Ambush Statue

Statue - (rogue only) select this to use the stone skin and have him frozen in place.

delay: time from sight to attack (default 5)
frame: frame to be frozen in. (default 44)
*/
spawnfunc(monster_knight) { monster_start(this, true, MON_KNIGHT); }
#endif // SVQC

#ifdef SVQC
METHOD(Knight, mr_setup, bool(Knight this, entity actor))
{
    TC(Knight, this);

    if((actor.spawnflags & 2) && substring(world.model, 0, 6) != "maps/r")
    	actor.spawnflags &= ~2; // TODO: why would mg be setting this?

	if((actor.spawnflags & 2)) // statue
	{
		precache_model("progs/statgib1.mdl");
		precache_model("progs/statgib2.mdl");
		precache_model("progs/statgib3.mdl");
		precache_sound("statue/see.wav");
		precache_sound("statue/idle.wav");
		precache_sound("statue/pain.wav");
		precache_sound("statue/death.wav");
	}
	else
	{
		precache_sound("knight/kdeath.wav");
		precache_sound("knight/khurt.wav");
		precache_sound("knight/idle.wav");
	}
	precache_sound("knight/sword1.wav");
	precache_sound("knight/sword2.wav");

    actor.health = 75;
	if((actor.spawnflags & 2)) // statue
	{
		if(actor.frame == 0)
			actor.frame = 44;
		actor.skin = 1;

		actor.takedamage = DAMAGE_NO;
		actor.th_stand = knight_pause1;
		actor.th_walk = knight_pause1;
		actor.th_run = knight_pause1;
		actor.use = knight_pause;

		if(!actor.targetname || actor.targetname == "")
			LOG_DEBUGF("statue %s not targeted at %v\n", actor.classname, actor.origin);
	}
	else
	{
		actor.th_stand = knight_stand1;
		actor.th_walk = knight_walk1;
		actor.th_run = knight_run1;
		actor.th_melee = knight_attack;
		actor.th_pain = knight_pain;
		actor.th_die = knight_die;
	}

    return true;
}
METHOD(Knight, mr_sight, bool(Knight this, entity actor))
{
    TC(Knight, this);

	if((actor.spawnflags & 2) && actor.takedamage == DAMAGE_NO)
	{
		actor.enemy = NULL;
		return false;
	}

	if(!MP_ROGUE || !actor.skin)
		sound(actor, CH_VOICE, this.m_sound, 1, ATTN_NORM);

    return true;
}
#endif
