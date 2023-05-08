#include "laser_cannon.qh"

#ifdef SVQC
//MED 10/18/96 added HIPSWEAPONS
//void() player_laser1   =[$nailatt1, player_laser2  ] {this.attack_finished = time + 0.1;this.weaponentity.m_frame=1;this.nextthink = time + 0.09;HIP_FireLaser(0);}
//void() player_laser2   =[$nailatt2, player_laser4  ] {this.attack_finished = time + 0.1;this.weaponentity.m_frame=2;this.nextthink = time + 0.09;}
//void() player_laser3   =[$nailatt1, player_laser4  ] {this.attack_finished = time + 0.1;this.weaponentity.m_frame=3;this.nextthink = time + 0.09;}
//void() player_laser4   =[$nailatt2, player_laser5  ] {this.attack_finished = time + 0.1;this.weaponentity.m_frame=4;this.nextthink = time + 0.09;HIP_FireLaser(1);}
//void() player_laser5   =[$nailatt1, player_laser1  ] {this.attack_finished = time + 0.1;this.weaponentity.m_frame=5;this.nextthink = time + 0.09;}
//void() player_laser6   =[$nailatt2, player_laser1  ] {this.attack_finished = time + 0.1;this.weaponentity.m_frame=6;this.nextthink = time + 0.09;}
void player_laser4(entity this) { set_animofs(this, anim_player_nailatt1, 1, player_laser1); this.attack_finished = time + 0.1; this.weaponentity.m_frame = 5; this.nextthink = time + 0.1; }
void player_laser3(entity this) { set_animofs(this, anim_player_nailatt1, 2, player_laser1); this.attack_finished = time + 0.1; this.weaponentity.m_frame = 4; this.nextthink = time + 0.1; HIP_FireLaser(this, 1); }
void player_laser2(entity this) { set_animofs(this, anim_player_nailatt1, 2, player_laser3); this.attack_finished = time + 0.1; this.weaponentity.m_frame = 2; this.nextthink = time + 0.1; }
void player_laser1(entity this) { set_animofs(this, anim_player_nailatt1, 1, player_laser3); this.attack_finished = time + 0.1; this.weaponentity.m_frame = 1; this.nextthink = time + 0.1; HIP_FireLaser(this, 0); }

void HIP_FireLaser(entity this, float stat)
{
	if(!this.button0)
	{
		player_run(this);
		return;
	}
	if(this.ammo_cells < 1)
	{
		W_SwitchWeapon(this, w_getbestweapon(this));
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
		this.ammo_cells = this.ammo_cells - 1;
		org = org +(aofs*v_right);
		org = org -(aofs*v_up);
		HIP_LaunchLaser(this, org, dir, 0);
		org = org -(2*aofs*v_right);
		HIP_LaunchLaser(this, org, dir, 0);
	}
	else if(stat == 1)
	{
		this.ammo_cells = this.ammo_cells - 1;
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
METHOD(LaserCannon, wr_checkammo1, bool(entity thiswep, entity actor))
{
	float ammo_amount = actor.ammo_cells >= 1;
	return ammo_amount;
}
METHOD(LaserCannon, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
