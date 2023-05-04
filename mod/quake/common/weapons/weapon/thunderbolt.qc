#include "thunderbolt.qh"

#ifdef SVQC
void W_FireLightning(entity this)
{
	if(this.ammo_cells < 1)
	{
		W_SwitchWeapon(this, W_BestWeapon(this, 0));
		return;
	}

// explode if under water
	if(this.waterlevel > 1)
	{
		int cells = this.ammo_cells;
		this.ammo_cells = 0;
		W_SetCurrentAmmo(this);
		discharged = true;
		T_RadiusDamage(this, this, 35 * cells, NULL);
		discharged = false;
		return;
	}

	makevectors(this.v_angle);

	if(this.t_width < time)
	{
		_sound(this, CH_WEAPON_SINGLE, "weapons/lhit.wav", 1, ATTN_NORM);
		this.t_width = time + 0.6;
	}
	this.punchangle_x = -2;

	this.currentammo = this.ammo_cells = this.ammo_cells - 1;

	vector org = this.origin + '0 0 16';

	traceline(org, org + v_forward*600, MOVE_NOMONSTERS, this);

	//te_lightning2(NULL, org, trace_endpos);
	SendCSQCLightningBeam(org, trace_endpos);

	LightningDamage(org, trace_endpos + v_forward*4, this, 30);
}

METHOD(Thunderbolt, wr_think, void(entity thiswep, entity actor))
{
	player_light1(actor);
	actor.attack_finished = time + 0.1;
	_sound(actor, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
}
METHOD(Thunderbolt, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
