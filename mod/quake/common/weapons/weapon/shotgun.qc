#include "shotgun.qh"

#ifdef SVQC
void W_FireShotgun(entity this)
{
	_sound(this, CH_WEAPON_SINGLE, "weapons/guncock.wav", 1, ATTN_NORM);	

	this.punchangle_x = -2;

	this.ammo_shells = this.ammo_shells - 1;
	vector dir = qc_aim(this, 100000);
	FireBullets(this, 6, dir, '0.04 0.04 0', WEP_SHOTGUN.m_id);
}

METHOD(Shotgun, wr_think, void(entity thiswep, entity actor, int fire))
{
	if(fire & 1)
	if(thiswep.wr_checkammo1(thiswep, actor))
	{
		wep_generic_shot1(actor.weaponentity);
		W_FireShotgun(actor);
		actor.attack_finished = time + 0.5;
	}
}
METHOD(Shotgun, wr_checkammo1, bool(entity thiswep, entity actor))
{
	float ammo_amount = actor.ammo_shells >= 1;
	return ammo_amount;
}
METHOD(Shotgun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
