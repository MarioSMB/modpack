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

const int MON_KNIGHT_STATUE = BIT(1);

void kn_idle_sound(entity this)
{
	if(random() < 0.2)
	{
		if(this.spawnflags & MON_KNIGHT_STATUE) // statue)
			_sound(this, CH_VOICE, "statue/idle.wav", 1, ATTN_IDLE);
		else if(IsQBJMap())
		{
			float r = random();
			if(r < 0.33)
				_sound(this, CH_VOICE, "knight/knight_idle_conditionreportblue.wav", 1, ATTN_IDLE);
			else if(r < 0.66)
				_sound(this, CH_VOICE, "knight/knight_idle_confirmingposition.wav", 1, ATTN_IDLE);
			else
				_sound(this, CH_VOICE, "knight/knight_idle_yeahgoodhere.wav", 1, ATTN_IDLE);
		}
		else
			_sound(this, CH_VOICE, "knight/idle.wav", 1,  ATTN_IDLE);
	}
}

void kn_aggro_sound(entity this)
{
	if(random() > 0.2)
		return;

	if(IsQBJMap())
	{
		if(random() > 0.5)
			return; // less dying for this ass
		if(random() > 0.5)
			_sound(this, CH_VOICE, "knight/knight_aggro_dieasshole.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "knight/knight_aggro_standdown.wav", 1, ATTN_IDLE);
		return;
	}

	_sound(this, CH_VOICE, "knight/idle.wav", 1,  ATTN_IDLE);
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
void knight_walk8(entity this) { set_animofs(this, anim_knight_walk, 8, knight_walk9); ai_walk(this, 4); monster_footstep(this, false); }
void knight_walk7(entity this) { set_animofs(this, anim_knight_walk, 7, knight_walk8); ai_walk(this, 3); }
void knight_walk6(entity this) { set_animofs(this, anim_knight_walk, 6, knight_walk7); ai_walk(this, 3); }
void knight_walk5(entity this) { set_animofs(this, anim_knight_walk, 5, knight_walk6); ai_walk(this, 3); }
void knight_walk4(entity this) { set_animofs(this, anim_knight_walk, 4, knight_walk5); ai_walk(this, 4); }
void knight_walk3(entity this) { set_animofs(this, anim_knight_walk, 3, knight_walk4); ai_walk(this, 3); }
void knight_walk1(entity this) { set_animofs(this, anim_knight_walk, 2, knight_walk3); kn_idle_sound(this); ai_walk(this, 2); monster_footstep(this, false); }
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
void knight_run6(entity this) { set_animofs(this, anim_knight_runb, 6, knight_run7); ai_run(this, 20); monster_footstep(this, false); }
void knight_run5(entity this) { set_animofs(this, anim_knight_runb, 5, knight_run6); ai_run(this, 16); }
void knight_run4(entity this) { set_animofs(this, anim_knight_runb, 4, knight_run5); ai_run(this, 7); }
void knight_run3(entity this) { set_animofs(this, anim_knight_runb, 3, knight_run4); ai_run(this, 13); }
void knight_run2(entity this) { set_animofs(this, anim_knight_runb, 2, knight_run3); ai_run(this, 20); monster_footstep(this, false); }
void knight_run1(entity this)
{
	set_animofs(this, anim_knight_runb, 1, knight_run2);
	kn_aggro_sound(this);
	ai_run(this, 16);
}

void knight_runatk11(entity this) { set_animofs(this, anim_knight_runattack, 11, knight_run1); ai_charge(this, 10); }
void knight_runatk10(entity this) { set_animofs(this, anim_knight_runattack, 10, knight_runatk11); ai_charge_side(this); monster_footstep(this, false); }
void knight_runatk9(entity this) { set_animofs(this, anim_knight_runattack, 9, knight_runatk10); ai_melee_side(this, DEATH_MONSTER_KNIGHT.m_id, 60, true); }
void knight_runatk8(entity this) { set_animofs(this, anim_knight_runattack, 8, knight_runatk9); ai_melee_side(this, DEATH_MONSTER_KNIGHT.m_id, 60, true); }
void knight_runatk7(entity this) { set_animofs(this, anim_knight_runattack, 7, knight_runatk8); ai_melee_side(this, DEATH_MONSTER_KNIGHT.m_id, 60, true); }
void knight_runatk6(entity this) { set_animofs(this, anim_knight_runattack, 6, knight_runatk7); ai_melee_side(this, DEATH_MONSTER_KNIGHT.m_id, 60, true); monster_footstep(this, false); }
void knight_runatk5(entity this) { set_animofs(this, anim_knight_runattack, 5, knight_runatk6); ai_melee_side(this, DEATH_MONSTER_KNIGHT.m_id, 60, true); }
void knight_runatk4(entity this) { set_animofs(this, anim_knight_runattack, 4, knight_runatk5); ai_charge_side(this); W_Parry_Trigger(this, 0); }
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
void knight_atk8(entity this) { set_animofs(this, anim_knight_attackb, 8, knight_atk9); ai_charge(this, 3); ai_melee(this, DEATH_MONSTER_KNIGHT.m_id, 60, true); }
void knight_atk7(entity this) { set_animofs(this, anim_knight_attackb, 7, knight_atk8); ai_charge(this, 1); ai_melee(this, DEATH_MONSTER_KNIGHT.m_id, 60, true); }
void knight_atk6(entity this) { set_animofs(this, anim_knight_attackb, 6, knight_atk7); ai_charge(this, 4); ai_melee(this, DEATH_MONSTER_KNIGHT.m_id, 60, true); }
void knight_atk5(entity this) { set_animofs(this, anim_knight_attackb, 5, knight_atk6); ai_charge(this, 3); W_Parry_Trigger(this, 0); monster_footstep(this, false); }
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
void knight_painb8(entity this) { set_animofs(this, anim_knight_painb, 8, knight_painb9); ai_painforward(this, 5); monster_footstep(this, false); }
void knight_painb7(entity this) { set_animofs(this, anim_knight_painb, 7, knight_painb8); ai_painforward(this, 2); }
void knight_painb6(entity this) { set_animofs(this, anim_knight_painb, 6, knight_painb7); ai_painforward(this, 4); }
void knight_painb5(entity this) { set_animofs(this, anim_knight_painb, 5, knight_painb6); ai_painforward(this, 2); }
void knight_painb4(entity this) { set_animofs(this, anim_knight_painb, 4, knight_painb5); monster_footstep(this, false); }
void knight_painb3(entity this) { set_animofs(this, anim_knight_painb, 3, knight_painb4); }
void knight_painb2(entity this) { set_animofs(this, anim_knight_painb, 2, knight_painb3); ai_painforward(this, 3); }
void knight_painb1(entity this) { set_animofs(this, anim_knight_painb, 1, knight_painb2); ai_painforward(this, 0); }

void knight_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	float r = random();
	
	if(this.spawnflags & MON_KNIGHT_STATUE) // statue)
		_sound(this, CH_VOICE, "statue/pain.wav", 1, ATTN_NORM);
	else if(IsQBJMap())
	{
		float r = random();
		if(r < 0.33)
			_sound(this, CH_VOICE, "knight/knight_pain_1.wav", 1, ATTN_NORM);
		else if(r < 0.66)
			_sound(this, CH_VOICE, "knight/knight_pain_2.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "knight/knight_pain_3.wav", 1, ATTN_NORM);
	}
	else
		_sound(this, CH_VOICE, "knight/khurt.wav", 1, ATTN_NORM);
	if(r < 0.85)
	{
		this.pain_finished = time + 1;
		setthink(this, knight_pain1);
		this.nextthink = time;
	}
	else
	{
		this.pain_finished = time + 1;
		setthink(this, knight_painb1);
		this.nextthink = time;
	}
	
}

//===========================================================================

void knight_bowend(entity this)
{
	SUB_SetFade(this, time, 0.25);
}

void knight_bow5(entity this) { set_animofs(this, anim_knight_kneel, 5, knight_bowend); }
void knight_bow4(entity this) { set_animofs(this, anim_knight_kneel, 4, knight_bow5); }
void knight_bow3(entity this) { set_animofs(this, anim_knight_kneel, 3, knight_bow4); }
void knight_bow2(entity this) { set_animofs(this, anim_knight_kneel, 2, knight_bow3); }
void knight_bow1(entity this) { set_animofs(this, anim_knight_kneel, 1, knight_bow2); this.solid = SOLID_NOT; }

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
void knight_die3(entity this) { set_animofs(this, anim_knight_death, 3, knight_die4); }
void knight_die2(entity this) { set_animofs(this, anim_knight_death, 2, knight_die3); }
void knight_die1(entity this) { set_animofs(this, anim_knight_death, 1, knight_die2); this.solid = SOLID_NOT; }

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
void knight_dieb3(entity this) { set_animofs(this, anim_knight_deathb, 3, knight_dieb4); }
void knight_dieb2(entity this) { set_animofs(this, anim_knight_deathb, 2, knight_dieb3); }
void knight_dieb1(entity this) { set_animofs(this, anim_knight_deathb, 1, knight_dieb2); this.solid = SOLID_NOT; }

void knight_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
			if(!(this.spawnflags & MON_KNIGHT_STATUE) && IsQBJMap())
				ThrowGib(this, inflictor, "progs/gibs/gibhead_knight.mdl", this.health);
			else
				ThrowGib(this, inflictor, "progs/h_knight.mdl", this.health);
			if((this.spawnflags & MON_KNIGHT_STATUE)) // statue)
			{
				ThrowGib(this, inflictor, "progs/statgib1.mdl", this.health);
				ThrowGib(this, inflictor, "progs/statgib2.mdl", this.health);
				ThrowGib(this, inflictor, "progs/statgib3.mdl", this.health);
			}
			else
			{
				ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
				ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
				ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
			}
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

// regular death
	if(this.spawnflags & MON_KNIGHT_STATUE) // statue
		_sound(this, CH_VOICE, "statue/death.wav", 1, ATTN_NORM);
	else if(IsQBJMap())
	{
		if(random() > 0.5)
			_sound(this, CH_VOICE, "knight/knight_death_1.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "knight/knight_death_2.wav", 1, ATTN_NORM);
	}
	else
		_sound(this, CH_VOICE, "knight/kdeath.wav", 1, ATTN_NORM);
	if(autocvar_skill >= 2 && gametype != GAMETYPE_TD)
	{
		minion_spawn(this, this.origin, new(monster), MON_PHANTOM_SWORDSMAN);
		knight_bow1(this);
	}
	else if(random() < 0.5)
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
spawnfunc(monster_knight)
{
	if(substring(world.model, 0, 9) == "maps/mcj_")
	{
		if(random() < 0.33)
			monster_start(this, true, MON_WITHER_SKELETON);
		else
			monster_start(this, true, MON_MCZOMBIE);
		return;
	}

	monster_start(this, true, MON_KNIGHT);
}
#endif // SVQC

#ifdef SVQC
METHOD(Knight, mr_setup, bool(Knight this, entity actor))
{
    TC(Knight, this);

    if((actor.spawnflags & MON_KNIGHT_STATUE) && !IsRogueMap())
    {
    	actor.skin = 0;
    	actor.spawnflags &= ~MON_KNIGHT_STATUE; // TODO: why would mg be setting this?
    }

    precache_model("progs/h_knight.mdl");

	if(actor.spawnflags & MON_KNIGHT_STATUE) // statue
	{
		precache_model("progs/statgib1.mdl");
		precache_model("progs/statgib2.mdl");
		precache_model("progs/statgib3.mdl");
		precache_sound("statue/see.wav");
		precache_sound("statue/idle.wav");
		precache_sound("statue/pain.wav");
		precache_sound("statue/death.wav");
	}
	else if(IsQBJMap())
	{
		precache_model("progs/knight_qbj.mdl");
		precache_model("progs/gibs/gibhead_knight.mdl");

		precache_sound("knight/knight_pain_1.wav");
		precache_sound("knight/knight_pain_2.wav");
		precache_sound("knight/knight_pain_3.wav");
		precache_sound("knight/knight_death_1.wav");
		precache_sound("knight/knight_death_2.wav");

		precache_sound("knight/knight_idle_conditionreportblue.wav");
		precache_sound("knight/knight_idle_confirmingposition.wav");
		precache_sound("knight/knight_idle_yeahgoodhere.wav");

		precache_sound("knight/knight_sight_enemysighted.wav");
		precache_sound("knight/knight_sight_ivegother.wav");
		precache_sound("knight/knight_sight_youregoingdown.wav");

		precache_sound("knight/knight_aggro_dieasshole.wav");
		precache_sound("knight/knight_aggro_standdown.wav");

		_setmodel(actor, "progs/knight_qbj.mdl");
		setsize(actor, this.m_mins, this.m_maxs);
	}
	else
	{
		precache_sound("knight/kdeath.wav");
		precache_sound("knight/khurt.wav");
		precache_sound("knight/idle.wav");
		precache_sound("knight/ksight.wav");
	}
	precache_sound("knight/sword1.wav");
	precache_sound("knight/sword2.wav");

	actor.steptype = FS_TYPEMEDIUM;

    actor.health = 75;
    actor.gibhealth = -40;
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

		actor.steptype = FS_TYPEHEAVY;

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

	if(!actor.skin)
	{
		if(IsQBJMap())
		{
			float r = random();
			if(r < 0.33)
				_sound(actor, CH_VOICE, "knight/knight_sight_enemysighted.wav", 1, ATTN_NORM);
			else if(r < 0.66)
				_sound(actor, CH_VOICE, "knight/knight_sight_ivegother.wav", 1, ATTN_NORM);
			else
				_sound(actor, CH_VOICE, "knight/knight_sight_youregoingdown.wav", 1, ATTN_NORM);

			return true;
		}
		_sound(actor, CH_VOICE, "knight/ksight.wav", 1, ATTN_NORM);
	}

    return true;
}
#endif

// kirby power
#ifdef CSQC
PRECACHE(Star_Knight)
{
	precache_model("progs/v_star_knight.mdl");
}
#endif

#ifdef SVQC
PRECACHE(Star_Knight)
{
	// slam
	precache_sound("kirby/slam.wav");
	precache_sound("kirby/slam_hit.wav");

	// uppercut
	precache_sound("kirby/slice_upper.wav");

	// slices
	precache_sound("kirby/slice.wav");
	precache_sound("kirby/slice_spam.wav");
	precache_sound("player/axhit2.wav");
	precache_sound("enviro/physics/axemet1.wav");
	precache_sound("enviro/physics/axemet2.wav");
	precache_sound("enviro/physics/axemet3.wav");
	precache_sound("enviro/physics/axecut1.wav");
	precache_sound("enviro/physics/axecut2.wav");
}

void star_knight_slam_trace(entity actor, .entity weaponentity)
{
	vector padding = '8 8 8'; // add a bit of padding for forward attacks
	tracebox(actor.origin, actor.mins - padding, actor.maxs + padding, actor.origin - ('0 0 1' * (actor.maxs_z + 5)), MOVE_NORMAL, actor);

	if(!trace_ent || !trace_ent.takedamage || !Damage_ValidTarget(trace_ent, actor))
		return;

	trace_ent.axhitme = true;

	// bounce up a bit and cancel out of slam
	actor.velocity_z = 400;
	actor.oldvelocity_z = actor.velocity_z;
	UNSET_ONGROUND(actor);

	// also reset uppercut air state for fun
	actor.(weaponentity).star_knight_inair = false;
	STAT(KIRBY_JUMPS, actor) = 0;

	actor.(weaponentity).m_frame = 0;
	w_ready(actor.(weaponentity));

	if(IS_PLAYER(actor))
		player_axe1(actor);

	ATTACK_FINISHED(actor, weaponentity) = time + 0.5; // prevent spamming something to death

	float damage = 70;
	T_Damage(trace_ent, actor, actor, damage, WEP_STAR.m_id);
	_sound(actor, CH_SHOTS, "kirby/slam_hit.wav", 1, ATTN_NORM);
}

void star_knight_slam_frame(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;

	if(IS_ONGROUND(actor) || actor.waterlevel > 1)
	{
		_sound(actor, CH_SHOTS, "kirby/slam_hit.wav", 1, ATTN_NORM);
		this.m_frame = 0;
		w_ready(this);
		return;
	}

	if(IS_PLAYER(actor))
		player_shot1(actor);

	ATTACK_FINISHED(actor, weaponentity) = time + 0.2;

	wep_set_anim(this, 4, star_knight_slam_frame);
	this.weapon_nextthink = time; // accurate slam tracing

	// done last as it may cancel the slam
	star_knight_slam_trace(actor, weaponentity);
}

void star_knight_slam(entity actor, .entity weaponentity)
{
	_sound(actor, CH_WEAPON_SINGLE, "kirby/slam.wav", 1, ATTN_NORM);
	if(actor.velocity_z > -800)
		actor.velocity_z -= 800;
	star_knight_slam_frame(actor.(weaponentity));
}

.bool star_knight_inair;
.float star_knight_sliced;
void star_knight_uppercut_trace(entity actor, .entity weaponentity)
{
	makevectors(actor.angles);
	vector org = actor.origin + v_forward * 64;
	// TODO: custom size? maybe a traceline is better?
	tracebox(org, '-32 -32 -32', '32 32 32', org + ('0 0 1' * (actor.maxs_z + 5)), MOVE_NORMAL, actor);

	if(!trace_ent || trace_ent.star_knight_sliced > time || !trace_ent.takedamage || !Damage_ValidTarget(trace_ent, actor))
		return;

	trace_ent.axhitme = true;
	trace_ent.star_knight_sliced = time + 0.5; // no spam

	// doesn't cancel out of attack!

	float damage = 70;
	T_Damage(trace_ent, actor, actor, damage, WEP_STAR.m_id);
	// same channel as uppercut sound to override it
	_sound(trace_ent, CH_SHOTS, "kirby/slam_hit.wav", 1, ATTN_NORM);
}

void star_knight_uppercut_frame(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;

	// cancel if we land or start falling
	// or if we start flying! no abuse thank you very much
	if(IS_ONGROUND(actor) || actor.waterlevel > 1 || actor.velocity_z <= 0 || STAT(KIRBY_STATE, actor) == KIRBY_FLYING)
	{
		this.m_frame = 0;
		w_ready(this);
		return;
	}

	if(IS_PLAYER(actor))
		player_shot1(actor);

	ATTACK_FINISHED(actor, weaponentity) = time + 0.2;

	wep_set_anim(this, 1, star_knight_uppercut_frame);
	this.weapon_nextthink = time; // accurate uppercut tracing

	// done last as it may cancel the uppercut
	star_knight_uppercut_trace(actor, weaponentity);
}

void star_knight_uppercut(entity actor, .entity weaponentity)
{
	_sound(actor, CH_WEAPON_SINGLE, "kirby/slice_upper.wav", 1, ATTN_NORM);
	actor.velocity_z = max(actor.velocity_z + 600, 600);
	UNSET_ONGROUND(actor);
	actor.(weaponentity).star_knight_inair = true;
	star_knight_uppercut_frame(actor.(weaponentity));
}

void star_knight_slicespam_trace(entity this, .entity weaponentity, vector offset)
{
	makevectors(this.v_angle);
	vector source = W_Shotorg(this, weaponentity);
	int oldsolid = this.dphitcontentsmask;
	this.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	float arange = 64;
	traceline(source, source + v_forward * arange + v_right * offset.y + v_up * offset.z, false, this);
	this.dphitcontentsmask = oldsolid;
	if(trace_fraction == 1.0)
		return;
	
	vector org = trace_endpos - v_forward * 4;

	if(trace_ent.takedamage) // yoder mod, Jan 05 2021
	{
		{
			float r = random();
			if(trace_ent.monsterdef == MON_JUGGERNAUT) // special case: axe attacks produce unique sound against juggernauts TODO: handle melee attacks in monster pain code
				_sound(this, CH_WEAPON_SINGLE, "monsters/juggers/jbent.wav", 1, ATTN_NORM);
			else if(trace_ent.monsterdef && (trace_ent.monsterdef.spawnflags & MON_FLAG_METAL))
			{
				if(r < 0.3)
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet1.wav", 1, ATTN_NORM);
				else if(r < 0.6)
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet2.wav", 1, ATTN_NORM);
				else
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet3.wav", 1, ATTN_NORM);
			}
			else if(IS_PLAYER(trace_ent) && trace_ent.armorvalue > 0)
			{
				if(r < 0.3)
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet1.wav", 1, ATTN_NORM);
				else if(r < 0.6)
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet2.wav", 1, ATTN_NORM);
				else
					_sound(trace_ent, CH_SHOTS, "enviro/physics/axemet3.wav", 1, ATTN_NORM);
			}
			else if(r < 0.5)
			{
				_sound(trace_ent, CH_SHOTS, "enviro/physics/axecut1.wav", 1, ATTN_NORM);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
			}
			else
			{
				_sound(trace_ent, CH_SHOTS, "enviro/physics/axecut2.wav", 1, ATTN_NORM);
				SpawnBlood(org, '0 0 0', 20, trace_ent);
			}
		}
		trace_ent.axhitme = true;
		T_Damage(trace_ent, this, this, 40, WEP_STAR.m_id);
	}
	else
	{	// hit wall
		_sound(this, CH_SHOTS, "player/axhit2.wav", 1, ATTN_NORM);
		te_gunshot(org);
	}
}

void star_knight_slicespam_frame(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;

	if(this.m_frame >= 18)
	{
		this.m_frame = 0;
		w_ready(this);
		return;
	}

	// doing frame here so it looks spammy!
	if(IS_PLAYER(actor))
		player_shot1(actor);

	this.m_frame += 1;

	wep_set_anim(this, this.m_frame, star_knight_slicespam_frame);

	vector offset = '0 0 0';
	switch(this.m_frame)
	{
		case 14: offset = '0 4 -8'; break;
		case 15: offset = '0 -4 0'; break;
		case 16: offset = '0 8 -6'; break;
		case 17: offset = '0 0 8'; break;
		case 18: offset = '0 -8 6'; break;
	}
	star_knight_slicespam_trace(actor, weaponentity, offset);
}

void star_knight_slicespam(entity actor, .entity weaponentity)
{
	_sound(actor, CH_WEAPON_SINGLE, "kirby/slice_spam.wav", 1, ATTN_NORM);
	actor.(weaponentity).m_frame = 13; // gets increased by one
	star_knight_slicespam_frame(actor.(weaponentity));
	actor.(weaponentity).count = 0; // reset combo

	weapon_prepareattack(WEP_STAR, actor, weaponentity, 0.8);
}

// copied from wrench code
void star_knight_slice_hit(entity this, entity hitent, vector org, vector dir)
{
	if(hitent.takedamage) 
	{		
		hitent.axhitme = 1;

		SpawnBlood(org, dir, 40, hitent);

		te_gunshot(org);

		T_Damage(hitent, this, this, 40, WEP_STAR.m_id);
		
		//johnfitz -- make clank sound when hitting brushmodels
		if(hitent.solid == SOLID_BSP || hitent.movetype == MOVETYPE_PUSH || hitent.movetype == MOVETYPE_NONE)
			_sound(this, CH_SHOTS, "player/axhit2.wav", 1, ATTN_NORM);
		else
		{	
			if(hitent.monsterdef.spawnflags & MON_FLAG_METAL)
			{
				te_gunshot(org);
				float r = random();
				if(r < 0.3)
					_sound(hitent, CH_SHOTS, "enviro/physics/axemet1.wav", 1, ATTN_NORM);
				else if(r < 0.6)
					_sound(hitent, CH_SHOTS, "enviro/physics/axemet2.wav", 1, ATTN_NORM);
				else
					_sound(hitent, CH_SHOTS, "enviro/physics/axemet3.wav", 1, ATTN_NORM);
			}
			else
			{
				if(random() < 0.5)
					_sound(hitent, CH_SHOTS, "enviro/physics/axecut1.wav", 1, ATTN_NORM);
				else
					_sound(hitent, CH_SHOTS, "enviro/physics/axecut2.wav", 1, ATTN_NORM);
			}
			// enable to push enemies around
#if 0
			if((hitent.move_movetype == MOVETYPE_STEP || hitent.move_movetype == MOVETYPE_WALK) && 
				// don't swat bosses or other non-standard-sized enemies around
				hitent.maxs_x <= 32 && hitent.health > 0 && !(hitent.monsterdef.spawnflags & MONSTER_TYPE_BOSS))
			{
				vector toss = v_forward;
				toss.z = 0;
				toss = normalize(toss) * 175;
				toss.z = 95;
				hitent.origin_z += 1;
				hitent.velocity = toss;
				UNSET_ONGROUND(hitent);
			}
#endif
		}
	}
	else
	{	// hit wall
		_sound(this, CH_SHOTS, "player/axhit2.wav", 0.8, ATTN_NORM);

		te_gunshot(org);
	}
}

void star_knight_slice_trace(entity this, .entity weaponentity, float direction)
{
	entity hitent1 = NULL, hitent2 = NULL;
	vector hitpos1 = '0 0 0', hitpos2 = '0 0 0';
	float shortest_hit1 = 1000;
	float shortest_hit2 = 1000;
	int oldsolid = this.dphitcontentsmask;
	this.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;

	makevectors(this.v_angle);
	vector source = this.origin + this.view_ofs - v_up*0;

	traceline(source, source + v_forward * 60 - v_right * (40 * direction), false, this);
	if(trace_fraction < 1)
	{
		shortest_hit1 = vlen(trace_endpos - source);
		hitent1 = trace_ent;
		hitpos1 = trace_endpos;
 	}

	traceline(source, source + v_forward * 72 - v_right * (20 * direction), false, this);
	if(trace_fraction < 1)
	{
		if(trace_ent == hitent1 && vdist(trace_endpos - source, <, shortest_hit1))
		{
			shortest_hit1 = vlen(trace_endpos - source);
			hitent1 = trace_ent;
			hitpos1 = trace_endpos;
		}
		if(trace_ent != hitent1 && vdist(trace_endpos - source, <, shortest_hit2))
		{
			shortest_hit2 = vlen(trace_endpos - source);
			hitent2 = trace_ent;
			hitpos2 = trace_endpos;
		}
	}

	traceline(source, source + v_forward * 86, false, this);
	if(trace_fraction < 1)
	{
		if(trace_ent == hitent1 && vdist(trace_endpos - source, <, shortest_hit1))
		{
			shortest_hit1 = vlen(trace_endpos - source);
			hitent1 = trace_ent;
			hitpos1 = trace_endpos;
		}
		if(trace_ent != hitent1 && vdist(trace_endpos - source, <, shortest_hit2))
		{
			shortest_hit2 = vlen(trace_endpos - source);
			hitent2 = trace_ent;
			hitpos2 = trace_endpos;
		}
	}

	traceline(source, source + v_forward * 72 + v_right * (20 * direction), false, this);
	if(trace_fraction < 1)
	{
		if(trace_ent == hitent1 && vdist(trace_endpos - source, <, shortest_hit1))
		{
			shortest_hit1 = vlen(trace_endpos - source);
			hitent1 = trace_ent;
			hitpos1 = trace_endpos;
		}
		if(trace_ent != hitent1 && vdist(trace_endpos - source, <, shortest_hit2))
		{
			shortest_hit2 = vlen(trace_endpos - source);
			hitent2 = trace_ent;
			hitpos2 = trace_endpos;
		}
	}

	traceline(source, source + v_forward * 60 + v_right * (40 * direction), false, this);
	if(trace_fraction < 1)
	{
		if(trace_ent == hitent1 && vdist(trace_endpos - source, <, shortest_hit1))
		{
			shortest_hit1 = vlen(trace_endpos - source);
			hitent1 = trace_ent;
			hitpos1 = trace_endpos;
		}
		if(trace_ent != hitent1 && vdist(trace_endpos - source, <, shortest_hit2))
		{
			shortest_hit2 = vlen(trace_endpos - source);
			hitent2 = trace_ent;
			hitpos2 = trace_endpos;
		}
	}

	this.dphitcontentsmask = oldsolid;

	if(shortest_hit1 == 1000 && shortest_hit2 == 1000)
		return;

	this.show_hostile = time + 1; // hit something, so alert monsters
	
	vector dir = v_right * 20 - v_up*5; // direction for blood particles

	if(shortest_hit1 < 1000)
		star_knight_slice_hit(this, hitent1, hitpos1 - v_forward*4, dir);
	if(shortest_hit2 < 1000 && hitent1 != hitent2)
		star_knight_slice_hit(this, hitent2, hitpos2 - v_forward*4, dir);
}

void star_knight_slice_frame(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;

	if(this.m_frame == 8)
		star_knight_slice_trace(actor, weaponentity, 1);
	else if(this.m_frame == 11)
		star_knight_slice_trace(actor, weaponentity, -1);

	if(this.m_frame == 9 || this.m_frame >= 13)
	{
		this.m_frame = 0;
		w_ready(this);
		return;
	}

	this.m_frame += 1;
	wep_set_anim(this, this.m_frame, star_knight_slice_frame);
}

void star_knight_slice(entity actor, .entity weaponentity)
{
	_sound(actor, CH_WEAPON_SINGLE, "kirby/slice.wav", 1, ATTN_NORM);
	actor.(weaponentity).count += 1;
	if(actor.(weaponentity).count % 2)
		actor.(weaponentity).m_frame = 6;
	else
		actor.(weaponentity).m_frame = 10;
	wep_set_anim(actor.(weaponentity), actor.(weaponentity).m_frame, star_knight_slice_frame);

	if(IS_PLAYER(actor))
		player_shot1(actor);

	weapon_prepareattack(WEP_STAR, actor, weaponentity, 0.4);
}

METHOD(Knight, star_fire, void(Knight this, entity actor, .entity weaponentity))
{
	// we're always going to do *something*, so always cancel out of flight now
	if(STAT(KIRBY_STATE, actor) == KIRBY_FLYING)
		STAT(KIRBY_STATE, actor) = KIRBY_NORMAL;

	bool swimming = (actor.waterlevel > 1);

	// looking down and in the air!
	if(!IS_ONGROUND(actor) && !swimming && actor.v_angle_x >= 55 && actor.v_angle_x <= 110)
	{
		star_knight_slam(actor, weaponentity);
		return;
	}

	// looking up!
	if(!actor.(weaponentity).star_knight_inair && !swimming && actor.v_angle_x <= -55 && actor.v_angle_x >= -110)
	{
		star_knight_uppercut(actor, weaponentity);
		return;
	}

	// spam combo
	if(IS_ONGROUND(actor) && !swimming && actor.(weaponentity).count >= 4)
	{
		star_knight_slicespam(actor, weaponentity);
		return;
	}

	// regular slice attack
	star_knight_slice(actor, weaponentity);
}
#endif
