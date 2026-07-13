#include "bulletkin.qh"

// Bullet Kin - designed by Mäggot "QuadLicker" Eater
// code is a clone of the Enforcer

#ifdef SVQC
const int anim_bulletkin_stand = 0; //'0 6 0'
const int anim_bulletkin_walk = 7; //'7 22 0'
const int anim_bulletkin_run = 23; //'23 30 0'
const int anim_bulletkin_attack = 31; //'31 40 0'
const int anim_bulletkin_death = 41; //'41 54 0'
const int anim_bulletkin_fdeath = 55; //'55 65 0'
const int anim_bulletkin_paina = 66; //'66 69 0'
const int anim_bulletkin_painb = 70; //'70 74 0'
const int anim_bulletkin_painc = 75; //'75 82 0'
const int anim_bulletkin_paind = 83; //'83 101 0'

void bulletkin_fire(entity this)
{
	this.effects |= EF_MUZZLEFLASH;

	_sound(this, CH_WEAPON_SINGLE, "bulletkin/attack.wav", 1, ATTN_NORM);

	fixedmakevectors(this.angles);

	vector org = this.origin + v_forward * 30 + v_right * 10.5 + '0 0 12';
	vector enemy_org = (this.enemy.absmin + this.enemy.absmax) * 0.5;
	vector dir = normalize(enemy_org - org);

	entity newmis = launch_spike(this, org, dir);
	newmis.projectiledeathtype = DEATH_MONSTER_BULLETKIN.m_id;
	newmis.noise = "bulletkin/hit.wav";
	newmis.dmg = 15;
	//newmis.velocity = dir * 600;
	//newmis.angles = vectoangles(newmis.velocity);

	CSQCProjectile(newmis, true, PROJECTILE_BULLETKIN_SHOT, true);
}

//============================================================================

void bulletkin_stand1(entity this);
void bulletkin_stand7(entity this) { set_animofs(this, anim_bulletkin_stand, 7, bulletkin_stand1); ai_stand(this); }
void bulletkin_stand6(entity this) { set_animofs(this, anim_bulletkin_stand, 6, bulletkin_stand7); ai_stand(this); }
void bulletkin_stand5(entity this) { set_animofs(this, anim_bulletkin_stand, 5, bulletkin_stand6); ai_stand(this); }
void bulletkin_stand4(entity this) { set_animofs(this, anim_bulletkin_stand, 4, bulletkin_stand5); ai_stand(this); }
void bulletkin_stand3(entity this) { set_animofs(this, anim_bulletkin_stand, 3, bulletkin_stand4); ai_stand(this); }
void bulletkin_stand2(entity this) { set_animofs(this, anim_bulletkin_stand, 2, bulletkin_stand3); ai_stand(this); }
void bulletkin_stand1(entity this) { set_animofs(this, anim_bulletkin_stand, 1, bulletkin_stand2); ai_stand(this); }

void bulletkin_walk1(entity this);
void bulletkin_walk16(entity this) { set_animofs(this, anim_bulletkin_walk, 16, bulletkin_walk1); ai_walk(this, 2); }
void bulletkin_walk15(entity this) { set_animofs(this, anim_bulletkin_walk, 15, bulletkin_walk16); ai_walk(this, 4); }
void bulletkin_walk14(entity this) { set_animofs(this, anim_bulletkin_walk, 14, bulletkin_walk15); ai_walk(this, 3); }
void bulletkin_walk13(entity this) { set_animofs(this, anim_bulletkin_walk, 13, bulletkin_walk14); ai_walk(this, 2); }
void bulletkin_walk12(entity this) { set_animofs(this, anim_bulletkin_walk, 12, bulletkin_walk13); ai_walk(this, 1); }
void bulletkin_walk11(entity this) { set_animofs(this, anim_bulletkin_walk, 11, bulletkin_walk12); ai_walk(this, 4); }
void bulletkin_walk10(entity this) { set_animofs(this, anim_bulletkin_walk, 10, bulletkin_walk11); ai_walk(this, 4); monster_footstep(this, false); }
void bulletkin_walk9(entity this) { set_animofs(this, anim_bulletkin_walk, 9, bulletkin_walk10); ai_walk(this, 2); }
void bulletkin_walk8(entity this) { set_animofs(this, anim_bulletkin_walk, 8, bulletkin_walk9); ai_walk(this, 1); }
void bulletkin_walk7(entity this) { set_animofs(this, anim_bulletkin_walk, 7, bulletkin_walk8); ai_walk(this, 2); }
void bulletkin_walk6(entity this) { set_animofs(this, anim_bulletkin_walk, 6, bulletkin_walk7); ai_walk(this, 2); }
void bulletkin_walk5(entity this) { set_animofs(this, anim_bulletkin_walk, 5, bulletkin_walk6); ai_walk(this, 1); }
void bulletkin_walk4(entity this) { set_animofs(this, anim_bulletkin_walk, 4, bulletkin_walk5); ai_walk(this, 3); }
void bulletkin_walk3(entity this) { set_animofs(this, anim_bulletkin_walk, 3, bulletkin_walk4); ai_walk(this, 4); }
void bulletkin_walk2(entity this) { set_animofs(this, anim_bulletkin_walk, 2, bulletkin_walk3); ai_walk(this, 4); monster_footstep(this, false); }
void bulletkin_walk1(entity this) { set_animofs(this, anim_bulletkin_walk, 1, bulletkin_walk2); ai_walk(this, 2); }

void bulletkin_run1(entity this);
void bulletkin_run8(entity this) { set_animofs(this, anim_bulletkin_run, 8, bulletkin_run1); ai_run(this, 11); }
void bulletkin_run7(entity this) { set_animofs(this, anim_bulletkin_run, 7, bulletkin_run8); ai_run(this, 7); monster_footstep(this, false); }
void bulletkin_run6(entity this) { set_animofs(this, anim_bulletkin_run, 6, bulletkin_run7); ai_run(this, 14); }
void bulletkin_run5(entity this) { set_animofs(this, anim_bulletkin_run, 5, bulletkin_run6); ai_run(this, 14); }
void bulletkin_run4(entity this) { set_animofs(this, anim_bulletkin_run, 4, bulletkin_run5); ai_run(this, 12); monster_footstep(this, false); }
void bulletkin_run3(entity this) { set_animofs(this, anim_bulletkin_run, 3, bulletkin_run4); ai_run(this, 7); }
void bulletkin_run2(entity this) { set_animofs(this, anim_bulletkin_run, 2, bulletkin_run3); ai_run(this, 14); }
void bulletkin_run1(entity this) { set_animofs(this, anim_bulletkin_run, 1, bulletkin_run2); ai_run(this, 18); }

void bulletkin_atk1(entity this);
void bulletkin_atk14(entity this)
{
	set_animofs(this, anim_bulletkin_attack, 10, bulletkin_run1);
	ai_face(this);
}
void bulletkin_atk13(entity this) { set_animofs(this, anim_bulletkin_attack, 9, bulletkin_atk14); ai_face(this); }
void bulletkin_atk12(entity this) { set_animofs(this, anim_bulletkin_attack, 8, bulletkin_atk13); ai_face(this); }
void bulletkin_atk11(entity this) { set_animofs(this, anim_bulletkin_attack, 7, bulletkin_atk12); ai_face(this); }
void bulletkin_atk10(entity this) { set_animofs(this, anim_bulletkin_attack, 6, bulletkin_atk11); bulletkin_fire(this); }
void bulletkin_atk9(entity this) { set_animofs(this, anim_bulletkin_attack, 5, bulletkin_atk10); ai_face(this); }
void bulletkin_atk8(entity this) { set_animofs(this, anim_bulletkin_attack, 8, bulletkin_atk9); ai_face(this); }
void bulletkin_atk7(entity this) { set_animofs(this, anim_bulletkin_attack, 7, bulletkin_atk8); ai_face(this); }
void bulletkin_atk6(entity this) { set_animofs(this, anim_bulletkin_attack, 6, bulletkin_atk7); bulletkin_fire(this); }
void bulletkin_atk5(entity this) { set_animofs(this, anim_bulletkin_attack, 5, bulletkin_atk6); ai_face(this); }
void bulletkin_atk4(entity this) { set_animofs(this, anim_bulletkin_attack, 4, bulletkin_atk5); ai_face(this); }
void bulletkin_atk3(entity this) { set_animofs(this, anim_bulletkin_attack, 3, bulletkin_atk4); ai_face(this); }
void bulletkin_atk2(entity this) { set_animofs(this, anim_bulletkin_attack, 2, bulletkin_atk3); ai_face(this); monster_footstep(this, false); }
void bulletkin_atk1(entity this) { set_animofs(this, anim_bulletkin_attack, 1, bulletkin_atk2); ai_face(this); }

void bulletkin_paina4(entity this) { set_animofs(this, anim_bulletkin_paina, 4, bulletkin_run1); }
void bulletkin_paina3(entity this) { set_animofs(this, anim_bulletkin_paina, 3, bulletkin_paina4); }
void bulletkin_paina2(entity this) { set_animofs(this, anim_bulletkin_paina, 2, bulletkin_paina3); }
void bulletkin_paina1(entity this) { set_animofs(this, anim_bulletkin_paina, 1, bulletkin_paina2); }

void bulletkin_painb5(entity this) { set_animofs(this, anim_bulletkin_painb, 5, bulletkin_run1); }
void bulletkin_painb4(entity this) { set_animofs(this, anim_bulletkin_painb, 4, bulletkin_painb5); }
void bulletkin_painb3(entity this) { set_animofs(this, anim_bulletkin_painb, 3, bulletkin_painb4); }
void bulletkin_painb2(entity this) { set_animofs(this, anim_bulletkin_painb, 2, bulletkin_painb3); }
void bulletkin_painb1(entity this) { set_animofs(this, anim_bulletkin_painb, 1, bulletkin_painb2); }

void bulletkin_painc8(entity this) { set_animofs(this, anim_bulletkin_painc, 8, bulletkin_run1); }
void bulletkin_painc7(entity this) { set_animofs(this, anim_bulletkin_painc, 7, bulletkin_painc8); }
void bulletkin_painc6(entity this) { set_animofs(this, anim_bulletkin_painc, 6, bulletkin_painc7); }
void bulletkin_painc5(entity this) { set_animofs(this, anim_bulletkin_painc, 5, bulletkin_painc6); }
void bulletkin_painc4(entity this) { set_animofs(this, anim_bulletkin_painc, 4, bulletkin_painc5); }
void bulletkin_painc3(entity this) { set_animofs(this, anim_bulletkin_painc, 3, bulletkin_painc4); }
void bulletkin_painc2(entity this) { set_animofs(this, anim_bulletkin_painc, 2, bulletkin_painc3); monster_footstep(this, false); }
void bulletkin_painc1(entity this) { set_animofs(this, anim_bulletkin_painc, 1, bulletkin_painc2); }

void bulletkin_paind19(entity this) { set_animofs(this, anim_bulletkin_paind, 19, bulletkin_run1); }
void bulletkin_paind18(entity this) { set_animofs(this, anim_bulletkin_paind, 18, bulletkin_paind19); }
void bulletkin_paind17(entity this) { set_animofs(this, anim_bulletkin_paind, 17, bulletkin_paind18); ai_pain(this, 1); }
void bulletkin_paind16(entity this) { set_animofs(this, anim_bulletkin_paind, 16, bulletkin_paind17); ai_pain(this, 1); }
void bulletkin_paind15(entity this) { set_animofs(this, anim_bulletkin_paind, 15, bulletkin_paind16); }
void bulletkin_paind14(entity this) { set_animofs(this, anim_bulletkin_paind, 14, bulletkin_paind15); }
void bulletkin_paind13(entity this) { set_animofs(this, anim_bulletkin_paind, 13, bulletkin_paind14); ai_painforward(this, 1); }
void bulletkin_paind12(entity this) { set_animofs(this, anim_bulletkin_paind, 12, bulletkin_paind13); ai_painforward(this, 1); }
void bulletkin_paind11(entity this) { set_animofs(this, anim_bulletkin_paind, 11, bulletkin_paind12); ai_painforward(this, 1); }
void bulletkin_paind10(entity this) { set_animofs(this, anim_bulletkin_paind, 10, bulletkin_paind11); }
void bulletkin_paind9(entity this) { set_animofs(this, anim_bulletkin_paind, 9, bulletkin_paind10); }
void bulletkin_paind8(entity this) { set_animofs(this, anim_bulletkin_paind, 8, bulletkin_paind9); }
void bulletkin_paind7(entity this) { set_animofs(this, anim_bulletkin_paind, 7, bulletkin_paind8); }
void bulletkin_paind6(entity this) { set_animofs(this, anim_bulletkin_paind, 6, bulletkin_paind7); }
void bulletkin_paind5(entity this) { set_animofs(this, anim_bulletkin_paind, 5, bulletkin_paind6); ai_painforward(this, 1); }
void bulletkin_paind4(entity this) { set_animofs(this, anim_bulletkin_paind, 4, bulletkin_paind5); ai_painforward(this, 2); }
void bulletkin_paind3(entity this) { set_animofs(this, anim_bulletkin_paind, 3, bulletkin_paind4); monster_footstep(this, false); }
void bulletkin_paind2(entity this) { set_animofs(this, anim_bulletkin_paind, 2, bulletkin_paind3); }
void bulletkin_paind1(entity this) { set_animofs(this, anim_bulletkin_paind, 1, bulletkin_paind2); }

void bulletkin_pain(entity this, entity attacker, float damage, int deathtype)
{
	float r = random();
	if(this.pain_finished > time)
		return;

	if(r < 0.5)
		_sound(this, CH_VOICE, "bulletkin/pain1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "bulletkin/pain2.wav", 1, ATTN_NORM);

	if(r < 0.2)
	{
		this.pain_finished = time + 1;
		bulletkin_paina1(this);
	}
	else if(r < 0.4)
	{
		this.pain_finished = time + 1;
		bulletkin_painb1(this);
	}
	else if(r < 0.7)
	{
		this.pain_finished = time + 1;
		bulletkin_painc1(this);
	}
	else
	{
		this.pain_finished = time + 2;
		bulletkin_paind1(this);
	}
}

//============================================================================

void bulletkin_deadtouch(entity this, entity toucher)
{
	if(!CanTouchItem(this, toucher))
		return;

	if(this.ammo_shells && toucher.ammo_shells < GetAmmoLimit(toucher, IT_SHELLS))
	{
		toucher.ammo_shells += this.ammo_shells;
		SendItemPickup(toucher, IT_SHELLS, this.ammo_shells);
		bound_other_ammo(toucher);

		_sound(toucher, CH_TRIGGER_SINGLE, "weapons/lock4.wav", 1, ATTN_NORM);

		delete(this);
	}
}

void bulletkin_dead(entity this)
{
	if(!IS_MONSTER(this))
		return;

	entity item = new(bulletkin_item);
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.ammo_shells = 20;
	set_movetype(item, MOVETYPE_TOSS);
	setorigin(item, this.origin);
	_setmodel(item, this.model);
	setsize(item, this.mins, this.maxs);
	settouch(item, bulletkin_deadtouch);
	item.angles = this.angles;
	item.frame = this.frame;

	Corpse_Fade(item);

	delete(this);
}

void bulletkin_die14(entity this)
{
	set_animofs(this, anim_bulletkin_death, 14, bulletkin_die14);

	bulletkin_dead(this);
}
void bulletkin_die13(entity this) { set_animofs(this, anim_bulletkin_death, 13, bulletkin_die14); }
void bulletkin_die12(entity this) { set_animofs(this, anim_bulletkin_death, 12, bulletkin_die13); ai_forward(this, 5); }
void bulletkin_die11(entity this) { set_animofs(this, anim_bulletkin_death, 11, bulletkin_die12); ai_forward(this, 5); }
void bulletkin_die10(entity this) { set_animofs(this, anim_bulletkin_death, 10, bulletkin_die11); ai_forward(this, 5); }
void bulletkin_die9(entity this) { set_animofs(this, anim_bulletkin_death, 9, bulletkin_die10); ai_forward(this, 3); }
void bulletkin_die8(entity this) { set_animofs(this, anim_bulletkin_death, 8, bulletkin_die9); }
void bulletkin_die7(entity this) { set_animofs(this, anim_bulletkin_death, 7, bulletkin_die8); }
void bulletkin_die6(entity this) { set_animofs(this, anim_bulletkin_death, 6, bulletkin_die7); }
void bulletkin_die5(entity this) { set_animofs(this, anim_bulletkin_death, 5, bulletkin_die6); ai_forward(this, 2); }
void bulletkin_die4(entity this) { set_animofs(this, anim_bulletkin_death, 4, bulletkin_die5); ai_forward(this, 14); }
void bulletkin_die3(entity this) { set_animofs(this, anim_bulletkin_death, 3, bulletkin_die4); }
void bulletkin_die2(entity this) { set_animofs(this, anim_bulletkin_death, 2, bulletkin_die3); }
void bulletkin_die1(entity this) { set_animofs(this, anim_bulletkin_death, 1, bulletkin_die2); this.solid = SOLID_NOT; }

void bulletkin_fdie11(entity this)
{
	set_animofs(this, anim_bulletkin_fdeath, 11, bulletkin_fdie11);

	bulletkin_dead(this);
}
void bulletkin_fdie10(entity this) { set_animofs(this, anim_bulletkin_fdeath, 10, bulletkin_fdie11); }
void bulletkin_fdie9(entity this) { set_animofs(this, anim_bulletkin_fdeath, 9, bulletkin_fdie10); }
void bulletkin_fdie8(entity this) { set_animofs(this, anim_bulletkin_fdeath, 8, bulletkin_fdie9); }
void bulletkin_fdie7(entity this) { set_animofs(this, anim_bulletkin_fdeath, 7, bulletkin_fdie8); }
void bulletkin_fdie6(entity this) { set_animofs(this, anim_bulletkin_fdeath, 6, bulletkin_fdie7); }
void bulletkin_fdie5(entity this) { set_animofs(this, anim_bulletkin_fdeath, 5, bulletkin_fdie6); }
void bulletkin_fdie4(entity this) { set_animofs(this, anim_bulletkin_fdeath, 4, bulletkin_fdie5); }
void bulletkin_fdie3(entity this) { set_animofs(this, anim_bulletkin_fdeath, 3, bulletkin_fdie4); }
void bulletkin_fdie2(entity this) { set_animofs(this, anim_bulletkin_fdeath, 2, bulletkin_fdie3); }
void bulletkin_fdie1(entity this) { set_animofs(this, anim_bulletkin_fdeath, 1, bulletkin_fdie2); this.solid = SOLID_NOT; }

void bulletkin_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			_sound(this, CH_VOICE, "weapons/resist_rocket.wav", 1, ATTN_NORM);
			te_tarexplosion(this.origin);
			entity gib = ThrowGib(this, inflictor, "progs/bullet_casing.mdl", this.health);
			gib.scale = 3;
			gib = ThrowGib(this, inflictor, "progs/bullet_casing.mdl", this.health);
			gib.scale = 3;
			gib = ThrowGib(this, inflictor, "progs/bullet_casing.mdl", this.health);
			gib.scale = 3;
			gib = ThrowGib(this, inflictor, "progs/bullet_casing.mdl", this.health);
			gib.scale = 3;
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

// regular death
	_sound(this, CH_VOICE, "bulletkin/death.wav", 1, ATTN_NORM);
	if(random() > 0.5)
		bulletkin_die1(this);
	else
		bulletkin_fdie1(this);
}

/*QUAKED monster_bulletkin(1 0 0)(-16 -16 -24)(16 16 24) Ambush
*/
spawnfunc(monster_bulletkin) { monster_start(this, true, MON_BULLETKIN); }
#endif // SVQC

#ifdef SVQC
METHOD(BulletKin, mr_setup, bool(BulletKin this, entity actor))
{
	TC(BulletKin, this);

	precache_model("progs/bullet_casing.mdl");

	precache_sound("bulletkin/attack.wav");
	precache_sound("bulletkin/hit.wav");
	precache_sound("weapons/resist_rocket.wav");
	precache_sound("weapons/lock4.wav");

	precache_sound("bulletkin/death.wav");
	precache_sound("bulletkin/pain1.wav");
	precache_sound("bulletkin/pain2.wav");
	precache_sound("bulletkin/sight.wav");

	actor.health = 70;
	actor.gibhealth = -35;
	actor.th_stand = bulletkin_stand1;
	actor.th_walk = bulletkin_walk1;
	actor.th_run = bulletkin_run1;
	actor.th_pain = bulletkin_pain;
	actor.th_die = bulletkin_die;
	actor.th_missile = bulletkin_atk1;

	// Custom feet sounds
	actor.stepc1 = "bulletkin/step1.wav";
	actor.stepc2 = "bulletkin/step2.wav";
	actor.stepc3 = "bulletkin/step3.wav";
	actor.stepc4 = "bulletkin/step4.wav";
	actor.stepc5 = "bulletkin/step1.wav";
	precache_sound(actor.stepc1);
	precache_sound(actor.stepc2);
	precache_sound(actor.stepc3);
	precache_sound(actor.stepc4);
	actor.steptype = FS_TYPECUSTOM;

	return true;
}
METHOD(BulletKin, mr_sight, bool(BulletKin this, entity actor))
{
	TC(BulletKin, this);

	_sound(actor, CH_VOICE, "bulletkin/sight.wav", 1, ATTN_NORM);

	return true;
}
#endif
