#include "phantom_swordsman.qh"

#ifdef SVQC
const int anim_sword_stand1 = 0;
const int anim_sword_runb1 = 1;
const int anim_sword_attackb1 = 9;
const int anim_sword_death1 = 19;
const int anim_sword_deathb1 = 29;

void sword_stand1(entity this) { set_anim(this, anim_sword_stand1, sword_stand1); ai_stand(this); }

void sword_run1(entity this);
void sword_run8(entity this) { set_animofs(this, anim_sword_runb1, 8, sword_run1); ai_run(this, 14); }
void sword_run7(entity this) { set_animofs(this, anim_sword_runb1, 7, sword_run8); ai_run(this, 14); }
void sword_run6(entity this) { set_animofs(this, anim_sword_runb1, 6, sword_run7); ai_run(this, 14); }
void sword_run5(entity this) { set_animofs(this, anim_sword_runb1, 5, sword_run6); ai_run(this, 14); }
void sword_run4(entity this) { set_animofs(this, anim_sword_runb1, 4, sword_run5); ai_run(this, 14); }
void sword_run3(entity this) { set_animofs(this, anim_sword_runb1, 3, sword_run4); ai_run(this, 14); }
void sword_run2(entity this) { set_animofs(this, anim_sword_runb1, 2, sword_run3); ai_run(this, 14); }
void sword_run1(entity this)
{
	set_animofs(this, anim_sword_runb1, 1, sword_run2);
	this.effects = EF_DIMLIGHT;
	ai_run(this, 14);
}

void sword_atk10(entity this) { set_animofs(this, anim_sword_attackb1, 10, sword_run1); ai_charge(this, 14); }
void sword_atk9(entity this) { set_animofs(this, anim_sword_attackb1, 9, sword_atk10); ai_charge(this, 14); }
void sword_atk8(entity this) { set_animofs(this, anim_sword_attackb1, 8, sword_atk9); ai_charge(this, 14); }
void sword_atk7(entity this) { set_animofs(this, anim_sword_attackb1, 7, sword_atk8); ai_melee(this, DEATH_MONSTER_SWORD.m_id, 60); }
void sword_atk6(entity this) { set_animofs(this, anim_sword_attackb1, 6, sword_atk7); ai_melee(this, DEATH_MONSTER_SWORD.m_id, 60); }
void sword_atk5(entity this) { set_animofs(this, anim_sword_attackb1, 5, sword_atk6); ai_melee(this, DEATH_MONSTER_SWORD.m_id, 60); }
void sword_atk4(entity this) { set_animofs(this, anim_sword_attackb1, 4, sword_atk5); ai_charge(this, 14); }
void sword_atk3(entity this) { set_animofs(this, anim_sword_attackb1, 3, sword_atk4); ai_charge(this, 14); }
void sword_atk2(entity this) { set_animofs(this, anim_sword_attackb1, 2, sword_atk3); ai_charge(this, 14); }
void sword_atk1(entity this)
{
	set_animofs(this, anim_sword_attackb1, 1, sword_atk2);
	_sound(this, 0, "knight/sword1.wav", 1, 1);
	ai_charge(this, 14);
}

//===========================================================================

void sword_die10(entity this) { set_animofs(this, anim_sword_death1, 10, sword_die10); CorpseThink(this); }
void sword_die9(entity this) { set_animofs(this, anim_sword_death1, 9, sword_die10); }
void sword_die8(entity this) { set_animofs(this, anim_sword_death1, 8, sword_die9); }
void sword_die7(entity this)
{
	set_animofs(this, anim_sword_death1, 7, sword_die8);
	_sound(this, 1, "player/axhit2.wav", 0.5, ATTN_NORM);
}
void sword_die6(entity this) { set_animofs(this, anim_sword_death1, 6, sword_die7); }
void sword_die5(entity this) { set_animofs(this, anim_sword_death1, 5, sword_die6); }
void sword_die4(entity this) { set_animofs(this, anim_sword_death1, 4, sword_die5); }
void sword_die3(entity this) { set_animofs(this, anim_sword_death1, 3, sword_die4); this.solid = SOLID_NOT; }
void sword_die2(entity this) { set_animofs(this, anim_sword_death1, 2, sword_die3); }
void sword_die1(entity this) { set_animofs(this, anim_sword_death1, 1, sword_die2); }

void sword_dieb11(entity this) { set_animofs(this, anim_sword_deathb1, 11, sword_dieb11); CorpseThink(this); }
void sword_dieb10(entity this) { set_animofs(this, anim_sword_deathb1, 10, sword_dieb11); }
void sword_dieb9(entity this) { set_animofs(this, anim_sword_deathb1, 9, sword_dieb10); }
void sword_dieb8(entity this) { set_animofs(this, anim_sword_deathb1, 8, sword_dieb9); }
void sword_dieb7(entity this)
{
	set_animofs(this, anim_sword_deathb1, 7, sword_dieb8);
	_sound(this, 1, "player/axhit2.wav", 0.5, ATTN_NORM);
}
void sword_dieb6(entity this) { set_animofs(this, anim_sword_deathb1, 6, sword_dieb7); }
void sword_dieb5(entity this) { set_animofs(this, anim_sword_deathb1, 5, sword_dieb6); }
void sword_dieb4(entity this) { set_animofs(this, anim_sword_deathb1, 4, sword_dieb5); }
void sword_dieb3(entity this) { set_animofs(this, anim_sword_deathb1, 3, sword_dieb4); this.solid = SOLID_NOT; }
void sword_dieb2(entity this) { set_animofs(this, anim_sword_deathb1, 2, sword_dieb3); }
void sword_dieb1(entity this) { set_animofs(this, anim_sword_deathb1, 1, sword_dieb2); }

void sword_die(entity this, entity inflictor, entity attacker, int deathtype)
{
// regular death
	this.effects = 0;
	if(random() < 0.5)
		sword_die1(this);
	else
		sword_dieb1(this);
}

void sword_pause(entity this)
{
	this.th_run = sword_run1; 
	setthink(this, sword_run1);
	this.nextthink = time + this.delay;
	this.delay = 0;
}

void sword_pain(entity this, entity attacker, float damage, int deathtype)
{
	this.th_run = sword_run1; 
	setthink(this, sword_run1);
	this.nextthink = time + 0.1;
	this.delay = 0;
	this.th_pain = func_null;
}

/*QUAKED monster_sword (1 0 0) (-16 -16 -24) (16 16 40) Ambush
The Invisible Swordsman

delay - seconds after first sighting before it attacks (default 10)
*/
spawnfunc(monster_sword)
{
	if(!MP_ROGUE) { delete(this); return; }
	monster_start(this, true, MON_PHANTOM_SWORDSMAN);
}
#endif // SVQC

#ifdef SVQC
METHOD(PhantomSwordsman, mr_setup, bool(PhantomSwordsman this, entity actor))
{
    TC(PhantomSwordsman, this);

	precache_sound("knight/sword1.wav");
	precache_sound("player/axhit2.wav");

	if(!this.delay)
		this.delay = 10;

    actor.health = 150;
    actor.th_stand = sword_stand1;
//	actor.th_walk = sword_walk1;
	actor.th_walk = sword_stand1;
	actor.th_run = sword_pause;
	actor.th_melee = sword_atk1;
	actor.th_die = sword_die;
	actor.th_pain = sword_pain;

    return true;
}
#endif
