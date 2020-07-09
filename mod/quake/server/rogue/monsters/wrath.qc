$skin wrthskin

// unused?
//const int anim_wrath_wrthfrme = 0;

const int anim_wrath_wrthwk01 = 1;
//const int anim_wrath_wrthwk02 = 2;
//const int anim_wrath_wrthwk03 = 3;
//const int anim_wrath_wrthwk04 = 4;
//const int anim_wrath_wrthwk05 = 5;
//const int anim_wrath_wrthwk06 = 6;
//const int anim_wrath_wrthwk07 = 7;
//const int anim_wrath_wrthwk08 = 8;
//const int anim_wrath_wrthwk09 = 9;
//const int anim_wrath_wrthwk10 = 10;
//const int anim_wrath_wrthwk11 = 11;
//const int anim_wrath_wrthwk12 = 12;

const int anim_wrath_wrthaa01 = 13;
//const int anim_wrath_wrthaa02 = 14;
//const int anim_wrath_wrthaa03 = 15;
//const int anim_wrath_wrthaa04 = 16;
//const int anim_wrath_wrthaa05 = 17;
//const int anim_wrath_wrthaa06 = 18;
//const int anim_wrath_wrthaa07 = 19;
//const int anim_wrath_wrthaa08 = 20;
//const int anim_wrath_wrthaa09 = 21;
//const int anim_wrath_wrthaa10 = 22;
//const int anim_wrath_wrthaa11 = 23;
//const int anim_wrath_wrthaa12 = 24;
//const int anim_wrath_wrthaa13 = 25;
//const int anim_wrath_wrthaa14 = 26;

const int anim_wrath_wrthab01 = 27;
//const int anim_wrath_wrthab02 = 28;
//const int anim_wrath_wrthab03 = 29;
//const int anim_wrath_wrthab04 = 30;
//const int anim_wrath_wrthab05 = 31;
//const int anim_wrath_wrthab06 = 32;
//const int anim_wrath_wrthab07 = 33;
//const int anim_wrath_wrthab08 = 34;
//const int anim_wrath_wrthab09 = 35;
//const int anim_wrath_wrthab10 = 36;
//const int anim_wrath_wrthab11 = 37;
//const int anim_wrath_wrthab12 = 38;
//const int anim_wrath_wrthab13 = 39;

const int anim_wrath_wrthac01 = 40;
//const int anim_wrath_wrthac02 = 41;
//const int anim_wrath_wrthac03 = 42;
//const int anim_wrath_wrthac04 = 43;
//const int anim_wrath_wrthac05 = 44;
//const int anim_wrath_wrthac06 = 45;
//const int anim_wrath_wrthac07 = 46;
//const int anim_wrath_wrthac08 = 47;
//const int anim_wrath_wrthac09 = 48;
//const int anim_wrath_wrthac10 = 49;
//const int anim_wrath_wrthac11 = 50;
//const int anim_wrath_wrthac12 = 51;
//const int anim_wrath_wrthac13 = 52;
//const int anim_wrath_wrthac14 = 53;
//const int anim_wrath_wrthac15 = 54;

const int anim_wrath_wrthpa01 = 55;
//const int anim_wrath_wrthpa02 = 56;
//const int anim_wrath_wrthpa03 = 57;
//const int anim_wrath_wrthpa04 = 58;
//const int anim_wrath_wrthpa05 = 59;
//const int anim_wrath_wrthpa06 = 60;

const int anim_wrath_wrthpb01 = 61;
//const int anim_wrath_wrthpb02 = 62;
//const int anim_wrath_wrthpb03 = 63;
//const int anim_wrath_wrthpb04 = 64;
//const int anim_wrath_wrthpb05 = 65;
//const int anim_wrath_wrthpb06 = 66;
//const int anim_wrath_wrthpb07 = 67;
//const int anim_wrath_wrthpb08 = 68;
//const int anim_wrath_wrthpb09 = 69;
//const int anim_wrath_wrthpb10 = 70;
//const int anim_wrath_wrthpb11 = 71;

const int anim_wrath_wrthdt01 = 72;
//const int anim_wrath_wrthdt02 = 73;
//const int anim_wrath_wrthdt03 = 74;
//const int anim_wrath_wrthdt04 = 75;
//const int anim_wrath_wrthdt05 = 76;
//const int anim_wrath_wrthdt06 = 77;
//const int anim_wrath_wrthdt07 = 78;
//const int anim_wrath_wrthdt08 = 79;
//const int anim_wrath_wrthdt09 = 80;
//const int anim_wrath_wrthdt10 = 81;
//const int anim_wrath_wrthdt11 = 82;
//const int anim_wrath_wrthdt12 = 83;
//const int anim_wrath_wrthdt13 = 84;
//const int anim_wrath_wrthdt14 = 85;
//const int anim_wrath_wrthdt15 = 86;

void WrathMissileTouch(entity this, entity toucher);
void WrathHome(entity this);
void WrathMissile(entity this, int AttackNumber);

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

void wrath_pain(entity this, entity attacker, float damage)
{
	if(this.pain_finished > time)
		return;

	float r = random();
	
	if(r > 0.1)
	{
		this.pain_finished = time + 0.5;
		return;
	}
			
	if(r < 0.07)
		wrath_pn_a01(this);
	else 
		wrath_pn_b01(this);

	this.pain_finished = time + 3;
	_sound(this, CH_VOICE, "wrath/wpain.wav", 1, ATTN_NORM);
}

void wrath_die15(entity this)
{
	set_animofs(this, anim_wrath_wrthdt01, 15, wrath_die15);

	ThrowGib(this, "progs/wrthgib1.mdl", this.health);
	ThrowGib(this, "progs/wrthgib2.mdl", this.health);
	ThrowGib(this, "progs/wrthgib3.mdl", this.health);
	T_RadiusDamage(this, this, 80, NULL);

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
void wrath_die02(entity this, entity inflictor, entity attacker) { set_animofs(this, anim_wrath_wrthdt01, 2, wrath_die03); _sound(this, CH_VOICE, "wrath/wdthc.wav", 1, ATTN_NORM); }

string wrath_sight(entity this) { return "wrath/wsee.wav"; }
string wrath_deathmessage(entity this) { return "was disintegrated by a Wrath"; }

/*QUAKED monster_wrath (1 0 0) (-16 -16 -24) (16 16 32) Ambush
*/
spawnfunc(monster_wrath)
{
	if(!MP_ROGUE) { delete(this); return; }
	if(deathmatch) { delete(this); return; }

	precache_model("progs/wrath.mdl");
	precache_model("progs/w_ball.mdl");
	precache_model("progs/wrthgib1.mdl");
	precache_model("progs/wrthgib2.mdl");
	precache_model("progs/wrthgib3.mdl");
	
	precache_sound("wrath/wsee.wav");
	precache_sound("wrath/watt.wav");
	precache_sound("wrath/wpain.wav");
	precache_sound("wrath/wdthc.wav");
	
	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);
	
	_setmodel(this, "progs/wrath.mdl");

	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);

	this.health = 400;
	this.yaw_speed = 35;
	
	this.th_stand = wrath_stand1;
	this.th_walk = wrath_walk01;
	this.th_run = wrath_run01;
	this.th_missile = wrath_attack;
	this.th_pain = wrath_pain;
	this.th_die = wrath_die02;

	this.sightsound = wrath_sight;
	this.deathmessage = wrath_deathmessage;

	monster_start(this, FL_FLY);
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
	missile.owner = this;
	missile.solid = SOLID_BBOX;
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
	settouch(missile, WrathMissileTouch);
	missile.nextthink = time + 0.1;
	setthink(missile, WrathHome);
	
	this.attack_finished = time + 2;
}

void WrathHome(entity this)
{
	if(this.enemy.health < 1)
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
	if(toucher == this.owner ||
		toucher.classname == "monster_wrath" || 
		toucher.classname == "monster_super_wrath")
	{
		delete(this);
		return;		// don't explode on any wraths
	}

	if(toucher.classname == "monster_zombie")
		T_Damage(toucher, this, this, 110);	
		
	T_RadiusDamage(this, this.owner, 20, NULL);
	_sound(this, CH_WEAPON_SINGLE, "weapons/r_exp3.wav", 1, ATTN_NORM);

	te_explosion(this.origin);

	this.velocity = '0 0 0';
	settouch(this, func_null);
	_setmodel(this, "progs/s_explod.spr");
	this.solid = SOLID_NOT;
	s_explode1(this);
}
