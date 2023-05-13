#include "rotfish.qh"

#ifdef SVQC
const int anim_fish_attack = 0; //'0 17 0'
const int anim_fish_death = 18; //'18 38 0'
const int anim_fish_swim = 39; //'39 56 0'
const int anim_fish_pain = 57; //'57 65 0'

void f_stand1(entity this);
void f_stand18(entity this) { set_animofs(this, anim_fish_swim, 18, f_stand1); ai_stand(this); }
void f_stand17(entity this) { set_animofs(this, anim_fish_swim, 17, f_stand18); ai_stand(this); }
void f_stand16(entity this) { set_animofs(this, anim_fish_swim, 16, f_stand17); ai_stand(this); }
void f_stand15(entity this) { set_animofs(this, anim_fish_swim, 15, f_stand16); ai_stand(this); }
void f_stand14(entity this) { set_animofs(this, anim_fish_swim, 14, f_stand15); ai_stand(this); }
void f_stand13(entity this) { set_animofs(this, anim_fish_swim, 13, f_stand14); ai_stand(this); }
void f_stand12(entity this) { set_animofs(this, anim_fish_swim, 12, f_stand13); ai_stand(this); }
void f_stand11(entity this) { set_animofs(this, anim_fish_swim, 11, f_stand12); ai_stand(this); }
void f_stand10(entity this) { set_animofs(this, anim_fish_swim, 10, f_stand11); ai_stand(this); }
void f_stand9(entity this) { set_animofs(this, anim_fish_swim, 9, f_stand10); ai_stand(this); }
void f_stand8(entity this) { set_animofs(this, anim_fish_swim, 8, f_stand9); ai_stand(this); }
void f_stand7(entity this) { set_animofs(this, anim_fish_swim, 7, f_stand8); ai_stand(this); }
void f_stand6(entity this) { set_animofs(this, anim_fish_swim, 6, f_stand7); ai_stand(this); }
void f_stand5(entity this) { set_animofs(this, anim_fish_swim, 5, f_stand6); ai_stand(this); }
void f_stand4(entity this) { set_animofs(this, anim_fish_swim, 4, f_stand5); ai_stand(this); }
void f_stand3(entity this) { set_animofs(this, anim_fish_swim, 3, f_stand4); ai_stand(this); }
void f_stand2(entity this) { set_animofs(this, anim_fish_swim, 2, f_stand3); ai_stand(this); }
void f_stand1(entity this) { set_animofs(this, anim_fish_swim, 1, f_stand2); ai_stand(this); }

void f_walk1(entity this);
void f_walk18(entity this) { set_animofs(this, anim_fish_swim, 18, f_walk1); ai_walk(this, 8); }
void f_walk17(entity this) { set_animofs(this, anim_fish_swim, 17, f_walk18); ai_walk(this, 8); }
void f_walk16(entity this) { set_animofs(this, anim_fish_swim, 16, f_walk17); ai_walk(this, 8); }
void f_walk15(entity this) { set_animofs(this, anim_fish_swim, 15, f_walk16); ai_walk(this, 8); }
void f_walk14(entity this) { set_animofs(this, anim_fish_swim, 14, f_walk15); ai_walk(this, 8); }
void f_walk13(entity this) { set_animofs(this, anim_fish_swim, 13, f_walk14); ai_walk(this, 8); }
void f_walk12(entity this) { set_animofs(this, anim_fish_swim, 12, f_walk13); ai_walk(this, 8); }
void f_walk11(entity this) { set_animofs(this, anim_fish_swim, 11, f_walk12); ai_walk(this, 8); }
void f_walk10(entity this) { set_animofs(this, anim_fish_swim, 10, f_walk11); ai_walk(this, 8); }
void f_walk9(entity this) { set_animofs(this, anim_fish_swim, 9, f_walk10); ai_walk(this, 8); }
void f_walk8(entity this) { set_animofs(this, anim_fish_swim, 8, f_walk9); ai_walk(this, 8); }
void f_walk7(entity this) { set_animofs(this, anim_fish_swim, 7, f_walk8); ai_walk(this, 8); }
void f_walk6(entity this) { set_animofs(this, anim_fish_swim, 6, f_walk7); ai_walk(this, 8); }
void f_walk5(entity this) { set_animofs(this, anim_fish_swim, 5, f_walk6); ai_walk(this, 8); }
void f_walk4(entity this) { set_animofs(this, anim_fish_swim, 4, f_walk5); ai_walk(this, 8); }
void f_walk3(entity this) { set_animofs(this, anim_fish_swim, 3, f_walk4); ai_walk(this, 8); }
void f_walk2(entity this) { set_animofs(this, anim_fish_swim, 2, f_walk3); ai_walk(this, 8); }
void f_walk1(entity this) { set_animofs(this, anim_fish_swim, 1, f_walk2); ai_walk(this, 8); }

void f_run1(entity this);
void f_run9(entity this) { set_animofs(this, anim_fish_swim, 17, f_run1); ai_run(this, 12); }
void f_run8(entity this) { set_animofs(this, anim_fish_swim, 15, f_run9); ai_run(this, 12); }
void f_run7(entity this) { set_animofs(this, anim_fish_swim, 13, f_run8); ai_run(this, 12); }
void f_run6(entity this) { set_animofs(this, anim_fish_swim, 11, f_run7); ai_run(this, 12); }
void f_run5(entity this) { set_animofs(this, anim_fish_swim, 9, f_run6); ai_run(this, 12); }
void f_run4(entity this) { set_animofs(this, anim_fish_swim, 7, f_run5); ai_run(this, 12); }
void f_run3(entity this) { set_animofs(this, anim_fish_swim, 5, f_run4); ai_run(this, 12); }
void f_run2(entity this) { set_animofs(this, anim_fish_swim, 3, f_run3); ai_run(this, 12); }
void f_run1(entity this)
{
	set_animofs(this, anim_fish_swim, 1, f_run2);
	ai_run(this, 12);
	if(random() < 0.5)
		_sound(this, CH_VOICE, "fish/idle.wav", 1, ATTN_NORM);
}

void fish_melee(entity this)
{
	if(!this.enemy)
		return;		// removed before stroke

	if(vdist(this.enemy.origin - this.origin, >, 60))
		return;
		
	_sound(this, CH_VOICE, "fish/bite.wav", 1, ATTN_NORM);
	float ldmg = (random() + random()) * 3;
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_ROTFISH.m_id);
}

void f_attack1(entity this);
void f_attack18(entity this) { set_animofs(this, anim_fish_attack, 18, f_attack1); ai_charge(this, 10); }
void f_attack17(entity this) { set_animofs(this, anim_fish_attack, 17, f_attack18); ai_charge(this, 10); }
void f_attack16(entity this) { set_animofs(this, anim_fish_attack, 16, f_attack17); ai_charge(this, 10); }
void f_attack15(entity this) { set_animofs(this, anim_fish_attack, 15, f_attack16); fish_melee(this); }
void f_attack14(entity this) { set_animofs(this, anim_fish_attack, 14, f_attack15); ai_charge(this, 10); }
void f_attack13(entity this) { set_animofs(this, anim_fish_attack, 13, f_attack14); ai_charge(this, 10); }
void f_attack12(entity this) { set_animofs(this, anim_fish_attack, 12, f_attack13); ai_charge(this, 10); }
void f_attack11(entity this) { set_animofs(this, anim_fish_attack, 11, f_attack12); ai_charge(this, 10); }
void f_attack10(entity this) { set_animofs(this, anim_fish_attack, 10, f_attack11); ai_charge(this, 10); }
void f_attack9(entity this) { set_animofs(this, anim_fish_attack, 9, f_attack10); fish_melee(this); }
void f_attack8(entity this) { set_animofs(this, anim_fish_attack, 8, f_attack9); ai_charge(this, 10); }
void f_attack7(entity this) { set_animofs(this, anim_fish_attack, 7, f_attack8); ai_charge(this, 10); }
void f_attack6(entity this) { set_animofs(this, anim_fish_attack, 6, f_attack7); ai_charge(this, 10); }
void f_attack5(entity this) { set_animofs(this, anim_fish_attack, 5, f_attack6); ai_charge(this, 10); }
void f_attack4(entity this) { set_animofs(this, anim_fish_attack, 4, f_attack5); ai_charge(this, 10); }
void f_attack3(entity this) { set_animofs(this, anim_fish_attack, 3, f_attack4); fish_melee(this); }
void f_attack2(entity this) { set_animofs(this, anim_fish_attack, 2, f_attack3); ai_charge(this, 10); }
void f_attack1(entity this) { set_animofs(this, anim_fish_attack, 1, f_attack2); ai_charge(this, 10); }

void f_death21(entity this)
{
	set_animofs(this, anim_fish_death, 18, f_death21);
	this.solid = SOLID_NOT;
	CorpseThink(this);
}
void f_death20(entity this) { set_animofs(this, anim_fish_death, 18, f_death21); }
void f_death19(entity this) { set_animofs(this, anim_fish_death, 18, f_death20); }
void f_death18(entity this) { set_animofs(this, anim_fish_death, 18, f_death19); }
void f_death17(entity this) { set_animofs(this, anim_fish_death, 17, f_death18); }
void f_death16(entity this) { set_animofs(this, anim_fish_death, 16, f_death17); }
void f_death15(entity this) { set_animofs(this, anim_fish_death, 15, f_death16); }
void f_death14(entity this) { set_animofs(this, anim_fish_death, 14, f_death15); }
void f_death13(entity this) { set_animofs(this, anim_fish_death, 13, f_death14); }
void f_death12(entity this) { set_animofs(this, anim_fish_death, 12, f_death13); }
void f_death11(entity this) { set_animofs(this, anim_fish_death, 11, f_death12); }
void f_death10(entity this) { set_animofs(this, anim_fish_death, 10, f_death11); }
void f_death9(entity this) { set_animofs(this, anim_fish_death, 9, f_death10); }
void f_death8(entity this) { set_animofs(this, anim_fish_death, 8, f_death9); }
void f_death7(entity this) { set_animofs(this, anim_fish_death, 7, f_death8); }
void f_death6(entity this) { set_animofs(this, anim_fish_death, 6, f_death7); }
void f_death5(entity this) { set_animofs(this, anim_fish_death, 5, f_death6); }
void f_death4(entity this) { set_animofs(this, anim_fish_death, 4, f_death5); }
void f_death3(entity this) { set_animofs(this, anim_fish_death, 3, f_death4); }
void f_death2(entity this) { set_animofs(this, anim_fish_death, 2, f_death3); this.solid = SOLID_NOT; }
void f_death1(entity this, entity inflictor, entity attacker)
{
	set_animofs(this, anim_fish_death, 1, f_death2);
	_sound(this, CH_VOICE, "fish/death.wav", 1, ATTN_NORM);
}

void f_pain9(entity this) { set_animofs(this, anim_fish_swim, 9, f_run1); ai_pain(this, 6); }
void f_pain8(entity this) { set_animofs(this, anim_fish_swim, 8, f_pain9); ai_pain(this, 6); }
void f_pain7(entity this) { set_animofs(this, anim_fish_swim, 7, f_pain8); ai_pain(this, 6); }
void f_pain6(entity this) { set_animofs(this, anim_fish_swim, 6, f_pain7); ai_pain(this, 6); }
void f_pain5(entity this) { set_animofs(this, anim_fish_swim, 5, f_pain6); ai_pain(this, 6); }
void f_pain4(entity this) { set_animofs(this, anim_fish_swim, 4, f_pain5); ai_pain(this, 6); }
void f_pain3(entity this) { set_animofs(this, anim_fish_swim, 3, f_pain4); ai_pain(this, 6); }
void f_pain2(entity this) { set_animofs(this, anim_fish_swim, 2, f_pain3); ai_pain(this, 6); }
void f_pain1(entity this) { set_animofs(this, anim_fish_swim, 1, f_pain2); }

void fish_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	// check for gib
	if(this.health < -20)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowGib(this, "progs/gib1.mdl", this.health);
		ThrowGib(this, "progs/gib2.mdl", this.health);
		ThrowGib(this, "progs/gib3.mdl", this.health);
		setthink(this, SUB_Remove);
		this.nextthink = time + 0.1;
		return;
	}

	// regular death
	f_death1(this, inflictor, attacker);
}

void fish_pain(entity this, entity attacker, float damage, int deathtype)
{

// fish allways do pain frames
	f_pain1(this);
}

/*QUAKED monster_fish(1 0 0)(-16 -16 -24)(16 16 24) Ambush
*/
spawnfunc(monster_fish) { monster_start(this, true, MON_ROTFISH); }
#endif // SVQC

#ifdef SVQC
METHOD(Rotfish, mr_setup, bool(Rotfish this, entity actor))
{
    TC(Rotfish, this);

	precache_sound2("fish/death.wav");
	precache_sound2("fish/bite.wav");
	precache_sound2("fish/idle.wav");

    actor.health = 25;
    actor.th_stand = f_stand1;
	actor.th_walk = f_walk1;
	actor.th_run = f_run1;
	actor.th_die = fish_die;
	actor.th_pain = fish_pain;
	actor.th_melee = f_attack1;

    return true;
}
#endif
