#include "grunt.qh"

#ifdef SVQC
const int anim_army_stand = 0; //'0 14 0'
const int anim_army_death = 8; //'8 17 0'
const int anim_army_deathc = 18; //'18 28 0'
const int anim_army_load = 29; //'29 39 0'
const int anim_army_pain = 40; //'40 45 0'
const int anim_army_painb = 46; //'46 59 0'
const int anim_army_painc = 60; //'60 72 0'
const int anim_army_run = 73; //'73 80 0'
const int anim_army_shoot = 81; //'81 191 0'
const int anim_army_prowl = 90; //'90 113 0'

.string mdl_body;
.string mdl_head;

.int variant;
const int GRUNT_SHOTGUN = 0; // default state
const int GRUNT_PISTOL = 1;
const int GRUNT_ROCKET = 2;

void army_idlesound(entity this)
{
	if(IsQBJMap())
	{
		if(random() < 0.08)
		{
			float rs = (random() * 5);
			if(rs < 1)		_sound(this, CH_VOICE, "grunt/soldier_idle_inposition.wav", 1, ATTN_IDLE);
			else if(rs < 2)	_sound(this, CH_VOICE, "grunt/soldier_idle_standingby.wav", 1, ATTN_IDLE);
			else if(rs < 3)	_sound(this, CH_VOICE, "grunt/soldier_idle_ten2.wav", 1, ATTN_IDLE);
			else if(rs < 4)	_sound(this, CH_VOICE, "grunt/soldier_idle_ten4.wav", 1, ATTN_IDLE);
			else			_sound(this, CH_VOICE, "grunt/soldier_idle_unithasnocontact.wav", 1, ATTN_IDLE);
		}
	}
	else if(random() < 0.2)
		_sound(this, CH_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
}

void army_aggrosound(entity this)
{
	if(IsQBJMap())
	{
		if(random() < 0.05 && time > this.show_hostile)
		{
			float rs = (random() * 6);
			if(rs < 1)		_sound(this, CH_VOICE, "grunt/soldier_aggro_breakcover.wav", 1, ATTN_NORM);
			else if(rs < 2)	_sound(this, CH_VOICE, "grunt/soldier_aggro_converging.wav", 1, ATTN_NORM);
			else if(rs < 3)	_sound(this, CH_VOICE, "grunt/soldier_aggro_mobile.wav", 1, ATTN_NORM);
			else if(rs < 4)	_sound(this, CH_VOICE, "grunt/soldier_aggro_movingin.wav", 1, ATTN_NORM);
			else if(rs < 5)	_sound(this, CH_VOICE, "grunt/soldier_aggro_outbreak.wav", 1, ATTN_NORM);
			else			_sound(this, CH_VOICE, "grunt/soldier_aggro_stopresisting.wav", 1, ATTN_NORM);
		}
	}
	else if(random() < 0.2)
		_sound(this, CH_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
}

void army_stand1(entity this);
void army_stand8(entity this) { set_animofs(this, anim_army_stand, 8, army_stand1); ai_stand(this); }
void army_stand7(entity this) { set_animofs(this, anim_army_stand, 7, army_stand8); ai_stand(this); }
void army_stand6(entity this) { set_animofs(this, anim_army_stand, 6, army_stand7); ai_stand(this); }
void army_stand5(entity this) { set_animofs(this, anim_army_stand, 5, army_stand6); ai_stand(this); }
void army_stand4(entity this) { set_animofs(this, anim_army_stand, 4, army_stand5); ai_stand(this); }
void army_stand3(entity this) { set_animofs(this, anim_army_stand, 3, army_stand4); ai_stand(this); }
void army_stand2(entity this) { set_animofs(this, anim_army_stand, 2, army_stand3); ai_stand(this); }
void army_stand1(entity this) { set_animofs(this, anim_army_stand, 1, army_stand2); ai_stand(this); }

void army_walk1(entity this);
void army_walk24(entity this) { set_animofs(this, anim_army_prowl, 24, army_walk1); ai_walk(this, 1); }
void army_walk23(entity this) { set_animofs(this, anim_army_prowl, 23, army_walk24); ai_walk(this, 1); }
void army_walk22(entity this) { set_animofs(this, anim_army_prowl, 22, army_walk23); ai_walk(this, 1); }
void army_walk21(entity this) { set_animofs(this, anim_army_prowl, 21, army_walk22); ai_walk(this, 2); }
void army_walk20(entity this) { set_animofs(this, anim_army_prowl, 20, army_walk21); ai_walk(this, 3); }
void army_walk19(entity this) { set_animofs(this, anim_army_prowl, 19, army_walk20); ai_walk(this, 3); }
void army_walk18(entity this) { set_animofs(this, anim_army_prowl, 18, army_walk19); ai_walk(this, 3); }
void army_walk17(entity this) { set_animofs(this, anim_army_prowl, 17, army_walk18); ai_walk(this, 3); }
void army_walk16(entity this) { set_animofs(this, anim_army_prowl, 16, army_walk17); ai_walk(this, 1); }
void army_walk15(entity this) { set_animofs(this, anim_army_prowl, 15, army_walk16); ai_walk(this, 1); }
void army_walk14(entity this) { set_animofs(this, anim_army_prowl, 14, army_walk15); ai_walk(this, 1); }
void army_walk13(entity this) { set_animofs(this, anim_army_prowl, 13, army_walk14); ai_walk(this, 0); }
void army_walk12(entity this) { set_animofs(this, anim_army_prowl, 12, army_walk13); ai_walk(this, 1); monster_footstep(this, false); }
void army_walk11(entity this) { set_animofs(this, anim_army_prowl, 11, army_walk12); ai_walk(this, 2); }
void army_walk10(entity this) { set_animofs(this, anim_army_prowl, 10, army_walk11); ai_walk(this, 2); }
void army_walk9(entity this) { set_animofs(this, anim_army_prowl, 9, army_walk10); ai_walk(this, 2); }
void army_walk8(entity this) { set_animofs(this, anim_army_prowl, 8, army_walk9); ai_walk(this, 4); }
void army_walk7(entity this) { set_animofs(this, anim_army_prowl, 7, army_walk8); ai_walk(this, 4); }
void army_walk6(entity this) { set_animofs(this, anim_army_prowl, 6, army_walk7); ai_walk(this, 3); }
void army_walk5(entity this) { set_animofs(this, anim_army_prowl, 5, army_walk6); ai_walk(this, 2); }
void army_walk4(entity this) { set_animofs(this, anim_army_prowl, 4, army_walk5); ai_walk(this, 1); }
void army_walk3(entity this) { set_animofs(this, anim_army_prowl, 3, army_walk4); ai_walk(this, 1); }
void army_walk2(entity this) { set_animofs(this, anim_army_prowl, 2, army_walk3); ai_walk(this, 1); }
void army_walk1(entity this)
{
	set_animofs(this, anim_army_prowl, 1, army_walk2);
	army_idlesound(this);
	ai_walk(this, 1);
	monster_footstep(this, false);
}

void army_run1(entity this);
void army_run8(entity this) { set_animofs(this, anim_army_run, 8, army_run1); ai_run(this, 8); }
void army_run7(entity this) { set_animofs(this, anim_army_run, 7, army_run8); ai_run(this, 10); }
void army_run6(entity this) { set_animofs(this, anim_army_run, 6, army_run7); ai_run(this, 15); monster_footstep(this, false); }
void army_run5(entity this) { set_animofs(this, anim_army_run, 5, army_run6); ai_run(this, 8); }
void army_run4(entity this) { set_animofs(this, anim_army_run, 4, army_run5); ai_run(this, 10); }
void army_run3(entity this) { set_animofs(this, anim_army_run, 3, army_run4); ai_run(this, 10); }
void army_run2(entity this) { set_animofs(this, anim_army_run, 2, army_run3); ai_run(this, 15); monster_footstep(this, false); }
void army_run1(entity this)
{
	set_animofs(this, anim_army_run, 1, army_run2);
	army_aggrosound(this);
	ai_run(this, 11);
}

void army_fire(entity this);

void army_atk1(entity this);
void army_atk9(entity this) { set_animofs(this, anim_army_shoot, 8, army_run1); ai_face(this); }
void army_atk8(entity this) { set_animofs(this, anim_army_shoot, 8, army_atk9); ai_face(this); }
void army_atk7(entity this)
{
	set_animofs(this, anim_army_shoot, 7, army_atk8);
	ai_face(this);
}
void army_atk6(entity this) { set_animofs(this, anim_army_shoot, 6, army_atk7); ai_face(this); }
void army_atk5(entity this)
{
	set_animofs(this, anim_army_shoot, 5, army_atk6);
	ai_face(this);
	army_fire(this);
	this.effects |= EF_MUZZLEFLASH;
}
void army_atk4(entity this) { set_animofs(this, anim_army_shoot, 4, army_atk5); ai_face(this); }
void army_atk3(entity this) { set_animofs(this, anim_army_shoot, 3, army_atk4); ai_face(this); }
void army_atk2(entity this) { set_animofs(this, anim_army_shoot, 2, army_atk3); ai_face(this); }
void army_atk1(entity this) { set_animofs(this, anim_army_shoot, 1, army_atk2); ai_face(this); }

void army_pain6(entity this) { set_animofs(this, anim_army_pain, 6, army_run1); ai_pain(this, 1); }
void army_pain5(entity this) { set_animofs(this, anim_army_pain, 5, army_pain6); }
void army_pain4(entity this) { set_animofs(this, anim_army_pain, 4, army_pain5); }
void army_pain3(entity this) { set_animofs(this, anim_army_pain, 3, army_pain4); }
void army_pain2(entity this) { set_animofs(this, anim_army_pain, 2, army_pain3); }
void army_pain1(entity this) { set_animofs(this, anim_army_pain, 1, army_pain2); }

void army_painb14(entity this) { set_animofs(this, anim_army_painb, 14, army_run1); }
void army_painb13(entity this) { set_animofs(this, anim_army_painb, 13, army_painb14); }
void army_painb12(entity this) { set_animofs(this, anim_army_painb, 12, army_painb13); ai_pain(this, 2); }
void army_painb11(entity this) { set_animofs(this, anim_army_painb, 11, army_painb12); monster_footstep(this, false); }
void army_painb10(entity this) { set_animofs(this, anim_army_painb, 10, army_painb11); }
void army_painb9(entity this) { set_animofs(this, anim_army_painb, 9, army_painb10); }
void army_painb8(entity this) { set_animofs(this, anim_army_painb, 8, army_painb9); }
void army_painb7(entity this) { set_animofs(this, anim_army_painb, 7, army_painb8); }
void army_painb6(entity this) { set_animofs(this, anim_army_painb, 6, army_painb7); }
void army_painb5(entity this) { set_animofs(this, anim_army_painb, 5, army_painb6); }
void army_painb4(entity this) { set_animofs(this, anim_army_painb, 4, army_painb5); }
void army_painb3(entity this) { set_animofs(this, anim_army_painb, 3, army_painb4); ai_painforward(this, 9); }
void army_painb2(entity this) { set_animofs(this, anim_army_painb, 2, army_painb3); ai_painforward(this, 13); }
void army_painb1(entity this) { set_animofs(this, anim_army_painb, 1, army_painb2); }

void army_painc13(entity this) { set_animofs(this, anim_army_painc, 13, army_run1); }
void army_painc12(entity this) { set_animofs(this, anim_army_painc, 12, army_painc13); ai_painforward(this, 8); }
void army_painc11(entity this) { set_animofs(this, anim_army_painc, 11, army_painc12); ai_painforward(this, 6); }
void army_painc10(entity this) { set_animofs(this, anim_army_painc, 10, army_painc11); ai_painforward(this, 3); }
void army_painc9(entity this) { set_animofs(this, anim_army_painc, 9, army_painc10); ai_painforward(this, 4); monster_footstep(this, false); }
void army_painc8(entity this) { set_animofs(this, anim_army_painc, 8, army_painc9); ai_pain(this, 1); }
void army_painc7(entity this) { set_animofs(this, anim_army_painc, 7, army_painc8); }
void army_painc6(entity this) { set_animofs(this, anim_army_painc, 6, army_painc7); ai_painforward(this, 1); }
void army_painc5(entity this) { set_animofs(this, anim_army_painc, 5, army_painc6); ai_painforward(this, 1); }
void army_painc4(entity this) { set_animofs(this, anim_army_painc, 4, army_painc5); }
void army_painc3(entity this) { set_animofs(this, anim_army_painc, 3, army_painc4); }
void army_painc2(entity this) { set_animofs(this, anim_army_painc, 2, army_painc3); ai_pain(this, 1); }
void army_painc1(entity this) { set_animofs(this, anim_army_painc, 1, army_painc2); }

void army_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	float r = random();

	if(r < 0.2)
	{
		this.pain_finished = time + 0.6;
		army_pain1(this);
		if(IsQBJMap())
			_sound(this, CH_VOICE, "grunt/soldier_pain1.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "soldier/pain1.wav", 1, ATTN_NORM);
	}
	else if(r < 0.6)
	{
		this.pain_finished = time + 1.1;
		army_painb1(this);
		if(IsQBJMap())
			_sound(this, CH_VOICE, "grunt/soldier_pain2.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "soldier/pain2.wav", 1, ATTN_NORM);
	}
	else
	{
		this.pain_finished = time + 1.1;
		army_painc1(this);
		if(IsQBJMap())
			_sound(this, CH_VOICE, "grunt/soldier_pain3.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "soldier/pain2.wav", 1, ATTN_NORM);
	}
}

void army_fire(entity this)
{
	ai_face(this);

	entity en = this.enemy;
	vector org = this.origin;

	if(this.variant == GRUNT_ROCKET && !IS_PLAYER(this))
		org.z = this.absmin_z + this.size_z * 0.7;
	
	vector dir = ai_shotlead(org, (en.absmin + en.absmax) * 0.5, en.velocity, 900);
	dir = normalize(dir - org);

	switch(this.variant)
	{
		default:
		case GRUNT_SHOTGUN:
		{
			if(IsQBJMap())
				_sound(this, CH_WEAPON_SINGLE, "weapons/shotgn2.wav", 1, ATTN_NORM);
			else
				_sound(this, CH_WEAPON_SINGLE, "soldier/sattck1.wav", 1, ATTN_NORM);
			FireBullets(this, 4, 4, org, dir, '0.1 0.1 0', DEATH_MONSTER_GRUNT.m_id);
			break;
		}
		case GRUNT_ROCKET:
		{
			_sound(this, CH_WEAPON_SINGLE, "weapons/sgun1.wav", 1, ATTN_NORM);

			entity newmis = launch_spike(this, org, dir);
			newmis.noise = "weapons/r_exp3.wav";
			newmis.dmg = 40;
			setsize(newmis, '0 0 0', '0 0 0');
			newmis.velocity = dir * 900;
			settouch(newmis, T_MissileTouch); // rocket explosion
			newmis.projectiledeathtype = DEATH_MONSTER_GRUNT.m_id;

			CSQCProjectile(newmis, true, PROJECTILE_ROCKET, true);
			break;
		}
		case GRUNT_PISTOL:
		{
			_sound(this, CH_WEAPON_SINGLE, "pistol/pistol_fire.wav", 1, ATTN_NORM);

			float bullet_speed = 800 + (autocvar_skill * 150);
			makevectors(this.angles);
			vector src_origin = org;
			if(!IS_PLAYER(this))
				src_origin.z = this.absmin_z + this.size_z * 0.7;

			traceline(src_origin, src_origin + v_forward, MOVE_NORMAL, this);
			src_origin = trace_endpos;

			int shotcount = 1;
			vector spread = '0.05 0.05 0';
			for(int j = 0; j < shotcount; ++j)
			{
				float var_speed = crandom() * 10 + bullet_speed;
				vector spread_dir = dir + (crandom() * spread.x) * v_right + (crandom() * spread.y) * v_up;
				entity missile = launch_spike(this, src_origin, spread_dir);
				missile.classname = "bullet"; // hack
				missile.velocity = spread_dir * var_speed;
				missile.projectiledeathtype = DEATH_MONSTER_GRUNT.m_id;
				missile.dmg = 12;

				CSQCProjectile(missile, true, PROJECTILE_BULLET, true);
			}
			break;
		}
	}
}


void army_die10(entity this)
{
	set_animofs(this, anim_army_death, 10, army_die10);
	CorpseThink(this);
}
void army_die9(entity this) { set_animofs(this, anim_army_death, 9, army_die10); }
void army_die8(entity this) { set_animofs(this, anim_army_death, 8, army_die9); }
void army_die7(entity this) { set_animofs(this, anim_army_death, 7, army_die8); }
void army_die6(entity this) { set_animofs(this, anim_army_death, 6, army_die7); }
void army_die5(entity this) { set_animofs(this, anim_army_death, 5, army_die6); }
void army_die4(entity this) { set_animofs(this, anim_army_death, 4, army_die5); }
void army_die3(entity this) { set_animofs(this, anim_army_death, 3, army_die4); }
void army_die2(entity this) { set_animofs(this, anim_army_death, 2, army_die3); }
void army_die1(entity this) { set_animofs(this, anim_army_death, 1, army_die2); this.solid = SOLID_NOT; }

void army_cdie11(entity this)
{
	set_animofs(this, anim_army_deathc, 11, army_cdie11);
	CorpseThink(this);
}
void army_cdie10(entity this) { set_animofs(this, anim_army_deathc, 10, army_cdie11); }
void army_cdie9(entity this) { set_animofs(this, anim_army_deathc, 9, army_cdie10); }
void army_cdie8(entity this) { set_animofs(this, anim_army_deathc, 8, army_cdie9); }
void army_cdie7(entity this) { set_animofs(this, anim_army_deathc, 7, army_cdie8); }
void army_cdie6(entity this) { set_animofs(this, anim_army_deathc, 6, army_cdie7); ai_back(this, 4); }
void army_cdie5(entity this) { set_animofs(this, anim_army_deathc, 5, army_cdie6); ai_back(this, 3); }
void army_cdie4(entity this) { set_animofs(this, anim_army_deathc, 4, army_cdie5); ai_back(this, 13); }
void army_cdie3(entity this)
{
	set_animofs(this, anim_army_deathc, 3, army_cdie4);
	ai_back(this, 4);
}
void army_cdie2(entity this) { set_animofs(this, anim_army_deathc, 2, army_cdie3); ai_back(this, 5); }
void army_cdie1(entity this) { set_animofs(this, anim_army_deathc, 1, army_cdie2); this.solid = SOLID_NOT; }

void army_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	switch(this.variant)
	{
		default:
		case GRUNT_SHOTGUN: this.ammo_shells = 5; break;
		case GRUNT_ROCKET: this.ammo_rockets = 1; break;
		case GRUNT_PISTOL: this.ammo_shells = 4; break;
	}
	DropBackpack(this);

	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
			if(this.mdl_head != "")
				ThrowGib(this, inflictor, this.mdl_head, this.health);
			else
				ThrowGib(this, inflictor, "progs/h_guard.mdl", this.health);
			if(IsQBJMap())
			{
				ThrowGib(this, inflictor, "progs/gibs/gib_gen_1.mdl", this.health);
				ThrowGib(this, inflictor, "progs/gibs/gib_gen_2.mdl", this.health);
				if(random() < 0.5)
					ThrowGib(this, inflictor, "progs/gibs/gib_gen_3.mdl", this.health);
				else
					ThrowGib(this, inflictor, "progs/gibs/gib_gen_4.mdl", this.health);
				if(random() < 0.5)
					ThrowGib(this, inflictor, "progs/gibs/gib_gen_5.mdl", this.health);
				else
					ThrowGib(this, inflictor, "progs/gibs/gib_gen_6.mdl", this.health);
			}
			else
			{
				ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
				ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
				ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
			}
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

// regular death
	if(IsQBJMap())
	{
		if(random() < 0.5)
			_sound(this, CH_VOICE, "grunt/soldier_death1.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "grunt/soldier_death2.wav", 1, ATTN_NORM);
	}
	else
		_sound(this, CH_VOICE, "soldier/death1.wav", 1, ATTN_NORM);
	if(random() < 0.5)
		army_die1(this);
	else
		army_cdie1(this);
}

/*
===========
SoldierCheckAttack

The player is in view, so decide to move or launch an attack
Returns false if movement should continue
============
*/
bool SoldierCheckAttack(entity this)
{
	entity targ = this.enemy;

	if(this.enemy_range == RANGE_FAR)
		return false;
	if(time < this.attack_finished)
		return false;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, MOVE_NORMAL, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
		return false;	// don't have a clear shot
			
	
// missile attack

	float chance = 0;
	if(this.enemy_range == RANGE_MELEE)
		chance = 0.9;
	else if(this.enemy_range == RANGE_NEAR)
		chance = 0.4;
	else if(this.enemy_range == RANGE_MID)
		chance = 0.05;

	if(random() < chance)
	{
		this.th_missile(this);
		this.attack_finished = time + (1 * random());
		if(random() < 0.3)
			this.lefty = !this.lefty;

		return true;
	}

	return false;
}

/*QUAKED monster_army(1 0 0)(-16 -16 -24)(16 16 40) Ambush
*/
spawnfunc(monster_army)
{
	if(substring(world.model, 0, 9) == "maps/mcj_")
	{
		monster_start(this, true, MON_SKELETON);
		return;
	}

	monster_start(this, true, MON_GRUNT);
}

// alkaline
spawnfunc(monster_nailgrunt) { monster_start(this, true, MON_GRUNT); }

// drake
spawnfunc(monster_ranger) { monster_start(this, true, MON_GRUNT); }

// qbj3
spawnfunc(monster_army_rocket)
{
	this.variant = GRUNT_ROCKET;
	monster_start(this, true, MON_GRUNT);
}
spawnfunc(monster_army_pistol)
{
	this.variant = GRUNT_PISTOL;
	monster_start(this, true, MON_GRUNT);
}

// qzone
spawnfunc(monster_headless) { monster_start(this, true, MON_GRUNT); }
#endif // SVQC

#ifdef SVQC
METHOD(Grunt, mr_setup, bool(Grunt this, entity actor))
{
    TC(Grunt, this);

	precache_model("progs/h_guard.mdl");
	precache_sound("soldier/sattck1.wav");

	precache_sound("player/udeath.wav");		// gib death

	if(IsQBJMap())
	{
		precache_model("progs/gibs/gib_gen_1.mdl");
		precache_model("progs/gibs/gib_gen_2.mdl");
		precache_model("progs/gibs/gib_gen_3.mdl");
		precache_model("progs/gibs/gib_gen_4.mdl");
		precache_model("progs/gibs/gib_gen_5.mdl");
		precache_model("progs/gibs/gib_gen_6.mdl");

		precache_sound("grunt/soldier_aggro_breakcover.wav");
		precache_sound("grunt/soldier_aggro_converging.wav");
		precache_sound("grunt/soldier_aggro_mobile.wav");
		precache_sound("grunt/soldier_aggro_movingin.wav");
		precache_sound("grunt/soldier_aggro_outbreak.wav");
		precache_sound("grunt/soldier_aggro_stopresisting.wav");
		precache_sound("grunt/soldier_death1.wav");
		precache_sound("grunt/soldier_death2.wav");
		precache_sound("grunt/soldier_fireinthehole.wav");
		precache_sound("grunt/soldier_firing.wav");
		precache_sound("grunt/soldier_idle_inposition.wav");
		precache_sound("grunt/soldier_idle_standingby.wav");
		precache_sound("grunt/soldier_idle_ten2.wav");
		precache_sound("grunt/soldier_idle_ten4.wav");
		precache_sound("grunt/soldier_idle_unithasnocontact.wav");
		precache_sound("grunt/soldier_pain1.wav");
		precache_sound("grunt/soldier_pain2.wav");
		precache_sound("grunt/soldier_pain3.wav");
		precache_sound("grunt/soldier_pain4.wav");
		precache_sound("grunt/soldier_sight_contact.wav");
		precache_sound("grunt/soldier_sight_hostile.wav");
		precache_sound("grunt/soldier_sight_target.wav");

		precache_sound("weapons/sgun1.wav");
		precache_sound("weapons/shotgn2.wav");
		precache_sound("weapons/r_exp3.wav");
		precache_sound("pistol/pistol_fire.wav");

		switch(actor.variant)
		{
			default:
			case GRUNT_SHOTGUN: actor.mdl_body = "progs/soldier_shotgun_qbj.mdl"; actor.mdl_head = "progs/gibs/gibhead_grunt_s.mdl"; break;
			case GRUNT_ROCKET: actor.mdl_body = "progs/soldier_rocket_qbj.mdl"; actor.mdl_head = "progs/gibs/gibhead_grunt_r.mdl"; break;
			case GRUNT_PISTOL: actor.mdl_body = "progs/soldier_pistol_qbj.mdl"; actor.mdl_head = "progs/gibs/gibhead_grunt_p.mdl"; break;
		}
	}
	else
	{
		actor.variant = GRUNT_SHOTGUN; // we don't have the assets for other types otherwise!

		precache_model("progs/gib1.mdl");
		precache_model("progs/gib2.mdl");
		precache_model("progs/gib3.mdl");

		precache_sound("soldier/death1.wav");
		precache_sound("soldier/idle.wav");
		precache_sound("soldier/pain1.wav");
		precache_sound("soldier/pain2.wav");
		precache_sound("soldier/sight1.wav");
	}

	if(actor.mdl_head != "")
		precache_model(actor.mdl_head);

	if(actor.mdl_body != "")
	{
		vector oldmin = actor.mins;
		vector oldmax = actor.maxs;
		precache_model(actor.mdl_body);
		_setmodel(actor, actor.mdl_body);
		setsize(actor, oldmin, oldmax);
	}

    actor.health = 30;
    actor.gibhealth = -35;
    actor.th_stand = army_stand1;
	actor.th_walk = army_walk1;
	actor.th_run = army_run1;
	actor.th_missile = army_atk1;
	actor.th_pain = army_pain;
	actor.th_die = army_die;

	actor.checkattack = SoldierCheckAttack;

	actor.steptype = FS_TYPEMEDIUM;

    return true;
}
METHOD(Grunt, mr_sight, bool(Grunt this, entity actor))
{
	TC(Grunt, this);

	if(IsQBJMap())
	{
		float rs = (random() * 3);

		if(rs < 1)
			_sound(actor, CH_VOICE, "grunt/soldier_sight_contact.wav", 1, ATTN_NORM);
		else if(rs < 2)
			_sound(actor, CH_VOICE, "grunt/soldier_sight_hostile.wav", 1, ATTN_NORM);
		else
			_sound(actor, CH_VOICE, "grunt/soldier_sight_target.wav", 1, ATTN_NORM);

		return true;
	}
	_sound(actor, CH_VOICE, "soldier/sight1.wav", 1, ATTN_NORM);

	return true;
}
#endif
