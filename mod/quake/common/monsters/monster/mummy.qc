#include "mummy.qh"

#include "zombie.qh"

#ifdef SVQC
const int anim_mummy_stand = 0; //'0 14 0';
const int anim_mummy_walk = 15; //'15 33 0';
const int anim_mummy_run = 34; //'34 51 0';
const int anim_mummy_atta = 52; //'52 64 0';
const int anim_mummy_attb = 65; //'65 78 0';
const int anim_mummy_attc = 79; //'79 90 0';
const int anim_mummy_paina = 91; //'91 102 0';
const int anim_mummy_painb = 103; //'103 130 0';
const int anim_mummy_painc = 131; //'131 148 0';
const int anim_mummy_paind = 149; //'149 161 0';
const int anim_mummy_paine = 162; //'162 191 0';

.int inpain;

void mummy_stand1(entity this);
void mummy_stand15(entity this) { set_animofs(this, anim_mummy_stand, 15, mummy_stand1); ai_stand(this); }
void mummy_stand14(entity this) { set_animofs(this, anim_mummy_stand, 14, mummy_stand15); ai_stand(this); }
void mummy_stand13(entity this) { set_animofs(this, anim_mummy_stand, 13, mummy_stand14); ai_stand(this); }
void mummy_stand12(entity this) { set_animofs(this, anim_mummy_stand, 12, mummy_stand13); ai_stand(this); }
void mummy_stand11(entity this) { set_animofs(this, anim_mummy_stand, 11, mummy_stand12); ai_stand(this); }
void mummy_stand10(entity this) { set_animofs(this, anim_mummy_stand, 10, mummy_stand11); ai_stand(this); }
void mummy_stand9(entity this) { set_animofs(this, anim_mummy_stand, 9, mummy_stand10); ai_stand(this); }
void mummy_stand8(entity this) { set_animofs(this, anim_mummy_stand, 8, mummy_stand9); ai_stand(this); }
void mummy_stand7(entity this) { set_animofs(this, anim_mummy_stand, 7, mummy_stand8); ai_stand(this); }
void mummy_stand6(entity this) { set_animofs(this, anim_mummy_stand, 6, mummy_stand7); ai_stand(this); }
void mummy_stand5(entity this) { set_animofs(this, anim_mummy_stand, 5, mummy_stand6); ai_stand(this); }
void mummy_stand4(entity this) { set_animofs(this, anim_mummy_stand, 4, mummy_stand5); ai_stand(this); }
void mummy_stand3(entity this) { set_animofs(this, anim_mummy_stand, 3, mummy_stand4); ai_stand(this); }
void mummy_stand2(entity this) { set_animofs(this, anim_mummy_stand, 2, mummy_stand3); ai_stand(this); }
void mummy_stand1(entity this) { set_animofs(this, anim_mummy_stand, 1, mummy_stand2); ai_stand(this); }

void mummy_walk1(entity this);
void mummy_walk19(entity this)
{
	set_animofs(this, anim_mummy_walk, 19, mummy_walk1);

	ai_walk(this, 0);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "zombie/z_idle.wav", 1, ATTN_IDLE);
}
void mummy_walk18(entity this) { set_animofs(this, anim_mummy_walk, 18, mummy_walk19); ai_walk(this, 0); }
void mummy_walk17(entity this) { set_animofs(this, anim_mummy_walk, 17, mummy_walk18); ai_walk(this, 0); }
void mummy_walk16(entity this) { set_animofs(this, anim_mummy_walk, 16, mummy_walk17); ai_walk(this, 0); }
void mummy_walk15(entity this) { set_animofs(this, anim_mummy_walk, 15, mummy_walk16); ai_walk(this, 0); }
void mummy_walk14(entity this) { set_animofs(this, anim_mummy_walk, 14, mummy_walk15); ai_walk(this, 0); }
void mummy_walk13(entity this) { set_animofs(this, anim_mummy_walk, 13, mummy_walk14); ai_walk(this, 2); }
void mummy_walk12(entity this) { set_animofs(this, anim_mummy_walk, 12, mummy_walk13); ai_walk(this, 4); }
void mummy_walk11(entity this) { set_animofs(this, anim_mummy_walk, 11, mummy_walk12); ai_walk(this, 3); }
void mummy_walk10(entity this) { set_animofs(this, anim_mummy_walk, 10, mummy_walk11); ai_walk(this, 0); }
void mummy_walk9(entity this) { set_animofs(this, anim_mummy_walk, 9, mummy_walk10); ai_walk(this, 0); }
void mummy_walk8(entity this) { set_animofs(this, anim_mummy_walk, 8, mummy_walk9); ai_walk(this, 0); }
void mummy_walk7(entity this) { set_animofs(this, anim_mummy_walk, 7, mummy_walk8); ai_walk(this, 0); }
void mummy_walk6(entity this) { set_animofs(this, anim_mummy_walk, 6, mummy_walk7); ai_walk(this, 0); }
void mummy_walk5(entity this) { set_animofs(this, anim_mummy_walk, 5, mummy_walk6); ai_walk(this, 2); }
void mummy_walk4(entity this) { set_animofs(this, anim_mummy_walk, 4, mummy_walk5); ai_walk(this, 4); }
void mummy_walk3(entity this) { set_animofs(this, anim_mummy_walk, 3, mummy_walk4); ai_walk(this, 5); }
void mummy_walk2(entity this) { set_animofs(this, anim_mummy_walk, 2, mummy_walk3); ai_walk(this, 3); }
void mummy_walk1(entity this) { set_animofs(this, anim_mummy_walk, 1, mummy_walk2); ai_walk(this, 0); }

void mummy_run1(entity this);
void mummy_run18(entity this)
{
	set_animofs(this, anim_mummy_run, 18, mummy_run1);

	ai_run(this, 16);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "zombie/z_idle.wav", 1, ATTN_IDLE);
	if(random() > 0.8)
		_sound(this, CH_VOICE, "zombie/z_idle1.wav", 1, ATTN_IDLE);
}
void mummy_run17(entity this) { set_animofs(this, anim_mummy_run, 17, mummy_run18); ai_run(this, 6); }
void mummy_run16(entity this) { set_animofs(this, anim_mummy_run, 16, mummy_run17); ai_run(this, 14); }
void mummy_run15(entity this) { set_animofs(this, anim_mummy_run, 15, mummy_run16); ai_run(this, 12); }
void mummy_run14(entity this) { set_animofs(this, anim_mummy_run, 14, mummy_run15); ai_run(this, 8); }
void mummy_run13(entity this) { set_animofs(this, anim_mummy_run, 13, mummy_run14); ai_run(this, 4); }
void mummy_run12(entity this) { set_animofs(this, anim_mummy_run, 12, mummy_run13); ai_run(this, 0); }
void mummy_run11(entity this) { set_animofs(this, anim_mummy_run, 11, mummy_run12); ai_run(this, 0); }
void mummy_run10(entity this) { set_animofs(this, anim_mummy_run, 10, mummy_run11); ai_run(this, 0); }
void mummy_run9(entity this) { set_animofs(this, anim_mummy_run, 9, mummy_run10); ai_run(this, 4); }
void mummy_run8(entity this) { set_animofs(this, anim_mummy_run, 8, mummy_run9); ai_run(this, 8); }
void mummy_run7(entity this) { set_animofs(this, anim_mummy_run, 7, mummy_run8); ai_run(this, 8); }
void mummy_run6(entity this) { set_animofs(this, anim_mummy_run, 6, mummy_run7); ai_run(this, 6); }
void mummy_run5(entity this) { set_animofs(this, anim_mummy_run, 5, mummy_run6); ai_run(this, 4); }
void mummy_run4(entity this) { set_animofs(this, anim_mummy_run, 4, mummy_run5); ai_run(this, 2); }
void mummy_run3(entity this) { set_animofs(this, anim_mummy_run, 3, mummy_run4); ai_run(this, 0); }
void mummy_run2(entity this) { set_animofs(this, anim_mummy_run, 2, mummy_run3); ai_run(this, 2); }
void mummy_run1(entity this) { set_animofs(this, anim_mummy_run, 1, mummy_run2); ai_run(this, 2); this.inpain = 0; }


/*
=============================================================================

ATTACKS

=============================================================================
*/

void mummyGrenadeRemove(entity this, entity toucher)
{
	delete(this);
}

void mummyGrenadeTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;     // don't explode on owner
	if(toucher.takedamage)
	{
		float mummyDamage = 15 + random() * 15;
		  
		T_Damage(toucher, this, this.owner, mummyDamage, this.projectiledeathtype);
		_sound(this, CH_WEAPON_SINGLE, "zombie/z_hit.wav", 1, ATTN_NORM);
		delete(this);
		return;
	}
	_sound(this, CH_WEAPON_SINGLE, "zombie/z_miss.wav", 1, ATTN_NORM);   // bounce sound
	this.velocity = '0 0 0';
	this.avelocity = '0 0 0';
	settouch(this, mummyGrenadeRemove);
}

/*
================
mummyFireGrenade
================
*/
void mummyFireGrenade(entity this, vector st)
{
	_sound(this, CH_WEAPON_SINGLE, "zombie/z_shot1.wav", 1, ATTN_NORM);

	entity missile = spawn();
	missile.owner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;
	missile.projectiledeathtype = DEATH_MONSTER_MUMMY.m_id;

// calc org
	vector org = this.origin + st.x * v_forward + st.y * v_right + (st.z - 24) * v_up;
	
// set missile speed    

	makevectors(this.angles);

	missile.velocity = normalize(this.enemy.origin - org);
	missile.velocity = missile.velocity * 600;
	missile.velocity_z = 200;

	missile.avelocity = '3000 1000 2000';

	settouch(missile, mummyGrenadeTouch);
	
// set missile duration
	missile.nextthink = time + 2.5;
	setthink(missile, SUB_Remove);

	_setmodel(missile, "progs/zom_gib.mdl");
	setsize(missile, '0 0 0', '0 0 0');        
	setorigin(missile, org);
}

void mummy_atta13(entity this) { set_animofs(this, anim_mummy_atta, 13, mummy_run1); ai_face(this); mummyFireGrenade(this, '-10 -22 30'); }
void mummy_atta12(entity this) { set_animofs(this, anim_mummy_atta, 12, mummy_atta13); ai_face(this); }
void mummy_atta11(entity this) { set_animofs(this, anim_mummy_atta, 11, mummy_atta12); ai_face(this); }
void mummy_atta10(entity this) { set_animofs(this, anim_mummy_atta, 10, mummy_atta11); ai_face(this); }
void mummy_atta9(entity this) { set_animofs(this, anim_mummy_atta, 9, mummy_atta10); ai_face(this); }
void mummy_atta8(entity this) { set_animofs(this, anim_mummy_atta, 8, mummy_atta9); ai_face(this); }
void mummy_atta7(entity this) { set_animofs(this, anim_mummy_atta, 7, mummy_atta8); ai_face(this); }
void mummy_atta6(entity this) { set_animofs(this, anim_mummy_atta, 6, mummy_atta7); ai_face(this); }
void mummy_atta5(entity this) { set_animofs(this, anim_mummy_atta, 5, mummy_atta6); ai_face(this); }
void mummy_atta4(entity this) { set_animofs(this, anim_mummy_atta, 4, mummy_atta5); ai_face(this); }
void mummy_atta3(entity this) { set_animofs(this, anim_mummy_atta, 3, mummy_atta4); ai_face(this); }
void mummy_atta2(entity this) { set_animofs(this, anim_mummy_atta, 2, mummy_atta3); ai_face(this); }
void mummy_atta1(entity this) { set_animofs(this, anim_mummy_atta, 1, mummy_atta2); ai_face(this); }

void mummy_attb14(entity this) { set_animofs(this, anim_mummy_attb, 13, mummy_run1); ai_face(this); mummyFireGrenade(this, '-10 -24 29'); }
void mummy_attb13(entity this) { set_animofs(this, anim_mummy_attb, 13, mummy_attb14); ai_face(this); }
void mummy_attb12(entity this) { set_animofs(this, anim_mummy_attb, 12, mummy_attb13); ai_face(this); }
void mummy_attb11(entity this) { set_animofs(this, anim_mummy_attb, 11, mummy_attb12); ai_face(this); }
void mummy_attb10(entity this) { set_animofs(this, anim_mummy_attb, 10, mummy_attb11); ai_face(this); }
void mummy_attb9(entity this) { set_animofs(this, anim_mummy_attb, 9, mummy_attb10); ai_face(this); }
void mummy_attb8(entity this) { set_animofs(this, anim_mummy_attb, 8, mummy_attb9); ai_face(this); }
void mummy_attb7(entity this) { set_animofs(this, anim_mummy_attb, 7, mummy_attb8); ai_face(this); }
void mummy_attb6(entity this) { set_animofs(this, anim_mummy_attb, 6, mummy_attb7); ai_face(this); }
void mummy_attb5(entity this) { set_animofs(this, anim_mummy_attb, 5, mummy_attb6); ai_face(this); }
void mummy_attb4(entity this) { set_animofs(this, anim_mummy_attb, 4, mummy_attb5); ai_face(this); }
void mummy_attb3(entity this) { set_animofs(this, anim_mummy_attb, 3, mummy_attb4); ai_face(this); }
void mummy_attb2(entity this) { set_animofs(this, anim_mummy_attb, 2, mummy_attb3); ai_face(this); }
void mummy_attb1(entity this) { set_animofs(this, anim_mummy_attb, 1, mummy_attb2); ai_face(this); }

void mummy_attc12(entity this) { set_animofs(this, anim_mummy_attc, 12, mummy_run1); ai_face(this); mummyFireGrenade(this, '-12 -19 29'); }
void mummy_attc11(entity this) { set_animofs(this, anim_mummy_attc, 11, mummy_attc12); ai_face(this); }
void mummy_attc10(entity this) { set_animofs(this, anim_mummy_attc, 10, mummy_attc11); ai_face(this); }
void mummy_attc9(entity this) { set_animofs(this, anim_mummy_attc, 9, mummy_attc10); ai_face(this); }
void mummy_attc8(entity this) { set_animofs(this, anim_mummy_attc, 8, mummy_attc9); ai_face(this); }
void mummy_attc7(entity this) { set_animofs(this, anim_mummy_attc, 7, mummy_attc8); ai_face(this); }
void mummy_attc6(entity this) { set_animofs(this, anim_mummy_attc, 6, mummy_attc7); ai_face(this); }
void mummy_attc5(entity this) { set_animofs(this, anim_mummy_attc, 5, mummy_attc6); ai_face(this); }
void mummy_attc4(entity this) { set_animofs(this, anim_mummy_attc, 4, mummy_attc5); ai_face(this); }
void mummy_attc3(entity this) { set_animofs(this, anim_mummy_attc, 3, mummy_attc4); ai_face(this); }
void mummy_attc2(entity this) { set_animofs(this, anim_mummy_attc, 2, mummy_attc3); ai_face(this); }
void mummy_attc1(entity this) { set_animofs(this, anim_mummy_attc, 1, mummy_attc2); ai_face(this); }

void mummy_missile(entity this)
{
	float r = random();
	
	if(r < 0.3)
		mummy_atta1(this);
	else if(r < 0.6)
		mummy_attb1(this);
	else
		mummy_attc1(this);
}


/*
=============================================================================

PAIN

=============================================================================
*/

void mummy_paina12(entity this) { set_animofs(this, anim_mummy_paina, 12, mummy_run1); }
void mummy_paina11(entity this) { set_animofs(this, anim_mummy_paina, 11, mummy_paina12); }
void mummy_paina10(entity this) { set_animofs(this, anim_mummy_paina, 10, mummy_paina11); }
void mummy_paina9(entity this) { set_animofs(this, anim_mummy_paina, 9, mummy_paina10); }
void mummy_paina8(entity this) { set_animofs(this, anim_mummy_paina, 8, mummy_paina9); }
void mummy_paina7(entity this) { set_animofs(this, anim_mummy_paina, 7, mummy_paina8); }
void mummy_paina6(entity this) { set_animofs(this, anim_mummy_paina, 6, mummy_paina7); ai_pain(this, 1); }
void mummy_paina5(entity this) { set_animofs(this, anim_mummy_paina, 5, mummy_paina6); ai_pain(this, 3); }
void mummy_paina4(entity this) { set_animofs(this, anim_mummy_paina, 4, mummy_paina5); ai_pain(this, 1); }
void mummy_paina3(entity this) { set_animofs(this, anim_mummy_paina, 3, mummy_paina4); ai_painforward(this, 1); }
void mummy_paina2(entity this) { set_animofs(this, anim_mummy_paina, 2, mummy_paina3); ai_painforward(this, 3); }
void mummy_paina1(entity this) { set_animofs(this, anim_mummy_paina, 1, mummy_paina2); _sound (this, CH_VOICE, "zombie/z_pain.wav", 1, ATTN_NORM); }

void mummy_painb28(entity this) { set_animofs(this, anim_mummy_painb, 28, mummy_run1); }
void mummy_painb27(entity this) { set_animofs(this, anim_mummy_painb, 27, mummy_painb28); }
void mummy_painb26(entity this) { set_animofs(this, anim_mummy_painb, 26, mummy_painb27); }
void mummy_painb25(entity this) { set_animofs(this, anim_mummy_painb, 25, mummy_painb26); ai_painforward(this, 1); }
void mummy_painb24(entity this) { set_animofs(this, anim_mummy_painb, 24, mummy_painb25); }
void mummy_painb23(entity this) { set_animofs(this, anim_mummy_painb, 23, mummy_painb24); }
void mummy_painb22(entity this) { set_animofs(this, anim_mummy_painb, 22, mummy_painb23); }
void mummy_painb21(entity this) { set_animofs(this, anim_mummy_painb, 21, mummy_painb22); }
void mummy_painb20(entity this) { set_animofs(this, anim_mummy_painb, 20, mummy_painb21); }
void mummy_painb19(entity this) { set_animofs(this, anim_mummy_painb, 19, mummy_painb20); }
void mummy_painb18(entity this) { set_animofs(this, anim_mummy_painb, 18, mummy_painb19); }
void mummy_painb17(entity this) { set_animofs(this, anim_mummy_painb, 17, mummy_painb18); }
void mummy_painb16(entity this) { set_animofs(this, anim_mummy_painb, 16, mummy_painb17); }
void mummy_painb15(entity this) { set_animofs(this, anim_mummy_painb, 15, mummy_painb16); }
void mummy_painb14(entity this) { set_animofs(this, anim_mummy_painb, 14, mummy_painb15); }
void mummy_painb13(entity this) { set_animofs(this, anim_mummy_painb, 13, mummy_painb14); }
void mummy_painb12(entity this) { set_animofs(this, anim_mummy_painb, 12, mummy_painb13); }
void mummy_painb11(entity this) { set_animofs(this, anim_mummy_painb, 11, mummy_painb12); }
void mummy_painb10(entity this) { set_animofs(this, anim_mummy_painb, 10, mummy_painb11); }
void mummy_painb9(entity this) { set_animofs(this, anim_mummy_painb, 9, mummy_painb10); _sound (this, CH_PLAYER, "zombie/z_fall.wav", 1, ATTN_NORM); }
void mummy_painb8(entity this) { set_animofs(this, anim_mummy_painb, 8, mummy_painb9); }
void mummy_painb7(entity this) { set_animofs(this, anim_mummy_painb, 7, mummy_painb8); }
void mummy_painb6(entity this) { set_animofs(this, anim_mummy_painb, 6, mummy_painb7); }
void mummy_painb5(entity this) { set_animofs(this, anim_mummy_painb, 5, mummy_painb6); ai_pain(this, 2); }
void mummy_painb4(entity this) { set_animofs(this, anim_mummy_painb, 4, mummy_painb5); ai_pain(this, 6); }
void mummy_painb3(entity this) { set_animofs(this, anim_mummy_painb, 3, mummy_painb4); ai_pain(this, 8); }
void mummy_painb2(entity this) { set_animofs(this, anim_mummy_painb, 2, mummy_painb3); ai_pain(this, 2); }
void mummy_painb1(entity this) { set_animofs(this, anim_mummy_painb, 1, mummy_painb2); _sound (this, CH_VOICE, "zombie/z_pain1.wav", 1, ATTN_NORM); }

void mummy_painc18(entity this) { set_animofs(this, anim_mummy_painc, 18, mummy_run1); }
void mummy_painc17(entity this) { set_animofs(this, anim_mummy_painc, 17, mummy_painc18); }
void mummy_painc16(entity this) { set_animofs(this, anim_mummy_painc, 16, mummy_painc17); }
void mummy_painc15(entity this) { set_animofs(this, anim_mummy_painc, 15, mummy_painc16); }
void mummy_painc14(entity this) { set_animofs(this, anim_mummy_painc, 14, mummy_painc15); }
void mummy_painc13(entity this) { set_animofs(this, anim_mummy_painc, 13, mummy_painc14); }
void mummy_painc12(entity this) { set_animofs(this, anim_mummy_painc, 12, mummy_painc13); ai_painforward(this, 1); }
void mummy_painc11(entity this) { set_animofs(this, anim_mummy_painc, 11, mummy_painc12); ai_painforward(this, 1); }
void mummy_painc10(entity this) { set_animofs(this, anim_mummy_painc, 10, mummy_painc11); }
void mummy_painc9(entity this) { set_animofs(this, anim_mummy_painc, 9, mummy_painc10); }
void mummy_painc8(entity this) { set_animofs(this, anim_mummy_painc, 8, mummy_painc9); }
void mummy_painc7(entity this) { set_animofs(this, anim_mummy_painc, 7, mummy_painc8); }
void mummy_painc6(entity this) { set_animofs(this, anim_mummy_painc, 6, mummy_painc7); }
void mummy_painc5(entity this) { set_animofs(this, anim_mummy_painc, 5, mummy_painc6); }
void mummy_painc4(entity this) { set_animofs(this, anim_mummy_painc, 4, mummy_painc5); ai_pain(this, 1); }
void mummy_painc3(entity this) { set_animofs(this, anim_mummy_painc, 3, mummy_painc4); ai_pain(this, 3); }
void mummy_painc2(entity this) { set_animofs(this, anim_mummy_painc, 2, mummy_painc3); }
void mummy_painc1(entity this) { set_animofs(this, anim_mummy_painc, 1, mummy_painc2); _sound (this, CH_VOICE, "zombie/z_pain1.wav", 1, ATTN_NORM); }

void mummy_paind13(entity this) { set_animofs(this, anim_mummy_paind, 13, mummy_run1); }
void mummy_paind12(entity this) { set_animofs(this, anim_mummy_paind, 12, mummy_paind13); }
void mummy_paind11(entity this) { set_animofs(this, anim_mummy_paind, 11, mummy_paind12); }
void mummy_paind10(entity this) { set_animofs(this, anim_mummy_paind, 10, mummy_paind11); }
void mummy_paind9(entity this) { set_animofs(this, anim_mummy_paind, 9, mummy_paind10); ai_pain(this, 1); }
void mummy_paind8(entity this) { set_animofs(this, anim_mummy_paind, 8, mummy_paind9); }
void mummy_paind7(entity this) { set_animofs(this, anim_mummy_paind, 7, mummy_paind8); }
void mummy_paind6(entity this) { set_animofs(this, anim_mummy_paind, 6, mummy_paind7); }
void mummy_paind5(entity this) { set_animofs(this, anim_mummy_paind, 5, mummy_paind6); }
void mummy_paind4(entity this) { set_animofs(this, anim_mummy_paind, 4, mummy_paind5); }
void mummy_paind3(entity this) { set_animofs(this, anim_mummy_paind, 3, mummy_paind4); }
void mummy_paind2(entity this) { set_animofs(this, anim_mummy_paind, 2, mummy_paind3); }
void mummy_paind1(entity this) { set_animofs(this, anim_mummy_paind, 1, mummy_paind2); _sound (this, CH_VOICE, "zombie/z_pain.wav", 1, ATTN_NORM); }

void mummy_paine11(entity this);
void mummy_paine30(entity this) { set_animofs(this, anim_mummy_paine, 30, mummy_run1); }
void mummy_paine29(entity this) { set_animofs(this, anim_mummy_paine, 29, mummy_paine30); }
void mummy_paine28(entity this) { set_animofs(this, anim_mummy_paine, 28, mummy_paine29); ai_pain(this, 1); }
void mummy_paine27(entity this) { set_animofs(this, anim_mummy_paine, 27, mummy_paine28); ai_painforward(this, 1); }
void mummy_paine26(entity this) { set_animofs(this, anim_mummy_paine, 26, mummy_paine27); ai_painforward(this, 3); }
void mummy_paine25(entity this) { set_animofs(this, anim_mummy_paine, 25, mummy_paine26); ai_painforward(this, 5); }
void mummy_paine24(entity this) { set_animofs(this, anim_mummy_paine, 24, mummy_paine25); }
void mummy_paine23(entity this) { set_animofs(this, anim_mummy_paine, 23, mummy_paine24); }
void mummy_paine22(entity this) { set_animofs(this, anim_mummy_paine, 22, mummy_paine23); }
void mummy_paine21(entity this) { set_animofs(this, anim_mummy_paine, 21, mummy_paine22); }
void mummy_paine20(entity this) { set_animofs(this, anim_mummy_paine, 20, mummy_paine21); }
void mummy_paine19(entity this) { set_animofs(this, anim_mummy_paine, 19, mummy_paine20); }
void mummy_paine18(entity this) { set_animofs(this, anim_mummy_paine, 18, mummy_paine19); }
void mummy_paine17(entity this) { set_animofs(this, anim_mummy_paine, 17, mummy_paine18); }
void mummy_paine16(entity this) { set_animofs(this, anim_mummy_paine, 16, mummy_paine17); }
void mummy_paine15(entity this) { set_animofs(this, anim_mummy_paine, 15, mummy_paine16); }
void mummy_paine14(entity this) { set_animofs(this, anim_mummy_paine, 14, mummy_paine15); }
void mummy_paine13(entity this) { set_animofs(this, anim_mummy_paine, 13, mummy_paine14); }
void mummy_paine12(entity this)
{
	set_animofs(this, anim_mummy_paine, 12, mummy_paine13);
	// see if ok to stand up
	_sound(this, CH_VOICE, "zombie/z_idle.wav", 1, ATTN_IDLE);
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	this.solid = SOLID_SLIDEBOX;
	tracebox(this.origin, this.mins, this.maxs, this.origin, MOVE_NOMONSTERS, this);
	if(trace_startsolid)
	{
		setthink(this, mummy_paine11);
		this.solid = SOLID_CORPSE;
		return;
	}
}
void mummy_paine11(entity this) { set_animofs(this, anim_mummy_paine, 11, mummy_paine12); this.nextthink = this.nextthink + 5; }
void mummy_paine10(entity this) { set_animofs(this, anim_mummy_paine, 10, mummy_paine11); _sound(this, CH_PLAYER, "zombie/z_fall.wav", 1, ATTN_NORM); }
void mummy_paine9(entity this) { set_animofs(this, anim_mummy_paine, 9, mummy_paine10); ai_pain(this, 2); }
void mummy_paine8(entity this) { set_animofs(this, anim_mummy_paine, 8, mummy_paine9); ai_pain(this, 1); }
void mummy_paine7(entity this) { set_animofs(this, anim_mummy_paine, 7, mummy_paine8); ai_pain(this, 1); }
void mummy_paine6(entity this) { set_animofs(this, anim_mummy_paine, 6, mummy_paine7); ai_pain(this, 2); }
void mummy_paine5(entity this) { set_animofs(this, anim_mummy_paine, 5, mummy_paine6); ai_pain(this, 1); }
void mummy_paine4(entity this) { set_animofs(this, anim_mummy_paine, 4, mummy_paine5); ai_pain(this, 3); }
void mummy_paine3(entity this) { set_animofs(this, anim_mummy_paine, 3, mummy_paine4); ai_pain(this, 5); }
void mummy_paine2(entity this) { set_animofs(this, anim_mummy_paine, 2, mummy_paine3); ai_pain(this, 8); }
void mummy_paine1(entity this) { set_animofs(this, anim_mummy_paine, 1, mummy_paine2); _sound(this, CH_VOICE, "zombie/z_pain.wav", 1, ATTN_NORM); this.solid = SOLID_CORPSE; }

void mummy_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.health = -35;
	_sound(this, CH_VOICE, "zombie/z_gib.wav", 1, ATTN_NORM);
	ThrowHead(this, "progs/h_zombie.mdl", this.health);
	ThrowGib(this, "progs/gib1.mdl", this.health);
	ThrowGib(this, "progs/gib2.mdl", this.health);
	ThrowGib(this, "progs/gib3.mdl", this.health);
}

/*
=================
mummy_pain
=================
*/
void mummy_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)	
		return;
	
	float r = random();
	if(r > 0.24)
		return;
			
	this.pain_finished = time + 2.5;
	
	if(r < 0.06)
		mummy_paina1(this);
	else if(r <  0.12)
		mummy_painb1(this);
	else if(r <  0.18)
		mummy_painc1(this);
	else
		mummy_paind1(this);
}

void mummy_sleep(entity this) { set_animofs(this, anim_mummy_paine, 11, mummy_sleep); ai_stand(this); }

void mummy_wake(entity this)
{
	this.th_stand = mummy_stand1;
	this.th_walk = mummy_walk1;
	this.th_pain = mummy_pain;
	this.th_run = mummy_run1;
	this.th_missile = mummy_missile;

	mummy_paine12(this);
}
void mummy_wake_pain(entity this, entity attacker, float damage, int deathtype)
{
	mummy_wake(this);
}

//============================================================================

const int MUMMY_STRONG = BIT(2);

/*QUAKED monster_mummy (1 0 0) (-16 -16 -24) (16 16 32) Ambush Lying Stronger

Lying - mummy will start lying down, and stand when player spotted.
Stronger - mummy starts with 1000 hitpoints, rather than 500.
*/
spawnfunc(monster_mummy)
{
	if(!MP_ROGUE) { delete(this); return; }
	monster_start(this, true, MON_MUMMY);
}
#endif // SVQC

#ifdef SVQC
METHOD(Mummy, mr_setup, bool(Mummy this, entity actor))
{
    TC(Mummy, this);

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

    if(actor.spawnflags & MUMMY_STRONG)
		actor.health = 1000;
	else
		actor.health = 500;

	if(actor.spawnflags & SPAWN_LYING)
	{
		setsize(actor, '-16 -16 -24', '16 16 -16');
		actor.solid = SOLID_CORPSE;
		actor.th_stand = mummy_sleep;
		actor.th_run = mummy_wake;
		actor.th_walk = mummy_wake;
		actor.th_pain = mummy_wake_pain;
		actor.th_missile = mummy_wake;
	}
	else
	{
		actor.th_stand = mummy_stand1;
		actor.th_walk = mummy_walk1;
		actor.th_run = mummy_run1;
		actor.th_pain = mummy_pain;
		actor.th_die = mummy_die;
		actor.th_missile = mummy_missile;
	}

    return true;
}
#endif
