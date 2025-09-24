#include "smg.qh"

#ifdef SVQC
PRECACHE(SubMachineGun)
{
	precache_model("progs/v_smg.mdl");
	precache_model("progs/g_smg.mdl");

	precache_model("progs/ee_p_pm_yl.mdl");

	//precache_sound("weapons/dsfirxpl.wav");
	precache_sound("weapons/hplasma.wav");
}

void W_SubMachineGun_Attack(entity this)
{
	entity actor = this.owner;
	.entity weaponentity = this.weaponentity_fld;
	if(!actor.button0)
	{
		w_ready(this);
		return;
	}

	this.misc_bulletcounter += 1;

	if(IS_PLAYER(actor))
	{
		if(actor.m_champion != CHAMPION_Valkyrie)
			player_nail1(actor);
	}

	actor.effects |= EF_MUZZLEFLASH;

	this.m_frame += 1;
	if(this.m_frame >= 9)
		this.m_frame = 1;
	wep_set_anim(this, this.m_frame, W_SubMachineGun_Attack);
	SuperDamageSound(actor);
	W_FireSubMachineGun(actor, ((this.misc_bulletcounter % 2) ? 3 : -3), weaponentity);
	ATTACK_FINISHED(actor, weaponentity) = time + 0.1;
}

void W_FireSubMachineGun(entity this, float ox, .entity weaponentity)
{
	makevectors(this.v_angle);

	_sound(this, CH_WEAPON_SINGLE, "weapons/hplasma.wav", 1, ATTN_NORM);
	ATTACK_FINISHED(this, weaponentity) = time + 0.1;
	vector dir = qc_aim(this, 3000);
	// NOTE: position fix by Seven and Sajt applied here
	entity missile = launch_spike(this, W_Shotorg(this, weaponentity) + v_right * ox, dir);
	missile.velocity = dir * 3000;
	missile.classname = "smg_bolt";
	missile.projectiledeathtype = WEP_NAILGUN.m_id;
	_setmodel(missile, "progs/ee_p_pm_yl.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	//missile.noise = "weapons/dsfirxpl.wav";
	missile.dmg = 15;

	this.punchangle_x = -2;
}

METHOD(SubMachineGun, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	{
		actor.(weaponentity).misc_bulletcounter = 0;
		W_SubMachineGun_Attack(actor.(weaponentity));
	}
}
METHOD(SubMachineGun, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	// no ammo consumption
	return true;
}
METHOD(SubMachineGun, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(SubMachineGun, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
