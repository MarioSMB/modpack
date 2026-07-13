#include "kiwi.qh"

#ifdef SVQC

void kiwi_stand1(entity this);
void kiwi_run1(entity this);
void kiwi_walk1(entity this);

void kiwi_stand1(entity this) { set_anim(this, 0, kiwi_stand1); ai_stand(this); }

void kiwi_walk2(entity this) { set_anim(this, 1, kiwi_walk1); ai_walk(this, 3); }
void kiwi_walk1(entity this) { set_anim(this, 0, kiwi_walk2); ai_walk(this, 3); }

void kiwi_run2(entity this) { set_anim(this, 1, kiwi_run1); ai_run(this, 6); }
void kiwi_run1(entity this)
{
	set_anim(this, 0, kiwi_run2);
	ai_run(this, 6);

	if(time >= this.idle_finished)
	{
		this.idle_finished = time + 3 + (random() * 3);
		if(this.spawnsilent)
		{
			float r = random() * (random() * 3);
			sound7(this, CH_VOICE, "kiwi/kiwi.wav", 1, ATTN_NORM, 100 / r, 0);
		}
		else
			_sound(this, CH_VOICE, "kiwi/kiwi.wav", 1, ATTN_NORM);
	}
}

void kiwi_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(time < this.pain_finished)
		return;
	SpawnBlood(this.origin, '0 0 -5', 100, this);
	this.pain_finished = time + 0.2;
	//_sound(this, CH_VOICE, "kiwi/kiwi.wav", 1, ATTN_NORM);
	float sndpitch = 100 / bound(0.75, random() * 2, 1.25);
	sound7(this, CH_VOICE, "kiwi/kiwi.wav", 1, ATTN_NORM, sndpitch, 0);
}

void kiwi_gib(entity this, entity inflictor)
{
	_sound(this, CH_VOICE, "weapons/grape_impact.wav", 1, ATTN_NORM);
	te_wizspike(CENTER_OR_VIEWOFS(this));
}

void kiwi_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		case KILLED_SIMPLEGIB:
		{
			kiwi_gib(this, inflictor);
			delete(this);
			return;
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	kiwi_gib(this, inflictor);
	delete(this);
}

spawnfunc(monster_kiwi) { monster_start(this, true, MON_KIWI); }
#endif // SVQC

#ifdef SVQC
METHOD(Kiwi, mr_setup, bool(Kiwi this, entity actor))
{
	TC(Kiwi, this);

	precache_sound("kiwi/kiwi.wav");
	precache_sound("weapons/grape_impact.wav");

	actor.health = 120;
	actor.th_stand = kiwi_stand1;
	actor.th_walk = kiwi_walk1;
	actor.th_run = kiwi_run1;
	actor.th_die = kiwi_die;
	actor.th_pain = kiwi_pain;

	return true;
}
METHOD(Kiwi, mr_sight, bool(Kiwi this, entity actor))
{
	TC(Kiwi, this);

	_sound(actor, CH_VOICE, "kiwi/kiwi.wav", 1, ATTN_NORM);
	actor.idle_finished = time + 3 + (random() * 3);

	return true;
}
#endif
