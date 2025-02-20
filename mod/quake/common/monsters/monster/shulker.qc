#include "shulker.qh"

#ifdef SVQC
const int anim_shulker_loop = 0;
const int anim_shulker_open = 1; // starts opening animation 1 after this
const int anim_shulker_close = 54; // starts closing animation 1 after this

void shulker_shoot(entity this);

void shulker_frame(entity this)
{
	this.walkframe += 1;
	if(this.walkframe < anim_shulker_loop || this.walkframe > 95)
		this.walkframe = anim_shulker_loop;

	switch(this.walkframe)
	{
		case 2:
		case 65:
		{
			this.resist_shells = this.resist_cells = 0.9;
			this.resist_nails = this.resist_rockets = 0.9;
			break;
		}
		case 16:
		{
			this.resist_shells = this.resist_cells = 0;
			this.resist_nails = this.resist_rockets = 0;
			break;
		}
		case 26:
		{
			if(this.enemy)
				sound(this, CH_WEAPON_SINGLE, SND_MON_SHULKER_CHARGE_RANDOM(), 1, ATTN_NORM);
			break;
		}
		case 32:
		{
			if(this.enemy)
				shulker_shoot(this);
			break;
		}
	}

	set_anim(this, this.walkframe, shulker_frame);
	this.nextthink = time + 0.05;

	if(this.enemy)
		ai_run(this, 0);
	else
		ai_walk(this, 0);
}

/*
================
ShulkerMissile
================
*/
void ShulkerMissileTouch(entity this, entity toucher);
void ShulkerHome(entity this);
void ShulkerMissile(entity this)
{
	vector dir = normalize((this.enemy.origin + '0 0 10') - this.origin);
	float dist = vlen(this.enemy.origin - this.origin);
	float flytime = dist * 0.002;
	if(flytime < 0.1)
		flytime = 0.1;

	this.effects |= EF_MUZZLEFLASH;

	entity missile = spawn();
	missile.classname = "vore_ball";
	missile.owner = this;
	missile.projectiledeathtype = DEATH_MONSTER_SHULKER.m_id;

	missile.solid = SOLID_BBOX;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	_setmodel(missile, "progs/v_spike.mdl");

	setsize(missile, '0 0 0', '0 0 0');		

	missile.origin = this.origin;
	missile.velocity = dir * 200;
	missile.colormod = '1 0.99 0.81';
	missile.avelocity = '300 300 300';
	missile.nextthink = flytime + time;
	missile.count = time + 10;
	setthink(missile, ShulkerHome);
	missile.enemy = this.enemy;
	settouch(missile, ShulkerMissileTouch);
}

void ShulkerHome(entity this)
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
	setthink(this, ShulkerHome);	
}

void ShulkerMissileTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(toucher.takedamage)
	{
		float efftime = 7;
		float curtime = StatusEffects_gettime(STATUSEFFECT_Levitation, toucher);
		if((time + efftime) > curtime)
			StatusEffects_apply(STATUSEFFECT_Levitation, toucher, time + efftime, 0);
	}

	if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD))
		T_Damage(toucher, this, this, 110, this.projectiledeathtype);	
	T_RadiusDamage(this, this.owner, 15, this.projectiledeathtype, NULL);
	sound(this, CH_WEAPON_SINGLE, SND_MON_SHULKER_EXPLODE_RANDOM(), 1, ATTN_NORM);

	te_explosion2(this.origin, 10, 5);

	delete(this);
}

void shulker_shoot(entity this)
{
	sound(this, CH_VOICE, SND_MON_SHULKER_SHOOT_RANDOM(), 1, ATTN_NORM);

	ShulkerMissile(this);
}

//===========================================================================

void shulker_teleport(entity this)
{
	vector extrasize = '1 1 1' * 400;
	vector from = this.origin;
	if(MoveToRandomLocationWithinBounds(this, this.absmin - extrasize, this.absmax + extrasize,
											DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, 
											Q3SURFACEFLAG_SKY, 20, 64, 256, true))
	{
		// no special treatment needed, we're just using it as a position!
		this.mangle = '0 1 0' * this.angles_y;
		this.angles = '0 0 0';
		soundat(NULL, from, CH_TRIGGER, "shulker/portal.wav", 1, ATTEN_NORM);
		soundat(NULL, this.origin, CH_TRIGGER, "shulker/portal2.wav", 1, ATTEN_NORM);
		te_teleport(this.origin);
		te_teleport(from);
		UNSET_ONGROUND(this);
	}
}

void shulker_pain6(entity this) { set_anim(this, this.walkframe, shulker_frame); this.colormod = (this.charmed) ? '0 1 0' : '1 1 1'; }
void shulker_pain5(entity this) { set_anim(this, this.walkframe, shulker_pain6); }
void shulker_pain4(entity this) { set_anim(this, this.walkframe, shulker_pain5); this.colormod = '1 0.8 0.8'; }
void shulker_pain3(entity this) { set_anim(this, this.walkframe, shulker_pain4); }
void shulker_pain2(entity this) { set_anim(this, this.walkframe, shulker_pain3); this.colormod = '1 0.6 0.6'; }
void shulker_pain1(entity this) { set_anim(this, this.walkframe, shulker_pain2); }

void shulker_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	bool is_closed = (this.walkframe > 64 || this.walkframe < 10);

	if(is_closed)
		sound(this, CH_VOICE, SND_MON_SHULKER_PAIN_CLOSED_RANDOM(), 1, ATTN_NORM);
	else
		sound(this, CH_VOICE, SND_MON_SHULKER_PAIN_RANDOM(), 1, ATTN_NORM);

	this.pain_finished = time + 0.6;
	this.colormod = '1 0.9 0.9';

	if(random() < 0.80)
		shulker_teleport(this);

	shulker_pain1(this);
}

//===========================================================================

void shulker_vanish(entity this)
{
	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

void shulker_die7(entity this) { set_anim(this, this.walkframe, shulker_vanish); this.nextthink = time + 0.7; this.angles_z = 90; }
void shulker_die6(entity this) { set_anim(this, this.walkframe, shulker_die7); this.angles_z = 90; }
void shulker_die5(entity this) { set_anim(this, this.walkframe, shulker_die6); this.angles_z = 75; }
void shulker_die4(entity this) { set_anim(this, this.walkframe, shulker_die5); this.angles_z = 60; }
void shulker_die3(entity this) { set_anim(this, this.walkframe, shulker_die4); this.angles_z = 45; }
void shulker_die2(entity this) { set_anim(this, this.walkframe, shulker_die3); this.angles_z = 30; }
void shulker_die1(entity this) { set_anim(this, this.walkframe, shulker_die2); this.solid = SOLID_NOT; this.angles_z = 15; }

void shulker_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	sound(this, CH_VOICE, SND_MON_SHULKER_DEATH_RANDOM(), 1, ATTN_NORM);

	this.colormod = '1 0.6 0.6';
	this.angles_z = 0;
	shulker_die1(this);
}

/*QUAKED monster_shulker (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_shulker) { monster_start(this, true, MON_SHULKER); }
#endif // SVQC

#ifdef SVQC
METHOD(Shulker, mr_setup, bool(Shulker this, entity actor))
{
    TC(Shulker, this);

    precache_sound("shulker/portal.wav");
	precache_sound("shulker/portal2.wav");

	actor.yaw_speed = 90;

    actor.health = 100;
    actor.th_stand = shulker_frame;
	actor.th_walk = shulker_frame;
	actor.th_run = shulker_frame;
	actor.th_pain = shulker_pain;
	actor.th_die = shulker_die;

    return true;
}
#endif
