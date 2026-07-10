#include "keyleth.qh"

// =========
//  SWARMER
// =========

#ifdef SVQC
void SwarmHome(entity this)
{
	if(!this.enemy || this.enemy.health < 1)
	{
		RandomSelection_Init();
		float myrange = (this.cnt) ? this.cnt : 256;
		FOREACH_ENTITY_RADIUS(this.origin, myrange, it.takedamage && IS_MONSTER(it) && it.health > 0,
		{
			RandomSelection_AddEnt(it, 1, 1);
		});
		this.enemy = RandomSelection_chosen_ent;
	}

	vector vtemp = (this.enemy) ? CENTER_OR_VIEWOFS(this.enemy) : this.origin;
	if(time > this.count)
	{
		stopsound(this, CH_SHOTS_SINGLE);
		delete(this);
		return;
	}
	if(time >= this.attack_finished)
	{
		float damage = (this.dmg) ? this.dmg : 15;
		FOREACH_ENTITY_RADIUS(this.origin, 16, it.takedamage && IS_MONSTER(it) && it.health > 0,
		{
			if(it.monsterdef.spawnflags & MONSTER_TYPE_BOSS)
				continue;
			T_Damage(it, this, this.owner, damage, DEATH_TRAP.m_id);
		});

		this.attack_finished = time + 0.5;
	}

	vector dir = normalize(vtemp - this.origin);
	this.velocity = dir * 250;
	this.nextthink = time;
	UpdateCSQCProjectile(this);
}

void Swarm_Launch(entity this, vector org, entity targ)
{
	entity missile = spawn();
	missile.flags = FL_PROJECTILE;
	missile.classname = "swarm";
	missile.owner = this;
	missile.projectiledeathtype = DEATH_TRAP.m_id;
	missile.clipgroup = this.clipgroup;

	missile.solid = SOLID_TRIGGER;
	set_movetype(missile, MOVETYPE_FLYMISSILE);

	setsize(missile, '0 0 0', '0 0 0');		

	setorigin(missile, org);
	missile.velocity = this.tur_shotdir_updated * 400;
	missile.nextthink = time;
	missile.count = time + 3.6;
	setthink(missile, SwarmHome);
	missile.enemy = targ;
	missile.dmg = this.shot_dmg;
	missile.cnt = 256 * turret_getpower(this.tur_level, 0.2);

	IL_PUSH(g_projectiles, missile);

	CSQCProjectile(missile, false, PROJECTILE_SWARM, true);
}

METHOD(KeylethSwarmer, tr_attack, void(KeylethSwarmer this, entity actor))
{
	setanim(actor, actor.anim_shoot, true, true, true);
	actor.anim_start_time = actor.animstate_starttime;
	actor.SendFlags |= TNSF_ANIM; // assume it updated anyway

	vector org = CENTER_OR_VIEWOFS(actor) + '0 0 8';
	Swarm_Launch(actor, org, actor.enemy);
}
METHOD(KeylethSwarmer, tr_think, void(KeylethSwarmer this, entity actor))
{
	if(actor && time >= actor.animstate_endtime)
	{
		int oldframe = actor.frame;
		setanim(actor, actor.anim_idle, true, false, false);
		if(actor.frame != oldframe)
		{
			actor.anim_start_time = actor.animstate_starttime;
			actor.SendFlags |= TNSF_ANIM;
		}
	}
}
METHOD(KeylethSwarmer, tr_setup, void(KeylethSwarmer this, entity actor))
{
	actor.view_ofs = '0 0 8'; // for line of sight checks

	vector none = '0 0 0';
	actor.anim_idle = animfixfps(actor, '0 1 1', none);
	actor.anim_shoot = animfixfps(actor, '1 1 1', none);
}
#endif // SVQC
#ifdef CSQC
METHOD(KeylethSwarmer, tr_drawselected, void(KeylethSwarmer this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	vector org = actor.origin + ((actor.mins + actor.maxs) * 0.5) + '0 0 8';
	makevectors(actor.angles);

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);
}
#endif // CSQC

// ======
//  FROG
// ======

#ifdef SVQC
void frog_spit_touch(entity this, entity toucher)
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

	// slow all enemies near the impact site
	FOREACH_ENTITY_RADIUS(this.origin, 16, it.takedamage && IS_MONSTER(it) && it.health > 0,
	{
		float efftime = 3;
		float curtime = StatusEffects_gettime(STATUSEFFECT_Slowness, it);
		if((time + efftime) > curtime)
			StatusEffects_apply(STATUSEFFECT_Slowness, it, time + efftime, 0);
	});

	//te_wizspike(this.origin);
	//te_explosion2(this.origin, 55, 5);
	Send_Effect(EFFECT_TE_POISONBIG, this.origin, '0 0 0', 1);
	_sound(this, CH_SHOTS, "weapons/grape_impact.wav", 1, ATTN_NORM);

	delete(this);
}

METHOD(KeylethFrog, tr_precache, void(KeylethFrog thistur))
{
	precache_sound("turrets/frog_attack1.wav");
	precache_sound("turrets/frog_attack2.wav");
	precache_sound("weapons/grape_impact.wav");
}
METHOD(KeylethFrog, tr_attack, void(KeylethFrog this, entity actor))
{
	setanim(actor, actor.anim_shoot, true, true, true);
	actor.anim_start_time = actor.animstate_starttime;
	actor.SendFlags |= TNSF_ANIM; // assume it updated anyway

	if(random() > 0.5)
		_sound(actor, CH_WEAPON_SINGLE, "turrets/frog_attack1.wav", 1, ATTN_NORM);
	else
		_sound(actor, CH_WEAPON_SINGLE, "turrets/frog_attack2.wav", 1, ATTN_NORM);

	entity newmis = launch_spike(actor, actor.tur_shotorg, actor.tur_shotdir_updated);
	newmis.projectiledeathtype = DEATH_TRAP.m_id;
	newmis.velocity = actor.tur_shotdir_updated * 600;
	//newmis.dmg = 16 * turret_getpower(actor.tur_level, 0.15);
	settouch(newmis, frog_spit_touch);
	CSQCProjectile(newmis, true, PROJECTILE_FROG_SPIT, true);
}
METHOD(KeylethFrog, tr_think, void(KeylethFrog this, entity actor))
{
	if(actor && time >= actor.animstate_endtime)
	{
		int oldframe = actor.frame;
		setanim(actor, actor.anim_idle, true, false, false);
		if(actor.frame != oldframe)
		{
			actor.anim_start_time = actor.animstate_starttime;
			actor.SendFlags |= TNSF_ANIM;
		}
	}
}
METHOD(KeylethFrog, tr_setup, void(KeylethFrog this, entity actor))
{
	actor.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;

	actor.view_ofs = '0 0 4'; // for line of sight checks

	vector none = '0 0 0';
	actor.anim_idle = animfixfps(actor, '0 1 1', none);
	actor.anim_shoot = animfixfps(actor, '1 1 1', none);
}
#endif // SVQC
#ifdef CSQC
METHOD(KeylethFrog, tr_drawselected, void(KeylethFrog this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin;

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);
}
#endif // CSQC

// ==========
//  FLY TRAP
// ==========

#ifdef SVQC
bool flytrap_target_infront(entity this, entity targ, vector sangle, float maxpitch, float maxrot)
{
	vector org = this.origin + this.view_ofs;
	vector targ_org = (targ.absmin + targ.absmax) * 0.5;
	vector tvt_tadv = shortangle_vxy(angleofs3(org, sangle, targ_org), sangle);
	if(maxpitch > 0 && fabs(tvt_tadv.x) > maxpitch)
		return false;
	if(maxrot > 0 && fabs(tvt_tadv.y) > maxrot)
		return false;
	return true;
}

METHOD(KeylethFlyTrap, tr_precache, void(KeylethFlyTrap thistur))
{
	precache_sound("turrets/flytrap_spit1.wav");
	precache_sound("turrets/flytrap_spit2.wav");
}
METHOD(KeylethFlyTrap, tr_think, void(KeylethFlyTrap this, entity actor))
{
	float myrange = actor.target_range;
	float maxpitch = actor.aim_maxpitch;
	float maxrot = actor.aim_maxrot;
	vector org = actor.origin + actor.view_ofs;

	// copy of the parry code
	entity targ = NULL;
	float bestdist = 0;
	FOREACH_ENTITY_RADIUS(org, myrange, (it.flags & FL_PROJECTILE) && time > it.parry_time && time > it.parry_cooldown && IS_MONSTER(it.owner),
	{
		if(it.clipgroup == actor.clipgroup || it.velocity == '0 0 0')
			continue;
		if(!flytrap_target_infront(actor, it, actor.angles, maxpitch, maxrot))
			continue;

		float mydist = vlen2(it.origin - org);
		if(!targ || mydist <= bestdist)
		{
			targ = it;
			bestdist = mydist;
		}
	});

	if(targ)
	{
		setanim(actor, actor.anim_shoot, true, true, true);
		actor.anim_start_time = actor.animstate_starttime;
		actor.SendFlags |= TNSF_ANIM; // assume it updated anyway
		actor.attack_finished = time + 0.4; // animation duration

		entity oldown = targ.owner;
		targ.owner = actor;
		targ.realowner = actor;
		targ.clipgroup = actor.clipgroup;
		targ.enemy = oldown;
		targ.parry_time = time; // hack to make parry code trigger on target
		//if(autocvar_sv_quake_reflectshots)
			targ.velocity *= -1;
		//else
			//targ.velocity = v_forward * vlen(targ.velocity);
		targ.angles = vectoangles(targ.velocity);

		targ.projectiledeathtype = DEATH_TRAP.m_id;

		UpdateCSQCProjectile(targ);

		if(time > actor.spamtime)
		{
			actor.spamtime = time + 0.1;
			if(random() > 0.5)
				_sound(actor, CH_WEAPON_SINGLE, "turrets/flytrap_spit1.wav", 1, ATTN_NORM);
			else
				_sound(actor, CH_WEAPON_SINGLE, "turrets/flytrap_spit2.wav", 1, ATTN_NORM);
		}

		// we also take a small amount of damage from the projectile
		float damage = (targ.dmg) ? targ.dmg * 0.5 : 5;
		damage = min(damage, 5); // cap it to prevent instant break!
		T_Damage(actor, targ, oldown, damage, DEATH_TRAP.m_id);
	}

	if(actor && time >= actor.animstate_endtime)
	{
		int oldframe = actor.frame;
		setanim(actor, actor.anim_idle, true, false, false);
		if(actor.frame != oldframe)
		{
			actor.anim_start_time = actor.animstate_starttime;
			actor.SendFlags |= TNSF_ANIM;
		}
	}
}
METHOD(KeylethFlyTrap, tr_setup, void(KeylethFlyTrap this, entity actor))
{
	actor.monster_attack = false;

	actor.solid = SOLID_TRIGGER;

	actor.view_ofs = '0 0 24';

	vector none = '0 0 0';
	actor.anim_idle = animfixfps(actor, '0 1 1', none);
	actor.anim_shoot = animfixfps(actor, '1 1 1', none);

	// does nothing on its own
	actor.damage_flags = TFL_DMG_YES;
	actor.aim_flags = TFL_AIM_NO;
	actor.track_flags = TFL_TRACK_NO;
	actor.firecheck_flags = TFL_FIRECHECK_NO;
	actor.shoot_flags = TFL_SHOOT_NO;
	actor.target_select_flags = TFL_TARGETSELECT_NO;
	actor.target_validate_flags = actor.target_select_flags;
}
#endif // SVQC
#ifdef CSQC
METHOD(KeylethFlyTrap, tr_drawselected, void(KeylethFlyTrap this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 24';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);
}
METHOD(KeylethFlyTrap, tr_setup, void(KeylethFlyTrap this, entity actor))
{
	actor.solid = SOLID_TRIGGER;
}
#endif // CSQC
