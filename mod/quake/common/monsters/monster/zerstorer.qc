#include "zerstorer.qh"

#ifdef SVQC
const int anim_zer_rize = 0; //'0 14 0'
const int anim_zer_hover = 15; //'15 36 0'
const int anim_zer_walk = 37; //'37 65 0'
const int anim_zer_run = 66; //'66 73 0'
const int anim_zer_atk = 74; //'74 91 0'
const int anim_zer_atka = 92; //'92 109 0'
const int anim_zer_atkb = 110; //'110 125 0'
const int anim_zer_pain = 126; //'126 133 0'
const int anim_zer_paina = 134; //'134 143 0'
const int anim_zer_die = 144; //'144 164 0'
const int anim_zer_dieb = 165; //'165 190 0'

/*
-------------------------------------------------------------------------------------------------------------------
 QUAKE 1 ZERSTORER  -  converted from zerstorerbase frame  -    MadFox 15 januari 2016             
------------------------------------------------------------------------------------------------------------------- 
*/

void zer_stand1(entity this);
void zer_stand22(entity this) { set_animofs(this, anim_zer_hover, 22, zer_stand1); ai_stand(this); }
void zer_stand21(entity this) { set_animofs(this, anim_zer_hover, 21, zer_stand22); ai_stand(this); }
void zer_stand20(entity this) { set_animofs(this, anim_zer_hover, 20, zer_stand21); ai_stand(this); }
void zer_stand19(entity this) { set_animofs(this, anim_zer_hover, 19, zer_stand20); ai_stand(this); }
void zer_stand18(entity this) { set_animofs(this, anim_zer_hover, 18, zer_stand19); ai_stand(this); }
void zer_stand17(entity this) { set_animofs(this, anim_zer_hover, 17, zer_stand18); ai_stand(this); }
void zer_stand16(entity this) { set_animofs(this, anim_zer_hover, 16, zer_stand17); ai_stand(this); }
void zer_stand15(entity this) { set_animofs(this, anim_zer_hover, 15, zer_stand16); ai_stand(this); }
void zer_stand14(entity this) { set_animofs(this, anim_zer_hover, 14, zer_stand15); ai_stand(this); }
void zer_stand13(entity this) { set_animofs(this, anim_zer_hover, 13, zer_stand14); ai_stand(this); }
void zer_stand12(entity this) { set_animofs(this, anim_zer_hover, 12, zer_stand13); ai_stand(this); }
void zer_stand11(entity this) { set_animofs(this, anim_zer_hover, 11, zer_stand12); ai_stand(this); }
void zer_stand10(entity this) { set_animofs(this, anim_zer_hover, 10, zer_stand11); ai_stand(this); }
void zer_stand9(entity this) { set_animofs(this, anim_zer_hover, 9, zer_stand10); ai_stand(this); }
void zer_stand8(entity this) { set_animofs(this, anim_zer_hover, 8, zer_stand9); ai_stand(this); }
void zer_stand7(entity this) { set_animofs(this, anim_zer_hover, 7, zer_stand8); ai_stand(this); }
void zer_stand6(entity this) { set_animofs(this, anim_zer_hover, 6, zer_stand7); ai_stand(this); }
void zer_stand5(entity this) { set_animofs(this, anim_zer_hover, 5, zer_stand6); ai_stand(this); }
void zer_stand4(entity this) { set_animofs(this, anim_zer_hover, 4, zer_stand5); ai_stand(this); }
void zer_stand3(entity this) { set_animofs(this, anim_zer_hover, 3, zer_stand4); ai_stand(this); }
void zer_stand2(entity this) { set_animofs(this, anim_zer_hover, 2, zer_stand3); ai_stand(this); }
void zer_stand1(entity this)
{
	set_animofs(this, anim_zer_hover, 1, zer_stand2); 
	if(random() < 0.2)
	{
		if(random() > 0.5)
			_sound(this, CH_VOICE, "zer/idle1.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "zer/idle2.wav", 1, ATTN_IDLE);
	}
	ai_stand(this);
}

void zer_walk1(entity this);
void zer_walk29(entity this) { set_animofs(this, anim_zer_walk, 29, zer_walk1); ai_walk(this, 3); }
void zer_walk28(entity this) { set_animofs(this, anim_zer_walk, 28, zer_walk29); ai_walk(this, 4); }
void zer_walk27(entity this) { set_animofs(this, anim_zer_walk, 27, zer_walk28); ai_walk(this, 3); }
void zer_walk26(entity this) { set_animofs(this, anim_zer_walk, 26, zer_walk27); ai_walk(this, 2); }
void zer_walk25(entity this) { set_animofs(this, anim_zer_walk, 25, zer_walk26); ai_walk(this, 3); }
void zer_walk24(entity this) { set_animofs(this, anim_zer_walk, 24, zer_walk25); ai_walk(this, 4); }
void zer_walk23(entity this) { set_animofs(this, anim_zer_walk, 23, zer_walk24); ai_walk(this, 5); }
void zer_walk22(entity this) { set_animofs(this, anim_zer_walk, 22, zer_walk23); ai_walk(this, 2); }
void zer_walk21(entity this) { set_animofs(this, anim_zer_walk, 21, zer_walk22); ai_walk(this, 2); }
void zer_walk20(entity this) { set_animofs(this, anim_zer_walk, 20, zer_walk21); ai_walk(this, 3); }
void zer_walk19(entity this) { set_animofs(this, anim_zer_walk, 19, zer_walk20); ai_walk(this, 3); }
void zer_walk18(entity this) { set_animofs(this, anim_zer_walk, 18, zer_walk19); ai_walk(this, 4); }
void zer_walk17(entity this) { set_animofs(this, anim_zer_walk, 17, zer_walk18); ai_walk(this, 3); }
void zer_walk16(entity this) { set_animofs(this, anim_zer_walk, 16, zer_walk17); ai_walk(this, 2); }
void zer_walk15(entity this) { set_animofs(this, anim_zer_walk, 15, zer_walk16); ai_walk(this, 3); }
void zer_walk14(entity this) { set_animofs(this, anim_zer_walk, 14, zer_walk15); ai_walk(this, 4); }
void zer_walk13(entity this) { set_animofs(this, anim_zer_walk, 13, zer_walk14); ai_walk(this, 5); }
void zer_walk12(entity this) { set_animofs(this, anim_zer_walk, 12, zer_walk13); ai_walk(this, 2); }
void zer_walk11(entity this) { set_animofs(this, anim_zer_walk, 11, zer_walk12); ai_walk(this, 2); }
void zer_walk10(entity this) { set_animofs(this, anim_zer_walk, 10, zer_walk11); ai_walk(this, 3); }
void zer_walk9(entity this) { set_animofs(this, anim_zer_walk, 9, zer_walk10); ai_walk(this, 3); }
void zer_walk8(entity this) { set_animofs(this, anim_zer_walk, 8, zer_walk9); ai_walk(this, 4); }
void zer_walk7(entity this) { set_animofs(this, anim_zer_walk, 7, zer_walk8); ai_walk(this, 3); }
void zer_walk6(entity this) { set_animofs(this, anim_zer_walk, 6, zer_walk7); ai_walk(this, 2); }
void zer_walk5(entity this) { set_animofs(this, anim_zer_walk, 5, zer_walk6); ai_walk(this, 3); }
void zer_walk4(entity this) { set_animofs(this, anim_zer_walk, 4, zer_walk5); ai_walk(this, 4); }
void zer_walk3(entity this) { set_animofs(this, anim_zer_walk, 3, zer_walk4); ai_walk(this, 5); }
void zer_walk2(entity this) { set_animofs(this, anim_zer_walk, 2, zer_walk3); ai_walk(this, 4); }
void zer_walk1(entity this)
{
	set_animofs(this, anim_zer_walk, 1, zer_walk2); 
	if(random() < 0.2)
	{
		if(random() > 0.5)
			_sound(this, CH_VOICE, "zer/idle1.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "zer/idle2.wav", 1, ATTN_IDLE);
	}
	ai_walk(this, 3);
}

void zer_run1(entity this);
void zer_run8(entity this) { set_animofs(this, anim_zer_run, 8, zer_run1); ai_run(this, 14); }
void zer_run7(entity this) { set_animofs(this, anim_zer_run, 7, zer_run8); ai_run(this, 20); }
void zer_run6(entity this) { set_animofs(this, anim_zer_run, 6, zer_run7); ai_run(this, 14); }
void zer_run5(entity this) { set_animofs(this, anim_zer_run, 5, zer_run6); ai_run(this, 9); }
void zer_run4(entity this) { set_animofs(this, anim_zer_run, 4, zer_run5); ai_run(this, 7); }
void zer_run3(entity this) { set_animofs(this, anim_zer_run, 3, zer_run4); ai_run(this, 9); }
void zer_run2(entity this) { set_animofs(this, anim_zer_run, 2, zer_run3); ai_run(this, 13); }
void zer_run1(entity this)
{
	set_animofs(this, anim_zer_run, 1, zer_run2); 
	if(random() < 0.2)
	{
		if(random() > 0.5)
			_sound(this, CH_VOICE, "zer/idle1.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "zer/fly.wav", 1, ATTN_IDLE);
	}
	ai_run(this, 20);
}

void ZerMissile(entity this);
void zer_atk18(entity this) { set_animofs(this, anim_zer_atk, 18, zer_run1); ai_face(this); }
void zer_atk17(entity this) { set_animofs(this, anim_zer_atk, 17, zer_atk18); ai_face(this); }
void zer_atk16(entity this) { set_animofs(this, anim_zer_atk, 16, zer_atk17); ai_charge(this, 10); }
void zer_atk15(entity this) { set_animofs(this, anim_zer_atk, 15, zer_atk16); ai_face(this); }
void zer_atk14(entity this) { set_animofs(this, anim_zer_atk, 14, zer_atk15); ai_face(this); }
void zer_atk13(entity this) { set_animofs(this, anim_zer_atk, 13, zer_atk14); ai_charge(this, 10); }
void zer_atk12(entity this) { set_animofs(this, anim_zer_atk, 12, zer_atk13); ai_face(this); /*ZerMissile(this);*/ }
void zer_atk11(entity this) { set_animofs(this, anim_zer_atk, 11, zer_atk12); ai_face(this); }
void zer_atk10(entity this) { set_animofs(this, anim_zer_atk, 10, zer_atk11); ai_charge(this, 10); }
void zer_atk9(entity this) { set_animofs(this, anim_zer_atk, 9, zer_atk10); ai_face(this); }
void zer_atk8(entity this) { set_animofs(this, anim_zer_atk, 8, zer_atk9); ai_face(this); }
void zer_atk7(entity this) { set_animofs(this, anim_zer_atk, 7, zer_atk8); ai_face(this); }
void zer_atk6(entity this) { set_animofs(this, anim_zer_atk, 6, zer_atk7); ai_charge(this, 10); }
void zer_atk5(entity this) { set_animofs(this, anim_zer_atk, 5, zer_atk6); ai_face(this); ZerMissile(this); }
void zer_atk4(entity this) { set_animofs(this, anim_zer_atk, 4, zer_atk5); ai_face(this); }
void zer_atk3(entity this) { set_animofs(this, anim_zer_atk, 3, zer_atk4); ai_charge(this, 10); }
void zer_atk2(entity this) { set_animofs(this, anim_zer_atk, 2, zer_atk3); ai_face(this); }
void zer_atk1(entity this) { set_animofs(this, anim_zer_atk, 1, zer_atk2); ai_face(this); }

void ZerVortex_Spam(entity this);
void zer_atkb16(entity this) { set_animofs(this, anim_zer_atkb, 16, zer_run1); ai_charge(this, 10); ZerVortex_Spam(this); }
void zer_atkb15(entity this) { set_animofs(this, anim_zer_atkb, 15, zer_atkb16); ai_face(this); }
void zer_atkb14(entity this) { set_animofs(this, anim_zer_atkb, 14, zer_atkb15); ai_face(this); }
void zer_atkb13(entity this) { set_animofs(this, anim_zer_atkb, 13, zer_atkb14); ai_charge(this, 10); }
void zer_atkb12(entity this) { set_animofs(this, anim_zer_atkb, 12, zer_atkb13); ai_face(this); }
void zer_atkb11(entity this) { set_animofs(this, anim_zer_atkb, 11, zer_atkb12); ai_face(this); }
void zer_atkb10(entity this) { set_animofs(this, anim_zer_atkb, 10, zer_atkb11); ai_charge(this, 10); }
void zer_atkb9(entity this) { set_animofs(this, anim_zer_atkb, 9, zer_atkb10); ai_face(this); }
void zer_atkb8(entity this) { set_animofs(this, anim_zer_atkb, 8, zer_atkb9); ai_face(this); }
void zer_atkb7(entity this) { set_animofs(this, anim_zer_atkb, 7, zer_atkb8); ai_face(this); }
void zer_atkb6(entity this) { set_animofs(this, anim_zer_atkb, 6, zer_atkb7); ai_charge(this, 10); }
void zer_atkb5(entity this) { set_animofs(this, anim_zer_atkb, 5, zer_atkb6); ai_face(this); }
void zer_atkb4(entity this) { set_animofs(this, anim_zer_atkb, 4, zer_atkb5); ai_face(this); }
void zer_atkb3(entity this) { set_animofs(this, anim_zer_atkb, 3, zer_atkb4); ai_charge(this, 10); _sound(this, CH_VOICE, "zer/charge.wav", 1, ATTN_NORM); }
void zer_atkb2(entity this) { set_animofs(this, anim_zer_atkb, 2, zer_atkb3); ai_face(this); }
void zer_atkb1(entity this) { set_animofs(this, anim_zer_atkb, 1, zer_atkb2); ai_face(this); }

void ZerBullet(entity this);
void zer_atkc18(entity this) { set_animofs(this, anim_zer_atk, 18, zer_run1); ai_face(this); }
void zer_atkc17(entity this) { set_animofs(this, anim_zer_atk, 17, zer_atkc18); ai_face(this); ZerBullet(this); }
void zer_atkc16(entity this) { set_animofs(this, anim_zer_atk, 16, zer_atkc17); ai_charge(this, 10); }
void zer_atkc15(entity this) { set_animofs(this, anim_zer_atk, 15, zer_atkc16); ai_face(this); }
void zer_atkc14(entity this) { set_animofs(this, anim_zer_atk, 14, zer_atkc15); ai_face(this); }
void zer_atkc13(entity this) { set_animofs(this, anim_zer_atk, 13, zer_atkc14); ai_charge(this, 10); }
void zer_atkc12(entity this) { set_animofs(this, anim_zer_atk, 12, zer_atkc13); ai_face(this); ZerBullet(this); }
void zer_atkc11(entity this) { set_animofs(this, anim_zer_atk, 11, zer_atkc12); ai_face(this); }
void zer_atkc10(entity this) { set_animofs(this, anim_zer_atk, 10, zer_atkc11); ai_charge(this, 10); }
void zer_atkc9(entity this) { set_animofs(this, anim_zer_atk, 9, zer_atkc10); ai_face(this); }
void zer_atkc8(entity this) { set_animofs(this, anim_zer_atk, 8, zer_atkc9); ai_face(this); ZerBullet(this); }
void zer_atkc7(entity this) { set_animofs(this, anim_zer_atk, 7, zer_atkc8); ai_face(this); }
void zer_atkc6(entity this) { set_animofs(this, anim_zer_atk, 6, zer_atkc7); ai_charge(this, 10); }
void zer_atkc5(entity this) { set_animofs(this, anim_zer_atk, 5, zer_atkc6); ai_face(this); ZerBullet(this); }
void zer_atkc4(entity this) { set_animofs(this, anim_zer_atk, 4, zer_atkc5); ai_face(this); }
void zer_atkc3(entity this) { set_animofs(this, anim_zer_atk, 3, zer_atkc4); ai_charge(this, 10); }
void zer_atkc2(entity this) { set_animofs(this, anim_zer_atk, 2, zer_atkc3); ai_face(this); }
void zer_atkc1(entity this) { set_animofs(this, anim_zer_atk, 1, zer_atkc2); ai_face(this); }

void zer_pain8(entity this) { set_animofs(this, anim_zer_pain, 8, zer_run1); ai_pain(this, 1); }
void zer_pain7(entity this) { set_animofs(this, anim_zer_pain, 7, zer_pain8); ai_pain(this, 1); }
void zer_pain6(entity this) { set_animofs(this, anim_zer_pain, 6, zer_pain7); ai_painforward(this, 5); }
void zer_pain5(entity this) { set_animofs(this, anim_zer_pain, 5, zer_pain6); ai_pain(this, 1); }
void zer_pain4(entity this) { set_animofs(this, anim_zer_pain, 4, zer_pain5); ai_pain(this, 1); }
void zer_pain3(entity this) { set_animofs(this, anim_zer_pain, 3, zer_pain4); ai_pain(this, 1); }
void zer_pain2(entity this) { set_animofs(this, anim_zer_pain, 2, zer_pain3); ai_painforward(this, 5); }
void zer_pain1(entity this) { set_animofs(this, anim_zer_pain, 1, zer_pain2); ai_pain(this, 1); }

void zer_paina10(entity this) { set_animofs(this, anim_zer_paina, 10, zer_run1); ai_pain(this, 1); }
void zer_paina9(entity this) { set_animofs(this, anim_zer_paina, 9, zer_paina10); ai_pain(this, 1); }
void zer_paina8(entity this) { set_animofs(this, anim_zer_paina, 8, zer_paina9); ai_pain(this, 1); }
void zer_paina7(entity this) { set_animofs(this, anim_zer_paina, 7, zer_paina8); ai_pain(this, 1); }
void zer_paina6(entity this) { set_animofs(this, anim_zer_paina, 6, zer_paina7); ai_painforward(this, 5); }
void zer_paina5(entity this) { set_animofs(this, anim_zer_paina, 5, zer_paina6); ai_pain(this, 1); }
void zer_paina4(entity this) { set_animofs(this, anim_zer_paina, 4, zer_paina5); ai_pain(this, 1); }
void zer_paina3(entity this) { set_animofs(this, anim_zer_paina, 3, zer_paina4); ai_pain(this, 1); }
void zer_paina2(entity this) { set_animofs(this, anim_zer_paina, 2, zer_paina3); ai_painforward(this, 5); }
void zer_paina1(entity this) { set_animofs(this, anim_zer_paina, 1, zer_paina2); ai_pain(this, 1); }

void zer_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(deathtype != DEATH_VOID.m_id)
		return;
	if(this.pain_finished > time)
		return;

	_sound(this, CH_VOICE, "zer/pain1.wav", 1, ATTN_NORM);

	if(random() < 0.5)
		zer_pain1(this);
	else
		zer_paina1(this);

	this.pain_finished = time + 1;
}

void zer_gib(entity this, entity inflictor)
{
	// throw tons of meat chunks
	_sound(this, CHAN_BODY, "boss2/pop2.wav", 1, ATTN_NORM);
	
	vector oldo = this.origin;

	float posz = 32; // was 0
	while(posz <= 80)
	{
		float posx = 0; // was -62
		while(posx <= 45)
		{
			float posy = 0; // was -62
			while(posy <= 45)
			{
				this.origin_x = oldo.x + (posx * this.scale);
				this.origin_y = oldo.y + (posy * this.scale);
				this.origin_z = oldo.z + (posz * this.scale);

				float r = random();
				if(r < 0.3)				
					ThrowGib(this, inflictor, "progs/gib1.mdl", -100);
				else if(r < 0.6)
					ThrowGib(this, inflictor, "progs/gib2.mdl", -100);
				else
					ThrowGib(this, inflictor, "progs/gib3.mdl", -100);
				posy += 15;
			}
			posx += 15;
		}
		posz += 20;
	}
	delete(this);
}

void zer_gibthink(entity this)
{
	zer_gib(this, this);
}

void zer_die21(entity this) { set_animofs(this, anim_zer_die, 21, zer_gibthink); }
void zer_die20(entity this) { set_animofs(this, anim_zer_die, 20, zer_die21); }
void zer_die19(entity this) { set_animofs(this, anim_zer_die, 19, zer_die20); }
void zer_die18(entity this) { set_animofs(this, anim_zer_die, 18, zer_die19); }
void zer_die17(entity this) { set_animofs(this, anim_zer_die, 17, zer_die18); }
void zer_die16(entity this) { set_animofs(this, anim_zer_die, 16, zer_die17); }
void zer_die15(entity this) { set_animofs(this, anim_zer_die, 15, zer_die16); }
void zer_die14(entity this) { set_animofs(this, anim_zer_die, 14, zer_die15); }
void zer_die13(entity this) { set_animofs(this, anim_zer_die, 13, zer_die14); }
void zer_die12(entity this) { set_animofs(this, anim_zer_die, 12, zer_die13); }
void zer_die11(entity this) { set_animofs(this, anim_zer_die, 11, zer_die12); }
void zer_die10(entity this) { set_animofs(this, anim_zer_die, 10, zer_die11); }
void zer_die9(entity this) { set_animofs(this, anim_zer_die, 9, zer_die10); }
void zer_die8(entity this) { set_animofs(this, anim_zer_die, 8, zer_die9); }
void zer_die7(entity this) { set_animofs(this, anim_zer_die, 7, zer_die8); }
void zer_die6(entity this) { set_animofs(this, anim_zer_die, 6, zer_die7); }
void zer_die5(entity this) { set_animofs(this, anim_zer_die, 5, zer_die6); }
void zer_die4(entity this) { set_animofs(this, anim_zer_die, 4, zer_die5); }
void zer_die3(entity this) { set_animofs(this, anim_zer_die, 3, zer_die4); }
void zer_die2(entity this) { set_animofs(this, anim_zer_die, 2, zer_die3); }
void zer_die1(entity this) { set_animofs(this, anim_zer_die, 1, zer_die2); this.solid = SOLID_NOT; }

void zer_dieb26(entity this) { set_animofs(this, anim_zer_dieb, 26, zer_gibthink); }
void zer_dieb25(entity this) { set_animofs(this, anim_zer_dieb, 25, zer_dieb26); }
void zer_dieb24(entity this) { set_animofs(this, anim_zer_dieb, 24, zer_dieb25); }
void zer_dieb23(entity this) { set_animofs(this, anim_zer_dieb, 23, zer_dieb24); }
void zer_dieb22(entity this) { set_animofs(this, anim_zer_dieb, 22, zer_dieb23); }
void zer_dieb21(entity this) { set_animofs(this, anim_zer_dieb, 21, zer_dieb22); }
void zer_dieb20(entity this) { set_animofs(this, anim_zer_dieb, 20, zer_dieb21); }
void zer_dieb19(entity this) { set_animofs(this, anim_zer_dieb, 19, zer_dieb20); }
void zer_dieb18(entity this) { set_animofs(this, anim_zer_dieb, 18, zer_dieb19); }
void zer_dieb17(entity this) { set_animofs(this, anim_zer_dieb, 17, zer_dieb18); }
void zer_dieb16(entity this) { set_animofs(this, anim_zer_dieb, 16, zer_dieb17); }
void zer_dieb15(entity this) { set_animofs(this, anim_zer_dieb, 15, zer_dieb16); }
void zer_dieb14(entity this) { set_animofs(this, anim_zer_dieb, 14, zer_dieb15); }
void zer_dieb13(entity this) { set_animofs(this, anim_zer_dieb, 13, zer_dieb14); }
void zer_dieb12(entity this) { set_animofs(this, anim_zer_dieb, 12, zer_dieb13); }
void zer_dieb11(entity this) { set_animofs(this, anim_zer_dieb, 11, zer_dieb12); }
void zer_dieb10(entity this) { set_animofs(this, anim_zer_dieb, 10, zer_dieb11); }
void zer_dieb9(entity this) { set_animofs(this, anim_zer_dieb, 9, zer_dieb10); }
void zer_dieb8(entity this) { set_animofs(this, anim_zer_dieb, 8, zer_dieb9); }
void zer_dieb7(entity this) { set_animofs(this, anim_zer_dieb, 7, zer_dieb8); }
void zer_dieb6(entity this) { set_animofs(this, anim_zer_dieb, 6, zer_dieb7); }
void zer_dieb5(entity this) { set_animofs(this, anim_zer_dieb, 5, zer_dieb6); }
void zer_dieb4(entity this) { set_animofs(this, anim_zer_dieb, 4, zer_dieb5); }
void zer_dieb3(entity this) { set_animofs(this, anim_zer_dieb, 3, zer_dieb4); }
void zer_dieb2(entity this) { set_animofs(this, anim_zer_dieb, 2, zer_dieb3); }
void zer_dieb1(entity this) { set_animofs(this, anim_zer_dieb, 1, zer_dieb2); this.solid = SOLID_NOT; }

void zer_die(entity this, entity inflictor, entity attacker, int deathtype)
{
// check for gib
	if(this.health < -150 && deathtype != DEATH_VOID.m_id)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, inflictor, "progs/h_zer.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		return;
	}

// regular death
	if(random() > 0.5)
	{
		_sound(this, CH_VOICE, "zer/death1.wav", 1, ATTN_NORM);
		zer_die1(this);
	}
	else
	{
		_sound(this, CH_VOICE, "zer/death2.wav", 1, ATTN_NORM);
		zer_dieb1(this);
	}
}

const int ZER_ATTACK_MISSILE = 0;
const int ZER_ATTACK_VORTEX = 1;
const int ZER_ATTACK_BULLET = 2;
const int ZER_ATTACK_NONE = 3;

void Zer_Attack(entity this)
{
	int boss_phase = 0;
	if(this.health <= (this.max_health * 0.5))
		boss_phase = 1;

	RandomSelection_Init();

	RandomSelection_AddFloat(ZER_ATTACK_MISSILE, 1, 1);

	if(boss_phase == 0)
	{
		RandomSelection_AddFloat(ZER_ATTACK_NONE, 1, 1);
		RandomSelection_AddFloat(ZER_ATTACK_BULLET, 1, 1);
	}

	// void attack once half health
	if(boss_phase >= 1)
		RandomSelection_AddFloat(ZER_ATTACK_VORTEX, 0.5, 1);

	switch(RandomSelection_chosen_float)
	{
		case ZER_ATTACK_MISSILE: zer_atk1(this); break;
		case ZER_ATTACK_VORTEX: zer_atkb1(this); break;
		case ZER_ATTACK_BULLET: zer_atkc1(this); break;
		case ZER_ATTACK_NONE: break;
	}
}

void vortex_fade(entity this)
{
	particle(this.origin, '0 0 1' * (20 + random() * 20), 150, 75);
	//stopsound(this, CH_TRIGGER_SINGLE);
	delete(this);
}

void vortex_think(entity this)
{
	this.nextthink = time + 0.1;
	if(time >= this.cnt || !this.owner || this.owner.health < 1)
	{
		vortex_fade(this);
		return;
	}

	this.frame += 1;
	if(this.frame > 23)
		this.frame = 0;

	if(time < this.attack_finished)
		return;

	this.attack_finished = time + 0.25;

	FOREACH_ENTITY_RADIUS(this.origin, this.distance, it.classname != this.classname && it != this.owner && it.owner != this.owner && it.takedamage && it.health > 0,
	{
		if(!Damage_ValidTarget(it, this.owner))
			continue;

		T_Damage(it, this, this.owner, 20, DEATH_MONSTER_ZERSTORER.m_id);
	});
}

void ZerVortex(entity this, entity targ)
{
	if(!targ || targ.health < 1)
		return;

	entity vortex = new(vortex);
	vector targ_org = targ.origin + '0 0 8';

	vortex.solid = SOLID_NOT;
	vortex.owner = this;
	vortex.realowner = this;
	vortex.takedamage = DAMAGE_NO;
	vortex.distance = 100;
	_setmodel(vortex, "progs/vortex.mdl");
	setsize(vortex, '-32 -32 -24', '32 32 32');
	vortex.attack_finished = time + 1; // give them a fighting chance!
	setorigin(vortex, targ_org);
	setthink(vortex, vortex_think);
	vortex.nextthink = time + 0.1;
	vortex.cnt = time + 10;
	vortex.frame = 0;

	vector extrasize = '1 1 1' * 400;
	if(MoveToRandomLocationWithinBounds(vortex, vortex.absmin - extrasize, vortex.absmax + extrasize,
											DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, 
											Q3SURFACEFLAG_SKY, 20, 64, 256, true))
	{
		// no special treatment needed, we're just using it as a position!
		vortex.mangle = '0 1 0' * vortex.angles_y;
		vortex.angles = '0 0 0';
		DropToFloor_QC_DelayedInit(vortex);
		te_teleport(vortex.origin);
	}

	//_sound(vortex, CH_TRIGGER_SINGLE, "zer/vortex.wav", 1, 0.25);
}

void ZerVortex_Spam(entity this)
{
	if(!this.enemy || this.enemy.health < 1)
		return;

	int shots = floor(random() * 4) + 1;
	for(int j = 0; j < shots; ++j)
	{
		// TODO: multi-target?
		ZerVortex(this, this.enemy);
	}
}

/*
================
ZerBullet
Quick shots in rapid succession
================
*/


//============================================================================
// * The trick to drole rockets is that they start really slow
// * Over time (4 frames) the rocket speeds up (linked to animation)
// * requires special projectile and new th_updmissile function
// * Has a different explosion sound (does not play rocket default)
//
//============================================================================

void zer_bullet4(entity this)
{
	set_anim(this, 3, SUB_Remove);
	this.nextthink = time + 5;
	if(autocvar_skill == 0)
		this.velocity = this.velocity * 3.5;
	else
		this.velocity = this.velocity * 4.5;
}
void zer_bullet3(entity this) { set_anim(this, 3, zer_bullet4); this.velocity = this.velocity * 1.5; }
void zer_bullet2(entity this) { set_anim(this, 2, zer_bullet3); this.velocity = this.velocity * 1.5; }
void zer_bullet1(entity this) { set_anim(this, 1, zer_bullet2); this.nextthink = time + 0.2; }

void ZerBullet(entity this)
{
	if(!this.enemy) return;
	if(this.health < 1) return;

	makevectors(this.angles);
	vector org;
	if(random() < 0.5)
		org = this.origin + attack_vector('0 24 60');
	else
		org = this.origin + attack_vector('0 -24 64');
	vector dir = normalize((this.enemy.origin + '0 0 -8') - org);
	vector avel = randomvec() * 100;

	entity newmis = launch_spike(this, org, dir);
	newmis.poisonous = this.poisonous;
	_setmodel(newmis, "progs/proj_drole.mdl");
	newmis.avelocity = avel;
	newmis.dmg = 15;
	setsize(newmis, '0 0 0', '0 0 0');
	newmis.noise = "drole/r_explode.wav";
	newmis.nextthink = time + 0.025;
	setthink(newmis, zer_bullet1);
	newmis.velocity = dir * 80;
	settouch(newmis, T_MissileTouch); // rocket explosion
	newmis.projectiledeathtype = DEATH_MONSTER_ZERSTORER.m_id;
}

/*
================
ZerMissile
Homing missile
================
*/

void ZerHome(entity this);
void ZerMissileTouch(entity this, entity toucher);
void ZerMissile(entity this)
{
	vector dir = normalize((this.enemy.origin + '0 0 10') - this.origin);

	this.effects |= EF_MUZZLEFLASH;
	_sound(this, CH_WEAPON_SINGLE, "zer/attack.wav", 1, ATTN_NORM);

	entity missile = spawn();
	missile.flags = FL_PROJECTILE;
	missile.classname = "vore_ball";
	missile.owner = this;
	missile.projectiledeathtype = DEATH_MONSTER_ZERSTORER.m_id;
	missile.clipgroup = this.clipgroup;

	missile.solid = SOLID_BBOX;
	missile.movetype = MOVETYPE_FLYMISSILE;
	_setmodel(missile, "progs/q1_zers_star.mdl");

	setsize(missile, '0 0 0', '0 0 0');		

	missile.origin = this.origin + '0 0 48';
//	missile.origin = this.origin  - normalize(this.velocity);
	missile.velocity = dir * 400;
	missile.angles = vectoangles(missile.velocity);
	missile.avelocity = '0 0 0';
	missile.nextthink = time + 0.1;
	missile.count = time + 8;
	setthink(missile, ZerHome);
	missile.enemy = this.enemy;
	settouch(missile, ZerMissileTouch);

	missile.frame = 7;

	IL_PUSH(g_projectiles, missile);
}

void ZerMissileExplode(entity this)
{
	T_RadiusDamage(this, this.owner, 40, this.projectiledeathtype, NULL);
	_sound(this, CH_WEAPON_SINGLE, "zer/bigboom.wav", 1, ATTN_NORM);

	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);

	this.velocity = '0 0 0';
	settouch(this, func_null);
	setmodel(this, MDL_EXPLOSION);
	this.solid = SOLID_NOT;
	setsize(this, '0 0 0', '0 0 0');
	s_explode1(this);
}

void ZerHome(entity this)
{
	vector vtemp = this.enemy.origin;
	if(this.enemy.health < 1 || (this.enemy.flags & FL_NOTARGET) || time > this.count || this.owner.health < 1)
	{
		ZerMissileExplode(this);
		return;
	}
	this.frame += 1;
	if(this.frame > 11)
		this.frame = 7;
	vector dir = normalize(vtemp - this.origin);
	this.angles = vectoangles(dir);
	this.velocity = dir * 100;
	this.nextthink = time + 0.1;
	setthink(this, ZerHome);	
}

void ZerMissileTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if((toucher.monsterdef && (toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD)))
 		T_Damage(toucher, this, this, 110, this.projectiledeathtype);	
	
	ZerMissileExplode(this);
}

/*QUAKED monster_zer(1 0 0)(-16 -16 -24)(16 16 40) Ambush
*/
spawnfunc(monster_zer) { monster_start(this, true, MON_ZERSTORER); }
#endif // SVQC

#ifdef SVQC
METHOD(Zerstorer, mr_setup, bool(Zerstorer this, entity actor))
{
    TC(Zerstorer, this);

	precache_model("progs/q1_zers_star.mdl");
	precache_model("progs/vortex.mdl");
	precache_model("progs/proj_drole.mdl");

	precache_sound("zer/death1.wav");
	precache_sound("zer/death2.wav");
	precache_sound("zer/idle1.wav");
	precache_sound("zer/idle2.wav");
	precache_sound("zer/pain1.wav");
	precache_sound("zer/attack.wav");
	precache_sound("zer/bigboom.wav");
	precache_sound("zer/fly.wav");
	precache_sound("zer/charge.wav");
	precache_sound("zer/vortex.wav");
	precache_sound("drole/r_explode.wav");

	precache_sound("player/udeath.wav");		// gib death
	precache_sound("boss2/pop2.wav");

    actor.health = 1500;
    actor.th_stand = zer_stand1;
	actor.th_walk = zer_walk1;
	actor.th_run = zer_run1;
	actor.th_missile = Zer_Attack;
	actor.th_pain = zer_pain;
	actor.th_die = zer_die;

	actor.resist_shells = actor.resist_cells = 0.5;
	actor.resist_nails = actor.resist_rockets = 0.75;

    return true;
}
METHOD(Zerstorer, mr_sight, bool(Zerstorer this, entity actor))
{
    TC(Zerstorer, this);

	sound(actor, CH_VOICE, SND_MON_ZERSTORER_SIGHT_RANDOM(), 1, ATTN_NORM);

    return true;
}
#endif
