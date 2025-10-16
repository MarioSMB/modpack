#include "spazmatism.qh"

#ifdef SVQC
.int bosswave;

void spaz_run1(entity this);

/*
=================
SpazmatismCheckAttack
=================
*/
bool SpazmatismCheckAttack(entity this)
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
			spaz_run1(this);
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
		if(this.attack_state != AS_SLIDING)
		{
			this.attack_state = AS_SLIDING;
			spaz_run1(this);
		}
		return false;
	}

	float chance;	
	if(this.enemy_range == RANGE_MELEE)
		chance = 0.3;
	else if(this.enemy_range == RANGE_NEAR)
		chance = 0.6;
	else if(this.enemy_range == RANGE_MID)
		chance = 0.9;
	else
		chance = 0;

	if(random() < chance)
	{
		this.attack_state = AS_MISSILE;
		return true;
	}

	if(this.enemy_range == RANGE_MID)
	{
		if(this.attack_state != AS_SLIDING)
		{
			this.attack_state = AS_SLIDING;
			spaz_run1(this);
		}
	}
	else
	{
		if(random() < 0.5)
		{
			if(this.attack_state != AS_DODGING)
			{
				this.attack_state = AS_DODGING;
				spaz_run1(this);
			}
		}
		else
		{
			if(this.attack_state != AS_SLIDING)
			{
				this.attack_state = AS_SLIDING;
				spaz_run1(this);
			}
		}
	}
	
	return false;
}

void spaz_anim(entity this, void(entity) tnk)
{
	this.walkframe += 1;
	if(this.walkframe > 3)
		this.walkframe = 0;
	this.frame = this.walkframe;
	this.nextthink = time + 0.1;
	setthink(this, tnk);
}

void spaz_movetogoal(entity this, float dist)
{
	if(StatusEffects_active(STATUSEFFECT_Slowness, this))
		dist *= 0.5;

	this.enemy_range = range(this, this.enemy);

	if(this.enemy && this.enemy_range == RANGE_MELEE && gettouch(this) && ai_checkmelee(this, 100, false))
		gettouch(this)(this, this.enemy);

	if(!t_stepdirection(this, this.ideal_yaw, dist))
	{
		settouch(this, func_null);
		setthink(this, spaz_run1);
	}
}

void spaz_stand1(entity this);
void spaz_stand6(entity this) { spaz_anim(this, spaz_stand1); ai_stand(this); }
void spaz_stand5(entity this) { spaz_anim(this, spaz_stand6); ai_stand(this); }
void spaz_stand4(entity this) { spaz_anim(this, spaz_stand5); ai_stand(this); }
void spaz_stand3(entity this) { spaz_anim(this, spaz_stand4); ai_stand(this); }
void spaz_stand2(entity this) { spaz_anim(this, spaz_stand3); ai_stand(this); }
void spaz_stand1(entity this) { spaz_anim(this, spaz_stand2); ai_stand(this); }

void spaz_walk1(entity this);
void spaz_walk6(entity this) { spaz_anim(this, spaz_walk1); ai_walk(this, 3); }
void spaz_walk5(entity this) { spaz_anim(this, spaz_walk6); ai_walk(this, 3); }
void spaz_walk4(entity this) { spaz_anim(this, spaz_walk5); ai_walk(this, 4); }
void spaz_walk3(entity this) { spaz_anim(this, spaz_walk4); ai_walk(this, 3); }
void spaz_walk2(entity this) { spaz_anim(this, spaz_walk3); ai_walk(this, 2); }
void spaz_walk1(entity this) { spaz_anim(this, spaz_walk2); ai_walk(this, 3); }

void Spaz_JumpTouch(entity this, entity toucher)
{
	if(this.health <= 0 || !this.takedamage)
		return;
	if(toucher.takedamage)
	{
		float admg = 20;
		if(this.bosswave >= 1)
			admg *= 1.5;
		float ldmg = ((random() + random()) + random()) * admg;
		T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_SPAZMATISM.m_id);
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	}
	settouch(this, func_null);
}

void gib_spaz(entity this);
void spaz_atkc6(entity this) { spaz_anim(this, spaz_run1); spaz_movetogoal(this, 5); settouch(this, func_null); }
void spaz_atkc5(entity this) { spaz_anim(this, spaz_atkc6); spaz_movetogoal(this, 10); }
void spaz_atkc4(entity this) { spaz_anim(this, spaz_atkc5); spaz_movetogoal(this, 10); }
void spaz_atkc3(entity this) { spaz_anim(this, spaz_atkc4); spaz_movetogoal(this, 10); }
void spaz_atkc2(entity this) { spaz_anim(this, spaz_atkc3); spaz_movetogoal(this, 10); }
void spaz_atkc1(entity this)
{
	spaz_anim(this, spaz_atkc2);
	if(this.health <= 0)
	{
		settouch(this, func_null);
		setthink(this, gib_spaz);
		return;
	}
	if(this.bosswave >= 1)
		sound(this, CH_VOICE, SND_MON_SPAZMATISM_SIGHT, 1, ATTN_BOSS);
	ai_face(this);
	settouch(this, Spaz_JumpTouch);
	this.attack_finished = time + 2 + (random() * 2);
}

void spaz_run1(entity this);
void spaz_atkd15(entity this) { spaz_anim(this, spaz_run1); spaz_movetogoal(this, 60); settouch(this, func_null); }
void spaz_atkd14(entity this) { spaz_anim(this, spaz_atkd15); spaz_movetogoal(this, 120); }
void spaz_atkd13(entity this) { spaz_anim(this, spaz_atkd14); spaz_movetogoal(this, 120); }
void spaz_atkd12(entity this) { spaz_anim(this, spaz_atkd13); spaz_movetogoal(this, 120); }
void spaz_atkd11(entity this) { spaz_anim(this, spaz_atkd12); spaz_movetogoal(this, 120); }
void spaz_atkd10(entity this) { spaz_anim(this, spaz_atkd11); spaz_movetogoal(this, 120); }
void spaz_atkd9(entity this) { spaz_anim(this, spaz_atkd10); spaz_movetogoal(this, 120); }
void spaz_atkd8(entity this) { spaz_anim(this, spaz_atkd9); spaz_movetogoal(this, 120); }
void spaz_atkd7(entity this) { spaz_anim(this, spaz_atkd8); spaz_movetogoal(this, 120); }
void spaz_atkd6(entity this) { spaz_anim(this, spaz_atkd7); spaz_movetogoal(this, 120); }
void spaz_atkd5(entity this) { spaz_anim(this, spaz_atkd6); }
void spaz_atkd4(entity this) { spaz_anim(this, spaz_atkd5); }
void spaz_atkd3(entity this) { spaz_anim(this, spaz_atkd4); }
void spaz_atkd2(entity this) { spaz_anim(this, spaz_atkd3); }
void spaz_atkd1(entity this)
{
	spaz_anim(this, spaz_atkd2);
	if(this.health <= 0)
	{
		settouch(this, func_null);
		setthink(this, gib_spaz);
		return;
	}
	sound(this, CH_VOICE, SND_MON_SPAZMATISM_SIGHT, 1, ATTN_BOSS);
	ai_face(this);
	settouch(this, Spaz_JumpTouch);
	this.attack_finished = time + 5 + (random() * 2);
}

void spaz_breath(entity this)
{
	if(time >= this.fly_sound)
	{
		this.fly_sound = time + 0.33;
		_sound(this, CH_WEAPON_A, "twins/cursed_flames.wav", 1, ATTN_BOSS);
	}

	fixedmakevectors(this.angles);

	vector myorg = CENTER_OR_VIEWOFS(this) - '0 0 8'; // lower slightly so it has a chance of hitting the player!
	Send_Effect(EFFECT_CURSED_FLAMEJET, myorg, v_forward * 30, 3);

	tracebox(myorg, '-10 -10 -10', '10 10 10', myorg + v_forward * 500, MOVE_NORMAL, this);

	if(trace_ent && trace_ent.takedamage && trace_ent.health > 0)
	{
		float damg = 4 + random();
		T_Damage(trace_ent, this, this, damg, DEATH_MONSTER_SPAZMATISM.m_id);

		float burntime = floor(autocvar_skill + 3 + 2*random());
		// only add more burn time if there isn't already a longer timer running!
		float curtime = StatusEffects_gettime(STATUSEFFECT_Burning, trace_ent);
		if((time + burntime) > curtime)
			StatusEffects_apply(STATUSEFFECT_Burning, trace_ent, time + burntime, 0);
	}
}

.int attack_frame;
void spaz_breath_loop(entity this)
{
	spaz_anim(this, spaz_breath_loop);
	ai_charge(this, 20);

	this.attack_frame += 1;

	if(this.attack_frame > 64)
	{
		this.yaw_speed = 20;
		setthink(this, spaz_run1);
	}
	else if(this.attack_frame > 8)
		spaz_breath(this);
}

void spaz_attack_phase2(entity this)
{
	this.state = (this.state == 1) ? 0 : 1;

	if(this.state == 1)
	{
		this.yaw_speed = 10;
		this.attack_frame = 0;
		this.attack_finished = time + 5 + (random() * 2);
		spaz_breath_loop(this);
	}
	else
		spaz_atkd1(this);
}

void spaz_spin(entity this, bool increase)
{
	if(increase)
		this.avelocity_x += 15;
	else
		this.avelocity_x -= 30;

	this.angles = this.angles + 0.1 * this.avelocity;
}

void spaz_transform(entity this)
{
	vector oldmin = this.mins;
	vector oldmax = this.maxs;
	_setmodel(this, "progs/spazmatism.mdl");
	setsize(this, oldmin, oldmax);

	sound(this, CH_VOICE, SND_MON_SPAZMATISM_SIGHT, 1, ATTN_BOSS);

	this.th_missile = spaz_attack_phase2;
	this.bosswave += 1;

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

	if(this.tether_ent)
		tether_remove(this.tether_ent);
}

void spaz_rise32(entity this) { spaz_anim(this, spaz_run1); this.avelocity = '0 0 0'; this.angles_x = 0; }
void spaz_rise31(entity this) { spaz_anim(this, spaz_rise32); spaz_spin(this, false); }
void spaz_rise30(entity this) { spaz_anim(this, spaz_rise31); spaz_spin(this, false); }
void spaz_rise29(entity this) { spaz_anim(this, spaz_rise30); spaz_spin(this, false); }
void spaz_rise28(entity this) { spaz_anim(this, spaz_rise29); spaz_spin(this, false); }
void spaz_rise27(entity this) { spaz_anim(this, spaz_rise28); spaz_transform(this); }
void spaz_rise26(entity this) { spaz_anim(this, spaz_rise27); spaz_spin(this, true); }
void spaz_rise25(entity this) { spaz_anim(this, spaz_rise26); spaz_spin(this, true); }
void spaz_rise24(entity this) { spaz_anim(this, spaz_rise25); spaz_spin(this, true); }
void spaz_rise23(entity this) { spaz_anim(this, spaz_rise24); spaz_spin(this, true); }
void spaz_rise22(entity this) { spaz_anim(this, spaz_rise23); spaz_spin(this, true); }
void spaz_rise21(entity this) { spaz_anim(this, spaz_rise22); spaz_spin(this, true); }
void spaz_rise20(entity this) { spaz_anim(this, spaz_rise21); spaz_spin(this, true); }
void spaz_rise19(entity this) { spaz_anim(this, spaz_rise20); spaz_spin(this, true); }
void spaz_rise18(entity this) { spaz_anim(this, spaz_rise19); spaz_spin(this, true); }
void spaz_rise17(entity this) { spaz_anim(this, spaz_rise18); spaz_spin(this, true); }
void spaz_rise16(entity this) { spaz_anim(this, spaz_rise17); spaz_spin(this, true); }
void spaz_rise15(entity this) { spaz_anim(this, spaz_rise16); spaz_spin(this, true); }
void spaz_rise14(entity this) { spaz_anim(this, spaz_rise15); spaz_spin(this, true); }
void spaz_rise13(entity this) { spaz_anim(this, spaz_rise14); spaz_spin(this, true); }
void spaz_rise12(entity this) { spaz_anim(this, spaz_rise13); spaz_spin(this, true); }
void spaz_rise11(entity this) { spaz_anim(this, spaz_rise12); spaz_spin(this, true); }
void spaz_rise10(entity this) { spaz_anim(this, spaz_rise11); spaz_spin(this, true); }
void spaz_rise9(entity this) { spaz_anim(this, spaz_rise10); spaz_spin(this, true); }
void spaz_rise8(entity this) { spaz_anim(this, spaz_rise9); spaz_spin(this, true); }
void spaz_rise7(entity this) { spaz_anim(this, spaz_rise8); spaz_spin(this, true); }
void spaz_rise6(entity this) { spaz_anim(this, spaz_rise7); spaz_spin(this, true); }
void spaz_rise5(entity this) { spaz_anim(this, spaz_rise6); spaz_spin(this, true); }
void spaz_rise4(entity this) { spaz_anim(this, spaz_rise5); spaz_spin(this, true); }
void spaz_rise3(entity this) { spaz_anim(this, spaz_rise4); spaz_spin(this, true); }
void spaz_rise2(entity this) { spaz_anim(this, spaz_rise3); spaz_spin(this, true); }
void spaz_rise1(entity this)
{
	spaz_anim(this, spaz_rise2);
	settouch(this, func_null);
	//this.pain_finished = time + 4;
	this.avelocity = '0 0 0';
	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, this, "progs/gib1.mdl", this.health);
	ThrowGib(this, this, "progs/bone.mdl", this.health);
}

void spaz_run6(entity this) { spaz_anim(this, spaz_run1); ai_run(this, 36); }
void spaz_run5(entity this) { spaz_anim(this, spaz_run6); ai_run(this, 35); }
void spaz_run4(entity this) { spaz_anim(this, spaz_run5); ai_run(this, 34); }
void spaz_run3(entity this) { spaz_anim(this, spaz_run4); ai_run(this, 38); }
void spaz_run2(entity this) { spaz_anim(this, spaz_run3); ai_run(this, 36); }
void spaz_run1(entity this)
{
	if(this.bosswave == 0 && this.health <= (this.max_health * 0.5))
	{
		spaz_rise1(this);
		return;
	}

	spaz_anim(this, spaz_run2);
	ai_run(this, 32);
}

void spaz_suck(entity this)
{
	if(!this.enemy)
		return;
	ai_charge(this, 0);
	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;
	float ldmg = (((random() + random()) + random()) * 10);
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_SPAZMATISM.m_id);
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
}

void spaz_atk17(entity this) { spaz_anim(this, spaz_run1); ai_charge(this, 18); }
void spaz_atk16(entity this) { spaz_anim(this, spaz_atk17); ai_charge(this, 19); spaz_suck(this); }
void spaz_atk15(entity this) { spaz_anim(this, spaz_atk16); ai_charge(this, 20); }
void spaz_atk14(entity this) { spaz_anim(this, spaz_atk15); ai_charge(this, 21); }
void spaz_atk13(entity this) { spaz_anim(this, spaz_atk14); ai_charge(this, 22); }
void spaz_atk12(entity this) { spaz_anim(this, spaz_atk13); ai_charge(this, 23); spaz_suck(this); }
void spaz_atk11(entity this) { spaz_anim(this, spaz_atk12); ai_charge(this, 24); }
void spaz_atk10(entity this) { spaz_anim(this, spaz_atk11); ai_charge(this, 25); }
void spaz_atk9(entity this) { spaz_anim(this, spaz_atk10); ai_charge(this, 26); }
void spaz_atk8(entity this) { spaz_anim(this, spaz_atk9); ai_charge(this, 27); spaz_suck(this); }
void spaz_atk7(entity this) { spaz_anim(this, spaz_atk8); ai_charge(this, 26); }
void spaz_atk6(entity this) { spaz_anim(this, spaz_atk7); ai_charge(this, 25); }
void spaz_atk5(entity this) { spaz_anim(this, spaz_atk6); ai_charge(this, 24); }
void spaz_atk4(entity this) { spaz_anim(this, spaz_atk5); ai_charge(this, 23); spaz_suck(this); }
void spaz_atk3(entity this) { spaz_anim(this, spaz_atk4); ai_charge(this, 22); }
void spaz_atk2(entity this) { spaz_anim(this, spaz_atk3); ai_charge(this, 21); }
void spaz_atk1(entity this) { spaz_anim(this, spaz_atk2); ai_charge(this, 20); spaz_suck(this); }

void cursed_flame_touch(entity this, entity toucher)
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
		float curtime = StatusEffects_gettime(STATUSEFFECT_Burning, toucher);
		if((time + slowtime) > curtime)
			StatusEffects_apply(STATUSEFFECT_Burning, toucher, time + slowtime, 0);
	}

	_sound(this, CH_WEAPON_SINGLE, "twins/cursed_flame_impact.wav", 1, ATTN_NORM);
	te_explosion2(this.origin, 55, 5);

	delete(this);
}

void spaz_cursedflame(entity this)
{
	_sound(this, CH_WEAPON_SINGLE, "twins/cursed_flame_fire.wav", 1, ATTN_BOSS);

	vector org = CENTER_OR_VIEWOFS(this);

	// lead the player on hard mode
	float pspeed = 600;
	entity targ = this.enemy;
	vector enemy_org = CENTER_OR_VIEWOFS(targ);
	vector d = enemy_org;
	if(autocvar_skill > 1)
	{
		float t = vlen(enemy_org - org) / pspeed;
		vector vec = targ.velocity;
		vec.z = 0;
		d = enemy_org + t * vec;		
	}

	vector dir = normalize(d - org);

	entity newmis = launch_spike(this, org, dir);
	newmis.dmg = 12;
	newmis.velocity = dir * pspeed;
	settouch(newmis, cursed_flame_touch);
	newmis.avelocity = '180 180 180';
	newmis.projectiledeathtype = DEATH_MONSTER_SPAZMATISM.m_id;
	_setmodel(newmis, "progs/cursedball.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
}

void spaz_atkb1(entity this) { spaz_anim(this, spaz_run1); ai_face(this); spaz_cursedflame(this); this.attack_finished = time + 2 + (random() * 2); }

void spaz_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	if(this.health <= 0)
		return;
	if(this.bosswave >= 1)
		_sound(this, CH_VOICE, "twins/hit.wav", 1, ATTN_BOSS);
	else
		_sound(this, CH_VOICE, "eoc/pain.wav", 1, ATTN_BOSS);
	this.pain_finished = time + 0.2;
}

void gib_spaz(entity this)
{
	_sound(this, CH_VOICE, "twins/explode.wav", 1, ATTN_BOSS);
	settouch(this, func_null);

	Send_Effect(EFFECT_EXPLOSION_SMALL, CENTER_OR_VIEWOFS(this), '0 0 0', 1);
	ThrowHead(this, this, "progs/rawbone.mdl", this.health);
}

void spaz_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	gib_spaz(this);
}

//spawnfunc(monster_spazmatism) { monster_start(this, true, MON_SPAZMATISM); }
#endif // SVQC

#ifdef SVQC
METHOD(Spazmatism, mr_setup, bool(Spazmatism this, entity actor))
{
    TC(Spazmatism, this);

	precache_model("progs/spazmatism.mdl");
	precache_model("progs/xtragib.mdl");
	precache_model("progs/bone.mdl");
	precache_model("progs/bone2.mdl");
	precache_model("progs/rawbone2.mdl");
	precache_sound("eoc/death.wav");
	precache_sound("eoc/pain.wav");
	precache_sound("twins/explode.wav");
	precache_sound("twins/hit.wav");
	precache_sound("twins/cursed_flames.wav");
	precache_sound("twins/cursed_flame_fire.wav");
	precache_sound("twins/cursed_flame_impact.wav");
	precache_model("progs/cursedball.mdl");

	actor.bosswave = 0;
	actor.skin = 2;

    actor.health = 3000;
	actor.th_stand = spaz_stand1;
	actor.th_walk = spaz_walk1;
	actor.th_run = spaz_run1;
	actor.th_melee = spaz_atk1;
	actor.th_missile = spaz_atkb1;
	actor.th_pain = spaz_pain;
	actor.th_die = spaz_die;

	actor.checkattack = SpazmatismCheckAttack;

    return true;
}
#endif
