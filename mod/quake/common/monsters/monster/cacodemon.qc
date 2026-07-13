#include "cacodemon.qh"

#ifdef SVQC
const int anim_caco_hover = 0; //'0 14 0'
const int anim_caco_fly = 15; //'15 28 0'
const int anim_caco_magatt = 29; //'15 41 0'
const int anim_caco_pain = 42; //'42 45 0'
const int anim_caco_death = 46; //'46 53 0'

/*
==============================================================================

CACODEMON

If the player moves behind cover before the missile is launched, launch it
at the last visible spot with no velocity leading, in hopes that the player
will duck back out and catch it.
==============================================================================
*/


void caco_run1(entity this);
void caco_side1(entity this);

/*
=================
CacodemonCheckAttack
=================
*/
bool CacodemonCheckAttack(entity this)
{
	if(time < this.attack_finished)
		return false;
	if(!this.enemy_visible)
		return false;

	if(this.enemy_range == RANGE_FAR)
	{
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
			caco_run1(this);
		}
		return false;
	}
		
	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, false, this);

	if(trace_ent != targ)
	{	// don't have a clear shot, so move to a side
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
			caco_run1(this);
		}
		return false;
	}

	float chance;	
	if(this.enemy_range == RANGE_MELEE)
		chance = 0.9;
	else if(this.enemy_range == RANGE_NEAR)
		chance = 0.6;
	else if(this.enemy_range == RANGE_MID)
		chance = 0.2;
	else
		chance = 0;

	if(random() < chance)
	{
		this.attack_state = AS_MISSILE;
		return true;
	}

	if(this.enemy_range == RANGE_MID)
	{
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
			caco_run1(this);
		}
	}
	else
	{
		if(this.attack_state != AS_SLIDING)
		{
			this.attack_state = AS_SLIDING;
			caco_side1(this);
		}
	}
	
	return false;
}

/*
=================
CacodemonAttackFinished
=================
*/
void CacodemonAttackFinished(entity this)
{
	if(this.enemy_range >= RANGE_MID || !this.enemy_visible)
	{
		this.attack_state = AS_STRAIGHT;
		setthink(this, caco_run1);
	}
	else
	{
		this.attack_state = AS_SLIDING;
		setthink(this, caco_side1);
	}
}

/*
==============================================================================

FAST ATTACKS

==============================================================================
*/

void Caco_FastFire(entity this)
{
	entity actor = this.owner;
	if(actor && actor.health > 0 && actor.exptime == 0)
	{
		actor.effects |= EF_MUZZLEFLASH;

		fixedmakevectors(this.enemy.angles);	
		vector dst = this.enemy.origin - 13*this.movedir;
	
		vector vec = normalize(dst - this.origin);
		_sound(actor, CH_WEAPON_SINGLE, "cacodemon/attack.wav", 1, ATTN_NORM);
		entity newmis = launch_spike(this, this.origin, vec);
		newmis.projectiledeathtype = DEATH_MONSTER_CACODEMON.m_id;
		newmis.velocity = vec * 600;
		newmis.owner = actor;
		newmis.classname = "cacodemon_spike";
		newmis.dmg = 40;
		newmis.noise = "cacodemon/hit.wav";
		settouch(newmis, T_MissileTouch);
		setsize(newmis, '0 0 0', '0 0 0');
		CSQCProjectile(newmis, true, PROJECTILE_CACODEMON_FIREBALL, true);
	}

	delete(this);
}

void Caco_StartFast(entity this)
{
	//_sound(this, CH_WEAPON_SINGLE, "cacodemon/attack.wav", 1, ATTN_NORM);
	this.v_angle = this.angles;
	fixedmakevectors(this.angles);

	entity missile = spawn();
	missile.owner = this;
	missile.nextthink = time + 1;
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, this.origin + v_forward*14);
	missile.enemy = this.enemy;
	missile.nextthink = time + 0.3;
	setthink(missile, Caco_FastFire);
	missile.movedir = '0 0 0' - v_right;
}

void Caco_idle_sound(entity this)
{
	float wr = random() * 5;

	if(this.waitmin < time)
	{
	 	this.waitmin = time + 2;
	 	if(wr > 4.5) 
	 		_sound(this, CH_VOICE, "cacodemon/idle1.wav", 1,  ATTN_IDLE);
	 	if(wr < 1.5)
	 		_sound(this, CH_VOICE, "cacodemon/idle2.wav", 1, ATTN_IDLE);
	}
	return;
}

void caco_stand1(entity this);
void caco_stand8(entity this) { set_animofs(this, anim_caco_hover, 8, caco_stand1); ai_stand(this); }
void caco_stand7(entity this) { set_animofs(this, anim_caco_hover, 7, caco_stand8); ai_stand(this); }
void caco_stand6(entity this) { set_animofs(this, anim_caco_hover, 6, caco_stand7); ai_stand(this); }
void caco_stand5(entity this) { set_animofs(this, anim_caco_hover, 5, caco_stand6); ai_stand(this); }
void caco_stand4(entity this) { set_animofs(this, anim_caco_hover, 4, caco_stand5); ai_stand(this); }
void caco_stand3(entity this) { set_animofs(this, anim_caco_hover, 3, caco_stand4); ai_stand(this); }
void caco_stand2(entity this) { set_animofs(this, anim_caco_hover, 2, caco_stand3); ai_stand(this); }
void caco_stand1(entity this) { set_animofs(this, anim_caco_hover, 1, caco_stand2); ai_stand(this); }

void caco_walk1(entity this);
void caco_walk8(entity this) { set_animofs(this, anim_caco_hover, 8, caco_walk1); ai_walk(this, 8); }
void caco_walk7(entity this) { set_animofs(this, anim_caco_hover, 7, caco_walk8); ai_walk(this, 8); }
void caco_walk6(entity this) { set_animofs(this, anim_caco_hover, 6, caco_walk7); ai_walk(this, 8); }
void caco_walk5(entity this) { set_animofs(this, anim_caco_hover, 5, caco_walk6); ai_walk(this, 8); }
void caco_walk4(entity this) { set_animofs(this, anim_caco_hover, 4, caco_walk5); ai_walk(this, 8); }
void caco_walk3(entity this) { set_animofs(this, anim_caco_hover, 3, caco_walk4); ai_walk(this, 8); }
void caco_walk2(entity this) { set_animofs(this, anim_caco_hover, 2, caco_walk3); ai_walk(this, 8); }
void caco_walk1(entity this) { set_animofs(this, anim_caco_hover, 1, caco_walk2); ai_walk(this, 8); Caco_idle_sound(this); }

void caco_side1(entity this);
void caco_side8(entity this) { set_animofs(this, anim_caco_hover, 8, caco_side1); ai_run(this, 8); }
void caco_side7(entity this) { set_animofs(this, anim_caco_hover, 7, caco_side8); ai_run(this, 8); }
void caco_side6(entity this) { set_animofs(this, anim_caco_hover, 6, caco_side7); ai_run(this, 8); }
void caco_side5(entity this) { set_animofs(this, anim_caco_hover, 5, caco_side6); ai_run(this, 8); }
void caco_side4(entity this) { set_animofs(this, anim_caco_hover, 4, caco_side5); ai_run(this, 8); }
void caco_side3(entity this) { set_animofs(this, anim_caco_hover, 3, caco_side4); ai_run(this, 8); }
void caco_side2(entity this) { set_animofs(this, anim_caco_hover, 2, caco_side3); ai_run(this, 8); }
void caco_side1(entity this) { set_animofs(this, anim_caco_hover, 1, caco_side2); ai_run(this, 8); Caco_idle_sound(this); }

void caco_run1(entity this);
void caco_run14(entity this) { set_animofs(this, anim_caco_fly, 14, caco_run1); ai_run(this, 16); }
void caco_run13(entity this) { set_animofs(this, anim_caco_fly, 13, caco_run14); ai_run(this, 16); }
void caco_run12(entity this) { set_animofs(this, anim_caco_fly, 12, caco_run13); ai_run(this, 16); }
void caco_run11(entity this) { set_animofs(this, anim_caco_fly, 11, caco_run12); ai_run(this, 16); }
void caco_run10(entity this) { set_animofs(this, anim_caco_fly, 10, caco_run11); ai_run(this, 16); }
void caco_run9(entity this) { set_animofs(this, anim_caco_fly, 9, caco_run10); ai_run(this, 16); }
void caco_run8(entity this) { set_animofs(this, anim_caco_fly, 8, caco_run9); ai_run(this, 16); }
void caco_run7(entity this) { set_animofs(this, anim_caco_fly, 7, caco_run8); ai_run(this, 16); }
void caco_run6(entity this) { set_animofs(this, anim_caco_fly, 6, caco_run7); ai_run(this, 16); }
void caco_run5(entity this) { set_animofs(this, anim_caco_fly, 5, caco_run6); ai_run(this, 16); }
void caco_run4(entity this) { set_animofs(this, anim_caco_fly, 4, caco_run5); ai_run(this, 16); }
void caco_run3(entity this) { set_animofs(this, anim_caco_fly, 3, caco_run4); ai_run(this, 16); }
void caco_run2(entity this) { set_animofs(this, anim_caco_fly, 2, caco_run3); ai_run(this, 16); }
void caco_run1(entity this) { set_animofs(this, anim_caco_fly, 1, caco_run2); ai_run(this, 16); Caco_idle_sound(this); }

void caco_fast10(entity this) { set_animofs(this, anim_caco_magatt, 10, caco_run1); ai_face(this); this.attack_finished = time + 2; CacodemonAttackFinished(this); }
void caco_fast9(entity this) { set_animofs(this, anim_caco_magatt, 9, caco_fast10); ai_face(this); }
void caco_fast8(entity this) { set_animofs(this, anim_caco_magatt, 8, caco_fast9); ai_face(this); }
void caco_fast7(entity this) { set_animofs(this, anim_caco_magatt, 7, caco_fast8); ai_face(this); }
void caco_fast6(entity this) { set_animofs(this, anim_caco_magatt, 6, caco_fast7); ai_face(this); }
void caco_fast5(entity this) { set_animofs(this, anim_caco_magatt, 5, caco_fast6); ai_face(this); }
void caco_fast4(entity this) { set_animofs(this, anim_caco_magatt, 4, caco_fast5); ai_face(this); }
void caco_fast3(entity this) { set_animofs(this, anim_caco_magatt, 3, caco_fast4); ai_face(this); }
void caco_fast2(entity this) { set_animofs(this, anim_caco_magatt, 2, caco_fast3); ai_face(this); }
void caco_fast1(entity this) { set_animofs(this, anim_caco_magatt, 1, caco_fast2); ai_face(this); Caco_StartFast(this); }

void caco_pain4(entity this) { set_animofs(this, anim_caco_pain, 4, caco_run1); }
void caco_pain3(entity this) { set_animofs(this, anim_caco_pain, 3, caco_pain4); }
void caco_pain2(entity this) { set_animofs(this, anim_caco_pain, 2, caco_pain3); }
void caco_pain1(entity this) { set_animofs(this, anim_caco_pain, 1, caco_pain2); }

void caco_death8(entity this)
{
	set_animofs(this, anim_caco_death, 8, caco_death8);
	CorpseThink(this);
}
void caco_death7(entity this) { set_animofs(this, anim_caco_death, 7, caco_death8); }
void caco_death6(entity this) { set_animofs(this, anim_caco_death, 6, caco_death7); }
void caco_death5(entity this) { set_animofs(this, anim_caco_death, 5, caco_death6); }
void caco_death4(entity this) { set_animofs(this, anim_caco_death, 4, caco_death5); }
void caco_death3(entity this) { set_animofs(this, anim_caco_death, 3, caco_death4); }
void caco_death2(entity this) { set_animofs(this, anim_caco_death, 2, caco_death3); }
void caco_death1(entity this)
{
	set_animofs(this, anim_caco_death, 1, caco_death2);
	set_movetype(this, MOVETYPE_TOSS);
	this.velocity_x = -200 + 400*random();
	this.velocity_y = -200 + 400*random();
	this.velocity_z = 100 + 100*random();
	UNSET_ONGROUND(this);
	_sound(this, CH_VOICE, "cacodemon/death.wav", 1, ATTN_NORM);
	this.solid = SOLID_NOT;
}

void caco_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
			ThrowGib(this, inflictor, "progs/h_cacodemon.mdl", this.health);
			ThrowGib(this, inflictor, "progs/grenbone.mdl", this.health);
			ThrowGib(this, inflictor, "progs/grenbone.mdl", this.health);
			ThrowGib(this, inflictor, "progs/grenbone.mdl", this.health);
			ThrowGib(this, inflictor, "progs/grenbone.mdl", this.health);
			ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
			ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	caco_death1(this);
}

void Caco_Pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	if(random()*70 > damage)
		return;		// didn't flinch
	_sound(this, CH_VOICE, "cacodemon/pain.wav", 1, ATTN_NORM);

	this.pain_finished = time + 1;
	caco_pain1(this);
}

void Caco_Missile(entity this)
{
	caco_fast1(this);
}

/*QUAKED monster_cacodemon(1 0 0)(-16 -16 -24)(16 16 40) Ambush
*/
spawnfunc(monster_cacodemon) { monster_start(this, true, MON_CACODEMON); }
#endif // SVQC

#ifdef SVQC
METHOD(Cacodemon, mr_setup, bool(Cacodemon this, entity actor))
{
    TC(Cacodemon, this);

    precache_model("progs/h_cacodemon.mdl");
    precache_model("progs/grenbone.mdl");
	precache_sound("cacodemon/hit.wav");
	precache_sound("cacodemon/attack.wav");
	precache_sound("cacodemon/death.wav");
	precache_sound("cacodemon/idle1.wav");
	precache_sound("cacodemon/idle2.wav");
	precache_sound("cacodemon/pain.wav");
	precache_sound("cacodemon/sight.wav");

    actor.health = 120;
    actor.gibhealth = -40;
    actor.th_stand = caco_stand1;
	actor.th_walk = caco_walk1;
	actor.th_run = caco_run1;
	actor.th_missile = Caco_Missile;
	actor.th_pain = Caco_Pain;
	actor.th_die = caco_die;

	actor.checkattack = CacodemonCheckAttack;

    return true;
}
METHOD(Cacodemon, mr_sight, bool(Cacodemon this, entity actor))
{
	TC(Cacodemon, this);

	_sound(actor, CH_VOICE, "cacodemon/sight.wav", 1, ATTN_NORM);

	return true;
}
#endif
