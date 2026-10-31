#include "rocket_launcher.qh"

#ifdef SVQC
void W_FireRocket(entity this, .entity weaponentity)
{
	W_TakeAmmo(this, IT_ROCKETS, 1);
	
	_sound(this, CH_WEAPON_SINGLE, "weapons/sgun1.wav", 1, ATTN_NORM);

	this.punchangle_x = -2 * autocvar_sv_quake_recoil;

	Projectile ptype = PROJECTILE_ROCKET;
	vector org = W_Shotorg(this, weaponentity);
	vector dir = qc_aim_fromorg(this, org, ptype.m_speed);

	Projectile_Create(ptype, this, org, dir, WEP_ROCKET_LAUNCHER.m_id);
}

METHOD(RocketLauncher, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_rocket1(actor);
		wep_generic_rocket1(actor.(weaponentity));
		W_FireRocket(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.8);
	}
}
METHOD(RocketLauncher, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_rockets >= 1;
	return ammo_amount;
}
METHOD(RocketLauncher, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(RocketLauncher, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
