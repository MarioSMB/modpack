#include "nailgun.qh"

#ifdef SVQC
void player_nail1(entity this)
{
	set_animofs(this, anim_player_nailatt1, 1, player_nail2);

	this.effects |= EF_MUZZLEFLASH;

	if(!this.button0)
		{player_run(this);return;}
	this.weaponentity.m_frame += 1;
	if(this.weaponentity.m_frame >= 9)
		this.weaponentity.m_frame = 1;
	SuperDamageSound(this);
	W_FireSpikes(this, 3);
	this.attack_finished = time + 0.2;
}
void player_nail2(entity this)
{
	set_animofs(this, anim_player_nailatt1, 2, player_nail1);

	this.effects |= EF_MUZZLEFLASH;

	if(!this.button0)
		{player_run(this);return;}
	this.weaponentity.m_frame += 1;
	if(this.weaponentity.m_frame >= 9)
		this.weaponentity.m_frame = 1;
	SuperDamageSound(this);
	W_FireSpikes(this, -3);
	this.attack_finished = time + 0.2;
}

void W_FireSpikes(entity this, float ox)
{
	makevectors(this.v_angle);

	if(this.ammo_nails < 1)
	{
		W_SwitchWeapon(this, w_getbestweapon(this));
		return;
	}

	if(this.silencer)
		_sound(this, CH_WEAPON_SINGLE, "weapons/rocketli.wav", 0.2, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "weapons/rocket1i.wav", 1, ATTN_NORM);
	this.attack_finished = time + 0.2;
	this.ammo_nails = this.ammo_nails - 1;
	vector dir = qc_aim(this, 1000);
	// NOTE: position fix by Seven and Sajt applied here
	entity missile = launch_spike(this, this.origin + this.view_ofs + v_up * -8 + v_right * ox, dir);
	missile.projectiledeathtype = WEP_NAILGUN.m_id;

	this.punchangle_x = -2;
}

METHOD(Nailgun, wr_think, void(entity thiswep, entity actor))
{
	player_nail1(actor);
}
METHOD(Nailgun, wr_checkammo1, bool(entity thiswep, entity actor))
{
	float ammo_amount = actor.ammo_nails >= 1;
	return ammo_amount;
}
METHOD(Nailgun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
