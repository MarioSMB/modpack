#include "mcspider.qh"

#ifdef SVQC
// 0 is a dead frame
const int anim_mcspider_stand = 1;
const int anim_mcspider_walk = 0;
const int anim_mcspider_death = 4;

const int MON_MCSPIDER_CAVE = BIT(1);

.float idle_finished;

void mcspider_idlesound(entity this)
{
	if(time < this.pain_finished)
		return;

	if(random() < 0.2 && time >= this.idle_finished)
	{
		this.idle_finished = time + 2;
		sound(this, CH_VOICE, SND_MON_MCSPIDER_IDLE_RANDOM(), 1, ATTN_NORM);
	}
}

void mcspider_stand1(entity this);
void mcspider_stand8(entity this) { set_anim(this, anim_mcspider_stand, mcspider_stand1); ai_stand(this); }
void mcspider_stand7(entity this) { set_anim(this, anim_mcspider_stand, mcspider_stand1); ai_stand(this); }
void mcspider_stand6(entity this) { set_anim(this, anim_mcspider_stand, mcspider_stand1); ai_stand(this); }
void mcspider_stand5(entity this) { set_anim(this, anim_mcspider_stand, mcspider_stand1); ai_stand(this); }
void mcspider_stand4(entity this) { set_anim(this, anim_mcspider_stand, mcspider_stand1); ai_stand(this); }
void mcspider_stand3(entity this) { set_anim(this, anim_mcspider_stand, mcspider_stand1); ai_stand(this); }
void mcspider_stand2(entity this) { set_anim(this, anim_mcspider_stand, mcspider_stand1); ai_stand(this); }
void mcspider_stand1(entity this) { set_anim(this, anim_mcspider_stand, mcspider_stand2); ai_stand(this); mcspider_idlesound(this); }

void mcspider_moveframe(entity this)
{
	this.walkframe += 1;
	if(this.walkframe < anim_mcspider_walk || this.walkframe >= 3)
		this.walkframe = anim_mcspider_walk;

	if(time >= this.footstep && IS_ONGROUND(this) && this.origin != this.oldorigin)
	{
		this.oldorigin = this.origin;
		this.footstep = time + 0.2 * random();
		sound(this, CH_VOICE, SND_MON_MCSPIDER_STEP_RANDOM(), 1, ATTN_NORM);
	}

	mcspider_idlesound(this);
}

void mcspider_walk(entity this)
{
	mcspider_moveframe(this);
	set_anim(this, this.walkframe, mcspider_walk);

	ai_walk(this, 10);
}

void mcspider_run(entity this)
{
	mcspider_moveframe(this);
	set_anim(this, this.walkframe, mcspider_run);

	ai_run(this, 16);
}

void mcspider_melee(entity this)
{
	set_anim(this, anim_mcspider_stand, mcspider_run);
	this.nextthink = time + 0.5;
	ai_face(this);
	ai_melee(this, DEATH_MONSTER_MCSPIDER.m_id, 120, false);
	this.attack_finished = time + 0.5;

	if(this.skin == 1 && this.enemy && this.enemy.health > 0 && ai_checkmelee(this, 120, false))
	{
		float efftime = 12;
		float curtime = StatusEffects_gettime(STATUSEFFECT_Poisoned, this.enemy);
		if((time + efftime) > curtime)
			StatusEffects_apply(STATUSEFFECT_Poisoned, this.enemy, time + efftime, 0);
	}
}

//===========================================================================

void mcspider_pain6(entity this) { set_anim(this, anim_mcspider_stand, mcspider_run); this.colormod = (this.charmed) ? '0 1 0' : '1 1 1'; }
void mcspider_pain5(entity this) { set_anim(this, anim_mcspider_stand, mcspider_pain6); }
void mcspider_pain4(entity this) { set_anim(this, anim_mcspider_stand, mcspider_pain5); this.colormod = '1 0.8 0.8'; }
void mcspider_pain3(entity this) { set_anim(this, anim_mcspider_stand, mcspider_pain4);}
void mcspider_pain2(entity this) { set_anim(this, anim_mcspider_stand, mcspider_pain3); ai_pain(this, 6); this.colormod = '1 0.6 0.6'; }
void mcspider_pain1(entity this) { set_anim(this, anim_mcspider_stand, mcspider_pain2); ai_pain(this, 6); }

void mcspider_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	sound(this, CH_VOICE, SND_MON_MCSPIDER_IDLE_RANDOM(), 1, ATTN_NORM);

	this.pain_finished = time + 1.1;
	this.colormod = '1 0.9 0.9';

	mcspider_pain1(this);
}

//===========================================================================

void mcspider_vanish(entity this)
{
	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

void mcspider_die7(entity this) { set_animofs(this, anim_mcspider_death, 7, mcspider_vanish); this.nextthink = time + 0.7; }
void mcspider_die6(entity this) { set_animofs(this, anim_mcspider_death, 6, mcspider_die7); }
void mcspider_die5(entity this) { set_animofs(this, anim_mcspider_death, 5, mcspider_die6); }
void mcspider_die4(entity this) { set_animofs(this, anim_mcspider_death, 4, mcspider_die5); }
void mcspider_die3(entity this) { set_animofs(this, anim_mcspider_death, 3, mcspider_die4); }
void mcspider_die2(entity this) { set_animofs(this, anim_mcspider_death, 2, mcspider_die3); }
void mcspider_die1(entity this) { set_animofs(this, anim_mcspider_death, 1, mcspider_die2); this.solid = SOLID_NOT; }

void mcspider_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CH_VOICE, "mcspider/death.wav", 1, ATTN_NORM);

	this.colormod = '1 0.6 0.6';
	mcspider_die1(this);
}

/*QUAKED monster_mcspider (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_mcspider) { monster_start(this, true, MON_MCSPIDER); }
#endif // SVQC

#ifdef SVQC
METHOD(MCSpider, mr_setup, bool(MCSpider this, entity actor))
{
    TC(MCSpider, this);

	precache_sound("mcspider/death.wav");

	if(random() < 0.25)
		actor.spawnflags |= MON_MCSPIDER_CAVE;

	actor.yaw_speed = 180;

	if(actor.spawnflags & MON_MCSPIDER_CAVE)
	{
		actor.skin = 1;
		actor.scale = 0.6;
		setsize(actor, this.m_mins * actor.scale, this.m_maxs * actor.scale);
	}

    actor.health = 100;
    actor.th_stand = mcspider_stand1;
	actor.th_walk = mcspider_walk;
	actor.th_run = mcspider_run;
	actor.th_pain = mcspider_pain;
	actor.th_die = mcspider_die;
	actor.th_melee = mcspider_melee;

    return true;
}
#endif
