#include "doom.qh"

// ==================
//  CONCRETE BARRIER
// ==================

#ifdef SVQC
METHOD(DoomConcreteBarrier, tr_setup, void(DoomConcreteBarrier this, entity actor))
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
#endif

// =================
//  AUTO MACHINEGUN
// =================

#ifdef SVQC
METHOD(DoomAutoMachineGun, tr_precache, void(DoomAutoMachineGun thistur))
{
	precache_sound("weapons/spike2.wav");
}
METHOD(DoomAutoMachineGun, tr_attack, void(DoomAutoMachineGun this, entity actor))
{
	if(time >= actor.spamtime)
	{
		actor.spamtime = time + 0.1;
		_sound(actor, CH_WEAPON_SINGLE, "weapons/spike2.wav", 0.5, ATTN_NORM);
	}

	float damage = actor.shot_dmg;
	int shotcount = 4;

	damage /= shotcount;
	for(int j = 0; j < shotcount; ++j)
	{
		float var_speed = crandom() * 10 + 800;
		vector spread_dir = normalize(actor.tur_shotdir_updated + randomvec() * actor.shot_spread);
		entity missile = launch_spike(actor, actor.tur_shotorg, spread_dir);
		missile.classname = "bullet"; // hack
		missile.velocity = spread_dir * var_speed;
		missile.projectiledeathtype = DEATH_TRAP.m_id;
		missile.dmg = damage;

		CSQCProjectile(missile, true, PROJECTILE_BULLET, true);
	}
}
METHOD(DoomAutoMachineGun, tr_setup, void(DoomAutoMachineGun this, entity actor))
{
	actor.view_ofs = '0 0 27';

	actor.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
}
#endif // SVQC
#ifdef CSQC
METHOD(DoomAutoMachineGun, tr_drawselected, void(DoomAutoMachineGun this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 27';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);

	// TODO: cone?
	//Draw_CylindricLine(org, org + v_forward * myrange, 6, "particles/laserbeam", 0.25, -time * 3, '1 0.25 0', 1, DRAWFLAG_NORMAL, view_origin);
}
#endif // CSQC

// ========
//  PHASER
// ========

#ifdef SVQC
METHOD(DoomPhaser, tr_precache, void(DoomPhaser thistur))
{
	precache_sound("hipweap/laserg.wav");
}
METHOD(DoomPhaser, tr_attack, void(DoomPhaser this, entity actor))
{
	_sound(actor, CH_WEAPON_SINGLE, "hipweap/laserg.wav", 0.5, ATTN_NORM);

	makevectors(actor.tur_shotdir_updated);

	int shots = 3;
	float spread = 0.08;
	float damage = actor.shot_dmg;
	damage /= shots;
	for(int counter = 0; counter < shots; ++counter)
	{
		vector dir = actor.tur_shotdir_updated + (((counter + 0.5) / shots) * 2 - 1) * v_right * spread;
		entity newmis = LaunchLaser(actor, actor.tur_shotorg, dir);
		newmis.velocity = dir * 600;
		newmis.projectiledeathtype = DEATH_TRAP.m_id;
		newmis.dmg = damage;
	}
}
METHOD(DoomPhaser, tr_setup, void(DoomPhaser this, entity actor))
{
	actor.view_ofs = '0 0 32'; // for line of sight checks
	actor.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
}
#endif // SVQC
#ifdef CSQC
METHOD(DoomPhaser, tr_drawselected, void(DoomPhaser this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 32';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);
}
#endif // CSQC

// ========
//  COIL
// ========

#ifdef SVQC
bool coil_firecheck(entity this)
{
	if (time < this.attack2_finished)
		return false;
	return turret_firecheck(this);
}

METHOD(DoomCoil, tr_precache, void(DoomCoil thistur))
{
	precache_sound("weapons/lhit.wav");
}
METHOD(DoomCoil, tr_attack, void(DoomCoil this, entity actor))
{
	actor.attack2_finished = time + 0.2; // hardcoded delay (lightning zappy)

	if(actor.spamtime < time)
	{
		_sound(actor, CH_WEAPON_SINGLE, "weapons/lhit.wav", 0.5, ATTN_NORM);
		actor.spamtime = time + 0.6;
	}

	// TODO: water check? explode turret!
	float damage = actor.shot_dmg;

	traceline(actor.tur_shotorg, actor.tur_aimpos, MOVE_NORMAL, actor);

	SendCSQCLightningBeam(actor.tur_shotorg, trace_endpos);
	LightningDamage(actor.tur_shotorg, trace_endpos, actor, damage, DEATH_TRAP.m_id);
}
METHOD(DoomCoil, tr_setup, void(DoomCoil this, entity actor))
{
	actor.view_ofs = '0 0 20'; // for line of sight checks
	actor.turret_firecheckfunc = coil_firecheck;
	actor.aim_flags = TFL_AIM_SIMPLE;
}
#endif // SVQC
#ifdef CSQC
METHOD(DoomCoil, tr_drawselected, void(DoomCoil this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 20';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);
}
#endif // CSQC
