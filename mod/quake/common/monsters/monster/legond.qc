#include "legond.qh"

#ifdef SVQC
void legond_shoot1(entity this);
void legond_light1(entity this);
void legond_shootb1(entity this);
void legond_combob1(entity this);

float LegondCheckAttack(entity this)
{
	if(this.enemy_range != RANGE_MELEE)
	{
		if(time < this.attack_finished)
			return false;
	}
	entity targ = this.enemy;
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;
	traceline(spot1, spot2, false, this);
	if(trace_ent != targ)
		return false;
	if(trace_inopen && trace_inwater)
		return false;
	if(this.enemy_range == RANGE_MELEE)
	{
		this.th_melee(this);
		return true;
	}
	float chance = 0;
	if(this.enemy_range == RANGE_FAR)
		chance = 0.1;
	else if(this.enemy_range == RANGE_MELEE)
	{
		chance = 0.9;
		this.attack_finished = 0;
	}
	else if(this.enemy_range == RANGE_NEAR)
	{
		if(this.th_melee)
			chance = 0.2;
		else
			chance = 0.4;
	}
	else if(this.enemy_range == RANGE_MID)
		chance = 0.2;
	float r = random();
	if(random() < chance)
	{
		if(r < 0.25)
			legond_shootb1(this);
		else if(r < 0.5)
			legond_shoot1(this);
		else if(r < 0.75)
			legond_combob1(this);
		else
			legond_light1(this);
		this.attack_finished = time + (2 * random());
		return true;
	}
	return false;
}
void legond_stand1(entity this);
void legond_stand10(entity this) { set_anim(this, 10, legond_stand1); ai_stand(this); }
void legond_stand9(entity this) { set_anim(this, 9, legond_stand10); ai_stand(this); }
void legond_stand8(entity this) { set_anim(this, 8, legond_stand9); ai_stand(this); }
void legond_stand7(entity this) { set_anim(this, 7, legond_stand8); ai_stand(this); }
void legond_stand6(entity this) { set_anim(this, 6, legond_stand7); ai_stand(this); }
void legond_stand5(entity this) { set_anim(this, 5, legond_stand6); ai_stand(this); }
void legond_stand4(entity this) { set_anim(this, 4, legond_stand5); ai_stand(this); }
void legond_stand3(entity this) { set_anim(this, 3, legond_stand4); ai_stand(this); }
void legond_stand2(entity this) { set_anim(this, 2, legond_stand3); ai_stand(this); }
void legond_stand1(entity this) { set_anim(this, 1, legond_stand2); ai_stand(this); }

void legond_walk1(entity this);
void legond_walk12(entity this) { set_anim(this, 22, legond_walk1); ai_walk(this, 15); }
void legond_walk11(entity this) { set_anim(this, 21, legond_walk12); ai_walk(this, 17); }
void legond_walk10(entity this) { set_anim(this, 20, legond_walk11); ai_walk(this, 16); }
void legond_walk9(entity this) { set_anim(this, 19, legond_walk10); ai_walk(this, 13); }
void legond_walk8(entity this) { set_anim(this, 18, legond_walk9); ai_walk(this, 15); }
void legond_walk7(entity this) { set_anim(this, 17, legond_walk8); ai_walk(this, 13); }
void legond_walk6(entity this) { set_anim(this, 16, legond_walk7); ai_walk(this, 14); }
void legond_walk5(entity this) { set_anim(this, 15, legond_walk6); ai_walk(this, 16); }
void legond_walk4(entity this) { set_anim(this, 14, legond_walk5); ai_walk(this, 15); }
void legond_walk3(entity this) { set_anim(this, 13, legond_walk4); ai_walk(this, 13); }
void legond_walk2(entity this) { set_anim(this, 12, legond_walk3); ai_walk(this, 14); }
void legond_walk1(entity this)
{
	set_anim(this, 11, legond_walk1);
	float r = random();
	if(r < 0.3)
		_sound(this, CHAN_BODY, "monsters/legond/lidle.wav", 1, ATTN_NORM);
	ai_walk(this, 16);
}

void legond_run1(entity this);
void legond_run12(entity this) { set_anim(this, 38, legond_run1); ai_run(this, 23); }
void legond_run11(entity this) { set_anim(this, 37, legond_run12); ai_run(this, 15); }
void legond_run10(entity this) { set_anim(this, 36, legond_run11); ai_run(this, 19); }
void legond_run9(entity this) { set_anim(this, 35, legond_run10); ai_run(this, 18); }
void legond_run8(entity this) { set_anim(this, 34, legond_run9); ai_run(this, 17); }
void legond_run7(entity this) { set_anim(this, 33, legond_run8); ai_run(this, 16); }
void legond_run6(entity this) { set_anim(this, 32, legond_run7); ai_run(this, 15); }
void legond_run5(entity this) { set_anim(this, 31, legond_run6); ai_run(this, 17); }
void legond_run4(entity this) { set_anim(this, 30, legond_run5); ai_run(this, 18); }
void legond_run3(entity this) { set_anim(this, 29, legond_run4); ai_run(this, 16); }
void legond_run2(entity this) { set_anim(this, 28, legond_run3); ai_run(this, 17); }
void legond_run1(entity this)
{
	set_anim(this, 27, legond_run2);
	float r = random();
	if(r < 0.3)
		_sound(this, CHAN_BODY, "monsters/legond/lidle.wav", 1, ATTN_NORM);
	ai_run(this, 18);
}

void Legond_MissileTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;
	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	float damg = (80 + (random() * 20));
	if(toucher.health)
	{
		if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MON_FLAG_EXPLOSIONRESISTANT))
			damg = damg * 0.5;
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
		this.health = this.health + damg;
	}
	if(autocvar_skill == 3)
		T_RadiusDamage(this, this.owner, 100, this.projectiledeathtype, toucher);
	if(autocvar_skill == 2)
		T_RadiusDamage(this, this.owner, 90, this.projectiledeathtype, toucher);
	if(autocvar_skill == 1)
		T_RadiusDamage(this, this.owner, 80, this.projectiledeathtype, toucher);
	else
		T_RadiusDamage(this, this.owner, 70, this.projectiledeathtype, toucher);
	this.origin = this.origin - (8 * normalize(this.velocity));
	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);
	BecomeExplosion(this);
}

void LaunchRocket(entity this, vector org, vector vec)
{
	ai_face(this);
	this.attack_finished = time + 0.8;
	entity newmis = spawn();
	newmis.owner = this;
	newmis.projectiledeathtype = DEATH_MONSTER_LEGOND.m_id;
	set_movetype(newmis, MOVETYPE_FLY);
	newmis.solid = SOLID_BBOX;
	_setmodel(newmis, "progs/missile2.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, org);
	newmis.velocity = normalize(vec) * 700;
	newmis.angles = vectoangles(newmis.velocity);
	newmis.nextthink = (time + 5);
	setthink(newmis, SUB_Remove);
	settouch(newmis, Legond_MissileTouch);
}

void LegondFireRocket(entity this)
{
	this.effects |= EF_MUZZLEFLASH;
	makevectors(this.angles);
	vector org = ((((this.origin + (v_forward * 8)) + (v_right * 12)) + (v_up * 12)) + '0 0 16');
	_sound(this, CHAN_WEAPON, "monsters/legond/lshot.wav", 1, ATTN_NORM);
	LaunchRocket(this, org, ((this.enemy.origin - this.origin) - ((v_up * random()) * 80)));
}

void LegondFireRocketB(entity this)
{
	this.effects |= EF_MUZZLEFLASH;
	makevectors(this.angles);
	vector org = ((((this.origin + (v_forward * 8)) - (v_right * 12)) + (v_up * 12)) + '0 0 16');
	vector org2 = ((((this.origin + (v_forward * 8)) + (v_right * 12)) + (v_up * 12)) + '0 0 16');
	float r = random() * 80;
	_sound(this, CHAN_WEAPON, "monsters/legond/lshot.wav", 1, ATTN_NORM);
	LaunchRocket(this, org, ((this.enemy.origin - this.origin) - (v_up * r)));
	_sound(this, CHAN_WEAPON, "monsters/legond/lshot.wav", 1, ATTN_NORM);
	LaunchRocket(this, org2, ((this.enemy.origin - this.origin) - (v_up * r)));
}

void legond_shoot12(entity this) { set_anim(this, 73, legond_run1); ai_face(this); }
void legond_shoot11(entity this) { set_anim(this, 72, legond_shoot12); ai_face(this); }
void legond_shoot10(entity this) { set_anim(this, 71, legond_shoot11); ai_face(this); }
void legond_shoot9(entity this) { set_anim(this, 70, legond_shoot10); ai_face(this); }
void legond_shoot8(entity this) { set_anim(this, 69, legond_shoot9); ai_face(this); LegondFireRocket(this); }
void legond_shoot7(entity this) { set_anim(this, 68, legond_shoot8); ai_face(this); }
void legond_shoot6(entity this) { set_anim(this, 67, legond_shoot7); ai_face(this); }
void legond_shoot5(entity this) { set_anim(this, 66, legond_shoot6); ai_face(this); }
void legond_shoot4(entity this) { set_anim(this, 65, legond_shoot5); ai_face(this); }
void legond_shoot3(entity this) { set_anim(this, 64, legond_shoot4); ai_face(this); }
void legond_shoot2(entity this) { set_anim(this, 63, legond_shoot3); ai_face(this); }
void legond_shoot1(entity this) { set_anim(this, 62, legond_shoot2); ai_face(this); }

void legond_shootb14(entity this) { set_anim(this, 87, legond_run1); ai_face(this); }
void legond_shootb13(entity this) { set_anim(this, 86, legond_shootb14); ai_face(this); }
void legond_shootb12(entity this) { set_anim(this, 85, legond_shootb13); ai_face(this); }
void legond_shootb11(entity this) { set_anim(this, 84, legond_shootb12); ai_face(this); }
void legond_shootb10(entity this) { set_anim(this, 83, legond_shootb11); ai_face(this); LegondFireRocketB(this); }
void legond_shootb9(entity this) { set_anim(this, 82, legond_shootb10); ai_face(this); }
void legond_shootb8(entity this) { set_anim(this, 81, legond_shootb9); ai_face(this); }
void legond_shootb7(entity this) { set_anim(this, 80, legond_shootb8); ai_face(this); }
void legond_shootb6(entity this) { set_anim(this, 79, legond_shootb7); ai_face(this); }
void legond_shootb5(entity this) { set_anim(this, 78, legond_shootb6); ai_face(this); }
void legond_shootb4(entity this) { set_anim(this, 77, legond_shootb5); ai_face(this); }
void legond_shootb3(entity this) { set_anim(this, 76, legond_shootb4); ai_face(this); }
void legond_shootb2(entity this) { set_anim(this, 75, legond_shootb3); ai_face(this); }
void legond_shootb1(entity this) { set_anim(this, 74, legond_shootb2); ai_face(this); }

void Legond_FireLightning(entity this)
{
	this.effects |= EF_MUZZLEFLASH;
	ai_face(this);
	_sound(this, CHAN_ITEM, "monsters/legond/lpull.wav", 1, ATTN_NORM);
	vector org = ((this.origin + '0 0 12') - (v_right * 8));
	vector dir = normalize((this.enemy.origin + '0 0 16') - org);
	traceline(org, (this.origin + (dir * 600)), true, this);
	te_lightning2(NULL, org, trace_endpos); // should be this
	LightningDamage(org, (trace_endpos + (v_forward * 4)), this, 4, DEATH_MONSTER_LEGOND.m_id);
	this.health = this.health + 3;
	this.enemy.velocity = '0 0 150' + (v_forward * 400);
	UNSET_ONGROUND(this);
}
void legond_light13(entity this) { set_anim(this, 39, legond_run1); ai_face(this); }
void legond_light12(entity this) { set_anim(this, 40, legond_light13); ai_face(this); }
void legond_light11(entity this) { set_anim(this, 41, legond_light12); ai_face(this); }
void legond_light10(entity this) { set_anim(this, 42, legond_light11); ai_face(this); }
void legond_light9(entity this) { set_anim(this, 43, legond_light10); ai_face(this); }
void legond_light8(entity this) { set_anim(this, 44, legond_light9); ai_face(this); }
void legond_light7(entity this) { set_anim(this, 45, legond_light8);ai_face(this); Legond_FireLightning(this); }
void legond_light6(entity this) { set_anim(this, 45, legond_light7); ai_face(this); Legond_FireLightning(this); }
void legond_light5(entity this) { set_anim(this, 45, legond_light6); ai_face(this); Legond_FireLightning(this); }
void legond_light4(entity this) { set_anim(this, 46, legond_light5); ai_face(this); }
void legond_light3(entity this) { set_anim(this, 47, legond_light4); ai_face(this); }
void legond_light2(entity this) { set_anim(this, 48, legond_light3); ai_face(this); }
void legond_light1(entity this) { set_anim(this, 49, legond_light2); ai_face(this); }

void Legond_Punch(entity this)
{
	if(!this.enemy)
		return;
	_sound(this, CHAN_BODY, "monsters/legond/lswipe.wav", 1, ATTN_NORM);
	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;
	float ldmg = random() + random() + random() * 9;
	_sound(this, CHAN_WEAPON, "monsters/legond/legsmak.wav", 1, ATTN_NORM);
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_LEGOND.m_id);
	this.health = this.health + ldmg;
	SpawnMeatSpray(this, this.origin + (v_forward * 16), (crandom() * 100) * v_right);
	SpawnMeatSpray(this, this.origin + (v_forward * 16), (crandom() * 100) * v_right);
	this.enemy.velocity = '0 0 150' + (v_forward * 350);
	UNSET_ONGROUND(this);
}

void legond_punch11(entity this) { set_anim(this, 49, legond_run1); ai_charge(this, 12); }
void legond_punch10(entity this) { set_anim(this, 48, legond_punch11); ai_charge(this, 10); }
void legond_punch9(entity this) { set_anim(this, 47, legond_punch10); ai_charge(this, 11); }
void legond_punch8(entity this) { set_anim(this, 46, legond_punch9); ai_charge(this, 9); }
void legond_punch7(entity this) { set_anim(this, 45, legond_punch8); ai_charge(this, 8); }
void legond_punch6(entity this) { set_anim(this, 44, legond_punch7); ai_charge(this, 12); }
void legond_punch5(entity this) { set_anim(this, 43, legond_punch6); ai_charge(this, 10); Legond_Punch(this); }
void legond_punch4(entity this) { set_anim(this, 42, legond_punch5); ai_charge(this, 11); Legond_Punch(this); }
void legond_punch3(entity this) { set_anim(this, 41, legond_punch4); ai_charge(this, 9); }
void legond_punch2(entity this) { set_anim(this, 40, legond_punch3); ai_charge(this, 8); }
void legond_punch1(entity this) { set_anim(this, 39, legond_punch2); ai_charge(this, 12); }

void Legond_SoftPunch(entity this)
{
	if(!this.enemy)
		return;
	_sound(this, CHAN_BODY, "monsters/legond/lswipe.wav", 1, ATTN_NORM);
	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;
	float ldmg = random() + random() + random() * 3; // lol what
	_sound(this, CHAN_WEAPON, "monsters/legond/legsmak.wav", 1, ATTN_NORM);
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_LEGOND.m_id);
	this.health = this.health + ldmg;
	SpawnMeatSpray(this, this.origin + v_forward * 16, (crandom() * 100) * v_right);
}

void legond_combo30(entity this) { set_anim(this, 39, legond_run1); ai_face(this); }
void legond_combo29(entity this) { set_anim(this, 41, legond_combo30); ai_face(this); }
void legond_combo28(entity this) { set_anim(this, 43, legond_combo29); ai_face(this); Legond_FireLightning(this); }
void legond_combo27(entity this) { set_anim(this, 45, legond_combo28); ai_face(this); Legond_FireLightning(this); }
void legond_combo26(entity this) { set_anim(this, 47, legond_combo27); ai_face(this); Legond_FireLightning(this); }
void legond_combo25(entity this) { set_anim(this, 49, legond_combo26); ai_face(this); }
void legond_combo24(entity this) { set_anim(this, 72, legond_combo25); ai_face(this); }
void legond_combo23(entity this) { set_anim(this, 70, legond_combo24); ai_face(this); }
void legond_combo22(entity this) { set_anim(this, 68, legond_combo23); ai_face(this); LegondFireRocket(this); }
void legond_combo21(entity this) { set_anim(this, 66, legond_combo22); ai_face(this); }
void legond_combo20(entity this) { set_anim(this, 64, legond_combo21); ai_face(this); }
void legond_combo19(entity this) { set_anim(this, 62, legond_combo20); ai_face(this); }
void legond_combo18(entity this) { set_anim(this, 60, legond_combo19); ai_charge(this, 12); }
void legond_combo17(entity this) { set_anim(this, 58, legond_combo18); ai_charge(this, 10); }
void legond_combo16(entity this) { set_anim(this, 56, legond_combo17); ai_charge(this, 11); }
void legond_combo15(entity this) { set_anim(this, 54, legond_combo16); ai_charge(this, 9); Legond_Punch(this); }
void legond_combo14(entity this) { set_anim(this, 52, legond_combo15); ai_charge(this, 8); }
void legond_combo13(entity this) { set_anim(this, 50, legond_combo14); ai_charge(this, 12); }
void legond_combo12(entity this) { set_anim(this, 49, legond_combo13); ai_charge(this, 12); }
void legond_combo11(entity this) { set_anim(this, 46, legond_combo12); ai_charge(this, 10); Legond_SoftPunch(this); }
void legond_combo10(entity this) { set_anim(this, 45, legond_combo11); ai_charge(this, 11); Legond_SoftPunch(this); }
void legond_combo9(entity this) { set_anim(this, 43, legond_combo10); ai_charge(this, 9); }
void legond_combo8(entity this) { set_anim(this, 41, legond_combo9); ai_charge(this, 8); }
void legond_combo7(entity this) { set_anim(this, 39, legond_combo8); ai_charge(this, 12); }
void legond_combo6(entity this) { set_anim(this, 49, legond_combo7); ai_charge(this, 12); }
void legond_combo5(entity this) { set_anim(this, 46, legond_combo6); ai_charge(this, 10); Legond_SoftPunch(this); }
void legond_combo4(entity this) { set_anim(this, 45, legond_combo5); ai_charge(this, 11); Legond_SoftPunch(this); }
void legond_combo3(entity this) { set_anim(this, 43, legond_combo4); ai_charge(this, 9); }
void legond_combo2(entity this) { set_anim(this, 41, legond_combo3); ai_charge(this, 8); }
void legond_combo1(entity this) { set_anim(this, 39, legond_combo2); ai_charge(this, 12); }

void legond_combob23(entity this) { set_anim(this, 58, legond_run1); ai_charge(this, 11); }
void legond_combob22(entity this) { set_anim(this, 57, legond_combob23); ai_charge(this, 8); Legond_Punch(this); }
void legond_combob21(entity this) { set_anim(this, 56, legond_combob22); ai_charge(this, 10); }
void legond_combob20(entity this) { set_anim(this, 57, legond_combob21); ai_charge(this, 12); }
void legond_combob19(entity this) { set_anim(this, 58, legond_combob20); ai_charge(this, 11); }
void legond_combob18(entity this) { set_anim(this, 56, legond_combob19); ai_charge(this, 8); Legond_SoftPunch(this); }
void legond_combob17(entity this) { set_anim(this, 54, legond_combob18); ai_charge(this, 10); }
void legond_combob16(entity this) { set_anim(this, 52, legond_combob17); ai_charge(this, 9); }
void legond_combob15(entity this) { set_anim(this, 50, legond_combob16); ai_charge(this, 12); }
void legond_combob14(entity this) { set_anim(this, 39, legond_combob15); ai_face(this); }
void legond_combob13(entity this) { set_anim(this, 41, legond_combob14); ai_face(this); }
void legond_combob12(entity this) { set_anim(this, 43, legond_combob13); ai_face(this); Legond_FireLightning(this); }
void legond_combob11(entity this) { set_anim(this, 45, legond_combob12); ai_face(this); Legond_FireLightning(this); }
void legond_combob10(entity this) { set_anim(this, 47, legond_combob11); ai_face(this); Legond_FireLightning(this); }
void legond_combob9(entity this) { set_anim(this, 49, legond_combob10); ai_face(this); }
void legond_combob8(entity this) { set_anim(this, 87, legond_combob9); ai_face(this); }
void legond_combob7(entity this) { set_anim(this, 85, legond_combob8); ai_face(this); }
void legond_combob6(entity this) { set_anim(this, 83, legond_combob7); ai_face(this); LegondFireRocketB(this); }
void legond_combob5(entity this) { set_anim(this, 82, legond_combob6); ai_face(this); }
void legond_combob4(entity this) { set_anim(this, 80, legond_combob5); ai_face(this); }
void legond_combob3(entity this) { set_anim(this, 78, legond_combob4); ai_face(this); }
void legond_combob2(entity this) { set_anim(this, 76, legond_combob3); ai_face(this); }
void legond_combob1(entity this) { set_anim(this, 74, legond_combob2); ai_face(this); }

void legond_kick12(entity this) { set_anim(this, 61, legond_run1); ai_charge(this, 12); }
void legond_kick11(entity this) { set_anim(this, 60, legond_kick12); ai_charge(this, 8); }
void legond_kick10(entity this) { set_anim(this, 59, legond_kick11); ai_charge(this, 10); }
void legond_kick9(entity this) { set_anim(this, 58, legond_kick10); ai_charge(this, 11); }
void legond_kick8(entity this)
{
	set_anim(this, 57, legond_kick9);
	ai_charge(this, 9);
	Legond_Punch(this);
}
void legond_kick7(entity this)
{
	set_anim(this, 56, legond_kick8);
	ai_charge(this, 8);
	Legond_Punch(this);
}
void legond_kick6(entity this)
{
	set_anim(this, 55, legond_kick7);
	ai_charge(this, 12);
	Legond_Punch(this);
}
void legond_kick5(entity this) { set_anim(this, 54, legond_kick6); ai_charge(this, 10); }
void legond_kick4(entity this) { set_anim(this, 53, legond_kick5); ai_charge(this, 11); }
void legond_kick3(entity this) { set_anim(this, 52, legond_kick4); ai_charge(this, 9); }
void legond_kick2(entity this) { set_anim(this, 51, legond_kick3); ai_charge(this, 8); }
void legond_kick1(entity this) { set_anim(this, 50, legond_kick2); ai_charge(this, 12); }

void Legond_Melee(entity this)
{
	if(random() < 0.4)
		legond_punch1(this);
	else if(random() > 0.7)
		legond_kick1(this);
	else
		legond_combo1(this);
}

void Legond_Des_return(entity this)
{
	this.cnt = 0;
}

spawnfunc(legond_teledes)
{
	if(!MP_IMPEL) { delete(this); return; }

	this.solid = SOLID_BBOX;
	setmodel(this, MDL_Null);
	set_movetype(this, MOVETYPE_FLY);
	this.velocity = '0 0 0';
	setsize(this, '0 0 0', '0 0 0');
	this.cnt = 1;
	this.nextthink = time + (random() * 20);
	setthink(this, Legond_Des_return);
}

void Legond_Teleport(entity this)
{
	FOREACH_ENTITY_RADIUS(this.origin, 500, it.classname == "legond_teledes" && it.cnt == 0 && (random() < 0.3),
	{
		te_teleport(this.origin);
		te_teleport(it.origin);
		setorigin(this, it.origin);
		float v = random() * 5;
		string tmpstr;
		if(v < 1)
			tmpstr = "misc/r_tele1.wav";
		else if(v < 2)
			tmpstr = "misc/r_tele2.wav";
		else if(v < 3)
			tmpstr = "misc/r_tele3.wav";
		else if(v < 4)
			tmpstr = "misc/r_tele4.wav";
		else
			tmpstr = "misc/r_tele5.wav";
		_sound(this, CHAN_ITEM, tmpstr, 1, ATTN_NORM);
		_sound(this, CHAN_AUTO, "monsters/legond/legond.wav", 1, ATTN_NORM);
		it.cnt = 1;
		it.nextthink = time + (random() * 20);
		setthink(it, Legond_Des_return);
		break;
	});
}

void legond_pain11(entity this) { set_anim(this, 88, legond_run1); Legond_Teleport(this); }
void legond_pain10(entity this) { set_anim(this, 89, legond_pain11); ai_painforward(this, 0); }
void legond_pain9(entity this) { set_anim(this, 90, legond_pain10); ai_painforward(this, 5); }
void legond_pain8(entity this) { set_anim(this, 91, legond_pain9); ai_painforward(this, 5); }
void legond_pain7(entity this) { set_anim(this, 92, legond_pain8); ai_painforward(this, 2); }
void legond_pain6(entity this) { set_anim(this, 93, legond_pain7); ai_painforward(this, 4); }
void legond_pain5(entity this) { set_anim(this, 92, legond_pain6); ai_painforward(this, 2); }
void legond_pain4(entity this) { set_anim(this, 91, legond_pain5); }
void legond_pain3(entity this) { set_anim(this, 90, legond_pain4); }
void legond_pain2(entity this) { set_anim(this, 89, legond_pain3); ai_painforward(this, 3); }
void legond_pain1(entity this) { set_anim(this, 88, legond_pain2); ai_painforward(this, 0); }

void Legond_Pain(entity this, entity attacker, float damage, int deathtype)
{
	if((random() * 275) > damage)
		return;
	if(this.health <= 0)
		return;
	if(this.pain_finished > time)
		return;
	if(random() <= 0.5)
		_sound(this, CHAN_VOICE, "monsters/legond/lpain1.wav", 1, ATTN_NORM);
	else
		_sound(this, CHAN_VOICE, "monsters/legond/lpain2.wav", 1, ATTN_NORM);
	this.pain_finished = time + 5;
	legond_pain1(this);
}

void legond_die24(entity this) { set_anim(this, 109, legond_die24); CorpseThink(this); }
void legond_die23(entity this) { set_anim(this, 109, legond_die24); if(coop != 2 || world.model == "maps/aopend.bsp") NextLevel(); }
void legond_die22(entity this) { set_anim(this, 109, legond_die23); }
void legond_die21(entity this) { set_anim(this, 109, legond_die22); }
void legond_die20(entity this) { set_anim(this, 109, legond_die21); }
void legond_die19(entity this) { set_anim(this, 109, legond_die20); }
void legond_die18(entity this) { set_anim(this, 109, legond_die19); }
void legond_die17(entity this) { set_anim(this, 109, legond_die18); }
void legond_die16(entity this) { set_anim(this, 109, legond_die17); }
void legond_die15(entity this) { set_anim(this, 108, legond_die16); }
void legond_die14(entity this) { set_anim(this, 107, legond_die15); }
void legond_die13(entity this) { set_anim(this, 106, legond_die14); }
void legond_die12(entity this) { set_anim(this, 105, legond_die13); }
void legond_die11(entity this) { set_anim(this, 104, legond_die12); }
void legond_die10(entity this) { set_anim(this, 103, legond_die11); }
void legond_die9(entity this) { set_anim(this, 102, legond_die10); }
void legond_die8(entity this) { set_anim(this, 101, legond_die9); }
void legond_die7(entity this) { set_anim(this, 100, legond_die8); }
void legond_die6(entity this) { set_anim(this, 99, legond_die7); }
void legond_die5(entity this)
{
	set_anim(this, 98, legond_die6);
	_sound(this, CHAN_AUTO, "monsters/legond/ldeath.wav", 1, ATTN_NORM);
}
void legond_die4(entity this) { set_anim(this, 97, legond_die5); this.solid = SOLID_NOT; }
void legond_die3(entity this) { set_anim(this, 96, legond_die4); }
void legond_die2(entity this) { set_anim(this, 95, legond_die3); }
void legond_die1(entity this, entity inflictor, entity attacker, int deathtype)
{
	set_anim(this, 94, legond_die2);
	_sound(this, CHAN_AUTO, "monsters/legond/lpain2.wav", 1, ATTN_NORM);
}

spawnfunc(monster_legond)
{
	if(!MP_IMPEL) { delete(this); return; }
	monster_start(this, MON_LEGOND);
}
#endif // SVQC

#ifdef SVQC
METHOD(Legond, mr_setup, bool(Legond this, entity actor))
{
    TC(Legond, this);

	precache_model("progs/missile2.mdl");
	precache_sound("monsters/legond/legsmak.wav");
	precache_sound("monsters/legond/lpain1.wav");
	precache_sound("monsters/legond/lpain2.wav");
	precache_sound("monsters/legond/lshot.wav");
	precache_sound("monsters/legond/lpull.wav");
	precache_sound("monsters/legond/ldeath.wav");
	precache_sound("monsters/legond/lswipe.wav");
	precache_sound("monsters/legond/lidle.wav");

    actor.health = 3000;
	actor.th_stand = legond_stand1;
	actor.th_walk = legond_walk1;
	actor.th_run = legond_run1;
	actor.th_melee = Legond_Melee;
	actor.th_pain = Legond_Pain;
	actor.th_die = legond_die1;
	actor.th_missile = legond_shoot1;

	actor.checkattack = LegondCheckAttack;

    return true;
}
#endif
