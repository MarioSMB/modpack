#include "multi_rocket.qh"

#ifdef SVQC
void MultiRocketLaunch(entity this, vector org, float offset, float frameNum, .entity weaponentity)
{
	vector aimangle = this.v_angle;
	aimangle_y = aimangle_y + (offset * 0.66);
	makevectors(aimangle);

	Projectile ptype = PROJECTILE_MULTI_ROCKET;
	vector dir = qc_aim_fromorg(this, org, ptype.m_speed);

	Projectile_Create(ptype, this, org, dir, WEP_MULTI_ROCKET.m_id);
}

void W_FireMultiRocket(entity this, .entity weaponentity)
{
	W_TakeAmmo(this, IT_MULTI_ROCKETS, 1);
	
	_sound(this, CH_WEAPON_SINGLE, "weapons/sgun1.wav", 1, ATTN_NORM);

	vector org = W_Shotorg(this, weaponentity);
	this.punchangle_x = -2 * autocvar_sv_quake_recoil;
	
	MultiRocketLaunch(this, org, -10, 2, weaponentity);
	MultiRocketLaunch(this, org, -5, 3, weaponentity);
	MultiRocketLaunch(this, org, 5, 0, weaponentity);
	MultiRocketLaunch(this, org, 10, 1, weaponentity);
}

METHOD(MultiRocketLauncher, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_rocket1(actor);
		wep_generic_rocket1(actor.(weaponentity));
		W_FireMultiRocket(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.8);
	}
}
METHOD(MultiRocketLauncher, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_multi_rockets >= 1;
	return ammo_amount;
}
METHOD(MultiRocketLauncher, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(MultiRocketLauncher, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
