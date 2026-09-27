#include "spazmatism.qh"

#ifdef SVQC
.int bosswave;
.float anim_finished;
.vector moveto;

void spaz_think(entity this);

void spaz_breath(entity this)
{
	if(time >= this.fly_sound)
	{
		this.fly_sound = time + 0.33;
		_sound(this, CH_WEAPON_A, "twins/cursed_flames.wav", 1, ATTN_BOSS);
	}

	vector ang = this.angles;
	ang.x = -ang.x;

	makevectors(ang);

	vector myorg = CENTER_OR_VIEWOFS(this) - '0 0 8'; // lower slightly so it has a chance of hitting the player!
	Send_Effect(EFFECT_CURSED_FLAMEJET, myorg, v_forward * 30, 3);

	tracebox(myorg, '-10 -10 -10', '10 10 10', myorg + v_forward * 500, MOVE_NORMAL, this);

	if(trace_ent && trace_ent.takedamage && trace_ent.health > 0)
	{
		if(random() <= 0.68)
		{
			float burntime = floor(autocvar_skill + 3 + 2*random());
			// only add more burn time if there isn't already a longer timer running!
			float curtime = StatusEffects_gettime(STATUSEFFECT_Burning, trace_ent);
			if((time + burntime) > curtime)
				StatusEffects_apply(STATUSEFFECT_Burning, trace_ent, time + burntime, 0);
		}

		float damg = 4 + random();
		T_Damage(trace_ent, this, this, damg, DEATH_MONSTER_SPAZMATISM.m_id);
	}
}

.int attack_frame;
.float attack2_finished;
void spaz_breath_loop(entity this)
{
	setthink(this, spaz_breath_loop);
	this.nextthink = time;

	twins_anim(this);

	if(!this.enemy || wasfreed(this.enemy) || this.enemy.health < 1)
	{
		setthink(this, spaz_think);
		return;
	}

	vector goal = CENTER_OR_VIEWOFS(this.enemy);

	float myspeed = 150; // not very fast in this mode
	if(vdist(this.velocity, <=, myspeed))
		twins_move(this, goal, myspeed, 0.05);
	else
		twins_brake(this, 10);

	twins_setangle(this, goal);

	// fires at 10 fps but we need smooth movement
	if(time < this.attack2_finished)
		return;
	this.attack2_finished = time + 0.1;

	this.attack_frame += 1;

	if(this.attack_frame > 64)
	{
		this.twins_attackcount = 5;
		this.attack_finished = time + 0.5; // almost immediately start dashing
		this.attack_state = AS_MISSILE;
		setthink(this, spaz_think);
	}
	else if(this.attack_frame > 8)
		spaz_breath(this);
}

void spaz_transform(entity this)
{
	vector oldmin = this.mins;
	vector oldmax = this.maxs;
	_setmodel(this, "progs/spazmatism.mdl");
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

void spaz_spin(entity this)
{
	this.nextthink = time;

	twins_anim(this);

	if(time >= this.attack_finished)
	{
		if(this.bosswave == 0)
		{
			spaz_transform(this);
			this.attack_finished = time + 2;
		}
		else
		{
			this.attack_finished = time + 3;
			this.attack_state = AS_STRAIGHT;
			this.avelocity = '0 0 0';
			this.angles_x = anglemods(this.angles_x); // ???
			setthink(this, spaz_think);
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

void cursed_flame_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
// hit something that bleeds
	if(toucher.takedamage) // yoder mod, jan 05 2021
	{
		float damg = ((this.dmg) ? this.dmg : 9);
		spawn_touchblood(this, damg, toucher);
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);

		float efftime = floor(autocvar_skill + 3 + 2*random());
		// only add more burn time if there isn't already a longer timer running!
		float curtime = StatusEffects_gettime(STATUSEFFECT_Burning, toucher);
		if((time + efftime) > curtime)
			StatusEffects_apply(STATUSEFFECT_Burning, toucher, time + efftime, 0);
	}

	_sound(this, CH_WEAPON_SINGLE, "twins/cursed_flame_impact.wav", 1, ATTN_NORM);
	te_explosion2(this.origin, 55, 5);

	delete(this);
}

void spaz_cursedflame(entity this)
{
	_sound(this, CH_WEAPON_SINGLE, "twins/cursed_flame_fire.wav", 1, ATTN_BOSS);

	vector org = CENTER_OR_VIEWOFS(this);

	// lead the player on hard mode
	float pspeed = 600;
	entity targ = this.enemy;
	vector enemy_org = CENTER_OR_VIEWOFS(targ);
	vector targ_org = ai_shotlead(org, enemy_org, targ.velocity, pspeed);
	vector dir = normalize(targ_org - org);

	entity newmis = launch_spike(this, org, dir);
	newmis.dmg = 12;
	newmis.velocity = dir * pspeed;
	settouch(newmis, cursed_flame_touch);
	newmis.avelocity = '180 180 180';
	newmis.projectiledeathtype = DEATH_MONSTER_SPAZMATISM.m_id;
	_setmodel(newmis, "progs/cursedball.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
}

void spaz_touch(entity this, entity toucher)
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
	
	T_Damage(toucher, this, this, damage, DEATH_MONSTER_SPAZMATISM.m_id);
}

void spaz_touchframe(entity this)
{
	// since we use noclip, touching must be handled manually
	vector emin = this.absmin, emax = this.absmax;
	emin -= '1 1 1';
	emax += '1 1 1';

	FOREACH_ENTITY_BOX_ORDERED(emin, emax, it != this,
	{
		if (it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY)
			spaz_touch(this, it);
	});
}

void spaz_attack_phase2(entity this)
{
	switch(this.attack_state)
	{
		default:
		case AS_STRAIGHT:
		{
			this.attack_frame = 0;
			setthink(this, spaz_breath_loop);
			this.nextthink = time;
			break;
		}
		case AS_MISSILE:
		{
			this.twins_attackcount -= 1;
			vector myorg = CENTER_OR_VIEWOFS(this);
			vector targ_org = CENTER_OR_VIEWOFS(this.enemy);

			vector dir = normalize(targ_org - myorg);
			this.moveto = targ_org + dir * 500;
			this.velocity = dir * 1600;

			this.attack_finished = time + 2;

			if(this.twins_attackcount % 2)
				_sound(this, CH_VOICE, "eoc/sight.wav", 1, ATTN_BOSS);

			if(this.twins_attackcount <= 0)
			{
				this.attack_state = AS_STRAIGHT;
				this.attack_finished = time + 2;
			}
			break;
		}
	}
}

void spaz_attack_phase1(entity this)
{
	switch(this.attack_state)
	{
		default:
		case AS_STRAIGHT: // passive phase
		{
			this.twins_attackcount -= 1;
			spaz_cursedflame(this);
			if(autocvar_skill >= 2)
				this.attack_finished = time + 1;
			else
				this.attack_finished = time + 2;

			if(this.twins_attackcount <= 0)
			{
				this.attack_finished = time + 1;
				this.attack_state = AS_DODGING;
				this.twins_attackcount = 5;
			}
			break;
		}
		case AS_DODGING:
		{
			this.twins_attackcount -= 1;
			vector myorg = CENTER_OR_VIEWOFS(this);
			vector targ_org = CENTER_OR_VIEWOFS(this.enemy);
			vector dir = normalize(targ_org - myorg);
			this.moveto = targ_org + dir * 500;
			this.velocity = dir * 900;

			this.attack_finished = time + 2;

			if(this.twins_attackcount <= 0)
			{
				this.attack_finished = time + 5;
				this.attack_state = AS_STRAIGHT;
				this.twins_attackcount = 5;
			}
			break;
		}
	}
}

void spaz_attackframe(entity this)
{
	if(this.bosswave == 0)
		spaz_attack_phase1(this);
	else
		spaz_attack_phase2(this);
}

void spaz_think(entity this)
{
	this.nextthink = time;
	setthink(this, spaz_think);

	twins_anim(this);

	if(this.bosswave == 0 && this.health <= (this.max_health * 0.40))
	{
		this.attack_finished = time + 2; // time it takes to transform
		setthink(this, spaz_spin);
		this.nextthink = time;
		return;
	}

	spaz_touchframe(this);

	bool had_enemy = (this.enemy != NULL);

#if 0
	if(this.buddy && this.buddy.enemy)
		this.enemy = this.buddy.enemy;
	else
#endif
		boss_FindTarget(this);

	if(this.enemy && !had_enemy)
		this.attack_finished = time + 3; // initial delay before attacking

	this.goalentity = twins_pickmovegoal(this);

	if(this.moveto != '0 0 0' && vdist(this.origin - this.moveto, <=, 64))
		this.moveto = '0 0 0';

	if(this.enemy && time >= this.attack_finished)
		spaz_attackframe(this);

	vector goal = '0 0 0';
	if(this.moveto != '0 0 0')
		goal = this.moveto;
	else if(this.enemy)
	{
		// circle the target
		goal = CENTER_OR_VIEWOFS(this.enemy);

		float orbit_radius = 128;

		goal.x += (sin(time * 6) * orbit_radius);
		goal.y += (cos(time * 6) * orbit_radius);
		goal.z += 200;
	}
	else if(this.goalentity)
		goal = CENTER_OR_VIEWOFS(this.goalentity);
	else if(this.pos1 != '0 0 0')
		goal = this.pos1; // return home otherwise, so we're not left in the void

	if(goal != '0 0 0')
	{
		float myspeed = (this.enemy) ? 500 : 200;
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

void spaz_pain(entity this, entity attacker, float damage, int deathtype)
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

void gib_spaz(entity this)
{
	_sound(this, CH_VOICE, "twins/explode.wav", 1, ATTN_BOSS);
	settouch(this, func_null);

	Send_Effect(EFFECT_EXPLOSION_SMALL, CENTER_OR_VIEWOFS(this), '0 0 0', 1);
	ThrowGib(this, this, "progs/rawbone.mdl", this.health);
}

void spaz_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			gib_spaz(this);
			// fall back to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	gib_spaz(this);
	delete(this);
}

//spawnfunc(monster_spazmatism) { monster_start(this, true, MON_SPAZMATISM); }
#endif // SVQC

#ifdef SVQC
METHOD(Spazmatism, mr_setup, bool(Spazmatism this, entity actor))
{
    TC(Spazmatism, this);

	precache_model("progs/spazmatism.mdl");
	precache_model("progs/xtragib.mdl");
	precache_model("progs/bone.mdl");
	precache_model("progs/bone2.mdl");
	precache_model("progs/rawbone2.mdl");
	precache_model("progs/cursedball.mdl");
	precache_sound("eoc/death.wav");
	precache_sound("eoc/pain.wav");
	precache_sound("twins/explode.wav");
	precache_sound("twins/hit.wav");
	precache_sound("twins/cursed_flames.wav");
	precache_sound("twins/cursed_flame_fire.wav");
	precache_sound("twins/cursed_flame_impact.wav");
	precache_sound("eoc/sight.wav");

	actor.bosswave = 0;
	actor.skin = 2;

	actor.yaw_speed = 10;
	actor.twins_attackcount = 5;

	actor.pos1 = actor.origin;

	set_movetype(actor, MOVETYPE_NOCLIP);

    actor.health = 3200;
	actor.th_stand = spaz_think;
	actor.th_walk = spaz_think;
	actor.th_run = spaz_think;
	actor.th_pain = spaz_pain;
	actor.th_die = spaz_die;

    return true;
}
METHOD(Spazmatism, mr_sight, bool(Spazmatism this, entity actor))
{
	TC(Spazmatism, this);

	_sound(actor, CH_VOICE, "eoc/sight.wav", 1, ATTN_NORM);

	return true;
}
#endif
