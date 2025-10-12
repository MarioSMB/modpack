#include "queen_bee.qh"

#ifdef SVQC
.int qb_summonflag;

void qb_run1(entity this);

void qb_anim(entity this, void(entity) tnk)
{
	this.walkframe += 1;
	if(this.walkframe > 1)
		this.walkframe = 0;
	this.frame = this.walkframe;
	this.nextthink = time + 0.1;
	setthink(this, tnk);
}

void qb_movetogoal(entity this, float dist)
{
	if(StatusEffects_active(STATUSEFFECT_Slowness, this))
		dist *= 0.5;

	this.enemy_range = range(this, this.enemy);

	if(this.enemy && this.enemy_range == RANGE_MELEE && gettouch(this) && ai_checkmelee(this, 100, false))
		gettouch(this)(this, this.enemy);

	if(!t_stepdirection(this, this.ideal_yaw, dist))
	{
		settouch(this, func_null);
		setthink(this, qb_run1);
	}
}

void qb_stand1(entity this);
void qb_stand6(entity this) { qb_anim(this, qb_stand1); ai_stand(this); }
void qb_stand5(entity this) { qb_anim(this, qb_stand6); ai_stand(this); }
void qb_stand4(entity this) { qb_anim(this, qb_stand5); ai_stand(this); }
void qb_stand3(entity this) { qb_anim(this, qb_stand4); ai_stand(this); }
void qb_stand2(entity this) { qb_anim(this, qb_stand3); ai_stand(this); }
void qb_stand1(entity this) { qb_anim(this, qb_stand2); ai_stand(this); }

void qb_walk1(entity this);
void qb_walk6(entity this) { qb_anim(this, qb_walk1); ai_walk(this, 3); }
void qb_walk5(entity this) { qb_anim(this, qb_walk6); ai_walk(this, 3); }
void qb_walk4(entity this) { qb_anim(this, qb_walk5); ai_walk(this, 4); }
void qb_walk3(entity this) { qb_anim(this, qb_walk4); ai_walk(this, 3); }
void qb_walk2(entity this) { qb_anim(this, qb_walk3); ai_walk(this, 2); }
void qb_walk1(entity this) { qb_anim(this, qb_walk2); ai_walk(this, 3); }

void QueenBee_JumpTouch(entity this, entity toucher)
{
	if(this.health <= 0 || !this.takedamage)
		return;
	if(toucher.takedamage)
	{
		float admg = 20;
		float ldmg = ((random() + random()) + random()) * admg;
		T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_QUEEN_BEE.m_id);
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	}
	settouch(this, func_null);
}

void gib_qb(entity this);
void qb_atkc1(entity this);
void qb_atkc6(entity this) { qb_anim(this, qb_run1); qb_movetogoal(this, 5); settouch(this, func_null); if(random() < 0.5) setthink(this, qb_atkc1); }
void qb_atkc5(entity this) { qb_anim(this, qb_atkc6); qb_movetogoal(this, 10); }
void qb_atkc4(entity this) { qb_anim(this, qb_atkc5); qb_movetogoal(this, 10); }
void qb_atkc3(entity this) { qb_anim(this, qb_atkc4); qb_movetogoal(this, 10); }
void qb_atkc2(entity this) { qb_anim(this, qb_atkc3); qb_movetogoal(this, 10); }
void qb_atkc1(entity this)
{
	qb_anim(this, qb_atkc2);
	if(this.health <= 0)
	{
		settouch(this, func_null);
		setthink(this, gib_qb);
		return;
	}
	if(random() < 0.33)
		sound(this, CH_VOICE, SND_MON_QUEEN_BEE_SIGHT, 1, ATTN_BOSS);
	ai_face(this);
	settouch(this, QueenBee_JumpTouch);
	this.attack_finished = time + 2 + (random() * 2);
}

void qb_run1(entity this);
void qb_atkd15(entity this) { qb_anim(this, qb_run1); qb_movetogoal(this, 30); settouch(this, func_null); }
void qb_atkd14(entity this) { qb_anim(this, qb_atkd15); qb_movetogoal(this, 60); }
void qb_atkd13(entity this) { qb_anim(this, qb_atkd14); qb_movetogoal(this, 60); }
void qb_atkd12(entity this) { qb_anim(this, qb_atkd13); qb_movetogoal(this, 60); }
void qb_atkd11(entity this) { qb_anim(this, qb_atkd12); qb_movetogoal(this, 60); }
void qb_atkd10(entity this) { qb_anim(this, qb_atkd11); qb_movetogoal(this, 60); }
void qb_atkd9(entity this) { qb_anim(this, qb_atkd10); qb_movetogoal(this, 60); }
void qb_atkd8(entity this) { qb_anim(this, qb_atkd9); qb_movetogoal(this, 60); }
void qb_atkd7(entity this) { qb_anim(this, qb_atkd8); qb_movetogoal(this, 60); }
void qb_atkd6(entity this) { qb_anim(this, qb_atkd7); qb_movetogoal(this, 60); }
void qb_atkd5(entity this) { qb_anim(this, qb_atkd6); }
void qb_atkd4(entity this) { qb_anim(this, qb_atkd5); }
void qb_atkd3(entity this) { qb_anim(this, qb_atkd4); }
void qb_atkd2(entity this) { qb_anim(this, qb_atkd3); }
void qb_atkd1(entity this)
{
	qb_anim(this, qb_atkd2);
	if(this.health <= 0)
	{
		settouch(this, func_null);
		setthink(this, gib_qb);
		return;
	}
	//sound(this, CH_VOICE, SND_MON_QUEEN_BEE_SIGHT, 1, ATTN_BOSS);
	ai_face(this);
	settouch(this, QueenBee_JumpTouch);
	this.attack_finished = time + 2 + (random() * 2);
}

void qb_run6(entity this) { qb_anim(this, qb_run1); ai_run(this, 20); }
void qb_run5(entity this) { qb_anim(this, qb_run6); ai_run(this, 24); }
void qb_run4(entity this) { qb_anim(this, qb_run5); ai_run(this, 22); }
void qb_run3(entity this) { qb_anim(this, qb_run4); ai_run(this, 24); }
void qb_run2(entity this) { qb_anim(this, qb_run3); ai_run(this, 20); }
void qb_run1(entity this)
{
	qb_anim(this, qb_run2);
	if(random() < 0.2)
	{
		qb_atkd1(this);
		return;
	}
	if(random() < 0.3)
	{
		qb_atkc1(this);
		return;
	}
	ai_run(this, 16);
}

void qb_suck(entity this)
{
	if(!this.enemy)
		return;
	ai_charge(this, 0);
	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;
	float ldmg = (((random() + random()) + random()) * 10);
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_QUEEN_BEE.m_id);
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
}

void qb_atk17(entity this) { qb_anim(this, qb_run1); ai_charge(this, 18); }
void qb_atk16(entity this) { qb_anim(this, qb_atk17); ai_charge(this, 19); qb_suck(this); }
void qb_atk15(entity this) { qb_anim(this, qb_atk16); ai_charge(this, 20); }
void qb_atk14(entity this) { qb_anim(this, qb_atk15); ai_charge(this, 21); }
void qb_atk13(entity this) { qb_anim(this, qb_atk14); ai_charge(this, 22); }
void qb_atk12(entity this) { qb_anim(this, qb_atk13); ai_charge(this, 23); qb_suck(this); }
void qb_atk11(entity this) { qb_anim(this, qb_atk12); ai_charge(this, 24); }
void qb_atk10(entity this) { qb_anim(this, qb_atk11); ai_charge(this, 25); }
void qb_atk9(entity this) { qb_anim(this, qb_atk10); ai_charge(this, 26); }
void qb_atk8(entity this) { qb_anim(this, qb_atk9); ai_charge(this, 27); qb_suck(this); }
void qb_atk7(entity this) { qb_anim(this, qb_atk8); ai_charge(this, 26); }
void qb_atk6(entity this) { qb_anim(this, qb_atk7); ai_charge(this, 25); }
void qb_atk5(entity this) { qb_anim(this, qb_atk6); ai_charge(this, 24); }
void qb_atk4(entity this) { qb_anim(this, qb_atk5); ai_charge(this, 23); qb_suck(this); }
void qb_atk3(entity this) { qb_anim(this, qb_atk4); ai_charge(this, 22); }
void qb_atk2(entity this) { qb_anim(this, qb_atk3); ai_charge(this, 21); }
void qb_atk1(entity this) { qb_anim(this, qb_atk2); ai_charge(this, 20); qb_suck(this); }

void QueenBeeFireBaby(entity this)
{
	if(query_minionactive(this) <= 0)
		return;

	makevectors(this.angles);
	vector org = CENTER_OR_VIEWOFS(this) + v_forward * 64 + v_up * -48;
	this.qb_summonflag = find_minionspace(org);
	
	// If the spawn locaiton all clear, spawn something!
	if(this.qb_summonflag)
	{
		_sound(this, CH_VOICE, "queen_bee/stinger_attack.wav", 1, ATTN_BOSS);

		entity pet = minion_spawn(this, org, new(monster), MON_BEE);
		pet.velocity = v_forward * (random() * 400) + randomvec() * 70;
		pet.angles = this.angles;
	}
}

void qb_atkb10(entity this) { qb_anim(this, qb_run1); ai_face(this); QueenBeeFireBaby(this); }
void qb_atkb9(entity this) { qb_anim(this, qb_atkb10); ai_face(this); QueenBeeFireBaby(this); }
void qb_atkb8(entity this) { qb_anim(this, qb_atkb9); ai_face(this); QueenBeeFireBaby(this); }
void qb_atkb7(entity this) { qb_anim(this, qb_atkb8); ai_face(this); QueenBeeFireBaby(this); }
void qb_atkb6(entity this) { qb_anim(this, qb_atkb7); ai_face(this); QueenBeeFireBaby(this); }
void qb_atkb5(entity this) { qb_anim(this, qb_atkb6); ai_face(this); QueenBeeFireBaby(this); }
void qb_atkb4(entity this) { qb_anim(this, qb_atkb5); ai_face(this); QueenBeeFireBaby(this); }
void qb_atkb3(entity this) { qb_anim(this, qb_atkb4); ai_face(this); QueenBeeFireBaby(this); }
void qb_atkb2(entity this) { qb_anim(this, qb_atkb3); ai_face(this); }
void qb_atkb1(entity this) { qb_anim(this, qb_atkb2); ai_face(this); }

void QueenBee_Stinger(entity this)
{
	_sound(this, CH_WEAPON_SINGLE, "queen_bee/stinger_attack.wav", 1, ATTN_BOSS);

	vector dir = normalize(this.enemy.origin - this.origin);
	vector spread = '0.1 0.1 0';
	dir += (crandom() * spread.x) * v_right + (crandom() * spread.y) * v_up;

	entity missile = launch_spike(this, this.origin, dir);
	missile.modelflags = MF_GRENADE;
	missile.poisonous = true;
	missile.projectiledeathtype = DEATH_MONSTER_QUEEN_BEE.m_id;
}

void qb_atka10(entity this) { qb_anim(this, qb_run1); ai_face(this); }
void qb_atka9(entity this) { qb_anim(this, qb_atka10); ai_face(this); QueenBee_Stinger(this); }
void qb_atka8(entity this) { qb_anim(this, qb_atka9); ai_face(this); }
void qb_atka7(entity this) { qb_anim(this, qb_atka8); ai_face(this); QueenBee_Stinger(this); }
void qb_atka6(entity this) { qb_anim(this, qb_atka7); ai_face(this); }
void qb_atka5(entity this) { qb_anim(this, qb_atka6); ai_face(this); QueenBee_Stinger(this); }
void qb_atka4(entity this) { qb_anim(this, qb_atka5); ai_face(this); }
void qb_atka3(entity this) { qb_anim(this, qb_atka4); ai_face(this); QueenBee_Stinger(this); }
void qb_atka2(entity this) { qb_anim(this, qb_atka3); ai_face(this); }
void qb_atka1(entity this) { qb_anim(this, qb_atka2); ai_face(this); }

void qb_attack(entity this)
{
	if(random() < 0.5)
		qb_atkb1(this);
	else
		qb_atka1(this);
}

void qb_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	if(this.health <= 0)
		return;
	_sound(this, CH_VOICE, "queen_bee/pain.wav", 1, ATTN_BOSS);
	this.pain_finished = time + 0.2;
}

void gib_qb(entity this)
{
	_sound(this, CH_VOICE, "queen_bee/death.wav", 1, ATTN_BOSS);
	settouch(this, func_null);

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

void qb_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	gib_qb(this);
}

spawnfunc(monster_queen_bee) { monster_start(this, true, MON_QUEEN_BEE); }
#endif // SVQC

#ifdef SVQC
METHOD(QueenBee, mr_setup, bool(QueenBee this, entity actor))
{
	TC(QueenBee, this);

	precache_model("progs/xtragib.mdl");
	precache_model("progs/bone.mdl");
	precache_model("progs/bone2.mdl");
	precache_model("progs/rawbone2.mdl");
	precache_sound("queen_bee/death.wav");
	precache_sound("queen_bee/pain.wav");
	precache_sound("queen_bee/stinger_attack.wav");

	if(!actor.minion_maxcount)
		actor.minion_maxcount = 16;

	actor.poisonous = true;

	actor.health = 3640;
	actor.th_stand = qb_stand1;
	actor.th_walk = qb_walk1;
	actor.th_run = qb_run1;
	actor.th_melee = qb_atk1;
	actor.th_missile = qb_attack;
	actor.th_pain = qb_pain;
	actor.th_die = qb_die;

	return true;
}
#endif
