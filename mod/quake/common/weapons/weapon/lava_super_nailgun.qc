#include "lava_super_nailgun.qh"

#ifdef SVQC
void player_lava_super_nail1(entity this)
{
	set_animofs(this, anim_player_nailatt1, 1, player_lava_super_nail2);

	this.effects |= EF_MUZZLEFLASH;

	if(!this.button0)
	{
		player_run(this);
		return;
	}
	this.weaponentity.m_frame += 1;
	if(this.weaponentity.m_frame >= 9)
		this.weaponentity.m_frame = 1;
	SuperDamageSound(this);
	W_FireSuperLavaSpikes(this);
	this.attack_finished = time + 0.2;
}
void player_lava_super_nail2(entity this)
{
	set_animofs(this, anim_player_nailatt1, 2, player_lava_super_nail1);

	this.effects |= EF_MUZZLEFLASH;

	if(!this.button0)
		{player_run(this);return;}
	this.weaponentity.m_frame += 1;
	if(this.weaponentity.m_frame >= 9)
		this.weaponentity.m_frame = 1;
	SuperDamageSound(this);
	W_FireSuperLavaSpikes(this);
	this.attack_finished = time + 0.2;
}

void W_FireSuperLavaSpikes(entity this)
{
	makevectors(this.v_angle);

	if(this.ammo_lava_nails < 2)
	{
		// disabled notification to reduce spam
		//centerprint(this, "Out of Lava Nails");
		W_SwitchWeapon(this, w_getbestweapon(this));
		return;
	}

	_sound(this, CH_WEAPON_SINGLE, "weapons/spike2.wav", 1, ATTN_NORM);
	this.attack_finished = time + 0.2;
	this.ammo_lava_nails = this.ammo_lava_nails - 2;
	
	vector dir = qc_aim(this, 1000);
	entity newmis = launch_lava_spike(this, this.origin + '0 0 16', dir);
	newmis.projectiledeathtype = WEP_LAVA_SUPER_NAILGUN.m_id;
	settouch(newmis, superlavaspike_touch);

//	setmodel(newmis, "progs/lspike.mdl");			

	setsize(newmis, '0 0 0', '0 0 0');		
	this.punchangle_x = -2;
}

METHOD(LavaSuperNailgun, wr_think, void(entity thiswep, entity actor))
{
	actor.lavaGunFired = true;
	player_lava_super_nail1(actor);
}
METHOD(LavaSuperNailgun, wr_checkammo1, bool(entity thiswep, entity actor))
{
	float ammo_amount = actor.ammo_lava_nails >= 2;
	return ammo_amount;
}
METHOD(LavaSuperNailgun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
