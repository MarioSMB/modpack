#include "laser_cannon.qh"

#ifdef SVQC
void player_laser2(entity this) { set_animofs(this, anim_player_nailatt1, 2, player_run); }
void player_laser1(entity this) { set_animofs(this, anim_player_nailatt1, 1, player_laser2); }

// TODO: wtf
void wep_lasercannon_laser1(entity this);
void wep_lasercannon_laser2(entity this) { wep_set_anim(this, 4, wep_lasercannon_laser1); HIP_FireLaser(this.owner, 1, this.weaponentity_fld); }
void wep_lasercannon_laser1(entity this) { wep_set_anim(this, 1, wep_lasercannon_laser2); HIP_FireLaser(this.owner, 0, this.weaponentity_fld); }

void HIP_FireLaser(entity this, float stat, .entity weaponentity)
{
	if(!this.button0)
	{
		w_ready(this.(weaponentity));
		return;
	}
	if(this.ammo_cells < 1)
	{
		ATTACK_FINISHED(this, weaponentity) = time + 0.5;
		W_SwitchWeapon(this, w_getbestweapon(this, weaponentity), weaponentity);
		return;
	}
	if(IS_PLAYER(this))
		player_laser1(this);
	SuperDamageSound(this);
	this.effects |= EF_MUZZLEFLASH;
	ATTACK_FINISHED(this, weaponentity) = time + 0.2;
	makevectors(this.v_angle);

	float ofs = 6;
	vector out = vec2(v_forward);
	out = normalize(out);
	vector org = W_Shotorg(this, weaponentity) + (12 * out);
//   org = this.origin +(1*v_forward);
	vector dir = qc_aim(this, 1000);
	float aofs = ofs * 0.707;
	if(stat == 0)
	{
		W_TakeAmmo(this, ammo_cells, 1);
		org = org +(aofs*v_right);
		org = org -(aofs*v_up);
		HIP_LaunchLaser(this, org, dir, 0);
		org = org -(2*aofs*v_right);
		HIP_LaunchLaser(this, org, dir, 0);
	}
	else if(stat == 1)
	{
		W_TakeAmmo(this, ammo_cells, 1);
		org = org +(ofs*v_up);
		if(random() < 0.1)
		{
			entity missile = HIP_LaunchLaser(this, org, dir, 1);
			missile.dmg = 25;
		}
		else
			HIP_LaunchLaser(this, org, dir, 0);
	}
	this.punchangle_x = -1;
}

METHOD(LaserCannon, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
		wep_lasercannon_laser1(actor.(weaponentity));
}
METHOD(LaserCannon, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_cells >= 1;
	return ammo_amount;
}
METHOD(LaserCannon, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
