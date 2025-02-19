#include "mcguardian.qh"

#ifdef SVQC
const int anim_mcguardian_attack = 0;
const int anim_mcguardian_death = 0;
const int anim_mcguardian_pain = 0;
const int anim_mcguardian_swim = 1;

.float mcguardian_chargetime;
.int mcguardian_charging;

void mcguardian_idlesound(entity this)
{
	if(random() < 0.5)
		sound(this, CH_VOICE, SND_MON_MCGUARDIAN_IDLE_RANDOM(), 1, ATTN_NORM);
}

void mcguardian_stand1(entity this);
void mcguardian_stand18(entity this) { set_animofs(this, anim_mcguardian_swim, 2, mcguardian_stand1); ai_stand(this); }
void mcguardian_stand17(entity this) { set_animofs(this, anim_mcguardian_swim, 3, mcguardian_stand18); ai_stand(this); }
void mcguardian_stand16(entity this) { set_animofs(this, anim_mcguardian_swim, 4, mcguardian_stand17); ai_stand(this); }
void mcguardian_stand15(entity this) { set_animofs(this, anim_mcguardian_swim, 5, mcguardian_stand16); ai_stand(this); }
void mcguardian_stand14(entity this) { set_animofs(this, anim_mcguardian_swim, 6, mcguardian_stand15); ai_stand(this); }
void mcguardian_stand13(entity this) { set_animofs(this, anim_mcguardian_swim, 7, mcguardian_stand14); ai_stand(this); }
void mcguardian_stand12(entity this) { set_animofs(this, anim_mcguardian_swim, 8, mcguardian_stand13); ai_stand(this); }
void mcguardian_stand11(entity this) { set_animofs(this, anim_mcguardian_swim, 9, mcguardian_stand12); ai_stand(this); }
void mcguardian_stand10(entity this) { set_animofs(this, anim_mcguardian_swim, 10, mcguardian_stand11); ai_stand(this); }
void mcguardian_stand9(entity this) { set_animofs(this, anim_mcguardian_swim, 9, mcguardian_stand10); ai_stand(this); }
void mcguardian_stand8(entity this) { set_animofs(this, anim_mcguardian_swim, 8, mcguardian_stand9); ai_stand(this); }
void mcguardian_stand7(entity this) { set_animofs(this, anim_mcguardian_swim, 7, mcguardian_stand8); ai_stand(this); }
void mcguardian_stand6(entity this) { set_animofs(this, anim_mcguardian_swim, 6, mcguardian_stand7); ai_stand(this); }
void mcguardian_stand5(entity this) { set_animofs(this, anim_mcguardian_swim, 5, mcguardian_stand6); ai_stand(this); }
void mcguardian_stand4(entity this) { set_animofs(this, anim_mcguardian_swim, 4, mcguardian_stand5); ai_stand(this); }
void mcguardian_stand3(entity this) { set_animofs(this, anim_mcguardian_swim, 3, mcguardian_stand4); ai_stand(this); }
void mcguardian_stand2(entity this) { set_animofs(this, anim_mcguardian_swim, 2, mcguardian_stand3); ai_stand(this); }
void mcguardian_stand1(entity this) { set_animofs(this, anim_mcguardian_swim, 1, mcguardian_stand2); ai_stand(this); mcguardian_idlesound(this); }

void mcguardian_walk1(entity this);
void mcguardian_walk18(entity this) { set_animofs(this, anim_mcguardian_swim, 2, mcguardian_walk1); ai_walk(this, 8); }
void mcguardian_walk17(entity this) { set_animofs(this, anim_mcguardian_swim, 3, mcguardian_walk18); ai_walk(this, 8); }
void mcguardian_walk16(entity this) { set_animofs(this, anim_mcguardian_swim, 4, mcguardian_walk17); ai_walk(this, 8); }
void mcguardian_walk15(entity this) { set_animofs(this, anim_mcguardian_swim, 5, mcguardian_walk16); ai_walk(this, 8); }
void mcguardian_walk14(entity this) { set_animofs(this, anim_mcguardian_swim, 6, mcguardian_walk15); ai_walk(this, 8); }
void mcguardian_walk13(entity this) { set_animofs(this, anim_mcguardian_swim, 7, mcguardian_walk14); ai_walk(this, 8); }
void mcguardian_walk12(entity this) { set_animofs(this, anim_mcguardian_swim, 8, mcguardian_walk13); ai_walk(this, 8); }
void mcguardian_walk11(entity this) { set_animofs(this, anim_mcguardian_swim, 9, mcguardian_walk12); ai_walk(this, 8); }
void mcguardian_walk10(entity this) { set_animofs(this, anim_mcguardian_swim, 10, mcguardian_walk11); ai_walk(this, 8); }
void mcguardian_walk9(entity this) { set_animofs(this, anim_mcguardian_swim, 9, mcguardian_walk10); ai_walk(this, 8); }
void mcguardian_walk8(entity this) { set_animofs(this, anim_mcguardian_swim, 8, mcguardian_walk9); ai_walk(this, 8); }
void mcguardian_walk7(entity this) { set_animofs(this, anim_mcguardian_swim, 7, mcguardian_walk8); ai_walk(this, 8); }
void mcguardian_walk6(entity this) { set_animofs(this, anim_mcguardian_swim, 6, mcguardian_walk7); ai_walk(this, 8); }
void mcguardian_walk5(entity this) { set_animofs(this, anim_mcguardian_swim, 5, mcguardian_walk6); ai_walk(this, 8); }
void mcguardian_walk4(entity this) { set_animofs(this, anim_mcguardian_swim, 4, mcguardian_walk5); ai_walk(this, 8); }
void mcguardian_walk3(entity this) { set_animofs(this, anim_mcguardian_swim, 3, mcguardian_walk4); ai_walk(this, 8); }
void mcguardian_walk2(entity this) { set_animofs(this, anim_mcguardian_swim, 2, mcguardian_walk3); ai_walk(this, 8); }
void mcguardian_walk1(entity this) { set_animofs(this, anim_mcguardian_swim, 1, mcguardian_walk2); ai_walk(this, 8); mcguardian_idlesound(this); }

void mcguardian_run1(entity this);
void mcguardian_run9(entity this) { set_animofs(this, anim_mcguardian_swim, 2, mcguardian_run1); ai_run(this, 12); }
void mcguardian_run8(entity this) { set_animofs(this, anim_mcguardian_swim, 3, mcguardian_run9); ai_run(this, 12); }
void mcguardian_run7(entity this) { set_animofs(this, anim_mcguardian_swim, 5, mcguardian_run8); ai_run(this, 12); }
void mcguardian_run6(entity this) { set_animofs(this, anim_mcguardian_swim, 7, mcguardian_run7); ai_run(this, 12); }
void mcguardian_run5(entity this) { set_animofs(this, anim_mcguardian_swim, 9, mcguardian_run6); ai_run(this, 12); }
void mcguardian_run4(entity this) { set_animofs(this, anim_mcguardian_swim, 7, mcguardian_run5); ai_run(this, 12); }
void mcguardian_run3(entity this) { set_animofs(this, anim_mcguardian_swim, 5, mcguardian_run4); ai_run(this, 12); }
void mcguardian_run2(entity this) { set_animofs(this, anim_mcguardian_swim, 3, mcguardian_run3); ai_run(this, 12); }
void mcguardian_run1(entity this) { set_animofs(this, anim_mcguardian_swim, 1, mcguardian_run2); ai_run(this, 12); mcguardian_idlesound(this); }

void mcguardian_vanish(entity this)
{
	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

void mcguardian_attack(entity this)
{
	set_anim(this, anim_mcguardian_attack, mcguardian_attack);
	ai_face(this);

	if(time >= this.mcguardian_chargetime)
	{
		this.mcguardian_chargetime = time + 1;
		if(!this.enemy || this.enemy.health <= 0 || vdist(this.origin - this.enemy.origin, >=, 800) || !visible(this, this.enemy))
		{
			this.attack_finished = time + 2 + (random() * 2);
			this.mcguardian_charging = 0;
			mcguardian_run1(this);
			return;
		}
		this.mcguardian_charging += 1;
		_sound(this, CH_WEAPON_B, "mcguardian/attack_loop.wav", 1, ATTN_NORM);
		_sound(this.enemy, CH_WEAPON_B, "mcguardian/attack_loop.wav", 1, ATTN_NORM);

		if(this.mcguardian_charging > 3)
		{
			float ldmg = (random() + random()) * 20;
			T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_MCGUARDIAN.m_id);
			this.mcguardian_charging = 0;
			this.attack_finished = time + 3 + (random() * 2);
			mcguardian_run1(this);
			return;
		}
	}

	if(this.enemy)
		Send_Effect(EFFECT_GUARDIAN_BEAM, this.origin, this.enemy.origin, 1);
}

void mcguardian_death7(entity this) { set_anim(this, anim_mcguardian_death, mcguardian_vanish); this.angles_z = 90; this.nextthink = time + 0.7; }
void mcguardian_death6(entity this) { set_anim(this, anim_mcguardian_death, mcguardian_death7); this.angles_z = 75; }
void mcguardian_death5(entity this) { set_anim(this, anim_mcguardian_death, mcguardian_death6); this.angles_z = 60; }
void mcguardian_death4(entity this) { set_anim(this, anim_mcguardian_death, mcguardian_death5); this.angles_z = 45; }
void mcguardian_death3(entity this) { set_anim(this, anim_mcguardian_death, mcguardian_death4); this.angles_z = 30; }
void mcguardian_death2(entity this) { set_anim(this, anim_mcguardian_death, mcguardian_death3); this.angles_z = 15; }
void mcguardian_death1(entity this, entity inflictor, entity attacker)
{
	set_anim(this, anim_mcguardian_death, mcguardian_death2);
	this.solid = SOLID_NOT;
	this.colormod = '1 0.9 0.9';
	this.angles_z = 0;
}

void mcguardian_pain6(entity this) { set_anim(this, anim_mcguardian_pain, mcguardian_run1); this.colormod = (this.charmed) ? '0 1 0' : '1 1 1'; }
void mcguardian_pain5(entity this) { set_anim(this, anim_mcguardian_pain, mcguardian_pain6); }
void mcguardian_pain4(entity this) { set_anim(this, anim_mcguardian_pain, mcguardian_pain5); this.colormod = '1 0.8 0.8'; }
void mcguardian_pain3(entity this) { set_anim(this, anim_mcguardian_pain, mcguardian_pain4);}
void mcguardian_pain2(entity this) { set_anim(this, anim_mcguardian_pain, mcguardian_pain3); ai_pain(this, 6); this.colormod = '1 0.6 0.6'; }
void mcguardian_pain1(entity this) { set_anim(this, anim_mcguardian_pain, mcguardian_pain2); ai_pain(this, 6); }

void mcguardian_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CH_VOICE, "mcguardian/guardian_death.wav", 1, ATTN_NORM);

	// regular death
	mcguardian_death1(this, inflictor, attacker);
}

void mcguardian_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.mcguardian_charging > 0)
		return;

	sound(this, CH_VOICE, SND_MON_MCGUARDIAN_PAIN_RANDOM(), 1, ATTN_NORM);
	this.colormod = '1 1 1';
	mcguardian_pain1(this);
}

/*QUAKED monster_mcguardian(1 0 0)(-16 -16 -24)(16 16 24) Ambush
*/
spawnfunc(monster_mcguardian) { monster_start(this, true, MON_MCGUARDIAN); }
#endif // SVQC

#ifdef SVQC
METHOD(MCGuardian, mr_setup, bool(MCGuardian this, entity actor))
{
    TC(MCGuardian, this);

	precache_sound("mcguardian/attack_loop.wav");
	precache_sound("mcguardian/guardian_death.wav");

    actor.health = 75;
    actor.th_stand = mcguardian_stand1;
	actor.th_walk = mcguardian_walk1;
	actor.th_run = mcguardian_run1;
	actor.th_die = mcguardian_die;
	actor.th_pain = mcguardian_pain;
	actor.th_missile = mcguardian_attack;

    return true;
}
#endif
