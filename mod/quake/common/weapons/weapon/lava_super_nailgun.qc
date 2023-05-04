#include "lava_super_nailgun.qh"

#ifdef SVQC
void W_FireSuperLavaSpikes(entity this)
{
	makevectors(this.v_angle);

	if(this.ammo_lava_nails < 2)
	{
		// disabled notification to reduce spam
		//centerprint(this, "Out of Lava Nails");
		W_SwitchWeapon(this, W_BestWeapon(this, 0));
		return;
	}

	_sound(this, CH_WEAPON_SINGLE, "weapons/spike2.wav", 1, ATTN_NORM);
	this.attack_finished = time + 0.2;
	this.currentammo = this.ammo_lava_nails = this.ammo_lava_nails - 2;
	
	vector dir = qc_aim(this, 1000);
	entity newmis = launch_lava_spike(this, this.origin + '0 0 16', dir);
	settouch(newmis, superlavaspike_touch);

//	setmodel(newmis, "progs/lspike.mdl");			

	setsize(newmis, '0 0 0', '0 0 0');		
	this.punchangle_x = -2;
}

METHOD(LavaSuperNailgun, wr_think, void(entity thiswep, entity actor))
{
	actor.lavaGunFired = true;
	player_lava_nail1(actor);
}
METHOD(LavaSuperNailgun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
