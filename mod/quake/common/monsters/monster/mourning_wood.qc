#include "mourning_wood.qh"

#ifdef SVQC
void mw_run1(entity this);

void mw_anim(entity this, void(entity) tnk)
{
	this.walkframe += 1;
	if(this.walkframe > 3)
		this.walkframe = 0;
	this.frame = this.walkframe;
	this.nextthink = time + 0.1;
	setthink(this, tnk);
}

void mw_stand1(entity this);
void mw_stand6(entity this) { mw_anim(this, mw_stand1); ai_stand(this); }
void mw_stand5(entity this) { mw_anim(this, mw_stand6); ai_stand(this); }
void mw_stand4(entity this) { mw_anim(this, mw_stand5); ai_stand(this); }
void mw_stand3(entity this) { mw_anim(this, mw_stand4); ai_stand(this); }
void mw_stand2(entity this) { mw_anim(this, mw_stand3); ai_stand(this); }
void mw_stand1(entity this) { mw_anim(this, mw_stand2); ai_stand(this); }

void mw_walk1(entity this);
void mw_walk6(entity this) { mw_anim(this, mw_walk1); ai_walk(this, 3); }
void mw_walk5(entity this) { mw_anim(this, mw_walk6); ai_walk(this, 3); }
void mw_walk4(entity this) { mw_anim(this, mw_walk5); ai_walk(this, 4); }
void mw_walk3(entity this) { mw_anim(this, mw_walk4); ai_walk(this, 3); }
void mw_walk2(entity this) { mw_anim(this, mw_walk3); ai_walk(this, 2); }
void mw_walk1(entity this) { mw_anim(this, mw_walk2); ai_walk(this, 3); }

void mw_greek_fire_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	int contents = pointcontents(this.origin);
	if(contents == CONTENT_SKY || contents == CONTENT_WATER)
	{
		delete(this);
		return;
	}

	if(toucher.takedamage)
	{
		float damg = ((this.dmg) ? this.dmg : 9);
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);

		float burntime = floor(autocvar_skill + 3 + 2*random());
		// only add more burn time if there isn't already a longer timer running!
		float curtime = StatusEffects_gettime(STATUSEFFECT_Burning, toucher);
		if((time + burntime) > curtime)
			StatusEffects_apply(STATUSEFFECT_Burning, toucher, time + burntime, 0);
	}
}

void mw_greek_fire_think(entity this)
{
	if(time >= this.count)
	{
		delete(this);
		return;
	}

	this.nextthink = time + 0.1;

	this.frame += 1;
	if(this.frame > 5)
		this.frame = 0;
}

void mw_greek_fire(entity this)
{
	_sound(this, CH_WEAPON_A, "mourning_wood/greek_fire.wav", 1, ATTN_BOSS);

	vector org = CENTER_OR_VIEWOFS(this);

	int maxflames = 3; // per fire frame
	for(int j = 0; j < maxflames; ++j)
	{
		entity newmis = launch_spike(this, org, '0 0 0');
		newmis.projectiledeathtype = DEATH_MONSTER_MOURNING_WOOD.m_id;
		newmis.dmg = 3; // low damage because burny
		newmis.classname = "greek_fire";
		settouch(newmis, mw_greek_fire_touch);
		_setmodel(newmis, "progs/mourning_wood_flame.mdl");
		setsize(newmis, '0 0 0', '0 0 0');
		setthink(newmis, mw_greek_fire_think);
		newmis.nextthink = time + 0.1;
		newmis.count = time + 7;
		newmis.gravity = 0.3;
		set_movetype(newmis, MOVETYPE_TOSS);
		newmis.angles = '0 0 0';
		newmis.avelocity = '0 0 0';
		//newmis.angles_y = random() * 180;

		newmis.velocity = randomvec() * 200;
		newmis.velocity_z = 300;
	}
		
}

void gib_mw(entity this);
void mw_atkc6(entity this) { mw_anim(this, mw_run1); mw_greek_fire(this); }
void mw_atkc5(entity this) { mw_anim(this, mw_atkc6); mw_greek_fire(this); }
void mw_atkc4(entity this) { mw_anim(this, mw_atkc5); mw_greek_fire(this); }
void mw_atkc3(entity this) { mw_anim(this, mw_atkc4); mw_greek_fire(this); }
void mw_atkc2(entity this) { mw_anim(this, mw_atkc3); mw_greek_fire(this); }
void mw_atkc1(entity this) { mw_anim(this, mw_atkc2); ai_face(this); this.attack_finished = time + 2 + (random() * 2); }

void mw_flamewood_fire(entity this)
{
	_sound(this, CH_WEAPON_A, "mourning_wood/wood_fire.wav", 1, ATTN_BOSS);

	vector org = CENTER_OR_VIEWOFS(this);
	vector dir = normalize(this.enemy.origin - this.origin);

	entity newmis = launch_spike(this, org, dir);
	newmis.projectiledeathtype = DEATH_MONSTER_MOURNING_WOOD.m_id;
	newmis.classname = "flamewood";
	newmis.avelocity_z = random() * 90;
	//newmis.modelflags |= MF_GRENADE;
	newmis.dmg = 20;
	_setmodel(newmis, "progs/mourning_wood_flamewood.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	newmis.velocity = dir * 500;
}

void mw_run1(entity this);
void mw_atkd15(entity this) { mw_anim(this, mw_run1); mw_flamewood_fire(this); }
void mw_atkd14(entity this) { mw_anim(this, mw_atkd15); }
void mw_atkd13(entity this) { mw_anim(this, mw_atkd14); mw_flamewood_fire(this); }
void mw_atkd12(entity this) { mw_anim(this, mw_atkd13); }
void mw_atkd11(entity this) { mw_anim(this, mw_atkd12); mw_flamewood_fire(this); }
void mw_atkd10(entity this) { mw_anim(this, mw_atkd11); }
void mw_atkd9(entity this) { mw_anim(this, mw_atkd10); mw_flamewood_fire(this); }
void mw_atkd8(entity this) { mw_anim(this, mw_atkd9); }
void mw_atkd7(entity this) { mw_anim(this, mw_atkd8); mw_flamewood_fire(this); }
void mw_atkd6(entity this) { mw_anim(this, mw_atkd7); }
void mw_atkd5(entity this) { mw_anim(this, mw_atkd6); mw_flamewood_fire(this); }
void mw_atkd4(entity this) { mw_anim(this, mw_atkd5); }
void mw_atkd3(entity this) { mw_anim(this, mw_atkd4); mw_flamewood_fire(this); }
void mw_atkd2(entity this) { mw_anim(this, mw_atkd3); }
void mw_atkd1(entity this) { mw_anim(this, mw_atkd2); ai_face(this); this.attack_finished = time + 2 + (random() * 2); }

void mw_run6(entity this) { mw_anim(this, mw_run1); ai_run(this, 20); }
void mw_run5(entity this) { mw_anim(this, mw_run6); ai_run(this, 24); }
void mw_run4(entity this) { mw_anim(this, mw_run5); ai_run(this, 22); }
void mw_run3(entity this) { mw_anim(this, mw_run4); ai_run(this, 24); }
void mw_run2(entity this) { mw_anim(this, mw_run3); ai_run(this, 20); }
void mw_run1(entity this)
{
	mw_anim(this, mw_run2);
	if(time >= this.attack_finished && random() < 0.2)
	{
		mw_atkd1(this);
		return;
	}
	if(time >= this.attack_finished && random() < 0.3)
	{
		mw_atkc1(this);
		return;
	}
	ai_run(this, 16);
}

void mw_suck(entity this)
{
	if(!this.enemy)
		return;
	ai_charge(this, 0);
	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;
	float ldmg = (((random() + random()) + random()) * 10);
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_MOURNING_WOOD.m_id);
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
}

void mw_atk17(entity this) { mw_anim(this, mw_run1); ai_charge(this, 18); }
void mw_atk16(entity this) { mw_anim(this, mw_atk17); ai_charge(this, 19); mw_suck(this); }
void mw_atk15(entity this) { mw_anim(this, mw_atk16); ai_charge(this, 20); }
void mw_atk14(entity this) { mw_anim(this, mw_atk15); ai_charge(this, 21); }
void mw_atk13(entity this) { mw_anim(this, mw_atk14); ai_charge(this, 22); }
void mw_atk12(entity this) { mw_anim(this, mw_atk13); ai_charge(this, 23); mw_suck(this); }
void mw_atk11(entity this) { mw_anim(this, mw_atk12); ai_charge(this, 24); }
void mw_atk10(entity this) { mw_anim(this, mw_atk11); ai_charge(this, 25); }
void mw_atk9(entity this) { mw_anim(this, mw_atk10); ai_charge(this, 26); }
void mw_atk8(entity this) { mw_anim(this, mw_atk9); ai_charge(this, 27); mw_suck(this); }
void mw_atk7(entity this) { mw_anim(this, mw_atk8); ai_charge(this, 26); }
void mw_atk6(entity this) { mw_anim(this, mw_atk7); ai_charge(this, 25); }
void mw_atk5(entity this) { mw_anim(this, mw_atk6); ai_charge(this, 24); }
void mw_atk4(entity this) { mw_anim(this, mw_atk5); ai_charge(this, 23); mw_suck(this); }
void mw_atk3(entity this) { mw_anim(this, mw_atk4); ai_charge(this, 22); }
void mw_atk2(entity this) { mw_anim(this, mw_atk3); ai_charge(this, 21); }
void mw_atk1(entity this) { mw_anim(this, mw_atk2); ai_charge(this, 20); mw_suck(this); }

void mw_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	if(this.health <= 0)
		return;
	_sound(this, CH_VOICE, "mourning_wood/pain.wav", 1, ATTN_BOSS);
	this.pain_finished = time + 0.2;
}

void gib_mw(entity this)
{
	_sound(this, CH_VOICE, "mourning_wood/death.wav", 1, ATTN_BOSS);
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

void mw_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	gib_mw(this);
}

spawnfunc(monster_mourning_wood) { monster_start(this, true, MON_MOURNING_WOOD); }
#endif // SVQC

#ifdef SVQC
METHOD(MourningWood, mr_setup, bool(MourningWood this, entity actor))
{
	TC(MourningWood, this);

	precache_model("progs/xtragib.mdl");
	precache_model("progs/bone.mdl");
	precache_model("progs/bone2.mdl");
	precache_model("progs/rawbone2.mdl");
	precache_model("progs/mourning_wood_flame.mdl");
	precache_model("progs/mourning_wood_flamewood.mdl");
	precache_sound("mourning_wood/death.wav");
	precache_sound("mourning_wood/pain.wav");
	precache_sound("mourning_wood/greek_fire.wav");
	precache_sound("mourning_wood/wood_fire.wav");

	actor.health = 2500;
	actor.th_stand = mw_stand1;
	actor.th_walk = mw_walk1;
	actor.th_run = mw_run1;
	actor.th_melee = mw_atk1;
	actor.th_pain = mw_pain;
	actor.th_die = mw_die;

	return true;
}
#endif
