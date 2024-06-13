#include "lava_super_nailgun.qh"

#ifdef SVQC
void W_LavaSuperNailgun_Attack(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;
	if(!actor.button0)
	{
		w_ready(this);
		return;
	}

	this.misc_bulletcounter += 1;

	if(IS_PLAYER(actor))
		player_nail1(actor);

	actor.effects |= EF_MUZZLEFLASH;

	this.m_frame += 1;
	if(this.m_frame >= 9)
		this.m_frame = 1;
	wep_set_anim(this, this.m_frame, W_LavaSuperNailgun_Attack);
	SuperDamageSound(actor);
	W_FireSuperLavaSpikes(actor, weaponentity);
	ATTACK_FINISHED(actor, weaponentity) = time + 0.2;
}

void W_FireSuperLavaSpikes(entity this, .entity weaponentity)
{
	makevectors(this.v_angle);

	if(this.ammo_lava_nails < 2)
	{
		// disabled notification to reduce spam
		//centerprint(this, "Out of Lava Nails");
		ATTACK_FINISHED(this, weaponentity) = time + 0.5;
		W_SwitchWeapon(this, w_getbestweapon(this, weaponentity), weaponentity);
		return;
	}

	_sound(this, CH_WEAPON_SINGLE, "weapons/spike2.wav", 1, ATTN_NORM);
	W_TakeAmmo(this, ammo_lava_nails, 2);
	
	vector dir = qc_aim(this, 1000);
	entity newmis = launch_lava_spike(this, W_Shotorg(this, weaponentity), dir);
	newmis.projectiledeathtype = WEP_LAVA_SUPER_NAILGUN.m_id;
	settouch(newmis, superlavaspike_touch);

//	setmodel(newmis, "progs/lspike.mdl");			

	setsize(newmis, '0 0 0', '0 0 0');		
	this.punchangle_x = -2;
}

METHOD(LavaSuperNailgun, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		actor.lava_super_nailgun_fired = true;
		W_LavaSuperNailgun_Attack(actor.(weaponentity));
	}

	if(!(fire & 1) && actor.lava_super_nailgun_fired && time >= ATTACK_FINISHED(actor, weaponentity))
	{
		_sound(actor, CH_WEAPON_SINGLE, "lavagun/snail.wav", 1, ATTN_NORM);
		actor.lava_super_nailgun_fired = false;
	}

}
METHOD(LavaSuperNailgun, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_lava_nails >= 2;
	return ammo_amount;
}
METHOD(LavaSuperNailgun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
