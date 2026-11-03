#include "megashark.qh"

#ifdef SVQC
PRECACHE(Megashark)
{
	precache_model("progs/v_megashark.mdl");
	precache_model("progs/g_megashark.mdl");

	precache_sound("weapons/megashark_fire.wav");
}

void W_Megashark_Attack(entity this)
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
	if(this.m_frame > 5)
		this.m_frame = 1;
	wep_set_anim(this, this.m_frame, W_Megashark_Attack);
	SuperDamageSound(actor);
	W_FireMegashark(actor, weaponentity);
	ATTACK_FINISHED(actor, weaponentity) = time + 0.2;
}

void W_FireMegashark(entity this, .entity weaponentity)
{
	makevectors(this.v_angle);

	if(this.ammo_nails < 2)
	{
		ATTACK_FINISHED(this, weaponentity) = time + 0.5;
		W_SwitchWeapon(this, w_getbestweapon(this, weaponentity), weaponentity);
		return;
	}

	_sound(this, CH_WEAPON_SINGLE, "weapons/megashark_fire.wav", 1, ATTN_NORM);
	ATTACK_FINISHED(this, weaponentity) = time + 0.2;
	W_TakeAmmo(this, IT_NAILS, 2);

	Projectile ptype = PROJECTILE_MEGASHARK_BULLET;
	vector org = W_Shotorg(this, weaponentity) + v_right * 4 + v_up * 2;
	vector dir = qc_aim_fromorg(this, org, ptype.m_speed);

	Projectile_Create(ptype, this, org, dir, WEP_MEGASHARK.m_id);

	this.punchangle_x = -2 * autocvar_sv_quake_recoil;
}

METHOD(Megashark, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
		W_Megashark_Attack(actor.(weaponentity));
}
METHOD(Megashark, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_nails >= 2;
	return ammo_amount;
}
METHOD(Megashark, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Megashark, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
