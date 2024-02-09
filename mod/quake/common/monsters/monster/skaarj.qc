#include "skaarj.qh"
#include "skaarj_ai.qh"

#ifdef SVQC
const int anim_skaarj_stand = 0; //'0 7 0'
const int anim_skaarj_death = 8; //'8 17 0'
const int anim_skaarj_deathc = 18; //'18 28 0'
const int anim_skaarj_load = 29; //'29 39 0'
const int anim_skaarj_pain = 40; //'40 45 0'
const int anim_skaarj_painb = 46; //'46 59 0'
const int anim_skaarj_painc = 60; //'60 72 0'
const int anim_skaarj_run = 73; //'73 80 0'
const int anim_skaarj_shoot = 81; //'81 89 0'
const int anim_skaarj_prowl = 90; //'90 113 0'

/*
==============================================================================

SKAARJ

==============================================================================

id	seq					lgt	st	end	spd
2	claw				11	0	10	15
3	GutHit				1	11	11	0
4	guncheck			7	12	18	6
5	Breath				12	19	30	6
17	Death2				13	31	43	15
19	Death4				11	44	54	15
20	Duck				1	55	55	0
21	Fighter				15	56	70	15
22	Firing				11	71	81	15
25	HeadHit				1	82	82	0
27	Jog2Fight			11	83	93	15
28	Jog					10	94	103	15
35	LeftDodge			13	104	116	15
37	StrafeLeftFr		14	117	130	15
39	StrafeLeft			14	131	144	15
40	Lunge				13	145	157	15
41	StrafeRightFr		14	158	171	15
43	StrafeRight			14	172	185	15
44	Spin				20	186	205	15
45	gunfix				8	206	213	6
47	Walk				15	214	228	15
49	RightDodge			13	229	241	15
50	JogFire				10	242	251	15


*/

void skaarj_fight(entity this);

.bool skaarj_spin_finished;

const float SK_ANIMTIME = 0.066666;
const float SK_WALKTIME = 0.166666;
const float SK_SPINTIME = 0.05;

void skframe(entity this, float frm, void(entity) nxtfunc, float nxtthink)
{
	if(time > this.sk_painanim_finished)
		this.frame = frm;
	/*else {
		if(this.height == 1) this.frame = 82;
		else this.frame = 11;
	}*/
	setthink(this, nxtfunc);
	this.nextthink = time + nxtthink;
}

void skthink(entity this, float t)
{
	//if(!delay) delay = SK_ANIMTIME;
	this.nextthink = time + t;
}

void skaarj_fire(entity this, vector org1, vector org2);

void skaarj_stand(entity this)
{
	if(this.frame >= 30 || this.frame < 19)
		this.frame = 19;
	else
		this.frame++;

	setthink(this, skaarj_stand);
	skthink(this, SK_WALKTIME);

	ai_stand(this);
}

void skaarj_sit(entity this)
{
	float frm = this.frame;
	if(!(this.frame >= 12 && this.frame <= 18) && !(this.frame >= 206 && this.frame <= 203))
		frm = 12;
	else if(this.frame == 18)
		frm = 206;
	else if(this.frame == 213)
		frm = 12;
	else
		frm++;

	skframe(this, frm, skaarj_sit, SK_WALKTIME);

	ai_stand(this);
}

void skaarj_walk1(entity this);
void skaarj_walk15(entity this)
{
	skframe(this, 228, skaarj_walk1, SK_WALKTIME);
	ai_walk(this, 8);
	if(random() < 0.3)
		_sound(this, CH_VOICE, "skaarj/roam11s.wav", 1, ATTN_IDLE);
}
void skaarj_walk14(entity this) { skframe(this, 227, skaarj_walk15, SK_WALKTIME); ai_walk(this, 8); }
void skaarj_walk13(entity this) { skframe(this, 226, skaarj_walk14, SK_WALKTIME); ai_walk(this, 5); }
void skaarj_walk12(entity this) { skframe(this, 225, skaarj_walk13, SK_WALKTIME); ai_walk(this, 5); }
void skaarj_walk11(entity this) { skframe(this, 224, skaarj_walk12, SK_WALKTIME); ai_walk(this, 5); }
void skaarj_walk10(entity this) { skframe(this, 223, skaarj_walk11, SK_WALKTIME); ai_walk(this, 10); }
void skaarj_walk9(entity this) { skframe(this, 222, skaarj_walk10, SK_WALKTIME); ai_walk(this, 10); }
void skaarj_walk8(entity this) { skframe(this, 221, skaarj_walk9, SK_WALKTIME); ai_walk(this, 10); }
void skaarj_walk7(entity this) { skframe(this, 220, skaarj_walk8, SK_WALKTIME); ai_walk(this, 8); }
void skaarj_walk6(entity this) { skframe(this, 219, skaarj_walk7, SK_WALKTIME); ai_walk(this, 8); }
void skaarj_walk5(entity this) { skframe(this, 218, skaarj_walk6, SK_WALKTIME); ai_walk(this, 8); }
void skaarj_walk4(entity this) { skframe(this, 217, skaarj_walk5, SK_WALKTIME); ai_walk(this, 5); }
void skaarj_walk3(entity this) { skframe(this, 216, skaarj_walk4, SK_WALKTIME); ai_walk(this, 8); }
void skaarj_walk2(entity this) { skframe(this, 215, skaarj_walk3, SK_WALKTIME); ai_walk(this, 8); }
void skaarj_walk1(entity this) { skframe(this, 214, skaarj_walk2, SK_WALKTIME); ai_walk(this, 8); }

void skaarj_strafeleft14(entity this) { skframe(this, 144, skaarj_fight, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft13(entity this) { skframe(this, 143, skaarj_strafeleft14, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft12(entity this) { skframe(this, 142, skaarj_strafeleft13, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft11(entity this) { skframe(this, 141, skaarj_strafeleft12, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft10(entity this) { skframe(this, 140, skaarj_strafeleft11, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft9(entity this) { skframe(this, 139, skaarj_strafeleft10, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft8(entity this) { skframe(this, 138, skaarj_strafeleft9, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft7(entity this) { skframe(this, 137, skaarj_strafeleft8, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft6(entity this) { skframe(this, 136, skaarj_strafeleft7, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft5(entity this) { skframe(this, 135, skaarj_strafeleft6, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft4(entity this) { skframe(this, 134, skaarj_strafeleft5, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft3(entity this) { skframe(this, 133, skaarj_strafeleft4, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft2(entity this) { skframe(this, 132, skaarj_strafeleft3, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft1(entity this) { skframe(this, 131, skaarj_strafeleft2, SK_ANIMTIME); sk_strafe(this, 6, -60); }

void skaarj_strafeleft_fr1(entity this);
void skaarj_strafeleft_fr14(entity this)
{
	skframe(this, 130, skaarj_strafeleft1, SK_ANIMTIME);
	sk_strafe(this, 6, -60);
	if(sk_checkrefire(this))
		setthink(this, skaarj_strafeleft_fr1);
}
void skaarj_strafeleft_fr13(entity this) { skframe(this, 129, skaarj_strafeleft_fr14, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft_fr12(entity this) { skframe(this, 128, skaarj_strafeleft_fr13, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft_fr11(entity this) { skframe(this, 127, skaarj_strafeleft_fr12, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft_fr10(entity this) { skframe(this, 126, skaarj_strafeleft_fr11, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft_fr9(entity this)
{
	skframe(this, 125, skaarj_strafeleft_fr10, SK_ANIMTIME);
	skaarj_fire(this, '8 -16 16','8 24 16');
	sk_strafe(this, 6, -60);
}
void skaarj_strafeleft_fr8(entity this) { skframe(this, 124, skaarj_strafeleft_fr9, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft_fr7(entity this) { skframe(this, 123, skaarj_strafeleft_fr8, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft_fr6(entity this) { skframe(this, 122, skaarj_strafeleft_fr7, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft_fr5(entity this) { skframe(this, 121, skaarj_strafeleft_fr6, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft_fr4(entity this) { skframe(this, 120, skaarj_strafeleft_fr5, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft_fr3(entity this) { skframe(this, 119, skaarj_strafeleft_fr4, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft_fr2(entity this) { skframe(this, 118, skaarj_strafeleft_fr3, SK_ANIMTIME); sk_strafe(this, 6, -60); }
void skaarj_strafeleft_fr1(entity this) { skframe(this, 117, skaarj_strafeleft_fr2, SK_ANIMTIME); sk_strafe(this, 6, -60); }

void skaarj_straferight14(entity this) { skframe(this, 185, skaarj_fight, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight13(entity this) { skframe(this, 184, skaarj_straferight14, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight12(entity this) { skframe(this, 183, skaarj_straferight13, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight11(entity this) { skframe(this, 182, skaarj_straferight12, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight10(entity this) { skframe(this, 181, skaarj_straferight11, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight9(entity this) { skframe(this, 180, skaarj_straferight10, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight8(entity this) { skframe(this, 179, skaarj_straferight9, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight7(entity this) { skframe(this, 178, skaarj_straferight8, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight6(entity this) { skframe(this, 177, skaarj_straferight7, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight5(entity this) { skframe(this, 176, skaarj_straferight6, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight4(entity this) { skframe(this, 175, skaarj_straferight5, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight3(entity this) { skframe(this, 174, skaarj_straferight4, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight2(entity this) { skframe(this, 173, skaarj_straferight3, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight1(entity this) { skframe(this, 172, skaarj_straferight2, SK_ANIMTIME); sk_strafe(this, 6, 60); }

void skaarj_straferight_fr1(entity this);
void skaarj_straferight_fr14(entity this)
{
	skframe(this, 171, skaarj_straferight1, SK_ANIMTIME);
	sk_strafe(this, 6, 60);
	if(sk_checkrefire(this))
		setthink(this, skaarj_straferight_fr1);
}
void skaarj_straferight_fr13(entity this) { skframe(this, 170, skaarj_straferight_fr14, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight_fr12(entity this) { skframe(this, 169, skaarj_straferight_fr13, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight_fr11(entity this) { skframe(this, 168, skaarj_straferight_fr12, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight_fr10(entity this) { skframe(this, 167, skaarj_straferight_fr11, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight_fr9(entity this)
{
	skframe(this, 166, skaarj_straferight_fr10, SK_ANIMTIME);
	skaarj_fire(this, '8 -16 16','8 24 16');
	sk_strafe(this, 6, 60);
}
void skaarj_straferight_fr8(entity this) { skframe(this, 165, skaarj_straferight_fr9, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight_fr7(entity this) { skframe(this, 164, skaarj_straferight_fr8, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight_fr6(entity this) { skframe(this, 163, skaarj_straferight_fr7, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight_fr5(entity this) { skframe(this, 162, skaarj_straferight_fr6, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight_fr4(entity this) { skframe(this, 161, skaarj_straferight_fr5, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight_fr3(entity this) { skframe(this, 160, skaarj_straferight_fr4, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight_fr2(entity this) { skframe(this, 159, skaarj_straferight_fr3, SK_ANIMTIME); sk_strafe(this, 6, 60); }
void skaarj_straferight_fr1(entity this) { skframe(this, 158, skaarj_straferight_fr2, SK_ANIMTIME); sk_strafe(this, 6, 60); }

void skaarj_fight1(entity this);
void skaarj_fight(entity this)
{
	this.cnt = 0;
	this.skaarj_fight_finished = time + 1 + random() * 1;
	skaarj_fight1(this);
}

void skaarj_fight15(entity this) { skframe(this, 70, skaarj_fight1, SK_ANIMTIME); sk_fight(this, 0); }
void skaarj_fight14(entity this) { skframe(this, 69, skaarj_fight15, SK_ANIMTIME); sk_fight(this, 0); }
void skaarj_fight13(entity this) { skframe(this, 68, skaarj_fight14, SK_ANIMTIME); sk_fight(this, 0); }
void skaarj_fight12(entity this) { skframe(this, 67, skaarj_fight13, SK_ANIMTIME); sk_fight(this, 0); }
void skaarj_fight11(entity this) { skframe(this, 66, skaarj_fight12, SK_ANIMTIME); sk_fight(this, 0); }
void skaarj_fight10(entity this) { skframe(this, 65, skaarj_fight11, SK_ANIMTIME); sk_fight(this, 0); }
void skaarj_fight9(entity this) { skframe(this, 64, skaarj_fight10, SK_ANIMTIME); sk_fight(this, 0); }
void skaarj_fight8(entity this) { skframe(this, 63, skaarj_fight9, SK_ANIMTIME); sk_fight(this, 0); }
void skaarj_fight7(entity this) { skframe(this, 62, skaarj_fight8, SK_ANIMTIME); sk_fight(this, 0); }
void skaarj_fight6(entity this) { skframe(this, 61, skaarj_fight7, SK_ANIMTIME); sk_fight(this, 0); }
void skaarj_fight5(entity this) { skframe(this, 60, skaarj_fight6, SK_ANIMTIME); sk_fight(this, 0); }
void skaarj_fight4(entity this) { skframe(this, 59, skaarj_fight5, SK_ANIMTIME); sk_fight(this, 0); }
void skaarj_fight3(entity this) { skframe(this, 58, skaarj_fight4, SK_ANIMTIME); sk_fight(this, 0); }
void skaarj_fight2(entity this) { skframe(this, 57, skaarj_fight3, SK_ANIMTIME); sk_fight(this, 0); }
void skaarj_fight1(entity this) { skframe(this, 56, skaarj_fight2, SK_ANIMTIME); sk_fight(this, 0); }

void skaarj_jog2fight(entity this)
{
	if(this.frame < 83 || this.frame >= 93)
		this.frame = 83;
	else
		this.frame++;

	setthink(this, skaarj_jog2fight);
	skthink(this, SK_ANIMTIME);

	if(this.frame == 93)
		setthink(this, skaarj_fight);
}

void skaarj_run1(entity this);
void skaarj_runfire1(entity this);
void skaarj_run10(entity this) { skframe(this, 103, skaarj_run1, SK_ANIMTIME); sk_run(this, 10); }
void skaarj_run9(entity this) { skframe(this, 102, skaarj_run10, SK_ANIMTIME); sk_run(this, 5); }
void skaarj_run8(entity this) { skframe(this, 101, skaarj_run9, SK_ANIMTIME); sk_run(this, 18); }
void skaarj_run7(entity this) { skframe(this, 100, skaarj_run8, SK_ANIMTIME); sk_run(this, 22); }
void skaarj_run6(entity this) { skframe(this, 99, skaarj_run7, SK_ANIMTIME); sk_run(this, 22); }
void skaarj_run5(entity this) { skframe(this, 98, skaarj_run6, SK_ANIMTIME); sk_run(this, 10); }
void skaarj_run4(entity this) { skframe(this, 97, skaarj_run5, SK_ANIMTIME); sk_run(this, 5); }
void skaarj_run3(entity this) { skframe(this, 96, skaarj_run4, SK_ANIMTIME); sk_run(this, 18); }
void skaarj_run2(entity this) { skframe(this, 95, skaarj_run3, SK_ANIMTIME); sk_run(this, 22); }
void skaarj_run1(entity this)
{
	this.state = SK_ST_RUN;
	skframe(this, 94, skaarj_run2, SK_ANIMTIME);
	//this.th_stand = skaarj_stand;
	if(sk_checkrefire(this))
	{
		skaarj_runfire1(this);
		return;
	}

	this.attack_finished = time + 0.5;

	/*if(vlen(this.origin + this.view_ofs - this.enemy.origin - this.enemy.view_ofs) > 300) {
		skaarj_jog2fight();
		return;
	}*/

	if(random() < 0.2)
		_sound(this, CH_VOICE, "skaarj/chalnge1s.wav", 1, ATTN_NORM);

	sk_run(this, 22);
}

void skaarj_runfire10(entity this) { skframe(this, 251, skaarj_run1, SK_ANIMTIME); sk_run(this, 10); }
void skaarj_runfire9(entity this) { skframe(this, 250, skaarj_runfire10, SK_ANIMTIME); sk_run(this, 5); }
void skaarj_runfire8(entity this) { skframe(this, 249, skaarj_runfire9, SK_ANIMTIME); sk_run(this, 18); }
void skaarj_runfire7(entity this)
{
	skframe(this, 248, skaarj_runfire8, SK_ANIMTIME);
	skaarj_fire(this, '32 -24 16','32 24 16');
	sk_run(this, 22);
}
void skaarj_runfire6(entity this) { skframe(this, 247, skaarj_runfire7, SK_ANIMTIME); sk_run(this, 22); }
void skaarj_runfire5(entity this) { skframe(this, 246, skaarj_runfire6, SK_ANIMTIME); sk_run(this, 10); }
void skaarj_runfire4(entity this) { skframe(this, 245, skaarj_runfire5, SK_ANIMTIME); sk_run(this, 5); }
void skaarj_runfire3(entity this) { skframe(this, 244, skaarj_runfire4, SK_ANIMTIME); sk_run(this, 18); }
void skaarj_runfire2(entity this) { skframe(this, 243, skaarj_runfire3, SK_ANIMTIME); sk_run(this, 22); }
void skaarj_runfire1(entity this)
{
	skframe(this, 242, skaarj_runfire2, SK_ANIMTIME);
	//this.th_stand = skaarj_stand;
	this.attack_finished = time + 0.5;

	/*if(vlen(this.origin + this.view_ofs - this.enemy.origin - this.enemy.view_ofs) > 300)
		skaarj_jog2fight();
	*/
	if(random() < 0.2)
		_sound(this, CH_VOICE, "skaarj/chalnge1s.wav", 1, ATTN_NORM);

	sk_run(this, 22);
}

void skaarj_run_charge1(entity this);
void skaarj_runfire_charge1(entity this);
void skaarj_run_charge10(entity this) { skframe(this, 103, skaarj_run_charge1, SK_ANIMTIME); sk_run_charge(this, 10); }
void skaarj_run_charge9(entity this) { skframe(this, 102, skaarj_run_charge10, SK_ANIMTIME); sk_run_charge(this, 5); }
void skaarj_run_charge8(entity this) { skframe(this, 101, skaarj_run_charge9, SK_ANIMTIME); sk_run_charge(this, 18); }
void skaarj_run_charge7(entity this) { skframe(this, 100, skaarj_run_charge8, SK_ANIMTIME); sk_run_charge(this, 22); }
void skaarj_run_charge6(entity this) { skframe(this, 99, skaarj_run_charge7, SK_ANIMTIME); sk_run_charge(this, 22); }
void skaarj_run_charge5(entity this) { skframe(this, 98, skaarj_run_charge6, SK_ANIMTIME); sk_run_charge(this, 10); }
void skaarj_run_charge4(entity this) { skframe(this, 97, skaarj_run_charge5, SK_ANIMTIME); sk_run_charge(this, 5); }
void skaarj_run_charge3(entity this) { skframe(this, 96, skaarj_run_charge4, SK_ANIMTIME); sk_run_charge(this, 18); }
void skaarj_run_charge2(entity this) { skframe(this, 95, skaarj_run_charge3, SK_ANIMTIME); sk_run_charge(this, 22); }
void skaarj_run_charge1(entity this)
{
	skframe(this, 94, skaarj_run_charge2, SK_ANIMTIME);
	//this.th_stand = skaarj_stand;
	if(sk_checkrefire(this))
	{
		skaarj_runfire_charge1(this);
		return;
	}

	this.attack_finished = time + 0.5;

	if(vdist(this.origin + this.view_ofs - this.enemy.origin - this.enemy.view_ofs, >, 300))
	{
		skaarj_jog2fight(this);
		return;
	}

	if(random() < 0.2)
		_sound(this, CH_VOICE, "skaarj/chalnge1s.wav", 1, ATTN_NORM);

	sk_run_charge(this, 22);
}

void skaarj_runfire_charge10(entity this) { skframe(this, 251,	skaarj_run_charge1, SK_ANIMTIME);sk_run_charge(this, 10); }
void skaarj_runfire_charge9(entity this) { skframe(this, 250,	skaarj_runfire_charge10, SK_ANIMTIME);sk_run_charge(this, 5); }
void skaarj_runfire_charge8(entity this) { skframe(this, 249,	skaarj_runfire_charge9, SK_ANIMTIME);sk_run_charge(this, 18); }
void skaarj_runfire_charge7(entity this)
{
	skframe(this, 248,	skaarj_runfire_charge8, SK_ANIMTIME);
	skaarj_fire(this, '32 -24 16','32 24 16');
	sk_run_charge(this, 22);
}
void skaarj_runfire_charge6(entity this) { skframe(this, 247,	skaarj_runfire_charge7, SK_ANIMTIME);sk_run_charge(this, 22); }
void skaarj_runfire_charge5(entity this) { skframe(this, 246,	skaarj_runfire_charge6, SK_ANIMTIME);sk_run_charge(this, 10); }
void skaarj_runfire_charge4(entity this) { skframe(this, 245,	skaarj_runfire_charge5, SK_ANIMTIME);sk_run_charge(this, 5); }
void skaarj_runfire_charge3(entity this) { skframe(this, 244,	skaarj_runfire_charge4, SK_ANIMTIME);sk_run_charge(this, 18); }
void skaarj_runfire_charge2(entity this) { skframe(this, 243,	skaarj_runfire_charge3, SK_ANIMTIME);sk_run_charge(this, 22); }
void skaarj_runfire_charge1(entity this)
{
	skframe(this, 242, skaarj_runfire_charge2, SK_ANIMTIME);
	//this.th_stand = skaarj_stand;
	this.attack_finished = time + 0.5;

	if(vdist(this.origin + this.view_ofs - this.enemy.origin - this.enemy.view_ofs, >, 300))
		skaarj_jog2fight(this);

	if(random() < 0.2)
		_sound(this, CH_VOICE, "skaarj/chalnge1s.wav", 1, ATTN_NORM);

	sk_run_charge(this, 22);
}

void skaarj_lungetouch(entity this, entity toucher)
{
	if(this.health <= 0)
	{
		settouch(this, func_null);
		return;
	}
		
	if(other.takedamage)
	{
		if(vdist(this.velocity, >, 400))
		{
			float ldmg = 30 + 10*random();
			T_Damage (other, this, this, ldmg, DEATH_MONSTER_SKAARJ.m_id);	
		}
	}

	if(!t_checkbottom(this))
	{
		if(IS_ONGROUND(this))
			settouch(this, func_null);
		return;
	}
	settouch(this, func_null);
}

void skaarj_lunge13(entity this) { skframe(this, 157, skaarj_jog2fight, SK_ANIMTIME); ai_forward(this, 15); }
void skaarj_lunge12(entity this) { skframe(this, 156, skaarj_lunge13, SK_ANIMTIME); ai_forward(this, 20); settouch(this, func_null); }
void skaarj_lunge11(entity this) { skframe(this, 155, skaarj_lunge12, SK_ANIMTIME); ai_forward(this, 20); }
void skaarj_lunge10(entity this) { skframe(this, 154, skaarj_lunge11, SK_ANIMTIME); }
void skaarj_lunge9(entity this) { skframe(this, 153, skaarj_lunge10, SK_ANIMTIME); }
void skaarj_lunge8(entity this) { skframe(this, 152, skaarj_lunge9, SK_ANIMTIME); }
void skaarj_lunge7(entity this) { skframe(this, 151, skaarj_lunge8, SK_ANIMTIME); }
void skaarj_lunge6(entity this) { skframe(this, 150, skaarj_lunge7, SK_ANIMTIME); }
void skaarj_lunge5(entity this) { skframe(this, 149, skaarj_lunge6, SK_ANIMTIME); }
void skaarj_lunge4(entity this) { skframe(this, 148, skaarj_lunge5, SK_ANIMTIME); }
void skaarj_lunge3(entity this) { skframe(this, 147, skaarj_lunge4, SK_ANIMTIME); }
void skaarj_lunge2(entity this)
{
	skframe(this, 146, skaarj_lunge3, SK_ANIMTIME);
	
	makevectors(this.angles);
	this.origin_z = this.origin_z + 1;
	this.velocity = v_forward * 400 + '0 0 250';
	settouch(this, skaarj_lungetouch);
	UNSET_ONGROUND(this);
}
void skaarj_lunge1(entity this)
{
	skframe(this, 145, skaarj_lunge2, SK_ANIMTIME);
	ai_forward(this, 22);
	_sound(this, CH_VOICE, "skaarj/lunge1sk.wav", 1, ATTN_NORM);
}

void skaarj_spindamage(entity this)
{
	if(this.skaarj_spin_finished)
		return;

	vector dest = normalize(this.enemy.origin - this.origin);
	traceline(this.origin, this.origin + dest * 80, false, this);

	if(trace_ent == this.enemy)
	{
		T_Damage(this.enemy, this, this, 30, DEATH_MONSTER_SKAARJ.m_id);
		this.skaarj_spin_finished = true;
	}
}

void skaarj_spin20(entity this) { skframe(this, 205, skaarj_fight, SK_SPINTIME); this.skaarj_spin_finished = 0; }
void skaarj_spin19(entity this) { skframe(this, 204, skaarj_spin20, SK_SPINTIME); }
void skaarj_spin18(entity this) { skframe(this, 203, skaarj_spin19, SK_SPINTIME); skaarj_spindamage(this); }
void skaarj_spin17(entity this) { skframe(this, 202, skaarj_spin18, SK_SPINTIME); skaarj_spindamage(this); }
void skaarj_spin16(entity this) { skframe(this, 201, skaarj_spin17, SK_SPINTIME); skaarj_spindamage(this); }
void skaarj_spin15(entity this) { skframe(this, 200, skaarj_spin16, SK_SPINTIME); skaarj_spindamage(this); }
void skaarj_spin14(entity this) { skframe(this, 199, skaarj_spin15, SK_SPINTIME); skaarj_spindamage(this); }
void skaarj_spin13(entity this) { skframe(this, 198, skaarj_spin14, SK_SPINTIME); skaarj_spindamage(this); }
void skaarj_spin12(entity this) { skframe(this, 197, skaarj_spin13, SK_SPINTIME); skaarj_spindamage(this); }
void skaarj_spin11(entity this) { skframe(this, 196, skaarj_spin12, SK_SPINTIME); skaarj_spindamage(this); }
void skaarj_spin10(entity this) { skframe(this, 195, skaarj_spin11, SK_SPINTIME); skaarj_spindamage(this); }
void skaarj_spin9(entity this) { skframe(this, 194, skaarj_spin10, SK_SPINTIME); }
void skaarj_spin8(entity this) { skframe(this, 193, skaarj_spin9, SK_SPINTIME); }
void skaarj_spin7(entity this) { skframe(this, 192, skaarj_spin8, SK_SPINTIME); }
void skaarj_spin6(entity this) { skframe(this, 191, skaarj_spin7, SK_SPINTIME); }
void skaarj_spin5(entity this) { skframe(this, 190, skaarj_spin6, SK_SPINTIME); }
void skaarj_spin4(entity this) { skframe(this, 189, skaarj_spin5, SK_SPINTIME); }
void skaarj_spin3(entity this) { skframe(this, 188, skaarj_spin4, SK_SPINTIME); }
void skaarj_spin2(entity this) { skframe(this, 187, skaarj_spin3, SK_SPINTIME); }
void skaarj_spin1(entity this) { skframe(this, 186, skaarj_spin2, SK_SPINTIME); this.skaarj_spin_finished = 0; }

void skaarj_claw1(entity this);
void skaarj_melee(entity this)
{
	if(random() < 0.3)
		skaarj_claw1(this);
	else
		skaarj_spin1(this);
}

void skaarj_clawdamage(entity this, float side)
{
	ai_face(this);

	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;
    	
	float ldmg = 10 + 10*random();
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_SKAARJ.m_id);	

	makevectors(this.angles);
	SpawnMeatSpray(this, this.origin + v_forward*16, side * v_right);
}

void skaarj_claw11(entity this) { skframe(this, 10, skaarj_fight, SK_ANIMTIME); sk_trymelee(this); }
void skaarj_claw10(entity this) { skframe(this, 9, skaarj_claw11, SK_ANIMTIME); }
void skaarj_claw9(entity this) { skframe(this, 8, skaarj_claw10, SK_ANIMTIME); }
void skaarj_claw8(entity this) { skframe(this, 7, skaarj_claw9, SK_ANIMTIME); skaarj_clawdamage(this, -200); }
void skaarj_claw7(entity this) { skframe(this, 6, skaarj_claw8, SK_ANIMTIME); }
void skaarj_claw6(entity this) { skframe(this, 5, skaarj_claw7, SK_ANIMTIME); }
void skaarj_claw5(entity this) { skframe(this, 4, skaarj_claw6, SK_ANIMTIME); }
void skaarj_claw4(entity this) { skframe(this, 3, skaarj_claw5, SK_ANIMTIME); }
void skaarj_claw3(entity this) { skframe(this, 2, skaarj_claw4, SK_ANIMTIME); skaarj_clawdamage(this, 200); }
void skaarj_claw2(entity this) { skframe(this, 1, skaarj_claw3, SK_ANIMTIME); }
void skaarj_claw1(entity this) { skframe(this, 0, skaarj_claw2, SK_ANIMTIME); }

void skaarj_leftdodge13(entity this) { skframe(this, 116, skaarj_run1, SK_ANIMTIME); sk_side(this, 25, -60); }
void skaarj_leftdodge12(entity this) { skframe(this, 115, skaarj_leftdodge13, SK_ANIMTIME); sk_side(this, 25, -60); }
void skaarj_leftdodge11(entity this) { skframe(this, 114, skaarj_leftdodge12, SK_ANIMTIME); sk_side(this, 25, -60); }
void skaarj_leftdodge10(entity this) { skframe(this, 113, skaarj_leftdodge11, SK_ANIMTIME); sk_side(this, 25, -60); }
void skaarj_leftdodge9(entity this) { skframe(this, 112, skaarj_leftdodge10, SK_ANIMTIME); sk_side(this, 25, -60); }
void skaarj_leftdodge8(entity this) { skframe(this, 111, skaarj_leftdodge9, SK_ANIMTIME); sk_side(this, 25, -60); }
void skaarj_leftdodge7(entity this) { skframe(this, 110, skaarj_leftdodge8, SK_ANIMTIME); sk_side(this, 25, -60); }
void skaarj_leftdodge6(entity this) { skframe(this, 109, skaarj_leftdodge7, SK_ANIMTIME); sk_side(this, 25, -60); }
void skaarj_leftdodge5(entity this) { skframe(this, 108, skaarj_leftdodge6, SK_ANIMTIME); sk_side(this, 25, -60); }
void skaarj_leftdodge4(entity this) { skframe(this, 107, skaarj_leftdodge5, SK_ANIMTIME); sk_side(this, 15, -60); }
void skaarj_leftdodge3(entity this) { skframe(this, 106, skaarj_leftdodge4, SK_ANIMTIME); sk_side(this, 15, -60); }
void skaarj_leftdodge2(entity this) { skframe(this, 105, skaarj_leftdodge3, SK_ANIMTIME); sk_side(this, 15, -60); }
void skaarj_leftdodge1(entity this)
{
	this.state = SK_ST_DODGE_LEFT;
	skframe(this, 104, skaarj_leftdodge2, SK_ANIMTIME);
	sk_side(this, 15, -60);
}

void skaarj_rightdodge13(entity this) { skframe(this, 241, skaarj_run1, SK_ANIMTIME); sk_side(this, 25, 60); }
void skaarj_rightdodge12(entity this) { skframe(this, 240, skaarj_rightdodge13, SK_ANIMTIME); sk_side(this, 25, 60); }
void skaarj_rightdodge11(entity this) { skframe(this, 239, skaarj_rightdodge12, SK_ANIMTIME); sk_side(this, 25, 60); }
void skaarj_rightdodge10(entity this) { skframe(this, 238, skaarj_rightdodge11, SK_ANIMTIME); sk_side(this, 25, 60); }
void skaarj_rightdodge9(entity this) { skframe(this, 237, skaarj_rightdodge10, SK_ANIMTIME); sk_side(this, 25, 60); }
void skaarj_rightdodge8(entity this) { skframe(this, 236, skaarj_rightdodge9, SK_ANIMTIME); sk_side(this, 25, 60); }
void skaarj_rightdodge7(entity this) { skframe(this, 235, skaarj_rightdodge8, SK_ANIMTIME); sk_side(this, 25, 60); }
void skaarj_rightdodge6(entity this) { skframe(this, 234, skaarj_rightdodge7, SK_ANIMTIME); sk_side(this, 25, 60); }
void skaarj_rightdodge5(entity this) { skframe(this, 233, skaarj_rightdodge6, SK_ANIMTIME); sk_side(this, 25, 60); }
void skaarj_rightdodge4(entity this) { skframe(this, 232, skaarj_rightdodge5, SK_ANIMTIME); sk_side(this, 15, 60); }
void skaarj_rightdodge3(entity this) { skframe(this, 231, skaarj_rightdodge4, SK_ANIMTIME); sk_side(this, 15, 60); }
void skaarj_rightdodge2(entity this) { skframe(this, 230, skaarj_rightdodge3, SK_ANIMTIME); sk_side(this, 15, 60); }
void skaarj_rightdodge1(entity this)
{
	this.state = SK_ST_DODGE_RIGHT;
	skframe(this, 229, skaarj_rightdodge2, SK_ANIMTIME);
	sk_side(this, 15, 60);
}

void skaarj_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	float r = random();

	if(r < 0.5)
		_sound(this, CH_VOICE, "skaarj/injur1sk.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "skaarj/injur2sk.wav", 1, ATTN_NORM);


	this.sk_painanim_finished = time + 0.25;
	this.pain_finished = time + 0.6;
	this.cnt++;

	if(this.state != SK_ST_DODGE_LEFT && this.state != SK_ST_DODGE_RIGHT)
	{
		if(r < 0.5)
			this.frame = 11;
		else
			this.frame = 82;
	}

	if(this.cnt > 3)
		setthink(this, skaarj_fight);
}

void SkaarjMissileTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner
	if(toucher.classname == this.classname)
		return;

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float damg = 10;
	
	if(toucher.health)
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);

	_sound(this, CH_WEAPON_SINGLE, "skaarj/skrjimp.wav", 1, ATTN_NORM);

	delete(this);
}

void SkaarjMissile(entity this, vector org, vector dir)
{
	entity newmis = spawn();
	newmis.owner = this;
	set_movetype(newmis, MOVETYPE_FLYMISSILE);
	newmis.solid = SOLID_BBOX;
	newmis.classname = "skaarjmissile";
	newmis.projectiledeathtype = DEATH_MONSTER_SKAARJ.m_id;
		
	// set missile speed	
	newmis.velocity = dir * 500;
	newmis.angles = vectoangles(newmis.velocity);
	
	settouch(newmis, SkaarjMissileTouch);
	
	// set missile duration
	newmis.nextthink = time + 5;
	setthink(newmis, SUB_Remove);

	_setmodel(newmis, "progs/big_bullet.mdl");
	setsize(newmis, '0 0 0', '0 0 0');		
	setorigin(newmis, org);
}

void skaarj_fire(entity this, vector org1, vector org2)
{
	_sound(this, CH_WEAPON_SINGLE, "skaarj/skrjshot.wav", 1, ATTN_NORM);	

	entity en = this.enemy;
	
	vector dir = en.origin + (en.velocity * vlen(this.origin - this.enemy.origin)/500);
	dir = normalize(dir - this.origin);
	
	fixedmakevectors(this.angles);
	SkaarjMissile(this, this.origin + v_right * (-org1.y) + v_up * org1.z, dir); // also had + v_forward * org1.x
	SkaarjMissile(this, this.origin + v_right * (-org2.y) + v_up * org2.z, dir); // also had + v_forward * org2.x
}

void skaarj_die_a(entity this)
{
	this.solid = SOLID_NOT;
	if(this.frame < 31 || this.frame > 43)
		this.frame = 31;
	else
		this.frame++;

	if(this.frame < 43)
	{
		setthink(this, skaarj_die_a);
		this.nextthink = time + 0.075;
	}
	else
		CorpseThink(this);
}

void skaarj_die_b(entity this)
{
	this.solid = SOLID_NOT;
	if(this.frame < 44 || this.frame > 54)
		this.frame = 44;
	else
		this.frame++;
	
	if(this.frame < 54)
	{
		setthink(this, skaarj_die_a);
		this.nextthink = time + 0.075;
	}
	else
		CorpseThink(this);
}

void skaarj_die(entity this, entity inflictor, entity attacker, int deathtype)
{
// check for gib
	if(this.health < -50)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		return;
	}

// regular death
	_sound(this, CH_VOICE, "skaarj/death1sk.wav", 1, ATTN_NORM);
	if(random() < 0.5)
		skaarj_die_a(this);
	else
		skaarj_die_b(this);
}

/*QUAKED monster_skaarj(1 0 0)(-16 -16 -38)(16 16 26)
*/
spawnfunc(monster_skaarj) { monster_start(this, true, MON_SKAARJ); }
#endif // SVQC

#ifdef SVQC
METHOD(Skaarj, mr_setup, bool(Skaarj this, entity actor))
{
    TC(Skaarj, this);

	precache_model("progs/big_bullet.mdl");
	precache_model("progs/gib1.mdl");
	precache_model("progs/gib2.mdl");
	precache_model("progs/gib3.mdl");

	precache_sound("skaarj/chalnge1s.wav");
	precache_sound("skaarj/chalnge3s.wav");
	precache_sound("skaarj/injur1sk.wav");
	precache_sound("skaarj/injur2sk.wav");
	precache_sound("skaarj/roam11s.wav");
	precache_sound("skaarj/death1sk.wav");
	precache_sound("skaarj/lunge1sk.wav");
	precache_sound("skaarj/skrjshot.wav");
	precache_sound("skaarj/skrjimp.wav");

	precache_sound("player/udeath.wav");		// gib death

	if(actor.spawnflags & 4)
		actor.th_stand = skaarj_sit;
	else
		actor.th_stand = skaarj_stand;

    actor.health = 500;
	actor.th_walk = skaarj_walk1;
	actor.th_run = skaarj_fight;
	actor.th_pain = skaarj_pain;
	actor.th_die = skaarj_die;

    return true;
}
#endif
