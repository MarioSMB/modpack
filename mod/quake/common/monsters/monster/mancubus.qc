#include "mancubus.qh"

// Mancubus - designed by Mäggot "QuadLicker" Eater
// code is a clone of the Ogre

#ifdef SVQC
const int anim_mancubus_stand = 0; //'0 8 0'
const int anim_mancubus_walk = 9; //'9 24 0'
const int anim_mancubus_run = 25; //'25 32 0'
const int anim_mancubus_swing = 33; //'33 46 0'
const int anim_mancubus_smash = 47; //'47 60 0'
const int anim_mancubus_shoot = 61; //'61 66 0'
const int anim_mancubus_pain = 67; //'67 71 0'
const int anim_mancubus_painb = 72; //'72 74 0'
const int anim_mancubus_painc = 75; //'75 80 0'
const int anim_mancubus_paind = 81; //'81 96 0'
const int anim_mancubus_paine = 97; //'97 111 0'
const int anim_mancubus_death = 112; //'112 125 0'
const int anim_mancubus_bdeath = 126; //'126 135 0'
const int anim_mancubus_pull = 136; //'136 146 0'

//=============================================================================

const int MANCUBUS_BOSS = BIT(1);

/*
================
MancubusFireShot
================
*/

void BecomeMiniBlast(entity this, int blasttype);
void mancubus_LaserTouch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.solid == SOLID_TRIGGER)
		return;

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float mydmg = (this.dmg) ? this.dmg : 15;
	float damg = mydmg + random() * (mydmg * 0.2);

	if(toucher.takedamage)
	{
		if(Resist_Explosions(toucher))
			damg *= 0.5;
		if(toucher.resist_rockets != 0)
		{
			damg = Resist_Damage(toucher, IT_ROCKETS, damg);
			Resist_Rockets(toucher, this.origin);
		}
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}

	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	T_RadiusDamage(this, this.owner, mydmg * 1.2, this.projectiledeathtype, toucher);

	this.origin = this.origin - 8 * normalize(this.velocity);

	//Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);
	_sound(this, CH_SHOTS, "mancubus/fireball_impact.wav", 1, ATTN_NORM);

	BecomeMiniBlast(this, 0);
}

void mancubus_LaunchLaser(entity this, float offset)
{
	vector org = this.origin + '0 0 8' + v_right * offset;
	vector enemy_org = (this.enemy.absmin + this.enemy.absmax) * 0.5;
	vector dir = normalize(enemy_org - org);

	entity newmis = launch_spike(this, org, dir);
	newmis.projectiledeathtype = DEATH_MONSTER_MANCUBUS.m_id;
	newmis.dmg = 15;
	//newmis.noise = "weapons/r_exp3b.wav";
	newmis.velocity = dir * 600;
	newmis.angles = vectoangles(newmis.velocity);
	settouch(newmis, mancubus_LaserTouch); // go kaboom instead of tink

	CSQCProjectile(newmis, true, PROJECTILE_MANCUBUS_BOLT, true);
}

void MancubusFireShot(entity this)
{
	this.effects |= EF_MUZZLEFLASH;

	_sound(this, CH_WEAPON_SINGLE, "hipweap/laserg.wav", 1, ATTN_NORM);

	fixedmakevectors(this.angles);

	mancubus_LaunchLaser(this, 30);
	mancubus_LaunchLaser(this, -30);
}


//=============================================================================

/*
================
chainsaw
FIXME
================
*/
void mancubus_chainsaw(entity this, float side)
{
	if(!this.enemy)
		return;
	ai_damagebreakable(this, 20);							// Damage any breakables
	if(!CanDamage(this.enemy, this))
		return;

	ai_charge(this, 10);

	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
		
	float ldmg =(random() + random() + random()) * 4;
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_MANCUBUS.m_id);
	
	if(side)
	{
		fixedmakevectors(this.angles);
		if(side == 1)
			SpawnMeatSpray(this, this.origin + v_forward*16, crandom() * 100 * v_right);
		else
			SpawnMeatSpray(this, this.origin + v_forward*16, side * v_right);
	}
}

void mancubus_stand1(entity this);
void mancubus_stand9(entity this) { set_animofs(this, anim_mancubus_stand, 9, mancubus_stand1); ai_stand(this); }
void mancubus_stand8(entity this) { set_animofs(this, anim_mancubus_stand, 8, mancubus_stand9); ai_stand(this); }
void mancubus_stand7(entity this) { set_animofs(this, anim_mancubus_stand, 7, mancubus_stand8); ai_stand(this); }
void mancubus_stand6(entity this) { set_animofs(this, anim_mancubus_stand, 6, mancubus_stand7); ai_stand(this); }
void mancubus_stand5(entity this)
{
	set_animofs(this, anim_mancubus_stand, 5, mancubus_stand6);
	if(random() < 0.2)
	{
		if(this.spawnflags & MANCUBUS_BOSS)
			_sound(this, CH_VOICE, "mancubus/idle2.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "mancubus/idle.wav", 1, ATTN_IDLE);
	}
	ai_stand(this);
}
void mancubus_stand4(entity this) { set_animofs(this, anim_mancubus_stand, 4, mancubus_stand5); ai_stand(this); }
void mancubus_stand3(entity this) { set_animofs(this, anim_mancubus_stand, 3, mancubus_stand4); ai_stand(this); }
void mancubus_stand2(entity this) { set_animofs(this, anim_mancubus_stand, 2, mancubus_stand3); ai_stand(this); }
void mancubus_stand1(entity this) { set_animofs(this, anim_mancubus_stand, 1, mancubus_stand2); ai_stand(this); }

void mancubus_walk1(entity this);
void mancubus_walk16(entity this) { set_animofs(this, anim_mancubus_walk, 16, mancubus_walk1); ai_walk(this, 4); }
void mancubus_walk15(entity this) { set_animofs(this, anim_mancubus_walk, 15, mancubus_walk16); ai_walk(this, 3); }
void mancubus_walk14(entity this) { set_animofs(this, anim_mancubus_walk, 14, mancubus_walk15); ai_walk(this, 3); }
void mancubus_walk13(entity this) { set_animofs(this, anim_mancubus_walk, 13, mancubus_walk14); ai_walk(this, 3); }
void mancubus_walk12(entity this) { set_animofs(this, anim_mancubus_walk, 12, mancubus_walk13); ai_walk(this, 3); }
void mancubus_walk11(entity this) { set_animofs(this, anim_mancubus_walk, 11, mancubus_walk12); ai_walk(this, 2); }
void mancubus_walk10(entity this) { set_animofs(this, anim_mancubus_walk, 10, mancubus_walk11); ai_walk(this, 1); }
void mancubus_walk9(entity this) { set_animofs(this, anim_mancubus_walk, 9, mancubus_walk10); ai_walk(this, 3); monster_footstep(this, false); }
void mancubus_walk8(entity this) { set_animofs(this, anim_mancubus_walk, 8, mancubus_walk9); ai_walk(this, 2); }
void mancubus_walk7(entity this) { set_animofs(this, anim_mancubus_walk, 7, mancubus_walk8); ai_walk(this, 3); }
void mancubus_walk6(entity this) { set_animofs(this, anim_mancubus_walk, 6, mancubus_walk7); ai_walk(this, 5); }
void mancubus_walk5(entity this) { set_animofs(this, anim_mancubus_walk, 5, mancubus_walk6); ai_walk(this, 2); }
void mancubus_walk4(entity this) { set_animofs(this, anim_mancubus_walk, 4, mancubus_walk5); ai_walk(this, 2); }
void mancubus_walk3(entity this)
{
	set_animofs(this, anim_mancubus_walk, 3, mancubus_walk4);
	ai_walk(this, 2);
	if(random() < 0.2)
	{
		if(this.spawnflags & MANCUBUS_BOSS)
			_sound(this, CH_VOICE, "mancubus/idle2.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "mancubus/idle.wav", 1, ATTN_IDLE);
	}
}
void mancubus_walk2(entity this) { set_animofs(this, anim_mancubus_walk, 2, mancubus_walk3); ai_walk(this, 2); }
void mancubus_walk1(entity this) { set_animofs(this, anim_mancubus_walk, 1, mancubus_walk2); ai_walk(this, 3); monster_footstep(this, false); }

void mancubus_run1(entity this);
void mancubus_run8(entity this) { set_animofs(this, anim_mancubus_run, 8, mancubus_run1); ai_run(this, 9); }
void mancubus_run7(entity this) { set_animofs(this, anim_mancubus_run, 7, mancubus_run8); ai_run(this, 12); }
void mancubus_run6(entity this) { set_animofs(this, anim_mancubus_run, 6, mancubus_run7); ai_run(this, 8); monster_footstep(this, false); }
void mancubus_run5(entity this) { set_animofs(this, anim_mancubus_run, 5, mancubus_run6); ai_run(this, 22); }
void mancubus_run4(entity this) { set_animofs(this, anim_mancubus_run, 4, mancubus_run5); ai_run(this, 16); }
void mancubus_run3(entity this) { set_animofs(this, anim_mancubus_run, 3, mancubus_run4); ai_run(this, 4); }
void mancubus_run2(entity this) { set_animofs(this, anim_mancubus_run, 2, mancubus_run3); ai_run(this, 13); monster_footstep(this, false); }
void mancubus_run1(entity this)
{
	set_animofs(this, anim_mancubus_run, 1, mancubus_run2);
	ai_run(this, 24);
	if(random() < 0.2)
	{
		if(this.spawnflags & MANCUBUS_BOSS)
			_sound(this, CH_VOICE, "mancubus/idle2.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "mancubus/idle.wav", 1, ATTN_IDLE);
	}
}

void mancubus_swing14(entity this) { set_animofs(this, anim_mancubus_swing, 14, mancubus_run1); ai_charge(this, 9); }
void mancubus_swing13(entity this) { set_animofs(this, anim_mancubus_swing, 13, mancubus_swing14); ai_charge(this, 8); }
void mancubus_swing12(entity this) { set_animofs(this, anim_mancubus_swing, 12, mancubus_swing13); ai_charge(this, 3); }
void mancubus_swing11(entity this) { set_animofs(this, anim_mancubus_swing, 11, mancubus_swing12); mancubus_chainsaw(this, 0); this.angles_y = this.angles_y + random() * 25; }
void mancubus_swing10(entity this) { set_animofs(this, anim_mancubus_swing, 10, mancubus_swing11); mancubus_chainsaw(this, -200); this.angles_y = this.angles_y + random() * 25; }
void mancubus_swing9(entity this) { set_animofs(this, anim_mancubus_swing, 9, mancubus_swing10); mancubus_chainsaw(this, 0); this.angles_y = this.angles_y + random() * 25; }
void mancubus_swing8(entity this) { set_animofs(this, anim_mancubus_swing, 8, mancubus_swing9); mancubus_chainsaw(this, 0); this.angles_y = this.angles_y + random() * 25; }
void mancubus_swing7(entity this) { set_animofs(this, anim_mancubus_swing, 7, mancubus_swing8); mancubus_chainsaw(this, 0); this.angles_y = this.angles_y + random() * 25; }
void mancubus_swing6(entity this) { set_animofs(this, anim_mancubus_swing, 6, mancubus_swing7); mancubus_chainsaw(this, 200); this.angles_y = this.angles_y + random() * 25; }
void mancubus_swing5(entity this) { set_animofs(this, anim_mancubus_swing, 5, mancubus_swing6); ai_charge(this, 9); mancubus_chainsaw(this, 0); this.angles_y = this.angles_y + random() * 25; monster_footstep(this, false); }
void mancubus_swing4(entity this) { set_animofs(this, anim_mancubus_swing, 4, mancubus_swing5); ai_charge(this, 13); }
void mancubus_swing3(entity this) { set_animofs(this, anim_mancubus_swing, 3, mancubus_swing4); ai_charge(this, 4); }
void mancubus_swing2(entity this) { set_animofs(this, anim_mancubus_swing, 2, mancubus_swing3); ai_charge(this, 1); }
void mancubus_swing1(entity this)
{
	set_animofs(this, anim_mancubus_swing, 1, mancubus_swing2);
	ai_charge(this, 11);
	if(this.spawnflags & MANCUBUS_BOSS)
		_sound(this, CH_WEAPON_SINGLE, "mancubus/attack2.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "mancubus/attack.wav", 1, ATTN_NORM);
}

void mancubus_smash14(entity this) { set_animofs(this, anim_mancubus_smash, 14, mancubus_run1); ai_charge(this, 12); }
void mancubus_smash13(entity this) { set_animofs(this, anim_mancubus_smash, 13, mancubus_smash14); ai_charge(this, 4); }
void mancubus_smash12(entity this) { set_animofs(this, anim_mancubus_smash, 12, mancubus_smash13); ai_charge(this, 0); }
void mancubus_smash11(entity this) { set_animofs(this, anim_mancubus_smash, 11, mancubus_smash12); mancubus_chainsaw(this, 2); this.nextthink = this.nextthink + random() * 0.2; /* slight variation */ }
void mancubus_smash10(entity this) { set_animofs(this, anim_mancubus_smash, 10, mancubus_smash11); mancubus_chainsaw(this, 1); }
void mancubus_smash9(entity this) { set_animofs(this, anim_mancubus_smash, 9, mancubus_smash10); ai_charge(this, 13); mancubus_chainsaw(this, 0); monster_footstep(this, false); }
void mancubus_smash8(entity this) { set_animofs(this, anim_mancubus_smash, 8, mancubus_smash9); ai_charge(this, 10); mancubus_chainsaw(this, 0); }
void mancubus_smash7(entity this) { set_animofs(this, anim_mancubus_smash, 7, mancubus_smash8); ai_charge(this, 4); mancubus_chainsaw(this, 0); }
void mancubus_smash6(entity this) { set_animofs(this, anim_mancubus_smash, 6, mancubus_smash7); ai_charge(this, 4); mancubus_chainsaw(this, 0); }
void mancubus_smash5(entity this) { set_animofs(this, anim_mancubus_smash, 5, mancubus_smash6); ai_charge(this, 4); }
void mancubus_smash4(entity this) { set_animofs(this, anim_mancubus_smash, 4, mancubus_smash5); ai_charge(this, 1); }
void mancubus_smash3(entity this) { set_animofs(this, anim_mancubus_smash, 3, mancubus_smash4); ai_charge(this, 0); }
void mancubus_smash2(entity this) { set_animofs(this, anim_mancubus_smash, 2, mancubus_smash3); ai_charge(this, 0); }
void mancubus_smash1(entity this)
{
	set_animofs(this, anim_mancubus_smash, 1, mancubus_smash2);
	ai_charge(this, 6);
	if(this.spawnflags & MANCUBUS_BOSS)
		_sound(this, CH_WEAPON_SINGLE, "mancubus/attack2.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "mancubus/attack.wav", 1, ATTN_NORM);
}

void mancubus_nail7(entity this) { set_animofs(this, anim_mancubus_shoot, 6, mancubus_run1); ai_face(this); }
void mancubus_nail6(entity this) { set_animofs(this, anim_mancubus_shoot, 5, mancubus_nail7); ai_face(this); }
void mancubus_nail5(entity this) { set_animofs(this, anim_mancubus_shoot, 4, mancubus_nail6); ai_face(this); }
void mancubus_nail4(entity this) { set_animofs(this, anim_mancubus_shoot, 3, mancubus_nail5); ai_face(this); MancubusFireShot(this); }
void mancubus_nail3(entity this) { set_animofs(this, anim_mancubus_shoot, 2, mancubus_nail4); ai_face(this); }
void mancubus_nail2(entity this) { set_animofs(this, anim_mancubus_shoot, 2, mancubus_nail3); ai_face(this); }
void mancubus_nail1(entity this) { set_animofs(this, anim_mancubus_shoot, 1, mancubus_nail2); ai_face(this); }

void mancubus_pain5(entity this) { set_animofs(this, anim_mancubus_pain, 5, mancubus_run1); }
void mancubus_pain4(entity this) { set_animofs(this, anim_mancubus_pain, 4, mancubus_pain5); }
void mancubus_pain3(entity this) { set_animofs(this, anim_mancubus_pain, 3, mancubus_pain4); }
void mancubus_pain2(entity this) { set_animofs(this, anim_mancubus_pain, 2, mancubus_pain3); }
void mancubus_pain1(entity this) { set_animofs(this, anim_mancubus_pain, 1, mancubus_pain2); }

void mancubus_painb3(entity this) { set_animofs(this, anim_mancubus_painb, 3, mancubus_run1); }
void mancubus_painb2(entity this) { set_animofs(this, anim_mancubus_painb, 2, mancubus_painb3); }
void mancubus_painb1(entity this) { set_animofs(this, anim_mancubus_painb, 1, mancubus_painb2); }

void mancubus_painc6(entity this) { set_animofs(this, anim_mancubus_painc, 6, mancubus_run1); }
void mancubus_painc5(entity this) { set_animofs(this, anim_mancubus_painc, 5, mancubus_painc6); }
void mancubus_painc4(entity this) { set_animofs(this, anim_mancubus_painc, 4, mancubus_painc5); }
void mancubus_painc3(entity this) { set_animofs(this, anim_mancubus_painc, 3, mancubus_painc4); }
void mancubus_painc2(entity this) { set_animofs(this, anim_mancubus_painc, 2, mancubus_painc3); }
void mancubus_painc1(entity this) { set_animofs(this, anim_mancubus_painc, 1, mancubus_painc2); }

void mancubus_paind16(entity this) { set_animofs(this, anim_mancubus_paind, 16, mancubus_run1); }
void mancubus_paind15(entity this) { set_animofs(this, anim_mancubus_paind, 15, mancubus_paind16); }
void mancubus_paind14(entity this) { set_animofs(this, anim_mancubus_paind, 14, mancubus_paind15); }
void mancubus_paind13(entity this) { set_animofs(this, anim_mancubus_paind, 13, mancubus_paind14); }
void mancubus_paind12(entity this) { set_animofs(this, anim_mancubus_paind, 12, mancubus_paind13); monster_footstep(this, false); }
void mancubus_paind11(entity this) { set_animofs(this, anim_mancubus_paind, 11, mancubus_paind12); }
void mancubus_paind10(entity this) { set_animofs(this, anim_mancubus_paind, 10, mancubus_paind11); monster_footstep(this, false); }
void mancubus_paind9(entity this) { set_animofs(this, anim_mancubus_paind, 9, mancubus_paind10); }
void mancubus_paind8(entity this) { set_animofs(this, anim_mancubus_paind, 8, mancubus_paind9); }
void mancubus_paind7(entity this) { set_animofs(this, anim_mancubus_paind, 7, mancubus_paind8); }
void mancubus_paind6(entity this) { set_animofs(this, anim_mancubus_paind, 6, mancubus_paind7); }
void mancubus_paind5(entity this) { set_animofs(this, anim_mancubus_paind, 5, mancubus_paind6); }
void mancubus_paind4(entity this) { set_animofs(this, anim_mancubus_paind, 4, mancubus_paind5); ai_pain(this, 4); monster_footstep(this, false); }
void mancubus_paind3(entity this) { set_animofs(this, anim_mancubus_paind, 3, mancubus_paind4); ai_pain(this, 9); }
void mancubus_paind2(entity this) { set_animofs(this, anim_mancubus_paind, 2, mancubus_paind3); ai_pain(this, 10); }
void mancubus_paind1(entity this) { set_animofs(this, anim_mancubus_paind, 1, mancubus_paind2); }

void mancubus_paine15(entity this) { set_animofs(this, anim_mancubus_paine, 15, mancubus_run1); }
void mancubus_paine14(entity this) { set_animofs(this, anim_mancubus_paine, 14, mancubus_paine15); }
void mancubus_paine13(entity this) { set_animofs(this, anim_mancubus_paine, 13, mancubus_paine14); }
void mancubus_paine12(entity this) { set_animofs(this, anim_mancubus_paine, 12, mancubus_paine13); }
void mancubus_paine11(entity this) { set_animofs(this, anim_mancubus_paine, 11, mancubus_paine12); }
void mancubus_paine10(entity this) { set_animofs(this, anim_mancubus_paine, 10, mancubus_paine11); }
void mancubus_paine9(entity this) { set_animofs(this, anim_mancubus_paine, 9, mancubus_paine10); }
void mancubus_paine8(entity this) { set_animofs(this, anim_mancubus_paine, 8, mancubus_paine9); }
void mancubus_paine7(entity this) { set_animofs(this, anim_mancubus_paine, 7, mancubus_paine8); }
void mancubus_paine6(entity this) { set_animofs(this, anim_mancubus_paine, 6, mancubus_paine7); }
void mancubus_paine5(entity this) { set_animofs(this, anim_mancubus_paine, 5, mancubus_paine6); }
void mancubus_paine4(entity this) { set_animofs(this, anim_mancubus_paine, 4, mancubus_paine5); ai_pain(this, 4); }
void mancubus_paine3(entity this) { set_animofs(this, anim_mancubus_paine, 3, mancubus_paine4); ai_pain(this, 9); monster_footstep(this, false); }
void mancubus_paine2(entity this) { set_animofs(this, anim_mancubus_paine, 2, mancubus_paine3); ai_pain(this, 10); }
void mancubus_paine1(entity this) { set_animofs(this, anim_mancubus_paine, 1, mancubus_paine2); }

void mancubus_pain(entity this, entity attacker, float damage, int deathtype)
{
// don't make multiple pain sounds right after each other
	if(this.pain_finished > time)
		return;

	if(this.spawnflags & MANCUBUS_BOSS)
		_sound(this, CH_VOICE, "mancubus/pain2.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "mancubus/pain.wav", 1, ATTN_NORM);

	float r = random();
	
	if(r < 0.25)
	{
		this.pain_finished = time + 1;
		mancubus_pain1(this);
	}
	else if(r < 0.5)
	{
		this.pain_finished = time + 1;
		mancubus_painb1(this);
	}
	else if(r < 0.75)
	{
		this.pain_finished = time + 1;
		mancubus_painc1(this);
	}
	else if(r < 0.88)
	{
		this.pain_finished = time + 2;
		mancubus_paind1(this);
	}
	else
	{
		this.pain_finished = time + 2;
		mancubus_paine1(this);
	}
}

void mancubus_die14(entity this)
{
	set_animofs(this, anim_mancubus_death, 14, mancubus_die14);
	CorpseThink(this);
}
void mancubus_die13(entity this) { set_animofs(this, anim_mancubus_death, 13, mancubus_die14); }
void mancubus_die12(entity this) { set_animofs(this, anim_mancubus_death, 12, mancubus_die13); }
void mancubus_die11(entity this) { set_animofs(this, anim_mancubus_death, 11, mancubus_die12); }
void mancubus_die10(entity this) { set_animofs(this, anim_mancubus_death, 10, mancubus_die11); }
void mancubus_die9(entity this) { set_animofs(this, anim_mancubus_death, 9, mancubus_die10); }
void mancubus_die8(entity this) { set_animofs(this, anim_mancubus_death, 8, mancubus_die9); }
void mancubus_die7(entity this) { set_animofs(this, anim_mancubus_death, 7, mancubus_die8); }
void mancubus_die6(entity this) { set_animofs(this, anim_mancubus_death, 6, mancubus_die7); }
void mancubus_die5(entity this) { set_animofs(this, anim_mancubus_death, 5, mancubus_die6); }
void mancubus_die4(entity this) { set_animofs(this, anim_mancubus_death, 4, mancubus_die5); }
void mancubus_die3(entity this) { set_animofs(this, anim_mancubus_death, 3, mancubus_die4); }
void mancubus_die2(entity this) { set_animofs(this, anim_mancubus_death, 2, mancubus_die3); }
void mancubus_die1(entity this) { set_animofs(this, anim_mancubus_death, 1, mancubus_die2); this.solid = SOLID_NOT; }

void mancubus_bdie10(entity this)
{
	set_animofs(this, anim_mancubus_bdeath, 10, mancubus_bdie10);
	CorpseThink(this);
}
void mancubus_bdie9(entity this) { set_animofs(this, anim_mancubus_bdeath, 9, mancubus_bdie10); }
void mancubus_bdie8(entity this) { set_animofs(this, anim_mancubus_bdeath, 8, mancubus_bdie9); }
void mancubus_bdie7(entity this) { set_animofs(this, anim_mancubus_bdeath, 7, mancubus_bdie8); ai_forward(this, 25); }
void mancubus_bdie6(entity this) { set_animofs(this, anim_mancubus_bdeath, 6, mancubus_bdie7); ai_forward(this, 7); }
void mancubus_bdie5(entity this) { set_animofs(this, anim_mancubus_bdeath, 5, mancubus_bdie6); ai_forward(this, 3); }
void mancubus_bdie4(entity this) { set_animofs(this, anim_mancubus_bdeath, 4, mancubus_bdie5); ai_forward(this, 1); }
void mancubus_bdie3(entity this) { set_animofs(this, anim_mancubus_bdeath, 3, mancubus_bdie4); }
void mancubus_bdie2(entity this) { set_animofs(this, anim_mancubus_bdeath, 2, mancubus_bdie3); ai_forward(this, 5); }
void mancubus_bdie1(entity this) { set_animofs(this, anim_mancubus_bdeath, 1, mancubus_bdie2); this.solid = SOLID_NOT; }

// NOTE: requires makevectors
void mancubus_ThrowGib(entity this, string gibmdl)
{
	entity gib = ThrowGib(this, NULL, gibmdl, 20);
	gib.velocity = v_forward * 100 + randomvec() * 40;
}

void mancubus_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
			ThrowGib(this, inflictor, "progs/h_mancubus.mdl", this.health);
			ThrowGib(this, inflictor, "progs/gib1_mancubus.mdl", this.health);
			ThrowGib(this, inflictor, "progs/gib2_mancubus.mdl", this.health);
			ThrowGib(this, inflictor, "progs/gib3_mancubus.mdl", this.health);
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	if(this.spawnflags & MANCUBUS_BOSS)
		_sound(this, CH_VOICE, "mancubus/death2.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "mancubus/death.wav", 1, ATTN_NORM);

	// throw some meaty bits at the player
	makevectors(this.angles);
	mancubus_ThrowGib(this, "progs/gib1.mdl");
	mancubus_ThrowGib(this, "progs/gib2.mdl");
	mancubus_ThrowGib(this, "progs/gib3_mancubus.mdl");

	SpawnBlood(this.origin, v_forward * 150, 14, this);

	if(random() < 0.5)
		mancubus_die1(this);
	else
		mancubus_bdie1(this);
}

void mancubus_melee(entity this)
{
	if(random() > 0.5)
		mancubus_smash1(this);
	else
		mancubus_swing1(this);
}

/*
===========
MancubusCheckAttack

The player is in view, so decide to move or launch an attack
Returns false if movement should continue
============
*/
bool MancubusCheckAttack(entity this)
{
	if(this.enemy_range == RANGE_MELEE)
	{
		if(CanDamage(this.enemy, this))
		{
			this.attack_state = AS_MELEE;
			return true;
		}
	}

	if(this.enemy_range == RANGE_FAR)
		return false;
	if(time < this.attack_finished)
		return false;
	if(!this.enemy_visible)
		return false;

	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, false, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
	{
		return false;	// don't have a clear shot
	}
			
// missile attack
	float chance = 0;
	if(this.enemy_range == RANGE_NEAR)
		chance = 0.10;
	else if(this.enemy_range == RANGE_MID)
		chance = 0.05;

	this.attack_state = AS_MISSILE;
	float extra_delay = 3;
	this.attack_finished = time + (1 * extra_delay * random());
	return true;
}

/*QUAKED monster_mancubus(1 0 0)(-32 -32 -24)(32 32 64) Ambush Boss Normal
The Mancubus

Boss:  use the modified skin and sounds.
Normal: use the original skin and sounds.
*/
spawnfunc(monster_mancubus) { monster_start(this, true, MON_MANCUBUS); }
#endif // SVQC

#ifdef SVQC
METHOD(Mancubus, mr_setup, bool(Mancubus this, entity actor))
{
    TC(Mancubus, this);

    precache_model("progs/h_mancubus.mdl");
    precache_model("progs/gib1.mdl");
    precache_model("progs/gib2.mdl");
    precache_model("progs/gib1_mancubus.mdl");
	precache_model("progs/gib2_mancubus.mdl");
	precache_model("progs/gib3_mancubus.mdl");
	precache_model("progs/s_explode_fire_64x.spr");

	precache_sound("hipweap/laserg.wav");
	precache_sound("mancubus/fireball_impact.wav");

	// none specified - choose random. 25% boss on normal, hard, bloodbath
	if(!(actor.spawnflags & MANCUBUS_BOSS) && autocvar_skill > 0 && random() <= 0.25)
		actor.spawnflags |= MANCUBUS_BOSS;

	actor.effects |= EF_NOMODELFLAGS; // fix selectable glow

	if(actor.spawnflags & MANCUBUS_BOSS)
	{
		precache_sound("mancubus/attack2.wav");
		precache_sound("mancubus/death2.wav");
		precache_sound("mancubus/idle2.wav");
		precache_sound("mancubus/pain2.wav");
		precache_sound("mancubus/shoot2.wav");
		precache_sound("mancubus/sight2.wav");

		//actor.skin = 1; // TODO: skin is broken (transparent parts don't work)
		actor.skin = 0;
	}
	else
	{
		precache_sound("mancubus/attack.wav");
		precache_sound("mancubus/death.wav");
		precache_sound("mancubus/idle.wav");
		precache_sound("mancubus/pain.wav");
		precache_sound("mancubus/shoot.wav");
		precache_sound("mancubus/sight.wav");

		actor.skin = 0;
	}

    actor.health = 300;
    actor.gibhealth = -80;
    actor.th_stand = mancubus_stand1;
	actor.th_walk = mancubus_walk1;
	actor.th_run = mancubus_run1;
	actor.th_die = mancubus_die;
	actor.th_melee = mancubus_melee;
	actor.th_missile = mancubus_nail1;
	actor.th_pain = mancubus_pain;

	actor.checkattack = MancubusCheckAttack;

	actor.steptype = FS_TYPESLOW;

    return true;
}
METHOD(Mancubus, mr_sight, bool(Mancubus this, entity actor))
{
    TC(Mancubus, this);

    if(actor.spawnflags & MANCUBUS_BOSS)
		_sound(actor, CH_VOICE, "mancubus/sight2.wav", 1, ATTN_NORM);
	else
		_sound(actor, CH_VOICE, "mancubus/sight.wav", 1, ATTN_NORM);

	return true;
}
#endif
