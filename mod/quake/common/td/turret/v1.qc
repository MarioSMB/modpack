#include "v1.qh"

// ============
//  LASER WALL
// ============

#ifdef SVQC
.float laserwall_dmgtime;
void laserwall_hitbox_touch(entity this, entity toucher)
{
	if(time < toucher.laserwall_dmgtime)
		return;
	if(time < toucher.invincible_finished)
		return;

	Turret tur = this.turretdef;
	toucher.laserwall_dmgtime = time + 0.25; // TODO?
	float damage = tur.tur_dmg * turret_getpower(this.tur_level, tur.tur_dmgscale);

	_sound(toucher, CH_SHOTS, "misc/spark.wav", 1, ATTN_NORM);

	vector targ_org = CENTER_OR_VIEWOFS(toucher);
	Send_Effect(EFFECT_V1_SLIDE, targ_org, normalize(targ_org - this.origin) * -96, 1);

	T_Damage(toucher, this, this, damage, DEATH_TRAP.m_id);

	// for hurting the wall
	this.enemy = toucher;
	this.cnt += 1;
}

METHOD(V1LaserWall, tr_precache, void(V1LaserWall thistur))
{
	precache_sound("misc/spark.wav");
}
METHOD(V1LaserWall, tr_think, void(V1LaserWall thistur, entity actor))
{
	vector emin = actor.absmin, emax = actor.absmax;
	vector extrasize = '1 1 1';
	emin -= extrasize;
	emax += extrasize;

	actor.cnt = 0; // number of targets hit

	FOREACH_ENTITY_BOX_ORDERED(emin, emax, it != actor && IS_MONSTER(it) && it.health > 0 && !it.charmed,
	{
		if (it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY)
			laserwall_hitbox_touch(actor, it);
	});

	if(actor.cnt > 0)
	{
		float damage = 2 * actor.cnt;
		T_Damage(actor, actor.enemy, actor.enemy, damage, DEATH_CRUSH.m_id);
	}
}
METHOD(V1LaserWall, tr_setup, void(V1LaserWall this, entity actor))
{
	actor.view_ofs = '0 0 16';

	actor.monster_attack = false;

	actor.solid = SOLID_TRIGGER;
}
#endif // SVQC
#ifdef CSQC
METHOD(V1LaserWall, tr_setup, void(V1LaserWall this, entity actor))
{
	actor.solid = SOLID_TRIGGER;
}
#endif // CSQC

// =======
//  ROBOT
// =======

#ifdef SVQC
METHOD(V1Robot, tr_precache, void(V1Robot thistur))
{
	precache_sound("weapons/spike2.wav");
}
METHOD(V1Robot, tr_think, void(V1Robot this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	if(actor.enemy)
	{
		vector myorg = actor.origin + actor.view_ofs;
		vector targ_org = (actor.enemy.absmin + actor.enemy.absmax) * 0.5;
		bool isinfront = turret_infront(actor, actor.enemy, actor.angles, maxpitch, maxrot);
		bool isvisible = visible(actor, actor.enemy);
		if(isvisible || isinfront)
			actor.search_time = time + 1;
		if(actor.enemy.health < 1 || actor.enemy.exptime != 0 || time > actor.search_time || vdist(myorg - targ_org, >, myrange * 1.5))
		{
			actor.enemy = NULL;
			return; // won't find a new target this frame
		}

		if(time >= actor.attack_finished && isinfront && isvisible)
		{
			actor.attack_finished = time + max(0.03, (0.5 / turret_getpower(actor.tur_level, 0.3)));
			float offset = (actor.cnt) ? 20 : -20;
			actor.cnt = (actor.cnt) ? 0 : 1;

			if(time >= actor.spamtime)
			{
				actor.spamtime = time + 0.1;
				_sound(actor, CH_WEAPON_SINGLE, "weapons/spike2.wav", 0.5, ATTN_NORM);
			}

			makevectors(actor.angles);
			vector org = myorg + v_right * offset;
			vector dir = normalize(targ_org - org);
			entity missile = launch_spike(actor, org, dir);
			missile.velocity = dir * 1000;
			missile.projectiledeathtype = DEATH_TRAP.m_id;
			missile.dmg = this.tur_dmg * turret_getpower(actor.tur_level, this.tur_dmgscale);

			CSQCProjectile(missile, true, PROJECTILE_BULLET, true);
		}
	}
	
	if(!actor.enemy && time >= actor.idle_finished)
	{
		actor.idle_finished = time + 0.5;
		actor.enemy = turret_findtarget(actor, maxpitch, maxrot, myrange);
	}
}
METHOD(V1Robot, tr_setup, void(V1Robot this, entity actor))
{
	actor.view_ofs = '0 0 52';
}
#endif // SVQC
#ifdef CSQC
METHOD(V1Robot, tr_drawselected, void(V1Robot this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 52';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);

	// TODO: cone?
	//Draw_CylindricLine(org, org + v_forward * myrange, 6, "particles/laserbeam", 0.25, -time * 3, '1 0.25 0', 1, DRAWFLAG_NORMAL, view_origin);
}
#endif // CSQC

// ======
//  RAIL
// ======

#ifdef SVQC
vector SniperLightningDamage(entity this, vector org, vector dir, float arange, float damage, int deathtype);

METHOD(V1Rail, tr_precache, void(V1Rail thistur))
{
	precache_sound("weapons/rail2.wav");
}
METHOD(V1Rail, tr_think, void(V1Rail this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	if(actor.enemy)
	{
		vector myorg = actor.origin + actor.view_ofs;
		vector targ_org = (actor.enemy.absmin + actor.enemy.absmax) * 0.5;
		bool isinfront = turret_infront(actor, actor.enemy, actor.angles, maxpitch, maxrot);
		bool isvisible = visible(actor, actor.enemy);
		if(isvisible || isinfront)
			actor.search_time = time + 1;
		if(actor.enemy.health < 1 || actor.enemy.exptime != 0 || time > actor.search_time || vdist(myorg - targ_org, >, myrange * 1.5))
		{
			actor.enemy = NULL;
			return; // won't find a new target this frame
		}

		if(time >= actor.attack_finished && isinfront && isvisible)
		{
			actor.attack_finished = time + max(0.03, (5 / turret_getpower(actor.tur_level, 0.5)));

			_sound(actor, CH_WEAPON_SINGLE, "weapons/rail2.wav", 0.5, ATTN_NORM);

			vector dir = normalize(targ_org - myorg);
			float damage = this.tur_dmg * turret_getpower(actor.tur_level, this.tur_dmgscale);

			vector endpos = SniperLightningDamage(actor, myorg, dir, myrange, damage, DEATH_TRAP.m_id);
			SendCSQCSniperLightning(myorg, endpos, 0);
		}
	}
	
	if(!actor.enemy && time >= actor.idle_finished)
	{
		actor.idle_finished = time + 0.5;
		actor.enemy = turret_findtarget(actor, maxpitch, maxrot, myrange);
	}
}
METHOD(V1Rail, tr_setup, void(V1Rail this, entity actor))
{
	actor.view_ofs = '0 0 38'; // for line of sight checks
}
#endif // SVQC
#ifdef CSQC
METHOD(V1Rail, tr_drawselected, void(V1Rail this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 38';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);
}
#endif // CSQC
