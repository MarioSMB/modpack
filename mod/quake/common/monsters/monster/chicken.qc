#include "chicken.qh"

#ifdef SVQC

const float CHICKEN_PITCH = 150; // TODO: just make sounds?

void chicken_bock(entity this)
{
	float n = ceil(random() * 6);
	switch(n)
	{
		case 1: sound7(this, CH_VOICE, "chicken/fire.wav", 1, ATTN_NORM, CHICKEN_PITCH, 0); break;
		case 2: sound7(this, CH_VOICE, "chicken/random1.wav", 1, ATTN_NORM, CHICKEN_PITCH, 0); break;
		case 3: sound7(this, CH_VOICE, "chicken/random2.wav", 1, ATTN_NORM, CHICKEN_PITCH, 0); break;
		case 4: sound7(this, CH_VOICE, "chicken/random3.wav", 1, ATTN_NORM, CHICKEN_PITCH, 0); break;
		case 5: sound7(this, CH_VOICE, "chicken/sight.wav", 1, ATTN_NORM, CHICKEN_PITCH, 0); break;
		default:
		case 6: sound7(this, CH_VOICE, "chicken/pickup.wav", 1, ATTN_NORM, CHICKEN_PITCH, 0); break;
	}
}

void chicken_stand(entity this) { set_anim(this, 0, chicken_stand); ai_stand(this); }

void chicken_walk7(entity this) { set_anim(this, 17, chicken_walk1); ai_walk(this, 8); }
void chicken_walk6(entity this) { set_anim(this, 16, chicken_walk7); ai_walk(this, 8); }
void chicken_walk5(entity this) { set_anim(this, 15, chicken_walk6); ai_walk(this, 8); }
void chicken_walk4(entity this) { set_anim(this, 14, chicken_walk5); ai_walk(this, 8); }
void chicken_walk3(entity this) { set_anim(this, 13, chicken_walk4); ai_walk(this, 8); }
void chicken_walk2(entity this) { set_anim(this, 12, chicken_walk3); ai_walk(this, 8); }
void chicken_walk1(entity this) { set_anim(this, 11, chicken_walk2); ai_walk(this, 8); if(random() < 0.2) chicken_bock(this); }

void chicken_peck10(entity this) { set_anim(this, 10, chicken_run1); }
void chicken_peck9(entity this) { set_anim(this, 9, chicken_peck10); }
void chicken_peck8(entity this) { set_anim(this, 8, chicken_peck9); ai_melee(this, DEATH_MONSTER_CHICKEN.m_id, 60, false); ai_face(this); }
void chicken_peck7(entity this) { set_anim(this, 7, chicken_peck8); ai_melee(this, DEATH_MONSTER_CHICKEN.m_id, 60, false); ai_face(this); }
void chicken_peck6(entity this) { set_anim(this, 6, chicken_peck7); ai_melee(this, DEATH_MONSTER_CHICKEN.m_id, 60, false); ai_face(this); _sound(this, CH_VOICE, "chicken/peck.wav", 1, ATTEN_NORM); }
void chicken_peck5(entity this) { set_anim(this, 5, chicken_peck6); ai_melee(this, DEATH_MONSTER_CHICKEN.m_id, 60, false); ai_face(this); }
void chicken_peck4(entity this) { set_anim(this, 4, chicken_peck5); ai_melee(this, DEATH_MONSTER_CHICKEN.m_id, 60, false); ai_face(this); }
void chicken_peck3(entity this) { set_anim(this, 3, chicken_peck4); ai_melee(this, DEATH_MONSTER_CHICKEN.m_id, 60, false); _sound(this, CH_VOICE, "chicken/peck.wav", 1, ATTEN_NORM); }
void chicken_peck2(entity this) { set_anim(this, 2, chicken_peck3); ai_face(this); }
void chicken_peck1(entity this) { set_anim(this, 1, chicken_peck2); ai_face(this); }

void chicken_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	sound7(this, CH_VOICE, "chicken/chickdie.wav", 1, ATTN_NORM, CHICKEN_PITCH, 0);
	float dm = -15;
	ThrowHead(this, inflictor, "progs/gib1.mdl", dm);
	ThrowGib(this, inflictor, "progs/gib1.mdl", dm);
	ThrowGib(this, inflictor, "progs/gib2.mdl", dm);
	ThrowGib(this, inflictor, "progs/gib3.mdl", dm);

	// feathery mess
	Send_Effect(EFFECT_CHICKEN_DIE, this.origin + '0 0 16', '0 0 0', 1);
}

void chicken_run7(entity this) { set_anim(this, 17, chicken_run1); ai_run(this, 15); }
void chicken_run6(entity this) { set_anim(this, 16, chicken_run7); ai_run(this, 15); }
void chicken_run5(entity this) { set_anim(this, 15, chicken_run6); ai_run(this, 15); }
void chicken_run4(entity this) { set_anim(this, 14, chicken_run5); ai_run(this, 15); }
void chicken_run3(entity this) { set_anim(this, 13, chicken_run4); ai_run(this, 15); }
void chicken_run2(entity this) { set_anim(this, 12, chicken_run3); ai_run(this, 15); }
void chicken_run1(entity this) { set_anim(this, 11, chicken_run2); ai_run(this, 15); if(random() < 0.2) chicken_bock(this); }

spawnfunc(monster_chicken) { monster_start(this, true, MON_CHICKEN); }
#endif // SVQC

#ifdef SVQC
METHOD(Chicken, mr_setup, bool(Chicken this, entity actor))
{
    TC(Chicken, this);

    precache_sound("chicken/chickdie.wav");
    precache_sound("chicken/peck.wav");

    actor.health = 60;
    actor.th_stand = chicken_stand;
	actor.th_walk = chicken_walk1;
	actor.th_run = chicken_run1;
	actor.th_die = chicken_die;
	actor.th_melee = chicken_peck1;

    return true;
}
METHOD(Chicken, mr_sight, bool(Chicken this, entity actor))
{
    TC(Chicken, this);

	sound7(this, CH_VOICE, "chicken/sight.wav", 1, ATTN_NORM, CHICKEN_PITCH, 0);

    return true;
}
#endif
