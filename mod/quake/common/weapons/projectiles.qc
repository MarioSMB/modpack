#include "projectiles.qh"

#ifdef SVQC
.int bounced;
.int pierced;

.float dmg_radius;
.entity proj_hit;
.float proj_antispam;

.bool proj_homing;
.float proj_homecheck;

METHOD(Projectile, pr_explode, void(Projectile this, entity actor, entity directhitentity, bool is_touch))
{
	if(actor.dmg_radius > 0)
		T_RadiusDamage(actor, actor.owner, actor.dmg, actor.projectiledeathtype, directhitentity);

	Sound snd = SND_Null;
	if(this.m_sound_explode && (snd = this.m_sound_explode(actor)) != SND_Null)
		sound(actor, CH_SHOTS, snd, VOL_BASE, ATTEN_NORM);
	else if(this.m_sound_impact && is_touch && (snd = this.m_sound_impact(actor)) != SND_Null)
		sound(actor, CH_SHOTS, snd, VOL_BASE, ATTEN_NORM);

	vector org = (actor.dmg_radius > 0) ? actor.origin - 8 * normalize(actor.velocity) : actor.origin;
	//org = findbetterlocation(actor.origin, 8);

	if(this.m_effect_explode != EFFECT_Null)
		Send_Effect(this.m_effect_explode, org, '0 0 0', 1);
	else if(this.m_effect_impact != EFFECT_Null && is_touch)
		Send_Effect(this.m_effect_impact, org, '0 0 0', 1);
}

void Projectile_Explode(entity this, entity directhitentity, bool is_touch)
{
	Projectile ptype = this.csqcprojectile_type;

	if(ptype.pr_explode)
		ptype.pr_explode(ptype, this, directhitentity, is_touch);

	settouch(this, func_null);
	this.solid = SOLID_NOT;
	setthink(this, SUB_Remove);
	this.nextthink = time;
}

void Projectile_Explode_do(entity this)
{
	Projectile_Explode(this, NULL, false);
}

bool Projectile_Collide(entity this, entity toucher, bool is_touch)
{
	Projectile ptype = this.csqcprojectile_type;

	if(toucher && toucher.takedamage)
	{
		// assume we passed through this target
		if(time < toucher.proj_antispam)
			return true;
		toucher.proj_antispam = time + 0.1;
		if(this.dmg)
		{
			float damage = this.dmg;
			// TODO: damage resistance needs to be a bit more dynamic!
			Weapon death_weapon = DEATH_WEAPONOF(this.projectiledeathtype);
			if(death_weapon != WEP_Null && death_weapon.ammo_type)
				damage = Resist_Damage(toucher, death_weapon.ammo_type, damage);
			// resistance! try adding effects
			if(damage != this.dmg)
			{
				switch(death_weapon.ammo_type)
				{
					case IT_NAILS: Resist_Nails(toucher, this.origin); break;
					case IT_ROCKETS: Resist_Rockets(toucher, this.origin); break;
					case IT_SHELLS: Resist_Shells(toucher, this.origin, this.velocity, damage); break;
					case IT_CELLS: Resist_Lightning(toucher, this.origin); break;
				}
			}
			// TODO: damage effects system?
			if(toucher.solid != SOLID_BSP)
				spawn_touchblood(this, damage, toucher);
			T_Damage(toucher, this, this.owner, damage, this.projectiledeathtype);

			if(ptype.m_effect_pierce != EFFECT_Null)
				Send_Effect(ptype.m_effect_pierce, this.origin, normalize(this.velocity) * -(this.speed * 0.5), 1);

			Sound snd = SND_Null;
			if(ptype.m_sound_pierce && (snd = ptype.m_sound_pierce(this)) != SND_Null)
				sound(this, CH_SHOTS_SINGLE, snd, VOL_BASE, ATTEN_NORM);

			if(ptype.pr_collide)
				ptype.pr_collide(ptype, this, toucher, is_touch);
		}

		this.pierced += 1;
		if((ptype.m_piercecnt >= 0 && this.pierced > ptype.m_piercecnt) || toucher.solid == SOLID_BSP)
		{
			Projectile_Explode(this, toucher, is_touch);
			return false;
		}
	}
	else
	{
		if(ptype.m_effect_bounce != EFFECT_Null)
			Send_Effect(ptype.m_effect_bounce, this.origin, normalize(this.velocity) * (this.speed * 0.25), 1);

		Sound snd = SND_Null;
		if(ptype.m_sound_bounce && (snd = ptype.m_sound_bounce(this)) != SND_Null)
			spamsound(this, CH_SHOTS_SINGLE, snd, VOL_BASE, ATTEN_NORM);

		if(ptype.pr_bounce)
			ptype.pr_bounce(ptype, this, toucher, is_touch);

		this.bounced += 1;
		if(ptype.m_bouncecnt >= 0 && this.bounced > ptype.m_bouncecnt)
		{
			Projectile_Explode(this, NULL, is_touch);
			return false;
		}
	}
	return true;
}

void Projectile_Touch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.solid == SOLID_TRIGGER)
		return;

	if((trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT) || pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	// entity collisions are handled during tick for piercing
	// but buttons and such can still trigger a collision!
	if(toucher && toucher.solid != SOLID_BSP)
		{ /* do nothing */ }
	else
		Projectile_Collide(this, toucher, true);
}

void Projectile_Home(entity this)
{
	if(!this.enemy && time > this.proj_homecheck && this.home_range > 0)
	{
		this.enemy = W_PickNearbyTarget(this, this.owner, this.home_range, false, false);
		this.proj_homecheck = time + 0.1;
	}

	vector targ_org = (this.enemy.absmin + this.enemy.absmax) * 0.5;
	if(this.home_range_max > 0 && vdist(targ_org - this.origin, >, this.home_range_max))
		this.enemy = NULL;

	W_SeekOutEnemy(this, this.home_speed_decel, this.home_speed_accel, this.home_speed_max, this.home_turn_rate,
					this.home_smart, this.home_smart_mindist, this.home_smart_trace_min, this.home_smart_trace_max);
}

METHOD(Projectile, m_tick, void(Projectile this, entity actor))
{
	vector emin = actor.absmin, emax = actor.absmax;
	emin -= '1 1 1';
	emax += '1 1 1';

	if(actor.proj_homing)
		Projectile_Home(actor);

	if(!actor.csqcprojectile_clientanimate)
		UpdateCSQCProjectile(actor);

	FOREACH_ENTITY_BOX_ORDERED(emin, emax, it != actor && it != actor.owner && it.solid != SOLID_TRIGGER,
	{
		if(it.clipgroup && it.clipgroup == actor.clipgroup)
			continue;
		if (it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY)
		{
			if(!Projectile_Collide(actor, it, false))
				break;
		}
	});

	// NOTE: projectile may have been deleted at this point
}

void Projectile_Think(entity this)
{
	Projectile ptype = this.csqcprojectile_type;

	// lifetime check is done globally, we never want lingering projectiles!
	if(time >= this.lifetime)
	{
		settouch(this, func_null);
		setthink(this, Projectile_Explode_do);
		this.nextthink = time;
		this.solid = SOLID_NOT;
		return;
	}

	this.nextthink = time;

	if(ptype.m_tick)
		ptype.m_tick(ptype, this);
}

METHOD(Projectile, pr_setup, void(Projectile this, entity actor))
{
	// stuff?
}

// FIXME: Xonotic's progsdefs don't define this...
void(vector dir) _vectorvectors_hidden = #432;
entity Projectile_Create(Projectile this, entity actor, vector org, vector dir, int deathtype)
{
	int scount = this.m_count;
	float spread = this.m_spread;

	scount = max(1, scount); // never allow less than 1 projectile
	// if we're firing more than 1 shot, we need some spread!
	if(scount > 1 && spread <= 0 && !this.m_spread_pattern)
		spread = 0.05;

	vector forward, right, up;
	VECTOR_VECTORS(dir, forward, right, up);

	entity prev = NULL;
	entity proj = NULL;
	for(int j = 0; j < scount; ++j)
	{
		vector pdir = dir;
		if(this.m_spread_pattern)
		{
			vector spat = W_CalculateSpreadPattern(this.m_spread_pattern, this.m_spread_pattern_bias, j, scount);
			spat *= this.m_spread_pattern_scale;
			pdir = pdir + right * spat.y + up * spat.z;
			pdir = normalize(pdir);
		}

		pdir = W_CalculateSpread(pdir, spread, this.m_spread_style, false);

		proj = spawn();
		proj.classname = "projectile";
		proj.flags = FL_PROJECTILE;
		proj.owner = actor;
		proj.realowner = actor;
		proj.clipgroup = actor.clipgroup;
		proj.projectiledeathtype = deathtype;
		proj.speed = this.m_speed;
		proj.solid = SOLID_TRIGGER;
		proj.move_nomonsters = MOVE_WORLDONLY; // entity collisions are handled manually
		proj.dmg = this.dmg;
		proj.dmg_radius = this.dmg_radius;
		proj.gravity = this.m_gravity;
		proj.bouncefactor = this.m_bouncefactor;
		proj.bouncestop = this.m_bouncestop;
		setsize(proj, this.m_mins, this.m_maxs);
		setorigin(proj, org);
		settouch(proj, Projectile_Touch);
		setthink(proj, Projectile_Think);
		proj.nextthink = time;
		proj.lifetime = time + this.m_lifetime;
		proj.velocity = pdir * this.m_speed;
		proj.pos1 = org;
		proj.pos2 = pdir;
		proj.proj_homing = (this.spawnflags & PROJ_FLAG_HOMING);
		proj.home_range = this.home_range;
		proj.home_speed_decel = this.home_speed_decel;
		proj.home_speed_accel = this.home_speed_accel;
		proj.home_speed_max = this.home_speed_max;
		proj.home_turn_rate = this.home_turn_rate;
		proj.home_smart = this.home_smart;
		proj.home_smart_mindist = this.home_smart_mindist;
		proj.home_smart_trace_min = this.home_smart_trace_min;
		proj.home_smart_trace_max = this.home_smart_trace_max;

		if(this.spawnflags & PROJ_FLAG_NOCOLLISIONS)
			proj.dphitcontentsmask = DPCONTENTS_DONOTENTER;

		if(this.m_bouncecnt != 0)
			set_movetype(proj, MOVETYPE_BOUNCE);
		else if(this.m_gravity)
			set_movetype(proj, MOVETYPE_TOSS);
		else
			set_movetype(proj, MOVETYPE_FLY);

		// copied from CSQC projectile logic
		if (proj.gravity)
		{
			if (proj.move_movetype == MOVETYPE_FLY)
				set_movetype(proj, MOVETYPE_TOSS);
			if (proj.move_movetype == MOVETYPE_BOUNCEMISSILE)
				set_movetype(proj, MOVETYPE_BOUNCE);
		}
		else
		{
			if (proj.move_movetype == MOVETYPE_TOSS)
				set_movetype(proj, MOVETYPE_FLY);
			if (proj.move_movetype == MOVETYPE_BOUNCE)
				set_movetype(proj, MOVETYPE_BOUNCEMISSILE);
		}

		IL_PUSH(g_projectiles, proj);

		bool doanimate = !(this.spawnflags & PROJ_FLAG_NOANIMATE);
		if(proj.proj_homing)
			doanimate = false; // incompatible!

		CSQCProjectile(proj, doanimate, this, !(this.spawnflags & PROJ_FLAG_NOCULL));

		if(this.pr_setup)
			this.pr_setup(this, actor);

		// for references
		proj.chain = prev;
		prev = proj;
	}

	return proj;
}
#endif

#ifdef CSQC
METHOD(Projectile, pr_setup, void(Projectile this, entity actor))
{
	if(this.m_model != MDL_Null)
		setmodel(actor, this.m_model);

	if(this.m_traileffect != EFFECT_Null)
		actor.traileffect = this.m_traileffect.m_id;
	if(this.m_bouncecnt != 0)
	{
		settouch(actor, func_null);
		set_movetype(actor, MOVETYPE_BOUNCE);
	}
	if(this.m_gravity)
		actor.gravity = this.m_gravity;
	if(this.m_bouncefactor)
		actor.bouncefactor = this.m_bouncefactor;
	if(this.m_bouncestop)
		actor.bouncestop = this.m_bouncestop;
	if(this.m_mins != '0 0 0' || this.m_maxs != '0 0 0')
	{
		actor.mins = this.m_mins;
		actor.maxs = this.m_maxs;
	}
	if(this.m_avelocity != '0 0 0')
		actor.avelocity = this.m_avelocity;
	if(this.scale)
		actor.scale = this.scale;

	if(this.spawnflags & PROJ_FLAG_NOCOLLISIONS)
		actor.dphitcontentsmask = DPCONTENTS_DONOTENTER;
}

METHOD(Projectile, m_tick, void(Projectile this, entity actor))
{
	// stuff?
}
#endif
