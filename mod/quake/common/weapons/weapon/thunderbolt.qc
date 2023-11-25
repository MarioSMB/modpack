#include "thunderbolt.qh"

#ifdef SVQC
void W_Thunderbolt_Attack(entity this)
{
	entity actor = this.owner;
	if(!actor.button0)
	{
		w_ready(this);
		return;
	}

	player_light1(actor);
	setthink(this, W_Thunderbolt_Attack);
	this.nextthink = time + 0.1;

	actor.effects |= EF_MUZZLEFLASH;

	this.m_frame += 1;
	if(this.m_frame >= 5)
		this.m_frame = 1;
	SuperDamageSound(actor);
	W_FireLightning(actor);
	actor.attack_finished = time + 0.2;
}

void W_FireLightning(entity this)
{
	if(this.ammo_cells < 1)
	{
		W_SwitchWeapon(this, w_getbestweapon(this));
		return;
	}

// explode if under water
	if(this.waterlevel > 1)
	{
		int cells = this.ammo_cells;
		this.ammo_cells = 0;
		W_SetCurrentAmmo(this);
		discharged = true;
		T_RadiusDamage(this, this, 35 * cells, DEATH_DISCHARGE.m_id, NULL);
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

	this.ammo_cells = this.ammo_cells - 1;

	vector org = this.origin + '0 0 16';

	traceline(org, org + v_forward*600, MOVE_NOMONSTERS, this);

	//te_lightning2(NULL, org, trace_endpos);
	SendCSQCLightningBeam(org, trace_endpos);
	// prototype for flamethrower visuals
	//Send_Effect(EFFECT_FLAMER, this.origin, v_forward*100, 1);

	LightningDamage(org, trace_endpos + v_forward*4, this, 30, WEP_LIGHTNING.m_id);
}

METHOD(Thunderbolt, wr_think, void(entity thiswep, entity actor, int fire))
{
	if(fire & 1)
	if(thiswep.wr_checkammo1(thiswep, actor))
	{
		W_Thunderbolt_Attack(actor.weaponentity);
		actor.attack_finished = time + 0.1;
		_sound(actor, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
	}
}
METHOD(Thunderbolt, wr_checkammo1, bool(entity thiswep, entity actor))
{
	float ammo_amount = actor.ammo_cells >= 1;
	return ammo_amount;
}
METHOD(Thunderbolt, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
