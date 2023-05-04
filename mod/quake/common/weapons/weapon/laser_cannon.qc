#include "laser_cannon.qh"

#ifdef SVQC
void HIP_FireLaser(entity this, float stat)
{
	if(!this.button0)
	{
		player_run(this);
		return;
	}
	if(this.ammo_cells < 1)
	{
		W_SwitchWeapon(this, W_BestWeapon(this, 0));
		return;
	}
	SuperDamageSound(this);
	this.effects |= EF_MUZZLEFLASH;
	makevectors(this.v_angle);

	float ofs = 6;
	vector out = vec2(v_forward);
	out = normalize(out);
	vector org = this.origin +((12-ofs) * v_up) +(12*out);
//   org = this.origin +(1*v_forward);
	vector dir = qc_aim(this, 1000);
	float aofs = ofs * 0.707;
	if(stat == 0)
	{
		this.currentammo = this.ammo_cells = this.ammo_cells - 1;
		org = org +(aofs*v_right);
		org = org -(aofs*v_up);
		HIP_LaunchLaser(this, org, dir, 0);
		org = org -(2*aofs*v_right);
		HIP_LaunchLaser(this, org, dir, 0);
	}
	else if(stat == 1)
	{
		this.currentammo = this.ammo_cells = this.ammo_cells - 1;
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

METHOD(LaserCannon, wr_think, void(entity thiswep, entity actor))
{
	player_laser1(actor);
}
METHOD(LaserCannon, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
