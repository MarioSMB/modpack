#include "squeak.qh"

#ifdef SVQC
const int anim_squeak_walk = 0; //'0 8 0'

void squeak_idle_sound(entity this)
{
	if(random() < 0.05)
	{
		float r = random();
		if(r < 0.33)
			_sound(this, CH_VOICE, "squeak/hunt1.wav", 1, ATTN_NORM);
		else if(r < 0.66)
			_sound(this, CH_VOICE, "squeak/hunt2.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "squeak/hunt3.wav", 1, ATTN_NORM);
	}
}

void squeak_moveframe(entity this)
{
	this.walkframe += 1;
	if(this.walkframe < anim_squeak_walk || this.walkframe > 8)
		this.walkframe = anim_squeak_walk;

	if(this.walkframe % 3)
		monster_footstep(this, false);

	squeak_idle_sound(this);
}

void squeak_idle1(entity this);
void squeak_idle13(entity this) { set_anim(this, anim_squeak_walk, squeak_idle1); ai_stand(this); }
void squeak_idle12(entity this) { set_anim(this, anim_squeak_walk, squeak_idle13); ai_stand(this); }
void squeak_idle11(entity this) { set_anim(this, anim_squeak_walk, squeak_idle12); ai_stand(this); }
void squeak_idle10(entity this) { set_anim(this, anim_squeak_walk, squeak_idle11); ai_stand(this); }
void squeak_idle9(entity this) { set_anim(this, anim_squeak_walk, squeak_idle10); ai_stand(this); }
void squeak_idle8(entity this) { set_anim(this, anim_squeak_walk, squeak_idle9); ai_stand(this); }
void squeak_idle7(entity this) { set_anim(this, anim_squeak_walk, squeak_idle8); ai_stand(this); }
void squeak_idle6(entity this) { set_anim(this, anim_squeak_walk, squeak_idle7); ai_stand(this); }
void squeak_idle5(entity this) { set_anim(this, anim_squeak_walk, squeak_idle6); ai_stand(this); }
void squeak_idle4(entity this) { set_anim(this, anim_squeak_walk, squeak_idle5); ai_stand(this); }
void squeak_idle3(entity this) { set_anim(this, anim_squeak_walk, squeak_idle4); ai_stand(this); }
void squeak_idle2(entity this) { set_anim(this, anim_squeak_walk, squeak_idle3); ai_stand(this); }
void squeak_idle1(entity this) { set_anim(this, anim_squeak_walk, squeak_idle2); squeak_idle_sound(this); ai_stand(this); }

void squeak_walk1(entity this)
{
	squeak_moveframe(this);
	set_anim(this, this.walkframe, squeak_walk1);

	ai_walk(this, 4);
}

void squeak_run1(entity this)
{
	squeak_moveframe(this);
	set_anim(this, this.walkframe, squeak_run1);

	ai_run(this, 14);
}

void squeak_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(time < this.pain_finished)
		return;
	// Any pain animation/sound required?
	_sound(this, CH_VOICE, "squeak/hunt1.wav", 1, ATTN_NORM);
	this.pain_finished = time + 1;
}

void squeak_die6(entity this) { set_anim(this, anim_squeak_walk, squeak_die6); te_wizspike(this.origin); this.health = 0; delete(this); }
void squeak_die5(entity this) { set_anim(this, anim_squeak_walk, squeak_die6); }
void squeak_die4(entity this) { set_anim(this, anim_squeak_walk, squeak_die5); }
void squeak_die3(entity this) { set_anim(this, anim_squeak_walk, squeak_die4); }
void squeak_die2(entity this) { set_anim(this, anim_squeak_walk, squeak_die3); }
void squeak_die1(entity this) { set_anim(this, anim_squeak_walk, squeak_die2); this.solid = SOLID_NOT; }

void squeak_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(inflictor == this)
		return; // bomber mode

	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			_sound(this, CH_VOICE, "squeak/die.wav", 1, ATTN_NORM);
			te_wizspike(this.origin);
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	_sound(this, CH_VOICE, "squeak/die.wav", 1, ATTN_NORM);
	squeak_die1(this);
}

void s_squeakexplode12(entity this) { set_anim(this, 11, SUB_Remove); }
void s_squeakexplode11(entity this) { set_anim(this, 10, s_squeakexplode12); }
void s_squeakexplode10(entity this) { set_anim(this, 9, s_squeakexplode11); }
void s_squeakexplode9(entity this) { set_anim(this, 8, s_squeakexplode10); }
void s_squeakexplode8(entity this) { set_anim(this, 7, s_squeakexplode9); }
void s_squeakexplode7(entity this) { set_anim(this, 6, s_squeakexplode8); }
void s_squeakexplode6(entity this) { set_anim(this, 5, s_squeakexplode7); }
void s_squeakexplode5(entity this) { set_anim(this, 4, s_squeakexplode6); }
void s_squeakexplode4(entity this) { set_anim(this, 3, s_squeakexplode5); }
void s_squeakexplode3(entity this) { set_anim(this, 2, s_squeakexplode4); }
void s_squeakexplode2(entity this) { set_anim(this, 1, s_squeakexplode3); }
void s_squeakexplode1(entity this) { set_anim(this, 0, s_squeakexplode2); }

void squeak_explode(entity this)
{
	entity attacker = (this.owner) ? this.owner : this;
	T_RadiusDamage(this, attacker, 130, DEATH_MONSTER_SQUEAK.m_id, this);
	_sound(this, CH_VOICE, "squeak/blast.wav", 1, ATTN_NORM);

	entity newmis = spawn();
	set_movetype(newmis, MOVETYPE_NONE);
	newmis.solid = SOLID_NOT;
	_setmodel(newmis, "progs/s_squeak_explode.spr");
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, findbetterlocation(this.origin, 8));
	s_squeakexplode1(newmis);

	Killed(this, this, this, DEATH_MONSTER_SQUEAK.m_id);

	setthink(this, SUB_Remove);
	this.nextthink = time;
}

/*======================================================================
QUAKED monster_squeak (1 0 0) (-16 -16 -24) (16 16 24) Ambush
======================================================================*/
spawnfunc(monster_squeak) { monster_start(this, true, MON_SQUEAK); }
#endif // SVQC

#ifdef SVQC
METHOD(Squeak, mr_setup, bool(Squeak this, entity actor))
{
	TC(Squeak, this);

	precache_model("progs/s_squeak_explode.spr");
	precache_sound("squeak/blast.wav");
	precache_sound("squeak/die.wav");
	precache_sound("squeak/hunt1.wav");
	precache_sound("squeak/hunt2.wav");
	precache_sound("squeak/hunt3.wav");
	precache_sound("squeak/deploy.wav");

	actor.health = 50;
	actor.th_pain = squeak_pain;
	actor.th_die = squeak_die;

	actor.steptype = FS_TYPELIGHT;
	actor.th_stand = squeak_idle1;
	actor.th_walk = squeak_walk1;
	actor.th_run = squeak_run1;
	actor.th_melee = squeak_explode;

	return true;
}
METHOD(Squeak, mr_sight, bool(Squeak this, entity actor))
{
	TC(Squeak, this);

	_sound(actor, CH_VOICE, "squeak/deploy.wav", 1, ATTN_NORM);

	return true;
}
#endif
