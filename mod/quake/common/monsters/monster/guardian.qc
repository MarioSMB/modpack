#include "guardian.qh"

#ifdef SVQC
const int anim_morph_mfstand1 = 0; 
const int anim_morph_start01 = 1;
const int anim_morph_mfrun01 = 32;
const int anim_morph_mfwlk01 = 43;
const int anim_morph_mfata01 = 56;
const int anim_morph_mfatb01 = 65;
const int anim_morph_mfatc01 = 76;
const int anim_morph_mfknck01 = 92;
const int anim_morph_mfpain01 = 104;
const int anim_morph_mfpbin01 = 114;
const int anim_morph_mfdth01 = 121;

const int MORPH_AZTEC = BIT(1);
const int MORPH_EGYPT = BIT(2);
const int MORPH_GREEK = BIT(3);

.float childrenSpawned;

void morph_teleport(entity this);

// ========================
// standing
// ========================
void morph_stand1(entity this) { set_animofs(this, anim_morph_mfstand1, 1, morph_stand1); ai_stand(this); }

// ========================
// movement
// ========================
// 3 2 1 1 0 1 2 3 4 5 4 2 1 0
// 3 2 1 2 3 4 4 3 2 1 2 3 3 
// 2 4 4 4 3 3 2 2 4 4 3 2 1
// 4 5 5 4 3 2 2 4 5 4 3 2 2
void morph_walk1(entity this);
 // 1
void morph_walk13(entity this) { set_animofs(this, anim_morph_mfwlk01, 13, morph_walk1); ai_walk(this, 3); }
void morph_walk12(entity this) { set_animofs(this, anim_morph_mfwlk01, 12, morph_walk13); ai_walk(this, 4); }
void morph_walk11(entity this) { set_animofs(this, anim_morph_mfwlk01, 11, morph_walk12); ai_walk(this, 5); }
void morph_walk10(entity this) { set_animofs(this, anim_morph_mfwlk01, 10, morph_walk11); ai_walk(this, 5); }
void morph_walk9(entity this) { set_animofs(this, anim_morph_mfwlk01, 9, morph_walk10); ai_walk(this, 4); }
void morph_walk8(entity this) { set_animofs(this, anim_morph_mfwlk01, 8, morph_walk9); ai_walk(this, 3); }
 //1 
void morph_walk7(entity this) { set_animofs(this, anim_morph_mfwlk01, 7, morph_walk8); ai_walk(this, 2); }
 //1
void morph_walk6(entity this) { set_animofs(this, anim_morph_mfwlk01, 6, morph_walk7); ai_walk(this, 4); }
void morph_walk5(entity this) { set_animofs(this, anim_morph_mfwlk01, 5, morph_walk6); ai_walk(this, 5); }
void morph_walk4(entity this) { set_animofs(this, anim_morph_mfwlk01, 4, morph_walk5); ai_walk(this, 5); }
void morph_walk3(entity this) { set_animofs(this, anim_morph_mfwlk01, 3, morph_walk4); ai_walk(this, 4); }
void morph_walk2(entity this) { set_animofs(this, anim_morph_mfwlk01, 2, morph_walk3); ai_walk(this, 2); }
void morph_walk1(entity this) { set_animofs(this, anim_morph_mfwlk01, 1, morph_walk2); ai_walk(this, 3); }

// 8 6 4 10 13 13 11 10
// 11 15 10 10 8 15 10 8 8 8 8
// 6 9 13 13 9 6 9 13 15 13 9
void morph_run1(entity this);
	// 43
void morph_run11(entity this) { set_animofs(this, anim_morph_mfrun01, 11, morph_run1); ai_run(this, 11); }
		
void morph_run10(entity this) { set_animofs(this, anim_morph_mfrun01, 10, morph_run11); ai_run(this, 15); }
		
void morph_run9(entity this) { set_animofs(this, anim_morph_mfrun01, 9, morph_run10); ai_run(this, 19); }
	// 40
void morph_run8(entity this) { set_animofs(this, anim_morph_mfrun01, 8, morph_run9); ai_run(this, 15); }
void morph_run7(entity this) { set_animofs(this, anim_morph_mfrun01, 7, morph_run8); ai_run(this, 11); }
	// 38
void morph_run6(entity this) { set_animofs(this, anim_morph_mfrun01, 6, morph_run7); ai_run(this, 7); }
void morph_run5(entity this) { set_animofs(this, anim_morph_mfrun01, 5, morph_run6); ai_run(this, 11); }
	// 36
void morph_run4(entity this) { set_animofs(this, anim_morph_mfrun01, 4, morph_run5); ai_run(this, 16); }
void morph_run3(entity this) { set_animofs(this, anim_morph_mfrun01, 3, morph_run4); ai_run(this, 16); }
void morph_run2(entity this) { set_animofs(this, anim_morph_mfrun01, 2, morph_run3); ai_run(this, 11); }
	// 33
void morph_run1(entity this)
{
	set_animofs(this, anim_morph_mfrun01, 1, morph_run2);
	if(this.skin == 2) // canceled out of setup
	{
		this.solid = SOLID_SLIDEBOX;
		this.takedamage = DAMAGE_AIM;		
		this.skin = 0;
	}
	ai_run(this, 7);
}

// ========================
// new attack code
// ========================
void morph_stab2(entity this)
{
	if(!this.enemy)
		return;
	if(!CanDamage(this.enemy, this))
		return;

	ai_face(this);

	vector dir = this.enemy.origin - this.origin + this.enemy.view_ofs;
	vector dist = dir; // prenormalization
	dir = normalize(dir);
	makevectors(this.angles);

	if(vdist(dist, <=, 90))
	{
		_sound(this, CH_WEAPON_SINGLE, "enforcer/enfstop.wav", 1, ATTN_STATIC);
		float attackDamage = (random() * 10) + 20;
		T_Damage(this.enemy, this, this, attackDamage, DEATH_MONSTER_GUARDIAN.m_id);
		SpawnBlood(this.enemy.origin, v_forward * 150, 14, this.enemy);
	}
	else
	{
		this.effects |= EF_MUZZLEFLASH;
		vector org = this.origin + v_forward * 80 + v_right * 4 + '0 0 4';
		LaunchLaser(this, org, dir);
		if(vdist(dist, >, 0))
		{
			LaunchLaser(this, org, (dir + v_right * 0.04));
			LaunchLaser(this, org, (dir - v_right * 0.04));
		}
		else
		{
			LaunchLaser(this, org, (dir + v_right * 0.10));
			LaunchLaser(this, org, (dir - v_right * 0.10));	
		}
	}	
}

// ========================
// hand to hand attack
// ========================

void morph_attack12(entity this) { set_animofs(this, anim_morph_mfatb01, 1, morph_run1); ai_face(this); }
void morph_attack11(entity this) { set_animofs(this, anim_morph_mfatb01, 11, morph_attack12); ai_face(this); }
void morph_attack10(entity this) { set_animofs(this, anim_morph_mfatb01, 10, morph_attack11); ai_face(this); }
void morph_attack09(entity this) { set_animofs(this, anim_morph_mfatb01, 9, morph_attack10); ai_face(this); }
void morph_attack08(entity this) { set_animofs(this, anim_morph_mfatb01, 8, morph_attack09); ai_face(this); }
void morph_attack07(entity this) { set_animofs(this, anim_morph_mfatb01, 7, morph_attack08); morph_stab2(this); }
void morph_attack06(entity this) { set_animofs(this, anim_morph_mfatb01, 6, morph_attack07); ai_face(this); }
void morph_attack05(entity this) { set_animofs(this, anim_morph_mfatb01, 5, morph_attack06); ai_face(this); }
void morph_attack04(entity this) { set_animofs(this, anim_morph_mfatb01, 4, morph_attack05); ai_face(this); }
void morph_attack03(entity this) { set_animofs(this, anim_morph_mfatb01, 3, morph_attack04); ai_face(this); }
void morph_attack02(entity this) { set_animofs(this, anim_morph_mfatb01, 2, morph_attack03); ai_face(this); }
void morph_attack01(entity this) { set_animofs(this, anim_morph_mfatb01, 1, morph_attack02); ai_face(this); }

void morph_bigattack17(entity this) { set_animofs(this, anim_morph_mfatc01, 1, morph_run1); ai_face(this); }
void morph_bigattack16(entity this) { set_animofs(this, anim_morph_mfatc01, 16, morph_bigattack17); ai_face(this); }
void morph_bigattack15(entity this) { set_animofs(this, anim_morph_mfatc01, 15, morph_bigattack16); ai_face(this); }
void morph_bigattack14(entity this) { set_animofs(this, anim_morph_mfatc01, 14, morph_bigattack15); ai_face(this); }
void morph_bigattack13(entity this) { set_animofs(this, anim_morph_mfatc01, 13, morph_bigattack14); ai_face(this); }
void morph_bigattack12(entity this) { set_animofs(this, anim_morph_mfatc01, 12, morph_bigattack13); ai_face(this); }
void morph_bigattack11(entity this) { set_animofs(this, anim_morph_mfatc01, 11, morph_bigattack12); ai_face(this); }
void morph_bigattack10(entity this) { set_animofs(this, anim_morph_mfatc01, 10, morph_bigattack11); morph_stab2(this); }
void morph_bigattack09(entity this) { set_animofs(this, anim_morph_mfatc01, 9, morph_bigattack10); ai_face(this); }
void morph_bigattack08(entity this) { set_animofs(this, anim_morph_mfatc01, 8, morph_bigattack09); ai_face(this); }
void morph_bigattack07(entity this) { set_animofs(this, anim_morph_mfatc01, 7, morph_bigattack08); ai_face(this); }
void morph_bigattack06(entity this) { set_animofs(this, anim_morph_mfatc01, 6, morph_bigattack07); ai_face(this); }
void morph_bigattack05(entity this) { set_animofs(this, anim_morph_mfatc01, 5, morph_bigattack06); ai_face(this); }
void morph_bigattack04(entity this) { set_animofs(this, anim_morph_mfatc01, 4, morph_bigattack05); ai_face(this); }
void morph_bigattack03(entity this) { set_animofs(this, anim_morph_mfatc01, 3, morph_bigattack04); ai_face(this); }
void morph_bigattack02(entity this) { set_animofs(this, anim_morph_mfatc01, 2, morph_bigattack03); ai_face(this); }
void morph_bigattack01(entity this) { set_animofs(this, anim_morph_mfatc01, 1, morph_bigattack02); ai_face(this); }

void morph_smack(entity this)
{
	if(!this.enemy)
		return;
	if(!CanDamage(this.enemy, this))
		return;

	ai_face(this);

	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
		
	float ldmg = (random() * 10) + 10;
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_GUARDIAN.m_id);
	
	makevectors(this.angles);
	this.enemy.velocity = v_forward * 100 + '0 0 100';
}

void morph_knockback12(entity this) { set_animofs(this, anim_morph_mfknck01, 12, morph_run1); ai_face(this); }
void morph_knockback11(entity this) { set_animofs(this, anim_morph_mfknck01, 11, morph_knockback12); ai_face(this); }
void morph_knockback10(entity this) { set_animofs(this, anim_morph_mfknck01, 10, morph_knockback11); ai_face(this); }
void morph_knockback09(entity this) { set_animofs(this, anim_morph_mfknck01, 9, morph_knockback10); morph_smack(this); }
void morph_knockback08(entity this) { set_animofs(this, anim_morph_mfknck01, 8, morph_knockback09); ai_face(this); }
void morph_knockback07(entity this) { set_animofs(this, anim_morph_mfknck01, 7, morph_knockback08); ai_face(this); }
void morph_knockback06(entity this) { set_animofs(this, anim_morph_mfknck01, 6, morph_knockback07); ai_face(this); }
void morph_knockback05(entity this) { set_animofs(this, anim_morph_mfknck01, 5, morph_knockback06); ai_face(this); }
void morph_knockback04(entity this) { set_animofs(this, anim_morph_mfknck01, 4, morph_knockback05); ai_face(this); }
void morph_knockback03(entity this) { set_animofs(this, anim_morph_mfknck01, 3, morph_knockback04); ai_face(this); }
void morph_knockback02(entity this) { set_animofs(this, anim_morph_mfknck01, 2, morph_knockback03); ai_face(this); }
void morph_knockback01(entity this) { set_animofs(this, anim_morph_mfknck01, 1, morph_knockback02); ai_face(this); }

void morph_attack(entity this)
{
	float attackChoice = random();
	
	if(attackChoice < 0.50)
		morph_bigattack01(this);
	else if(attackChoice < 0.75)
		morph_attack01(this);
	else
		morph_knockback01(this);
}

void GuardianLaser_Touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
	if(!(this.spawnflags & SPAWNFLAG_SILENT))
		_sound(this, CH_WEAPON_SINGLE, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	vector org = this.origin - 8*normalize(this.velocity);

	if(toucher.health)
	{
		SpawnBlood(org, this.velocity*0.2, 15, toucher);
		T_Damage(toucher, this, this.owner, 15, this.projectiledeathtype);
	}
	else
		te_gunshot(org);
	
	delete(this);	
}

entity LaunchGuardianLaser(entity this, vector org, vector vec)
{
	vector vec2 = normalize(vec);
	
	entity newmis = new(enforcer_laser);
	newmis.flags = FL_PROJECTILE;
	newmis.owner = this;
	newmis.realowner = this;
	newmis.projectiledeathtype = DEATH_MONSTER_GUARDIAN.m_id;
	newmis.clipgroup = this.clipgroup;
	set_movetype(newmis, MOVETYPE_FLY);
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;

	_setmodel(newmis, "progs/laser.mdl");
	setsize(newmis, '0 0 0', '0 0 0');		

	if(!this.guardian_owner)
		newmis.skin = 1; // class check doesn't need rogue check

	setorigin(newmis, org);

	newmis.velocity = vec2 * 600;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 5;
	setthink(newmis, SUB_Remove);
	settouch(newmis, GuardianLaser_Touch);

	IL_PUSH(g_projectiles, newmis);

	return newmis;
}

// ========================
// ranged attack
// ========================
void morph_fire(entity this)
{
	ai_face(this);
	
	this.effects |= EF_MUZZLEFLASH;
	
	makevectors(this.angles);
	vector org = this.origin + v_forward * 30 + v_right * 8.5 + '0 0 16';
	vector dir = normalize(this.enemy.origin - this.origin);
	LaunchGuardianLaser(this, org, dir);
	if(vdist(this.enemy.origin - this.origin, >, 400))
	{
		LaunchGuardianLaser(this, org, (dir + v_right * 0.04));
		LaunchGuardianLaser(this, org, (dir - v_right * 0.04));
	}
	else
	{
		LaunchGuardianLaser(this, org, (dir + v_right * 0.10));
		LaunchGuardianLaser(this, org, (dir - v_right * 0.10));	
	}
}

void morph_fire9(entity this) { set_animofs(this, anim_morph_mfata01, 9, morph_run1); ai_face(this); }
void morph_fire8(entity this) { set_animofs(this, anim_morph_mfata01, 8, morph_fire9); ai_face(this); }
void morph_fire7(entity this) { set_animofs(this, anim_morph_mfata01, 7, morph_fire8); ai_face(this); }
void morph_fire6(entity this) { set_animofs(this, anim_morph_mfata01, 6, morph_fire7); ai_face(this); }
void morph_fire5(entity this) { set_animofs(this, anim_morph_mfata01, 5, morph_fire6); ai_face(this); }
void morph_fire4(entity this) { set_animofs(this, anim_morph_mfata01, 4, morph_fire5); morph_fire(this); }
void morph_fire3(entity this) { set_animofs(this, anim_morph_mfata01, 3, morph_fire4); ai_face(this); }
void morph_fire2(entity this) { set_animofs(this, anim_morph_mfata01, 2, morph_fire3); ai_face(this); }
void morph_fire1(entity this) { set_animofs(this, anim_morph_mfata01, 1, morph_fire2); ai_face(this); }

// ========================
// pain
// ========================
void morph_painA10(entity this) { set_animofs(this, anim_morph_mfpain01, 10, morph_run1); morph_teleport(this); }
void morph_painA9(entity this) { set_animofs(this, anim_morph_mfpain01, 9, morph_painA10); }
void morph_painA8(entity this) { set_animofs(this, anim_morph_mfpain01, 8, morph_painA9); }
void morph_painA7(entity this) { set_animofs(this, anim_morph_mfpain01, 7, morph_painA8); }
void morph_painA6(entity this) { set_animofs(this, anim_morph_mfpain01, 6, morph_painA7); }
void morph_painA5(entity this) { set_animofs(this, anim_morph_mfpain01, 5, morph_painA6); }
void morph_painA4(entity this) { set_animofs(this, anim_morph_mfpain01, 4, morph_painA5); }
void morph_painA3(entity this) { set_animofs(this, anim_morph_mfpain01, 3, morph_painA4); }
void morph_painA2(entity this) { set_animofs(this, anim_morph_mfpain01, 2, morph_painA3); }
void morph_painA1(entity this) { set_animofs(this, anim_morph_mfpain01, 1, morph_painA2); }

void morph_painB7(entity this) { set_animofs(this, anim_morph_mfpbin01, 7, morph_run1); morph_teleport(this); }
void morph_painB6(entity this) { set_animofs(this, anim_morph_mfpbin01, 6, morph_painB7); }
void morph_painB5(entity this) { set_animofs(this, anim_morph_mfpbin01, 5, morph_painB6); }
void morph_painB4(entity this) { set_animofs(this, anim_morph_mfpbin01, 4, morph_painB5); }
void morph_painB3(entity this) { set_animofs(this, anim_morph_mfpbin01, 3, morph_painB4); }
void morph_painB2(entity this) { set_animofs(this, anim_morph_mfpbin01, 2, morph_painB3); }
void morph_painB1(entity this) { set_animofs(this, anim_morph_mfpbin01, 1, morph_painB2); }

void morph_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(autocvar_skill == 3)
	{
		if(random() > 0.5)
			morph_teleport(this);
		return;
	}
	
	if(this.pain_finished > time)
		return;
	if(random() > 0.25)
		return;
	
	float painChoice = random();
	this.pain_finished = time + 2;

	_sound(this, CH_VOICE, "guard/pain1.wav", 1, ATTN_NORM );

	if(painChoice > 0.6)
		setthink(this, morph_painB1);
	else
		setthink(this, morph_painA1);
	
	this.nextthink = time + 0.1;
}

// ========================
// die
// ========================
void morph_die21(entity this) { set_animofs(this, anim_morph_mfdth01, 21, morph_die21); delete(this); }
void morph_die20(entity this) { set_animofs(this, anim_morph_mfdth01, 20, morph_die21); }		// 140
void morph_die19(entity this) { set_animofs(this, anim_morph_mfdth01, 19, morph_die20); }
void morph_die18(entity this) { set_animofs(this, anim_morph_mfdth01, 18, morph_die19); }
void morph_die17(entity this) { set_animofs(this, anim_morph_mfdth01, 17, morph_die18); }
void morph_die16(entity this) { set_animofs(this, anim_morph_mfdth01, 16, morph_die17); }		// 136
void morph_die15(entity this) { set_animofs(this, anim_morph_mfdth01, 15, morph_die16); }
void morph_die14(entity this) { set_animofs(this, anim_morph_mfdth01, 14, morph_die15); }
void morph_die13(entity this) { set_animofs(this, anim_morph_mfdth01, 13, morph_die14); }
void morph_die12(entity this) { set_animofs(this, anim_morph_mfdth01, 12, morph_die13); }		// 132
void morph_die11(entity this) { set_animofs(this, anim_morph_mfdth01, 11, morph_die12); }
void morph_die10(entity this) { set_animofs(this, anim_morph_mfdth01, 10, morph_die11); }
void morph_die9(entity this) { set_animofs(this, anim_morph_mfdth01, 9, morph_die10); this.skin = this.skin + 1; }
void morph_die8(entity this) { set_animofs(this, anim_morph_mfdth01, 8, morph_die9); }		// 129
void morph_die7(entity this) { set_animofs(this, anim_morph_mfdth01, 7, morph_die8); }
void morph_die6(entity this) { set_animofs(this, anim_morph_mfdth01, 6, morph_die7); }
void morph_die5(entity this) { set_animofs(this, anim_morph_mfdth01, 5, morph_die6); }		// 126
void morph_die4(entity this) { set_animofs(this, anim_morph_mfdth01, 4, morph_die5); }
void morph_die3(entity this) { set_animofs(this, anim_morph_mfdth01, 3, morph_die4); }
void morph_die2(entity this) { set_animofs(this, anim_morph_mfdth01, 2, morph_die3); }
void morph_die1(entity this) { set_animofs(this, anim_morph_mfdth01, 1, morph_die2); }		// 122

void morph_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CH_VOICE, "guard/death.wav", 1, ATTN_NORM);
	this.solid = SOLID_NOT;
	setthink(this, morph_die1);
	this.nextthink = time + 0.1;
}


// ========================
// hide in floor
// ========================

void morph_wake31(entity this)
{
	set_animofs(this, anim_morph_start01, 31, morph_stand1);

	this.solid = SOLID_SLIDEBOX;
	this.takedamage = DAMAGE_AIM;		
	this.skin -= 1;
	if(this.guardian_owner)
	{
		setthink(this, morph_run1);
		this.nextthink = time + 0.1;
	}
}
void morph_wake30(entity this) { set_animofs(this, anim_morph_start01, 30, morph_wake31); }
void morph_wake29(entity this) { set_animofs(this, anim_morph_start01, 29, morph_wake30); }
void morph_wake28(entity this) { set_animofs(this, anim_morph_start01, 28, morph_wake29); }
void morph_wake27(entity this) { set_animofs(this, anim_morph_start01, 27, morph_wake28); }
void morph_wake26(entity this) { set_animofs(this, anim_morph_start01, 26, morph_wake27); }
void morph_wake25(entity this) { set_animofs(this, anim_morph_start01, 25, morph_wake26); }
void morph_wake24(entity this) { set_animofs(this, anim_morph_start01, 24, morph_wake25); }
void morph_wake23(entity this) { set_animofs(this, anim_morph_start01, 23, morph_wake24); }
void morph_wake22(entity this) { set_animofs(this, anim_morph_start01, 22, morph_wake23); }
void morph_wake21(entity this) { set_animofs(this, anim_morph_start01, 21, morph_wake22); }
void morph_wake20(entity this) { set_animofs(this, anim_morph_start01, 20, morph_wake21); }
//void morph_wake19(entity this) { set_animofs(this, anim_morph_start01, 19, morph_wake20); }
//void morph_wake18(entity this) { set_animofs(this, anim_morph_start01, 18, morph_wake19); }
void morph_wake18(entity this) { set_animofs(this, anim_morph_start01, 18, morph_wake20); }
void morph_wake17(entity this) { set_animofs(this, anim_morph_start01, 17, morph_wake18); }
void morph_wake16(entity this) { set_animofs(this, anim_morph_start01, 16, morph_wake17); }
void morph_wake15(entity this) { set_animofs(this, anim_morph_start01, 15, morph_wake16); this.skin = 1; }
void morph_wake14(entity this) { set_animofs(this, anim_morph_start01, 14, morph_wake15); }
void morph_wake13(entity this) { set_animofs(this, anim_morph_start01, 13, morph_wake14); }
void morph_wake12(entity this) { set_animofs(this, anim_morph_start01, 12, morph_wake13); }
void morph_wake11(entity this) { set_animofs(this, anim_morph_start01, 11, morph_wake12); }
void morph_wake10(entity this) { set_animofs(this, anim_morph_start01, 10, morph_wake11); }
void morph_wake9(entity this) { set_animofs(this, anim_morph_start01, 9, morph_wake10); }
void morph_wake8(entity this) { set_animofs(this, anim_morph_start01, 8, morph_wake9); }
void morph_wake7(entity this) { set_animofs(this, anim_morph_start01, 7, morph_wake8); }
void morph_wake6(entity this) { set_animofs(this, anim_morph_start01, 6, morph_wake7); }
void morph_wake5(entity this) { set_animofs(this, anim_morph_start01, 5, morph_wake6); }
void morph_wake4(entity this) { set_animofs(this, anim_morph_start01, 4, morph_wake5); }
void morph_wake3(entity this) { set_animofs(this, anim_morph_start01, 3, morph_wake4); }
void morph_wake2(entity this) { set_animofs(this, anim_morph_start01, 2, morph_wake3); }
void morph_wake1(entity this)
{
	set_animofs(this, anim_morph_start01, 1, morph_wake2);

	_sound(this, CH_VOICE, "guard/see1.wav", 1, ATTN_NORM);
	if(this.guardian_owner)
	{
//		this.solid = SOLID_SLIDEBOX;
//		this.takedamage = DAMAGE_NO;

		//monsters_total += 1;
  
		this.guardian_owner.childrenSpawned = this.guardian_owner.childrenSpawned + 1;
	}
}

void morph_setup(entity this)
{
	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);
	this.takedamage = DAMAGE_NO;
	this.flags |= FL_MONSTER;
	this.ideal_yaw = this.angles * '0 1 0';
	if(!this.yaw_speed)
		this.yaw_speed = 20;
	this.view_ofs = '0 0 25';
	this.frame = anim_morph_start01;

	if(!this.damagedbycontents)
		IL_PUSH(g_damagedbycontents, this);
	this.damagedbycontents	= true;

	_setmodel(this, this.mdl);

	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);

	this.th_stand = morph_stand1;
	this.th_walk = morph_walk1;
	this.th_run = morph_run1;
	this.th_missile = morph_fire1;
	this.th_melee = morph_attack;
	this.th_pain = morph_pain;
	this.th_die = morph_die;

	if(this.guardian_owner)
	{
		this.effects = EF_STARDUST;
		this.health = 200;
		this.spawnflags = this.guardian_owner.spawnflags;
	}
	else
	{
		this.effects |= EF_DIMLIGHT;
		this.health = 2000;
	}
	this.max_health = this.health;

	this.skin = 2;
}

bool isSpawnPointEmpty(entity thePoint);
void morph_wake(entity this)
{
	morph_setup(this);
	setthink(this, morph_wake1);
	this.nextthink = time + 0.1;
}

entity overlord_find_dest3(entity this);
void morph_teleport(entity this)
{
	if(this.guardian_owner || (this.flags & FL_CLONE))
		return;

	if(this.childrenSpawned > (1 + autocvar_skill))
		return;
		
	entity theDest = overlord_find_dest3(this);
	if(!theDest)
		return;

	entity theChild = new(monster_morph);
	theChild.monsterdef = this.monsterdef;
	//theChild.effects = EF_STARDUST;
	theChild.flags = FL_CLONE; // don't count it in anything
	theChild.mdl = this.mdl;
	theChild.angles = theDest.mangle;
	theChild.guardian_owner = this;
	theChild.enemy = this.enemy;
	theChild.movetarget = this.movetarget;
	theChild.goalentity = this.goalentity;
	theChild.mangle = theDest.mangle;
	morph_setup(theChild);
	setorigin(theChild, theDest.origin);
	DropToFloor_QC_DelayedInit(theChild);

	setthink(theChild, morph_wake1);
	theChild.nextthink = time + 0.3;
}


/*QUAKED monster_morph (1 0 0) (-16 -16 -24) (16 16 32) Ambush Aztec Egyptian Greek
The morphing monster.

Select the look of the monster (Aztec,Greek,Egyptian).
If the monster has a targetname (triggered by something) he will rise up out of the floor when triggered.
*/
spawnfunc(monster_morph) { monster_start(this, true, MON_GUARDIAN); }
#endif

#ifdef SVQC
METHOD(Guardian, mr_setup, bool(Guardian this, entity actor))
{
    TC(Guardian, this);

	// hack to make guardian use an existing skin if none is selected (when one is spawned in, for example)
	if(!(actor.spawnflags & MORPH_AZTEC) && !(actor.spawnflags & MORPH_EGYPT) && !(actor.spawnflags & MORPH_GREEK))
	{
		float r = random();
		if(r > 0.66)
			actor.spawnflags |= MORPH_AZTEC;
		else if(r > 0.33)
			actor.spawnflags |= MORPH_EGYPT;
		else
			actor.spawnflags |= MORPH_GREEK;
	}

	if(actor.spawnflags & MORPH_AZTEC) // Aztec
	{
		precache_model("progs/morph_az.mdl");
		actor.mdl = "progs/morph_az.mdl";
	}
	else if(actor.spawnflags & MORPH_EGYPT) // Egyptian
	{
		precache_model("progs/morph_eg.mdl");
		actor.mdl = "progs/morph_eg.mdl";
	}
	else if(actor.spawnflags & MORPH_GREEK)	// greek
	{
		precache_model("progs/morph_gr.mdl");
		actor.mdl = "progs/morph_gr.mdl";
	}
	//else
		//objerror(actor, "monster_morph: no skin selection!");
	
	precache_model("progs/laser.mdl");
	precache_sound("enforcer/enfire.wav");
	precache_sound("guard/death.wav");
	precache_sound("guard/pain1.wav");
	precache_sound("guard/see1.wav");

	// undo what setup did
	setmodel(actor, MDL_Null);
	setsize(actor, '0 0 0', '0 0 0');

	// if we got this far, wake up!!
	morph_wake(actor);

    return true;
}
#endif
