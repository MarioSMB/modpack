#include "super_shotgun.qh"

#ifdef SVQC
void W_FireSuperShotgun(entity this, .entity weaponentity)
{
	if(this.ammo_shells == 1)
	{
		W_FireShotgun(this, weaponentity);
		return;
	}
		
	_sound(this ,CH_WEAPON_SINGLE, "weapons/shotgn2.wav", 1, ATTN_NORM);	

	this.punchangle_x = -4;

	W_TakeAmmo(this, ammo_shells, 2);
	vector dir = qc_aim(this, 100000);
	FireBullets(this, 14, W_Shotorg(this, weaponentity), dir, '0.14 0.08 0', WEP_SUPER_SHOTGUN.m_id);
}

METHOD(SuperShotgun, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		wep_generic_shot1(actor.(weaponentity));
		W_FireSuperShotgun(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.7);
	}
}
METHOD(SuperShotgun, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_shells >= 2;
	return ammo_amount;
}
METHOD(SuperShotgun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(SuperShotgun, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
