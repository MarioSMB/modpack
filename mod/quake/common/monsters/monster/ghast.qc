#include "ghast.qh"

#ifdef SVQC
const int anim_ghast = 0;
const int anim_ghast_fly = 1;

void ghast_run1(entity this);
void ghast_side1(entity this);

/*
=================
GhastCheckAttack
=================
*/
bool GhastCheckAttack(entity this)
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
			ghast_run1(this);
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
			ghast_run1(this);
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
			ghast_run1(this);
		}
	}
	else
	{
		if(this.health <= (this.max_health * 0.5))
		{
			if(this.attack_state != AS_DODGING)
			{
				this.attack_state = AS_DODGING;
				ghast_side1(this);
			}
		}
		else
		{
			if(this.attack_state != AS_SLIDING)
			{
				this.attack_state = AS_SLIDING;
				ghast_side1(this);
			}
		}
	}
	
	return false;
}

/*
=================
GhastAttackFinished
=================
*/
void Ghast_Missile(entity this);
void GhastAttackFinished(entity this)
{
	this.skin = 0;
	if(this.enemy_range >= RANGE_MID || !this.enemy_visible)
	{
		this.attack_state = AS_STRAIGHT;
		setthink(this, ghast_run1);
	}
	else
	{
		this.attack_state = AS_SLIDING;
		setthink(this, ghast_side1);
	}
}

/*
==============================================================================

FAST ATTACKS

==============================================================================
*/

void ghast_fireball_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
// hit something that bleeds
	if(toucher.takedamage) // yoder mod, jan 05 2021
	{
		float damg = ((this.dmg) ? this.dmg : 20);
		if(toucher.monsterdef == MON_GHAST && toucher.owner.monsterdef != MON_GHAST)
			damg *= 10;
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);

		sound(this, CH_WEAPON_SINGLE, SND_MON_GHAST_EXPLODE_RANDOM(), 1, ATTN_NORM);
		T_RadiusDamage(this, this.owner, 60, this.projectiledeathtype, toucher); // tonedown
		te_explosion2(this.origin, 3, 10);
	}
	else
	{
		sound(this, CH_WEAPON_SINGLE, SND_MON_GHAST_EXPLODE_RANDOM(), 1, ATTN_NORM);
		T_RadiusDamage(this, this.owner, 60, this.projectiledeathtype, this.owner); // tonedown
		te_explosion2(this.origin, 3, 10);
	}

	delete(this);
}

void Ghast_FastFire(entity this)
{
	if(this.owner && this.owner.health > 0)
	{
		this.owner.effects |= EF_MUZZLEFLASH;

		fixedmakevectors(this.enemy.angles);	
		vector dst = this.enemy.origin - 13*this.movedir;
	
		vector vec = normalize(dst - this.origin);
		_sound(this.owner, CH_WEAPON_SINGLE, "ghast/fireball4.wav", 1, ATTN_NORM);
		entity newmis = launch_spike(this, this.origin, vec);
		newmis.projectiledeathtype = DEATH_MONSTER_GHAST.m_id;
		newmis.velocity = vec*400;
		newmis.owner = this.owner;
		settouch(newmis, ghast_fireball_touch);
		newmis.classname = "ghast_fireball";
		_setmodel(newmis, "progs/lavaball.mdl");
		setsize(newmis, '0 0 0', '0 0 0');		
	}

	delete(this);
}

void Ghast_StartFast(entity this)
{
	_sound(this, CH_WEAPON_SINGLE, "ghast/charge.wav", 1, ATTN_NORM);
	this.v_angle = this.angles;
	fixedmakevectors(this.angles);

	entity missile = spawn();
	missile.owner = this;
	missile.nextthink = time + 0.6;
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, this.origin + '0 0 8');
	missile.enemy = this.enemy;
	missile.nextthink = time + 0.35;
	setthink(missile, Ghast_FastFire);
	missile.movedir = v_right;
}

void Ghast_idle_sound(entity this)
{
	if(this.waitmin < time)
	{
	 	this.waitmin = time + 2 + (random() * 3);
	 	sound(this, CH_VOICE, SND_MON_GHAST_IDLE_RANDOM(), 1, 0.5);
	}
}

void ghast_stand1(entity this);
void ghast_stand8(entity this) { set_animofs(this, anim_ghast_fly, 2, ghast_stand1); ai_stand(this); }
void ghast_stand7(entity this) { set_animofs(this, anim_ghast_fly, 1, ghast_stand8); ai_stand(this); }
void ghast_stand6(entity this) { set_animofs(this, anim_ghast_fly, 2, ghast_stand7); ai_stand(this); }
void ghast_stand5(entity this) { set_animofs(this, anim_ghast_fly, 3, ghast_stand6); ai_stand(this); }
void ghast_stand4(entity this) { set_animofs(this, anim_ghast_fly, 4, ghast_stand5); ai_stand(this); }
void ghast_stand3(entity this) { set_animofs(this, anim_ghast_fly, 3, ghast_stand4); ai_stand(this); }
void ghast_stand2(entity this) { set_animofs(this, anim_ghast_fly, 2, ghast_stand3); ai_stand(this); }
void ghast_stand1(entity this) { set_animofs(this, anim_ghast_fly, 1, ghast_stand2); ai_stand(this); Ghast_idle_sound(this); }

void ghast_walk1(entity this);
void ghast_walk8(entity this) { set_animofs(this, anim_ghast_fly, 1, ghast_walk1); ai_walk(this, 8); }
void ghast_walk7(entity this) { set_animofs(this, anim_ghast_fly, 2, ghast_walk8); ai_walk(this, 8); }
void ghast_walk6(entity this) { set_animofs(this, anim_ghast_fly, 3, ghast_walk7); ai_walk(this, 8); }
void ghast_walk5(entity this) { set_animofs(this, anim_ghast_fly, 4, ghast_walk6); ai_walk(this, 8); }
void ghast_walk4(entity this) { set_animofs(this, anim_ghast_fly, 4, ghast_walk5); ai_walk(this, 8); }
void ghast_walk3(entity this) { set_animofs(this, anim_ghast_fly, 3, ghast_walk4); ai_walk(this, 8); }
void ghast_walk2(entity this) { set_animofs(this, anim_ghast_fly, 2, ghast_walk3); ai_walk(this, 8); }
void ghast_walk1(entity this) { set_animofs(this, anim_ghast_fly, 1, ghast_walk2); ai_walk(this, 8); Ghast_idle_sound(this); }

void ghast_side1(entity this);
void ghast_side8(entity this) { set_animofs(this, anim_ghast_fly, 1, ghast_side1); ai_run(this, 8); }
void ghast_side7(entity this) { set_animofs(this, anim_ghast_fly, 2, ghast_side8); ai_run(this, 8); }
void ghast_side6(entity this) { set_animofs(this, anim_ghast_fly, 3, ghast_side7); ai_run(this, 8); }
void ghast_side5(entity this) { set_animofs(this, anim_ghast_fly, 4, ghast_side6); ai_run(this, 8); }
void ghast_side4(entity this) { set_animofs(this, anim_ghast_fly, 4, ghast_side5); ai_run(this, 8); }
void ghast_side3(entity this) { set_animofs(this, anim_ghast_fly, 3, ghast_side4); ai_run(this, 8); }
void ghast_side2(entity this) { set_animofs(this, anim_ghast_fly, 2, ghast_side3); ai_run(this, 8); }
void ghast_side1(entity this) { set_animofs(this, anim_ghast_fly, 1, ghast_side2); ai_run(this, 8); Ghast_idle_sound(this); }

void ghast_run1(entity this);
void ghast_run14(entity this) { set_animofs(this, anim_ghast_fly, 2, ghast_run1); ai_run(this, 16); }
void ghast_run13(entity this) { set_animofs(this, anim_ghast_fly, 1, ghast_run14); ai_run(this, 16); }
void ghast_run12(entity this) { set_animofs(this, anim_ghast_fly, 2, ghast_run13); ai_run(this, 16); }
void ghast_run11(entity this) { set_animofs(this, anim_ghast_fly, 3, ghast_run12); ai_run(this, 16); }
void ghast_run10(entity this) { set_animofs(this, anim_ghast_fly, 4, ghast_run11); ai_run(this, 16); }
void ghast_run9(entity this) { set_animofs(this, anim_ghast_fly, 3, ghast_run10); ai_run(this, 16); }
void ghast_run8(entity this) { set_animofs(this, anim_ghast_fly, 2, ghast_run9); ai_run(this, 16); }
void ghast_run7(entity this) { set_animofs(this, anim_ghast_fly, 1, ghast_run8); ai_run(this, 16); }
void ghast_run6(entity this) { set_animofs(this, anim_ghast_fly, 2, ghast_run7); ai_run(this, 16); }
void ghast_run5(entity this) { set_animofs(this, anim_ghast_fly, 3, ghast_run6); ai_run(this, 16); }
void ghast_run4(entity this) { set_animofs(this, anim_ghast_fly, 4, ghast_run5); ai_run(this, 16); }
void ghast_run3(entity this) { set_animofs(this, anim_ghast_fly, 3, ghast_run4); ai_run(this, 16); }
void ghast_run2(entity this) { set_animofs(this, anim_ghast_fly, 2, ghast_run3); ai_run(this, 16); }
void ghast_run1(entity this) { set_animofs(this, anim_ghast_fly, 1, ghast_run2); ai_run(this, 16); Ghast_idle_sound(this); }

void ghast_fast10(entity this) { set_animofs(this, anim_ghast_fly, 2, ghast_run1); ai_face(this); this.attack_finished = time + 2; GhastAttackFinished(this); }
void ghast_fast9(entity this) { set_animofs(this, anim_ghast_fly, 3, ghast_fast10); ai_face(this); }
void ghast_fast8(entity this) { set_animofs(this, anim_ghast_fly, 2, ghast_fast9); ai_face(this); }
void ghast_fast7(entity this) { set_animofs(this, anim_ghast_fly, 1, ghast_fast8); ai_face(this); }
void ghast_fast6(entity this) { set_animofs(this, anim_ghast_fly, 2, ghast_fast7); ai_face(this); }
void ghast_fast5(entity this) { set_animofs(this, anim_ghast_fly, 3, ghast_fast6); ai_face(this); }
void ghast_fast4(entity this) { set_animofs(this, anim_ghast_fly, 4, ghast_fast5); ai_face(this); }
void ghast_fast3(entity this) { set_animofs(this, anim_ghast_fly, 3, ghast_fast4); ai_face(this); }
void ghast_fast2(entity this) { set_animofs(this, anim_ghast_fly, 2, ghast_fast3); ai_face(this); }
void ghast_fast1(entity this) { set_animofs(this, anim_ghast_fly, 1, ghast_fast2); ai_face(this); this.skin = 1; Ghast_StartFast(this); }

void ghast_pain4(entity this) { set_anim(this, anim_ghast, ghast_run1); this.colormod = (this.charmed) ? '0 1 0' : '1 1 1'; }
void ghast_pain3(entity this) { set_anim(this, anim_ghast, ghast_pain4); this.colormod = '1 0.8 0.8'; }
void ghast_pain2(entity this) { set_anim(this, anim_ghast, ghast_pain3); this.colormod = '1 0.6 0.6'; }
void ghast_pain1(entity this) { set_anim(this, anim_ghast, ghast_pain2); }

void ghast_vanish(entity this)
{
	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

void ghast_death7(entity this) { set_anim(this, anim_ghast, ghast_vanish); this.nextthink = time + 0.7; this.angles_z = 90; }
void ghast_death6(entity this) { set_anim(this, anim_ghast, ghast_death7); this.angles_z = 75; }
void ghast_death5(entity this) { set_anim(this, anim_ghast, ghast_death6); this.angles_z = 60; }
void ghast_death4(entity this) { set_anim(this, anim_ghast, ghast_death5); this.angles_z = 45; }
void ghast_death3(entity this) { set_anim(this, anim_ghast, ghast_death4); this.angles_z = 30; }
void ghast_death2(entity this) { set_anim(this, anim_ghast, ghast_death3); this.angles_z = 15; }
void ghast_death1(entity this)
{
	set_anim(this, anim_ghast, ghast_death2);
	set_movetype(this, MOVETYPE_TOSS);
	this.skin = 0;
	this.colormod = '1 0.6 0.6';
	this.angles_z = 0;
	this.velocity_x = -200 + 400*random();
	this.velocity_y = -200 + 400*random();
	this.velocity_z = 100 + 100*random();
	UNSET_ONGROUND(this);
	this.solid = SOLID_NOT;
}

void ghast_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CH_VOICE, "ghast/death.wav", 1, ATTN_NORM);

	ghast_death1(this);
}

void Ghast_Pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	//if(random()*70 > damage)
		//return;		// didn't flinch
	sound(this, CH_VOICE, SND_MON_GHAST_PAIN_RANDOM(), 1, ATTN_NORM);

	this.colormod = '1 0.9 0.9';
	this.pain_finished = time + 1;
	ghast_pain1(this);
}

void Ghast_Missile(entity this)
{
	ghast_fast1(this);
}

/*QUAKED monster_ghast(1 0 0)(-16 -16 -24)(16 16 40) Ambush
*/
spawnfunc(monster_ghast) { monster_start(this, true, MON_GHAST); }
#endif // SVQC

#ifdef SVQC
METHOD(Ghast, mr_setup, bool(Ghast this, entity actor))
{
    TC(Ghast, this);

	precache_sound("ghast/death.wav");
	precache_sound("ghast/charge.wav");

	precache_sound("ghast/fireball4.wav");

	precache_model("progs/lavaball.mdl");

	actor.skin = 0;
    actor.health = 80;
    actor.th_stand = ghast_stand1;
	actor.th_walk = ghast_walk1;
	actor.th_run = ghast_run1;
	actor.th_missile = Ghast_Missile;
	actor.th_pain = Ghast_Pain;
	actor.th_die = ghast_die;

	actor.checkattack = GhastCheckAttack;

    return true;
}
#endif
