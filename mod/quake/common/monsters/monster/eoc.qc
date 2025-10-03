#include "eoc.qh"

#ifdef SVQC
.int eoc_summonflag;

.int bosswave;

void eoc_run1(entity this);

void eoc_anim(entity this, void(entity) tnk)
{
	this.walkframe += 1;
	if(this.walkframe > 3)
		this.walkframe = 0;
	this.frame = this.walkframe;
	this.nextthink = time + 0.1;
	setthink(this, tnk);
}

void eoc_movetogoal(entity this, float dist)
{
	if(StatusEffects_active(STATUSEFFECT_Slowness, this))
		dist *= 0.5;

	this.enemy_range = range(this, this.enemy);

	if(this.enemy && this.enemy_range == RANGE_MELEE && gettouch(this) && ai_checkmelee(this, 100, false))
		gettouch(this)(this, this.enemy);

	if(!t_stepdirection(this, this.ideal_yaw, dist))
	{
		settouch(this, func_null);
		setthink(this, eoc_run1);
	}
}

void eoc_stand1(entity this);
void eoc_stand6(entity this) { eoc_anim(this, eoc_stand1); ai_stand(this); }
void eoc_stand5(entity this) { eoc_anim(this, eoc_stand6); ai_stand(this); }
void eoc_stand4(entity this) { eoc_anim(this, eoc_stand5); ai_stand(this); }
void eoc_stand3(entity this) { eoc_anim(this, eoc_stand4); ai_stand(this); }
void eoc_stand2(entity this) { eoc_anim(this, eoc_stand3); ai_stand(this); }
void eoc_stand1(entity this) { eoc_anim(this, eoc_stand2); ai_stand(this); }

void eoc_walk1(entity this);
void eoc_walk6(entity this) { eoc_anim(this, eoc_walk1); ai_walk(this, 3); }
void eoc_walk5(entity this) { eoc_anim(this, eoc_walk6); ai_walk(this, 3); }
void eoc_walk4(entity this) { eoc_anim(this, eoc_walk5); ai_walk(this, 4); }
void eoc_walk3(entity this) { eoc_anim(this, eoc_walk4); ai_walk(this, 3); }
void eoc_walk2(entity this) { eoc_anim(this, eoc_walk3); ai_walk(this, 2); }
void eoc_walk1(entity this) { eoc_anim(this, eoc_walk2); ai_walk(this, 3); }

void EOC_JumpTouch(entity this, entity toucher)
{
	if(this.health <= 0 || !this.takedamage)
		return;
	if(toucher.takedamage)
	{
		float admg = 20;
		if(this.bosswave >= 1)
			admg *= 1.5;
		float ldmg = ((random() + random()) + random()) * admg;
		T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_EOC.m_id);
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	}
	settouch(this, func_null);
}

void gib_eoc(entity this);
void eoc_atkc6(entity this) { eoc_anim(this, eoc_run1); eoc_movetogoal(this, 5); settouch(this, func_null); }
void eoc_atkc5(entity this) { eoc_anim(this, eoc_atkc6); eoc_movetogoal(this, 10); }
void eoc_atkc4(entity this) { eoc_anim(this, eoc_atkc5); eoc_movetogoal(this, 10); }
void eoc_atkc3(entity this) { eoc_anim(this, eoc_atkc4); eoc_movetogoal(this, 10); }
void eoc_atkc2(entity this) { eoc_anim(this, eoc_atkc3); eoc_movetogoal(this, 10); }
void eoc_atkc1(entity this)
{
	eoc_anim(this, eoc_atkc2);
	if(this.health <= 0)
	{
		settouch(this, func_null);
		setthink(this, gib_eoc);
		return;
	}
	if(this.bosswave >= 1)
		sound(this, CH_VOICE, SND_MON_EOC_SIGHT, 1, ATTN_NORM);
	ai_face(this);
	settouch(this, EOC_JumpTouch);
	this.attack_finished = time + 2 + (random() * 2);
}

void eoc_run1(entity this);
void eoc_atkd15(entity this) { eoc_anim(this, eoc_run1); eoc_movetogoal(this, 30); settouch(this, func_null); }
void eoc_atkd14(entity this) { eoc_anim(this, eoc_atkd15); eoc_movetogoal(this, 60); }
void eoc_atkd13(entity this) { eoc_anim(this, eoc_atkd14); eoc_movetogoal(this, 60); }
void eoc_atkd12(entity this) { eoc_anim(this, eoc_atkd13); eoc_movetogoal(this, 60); }
void eoc_atkd11(entity this) { eoc_anim(this, eoc_atkd12); eoc_movetogoal(this, 60); }
void eoc_atkd10(entity this) { eoc_anim(this, eoc_atkd11); eoc_movetogoal(this, 60); }
void eoc_atkd9(entity this) { eoc_anim(this, eoc_atkd10); eoc_movetogoal(this, 60); }
void eoc_atkd8(entity this) { eoc_anim(this, eoc_atkd9); eoc_movetogoal(this, 60); }
void eoc_atkd7(entity this) { eoc_anim(this, eoc_atkd8); eoc_movetogoal(this, 60); }
void eoc_atkd6(entity this) { eoc_anim(this, eoc_atkd7); eoc_movetogoal(this, 60); }
void eoc_atkd5(entity this) { eoc_anim(this, eoc_atkd6); }
void eoc_atkd4(entity this) { eoc_anim(this, eoc_atkd5); }
void eoc_atkd3(entity this) { eoc_anim(this, eoc_atkd4); }
void eoc_atkd2(entity this) { eoc_anim(this, eoc_atkd3); }
void eoc_atkd1(entity this)
{
	eoc_anim(this, eoc_atkd2);
	if(this.health <= 0)
	{
		settouch(this, func_null);
		setthink(this, gib_eoc);
		return;
	}
	if(this.bosswave >= 1)
		sound(this, CH_VOICE, SND_MON_EOC_SIGHT, 1, ATTN_NORM);
	ai_face(this);
	settouch(this, EOC_JumpTouch);
	this.attack_finished = time + 2 + (random() * 2);
}

void eoc_spin(entity this, bool increase)
{
	if(increase)
		this.avelocity_x += 15;
	else
		this.avelocity_x -= 30;

	this.angles = this.angles + 0.1 * this.avelocity;
}

void eoc_transform(entity this)
{
	vector oldmin = this.mins;
	vector oldmax = this.maxs;
	_setmodel(this, "progs/eoc_p2.mdl");
	setsize(this, oldmin, oldmax);

	sound(this, CH_VOICE, SND_MON_EOC_SIGHT, 1, ATTN_NORM);

	this.th_missile = eoc_atkd1; // no more minions!
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
}

void eoc_rise32(entity this) { eoc_anim(this, eoc_run1); this.avelocity = '0 0 0'; this.angles_x = 0; }
void eoc_rise31(entity this) { eoc_anim(this, eoc_rise32); eoc_spin(this, false); }
void eoc_rise30(entity this) { eoc_anim(this, eoc_rise31); eoc_spin(this, false); }
void eoc_rise29(entity this) { eoc_anim(this, eoc_rise30); eoc_spin(this, false); }
void eoc_rise28(entity this) { eoc_anim(this, eoc_rise29); eoc_spin(this, false); }
void eoc_rise27(entity this) { eoc_anim(this, eoc_rise28); eoc_transform(this); }
void eoc_rise26(entity this) { eoc_anim(this, eoc_rise27); eoc_spin(this, true); }
void eoc_rise25(entity this) { eoc_anim(this, eoc_rise26); eoc_spin(this, true); }
void eoc_rise24(entity this) { eoc_anim(this, eoc_rise25); eoc_spin(this, true); }
void eoc_rise23(entity this) { eoc_anim(this, eoc_rise24); eoc_spin(this, true); }
void eoc_rise22(entity this) { eoc_anim(this, eoc_rise23); eoc_spin(this, true); }
void eoc_rise21(entity this) { eoc_anim(this, eoc_rise22); eoc_spin(this, true); }
void eoc_rise20(entity this) { eoc_anim(this, eoc_rise21); eoc_spin(this, true); }
void eoc_rise19(entity this) { eoc_anim(this, eoc_rise20); eoc_spin(this, true); }
void eoc_rise18(entity this) { eoc_anim(this, eoc_rise19); eoc_spin(this, true); }
void eoc_rise17(entity this) { eoc_anim(this, eoc_rise18); eoc_spin(this, true); }
void eoc_rise16(entity this) { eoc_anim(this, eoc_rise17); eoc_spin(this, true); }
void eoc_rise15(entity this) { eoc_anim(this, eoc_rise16); eoc_spin(this, true); }
void eoc_rise14(entity this) { eoc_anim(this, eoc_rise15); eoc_spin(this, true); }
void eoc_rise13(entity this) { eoc_anim(this, eoc_rise14); eoc_spin(this, true); }
void eoc_rise12(entity this) { eoc_anim(this, eoc_rise13); eoc_spin(this, true); }
void eoc_rise11(entity this) { eoc_anim(this, eoc_rise12); eoc_spin(this, true); }
void eoc_rise10(entity this) { eoc_anim(this, eoc_rise11); eoc_spin(this, true); }
void eoc_rise9(entity this) { eoc_anim(this, eoc_rise10); eoc_spin(this, true); }
void eoc_rise8(entity this) { eoc_anim(this, eoc_rise9); eoc_spin(this, true); }
void eoc_rise7(entity this) { eoc_anim(this, eoc_rise8); eoc_spin(this, true); }
void eoc_rise6(entity this) { eoc_anim(this, eoc_rise7); eoc_spin(this, true); }
void eoc_rise5(entity this) { eoc_anim(this, eoc_rise6); eoc_spin(this, true); }
void eoc_rise4(entity this) { eoc_anim(this, eoc_rise5); eoc_spin(this, true); }
void eoc_rise3(entity this) { eoc_anim(this, eoc_rise4); eoc_spin(this, true); }
void eoc_rise2(entity this) { eoc_anim(this, eoc_rise3); eoc_spin(this, true); }
void eoc_rise1(entity this)
{
	eoc_anim(this, eoc_rise2);
	settouch(this, func_null);
	this.pain_finished = time + 4;
	this.avelocity = '0 0 0';
	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, this, "progs/gib1.mdl", this.health);
	ThrowGib(this, this, "progs/bone.mdl", this.health);
}

void eoc_run6(entity this) { eoc_anim(this, eoc_run1); ai_run(this, 20); }
void eoc_run5(entity this) { eoc_anim(this, eoc_run6); ai_run(this, 24); }
void eoc_run4(entity this) { eoc_anim(this, eoc_run5); ai_run(this, 22); }
void eoc_run3(entity this) { eoc_anim(this, eoc_run4); ai_run(this, 24); }
void eoc_run2(entity this) { eoc_anim(this, eoc_run3); ai_run(this, 20); }
void eoc_run1(entity this)
{
	if(this.bosswave == 0 && this.health <= (this.max_health * 0.5))
	{
		eoc_rise1(this);
		return;
	}

	eoc_anim(this, eoc_run2);
	if(random() < 0.2)
	{
		eoc_atkd1(this);
		return;
	}
	if(random() < 0.3)
	{
		eoc_atkc1(this);
		return;
	}
	ai_run(this, 16);
}

void eoc_suck(entity this)
{
	if(!this.enemy)
		return;
	ai_charge(this, 0);
	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;
	float ldmg = (((random() + random()) + random()) * 10);
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_EOC.m_id);
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
}

void eoc_atk17(entity this) { eoc_anim(this, eoc_run1); ai_charge(this, 18); }
void eoc_atk16(entity this) { eoc_anim(this, eoc_atk17); ai_charge(this, 19); eoc_suck(this); }
void eoc_atk15(entity this) { eoc_anim(this, eoc_atk16); ai_charge(this, 20); }
void eoc_atk14(entity this) { eoc_anim(this, eoc_atk15); ai_charge(this, 21); }
void eoc_atk13(entity this) { eoc_anim(this, eoc_atk14); ai_charge(this, 22); }
void eoc_atk12(entity this) { eoc_anim(this, eoc_atk13); ai_charge(this, 23); eoc_suck(this); }
void eoc_atk11(entity this) { eoc_anim(this, eoc_atk12); ai_charge(this, 24); }
void eoc_atk10(entity this) { eoc_anim(this, eoc_atk11); ai_charge(this, 25); }
void eoc_atk9(entity this) { eoc_anim(this, eoc_atk10); ai_charge(this, 26); }
void eoc_atk8(entity this) { eoc_anim(this, eoc_atk9); ai_charge(this, 27); eoc_suck(this); }
void eoc_atk7(entity this) { eoc_anim(this, eoc_atk8); ai_charge(this, 26); }
void eoc_atk6(entity this) { eoc_anim(this, eoc_atk7); ai_charge(this, 25); }
void eoc_atk5(entity this) { eoc_anim(this, eoc_atk6); ai_charge(this, 24); }
void eoc_atk4(entity this) { eoc_anim(this, eoc_atk5); ai_charge(this, 23); eoc_suck(this); }
void eoc_atk3(entity this) { eoc_anim(this, eoc_atk4); ai_charge(this, 22); }
void eoc_atk2(entity this) { eoc_anim(this, eoc_atk3); ai_charge(this, 21); }
void eoc_atk1(entity this) { eoc_anim(this, eoc_atk2); ai_charge(this, 20); eoc_suck(this); }

void EOCFireBaby(entity this)
{
	if(query_minionactive(this) <= 0)
		return;

	makevectors(this.angles);
	vector org = CENTER_OR_VIEWOFS(this) + v_forward * 64;
	this.eoc_summonflag = find_minionspace(org);
	
	// If the spawn locaiton all clear, spawn something!
	if(this.eoc_summonflag)
	{
		_sound(this, CH_VOICE, "eoc/spit.wav", 1, ATTN_NORM);

		// special "servant" variant of demon eye
		entity pet = minion_spawn(this, org, new(monster), MON_DEMON_EYE);
		pet.velocity = v_forward * (random() * 400) + randomvec() * 70;
		pet.angles = this.angles;
		pet.health = min(pet.health, 10);
		pet.max_health = pet.health;
		pet.skin = 5; // unique servant skin
		pet.scale = 0.5;
		setsize(pet, pet.mins * pet.scale, pet.maxs * pet.scale);
	}
}

void eoc_atkb10(entity this) { eoc_anim(this, eoc_run1); ai_face(this); }
void eoc_atkb9(entity this) { eoc_anim(this, eoc_atkb10); ai_face(this); EOCFireBaby(this); }
void eoc_atkb8(entity this) { eoc_anim(this, eoc_atkb9); ai_face(this); }
void eoc_atkb7(entity this) { eoc_anim(this, eoc_atkb8); ai_face(this); }
void eoc_atkb6(entity this) { eoc_anim(this, eoc_atkb7); ai_face(this); EOCFireBaby(this); }
void eoc_atkb5(entity this) { eoc_anim(this, eoc_atkb6); ai_face(this); }
void eoc_atkb4(entity this) { eoc_anim(this, eoc_atkb5); ai_face(this); }
void eoc_atkb3(entity this) { eoc_anim(this, eoc_atkb4); ai_face(this); EOCFireBaby(this); }
void eoc_atkb2(entity this) { eoc_anim(this, eoc_atkb3); ai_face(this); }
void eoc_atkb1(entity this) { eoc_anim(this, eoc_atkb2); ai_face(this); }

void eoc_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	if(this.health <= 0)
		return;
	_sound(this, CH_VOICE, "eoc/pain.wav", 1, ATTN_NORM);
	this.pain_finished = time + 0.2;
}

void gib_eoc(entity this)
{
	_sound(this, CH_VOICE, "eoc/death.wav", 1, ATTN_NORM);
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

void eoc_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	gib_eoc(this);
}

spawnfunc(monster_eoc) { monster_start(this, true, MON_EOC); }
#endif // SVQC

#ifdef SVQC
METHOD(EyeOfCthulhu, mr_setup, bool(EyeOfCthulhu this, entity actor))
{
    TC(EyeOfCthulhu, this);

	precache_model("progs/eoc_p2.mdl");
	precache_model("progs/xtragib.mdl");
	precache_model("progs/bone.mdl");
	precache_model("progs/bone2.mdl");
	precache_model("progs/rawbone2.mdl");
	precache_sound("eoc/death.wav");
	precache_sound("eoc/pain.wav");
	precache_sound("eoc/charge.wav"); // TODO: unused for now, need a hard mode attack!
	precache_sound("eoc/spit.wav");

	if(!actor.minion_maxcount)
		actor.minion_maxcount = 9;

	actor.bosswave = 0;

    actor.health = 3640;
	actor.th_stand = eoc_stand1;
	actor.th_walk = eoc_walk1;
	actor.th_run = eoc_run1;
	actor.th_melee = eoc_atk1;
	actor.th_missile = eoc_atkb1;
	actor.th_pain = eoc_pain;
	actor.th_die = eoc_die;

    return true;
}
#endif
