/*
==============================================================================

KNIGHT

==============================================================================
*/

$cd id1/models/knight2
$origin 0 0 24
$base base
$skin skin
// rogue
$skin statue2

#if 0
const int anim_hknight_stand1 = 0;
const int anim_hknight_stand2 = 1;
const int anim_hknight_stand3 = 2;
const int anim_hknight_stand4 = 3;
const int anim_hknight_stand5 = 4;
const int anim_hknight_stand6 = 5;
const int anim_hknight_stand7 = 6;
const int anim_hknight_stand8 = 7;
const int anim_hknight_stand9 = 8;

const int anim_hknight_walk1 = 9;
const int anim_hknight_walk2 = 10;
const int anim_hknight_walk3 = 11;
const int anim_hknight_walk4 = 12;
const int anim_hknight_walk5 = 13;
const int anim_hknight_walk6 = 14;
const int anim_hknight_walk7 = 15;
const int anim_hknight_walk8 = 16;
const int anim_hknight_walk9 = 17;
const int anim_hknight_walk10 = 18;
const int anim_hknight_walk11 = 19;
const int anim_hknight_walk12 = 20;
const int anim_hknight_walk13 = 21;
const int anim_hknight_walk14 = 22;
const int anim_hknight_walk15 = 23;
const int anim_hknight_walk16 = 24;
const int anim_hknight_walk17 = 25;
const int anim_hknight_walk18 = 26;
const int anim_hknight_walk19 = 27;
const int anim_hknight_walk20 = 28;

const int anim_hknight_run1 = 29;
const int anim_hknight_run2 = 30;
const int anim_hknight_run3 = 31;
const int anim_hknight_run4 = 32;
const int anim_hknight_run5 = 33;
const int anim_hknight_run6 = 34;
const int anim_hknight_run7 = 35;
const int anim_hknight_run8 = 36;

const int anim_hknight_pain1 = 37;
const int anim_hknight_pain2 = 38;
const int anim_hknight_pain3 = 39;
const int anim_hknight_pain4 = 40;
const int anim_hknight_pain5 = 41;

const int anim_hknight_death1 = 42;
const int anim_hknight_death2 = 43;
const int anim_hknight_death3 = 44;
const int anim_hknight_death4 = 45;
const int anim_hknight_death5 = 46;
const int anim_hknight_death6 = 47;
const int anim_hknight_death7 = 48;
const int anim_hknight_death8 = 49;
const int anim_hknight_death9 = 50;
const int anim_hknight_death10 = 51;
const int anim_hknight_death11 = 52;
const int anim_hknight_death12 = 53;

const int anim_hknight_deathb1 = 54;
const int anim_hknight_deathb2 = 55;
const int anim_hknight_deathb3 = 56;
const int anim_hknight_deathb4 = 57;
const int anim_hknight_deathb5 = 58;
const int anim_hknight_deathb6 = 59;
const int anim_hknight_deathb7 = 60;
const int anim_hknight_deathb8 = 61;
const int anim_hknight_deathb9 = 62;

const int anim_hknight_char_a1 = 63;
const int anim_hknight_char_a2 = 64;
const int anim_hknight_char_a3 = 65;
const int anim_hknight_char_a4 = 66;
const int anim_hknight_char_a5 = 67;
const int anim_hknight_char_a6 = 68;
const int anim_hknight_char_a7 = 69;
const int anim_hknight_char_a8 = 70;
const int anim_hknight_char_a9 = 71;
const int anim_hknight_char_a10 = 72;
const int anim_hknight_char_a11 = 73;
const int anim_hknight_char_a12 = 74;
const int anim_hknight_char_a13 = 75;
const int anim_hknight_char_a14 = 76;
const int anim_hknight_char_a15 = 77;
const int anim_hknight_char_a16 = 78;

const int anim_hknight_magica1 = 79;
const int anim_hknight_magica2 = 80;
const int anim_hknight_magica3 = 81;
const int anim_hknight_magica4 = 82;
const int anim_hknight_magica5 = 83;
const int anim_hknight_magica6 = 84;
const int anim_hknight_magica7 = 85;
const int anim_hknight_magica8 = 86;
const int anim_hknight_magica9 = 87;
const int anim_hknight_magica10 = 88;
const int anim_hknight_magica11 = 89;
const int anim_hknight_magica12 = 90;
const int anim_hknight_magica13 = 91;
const int anim_hknight_magica14 = 92;

const int anim_hknight_magicb1 = 93;
const int anim_hknight_magicb2 = 94;
const int anim_hknight_magicb3 = 95;
const int anim_hknight_magicb4 = 96;
const int anim_hknight_magicb5 = 97;
const int anim_hknight_magicb6 = 98;
const int anim_hknight_magicb7 = 99;
const int anim_hknight_magicb8 = 100;
const int anim_hknight_magicb9 = 101;
const int anim_hknight_magicb10 = 102;
const int anim_hknight_magicb11 = 103;
const int anim_hknight_magicb12 = 104;
const int anim_hknight_magicb13 = 105;

const int anim_hknight_char_b1 = 106;
const int anim_hknight_char_b2 = 107;
const int anim_hknight_char_b3 = 108;
const int anim_hknight_char_b4 = 109;
const int anim_hknight_char_b5 = 110;
const int anim_hknight_char_b6 = 111;

const int anim_hknight_slice1 = 112;
const int anim_hknight_slice2 = 113;
const int anim_hknight_slice3 = 114;
const int anim_hknight_slice4 = 115;
const int anim_hknight_slice5 = 116;
const int anim_hknight_slice6 = 117;
const int anim_hknight_slice7 = 118;
const int anim_hknight_slice8 = 119;
const int anim_hknight_slice9 = 120;
const int anim_hknight_slice10 = 121;

const int anim_hknight_smash1 = 122;
const int anim_hknight_smash2 = 123;
const int anim_hknight_smash3 = 124;
const int anim_hknight_smash4 = 125;
const int anim_hknight_smash5 = 126;
const int anim_hknight_smash6 = 127;
const int anim_hknight_smash7 = 128;
const int anim_hknight_smash8 = 129;
const int anim_hknight_smash9 = 130;
const int anim_hknight_smash10 = 131;
const int anim_hknight_smash11 = 132;

const int anim_hknight_w_attack1 = 133;
const int anim_hknight_w_attack2 = 134;
const int anim_hknight_w_attack3 = 135;
const int anim_hknight_w_attack4 = 136;
const int anim_hknight_w_attack5 = 137;
const int anim_hknight_w_attack6 = 138;
const int anim_hknight_w_attack7 = 139;
const int anim_hknight_w_attack8 = 140;
const int anim_hknight_w_attack9 = 141;
const int anim_hknight_w_attack10 = 142;
const int anim_hknight_w_attack11 = 143;
const int anim_hknight_w_attack12 = 144;
const int anim_hknight_w_attack13 = 145;
const int anim_hknight_w_attack14 = 146;
const int anim_hknight_w_attack15 = 147;
const int anim_hknight_w_attack16 = 148;
const int anim_hknight_w_attack17 = 149;
const int anim_hknight_w_attack18 = 150;
const int anim_hknight_w_attack19 = 151;
const int anim_hknight_w_attack20 = 152;
const int anim_hknight_w_attack21 = 153;
const int anim_hknight_w_attack22 = 154;

const int anim_hknight_magicc1 = 155;
const int anim_hknight_magicc2 = 156;
const int anim_hknight_magicc3 = 157;
const int anim_hknight_magicc4 = 158;
const int anim_hknight_magicc5 = 159;
const int anim_hknight_magicc6 = 160;
const int anim_hknight_magicc7 = 161;
const int anim_hknight_magicc8 = 162;
const int anim_hknight_magicc9 = 163;
const int anim_hknight_magicc10 = 164;
const int anim_hknight_magicc11 = 165;
#endif

const int anim_hknight_stand = 0; //'0 8 0'
const int anim_hknight_walk = 9; //'9 28 0'
const int anim_hknight_run = 29; //'29 36 0'
const int anim_hknight_pain = 37; //'37 41 0'
const int anim_hknight_death = 42; //'42 53 0'
const int anim_hknight_deathb = 54; //'54 62 0'
const int anim_hknight_char_a = 63; //'63 78 0'
const int anim_hknight_magica = 79; //'79 92 0'
const int anim_hknight_magicb = 93; //'93 105 0'
const int anim_hknight_char_b = 106; //'106 111 0'
const int anim_hknight_slice = 112; //'112 121 0'
const int anim_hknight_smash = 122; //'122 132 0'
const int anim_hknight_w_attack = 133; //'133 154 0'
const int anim_hknight_magicc = 155; //'155 165 0'

void hknight_char_a1(entity this);
void hknight_run1(entity this);
void hk_idle_sound(entity this);

void hknight_shot(entity this, float offset)
{
	vector offang = vectoangles(this.enemy.origin - this.origin);
	offang_y = offang_y + offset * 6;
	
	makevectors(offang);

	vector org = this.origin + this.mins + this.size*0.5 + v_forward * 20;

// set missile speed
	vector vec = normalize(v_forward);
	vec_z = 0 - vec_z +(random() - 0.5)*0.1;
	
	entity newmis = launch_spike(this, org, vec);
	newmis.classname = "knight_spike";
	_setmodel(newmis, "progs/k_spike.mdl");
	setsize(newmis, '0 0 0', '0 0 0');		
	newmis.velocity = vec*300;
	_sound(this, CH_WEAPON_SINGLE, "hknight/attack1.wav", 1, ATTN_NORM);
}

void CheckForCharge(entity this)
{
	// check for mad charge
	if(!this.enemy_visible)
		return;
	if(time < this.attack_finished)
		return;	
	if( fabs(this.origin_z - this.enemy.origin_z) > 20)
		return;		// too much height change
	if( vdist(this.origin - this.enemy.origin, <, 80) )
		return;		// use regular attack

// charge		
	SUB_AttackFinished(this, 2);
	hknight_char_a1(this);

}

void hknight_run1(entity this);
void CheckContinueCharge(entity this)
{
	if(time > this.attack_finished)
	{
		SUB_AttackFinished(this, 3);
		hknight_run1(this);
		return;		// done charging
	}
	if(random() > 0.5)
		_sound(this, CH_WEAPON_SINGLE, "knight/sword2.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "knight/sword1.wav", 1, ATTN_NORM);
}

//===========================================================================

void hknight_stand1(entity this);
void hknight_stand9(entity this) { set_animofs(this, anim_hknight_stand, 9, hknight_stand1); ai_stand(this); }
void hknight_stand8(entity this) { set_animofs(this, anim_hknight_stand, 8, hknight_stand9); ai_stand(this); }
void hknight_stand7(entity this) { set_animofs(this, anim_hknight_stand, 7, hknight_stand8); ai_stand(this); }
void hknight_stand6(entity this) { set_animofs(this, anim_hknight_stand, 6, hknight_stand7); ai_stand(this); }
void hknight_stand5(entity this) { set_animofs(this, anim_hknight_stand, 5, hknight_stand6); ai_stand(this); }
void hknight_stand4(entity this) { set_animofs(this, anim_hknight_stand, 4, hknight_stand5); ai_stand(this); }
void hknight_stand3(entity this) { set_animofs(this, anim_hknight_stand, 3, hknight_stand4); ai_stand(this); }
void hknight_stand2(entity this) { set_animofs(this, anim_hknight_stand, 2, hknight_stand3); ai_stand(this); }
void hknight_stand1(entity this) { set_animofs(this, anim_hknight_stand, 1, hknight_stand2); ai_stand(this); }

//===========================================================================

void hknight_walk1(entity this);
void hknight_walk20(entity this) { set_animofs(this, anim_hknight_walk, 20, hknight_walk1); ai_walk(this, 2); }
void hknight_walk19(entity this) { set_animofs(this, anim_hknight_walk, 19, hknight_walk20); ai_walk(this, 3); }
void hknight_walk18(entity this) { set_animofs(this, anim_hknight_walk, 18, hknight_walk19); ai_walk(this, 3); }
void hknight_walk17(entity this) { set_animofs(this, anim_hknight_walk, 17, hknight_walk18); ai_walk(this, 3); }
void hknight_walk16(entity this) { set_animofs(this, anim_hknight_walk, 16, hknight_walk17); ai_walk(this, 4); }
void hknight_walk15(entity this) { set_animofs(this, anim_hknight_walk, 15, hknight_walk16); ai_walk(this, 2); }
void hknight_walk14(entity this) { set_animofs(this, anim_hknight_walk, 14, hknight_walk15); ai_walk(this, 2); }
void hknight_walk13(entity this) { set_animofs(this, anim_hknight_walk, 13, hknight_walk14); ai_walk(this, 6); }
void hknight_walk12(entity this) { set_animofs(this, anim_hknight_walk, 12, hknight_walk13); ai_walk(this, 4); }
void hknight_walk11(entity this) { set_animofs(this, anim_hknight_walk, 11, hknight_walk12); ai_walk(this, 3); }
void hknight_walk10(entity this) { set_animofs(this, anim_hknight_walk, 10, hknight_walk11); ai_walk(this, 4); }
void hknight_walk9(entity this) { set_animofs(this, anim_hknight_walk, 9, hknight_walk10); ai_walk(this, 3); }
void hknight_walk8(entity this) { set_animofs(this, anim_hknight_walk, 8, hknight_walk9); ai_walk(this, 3); }
void hknight_walk7(entity this) { set_animofs(this, anim_hknight_walk, 7, hknight_walk8); ai_walk(this, 2); }
void hknight_walk6(entity this) { set_animofs(this, anim_hknight_walk, 6, hknight_walk7); ai_walk(this, 2); }
void hknight_walk5(entity this) { set_animofs(this, anim_hknight_walk, 5, hknight_walk6); ai_walk(this, 4); }
void hknight_walk4(entity this) { set_animofs(this, anim_hknight_walk, 4, hknight_walk5); ai_walk(this, 4); }
void hknight_walk3(entity this) { set_animofs(this, anim_hknight_walk, 3, hknight_walk4); ai_walk(this, 5); }
void hknight_walk2(entity this) { set_animofs(this, anim_hknight_walk, 2, hknight_walk3); ai_walk(this, 5); }
void hknight_walk1(entity this) { set_animofs(this, anim_hknight_walk, 1, hknight_walk2); hk_idle_sound(this); ai_walk(this, 2); }

//===========================================================================

void hknight_run1(entity this);
void hknight_run8(entity this) { set_animofs(this, anim_hknight_run, 8, hknight_run1); ai_run(this, 13); }
void hknight_run7(entity this) { set_animofs(this, anim_hknight_run, 7, hknight_run8); ai_run(this, 21); }
void hknight_run6(entity this) { set_animofs(this, anim_hknight_run, 6, hknight_run7); ai_run(this, 25); }
void hknight_run5(entity this) { set_animofs(this, anim_hknight_run, 5, hknight_run6); ai_run(this, 14); }
void hknight_run4(entity this) { set_animofs(this, anim_hknight_run, 4, hknight_run5); ai_run(this, 16); }
void hknight_run3(entity this) { set_animofs(this, anim_hknight_run, 3, hknight_run4); ai_run(this, 18); }
void hknight_run2(entity this) { set_animofs(this, anim_hknight_run, 2, hknight_run3); ai_run(this, 25); }
void hknight_run1(entity this) { set_animofs(this, anim_hknight_run, 1, hknight_run2); hk_idle_sound(this); ai_run(this, 20); CheckForCharge(this); }

//============================================================================

void hknight_pain5(entity this) { set_animofs(this, anim_hknight_pain, 5, hknight_run1); }
void hknight_pain4(entity this) { set_animofs(this, anim_hknight_pain, 4, hknight_pain5); }
void hknight_pain3(entity this) { set_animofs(this, anim_hknight_pain, 3, hknight_pain4); }
void hknight_pain2(entity this) { set_animofs(this, anim_hknight_pain, 2, hknight_pain3); }
void hknight_pain1(entity this)
{
	set_animofs(this, anim_hknight_pain, 1, hknight_pain2);
	if(!MP_MG && MP_ROGUE && (this.spawnflags & 2)) // statue
		_sound(this, CH_VOICE, "statue/pain.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "hknight/pain1.wav", 1, ATTN_NORM);
}

//============================================================================

void hknight_die12(entity this)
{
	set_animofs(this, anim_hknight_death, 12, hknight_die12);
	if(MP_MG && horde_ent)
	{
		setthink(this, MonsterFade);
		this.nextthink = time + FADETIME;
	}
	else
		CorpseThink(this);
}
void hknight_die11(entity this) { set_animofs(this, anim_hknight_death, 11, hknight_die12); }
void hknight_die10(entity this) { set_animofs(this, anim_hknight_death, 10, hknight_die11); }
void hknight_die9(entity this) { set_animofs(this, anim_hknight_death, 9, hknight_die10); ai_forward(this, 11); }
void hknight_die8(entity this) { set_animofs(this, anim_hknight_death, 8, hknight_die9); ai_forward(this, 10); }
void hknight_die7(entity this) { set_animofs(this, anim_hknight_death, 7, hknight_die8); }
void hknight_die6(entity this) { set_animofs(this, anim_hknight_death, 6, hknight_die7); }
void hknight_die5(entity this) { set_animofs(this, anim_hknight_death, 5, hknight_die6); }
void hknight_die4(entity this) { set_animofs(this, anim_hknight_death, 4, hknight_die5); }
void hknight_die3(entity this) { set_animofs(this, anim_hknight_death, 3, hknight_die4); this.solid = SOLID_NOT; ai_forward(this, 7); }
void hknight_die2(entity this) { set_animofs(this, anim_hknight_death, 2, hknight_die3); ai_forward(this, 8); }
void hknight_die1(entity this) { set_animofs(this, anim_hknight_death, 1, hknight_die2); ai_forward(this, 10); }

void hknight_dieb9(entity this)
{
	set_animofs(this, anim_hknight_deathb, 9, hknight_dieb9);
	if(MP_MG && horde_ent)
	{
		setthink(this, MonsterFade);
		this.nextthink = time + FADETIME;
	}
	else
		CorpseThink(this);
}
void hknight_dieb8(entity this) { set_animofs(this, anim_hknight_deathb, 8, hknight_dieb9); }
void hknight_dieb7(entity this) { set_animofs(this, anim_hknight_deathb, 7, hknight_dieb8); }
void hknight_dieb6(entity this) { set_animofs(this, anim_hknight_deathb, 6, hknight_dieb7); }
void hknight_dieb5(entity this) { set_animofs(this, anim_hknight_deathb, 5, hknight_dieb6); }
void hknight_dieb4(entity this) { set_animofs(this, anim_hknight_deathb, 4, hknight_dieb5); }
void hknight_dieb3(entity this) { set_animofs(this, anim_hknight_deathb, 3, hknight_dieb4); this.solid = SOLID_NOT; }
void hknight_dieb2(entity this) { set_animofs(this, anim_hknight_deathb, 2, hknight_dieb3); }
void hknight_dieb1(entity this) { set_animofs(this, anim_hknight_deathb, 1, hknight_dieb2); }

void hknight_die(entity this, entity inflictor, entity attacker)
{
// check for gib
	if(this.health < -40)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, "progs/h_hellkn.mdl", this.health);
		if(!MP_MG && MP_ROGUE && (this.spawnflags & 2)) // statue
		{
			ThrowGib(this, "progs/statgib1.mdl", this.health);
			ThrowGib(this, "progs/statgib2.mdl", this.health);
			ThrowGib(this, "progs/statgib3.mdl", this.health);
		}
		else
		{
			ThrowGib(this, "progs/gib1.mdl", this.health);
			ThrowGib(this, "progs/gib2.mdl", this.health);
			ThrowGib(this, "progs/gib3.mdl", this.health);
		}
			
		return;
	}

// regular death
	if(!MP_MG && MP_ROGUE && (this.spawnflags & 2)) // statue
		_sound(this, CH_VOICE, "statue/death.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "hknight/death1.wav", 1, ATTN_NORM);
	if(random() > 0.5)
		hknight_die1(this);
	else
		hknight_dieb1(this);
}


//============================================================================

void hknight_magica14(entity this) { set_animofs(this, anim_hknight_magica, 14, hknight_run1); ai_face(this); }
void hknight_magica13(entity this) { set_animofs(this, anim_hknight_magica, 13, hknight_magica14); ai_face(this); }
void hknight_magica12(entity this) { set_animofs(this, anim_hknight_magica, 12, hknight_magica13); hknight_shot(this, 3); }
void hknight_magica11(entity this) { set_animofs(this, anim_hknight_magica, 11, hknight_magica12); hknight_shot(this, 2); }
void hknight_magica10(entity this) { set_animofs(this, anim_hknight_magica, 10, hknight_magica11); hknight_shot(this, 1); }
void hknight_magica9(entity this) { set_animofs(this, anim_hknight_magica, 9, hknight_magica10); hknight_shot(this, 0); }
void hknight_magica8(entity this) { set_animofs(this, anim_hknight_magica, 8, hknight_magica9); hknight_shot(this, -1); }
void hknight_magica7(entity this) { set_animofs(this, anim_hknight_magica, 7, hknight_magica8); hknight_shot(this, -2); }
void hknight_magica6(entity this) { set_animofs(this, anim_hknight_magica, 6, hknight_magica7); ai_face(this); }
void hknight_magica5(entity this) { set_animofs(this, anim_hknight_magica, 5, hknight_magica6); ai_face(this); }
void hknight_magica4(entity this) { set_animofs(this, anim_hknight_magica, 4, hknight_magica5); ai_face(this); }
void hknight_magica3(entity this) { set_animofs(this, anim_hknight_magica, 3, hknight_magica4); ai_face(this); }
void hknight_magica2(entity this) { set_animofs(this, anim_hknight_magica, 2, hknight_magica3); ai_face(this); }
void hknight_magica1(entity this) { set_animofs(this, anim_hknight_magica, 1, hknight_magica2); ai_face(this); }

//============================================================================

void hknight_magicb13(entity this) { set_animofs(this, anim_hknight_magicb, 13, hknight_run1); ai_face(this); }
void hknight_magicb12(entity this) { set_animofs(this, anim_hknight_magicb, 12, hknight_magicb13); hknight_shot(this, 3); }
void hknight_magicb11(entity this) { set_animofs(this, anim_hknight_magicb, 11, hknight_magicb12); hknight_shot(this, 2); }
void hknight_magicb10(entity this) { set_animofs(this, anim_hknight_magicb, 10, hknight_magicb11); hknight_shot(this, 1); }
void hknight_magicb9(entity this) { set_animofs(this, anim_hknight_magicb, 9, hknight_magicb10); hknight_shot(this, 0); }
void hknight_magicb8(entity this) { set_animofs(this, anim_hknight_magicb, 8, hknight_magicb9); hknight_shot(this, -1); }
void hknight_magicb7(entity this) { set_animofs(this, anim_hknight_magicb, 7, hknight_magicb8); hknight_shot(this, -2); }
void hknight_magicb6(entity this) { set_animofs(this, anim_hknight_magicb, 6, hknight_magicb7); ai_face(this); }
void hknight_magicb5(entity this) { set_animofs(this, anim_hknight_magicb, 5, hknight_magicb6); ai_face(this); }
void hknight_magicb4(entity this) { set_animofs(this, anim_hknight_magicb, 4, hknight_magicb5); ai_face(this); }
void hknight_magicb3(entity this) { set_animofs(this, anim_hknight_magicb, 3, hknight_magicb4); ai_face(this); }
void hknight_magicb2(entity this) { set_animofs(this, anim_hknight_magicb, 2, hknight_magicb3); ai_face(this); }
void hknight_magicb1(entity this) { set_animofs(this, anim_hknight_magicb, 1, hknight_magicb2); ai_face(this); }

//============================================================================

void hknight_magicc11(entity this) { set_animofs(this, anim_hknight_magicc, 11, hknight_run1); hknight_shot(this, 3); }
void hknight_magicc10(entity this) { set_animofs(this, anim_hknight_magicc, 10, hknight_magicc11); hknight_shot(this, 2); }
void hknight_magicc9(entity this) { set_animofs(this, anim_hknight_magicc, 9, hknight_magicc10); hknight_shot(this, 1); }
void hknight_magicc8(entity this) { set_animofs(this, anim_hknight_magicc, 8, hknight_magicc9); hknight_shot(this, 0); }
void hknight_magicc7(entity this) { set_animofs(this, anim_hknight_magicc, 7, hknight_magicc8); hknight_shot(this, -1); }
void hknight_magicc6(entity this) { set_animofs(this, anim_hknight_magicc, 6, hknight_magicc7); hknight_shot(this, -2); }
void hknight_magicc5(entity this) { set_animofs(this, anim_hknight_magicc, 5, hknight_magicc6); ai_face(this); }
void hknight_magicc4(entity this) { set_animofs(this, anim_hknight_magicc, 4, hknight_magicc5); ai_face(this); }
void hknight_magicc3(entity this) { set_animofs(this, anim_hknight_magicc, 3, hknight_magicc4); ai_face(this); }
void hknight_magicc2(entity this) { set_animofs(this, anim_hknight_magicc, 2, hknight_magicc3); ai_face(this); }
void hknight_magicc1(entity this) { set_animofs(this, anim_hknight_magicc, 1, hknight_magicc2); ai_face(this); }

//===========================================================================

void hknight_char_a16(entity this) { set_animofs(this, anim_hknight_char_a, 16, hknight_run1); ai_charge(this, 13); }
void hknight_char_a15(entity this) { set_animofs(this, anim_hknight_char_a, 15, hknight_char_a16); ai_charge(this, 21); }
void hknight_char_a14(entity this) { set_animofs(this, anim_hknight_char_a, 14, hknight_char_a15); ai_charge(this, 25); }
void hknight_char_a13(entity this) { set_animofs(this, anim_hknight_char_a, 13, hknight_char_a14); ai_charge(this, 14); }
void hknight_char_a12(entity this) { set_animofs(this, anim_hknight_char_a, 12, hknight_char_a13); ai_charge(this, 16); }
void hknight_char_a11(entity this) { set_animofs(this, anim_hknight_char_a, 11, hknight_char_a12); ai_charge(this, 18); ai_melee(this); }
void hknight_char_a10(entity this) { set_animofs(this, anim_hknight_char_a, 10, hknight_char_a11); ai_charge(this, 20); ai_melee(this); }
void hknight_char_a9(entity this) { set_animofs(this, anim_hknight_char_a, 9, hknight_char_a10); ai_charge(this, 20); ai_melee(this); }
void hknight_char_a8(entity this) { set_animofs(this, anim_hknight_char_a, 8, hknight_char_a9); ai_charge(this, 13); ai_melee(this); }
void hknight_char_a7(entity this) { set_animofs(this, anim_hknight_char_a, 7, hknight_char_a8); ai_charge(this, 21); ai_melee(this); }
void hknight_char_a6(entity this) { set_animofs(this, anim_hknight_char_a, 6, hknight_char_a7); ai_charge(this, 20); ai_melee(this); }
void hknight_char_a5(entity this) { set_animofs(this, anim_hknight_char_a, 5, hknight_char_a6); ai_charge(this, 14); }
void hknight_char_a4(entity this) { set_animofs(this, anim_hknight_char_a, 4, hknight_char_a5); ai_charge(this, 16); }
void hknight_char_a3(entity this) { set_animofs(this, anim_hknight_char_a, 3, hknight_char_a4); ai_charge(this, 18); }
void hknight_char_a2(entity this) { set_animofs(this, anim_hknight_char_a, 2, hknight_char_a3); ai_charge(this, 25); }
void hknight_char_a1(entity this) { set_animofs(this, anim_hknight_char_a, 1, hknight_char_a2); ai_charge(this, 20); }

//===========================================================================

void hknight_char_b1(entity this);
void hknight_char_b6(entity this) { set_animofs(this, anim_hknight_char_b, 6, hknight_char_b1); ai_charge(this, 8); ai_melee(this); }
void hknight_char_b5(entity this) { set_animofs(this, anim_hknight_char_b, 5, hknight_char_b6); ai_charge(this, 18); ai_melee(this); }
void hknight_char_b4(entity this) { set_animofs(this, anim_hknight_char_b, 4, hknight_char_b5); ai_charge(this, 22); ai_melee(this); }
void hknight_char_b3(entity this) { set_animofs(this, anim_hknight_char_b, 3, hknight_char_b4); ai_charge(this, 12); ai_melee(this); }
void hknight_char_b2(entity this) { set_animofs(this, anim_hknight_char_b, 2, hknight_char_b3); ai_charge(this, 17); ai_melee(this); }
void hknight_char_b1(entity this) { set_animofs(this, anim_hknight_char_b, 1, hknight_char_b2); CheckContinueCharge(this); ai_charge(this, 23); ai_melee(this); }

//===========================================================================

void hknight_slice10(entity this) { set_animofs(this, anim_hknight_slice, 10, hknight_run1); ai_charge(this, 3); }
void hknight_slice9(entity this) { set_animofs(this, anim_hknight_slice, 9, hknight_slice10); ai_melee(this); }
void hknight_slice8(entity this) { set_animofs(this, anim_hknight_slice, 8, hknight_slice9); ai_charge(this, 2); ai_melee(this); }
void hknight_slice7(entity this) { set_animofs(this, anim_hknight_slice, 7, hknight_slice8); ai_charge(this, 8); ai_melee(this); }
void hknight_slice6(entity this) { set_animofs(this, anim_hknight_slice, 6, hknight_slice7); ai_charge(this, 15); ai_melee(this); }
void hknight_slice5(entity this) { set_animofs(this, anim_hknight_slice, 5, hknight_slice6); ai_charge(this, 7); ai_melee(this); }
void hknight_slice4(entity this) { set_animofs(this, anim_hknight_slice, 4, hknight_slice5); ai_charge(this, 4); }
void hknight_slice3(entity this) { set_animofs(this, anim_hknight_slice, 3, hknight_slice4); ai_charge(this, 13); }
void hknight_slice2(entity this) { set_animofs(this, anim_hknight_slice, 2, hknight_slice3); ai_charge(this, 6); }
void hknight_slice1(entity this) { set_animofs(this, anim_hknight_slice, 1, hknight_slice2); ai_charge(this, 9); }

//===========================================================================

void hknight_smash11(entity this) { set_animofs(this, anim_hknight_smash, 11, hknight_run1); ai_charge(this, 0); }
void hknight_smash10(entity this) { set_animofs(this, anim_hknight_smash, 10, hknight_smash11); ai_charge(this, 0); }
void hknight_smash9(entity this) { set_animofs(this, anim_hknight_smash, 9, hknight_smash10); ai_charge(this, 3); ai_melee(this); }
void hknight_smash8(entity this) { set_animofs(this, anim_hknight_smash, 8, hknight_smash9); ai_charge(this, 2); ai_melee(this); }
void hknight_smash7(entity this) { set_animofs(this, anim_hknight_smash, 7, hknight_smash8); ai_charge(this, 12); ai_melee(this); }
void hknight_smash6(entity this) { set_animofs(this, anim_hknight_smash, 6, hknight_smash7); ai_charge(this, 7); ai_melee(this); }
void hknight_smash5(entity this) { set_animofs(this, anim_hknight_smash, 5, hknight_smash6); ai_charge(this, 10); ai_melee(this); }
void hknight_smash4(entity this) { set_animofs(this, anim_hknight_smash, 4, hknight_smash5); ai_charge(this, 11); }
void hknight_smash3(entity this) { set_animofs(this, anim_hknight_smash, 3, hknight_smash4); ai_charge(this, 9); }
void hknight_smash2(entity this) { set_animofs(this, anim_hknight_smash, 2, hknight_smash3); ai_charge(this, 13); }
void hknight_smash1(entity this) { set_animofs(this, anim_hknight_smash, 1, hknight_smash2); ai_charge(this, 1); }

//============================================================================

void hknight_watk22(entity this) { set_animofs(this, anim_hknight_w_attack, 22, hknight_run1); ai_charge(this, 3); }
void hknight_watk21(entity this) { set_animofs(this, anim_hknight_w_attack, 21, hknight_watk22); ai_charge(this, 7); }
void hknight_watk20(entity this) { set_animofs(this, anim_hknight_w_attack, 20, hknight_watk21); ai_charge(this, 6); }
void hknight_watk19(entity this) { set_animofs(this, anim_hknight_w_attack, 19, hknight_watk20); ai_charge(this, 4); ai_melee(this); }
void hknight_watk18(entity this) { set_animofs(this, anim_hknight_w_attack, 18, hknight_watk19); ai_charge(this, 3); ai_melee(this); }
void hknight_watk17(entity this) { set_animofs(this, anim_hknight_w_attack, 17, hknight_watk18); ai_charge(this, 1); ai_melee(this); }
void hknight_watk16(entity this) { set_animofs(this, anim_hknight_w_attack, 16, hknight_watk17); ai_charge(this, 1); }
void hknight_watk15(entity this) { set_animofs(this, anim_hknight_w_attack, 15, hknight_watk16); ai_charge(this, 0); }
void hknight_watk14(entity this) { set_animofs(this, anim_hknight_w_attack, 14, hknight_watk15); ai_charge(this, 0); }
void hknight_watk13(entity this) { set_animofs(this, anim_hknight_w_attack, 13, hknight_watk14); ai_charge(this, 0); }
void hknight_watk12(entity this) { set_animofs(this, anim_hknight_w_attack, 12, hknight_watk13); ai_charge(this, 2); ai_melee(this); }
void hknight_watk11(entity this) { set_animofs(this, anim_hknight_w_attack, 11, hknight_watk12); ai_charge(this, 2); ai_melee(this); }
void hknight_watk10(entity this) { set_animofs(this, anim_hknight_w_attack, 10, hknight_watk11); ai_charge(this, 3); ai_melee(this); }
void hknight_watk9(entity this) { set_animofs(this, anim_hknight_w_attack, 9, hknight_watk10); ai_charge(this, 5); }
void hknight_watk8(entity this) { set_animofs(this, anim_hknight_w_attack, 8, hknight_watk9); ai_charge(this, 4); }
void hknight_watk7(entity this) { set_animofs(this, anim_hknight_w_attack, 7, hknight_watk8); ai_charge(this, 1); }
void hknight_watk6(entity this) { set_animofs(this, anim_hknight_w_attack, 6, hknight_watk7); ai_melee(this); }
void hknight_watk5(entity this) { set_animofs(this, anim_hknight_w_attack, 5, hknight_watk6); ai_melee(this); }
void hknight_watk4(entity this) { set_animofs(this, anim_hknight_w_attack, 4, hknight_watk5); ai_melee(this); }
void hknight_watk3(entity this) { set_animofs(this, anim_hknight_w_attack, 3, hknight_watk4); ai_charge(this, 0); }
void hknight_watk2(entity this) { set_animofs(this, anim_hknight_w_attack, 2, hknight_watk3); ai_charge(this, 0); }
void hknight_watk1(entity this) { set_animofs(this, anim_hknight_w_attack, 1, hknight_watk2); ai_charge(this, 2); }

//============================================================================

void hk_idle_sound(entity this)
{
	if(random() < 0.2)
	{
		if(!MP_MG && MP_ROGUE && (this.spawnflags & 2)) // statue
			_sound(this, CH_VOICE, "statue/idle.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "hknight/idle.wav", 1, ATTN_NORM);
	}
}

void hknight_pain(entity this, entity attacker, float damage)
{
	if(MP_IMPEL && (random() * 30) > damage)
		return;

	if(this.pain_finished > time)
		return;

	if(!MP_MG && MP_ROGUE && (this.spawnflags & 2)) // statue
		_sound(this, CH_VOICE, "statue/pain.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "hknight/pain1.wav", 1, ATTN_NORM);

	if(!MP_IMPEL && time - this.pain_finished > 5)
	{	// allways go into pain frame if it has been a while
		hknight_pain1(this);
		this.pain_finished = time + 1;
		return;
	}
	
	if(!MP_IMPEL && (random()*30 > damage) )
		return;		// didn't flinch

	this.pain_finished = time + ((MP_IMPEL) ? 2 : 1);
	hknight_pain1(this);
}

.int hknight_type;

void hknight_melee(entity this)
{
	this.hknight_type = this.hknight_type + 1;

	_sound(this, CH_WEAPON_SINGLE, "hknight/slash1.wav", 1, ATTN_NORM);
	if(this.hknight_type == 1)
		hknight_slice1(this);
	else if(this.hknight_type == 2)
		hknight_smash1(this);
	else if(this.hknight_type == 3)
	{
		hknight_watk1(this);
		this.hknight_type = 0;
	}
}

void hknight_pause(entity this, entity actor, entity trigger)
{
	_sound(this, CH_VOICE, "statue/see.wav", 1, ATTN_NORM);

	this.takedamage = DAMAGE_AIM;
	this.th_stand = hknight_stand1;
	this.th_walk = hknight_walk1;
	this.th_run = hknight_run1;
	this.th_melee = hknight_melee;
	this.th_missile = hknight_magicc1;
	this.th_pain = hknight_pain;
	this.th_die = hknight_die;
	this.use = func_null;

	this.enemy = actor;
	this.nextthink = time + 0.1;
	setthink(this, FoundTarget);

	this.delay = 0;
}

void hknight_pause1(entity this)
{
	this.takedamage = DAMAGE_NO;
	this.use = hknight_pause;
	setthink(this, hknight_pause1);
	this.nextthink = time + 0.1;
}

string hknight_sight(entity this) { if(!MP_ROGUE || !this.skin) return "hknight/sight1.wav"; else return string_null; }
string hknight_deathmessage(entity this) { return "was slain by a Death Knight"; }

/*QUAKED monster_hell_knight(1 0 0)(-16 -16 -24)(16 16 40) Ambush Statue

Statue - (rogue only) select this to use the stone skin and have him frozen in place.

delay: time from sight to attack (default 5)
frame: frame to be frozen in. (default 73)
*/
spawnfunc(monster_dknight);
spawnfunc(monster_hell_knight)
{
	if(deathmatch) { delete(this); return; }
	if(MP_IMPEL && coop == 2 && orig_random(this) < 0.5)
	{
		this.classname = "monster_dknight";
		spawnfunc_monster_dknight(this);
		return;
	}
	precache_model2("progs/hknight.mdl");
	precache_model2("progs/k_spike.mdl");
	precache_model2("progs/h_hellkn.mdl");

	
	if(!MP_MG && MP_ROGUE && (this.spawnflags & 2)) // statue
	{
		precache_model("progs/statgib1.mdl");
		precache_model("progs/statgib2.mdl");
		precache_model("progs/statgib3.mdl");
		precache_sound("statue/see.wav");
		precache_sound("statue/idle.wav");
		precache_sound("statue/pain.wav");
		precache_sound("statue/death.wav");
	}
	else
	{
		precache_sound2("hknight/death1.wav");
		precache_sound2("hknight/pain1.wav");
		precache_sound2("hknight/sight1.wav");
		precache_sound2("hknight/idle.wav");
	}
	precache_sound2("hknight/attack1.wav");
	precache_sound("hknight/hit.wav");		// used by C code, so don't sound2
	precache_sound2("hknight/slash1.wav");
	precache_sound2("hknight/grunt.wav");

	precache_sound("knight/sword1.wav");
	precache_sound("knight/sword2.wav");
	
	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);

	_setmodel(this, "progs/hknight.mdl");

	setsize(this, '-16 -16 -24', '16 16 40');
	this.health = 250;

	if(!MP_MG && MP_ROGUE && (this.spawnflags & 2)) // statue
	{
		if(this.frame == 0)
			this.frame = 73;
		this.skin = 1;

		if(!this.targetname || this.targetname == "")
		{
			LOG_DEBUGF("statue %s not targeted at %v\n", this.classname, this.origin);
			return;
		}

		this.use = hknight_pause;
		this.th_stand = hknight_pause1;
		this.th_walk = hknight_pause1;
		this.th_run = hknight_pause1;
	}
	else
	{
		this.th_stand = hknight_stand1;
		this.th_walk = hknight_walk1;
		this.th_run = hknight_run1;
		this.th_melee = hknight_melee;
		this.th_missile = hknight_magicc1;
		this.th_pain = hknight_pain;
		this.th_die = hknight_die;
	}

	this.sightsound = hknight_sight;
	this.deathmessage = hknight_deathmessage;
	this.gibmodel = "progs/dknight.mdl";

	monster_start(this, 0);

	if(!MP_MG && MP_ROGUE && (this.spawnflags & 2))
		this.use = hknight_pause; // do this AFTER monster_start, so .use isn't overridden!
}
