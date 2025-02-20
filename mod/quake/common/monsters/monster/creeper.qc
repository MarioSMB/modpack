#include "creeper.qh"

#ifdef SVQC
const int anim_creeper_stand = 0;
const int anim_creeper_walk = 2;
const int anim_creeper_death = 41;

const int MON_CREEPER_NERD = BIT(1);

void creeper_stand1(entity this);
void creeper_stand8(entity this) { set_animofs(this, anim_creeper_stand, 2, creeper_stand1); ai_stand(this); }
void creeper_stand7(entity this) { set_animofs(this, anim_creeper_stand, 2, creeper_stand1); ai_stand(this); }
void creeper_stand6(entity this) { set_animofs(this, anim_creeper_stand, 2, creeper_stand1); ai_stand(this); }
void creeper_stand5(entity this) { set_animofs(this, anim_creeper_stand, 2, creeper_stand1); ai_stand(this); }
void creeper_stand4(entity this) { set_animofs(this, anim_creeper_stand, 2, creeper_stand1); ai_stand(this); }
void creeper_stand3(entity this) { set_animofs(this, anim_creeper_stand, 2, creeper_stand1); ai_stand(this); }
void creeper_stand2(entity this) { set_animofs(this, anim_creeper_stand, 2, creeper_stand1); ai_stand(this); }
void creeper_stand1(entity this) { set_animofs(this, anim_creeper_stand, 1, creeper_stand2); ai_stand(this); }

void creeper_moveframe(entity this)
{
	this.walkframe += 1;
	if(this.walkframe <= anim_creeper_walk || this.walkframe >= 41)
		this.walkframe = anim_creeper_walk;
}

void creeper_walk(entity this)
{
	creeper_moveframe(this);
	set_anim(this, this.walkframe, creeper_walk);
	this.nextthink = time + 0.05; // slow animation needs fixing

	ai_walk(this, 4);
}

void creeper_run(entity this)
{
	creeper_moveframe(this);
	set_anim(this, this.walkframe, creeper_run);
	this.nextthink = time + 0.05; // slow animation needs fixing

	ai_run(this, 6);
}

//===========================================================================

void creeper_primecolor(entity this, float colorscale)
{
	this.colormod = '1 1 1';
	if(colorscale)
	{
		this.colormod_x *= colorscale;
		this.colormod_y /= colorscale;
		this.colormod_z /= colorscale;
	}

	this.scale = colorscale;
}

void creeper_detonate(entity this)
{
	sound(this, CH_VOICE, SND_MON_CREEPER_EXPLODE_RANDOM(), 1, ATTN_NORM);
	Send_Effect(EFFECT_SMOKE_LARGE, this.origin, '0 0 0', 1);
	T_RadiusDamage(this, this, 160, DEATH_MONSTER_CREEPER.m_id, this);

	Killed(this, this, this, DEATH_MONSTER_CREEPER.m_id);
}

void creeper_explode20(entity this) { set_anim(this, anim_creeper_stand, creeper_run); }
void creeper_explode19(entity this) { set_anim(this, anim_creeper_stand, creeper_explode20); }
void creeper_explode18(entity this) { set_anim(this, anim_creeper_stand, creeper_explode19); }
void creeper_explode17(entity this) { set_anim(this, anim_creeper_stand, creeper_explode18); }
void creeper_explode16(entity this) { set_anim(this, anim_creeper_stand, creeper_explode17); creeper_primecolor(this, 1); }
void creeper_explode15(entity this) { set_anim(this, anim_creeper_stand, creeper_explode16); creeper_primecolor(this, 1.05); }
void creeper_explode14(entity this) { set_anim(this, anim_creeper_stand, creeper_explode15); creeper_primecolor(this, 1.10); }
void creeper_explode13(entity this) { set_anim(this, anim_creeper_stand, creeper_explode14); creeper_primecolor(this, 1.15); }
void creeper_explode12(entity this) { set_anim(this, anim_creeper_stand, creeper_explode13); creeper_primecolor(this, 1.20); }
void creeper_explode11(entity this)
{
	set_anim(this, anim_creeper_stand, creeper_explode12);
	if(vdist(this.origin - this.enemy.origin, <=, 200))
		creeper_detonate(this);
}
void creeper_explode10(entity this)
{
	set_anim(this, anim_creeper_stand, creeper_explode11);
	this.nextthink = time + 1;
	if(vdist(this.origin - this.enemy.origin, <=, 200))
		creeper_detonate(this);
}
void creeper_explode9(entity this) { set_anim(this, anim_creeper_stand, creeper_explode10); }
void creeper_explode8(entity this) { set_anim(this, anim_creeper_stand, creeper_explode9); }
void creeper_explode7(entity this) { set_anim(this, anim_creeper_stand, creeper_explode8); }
void creeper_explode6(entity this) { set_anim(this, anim_creeper_stand, creeper_explode7); creeper_primecolor(this, 1.25); }
void creeper_explode5(entity this) { set_anim(this, anim_creeper_stand, creeper_explode6); creeper_primecolor(this, 1.20); }
void creeper_explode4(entity this) { set_anim(this, anim_creeper_stand, creeper_explode5); creeper_primecolor(this, 1.15); }
void creeper_explode3(entity this) { set_anim(this, anim_creeper_stand, creeper_explode4); creeper_primecolor(this, 1.10); }
void creeper_explode2(entity this) { set_anim(this, anim_creeper_stand, creeper_explode3); creeper_primecolor(this, 1.05); }
void creeper_explode1(entity this)
{
	set_anim(this, anim_creeper_stand, creeper_explode2);
	_sound(this, CH_VOICE, "creeper/ranged.wav", 1, ATTN_NORM);
	this.attack_finished = time + 2;
	this.pain_finished = time + 2; // prevent animation cutting
	creeper_primecolor(this, 1);
}

//===========================================================================

void creeper_pain6(entity this) { set_anim(this, anim_creeper_stand, creeper_run); this.colormod = (this.charmed) ? '0 1 0' : '1 1 1'; }
void creeper_pain5(entity this) { set_anim(this, anim_creeper_stand, creeper_pain6); }
void creeper_pain4(entity this) { set_anim(this, anim_creeper_stand, creeper_pain5); this.colormod = '1 0.8 0.8'; }
void creeper_pain3(entity this) { set_anim(this, anim_creeper_stand, creeper_pain4);}
void creeper_pain2(entity this) { set_anim(this, anim_creeper_stand, creeper_pain3); ai_pain(this, 6); this.colormod = '1 0.6 0.6'; }
void creeper_pain1(entity this) { set_anim(this, anim_creeper_stand, creeper_pain2); ai_pain(this, 6); }

void creeper_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	sound(this, CH_VOICE, SND_MON_CREEPER_PAIN_RANDOM(), 1, ATTN_NORM);

	this.pain_finished = time + 1.1;
	this.colormod = '1 0.9 0.9';
	this.scale = 1;

	creeper_pain1(this);
}

//===========================================================================

void creeper_vanish(entity this)
{
	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

void creeper_die21(entity this) { set_animofs(this, anim_creeper_death, 21, creeper_vanish); this.nextthink = time + 0.7; }
void creeper_die20(entity this) { set_animofs(this, anim_creeper_death, 20, creeper_die21); this.nextthink = time + 0.05; }
void creeper_die19(entity this) { set_animofs(this, anim_creeper_death, 19, creeper_die20); this.nextthink = time + 0.05; }
void creeper_die18(entity this) { set_animofs(this, anim_creeper_death, 18, creeper_die19); this.nextthink = time + 0.05; }
void creeper_die17(entity this) { set_animofs(this, anim_creeper_death, 17, creeper_die18); this.nextthink = time + 0.05; }
void creeper_die16(entity this) { set_animofs(this, anim_creeper_death, 16, creeper_die17); this.nextthink = time + 0.05; }
void creeper_die15(entity this) { set_animofs(this, anim_creeper_death, 15, creeper_die16); this.nextthink = time + 0.05; }
void creeper_die14(entity this) { set_animofs(this, anim_creeper_death, 14, creeper_die15); this.nextthink = time + 0.05; }
void creeper_die13(entity this) { set_animofs(this, anim_creeper_death, 13, creeper_die14); this.nextthink = time + 0.05; }
void creeper_die12(entity this) { set_animofs(this, anim_creeper_death, 12, creeper_die13); this.nextthink = time + 0.05; }
void creeper_die11(entity this) { set_animofs(this, anim_creeper_death, 11, creeper_die12); this.nextthink = time + 0.05; }
void creeper_die10(entity this) { set_animofs(this, anim_creeper_death, 10, creeper_die11); this.nextthink = time + 0.05; }
void creeper_die9(entity this) { set_animofs(this, anim_creeper_death, 9, creeper_die10); this.nextthink = time + 0.05; }
void creeper_die8(entity this) { set_animofs(this, anim_creeper_death, 8, creeper_die9); this.nextthink = time + 0.05; }
void creeper_die7(entity this) { set_animofs(this, anim_creeper_death, 7, creeper_die8); this.nextthink = time + 0.05; }
void creeper_die6(entity this) { set_animofs(this, anim_creeper_death, 6, creeper_die7); this.nextthink = time + 0.05; }
void creeper_die5(entity this) { set_animofs(this, anim_creeper_death, 5, creeper_die6); this.nextthink = time + 0.05; }
void creeper_die4(entity this) { set_animofs(this, anim_creeper_death, 4, creeper_die5); this.nextthink = time + 0.05; }
void creeper_die3(entity this) { set_animofs(this, anim_creeper_death, 3, creeper_die4); this.nextthink = time + 0.05; }
void creeper_die2(entity this) { set_animofs(this, anim_creeper_death, 2, creeper_die3); this.nextthink = time + 0.05; }
void creeper_die1(entity this) { set_animofs(this, anim_creeper_death, 1, creeper_die2); this.solid = SOLID_NOT; this.nextthink = time + 0.05; }

void creeper_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(deathtype == DEATH_MONSTER_CREEPER.m_id && attacker == this)
	{
		// exploded to death
		delete(this);
		return;
	}

	_sound(this, CH_VOICE, "creeper/death.wav", 1, ATTN_NORM);

	if(deathtype == DEATH_MONSTER_SKELETON.m_id)
	{
		RandomSelection_Init();
		FOREACH(Weapons, it.spawnflags & WEP_FLAG_MUSIC,
		{
			RandomSelection_AddEnt(it, 1, 1);
		});
		STAT(WEAPONS, this) = RandomSelection_chosen_ent.m_wepset;
		DropBackpack(this);
	}

	this.colormod = '1 0.6 0.6';
	creeper_die1(this);
}

/*QUAKED monster_creeper (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_creeper) { monster_start(this, true, MON_CREEPER); }
#endif // SVQC

#ifdef SVQC
METHOD(Creeper, mr_setup, bool(Creeper this, entity actor))
{
    TC(Creeper, this);

	precache_sound("creeper/death.wav");
	precache_sound("creeper/explode1.wav");
	precache_sound("creeper/explode2.wav");
	precache_sound("creeper/explode3.wav");
	precache_sound("creeper/explode4.wav");
	precache_sound("creeper/ranged.wav");

	if(random() < 0.2)
		actor.spawnflags |= MON_CREEPER_NERD;

	actor.yaw_speed = 180;

	if(actor.spawnflags & MON_CREEPER_NERD)
		actor.skin = 1;
	else
		actor.skin = 0;

    actor.health = 100;
    actor.th_stand = creeper_stand1;
	actor.th_walk = creeper_walk;
	actor.th_run = creeper_run;
	actor.th_pain = creeper_pain;
	actor.th_die = creeper_die;
	actor.th_melee = creeper_explode1;

    return true;
}
#endif
