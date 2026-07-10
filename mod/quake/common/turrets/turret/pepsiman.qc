#include "pepsiman.qh"

// =================
//  VENDING MACHINE
// =================

#ifdef SVQC
entity can_launch(entity this, vector org, vector dir);

METHOD(PepsimanVendingMachine, tr_precache, void(PepsimanVendingMachine this))
{
	precache_sound("player_pepsiman/can_roll.wav");
}
METHOD(PepsimanVendingMachine, tr_attack, void(PepsimanVendingMachine this, entity actor))
{
	entity can = can_launch(actor, actor.tur_shotorg, actor.tur_shotdir_updated);
	can.cnt = 24; // rough bounding box for cheaper math, update if hitbox is changed!
	setsize(can, '-12 -12 0', '12 12 12');
	can.dmg = actor.shot_dmg;

	CSQCProjectile(can, true, PROJECTILE_CAN_SMALL, true);

	sound7(can, CH_SHOTS_SINGLE, "player_pepsiman/can_roll.wav", 1, ATTN_NORM, 200, 0);
}
METHOD(PepsimanVendingMachine, tr_setup, void(PepsimanVendingMachine this, entity actor))
{
	actor.view_ofs = '0 0 6';

	actor.track_flags = TFL_TRACK_ROTATE; // no pitching!
	actor.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
}
#endif // SVQC
#ifdef CSQC
METHOD(PepsimanVendingMachine, tr_drawselected, void(PepsimanVendingMachine this, entity actor))
{
	float myrange = this.target_range;
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + '0 0 24';

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);

	// TODO: cone?
	//Draw_CylindricLine(org, org + v_forward * myrange, 6, "particles/laserbeam", 0.25, -time * 3, '1 0.25 0', 1, DRAWFLAG_NORMAL, view_origin);
}
#endif // CSQC
