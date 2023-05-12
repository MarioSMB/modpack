#include "lava_nailgun.qh"

#ifdef SVQC
void player_lava_nail1(entity this)
{
	set_animofs(this, anim_player_nailatt1, 1, player_lava_nail2);

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
	W_FireLavaSpikes(this, 3);
	this.attack_finished = time + 0.2;
}
void player_lava_nail2(entity this)
{
	set_animofs(this, anim_player_nailatt1, 2, player_lava_nail1);

	this.effects |= EF_MUZZLEFLASH;

	if(!this.button0)
		{player_run(this);return;}
	this.weaponentity.m_frame += 1;
	if(this.weaponentity.m_frame >= 9)
		this.weaponentity.m_frame = 1;
	SuperDamageSound(this);
	W_FireLavaSpikes(this, -4);
	this.attack_finished = time + 0.2;
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
		player_lava_nail1(actor);
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
