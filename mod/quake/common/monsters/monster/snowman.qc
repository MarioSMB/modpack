#include "snowman.qh"

#ifdef SVQC
const int anim_snowman_stand = 0;
const int anim_snowman_claw = 1;
const int anim_snowman_attack = 6;

/*==============================================================================
XMAS Snowman - From Twisted Christmas Mod by Twisted Matrix
==============================================================================*/

void snowman_idlesound(entity this)
{
	if(random() < 0.2)
		_sound(this, CH_VOICE, "xmas/snowman/idle.wav", 1,  ATTN_IDLE);
}

void snowm_stand1(entity this);
void snowm_stand8(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_stand1); ai_stand(this); }
void snowm_stand7(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_stand8); ai_stand(this); }
void snowm_stand6(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_stand7); ai_stand(this); }
void snowm_stand5(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_stand6); ai_stand(this); }
void snowm_stand4(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_stand5); ai_stand(this); }
void snowm_stand3(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_stand4); ai_stand(this); }
void snowm_stand2(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_stand3); ai_stand(this); }
void snowm_stand1(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_stand2); snowman_idlesound(this); ai_stand(this); }

//======================================================================
void snowm_walk1(entity this);
void snowm_walk8(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_walk1); ai_walk(this, 0); }
void snowm_walk7(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_walk8); ai_walk(this, 0); }
void snowm_walk6(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_walk7); ai_walk(this, 0); }
void snowm_walk5(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_walk6); ai_walk(this, 0); }
void snowm_walk4(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_walk5); ai_walk(this, 0); }
void snowm_walk3(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_walk4); ai_walk(this, 0); }
void snowm_walk2(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_walk3); ai_walk(this, 0); }
void snowm_walk1(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_walk2); snowman_idlesound(this); ai_walk(this, 0); }

//======================================================================
void snowm_run1(entity this);
void snowm_run8(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_run1); ai_run(this, 0); }
void snowm_run7(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_run8); ai_run(this, 0); }
void snowm_run6(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_run7); ai_run(this, 0); }
void snowm_run5(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_run6); ai_run(this, 0); }
void snowm_run4(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_run5); ai_run(this, 0); }
void snowm_run3(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_run4); ai_run(this, 0); }
void snowm_run2(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_run3); ai_run(this, 0); }
void snowm_run1(entity this) { set_animofs(this, anim_snowman_stand, 1, snowm_run2); snowman_idlesound(this); ai_run(this, 0); }

void SnowmMelee(entity this)
{
	if(!this.enemy)
		return;
	if(this.health < 1)
		return;
	if(!this.enemy.takedamage)
		return;
		
	ai_charge(this, 10);	// + ai_face()
	if(!ai_checkmelee(this, 80, 0))
		return;

	_sound(this, CH_WEAPON_SINGLE, "xmas/snowman/claw.wav", 1, ATTN_NORM);

	// Sack attack is strong (1-60)
	float ldmg = max(1, (random() + random() + random()) * 5);
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_SNOWMAN.m_id);

	// Spawn blood at sack
	spawn_touchblood(this, ldmg*3, this.enemy);
}

//----------------------------------------------------------------------
void snowm_claw1(entity this);
void snowm_claw5(entity this)
{
	set_animofs(this, anim_snowman_claw, 5, snowm_run1);
	// Check if snowman is within range to attack again
	if(ai_checkmelee(this, 80, 0) && this.enemy.health > 0)
	{
		if(this.health > 0)
			setthink(this, snowm_claw1);
	}
}
void snowm_claw4(entity this) { set_animofs(this, anim_snowman_claw, 4, snowm_claw5); }
void snowm_claw3(entity this) { set_animofs(this, anim_snowman_claw, 3, snowm_claw4); ai_face(this); SnowmMelee(this);}
void snowm_claw2(entity this) { set_animofs(this, anim_snowman_claw, 2, snowm_claw3); ai_face(this);}
void snowm_claw1(entity this) { set_animofs(this, anim_snowman_claw, 1, snowm_claw2); ai_face(this);}

void snowman_launch_projectile(entity this, vector org, vector dir)
{
	entity newmis = launch_spike(this, org, dir);
	_setmodel(newmis, "progs/proj_ngred.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	newmis.dmg = 15;
	newmis.velocity = dir * 500;
	newmis.projectiledeathtype = DEATH_MONSTER_SNOWMAN.m_id;
}

void SnowmFireNails(entity this)
{
	if(this.health < 1)
		return;

	this.effects |= EF_MUZZLEFLASH;
	_sound(this, CH_WEAPON_SINGLE, "xmas/snowman/nail_fire.wav", 1, ATTN_NORM);

	fixedmakevectors(this.angles);
	vector org = this.origin + attack_vector('24 0 20');

	for(int j = 0; j < 5; ++j)
	{
		vector vec = (crandom() * 20) * v_right + (crandom() * 20) * v_up;
		vector dir = normalize((this.enemy.origin + vec) - org);
		snowman_launch_projectile(this, org, dir);
	}
}

//----------------------------------------------------------------------
void snowm_nail5(entity this) { set_animofs(this, anim_snowman_attack, 1, snowm_run1); ai_face(this); }
void snowm_nail4(entity this) { set_animofs(this, anim_snowman_attack, 2, snowm_nail5); }
void snowm_nail3(entity this) { set_animofs(this, anim_snowman_attack, 3, snowm_nail4); ai_face(this); SnowmFireNails(this); }
void snowm_nail2(entity this) { set_animofs(this, anim_snowman_attack, 2, snowm_nail3); ai_face(this); }
void snowm_nail1(entity this) { set_animofs(this, anim_snowman_attack, 1, snowm_nail2); ai_face(this); }

void snowm_pain4(entity this) { set_animofs(this, anim_snowman_claw, 1, snowm_run1); }
void snowm_pain3(entity this) { set_animofs(this, anim_snowman_claw, 2, snowm_pain4); }
void snowm_pain2(entity this) { set_animofs(this, anim_snowman_claw, 3, snowm_pain3); }
void snowm_pain1(entity this) { set_animofs(this, anim_snowman_claw, 4, snowm_pain2); }

void snowm_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.spawnflags & MON_SANTA_GOOD)
		return;
	if(this.pain_finished > time)
		return;
	if(random()*100 > damage)
		return;		// didn't flinch

	if(random() < 0.5)
		_sound(this, CH_VOICE, "xmas/snowman/pain1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "xmas/snowman/pain2.wav", 1, ATTN_NORM);

	if(random() < 0.5)
	{
		this.pain_finished = time + 1;
		snowm_pain1(this);
	}
	else
	{
		this.axhitme = false;
		this.pain_finished = time + 0.6;
		snowm_pain1(this);
	}
}

void snowm_explode(entity this)
{
	// Make sure gibs go flying up
	this.health = -100;

	// ID style explosion
	te_explosion(this.origin);
	T_RadiusDamage(this, this, 40, DEATH_MONSTER_SNOWMAN.m_id, NULL);
	
	// Sprite + Dust
	SpawnExplosion(EXPLODE_BIG, this.origin, "xmas/snowman/death1.wav");
	SpawnProjectileSmoke(this.origin, 200, 250, 100);
	SpawnProjectileSmoke(this.origin, 200, 250, 100);

	// No blood or guts!
	ThrowHead(this, "progs/xmas/h_snowman.mdl", this.health);
	ThrowGib(this, "progs/xmas/gib_snowclaw.mdl", this.health);
	ThrowGib(this, "progs/xmas/gib_snowgun.mdl", this.health);
	for(int j = 0; j < floor(random() * 8); ++j)
	{
		ThrowGib(this, "progs/xmas/gib_snowball.mdl", this.health);
	}
}

void snowm_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(random() < 0.5)
		_sound(this, CHAN_BODY, "xmas/snowman/death1.wav", 1, ATTN_NORM);
	else
		_sound(this, CHAN_BODY, "xmas/snowman/death2.wav", 1, ATTN_NORM);
	snowm_explode(this);
}

/*
===========
SnowmanCheckAttack

The player is in view, so decide to move or launch an attack
Returns false if movement should continue
============
*/
bool SnowmanCheckAttack(entity this)
{
	entity targ = this.enemy;

	if(MP_IMPEL)
	{
		if(this.enemy_range == RANGE_FAR)
			return false;
		if(time < this.attack_finished)
			return false;
	}

	if(ai_checkmelee(this, 80, 0))
	{
		this.attack_state = AS_MELEE;
		// As soon as out of melee, range attack!
		this.attack_finished = 0;
		return true;
	}
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, MOVE_NORMAL, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
		return false;	// don't have a clear shot
			
	
// missile attack
	if(!MP_IMPEL)
	{
		if(time < this.attack_finished)
			return false;
			
		if(this.enemy_range == RANGE_FAR)
			return false;
	}

	float chance = 0;
	if(this.enemy_range == RANGE_MELEE)
		chance = 0.9;
	else if(this.enemy_range == RANGE_NEAR)
		chance = 0.4;
	else if(this.enemy_range == RANGE_MID)
		chance = 0.05;

	if(random() < chance && this.th_missile)
	{
		this.th_missile(this);
		this.attack_finished = time + (2 + 2*random());
		return true;
	}

	return false;
}

/*======================================================================
QUAKED monster_snowman (1 0 0) (-16 -16 -24) (16 16 40) Ambush
======================================================================*/
spawnfunc(monster_xmas_snowman) { monster_start(this, true, MON_SNOWMAN); }
#endif // SVQC

#ifdef SVQC
METHOD(Snowman, mr_setup, bool(Snowman this, entity actor))
{
    TC(Snowman, this);

	precache_model("progs/xmas/gib_snowclaw.mdl");
	precache_model("progs/xmas/gib_snowgun.mdl");
	precache_model("progs/xmas/gib_snowball.mdl");

	precache_model("progs/proj_ngred.mdl");

	precache_sound("xmas/snowman/idle.wav");

	precache_sound("xmas/snowman/claw.wav");
	precache_sound("xmas/snowman/nail_fire.wav");

	precache_sound("xmas/snowman/pain1.wav");
	precache_sound("xmas/snowman/pain2.wav");
	precache_sound("xmas/snowman/death1.wav");
	precache_sound("xmas/snowman/death2.wav");

    actor.health = 125;
	actor.checkattack = SnowmanCheckAttack;
	actor.th_stand = snowm_stand1;
	actor.th_walk = snowm_walk1;
	actor.th_run = snowm_run1;
	actor.th_melee = snowm_claw1;
	actor.th_missile = snowm_nail1;
	actor.th_pain = snowm_pain;
	actor.th_die = snowm_die;

    return true;
}
METHOD(Snowman, mr_sight, bool(Snowman this, entity actor))
{
    TC(Snowman, this);

	sound(actor, CH_VOICE, SND_MON_SNOWMAN_SIGHT_RANDOM(), 1, ATTN_NORM);

    return true;
}
#endif
