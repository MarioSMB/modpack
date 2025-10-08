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

void minishark_bullet_touch(entity this, entity toucher)
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
	W_TakeAmmo(this, ammo_nails, 1);
	vector dir = qc_aim(this, 1000);
	entity newmis = launch_spike(this, W_Shotorg(this, weaponentity) + v_right * 3, dir);
	newmis.projectiledeathtype = WEP_MINISHARK.m_id;
	newmis.classname = "minishark_bullet";
	settouch(newmis, minishark_bullet_touch);
	//_setmodel(newmis, "progs/s_spike.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	CSQCProjectile(newmis, true, PROJECTILE_SUPER_SPIKE, true);

	this.punchangle_x = -2;
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
