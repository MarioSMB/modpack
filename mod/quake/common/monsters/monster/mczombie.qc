#include "mczombie.qh"

#ifdef SVQC
// 0 is a dead frame
const int anim_mczombie_stand = 1;
const int anim_mczombie_walk = 2;
const int anim_mczombie_death = 52;

const int MCZOMBIE_HUSK = BIT(1);

.float idle_finished;

void mczombie_idlesound(entity this)
{
	if(time < this.pain_finished)
		return;

	if(random() < 0.2 && time >= this.idle_finished)
	{
		this.idle_finished = time + 2 + (random() * 2);
		if(this.skin == 1)
		{
			float r = random();
			if(r < 0.33)
				_sound(this, CH_VOICE, "husk/idle1.wav", 1, ATTN_NORM);
			else if(r < 0.66)
				_sound(this, CH_VOICE, "husk/idle2.wav", 1, ATTN_NORM);
			else
				_sound(this, CH_VOICE, "husk/idle3.wav", 1, ATTN_NORM);
		}
		else
		{
			float r = random();
			if(r < 0.33)
				_sound(this, CH_VOICE, "mczombie/say1.wav", 1, ATTN_NORM);
			else if(r < 0.66)
				_sound(this, CH_VOICE, "mczombie/say2.wav", 1, ATTN_NORM);
			else
				_sound(this, CH_VOICE, "mczombie/say3.wav", 1, ATTN_NORM);
		}
	}
}

void mczombie_stand1(entity this);
void mczombie_stand8(entity this) { set_animofs(this, anim_mczombie_stand, 2, mczombie_stand1); ai_stand(this); }
void mczombie_stand7(entity this) { set_animofs(this, anim_mczombie_stand, 2, mczombie_stand1); ai_stand(this); }
void mczombie_stand6(entity this) { set_animofs(this, anim_mczombie_stand, 2, mczombie_stand1); ai_stand(this); }
void mczombie_stand5(entity this) { set_animofs(this, anim_mczombie_stand, 2, mczombie_stand1); ai_stand(this); }
void mczombie_stand4(entity this) { set_animofs(this, anim_mczombie_stand, 2, mczombie_stand1); ai_stand(this); }
void mczombie_stand3(entity this) { set_animofs(this, anim_mczombie_stand, 2, mczombie_stand1); ai_stand(this); }
void mczombie_stand2(entity this) { set_animofs(this, anim_mczombie_stand, 2, mczombie_stand1); ai_stand(this); }
void mczombie_stand1(entity this) { set_animofs(this, anim_mczombie_stand, 1, mczombie_stand2); ai_stand(this); mczombie_idlesound(this); }

void mczombie_moveframe(entity this)
{
	this.walkframe += 1;
	if(this.walkframe <= anim_mczombie_walk || this.walkframe >= 51)
		this.walkframe = anim_mczombie_walk;

	if(time >= this.footstep && IS_ONGROUND(this))
	{
		this.footstep = time + 1 + random();
		if(this.skin == 1)
		{
			float r = random();
			if(r < 0.2)
				_sound(this, CH_VOICE, "husk/step1.wav", 1, ATTN_NORM);
			else if(r < 0.4)
				_sound(this, CH_VOICE, "husk/step2.wav", 1, ATTN_NORM);
			else if(r < 0.6)
				_sound(this, CH_VOICE, "husk/step3.wav", 1, ATTN_NORM);
			else if(r < 0.8)
				_sound(this, CH_VOICE, "husk/step4.wav", 1, ATTN_NORM);
			else
				_sound(this, CH_VOICE, "husk/step5.wav", 1, ATTN_NORM);
		}
		else
		{
			float r = random();
			if(r < 0.2)
				_sound(this, CH_VOICE, "mczombie/step1.wav", 1, ATTN_NORM);
			else if(r < 0.4)
				_sound(this, CH_VOICE, "mczombie/step2.wav", 1, ATTN_NORM);
			else if(r < 0.6)
				_sound(this, CH_VOICE, "mczombie/step3.wav", 1, ATTN_NORM);
			else if(r < 0.8)
				_sound(this, CH_VOICE, "mczombie/step4.wav", 1, ATTN_NORM);
			else
				_sound(this, CH_VOICE, "mczombie/step5.wav", 1, ATTN_NORM);
		}
	}

	mczombie_idlesound(this);
}

void mczombie_walk(entity this)
{
	mczombie_moveframe(this);
	set_anim(this, this.walkframe, mczombie_walk);
	this.nextthink = time + 0.05; // slow animation needs fixing

	ai_walk(this, 2);
}

void mczombie_run(entity this)
{
	mczombie_moveframe(this);
	set_anim(this, this.walkframe, mczombie_run);
	this.nextthink = time + 0.05; // slow animation needs fixing

	ai_run(this, 4);
}

void mczombie_melee(entity this)
{
	set_anim(this, anim_mczombie_stand, mczombie_run);
	this.nextthink = time + 0.5;
	ai_face(this);
	ai_melee(this, DEATH_MONSTER_MCZOMBIE.m_id, 100, false);
	this.attack_finished = time + 0.5;
}

//===========================================================================

void mczombie_pain6(entity this) { set_anim(this, anim_mczombie_stand, mczombie_run); this.colormod = (this.charmed) ? '0 1 0' : '1 1 1'; }
void mczombie_pain5(entity this) { set_anim(this, anim_mczombie_stand, mczombie_pain6); }
void mczombie_pain4(entity this) { set_anim(this, anim_mczombie_stand, mczombie_pain5); this.colormod = '1 0.8 0.8'; }
void mczombie_pain3(entity this) { set_anim(this, anim_mczombie_stand, mczombie_pain4);}
void mczombie_pain2(entity this) { set_anim(this, anim_mczombie_stand, mczombie_pain3); ai_pain(this, 6); this.colormod = '1 0.6 0.6'; }
void mczombie_pain1(entity this) { set_anim(this, anim_mczombie_stand, mczombie_pain2); ai_pain(this, 6); }

void mczombie_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	if(this.skin == 1)
	{
		if(random() < 0.5)
			_sound(this, CH_VOICE, "husk/hurt1.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "husk/hurt2.wav", 1, ATTN_NORM);
	}
	else
	{
		if(random() < 0.5)
			_sound(this, CH_VOICE, "mczombie/hurt1.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "mczombie/hurt2.wav", 1, ATTN_NORM);
	}

	this.pain_finished = time + 1.1;
	this.colormod = '1 0.9 0.9';
	this.scale = 1;

	mczombie_pain1(this);
}

//===========================================================================

void mczombie_vanish(entity this)
{
	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

void mczombie_die13(entity this) { set_animofs(this, anim_mczombie_death, 13, mczombie_vanish); this.nextthink = time + 0.7; }
void mczombie_die12(entity this) { set_animofs(this, anim_mczombie_death, 12, mczombie_die13); this.nextthink = time + 0.05; }
void mczombie_die11(entity this) { set_animofs(this, anim_mczombie_death, 11, mczombie_die12); this.nextthink = time + 0.05; }
void mczombie_die10(entity this) { set_animofs(this, anim_mczombie_death, 10, mczombie_die11); this.nextthink = time + 0.05; }
void mczombie_die9(entity this) { set_animofs(this, anim_mczombie_death, 9, mczombie_die10); this.nextthink = time + 0.05; }
void mczombie_die8(entity this) { set_animofs(this, anim_mczombie_death, 8, mczombie_die9); this.nextthink = time + 0.05; }
void mczombie_die7(entity this) { set_animofs(this, anim_mczombie_death, 7, mczombie_die8); this.nextthink = time + 0.05; }
void mczombie_die6(entity this) { set_animofs(this, anim_mczombie_death, 6, mczombie_die7); this.nextthink = time + 0.05; }
void mczombie_die5(entity this) { set_animofs(this, anim_mczombie_death, 5, mczombie_die6); this.nextthink = time + 0.05; }
void mczombie_die4(entity this) { set_animofs(this, anim_mczombie_death, 4, mczombie_die5); this.nextthink = time + 0.05; }
void mczombie_die3(entity this) { set_animofs(this, anim_mczombie_death, 3, mczombie_die4); this.nextthink = time + 0.05; }
void mczombie_die2(entity this) { set_animofs(this, anim_mczombie_death, 2, mczombie_die3); this.nextthink = time + 0.05; }
void mczombie_die1(entity this) { set_animofs(this, anim_mczombie_death, 1, mczombie_die2); this.solid = SOLID_NOT; this.nextthink = time + 0.05; }

void mczombie_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(this.skin == 1)
	{
		if(random() < 0.5)
			_sound(this, CH_VOICE, "husk/death1.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "husk/death2.wav", 1, ATTN_NORM);
	}
	else
		_sound(this, CH_VOICE, "mczombie/death.wav", 1, ATTN_NORM);

	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			this.colormod = '1 1 1';
			ThrowGib(this, inflictor, "progs/h_mczombie.mdl", this.health);
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	this.colormod = '1 0.6 0.6';
	mczombie_die1(this);
}

/*QUAKED monster_mczombie (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_mczombie) { monster_start(this, true, MON_MCZOMBIE); }
#endif // SVQC

#ifdef SVQC
METHOD(MCZombie, mr_setup, bool(MCZombie this, entity actor))
{
    TC(MCZombie, this);

    precache_model("progs/h_mczombie.mdl");

	precache_sound("mczombie/death.wav");

	precache_sound("mczombie/hurt1.wav");
	precache_sound("mczombie/hurt2.wav");

	precache_sound("mczombie/say1.wav");
	precache_sound("mczombie/say2.wav");
	precache_sound("mczombie/say3.wav");

	precache_sound("mczombie/step1.wav");
	precache_sound("mczombie/step2.wav");
	precache_sound("mczombie/step3.wav");
	precache_sound("mczombie/step4.wav");
	precache_sound("mczombie/step5.wav");

	precache_sound("husk/hurt1.wav");
	precache_sound("husk/hurt2.wav");

	precache_sound("husk/idle1.wav");
	precache_sound("husk/idle2.wav");
	precache_sound("husk/idle3.wav");

	precache_sound("husk/step1.wav");
	precache_sound("husk/step2.wav");
	precache_sound("husk/step3.wav");
	precache_sound("husk/step4.wav");
	precache_sound("husk/step5.wav");

	actor.spawnflags |= SPAWNFLAG_NEARSIGHTED;

	if(random() < 0.5)
		actor.spawnflags |= MCZOMBIE_HUSK;

	actor.yaw_speed = 180;

    actor.health = 100;
    actor.gibhealth = -55;
    actor.th_stand = mczombie_stand1;
	actor.th_walk = mczombie_walk;
	actor.th_run = mczombie_run;
	actor.th_pain = mczombie_pain;
	actor.th_die = mczombie_die;
	actor.th_melee = mczombie_melee;

	if(actor.spawnflags & MCZOMBIE_HUSK)
	{
		precache_sound("husk/death1.wav");
		precache_sound("husk/death2.wav");
		actor.skin = 1;
	}

    return true;
}
#endif
