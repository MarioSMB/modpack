#include "shotgun.qh"

#ifdef SVQC
void W_FireShotgun(entity this, .entity weaponentity)
{
	_sound(this, CH_WEAPON_SINGLE, "weapons/guncock.wav", 1, ATTN_NORM);	

	this.punchangle_x = -2 * autocvar_sv_quake_recoil;

	W_TakeAmmo(this, IT_SHELLS, 1);
	vector dir = qc_aim(this, 2000);
	FireBullets(this, 6, 4, W_Shotorg(this, weaponentity), dir, '0.04 0.04 0', WEP_SHOTGUN.m_id);
}

METHOD(Shotgun, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		wep_generic_shot1(actor.(weaponentity));
		W_FireShotgun(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.5);
	}
}
METHOD(Shotgun, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_shells >= 1;
	return ammo_amount;
}
METHOD(Shotgun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Shotgun, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
