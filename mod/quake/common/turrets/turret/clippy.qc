#include "clippy.qh"

// =============
//  RECYCLE BIN
// =============

#ifdef SVQC
vector tuba_calc_arc(vector org, vector tgt, float ht); // saves some copy-pasta
vector recyclebin_calc_velocity(entity actor, vector org, vector targ_org)
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

METHOD(ClippyRecycleBin, tr_precache, void(ClippyRecycleBin thistur))
{
	precache_sound("turrets/recyclebin_fire.wav");
}
METHOD(ClippyRecycleBin, tr_attack, void(ClippyRecycleBin this, entity actor))
{
	_sound(actor, CH_WEAPON_SINGLE, "turrets/recyclebin_fire.wav", 1, ATTN_NORM);

	entity newmis = launch_spike(actor, actor.tur_shotorg, '0 0 1');
	newmis.projectiledeathtype = DEATH_TRAP.m_id;
	newmis.velocity = recyclebin_calc_velocity(actor, actor.tur_shotorg, actor.tur_aimpos);
	newmis.gravity = 1;
	newmis.dmg = actor.shot_dmg;
	set_movetype(newmis, MOVETYPE_TOSS);
	CSQCProjectile(newmis, true, PROJECTILE_RECYCLEBIN, true);
}
METHOD(ClippyRecycleBin, tr_setup, void(ClippyRecycleBin this, entity actor))
{
	actor.view_ofs = '0 0 12'; // for line of sight checks

	actor.target_select_flags = TFL_TARGETSELECT_MONSTERS | TFL_TARGETSELECT_RANGELIMITS | TFL_TARGETSELECT_ANGLELIMITS;
	actor.target_validate_flags = actor.target_select_flags;
}
#endif // SVQC
#ifdef CSQC
METHOD(ClippyRecycleBin, tr_drawselected, void(ClippyRecycleBin this, entity actor))
{
	float myrange = this.target_range * turret_getpower(actor.tur_level, 0.2);
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 12';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);

	// TODO: cone?
	//Draw_CylindricLine(org, org + v_forward * myrange, 6, "particles/laserbeam", 0.25, -time * 3, '1 0.25 0', 1, DRAWFLAG_NORMAL, view_origin);
}
#endif // CSQC
