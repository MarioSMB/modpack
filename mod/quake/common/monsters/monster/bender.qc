#include "bender.qh"

#ifdef SVQC
const int anim_bender_stand = 0; //'0 6 0'
const int anim_bender_walk = 7; //'7 20 0'
const int anim_bender_run = 21; //'21 28 0'
const int anim_bender_atk = 29; //'29 36 0'
const int anim_bender_runatk = 37; //'37 44 0'
const int anim_bender_nuts = 45; //'45 55 0'
const int anim_bender_pain = 56; //'56 62 0'
const int anim_bender_paina = 63; //'63 71 0'
const int anim_bender_die = 72; //'72 84 0'
const int anim_bender_diea = 85; //'85 98 0'


//============================================================================

void Bend_Touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
	_sound(this, CH_WEAPON_SINGLE, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	vector org = this.origin - 8*normalize(this.velocity);

	if(toucher.health)
	{
		SpawnBlood(org, this.velocity*0.2, 15, toucher);
		T_Damage(toucher, this, this.owner, 8, this.projectiledeathtype);
	}
	else
		te_gunshot(org);
	
	delete(this);	
}

void bend_shot(entity this, float offset)
{
	vector offang = vectoangles(this.enemy.origin - this.origin);
	offang.y = offang.y + offset * 6;
	
	makevectors(offang);

	vector org = this.origin + this.mins + this.size*0.4 + v_forward * 30 + v_right * 8.5 + '0 0 1';

// set missile speed
	vector vec = normalize (v_forward);
	vec.z = 0 - vec.z + (random() - 0.5)*0.1;
	
	entity newmis = launch_spike(this, org, vec);
	newmis.classname = "knightspike";
	settouch(newmis, Bend_Touch);
	newmis.projectiledeathtype = DEATH_MONSTER_BENDER.m_id;
	_setmodel(newmis, "progs/laser.mdl");
	setsize(newmis, '0 0 0', '0 0 0');		
	newmis.velocity = vec*300;
	_sound(this, CH_WEAPON_SINGLE, "hknight/attack1.wav", 1, ATTN_NORM);
}

//==========================================================
void bend_walk1(entity this);
void bend_stand1(entity this);
void bend_run1(entity this);

void bend_stand7(entity this) { set_animofs(this, anim_bender_stand, 7, bend_stand1); ai_stand(this); }
void bend_stand6(entity this) { set_animofs(this, anim_bender_stand, 6, bend_stand7); ai_stand(this); }
void bend_stand5(entity this) { set_animofs(this, anim_bender_stand, 5, bend_stand6); ai_stand(this); }
void bend_stand4(entity this) { set_animofs(this, anim_bender_stand, 4, bend_stand5); ai_stand(this); }
void bend_stand3(entity this) { set_animofs(this, anim_bender_stand, 3, bend_stand4); ai_stand(this); }
void bend_stand2(entity this) { set_animofs(this, anim_bender_stand, 2, bend_stand3); ai_stand(this); }
void bend_stand1(entity this)
{
	set_animofs(this, anim_bender_stand, 1, bend_stand2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "bend/idle.wav", 1,  ATTN_NORM);
	ai_stand(this);
}

void bend_walk14(entity this) { set_animofs(this, anim_bender_walk, 14, bend_walk1); ai_walk(this, 3); }
void bend_walk13(entity this) { set_animofs(this, anim_bender_walk, 13, bend_walk14); ai_walk(this, 4); }
void bend_walk12(entity this) { set_animofs(this, anim_bender_walk, 12, bend_walk13); ai_walk(this, 5); }
void bend_walk11(entity this) { set_animofs(this, anim_bender_walk, 11, bend_walk12); ai_walk(this, 6); }
void bend_walk10(entity this) { set_animofs(this, anim_bender_walk, 10, bend_walk11); ai_walk(this, 5); }
void bend_walk9(entity this) { set_animofs(this, anim_bender_walk, 9, bend_walk10); ai_walk(this, 4); }
void bend_walk8(entity this) { set_animofs(this, anim_bender_walk, 8, bend_walk9); ai_walk(this, 3); }
void bend_walk7(entity this) { set_animofs(this, anim_bender_walk, 7, bend_walk8); ai_walk(this, 3); }
void bend_walk6(entity this) { set_animofs(this, anim_bender_walk, 6, bend_walk7); ai_walk(this, 4); }
void bend_walk5(entity this) { set_animofs(this, anim_bender_walk, 5, bend_walk6); ai_walk(this, 5); }
void bend_walk4(entity this) { set_animofs(this, anim_bender_walk, 4, bend_walk5); ai_walk(this, 6); }
void bend_walk3(entity this) { set_animofs(this, anim_bender_walk, 3, bend_walk4); ai_walk(this, 5); }
void bend_walk2(entity this) { set_animofs(this, anim_bender_walk, 2, bend_walk3); ai_walk(this, 4); }
void bend_walk1(entity this)
{
	set_animofs(this, anim_bender_walk, 1, bend_walk2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "bend/idle0.wav", 1,  ATTN_NORM);
	ai_walk(this, 3);
}
 
void bend_run8(entity this) { set_animofs(this, anim_bender_run, 8, bend_run1); ai_run(this, 9); }
void bend_run7(entity this) { set_animofs(this, anim_bender_run, 7, bend_run8); ai_run(this, 14); }
void bend_run6(entity this) { set_animofs(this, anim_bender_run, 6, bend_run7); ai_run(this, 20); }
void bend_run5(entity this) { set_animofs(this, anim_bender_run, 5, bend_run6); ai_run(this, 14); }
void bend_run4(entity this) { set_animofs(this, anim_bender_run, 4, bend_run5); ai_run(this, 9); }
void bend_run3(entity this) { set_animofs(this, anim_bender_run, 3, bend_run4); ai_run(this, 14); }
void bend_run2(entity this) { set_animofs(this, anim_bender_run, 2, bend_run3); ai_run(this, 20); }
void bend_run1(entity this)
{
	set_animofs(this, anim_bender_run, 1, bend_run2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "bend/idle2.wav", 1,  ATTN_NORM);
	ai_run(this, 9);
}

void bend_atk8(entity this) { set_animofs(this, anim_bender_atk, 8, bend_run1); ai_face(this); }
void bend_atk7(entity this) { set_animofs(this, anim_bender_atk, 7, bend_atk8); ai_face(this); bend_shot(this, 0); }
void bend_atk6(entity this) { set_animofs(this, anim_bender_atk, 6, bend_atk7); ai_face(this); }
void bend_atk5(entity this) { set_animofs(this, anim_bender_atk, 5, bend_atk6); ai_face(this); bend_shot(this, 0); }
void bend_atk4(entity this) { set_animofs(this, anim_bender_atk, 4, bend_atk5); ai_face(this); }
void bend_atk3(entity this) { set_animofs(this, anim_bender_atk, 3, bend_atk4); ai_face(this); bend_shot(this, 0); }
void bend_atk2(entity this) { set_animofs(this, anim_bender_atk, 2, bend_atk3); ai_face(this); }
void bend_atk1(entity this)
{
	set_animofs(this, anim_bender_atk, 1, bend_atk2);
	_sound(this, CH_WEAPON_SINGLE, "bend/idle1.wav", 1, ATTN_NORM);
	ai_face(this);
	bend_shot(this, 0);
}

void bend_atka8(entity this) { set_animofs(this, anim_bender_runatk, 8, bend_run1); ai_face(this); }
void bend_atka7(entity this) { set_animofs(this, anim_bender_runatk, 7, bend_atka8); ai_run(this, 15); bend_shot(this, 0); }
void bend_atka6(entity this) { set_animofs(this, anim_bender_runatk, 6, bend_atka7); ai_run(this, 18); }
void bend_atka5(entity this) { set_animofs(this, anim_bender_runatk, 5, bend_atka6); ai_run(this, 12); bend_shot(this, 0); }
void bend_atka4(entity this) { set_animofs(this, anim_bender_runatk, 4, bend_atka5); ai_face(this); }
void bend_atka3(entity this) { set_animofs(this, anim_bender_runatk, 3, bend_atka4); ai_run(this, 15); bend_shot(this, 0); }
void bend_atka2(entity this) { set_animofs(this, anim_bender_runatk, 2, bend_atka3); ai_run(this, 9); }
void bend_atka1(entity this)
{
	set_animofs(this, anim_bender_runatk, 1, bend_atka2);
	_sound(this, CH_WEAPON_SINGLE, "bend/beat.wav", 1, ATTN_NORM);
	ai_face(this);
}

void bend_natk11(entity this) { set_animofs(this, anim_bender_nuts, 11, bend_run1); ai_face(this); bend_shot(this, 2); }
void bend_natk10(entity this) { set_animofs(this, anim_bender_nuts, 10, bend_natk11); ai_face(this); }
void bend_natk9(entity this) { set_animofs(this, anim_bender_nuts, 9, bend_natk10); ai_face(this); bend_shot(this, 1); }
void bend_natk8(entity this) { set_animofs(this, anim_bender_nuts, 8, bend_natk9); ai_face(this); }
void bend_natk7(entity this) { set_animofs(this, anim_bender_nuts, 7, bend_natk8); ai_face(this); bend_shot(this, 0); }
void bend_natk6(entity this) { set_animofs(this, anim_bender_nuts, 6, bend_natk7); ai_face(this); }
void bend_natk5(entity this) { set_animofs(this, anim_bender_nuts, 5, bend_natk6); ai_face(this); bend_shot(this, -1); }
void bend_natk4(entity this) { set_animofs(this, anim_bender_nuts, 4, bend_natk5); ai_face(this); }
void bend_natk3(entity this) { set_animofs(this, anim_bender_nuts, 3, bend_natk4); ai_face(this); bend_shot(this, -2); }
void bend_natk2(entity this) { set_animofs(this, anim_bender_nuts, 2, bend_natk3); ai_face(this); }
void bend_natk1(entity this)
{
	set_animofs(this, anim_bender_nuts, 1, bend_natk2);
	_sound(this, CH_WEAPON_SINGLE, "bend/gun.wav", 1, ATTN_NORM);
	ai_face(this);
	bend_shot(this, 0);
}

void bend_pain7(entity this) { set_animofs(this, anim_bender_pain, 7, bend_run1); }
void bend_pain6(entity this) { set_animofs(this, anim_bender_pain, 6, bend_pain7); ai_pain(this, 6);}
void bend_pain5(entity this) { set_animofs(this, anim_bender_pain, 5, bend_pain6); ai_pain(this, 4);}
void bend_pain4(entity this) { set_animofs(this, anim_bender_pain, 4, bend_pain5); }
void bend_pain3(entity this) { set_animofs(this, anim_bender_pain, 3, bend_pain4); }
void bend_pain2(entity this) { set_animofs(this, anim_bender_pain, 2, bend_pain3); }
void bend_pain1(entity this) { set_animofs(this, anim_bender_pain, 1, bend_pain2); _sound(this, CH_WEAPON_SINGLE, "bend/auw.wav", 1, ATTN_NORM);}

void bend_paina9(entity this) { set_animofs(this, anim_bender_paina, 9, bend_run1); }
void bend_paina8(entity this) { set_animofs(this, anim_bender_paina, 8, bend_paina9); }
void bend_paina7(entity this) { set_animofs(this, anim_bender_paina, 7, bend_paina8); ai_pain(this, 6);}
void bend_paina6(entity this) { set_animofs(this, anim_bender_paina, 6, bend_paina7); ai_pain(this, 4);}
void bend_paina5(entity this) { set_animofs(this, anim_bender_paina, 5, bend_paina6); }
void bend_paina4(entity this) { set_animofs(this, anim_bender_paina, 4, bend_paina5); }
void bend_paina3(entity this) { set_animofs(this, anim_bender_paina, 3, bend_paina4); }
void bend_paina2(entity this) { set_animofs(this, anim_bender_paina, 2, bend_paina3); }
void bend_paina1(entity this) { set_animofs(this, anim_bender_paina, 1, bend_paina2); _sound(this, CH_WEAPON_SINGLE, "bend/auw2.wav", 1, ATTN_NORM);}

void bend_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	float r = random();
	
	if(r < 0.5)
	{
		bend_pain1(this);
		this.pain_finished = time + 1;
	}
	else	
	{
		bend_paina1(this);
		this.pain_finished = time + 1;
	}
}

void bend_die13(entity this) { set_animofs(this, anim_bender_die, 13, bend_die13); }
void bend_die12(entity this) { set_animofs(this, anim_bender_die, 12, bend_die13); }
void bend_die11(entity this) { set_animofs(this, anim_bender_die, 11, bend_die12); }
void bend_die10(entity this) { set_animofs(this, anim_bender_die, 10, bend_die11); }
void bend_die9(entity this) { set_animofs(this, anim_bender_die, 9, bend_die10); }
void bend_die8(entity this) { set_animofs(this, anim_bender_die, 8, bend_die9); }
void bend_die7(entity this) { set_animofs(this, anim_bender_die, 7, bend_die8); }
void bend_die6(entity this) { set_animofs(this, anim_bender_die, 6, bend_die7); }
void bend_die5(entity this) { set_animofs(this, anim_bender_die, 5, bend_die6); }
void bend_die4(entity this) { set_animofs(this, anim_bender_die, 4, bend_die5); }
void bend_die3(entity this)
{
	set_animofs(this, anim_bender_die, 3, bend_die4);
	this.solid = SOLID_NOT;
	this.ammo_nails = 5;
	DropBackpack(this);
}
void bend_die2(entity this) { set_animofs(this, anim_bender_die, 2, bend_die3); }
void bend_die1(entity this)
{
	set_animofs(this, anim_bender_die, 1, bend_die2);
	_sound(this, CH_WEAPON_SINGLE, "bend/die.wav", 1, ATTN_NORM);
}

void bend_diea14(entity this) { set_animofs(this, anim_bender_diea, 14, bend_diea14); }
void bend_diea13(entity this) { set_animofs(this, anim_bender_diea, 13, bend_diea14); }
void bend_diea12(entity this) { set_animofs(this, anim_bender_diea, 12, bend_diea13); }
void bend_diea11(entity this) { set_animofs(this, anim_bender_diea, 11, bend_diea12); }
void bend_diea10(entity this) { set_animofs(this, anim_bender_diea, 10, bend_diea11); }
void bend_diea9(entity this) { set_animofs(this, anim_bender_diea, 9, bend_diea10); }
void bend_diea8(entity this) { set_animofs(this, anim_bender_diea, 8, bend_diea9); }
void bend_diea7(entity this) { set_animofs(this, anim_bender_diea, 7, bend_diea8); }
void bend_diea6(entity this) { set_animofs(this, anim_bender_diea, 6, bend_diea7); }
void bend_diea5(entity this) { set_animofs(this, anim_bender_diea, 5, bend_diea6); }
void bend_diea4(entity this) { set_animofs(this, anim_bender_diea, 4, bend_diea5); }
void bend_diea3(entity this)
{
	set_animofs(this, anim_bender_diea, 3, bend_diea4);
	this.solid = SOLID_NOT;
	this.ammo_nails = 5;
	DropBackpack(this);
}
void bend_diea2(entity this) { set_animofs(this, anim_bender_diea, 2, bend_diea3); }
void bend_diea1(entity this) { set_animofs(this, anim_bender_diea, 1, bend_diea2); _sound(this, CH_WEAPON_SINGLE, "bend/die1.wav", 1, ATTN_NORM); }

void bend_die(entity this, entity inflictor, entity attacker, int deathtype)
{
// check for gib
	if(this.health < -40)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, "progs/h_bender.mdl", this.health);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib2.mdl", this.health);
		ThrowGib(this, "progs/gib3.mdl", this.health);
		return;
	}

// regular death
	if(random() < 0.5)
		bend_die1(this);
	else
		bend_diea1(this);
}

void bend_melee(entity this)
{
	if(random() > 0.5)
		bend_atka1(this);
//                this.pain_finished = time + 1;
	else 
		bend_atk1(this);
//              this.pain_finished = time + 1;
}

void bend_missile(entity this)
{
	if(this.attack_finished > time)
		return;

	if(random() > 0.33)
	{
		bend_natk1(this);
		this.pain_finished = time + 1;
	}
}

/*QUAKED monster_bender (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_bender) { monster_start(this, true, MON_BENDER); }
#endif // SVQC

#ifdef SVQC
METHOD(Bender, mr_setup, bool(Bender this, entity actor))
{
	TC(Bender, this);

	precache_model("progs/laser.mdl");

	precache_sound("enforcer/enfstop.wav"); 
	precache_sound("hknight/attack1.wav");
	precache_sound("bend/idle.wav");
	precache_sound("bend/idle0.wav");
	precache_sound("bend/idle1.wav");
	precache_sound("bend/idle2.wav");
	precache_sound("bend/gun.wav");
	precache_sound("bend/die.wav");
	precache_sound("bend/die1.wav");
	precache_sound("bend/beat.wav");
	precache_sound("bend/auw2.wav");
	precache_sound("bend/auw.wav");

	actor.health = 250;
	actor.th_stand = bend_stand1;
	actor.th_walk = bend_walk1;
	actor.th_run = bend_run1;
	actor.th_melee = bend_melee;
	actor.th_pain = bend_pain;
	actor.th_die = bend_die;
	actor.th_missile = bend_missile;

	return true;
}
#endif
