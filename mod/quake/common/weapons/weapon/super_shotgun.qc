#include "super_shotgun.qh"

#ifdef SVQC
void W_FireSuperShotgun(entity this)
{
	if(this.ammo_shells == 1)
	{
		W_FireShotgun(this);
		return;
	}
		
	_sound(this ,CH_WEAPON_SINGLE, "weapons/shotgn2.wav", 1, ATTN_NORM);	

	this.punchangle_x = -4;

	this.ammo_shells = this.ammo_shells - 2;
	vector dir = qc_aim(this, 100000);
	FireBullets(this, 14, dir, '0.14 0.08 0', WEP_SUPER_SHOTGUN.m_id);
}

METHOD(SuperShotgun, wr_think, void(entity thiswep, entity actor, int fire))
{
	if(fire & 1)
	if(thiswep.wr_checkammo1(thiswep, actor))
	{
		player_shot1(actor);
		W_FireSuperShotgun(actor);
		actor.attack_finished = time + 0.7;
	}
}
METHOD(SuperShotgun, wr_checkammo1, bool(entity thiswep, entity actor))
{
	float ammo_amount = actor.ammo_shells >= 2;
	return ammo_amount;
}
METHOD(SuperShotgun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
