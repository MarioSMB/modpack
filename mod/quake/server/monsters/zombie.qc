/*
==============================================================================

ZOMBIE

==============================================================================
*/
$cd id1/models/zombie

$origin	0 0 24

$base base
$skin skin

const int anim_zombie_stand1 = 0;
const int anim_zombie_stand2 = 1;
const int anim_zombie_stand3 = 2;
const int anim_zombie_stand4 = 3;
const int anim_zombie_stand5 = 4;
const int anim_zombie_stand6 = 5;
const int anim_zombie_stand7 = 6;
const int anim_zombie_stand8 = 7;
const int anim_zombie_stand9 = 8;
const int anim_zombie_stand10 = 9;
const int anim_zombie_stand11 = 10;
const int anim_zombie_stand12 = 11;
const int anim_zombie_stand13 = 12;
const int anim_zombie_stand14 = 13;
const int anim_zombie_stand15 = 14;

const int anim_zombie_walk1 = 15;
const int anim_zombie_walk2 = 16;
const int anim_zombie_walk3 = 17;
const int anim_zombie_walk4 = 18;
const int anim_zombie_walk5 = 19;
const int anim_zombie_walk6 = 20;
const int anim_zombie_walk7 = 21;
const int anim_zombie_walk8 = 22;
const int anim_zombie_walk9 = 23;
const int anim_zombie_walk10 = 24;
const int anim_zombie_walk11 = 25;
const int anim_zombie_walk12 = 26;
const int anim_zombie_walk13 = 27;
const int anim_zombie_walk14 = 28;
const int anim_zombie_walk15 = 29;
const int anim_zombie_walk16 = 30;
const int anim_zombie_walk17 = 31;
const int anim_zombie_walk18 = 32;
const int anim_zombie_walk19 = 33;

const int anim_zombie_run1 = 34;
const int anim_zombie_run2 = 35;
const int anim_zombie_run3 = 36;
const int anim_zombie_run4 = 37;
const int anim_zombie_run5 = 38;
const int anim_zombie_run6 = 39;
const int anim_zombie_run7 = 40;
const int anim_zombie_run8 = 41;
const int anim_zombie_run9 = 42;
const int anim_zombie_run10 = 43;
const int anim_zombie_run11 = 44;
const int anim_zombie_run12 = 45;
const int anim_zombie_run13 = 46;
const int anim_zombie_run14 = 47;
const int anim_zombie_run15 = 48;
const int anim_zombie_run16 = 49;
const int anim_zombie_run17 = 50;
const int anim_zombie_run18 = 51;

const int anim_zombie_atta1 = 52;
const int anim_zombie_atta2 = 53;
const int anim_zombie_atta3 = 54;
const int anim_zombie_atta4 = 55;
const int anim_zombie_atta5 = 56;
const int anim_zombie_atta6 = 57;
const int anim_zombie_atta7 = 58;
const int anim_zombie_atta8 = 59;
const int anim_zombie_atta9 = 60;
const int anim_zombie_atta10 = 61;
const int anim_zombie_atta11 = 62;
const int anim_zombie_atta12 = 63;
const int anim_zombie_atta13 = 64;

const int anim_zombie_attb1 = 65;
const int anim_zombie_attb2 = 66;
const int anim_zombie_attb3 = 67;
const int anim_zombie_attb4 = 68;
const int anim_zombie_attb5 = 69;
const int anim_zombie_attb6 = 70;
const int anim_zombie_attb7 = 71;
const int anim_zombie_attb8 = 72;
const int anim_zombie_attb9 = 73;
const int anim_zombie_attb10 = 74;
const int anim_zombie_attb11 = 75;
const int anim_zombie_attb12 = 76;
const int anim_zombie_attb13 = 77;
const int anim_zombie_attb14 = 78;

const int anim_zombie_attc1 = 79;
const int anim_zombie_attc2 = 80;
const int anim_zombie_attc3 = 81;
const int anim_zombie_attc4 = 82;
const int anim_zombie_attc5 = 83;
const int anim_zombie_attc6 = 84;
const int anim_zombie_attc7 = 85;
const int anim_zombie_attc8 = 86;
const int anim_zombie_attc9 = 87;
const int anim_zombie_attc10 = 88;
const int anim_zombie_attc11 = 89;
const int anim_zombie_attc12 = 90;

const int anim_zombie_paina1 = 91;
const int anim_zombie_paina2 = 92;
const int anim_zombie_paina3 = 93;
const int anim_zombie_paina4 = 94;
const int anim_zombie_paina5 = 95;
const int anim_zombie_paina6 = 96;
const int anim_zombie_paina7 = 97;
const int anim_zombie_paina8 = 98;
const int anim_zombie_paina9 = 99;
const int anim_zombie_paina10 = 100;
const int anim_zombie_paina11 = 101;
const int anim_zombie_paina12 = 102;

const int anim_zombie_painb1 = 103;
const int anim_zombie_painb2 = 104;
const int anim_zombie_painb3 = 105;
const int anim_zombie_painb4 = 106;
const int anim_zombie_painb5 = 107;
const int anim_zombie_painb6 = 108;
const int anim_zombie_painb7 = 109;
const int anim_zombie_painb8 = 110;
const int anim_zombie_painb9 = 111;
const int anim_zombie_painb10 = 112;
const int anim_zombie_painb11 = 113;
const int anim_zombie_painb12 = 114;
const int anim_zombie_painb13 = 115;
const int anim_zombie_painb14 = 116;
const int anim_zombie_painb15 = 117;
const int anim_zombie_painb16 = 118;
const int anim_zombie_painb17 = 119;
const int anim_zombie_painb18 = 120;
const int anim_zombie_painb19 = 121;
const int anim_zombie_painb20 = 122;
const int anim_zombie_painb21 = 123;
const int anim_zombie_painb22 = 124;
const int anim_zombie_painb23 = 125;
const int anim_zombie_painb24 = 126;
const int anim_zombie_painb25 = 127;
const int anim_zombie_painb26 = 128;
const int anim_zombie_painb27 = 129;
const int anim_zombie_painb28 = 130;

const int anim_zombie_painc1 = 131;
const int anim_zombie_painc2 = 132;
const int anim_zombie_painc3 = 133;
const int anim_zombie_painc4 = 134;
const int anim_zombie_painc5 = 135;
const int anim_zombie_painc6 = 136;
const int anim_zombie_painc7 = 137;
const int anim_zombie_painc8 = 138;
const int anim_zombie_painc9 = 139;
const int anim_zombie_painc10 = 140;
const int anim_zombie_painc11 = 141;
const int anim_zombie_painc12 = 142;
const int anim_zombie_painc13 = 143;
const int anim_zombie_painc14 = 144;
const int anim_zombie_painc15 = 145;
const int anim_zombie_painc16 = 146;
const int anim_zombie_painc17 = 147;
const int anim_zombie_painc18 = 148;

const int anim_zombie_paind1 = 149;
const int anim_zombie_paind2 = 150;
const int anim_zombie_paind3 = 151;
const int anim_zombie_paind4 = 152;
const int anim_zombie_paind5 = 153;
const int anim_zombie_paind6 = 154;
const int anim_zombie_paind7 = 155;
const int anim_zombie_paind8 = 156;
const int anim_zombie_paind9 = 157;
const int anim_zombie_paind10 = 158;
const int anim_zombie_paind11 = 159;
const int anim_zombie_paind12 = 160;
const int anim_zombie_paind13 = 161;

const int anim_zombie_paine1 = 162;
const int anim_zombie_paine2 = 163;
const int anim_zombie_paine3 = 164;
const int anim_zombie_paine4 = 165;
const int anim_zombie_paine5 = 166;
const int anim_zombie_paine6 = 167;
const int anim_zombie_paine7 = 168;
const int anim_zombie_paine8 = 169;
const int anim_zombie_paine9 = 170;
const int anim_zombie_paine10 = 171;
const int anim_zombie_paine11 = 172;
const int anim_zombie_paine12 = 173;
const int anim_zombie_paine13 = 174;
const int anim_zombie_paine14 = 175;
const int anim_zombie_paine15 = 176;
const int anim_zombie_paine16 = 177;
const int anim_zombie_paine17 = 178;
const int anim_zombie_paine18 = 179;
const int anim_zombie_paine19 = 180;
const int anim_zombie_paine20 = 181;
const int anim_zombie_paine21 = 182;
const int anim_zombie_paine22 = 183;
const int anim_zombie_paine23 = 184;
const int anim_zombie_paine24 = 185;
const int anim_zombie_paine25 = 186;
const int anim_zombie_paine26 = 187;
const int anim_zombie_paine27 = 188;
const int anim_zombie_paine28 = 189;
const int anim_zombie_paine29 = 190;
const int anim_zombie_paine30 = 191;

const int anim_zombie_cruc_1 = 192;
const int anim_zombie_cruc_2 = 193;
const int anim_zombie_cruc_3 = 194;
const int anim_zombie_cruc_4 = 195;
const int anim_zombie_cruc_5 = 196;
const int anim_zombie_cruc_6 = 197;

const int SPAWN_CRUCIFIED = BIT(0);
const int SPAWN_LYINGDOWN = BIT(2); // HIPNOTIC

//=============================================================================

.int inpain;

void zombie_stand1(entity this);
void zombie_stand15(entity this) { set_anim(this, anim_zombie_stand15, zombie_stand1); ai_stand(this); }
void zombie_stand14(entity this) { set_anim(this, anim_zombie_stand14, zombie_stand15); ai_stand(this); }
void zombie_stand13(entity this) { set_anim(this, anim_zombie_stand13, zombie_stand14); ai_stand(this); }
void zombie_stand12(entity this) { set_anim(this, anim_zombie_stand12, zombie_stand13); ai_stand(this); }
void zombie_stand11(entity this) { set_anim(this, anim_zombie_stand11, zombie_stand12); ai_stand(this); }
void zombie_stand10(entity this) { set_anim(this, anim_zombie_stand10, zombie_stand11); ai_stand(this); }
void zombie_stand9(entity this) { set_anim(this, anim_zombie_stand9, zombie_stand10); ai_stand(this); }
void zombie_stand8(entity this) { set_anim(this, anim_zombie_stand8, zombie_stand9); ai_stand(this); }
void zombie_stand7(entity this) { set_anim(this, anim_zombie_stand7, zombie_stand8); ai_stand(this); }
void zombie_stand6(entity this) { set_anim(this, anim_zombie_stand6, zombie_stand7); ai_stand(this); }
void zombie_stand5(entity this) { set_anim(this, anim_zombie_stand5, zombie_stand6); ai_stand(this); }
void zombie_stand4(entity this) { set_anim(this, anim_zombie_stand4, zombie_stand5); ai_stand(this); }
void zombie_stand3(entity this) { set_anim(this, anim_zombie_stand3, zombie_stand4); ai_stand(this); }
void zombie_stand2(entity this) { set_anim(this, anim_zombie_stand2, zombie_stand3); ai_stand(this); }
void zombie_stand1(entity this) { set_anim(this, anim_zombie_stand1, zombie_stand2); ai_stand(this); }

void zombie_cruc1(entity this);
void zombie_cruc6(entity this) { set_anim(this, anim_zombie_cruc_6, zombie_cruc1); this.nextthink = time + 0.1 + random() * 0.1; }
void zombie_cruc5(entity this) { set_anim(this, anim_zombie_cruc_5, zombie_cruc6); this.nextthink = time + 0.1 + random() * 0.1; }
void zombie_cruc4(entity this) { set_anim(this, anim_zombie_cruc_4, zombie_cruc5); this.nextthink = time + 0.1 + random() * 0.1; }
void zombie_cruc3(entity this) { set_anim(this, anim_zombie_cruc_3, zombie_cruc4); this.nextthink = time + 0.1 + random() * 0.1; }
void zombie_cruc2(entity this) { set_anim(this, anim_zombie_cruc_2, zombie_cruc3); this.nextthink = time + 0.1 + random() * 0.1; }
void zombie_cruc1(entity this)
{
	set_anim(this, anim_zombie_cruc_1, zombie_cruc2);
	if(random() < 0.1)
		_sound(this, CHAN_VOICE, "zombie/idle_w2.wav", 1, ATTN_STATIC);
}

void zombie_walk1(entity this);
void zombie_walk19(entity this)
{
	set_anim(this, anim_zombie_walk19, zombie_walk1);
	ai_walk(this, 0);
	if(random() < 0.2)
		_sound(this, CHAN_VOICE, "zombie/z_idle.wav", 1, ATTN_IDLE);
}
void zombie_walk18(entity this) { set_anim(this, anim_zombie_walk18, zombie_walk19); ai_walk(this, 0); }
void zombie_walk17(entity this) { set_anim(this, anim_zombie_walk17, zombie_walk18); ai_walk(this, 0); }
void zombie_walk16(entity this) { set_anim(this, anim_zombie_walk16, zombie_walk17); ai_walk(this, 0); }
void zombie_walk15(entity this) { set_anim(this, anim_zombie_walk15, zombie_walk16); ai_walk(this, 0); }
void zombie_walk14(entity this) { set_anim(this, anim_zombie_walk14, zombie_walk15); ai_walk(this, 0); }
void zombie_walk13(entity this) { set_anim(this, anim_zombie_walk13, zombie_walk14); ai_walk(this, 1); }
void zombie_walk12(entity this) { set_anim(this, anim_zombie_walk12, zombie_walk13); ai_walk(this, 2); }
void zombie_walk11(entity this) { set_anim(this, anim_zombie_walk11, zombie_walk12); ai_walk(this, 2); }
void zombie_walk10(entity this) { set_anim(this, anim_zombie_walk10, zombie_walk11); ai_walk(this, 0); }
void zombie_walk9(entity this) { set_anim(this, anim_zombie_walk9, zombie_walk10); ai_walk(this, 0); }
void zombie_walk8(entity this) { set_anim(this, anim_zombie_walk8, zombie_walk9); ai_walk(this, 0); }
void zombie_walk7(entity this) { set_anim(this, anim_zombie_walk7, zombie_walk8); ai_walk(this, 0); }
void zombie_walk6(entity this) { set_anim(this, anim_zombie_walk6, zombie_walk7); ai_walk(this, 0); }
void zombie_walk5(entity this) { set_anim(this, anim_zombie_walk5, zombie_walk6); ai_walk(this, 1); }
void zombie_walk4(entity this) { set_anim(this, anim_zombie_walk4, zombie_walk5); ai_walk(this, 2); }
void zombie_walk3(entity this) { set_anim(this, anim_zombie_walk3, zombie_walk4); ai_walk(this, 3); }
void zombie_walk2(entity this) { set_anim(this, anim_zombie_walk2, zombie_walk3); ai_walk(this, 2); }
void zombie_walk1(entity this) { set_anim(this, anim_zombie_walk1, zombie_walk2); ai_walk(this, 0); }

void zombie_run1(entity this);
void zombie_run18(entity this)
{
	set_anim(this, anim_zombie_run18, zombie_run1);
	ai_run(this, 8);
	if(random() < 0.2)
		_sound(this, CHAN_VOICE, "zombie/z_idle.wav", 1, ATTN_IDLE);
	if(random() > 0.8)
		_sound(this, CHAN_VOICE, "zombie/z_idle1.wav", 1, ATTN_IDLE);
}
void zombie_run17(entity this) { set_anim(this, anim_zombie_run17, zombie_run18); ai_run(this, 3); }
void zombie_run16(entity this) { set_anim(this, anim_zombie_run16, zombie_run17); ai_run(this, 7); }
void zombie_run15(entity this) { set_anim(this, anim_zombie_run15, zombie_run16); ai_run(this, 6); }
void zombie_run14(entity this) { set_anim(this, anim_zombie_run14, zombie_run15); ai_run(this, 4); }
void zombie_run13(entity this) { set_anim(this, anim_zombie_run13, zombie_run14); ai_run(this, 2); }
void zombie_run12(entity this) { set_anim(this, anim_zombie_run12, zombie_run13); ai_run(this, 0); }
void zombie_run11(entity this) { set_anim(this, anim_zombie_run11, zombie_run12); ai_run(this, 0); }
void zombie_run10(entity this) { set_anim(this, anim_zombie_run10, zombie_run11); ai_run(this, 0); }
void zombie_run9(entity this) { set_anim(this, anim_zombie_run9, zombie_run10); ai_run(this, 2); }
void zombie_run8(entity this) { set_anim(this, anim_zombie_run8, zombie_run9); ai_run(this, 4); }
void zombie_run7(entity this) { set_anim(this, anim_zombie_run7, zombie_run8); ai_run(this, 4); }
void zombie_run6(entity this) { set_anim(this, anim_zombie_run6, zombie_run7); ai_run(this, 3); }
void zombie_run5(entity this) { set_anim(this, anim_zombie_run5, zombie_run6); ai_run(this, 2); }
void zombie_run4(entity this) { set_anim(this, anim_zombie_run4, zombie_run5); ai_run(this, 1); }
void zombie_run3(entity this) { set_anim(this, anim_zombie_run3, zombie_run4); ai_run(this, 0); }
void zombie_run2(entity this) { set_anim(this, anim_zombie_run2, zombie_run3); ai_run(this, 1); }
void zombie_run1(entity this) { set_anim(this, anim_zombie_run1, zombie_run2); ai_run(this, 1); this.inpain = 0; }

/*
=============================================================================

ATTACKS

=============================================================================
*/

void ZombieGrenadeTouch_Remove(entity this, entity toucher)
{
	delete(this);
}
void ZombieGrenadeTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner
	if(toucher.takedamage)
	{
		T_Damage(toucher, this, this.owner, 10 );
		_sound(this, CHAN_WEAPON, "zombie/z_hit.wav", 1, ATTN_NORM);
		delete(this);
		return;
	}
	_sound(this, CHAN_WEAPON, "zombie/z_miss.wav", 1, ATTN_NORM);	// bounce sound
	this.velocity = '0 0 0';
	this.avelocity = '0 0 0';
	settouch(this, ZombieGrenadeTouch_Remove);
}

/*
================
ZombieFireGrenade
================
*/
void ZombieFireGrenade(entity this, vector st)
{
	_sound(this, CHAN_WEAPON, "zombie/z_shot1.wav", 1, ATTN_NORM);

	entity missile = spawn();
	missile.owner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;

// calc org
	vector org = this.origin + st_x * v_forward + st_y * v_right +(st_z - 24) * v_up;
	
// set missile speed	

	makevectors(this.angles);

	missile.velocity = normalize(this.enemy.origin - org);
	missile.velocity = missile.velocity * 600;
	missile.velocity_z = 200;

	missile.avelocity = '3000 1000 2000';

	settouch(missile, ZombieGrenadeTouch);
	
// set missile duration
	missile.nextthink = time + 2.5;
	setthink(missile, SUB_Remove);

	_setmodel(missile, "progs/zom_gib.mdl");
	setsize(missile, '0 0 0', '0 0 0');		
	setorigin(missile, org);
}


void zombie_atta13(entity this) { set_anim(this, anim_zombie_atta13, zombie_run1); ai_face(this); ZombieFireGrenade(this, '-10 -22 30'); }
void zombie_atta12(entity this) { set_anim(this, anim_zombie_atta12, zombie_atta13); ai_face(this); }
void zombie_atta11(entity this) { set_anim(this, anim_zombie_atta11, zombie_atta12); ai_face(this); }
void zombie_atta10(entity this) { set_anim(this, anim_zombie_atta10, zombie_atta11); ai_face(this); }
void zombie_atta9(entity this) { set_anim(this, anim_zombie_atta9, zombie_atta10); ai_face(this); }
void zombie_atta8(entity this) { set_anim(this, anim_zombie_atta8, zombie_atta9); ai_face(this); }
void zombie_atta7(entity this) { set_anim(this, anim_zombie_atta7, zombie_atta8); ai_face(this); }
void zombie_atta6(entity this) { set_anim(this, anim_zombie_atta6, zombie_atta7); ai_face(this); }
void zombie_atta5(entity this) { set_anim(this, anim_zombie_atta5, zombie_atta6); ai_face(this); }
void zombie_atta4(entity this) { set_anim(this, anim_zombie_atta4, zombie_atta5); ai_face(this); }
void zombie_atta3(entity this) { set_anim(this, anim_zombie_atta3, zombie_atta4); ai_face(this); }
void zombie_atta2(entity this) { set_anim(this, anim_zombie_atta2, zombie_atta3); ai_face(this); }
void zombie_atta1(entity this) { set_anim(this, anim_zombie_atta1, zombie_atta2); ai_face(this); }

void zombie_attb14(entity this) { set_anim(this, anim_zombie_attb13, zombie_run1); ai_face(this); ZombieFireGrenade(this, '-10 -24 29'); }
void zombie_attb13(entity this) { set_anim(this, anim_zombie_attb13, zombie_attb14); ai_face(this); }
void zombie_attb12(entity this) { set_anim(this, anim_zombie_attb12, zombie_attb13); ai_face(this); }
void zombie_attb11(entity this) { set_anim(this, anim_zombie_attb11, zombie_attb12); ai_face(this); }
void zombie_attb10(entity this) { set_anim(this, anim_zombie_attb10, zombie_attb11); ai_face(this); }
void zombie_attb9(entity this) { set_anim(this, anim_zombie_attb9, zombie_attb10); ai_face(this); }
void zombie_attb8(entity this) { set_anim(this, anim_zombie_attb8, zombie_attb9); ai_face(this); }
void zombie_attb7(entity this) { set_anim(this, anim_zombie_attb7, zombie_attb8); ai_face(this); }
void zombie_attb6(entity this) { set_anim(this, anim_zombie_attb6, zombie_attb7); ai_face(this); }
void zombie_attb5(entity this) { set_anim(this, anim_zombie_attb5, zombie_attb6); ai_face(this); }
void zombie_attb4(entity this) { set_anim(this, anim_zombie_attb4, zombie_attb5); ai_face(this); }
void zombie_attb3(entity this) { set_anim(this, anim_zombie_attb3, zombie_attb4); ai_face(this); }
void zombie_attb2(entity this) { set_anim(this, anim_zombie_attb2, zombie_attb3); ai_face(this); }
void zombie_attb1(entity this) { set_anim(this, anim_zombie_attb1, zombie_attb2); ai_face(this); }

void zombie_attc12(entity this) { set_anim(this, anim_zombie_attc12, zombie_run1); ai_face(this); ZombieFireGrenade(this, '-12 -19 29'); }
void zombie_attc11(entity this) { set_anim(this, anim_zombie_attc11, zombie_attc12); ai_face(this); }
void zombie_attc10(entity this) { set_anim(this, anim_zombie_attc10, zombie_attc11); ai_face(this); }
void zombie_attc9(entity this) { set_anim(this, anim_zombie_attc9, zombie_attc10); ai_face(this); }
void zombie_attc8(entity this) { set_anim(this, anim_zombie_attc8, zombie_attc9); ai_face(this); }
void zombie_attc7(entity this) { set_anim(this, anim_zombie_attc7, zombie_attc8); ai_face(this); }
void zombie_attc6(entity this) { set_anim(this, anim_zombie_attc6, zombie_attc7); ai_face(this); }
void zombie_attc5(entity this) { set_anim(this, anim_zombie_attc5, zombie_attc6); ai_face(this); }
void zombie_attc4(entity this) { set_anim(this, anim_zombie_attc4, zombie_attc5); ai_face(this); }
void zombie_attc3(entity this) { set_anim(this, anim_zombie_attc3, zombie_attc4); ai_face(this); }
void zombie_attc2(entity this) { set_anim(this, anim_zombie_attc2, zombie_attc3); ai_face(this); }
void zombie_attc1(entity this) { set_anim(this, anim_zombie_attc1, zombie_attc2); ai_face(this); }

void zombie_missile(entity this)
{
	float r = random();
	
	if(r < 0.3)
		zombie_atta1(this);
	else if(r < 0.6)
		zombie_attb1(this);
	else
		zombie_attc1(this);
}


/*
=============================================================================

PAIN

=============================================================================
*/

void zombie_paina12(entity this) { set_anim(this, anim_zombie_paina12, zombie_run1); }
void zombie_paina11(entity this) { set_anim(this, anim_zombie_paina11, zombie_paina12); }
void zombie_paina10(entity this) { set_anim(this, anim_zombie_paina10, zombie_paina11); }
void zombie_paina9(entity this) { set_anim(this, anim_zombie_paina9, zombie_paina10); }
void zombie_paina8(entity this) { set_anim(this, anim_zombie_paina8, zombie_paina9); }
void zombie_paina7(entity this) { set_anim(this, anim_zombie_paina7, zombie_paina8); }
void zombie_paina6(entity this) { set_anim(this, anim_zombie_paina6, zombie_paina7); ai_pain(this, 1); }
void zombie_paina5(entity this) { set_anim(this, anim_zombie_paina5, zombie_paina6); ai_pain(this, 3); }
void zombie_paina4(entity this) { set_anim(this, anim_zombie_paina4, zombie_paina5); ai_pain(this, 1); }
void zombie_paina3(entity this) { set_anim(this, anim_zombie_paina3, zombie_paina4); ai_painforward(this, 1); }
void zombie_paina2(entity this) { set_anim(this, anim_zombie_paina2, zombie_paina3); ai_painforward(this, 3); }
void zombie_paina1(entity this) { set_anim(this, anim_zombie_paina1, zombie_paina2); _sound(this, CHAN_VOICE, "zombie/z_pain.wav", 1, ATTN_NORM); }

void zombie_painb28(entity this) { set_anim(this, anim_zombie_painb28, zombie_run1); }
void zombie_painb27(entity this) { set_anim(this, anim_zombie_painb27, zombie_painb28); }
void zombie_painb26(entity this) { set_anim(this, anim_zombie_painb26, zombie_painb27); }
void zombie_painb25(entity this) { set_anim(this, anim_zombie_painb25, zombie_painb26); ai_painforward(this, 1); }
void zombie_painb24(entity this) { set_anim(this, anim_zombie_painb24, zombie_painb25); }
void zombie_painb23(entity this) { set_anim(this, anim_zombie_painb23, zombie_painb24); }
void zombie_painb22(entity this) { set_anim(this, anim_zombie_painb22, zombie_painb23); }
void zombie_painb21(entity this) { set_anim(this, anim_zombie_painb21, zombie_painb22); }
void zombie_painb20(entity this) { set_anim(this, anim_zombie_painb20, zombie_painb21); }
void zombie_painb19(entity this) { set_anim(this, anim_zombie_painb19, zombie_painb20); }
void zombie_painb18(entity this) { set_anim(this, anim_zombie_painb18, zombie_painb19); }
void zombie_painb17(entity this) { set_anim(this, anim_zombie_painb17, zombie_painb18); }
void zombie_painb16(entity this) { set_anim(this, anim_zombie_painb16, zombie_painb17); }
void zombie_painb15(entity this) { set_anim(this, anim_zombie_painb15, zombie_painb16); }
void zombie_painb14(entity this) { set_anim(this, anim_zombie_painb14, zombie_painb15); }
void zombie_painb13(entity this) { set_anim(this, anim_zombie_painb13, zombie_painb14); }
void zombie_painb12(entity this) { set_anim(this, anim_zombie_painb12, zombie_painb13); }
void zombie_painb11(entity this) { set_anim(this, anim_zombie_painb11, zombie_painb12); }
void zombie_painb10(entity this) { set_anim(this, anim_zombie_painb10, zombie_painb11); }
void zombie_painb9(entity this) { set_anim(this, anim_zombie_painb9, zombie_painb10); _sound(this, CHAN_BODY, "zombie/z_fall.wav", 1, ATTN_NORM); }
void zombie_painb8(entity this) { set_anim(this, anim_zombie_painb8, zombie_painb9); }
void zombie_painb7(entity this) { set_anim(this, anim_zombie_painb7, zombie_painb8); }
void zombie_painb6(entity this) { set_anim(this, anim_zombie_painb6, zombie_painb7); }
void zombie_painb5(entity this) { set_anim(this, anim_zombie_painb5, zombie_painb6); ai_pain(this, 2); }
void zombie_painb4(entity this) { set_anim(this, anim_zombie_painb4, zombie_painb5); ai_pain(this, 6); }
void zombie_painb3(entity this) { set_anim(this, anim_zombie_painb3, zombie_painb4); ai_pain(this, 8); }
void zombie_painb2(entity this) { set_anim(this, anim_zombie_painb2, zombie_painb3); ai_pain(this, 2); }
void zombie_painb1(entity this) { set_anim(this, anim_zombie_painb1, zombie_painb2); _sound(this, CHAN_VOICE, "zombie/z_pain1.wav", 1, ATTN_NORM); }

void zombie_painc18(entity this) { set_anim(this, anim_zombie_painc18, zombie_run1); }
void zombie_painc17(entity this) { set_anim(this, anim_zombie_painc17, zombie_painc18); }
void zombie_painc16(entity this) { set_anim(this, anim_zombie_painc16, zombie_painc17); }
void zombie_painc15(entity this) { set_anim(this, anim_zombie_painc15, zombie_painc16); }
void zombie_painc14(entity this) { set_anim(this, anim_zombie_painc14, zombie_painc15); }
void zombie_painc13(entity this) { set_anim(this, anim_zombie_painc13, zombie_painc14); }
void zombie_painc12(entity this) { set_anim(this, anim_zombie_painc12, zombie_painc13); ai_painforward(this, 1); }
void zombie_painc11(entity this) { set_anim(this, anim_zombie_painc11, zombie_painc12); ai_painforward(this, 1); }
void zombie_painc10(entity this) { set_anim(this, anim_zombie_painc10, zombie_painc11); }
void zombie_painc9(entity this) { set_anim(this, anim_zombie_painc9, zombie_painc10); }
void zombie_painc8(entity this) { set_anim(this, anim_zombie_painc8, zombie_painc9); }
void zombie_painc7(entity this) { set_anim(this, anim_zombie_painc7, zombie_painc8); }
void zombie_painc6(entity this) { set_anim(this, anim_zombie_painc6, zombie_painc7); }
void zombie_painc5(entity this) { set_anim(this, anim_zombie_painc5, zombie_painc6); }
void zombie_painc4(entity this) { set_anim(this, anim_zombie_painc4, zombie_painc5); ai_pain(this, 1); }
void zombie_painc3(entity this) { set_anim(this, anim_zombie_painc3, zombie_painc4); ai_pain(this, 3); }
void zombie_painc2(entity this) { set_anim(this, anim_zombie_painc2, zombie_painc3); }
void zombie_painc1(entity this) { set_anim(this, anim_zombie_painc1, zombie_painc2); _sound(this, CHAN_VOICE, "zombie/z_pain1.wav", 1, ATTN_NORM); }

void zombie_paind13(entity this) { set_anim(this, anim_zombie_paind13, zombie_run1); }
void zombie_paind12(entity this) { set_anim(this, anim_zombie_paind12, zombie_paind13); }
void zombie_paind11(entity this) { set_anim(this, anim_zombie_paind11, zombie_paind12); }
void zombie_paind10(entity this) { set_anim(this, anim_zombie_paind10, zombie_paind11); }
void zombie_paind9(entity this) { set_anim(this, anim_zombie_paind9, zombie_paind10); ai_pain(this, 1); }
void zombie_paind8(entity this) { set_anim(this, anim_zombie_paind8, zombie_paind9); }
void zombie_paind7(entity this) { set_anim(this, anim_zombie_paind7, zombie_paind8); }
void zombie_paind6(entity this) { set_anim(this, anim_zombie_paind6, zombie_paind7); }
void zombie_paind5(entity this) { set_anim(this, anim_zombie_paind5, zombie_paind6); }
void zombie_paind4(entity this) { set_anim(this, anim_zombie_paind4, zombie_paind5); }
void zombie_paind3(entity this) { set_anim(this, anim_zombie_paind3, zombie_paind4); }
void zombie_paind2(entity this) { set_anim(this, anim_zombie_paind2, zombie_paind3); }
void zombie_paind1(entity this) { set_anim(this, anim_zombie_paind1, zombie_paind2); _sound(this, CHAN_VOICE, "zombie/z_pain.wav", 1, ATTN_NORM); }

void zombie_paine11(entity this);
void zombie_paine30(entity this) { set_anim(this, anim_zombie_paine30, zombie_run1); }
void zombie_paine29(entity this) { set_anim(this, anim_zombie_paine29, zombie_paine30); }
void zombie_paine28(entity this) { set_anim(this, anim_zombie_paine28, zombie_paine29); ai_pain(this, 1); }
void zombie_paine27(entity this) { set_anim(this, anim_zombie_paine27, zombie_paine28); ai_painforward(this, 1); }
void zombie_paine26(entity this) { set_anim(this, anim_zombie_paine26, zombie_paine27); ai_painforward(this, 3); }
void zombie_paine25(entity this) { set_anim(this, anim_zombie_paine25, zombie_paine26); ai_painforward(this, 5); }
void zombie_paine24(entity this) { set_anim(this, anim_zombie_paine24, zombie_paine25); }
void zombie_paine23(entity this) { set_anim(this, anim_zombie_paine23, zombie_paine24); }
void zombie_paine22(entity this) { set_anim(this, anim_zombie_paine22, zombie_paine23); }
void zombie_paine21(entity this) { set_anim(this, anim_zombie_paine21, zombie_paine22); }
void zombie_paine20(entity this) { set_anim(this, anim_zombie_paine20, zombie_paine21); }
void zombie_paine19(entity this) { set_anim(this, anim_zombie_paine19, zombie_paine20); }
void zombie_paine18(entity this) { set_anim(this, anim_zombie_paine18, zombie_paine19); }
void zombie_paine17(entity this) { set_anim(this, anim_zombie_paine17, zombie_paine18); }
void zombie_paine16(entity this) { set_anim(this, anim_zombie_paine16, zombie_paine17); }
void zombie_paine15(entity this) { set_anim(this, anim_zombie_paine15, zombie_paine16); }
void zombie_paine14(entity this) { set_anim(this, anim_zombie_paine14, zombie_paine15); }
void zombie_paine13(entity this) { set_anim(this, anim_zombie_paine13, zombie_paine14); }
void zombie_paine12(entity this)
{
	set_anim(this, anim_zombie_paine12, zombie_paine13);
	// see if ok to stand up
	this.health = 60;
	_sound(this, CHAN_VOICE, "zombie/z_idle.wav", 1, ATTN_IDLE);
	this.solid = SOLID_SLIDEBOX;
	if(!t_walkmove(this, 0, 0))
	{
		setthink(this, zombie_paine11);
		this.solid = SOLID_NOT;
		return;
	}
}
void zombie_paine11(entity this) { set_anim(this, anim_zombie_paine11, zombie_paine12); }
void zombie_paine10(entity this)
{
	set_anim(this, anim_zombie_paine10, zombie_paine11);
	_sound(this, CHAN_BODY, "zombie/z_fall.wav", 1, ATTN_NORM);
	this.solid = SOLID_NOT;
}
void zombie_paine9(entity this) { set_anim(this, anim_zombie_paine9, zombie_paine10); ai_pain(this, 2); }
void zombie_paine8(entity this) { set_anim(this, anim_zombie_paine8, zombie_paine9); ai_pain(this, 1); }
void zombie_paine7(entity this) { set_anim(this, anim_zombie_paine7, zombie_paine8); ai_pain(this, 1); }
void zombie_paine6(entity this) { set_anim(this, anim_zombie_paine6, zombie_paine7); ai_pain(this, 2); }
void zombie_paine5(entity this) { set_anim(this, anim_zombie_paine5, zombie_paine6); ai_pain(this, 1); }
void zombie_paine4(entity this) { set_anim(this, anim_zombie_paine4, zombie_paine5); ai_pain(this, 3); }
void zombie_paine3(entity this) { set_anim(this, anim_zombie_paine3, zombie_paine4); ai_pain(this, 5); }
void zombie_paine2(entity this) { set_anim(this, anim_zombie_paine2, zombie_paine3); ai_pain(this, 8); }
void zombie_paine1(entity this)
{
	set_anim(this, anim_zombie_paine1, zombie_paine2);
	_sound(this, CHAN_VOICE, "zombie/z_pain.wav", 1, ATTN_NORM);
	this.health = 60;
}

void zombie_die(entity this, entity attacker)
{
	_sound(this, CHAN_VOICE, "zombie/z_gib.wav", 1, ATTN_NORM);
	ThrowHead(this, "progs/h_zombie.mdl", this.health);
	ThrowGib(this, "progs/gib1.mdl", this.health);
	ThrowGib(this, "progs/gib2.mdl", this.health);
	ThrowGib(this, "progs/gib3.mdl", this.health);
}

/*
=================
zombie_pain

Zombies can only be killed(gibbed) by doing 60 hit points of damage
in a single frame(rockets, grenades, quad shotgun, quad nailgun).

A hit of 25 points or more(super shotgun, quad nailgun) will allways put it
down to the ground.

A hit of from 10 to 40 points in one frame will cause it to go down if it
has been twice in two seconds, otherwise it goes into one of the four
fast pain frames.

A hit of less than 10 points of damage(winged by a shotgun) will be ignored.

FIXME: don't use pain_finished because of nightmare hack
=================
*/
void zombie_pain(entity this, entity attacker, float take)
{
	this.health = 60;		// allways reset health

	if(take < 9)
		return;				// totally ignore

	if(this.inpain == 2)
		return;			// down on ground, so don't reset any counters

// go down immediately if a big enough hit
	if(take >= 25)
	{
		this.inpain = 2;
		zombie_paine1(this);
		return;
	}
	
	if(this.inpain)
	{
// if hit again in next gre seconds while not in pain frames, definately drop
		this.pain_finished = time + 3;
		return;			// currently going through an animation, don't change
	}
	
	if(this.pain_finished > time)
	{
// hit again, so drop down
		this.inpain = 2;
		zombie_paine1(this);
		return;
	}

// gp into one of the fast pain animations	
	this.inpain = 1;

	float r = random();
	if(r < 0.25)
		zombie_paina1(this);
	else if(r <  0.5)
		zombie_painb1(this);
	else if(r <  0.75)
		zombie_painc1(this);
	else
		zombie_paind1(this);
}

void zombie_lay12(entity this, entity attacker, float damage) { set_anim(this, anim_zombie_paine12, zombie_paine13); this.th_pain = zombie_pain; }

void zombie_lay(entity this)
{
	set_anim(this, anim_zombie_paine11, zombie_lay);
	this.nextthink += 0.1;
	this.th_stand = zombie_stand1;
	this.th_pain = zombie_lay12;
	this.health = 60;

	if(FindTarget(this))
	{
		zombie_lay12(this, NULL, 0);
		return;
	}
}

string zombie_sight(entity this) { return "zombie/z_idle.wav"; }
string zombie_deathmessage(entity this) { return "joins the Zombies"; }

//============================================================================

/*QUAKED monster_zombie(1 0 0)(-16 -16 -24)(16 16 32) Crucified ambush lying_down

If crucified, stick the bounding box 12 pixels back into a wall to look right.
If lying_down in hipnotic, the zombie will be lying down when spawned and will rise up
when awakened by the player.
*/
spawnfunc(monster_zombie)
{
	if(deathmatch)
	{
		delete(this);
		return;
	}

	precache_model("progs/zombie.mdl");
	precache_model("progs/h_zombie.mdl");
	precache_model("progs/zom_gib.mdl");

	precache_sound("zombie/z_idle.wav");
	precache_sound("zombie/z_idle1.wav");
	precache_sound("zombie/z_shot1.wav");
	precache_sound("zombie/z_gib.wav");
	precache_sound("zombie/z_pain.wav");
	precache_sound("zombie/z_pain1.wav");
	precache_sound("zombie/z_fall.wav");
	precache_sound("zombie/z_miss.wav");
	precache_sound("zombie/z_hit.wav");
	precache_sound("zombie/idle_w2.wav");

	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);

	_setmodel(this, "progs/zombie.mdl");

	setsize(this, '-16 -16 -24', '16 16 40');
	this.health = 60;

	this.th_stand = zombie_stand1;
	this.th_walk = zombie_walk1;
	this.th_run = zombie_run1;
	this.th_pain = zombie_pain;
	this.th_die = zombie_die;
	this.th_missile = zombie_missile;

	this.sightsound = zombie_sight;
	this.deathmessage = zombie_deathmessage;

	if(this.spawnflags & SPAWN_CRUCIFIED)
	{
		set_movetype(this, MOVETYPE_NONE);
		zombie_cruc1(this);
	}
	else
		monster_start(this, 0);

	if(MP_HIPNOTIC && (this.spawnflags & SPAWN_LYINGDOWN))
		this.th_stand = zombie_lay;
}
