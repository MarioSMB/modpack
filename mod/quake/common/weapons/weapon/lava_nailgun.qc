#include "lava_nailgun.qh"

#ifdef SVQC
void W_LavaNailgun_Attack(entity this)
{
	entity actor = this.owner;
	if(!actor.button0)
	{
		w_ready(this);
		return;
	}

	this.misc_bulletcounter += 1;

	player_nail1(actor);
	setthink(this, W_LavaNailgun_Attack);
	this.nextthink = time + 0.1;

	actor.effects |= EF_MUZZLEFLASH;

	this.m_frame += 1;
	if(this.m_frame >= 9)
		this.m_frame = 1;
	SuperDamageSound(actor);
	W_FireLavaSpikes(actor, ((this.misc_bulletcounter % 2) ? 3 : -3));
	actor.attack_finished = time + 0.2;
}

void W_FireLavaSpikes(entity this, float ox)
{
	makevectors(this.v_angle);

	if(this.ammo_lava_nails < 1)
	{
		// disabled notification to reduce spam
		//centerprint(this, "Out of Lava Nails");
		W_SwitchWeapon(this, w_getbestweapon(this));
		return;
	}

	_sound(this, CH_WEAPON_SINGLE, "weapons/rocket1i.wav", 1, ATTN_NORM);
	this.attack_finished = time + 0.2;
	this.ammo_lava_nails = this.ammo_lava_nails - 1;
	
	vector dir = qc_aim(this, 1000);
	entity missile = launch_lava_spike(this, this.origin + this.view_ofs + v_up * -8 + v_right * ox, dir);
	missile.projectiledeathtype = WEP_LAVA_NAILGUN.m_id;

	this.punchangle_x = -2;
}

METHOD(LavaNailgun, wr_think, void(entity thiswep, entity actor, int fire))
{
	if(fire & 1)
	if(thiswep.wr_checkammo1(thiswep, actor))
	{
		actor.lava_nailgun_fired = true;
		actor.weaponentity.misc_bulletcounter = 0;
		W_LavaNailgun_Attack(actor.weaponentity);
	}

	// TODO: reset sound on switch
	if(!(fire & 1) && actor.lava_nailgun_fired && time >= actor.attack_finished)
	{
		_sound(actor, CH_WEAPON_SINGLE, "lavagun/snail.wav", 1, ATTN_NORM);
		actor.lava_nailgun_fired = false;
	}
}
METHOD(LavaNailgun, wr_checkammo1, bool(entity thiswep, entity actor))
{
	float ammo_amount = actor.ammo_lava_nails >= 1;
	return ammo_amount;
}
METHOD(LavaNailgun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
