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
		if(time > this.show_hostile && random() < 0.05)
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

void army_stand1(entity this)
{
	monster_animate(this, anim_army_stand, 8, army_stand1, army_stand1);

	ai_stand(this);
}

void army_walk1(entity this)
{
	monster_animate(this, anim_army_prowl, 24, army_walk1, army_walk1);

	float mspeed = 1;
	switch(this.walkframe + 1)
	{
		case 1: monster_footstep(this, false); army_idlesound(this); break;
		case 5: mspeed = 2; break;
		case 6: mspeed = 3; break;
		case 7:
		case 8: mspeed = 4; break;
		case 9:
		case 10:
		case 11: mspeed = 2; break;
		case 12: monster_footstep(this, false); break;
		case 13: mspeed = 0; break;
		case 17:
		case 18:
		case 18:
		case 20: mspeed = 3; break;
		case 21: mspeed = 2; break;
	}

	ai_walk(this, mspeed);
}

void army_run1(entity this)
{
	monster_animate(this, anim_army_run, 8, army_run1, army_run1);

	float mspeed = 11;
	switch(this.walkframe + 1)
	{
		case 1: army_aggrosound(this); break;
		case 2: mspeed = 15; monster_footstep(this, false); break;
		case 3:
		case 4: mspeed = 10; break;
		case 5: mspeed = 8; break;
		case 6: mspeed = 15; monster_footstep(this, false); break;
		case 7: mspeed = 10; break;
		case 8: mspeed = 8; break;
	}

	ai_run(this, mspeed);
}

void army_fire(entity this);
void army_atk1(entity this)
{
	monster_animate(this, anim_army_shoot, 9, army_atk1, army_run1);

	ai_face(this);

	switch(this.walkframe + 1)
	{
		case 5: army_fire(this); this.effects |= EF_MUZZLEFLASH; break;
	}
}

void army_pain1(entity this)
{
	monster_animate(this, anim_army_pain, 6, army_pain1, army_run1);

	switch(this.walkframe + 1)
	{
		case 6: ai_pain(this, 1); break;
	}
}

void army_painb1(entity this)
{
	monster_animate(this, anim_army_painb, 14, army_painb1, army_run1);

	switch(this.walkframe + 1)
	{
		case 2: ai_painforward(this, 13); break;
		case 3: ai_painforward(this, 9); break;
		case 11: monster_footstep(this, false); break;
		case 12: ai_pain(this, 2); break;
	}
}

void army_painc1(entity this)
{
	monster_animate(this, anim_army_painc, 13, army_painc1, army_run1);

	switch(this.walkframe + 1)
	{
		case 2: ai_pain(this, 1); break;
		case 5:
		case 6: ai_painforward(this, 1); break;
		case 8: ai_pain(this, 1); break;
		case 9: ai_painforward(this, 4); monster_footstep(this, false); break;
		case 10: ai_painforward(this, 3); break;
		case 11: ai_painforward(this, 6); break;
		case 12: ai_painforward(this, 8); break;
	}
}

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

void army_die1(entity this)
{
	monster_animate(this, anim_army_death, 10, army_die1, CorpseThink);
}

void army_cdie1(entity this)
{
	monster_animate(this, anim_army_deathc, 11, army_cdie1, CorpseThink);

	switch(this.walkframe + 1)
	{
		case 2: ai_back(this, 5); break;
		case 3: ai_back(this, 4); break;
		case 4: ai_back(this, 13); break;
		case 5: ai_back(this, 3); break;
		case 6: ai_back(this, 4); break;
	}
}

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

	this.solid = SOLID_NOT;
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

	if(this.th_missile && random() < chance)
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
