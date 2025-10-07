#include "cheddar_goblin.qh"

#ifdef SVQC
const int anim_cheddar_stand = 0;
const int anim_cheddar_walk = 15;
const int anim_cheddar_run = 26;
const int anim_cheddar_attack = 33;
const int anim_cheddar_pain = 61;
const int anim_cheddar_death = 71;

.float idle_finished;

void cheddar_idle_sound(entity this)
{
	if(random() < 0.17 && time >= this.idle_finished)
	{
		this.idle_finished = time + 3;
		if(random() <= 0.3)
			_sound(this, CH_VOICE, "cheddar_goblin/idle1.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "cheddar_goblin/idle2.wav", 1,  ATTN_IDLE);
	}
}

void cheddar_stand1(entity this);
void cheddar_stand15(entity this) { set_animofs(this, anim_cheddar_stand, 15, cheddar_stand1); ai_stand(this); }
void cheddar_stand14(entity this) { set_animofs(this, anim_cheddar_stand, 14, cheddar_stand15); ai_stand(this); }
void cheddar_stand13(entity this) { set_animofs(this, anim_cheddar_stand, 13, cheddar_stand14); ai_stand(this); }
void cheddar_stand12(entity this) { set_animofs(this, anim_cheddar_stand, 12, cheddar_stand13); ai_stand(this); }
void cheddar_stand11(entity this) { set_animofs(this, anim_cheddar_stand, 11, cheddar_stand12); ai_stand(this); }
void cheddar_stand10(entity this) { set_animofs(this, anim_cheddar_stand, 10, cheddar_stand11); ai_stand(this); }
void cheddar_stand9(entity this) { set_animofs(this, anim_cheddar_stand, 9, cheddar_stand10); ai_stand(this); }
void cheddar_stand8(entity this) { set_animofs(this, anim_cheddar_stand, 8, cheddar_stand9); ai_stand(this); }
void cheddar_stand7(entity this) { set_animofs(this, anim_cheddar_stand, 7, cheddar_stand8); ai_stand(this); }
void cheddar_stand6(entity this) { set_animofs(this, anim_cheddar_stand, 6, cheddar_stand7); ai_stand(this); }
void cheddar_stand5(entity this) { set_animofs(this, anim_cheddar_stand, 5, cheddar_stand6); ai_stand(this); }
void cheddar_stand4(entity this) { set_animofs(this, anim_cheddar_stand, 4, cheddar_stand5); ai_stand(this); }
void cheddar_stand3(entity this) { set_animofs(this, anim_cheddar_stand, 3, cheddar_stand4); ai_stand(this); }
void cheddar_stand2(entity this) { set_animofs(this, anim_cheddar_stand, 2, cheddar_stand3); ai_stand(this); }
void cheddar_stand1(entity this) { set_animofs(this, anim_cheddar_stand, 1, cheddar_stand2); cheddar_idle_sound(this); ai_stand(this); }

void cheddar_walk1(entity this);
void cheddar_walk11(entity this) { set_animofs(this, anim_cheddar_walk, 11, cheddar_walk1); ai_walk(this, 2); }
void cheddar_walk10(entity this) { set_animofs(this, anim_cheddar_walk, 10, cheddar_walk11); ai_walk(this, 3); }
void cheddar_walk9(entity this) { set_animofs(this, anim_cheddar_walk, 9, cheddar_walk10); ai_walk(this, 3); }
void cheddar_walk8(entity this) { set_animofs(this, anim_cheddar_walk, 8, cheddar_walk9); ai_walk(this, 4); }
void cheddar_walk7(entity this) { set_animofs(this, anim_cheddar_walk, 7, cheddar_walk8); ai_walk(this, 3); }
void cheddar_walk6(entity this) { set_animofs(this, anim_cheddar_walk, 6, cheddar_walk7); ai_walk(this, 3); }
void cheddar_walk5(entity this) { set_animofs(this, anim_cheddar_walk, 5, cheddar_walk6); ai_walk(this, 3); }
void cheddar_walk4(entity this) { set_animofs(this, anim_cheddar_walk, 4, cheddar_walk5); ai_walk(this, 4); }
void cheddar_walk3(entity this) { set_animofs(this, anim_cheddar_walk, 3, cheddar_walk4); ai_walk(this, 3); }
void cheddar_walk1(entity this) { set_animofs(this, anim_cheddar_walk, 2, cheddar_walk3); cheddar_idle_sound(this); ai_walk(this, 2); }
#if 0
void cheddar_walk1(entity this)
{
	set_animofs(this, anim_cheddar_walk, 1, cheddar_walk2);
	cheddar_idle_sound(this);
	ai_walk(this, 3);
}
#endif

void cheddar_run1(entity this);
void cheddar_run7(entity this) { set_animofs(this, anim_cheddar_run, 7, cheddar_run1); ai_run(this, 11); }
void cheddar_run6(entity this) { set_animofs(this, anim_cheddar_run, 6, cheddar_run7); ai_run(this, 13); }
void cheddar_run5(entity this) { set_animofs(this, anim_cheddar_run, 5, cheddar_run6); ai_run(this, 12); }
void cheddar_run4(entity this) { set_animofs(this, anim_cheddar_run, 4, cheddar_run5); ai_run(this, 7); }
void cheddar_run3(entity this) { set_animofs(this, anim_cheddar_run, 3, cheddar_run4); ai_run(this, 10); }
void cheddar_run2(entity this) { set_animofs(this, anim_cheddar_run, 2, cheddar_run3); ai_run(this, 13); }
void cheddar_run1(entity this)
{
	set_animofs(this, anim_cheddar_run, 1, cheddar_run2);
	cheddar_idle_sound(this);
	ai_run(this, 12);
}

void cheddar_pool_touch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.solid == SOLID_TRIGGER || toucher.health < 1 || toucher.takedamage == DAMAGE_NO || !Damage_ValidTarget(toucher, this.owner))
		return;
	if(!Damage_ValidTarget(toucher, this.owner))
		return;

	float poisontime = 7;
	float curtime = StatusEffects_gettime(STATUSEFFECT_Poisoned, toucher);
	if((time + poisontime) > curtime)
		StatusEffects_apply(STATUSEFFECT_Poisoned, toucher, time + poisontime, 0);
}

void cheddar_pool_anim(entity this)
{
	setthink(this, cheddar_pool_anim);
	this.nextthink = time + 0.1;
	this.walkframe += 1;
	if(this.walkframe < 10)
		this.frame = this.walkframe;
	else
		delete(this);
}

void cheddar_spit_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(pointcontents(this.origin) < CONTENT_WATER)
	{
		delete(this);
		return;
	}

	particle(this.origin, '0 0 0', 57, 50);
	_sound(this, CH_WEAPON_SINGLE, "blob/land1.wav", 1, ATTN_NORM);

	if(toucher.takedamage || IS_MONSTER(toucher))
	{
		float damage = 15;
		T_Damage(toucher, this, this.owner, damage, this.projectiledeathtype);
		if(toucher.move_movetype != MOVETYPE_PUSH)
			return;
	}

	vector vel_norm = normalize(this.velocity);
	vector vec = this.origin - vel_norm;
	traceline(vec, vec + vel_norm * 16, false, this);
	if(trace_fraction < 1)
	{
		set_movetype(this, MOVETYPE_NONE);
		this.solid = SOLID_TRIGGER;
		_setmodel(this, "progs/s_macpool.mdl");
		setsize(this, '-12 -12 0', '12 12 4');
		setorigin(this, trace_endpos);

		vec = trace_plane_normal;
		this.angles = vectoangles(vec);
		this.angles_x -= 90;
		settouch(this, cheddar_pool_touch);
		this.frame = 0;
		this.nextthink = time + 4.1;
		setthink(this, cheddar_pool_anim);
	}
}

void cheddar_spit_anim(entity this)
{
	setthink(this, cheddar_spit_anim);
	this.nextthink = time + 0.1;
	particle(this.origin, '0 0 0', 57, 10);
	this.walkframe += 1;
	if(this.walkframe > 5)
		this.walkframe = 0;
	this.frame = this.walkframe;
	if(this.velocity == '0 0 0')
		delete(this);
}

void cheddar_spit(entity this, float offset)
{
	entity newmis = new(acidspit);
	newmis.flags = FL_PROJECTILE;
	newmis.owner = this;
	newmis.realowner = this;
	set_movetype(newmis, MOVETYPE_TOSS);
	newmis.solid = SOLID_CORPSE;
	newmis.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;

	fixedmakevectors(this.angles);

	newmis.velocity = v_forward * 300 + v_right * offset;
	newmis.velocity_z = 20;

	newmis.poisonous = true;
	newmis.projectiledeathtype = DEATH_MONSTER_CHEDDAR_GOBLIN.m_id;
	newmis.clipgroup = this.clipgroup;
	newmis.avelocity = '300 300 300';
	newmis.angles = vectoangles(newmis.avelocity);
	_setmodel(newmis, "progs/s_macspit.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, this.origin + '0 0 6');
	setthink(newmis, cheddar_spit_anim);
	settouch(newmis, cheddar_spit_touch);
	newmis.nextthink = time + 0.1;

	IL_PUSH(g_projectiles, newmis);
}

void cheddar_atk28(entity this) { set_animofs(this, anim_cheddar_attack, 28, cheddar_run1); }
void cheddar_atk27(entity this) { set_animofs(this, anim_cheddar_attack, 27, cheddar_atk28); }
void cheddar_atk26(entity this) { set_animofs(this, anim_cheddar_attack, 26, cheddar_atk27); }
void cheddar_atk25(entity this) { set_animofs(this, anim_cheddar_attack, 25, cheddar_atk26); }
void cheddar_atk24(entity this) { set_animofs(this, anim_cheddar_attack, 24, cheddar_atk25); }
void cheddar_atk23(entity this) { set_animofs(this, anim_cheddar_attack, 23, cheddar_atk24); }
void cheddar_atk22(entity this) { set_animofs(this, anim_cheddar_attack, 22, cheddar_atk23); cheddar_spit(this, 80); }
void cheddar_atk21(entity this) { set_animofs(this, anim_cheddar_attack, 21, cheddar_atk22); }
void cheddar_atk20(entity this) { set_animofs(this, anim_cheddar_attack, 20, cheddar_atk21); }
void cheddar_atk19(entity this) { set_animofs(this, anim_cheddar_attack, 19, cheddar_atk20); }
void cheddar_atk18(entity this) { set_animofs(this, anim_cheddar_attack, 18, cheddar_atk19); cheddar_spit(this, 0); }
void cheddar_atk17(entity this) { set_animofs(this, anim_cheddar_attack, 17, cheddar_atk18); }
void cheddar_atk16(entity this) { set_animofs(this, anim_cheddar_attack, 16, cheddar_atk17); }
void cheddar_atk15(entity this) { set_animofs(this, anim_cheddar_attack, 15, cheddar_atk16); cheddar_spit(this, -80); }
void cheddar_atk14(entity this) { set_animofs(this, anim_cheddar_attack, 14, cheddar_atk15); }
void cheddar_atk13(entity this) { set_animofs(this, anim_cheddar_attack, 13, cheddar_atk14); }
void cheddar_atk12(entity this) { set_animofs(this, anim_cheddar_attack, 12, cheddar_atk13); _sound(this, CH_WEAPON_SINGLE, "cheddar_goblin/spit.wav", 1, ATTN_NORM); }
void cheddar_atk11(entity this) { set_animofs(this, anim_cheddar_attack, 11, cheddar_atk12); }
void cheddar_atk10(entity this) { set_animofs(this, anim_cheddar_attack, 10, cheddar_atk11); }
void cheddar_atk9(entity this) { set_animofs(this, anim_cheddar_attack, 9, cheddar_atk10); }
void cheddar_atk8(entity this) { set_animofs(this, anim_cheddar_attack, 8, cheddar_atk9); }
void cheddar_atk7(entity this) { set_animofs(this, anim_cheddar_attack, 7, cheddar_atk8); }
void cheddar_atk6(entity this) { set_animofs(this, anim_cheddar_attack, 6, cheddar_atk7); }
void cheddar_atk5(entity this) { set_animofs(this, anim_cheddar_attack, 5, cheddar_atk6); }
void cheddar_atk4(entity this) { set_animofs(this, anim_cheddar_attack, 4, cheddar_atk5); }
void cheddar_atk3(entity this) { set_animofs(this, anim_cheddar_attack, 3, cheddar_atk4); }
void cheddar_atk2(entity this) { set_animofs(this, anim_cheddar_attack, 2, cheddar_atk3); }
void cheddar_atk1(entity this) { set_animofs(this, anim_cheddar_attack, 1, cheddar_atk2); }

void cheddar_attack(entity this)
{
	this.attack_finished = time + 3;
	ai_face(this);
	cheddar_atk1(this);
}

//void cheddar_atk11(entity this)	=[	anim_cheddar_attack11,		cheddar_run1	 
//void cheddar_atk10(entity this)	=[	anim_cheddar_attack10,		cheddar_atk11	 
//void cheddar_atk9(entity this)	=[	anim_cheddar_attack9,		cheddar_atk10	 

//===========================================================================

void cheddar_pain10(entity this) { set_animofs(this, anim_cheddar_pain, 10, cheddar_run1); }
void cheddar_pain9(entity this) { set_animofs(this, anim_cheddar_pain, 9, cheddar_pain10);  }
void cheddar_pain8(entity this) { set_animofs(this, anim_cheddar_pain, 8, cheddar_pain9);  }
void cheddar_pain7(entity this) { set_animofs(this, anim_cheddar_pain, 7, cheddar_pain8); }
void cheddar_pain6(entity this) { set_animofs(this, anim_cheddar_pain, 6, cheddar_pain7); }
void cheddar_pain5(entity this) { set_animofs(this, anim_cheddar_pain, 5, cheddar_pain6); }
void cheddar_pain4(entity this) { set_animofs(this, anim_cheddar_pain, 4, cheddar_pain5); }
void cheddar_pain3(entity this) { set_animofs(this, anim_cheddar_pain, 3, cheddar_pain4); }
void cheddar_pain2(entity this) { set_animofs(this, anim_cheddar_pain, 2, cheddar_pain3); ai_pain(this, 3); }
void cheddar_pain1(entity this) { set_animofs(this, anim_cheddar_pain, 1, cheddar_pain2); ai_pain(this, 0); }

void cheddar_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	if(this.attack_finished > time)
		return;

	float r = random();
	
	if(r > 0.5)
		_sound(this, CH_VOICE, "cheddar_goblin/pain1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "cheddar_goblin/pain2.wav", 1, ATTN_NORM);

	this.pain_finished = time + 1;
	cheddar_pain1(this);
}

//===========================================================================

void cheddar_die15(entity this) { set_animofs(this, anim_cheddar_death, 15, cheddar_die15); CorpseThink(this); }
void cheddar_die14(entity this) { set_animofs(this, anim_cheddar_death, 14, cheddar_die15); }
void cheddar_die13(entity this) { set_animofs(this, anim_cheddar_death, 13, cheddar_die14); }
void cheddar_die12(entity this) { set_animofs(this, anim_cheddar_death, 12, cheddar_die13); }
void cheddar_die11(entity this) { set_animofs(this, anim_cheddar_death, 11, cheddar_die12); }
void cheddar_die10(entity this) { set_animofs(this, anim_cheddar_death, 10, cheddar_die11); }
void cheddar_die9(entity this) { set_animofs(this, anim_cheddar_death, 9, cheddar_die10); }
void cheddar_die8(entity this) { set_animofs(this, anim_cheddar_death, 8, cheddar_die9); }
void cheddar_die7(entity this) { set_animofs(this, anim_cheddar_death, 7, cheddar_die8); }
void cheddar_die6(entity this) { set_animofs(this, anim_cheddar_death, 6, cheddar_die7); }
void cheddar_die5(entity this) { set_animofs(this, anim_cheddar_death, 5, cheddar_die6); }
void cheddar_die4(entity this) { set_animofs(this, anim_cheddar_death, 4, cheddar_die5); }
void cheddar_die3(entity this) { set_animofs(this, anim_cheddar_death, 3, cheddar_die4); }
void cheddar_die2(entity this) { set_animofs(this, anim_cheddar_death, 2, cheddar_die3); }
void cheddar_die1(entity this) { set_animofs(this, anim_cheddar_death, 1, cheddar_die2); this.solid = SOLID_NOT; }

void cheddar_die(entity this, entity inflictor, entity attacker, int deathtype)
{
// check for gib
	if(this.health < -40)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, inflictor, "progs/h_grem.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		return;
	}

// regular death
	_sound(this, CH_VOICE, "cheddar_goblin/death.wav", 1, ATTN_NORM);
	cheddar_die1(this);
}

/*QUAKED monster_cheddar_goblin(1 0 0)(-16 -16 -24)(16 16 40) Ambush
*/
spawnfunc(monster_cheddar_goblin) { monster_start(this, true, MON_CHEDDAR_GOBLIN); }
#endif // SVQC

#ifdef SVQC
METHOD(CheddarGoblin, mr_setup, bool(CheddarGoblin this, entity actor))
{
	TC(CheddarGoblin, this);

	precache_model("progs/s_macpool.mdl");
	precache_model("progs/s_macspit.mdl");
	precache_model("progs/gib1.mdl");
	precache_model("progs/gib2.mdl");
	precache_model("progs/gib3.mdl");

	precache_sound("cheddar_goblin/pain1.wav");
	precache_sound("cheddar_goblin/pain2.wav");
	precache_sound("cheddar_goblin/death.wav");
	precache_sound("cheddar_goblin/idle1.wav");
	precache_sound("cheddar_goblin/idle2.wav");
	precache_sound("cheddar_goblin/spit.wav");
	precache_sound("blob/land1.wav");

	actor.health = 110;
	actor.th_stand = cheddar_stand1;
	actor.th_walk = cheddar_walk1;
	actor.th_run = cheddar_run1;
	actor.th_melee = cheddar_attack;
	actor.th_pain = cheddar_pain;
	actor.th_die = cheddar_die;

	return true;
}
#endif
