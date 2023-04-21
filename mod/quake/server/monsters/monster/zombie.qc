/*
==============================================================================

ZOMBIE

==============================================================================
*/
$cd id1/models/zombie

$origin	0 0 24

$base base
$skin skin

#if 0
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
// new frames added by rogue (TODO)
const int anim_zombie_cruc_7 = 198;
const int anim_zombie_cruc_8 = 199;
const int anim_zombie_cruc_9 = 200;
const int anim_zombie_cruc_10 = 201;
const int anim_zombie_cruc_11 = 202;
const int anim_zombie_cruc_12 = 203;
const int anim_zombie_cruc_13 = 204;
const int anim_zombie_cruc_14 = 205;
const int anim_zombie_cruc_15 = 206;
const int anim_zombie_cruc_16 = 207;
#endif

const int anim_zombie_stand = 0; //'0 14 0'
const int anim_zombie_walk = 15; //'15 33 0'
const int anim_zombie_run = 34; //'34 51 0'
const int anim_zombie_atta = 52; //'52 64 0'
const int anim_zombie_attb = 65; //'65 78 0'
const int anim_zombie_attc = 79; //'79 90 0'
const int anim_zombie_paina = 91; //'91 102 0'
const int anim_zombie_painb = 103; //'103 130 0'
const int anim_zombie_painc = 131; //'131 148 0'
const int anim_zombie_paind = 149; //'149 161 0'
const int anim_zombie_paine = 162; //'162 191 0'
const int anim_zombie_cruc = 192; //'192 207 0'

const int SPAWN_CRUCIFIED = BIT(0);
const int SPAWN_LYINGDOWN = BIT(2); // HIPNOTIC

// ROGUE
const int SPAWN_LYING = BIT(1);
const int SPAWN_AMBUSH = BIT(2);
const int SPAWN_SNEAKY = BIT(3);

//=============================================================================

.int inpain;
void zombie_escape1(entity this);

void zombie_stand1(entity this);
void zombie_stand15(entity this) { set_animofs(this, anim_zombie_stand, 15, zombie_stand1); ai_stand(this); }
void zombie_stand14(entity this) { set_animofs(this, anim_zombie_stand, 14, zombie_stand15); ai_stand(this); }
void zombie_stand13(entity this) { set_animofs(this, anim_zombie_stand, 13, zombie_stand14); ai_stand(this); }
void zombie_stand12(entity this) { set_animofs(this, anim_zombie_stand, 12, zombie_stand13); ai_stand(this); }
void zombie_stand11(entity this) { set_animofs(this, anim_zombie_stand, 11, zombie_stand12); ai_stand(this); }
void zombie_stand10(entity this) { set_animofs(this, anim_zombie_stand, 10, zombie_stand11); ai_stand(this); }
void zombie_stand9(entity this) { set_animofs(this, anim_zombie_stand, 9, zombie_stand10); ai_stand(this); }
void zombie_stand8(entity this) { set_animofs(this, anim_zombie_stand, 8, zombie_stand9); ai_stand(this); }
void zombie_stand7(entity this) { set_animofs(this, anim_zombie_stand, 7, zombie_stand8); ai_stand(this); }
void zombie_stand6(entity this) { set_animofs(this, anim_zombie_stand, 6, zombie_stand7); ai_stand(this); }
void zombie_stand5(entity this) { set_animofs(this, anim_zombie_stand, 5, zombie_stand6); ai_stand(this); }
void zombie_stand4(entity this) { set_animofs(this, anim_zombie_stand, 4, zombie_stand5); ai_stand(this); }
void zombie_stand3(entity this) { set_animofs(this, anim_zombie_stand, 3, zombie_stand4); ai_stand(this); }
void zombie_stand2(entity this) { set_animofs(this, anim_zombie_stand, 2, zombie_stand3); ai_stand(this); }
void zombie_stand1(entity this) { set_animofs(this, anim_zombie_stand, 1, zombie_stand2); ai_stand(this); }

void zombie_lurk(entity this)
{
	if(!MP_ROGUE)
	{
		this.nextthink = time + 0.1 + random() * 0.1;
		return;
	}

	if(this.spawnflags & SPAWN_SNEAKY)
	{
		// not pausing before attack, but looking for player
		if(!this.pain_finished)
		{
			if(FindTarget(this))
				return;
		}
		else
		{
			// if we're waited long enough, pounce!
			if(this.pain_finished < time)
			{
				setthink(this, zombie_escape1);
				this.nextthink = time + 1;
				return;
			}
		}
	}
	this.nextthink = time + 0.1 + random() * 0.1;
}

void zombie_cruc1(entity this);
void zombie_cruc6(entity this) { set_animofs(this, anim_zombie_cruc, 6, zombie_cruc1); zombie_lurk(this); }
void zombie_cruc5(entity this) { set_animofs(this, anim_zombie_cruc, 5, zombie_cruc6); zombie_lurk(this); }
void zombie_cruc4(entity this) { set_animofs(this, anim_zombie_cruc, 4, zombie_cruc5); zombie_lurk(this); }
void zombie_cruc3(entity this) { set_animofs(this, anim_zombie_cruc, 3, zombie_cruc4); zombie_lurk(this); }
void zombie_cruc2(entity this) { set_animofs(this, anim_zombie_cruc, 2, zombie_cruc3); zombie_lurk(this); }
void zombie_cruc1(entity this)
{
	set_animofs(this, anim_zombie_cruc, 1, zombie_cruc2);
	if(MP_ROGUE)
		zombie_lurk(this);
	if(random() < 0.1)
		_sound(this, CH_VOICE, "zombie/idle_w2.wav", 1, ATTN_STATIC);
}

void zombie_walk1(entity this);
void zombie_walk19(entity this)
{
	set_animofs(this, anim_zombie_walk, 19, zombie_walk1);
	ai_walk(this, 0);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "zombie/z_idle.wav", 1, ATTN_IDLE);
}
void zombie_walk18(entity this) { set_animofs(this, anim_zombie_walk, 18, zombie_walk19); ai_walk(this, 0); }
void zombie_walk17(entity this) { set_animofs(this, anim_zombie_walk, 17, zombie_walk18); ai_walk(this, 0); }
void zombie_walk16(entity this) { set_animofs(this, anim_zombie_walk, 16, zombie_walk17); ai_walk(this, 0); }
void zombie_walk15(entity this) { set_animofs(this, anim_zombie_walk, 15, zombie_walk16); ai_walk(this, 0); }
void zombie_walk14(entity this) { set_animofs(this, anim_zombie_walk, 14, zombie_walk15); ai_walk(this, 0); }
void zombie_walk13(entity this) { set_animofs(this, anim_zombie_walk, 13, zombie_walk14); ai_walk(this, 1); }
void zombie_walk12(entity this) { set_animofs(this, anim_zombie_walk, 12, zombie_walk13); ai_walk(this, 2); }
void zombie_walk11(entity this) { set_animofs(this, anim_zombie_walk, 11, zombie_walk12); ai_walk(this, 2); }
void zombie_walk10(entity this) { set_animofs(this, anim_zombie_walk, 10, zombie_walk11); ai_walk(this, 0); }
void zombie_walk9(entity this) { set_animofs(this, anim_zombie_walk, 9, zombie_walk10); ai_walk(this, 0); }
void zombie_walk8(entity this) { set_animofs(this, anim_zombie_walk, 8, zombie_walk9); ai_walk(this, 0); }
void zombie_walk7(entity this) { set_animofs(this, anim_zombie_walk, 7, zombie_walk8); ai_walk(this, 0); }
void zombie_walk6(entity this) { set_animofs(this, anim_zombie_walk, 6, zombie_walk7); ai_walk(this, 0); }
void zombie_walk5(entity this) { set_animofs(this, anim_zombie_walk, 5, zombie_walk6); ai_walk(this, 1); }
void zombie_walk4(entity this) { set_animofs(this, anim_zombie_walk, 4, zombie_walk5); ai_walk(this, 2); }
void zombie_walk3(entity this) { set_animofs(this, anim_zombie_walk, 3, zombie_walk4); ai_walk(this, 3); }
void zombie_walk2(entity this) { set_animofs(this, anim_zombie_walk, 2, zombie_walk3); ai_walk(this, 2); }
void zombie_walk1(entity this) { set_animofs(this, anim_zombie_walk, 1, zombie_walk2); ai_walk(this, 0); }

void zombie_run1(entity this);
void zombie_run18(entity this)
{
	set_animofs(this, anim_zombie_run, 18, zombie_run1);
	ai_run(this, 8);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "zombie/z_idle.wav", 1, ATTN_IDLE);
	if(random() > 0.8)
		_sound(this, CH_VOICE, "zombie/z_idle1.wav", 1, ATTN_IDLE);
}
void zombie_run17(entity this) { set_animofs(this, anim_zombie_run, 17, zombie_run18); ai_run(this, 3); }
void zombie_run16(entity this) { set_animofs(this, anim_zombie_run, 16, zombie_run17); ai_run(this, 7); }
void zombie_run15(entity this) { set_animofs(this, anim_zombie_run, 15, zombie_run16); ai_run(this, 6); }
void zombie_run14(entity this) { set_animofs(this, anim_zombie_run, 14, zombie_run15); ai_run(this, 4); }
void zombie_run13(entity this) { set_animofs(this, anim_zombie_run, 13, zombie_run14); ai_run(this, 2); }
void zombie_run12(entity this) { set_animofs(this, anim_zombie_run, 12, zombie_run13); ai_run(this, 0); }
void zombie_run11(entity this) { set_animofs(this, anim_zombie_run, 11, zombie_run12); ai_run(this, 0); }
void zombie_run10(entity this) { set_animofs(this, anim_zombie_run, 10, zombie_run11); ai_run(this, 0); }
void zombie_run9(entity this) { set_animofs(this, anim_zombie_run, 9, zombie_run10); ai_run(this, 2); }
void zombie_run8(entity this) { set_animofs(this, anim_zombie_run, 8, zombie_run9); ai_run(this, 4); }
void zombie_run7(entity this) { set_animofs(this, anim_zombie_run, 7, zombie_run8); ai_run(this, 4); }
void zombie_run6(entity this) { set_animofs(this, anim_zombie_run, 6, zombie_run7); ai_run(this, 3); }
void zombie_run5(entity this) { set_animofs(this, anim_zombie_run, 5, zombie_run6); ai_run(this, 2); }
void zombie_run4(entity this) { set_animofs(this, anim_zombie_run, 4, zombie_run5); ai_run(this, 1); }
void zombie_run3(entity this) { set_animofs(this, anim_zombie_run, 3, zombie_run4); ai_run(this, 0); }
void zombie_run2(entity this) { set_animofs(this, anim_zombie_run, 2, zombie_run3); ai_run(this, 1); }
void zombie_run1(entity this) { set_animofs(this, anim_zombie_run, 1, zombie_run2); ai_run(this, 1); this.inpain = 0; }

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
		_sound(this, CH_WEAPON_SINGLE, "zombie/z_hit.wav", 1, ATTN_NORM);
		delete(this);
		return;
	}
	_sound(this, CH_WEAPON_SINGLE, "zombie/z_miss.wav", 1, ATTN_NORM);	// bounce sound
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
	_sound(this, CH_WEAPON_SINGLE, "zombie/z_shot1.wav", 1, ATTN_NORM);

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


void zombie_atta13(entity this) { set_animofs(this, anim_zombie_atta, 13, zombie_run1); ai_face(this); ZombieFireGrenade(this, '-10 -22 30'); }
void zombie_atta12(entity this) { set_animofs(this, anim_zombie_atta, 12, zombie_atta13); ai_face(this); }
void zombie_atta11(entity this) { set_animofs(this, anim_zombie_atta, 11, zombie_atta12); ai_face(this); }
void zombie_atta10(entity this) { set_animofs(this, anim_zombie_atta, 10, zombie_atta11); ai_face(this); }
void zombie_atta9(entity this) { set_animofs(this, anim_zombie_atta, 9, zombie_atta10); ai_face(this); }
void zombie_atta8(entity this) { set_animofs(this, anim_zombie_atta, 8, zombie_atta9); ai_face(this); }
void zombie_atta7(entity this) { set_animofs(this, anim_zombie_atta, 7, zombie_atta8); ai_face(this); }
void zombie_atta6(entity this) { set_animofs(this, anim_zombie_atta, 6, zombie_atta7); ai_face(this); }
void zombie_atta5(entity this) { set_animofs(this, anim_zombie_atta, 5, zombie_atta6); ai_face(this); }
void zombie_atta4(entity this) { set_animofs(this, anim_zombie_atta, 4, zombie_atta5); ai_face(this); }
void zombie_atta3(entity this) { set_animofs(this, anim_zombie_atta, 3, zombie_atta4); ai_face(this); }
void zombie_atta2(entity this) { set_animofs(this, anim_zombie_atta, 2, zombie_atta3); ai_face(this); }
void zombie_atta1(entity this) { set_animofs(this, anim_zombie_atta, 1, zombie_atta2); ai_face(this); }

void zombie_attb14(entity this) { set_animofs(this, anim_zombie_attb, 13, zombie_run1); ai_face(this); ZombieFireGrenade(this, '-10 -24 29'); }
void zombie_attb13(entity this) { set_animofs(this, anim_zombie_attb, 13, zombie_attb14); ai_face(this); }
void zombie_attb12(entity this) { set_animofs(this, anim_zombie_attb, 12, zombie_attb13); ai_face(this); }
void zombie_attb11(entity this) { set_animofs(this, anim_zombie_attb, 11, zombie_attb12); ai_face(this); }
void zombie_attb10(entity this) { set_animofs(this, anim_zombie_attb, 10, zombie_attb11); ai_face(this); }
void zombie_attb9(entity this) { set_animofs(this, anim_zombie_attb, 9, zombie_attb10); ai_face(this); }
void zombie_attb8(entity this) { set_animofs(this, anim_zombie_attb, 8, zombie_attb9); ai_face(this); }
void zombie_attb7(entity this) { set_animofs(this, anim_zombie_attb, 7, zombie_attb8); ai_face(this); }
void zombie_attb6(entity this) { set_animofs(this, anim_zombie_attb, 6, zombie_attb7); ai_face(this); }
void zombie_attb5(entity this) { set_animofs(this, anim_zombie_attb, 5, zombie_attb6); ai_face(this); }
void zombie_attb4(entity this) { set_animofs(this, anim_zombie_attb, 4, zombie_attb5); ai_face(this); }
void zombie_attb3(entity this) { set_animofs(this, anim_zombie_attb, 3, zombie_attb4); ai_face(this); }
void zombie_attb2(entity this) { set_animofs(this, anim_zombie_attb, 2, zombie_attb3); ai_face(this); }
void zombie_attb1(entity this) { set_animofs(this, anim_zombie_attb, 1, zombie_attb2); ai_face(this); }

void zombie_attc12(entity this) { set_animofs(this, anim_zombie_attc, 12, zombie_run1); ai_face(this); ZombieFireGrenade(this, '-12 -19 29'); }
void zombie_attc11(entity this) { set_animofs(this, anim_zombie_attc, 11, zombie_attc12); ai_face(this); }
void zombie_attc10(entity this) { set_animofs(this, anim_zombie_attc, 10, zombie_attc11); ai_face(this); }
void zombie_attc9(entity this) { set_animofs(this, anim_zombie_attc, 9, zombie_attc10); ai_face(this); }
void zombie_attc8(entity this) { set_animofs(this, anim_zombie_attc, 8, zombie_attc9); ai_face(this); }
void zombie_attc7(entity this) { set_animofs(this, anim_zombie_attc, 7, zombie_attc8); ai_face(this); }
void zombie_attc6(entity this) { set_animofs(this, anim_zombie_attc, 6, zombie_attc7); ai_face(this); }
void zombie_attc5(entity this) { set_animofs(this, anim_zombie_attc, 5, zombie_attc6); ai_face(this); }
void zombie_attc4(entity this) { set_animofs(this, anim_zombie_attc, 4, zombie_attc5); ai_face(this); }
void zombie_attc3(entity this) { set_animofs(this, anim_zombie_attc, 3, zombie_attc4); ai_face(this); }
void zombie_attc2(entity this) { set_animofs(this, anim_zombie_attc, 2, zombie_attc3); ai_face(this); }
void zombie_attc1(entity this) { set_animofs(this, anim_zombie_attc, 1, zombie_attc2); ai_face(this); }

void zombie_missile(entity this)
{
	float r = random();
	if(MP_ROGUE)
		droptofloor(this);
	
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

void zombie_paina12(entity this) { set_animofs(this, anim_zombie_paina, 12, zombie_run1); }
void zombie_paina11(entity this) { set_animofs(this, anim_zombie_paina, 11, zombie_paina12); }
void zombie_paina10(entity this) { set_animofs(this, anim_zombie_paina, 10, zombie_paina11); }
void zombie_paina9(entity this) { set_animofs(this, anim_zombie_paina, 9, zombie_paina10); }
void zombie_paina8(entity this) { set_animofs(this, anim_zombie_paina, 8, zombie_paina9); }
void zombie_paina7(entity this) { set_animofs(this, anim_zombie_paina, 7, zombie_paina8); }
void zombie_paina6(entity this) { set_animofs(this, anim_zombie_paina, 6, zombie_paina7); ai_pain(this, 1); }
void zombie_paina5(entity this) { set_animofs(this, anim_zombie_paina, 5, zombie_paina6); ai_pain(this, 3); }
void zombie_paina4(entity this) { set_animofs(this, anim_zombie_paina, 4, zombie_paina5); ai_pain(this, 1); }
void zombie_paina3(entity this) { set_animofs(this, anim_zombie_paina, 3, zombie_paina4); ai_painforward(this, 1); }
void zombie_paina2(entity this) { set_animofs(this, anim_zombie_paina, 2, zombie_paina3); ai_painforward(this, 3); }
void zombie_paina1(entity this) { set_animofs(this, anim_zombie_paina, 1, zombie_paina2); _sound(this, CH_VOICE, "zombie/z_pain.wav", 1, ATTN_NORM); }

void zombie_painb28(entity this) { set_animofs(this, anim_zombie_painb, 28, zombie_run1); }
void zombie_painb27(entity this) { set_animofs(this, anim_zombie_painb, 27, zombie_painb28); }
void zombie_painb26(entity this) { set_animofs(this, anim_zombie_painb, 26, zombie_painb27); }
void zombie_painb25(entity this) { set_animofs(this, anim_zombie_painb, 25, zombie_painb26); ai_painforward(this, 1); }
void zombie_painb24(entity this) { set_animofs(this, anim_zombie_painb, 24, zombie_painb25); }
void zombie_painb23(entity this) { set_animofs(this, anim_zombie_painb, 23, zombie_painb24); }
void zombie_painb22(entity this) { set_animofs(this, anim_zombie_painb, 22, zombie_painb23); }
void zombie_painb21(entity this) { set_animofs(this, anim_zombie_painb, 21, zombie_painb22); }
void zombie_painb20(entity this) { set_animofs(this, anim_zombie_painb, 20, zombie_painb21); }
void zombie_painb19(entity this) { set_animofs(this, anim_zombie_painb, 19, zombie_painb20); }
void zombie_painb18(entity this) { set_animofs(this, anim_zombie_painb, 18, zombie_painb19); }
void zombie_painb17(entity this) { set_animofs(this, anim_zombie_painb, 17, zombie_painb18); }
void zombie_painb16(entity this) { set_animofs(this, anim_zombie_painb, 16, zombie_painb17); }
void zombie_painb15(entity this) { set_animofs(this, anim_zombie_painb, 15, zombie_painb16); }
void zombie_painb14(entity this) { set_animofs(this, anim_zombie_painb, 14, zombie_painb15); }
void zombie_painb13(entity this) { set_animofs(this, anim_zombie_painb, 13, zombie_painb14); }
void zombie_painb12(entity this) { set_animofs(this, anim_zombie_painb, 12, zombie_painb13); }
void zombie_painb11(entity this) { set_animofs(this, anim_zombie_painb, 11, zombie_painb12); }
void zombie_painb10(entity this) { set_animofs(this, anim_zombie_painb, 10, zombie_painb11); }
void zombie_painb9(entity this) { set_animofs(this, anim_zombie_painb, 9, zombie_painb10); _sound(this, CH_PLAYER, "zombie/z_fall.wav", 1, ATTN_NORM); }
void zombie_painb8(entity this) { set_animofs(this, anim_zombie_painb, 8, zombie_painb9); }
void zombie_painb7(entity this) { set_animofs(this, anim_zombie_painb, 7, zombie_painb8); }
void zombie_painb6(entity this) { set_animofs(this, anim_zombie_painb, 6, zombie_painb7); }
void zombie_painb5(entity this) { set_animofs(this, anim_zombie_painb, 5, zombie_painb6); ai_pain(this, 2); }
void zombie_painb4(entity this) { set_animofs(this, anim_zombie_painb, 4, zombie_painb5); ai_pain(this, 6); }
void zombie_painb3(entity this) { set_animofs(this, anim_zombie_painb, 3, zombie_painb4); ai_pain(this, 8); }
void zombie_painb2(entity this) { set_animofs(this, anim_zombie_painb, 2, zombie_painb3); ai_pain(this, 2); }
void zombie_painb1(entity this) { set_animofs(this, anim_zombie_painb, 1, zombie_painb2); _sound(this, CH_VOICE, "zombie/z_pain1.wav", 1, ATTN_NORM); }

void zombie_painc18(entity this) { set_animofs(this, anim_zombie_painc, 18, zombie_run1); }
void zombie_painc17(entity this) { set_animofs(this, anim_zombie_painc, 17, zombie_painc18); }
void zombie_painc16(entity this) { set_animofs(this, anim_zombie_painc, 16, zombie_painc17); }
void zombie_painc15(entity this) { set_animofs(this, anim_zombie_painc, 15, zombie_painc16); }
void zombie_painc14(entity this) { set_animofs(this, anim_zombie_painc, 14, zombie_painc15); }
void zombie_painc13(entity this) { set_animofs(this, anim_zombie_painc, 13, zombie_painc14); }
void zombie_painc12(entity this) { set_animofs(this, anim_zombie_painc, 12, zombie_painc13); ai_painforward(this, 1); }
void zombie_painc11(entity this) { set_animofs(this, anim_zombie_painc, 11, zombie_painc12); ai_painforward(this, 1); }
void zombie_painc10(entity this) { set_animofs(this, anim_zombie_painc, 10, zombie_painc11); }
void zombie_painc9(entity this) { set_animofs(this, anim_zombie_painc, 9, zombie_painc10); }
void zombie_painc8(entity this) { set_animofs(this, anim_zombie_painc, 8, zombie_painc9); }
void zombie_painc7(entity this) { set_animofs(this, anim_zombie_painc, 7, zombie_painc8); }
void zombie_painc6(entity this) { set_animofs(this, anim_zombie_painc, 6, zombie_painc7); }
void zombie_painc5(entity this) { set_animofs(this, anim_zombie_painc, 5, zombie_painc6); }
void zombie_painc4(entity this) { set_animofs(this, anim_zombie_painc, 4, zombie_painc5); ai_pain(this, 1); }
void zombie_painc3(entity this) { set_animofs(this, anim_zombie_painc, 3, zombie_painc4); ai_pain(this, 3); }
void zombie_painc2(entity this) { set_animofs(this, anim_zombie_painc, 2, zombie_painc3); }
void zombie_painc1(entity this) { set_animofs(this, anim_zombie_painc, 1, zombie_painc2); _sound(this, CH_VOICE, "zombie/z_pain1.wav", 1, ATTN_NORM); }

void zombie_paind13(entity this) { set_animofs(this, anim_zombie_paind, 13, zombie_run1); }
void zombie_paind12(entity this) { set_animofs(this, anim_zombie_paind, 12, zombie_paind13); }
void zombie_paind11(entity this) { set_animofs(this, anim_zombie_paind, 11, zombie_paind12); }
void zombie_paind10(entity this) { set_animofs(this, anim_zombie_paind, 10, zombie_paind11); }
void zombie_paind9(entity this) { set_animofs(this, anim_zombie_paind, 9, zombie_paind10); ai_pain(this, 1); }
void zombie_paind8(entity this) { set_animofs(this, anim_zombie_paind, 8, zombie_paind9); }
void zombie_paind7(entity this) { set_animofs(this, anim_zombie_paind, 7, zombie_paind8); }
void zombie_paind6(entity this) { set_animofs(this, anim_zombie_paind, 6, zombie_paind7); }
void zombie_paind5(entity this) { set_animofs(this, anim_zombie_paind, 5, zombie_paind6); }
void zombie_paind4(entity this) { set_animofs(this, anim_zombie_paind, 4, zombie_paind5); }
void zombie_paind3(entity this) { set_animofs(this, anim_zombie_paind, 3, zombie_paind4); }
void zombie_paind2(entity this) { set_animofs(this, anim_zombie_paind, 2, zombie_paind3); }
void zombie_paind1(entity this) { set_animofs(this, anim_zombie_paind, 1, zombie_paind2); _sound(this, CH_VOICE, "zombie/z_pain.wav", 1, ATTN_NORM); if(MP_ROGUE) droptofloor(this); }

void zombie_paine11(entity this);
void zombie_paine30(entity this) { set_animofs(this, anim_zombie_paine, 30, zombie_run1); }
void zombie_paine29(entity this) { set_animofs(this, anim_zombie_paine, 29, zombie_paine30); }
void zombie_paine28(entity this) { set_animofs(this, anim_zombie_paine, 28, zombie_paine29); ai_pain(this, 1); }
void zombie_paine27(entity this) { set_animofs(this, anim_zombie_paine, 27, zombie_paine28); ai_painforward(this, 1); }
void zombie_paine26(entity this) { set_animofs(this, anim_zombie_paine, 26, zombie_paine27); ai_painforward(this, 3); }
void zombie_paine25(entity this) { set_animofs(this, anim_zombie_paine, 25, zombie_paine26); ai_painforward(this, 5); }
void zombie_paine24(entity this) { set_animofs(this, anim_zombie_paine, 24, zombie_paine25); }
void zombie_paine23(entity this) { set_animofs(this, anim_zombie_paine, 23, zombie_paine24); }
void zombie_paine22(entity this) { set_animofs(this, anim_zombie_paine, 22, zombie_paine23); }
void zombie_paine21(entity this) { set_animofs(this, anim_zombie_paine, 21, zombie_paine22); }
void zombie_paine20(entity this) { set_animofs(this, anim_zombie_paine, 20, zombie_paine21); }
void zombie_paine19(entity this) { set_animofs(this, anim_zombie_paine, 19, zombie_paine20); }
void zombie_paine18(entity this) { set_animofs(this, anim_zombie_paine, 18, zombie_paine19); }
void zombie_paine17(entity this) { set_animofs(this, anim_zombie_paine, 17, zombie_paine18); }
void zombie_paine16(entity this) { set_animofs(this, anim_zombie_paine, 16, zombie_paine17); }
void zombie_paine15(entity this) { set_animofs(this, anim_zombie_paine, 15, zombie_paine16); }
void zombie_paine14(entity this) { set_animofs(this, anim_zombie_paine, 14, zombie_paine15); }
void zombie_paine13(entity this) { set_animofs(this, anim_zombie_paine, 13, zombie_paine14); }
void zombie_paine12(entity this)
{
	set_animofs(this, anim_zombie_paine, 12, zombie_paine13);
	if(MP_ROGUE)
		droptofloor(this);
	// see if ok to stand up
	this.health = 60;
	_sound(this, CH_VOICE, "zombie/z_idle.wav", 1, ATTN_IDLE);
	if(MP_ROGUE)
		setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	this.solid = SOLID_SLIDEBOX;
	if(!t_walkmove(this, 0, 0))
	{
		setthink(this, zombie_paine11);
		if(MP_IMPEL)
			this.nextthink = time + 1;
		else
			this.solid = SOLID_NOT;
		return;
	}
}
void zombie_paine11(entity this)
{
	set_animofs(this, anim_zombie_paine, 11, zombie_paine12);
	if(MP_IMPEL)
	{
		this.solid = SOLID_NOT;
		this.nextthink = time + 5;
		this.health = 60;
	}
	// TODO: original quake has logic here missing from mine?!
}
void zombie_paine10(entity this)
{
	set_animofs(this, anim_zombie_paine, 10, zombie_paine11);
	_sound(this, CH_PLAYER, "zombie/z_fall.wav", 1, ATTN_NORM);
	this.solid = SOLID_NOT;
}
void zombie_paine9(entity this) { set_animofs(this, anim_zombie_paine, 9, zombie_paine10); ai_pain(this, 2); }
void zombie_paine8(entity this) { set_animofs(this, anim_zombie_paine, 8, zombie_paine9); ai_pain(this, 1); }
void zombie_paine7(entity this) { set_animofs(this, anim_zombie_paine, 7, zombie_paine8); ai_pain(this, 1); }
void zombie_paine6(entity this) { set_animofs(this, anim_zombie_paine, 6, zombie_paine7); ai_pain(this, 2); }
void zombie_paine5(entity this) { set_animofs(this, anim_zombie_paine, 5, zombie_paine6); ai_pain(this, 1); }
void zombie_paine4(entity this) { set_animofs(this, anim_zombie_paine, 4, zombie_paine5); ai_pain(this, 3); }
void zombie_paine3(entity this) { set_animofs(this, anim_zombie_paine, 3, zombie_paine4); ai_pain(this, 5); }
void zombie_paine2(entity this) { set_animofs(this, anim_zombie_paine, 2, zombie_paine3); ai_pain(this, 8); }
void zombie_paine1(entity this)
{
	set_animofs(this, anim_zombie_paine, 1, zombie_paine2);
	_sound(this, CH_VOICE, "zombie/z_pain.wav", 1, ATTN_NORM);
	this.health = 60;
}

void zombie_die(entity this, entity inflictor, entity attacker)
{
	_sound(this, CH_VOICE, "zombie/z_gib.wav", 1, ATTN_NORM);
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
	if(attacker.solid == SOLID_BSP || !attacker)
		return; // if killed by trigger or world, don't reset health

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

void zombie_lay12(entity this, entity attacker, float damage) { set_animofs(this, anim_zombie_paine, 12, zombie_paine13); this.th_pain = zombie_pain; }

void zombie_lay(entity this)
{
	set_animofs(this, anim_zombie_paine, 11, zombie_lay);
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

void zombie_sleep(entity this) { set_animofs(this, anim_zombie_paine, 11, zombie_sleep); ai_stand(this); }

void zombie_wake(entity this)
{
	this.th_stand = zombie_stand1;
	this.th_walk = zombie_walk1;
	this.th_pain = zombie_pain;
	this.th_run = zombie_run1;
	this.th_missile = zombie_missile;

//	paine12 will handle setting solid, just make the size box correct.
//	this.solid = SOLID_SLIDEBOX;
//	setsize(this, '-16 -16 -24', '16 16 40');

	zombie_paine12(this);
}

void zombie_wake_pain(entity this, entity attacker, float damage)
{
	zombie_wake(this);
}

void zombie_escape16(entity this)
{
	set_animofs(this, anim_zombie_cruc, 16, zombie_run1);

	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);
	this.takedamage = DAMAGE_AIM;
	this.th_stand = zombie_stand1;
	this.th_walk = zombie_walk1;
	this.th_pain = zombie_pain;
	this.th_run = zombie_run1;
	this.th_missile = zombie_missile;
	this.health = 60;
	_sound(this, CH_VOICE, "zombie/z_idle.wav", 1, ATTN_IDLE);

	droptofloor(this);
}
void zombie_escape15(entity this)
{
	set_animofs(this, anim_zombie_cruc, 15, zombie_escape16);

	makevectors(this.angles);
	setorigin(this, this.origin + v_forward * 8);
	this.nextthink = time + 0.15;
}
void zombie_escape14(entity this)
{
	set_animofs(this, anim_zombie_cruc, 14, zombie_escape15);

	makevectors(this.angles);
	setorigin(this, this.origin + v_forward * 8);
	this.nextthink = time + 0.15;
}
void zombie_escape13(entity this) { set_animofs(this, anim_zombie_cruc, 13, zombie_escape14); this.nextthink = time + 0.10; }
void zombie_escape12(entity this) { set_animofs(this, anim_zombie_cruc, 12, zombie_escape13); this.nextthink = time + 0.10; }
void zombie_escape11(entity this) { set_animofs(this, anim_zombie_cruc, 11, zombie_escape12); this.nextthink = time + 0.10; }
void zombie_escape10(entity this) { set_animofs(this, anim_zombie_cruc, 10, zombie_escape11); this.nextthink = time + 0.15; }
void zombie_escape9(entity this) { set_animofs(this, anim_zombie_cruc, 9, zombie_escape10); this.nextthink = time + 0.15; }
void zombie_escape8(entity this) { set_animofs(this, anim_zombie_cruc, 8, zombie_escape9); this.nextthink = time + 0.15; }
void zombie_escape7(entity this) { set_animofs(this, anim_zombie_cruc, 7, zombie_escape8); this.nextthink = time + 0.15; }
void zombie_escape6(entity this) { set_animofs(this, anim_zombie_cruc, 6, zombie_escape7); this.nextthink = time + 0.15; }
void zombie_escape5(entity this) { set_animofs(this, anim_zombie_cruc, 5, zombie_escape6); this.nextthink = time + 0.15; }
void zombie_escape4(entity this) { set_animofs(this, anim_zombie_cruc, 4, zombie_escape5); this.nextthink = time + 0.20; }
void zombie_escape3(entity this) { set_animofs(this, anim_zombie_cruc, 3, zombie_escape4); this.nextthink = time + 0.20; }
void zombie_escape2(entity this) { set_animofs(this, anim_zombie_cruc, 2, zombie_escape3); this.nextthink = time + 0.20; }
void zombie_escape1(entity this) { set_animofs(this, anim_zombie_cruc, 1, zombie_escape2); this.nextthink = time + 0.20; }

void zombie_escape(entity this) 
{
	if(!this.pain_finished)
		this.pain_finished = time + this.delay;

	setthink(this, zombie_cruc1);
	this.nextthink = time + 0.1;
}
void zombie_escape_pain(entity this, entity attacker, float damage)
{
	zombie_escape(this);
}

string zombie_sight(entity this) { return "zombie/z_idle.wav"; }
string zombie_deathmessage(entity this) { return "joins the Zombies"; }

//============================================================================

/*QUAKED monster_zombie(1 0 0)(-16 -16 -24)(16 16 32) Crucified Lying ambush Sneaky

Crucified - Zombie stays stuck in the wall, moans and writhes.
Lying - (rogue only) Zombie will start lying down, and stand when player spotted.
Ambush - Just like all the other ambush flags.
Sneaky - (rogue only) Zombie stays stuck in the wall, but breaks his chains, hops off the wall, and attacks after seeing the player.

If crucified, stick the bounding box 12 pixels back into a wall to look right.
If lying_down in hipnotic, the zombie will be lying down when spawned and will rise up
when awakened by the player.
*/
spawnfunc(monster_zombie)
{
	if(deathmatch) { delete(this); return; }

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

	if(MP_ROGUE)
		setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	else
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
	else if(MP_ROGUE && (this.spawnflags & SPAWN_LYING))
	{
		this.solid = SOLID_NOT;
		this.th_stand = zombie_sleep;
		this.th_run = zombie_wake;
		this.th_walk = zombie_wake;
		this.th_pain = zombie_wake_pain;
		this.th_missile = zombie_wake;
		setsize(this, '-16 -16 -24', '16 16 -16');

		// HOLY HACK, BATMAN! - Don't blame me. Check out FindTarget in ai.qc!
		if(this.spawnflags & SPAWN_AMBUSH)
			this.spawnflags = SPAWN_LYING;

		monster_start(this, 0);
	}
	else if(MP_ROGUE && (this.spawnflags & SPAWN_SNEAKY))
	{
		set_movetype(this, MOVETYPE_NONE);
		this.solid = SOLID_NOT;
		this.th_stand = zombie_cruc1;
		this.th_run = zombie_escape;
		this.th_walk = zombie_escape;
		this.th_pain = zombie_escape_pain;
		this.th_missile = zombie_escape;

		if(!this.delay)
			this.delay = 3;

		this.ideal_yaw = this.angles * '0 1 0';
		if(!this.yaw_speed)
			this.yaw_speed = 20;
		this.view_ofs = '0 0 25';
		this.flags |= FL_MONSTER;
		this.th_stand(this);
		this.nextthink = this.nextthink + random() * 0.5;
		if(!this.damagedbycontents)
			IL_PUSH(g_damagedbycontents, this);
		this.damagedbycontents	= true;
		monsters_total += 1;
	}
	else
	{
		if(MP_ROGUE && (this.spawnflags & SPAWN_AMBUSH))
			this.spawnflags = SPAWN_LYING;
		monster_start(this, 0);
	}

	if(MP_HIPNOTIC && (this.spawnflags & SPAWN_LYINGDOWN))
		this.th_stand = zombie_lay;
}
