#include "piglin.qh"

#ifdef SVQC
const int anim_piglin_shoot = 89;
const int anim_piglin_stand = 0;
const int anim_piglin_death = 0;
const int anim_piglin_run = 18;
const int anim_piglin_walk = 18;
const int anim_piglin_attack = 71;

.float idle_finished;

void piglin_idlesound(entity this)
{
	if(time < this.pain_finished)
		return;

	if(random() < 0.2 && time >= this.idle_finished)
	{
		this.idle_finished = time + 2;
		float r = random();
		if(r < 0.25)
			_sound(this, CH_VOICE, "piglin/idle1.wav", 1, ATTN_NORM);
		else if(r < 0.5)
			_sound(this, CH_VOICE, "piglin/idle2.wav", 1, ATTN_NORM);
		else if(r < 0.75)
			_sound(this, CH_VOICE, "piglin/idle3.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "piglin/idle4.wav", 1, ATTN_NORM);
	}
}

void piglin_stand(entity this)
{
	this.walkframe += 1;
	if(this.walkframe < anim_piglin_stand || this.walkframe > 17)
		this.walkframe = anim_piglin_stand;

	piglin_idlesound(this);
	set_anim(this, this.walkframe, piglin_stand);

	ai_stand(this);
}

void piglin_moveframe(entity this, int startframe, int endframe)
{
	this.walkframe += 1;
	if(this.walkframe < startframe || this.walkframe > endframe)
		this.walkframe = startframe;

	if(time >= this.footstep && IS_ONGROUND(this))
	{
		this.footstep = time + 0.6 + random();
		float r = random();
		if(r < 0.2)
			_sound(this, CH_VOICE, "piglin/step1.wav", 1, ATTN_NORM);
		else if(r < 0.4)
			_sound(this, CH_VOICE, "piglin/step2.wav", 1, ATTN_NORM);
		else if(r < 0.6)
			_sound(this, CH_VOICE, "piglin/step3.wav", 1, ATTN_NORM);
		else if(r < 0.8)
			_sound(this, CH_VOICE, "piglin/step4.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "piglin/step5.wav", 1, ATTN_NORM);
	}

	piglin_idlesound(this);
}

void piglin_walk(entity this)
{
	piglin_moveframe(this, anim_piglin_walk, 56);
	set_anim(this, this.walkframe, piglin_walk);
	this.nextthink = time + 0.05;

	ai_walk(this, 3);
}

.float piglin_movetime;
void piglin_run(entity this)
{
	piglin_moveframe(this, anim_piglin_run, 56);
	set_anim(this, this.walkframe, piglin_run);
	this.nextthink = time + 0.05;

	if(time >= this.attack_finished && time >= this.piglin_movetime)
	{
		this.piglin_movetime = time + 1 + random();
		if(random() < 0.25)
			this.attack_state = AS_DODGING;
		else
			this.attack_state = AS_SLIDING;
	}
	ai_run(this, 5);
}

/*
================
PiglinMissile
================
*/
void PiglinMissileTouch(entity this, entity toucher);
void PiglinHome(entity this);
void PiglinMissile(entity this)
{
	vector dir = normalize((this.enemy.origin + '0 0 10') - this.origin);
	float dist = vlen(this.enemy.origin - this.origin);
	float flytime = dist * 0.002;
	if(flytime < 0.1)
		flytime = 0.1;

	this.effects |= EF_MUZZLEFLASH;
	_sound(this, CH_WEAPON_SINGLE, "shalrath/attack2.wav", 1, ATTN_NORM);

	entity missile = spawn();
	missile.flags = FL_PROJECTILE;
	missile.classname = "vore_ball";
	missile.owner = this;
	missile.projectiledeathtype = DEATH_MONSTER_PIGLIN.m_id;
	missile.clipgroup = this.clipgroup;

	missile.solid = SOLID_BBOX;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	_setmodel(missile, "progs/v_spike.mdl");

	setsize(missile, '0 0 0', '0 0 0');		

	missile.origin = this.origin + '0 0 10';
	missile.velocity = dir * 400;
	missile.avelocity = '300 300 300';
	missile.nextthink = flytime + time;
	missile.count = time + 10;
	setthink(missile, PiglinHome);
	missile.enemy = this.enemy;
	settouch(missile, PiglinMissileTouch);

	IL_PUSH(g_projectiles, missile);
}

void PiglinHome(entity this)
{
	vector vtemp = this.enemy.origin + '0 0 10';
	if(this.enemy.health < 1 || (this.enemy.flags & FL_NOTARGET) || time > this.count)
	{
		delete(this);
		return;
	}
	vector dir = normalize(vtemp - this.origin);
	this.velocity = dir * 250;
	this.nextthink = time + 0.2;
	setthink(this, PiglinHome);	
}

void PiglinMissileTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD))
		T_Damage(toucher, this, this, 110, this.projectiledeathtype);	
	T_RadiusDamage(this, this.owner, 40, this.projectiledeathtype, NULL);
	sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);

	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);

	this.velocity = '0 0 0';
	settouch(this, func_null);
	setmodel(this, MDL_EXPLOSION);
	this.solid = SOLID_NOT;
	setsize(this, '0 0 0', '0 0 0');
	s_explode1(this);
}

void piglin_shoot(entity this)
{
	if(this.walkframe <= anim_piglin_shoot)
	{
		float r = random();
		if(r < 0.25)
			_sound(this, CH_VOICE, "piglin/retreat1.wav", 1, ATTN_NORM);
		else if(r < 0.5)
			_sound(this, CH_VOICE, "piglin/retreat2.wav", 1, ATTN_NORM);
		else if(r < 0.75)
			_sound(this, CH_VOICE, "piglin/retreat3.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "piglin/retreat4.wav", 1, ATTN_NORM);
		this.walkframe = anim_piglin_shoot;
	}

	if(this.walkframe == anim_piglin_shoot + 1)
		this.attack_finished = time + 5; // prevent silly

	this.walkframe += 1;

	if(this.walkframe == 125)
		PiglinMissile(this);
	set_anim(this, this.walkframe, piglin_shoot);
	this.nextthink = time + 0.05;
	if(this.walkframe >= 132)
	{
		this.attack_finished = time + 3;
		setthink(this, piglin_run);
	}
}

void piglin_melee(entity this)
{
	set_anim(this, anim_piglin_attack, piglin_run);
	this.nextthink = time + 0.5;
	ai_face(this);
	ai_melee(this, DEATH_MONSTER_PIGLIN.m_id, 100, false);
	this.attack_finished = time + 0.5;
}

//===========================================================================

void piglin_pain6(entity this) { set_anim(this, anim_piglin_stand, piglin_run); this.colormod = (this.charmed) ? '0 1 0' : '1 1 1'; }
void piglin_pain5(entity this) { set_anim(this, anim_piglin_stand, piglin_pain6); }
void piglin_pain4(entity this) { set_anim(this, anim_piglin_stand, piglin_pain5); this.colormod = '1 0.8 0.8'; }
void piglin_pain3(entity this) { set_anim(this, anim_piglin_stand, piglin_pain4); }
void piglin_pain2(entity this) { set_anim(this, anim_piglin_stand, piglin_pain3); ai_pain(this, 6); this.colormod = '1 0.6 0.6'; }
void piglin_pain1(entity this) { set_anim(this, anim_piglin_stand, piglin_pain2); ai_pain(this, 6); }

void piglin_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	if(this.attack_finished > time)
		return;

	float r = random();
	if(r < 0.33)
		_sound(this, CH_VOICE, "piglin/hurt1.wav", 1, ATTN_NORM);
	else if(r < 0.66)
		_sound(this, CH_VOICE, "piglin/hurt2.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "piglin/hurt3.wav", 1, ATTN_NORM);

	this.pain_finished = time + 1;
	this.colormod = '1 0.9 0.9';

	piglin_pain1(this);
}

//===========================================================================

void piglin_vanish(entity this)
{
	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

void piglin_die7(entity this) { set_anim(this, anim_piglin_death, piglin_vanish); this.nextthink = time + 0.7; this.angles_z = 90; }
void piglin_die6(entity this) { set_anim(this, anim_piglin_death, piglin_die7); this.angles_z = 90; }
void piglin_die5(entity this) { set_anim(this, anim_piglin_death, piglin_die6); this.angles_z = 75; }
void piglin_die4(entity this) { set_anim(this, anim_piglin_death, piglin_die5); this.angles_z = 60; }
void piglin_die3(entity this) { set_anim(this, anim_piglin_death, piglin_die4); this.angles_z = 45; }
void piglin_die2(entity this) { set_anim(this, anim_piglin_death, piglin_die3); this.angles_z = 30; }
void piglin_die1(entity this) { set_anim(this, anim_piglin_death, piglin_die2); this.solid = SOLID_NOT; this.angles_z = 15; }

void piglin_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	float r = random();
	if(r < 0.25)
		_sound(this, CH_VOICE, "piglin/death1.wav", 1, ATTN_NORM);
	else if(r < 0.50)
		_sound(this, CH_VOICE, "piglin/death2.wav", 1, ATTN_NORM);
	else if(r < 0.75)
		_sound(this, CH_VOICE, "piglin/death3.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "piglin/death4.wav", 1, ATTN_NORM);

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

	this.colormod = '1 0.6 0.6';
	this.angles_z = 0;
	piglin_die1(this);
}

/*QUAKED monster_piglin (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_piglin) { monster_start(this, true, MON_PIGLIN); }
#endif // SVQC

#ifdef SVQC
METHOD(Piglin, mr_setup, bool(Piglin this, entity actor))
{
    TC(Piglin, this);

	precache_sound("piglin/hurt1.wav");
	precache_sound("piglin/hurt2.wav");
	precache_sound("piglin/hurt3.wav");

	precache_sound("piglin/death1.wav");
	precache_sound("piglin/death2.wav");
	precache_sound("piglin/death3.wav");
	precache_sound("piglin/death4.wav");

	precache_sound("piglin/idle1.wav");
	precache_sound("piglin/idle2.wav");
	precache_sound("piglin/idle3.wav");
	precache_sound("piglin/idle4.wav");

	precache_sound("piglin/angry1.wav");
	precache_sound("piglin/angry2.wav");
	precache_sound("piglin/angry3.wav");
	precache_sound("piglin/angry4.wav");

	precache_sound("piglin/step1.wav");
	precache_sound("piglin/step2.wav");
	precache_sound("piglin/step3.wav");
	precache_sound("piglin/step4.wav");
	precache_sound("piglin/step5.wav");

	precache_sound("piglin/retreat1.wav");
	precache_sound("piglin/retreat2.wav");
	precache_sound("piglin/retreat3.wav");
	precache_sound("piglin/retreat4.wav");

	actor.yaw_speed = 180;

    actor.health = 100;
    actor.th_stand = piglin_stand;
	actor.th_walk = piglin_walk;
	actor.th_run = piglin_run;
	actor.th_pain = piglin_pain;
	actor.th_die = piglin_die;
	actor.th_melee = piglin_melee;
	actor.th_missile = piglin_shoot;

    return true;
}
METHOD(Piglin, mr_sight, bool(Piglin this, entity actor))
{
    TC(Piglin, this);

    float r = random();
	if(r < 0.25)
		_sound(actor, CH_VOICE, "piglin/angry1.wav", 1, ATTN_NORM);
	else if(r < 0.5)
		_sound(actor, CH_VOICE, "piglin/angry2.wav", 1, ATTN_NORM);
	else if(r < 0.75)
		_sound(actor, CH_VOICE, "piglin/angry3.wav", 1, ATTN_NORM);
	else
		_sound(actor, CH_VOICE, "piglin/angry4.wav", 1, ATTN_NORM);

    return true;
}
#endif
