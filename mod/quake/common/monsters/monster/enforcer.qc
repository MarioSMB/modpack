#include "enforcer.qh"

#include "dark_knight.qh"
#include "lightning_enforcer.qh"
#include "guardian.qh"

#ifdef SVQC
const int anim_enf_stand = 0; //'0 6 0'
const int anim_enf_walk = 7; //'7 22 0'
const int anim_enf_run = 23; //'23 30 0'
const int anim_enf_attack = 31; //'31 40 0'
const int anim_enf_death = 41; //'41 54 0'
const int anim_enf_fdeath = 55; //'55 65 0'
const int anim_enf_paina = 66; //'66 69 0'
const int anim_enf_painb = 70; //'70 74 0'
const int anim_enf_painc = 75; //'75 82 0'
const int anim_enf_paind = 83; //'83 101 0'

void Laser_Touch(entity this, entity toucher)
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

entity LaunchLaser(entity this, vector org, vector vec)
{
	if(this.monsterdef == MON_ENFORCER)
		_sound(this, CH_WEAPON_SINGLE, "enforcer/enfire.wav", 1, ATTN_NORM);

	vector vec2 = normalize(vec);
	
	entity newmis = new(enforcer_laser);
	newmis.owner = this;
	newmis.projectiledeathtype = DEATH_MONSTER_ENFORCER.m_id;
	set_movetype(newmis, MOVETYPE_FLY);
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;

	_setmodel(newmis, "progs/laser.mdl");
	setsize(newmis, '0 0 0', '0 0 0');

	setorigin(newmis, org);

	newmis.velocity = vec2 * 600;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 5;
	setthink(newmis, SUB_Remove);
	settouch(newmis, Laser_Touch);

	return newmis;
}

void enforcer_fire(entity this)
{
	this.effects |= EF_MUZZLEFLASH;
	fixedmakevectors(this.angles);
	
	vector org = this.origin + v_forward * 30 + v_right * 8.5 + '0 0 16';

	LaunchLaser(this, org, this.enemy.origin - this.origin);
}

//============================================================================

void enf_stand1(entity this);
void enf_stand7(entity this) { set_animofs(this, anim_enf_stand, 7, enf_stand1); ai_stand(this); }
void enf_stand6(entity this) { set_animofs(this, anim_enf_stand, 6, enf_stand7); ai_stand(this); }
void enf_stand5(entity this) { set_animofs(this, anim_enf_stand, 5, enf_stand6); ai_stand(this); }
void enf_stand4(entity this) { set_animofs(this, anim_enf_stand, 4, enf_stand5); ai_stand(this); }
void enf_stand3(entity this) { set_animofs(this, anim_enf_stand, 3, enf_stand4); ai_stand(this); }
void enf_stand2(entity this) { set_animofs(this, anim_enf_stand, 2, enf_stand3); ai_stand(this); }
void enf_stand1(entity this) { set_animofs(this, anim_enf_stand, 1, enf_stand2); ai_stand(this); }

void enf_walk1(entity this);
void enf_walk16(entity this) { set_animofs(this, anim_enf_walk, 16, enf_walk1); ai_walk(this, 2); }
void enf_walk15(entity this) { set_animofs(this, anim_enf_walk, 15, enf_walk16); ai_walk(this, 4); }
void enf_walk14(entity this) { set_animofs(this, anim_enf_walk, 14, enf_walk15); ai_walk(this, 3); }
void enf_walk13(entity this) { set_animofs(this, anim_enf_walk, 13, enf_walk14); ai_walk(this, 2); }
void enf_walk12(entity this) { set_animofs(this, anim_enf_walk, 12, enf_walk13); ai_walk(this, 1); }
void enf_walk11(entity this) { set_animofs(this, anim_enf_walk, 11, enf_walk12); ai_walk(this, 4); }
void enf_walk10(entity this) { set_animofs(this, anim_enf_walk, 10, enf_walk11); ai_walk(this, 4); }
void enf_walk9(entity this) { set_animofs(this, anim_enf_walk, 9, enf_walk10); ai_walk(this, 2); }
void enf_walk8(entity this) { set_animofs(this, anim_enf_walk, 8, enf_walk9); ai_walk(this, 1); }
void enf_walk7(entity this) { set_animofs(this, anim_enf_walk, 7, enf_walk8); ai_walk(this, 2); }
void enf_walk6(entity this) { set_animofs(this, anim_enf_walk, 6, enf_walk7); ai_walk(this, 2); }
void enf_walk5(entity this) { set_animofs(this, anim_enf_walk, 5, enf_walk6); ai_walk(this, 1); }
void enf_walk4(entity this) { set_animofs(this, anim_enf_walk, 4, enf_walk5); ai_walk(this, 3); }
void enf_walk3(entity this) { set_animofs(this, anim_enf_walk, 3, enf_walk4); ai_walk(this, 4); }
void enf_walk2(entity this) { set_animofs(this, anim_enf_walk, 2, enf_walk3); ai_walk(this, 4); }
void enf_walk1(entity this)
{
	set_animofs(this, anim_enf_walk, 1, enf_walk2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);
	ai_walk(this, 2);
}

void enf_run1(entity this);
void enf_run8(entity this) { set_animofs(this, anim_enf_run, 8, enf_run1); ai_run(this, 11); }
void enf_run7(entity this) { set_animofs(this, anim_enf_run, 7, enf_run8); ai_run(this, 7); }
void enf_run6(entity this) { set_animofs(this, anim_enf_run, 6, enf_run7); ai_run(this, 14); }
void enf_run5(entity this) { set_animofs(this, anim_enf_run, 5, enf_run6); ai_run(this, 14); }
void enf_run4(entity this) { set_animofs(this, anim_enf_run, 4, enf_run5); ai_run(this, 12); }
void enf_run3(entity this) { set_animofs(this, anim_enf_run, 3, enf_run4); ai_run(this, 7); }
void enf_run2(entity this) { set_animofs(this, anim_enf_run, 2, enf_run3); ai_run(this, 14); }
void enf_run1(entity this)
{
	set_animofs(this, anim_enf_run, 1, enf_run2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);
	ai_run(this, 18);
}

void enf_atk1(entity this);
void enf_atk14(entity this)
{
	set_animofs(this, anim_enf_attack, 10, enf_run1);
	ai_face(this);
}
void enf_atk13(entity this) { set_animofs(this, anim_enf_attack, 9, enf_atk14); ai_face(this); }
void enf_atk12(entity this) { set_animofs(this, anim_enf_attack, 8, enf_atk13); ai_face(this); }
void enf_atk11(entity this) { set_animofs(this, anim_enf_attack, 7, enf_atk12); ai_face(this); }
void enf_atk10(entity this) { set_animofs(this, anim_enf_attack, 6, enf_atk11); enforcer_fire(this); }
void enf_atk9(entity this) { set_animofs(this, anim_enf_attack, 5, enf_atk10); ai_face(this); }
void enf_atk8(entity this) { set_animofs(this, anim_enf_attack, 8, enf_atk9); ai_face(this); }
void enf_atk7(entity this) { set_animofs(this, anim_enf_attack, 7, enf_atk8); ai_face(this); }
void enf_atk6(entity this) { set_animofs(this, anim_enf_attack, 6, enf_atk7); enforcer_fire(this); }
void enf_atk5(entity this) { set_animofs(this, anim_enf_attack, 5, enf_atk6); ai_face(this); }
void enf_atk4(entity this) { set_animofs(this, anim_enf_attack, 4, enf_atk5); ai_face(this); }
void enf_atk3(entity this) { set_animofs(this, anim_enf_attack, 3, enf_atk4); ai_face(this); }
void enf_atk2(entity this) { set_animofs(this, anim_enf_attack, 2, enf_atk3); ai_face(this); }
void enf_atk1(entity this) { set_animofs(this, anim_enf_attack, 1, enf_atk2); ai_face(this); }

void enf_paina4(entity this) { set_animofs(this, anim_enf_paina, 4, enf_run1); }
void enf_paina3(entity this) { set_animofs(this, anim_enf_paina, 3, enf_paina4); }
void enf_paina2(entity this) { set_animofs(this, anim_enf_paina, 2, enf_paina3); }
void enf_paina1(entity this) { set_animofs(this, anim_enf_paina, 1, enf_paina2); }

void enf_painb5(entity this) { set_animofs(this, anim_enf_painb, 5, enf_run1); }
void enf_painb4(entity this) { set_animofs(this, anim_enf_painb, 4, enf_painb5); }
void enf_painb3(entity this) { set_animofs(this, anim_enf_painb, 3, enf_painb4); }
void enf_painb2(entity this) { set_animofs(this, anim_enf_painb, 2, enf_painb3); }
void enf_painb1(entity this) { set_animofs(this, anim_enf_painb, 1, enf_painb2); }

void enf_painc8(entity this) { set_animofs(this, anim_enf_painc, 8, enf_run1); }
void enf_painc7(entity this) { set_animofs(this, anim_enf_painc, 7, enf_painc8); }
void enf_painc6(entity this) { set_animofs(this, anim_enf_painc, 6, enf_painc7); }
void enf_painc5(entity this) { set_animofs(this, anim_enf_painc, 5, enf_painc6); }
void enf_painc4(entity this) { set_animofs(this, anim_enf_painc, 4, enf_painc5); }
void enf_painc3(entity this) { set_animofs(this, anim_enf_painc, 3, enf_painc4); }
void enf_painc2(entity this) { set_animofs(this, anim_enf_painc, 2, enf_painc3); }
void enf_painc1(entity this) { set_animofs(this, anim_enf_painc, 1, enf_painc2); }

void enf_paind19(entity this) { set_animofs(this, anim_enf_paind, 19, enf_run1); }
void enf_paind18(entity this) { set_animofs(this, anim_enf_paind, 18, enf_paind19); }
void enf_paind17(entity this) { set_animofs(this, anim_enf_paind, 17, enf_paind18); ai_pain(this, 1); }
void enf_paind16(entity this) { set_animofs(this, anim_enf_paind, 16, enf_paind17); ai_pain(this, 1); }
void enf_paind15(entity this) { set_animofs(this, anim_enf_paind, 15, enf_paind16); }
void enf_paind14(entity this) { set_animofs(this, anim_enf_paind, 14, enf_paind15); }
void enf_paind13(entity this) { set_animofs(this, anim_enf_paind, 13, enf_paind14); ai_painforward(this, 1); }
void enf_paind12(entity this) { set_animofs(this, anim_enf_paind, 12, enf_paind13); ai_painforward(this, 1); }
void enf_paind11(entity this) { set_animofs(this, anim_enf_paind, 11, enf_paind12); ai_painforward(this, 1); }
void enf_paind10(entity this) { set_animofs(this, anim_enf_paind, 10, enf_paind11); }
void enf_paind9(entity this) { set_animofs(this, anim_enf_paind, 9, enf_paind10); }
void enf_paind8(entity this) { set_animofs(this, anim_enf_paind, 8, enf_paind9); }
void enf_paind7(entity this) { set_animofs(this, anim_enf_paind, 7, enf_paind8); }
void enf_paind6(entity this) { set_animofs(this, anim_enf_paind, 6, enf_paind7); }
void enf_paind5(entity this) { set_animofs(this, anim_enf_paind, 5, enf_paind6); ai_painforward(this, 1); }
void enf_paind4(entity this) { set_animofs(this, anim_enf_paind, 4, enf_paind5); ai_painforward(this, 2); }
void enf_paind3(entity this) { set_animofs(this, anim_enf_paind, 3, enf_paind4); }
void enf_paind2(entity this) { set_animofs(this, anim_enf_paind, 2, enf_paind3); }
void enf_paind1(entity this) { set_animofs(this, anim_enf_paind, 1, enf_paind2); }

void enf_pain(entity this, entity attacker, float damage, int deathtype)
{
	float r = random();
	if(this.pain_finished > time)
		return;

	if(r < 0.5)
		_sound(this, CH_VOICE, "enforcer/pain1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "enforcer/pain2.wav", 1, ATTN_NORM);

	if(r < 0.2)
	{
		this.pain_finished = time + 1;
		enf_paina1(this);
	}
	else if(r < 0.4)
	{
		this.pain_finished = time + 1;
		enf_painb1(this);
	}
	else if(r < 0.7)
	{
		this.pain_finished = time + 1;
		enf_painc1(this);
	}
	else
	{
		this.pain_finished = time + 2;
		enf_paind1(this);
	}
}

//============================================================================


void enf_die14(entity this)
{
	set_animofs(this, anim_enf_death, 14, enf_die14);
	CorpseThink(this);
}
void enf_die13(entity this) { set_animofs(this, anim_enf_death, 13, enf_die14); }
void enf_die12(entity this) { set_animofs(this, anim_enf_death, 12, enf_die13); ai_forward(this, 5); }
void enf_die11(entity this) { set_animofs(this, anim_enf_death, 11, enf_die12); ai_forward(this, 5); }
void enf_die10(entity this) { set_animofs(this, anim_enf_death, 10, enf_die11); ai_forward(this, 5); }
void enf_die9(entity this) { set_animofs(this, anim_enf_death, 9, enf_die10); ai_forward(this, 3); }
void enf_die8(entity this) { set_animofs(this, anim_enf_death, 8, enf_die9); }
void enf_die7(entity this) { set_animofs(this, anim_enf_death, 7, enf_die8); }
void enf_die6(entity this) { set_animofs(this, anim_enf_death, 6, enf_die7); }
void enf_die5(entity this) { set_animofs(this, anim_enf_death, 5, enf_die6); ai_forward(this, 2); }
void enf_die4(entity this) { set_animofs(this, anim_enf_death, 4, enf_die5); ai_forward(this, 14); }
void enf_die3(entity this)
{
	set_animofs(this, anim_enf_death, 3, enf_die4);
	this.ammo_cells = 5;
	DropBackpack(this);
}
void enf_die2(entity this) { set_animofs(this, anim_enf_death, 2, enf_die3); }
void enf_die1(entity this) { set_animofs(this, anim_enf_death, 1, enf_die2); this.solid = SOLID_NOT; }

void enf_fdie11(entity this)
{
	set_animofs(this, anim_enf_fdeath, 11, enf_fdie11);
	CorpseThink(this);
}
void enf_fdie10(entity this) { set_animofs(this, anim_enf_fdeath, 10, enf_fdie11); }
void enf_fdie9(entity this) { set_animofs(this, anim_enf_fdeath, 9, enf_fdie10); }
void enf_fdie8(entity this) { set_animofs(this, anim_enf_fdeath, 8, enf_fdie9); }
void enf_fdie7(entity this) { set_animofs(this, anim_enf_fdeath, 7, enf_fdie8); }
void enf_fdie6(entity this) { set_animofs(this, anim_enf_fdeath, 6, enf_fdie7); }
void enf_fdie5(entity this) { set_animofs(this, anim_enf_fdeath, 5, enf_fdie6); }
void enf_fdie4(entity this) { set_animofs(this, anim_enf_fdeath, 4, enf_fdie5); }
void enf_fdie3(entity this)
{
	set_animofs(this, anim_enf_fdeath, 3, enf_fdie4);
	this.ammo_cells = 5;
	DropBackpack(this);
}
void enf_fdie2(entity this) { set_animofs(this, anim_enf_fdeath, 2, enf_fdie3); }
void enf_fdie1(entity this) { set_animofs(this, anim_enf_fdeath, 1, enf_fdie2); this.solid = SOLID_NOT; }

void enf_die(entity this, entity inflictor, entity attacker, int deathtype)
{
// check for gib
	if(this.health < -35)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, inflictor, "progs/h_mega.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		return;
	}

// regular death
	_sound(this, CH_VOICE, "enforcer/death1.wav", 1, ATTN_NORM);
	if(random() > 0.5)
		enf_die1(this);
	else
		enf_fdie1(this);
}

/*QUAKED monster_enforcer(1 0 0)(-16 -16 -24)(16 16 40) Ambush
*/
spawnfunc(monster_enforcer)
{
	if(world.model == "maps/aop2m2.bsp")
	{
		monster_start(this, true, MON_DARK_KNIGHT);
		return;
	}
	if(coop == 2 && orig_random(this) < 0.5)
	{
		monster_start(this, true, MON_LIGHTNING_ENFORCER);
		return;
	}
	monster_start(this, true, MON_ENFORCER);
}

// alkaline
spawnfunc(monster_dreadnaught) { monster_start(this, true, MON_ENFORCER); }
spawnfunc(monster_centurion) { monster_start(this, true, MON_ENFORCER); }
#endif // SVQC

#ifdef SVQC
METHOD(Enforcer, mr_setup, bool(Enforcer this, entity actor))
{
	TC(Enforcer, this);

	precache_model("progs/laser.mdl");

	precache_sound("enforcer/death1.wav");
	precache_sound("enforcer/enfire.wav");
	precache_sound("enforcer/enfstop.wav");
	precache_sound("enforcer/idle1.wav");
	precache_sound("enforcer/pain1.wav");
	precache_sound("enforcer/pain2.wav");

	actor.health = 80;
	actor.th_stand = enf_stand1;
	actor.th_walk = enf_walk1;
	actor.th_run = enf_run1;
	actor.th_pain = enf_pain;
	actor.th_die = enf_die;
	actor.th_missile = enf_atk1;

	return true;
}
METHOD(Enforcer, mr_sight, bool(Enforcer this, entity actor))
{
    TC(Enforcer, this);

	sound(actor, CH_VOICE, SND_MON_ENFORCER_SIGHT_RANDOM(), 1, ATTN_NORM);

    return true;
}
#endif
