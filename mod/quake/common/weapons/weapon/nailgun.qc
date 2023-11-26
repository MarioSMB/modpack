#include "nailgun.qh"

#ifdef SVQC
void W_Nailgun_Attack(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;
	if(!actor.button0)
	{
		w_ready(this);
		return;
	}

	this.misc_bulletcounter += 1;

	player_nail1(actor);
	setthink(this, W_Nailgun_Attack);
	this.nextthink = time + 0.1;

	actor.effects |= EF_MUZZLEFLASH;

	this.m_frame += 1;
	if(this.m_frame >= 9)
		this.m_frame = 1;
	SuperDamageSound(actor);
	W_FireSpikes(actor, ((this.misc_bulletcounter % 2) ? 3 : -3), weaponentity);
	ATTACK_FINISHED(actor, weaponentity) = time + 0.2;
}

void W_FireSpikes(entity this, float ox, .entity weaponentity)
{
	makevectors(this.v_angle);

	if(this.ammo_nails < 1)
	{
		W_SwitchWeapon(this, w_getbestweapon(this, weaponentity), weaponentity);
		return;
	}

	if(this.silencer)
		_sound(this, CH_WEAPON_SINGLE, "weapons/rocketli.wav", 0.2, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "weapons/rocket1i.wav", 1, ATTN_NORM);
	ATTACK_FINISHED(this, weaponentity) = time + 0.2;
	this.ammo_nails = this.ammo_nails - 1;
	vector dir = qc_aim(this, 1000);
	// NOTE: position fix by Seven and Sajt applied here
	entity missile = launch_spike(this, W_Shotorg(this, weaponentity) + v_up * -8 + v_right * ox, dir);
	missile.projectiledeathtype = WEP_NAILGUN.m_id;

	this.punchangle_x = -2;
}

METHOD(Nailgun, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		actor.(weaponentity).misc_bulletcounter = 0;
		W_Nailgun_Attack(actor.(weaponentity));
	}
}
METHOD(Nailgun, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_nails >= 1;
	return ammo_amount;
}
METHOD(Nailgun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
