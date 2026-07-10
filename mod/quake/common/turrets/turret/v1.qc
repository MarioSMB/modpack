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

	toucher.laserwall_dmgtime = time + 0.25; // TODO?
	float damage = this.shot_dmg;

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
METHOD(V1Robot, tr_attack, void(V1Robot this, entity actor))
{
	float offset = (actor.cnt) ? 20 : -20;
	actor.cnt = (actor.cnt) ? 0 : 1;

	if(time >= actor.spamtime)
	{
		actor.spamtime = time + 0.1;
		_sound(actor, CH_WEAPON_SINGLE, "weapons/spike2.wav", 0.5, ATTN_NORM);
	}

	makevectors(actor.tur_shotdir_updated);
	vector org = actor.tur_shotorg + v_right * offset;
	entity missile = launch_spike(actor, org, actor.tur_shotdir_updated);
	missile.velocity = actor.tur_shotdir_updated * 1000;
	missile.projectiledeathtype = DEATH_TRAP.m_id;
	missile.dmg = actor.shot_dmg;

	CSQCProjectile(missile, true, PROJECTILE_BULLET, true);
}
METHOD(V1Robot, tr_setup, void(V1Robot this, entity actor))
{
	actor.view_ofs = '0 0 52';
	actor.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
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
METHOD(V1Rail, tr_attack, void(V1Rail this, entity actor))
{
	_sound(actor, CH_WEAPON_SINGLE, "weapons/rail2.wav", 0.5, ATTN_NORM);

	float damage = actor.shot_dmg;
	vector endpos = SniperLightningDamage(actor, actor.tur_shotorg, actor.tur_shotdir_updated, actor.target_range, damage, DEATH_TRAP.m_id);
	SendCSQCSniperLightning(actor.tur_shotorg, endpos, 0);
}
METHOD(V1Rail, tr_setup, void(V1Rail this, entity actor))
{
	actor.view_ofs = '0 0 38'; // for line of sight checks

	actor.damage_flags |= TFL_DMG_HEADSHAKE;
	actor.aim_flags = TFL_AIM_SIMPLE;
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
