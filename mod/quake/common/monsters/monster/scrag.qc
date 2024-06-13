#include "scrag.qh"

#include "grenling.qh"

#ifdef SVQC
const int anim_wiz_hover = 0; //'0 14 0'
const int anim_wiz_fly = 15; //'15 28 0'
const int anim_wiz_magatt = 29; //'15 41 0'
const int anim_wiz_pain = 42; //'42 45 0'
const int anim_wiz_death = 46; //'46 53 0'

/*
==============================================================================

WIZARD

If the player moves behind cover before the missile is launched, launch it
at the last visible spot with no velocity leading, in hopes that the player
will duck back out and catch it.
==============================================================================
*/

/*
=============
LaunchMissile

Sets the given entities velocity and angles so that it will hit this.enemy
if this.enemy maintains it's current velocity
0.1 is moderately accurate, 0.0 is totally accurate
=============
*/
void LaunchMissile(entity this, entity missile, float mspeed, float accuracy)
{
	fixedmakevectors(this.angles);
		
// set missile speed
	vector vec = this.enemy.origin + this.enemy.mins + this.enemy.size * 0.7 - missile.origin;

// calc approximate time for missile to reach vec
	float fly = vlen(vec) / mspeed;
	
// get the entities xy velocity
	vector move = vec2(this.enemy.velocity);

// project the target forward in time
	vec = vec + move * fly;
	
	vec = normalize(vec);
	vec = vec + accuracy*v_up*(random()- 0.5) + accuracy*v_right*(random()- 0.5);
	
	missile.velocity = vec * mspeed;

	missile.angles = '0 0 0';
	missile.angles_y = vectoyaw(missile.velocity);

// set missile duration
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);	
}


void wiz_run1(entity this);
void wiz_side1(entity this);

/*
=================
WizardCheckAttack
=================
*/
bool WizardCheckAttack(entity this)
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
			wiz_run1(this);
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
			wiz_run1(this);
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
			wiz_run1(this);
		}
	}
	else
	{
		if(this.attack_state != AS_SLIDING)
		{
			this.attack_state = AS_SLIDING;
			wiz_side1(this);
		}
	}
	
	return false;
}

/*
=================
WizardAttackFinished
=================
*/
void WizardAttackFinished(entity this)
{
	if(this.enemy_range >= RANGE_MID || !this.enemy_visible)
	{
		this.attack_state = AS_STRAIGHT;
		setthink(this, wiz_run1);
	}
	else
	{
		this.attack_state = AS_SLIDING;
		setthink(this, wiz_side1);
	}
}

/*
==============================================================================

FAST ATTACKS

==============================================================================
*/

void Wiz_FastFire(entity this)
{
	if(this.owner && this.owner.health > 0)
	{
		this.owner.effects |= EF_MUZZLEFLASH;

		fixedmakevectors(this.enemy.angles);	
		vector dst = this.enemy.origin - 13*this.movedir;
	
		vector vec = normalize(dst - this.origin);
		_sound(this.owner, CH_WEAPON_SINGLE, "wizard/wattack.wav", 1, ATTN_NORM);
		entity newmis = launch_spike(this, this.origin, vec);
		newmis.projectiledeathtype = DEATH_MONSTER_SCRAG.m_id;
		newmis.velocity = vec*600;
		newmis.owner = this.owner;
		newmis.classname = "wizard_spike";
		_setmodel(newmis, "progs/w_spike.mdl");
		setsize(newmis, '0 0 0', '0 0 0');		
	}

	delete(this);
}

void Wiz_StartFast(entity this)
{
	_sound(this, CH_WEAPON_SINGLE, "wizard/wattack.wav", 1, ATTN_NORM);
	this.v_angle = this.angles;
	fixedmakevectors(this.angles);

	entity missile = spawn();
	missile.owner = this;
	missile.nextthink = time + 0.6;
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, this.origin + '0 0 30' + v_forward*14 + v_right*14);
	missile.enemy = this.enemy;
	missile.nextthink = time + 0.8;
	setthink(missile, Wiz_FastFire);
	missile.movedir = v_right;

	missile = spawn();
	missile.owner = this;
	missile.nextthink = time + 1;
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, this.origin + '0 0 30' + v_forward*14 + v_right* -14);
	missile.enemy = this.enemy;
	missile.nextthink = time + 0.3;
	setthink(missile, Wiz_FastFire);
	missile.movedir = '0 0 0' - v_right;
}

void Wiz_idle_sound(entity this)
{
	float wr = random() * 5;

	if(this.waitmin < time)
	{
	 	this.waitmin = time + 2;
	 	if(wr > 4.5) 
	 		_sound(this, CH_VOICE, "wizard/widle1.wav", 1,  ATTN_IDLE);
	 	if(wr < 1.5)
	 		_sound(this, CH_VOICE, "wizard/widle2.wav", 1, ATTN_IDLE);
	}
	return;
}

void wiz_stand1(entity this);
void wiz_stand8(entity this) { set_animofs(this, anim_wiz_hover, 8, wiz_stand1); ai_stand(this); }
void wiz_stand7(entity this) { set_animofs(this, anim_wiz_hover, 7, wiz_stand8); ai_stand(this); }
void wiz_stand6(entity this) { set_animofs(this, anim_wiz_hover, 6, wiz_stand7); ai_stand(this); }
void wiz_stand5(entity this) { set_animofs(this, anim_wiz_hover, 5, wiz_stand6); ai_stand(this); }
void wiz_stand4(entity this) { set_animofs(this, anim_wiz_hover, 4, wiz_stand5); ai_stand(this); }
void wiz_stand3(entity this) { set_animofs(this, anim_wiz_hover, 3, wiz_stand4); ai_stand(this); }
void wiz_stand2(entity this) { set_animofs(this, anim_wiz_hover, 2, wiz_stand3); ai_stand(this); }
void wiz_stand1(entity this) { set_animofs(this, anim_wiz_hover, 1, wiz_stand2); ai_stand(this); }

void wiz_walk1(entity this);
void wiz_walk8(entity this) { set_animofs(this, anim_wiz_hover, 8, wiz_walk1); ai_walk(this, 8); }
void wiz_walk7(entity this) { set_animofs(this, anim_wiz_hover, 7, wiz_walk8); ai_walk(this, 8); }
void wiz_walk6(entity this) { set_animofs(this, anim_wiz_hover, 6, wiz_walk7); ai_walk(this, 8); }
void wiz_walk5(entity this) { set_animofs(this, anim_wiz_hover, 5, wiz_walk6); ai_walk(this, 8); }
void wiz_walk4(entity this) { set_animofs(this, anim_wiz_hover, 4, wiz_walk5); ai_walk(this, 8); }
void wiz_walk3(entity this) { set_animofs(this, anim_wiz_hover, 3, wiz_walk4); ai_walk(this, 8); }
void wiz_walk2(entity this) { set_animofs(this, anim_wiz_hover, 2, wiz_walk3); ai_walk(this, 8); }
void wiz_walk1(entity this) { set_animofs(this, anim_wiz_hover, 1, wiz_walk2); ai_walk(this, 8); Wiz_idle_sound(this); }

void wiz_side1(entity this);
void wiz_side8(entity this) { set_animofs(this, anim_wiz_hover, 8, wiz_side1); ai_run(this, 8); }
void wiz_side7(entity this) { set_animofs(this, anim_wiz_hover, 7, wiz_side8); ai_run(this, 8); }
void wiz_side6(entity this) { set_animofs(this, anim_wiz_hover, 6, wiz_side7); ai_run(this, 8); }
void wiz_side5(entity this) { set_animofs(this, anim_wiz_hover, 5, wiz_side6); ai_run(this, 8); }
void wiz_side4(entity this) { set_animofs(this, anim_wiz_hover, 4, wiz_side5); ai_run(this, 8); }
void wiz_side3(entity this) { set_animofs(this, anim_wiz_hover, 3, wiz_side4); ai_run(this, 8); }
void wiz_side2(entity this) { set_animofs(this, anim_wiz_hover, 2, wiz_side3); ai_run(this, 8); }
void wiz_side1(entity this) { set_animofs(this, anim_wiz_hover, 1, wiz_side2); ai_run(this, 8); Wiz_idle_sound(this); }

void wiz_run1(entity this);
void wiz_run14(entity this) { set_animofs(this, anim_wiz_fly, 14, wiz_run1); ai_run(this, 16); }
void wiz_run13(entity this) { set_animofs(this, anim_wiz_fly, 13, wiz_run14); ai_run(this, 16); }
void wiz_run12(entity this) { set_animofs(this, anim_wiz_fly, 12, wiz_run13); ai_run(this, 16); }
void wiz_run11(entity this) { set_animofs(this, anim_wiz_fly, 11, wiz_run12); ai_run(this, 16); }
void wiz_run10(entity this) { set_animofs(this, anim_wiz_fly, 10, wiz_run11); ai_run(this, 16); }
void wiz_run9(entity this) { set_animofs(this, anim_wiz_fly, 9, wiz_run10); ai_run(this, 16); }
void wiz_run8(entity this) { set_animofs(this, anim_wiz_fly, 8, wiz_run9); ai_run(this, 16); }
void wiz_run7(entity this) { set_animofs(this, anim_wiz_fly, 7, wiz_run8); ai_run(this, 16); }
void wiz_run6(entity this) { set_animofs(this, anim_wiz_fly, 6, wiz_run7); ai_run(this, 16); }
void wiz_run5(entity this) { set_animofs(this, anim_wiz_fly, 5, wiz_run6); ai_run(this, 16); }
void wiz_run4(entity this) { set_animofs(this, anim_wiz_fly, 4, wiz_run5); ai_run(this, 16); }
void wiz_run3(entity this) { set_animofs(this, anim_wiz_fly, 3, wiz_run4); ai_run(this, 16); }
void wiz_run2(entity this) { set_animofs(this, anim_wiz_fly, 2, wiz_run3); ai_run(this, 16); }
void wiz_run1(entity this) { set_animofs(this, anim_wiz_fly, 1, wiz_run2); ai_run(this, 16); Wiz_idle_sound(this); }

void wiz_fast10(entity this) { set_animofs(this, anim_wiz_magatt, 10, wiz_run1); ai_face(this); this.attack_finished = time + 2; WizardAttackFinished(this); }
void wiz_fast9(entity this) { set_animofs(this, anim_wiz_magatt, 9, wiz_fast10); ai_face(this); }
void wiz_fast8(entity this) { set_animofs(this, anim_wiz_magatt, 8, wiz_fast9); ai_face(this); }
void wiz_fast7(entity this) { set_animofs(this, anim_wiz_magatt, 7, wiz_fast8); ai_face(this); }
void wiz_fast6(entity this) { set_animofs(this, anim_wiz_magatt, 6, wiz_fast7); ai_face(this); }
void wiz_fast5(entity this) { set_animofs(this, anim_wiz_magatt, 5, wiz_fast6); ai_face(this); }
void wiz_fast4(entity this) { set_animofs(this, anim_wiz_magatt, 4, wiz_fast5); ai_face(this); }
void wiz_fast3(entity this) { set_animofs(this, anim_wiz_magatt, 3, wiz_fast4); ai_face(this); }
void wiz_fast2(entity this) { set_animofs(this, anim_wiz_magatt, 2, wiz_fast3); ai_face(this); }
void wiz_fast1(entity this) { set_animofs(this, anim_wiz_magatt, 1, wiz_fast2); ai_face(this); Wiz_StartFast(this); }

void wiz_pain4(entity this) { set_animofs(this, anim_wiz_pain, 4, wiz_run1); }
void wiz_pain3(entity this) { set_animofs(this, anim_wiz_pain, 3, wiz_pain4); }
void wiz_pain2(entity this) { set_animofs(this, anim_wiz_pain, 2, wiz_pain3); }
void wiz_pain1(entity this) { set_animofs(this, anim_wiz_pain, 1, wiz_pain2); }

void wiz_death8(entity this)
{
	set_animofs(this, anim_wiz_death, 8, wiz_death8);
	CorpseThink(this);
}
void wiz_death7(entity this) { set_animofs(this, anim_wiz_death, 7, wiz_death8); }
void wiz_death6(entity this) { set_animofs(this, anim_wiz_death, 6, wiz_death7); }
void wiz_death5(entity this) { set_animofs(this, anim_wiz_death, 5, wiz_death6); }
void wiz_death4(entity this) { set_animofs(this, anim_wiz_death, 4, wiz_death5); }
void wiz_death3(entity this) { set_animofs(this, anim_wiz_death, 3, wiz_death4); }
void wiz_death2(entity this) { set_animofs(this, anim_wiz_death, 2, wiz_death3); }
void wiz_death1(entity this)
{
	set_animofs(this, anim_wiz_death, 1, wiz_death2);
	set_movetype(this, MOVETYPE_TOSS);
	this.velocity_x = -200 + 400*random();
	this.velocity_y = -200 + 400*random();
	this.velocity_z = 100 + 100*random();
	UNSET_ONGROUND(this);
	_sound(this, CH_VOICE, "wizard/wdeath.wav", 1, ATTN_NORM);
	this.solid = SOLID_NOT;
}

void wiz_die(entity this, entity inflictor, entity attacker, int deathtype)
{
// check for gib
	if(this.health < -40)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, inflictor, MDL_MON_SCRAG_HEAD.model_str(), this.health);
		ThrowGib(this, inflictor, "progs/grenbone.mdl", this.health);
		ThrowGib(this, inflictor, "progs/grenbone.mdl", this.health);
		ThrowGib(this, inflictor, "progs/grenbone.mdl", this.health);
		ThrowGib(this, inflictor, "progs/grenbone.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
		return;
	}

	wiz_death1(this);
}

void Wiz_Pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	if(random()*70 > damage)
		return;		// didn't flinch
	_sound(this, CH_VOICE, "wizard/wpain.wav", 1, ATTN_NORM);

	wiz_pain1(this);
	this.pain_finished = time + 1;
}

void Wiz_Missile(entity this)
{
	wiz_fast1(this);
}

/*QUAKED monster_wizard(1 0 0)(-16 -16 -24)(16 16 40) Ambush
*/
spawnfunc(monster_wizard)
{
	if(coop == 2 && orig_random(this) < 0.5)
	{
		monster_start(this, true, MON_GRENLING);
		return;
	}
	monster_start(this, true, MON_SCRAG);
}
#endif // SVQC

#ifdef SVQC
METHOD(Scrag, mr_setup, bool(Scrag this, entity actor))
{
    TC(Scrag, this);

	precache_model("progs/w_spike.mdl");
	precache_model("progs/grenbone.mdl");
	precache_sound("wizard/hit.wav");		// used by c code
	precache_sound("wizard/wattack.wav");
	precache_sound("wizard/wdeath.wav");
	precache_sound("wizard/widle1.wav");
	precache_sound("wizard/widle2.wav");
	precache_sound("wizard/wpain.wav");

    actor.health = 80;
    actor.th_stand = wiz_stand1;
	actor.th_walk = wiz_walk1;
	actor.th_run = wiz_run1;
	actor.th_missile = Wiz_Missile;
	actor.th_pain = Wiz_Pain;
	actor.th_die = wiz_die;

	actor.checkattack = WizardCheckAttack;

    return true;
}
#endif
