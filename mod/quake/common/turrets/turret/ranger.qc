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

	toucher.barricade_dmgtime = time + 0.5; // TODO?
	float damage = this.shot_dmg;

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
METHOD(RangerBarricade, tr_setup, void(RangerBarricade this, entity actor))
{
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

// ========
//  NAILER
// ========

#ifdef SVQC
METHOD(RangerNailer, tr_precache, void(RangerNailer this))
{
	precache_sound("weapons/rocket1i.wav");
}
METHOD(RangerNailer, tr_attack, void(RangerNailer this, entity actor))
{
	if(time >= actor.spamtime)
	{
		actor.spamtime = time + 0.1;
		_sound(actor, CH_WEAPON_SINGLE, "weapons/rocket1i.wav", 0.5, ATTN_NORM);
	}

	entity newmis = launch_spike(actor, actor.tur_shotorg, actor.tur_shotdir_updated);
	newmis.projectiledeathtype = DEATH_TRAP.m_id;
	newmis.velocity = normalize(actor.tur_shotdir_updated + randomvec() * actor.shot_spread) * actor.shot_speed;
	newmis.dmg = actor.shot_dmg;
	CSQCProjectile(newmis, true, PROJECTILE_BULLET, true);

	actor.tur_head.frame = (actor.tur_head.frame) ? 0 : 1;
}
METHOD(RangerNailer, tr_setup, void(RangerNailer this, entity actor))
{
	actor.damage_flags |= TFL_DMG_HEADSHAKE;
	actor.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
}
#endif // SVQC
#ifdef CSQC
METHOD(RangerNailer, tr_drawselected, void(RangerNailer this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	vector org = gettaginfo(actor.tur_head, gettagindex(actor.tur_head, "tag_fire"));

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
	precache_sound("weapons/r_exp3.wav");
}
METHOD(RangerMortar, tr_attack, void(RangerMortar this, entity actor))
{
	_sound(actor, CH_WEAPON_SINGLE, "weapons/grenade.wav", 1, ATTN_NORM);

	entity newmis = launch_spike(actor, actor.tur_shotorg, '0 0 1');
	newmis.projectiledeathtype = DEATH_TRAP.m_id;
	newmis.velocity = mortar_calc_velocity(actor, actor.tur_shotorg, actor.tur_aimpos);
	newmis.gravity = 1;
	newmis.dmg = actor.shot_dmg;
	newmis.noise = "weapons/r_exp3.wav";
	set_movetype(newmis, MOVETYPE_TOSS);
	settouch(newmis, T_MissileTouch);
	CSQCProjectile(newmis, true, PROJECTILE_MORTAR, true);
}
METHOD(RangerMortar, tr_setup, void(RangerMortar this, entity actor))
{
	actor.track_flags = TFL_TRACK_ROTATE; // no pitching!
	actor.target_select_flags = TFL_TARGETSELECT_MONSTERS | TFL_TARGETSELECT_RANGELIMITS | TFL_TARGETSELECT_ANGLELIMITS;
	actor.target_validate_flags = actor.target_select_flags;
	//actor.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
}
#endif // SVQC
#ifdef CSQC
METHOD(RangerMortar, tr_drawselected, void(RangerMortar this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	vector org = gettaginfo(actor.tur_head, gettagindex(actor.tur_head, "tag_fire"));

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
METHOD(RangerLaser, tr_attack, void(RangerLaser this, entity actor))
{
	_sound(actor, CH_WEAPON_SINGLE, "hipweap/laserg.wav", 1, ATTN_NORM);

	// FIXME? using the v_ angles from the tag are skewed
	makevectors(actor.tur_shotdir_updated);

	vector org;
	vector dir;
	float damage = actor.shot_dmg;
	damage *= 0.5; // since we're in 2 parts
	entity newmis;
	// left eye
	org = actor.tur_shotorg + v_right * 12;
	dir = normalize(actor.tur_shotdir_updated + randomvec() * actor.shot_spread);
	newmis = LaunchLaser(actor, org, dir);
	newmis.projectiledeathtype = DEATH_TRAP.m_id;
	newmis.dmg = damage;

	// right eye
	org = actor.tur_shotorg + v_right * -12;
	dir = normalize(actor.tur_shotdir_updated + randomvec() * actor.shot_spread);
	newmis = LaunchLaser(actor, org, dir);
	newmis.projectiledeathtype = DEATH_TRAP.m_id;
	newmis.dmg = damage;
}
METHOD(RangerLaser, tr_setup, void(RangerLaser this, entity actor))
{
	actor.damage_flags |= TFL_DMG_HEADSHAKE;
	actor.target_select_flags = TFL_TARGETSELECT_MONSTERS | TFL_TARGETSELECT_RANGELIMITS | TFL_TARGETSELECT_ANGLELIMITS;
	actor.target_validate_flags = actor.target_select_flags;
	actor.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
}
#endif // SVQC
#ifdef CSQC
METHOD(RangerLaser, tr_drawselected, void(RangerLaser this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	vector org = gettaginfo(actor.tur_head, gettagindex(actor.tur_head, "tag_fire"));

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);
}
#endif // CSQC
