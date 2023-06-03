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
void sham_walk7(entity this) { set_animofs(this, anim_sham_walk, 7, sham_walk8); ai_walk(this, 8); }
void sham_walk6(entity this) { set_animofs(this, anim_sham_walk, 6, sham_walk7); ai_walk(this, 12); }
void sham_walk5(entity this) { set_animofs(this, anim_sham_walk, 5, sham_walk6); ai_walk(this, 6); }
void sham_walk4(entity this) { set_animofs(this, anim_sham_walk, 4, sham_walk5); ai_walk(this, 5); }
void sham_walk3(entity this) { set_animofs(this, anim_sham_walk, 3, sham_walk4); ai_walk(this, 9); }
void sham_walk2(entity this) { set_animofs(this, anim_sham_walk, 2, sham_walk3); ai_walk(this, 9); }
void sham_walk1(entity this) { set_animofs(this, anim_sham_walk, 1, sham_walk2); ai_walk(this, 10); }

void sham_run1(entity this);
void sham_run6(entity this)
{
	set_animofs(this, anim_sham_run, 6, sham_run1);
	ai_run(this, 20);
	if(random() > 0.8)
		_sound(this, CH_VOICE, "shambler/sidle.wav", 1, ATTN_IDLE);
}
void sham_run5(entity this) { set_animofs(this, anim_sham_run, 5, sham_run6); ai_run(this, 24); }
void sham_run4(entity this) { set_animofs(this, anim_sham_run, 4, sham_run5); ai_run(this, 20); }
void sham_run3(entity this) { set_animofs(this, anim_sham_run, 3, sham_run4); ai_run(this, 20); }
void sham_run2(entity this) { set_animofs(this, anim_sham_run, 2, sham_run3); ai_run(this, 24); }
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
	_sound(this, CH_VOICE, "shambler/smack.wav", 1, ATTN_NORM);

	SpawnMeatSpray(this, this.origin + v_forward*16, crandom() * 100 * v_right);
	SpawnMeatSpray(this, this.origin + v_forward*16, crandom() * 100 * v_right);
}
void sham_smash9(entity this) { set_animofs(this, anim_sham_smash, 9, sham_smash10); ai_charge(this, 0); }
void sham_smash8(entity this) { set_animofs(this, anim_sham_smash, 8, sham_smash9); ai_charge(this, 0); }
void sham_smash7(entity this) { set_animofs(this, anim_sham_smash, 7, sham_smash8); ai_charge(this, 0); }
void sham_smash6(entity this) { set_animofs(this, anim_sham_smash, 6, sham_smash7); ai_charge(this, 1); }
void sham_smash5(entity this) { set_animofs(this, anim_sham_smash, 5, sham_smash6); ai_charge(this, 4); }
void sham_smash4(entity this) { set_animofs(this, anim_sham_smash, 4, sham_smash5); ai_charge(this, 5); }
void sham_smash3(entity this) { set_animofs(this, anim_sham_smash, 3, sham_smash4); ai_charge(this, 6); }
void sham_smash2(entity this) { set_animofs(this, anim_sham_smash, 2, sham_smash3); ai_charge(this, 6); }
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
	_sound(this, CH_VOICE, "shambler/smack.wav", 1, ATTN_NORM);

	if(side)
	{
		fixedmakevectors(this.angles);
		SpawnMeatSpray(this, this.origin + v_forward*16, side * v_right);
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
void sham_swingl2(entity this) { set_animofs(this, anim_sham_swingl, 2, sham_swingl3); ai_charge(this, 3); }
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
void sham_swingr2(entity this) { set_animofs(this, anim_sham_swingr, 2, sham_swingr3); ai_charge(this, 8); }
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

void CastLightning(entity this)
{
	this.effects |= EF_MUZZLEFLASH;

	ai_face(this);

	vector org = this.origin + '0 0 40';

	vector dir = this.enemy.origin + '0 0 16' - org;
	dir = normalize(dir);

	traceline(org, this.origin + dir*600, true, this);

	//te_lightning1(NULL, org, trace_endpos); // TODO: entity breaks
	SendCSQCLightningBeam(org, trace_endpos);

	LightningDamage(org, trace_endpos, this, 10, DEATH_MONSTER_SHAMBLER.m_id);
}

void sham_magic12(entity this) { set_animofs(this, anim_sham_magic, 12, sham_run1); }
void sham_magic11(entity this) { set_animofs(this, anim_sham_magic, 11, sham_magic12); }
void sham_magic10(entity this) { set_animofs(this, anim_sham_magic, 10, sham_magic11); CastLightning(this); }
void sham_magic9(entity this) { set_animofs(this, anim_sham_magic, 9, sham_magic10); CastLightning(this); }
void sham_magic6(entity this)
{
	set_animofs(this, anim_sham_magic, 6, sham_magic9);
	delete(this.owner);
	CastLightning(this);
	_sound(this, CH_WEAPON_SINGLE, "shambler/sboom.wav", 1, ATTN_NORM);
}
void sham_magic5(entity this)
{
	set_animofs(this, anim_sham_magic, 5, sham_magic6);
	this.effects |= EF_MUZZLEFLASH;
	this.owner.frame = 2;
}
void sham_magic4(entity this)
{
	set_animofs(this, anim_sham_magic, 4, sham_magic5);
	this.effects |= EF_MUZZLEFLASH;
	this.owner.frame = 1;
}
void sham_magic3(entity this)
{
	set_animofs(this, anim_sham_magic, 3, sham_magic4);
	ai_face(this);
	this.nextthink = this.nextthink + 0.2;

	this.effects |= EF_MUZZLEFLASH;
	entity o = spawn();
	this.owner = o;
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
	_sound(this, CH_VOICE, "shambler/shurt2.wav", 1, ATTN_NORM);

	if(this.health <= 0)
		return;		// allready dying, don't go into pain frame

	if(random()*400 > damage)
		return;		// didn't flinch

	if(this.pain_finished > time)
		return;
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
// check for gib
	if(this.health < -60)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, "progs/h_shams.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib2.mdl", this.health);
		ThrowGib(this, "progs/gib3.mdl", this.health);
		return;
	}

// regular death
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

	if(vlen(spot1 - spot2) > 600)
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

/*QUAKED monster_shambler(1 0 0)(-32 -32 -24)(32 32 64) Ambush
*/
spawnfunc(monster_shambler)
{
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

    actor.health = 600;
    actor.th_stand = sham_stand1;
	actor.th_walk = sham_walk1;
	actor.th_run = sham_run1;
	actor.th_die = sham_die;
	actor.th_melee = sham_melee;
	actor.th_missile = sham_magic1;
	actor.th_pain = sham_pain;

	actor.checkattack = ShamCheckAttack;

    return true;
}
#endif
