#include "thomas.qh"

#ifdef SVQC
const int anim_thomas_stand = 0; //'0 12 0'
const int anim_thomas_walk = 13; //'13 20 0'
const int anim_thomas_run = 21; //'21 26 0'
const int anim_thomas_leap = 27; //'27 38 0'
const int anim_thomas_pain = 39; //'39 44 0'
const int anim_thomas_death = 45; //'45 53 0'
const int anim_thomas_attacka = 54; //'54 68 0'


//============================================================================

void thomas_hitbox(entity this);

void thomas_stand1(entity this)
{
	setthink(this, thomas_stand1);
	this.nextthink = time + FRAME_TIME;

	this.walkframe += 1;
	if(this.walkframe >= 12)
		this.walkframe = 0;
	this.frame = this.walkframe + 1;

	ai_stand(this);
	thomas_hitbox(this);
}

void thomas_walk1(entity this);
void thomas_walk8(entity this) { set_animofs(this, anim_thomas_walk, 8, thomas_walk1); ai_walk(this, 10); thomas_hitbox(this); }
void thomas_walk7(entity this) { set_animofs(this, anim_thomas_walk, 7, thomas_walk8); ai_walk(this, 10); thomas_hitbox(this); }
void thomas_walk6(entity this) { set_animofs(this, anim_thomas_walk, 6, thomas_walk7); ai_walk(this, 6); thomas_hitbox(this); }
void thomas_walk5(entity this) { set_animofs(this, anim_thomas_walk, 5, thomas_walk6); ai_walk(this, 4); thomas_hitbox(this); }
void thomas_walk4(entity this) { set_animofs(this, anim_thomas_walk, 4, thomas_walk5); ai_walk(this, 7); thomas_hitbox(this); }
void thomas_walk3(entity this) { set_animofs(this, anim_thomas_walk, 3, thomas_walk4); ai_walk(this, 6); thomas_hitbox(this); }
void thomas_walk2(entity this) { set_animofs(this, anim_thomas_walk, 2, thomas_walk3); ai_walk(this, 6); thomas_hitbox(this); }
void thomas_walk1(entity this)
{
	set_animofs(this, anim_thomas_walk, 1, thomas_walk2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "thomas/idle.wav", 1, ATTN_IDLE);
	ai_walk(this, 8);
}

void thomas_run1(entity this);
void thomas_run6(entity this) { set_animofs(this, anim_thomas_stand, 6, thomas_run1); ai_run(this, 36); thomas_hitbox(this); }
void thomas_run5(entity this) { set_animofs(this, anim_thomas_stand, 5, thomas_run6); ai_run(this, 15); thomas_hitbox(this); }
void thomas_run4(entity this) { set_animofs(this, anim_thomas_stand, 4, thomas_run5); ai_run(this, 20); thomas_hitbox(this); }
void thomas_run3(entity this) { set_animofs(this, anim_thomas_stand, 3, thomas_run4); ai_run(this, 36); thomas_hitbox(this); }
void thomas_run2(entity this) { set_animofs(this, anim_thomas_stand, 2, thomas_run3); ai_run(this, 15); thomas_hitbox(this); }
void thomas_run1(entity this)
{
	set_animofs(this, anim_thomas_stand, 1, thomas_run2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "thomas/idle.wav", 1, ATTN_IDLE);
	ai_run(this, 20);
	thomas_hitbox(this);
}

void thomas_hitbox(entity this)
{
	if(this.health < 1 || !gettouch(this))
		return;

	// since we use noclip, touching must be handled manually
	vector emin = this.absmin, emax = this.absmax;
	emin -= '16 16 1';
	emax += '16 16 1';

	FOREACH_ENTITY_BOX_ORDERED(emin, emax, it != this,
	{
		if (it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY)
			gettouch(this)(this, it);
	});
}

void thomas_movetogoal(entity this, float dist)
{
	if(gametype == GAMETYPE_TD && !this.charmed)
		dist *= td_GetMonsterSpeed(this, dist);

	if(StatusEffects_active(STATUSEFFECT_Slowness, this))
		dist *= 0.5;
	if(StatusEffects_active(STATUSEFFECT_JesterSpeed, this))
		dist *= 1.5;

	this.enemy_range = range(this, this.enemy);

	if(this.enemy && this.enemy_range == RANGE_MELEE && gettouch(this) && ai_checkmelee(this, 100, false))
		gettouch(this)(this, this.enemy);

	thomas_hitbox(this);

	if(!t_stepdirection(this, this.ideal_yaw, dist))
		this.walkframe = max(20, this.walkframe); // end attack early
}

void thomas_chargeloop(entity this)
{
	set_animofs(this, anim_thomas_leap, 1, thomas_chargeloop);
	this.walkframe += 1;
	if(this.walkframe > 32)
	{
		this.walkframe = 0;
		thomas_run1(this);
		return;
	}
	thomas_movetogoal(this, 34);
}

void thomas_charge(entity this)
{
	_sound(this, CH_VOICE, "thomas/charge.wav", 1, 0.5);
	this.walkframe = 0;
	ai_face(this);
	thomas_chargeloop(this);
}

void thomas_pain6(entity this) { set_animofs(this, anim_thomas_pain, 6, thomas_run1); }
void thomas_pain5(entity this) { set_animofs(this, anim_thomas_pain, 5, thomas_pain6); }
void thomas_pain4(entity this) { set_animofs(this, anim_thomas_pain, 4, thomas_pain5); }
void thomas_pain3(entity this) { set_animofs(this, anim_thomas_pain, 3, thomas_pain4); }
void thomas_pain2(entity this) { set_animofs(this, anim_thomas_pain, 2, thomas_pain3); }
void thomas_pain1(entity this) { set_animofs(this, anim_thomas_pain, 1, thomas_pain2); }

void thomas_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	this.pain_finished = time + 1;
    //_sound(this, CH_VOICE, "thomas/pain.wav", 1, 0.5);

	if(random()*200 > damage)
		return;		// didn't flinch
		
	thomas_pain1(this);
}

void thomas_explode(entity this)
{
	sound(this, CH_TRIGGER_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);

	entity exp = spawn();
	exp.nextthink = time;
	setthink(exp, s_explode1);
	_setmodel(exp, "progs/s_explod.spr");
	setsize(exp, '0 0 0', '0 0 0');
	setorigin(exp, this.origin);

	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);
}

void thomas_gibthink(entity this)
{
	thomas_explode(this);
	delete(this);
}

void thomas_die9(entity this) 
{
	set_animofs(this, anim_thomas_death, 9, thomas_gibthink);
	this.nextthink = time + 1.5;
}
void thomas_die8(entity this) { set_animofs(this, anim_thomas_death, 8, thomas_die9); }
void thomas_die7(entity this) { set_animofs(this, anim_thomas_death, 7, thomas_die8); }
void thomas_die6(entity this) { set_animofs(this, anim_thomas_death, 6, thomas_die7); }
void thomas_die5(entity this) { set_animofs(this, anim_thomas_death, 5, thomas_die6); }
void thomas_die4(entity this) { set_animofs(this, anim_thomas_death, 4, thomas_die5); }
void thomas_die3(entity this) { set_animofs(this, anim_thomas_death, 3, thomas_die4); }
void thomas_die2(entity this) { set_animofs(this, anim_thomas_death, 2, thomas_die3); }
void thomas_die1(entity this)
{
	set_animofs(this, anim_thomas_death, 1, thomas_die2);
	if(random() > 0.5)
		_sound(this, CH_VOICE, "thomas/death1.wav", 1, 0.5);
	else
		_sound(this, CH_VOICE, "thomas/death2.wav", 1, 0.5);
	this.solid = SOLID_NOT;
}

void thomas_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			thomas_explode(this);
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

// regular death
	thomas_die1(this);
}

/*
==============
CheckThomasCharge

==============
*/
bool CheckThomasCharge(entity this)
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

bool ThomasCheckAttack(entity this)
{
	entity targ = this.enemy;

	if(this.enemy_range == RANGE_FAR)
		return false;
	if(time < this.attack_finished)
		return false;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, MOVE_NORMAL, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
		return false;	// don't have a clear shot
			
	
// missile attack

	float chance = 0;
	if(this.enemy_range == RANGE_MELEE)
		chance = 0.05;
	else if(this.enemy_range == RANGE_NEAR)
		chance = 0.4;
	else if(this.enemy_range == RANGE_MID)
		chance = 0.9;

	if(random() < chance && CheckThomasCharge(this))
	{
		this.th_missile(this);
		this.attack_finished = time + 3;

		return true;
	}

	return false;
}

void thomas_touch(entity this, entity toucher)
{
	if(this.health <= 0 || !this.takedamage || !toucher.takedamage)
		return;
	//if(!IS_PLAYER(toucher) && !IS_MONSTER(toucher) && !toucher.monster_attack)
		//return;
	if(!Damage_ValidTarget(toucher, this))
		return;

	float damage = (IS_PLAYER(toucher) || this.charmed) ? 150 : 1000;

	T_Damage(toucher, this, this, damage, DEATH_MONSTER_THOMAS.m_id);
}

/*QUAKED monster_thomas(1 0 0)(-32 -32 -24)(32 32 64) Ambush
*/
spawnfunc(monster_thomas) { monster_start(this, true, MON_THOMAS); }
#endif // SVQC

#ifdef SVQC
METHOD(Thomas, mr_setup, bool(Thomas this, entity actor))
{
    TC(Thomas, this);

	precache_sound("thomas/death1.wav");
	precache_sound("thomas/death2.wav");
	precache_sound("thomas/charge.wav");
	precache_sound("thomas/idle.wav");
	precache_sound("thomas/whistle.wav");

	actor.health = 2000;
	actor.gibhealth = -150;
	actor.scale = 3;
	setsize(actor, this.m_mins * actor.scale, this.m_maxs * actor.scale);
	actor.th_stand = thomas_stand1;
	actor.th_walk = thomas_walk1;
	actor.th_run = thomas_run1;
	actor.th_die = thomas_die;
	//actor.th_melee = Thomas_MeleeAttack;		// one of two attacks
	actor.th_missile = thomas_charge;			// jump attack
	actor.th_pain = thomas_pain;
	settouch(actor, thomas_touch);
	actor.solid = SOLID_CORPSE;

	actor.checkattack = ThomasCheckAttack;

	return true;
}
METHOD(Thomas, mr_sight, bool(Thomas this, entity actor))
{
	TC(Thomas, this);

	_sound(actor, CH_VOICE, "thomas/whistle.wav", 1, ATTN_NORM);

	return true;
}
#endif
