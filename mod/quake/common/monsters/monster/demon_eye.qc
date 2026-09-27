#include "demon_eye.qh"

#ifdef SVQC
.float anim_finished;

void demon_eye_anim(entity this)
{
	if(time < this.anim_finished)
		return;

	this.anim_finished = time + FRAME_TIME;

	this.walkframe += 1;
	if(this.walkframe > 10)
		this.walkframe = 0;
	this.frame = this.walkframe;
}

void demon_eye_move(entity this, entity targ, float velmax, float turnrate)
{
	float vel = vlen(this.velocity);
	if(vel == 0)
		vel = 1; // hack to make sure avelocity never divs by 0

	// gently home in
	if(targ)
	{
		vector newdir = ai_steerto(this, CENTER_OR_VIEWOFS(targ), turnrate);
		this.velocity = newdir * vel;
	}

	ai_accelerate(this, PHYS_INPUT_TIMELENGTH, normalize(this.velocity), vel, velmax, 0.25);
}

void demon_eye_brake(entity this, float brakespeed)
{
	vector dir = normalize(this.velocity);

	brakespeed = max(0, vlen(this.velocity) - brakespeed);

	this.velocity = dir * brakespeed;
}

void demon_eye_checkenemy(entity this)
{
	bool nyx_invis = (this.enemy.m_champion == CHAMPION_Nyx && STAT(NYX_INVIS, this.enemy));
	if(wasfreed(this.enemy) || this.enemy.health <= 0 || (this.charmed && (this.charmer == this.enemy)) || (this.enemy.flags & FL_NOTARGET) || nyx_invis)
	{
		this.enemy = NULL;
		if(this.charmed)
			return;
	// FIXME: look all around for other targets
		nyx_invis = (this.oldenemy.m_champion == CHAMPION_Nyx && STAT(NYX_INVIS, this.oldenemy));
		if(this.oldenemy.health > 0 && !(this.oldenemy.flags & FL_NOTARGET) && !StatusEffects_active(STATUSEFFECT_Invisibility, this.oldenemy) && !nyx_invis)
			this.enemy = this.oldenemy;
	}
}

float autocvar_sv_quake_demon_eye_turnrate = 0.04;
float autocvar_sv_quake_demon_eye_speed_chase = 300;
float autocvar_sv_quake_demon_eye_speed_idle = 200;
float autocvar_sv_quake_demon_eye_speed_brake = 1.5;
void demon_eye_think(entity this)
{
	this.nextthink = time;
	setthink(this, demon_eye_think);

	demon_eye_anim(this);

	if(this.enemy)
		demon_eye_checkenemy(this);
	else
		FindTarget(this);

	if(this.enemy)
		this.goalentity = this.enemy;
	else if(this.charmed)
		this.goalentity = this.charmer;
	else if(this.movetarget)
		this.goalentity = this.movetarget;
	else if(this.goalentity.classname != "path_corner")
		this.goalentity = (this.owner) ? this.owner : NULL;

	float myspeed = (this.enemy) ? autocvar_sv_quake_demon_eye_speed_chase : autocvar_sv_quake_demon_eye_speed_idle;

	if(this.goalentity)
		demon_eye_move(this, this.goalentity, myspeed, autocvar_sv_quake_demon_eye_turnrate);
	else
		demon_eye_brake(this, autocvar_sv_quake_demon_eye_speed_brake);

	if(vdist(this.velocity, >, 0))
		this.angles = vectoangles(this.velocity);
}

void demon_eye_touch(entity this, entity toucher)
{
	if(toucher.flags & FL_PROJECTILE)
		return;
	if(time < toucher.hurt_antispam)
		return;

	if(!toucher.takedamage || !Damage_ValidTarget(toucher, this))
		return;
	
	if(toucher == this.owner || toucher.owner == this)
		return;

	toucher.hurt_antispam = time + 0.2; // no spam please

	float damage = 8 + (random() * 4) + (random() * 2);
	
	T_Damage(toucher, this, this, damage, DEATH_MONSTER_DEMON_EYE.m_id);
}

void demon_eye_gib(entity this, entity inflictor)
{
	_sound(this, CH_VOICE, "demon_eye/death.wav", 1, ATTN_NORM);

	ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
	ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
	ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
	ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
}

void demon_eye_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			demon_eye_gib(this, inflictor);
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	demon_eye_gib(this, inflictor);
	delete(this);
}

void demon_eye_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	_sound(this, CHAN_BODY, "demon_eye/pain.wav", 1, ATTN_NORM);
	this.pain_finished = time + 0.2;
	// TODO: turn around maybe?
}

spawnfunc(monster_demon_eye) { monster_start(this, true, MON_DEMON_EYE); }
#endif // SVQC

#ifdef SVQC
METHOD(DemonEye, mr_setup, bool(DemonEye this, entity actor))
{
    TC(DemonEye, this);

	precache_sound("demon_eye/pain.wav");
	precache_sound("demon_eye/death.wav");

	actor.skin = bound(0, floor(random() * 5), 4);

    actor.health = 75;
	actor.th_stand = demon_eye_think;
	actor.th_walk = demon_eye_think;
	actor.th_run = demon_eye_think;
	actor.th_pain = demon_eye_pain;
	actor.th_die = demon_eye_die;
	//actor.checkattack = DemonEyeCheckAttack;

	settouch(actor, demon_eye_touch);
	set_movetype(actor, MOVETYPE_BOUNCEMISSILE); // bounces off walls!
	actor.solid = SOLID_CORPSE; // passes through enemies!

    return true;
}
#endif
