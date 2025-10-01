#include "wrath.qh"

#ifdef SVQC
const int anim_wrath_wrthwk01 = 1;
const int anim_wrath_wrthaa01 = 13;
const int anim_wrath_wrthab01 = 27;
const int anim_wrath_wrthac01 = 40;
const int anim_wrath_wrthpa01 = 55;
const int anim_wrath_wrthpb01 = 61;
const int anim_wrath_wrthdt01 = 72;

void wrath_stand1(entity this) { set_animofs(this, anim_wrath_wrthwk01, 1, wrath_stand1); ai_stand(this);}

void wrath_walk01(entity this);
void wrath_walk12(entity this) { set_animofs(this, anim_wrath_wrthwk01, 12, wrath_walk01); ai_walk(this, 8); }
void wrath_walk11(entity this) { set_animofs(this, anim_wrath_wrthwk01, 11, wrath_walk12); ai_walk(this, 8); }
void wrath_walk10(entity this) { set_animofs(this, anim_wrath_wrthwk01, 10, wrath_walk11); ai_walk(this, 8); }
void wrath_walk09(entity this) { set_animofs(this, anim_wrath_wrthwk01, 9, wrath_walk10); ai_walk(this, 8); }
void wrath_walk08(entity this) { set_animofs(this, anim_wrath_wrthwk01, 8, wrath_walk09); ai_walk(this, 8); }
void wrath_walk07(entity this) { set_animofs(this, anim_wrath_wrthwk01, 7, wrath_walk08); ai_walk(this, 8); }
void wrath_walk06(entity this) { set_animofs(this, anim_wrath_wrthwk01, 6, wrath_walk07); ai_walk(this, 8); }
void wrath_walk05(entity this) { set_animofs(this, anim_wrath_wrthwk01, 5, wrath_walk06); ai_walk(this, 8); }
void wrath_walk04(entity this) { set_animofs(this, anim_wrath_wrthwk01, 4, wrath_walk05); ai_walk(this, 8); }
void wrath_walk03(entity this) { set_animofs(this, anim_wrath_wrthwk01, 3, wrath_walk04); ai_walk(this, 8); }
void wrath_walk02(entity this) { set_animofs(this, anim_wrath_wrthwk01, 2, wrath_walk03); ai_walk(this, 8); }
void wrath_walk01(entity this) { set_animofs(this, anim_wrath_wrthwk01, 1, wrath_walk02); ai_walk(this, 8); }

void wrath_run01(entity this);
void wrath_run12(entity this) { set_animofs(this, anim_wrath_wrthwk01, 12, wrath_run01); ai_run(this, 12); }
void wrath_run11(entity this) { set_animofs(this, anim_wrath_wrthwk01, 11, wrath_run12); ai_run(this, 12); }
void wrath_run10(entity this) { set_animofs(this, anim_wrath_wrthwk01, 10, wrath_run11); ai_run(this, 12); }
void wrath_run09(entity this) { set_animofs(this, anim_wrath_wrthwk01, 9, wrath_run10); ai_run(this, 12); }
void wrath_run08(entity this) { set_animofs(this, anim_wrath_wrthwk01, 8, wrath_run09); ai_run(this, 12); }
void wrath_run07(entity this) { set_animofs(this, anim_wrath_wrthwk01, 7, wrath_run08); ai_run(this, 12); }
void wrath_run06(entity this) { set_animofs(this, anim_wrath_wrthwk01, 6, wrath_run07); ai_run(this, 12); }
void wrath_run05(entity this) { set_animofs(this, anim_wrath_wrthwk01, 5, wrath_run06); ai_run(this, 12); }
void wrath_run04(entity this) { set_animofs(this, anim_wrath_wrthwk01, 4, wrath_run05); ai_run(this, 12); }
void wrath_run03(entity this) { set_animofs(this, anim_wrath_wrthwk01, 3, wrath_run04); ai_run(this, 12); }
void wrath_run02(entity this) { set_animofs(this, anim_wrath_wrthwk01, 2, wrath_run03); ai_run(this, 12); }
void wrath_run01(entity this) { set_animofs(this, anim_wrath_wrthwk01, 1, wrath_run02); ai_run(this, 12); }

void wrath_at_a14(entity this) { set_animofs(this, anim_wrath_wrthaa01, 14, wrath_run01); ai_charge(this, 12);}
void wrath_at_a13(entity this) { set_animofs(this, anim_wrath_wrthaa01, 13, wrath_at_a14); ai_charge(this, 12);}
void wrath_at_a12(entity this) { set_animofs(this, anim_wrath_wrthaa01, 12, wrath_at_a13); ai_charge(this, 12);}
void wrath_at_a11(entity this) { set_animofs(this, anim_wrath_wrthaa01, 11, wrath_at_a12); WrathMissile(this, 1);}
void wrath_at_a10(entity this) { set_animofs(this, anim_wrath_wrthaa01, 10, wrath_at_a11); ai_charge(this, 12);}
void wrath_at_a09(entity this) { set_animofs(this, anim_wrath_wrthaa01, 9, wrath_at_a10); ai_charge(this, 12);}
void wrath_at_a08(entity this) { set_animofs(this, anim_wrath_wrthaa01, 8, wrath_at_a09); ai_charge(this, 12);}
void wrath_at_a07(entity this) { set_animofs(this, anim_wrath_wrthaa01, 7, wrath_at_a08); ai_charge(this, 12);}
void wrath_at_a06(entity this) { set_animofs(this, anim_wrath_wrthaa01, 6, wrath_at_a07); ai_charge(this, 12);}
void wrath_at_a05(entity this) { set_animofs(this, anim_wrath_wrthaa01, 5, wrath_at_a06); ai_charge(this, 12);}
void wrath_at_a04(entity this) { set_animofs(this, anim_wrath_wrthaa01, 4, wrath_at_a05); ai_charge(this, 12);}
void wrath_at_a03(entity this) { set_animofs(this, anim_wrath_wrthaa01, 3, wrath_at_a04); ai_charge(this, 12);}
void wrath_at_a02(entity this) { set_animofs(this, anim_wrath_wrthaa01, 2, wrath_at_a03); ai_charge(this, 12);}
void wrath_at_a01(entity this) { set_animofs(this, anim_wrath_wrthaa01, 1, wrath_at_a02); ai_charge(this, 12);}

void wrath_at_b13(entity this) { set_animofs(this, anim_wrath_wrthab01, 13, wrath_run01); ai_charge(this, 12);}
void wrath_at_b12(entity this) { set_animofs(this, anim_wrath_wrthab01, 12, wrath_at_b13); ai_charge(this, 12);}
void wrath_at_b11(entity this) { set_animofs(this, anim_wrath_wrthab01, 11, wrath_at_b12); ai_charge(this, 12);}
void wrath_at_b10(entity this) { set_animofs(this, anim_wrath_wrthab01, 10, wrath_at_b11); ai_charge(this, 12);}
void wrath_at_b09(entity this) { set_animofs(this, anim_wrath_wrthab01, 9, wrath_at_b10); ai_charge(this, 12);}
void wrath_at_b08(entity this) { set_animofs(this, anim_wrath_wrthab01, 8, wrath_at_b09); ai_charge(this, 12);}
void wrath_at_b07(entity this) { set_animofs(this, anim_wrath_wrthab01, 7, wrath_at_b08); ai_charge(this, 12);}
void wrath_at_b06(entity this) { set_animofs(this, anim_wrath_wrthab01, 6, wrath_at_b07); WrathMissile(this, 2);}
void wrath_at_b05(entity this) { set_animofs(this, anim_wrath_wrthab01, 5, wrath_at_b06); ai_charge(this, 12);}
void wrath_at_b04(entity this) { set_animofs(this, anim_wrath_wrthab01, 4, wrath_at_b05); ai_charge(this, 12);}
void wrath_at_b03(entity this) { set_animofs(this, anim_wrath_wrthab01, 3, wrath_at_b04); ai_charge(this, 12);}
void wrath_at_b02(entity this) { set_animofs(this, anim_wrath_wrthab01, 2, wrath_at_b03); ai_charge(this, 12);}
void wrath_at_b01(entity this) { set_animofs(this, anim_wrath_wrthab01, 1, wrath_at_b02); ai_charge(this, 12);}

void wrath_at_c15(entity this) { set_animofs(this, anim_wrath_wrthac01, 15, wrath_run01); ai_charge(this, 12);}
void wrath_at_c14(entity this) { set_animofs(this, anim_wrath_wrthac01, 14, wrath_at_c15); ai_charge(this, 12);}
void wrath_at_c13(entity this) { set_animofs(this, anim_wrath_wrthac01, 13, wrath_at_c14); ai_charge(this, 12);}
void wrath_at_c12(entity this) { set_animofs(this, anim_wrath_wrthac01, 12, wrath_at_c13); ai_charge(this, 12);}
void wrath_at_c11(entity this) { set_animofs(this, anim_wrath_wrthac01, 11, wrath_at_c12); ai_charge(this, 12);}
void wrath_at_c10(entity this) { set_animofs(this, anim_wrath_wrthac01, 10, wrath_at_c11); ai_charge(this, 12);}
void wrath_at_c09(entity this) { set_animofs(this, anim_wrath_wrthac01, 9, wrath_at_c10); ai_charge(this, 12);}
void wrath_at_c08(entity this) { set_animofs(this, anim_wrath_wrthac01, 8, wrath_at_c09); ai_charge(this, 12);}
void wrath_at_c07(entity this) { set_animofs(this, anim_wrath_wrthac01, 7, wrath_at_c08); WrathMissile(this, 3);}
void wrath_at_c06(entity this) { set_animofs(this, anim_wrath_wrthac01, 6, wrath_at_c07); ai_charge(this, 12);}
void wrath_at_c05(entity this) { set_animofs(this, anim_wrath_wrthac01, 5, wrath_at_c06); ai_charge(this, 12);}
void wrath_at_c04(entity this) { set_animofs(this, anim_wrath_wrthac01, 4, wrath_at_c05); ai_charge(this, 12);}
void wrath_at_c03(entity this) { set_animofs(this, anim_wrath_wrthac01, 3, wrath_at_c04); ai_charge(this, 12);}
void wrath_at_c02(entity this) { set_animofs(this, anim_wrath_wrthac01, 2, wrath_at_c03); ai_charge(this, 12);}
void wrath_at_c01(entity this) { set_animofs(this, anim_wrath_wrthac01, 1, wrath_at_c02); ai_charge(this, 12);}

void wrath_attack(entity this)
{
	float r = random();

	if(r < 0.25)
		wrath_at_a01(this);
	else if(r < 0.65)
		wrath_at_b01(this);
	else
		wrath_at_c01(this);

	_sound(this, CH_VOICE, "wrath/watt.wav", 1, ATTN_NORM);
}

void wrath_pn_a06(entity this) { set_animofs(this, anim_wrath_wrthpa01, 6, wrath_run01); }
void wrath_pn_a05(entity this) { set_animofs(this, anim_wrath_wrthpa01, 5, wrath_pn_a06); }
void wrath_pn_a04(entity this) { set_animofs(this, anim_wrath_wrthpa01, 4, wrath_pn_a05); }
void wrath_pn_a03(entity this) { set_animofs(this, anim_wrath_wrthpa01, 3, wrath_pn_a04); }
void wrath_pn_a02(entity this) { set_animofs(this, anim_wrath_wrthpa01, 2, wrath_pn_a03); }
void wrath_pn_a01(entity this) { set_animofs(this, anim_wrath_wrthpa01, 1, wrath_pn_a02); }

void wrath_pn_b11(entity this) { set_animofs(this, anim_wrath_wrthpb01, 11, wrath_run01);  }
void wrath_pn_b10(entity this) { set_animofs(this, anim_wrath_wrthpb01, 10, wrath_pn_b11); }
void wrath_pn_b09(entity this) { set_animofs(this, anim_wrath_wrthpb01, 9, wrath_pn_b10); }
void wrath_pn_b08(entity this) { set_animofs(this, anim_wrath_wrthpb01, 8, wrath_pn_b09); }
void wrath_pn_b07(entity this) { set_animofs(this, anim_wrath_wrthpb01, 7, wrath_pn_b08); }
void wrath_pn_b06(entity this) { set_animofs(this, anim_wrath_wrthpb01, 6, wrath_pn_b07); }
void wrath_pn_b05(entity this) { set_animofs(this, anim_wrath_wrthpb01, 5, wrath_pn_b06); }
void wrath_pn_b04(entity this) { set_animofs(this, anim_wrath_wrthpb01, 4, wrath_pn_b05); }
void wrath_pn_b03(entity this) { set_animofs(this, anim_wrath_wrthpb01, 3, wrath_pn_b04); }
void wrath_pn_b02(entity this) { set_animofs(this, anim_wrath_wrthpb01, 2, wrath_pn_b03); }
void wrath_pn_b01(entity this) { set_animofs(this, anim_wrath_wrthpb01, 1, wrath_pn_b02); }

void wrath_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	float r = random();
	
	if(r > 0.1)
	{
		this.pain_finished = time + 0.5;
		return;
	}
	this.pain_finished = time + 3;
			
	if(r < 0.07)
		wrath_pn_a01(this);
	else 
		wrath_pn_b01(this);

	_sound(this, CH_VOICE, "wrath/wpain.wav", 1, ATTN_NORM);
}

void wrath_die15(entity this)
{
	set_animofs(this, anim_wrath_wrthdt01, 15, wrath_die15);

	ThrowGib(this, this, "progs/wrthgib1.mdl", this.health);
	ThrowGib(this, this, "progs/wrthgib2.mdl", this.health);
	ThrowGib(this, this, "progs/wrthgib3.mdl", this.health);
	T_RadiusDamage(this, this, 80, DEATH_MONSTER_WRATH.m_id, NULL);

	this.origin = this.origin + '0 0 24';

	te_explosion2(this.origin, 0, 4);

	delete(this);
}
void wrath_die13(entity this) { set_animofs(this, anim_wrath_wrthdt01, 13, wrath_die15); }
void wrath_die11(entity this) { set_animofs(this, anim_wrath_wrthdt01, 11, wrath_die13); }
void wrath_die09(entity this) { set_animofs(this, anim_wrath_wrthdt01, 9, wrath_die11); }
void wrath_die07(entity this) { set_animofs(this, anim_wrath_wrthdt01, 7, wrath_die09); }
void wrath_die05(entity this) { set_animofs(this, anim_wrath_wrthdt01, 5, wrath_die07); }
void wrath_die04(entity this) { set_animofs(this, anim_wrath_wrthdt01, 4, wrath_die05); }
void wrath_die03(entity this) { set_animofs(this, anim_wrath_wrthdt01, 3, wrath_die04); }
void wrath_die02(entity this, entity inflictor, entity attacker, int deathtype)
{
	set_animofs(this, anim_wrath_wrthdt01, 2, wrath_die03);
	_sound(this, CH_VOICE, "wrath/wdthc.wav", 1, ATTN_NORM);
	this.solid = SOLID_NOT; // so players can get away while it explodes!
}

/*
================
WrathMissile
================
*/
void WrathMissile(entity this, int AttackNumber)
{
	vector dir = normalize((this.enemy.origin + '0 0 10') - this.origin);
	float dist = vlen (this.enemy.origin - this.origin);
	float flytime = dist * 0.002;
	if(flytime < 0.1)
		flytime = 0.1;

	this.effects |= EF_MUZZLEFLASH;

	makevectors(this.angles);

	entity missile = spawn();
	missile.flags = FL_PROJECTILE;
	missile.classname = "wrath_missile";
	missile.solid = SOLID_CORPSE;
	missile.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	missile.owner = this;
	//missile.solid = SOLID_BBOX;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	_setmodel(missile, "progs/w_ball.mdl");

	setsize(missile, '0 0 0', '0 0 0');		

	vector org = this.origin + v_forward * 20 + v_up * 12; // default to attack1?
	if(AttackNumber == 1)
	{
		org = this.origin + v_forward*20 + v_up*12; // 20 // 44;
	}
	else if(AttackNumber == 2)
	{
		org = this.origin + v_forward*18 + v_up*10; // 18 // 42;
	}
	else if(AttackNumber == 3)
	{
		org = this.origin + v_forward*12 + v_up*12 + v_right*20;
// up20
	}
    else if(AttackNumber == 4)
	{
        org = this.origin + v_forward*20 + v_up*16;
	}

	setorigin(missile, org);
	missile.velocity = dir * 400;
	missile.avelocity = '300 300 300';
	missile.enemy = this.enemy;
	missile.projectiledeathtype = DEATH_MONSTER_WRATH.m_id;
	missile.clipgroup = this.clipgroup;
	settouch(missile, WrathMissileTouch);
	missile.nextthink = time + 0.1;
	setthink(missile, WrathHome);
	missile.cnt = time + 10;

	IL_PUSH(g_projectiles, missile);
	
	this.attack_finished = time + 2;
}

void WrathHome(entity this)
{
	if(this.enemy.health < 1 || time > this.cnt)
	{
		delete(this);
		return;
	}

	if(autocvar_skill == 3)
		ai_track(this, this.enemy, 550);
	else
		ai_track(this, this.enemy, 400);

	this.nextthink = time + 0.1;
	setthink(this, WrathHome);
}

void WrathMissileTouch(entity this, entity toucher)
{
#if 0
	if(toucher == this.owner ||
		toucher.monsterdef == MON_WRATH || 
		toucher.monsterdef == MON_OVERLORD)
	{
		delete(this);
		return;		// don't explode on any wraths
	}
#else
	if(toucher == this.owner)
		return;
#endif

	if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD))
		T_Damage(toucher, this, this, 110, this.projectiledeathtype);	
		
	T_RadiusDamage(this, this.owner, 20, this.projectiledeathtype, NULL);
	sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);

	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);

	this.velocity = '0 0 0';
	settouch(this, func_null);
	setmodel(this, MDL_EXPLOSION);
	this.solid = SOLID_NOT;
	setsize(this, '0 0 0', '0 0 0');
	s_explode1(this);
}

/*QUAKED monster_wrath (1 0 0) (-16 -16 -24) (16 16 32) Ambush
*/
spawnfunc(monster_wrath)
{
	monster_start(this, true, MON_WRATH);
}
#endif // SVQC

#ifdef SVQC
METHOD(Wrath, mr_setup, bool(Wrath this, entity actor))
{
    TC(Wrath, this);

	precache_model("progs/w_ball.mdl");
	precache_model("progs/wrthgib1.mdl");
	precache_model("progs/wrthgib2.mdl");
	precache_model("progs/wrthgib3.mdl");

	precache_sound("wrath/watt.wav");
	precache_sound("wrath/wpain.wav");
	precache_sound("wrath/wdthc.wav");

    actor.health = 400;
	actor.yaw_speed = 35;
	
	actor.th_stand = wrath_stand1;
	actor.th_walk = wrath_walk01;
	actor.th_run = wrath_run01;
	actor.th_missile = wrath_attack;
	actor.th_pain = wrath_pain;
	actor.th_die = wrath_die02;

    return true;
}
#endif
