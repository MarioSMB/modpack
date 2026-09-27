#include "retinazer.qh"

#ifdef SVQC
.int bosswave;
.float anim_finished;
.vector moveto;

void ret_think(entity this);

void ret_transform(entity this)
{
	vector oldmin = this.mins;
	vector oldmax = this.maxs;
	_setmodel(this, "progs/retinazer.mdl");
	setsize(this, oldmin, oldmax);

	_sound(this, CH_VOICE, "eoc/sight.wav", 1, ATTN_BOSS);

	this.bosswave += 1;

	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, this, "progs/gib1.mdl", this.health);
	ThrowGib(this, this, "progs/bone.mdl", this.health);
	ThrowGib(this, this, "progs/gib2.mdl", this.health);
	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, this, "progs/bone2.mdl", this.health);
	ThrowGib(this, this, "progs/gib1.mdl", this.health);
	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, this, "progs/gib2.mdl", this.health);
	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, this, "progs/rawbone.mdl", this.health);
	ThrowGib(this, this, "progs/gib3.mdl", this.health);

	if(this.tether_ent)
		tether_remove(this.tether_ent);
	else if(this.buddy && this.buddy.tether_ent)
		tether_remove(this.buddy.tether_ent);
}

void ret_spin(entity this)
{
	this.nextthink = time;

	twins_anim(this);

	if(time >= this.attack_finished)
	{
		if(this.bosswave == 0)
		{
			ret_transform(this);
			this.attack_finished = time + 2;
		}
		else
		{
			this.attack_finished = time + 3;
			this.attack_state = AS_STRAIGHT;
			this.twins_attackcount = 3;
			this.avelocity = '0 0 0';
			this.angles_x = anglemods(this.angles_x); // ???
			setthink(this, ret_think);
			return;
		}
	}

	if(vdist(this.velocity, >, 0))
		twins_brake(this, 5);

	if(this.bosswave < 1)
		this.avelocity_x = min(this.avelocity_x + 720 * PHYS_INPUT_TIMELENGTH, 720);
	else
		this.avelocity_x = max(0, this.avelocity_x - 900 * PHYS_INPUT_TIMELENGTH);
}

void ret_laser(entity this)
{
	if(!this.enemy || this.enemy.health <= 0)
		return;

	entity targ = this.enemy;
	entity newmis = LaunchLaser(this, this.origin, targ.origin - this.origin);
	newmis.projectiledeathtype = DEATH_MONSTER_RETINAZER.m_id;
	_sound(this, CH_WEAPON_SINGLE, "twins/laser_fire.wav", 1, ATTN_NORM);
}

void ret_touch(entity this, entity toucher)
{
	if(toucher.flags & FL_PROJECTILE)
		return;
	if(this.clipgroup && this.clipgroup == toucher.clipgroup)
		return;
	if(time < toucher.hurt_antispam)
		return;

	if(!toucher.takedamage || !Damage_ValidTarget(toucher, this))
		return;
	
	if(toucher == this.owner || toucher.owner == this)
		return;

	toucher.hurt_antispam = time + 0.5; // no spam please

	float damage = 18 + (random() * 6) + (random() * 4);
	if(this.bosswave >= 1)
		damage *= 2;
	
	T_Damage(toucher, this, this, damage, DEATH_MONSTER_RETINAZER.m_id);
}

void ret_touchframe(entity this)
{
	// since we use noclip, touching must be handled manually
	vector emin = this.absmin, emax = this.absmax;
	emin -= '1 1 1';
	emax += '1 1 1';

	FOREACH_ENTITY_BOX_ORDERED(emin, emax, it != this,
	{
		if (it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY)
			ret_touch(this, it);
	});
}

void ret_attack_phase2(entity this)
{
	switch(this.attack_state)
	{
		default:
		case AS_STRAIGHT: // passive phase
		{
			this.twins_attackcount -= 1;
			ret_laser(this);
			this.attack_finished = time + 1;

			if(this.twins_attackcount <= 0)
			{
				this.attack_finished = time + 1;
				this.attack_state = AS_DODGING;
				this.twins_attackcount = 9;
			}
			break;
		}
		case AS_DODGING:
		{
			this.twins_attackcount -= 1;
			ret_laser(this);
			this.attack_finished = time + 0.15;

			if(this.twins_attackcount <= 0)
			{
				this.attack_finished = time + 3;
				this.attack_state = AS_STRAIGHT;
				this.twins_attackcount = 2;
			}
			break;
		}
	}
}

void ret_attack_phase1(entity this)
{
	switch(this.attack_state)
	{
		default:
		case AS_STRAIGHT: // passive phase
		{
			this.twins_attackcount -= 1;
			ret_laser(this);
			this.attack_finished = time + 1;

			if(this.twins_attackcount <= 0)
			{
				this.attack_finished = time + 1;
				this.attack_state = AS_DODGING;
				this.twins_attackcount = 4;
			}
			break;
		}
		case AS_DODGING:
		{
			this.twins_attackcount -= 1;
			vector myorg = CENTER_OR_VIEWOFS(this);
			vector targ_org = CENTER_OR_VIEWOFS(this.enemy);
			vector dir = normalize(targ_org - myorg);
			this.moveto = targ_org + dir * 400;
			this.velocity = dir * 700;

			this.attack_finished = time + 2;

			if(this.twins_attackcount <= 0)
			{
				this.attack_finished = time + 5;
				this.attack_state = AS_STRAIGHT;
				this.twins_attackcount = 6;
			}
			break;
		}
	}
}

void ret_attackframe(entity this)
{
	if(this.bosswave == 0)
		ret_attack_phase1(this);
	else
		ret_attack_phase2(this);
}

void ret_think(entity this)
{
	this.nextthink = time;
	setthink(this, ret_think);

	twins_anim(this);

	if(this.bosswave == 0 && this.health <= (this.max_health * 0.40))
	{
		this.attack_finished = time + 2; // time it takes to transform
		setthink(this, ret_spin);
		this.nextthink = time;
		return;
	}

	ret_touchframe(this);

	bool had_enemy = (this.enemy != NULL);

#if 0
	if(this.buddy && this.buddy.enemy)
		this.enemy = this.buddy.enemy;
	else
#endif
		boss_FindTarget(this);

	if(this.enemy && !had_enemy)
		this.attack_finished = time + 6; // initial delay before attacking

	this.goalentity = twins_pickmovegoal(this);

	if(this.moveto != '0 0 0' && vdist(this.origin - this.moveto, <=, 64))
		this.moveto = '0 0 0';

	if(this.enemy && time >= this.attack_finished)
		ret_attackframe(this);

	vector goal = '0 0 0';
	if(this.moveto != '0 0 0')
		goal = this.moveto;
	else if(this.enemy)
	{
		// circle the target
		goal = CENTER_OR_VIEWOFS(this.enemy);

		float orbit_radius = 128;

		goal.x += (cos(time * 6) * orbit_radius);
		goal.y += (sin(time * 6) * orbit_radius);
		// no longer diagonally follows the target
		if(this.bosswave < 1)
			goal.z += 200;
	}
	else if(this.goalentity)
		goal = CENTER_OR_VIEWOFS(this.goalentity);
	else if(this.pos1 != '0 0 0')
		goal = this.pos1; // return home otherwise, so we're not left in the void

	if(goal != '0 0 0')
	{
		float myspeed = (this.enemy) ? 400 : 200;
		if(this.bosswave >= 1)
			myspeed *= 0.7;
		if(StatusEffects_active(STATUSEFFECT_Slowness, this))
			myspeed *= 0.5;

		if(vdist(this.velocity, <=, myspeed))
			twins_move(this, goal, myspeed, 0.1);
		else
			twins_brake(this, 20);

		vector look_goal = '0 0 0';
		if(this.moveto != '0 0 0')
			look_goal = this.moveto;
		else if(this.goalentity)
			look_goal = CENTER_OR_VIEWOFS(this.goalentity);
		else
			look_goal = goal;
		twins_setangle(this, look_goal);
	}
	else
		twins_brake(this, 2);
}

void ret_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	if(this.health <= 0)
		return;
	if(this.bosswave >= 1)
		_sound(this, CH_VOICE, "twins/hit.wav", 1, ATTN_BOSS);
	else
		_sound(this, CH_VOICE, "eoc/pain.wav", 1, ATTN_BOSS);
	this.pain_finished = time + 0.1;
}

void gib_ret(entity this)
{
	_sound(this, CH_VOICE, "twins/explode.wav", 1, ATTN_BOSS);
	settouch(this, func_null);

	Send_Effect(EFFECT_EXPLOSION_SMALL, CENTER_OR_VIEWOFS(this), '0 0 0', 1);
	ThrowGib(this, this, "progs/rawbone.mdl", this.health);
}

void ret_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			gib_ret(this);
			// fall back to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	gib_ret(this);
	delete(this);
}

//spawnfunc(monster_retinazer) { monster_start(this, true, MON_RETINAZER); }
#endif // SVQC

#ifdef SVQC
METHOD(Retinazer, mr_setup, bool(Retinazer this, entity actor))
{
    TC(Retinazer, this);

	precache_model("progs/retinazer.mdl");
	precache_model("progs/xtragib.mdl");
	precache_model("progs/bone.mdl");
	precache_model("progs/bone2.mdl");
	precache_model("progs/rawbone2.mdl");
	precache_sound("eoc/death.wav");
	precache_sound("eoc/pain.wav");
	precache_sound("twins/explode.wav");
	precache_sound("twins/laser_fire.wav");
	precache_sound("twins/hit.wav");
	precache_sound("eoc/sight.wav");

	actor.bosswave = 0;
	actor.skin = 1;

	actor.yaw_speed = 10;
	actor.twins_attackcount = 5;

	actor.pos1 = actor.origin;

	set_movetype(actor, MOVETYPE_NOCLIP);

    actor.health = 3000;
	actor.th_stand = ret_think;
	actor.th_walk = ret_think;
	actor.th_run = ret_think;
	actor.th_pain = ret_pain;
	actor.th_die = ret_die;

    return true;
}
METHOD(Retinazer, mr_sight, bool(Retinazer this, entity actor))
{
	TC(Retinazer, this);

	_sound(actor, CH_VOICE, "eoc/sight.wav", 1, ATTN_NORM);

	return true;
}
#endif
