#include "crazydave.qh"

// ============
//  SUNFLOWER
// ============

#ifdef SVQC
METHOD(CrazyDaveSunflower, tr_precache, void(CrazyDaveSunflower thistur))
{
	precache_sound("turrets/sunflower_fire.wav");
}
METHOD(CrazyDaveSunflower, tr_think, void(CrazyDaveSunflower this, entity actor))
{
	if(time < actor.attack2_finished)
		return;

	actor.attack2_finished = time + 5;

	_sound(actor, CH_WEAPON_SINGLE, "turrets/sunflower_fire.wav", 1, ATTN_NORM);

	makevectors(actor.angles);
	vector from = CENTER_OR_VIEWOFS(actor);
	vector dir = v_forward;

	float fuel = rint(10 * turret_getpower(actor.tur_level, 1));
	td_DropFuelAmount(from, TD_FUEL_SUN, fuel, dir, actor);
}
METHOD(CrazyDaveSunflower, tr_setup, void(CrazyDaveSunflower this, entity actor))
{
	actor.view_ofs = '0 0 24';

	actor.attack2_finished = time + 3;
}
#endif // SVQC
#ifdef CSQC
METHOD(CrazyDaveSunflower, tr_setup, void(CrazyDaveSunflower this, entity actor))
{
	actor.anim_idle = '0 7 0';
	actor.anim_shoot = '0 7 0';
}
#endif // CSQC

// ============
//  PEASHOOTER
// ============

#ifdef SVQC
METHOD(CrazyDavePeashooter, tr_precache, void(CrazyDavePeashooter thistur))
{
	precache_sound("turrets/peashooter_fire.wav");
	precache_sound("turrets/peashooter_impact.wav");
}
METHOD(CrazyDavePeashooter, tr_think, void(CrazyDavePeashooter this, entity actor))
{
	// make sure it matches drawn values!
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	if(actor.enemy)
	{
		vector org = actor.origin + actor.view_ofs;
		vector targ_org = (actor.enemy.absmin + actor.enemy.absmax) * 0.5;
		bool isinfront = turret_infront(actor, actor.enemy, actor.angles, maxpitch, maxrot);
		bool isvisible = visible(actor, actor.enemy);
		if(isvisible || isinfront)
			actor.search_time = time + 1;
		if(actor.enemy.health < 1 || actor.enemy.exptime != 0 || time > actor.search_time || vdist(org - targ_org, >, myrange * 1.5))
		{
			actor.enemy = NULL;
			return; // won't find a new target this frame
		}

		if(time > actor.attack_finished && isinfront && isvisible)
		{
			actor.attack_finished = time + max(0.03, (2 / turret_getpower(actor.tur_level, 0.5)));
			actor.clientframe = TANIM_SHOOT;

			_sound(actor, CH_WEAPON_SINGLE, "turrets/peashooter_fire.wav", 1, ATTN_NORM);

			vector dir = normalize(targ_org - org);
			entity missile = launch_spike(actor, org, dir);
			missile.dmg = this.tur_dmg * turret_getpower(actor.tur_level, this.tur_dmgscale);
			missile.projectiledeathtype = DEATH_TRAP.m_id;
			setsize(missile, '0 0 0', '0 0 0');
			missile.noise = "turrets/peashooter_impact.wav";

			CSQCProjectile(missile, true, PROJECTILE_PEA, true);
		}
	}
	
	if(!actor.enemy && time >= actor.idle_finished)
	{
		actor.idle_finished = time + 0.5;
		actor.enemy = turret_findtarget(actor, maxpitch, maxrot, myrange);
	}
}
METHOD(CrazyDavePeashooter, tr_setup, void(CrazyDavePeashooter this, entity actor))
{
	actor.view_ofs = '0 0 32';
}
#endif // SVQC
#ifdef CSQC
METHOD(CrazyDavePeashooter, tr_drawselected, void(CrazyDavePeashooter this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 32';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);

	// TODO: cone?
	//Draw_CylindricLine(org, org + v_forward * myrange, 6, "particles/laserbeam", 0.25, -time * 3, '1 0.25 0', 1, DRAWFLAG_NORMAL, view_origin);
}
METHOD(CrazyDavePeashooter, tr_setup, void(CrazyDavePeashooter this, entity actor))
{
	actor.anim_idle = '0 30 0';
	actor.anim_shoot = '31 39 1';
}
#endif // CSQC

// ========
//  WALNUT
// ========

// does nothing lol

// ==========
//  SNOW PEA
// ==========

#ifdef SVQC
void snowpea_touch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.owner == this.owner)
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
		if(IS_MONSTER(toucher))
		{
			float slowtime = 3 + 2*random();
			// only add more burn time if there isn't already a longer timer running!
			float curtime = StatusEffects_gettime(STATUSEFFECT_Slowness, toucher);
			if((time + slowtime) > curtime)
				StatusEffects_apply(STATUSEFFECT_Slowness, toucher, time + slowtime, 0);
		}

		float damg = ((this.dmg) ? this.dmg : 10);
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}

	_sound(this, CH_SHOTS, "turrets/snowpea_impact.wav", 1, ATTN_NORM);
	//te_explosion2(this.origin, 244, 3);
	particle(this.origin, '0 0 0', 40, 10);

	delete(this);
}

METHOD(CrazyDaveSnowPea, tr_precache, void(CrazyDaveSnowPea thistur))
{
	precache_sound("turrets/peashooter_fire.wav");
	precache_sound("turrets/snowpea_impact.wav");
}
METHOD(CrazyDaveSnowPea, tr_think, void(CrazyDaveSnowPea this, entity actor))
{
	// make sure it matches drawn values!
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	if(actor.enemy)
	{
		vector org = actor.origin + actor.view_ofs;
		vector targ_org = (actor.enemy.absmin + actor.enemy.absmax) * 0.5;
		bool isinfront = turret_infront(actor, actor.enemy, actor.angles, maxpitch, maxrot);
		bool isvisible = visible(actor, actor.enemy);
		if(isvisible || isinfront)
			actor.search_time = time + 1;
		if(actor.enemy.health < 1 || actor.enemy.exptime != 0 || time > actor.search_time || vdist(org - targ_org, >, myrange * 1.5))
		{
			actor.enemy = NULL;
			return; // won't find a new target this frame
		}

		if(time > actor.attack_finished && isinfront && isvisible)
		{
			actor.attack_finished = time + max(0.03, (1.5 / turret_getpower(actor.tur_level, 0.5)));
			actor.clientframe = TANIM_SHOOT;

			_sound(actor, CH_WEAPON_SINGLE, "turrets/peashooter_fire.wav", 1, ATTN_NORM);

			vector dir = normalize(targ_org - org);
			entity missile = launch_spike(actor, org, dir);
			missile.dmg = this.tur_dmg * turret_getpower(actor.tur_level, this.tur_dmgscale);
			missile.projectiledeathtype = DEATH_TRAP.m_id;
			setsize(missile, '0 0 0', '0 0 0');
			missile.noise = "turrets/snowpea_impact.wav";
			settouch(missile, snowpea_touch);

			CSQCProjectile(missile, true, PROJECTILE_SNOWPEA, true);
		}
	}
	
	if(!actor.enemy && time >= actor.idle_finished)
	{
		actor.idle_finished = time + 0.5;
		actor.enemy = turret_findtarget(actor, maxpitch, maxrot, myrange);
	}
}
METHOD(CrazyDaveSnowPea, tr_setup, void(CrazyDaveSnowPea this, entity actor))
{
	actor.view_ofs = '0 0 32';
}
#endif // SVQC
#ifdef CSQC
METHOD(CrazyDaveSnowPea, tr_drawselected, void(CrazyDaveSnowPea this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 32';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);

	// TODO: cone?
	//Draw_CylindricLine(org, org + v_forward * myrange, 6, "particles/laserbeam", 0.25, -time * 3, '1 0.25 0', 1, DRAWFLAG_NORMAL, view_origin);
}
METHOD(CrazyDaveSnowPea, tr_setup, void(CrazyDaveSnowPea this, entity actor))
{
	actor.anim_idle = '0 30 0';
	actor.anim_shoot = '31 39 1';
}
#endif // CSQC

// =============
//  POTATO MINE
// =============

#ifdef SVQC
void potatomine_hitbox_touch(entity this, entity toucher)
{
	Turret tur = this.turretdef;
	float damage = tur.tur_dmg * turret_getpower(this.tur_level, tur.tur_dmgscale);

	// also push enemy away
	if(!(toucher.monsterdef.spawnflags & MONSTER_TYPE_BOSS) && !(toucher.monsterdef.spawnflags & MON_FLAG_STATIONARY))
	{
		float pushforce = 100 / vlen(toucher.maxs - toucher.mins);

		vector dir = normalize(toucher.origin - this.origin);
		toucher.velocity = dir * (200 * pushforce);
		toucher.velocity_z = (85 * pushforce);
	}

	if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MON_FLAG_EXPLOSIONRESISTANT))
		damage *= 0.5;

	T_Damage(toucher, this, this, damage, DEATH_TRAP.m_id);
}

METHOD(CrazyDavePotatoMine, tr_precache, void(CrazyDavePotatoMine thistur))
{
	precache_model("progs/s_spudow.spr");

	precache_sound("turrets/potatomine_arm.wav");
}
METHOD(CrazyDavePotatoMine, tr_think, void(CrazyDavePotatoMine this, entity actor))
{
	if(time <= actor.attack_finished)
		return;

	actor.attack_finished = time + 0.5; // cooldown for enemy checks

	// pick a random nearby target each time we attack
	// make sure it matches drawn values!
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	entity targ = turret_findtarget(actor, 0, 0, myrange);
	if(targ)
	{
		if(actor.enemy)
		{
			actor.enemy = NULL;
			actor.attack_finished = time + max(0.03, (3 / turret_getpower(actor.tur_level, 0.5)));

			// explode in a way that lets range work
			FOREACH_ENTITY_RADIUS(actor.origin + actor.view_ofs, myrange, it != actor && IS_MONSTER(it) && it.health > 0 && !it.charmed,
			{
				if(it.move_nomonsters == MOVE_NOMONSTERS || it.move_nomonsters == MOVE_WORLDONLY)
					continue;
				potatomine_hitbox_touch(actor, it);
			});

			Send_Effect(EFFECT_EXPLOSION, actor.origin + actor.view_ofs, '0 0 0', 1);

			entity exp = spawn();
			setorigin(exp, actor.origin + '0 0 64');
			_setmodel(exp, "progs/s_spudow.spr");
			setsize(exp, '0 0 0', '0 0 0');
			set_movetype(exp, MOVETYPE_NONE);
			exp.velocity = '0 0 0';
			settouch(exp, func_null);
			exp.solid = SOLID_NOT;
			setthink(exp, s_donk1);
			exp.nextthink = time;

			actor.clientframe = TANIM_IDLE;
			_sound(actor, CH_WEAPON_SINGLE, "weapons/r_exp3.wav", 1, ATTN_NORM);

			T_Damage(actor, NULL, NULL, 10, DEATH_GENERIC.m_id);
			return;
		}

		actor.enemy = targ; // for kaboom boom
		actor.attack_finished = time + 1;
		actor.clientframe = TANIM_SHOOT;

		_sound(actor, CH_WEAPON_SINGLE, "turrets/potatomine_arm.wav", 1, ATTN_NORM);
	}
	else if(actor.enemy)
		actor.enemy = NULL; // no go
}
METHOD(CrazyDavePotatoMine, tr_setup, void(CrazyDavePotatoMine this, entity actor))
{
	actor.view_ofs = '0 0 4';

	actor.monster_attack = false;

	actor.solid = SOLID_TRIGGER;
}
#endif // SVQC
#ifdef CSQC
METHOD(CrazyDavePotatoMine, tr_drawselected, void(CrazyDavePotatoMine this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 4';

	Draw_Circle(org, myrange);
}
METHOD(CrazyDavePotatoMine, tr_setup, void(CrazyDavePotatoMine this, entity actor))
{
	actor.anim_idle = '1 1 0';
	actor.anim_shoot = '1 14 0';

	actor.solid = SOLID_TRIGGER;
}
#endif // CSQC
