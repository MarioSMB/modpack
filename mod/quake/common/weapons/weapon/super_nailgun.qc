#include "super_nailgun.qh"

#ifdef SVQC
void player_supernail1(entity this)
{
	set_animofs(this, anim_player_nailatt1, 1, player_supernail2);

	this.effects |= EF_MUZZLEFLASH;

	if(!this.button0)
		{player_run(this);return;}
	this.weaponentity.m_frame += 1;
	if(this.weaponentity.m_frame >= 9)
		this.weaponentity.m_frame = 1;
	SuperDamageSound(this);
	W_FireSuperSpikes(this);
	this.attack_finished = time + 0.2;
}
void player_supernail2(entity this)
{
	set_animofs(this, anim_player_nailatt1, 2, player_supernail1);

	this.effects |= EF_MUZZLEFLASH;

	if(!this.button0)
		{player_run(this);return;}
	this.weaponentity.m_frame += 1;
	if(this.weaponentity.m_frame >= 9)
		this.weaponentity.m_frame = 1;
	SuperDamageSound(this);
	W_FireSuperSpikes(this);
	this.attack_finished = time + 0.2;
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

void W_FireSuperSpikes(entity this)
{
	makevectors(this.v_angle);

	if(this.ammo_nails < 2)
	{
		W_SwitchWeapon(this, w_getbestweapon(this));
		return;
	}

	_sound(this, CH_WEAPON_SINGLE, "weapons/spike2.wav", 1, ATTN_NORM);
	this.attack_finished = time + 0.2;
	this.ammo_nails = this.ammo_nails - 2;
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
	player_supernail1(actor);
}
METHOD(SuperNailgun, wr_checkammo1, bool(entity thiswep, entity actor))
{
	float ammo_amount = actor.ammo_nails >= 2;
	return ammo_amount;
}
METHOD(SuperNailgun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
