#include "ranger.qh"

// ============
//  BARRICADE
// ===========

#ifdef SVQC
.float barricade_dmgtime;
void barricade_hitbox_touch(entity this, entity toucher)
{
	if(time < toucher.barricade_dmgtime)
		return;
	if(time < toucher.invincible_finished)
		return;

	Turret tur = this.turretdef;
	toucher.barricade_dmgtime = time + 0.5; // TODO?
	float damage = tur.tur_dmg * turret_getpower(this.tur_level, tur.tur_dmgscale);

	// also push enemy away
	if(!(toucher.monsterdef.spawnflags & MONSTER_TYPE_BOSS) && !(toucher.monsterdef.spawnflags & MON_FLAG_STATIONARY))
	{
		float pushforce = 100 / (vlen(toucher.maxs - toucher.mins) + 1);

		vector dir = normalize(toucher.origin - this.origin);
		toucher.velocity = dir * (200 * pushforce);
		toucher.velocity_z = (75 * pushforce);
	}

	_sound(toucher, CH_SHOTS, "enviro/physics/trcut.wav", 1, ATTN_NORM);

	T_Damage(toucher, this, this, damage, DEATH_TRAP.m_id);
}

METHOD(RangerBarricade, tr_think, void(RangerBarricade thistur, entity actor))
{
	vector emin = actor.absmin, emax = actor.absmax;
	vector extrasize = '16 16 16'; // give it a bit of spiked range
	emin -= extrasize;
	emax += extrasize;

	FOREACH_ENTITY_BOX_ORDERED(emin, emax, it != actor && IS_MONSTER(it) && it.health > 0 && !it.charmed,
	{
		if (it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY)
			barricade_hitbox_touch(actor, it);
	});
}
#endif // SVQC

// ========
//  NAILER
// ========

#ifdef SVQC
METHOD(RangerNailer, tr_precache, void(RangerNailer thistur))
{
	precache_sound("weapons/rocket1i.wav");
}
METHOD(RangerNailer, tr_think, void(RangerNailer this, entity actor))
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
			actor.attack_finished = time + max(0.03, (0.33 / turret_getpower(actor.tur_level, 0.3)));
			float offset = (actor.cnt) ? 4 : -4;
			actor.cnt = (actor.cnt) ? 0 : 1;

			if(time >= actor.spamtime)
			{
				actor.spamtime = time + 0.1;
				_sound(actor, CH_WEAPON_SINGLE, "weapons/rocket1i.wav", 0.5, ATTN_NORM);
			}

			makevectors(actor.angles);
			vector org = myorg + v_right * offset;
			vector dir = normalize(CENTER_OR_VIEWOFS(actor.enemy) - org);
			entity newmis = launch_spike(actor, org, dir);
			newmis.projectiledeathtype = DEATH_TRAP.m_id;
			newmis.velocity = dir * 1000;
			newmis.dmg = this.tur_dmg * turret_getpower(actor.tur_level, this.tur_dmgscale);
			CSQCProjectile(newmis, true, PROJECTILE_BULLET, true);
		}
	}
	
	if(!actor.enemy && time >= actor.idle_finished)
	{
		actor.idle_finished = time + 0.5;
		actor.enemy = turret_findtarget(actor, maxpitch, maxrot, myrange);
	}
}
METHOD(RangerNailer, tr_setup, void(RangerNailer this, entity actor))
{
	actor.view_ofs = '0 0 4';
}
#endif // SVQC
#ifdef CSQC
METHOD(RangerNailer, tr_drawselected, void(RangerNailer this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 4';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);

	// TODO: cone?
	//Draw_CylindricLine(org, org + v_forward * myrange, 6, "particles/laserbeam", 0.25, -time * 3, '1 0.25 0', 1, DRAWFLAG_NORMAL, view_origin);
}
#endif // CSQC

// ========
//  MORTAR
// ========

#ifdef SVQC
vector tuba_calc_arc(vector org, vector tgt, float ht); // saves some copy-pasta
vector mortar_calc_velocity(entity actor, vector org, vector targ_org)
{
	//vector oldvel = normalize(actor.enemy.origin - org) * 500 + v_up * 500;

	vector tpos1 = targ_org;
	vector v = org;

	traceline(v, v + '0 0 1' * 65535, MOVE_WORLDONLY, actor);
	float h1 = 0.75 * vlen(v - trace_endpos);

	traceline(v, tpos1 + '0 0 1' * 65535, MOVE_WORLDONLY, actor);
	float h2 = 0.75 * vlen(tpos1 - v);

	return tuba_calc_arc(v, tpos1, ((h1 < h2) ? h1 : h2));
}

METHOD(RangerMortar, tr_precache, void(RangerMortar thistur))
{
	precache_sound("weapons/grenade.wav");
}
METHOD(RangerMortar, tr_think, void(RangerMortar this, entity actor))
{
	// make sure it matches drawn values!
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
			actor.attack_finished = time + max(0.03, (1.7 / turret_getpower(actor.tur_level, 0.33)));

			_sound(actor, CH_WEAPON_SINGLE, "weapons/grenade.wav", 1, ATTN_NORM);

			vector org = myorg;
			entity newmis = launch_spike(actor, org, '0 0 1');
			newmis.projectiledeathtype = DEATH_TRAP.m_id;
			newmis.velocity = mortar_calc_velocity(actor, org, targ_org);
			newmis.gravity = 1;
			newmis.dmg = this.tur_dmg * turret_getpower(actor.tur_level, this.tur_dmgscale);
			set_movetype(newmis, MOVETYPE_TOSS);
			settouch(newmis, T_MissileTouch);
			CSQCProjectile(newmis, true, PROJECTILE_MORTAR, true);
		}
	}
	
	if(!actor.enemy && time >= actor.idle_finished)
	{
		actor.idle_finished = time + 0.5;
		actor.enemy = turret_findtarget(actor, maxpitch, maxrot, myrange);
	}
}
METHOD(RangerMortar, tr_setup, void(RangerMortar this, entity actor))
{
	actor.view_ofs = '0 0 8'; // for line of sight checks
}
#endif // SVQC
#ifdef CSQC
METHOD(RangerMortar, tr_drawselected, void(RangerMortar this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 8';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);

	// TODO: cone?
	//Draw_CylindricLine(org, org + v_forward * myrange, 6, "particles/laserbeam", 0.25, -time * 3, '1 0.25 0', 1, DRAWFLAG_NORMAL, view_origin);
}
#endif // CSQC

// =======
//  LASER
// =======

#ifdef SVQC
METHOD(RangerLaser, tr_precache, void(RangerLaser thistur))
{
	precache_sound("hipweap/laserg.wav");
}
METHOD(RangerLaser, tr_think, void(RangerLaser this, entity actor))
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
			actor.attack_finished = time + max(0.03, (1 / turret_getpower(actor.tur_level, 0.5)));

			_sound(actor, CH_WEAPON_SINGLE, "hipweap/laserg.wav", 1, ATTN_NORM);

			vector org;
			vector dir;
			float damage = this.tur_dmg * turret_getpower(actor.tur_level, this.tur_dmgscale);
			damage *= 0.5; // since we're in 2 parts
			entity newmis;
			// left eye
			org = myorg + v_right * 6;
			dir = targ_org - org;
			newmis = LaunchLaser(actor, org, dir);
			newmis.projectiledeathtype = DEATH_TRAP.m_id;
			newmis.dmg = damage;

			// right eye
			org = myorg + v_right * -6;
			dir = targ_org - org;
			newmis = LaunchLaser(actor, org, dir);
			newmis.projectiledeathtype = DEATH_TRAP.m_id;
			newmis.dmg = damage;
		}
	}
	
	if(!actor.enemy && time >= actor.idle_finished)
	{
		actor.idle_finished = time + 0.5;
		actor.enemy = turret_findtarget(actor, maxpitch, maxrot, myrange);
	}
}
METHOD(RangerLaser, tr_setup, void(RangerLaser this, entity actor))
{
	actor.view_ofs = '0 0 30'; // for line of sight checks
}
#endif // SVQC
#ifdef CSQC
METHOD(RangerLaser, tr_drawselected, void(RangerLaser this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 32';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);
}
#endif // CSQC
