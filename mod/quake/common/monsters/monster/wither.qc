#include "wither.qh"

#ifdef SVQC
const int anim_wither_hover = 1;
const int anim_wither_fly = 96;
const int anim_wither_magatt = 96;
const int anim_wither_pain = 15;
const int anim_wither_death = 0;

const int MON_WITHER_FRIENDLY = BIT(1);

void wither_run1(entity this);
void wither_side1(entity this);

/*
=================
WitherCheckAttack
=================
*/
bool WitherCheckAttack(entity this)
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
			wither_run1(this);
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
			wither_run1(this);
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
			wither_run1(this);
		}
	}
	else
	{
		if(this.health <= (this.max_health * 0.5))
		{
			if(this.attack_state != AS_DODGING)
			{
				this.attack_state = AS_DODGING;
				wither_side1(this);
			}
		}
		else
		{
			if(this.attack_state != AS_SLIDING)
			{
				this.attack_state = AS_SLIDING;
				wither_side1(this);
			}
		}
	}
	
	return false;
}

/*
=================
WitherAttackFinished
=================
*/
void Wither_Missile(entity this);
void WitherAttackFinished(entity this)
{
	if(this.enemy_range >= RANGE_MID || !this.enemy_visible)
	{
		this.attack_state = AS_STRAIGHT;
		setthink(this, wither_run1);
	}
	else if(this.health <= (this.max_health * 0.5))
	{
		this.attack_state = AS_DODGING;
		setthink(this, wither_side1);
	}
	else
	{
		this.attack_state = AS_SLIDING;
		setthink(this, wither_side1);
	}
}

/*
==============================================================================

FAST ATTACKS

==============================================================================
*/

void wither_skull_touch(entity this, entity toucher)
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
		float damg = ((this.dmg) ? this.dmg : 10);
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);

		float withertime = 20;
		float curtime = StatusEffects_gettime(STATUSEFFECT_Withering, toucher);
		if((time + withertime) > curtime)
			StatusEffects_apply(STATUSEFFECT_Withering, toucher, time + withertime, 0);

		sound(this, CH_WEAPON_SINGLE, SND_MON_WITHER_EXPLODE_RANDOM(), 1, ATTN_NORM);
		T_RadiusDamage(this, this.owner, 40, this.projectiledeathtype, toucher); // tonedown
		te_explosion2(this.origin, 3, 10);
	}
	else
	{
		sound(this, CH_WEAPON_SINGLE, SND_MON_WITHER_EXPLODE_RANDOM(), 1, ATTN_NORM);
		T_RadiusDamage(this, this.owner, 40, this.projectiledeathtype, this.owner); // tonedown
		te_explosion2(this.origin, 3, 10);
	}

	delete(this);
}

void Wither_FastFire(entity this)
{
	if(this.owner && this.owner.health > 0)
	{
		this.owner.effects |= EF_MUZZLEFLASH;

		fixedmakevectors(this.enemy.angles);	
		vector dst = this.enemy.origin - 13*this.movedir;
	
		vector vec = normalize(dst - this.origin);
		_sound(this.owner, CH_WEAPON_SINGLE, "wither/shoot.wav", 1, ATTN_NORM);
		entity newmis = launch_spike(this, this.origin, vec);
		newmis.projectiledeathtype = DEATH_MONSTER_WITHER.m_id;
		newmis.velocity = vec*600;
		newmis.owner = this.owner;
		settouch(newmis, wither_skull_touch);
		newmis.classname = "wizard_spike";
		setmodel(newmis, MDL_MON_WITHER_HEAD);
		setsize(newmis, '0 0 0', '0 0 0');		
	}

	delete(this);
}

void Wither_StartFast(entity this)
{
	//_sound(this, CH_WEAPON_SINGLE, "wither/shoot.wav", 1, ATTN_NORM);
	this.v_angle = this.angles;
	fixedmakevectors(this.angles);

	entity missile = spawn();
	missile.owner = this;
	missile.nextthink = time + 0.6;
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, this.origin + '0 0 30' + v_forward*14 + v_right*32);
	missile.enemy = this.enemy;
	missile.nextthink = time + 0.8;
	setthink(missile, Wither_FastFire);
	missile.movedir = v_right;

	missile = spawn();
	missile.owner = this;
	missile.nextthink = time + 1;
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, this.origin + '0 0 30' + v_forward*14 + v_right* -32);
	missile.enemy = this.enemy;
	missile.nextthink = time + 0.3;
	setthink(missile, Wither_FastFire);
	missile.movedir = '0 0 0' - v_right;

	if(this.health > (this.max_health * 0.5))
		return;

	missile = spawn();
	missile.owner = this;
	missile.nextthink = time + 0.6;
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, this.origin + '0 0 30' + v_forward*14 + v_right*32);
	missile.enemy = this.enemy;
	missile.nextthink = time + 0.8;
	setthink(missile, Wither_FastFire);
	missile.movedir = v_right;
}

void Wither_idle_sound(entity this)
{
	if(this.waitmin < time)
	{
	 	this.waitmin = time + 2 + (random() * 3);
	 	sound(this, CH_VOICE, SND_MON_WITHER_IDLE_RANDOM(), 1, 0.5);
	}

	bool is_low = (this.health <= (this.max_health * 0.5));

	if(is_low)
		this.skin = 1;
	else
		this.skin = (this.spawnflags & MON_WITHER_FRIENDLY) ? 2 : 0;
}

void wither_stand1(entity this);
void wither_stand8(entity this) { set_animofs(this, anim_wither_hover, 1, wither_stand1); ai_stand(this); }
void wither_stand7(entity this) { set_animofs(this, anim_wither_hover, 2, wither_stand8); ai_stand(this); }
void wither_stand6(entity this) { set_animofs(this, anim_wither_hover, 3, wither_stand7); ai_stand(this); }
void wither_stand5(entity this) { set_animofs(this, anim_wither_hover, 4, wither_stand6); ai_stand(this); }
void wither_stand4(entity this) { set_animofs(this, anim_wither_hover, 4, wither_stand5); ai_stand(this); }
void wither_stand3(entity this) { set_animofs(this, anim_wither_hover, 3, wither_stand4); ai_stand(this); }
void wither_stand2(entity this) { set_animofs(this, anim_wither_hover, 2, wither_stand3); ai_stand(this); }
void wither_stand1(entity this) { set_animofs(this, anim_wither_hover, 1, wither_stand2); ai_stand(this); Wither_idle_sound(this); }

void wither_walk1(entity this);
void wither_walk8(entity this) { set_animofs(this, anim_wither_hover, 1, wither_walk1); ai_walk(this, 8); }
void wither_walk7(entity this) { set_animofs(this, anim_wither_hover, 2, wither_walk8); ai_walk(this, 8); }
void wither_walk6(entity this) { set_animofs(this, anim_wither_hover, 3, wither_walk7); ai_walk(this, 8); }
void wither_walk5(entity this) { set_animofs(this, anim_wither_hover, 4, wither_walk6); ai_walk(this, 8); }
void wither_walk4(entity this) { set_animofs(this, anim_wither_hover, 4, wither_walk5); ai_walk(this, 8); }
void wither_walk3(entity this) { set_animofs(this, anim_wither_hover, 3, wither_walk4); ai_walk(this, 8); }
void wither_walk2(entity this) { set_animofs(this, anim_wither_hover, 2, wither_walk3); ai_walk(this, 8); }
void wither_walk1(entity this) { set_animofs(this, anim_wither_hover, 1, wither_walk2); ai_walk(this, 8); Wither_idle_sound(this); }

void wither_side1(entity this);
void wither_side8(entity this) { set_animofs(this, anim_wither_hover, 1, wither_side1); ai_run(this, 8); }
void wither_side7(entity this) { set_animofs(this, anim_wither_hover, 2, wither_side8); ai_run(this, 8); }
void wither_side6(entity this) { set_animofs(this, anim_wither_hover, 3, wither_side7); ai_run(this, 8); }
void wither_side5(entity this) { set_animofs(this, anim_wither_hover, 4, wither_side6); ai_run(this, 8); }
void wither_side4(entity this) { set_animofs(this, anim_wither_hover, 4, wither_side5); ai_run(this, 8); }
void wither_side3(entity this) { set_animofs(this, anim_wither_hover, 3, wither_side4); ai_run(this, 8); }
void wither_side2(entity this) { set_animofs(this, anim_wither_hover, 2, wither_side3); ai_run(this, 8); }
void wither_side1(entity this) { set_animofs(this, anim_wither_hover, 1, wither_side2); ai_run(this, 8); Wither_idle_sound(this); }

void wither_run1(entity this);
void wither_run14(entity this) { set_animofs(this, anim_wither_fly, 14, wither_run1); ai_run(this, 16); }
void wither_run13(entity this) { set_animofs(this, anim_wither_fly, 13, wither_run14); ai_run(this, 16); }
void wither_run12(entity this) { set_animofs(this, anim_wither_fly, 12, wither_run13); ai_run(this, 16); }
void wither_run11(entity this) { set_animofs(this, anim_wither_fly, 11, wither_run12); ai_run(this, 16); }
void wither_run10(entity this) { set_animofs(this, anim_wither_fly, 10, wither_run11); ai_run(this, 16); }
void wither_run9(entity this) { set_animofs(this, anim_wither_fly, 9, wither_run10); ai_run(this, 16); }
void wither_run8(entity this) { set_animofs(this, anim_wither_fly, 8, wither_run9); ai_run(this, 16); }
void wither_run7(entity this) { set_animofs(this, anim_wither_fly, 7, wither_run8); ai_run(this, 16); }
void wither_run6(entity this) { set_animofs(this, anim_wither_fly, 6, wither_run7); ai_run(this, 16); }
void wither_run5(entity this) { set_animofs(this, anim_wither_fly, 5, wither_run6); ai_run(this, 16); }
void wither_run4(entity this) { set_animofs(this, anim_wither_fly, 4, wither_run5); ai_run(this, 16); }
void wither_run3(entity this) { set_animofs(this, anim_wither_fly, 3, wither_run4); ai_run(this, 16); }
void wither_run2(entity this) { set_animofs(this, anim_wither_fly, 2, wither_run3); ai_run(this, 16); }
void wither_run1(entity this) { set_animofs(this, anim_wither_fly, 1, wither_run2); ai_run(this, 16); Wither_idle_sound(this); }

void wither_fast10(entity this) { set_animofs(this, anim_wither_magatt, 10, wither_run1); ai_face(this); this.attack_finished = time + 2; WitherAttackFinished(this); }
void wither_fast9(entity this) { set_animofs(this, anim_wither_magatt, 9, wither_fast10); ai_face(this); }
void wither_fast8(entity this) { set_animofs(this, anim_wither_magatt, 8, wither_fast9); ai_face(this); }
void wither_fast7(entity this) { set_animofs(this, anim_wither_magatt, 7, wither_fast8); ai_face(this); }
void wither_fast6(entity this) { set_animofs(this, anim_wither_magatt, 6, wither_fast7); ai_face(this); }
void wither_fast5(entity this) { set_animofs(this, anim_wither_magatt, 5, wither_fast6); ai_face(this); }
void wither_fast4(entity this) { set_animofs(this, anim_wither_magatt, 4, wither_fast5); ai_face(this); }
void wither_fast3(entity this) { set_animofs(this, anim_wither_magatt, 3, wither_fast4); ai_face(this); }
void wither_fast2(entity this) { set_animofs(this, anim_wither_magatt, 2, wither_fast3); ai_face(this); }
void wither_fast1(entity this) { set_animofs(this, anim_wither_magatt, 1, wither_fast2); ai_face(this); Wither_StartFast(this); }

void wither_pain4(entity this) { set_animofs(this, anim_wither_pain, 4, wither_run1); this.colormod = (this.charmed) ? '0 1 0' : '1 1 1'; }
void wither_pain3(entity this) { set_animofs(this, anim_wither_pain, 3, wither_pain4); this.colormod = '1 0.8 0.8'; }
void wither_pain2(entity this) { set_animofs(this, anim_wither_pain, 2, wither_pain3); this.colormod = '1 0.6 0.6'; }
void wither_pain1(entity this) { set_animofs(this, anim_wither_pain, 1, wither_pain2); }

void wither_vanish(entity this)
{
	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

void wither_death7(entity this) { set_animofs(this, anim_wither_death, 7, wither_vanish); this.nextthink = time + 0.7; this.angles_z = 90; }
void wither_death6(entity this) { set_animofs(this, anim_wither_death, 6, wither_death7); this.angles_z = 75; }
void wither_death5(entity this) { set_animofs(this, anim_wither_death, 5, wither_death6); this.angles_z = 60; }
void wither_death4(entity this) { set_animofs(this, anim_wither_death, 4, wither_death5); this.angles_z = 45; }
void wither_death3(entity this) { set_animofs(this, anim_wither_death, 3, wither_death4); this.angles_z = 30; }
void wither_death2(entity this) { set_animofs(this, anim_wither_death, 2, wither_death3); this.angles_z = 15; }
void wither_death1(entity this)
{
	set_animofs(this, anim_wither_death, 1, wither_death2);
	set_movetype(this, MOVETYPE_TOSS);
	this.skin = (this.spawnflags & MON_WITHER_FRIENDLY) ? 2 : 0;
	this.colormod = '1 0.6 0.6';
	this.angles_z = 0;
	this.velocity_x = -200 + 400*random();
	this.velocity_y = -200 + 400*random();
	this.velocity_z = 100 + 100*random();
	UNSET_ONGROUND(this);
	this.solid = SOLID_NOT;
}

void wither_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CH_VOICE, "wither/death.wav", 1, ATTN_NORM);

	wither_death1(this);
}

void Wither_Pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	//if(random()*70 > damage)
		//return;		// didn't flinch
	sound(this, CH_VOICE, SND_MON_WITHER_PAIN_RANDOM(), 1, ATTN_NORM);

	this.colormod = '1 0.9 0.9';
	wither_pain1(this);
	this.pain_finished = time + 1;
}

void Wither_Missile(entity this)
{
	wither_fast1(this);
}

void wither_touch(entity this, entity toucher)
{
	if(this.health <= 0 || (!this.takedamage))
		return;
	if(!Damage_ValidTarget(toucher, this))
		return;

	if(toucher.takedamage && toucher.pain_finished < time)
	{
		float ldmg = 60*random();
		T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_WITHER.m_id);	
	}
}

/*QUAKED monster_wither(1 0 0)(-16 -16 -24)(16 16 40) Ambush
*/
spawnfunc(monster_wither) { monster_start(this, true, MON_WITHER); }
#endif // SVQC

#ifdef SVQC
METHOD(Wither, mr_setup, bool(Wither this, entity actor))
{
    TC(Wither, this);

	precache_sound("wither/death.wav");
	precache_sound("wither/shoot.wav");

	if(random() < 0.2)
		actor.spawnflags |= MON_WITHER_FRIENDLY;

    actor.health = 1200;
    actor.th_stand = wither_stand1;
	actor.th_walk = wither_walk1;
	actor.th_run = wither_run1;
	actor.th_missile = Wither_Missile;
	actor.th_pain = Wither_Pain;
	actor.th_die = wither_die;

	actor.resist_shells = actor.resist_cells = 0;
	actor.resist_nails = actor.resist_rockets = 0;

	if(actor.spawnflags & MON_WITHER_FRIENDLY)
		actor.skin = 2;

	settouch(actor, wither_touch);

	actor.checkattack = WitherCheckAttack;

    return true;
}
#endif
