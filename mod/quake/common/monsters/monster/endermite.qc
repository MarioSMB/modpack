#include "endermite.qh"

#ifdef SVQC
const int anim_endermite_stand = 0;
const int anim_endermite_walk = 0;
const int anim_endermite_death = 2;

.float idle_finished;
.float endermite_particletime;

void endermite_idlesound(entity this)
{
	if(time >= this.endermite_particletime)
	{
		this.endermite_particletime = time + 0.1;
		vector offset = '0 0 1';
		offset.z *= (random() * 16);
		Send_Effect(EFFECT_ENDERMAN, this.origin + offset + randomvec() * 8, '0 0 0', 1);
	}

	if(time < this.pain_finished)
		return;

	if(random() < 0.2 && time >= this.idle_finished)
	{
		this.idle_finished = time + 2;
		sound(this, CH_VOICE, SND_MON_ENDERMITE_IDLE_RANDOM(), 1, ATTN_NORM);
	}
}

void endermite_stand1(entity this);
void endermite_stand8(entity this) { set_anim(this, anim_endermite_stand, endermite_stand1); ai_stand(this); }
void endermite_stand7(entity this) { set_anim(this, anim_endermite_stand, endermite_stand1); ai_stand(this); }
void endermite_stand6(entity this) { set_anim(this, anim_endermite_stand, endermite_stand1); ai_stand(this); }
void endermite_stand5(entity this) { set_anim(this, anim_endermite_stand, endermite_stand1); ai_stand(this); }
void endermite_stand4(entity this) { set_anim(this, anim_endermite_stand, endermite_stand1); ai_stand(this); }
void endermite_stand3(entity this) { set_anim(this, anim_endermite_stand, endermite_stand1); ai_stand(this); }
void endermite_stand2(entity this) { set_anim(this, anim_endermite_stand, endermite_stand1); ai_stand(this); }
void endermite_stand1(entity this) { set_anim(this, anim_endermite_stand, endermite_stand2); ai_stand(this); endermite_idlesound(this); }

void endermite_moveframe(entity this)
{
	this.walkframe += 1;
	if(this.walkframe < anim_endermite_walk || this.walkframe > 4)
		this.walkframe = anim_endermite_walk;

	if(time >= this.footstep && IS_ONGROUND(this) && this.origin != this.oldorigin)
	{
		this.oldorigin = this.origin;
		this.footstep = time + 0.2 * random();
		sound(this, CH_VOICE, SND_MON_ENDERMITE_STEP_RANDOM(), 1, ATTN_NORM);
	}

	endermite_idlesound(this);
}

void endermite_walk(entity this)
{
	endermite_moveframe(this);
	set_anim(this, this.walkframe, endermite_walk);

	ai_walk(this, 8);
}

void endermite_run(entity this)
{
	endermite_moveframe(this);
	set_anim(this, this.walkframe, endermite_run);

	ai_run(this, 10);
}

void endermite_melee(entity this)
{
	set_anim(this, anim_endermite_stand, endermite_run);
	this.nextthink = time + 0.5;
	ai_face(this);
	ai_melee(this, DEATH_MONSTER_ENDERMITE.m_id, 120, false);
	this.attack_finished = time + 0.5;
}

//===========================================================================

void endermite_pain6(entity this) { set_anim(this, anim_endermite_stand, endermite_run); this.colormod = (this.charmed) ? '0 1 0' : '1 1 1'; this.glowmod = this.colormod; }
void endermite_pain5(entity this) { set_anim(this, anim_endermite_stand, endermite_pain6); }
void endermite_pain4(entity this) { set_anim(this, anim_endermite_stand, endermite_pain5); this.colormod = '1 0.8 0.8'; this.glowmod = this.colormod; }
void endermite_pain3(entity this) { set_anim(this, anim_endermite_stand, endermite_pain4);}
void endermite_pain2(entity this) { set_anim(this, anim_endermite_stand, endermite_pain3); ai_pain(this, 6); this.colormod = '1 0.6 0.6'; this.glowmod = this.colormod; }
void endermite_pain1(entity this) { set_anim(this, anim_endermite_stand, endermite_pain2); ai_pain(this, 6); }

void endermite_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	sound(this, CH_VOICE, SND_MON_ENDERMITE_PAIN_RANDOM(), 1, ATTN_NORM);

	this.pain_finished = time + 1.1;
	this.colormod = '1 0.9 0.9';
	this.glowmod = this.colormod;

	endermite_pain1(this);
}

//===========================================================================

void endermite_vanish(entity this)
{
	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

void endermite_die6(entity this) { set_anim(this, anim_endermite_death, endermite_vanish); this.angles_z = 90; this.nextthink = time + 0.67; }
void endermite_die5(entity this) { set_anim(this, anim_endermite_death, endermite_die6); this.angles_z = 75; }
void endermite_die4(entity this) { set_anim(this, anim_endermite_death, endermite_die5); this.angles_z = 60; }
void endermite_die3(entity this) { set_anim(this, anim_endermite_death, endermite_die4); this.angles_z = 45; }
void endermite_die2(entity this) { set_anim(this, anim_endermite_death, endermite_die3); this.angles_z = 30; }
void endermite_die1(entity this) { set_anim(this, anim_endermite_death, endermite_die2); this.angles_z = 15; this.solid = SOLID_NOT; }

void endermite_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CH_VOICE, "silverfish/kill.wav", 1, ATTN_NORM);

	this.angles_z = 0;
	this.colormod = '1 0.6 0.6';
	this.glowmod = this.colormod;
	endermite_die1(this);
}

/*QUAKED monster_endermite (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_endermite) { monster_start(this, true, MON_ENDERMITE); }
#endif // SVQC

#ifdef SVQC
METHOD(Endermite, mr_setup, bool(Endermite this, entity actor))
{
    TC(Endermite, this);

	precache_sound("silverfish/kill.wav");

	actor.yaw_speed = 180;

	actor.glowmod = actor.colormod;

    actor.health = 25;
    actor.th_stand = endermite_stand1;
	actor.th_walk = endermite_walk;
	actor.th_run = endermite_run;
	actor.th_pain = endermite_pain;
	actor.th_die = endermite_die;
	actor.th_melee = endermite_melee;

    return true;
}
#endif
