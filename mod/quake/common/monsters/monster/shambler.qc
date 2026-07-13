#include "shambler.qh"

#ifdef SVQC
const int anim_sham_stand = 0; //'0 16 0'
const int anim_sham_walk = 17; //'17 28 0'
const int anim_sham_run = 29; //'29 34 0'
const int anim_sham_smash = 35; //'35 46 0'
const int anim_sham_swingr = 47; //'47 55 0'
const int anim_sham_swingl = 56; //'47 64 0'
const int anim_sham_magic = 65; //'65 76 0'
const int anim_sham_pain = 77; //'77 82 0'
const int anim_sham_death = 83; //'83 93 0'

const int MON_SHAMBLER_COOKIE = BIT(1);

void sham_stand1(entity this);
void sham_stand17(entity this) { set_animofs(this, anim_sham_stand, 17, sham_stand1); ai_stand(this); }
void sham_stand16(entity this) { set_animofs(this, anim_sham_stand, 16, sham_stand17); ai_stand(this); }
void sham_stand15(entity this) { set_animofs(this, anim_sham_stand, 15, sham_stand16); ai_stand(this); }
void sham_stand14(entity this) { set_animofs(this, anim_sham_stand, 14, sham_stand15); ai_stand(this); }
void sham_stand13(entity this) { set_animofs(this, anim_sham_stand, 13, sham_stand14); ai_stand(this); }
void sham_stand12(entity this) { set_animofs(this, anim_sham_stand, 12, sham_stand13); ai_stand(this); }
void sham_stand11(entity this) { set_animofs(this, anim_sham_stand, 11, sham_stand12); ai_stand(this); }
void sham_stand10(entity this) { set_animofs(this, anim_sham_stand, 10, sham_stand11); ai_stand(this); }
void sham_stand9(entity this) { set_animofs(this, anim_sham_stand, 9, sham_stand10); ai_stand(this); }
void sham_stand8(entity this) { set_animofs(this, anim_sham_stand, 8, sham_stand9); ai_stand(this); }
void sham_stand7(entity this) { set_animofs(this, anim_sham_stand, 7, sham_stand8); ai_stand(this); }
void sham_stand6(entity this) { set_animofs(this, anim_sham_stand, 6, sham_stand7); ai_stand(this); }
void sham_stand5(entity this) { set_animofs(this, anim_sham_stand, 5, sham_stand6); ai_stand(this); }
void sham_stand4(entity this) { set_animofs(this, anim_sham_stand, 4, sham_stand5); ai_stand(this); }
void sham_stand3(entity this) { set_animofs(this, anim_sham_stand, 3, sham_stand4); ai_stand(this); }
void sham_stand2(entity this) { set_animofs(this, anim_sham_stand, 2, sham_stand3); ai_stand(this); }
void sham_stand1(entity this) { set_animofs(this, anim_sham_stand, 1, sham_stand2); ai_stand(this); }

void sham_walk1(entity this);
void sham_walk12(entity this)
{
	set_animofs(this, anim_sham_walk, 12, sham_walk1);
	ai_walk(this, 7);
	if(random() > 0.8)
		_sound(this, CH_VOICE, "shambler/sidle.wav", 1, ATTN_IDLE);
}
void sham_walk11(entity this) { set_animofs(this, anim_sham_walk, 11, sham_walk12); ai_walk(this, 7); }
void sham_walk10(entity this) { set_animofs(this, anim_sham_walk, 10, sham_walk11); ai_walk(this, 9); }
void sham_walk9(entity this) { set_animofs(this, anim_sham_walk, 9, sham_walk10); ai_walk(this, 13); }
void sham_walk8(entity this) { set_animofs(this, anim_sham_walk, 8, sham_walk9); ai_walk(this, 3); }
void sham_walk7(entity this) { set_animofs(this, anim_sham_walk, 7, sham_walk8); ai_walk(this, 8); monster_footstep(this, false); }
void sham_walk6(entity this) { set_animofs(this, anim_sham_walk, 6, sham_walk7); ai_walk(this, 12); }
void sham_walk5(entity this) { set_animofs(this, anim_sham_walk, 5, sham_walk6); ai_walk(this, 6); }
void sham_walk4(entity this) { set_animofs(this, anim_sham_walk, 4, sham_walk5); ai_walk(this, 5); }
void sham_walk3(entity this) { set_animofs(this, anim_sham_walk, 3, sham_walk4); ai_walk(this, 9); }
void sham_walk2(entity this) { set_animofs(this, anim_sham_walk, 2, sham_walk3); ai_walk(this, 9); monster_footstep(this, false); }
void sham_walk1(entity this) { set_animofs(this, anim_sham_walk, 1, sham_walk2); ai_walk(this, 10); }

void sham_run1(entity this);
void sham_run6(entity this)
{
	set_animofs(this, anim_sham_run, 6, sham_run1);
	ai_run(this, 20);
	if(random() > 0.8)
		_sound(this, CH_VOICE, "shambler/sidle.wav", 1, ATTN_IDLE);
}
void sham_run5(entity this) { set_animofs(this, anim_sham_run, 5, sham_run6); ai_run(this, 24); monster_footstep(this, false); }
void sham_run4(entity this) { set_animofs(this, anim_sham_run, 4, sham_run5); ai_run(this, 20); }
void sham_run3(entity this) { set_animofs(this, anim_sham_run, 3, sham_run4); ai_run(this, 20); }
void sham_run2(entity this) { set_animofs(this, anim_sham_run, 2, sham_run3); ai_run(this, 24); monster_footstep(this, false); }
void sham_run1(entity this) { set_animofs(this, anim_sham_run, 1, sham_run2); ai_run(this, 20); }

void sham_smash12(entity this) { set_animofs(this, anim_sham_smash, 12, sham_run1); ai_charge(this, 4); }
void sham_smash11(entity this) { set_animofs(this, anim_sham_smash, 11, sham_smash12); ai_charge(this, 5); }
void sham_smash10(entity this)
{
	set_animofs(this, anim_sham_smash, 10, sham_smash11);
	if(!this.enemy)
		return;
	ai_charge(this, 0);

	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;
		
	float ldmg =(random() + random() + random()) * 40;
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_SHAMBLER.m_id);
	if(this.spawnflags & MON_SHAMBLER_COOKIE)
		_sound(this, CH_VOICE, "shambler/nomnom.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "shambler/smack.wav", 1, ATTN_NORM);

	SpawnMeatSpray(this, this.enemy.origin + '0 0 16' + v_forward*-16, crandom() * 100 * v_right);
	SpawnMeatSpray(this, this.enemy.origin + '0 0 16' + v_forward*-16, crandom() * 100 * v_right);
}
void sham_smash9(entity this) { set_animofs(this, anim_sham_smash, 9, sham_smash10); ai_charge(this, 0); }
void sham_smash8(entity this) { set_animofs(this, anim_sham_smash, 8, sham_smash9); ai_charge(this, 0); }
void sham_smash7(entity this) { set_animofs(this, anim_sham_smash, 7, sham_smash8); ai_charge(this, 0); }
void sham_smash6(entity this) { set_animofs(this, anim_sham_smash, 6, sham_smash7); ai_charge(this, 1); }
void sham_smash5(entity this) { set_animofs(this, anim_sham_smash, 5, sham_smash6); ai_charge(this, 4); }
void sham_smash4(entity this) { set_animofs(this, anim_sham_smash, 4, sham_smash5); ai_charge(this, 5); }
void sham_smash3(entity this) { set_animofs(this, anim_sham_smash, 3, sham_smash4); ai_charge(this, 6); }
void sham_smash2(entity this) { set_animofs(this, anim_sham_smash, 2, sham_smash3); ai_charge(this, 6); monster_footstep(this, false); }
void sham_smash1(entity this)
{
	set_animofs(this, anim_sham_smash, 1, sham_smash2);
	_sound(this, CH_VOICE, "shambler/melee1.wav", 1, ATTN_NORM);
	ai_charge(this, 2);
}

void sham_swingr1(entity this);

void ShamClaw(entity this, float side)
{
	if(!this.enemy)
		return;
	ai_charge(this, 10);

	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
		
	float ldmg =(random() + random() + random()) * 20;
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_SHAMBLER.m_id);
	if(this.spawnflags & MON_SHAMBLER_COOKIE)
		_sound(this, CH_VOICE, "shambler/nomnom.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "shambler/smack.wav", 1, ATTN_NORM);

	if(side != 0)
	{
		fixedmakevectors(this.angles);
		SpawnMeatSpray(this, this.enemy.origin + '0 0 16' + v_forward*-16, side * v_right);
	}
}

void sham_swingl9(entity this)
{
	set_animofs(this, anim_sham_swingl, 9, sham_run1); 
	ai_charge(this, 8);
	if(random()<0.5)
		setthink(this, sham_swingr1);
}
void sham_swingl8(entity this) { set_animofs(this, anim_sham_swingl, 8, sham_swingl9); ai_charge(this, 4); }
void sham_swingl7(entity this)
{
	set_animofs(this, anim_sham_swingl, 7, sham_swingl8);
	ai_charge(this, 5);
	ShamClaw(this, 250);
}
void sham_swingl6(entity this) { set_animofs(this, anim_sham_swingl, 6, sham_swingl7); ai_charge(this, 9); }
void sham_swingl5(entity this) { set_animofs(this, anim_sham_swingl, 5, sham_swingl6); ai_charge(this, 7); }
void sham_swingl4(entity this) { set_animofs(this, anim_sham_swingl, 4, sham_swingl5); ai_charge(this, 3); }
void sham_swingl3(entity this) { set_animofs(this, anim_sham_swingl, 3, sham_swingl4); ai_charge(this, 7); }
void sham_swingl2(entity this) { set_animofs(this, anim_sham_swingl, 2, sham_swingl3); ai_charge(this, 3); monster_footstep(this, false); }
void sham_swingl1(entity this)
{
	set_animofs(this, anim_sham_swingl, 1, sham_swingl2); 
	_sound(this, CH_VOICE, "shambler/melee2.wav", 1, ATTN_NORM);
	ai_charge(this, 5);
}

void sham_swingr9(entity this)
{
	set_animofs(this, anim_sham_swingr, 9, sham_run1);
	//ai_charge(this, 1);
	ai_charge(this, 10);
	if(random() < 0.5)
		setthink(this, sham_swingl1);
}
void sham_swingr8(entity this) { set_animofs(this, anim_sham_swingr, 8, sham_swingr9); ai_charge(this, 3); }
void sham_swingr7(entity this)
{
	set_animofs(this, anim_sham_swingr, 7, sham_swingr8);
	ai_charge(this, 6);
	ShamClaw(this, -250);
}
void sham_swingr6(entity this) { set_animofs(this, anim_sham_swingr, 6, sham_swingr7); ai_charge(this, 6); }
void sham_swingr5(entity this) { set_animofs(this, anim_sham_swingr, 5, sham_swingr6); ai_charge(this, 3); }
void sham_swingr4(entity this) { set_animofs(this, anim_sham_swingr, 4, sham_swingr5); ai_charge(this, 7); }
void sham_swingr3(entity this) { set_animofs(this, anim_sham_swingr, 3, sham_swingr4); ai_charge(this, 14); }
void sham_swingr2(entity this) { set_animofs(this, anim_sham_swingr, 2, sham_swingr3); ai_charge(this, 8); monster_footstep(this, false); }
void sham_swingr1(entity this)
{
	set_animofs(this, anim_sham_swingr, 1, sham_swingr2); 
	_sound(this, CH_VOICE, "shambler/melee1.wav", 1, ATTN_NORM);
	ai_charge(this, 1);
}

void sham_melee(entity this)
{
	float chance = random();
	if(chance > 0.6 || this.health == 600)
		sham_smash1(this);
	else if(chance > 0.3)
		sham_swingr1(this);
	else
		sham_swingl1(this);
}


//============================================================================

void CastCookie(entity this)
{
	vector offang = vectoangles(this.enemy.origin - this.origin);
	
	makevectors(offang);

	vector org = this.origin + v_up * 30 + v_forward * 30 + v_right * 8.5 + '0 0 1';

// set missile speed
	vector vec = normalize (v_forward);
	vec.z = 0 - vec.z + (random() - 0.5)*0.1;
	
	entity newmis = launch_spike(this, org, vec);
	settouch(newmis, T_MissileTouch);
	newmis.dmg = 20;
	newmis.projectiledeathtype = DEATH_MONSTER_SHAMBLER.m_id;
	setsize(newmis, '0 0 0', '0 0 0');		
	newmis.velocity = vec*300;
	_sound(this, CH_WEAPON_SINGLE, "hknight/attack1.wav", 1, ATTN_NORM);

	CSQCProjectile(newmis, true, PROJECTILE_COOKIE, true);
}

void CastLightning(entity this)
{
	if(this.spawnflags & MON_SHAMBLER_COOKIE)
	{
		CastCookie(this);
		return;
	}

	int cont = Mod_Q1BSP_SuperContentsFromNativeContents(pointcontents(this.origin));
	if(cont & DPCONTENTS_LIQUIDSMASK)
	{
		T_RadiusDamage(this, this, 35 * 10, DEATH_DISCHARGE.m_id, NULL);
		return;
	}

	this.effects |= EF_MUZZLEFLASH;

	ai_face(this);

	vector org = this.origin + '0 0 40';

	vector dir = this.enemy.origin + '0 0 16' - org;
	dir = normalize(dir);

	traceline(org, this.origin + dir*600, true, this);

	//te_lightning1(NULL, org, trace_endpos); // TODO: entity breaks
	SendCSQCLightningBeam(org, trace_endpos);

	// Check for any breakables first
	if(ai_foundbreakable(this, trace_ent, false))
		T_Damage(trace_ent, this, this, 80, DEATH_MONSTER_SHAMBLER.m_id);
	else
		LightningDamage(org, trace_endpos, this, 10, DEATH_MONSTER_SHAMBLER.m_id);
}

void sham_magic12(entity this) { set_animofs(this, anim_sham_magic, 12, sham_run1); }
void sham_magic11(entity this) { set_animofs(this, anim_sham_magic, 11, sham_magic12); }
void sham_magic10(entity this) { set_animofs(this, anim_sham_magic, 10, sham_magic11); CastLightning(this); monster_footstep(this, false); }
void sham_magic9(entity this) { set_animofs(this, anim_sham_magic, 9, sham_magic10); CastLightning(this); }
void sham_magic6(entity this)
{
	set_animofs(this, anim_sham_magic, 6, sham_magic9);
	if(this.attachment)
		delete(this.attachment);
	this.attachment = NULL;
	CastLightning(this);
	if(season != SEASON_XMAS && !(this.spawnflags & MON_SHAMBLER_COOKIE) && IsQBJMap())
		_sound(this, CH_WEAPON_SINGLE, "shambler/shambler_sboom.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "shambler/sboom.wav", 1, ATTN_NORM);
}
void sham_magic5(entity this)
{
	set_animofs(this, anim_sham_magic, 5, sham_magic6);
	this.effects |= EF_MUZZLEFLASH;
	this.attachment.frame = 2;
}
void sham_magic4(entity this)
{
	set_animofs(this, anim_sham_magic, 4, sham_magic5);
	this.effects |= EF_MUZZLEFLASH;
	this.attachment.frame = 1;
	monster_footstep(this, false);
}
void sham_magic3(entity this)
{
	set_animofs(this, anim_sham_magic, 3, sham_magic4);
	ai_face(this);
	this.nextthink = this.nextthink + 0.2;

	this.effects |= EF_MUZZLEFLASH;
	entity o = spawn();
	this.attachment = o;
	_setmodel(o, "progs/s_light.mdl");
	setorigin(o, this.origin);
	o.angles = this.angles;
	o.nextthink = time + 0.7;
	setthink(o, SUB_Remove);
}
void sham_magic2(entity this) { set_animofs(this, anim_sham_magic, 2, sham_magic3); ai_face(this); }
void sham_magic1(entity this)
{
	set_animofs(this, anim_sham_magic, 1, sham_magic2);
	ai_face(this);
	if(season != SEASON_XMAS && !(this.spawnflags & MON_SHAMBLER_COOKIE) && IsQBJMap())
		_sound(this, CH_WEAPON_SINGLE, "shambler/shambler_sattck1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "shambler/sattck1.wav", 1, ATTN_NORM);
}

void sham_pain6(entity this) { set_animofs(this, anim_sham_pain, 6, sham_run1); }
void sham_pain5(entity this) { set_animofs(this, anim_sham_pain, 5, sham_pain6); }
void sham_pain4(entity this) { set_animofs(this, anim_sham_pain, 4, sham_pain5); }
void sham_pain3(entity this) { set_animofs(this, anim_sham_pain, 3, sham_pain4); }
void sham_pain2(entity this) { set_animofs(this, anim_sham_pain, 2, sham_pain3); }
void sham_pain1(entity this) { set_animofs(this, anim_sham_pain, 1, sham_pain2); }

void sham_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.health <= 0)
		return;		// already dying, don't go into pain frame
	if(this.pain_finished > time)
		return;
	this.pain_finished = time; // incase we return early, prevent same-frame spam

	if(this.spawnflags & MON_SHAMBLER_COOKIE)
		_sound(this, CH_VOICE, "shambler/cookie_hurt.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "shambler/shurt2.wav", 1, ATTN_NORM);

	if(random()*400 > damage)
		return;		// didn't flinch

	this.pain_finished = time + 2;
		
	sham_pain1(this);
}


//============================================================================


void sham_death11(entity this)
{
	set_animofs(this, anim_sham_death, 11, sham_death11);
	CorpseThink(this);
}
void sham_death10(entity this) { set_animofs(this, anim_sham_death, 10, sham_death11); }
void sham_death9(entity this) { set_animofs(this, anim_sham_death, 9, sham_death10); }
void sham_death8(entity this) { set_animofs(this, anim_sham_death, 8, sham_death9); }
void sham_death7(entity this) { set_animofs(this, anim_sham_death, 7, sham_death8); }
void sham_death6(entity this) { set_animofs(this, anim_sham_death, 6, sham_death7); }
void sham_death5(entity this) { set_animofs(this, anim_sham_death, 5, sham_death6); }
void sham_death4(entity this) { set_animofs(this, anim_sham_death, 4, sham_death5); }
void sham_death3(entity this) { set_animofs(this, anim_sham_death, 3, sham_death4); }
void sham_death2(entity this) { set_animofs(this, anim_sham_death, 2, sham_death3); }
void sham_death1(entity this) { set_animofs(this, anim_sham_death, 1, sham_death2); this.solid = SOLID_NOT; }

void sham_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	if(killed_type == KILLED_NORMAL && this.dmg_take > (this.max_health * 0.6))
		killed_type = KILLED_GIBBED;
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			bool is_qbj3sham = (season != SEASON_XMAS && !(this.spawnflags & MON_SHAMBLER_COOKIE) && IsQBJMap());
			_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
			if(season == SEASON_XMAS)
				ThrowGib(this, inflictor, "progs/h_shams_xmas.mdl", this.health);
			else if(is_qbj3sham)
			{
				if(random() <= 0.05)
					ThrowGib(this, inflictor, "progs/gibs/gib_shambler_6.mdl", this.health);
				else
					ThrowGib(this, inflictor, "progs/gibs/gibhead_shambler.mdl", this.health);
			}
			else
				ThrowGib(this, inflictor, "progs/h_shams.mdl", this.health);
			if(is_qbj3sham)
			{
				ThrowGib(this, inflictor, "progs/gibs/gib_shambler_1.mdl", this.health);
				ThrowGib(this, inflictor, "progs/gibs/gib_shambler_3.mdl", this.health);
				float r = random();
				if(r < 0.2)
					ThrowGib(this, inflictor, "progs/gibs/gib_shambler_2.mdl", this.health);
				else if(r < 0.6)
					ThrowGib(this, inflictor, "progs/gibs/gib_shambler_4.mdl", this.health);
				else
					ThrowGib(this, inflictor, "progs/gibs/gib_shambler_5.mdl", this.health);
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
	if(season == SEASON_XMAS)
		_sound(this, CH_VOICE, "shambler/sdeath_xmas.wav", 1, ATTN_NORM);
	else if(this.spawnflags & MON_SHAMBLER_COOKIE)
		_sound(this, CH_VOICE, "shambler/cookie_die.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "shambler/sdeath.wav", 1, ATTN_NORM);
	sham_death1(this);
}

/*
===========
ShamCheckAttack

The player is in view, so decide to move or launch an attack
Returns false if movement should continue
============
*/
bool ShamCheckAttack(entity this)
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
		
	this.attack_state = AS_MISSILE;
	this.attack_finished = time + (2 * 2 * random());
	return true;
}

/*QUAKED monster_shambler(1 0 0)(-32 -32 -24)(32 32 64) Ambush
*/
spawnfunc(monster_shambler)
{
	if(substring(world.model, 0, 9) == "maps/mcj_")
	{
		monster_start(this, true, MON_WARDEN);
		return;
	}

	if(coop == 2 && orig_random(this) < 0.2)
	{
		if(orig_random(this) < 0.1)
			monster_start(this, true, MON_BLUD);
		else
			monster_start(this, true, MON_JUGGERNAUT);
		return;
	}
	monster_start(this, true, MON_SHAMBLER);
}
#endif // SVQC

#ifdef SVQC
METHOD(Shambler, mr_setup, bool(Shambler this, entity actor))
{
	TC(Shambler, this);

	precache_model("progs/h_shams.mdl");
	precache_model("progs/s_light.mdl");
	precache_model("progs/bolt.mdl");
	
	precache_sound("shambler/sattck1.wav");
	precache_sound("shambler/sboom.wav");
	precache_sound("shambler/sdeath.wav");
	precache_sound("shambler/shurt2.wav");
	precache_sound("shambler/sidle.wav");
	precache_sound("shambler/melee1.wav");
	precache_sound("shambler/melee2.wav");
	precache_sound("shambler/smack.wav");
	precache_sound("shambler/ssight.wav");

	if(autocvar_skill == 3 && random() <= 0.25)
		actor.spawnflags |= MON_SHAMBLER_COOKIE;

	if(season == SEASON_XMAS)
	{
		actor.spawnflags &= ~MON_SHAMBLER_COOKIE;
		precache_model("progs/h_shams_xmas.mdl");
		precache_model("progs/shambler_xmas.mdl");
		precache_sound("shambler/ssight_xmas.wav");
		precache_sound("shambler/sdeath_xmas.wav");

		_setmodel(actor, "progs/shambler_xmas.mdl");
		setsize(actor, this.m_mins, this.m_maxs);
	}
	else if(actor.spawnflags & MON_SHAMBLER_COOKIE)
	{
		precache_sound("hknight/attack1.wav");
		precache_sound("shambler/cookie_die.wav");
		precache_sound("shambler/cookie_hurt.wav");
		precache_sound("shambler/nomnom.wav");
		precache_sound("shambler/cookie.wav");
		precache_model("progs/cookie.mdl");

		precache_model("progs/shambler_cookie_creature.mdl");
		_setmodel(actor, "progs/shambler_cookie_creature.mdl");
		setsize(actor, this.m_mins, this.m_maxs);
	}
	else if(IsQBJMap())
	{
		precache_model("progs/shambler_qbj.mdl");
		precache_model("progs/gibs/gib_shambler_1.mdl");
		precache_model("progs/gibs/gib_shambler_2.mdl");
		precache_model("progs/gibs/gib_shambler_3.mdl");
		precache_model("progs/gibs/gib_shambler_4.mdl");
		precache_model("progs/gibs/gib_shambler_5.mdl");
		precache_model("progs/gibs/gib_shambler_6.mdl");
		precache_model("progs/gibs/gibhead_shambler.mdl");

		precache_sound("shambler/shambler_sattck1.wav");
		precache_sound("shambler/shambler_sboom.wav");

		_setmodel(actor, "progs/shambler_qbj.mdl");
		setsize(actor, this.m_mins, this.m_maxs);
	}

	actor.health = 600;
	actor.gibhealth = -60;
	actor.th_stand = sham_stand1;
	actor.th_walk = sham_walk1;
	actor.th_run = sham_run1;
	actor.th_die = sham_die;
	actor.th_melee = sham_melee;
	actor.th_missile = sham_magic1;
	actor.th_pain = sham_pain;

	actor.checkattack = ShamCheckAttack;

	actor.steptype = FS_TYPELARGE;

	return true;
}
METHOD(Shambler, mr_sight, bool(Shambler this, entity actor))
{
	TC(Shambler, this);

	if(season == SEASON_XMAS)
		_sound(actor, CH_VOICE, "shambler/ssight_xmas.wav", 1, ATTN_NORM);
	else if(actor.spawnflags & MON_SHAMBLER_COOKIE)
		_sound(actor, CH_VOICE, "shambler/cookie.wav", 1, ATTN_NORM);
	else
		_sound(actor, CH_VOICE, "shambler/ssight.wav", 1, ATTN_NORM);

	return true;
}
#endif

// kirby power
#ifdef CSQC
PRECACHE(Star_Shambler)
{
	precache_model("progs/v_star_shambler.mdl");
}
#endif

#ifdef SVQC
PRECACHE(Star_Shambler)
{
	precache_model("progs/pbullet.mdl");
	precache_model("progs/s_plasma.spr");
	precache_model("models/ebomb.mdl"); // NOTE: Xonotic model TODO?

	precache_sound("kirby/spark_downzap.wav");
	precache_sound("kirby/spark_upzap.wav");
	precache_sound("kirby/spark_charge.wav");
	precache_sound("kirby/spark_passive.wav");

	precache_sound("weapons/dsfirxpl.wav");
	precache_sound("enforcer/enfstop.wav");
}

.entity kirby_spark;

void star_shambler_downzap_trace(entity actor, .entity weaponentity)
{
	vector myorg = CENTER_OR_VIEWOFS(actor);

	traceline(myorg, myorg - '0 0 1024', true, actor);

	SendCSQCLightningBeam(myorg, trace_endpos);

	LightningDamage(myorg, trace_endpos, actor, 20, WEP_STAR.m_id);
}

void star_shambler_downzap_frame(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;

	if(IS_ONGROUND(actor) || actor.waterlevel > 1 || time > STAT(KIRBY_ZAPTIME, actor))
	{
		this.m_frame = 0;
		w_ready(this);
		return;
	}

	if(IS_PLAYER(actor))
		player_shot1(actor);

	wep_set_anim(this, 1, star_shambler_downzap_frame);

	star_shambler_downzap_trace(actor, weaponentity);
}

void star_shambler_downzap(entity actor, .entity weaponentity)
{
	_sound(actor, CH_WEAPON_A, "kirby/spark_downzap.wav", 1, ATTN_NORM);
	actor.velocity_z = 0;
	actor.oldvelocity_z = 0;
	STAT(KIRBY_ZAPTIME, actor) = time + 1.5; // tiny bit longer than the attack
	ATTACK_FINISHED(actor, weaponentity) = time + 2;
	star_shambler_downzap_frame(actor.(weaponentity));
}

void ShockExplosion(entity this);
void spark_chargezap_watercheck(entity this)
{
	// The routine modified from BLAZE.QC included in the killer87 package.
	// Basically, plasma bullets explode when hitting liquids.
	// In this explosion, the electic charge of the plasma bullet is spread
	// into the said liquid...

	int pc = pointcontents(this.origin);
	if((pc == CONTENT_WATER) || (pc == CONTENT_SLIME) || (pc == CONTENT_LAVA))
	{
		_sound(this, CH_WEAPON_SINGLE, "enforcer/enfstop.wav", 1, ATTN_NORM);

		T_RadiusDamage(this, this.owner, 60, DEATH_DISCHARGE.m_id, NULL);   // Damage
		ShockExplosion(this);                         // Explosion sprite
		return;
	}

	this.nextthink = time;
}

void spark_chargezap_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;   // don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	float damg = this.dmg;
	if(!damg)
		damg = 10+random()*50;
	
	if(toucher.takedamage)
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);

	// Moves the plasma bullet backwards after hitting.. Otherwise the 
	// explosion sprite would often be inside a wall or something. 
	this.origin = this.origin - 8*normalize(this.velocity);

	// Sound from Doom...
	_sound(this, CH_WEAPON_SINGLE, "weapons/dsfirxpl.wav", 1, ATTN_NORM);

	entity newmis = spawn();
	set_movetype(newmis, MOVETYPE_NONE);
	newmis.solid = SOLID_NOT;
	setmodel(newmis, MDL_EXPLOSION);
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, this.origin);
	ShockExplosion(newmis);

	delete(this);
}

void star_shambler_charge_fire(entity actor, .entity weaponentity, float dmgscale)
{
	_sound(actor, CH_SHOTS_SINGLE, "kirby/spark_upzap.wav", 1, ATTN_NORM);

	makevectors(actor.v_angle);

	float bullet_speed = 1000;
	vector org = CENTER_OR_VIEWOFS(actor);
	vector dir = qc_aim_fromorg(actor, org, bullet_speed);

	entity missile = spawn();
	missile.flags = FL_PROJECTILE;
	missile.owner = actor;
	missile.realowner = actor;
	set_movetype(missile, MOVETYPE_FLYMISSILE);    // Like a rocket
	missile.solid = SOLID_BBOX;
	missile.classname = "spark";
	missile.projectiledeathtype = WEP_SHOCK_GUN.m_id;
	missile.clipgroup = actor.clipgroup;

	missile.dmg = 150 * dmgscale;

	missile.velocity = dir * bullet_speed;
	missile.angles = vectoangles(missile.velocity);
	missile.avelocity = '300 300 300';

	missile.nextthink = time;
	setthink(missile, spark_chargezap_watercheck);        // If shot underwater -> razzp!
	settouch(missile, spark_chargezap_touch);

	missile.effects = EF_FULLBRIGHT | EF_DIMLIGHT;

	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, org);

	IL_PUSH(g_projectiles, missile);

	CSQCProjectile(missile, true, PROJECTILE_SPARK_UPZAP, true);
}

void star_spark_clear(entity actor)
{
	if(actor.kirby_spark)
		delete(actor.kirby_spark);
	actor.kirby_spark = NULL;
}

void star_spark_zapnearby(entity this)
{
	// TODO: water check

	int hitenemy = 0;
	FOREACH_ENTITY_RADIUS(this.origin, 200, hitenemy < 3,
	{
		if(!it.takedamage || it == this.owner || !Damage_ValidTarget(it, this.owner))
			continue;
		SendCSQCLightningBeam(this.origin, it.origin);
		// may cause heavy lag when fired near water!
		//LightningDamage(this.origin, it.origin, this, 10, WEP_STAR.m_id);
		T_Damage(it, this, this.owner, 10, WEP_STAR.m_id);
		hitenemy += 1;
	});
}

void star_spark_think(entity this)
{
	entity actor = this.owner;
	this.nextthink = time;

	if(!actor || actor.kirby_spark != this || (this.wait && time >= this.wait) || actor.m_champion != CHAMPION_Kirby || actor.health < 1 || intermission_running)
	{
		if(actor && actor.kirby_spark == this)
			actor.kirby_spark = NULL;
		delete(this);
		return;
	}

	this.count = bound(0.01, this.count + 0.5 * PHYS_INPUT_TIMELENGTH, 1);
	this.scale = this.count * 7;

	// activate damaging bubble
	if(this.count >= 1 && !this.state)
	{
		this.state = 1;
		this.wait = time + 6;
	}

	// while active, zap nearby enemies
	if(this.state && time >= this.delay)
	{
		this.delay = time + 0.1;

		star_spark_zapnearby(this);
	}
}

void star_spark_spawn(entity actor)
{
	entity spark = spawn();
	spark.classname = "kirby_spark";
	spark.owner = actor;
	spark.realowner = actor;
	spark.solid = SOLID_NOT;
	_setmodel(spark, "models/ebomb.mdl");
	setsize(spark, '0 0 0', '0 0 0');
	setorigin(spark, actor.origin);
	SetMovetypeFollow(spark, actor);
	spark.effects = EF_LOWPRECISION | EF_NOSHADOW | EF_DOUBLESIDED;
	spark.count = 0; // charge amount
	spark.state = 0; // in active damaging mode
	spark.wait = 0; // once activated, will be a countdown until the effect is removed
	spark.delay = 0; // time between damage attempts
	spark.alpha = 0.5; // don't completely obscure view!
	setthink(spark, star_spark_think);
	spark.nextthink = time;

	actor.kirby_spark = spark;
}

void star_shambler_charge_frame(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;

	if((actor.kirby_spark && actor.kirby_spark.count >= 1) || !PHYS_INPUT_BUTTON_ATCK(actor))
	{
		if(actor.kirby_spark && actor.kirby_spark.count < 1)
		{
			star_shambler_charge_fire(actor, weaponentity, actor.kirby_spark.count);
			weapon_prepareattack(WEP_STAR, actor, weaponentity, 1);

			star_spark_clear(actor);
		}
		else
			_sound(actor, CH_SHOTS_SINGLE, "kirby/spark_passive.wav", 0.5, ATTN_NORM);

		ATTACK_FINISHED(actor, weaponentity) = time + 0.5;

		this.m_frame = 0;
		w_ready(this);
		return;
	}

	ATTACK_FINISHED(actor, weaponentity) = time + 0.2;

	if(IS_PLAYER(actor))
		player_shot1(actor);

	wep_set_anim(this, 4, star_shambler_charge_frame);
}

void star_shambler_charge(entity actor, .entity weaponentity)
{
	_sound(actor, CH_SHOTS_SINGLE, "kirby/spark_charge.wav", 1, ATTN_NORM);
	ATTACK_FINISHED(actor, weaponentity) = time + 0.2;
	star_spark_spawn(actor);
	star_shambler_charge_frame(actor.(weaponentity));
}

void W_Star_Shambler_Clear(entity actor)
{
	if(actor.kirby_spark)
		delete(actor.kirby_spark);
	actor.kirby_spark = NULL;
}

METHOD(Shambler, star_fire, void(Shambler this, entity actor, .entity weaponentity))
{
	// we're always going to do *something*, so always cancel out of flight now
	if(STAT(KIRBY_STATE, actor) == KIRBY_FLYING)
		STAT(KIRBY_STATE, actor) = KIRBY_NORMAL;

	bool swimming = (actor.waterlevel > 1);

	//if(swimming)
		//return; // kaboom?

	// looking down and in the air!
	if(!IS_ONGROUND(actor) && !swimming && actor.v_angle_x >= 55 && actor.v_angle_x <= 110)
	{
		star_shambler_downzap(actor, weaponentity);
		return;
	}

	// charge electric sphere
	if(!actor.kirby_spark)
		star_shambler_charge(actor, weaponentity);
}
#endif
