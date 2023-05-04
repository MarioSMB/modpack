#include "shotgun.qh"

#ifdef SVQC
void W_FireShotgun(entity this)
{
	_sound(this, CH_WEAPON_SINGLE, "weapons/guncock.wav", 1, ATTN_NORM);	

	this.punchangle_x = -2;

	this.currentammo = this.ammo_shells = this.ammo_shells - 1;
	vector dir = qc_aim(this, 100000);
	FireBullets(this, 6, dir, '0.04 0.04 0');
}

METHOD(Shotgun, wr_think, void(entity thiswep, entity actor))
{
	player_shot1(actor);
	W_FireShotgun(actor);
	actor.attack_finished = time + RuneApplyHell(0.5, actor);
}
METHOD(Shotgun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
