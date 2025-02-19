#include "vampire.qh"

#ifdef SVQC
// 0 is a dead frame
const int anim_vampire_stand = 0;
const int anim_vampire_walk = 0;
const int anim_vampire_melee = 32;
const int anim_vampire_bat_charge = 64;
const int anim_vampire_bat_fly = 123;
const int anim_vampire_bat_end = 124;
const int anim_vampire_death = 0;

.float idle_finished;

void vampire_idlesound(entity this)
{
	if(time < this.pain_finished)
		return;

	if(random() < 0.2 && time >= this.idle_finished)
	{
		this.idle_finished = time + 2 + random();
		sound(this, CH_VOICE, SND_MON_VAMPIRE_IDLE_RANDOM(), 1, ATTN_NORM);
	}
}

void vampire_stand(entity this)
{
	this.walkframe = anim_vampire_stand;

	set_anim(this, this.walkframe, vampire_stand);
	ai_stand(this);

	vampire_idlesound(this);
}

void vampire_moveframe(entity this)
{
	if(this.flags & FL_FLY)
	{
		this.walkframe += 1;
		if(this.walkframe < anim_vampire_bat_fly || this.walkframe > 145)
			this.walkframe = anim_vampire_bat_fly;
		return;
	}

	if(this.enemy)
		this.walkframe += 3;
	else
		this.walkframe += 1;
	if(this.walkframe <= anim_vampire_walk || this.walkframe > 31)
		this.walkframe = anim_vampire_walk;

	vampire_idlesound(this);
}

void vampire_walk(entity this)
{
	vampire_moveframe(this);
	set_anim(this, this.walkframe, vampire_walk);

	ai_walk(this, 6);
}

void vampire_run(entity this)
{
	vampire_moveframe(this);
	set_anim(this, this.walkframe, vampire_run);
	this.nextthink = time + 0.05; // double run speed

	ai_run(this, 10);
}

void ai_melee_vampire(entity this, int deathtype, int melee_range, bool check_parry)
{
	if(!this.enemy)
		return;		// removed before stroke

	if(!ai_checkmelee(this, melee_range, false))
		return; // Too far away

	float ldmg = (random() + random() + random()) * 10;
	T_Damage(this.enemy, this, this, ldmg, deathtype);
}

void vampire_melee10(entity this) { set_animofs(this, anim_vampire_melee, 2, vampire_run); ai_charge(this, 3); this.nextthink = time + 0.05; this.attack_finished = time + 1.5; }
void vampire_melee9(entity this) { set_animofs(this, anim_vampire_melee, 3, vampire_melee10); ai_charge(this, 3); this.nextthink = time + 0.05; }
void vampire_melee8(entity this) { set_animofs(this, anim_vampire_melee, 4, vampire_melee9); ai_charge(this, 3); this.nextthink = time + 0.05; }
void vampire_melee7(entity this) { set_animofs(this, anim_vampire_melee, 5, vampire_melee8); ai_charge(this, 3); this.nextthink = time + 0.05; }
void vampire_melee6(entity this) { set_animofs(this, anim_vampire_melee, 6, vampire_melee7); ai_charge(this, 3); this.nextthink = time + 0.05; }
void vampire_melee5(entity this)
{
	set_animofs(this, anim_vampire_melee, 5, vampire_melee6);
	ai_charge(this, 3);
	this.nextthink = time + 0.05;

	ai_melee_vampire(this, DEATH_MONSTER_VAMPIRE.m_id, 100, false);
}
void vampire_melee4(entity this) { set_animofs(this, anim_vampire_melee, 4, vampire_melee5); ai_charge(this, 3); this.nextthink = time + 0.05; }
void vampire_melee3(entity this) { set_animofs(this, anim_vampire_melee, 3, vampire_melee4); ai_charge(this, 3); this.nextthink = time + 0.05; }
void vampire_melee2(entity this) { set_animofs(this, anim_vampire_melee, 2, vampire_melee3); ai_charge(this, 3); this.nextthink = time + 0.05; }
void vampire_melee1(entity this) { set_animofs(this, anim_vampire_melee, 1, vampire_melee2); ai_charge(this, 3); this.nextthink = time + 0.05; }

void vampire_bat_untransform(entity this);
void vampire_melee(entity this)
{
	if(this.flags & FL_FLY)
		vampire_bat_untransform(this);
	else
	{
		this.attack_finished = time + 1;
		vampire_melee1(this);
	}
}

//===========================================================================

void vampire_bat_end_frame(entity this)
{
	this.walkframe += 1;
	if(this.walkframe > 200)
	{
		if(random() < 0.5)
			_sound(this, CH_VOICE, "evocation_illager/cast1.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "evocation_illager/cast2.wav", 1, ATTN_NORM);
		vampire_run(this);
		// NOTE: doesn't reset attack time
		return;
	}
	set_anim(this, this.walkframe, vampire_bat_end_frame);
	this.nextthink = time + 0.03;
}

void vampire_bat_untransform(entity this)
{
	if(!(this.flags & FL_FLY))
		return; // just incase
	this.flags &= ~FL_FLY;
	UNSET_ONGROUND(this);
	this.pain_finished = time + 3; // don't cancel untransform animation
	this.resist_shells = this.resist_cells = 0;
	this.resist_nails = this.resist_rockets = 0;
	_sound(this, CH_VOICE, "evocation_illager/prepare_wololo.wav", 1, ATTN_NORM);

	this.walkframe = anim_vampire_bat_end;
	set_anim(this, this.walkframe, vampire_bat_end_frame);
}

void vampire_bat_start(entity this)
{
	this.flags |= FL_FLY;
	UNSET_ONGROUND(this);
	this.resist_shells = this.resist_cells = 0.9;
	this.resist_nails = this.resist_rockets = 0.9;

	if(random() < 0.5)
		_sound(this, CH_VOICE, "evocation_illager/cast1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "evocation_illager/cast2.wav", 1, ATTN_NORM);

	vampire_run(this);
}

void vampire_bat_start_frame(entity this)
{
	this.walkframe += 1;
	if(this.walkframe > 122)
	{
		vampire_bat_start(this);
		return;
	}
	set_anim(this, this.walkframe, vampire_bat_start_frame);
	this.nextthink = time + 0.03;
}

void vampire_bat_transform(entity this)
{
	this.walkframe = anim_vampire_bat_charge;
	set_anim(this, this.walkframe, vampire_bat_start_frame);
	if(random() < 0.5)
		_sound(this, CH_VOICE, "evocation_illager/prepare_attack1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "evocation_illager/prepare_attack2.wav", 1, ATTN_NORM);
}

/*
===========
VampireCheckAttack

The player is in view, so decide to move or launch an attack
Returns false if movement should continue
============
*/
bool VampireCheckAttack(entity this)
{
	if(this.enemy_range == RANGE_MELEE)
	{
		if(CanDamage(this.enemy, this))
		{
			this.attack_state = AS_MELEE;
			return true;
		}
	}

	if(this.flags & FL_FLY)
		return false;
	if(this.enemy_range < RANGE_MID || this.enemy_range == RANGE_FAR)
		return false;
	if(time < this.attack_finished)
		return false;
		
	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	if(vdist(spot1 - spot2, >, 600))
		return false;

	traceline(spot1, spot2, false, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
	{
		return false;	// don't have a clear shot
	}
			
// missile attack
		
	this.attack_state = AS_MISSILE;
	this.attack_finished = time + (2 * 2 * random());
	return true;
}


//===========================================================================

void vampire_pain6(entity this) { set_anim(this, this.walkframe, vampire_run); this.colormod = (this.charmed) ? '0 1 0' : '1 1 1'; }
void vampire_pain5(entity this) { set_anim(this, this.walkframe, vampire_pain6); }
void vampire_pain4(entity this) { set_anim(this, this.walkframe, vampire_pain5); this.colormod = '1 0.8 0.8'; }
void vampire_pain3(entity this) { set_anim(this, this.walkframe, vampire_pain4);}
void vampire_pain2(entity this) { set_anim(this, this.walkframe, vampire_pain3); ai_pain(this, 6); this.colormod = '1 0.6 0.6'; }
void vampire_pain1(entity this) { set_anim(this, this.walkframe, vampire_pain2); ai_pain(this, 6); }

void vampire_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	if((this.flags & FL_FLY) || (this.walkframe >= anim_vampire_bat_charge && this.walkframe <= 122))
		return; // no pain animations!

	if(random() < 0.5)
		_sound(this, CH_VOICE, "evocation_illager/hurt1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "evocation_illager/hurt2.wav", 1, ATTN_NORM);

	this.pain_finished = time + 1.1;
	this.colormod = '1 0.9 0.9';

	vampire_pain1(this);
}

//===========================================================================

void vampire_vanish(entity this)
{
	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

void vampire_die6(entity this) { set_anim(this, this.walkframe, vampire_vanish); this.angles_z = 90; this.nextthink = time + 0.6; }
void vampire_die5(entity this) { set_anim(this, this.walkframe, vampire_die6); this.angles_z = 75; }
void vampire_die4(entity this) { set_anim(this, this.walkframe, vampire_die5); this.angles_z = 60; }
void vampire_die3(entity this) { set_anim(this, this.walkframe, vampire_die4); this.angles_z = 45; }
void vampire_die2(entity this) { set_anim(this, this.walkframe, vampire_die3); this.angles_z = 30; }
void vampire_die1(entity this) { set_anim(this, this.walkframe, vampire_die2); this.angles_z = 15; this.solid = SOLID_NOT; }

void vampire_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(random() < 0.5)
		_sound(this, CH_VOICE, "evocation_illager/death1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "evocation_illager/death2.wav", 1, ATTN_NORM);

	// some nice death animations thank you
	if(this.flags & FL_FLY)
		this.walkframe = anim_vampire_bat_fly;
	else
		this.walkframe = anim_vampire_stand;

	this.colormod = '1 0.6 0.6';
	this.angles_z = 0;
	vampire_die1(this);
}

/*QUAKED monster_vampire (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_vampire) { monster_start(this, true, MON_VAMPIRE); }
#endif // SVQC

#ifdef SVQC
METHOD(Vampire, mr_setup, bool(Vampire this, entity actor))
{
    TC(Vampire, this);

	precache_sound("evocation_illager/death1.wav");
	precache_sound("evocation_illager/death2.wav");
	precache_sound("evocation_illager/hurt1.wav");
	precache_sound("evocation_illager/hurt2.wav");
	precache_sound("evocation_illager/prepare_attack1.wav");
	precache_sound("evocation_illager/prepare_attack2.wav");
	precache_sound("evocation_illager/prepare_wololo.wav");
	precache_sound("evocation_illager/cast1.wav");
	precache_sound("evocation_illager/cast2.wav");

	actor.yaw_speed = 90;

    actor.health = 200;
    actor.th_stand = vampire_stand;
	actor.th_walk = vampire_walk;
	actor.th_run = vampire_run;
	actor.th_pain = vampire_pain;
	actor.th_die = vampire_die;
	actor.th_melee = vampire_melee;
	actor.th_missile = vampire_bat_transform;

	actor.checkattack = VampireCheckAttack;

    return true;
}
#endif
