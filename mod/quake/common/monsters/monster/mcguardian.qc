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
	{
		float r = random();
		if(r < 0.25)
			_sound(this, CH_VOICE, "mcguardian/guardian_idle1.wav", 1, ATTN_IDLE);
		else if(r < 0.50)
			_sound(this, CH_VOICE, "mcguardian/guardian_idle2.wav", 1, ATTN_IDLE);
		else if(r < 0.75)
			_sound(this, CH_VOICE, "mcguardian/guardian_idle3.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "mcguardian/guardian_idle4.wav", 1, ATTN_IDLE);
	}
}

void mcguardian_stand(entity this)
{
	this.nextthink = time + 0.1;
	setthink(this, mcguardian_stand);

	if(this.walkframe == 0)
		mcguardian_idlesound(this);

	if(this.walkframe >= 10)
		this.frame = anim_mcguardian_swim + this.walkframe;
	else
		this.frame = (anim_mcguardian_swim + 10) - (this.walkframe - 10); // nasty hack to invert anim
	this.walkframe += 1;
	if(this.walkframe >= 18)
		this.walkframe = 0;

	ai_stand(this);
}

void mcguardian_walk(entity this)
{
	this.nextthink = time + 0.1;
	setthink(this, mcguardian_walk);

	if(this.walkframe == 0)
		mcguardian_idlesound(this);

	if(this.walkframe >= 10)
		this.frame = anim_mcguardian_swim + this.walkframe;
	else
		this.frame = (anim_mcguardian_swim + 10) - this.walkframe; // nasty hack to invert anim
	this.walkframe += 1;
	if(this.walkframe >= 18)
		this.walkframe = 0;

	ai_walk(this, 8);
}

void mcguardian_run(entity this)
{
	this.nextthink = time + 0.1;
	setthink(this, mcguardian_run);

	if(this.walkframe == 0)
		mcguardian_idlesound(this);

	// haaaack
	switch(this.walkframe + 1)
	{
		case 1: this.frame = (anim_mcguardian_swim - 1) + 1; break;
		case 2: this.frame = (anim_mcguardian_swim - 1) + 3; break;
		case 3: this.frame = (anim_mcguardian_swim - 1) + 5; break;
		case 4: this.frame = (anim_mcguardian_swim - 1) + 7; break;
		case 5: this.frame = (anim_mcguardian_swim - 1) + 9; break;
		case 6: this.frame = (anim_mcguardian_swim - 1) + 7; break;
		case 7: this.frame = (anim_mcguardian_swim - 1) + 5; break;
		case 8: this.frame = (anim_mcguardian_swim - 1) + 3; break;
		case 9: this.frame = (anim_mcguardian_swim - 1) + 2; break;
	}

	this.walkframe += 1;
	if(this.walkframe >= 9)
		this.walkframe = 0;

	ai_run(this, 12);
}

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
			mcguardian_run(this);
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
			mcguardian_run(this);
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

void mcguardian_pain6(entity this) { set_anim(this, anim_mcguardian_pain, mcguardian_run); this.colormod = (this.charmed) ? '0 1 0' : '1 1 1'; }
void mcguardian_pain5(entity this) { set_anim(this, anim_mcguardian_pain, mcguardian_pain6); }
void mcguardian_pain4(entity this) { set_anim(this, anim_mcguardian_pain, mcguardian_pain5); this.colormod = '1 0.8 0.8'; }
void mcguardian_pain3(entity this) { set_anim(this, anim_mcguardian_pain, mcguardian_pain4);}
void mcguardian_pain2(entity this) { set_anim(this, anim_mcguardian_pain, mcguardian_pain3); ai_pain(this, 6); this.colormod = '1 0.6 0.6'; }
void mcguardian_pain1(entity this) { set_anim(this, anim_mcguardian_pain, mcguardian_pain2); ai_pain(this, 6); }

void mcguardian_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CH_VOICE, "mcguardian/guardian_death.wav", 1, ATTN_NORM);

	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			this.colormod = '1 1 1';
			Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	// regular death
	mcguardian_death1(this, inflictor, attacker);
}

void mcguardian_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.mcguardian_charging > 0)
		return;
	if(time < this.pain_finished)
		return;
	this.pain_finished = time; // prevent spam

	float r = random();
	if(r < 0.25)
		_sound(this, CH_VOICE, "mcguardian/guardian_hit1.wav", 1, ATTN_NORM);
	else if(r < 0.50)
		_sound(this, CH_VOICE, "mcguardian/guardian_hit2.wav", 1, ATTN_NORM);
	else if(r < 0.75)
		_sound(this, CH_VOICE, "mcguardian/guardian_hit3.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "mcguardian/guardian_hit4.wav", 1, ATTN_NORM);

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

	precache_sound("mcguardian/guardian_hit1.wav");
	precache_sound("mcguardian/guardian_hit2.wav");
	precache_sound("mcguardian/guardian_hit3.wav");
	precache_sound("mcguardian/guardian_hit4.wav");

	precache_sound("mcguardian/guardian_idle1.wav");
	precache_sound("mcguardian/guardian_idle2.wav");
	precache_sound("mcguardian/guardian_idle3.wav");
	precache_sound("mcguardian/guardian_idle4.wav");

    actor.health = 75;
    actor.th_stand = mcguardian_stand;
	actor.th_walk = mcguardian_walk;
	actor.th_run = mcguardian_run;
	actor.th_die = mcguardian_die;
	actor.th_pain = mcguardian_pain;
	actor.th_missile = mcguardian_attack;

    return true;
}
#endif
