#include "super_nailgun.qh"

#ifdef SVQC
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
	if(toucher.takedamage && toucher.monsterdef != MON_CHTHON) // yoder mod, jan 05 2021
	{
		spawn_touchblood(this, 18, toucher);
		T_Damage(toucher, this, this.owner, 18, this.projectiledeathtype);
	}
	else
		te_superspike(this.origin);

	delete(this);

}

void W_FireSuperSpikes(entity this)
{
	makevectors(this.v_angle);

	if(this.ammo_nails < 2)
	{
		W_SwitchWeapon(this, W_BestWeapon(this, 0));
		return;
	}

	_sound(this, CH_WEAPON_SINGLE, "weapons/spike2.wav", 1, ATTN_NORM);
	this.attack_finished = time + 0.2;
	this.currentammo = this.ammo_nails = this.ammo_nails - 2;
	vector dir = qc_aim(this, 1000);
	entity newmis = launch_spike(this, this.origin + '0 0 16', dir);
	newmis.projectiledeathtype = WEP_SUPER_NAILGUN.m_id;
	if(MP_IMPEL)
		newmis.classname = "superspike";
	else
		newmis.classname = "super_spike";
	settouch(newmis, superspike_touch);
	_setmodel(newmis, "progs/s_spike.mdl");
	setsize(newmis, '0 0 0', '0 0 0');		
	this.punchangle_x = -2;
}

METHOD(SuperNailgun, wr_think, void(entity thiswep, entity actor))
{
	player_nail1(actor);
}
METHOD(SuperNailgun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
