#include "minishark.qh"

#ifdef SVQC
PRECACHE(Minishark)
{
	precache_model("progs/v_minishark.mdl");
	precache_model("progs/g_minishark.mdl");

	precache_sound("weapons/minishark_fire.wav");
}

void W_Minishark_Attack(entity this)
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
	wep_set_anim(this, this.m_frame, W_Minishark_Attack);
	SuperDamageSound(actor);
	W_FireMinishark(actor, weaponentity);
	ATTACK_FINISHED(actor, weaponentity) = time + 0.2;
}

void W_FireMinishark(entity this, .entity weaponentity)
{
	makevectors(this.v_angle);

	if(this.ammo_nails < 1)
	{
		ATTACK_FINISHED(this, weaponentity) = time + 0.5;
		W_SwitchWeapon(this, w_getbestweapon(this, weaponentity), weaponentity);
		return;
	}

	_sound(this, CH_WEAPON_SINGLE, "weapons/minishark_fire.wav", 1, ATTN_NORM);
	ATTACK_FINISHED(this, weaponentity) = time + 0.2;
	W_TakeAmmo(this, IT_NAILS, 1);

	Projectile ptype = PROJECTILE_MINISHARK_BULLET;
	vector org = W_Shotorg(this, weaponentity) + v_right * 4;
	vector dir = qc_aim_fromorg(this, org, ptype.m_speed);

	Projectile_Create(ptype, this, org, dir, WEP_MINISHARK.m_id);

	this.punchangle_x = -2 * autocvar_sv_quake_recoil;
}

METHOD(Minishark, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
		W_Minishark_Attack(actor.(weaponentity));
}
METHOD(Minishark, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	float ammo_amount = actor.ammo_nails >= 1;
	return ammo_amount;
}
METHOD(Minishark, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Minishark, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
