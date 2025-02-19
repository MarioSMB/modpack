#include "wither_skeleton.qh"

#ifdef SVQC
const int anim_wskeleton_shoot = 2;
const int anim_wskeleton_stand = 22;
const int anim_wskeleton_death = 22;
const int anim_wskeleton_run = 96;
const int anim_wskeleton_walk = 117;
const int anim_wskeleton_attack = 71;

.float idle_finished;

void wskeleton_idlesound(entity this)
{
	if(time < this.pain_finished)
		return;

	if(random() < 0.2 && time >= this.idle_finished)
	{
		this.idle_finished = time + 2;
		sound(this, CH_VOICE, SND_MON_WITHER_SKELETON_IDLE_RANDOM(), 1, ATTN_NORM);
	}
}

void wskeleton_stand(entity this)
{
	this.walkframe += 1;
	if(this.walkframe < anim_wskeleton_stand || this.walkframe > 95)
		this.walkframe = anim_wskeleton_stand;

	wskeleton_idlesound(this);
	set_anim(this, this.walkframe, wskeleton_stand);

	ai_stand(this);
}

void wskeleton_moveframe(entity this, int startframe, int endframe)
{
	this.walkframe += 1;
	if(this.walkframe < startframe || this.walkframe > endframe)
		this.walkframe = startframe;

	if(time >= this.footstep && IS_ONGROUND(this))
	{
		this.footstep = time + 0.3 + random();
		sound(this, CH_VOICE, SND_MON_WITHER_SKELETON_STEP_RANDOM(), 1, ATTN_NORM);
	}

	wskeleton_idlesound(this);
}

void wskeleton_walk(entity this)
{
	wskeleton_moveframe(this, anim_wskeleton_walk, 133);
	set_anim(this, this.walkframe, wskeleton_walk);

	ai_walk(this, 10);
}

void wskeleton_run(entity this)
{
	wskeleton_moveframe(this, anim_wskeleton_run, 116);
	set_anim(this, this.walkframe, wskeleton_run);
	this.nextthink = time + 0.05;

	ai_run(this, 8);
}

void wskeleton_melee(entity this)
{
	set_anim(this, anim_wskeleton_attack, wskeleton_run);
	this.nextthink = time + 0.5;
	ai_face(this);
	ai_melee(this, DEATH_MONSTER_WITHER_SKELETON.m_id, 100, false);
	this.attack_finished = time + 0.5;

	if(this.enemy && this.enemy.health > 0 && ai_checkmelee(this, 100, false))
	{
		float withertime = 6;
		float curtime = StatusEffects_gettime(STATUSEFFECT_Withering, this.enemy);
		if((time + withertime) > curtime)
			StatusEffects_apply(STATUSEFFECT_Withering, this.enemy, time + withertime, 0);
	}
}

//===========================================================================

void wskeleton_pain6(entity this) { set_anim(this, anim_wskeleton_stand, wskeleton_run); this.colormod = (this.charmed) ? '0 1 0' : '1 1 1'; }
void wskeleton_pain5(entity this) { set_anim(this, anim_wskeleton_stand, wskeleton_pain6); }
void wskeleton_pain4(entity this) { set_anim(this, anim_wskeleton_stand, wskeleton_pain5); this.colormod = '1 0.8 0.8'; }
void wskeleton_pain3(entity this) { set_anim(this, anim_wskeleton_stand, wskeleton_pain4);}
void wskeleton_pain2(entity this) { set_anim(this, anim_wskeleton_stand, wskeleton_pain3); ai_pain(this, 6); this.colormod = '1 0.6 0.6'; }
void wskeleton_pain1(entity this) { set_anim(this, anim_wskeleton_stand, wskeleton_pain2); ai_pain(this, 6); }

void wskeleton_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	sound(this, CH_VOICE, SND_MON_WITHER_SKELETON_PAIN_RANDOM(), 1, ATTN_NORM);

	this.pain_finished = time + 1;
	this.colormod = '1 0.9 0.9';

	wskeleton_pain1(this);
}

//===========================================================================

void wskeleton_vanish(entity this)
{
	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

void wskeleton_die7(entity this) { set_animofs(this, anim_wskeleton_death, 7, wskeleton_vanish); this.nextthink = time + 0.7; this.angles_z = 90; }
void wskeleton_die6(entity this) { set_animofs(this, anim_wskeleton_death, 6, wskeleton_die7); this.angles_z = 90; }
void wskeleton_die5(entity this) { set_animofs(this, anim_wskeleton_death, 5, wskeleton_die6); this.angles_z = 75; }
void wskeleton_die4(entity this) { set_animofs(this, anim_wskeleton_death, 4, wskeleton_die5); this.angles_z = 60; }
void wskeleton_die3(entity this) { set_animofs(this, anim_wskeleton_death, 3, wskeleton_die4); this.angles_z = 45; }
void wskeleton_die2(entity this) { set_animofs(this, anim_wskeleton_death, 2, wskeleton_die3); this.angles_z = 30; }
void wskeleton_die1(entity this) { set_animofs(this, anim_wskeleton_death, 1, wskeleton_die2); this.solid = SOLID_NOT; this.angles_z = 15; }

void wskeleton_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(random() < 0.5)
		_sound(this, CH_VOICE, "wither_skeleton/death1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "wither_skeleton/death2.wav", 1, ATTN_NORM);

	this.colormod = '1 0.6 0.6';
	this.angles_z = 0;
	wskeleton_die1(this);
}

/*QUAKED monster_wither_skeleton (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_wither_skeleton) { monster_start(this, true, MON_WITHER_SKELETON); }
#endif // SVQC

#ifdef SVQC
METHOD(WitherSkeleton, mr_setup, bool(WitherSkeleton this, entity actor))
{
    TC(WitherSkeleton, this);

	precache_sound("wither_skeleton/death1.wav");
	precache_sound("wither_skeleton/death2.wav");

	actor.spawnflags |= SPAWNFLAG_NEARSIGHTED;

	actor.yaw_speed = 180;

    actor.health = 120;
    actor.th_stand = wskeleton_stand;
	actor.th_walk = wskeleton_walk;
	actor.th_run = wskeleton_run;
	actor.th_pain = wskeleton_pain;
	actor.th_die = wskeleton_die;
	actor.th_melee = wskeleton_melee;

    return true;
}
#endif
