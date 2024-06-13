#include "super_nailgun.qh"

#ifdef SVQC
void W_SuperNailgun_Attack(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;
	if(!actor.button0)
	{
		w_ready(this);
		return;
	}

	if(IS_PLAYER(actor))
		player_nail1(actor);

	actor.effects |= EF_MUZZLEFLASH;

	this.m_frame += 1;
	if(this.m_frame >= 9)
		this.m_frame = 1;
	wep_set_anim(this, this.m_frame, W_SuperNailgun_Attack);
	SuperDamageSound(actor);
	W_FireSuperSpikes(actor, weaponentity);
	ATTACK_FINISHED(actor, weaponentity) = time + 0.2;
}

void superspike_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
// hit something that bleeds
	if(toucher.takedamage) // yoder mod, jan 05 2021
	{
		spawn_touchblood(this, 18, toucher);
		T_Damage(toucher, this, this.owner, 18, this.projectiledeathtype);
	}
	else
		te_superspike(this.origin);

	delete(this);

}

void W_FireSuperSpikes(entity this, .entity weaponentity)
{
	makevectors(this.v_angle);

	if(this.ammo_nails < 2)
	{
		ATTACK_FINISHED(this, weaponentity) = time + 0.5;
		W_SwitchWeapon(this, w_getbestweapon(this, weaponentity), weaponentity);
		return;
	}

	_sound(this, CH_WEAPON_SINGLE, "weapons/spike2.wav", 1, ATTN_NORM);
	ATTACK_FINISHED(this, weaponentity) = time + 0.2;
	W_TakeAmmo(this, ammo_nails, 2);
	vector dir = qc_aim(this, 1000);
	entity newmis = launch_spike(this, W_Shotorg(this, weaponentity), dir);
	newmis.projectiledeathtype = WEP_SUPER_NAILGUN.m_id;
	newmis.classname = "super_spike";
	settouch(newmis, superspike_touch);
	_setmodel(newmis, "progs/s_spike.mdl");
	setsize(newmis, '0 0 0', '0 0 0');		
	this.punchangle_x = -2;
}

METHOD(SuperNailgun, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
		W_SuperNailgun_Attack(actor.(weaponentity));
}
METHOD(SuperNailgun, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_nails >= 2;
	return ammo_amount;
}
METHOD(SuperNailgun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
