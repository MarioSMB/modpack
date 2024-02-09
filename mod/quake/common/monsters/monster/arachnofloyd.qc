#include "arachnofloyd.qh"

#ifdef SVQC
const int anim_arachnofloyd_walk = 0; //'0 13 0'
const int anim_arachnofloyd_idle = 14; //'14 40 0'
const int anim_arachnofloyd_paina = 41; //'41 49 0'
const int anim_arachnofloyd_painb = 50; //'50 68 0'
const int anim_arachnofloyd_leap = 69; //'69 79 0'
const int anim_arachnofloyd_light = 80; //'80 90 0'
const int anim_arachnofloyd_death = 91; //'91 113 0'

.entity sibling;

void arf_step(entity this, float num)
{
	if(num == 1)
		_sound(this, 5, "arachnofloyd/step1.wav", 1, 1.5);
	else
		_sound(this, 5, "arachnofloyd/step2.wav", 1, 1.5);
}

void arf_whirr(entity this)
{
	_sound(this, CHAN_BODY, "arachnofloyd/whirr1.wav", 1, ATTN_IDLE);
}

void check_onground(entity this)
{
	if(IS_ONGROUND(this))
		settouch(this, func_null);
}

//-----------------------------------------------------------------------------

void arf_stand1(entity this);
void arf_stand27(entity this) { set_animofs(this, anim_arachnofloyd_idle, 27, arf_stand1); ai_stand(this); }
void arf_stand26(entity this) { set_animofs(this, anim_arachnofloyd_idle, 26, arf_stand27); ai_stand(this); }
void arf_stand25(entity this) { set_animofs(this, anim_arachnofloyd_idle, 25, arf_stand26); ai_stand(this); }
void arf_stand24(entity this) { set_animofs(this, anim_arachnofloyd_idle, 24, arf_stand25); ai_stand(this); }
void arf_stand23(entity this) { set_animofs(this, anim_arachnofloyd_idle, 23, arf_stand24); ai_stand(this); }
void arf_stand22(entity this) { set_animofs(this, anim_arachnofloyd_idle, 22, arf_stand23); ai_stand(this); }
void arf_stand21(entity this) { set_animofs(this, anim_arachnofloyd_idle, 21, arf_stand22); ai_stand(this); }
void arf_stand20(entity this) { set_animofs(this, anim_arachnofloyd_idle, 20, arf_stand21); ai_stand(this); }
void arf_stand19(entity this) { set_animofs(this, anim_arachnofloyd_idle, 19, arf_stand20); ai_stand(this); }
void arf_stand18(entity this) { set_animofs(this, anim_arachnofloyd_idle, 18, arf_stand19); ai_stand(this); }
void arf_stand17(entity this) { set_animofs(this, anim_arachnofloyd_idle, 17, arf_stand18); ai_stand(this); }
void arf_stand16(entity this) { set_animofs(this, anim_arachnofloyd_idle, 16, arf_stand17); ai_stand(this); }
void arf_stand15(entity this) { set_animofs(this, anim_arachnofloyd_idle, 15, arf_stand16); ai_stand(this); }
void arf_stand14(entity this) { set_animofs(this, anim_arachnofloyd_idle, 14, arf_stand15); ai_stand(this); }
void arf_stand13(entity this) { set_animofs(this, anim_arachnofloyd_idle, 13, arf_stand14); ai_stand(this); }
void arf_stand12(entity this) { set_animofs(this, anim_arachnofloyd_idle, 12, arf_stand13); ai_stand(this); }
void arf_stand11(entity this) { set_animofs(this, anim_arachnofloyd_idle, 11, arf_stand12); ai_stand(this); }
void arf_stand10(entity this) { set_animofs(this, anim_arachnofloyd_idle, 10, arf_stand11); ai_stand(this); }
void arf_stand9(entity this) { set_animofs(this, anim_arachnofloyd_idle, 9, arf_stand10); ai_stand(this); }
void arf_stand8(entity this) { set_animofs(this, anim_arachnofloyd_idle, 8, arf_stand9); ai_stand(this); }
void arf_stand7(entity this) { set_animofs(this, anim_arachnofloyd_idle, 7, arf_stand8); ai_stand(this); }
void arf_stand6(entity this) { set_animofs(this, anim_arachnofloyd_idle, 6, arf_stand7); ai_stand(this); }
void arf_stand5(entity this) { set_animofs(this, anim_arachnofloyd_idle, 5, arf_stand6); ai_stand(this); }
void arf_stand4(entity this) { set_animofs(this, anim_arachnofloyd_idle, 4, arf_stand5); ai_stand(this); }
void arf_stand3(entity this) { set_animofs(this, anim_arachnofloyd_idle, 3, arf_stand4); ai_stand(this); }
void arf_stand2(entity this) { set_animofs(this, anim_arachnofloyd_idle, 2, arf_stand3); ai_stand(this); }
void arf_stand1(entity this)
{
	set_animofs(this, anim_arachnofloyd_idle, 1, arf_stand2);
	if(random() < 0.2)
	{
		if(random() < 0.1) 	
			_sound(this, CH_VOICE, "arachnofloyd/idle1.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "arachnofloyd/idle2.wav", 1, ATTN_IDLE);
	}
	ai_stand(this);	
}

void arf_walk1(entity this);
void arf_walk14(entity this) { set_animofs(this, anim_arachnofloyd_walk, 14, arf_walk1); ai_walk(this, 4); }
void arf_walk13(entity this) { set_animofs(this, anim_arachnofloyd_walk, 13, arf_walk14); ai_walk(this, 0); }
void arf_walk12(entity this) { set_animofs(this, anim_arachnofloyd_walk, 12, arf_walk13); ai_walk(this, 2); arf_step(this, 2); }
void arf_walk11(entity this) { set_animofs(this, anim_arachnofloyd_walk, 11, arf_walk12); ai_walk(this, 4); }
void arf_walk10(entity this) { set_animofs(this, anim_arachnofloyd_walk, 10, arf_walk11); ai_walk(this, 8); arf_whirr(this); }
void arf_walk9(entity this) { set_animofs(this, anim_arachnofloyd_walk, 9, arf_walk10); ai_walk(this, 8); }
void arf_walk8(entity this) { set_animofs(this, anim_arachnofloyd_walk, 8, arf_walk9); ai_walk(this, 8); }
void arf_walk7(entity this) { set_animofs(this, anim_arachnofloyd_walk, 7, arf_walk8); ai_walk(this, 8); }
void arf_walk6(entity this) { set_animofs(this, anim_arachnofloyd_walk, 6, arf_walk7); ai_walk(this, 8); }
void arf_walk5(entity this) { set_animofs(this, anim_arachnofloyd_walk, 5, arf_walk6); ai_walk(this, 4); }
void arf_walk4(entity this) { set_animofs(this, anim_arachnofloyd_walk, 4, arf_walk5); ai_walk(this, 0); arf_step(this, 1); }
void arf_walk3(entity this) { set_animofs(this, anim_arachnofloyd_walk, 3, arf_walk4); ai_walk(this, 2); }
void arf_walk2(entity this) { set_animofs(this, anim_arachnofloyd_walk, 2, arf_walk3); ai_walk(this, 4); arf_whirr(this); }
void arf_walk1(entity this) { set_animofs(this, anim_arachnofloyd_walk, 1, arf_walk2); ai_walk(this, 10); }

void arf_run_fr(entity this, float dist)
{
	check_onground(this);
	ai_run(this, dist);
	this.nextthink = time + 0.075; 
}

void arf_run1(entity this);
void arf_run14(entity this) { set_animofs(this, anim_arachnofloyd_walk, 14, arf_run1); arf_run_fr(this, 6); }
void arf_run13(entity this) { set_animofs(this, anim_arachnofloyd_walk, 13, arf_run14); arf_run_fr(this, 0); }
void arf_run12(entity this) { set_animofs(this, anim_arachnofloyd_walk, 12, arf_run13); arf_run_fr(this, 2); arf_step(this, 2); }
void arf_run11(entity this) { set_animofs(this, anim_arachnofloyd_walk, 11, arf_run12); arf_run_fr(this, 6); }
void arf_run10(entity this) { set_animofs(this, anim_arachnofloyd_walk, 10, arf_run11); arf_run_fr(this, 12); }
void arf_run9(entity this) { set_animofs(this, anim_arachnofloyd_walk, 9, arf_run10); arf_run_fr(this, 12); arf_whirr(this); }
void arf_run8(entity this) { set_animofs(this, anim_arachnofloyd_walk, 8, arf_run9); arf_run_fr(this, 12); }
void arf_run7(entity this) { set_animofs(this, anim_arachnofloyd_walk, 7, arf_run8); arf_run_fr(this, 12); }
void arf_run6(entity this) { set_animofs(this, anim_arachnofloyd_walk, 6, arf_run7); arf_run_fr(this, 4); }
void arf_run5(entity this) { set_animofs(this, anim_arachnofloyd_walk, 5, arf_run6); arf_run_fr(this, 0); }
void arf_run4(entity this) { set_animofs(this, anim_arachnofloyd_walk, 4, arf_run5); arf_run_fr(this, 0); arf_step(this, 1); }
void arf_run3(entity this) { set_animofs(this, anim_arachnofloyd_walk, 3, arf_run4); arf_run_fr(this, 4); }
void arf_run2(entity this) { set_animofs(this, anim_arachnofloyd_walk, 2, arf_run3); arf_run_fr(this, 8); }
void arf_run1(entity this) { set_animofs(this, anim_arachnofloyd_walk, 1, arf_run2); arf_run_fr(this, 12); arf_whirr(this); }

void arf_paina9(entity this) { set_animofs(this, anim_arachnofloyd_paina, 9, arf_run1); }
void arf_paina8(entity this) { set_animofs(this, anim_arachnofloyd_paina, 8, arf_paina9); }
void arf_paina7(entity this) { set_animofs(this, anim_arachnofloyd_paina, 7, arf_paina8); }
void arf_paina6(entity this) { set_animofs(this, anim_arachnofloyd_paina, 6, arf_paina7); }
void arf_paina5(entity this) { set_animofs(this, anim_arachnofloyd_paina, 5, arf_paina6); }
void arf_paina4(entity this) { set_animofs(this, anim_arachnofloyd_paina, 4, arf_paina5); }
void arf_paina3(entity this) { set_animofs(this, anim_arachnofloyd_paina, 3, arf_paina4); }
void arf_paina2(entity this) { set_animofs(this, anim_arachnofloyd_paina, 2, arf_paina3); }
void arf_paina1(entity this) { set_animofs(this, anim_arachnofloyd_paina, 1, arf_paina2); }

void arf_painb19(entity this) { set_animofs(this, anim_arachnofloyd_painb, 19, arf_run1); }
void arf_painb18(entity this) { set_animofs(this, anim_arachnofloyd_painb, 18, arf_painb19); }
void arf_painb17(entity this) { set_animofs(this, anim_arachnofloyd_painb, 17, arf_painb18); }
void arf_painb16(entity this) { set_animofs(this, anim_arachnofloyd_painb, 16, arf_painb17); }
void arf_painb15(entity this) { set_animofs(this, anim_arachnofloyd_painb, 15, arf_painb16); }
void arf_painb14(entity this) { set_animofs(this, anim_arachnofloyd_painb, 14, arf_painb15); }
void arf_painb13(entity this) { set_animofs(this, anim_arachnofloyd_painb, 13, arf_painb14); }
void arf_painb12(entity this) { set_animofs(this, anim_arachnofloyd_painb, 12, arf_painb13); }
void arf_painb11(entity this) { set_animofs(this, anim_arachnofloyd_painb, 11, arf_painb12); }
void arf_painb10(entity this) { set_animofs(this, anim_arachnofloyd_painb, 10, arf_painb11); }
void arf_painb9(entity this) { set_animofs(this, anim_arachnofloyd_painb, 9, arf_painb10); }
void arf_painb8(entity this) { set_animofs(this, anim_arachnofloyd_painb, 8, arf_painb9); }
void arf_painb7(entity this) { set_animofs(this, anim_arachnofloyd_painb, 7, arf_painb8); }
void arf_painb6(entity this) { set_animofs(this, anim_arachnofloyd_painb, 6, arf_painb7); }
void arf_painb5(entity this) { set_animofs(this, anim_arachnofloyd_painb, 5, arf_painb6); }
void arf_painb4(entity this) { set_animofs(this, anim_arachnofloyd_painb, 4, arf_painb5); }
void arf_painb3(entity this) { set_animofs(this, anim_arachnofloyd_painb, 3, arf_painb4); }
void arf_painb2(entity this) { set_animofs(this, anim_arachnofloyd_painb, 2, arf_painb3); }
void arf_painb1(entity this) { set_animofs(this, anim_arachnofloyd_painb, 1, arf_painb2); }

void arf_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	if(random()*200 > damage)
		return;		// didn't flinch

	this.pain_finished = time + 2;

	if(random() < 0.5)
	{	
		arf_paina1(this);
		_sound(this, CH_VOICE, "arachnofloyd/pain1.wav", 1, ATTN_NORM);
	}
	else
	{
		arf_painb1(this);
		_sound(this, CH_VOICE, "arachnofloyd/pain2.wav", 1, ATTN_NORM);
	}
}

void arf_explode(entity this)
{
	_sound(this, CH_VOICE, "arachnofloyd/death1.wav", 1, ATTN_NORM);
	ThrowHead(this, this, "progs/h_arach.mdl", this.health);
	ThrowGib(this, this, "progs/fgib1.mdl", this.health);
	ThrowGib(this, this, "progs/fgib1.mdl", this.health);
	ThrowGib(this, this, "progs/fgib1.mdl", this.health);
	ThrowGib(this, this, "progs/fgib1.mdl", this.health);
	ThrowGib(this, this, "progs/fgib1.mdl", this.health);

	BecomeExplosion(this);
}

void arf_die23(entity this) { set_animofs(this, anim_arachnofloyd_death, 23, arf_die23); arf_explode(this); }
void arf_die22(entity this) { set_animofs(this, anim_arachnofloyd_death, 22, arf_die23); }
void arf_die21(entity this) { set_animofs(this, anim_arachnofloyd_death, 21, arf_die22); }
void arf_die20(entity this) { set_animofs(this, anim_arachnofloyd_death, 20, arf_die21); }
void arf_die19(entity this) { set_animofs(this, anim_arachnofloyd_death, 19, arf_die20); }
void arf_die18(entity this) { set_animofs(this, anim_arachnofloyd_death, 18, arf_die19); }
void arf_die17(entity this) { set_animofs(this, anim_arachnofloyd_death, 17, arf_die18); }
void arf_die16(entity this) { set_animofs(this, anim_arachnofloyd_death, 16, arf_die17); }
void arf_die15(entity this) { set_animofs(this, anim_arachnofloyd_death, 15, arf_die16); }
void arf_die14(entity this) { set_animofs(this, anim_arachnofloyd_death, 14, arf_die15); }
void arf_die13(entity this) { set_animofs(this, anim_arachnofloyd_death, 13, arf_die14); }
void arf_die12(entity this) { set_animofs(this, anim_arachnofloyd_death, 12, arf_die13); }
void arf_die11(entity this) { set_animofs(this, anim_arachnofloyd_death, 11, arf_die12); }
void arf_die10(entity this) { set_animofs(this, anim_arachnofloyd_death, 10, arf_die11); }
void arf_die9(entity this) { set_animofs(this, anim_arachnofloyd_death, 9, arf_die10); }
void arf_die8(entity this) { set_animofs(this, anim_arachnofloyd_death, 8, arf_die9); }
void arf_die7(entity this) { set_animofs(this, anim_arachnofloyd_death, 7, arf_die8); }
void arf_die6(entity this) { set_animofs(this, anim_arachnofloyd_death, 6, arf_die7); }
void arf_die5(entity this) { set_animofs(this, anim_arachnofloyd_death, 5, arf_die6); }
void arf_die4(entity this) { set_animofs(this, anim_arachnofloyd_death, 4, arf_die5); }
void arf_die3(entity this) { set_animofs(this, anim_arachnofloyd_death, 3, arf_die4); }
void arf_die2(entity this) { set_animofs(this, anim_arachnofloyd_death, 2, arf_die3); }
void arf_die1(entity this) { set_animofs(this, anim_arachnofloyd_death, 1, arf_die2); this.solid = SOLID_NOT; }

void arf_die(entity this, entity inflictor, entity attacker, int deathtype)
{
// check for gib
	if(this.health < -60)
	{
		arf_explode(this);
		return;
	}

// regular death
	_sound(this, CH_VOICE, "arachnofloyd/death2.wav", 1, ATTN_NORM);
	arf_die1(this);
}

void arf_touch_jump(entity this, entity toucher)
{
	if(IS_PLAYER(toucher) && toucher.pain_finished > time)
		return;

	if(toucher.takedamage)
	{
		T_Damage(toucher, this, this, 60, DEATH_MONSTER_ARACHNOFLOYD.m_id);
		// stop the player from taking damage every frame
		toucher.pain_finished = time + 1;
	}
}

void arf_leap11(entity this) { set_animofs(this, anim_arachnofloyd_leap, 11, arf_run1); this.attack_finished = time + 2; check_onground(this); }
void arf_leap10(entity this) { set_animofs(this, anim_arachnofloyd_leap, 10, arf_leap11); check_onground(this); }
void arf_leap9(entity this) { set_animofs(this, anim_arachnofloyd_leap, 9, arf_leap10); check_onground(this); }
void arf_leap8(entity this) { set_animofs(this, anim_arachnofloyd_leap, 8, arf_leap9); check_onground(this); }
void arf_leap7(entity this) { set_animofs(this, anim_arachnofloyd_leap, 7, arf_leap8); check_onground(this); }
void arf_leap6(entity this)
{
	set_animofs(this, anim_arachnofloyd_leap, 6, arf_leap7);
	ai_face(this);
	this.yaw_speed = 20;
	_sound(this, CH_VOICE, "arachnofloyd/leap.wav", 0.7, ATTN_NORM);
	fixedmakevectors(this.angles);
	UNSET_ONGROUND(this);
	setorigin(this, this.origin + '0 0 16');
	this.velocity = '0 0 0';
	this.velocity = this.velocity + v_forward * 400;
	this.velocity_z = this.velocity_z + 275;
	settouch(this, arf_touch_jump);
}
void arf_leap5(entity this) { set_animofs(this, anim_arachnofloyd_leap, 5, arf_leap6); ai_face(this); }
void arf_leap4(entity this) { set_animofs(this, anim_arachnofloyd_leap, 4, arf_leap5); ai_face(this); }
void arf_leap3(entity this) { set_animofs(this, anim_arachnofloyd_leap, 3, arf_leap4); ai_face(this); }
void arf_leap2(entity this) { set_animofs(this, anim_arachnofloyd_leap, 2, arf_leap3); ai_face(this); }
void arf_leap1(entity this) { set_animofs(this, anim_arachnofloyd_leap, 1, arf_leap2); this.yaw_speed = 30; ai_face(this); }



//-----------------------------------------------------------------------------



void arf_fire_lightning(entity this, float offs)
{
	int cont = Mod_Q1BSP_SuperContentsFromNativeContents(pointcontents(this.origin));
	if(cont & DPCONTENTS_LIQUIDSMASK)
	{
		T_RadiusDamage(this, this, 35 * 8, DEATH_DISCHARGE.m_id, NULL);
		return;
	}

	this.effects |= EF_MUZZLEFLASH;
	makevectors(this.angles);
	vector org = this.origin + v_right * offs * 32 + v_forward * 24 + '0 0 24';
	vector org2 = this.origin + v_right * offs * 32 + v_forward * 24 + '0 0 24';
	vector dir = this.enemy.origin - org;
	dir = normalize(dir);
	
	traceline(org, org + dir*600, true, this);
	
	//fx_beam(org2, trace_endpos, this);
	SendCSQCLightningBeam(org2, trace_endpos);

	LightningDamage(org, trace_endpos, this, 8, DEATH_MONSTER_ARACHNOFLOYD.m_id);
}

void arf_charge_lightning(entity this, float fr)
{
	this.effects |= EF_MUZZLEFLASH;
	makevectors(this.sibling.angles);
	this.sibling.origin = this.origin + v_forward * 48 + v_up * -56 + v_right * -12;
	setorigin(this.sibling, this.sibling.origin);
	this.sibling.angles = this.angles;
	if(fr == 1)
		_sound(this, CH_WEAPON_SINGLE, "misc/power.wav", 1, ATTN_NORM);
}

void arf_lightning_remove(entity lt)
{
	if(lt.owner.sibling == lt)
		lt.owner.sibling = NULL;
	delete(lt);
}

void arf_lightning_think(entity this)
{
	if (time > this.attack_finished)
	{
		arf_lightning_remove(this);
		return;
	}

	if(this.frame >= 2)
		this.frame = 0;
	else
		this.frame += 1;

	this.nextthink = time + 0.05;
}

void arf_light11(entity this)
{
	set_animofs(this, anim_arachnofloyd_light, 11, arf_run1);
	ai_face(this);
	arf_fire_lightning(this, 1);
	this.attack_finished = time + 3.25;
}
void arf_light10(entity this) { set_animofs(this, anim_arachnofloyd_light, 10, arf_light11); ai_face(this); arf_fire_lightning(this, -1); }
void arf_light9(entity this) { set_animofs(this, anim_arachnofloyd_light, 9, arf_light10); ai_face(this); arf_fire_lightning(this, 1); }
void arf_light8(entity this) { set_animofs(this, anim_arachnofloyd_light, 8, arf_light9); ai_face(this); arf_fire_lightning(this, -1); }
void arf_light7(entity this)
{
	set_animofs(this, anim_arachnofloyd_light, 7, arf_light8);
	ai_face(this);
	//delete(this.sibling);
	_sound(this, CH_WEAPON_SINGLE, "shambler/sboom.wav", 1, ATTN_NORM);
	arf_fire_lightning(this, 1);
}
void arf_light6(entity this) { set_animofs(this, anim_arachnofloyd_light, 6, arf_light7); ai_face(this); arf_charge_lightning(this, 2); }
void arf_light5(entity this) { set_animofs(this, anim_arachnofloyd_light, 5, arf_light6); ai_face(this); arf_charge_lightning(this, 1); }
void arf_light4(entity this) { set_animofs(this, anim_arachnofloyd_light, 4, arf_light5); ai_face(this); arf_charge_lightning(this, 2); }
void arf_light3(entity this) { set_animofs(this, anim_arachnofloyd_light, 3, arf_light4); ai_face(this); arf_charge_lightning(this, 1); }
void arf_light2(entity this) { set_animofs(this, anim_arachnofloyd_light, 2, arf_light3); ai_face(this); arf_charge_lightning(this, 2); }
void arf_light1(entity this)
{
	set_animofs(this, anim_arachnofloyd_light, 1, arf_light2);
	ai_face(this);

	if(!this.sibling)
		this.sibling = spawn();
	this.sibling.owner = this;
	this.sibling.nextthink = time + 0.05;
	setthink(this.sibling, arf_lightning_think);
	this.sibling.attack_finished = time + 0.7;
	_setmodel(this.sibling, "progs/s_light.mdl");

	arf_charge_lightning(this, 1);
}

/*
===========
arfCheckAttack

based off ShamCheckAttack
============
*/
bool arfCheckAttack(entity this)
{
	if(this.enemy_range == RANGE_MELEE)
	{
		if(CanDamage(this.enemy, this))
		{
			this.attack_state = AS_MELEE;
			return true;
		}
	}

	if(MP_IMPEL)
	{
		if(this.enemy_range == RANGE_FAR)
			return false;
		if(time < this.attack_finished)
			return false;
	}
	else
	{
		if(time < this.attack_finished)
			return false;
		
		if(!this.enemy_visible)
			return false;
	}
		
	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	if(vdist(spot1 - spot2, >, 600))
		return false;

	traceline(spot1, spot2, false, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
	{
		return false;	// don't have a clear shot
	}
			
// missile attack
	if(!MP_IMPEL && this.enemy_range == RANGE_FAR)
		return false;
		
	this.attack_state = AS_MISSILE;
	this.attack_finished = time + (2 * 2 * random());
	return true;
}

/*QUAKED monster_arachnofloyd(1 0 0)(-32 -32 -24)(32 32 64) Ambush
*/
spawnfunc(monster_arachnofloyd) { monster_start(this, true, MON_ARACHNOFLOYD); }
#endif // SVQC

#ifdef SVQC
METHOD(Arachnofloyd, mr_setup, bool(Arachnofloyd this, entity actor))
{
    TC(Arachnofloyd, this);

	precache_model2("progs/fgib1.mdl");

	precache_model2("progs/s_light.mdl");
	precache_sound2("misc/power.wav");
	precache_sound2("shambler/sboom.wav");
	precache_sound2("arachnofloyd/whirr1.wav");
	precache_sound2("arachnofloyd/step2.wav");
	precache_sound2("arachnofloyd/step1.wav");
	precache_sound2("arachnofloyd/leap.wav");
	precache_sound2("arachnofloyd/death1.wav");
	precache_sound2("arachnofloyd/death2.wav");	
	precache_sound2("arachnofloyd/idle1.wav");
	precache_sound2("arachnofloyd/idle2.wav");	
	precache_sound2("arachnofloyd/pain1.wav");
	precache_sound2("arachnofloyd/pain2.wav");	

    actor.health = 600;
    actor.th_stand = arf_stand1;
	actor.th_walk = arf_walk1;
	actor.th_run = arf_run1;
	actor.th_missile = arf_light1;
	actor.th_melee = arf_leap1;
	actor.th_pain = arf_pain;
	actor.th_die = arf_die;

	actor.checkattack = arfCheckAttack;

    return true;
}
#endif
