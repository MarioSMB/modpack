#include "elf.qh"

#ifdef SVQC
const int anim_elf_stand = 0;
const int anim_elf_skip = 8;
const int anim_elf_walk = 18;
const int anim_elf_surprise = 30;
const int anim_elf_magic = 37;
const int anim_elf_jump = 49;
const int anim_elf_attack = 57;
const int anim_elf_pain = 62;
const int anim_elf_ambush = 67;
const int anim_elf_bdeath = 79;
const int anim_elf_death = 94;

const int MON_ELF_MAGIC = 2;

/*==============================================================================
XMAS Elf - From Twisted Christmas Mod by Twisted Matrix
==============================================================================*/

void elf_idlesound(entity this)
{
	if(random() < 0.2)
		_sound(this, CH_VOICE, "xmas/elf/idle.wav", 1,  ATTN_IDLE);
}

void elf_stand1(entity this);
void elf_stand8(entity this) { set_animofs(this, anim_elf_stand, 8, elf_stand1); ai_stand(this); }
void elf_stand7(entity this) { set_animofs(this, anim_elf_stand, 7, elf_stand8); ai_stand(this); }
void elf_stand6(entity this) { set_animofs(this, anim_elf_stand, 6, elf_stand7); ai_stand(this); }
void elf_stand5(entity this) { set_animofs(this, anim_elf_stand, 5, elf_stand6); ai_stand(this); }
void elf_stand4(entity this) { set_animofs(this, anim_elf_stand, 4, elf_stand5); ai_stand(this); }
void elf_stand3(entity this) { set_animofs(this, anim_elf_stand, 3, elf_stand4); ai_stand(this); }
void elf_stand2(entity this) { set_animofs(this, anim_elf_stand, 2, elf_stand3); ai_stand(this); }
void elf_stand1(entity this) { set_animofs(this, anim_elf_stand, 1, elf_stand2); elf_idlesound(this); ai_stand(this); }

//======================================================================
void elf_walk1(entity this);
void elf_walk12(entity this) { set_animofs(this, anim_elf_walk, 12, elf_walk1); ai_walk(this, 3); }
void elf_walk11(entity this) { set_animofs(this, anim_elf_walk, 11, elf_walk12); ai_walk(this, 2); }
void elf_walk10(entity this) { set_animofs(this, anim_elf_walk, 10, elf_walk11); ai_walk(this, 0); }
void elf_walk9(entity this) { set_animofs(this, anim_elf_walk, 9, elf_walk10); ai_walk(this, 4); }
void elf_walk8(entity this) { set_animofs(this, anim_elf_walk, 8, elf_walk9); ai_walk(this, 6); }
void elf_walk7(entity this) { set_animofs(this, anim_elf_walk, 7, elf_walk8); ai_walk(this, 10); }
void elf_walk6(entity this) { set_animofs(this, anim_elf_walk, 6, elf_walk7); ai_walk(this, 3); }
void elf_walk5(entity this) { set_animofs(this, anim_elf_walk, 5, elf_walk6); ai_walk(this, 2); }
void elf_walk4(entity this) { set_animofs(this, anim_elf_walk, 4, elf_walk5); ai_walk(this, 0); }
void elf_walk3(entity this) { set_animofs(this, anim_elf_walk, 3, elf_walk4); ai_walk(this, 4); }
void elf_walk2(entity this) { set_animofs(this, anim_elf_walk, 2, elf_walk3); ai_walk(this, 6); }
void elf_walk1(entity this) { set_animofs(this, anim_elf_walk, 1, elf_walk2); elf_idlesound(this); ai_walk(this, 10); }

//======================================================================
void elf_run1(entity this);
void elf_run10(entity this) { set_animofs(this, anim_elf_skip, 10, elf_run1); ai_run(this, 8); }
void elf_run9(entity this) { set_animofs(this, anim_elf_skip, 9, elf_run10); ai_run(this, 12); }
void elf_run8(entity this) { set_animofs(this, anim_elf_skip, 8, elf_run9); ai_run(this, 20); }
void elf_run7(entity this) { set_animofs(this, anim_elf_skip, 7, elf_run8); ai_run(this, 6); }
void elf_run6(entity this) { set_animofs(this, anim_elf_skip, 6, elf_run7); ai_run(this, 1); }
void elf_run5(entity this) { set_animofs(this, anim_elf_skip, 5, elf_run6); ai_run(this, 8); }
void elf_run4(entity this) { set_animofs(this, anim_elf_skip, 4, elf_run5); ai_run(this, 12); }
void elf_run3(entity this) { set_animofs(this, anim_elf_skip, 3, elf_run4); ai_run(this, 20); }
void elf_run2(entity this) { set_animofs(this, anim_elf_skip, 2, elf_run3); ai_run(this, 6); }
void elf_run1(entity this) { set_animofs(this, anim_elf_skip, 1, elf_run2); elf_idlesound(this); ai_run(this, 1); }

//======================================================================
void elf_slide1(entity this);
void elf_slide7(entity this) { set_animofs(this, anim_elf_surprise, 7, elf_run1); ai_run(this, 2); }
void elf_slide6(entity this) { set_animofs(this, anim_elf_surprise, 6, elf_slide7); ai_run_slide(this, 3); }
void elf_slide5(entity this) { set_animofs(this, anim_elf_surprise, 5, elf_slide6); ai_run_slide(this, 4); }
void elf_slide4(entity this) { set_animofs(this, anim_elf_surprise, 4, elf_slide5); ai_run_slide(this, 6); }
void elf_slide3(entity this) { set_animofs(this, anim_elf_surprise, 3, elf_slide4); ai_run_slide(this, 6); }
void elf_slide2(entity this) { set_animofs(this, anim_elf_surprise, 2, elf_slide3); ai_run_slide(this, 4); }
void elf_slide1(entity this) { set_animofs(this, anim_elf_surprise, 1, elf_slide2); ai_run_slide(this, 2); elf_idlesound(this); }

void elf_launch_projectile(entity this, vector org, vector dir)
{
	entity newmis = launch_spike(this, org, dir);
	_setmodel(newmis, "progs/xmas/proj_elfsnow.mdl");
	set_movetype(newmis, MOVETYPE_TOSS);
	//newmis.gravity = 1;
	setsize(newmis, '0 0 0', '0 0 0');
	newmis.frame = rint((random() * 9));
	newmis.dmg = 12;
	newmis.velocity = dir * 600;
	newmis.velocity_z = 200;
	newmis.avelocity = randomvec() * 200;
	newmis.projectiledeathtype = DEATH_MONSTER_ELF.m_id;
}

void elf_shot(entity this, float sideang)
{
	if(!this.enemy || this.health < 1)
		return;

	this.effects |= EF_MUZZLEFLASH;
	if(sideang < 0)
		_sound(this, CH_WEAPON_SINGLE, "xmas/elf/attack1.wav", 1, ATTN_NORM);

	fixedmakevectors(this.angles);
	vector org = this.origin + attack_vector('10 0 4');
	vector vec = v_right * (sideang + (random() * 10));
	vector dir = normalize((this.enemy.origin + vec) - org);
	//vector theang = vectoangles(this.enemy.origin - org);
	//fixedmakevectors(theang);
	//vector dir = (v_forward + v_right * sideang) * 600;

	elf_launch_projectile(this, org, dir);
}

void elf_magic12(entity this) { set_animofs(this, anim_elf_magic, 1, elf_run1); }
void elf_magic11(entity this) { set_animofs(this, anim_elf_magic, 2, elf_magic12); }
void elf_magic10(entity this) { set_animofs(this, anim_elf_magic, 3, elf_magic11); elf_shot(this, 0.1); }
void elf_magic9(entity this) { set_animofs(this, anim_elf_magic, 4, elf_magic10); elf_shot(this, 0); }
void elf_magic8(entity this) { set_animofs(this, anim_elf_magic, 5, elf_magic9); elf_shot(this, -0.1); }
void elf_magic7(entity this) { set_animofs(this, anim_elf_magic, 6, elf_magic8); ai_face(this); }
void elf_magic6(entity this) { set_animofs(this, anim_elf_magic, 7, elf_magic7); ai_face(this); }
void elf_magic5(entity this){ set_animofs(this, anim_elf_magic, 8, elf_magic6); ai_face(this); }
void elf_magic4(entity this) { set_animofs(this, anim_elf_magic, 9, elf_magic5); ai_face(this); }
void elf_magic3(entity this) { set_animofs(this, anim_elf_magic, 10, elf_magic4); ai_face(this); }
void elf_magic2(entity this) { set_animofs(this, anim_elf_magic, 11, elf_magic3); ai_face(this); }
void elf_magic1(entity this)
{
	set_animofs(this, anim_elf_magic, 12, elf_magic2);
	_sound(this, CH_WEAPON_SINGLE, "xmas/elf/magic.wav", 1, ATTN_NORM);
}

void elf_melee(entity this)
{
	if(!this.enemy)
		return;
	if(this.health < 1)
		return;
	if(!this.enemy.takedamage)
		return;
		
	ai_charge(this, 10);
	if(!ai_checkmelee(this, 60, 0))
		return;

	if(random() < 0.5)
		_sound(this, CH_WEAPON_SINGLE, "xmas/elf/cane_hit1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "xmas/elf/cane_hit2.wav", 1, ATTN_NORM);

	// Sack attack is strong (1-60)
	float ldmg = max(1, (random() + random() + random()) * 3);
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_ELF.m_id);

	// Spawn blood at sack
	spawn_touchblood(this, ldmg*3, this.enemy);
}

//----------------------------------------------------------------------
void elf_cane1(entity this);
void elf_cane5(entity this)
{
	set_animofs(this, anim_elf_attack, 5, elf_run1);
	if(ai_checkmelee(this, 60, 0) && this.enemy.health > 0)
	{
		if(this.health > 0)
			setthink(this, elf_cane1);
	}
}
void elf_cane4(entity this) { set_animofs(this, anim_elf_attack, 4, elf_cane5); }
void elf_cane3(entity this) { set_animofs(this, anim_elf_attack, 3, elf_cane4); elf_melee(this); }
void elf_cane2(entity this) { set_animofs(this, anim_elf_attack, 2, elf_cane3); ai_charge(this, 5); }
void elf_cane1(entity this)
{
	set_animofs(this, anim_elf_attack, 1, elf_cane2);
	ai_charge(this, 5);
	if(random() < 0.5)
		_sound(this, CH_WEAPON_SINGLE, "xmas/elf/cane_swipe1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "xmas/elf/cane_swipe2.wav", 1, ATTN_NORM);	
}

void elf_leap7(entity this);
void elf_leap1(entity this);
void Elf_JumpTouch(entity this, entity toucher)
{
	if(this.health <= 0)
		return;
	settouch(this, func_null);			// No more touching
	this.count += 1;	// Total amount of touch jumps
	setthink(this, elf_leap7);

	// Do not damage other elves with jump attacks
	// Prevents packs from killing themselves
	if(this.classname != toucher.classname && toucher.takedamage)
	{
		if(vdist(this.velocity, >, 300))
		{
			float ldmg = 5 + 5*random();
			T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_ELF.m_id);	
			// Spawn some touch blood (no explicit direction)
			spawn_touchblood(this.enemy, ldmg * 3, this.enemy);
		}
	}

	// Is the elf floating in the air?
	if(!t_checkbottom(this))
	{
		// Is the elf standing on something?		
		if(IS_ONGROUND(this))
		{	
			// Do an extra jump if got the count
			if(this.count < 2)
				setthink(this, elf_leap1);
		}
	}

	// Next timer
	this.nextthink = time + 0.1;
}

//----------------------------------------------------------------------
void elf_leap3(entity this);
void elf_leap8(entity this) { set_animofs(this, anim_elf_jump, 8, elf_run1); this.angles_x = this.angles_z = 0; }
void elf_leap7(entity this) { set_animofs(this, anim_elf_jump, 7, elf_leap8); }
void elf_leap6(entity this)
{
	set_animofs(this, anim_elf_jump, 6, elf_leap7);
	// Double check monster is still falling?
	if(this.velocity == '0 0 0' || this.oldorigin == this.origin)
	{
		this.ideal_yaw = random() * 360; //random jump angle
		setthink(this, elf_leap3);
	}
	this.oldorigin = this.origin;
}
void elf_leap5(entity this) { set_animofs(this, anim_elf_jump, 5, elf_leap6); }
void elf_leap4(entity this) { set_animofs(this, anim_elf_jump, 4, elf_leap5); }
void elf_leap3(entity this)
{
	set_animofs(this, anim_elf_jump, 3, elf_leap4);
	ai_face(this);
	this.jump_flag = time + 2; // Stop jumping so much
	settouch(this, Elf_JumpTouch);
	fixedmakevectors(this.angles);
	this.velocity = (v_forward * 400) + ('0 0 1' * 200);
	setorigin(this, this.origin + '0 0 4');
	UNSET_ONGROUND(this);
	this.oldorigin = this.origin;
}
void elf_leap2(entity this) { set_animofs(this, anim_elf_jump, 2, elf_leap3); ai_face(this); }
void elf_leap1(entity this)
{
	set_animofs(this, anim_elf_jump, 1, elf_leap2);
	ai_face(this);
	this.jump_flag = time + 2; // Stop jumping so much
	if(random() < 0.5)
		_sound(this, CH_WEAPON_SINGLE, "xmas/elf/jump1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "xmas/elf/jump2.wav", 1, ATTN_NORM);
}

//----------------------------------------------------------------------

void elf_pain5(entity this) { set_animofs(this, anim_elf_pain, 5, elf_run1); }
void elf_pain4(entity this) { set_animofs(this, anim_elf_pain, 4, elf_pain5); }
void elf_pain3(entity this) { set_animofs(this, anim_elf_pain, 3, elf_pain4); }
void elf_pain2(entity this) { set_animofs(this, anim_elf_pain, 2, elf_pain3); }
void elf_pain1(entity this) { set_animofs(this, anim_elf_pain, 1, elf_pain2); }

void elf_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	_sound(this, CH_VOICE, "xmas/elf/pain.wav", 1, ATTN_NORM);

	if(random() < 0.5)
	{
		this.pain_finished = time + 1;
		elf_pain1(this);
	}
	else
	{
		this.axhitme = false;
		this.pain_finished = time + 1;
		elf_pain1(this);
	}
}

void elf_die9(entity this) { set_animofs(this, anim_elf_death, 9, elf_die9); CorpseThink(this); }
void elf_die8(entity this) { set_animofs(this, anim_elf_death, 8, elf_die9); }
void elf_die7(entity this) { set_animofs(this, anim_elf_death, 7, elf_die8); }
void elf_die6(entity this)
{
	set_animofs(this, anim_elf_death, 6, elf_die7);
	_sound(this, CH_WEAPON_SINGLE, "gibs/gibmetala.wav", 1, ATTN_NORM);
}
void elf_die5(entity this) { set_animofs(this, anim_elf_death, 5, elf_die6); }
void elf_die4(entity this) { set_animofs(this, anim_elf_death, 4, elf_die5); }
void elf_die3(entity this) { set_animofs(this, anim_elf_death, 3, elf_die4); }
void elf_die2(entity this) { set_animofs(this, anim_elf_death, 2, elf_die3); }
void elf_die1(entity this) { set_animofs(this, anim_elf_death, 1, elf_die2); this.solid = SOLID_NOT; }

//----------------------------------------------------------------------
void elf_dieb9(entity this) { set_animofs(this, anim_elf_bdeath, 9, elf_dieb9); CorpseThink(this); }
void elf_dieb8(entity this) { set_animofs(this, anim_elf_bdeath, 8, elf_dieb9); ai_back(this, 4); }
void elf_dieb7(entity this) { set_animofs(this, anim_elf_bdeath, 7, elf_dieb8); }
void elf_dieb6(entity this) { set_animofs(this, anim_elf_bdeath, 6, elf_dieb7); }
void elf_dieb5(entity this) { set_animofs(this, anim_elf_bdeath, 5, elf_dieb6); }
void elf_dieb4(entity this) { set_animofs(this, anim_elf_bdeath, 4, elf_dieb5); }
void elf_dieb3(entity this) { set_animofs(this, anim_elf_bdeath, 3, elf_dieb4); }
void elf_dieb2(entity this) { set_animofs(this, anim_elf_bdeath, 2, elf_dieb3); }
void elf_dieb1(entity this) { set_animofs(this, anim_elf_bdeath, 1, elf_dieb2); this.solid = SOLID_NOT; }

void elf_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(this.health < -20)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, inflictor, "progs/xmas/h_elf.mdl", this.health);
		ThrowGib(this, inflictor, "progs/xmas/gib_elfcane.mdl", this.health);
		for(int j = 0; j < floor(random() * 6); ++j)
		{
			ThrowGib(this, inflictor, "progs/xmas/gib_snowball.mdl", this.health);
		}
		return;
	}

	if(random() < 0.5)
		_sound(this, CHAN_BODY, "xmas/elf/death1.wav", 1, ATTN_NORM);
	else
		_sound(this, CHAN_BODY, "xmas/elf/death2.wav", 1, ATTN_NORM);
	if(random() > 0.5)
		elf_die1(this);
	else
		elf_dieb1(this);
}

/*
===========
ElfCheckAttack

The player is in view, so decide to move or launch an attack
Returns false if movement should continue
============
*/
bool ElfCheckAttack(entity this)
{
	entity targ = this.enemy;

	if(this.enemy_range == RANGE_FAR)
		return false;
	if(time < this.attack_finished)
		return false;

	if(ai_checkmelee(this, 60, 0))
	{
		this.attack_state = AS_MELEE;
		return true;
	}
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, MOVE_NORMAL, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
		return false;	// don't have a clear shot
			
	
// missile attack

	if(this.spawnflags & MON_ELF_MAGIC)
	{
		float chance = 0;
		if(this.enemy_range == RANGE_MELEE)
			chance = 0.9;
		else if(this.enemy_range == RANGE_NEAR)
			chance = 0.6;
		else if(this.enemy_range == RANGE_MID)
			chance = 0.2;

		if(random() < chance && this.th_missile)
		{
			this.th_missile(this);
			this.attack_finished = time + (2 + 2*random());
			return true;
		}
		else if(this.enemy_range == RANGE_MID)
		{
			if(this.attack_state != AS_STRAIGHT)
			{
				this.attack_state = AS_STRAIGHT;
				if(this.th_run)
					this.th_run(this);
			}
		}
		else if(this.attack_state != AS_SLIDING)
		{
			this.attack_state = AS_SLIDING;
			elf_slide1(this);
		}
	}
	else
	{
		// Is it time to jump?
		if(this.jump_flag < time)
		{
			// Stop the elf over or under jumping the enemy
			if(this.origin_z + this.mins_z > this.enemy.origin_z + this.enemy.mins_z + 0.75 * this.enemy.size_z)
				return false;
			if(this.origin_z + this.maxs_z < this.enemy.origin_z + this.enemy.mins_z + 0.25 * this.enemy.size_z)
				return false;

			if(vdist(this.enemy.origin - this.origin, <, 80))
				return false;
			if(vdist(this.enemy.origin - this.origin, >, 200))
				return false;
			if(this.enemy.origin_z > this.origin_z)
				return false;
			elf_leap1(this);
			return true;
		}
	}

	return false;
}

/*======================================================================
QUAKED monster_xmas_elf (1 0 0) (-16 -16 -24) (16 16 16) Ambush
======================================================================*/
spawnfunc(monster_xmas_elf) { monster_start(this, true, MON_ELF); }
#endif // SVQC

#ifdef SVQC
METHOD(Elf, mr_setup, bool(Elf this, entity actor))
{
    TC(Elf, this);

	precache_model("progs/xmas/gib_elfcane.mdl");
	precache_model("progs/xmas/gib_snowball.mdl");

	precache_model("progs/xmas/proj_elfsnow.mdl");

	precache_sound("xmas/elf/idle.wav");

	precache_sound("gibs/gibmetala.wav");

	// Elf 1 - Melee/Jump attacks - cane impacts
	precache_sound("xmas/elf/cane_swipe1.wav");
	precache_sound("xmas/elf/cane_swipe2.wav");
	precache_sound("xmas/elf/cane_hit1.wav");
	precache_sound("xmas/elf/cane_hit2.wav");
	precache_sound("xmas/elf/jump1.wav");
	precache_sound("xmas/elf/jump2.wav");
	
	// Elf 2 - Magic attacks
	precache_sound("xmas/elf/magic.wav");
	precache_sound("xmas/elf/attack1.wav");
	precache_sound("xmas/elf/miss.wav");

	precache_sound("xmas/elf/pain.wav");
	precache_sound("xmas/elf/death1.wav");
	precache_sound("xmas/elf/death2.wav");

	if(random() <= 0.33)
		actor.spawnflags |= MON_ELF_MAGIC;

	if(actor.spawnflags & MON_ELF_MAGIC)
	{
		actor.health = 75;
		actor.th_missile = elf_magic1;
		actor.skin = 2;
	}
	else
	{
		actor.health = 30;
		//actor.th_missile = elf_leap1;
		if(random() < 0.5)
			actor.skin = 1;
		else
			actor.skin = 0;
	}

	actor.checkattack = ElfCheckAttack;
	actor.th_stand = elf_stand1;
	actor.th_walk = elf_walk1;
	actor.th_run = elf_run1;
	actor.th_melee = elf_cane1;
	actor.th_pain = elf_pain;
	actor.th_die = elf_die;

    return true;
}
METHOD(Elf, mr_sight, bool(Elf this, entity actor))
{
    TC(Elf, this);

	sound(actor, CH_VOICE, SND_MON_ELF_SIGHT_RANDOM(), 1, ATTN_NORM);

    return true;
}
#endif
