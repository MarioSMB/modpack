#include "lava_nailgun.qh"

#ifdef SVQC
void W_FireLavaSpikes(entity this, float ox)
{
	makevectors(this.v_angle);

	if(this.ammo_lava_nails < 1)
	{
		// disabled notification to reduce spam
		//centerprint(this, "Out of Lava Nails");
		W_SwitchWeapon(this, W_BestWeapon(this, 0));
		return;
	}

	_sound(this, CH_WEAPON_SINGLE, "weapons/rocket1i.wav", 1, ATTN_NORM);
	this.attack_finished = time + 0.2;
	this.currentammo = this.ammo_lava_nails = this.ammo_lava_nails - 1;
	
	vector dir = qc_aim(this, 1000);
	entity missile = launch_lava_spike(this, this.origin + this.view_ofs + v_up * -8 + v_right * ox, dir);
	missile.projectiledeathtype = WEP_LAVA_NAILGUN.m_id;

	this.punchangle_x = -2;
}

METHOD(LavaNailgun, wr_think, void(entity thiswep, entity actor))
{
	actor.lavaGunFired = true;
	player_lava_nail1(actor);
}
METHOD(LavaNailgun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
