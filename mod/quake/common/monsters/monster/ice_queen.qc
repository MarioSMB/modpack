#include "ice_queen.qh"

#ifdef SVQC
const int anim_ice_queen = 0;

void ice_queen_run1(entity this);
void ice_queen_side1(entity this);

/*
=================
IceQueenCheckAttack
=================
*/
bool IceQueenCheckAttack(entity this)
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
			ice_queen_run1(this);
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
		if(this.attack_state != AS_DODGING)
		{
			this.attack_state = AS_DODGING;
			ice_queen_run1(this);
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
		if(this.attack_state != AS_DODGING)
		{
			this.attack_state = AS_DODGING;
			ice_queen_run1(this);
		}
	}
	else
	{
		if(this.health <= (this.max_health * 0.5))
		{
			if(this.attack_state != AS_DODGING)
			{
				this.attack_state = AS_DODGING;
				ice_queen_side1(this);
			}
		}
		else
		{
			if(this.attack_state != AS_SLIDING)
			{
				this.attack_state = AS_SLIDING;
				ice_queen_side1(this);
			}
		}
	}
	
	return false;
}

/*
=================
IceQueenAttackFinished
=================
*/
void IceQueen_Missile(entity this);
void IceQueenAttackFinished(entity this)
{
	if(this.enemy_range >= RANGE_MID || !this.enemy_visible)
	{
		this.attack_state = AS_DODGING;
		setthink(this, ice_queen_run1);
	}
	else
	{
		this.attack_state = AS_SLIDING;
		setthink(this, ice_queen_side1);
	}
}

/*
==============================================================================

FAST ATTACKS

==============================================================================
*/

void frost_touch(entity this, entity toucher)
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
		float damg = ((this.dmg) ? this.dmg : 9);
		spawn_touchblood(this, damg, toucher);
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);

		float slowtime = floor(autocvar_skill + 3 + 2*random());
		// only add more burn time if there isn't already a longer timer running!
		float curtime = StatusEffects_gettime(STATUSEFFECT_Slowness, toucher);
		if((time + slowtime) > curtime)
			StatusEffects_apply(STATUSEFFECT_Slowness, toucher, time + slowtime, 0);
	}

	_sound(this, CH_WEAPON_SINGLE, "ice_queen/frostshard_impact.wav", 1, ATTN_NORM);
	//te_explosion2(this.origin, 244, 3);
	particle(this.origin, '0 0 0', 40, 10);

	delete(this);
}

void IceQueen_FrostWave(entity this, float offset)
{
	_sound(this, CH_WEAPON_SINGLE, "ice_queen/frostwave_fire.wav", 1, ATTN_BOSS);
	fixedmakevectors(this.angles);

	vector org = this.origin + v_up * 100 + v_right * offset;
	vector dir = normalize(this.enemy.origin - org);

	entity newmis = launch_spike(this, org, dir);
	newmis.angles = vectoangles(newmis.velocity);
	settouch(newmis, frost_touch);
	newmis.dmg = 15;
	newmis.angles_x -= 45; // sprites TODO: something bizarre is going on with their angling!
	newmis.projectiledeathtype = DEATH_MONSTER_ICE_QUEEN.m_id;
	_setmodel(newmis, "progs/s_frostwave.spr");
	setsize(newmis, '0 0 0', '0 0 0');
	newmis.effects |= EF_DOUBLESIDED;
}

void ice_shard_think(entity this)
{
	if(time >= this.count)
	{
		delete(this);
		return;
	}

	this.frame += 1;
	if(this.frame > 5)
		this.frame = 0;
}

void IceQueen_IceShard(entity this, vector org, vector dir, vector vel)
{
	//_sound(this, CH_WEAPON_SINGLE, "ice_queen/frostwave_fire.wav", 1, ATTN_BOSS);

	entity newmis = launch_spike(this, org, dir);
	newmis.velocity = vel; // gravity handles it mostly
	newmis.avelocity = '0 0 0';
	newmis.dmg = 9;
	settouch(newmis, frost_touch);
	set_movetype(newmis, MOVETYPE_TOSS);
	newmis.angles = vectoangles(newmis.velocity);
	newmis.projectiledeathtype = DEATH_MONSTER_ICE_QUEEN.m_id;
	_setmodel(newmis, "progs/ice_queen_frostshard.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	setthink(newmis, ice_shard_think);
	newmis.nextthink = time + 0.1;
	newmis.count = time + 7;
	newmis.noise = "ice_queen/frostshard_impact.wav";
}

void ice_queen_stand1(entity this) { set_anim(this, anim_ice_queen, ice_queen_stand1); ai_stand(this); }

void ice_queen_walk1(entity this) { set_anim(this, anim_ice_queen, ice_queen_walk1); ai_walk(this, 8); }

void ice_queen_side1(entity this) { set_anim(this, anim_ice_queen, ice_queen_side1); ai_run(this, 8); }

void ice_queen_run1(entity this) { set_anim(this, anim_ice_queen, ice_queen_run1); ai_run(this, 16); }

void ice_queen_slide(entity this, float dist)
{
	//this.enemy_range = range(this, this.enemy);
	this.enemy_yaw = vectoyaw(this.enemy.origin - this.origin);
	ai_run_slide(this, dist);
}

void ice_queen_wave11(entity this) { set_anim(this, 11, ice_queen_run1); ai_face(this); IceQueenAttackFinished(this); }
void ice_queen_wave10(entity this) { set_anim(this, 10, ice_queen_wave11); ice_queen_slide(this, 20); IceQueen_FrostWave(this, -24); }
void ice_queen_wave9(entity this) { set_anim(this, 9, ice_queen_wave10); ice_queen_slide(this, 20); }
void ice_queen_wave8(entity this) { set_anim(this, 8, ice_queen_wave9); ice_queen_slide(this, 20); IceQueen_FrostWave(this, -24); }
void ice_queen_wave7(entity this) { set_anim(this, 7, ice_queen_wave8); ice_queen_slide(this, 20); }
void ice_queen_wave6(entity this) { set_anim(this, 6, ice_queen_wave7); ice_queen_slide(this, 20); }
void ice_queen_wave5(entity this) { set_anim(this, 5, ice_queen_wave6); ice_queen_slide(this, 20); IceQueen_FrostWave(this, 24);  }
void ice_queen_wave4(entity this) { set_anim(this, 4, ice_queen_wave5); ice_queen_slide(this, 20); }
void ice_queen_wave3(entity this) { set_anim(this, 3, ice_queen_wave4); ice_queen_slide(this, 20); IceQueen_FrostWave(this, 24); }
void ice_queen_wave2(entity this) { set_anim(this, 2, ice_queen_wave3); ice_queen_slide(this, 20); }
void ice_queen_wave1(entity this) { set_anim(this, 1, ice_queen_wave2); ai_face(this); }

void ice_queen_shard1(entity this)
{
	set_anim(this, 0, ice_queen_shard1);
	this.frame = (random() < 0.5) ? 0 : 11;

	if(random() > 0.5)
	{
		vector org = this.origin + randomvec() * 16;
		vector dir = '0 0 -1';
		IceQueen_IceShard(this, org, dir, dir * 5);
	}

	this.walkframe += 1;
	if(this.walkframe > 64)
	{
		setthink(this, ice_queen_run1);
		IceQueenAttackFinished(this);
	}

	ai_charge(this, 20);
}

void ice_queen_spin1(entity this)
{
	set_anim(this, 0, ice_queen_spin1);
	if(time >= this.attack_finished)
	{
		this.attack_finished = time + 2 + (random() * 2);
		setthink(this, ice_queen_run1);
		this.frame = 12;
		return;
	}

	this.walkframe += 1;
	if(this.walkframe > 20)
		this.walkframe = 13;
	this.frame = this.walkframe;

	vector myorg = this.origin + '0 0 70';

	for(int j = 0; j < 7; ++j)
	{
		vector org = myorg + ('0 0 1' * (random() * 32));
		vector dir = normalize(randomvec() * 1000);
		vector vel = dir * 700;
		vel.z = bound(-100, vel.z, 100);
		IceQueen_IceShard(this, org, dir, vel);
	}
}

void ice_queen_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CH_VOICE, "ice_queen/death.wav", 1, ATTN_BOSS);
	
	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, this, "progs/gib1.mdl", this.health);
	ThrowGib(this, this, "progs/bone.mdl", this.health);
	ThrowGib(this, this, "progs/gib2.mdl", this.health);
	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, this, "progs/bone2.mdl", this.health);
	ThrowGib(this, this, "progs/gib1.mdl", this.health);
	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, this, "progs/gib2.mdl", this.health);
	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, this, "progs/rawbone.mdl", this.health);
	ThrowGib(this, this, "progs/gib3.mdl", this.health);
	ThrowHead(this, this, "progs/rawbone.mdl", this.health);
}

void IceQueen_Pain(entity this, entity attacker, float damage, int deathtype)
{
	if(time < this.pain_finished)
		return;
	this.pain_finished = time + 0.2;
	_sound(this, CH_VOICE, "ice_queen/pain.wav", 1, ATTN_BOSS);
}

void IceQueen_Missile(entity this)
{
	this.attack_finished = time + 2 + (2 * random());
	this.walkframe = 0;

	if(random() < 0.3)
	{
		this.attack_finished = time + 3 + (random() * 3);
		this.walkframe = 13;
		ice_queen_spin1(this);
	}
	else if(random() < 0.6)
		ice_queen_wave1(this);
	else
	{
		this.attack_finished = time + 5 + (2 * random());
		ice_queen_shard1(this);
	}
}

/*QUAKED monster_ice_queen(1 0 0)(-24 -24 -24)(24 24 128) Ambush
*/
spawnfunc(monster_ice_queen) { monster_start(this, true, MON_ICE_QUEEN); }
#endif // SVQC

#ifdef SVQC
METHOD(IceQueen, mr_setup, bool(IceQueen this, entity actor))
{
    TC(IceQueen, this);

	precache_model("progs/s_frostwave.spr");
	precache_model("progs/ice_queen_frostshard.mdl");
	precache_sound("ice_queen/frostwave_fire.wav");
	precache_sound("ice_queen/frostshard_impact.wav");
	precache_sound("ice_queen/death.wav");
	precache_sound("ice_queen/pain.wav");

    actor.health = 2200;
    actor.th_stand = ice_queen_stand1;
	actor.th_walk = ice_queen_walk1;
	actor.th_run = ice_queen_run1;
	actor.th_missile = IceQueen_Missile;
	actor.th_pain = IceQueen_Pain;
	actor.th_die = ice_queen_die;

	actor.checkattack = IceQueenCheckAttack;

    return true;
}
#endif
