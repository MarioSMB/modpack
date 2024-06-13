#include "thunderbolt.qh"

#ifdef SVQC
void W_Thunderbolt_Attack(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;
	if(!actor.button0)
	{
		w_ready(this);
		return;
	}

	if(IS_PLAYER(actor))
		player_light1(actor);

	actor.effects |= EF_MUZZLEFLASH;

	this.m_frame += 1;
	if(this.m_frame >= 5)
		this.m_frame = 1;
	wep_set_anim(this, this.m_frame, W_Thunderbolt_Attack);
	SuperDamageSound(actor);
	W_FireLightning(actor, weaponentity);
	ATTACK_FINISHED(actor, weaponentity) = time + 0.2;
}

void W_FireLightning(entity this, .entity weaponentity)
{
	if(this.ammo_cells < 1)
	{
		ATTACK_FINISHED(this, weaponentity) = time + 0.5;
		W_SwitchWeapon(this, w_getbestweapon(this, weaponentity), weaponentity);
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

	W_TakeAmmo(this, ammo_cells, 1);

	vector org = W_Shotorg(this, weaponentity);

	traceline(org, org + v_forward*600, MOVE_NOMONSTERS, this);

	//te_lightning2(NULL, org, trace_endpos);
	SendCSQCLightningBeam(org, trace_endpos);
	// prototype for flamethrower visuals
	//Send_Effect(EFFECT_FLAMER, this.origin, v_forward*100, 1);

	LightningDamage(org, trace_endpos + v_forward*4, this, 30, WEP_LIGHTNING.m_id);
}

METHOD(Thunderbolt, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		W_Thunderbolt_Attack(actor.(weaponentity));
		ATTACK_FINISHED(actor, weaponentity) = time + 0.2;
		_sound(actor, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
	}
}
METHOD(Thunderbolt, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_cells >= 1;
	return ammo_amount;
}
METHOD(Thunderbolt, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
#endif
